--[[
    VALT :: REAL KATIO PET
    Clean recode of the decompiled script.

    Cosmetic group gate removed entirely.
]]

--=====================================================================
-- Services
--=====================================================================
local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local Workspace         = game:GetService("Workspace")
local Debris            = game:GetService("Debris")

local LocalPlayer = Players.LocalPlayer
local Camera      = Workspace.CurrentCamera

--=====================================================================
-- Kill previous instance
--=====================================================================
if getgenv().__VALT_SPAWNER then
    pcall(getgenv().__VALT_SPAWNER.unload)
end

--=====================================================================
-- Config
--=====================================================================
local CONFIG = {
    MAX_SPAWNS     = 40,
    SPAWN_DISTANCE = 12,
    SCALE_MULT     = 1,

    SPIN           = true,
    FLOAT          = false,
    OWN_PLOT_ONLY  = true,
    GROUND         = true,
    ANIMATE        = true,
    NAMETAG        = true,
    ANCHORED       = true,

    GRID_COLUMNS   = (UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled) and 2 or 3,

    GIVE_TOOL      = true,
    HAND_MAX_STUDS = 4,

    MONEY_POPUP    = true,
    PAY_INTERVAL   = 1,
    CASH_VISUAL    = true,
}

--=====================================================================
-- State
--=====================================================================
local running      = true
local connections  = {}
local activeSpawns = {}
local activeTools  = {}
local pets         = {}
local rarityList   = { "All" }
local rarityRank   = {}
local selectedPet  = nil
local filter       = { text = "", rarity = "All" }

local UI = {
    window      = nil,
    gridTab     = nil,
    rows        = {},
    viewport    = nil,
    counter     = nil,
    previewInfo = nil,
}

--=====================================================================
-- Utility
--=====================================================================
local function track(conn)
    connections[#connections + 1] = conn
    return conn
end

local function abbreviateNumber(n)
    n = tonumber(n) or 0
    local units = {
        { 1e12, "T" },
        { 1e9,  "B" },
        { 1e6,  "M" },
        { 1e3,  "K" },
    }
    for _, unit in ipairs(units) do
        if n >= unit[1] then
            return string.format("%.2f", n / unit[1]):gsub("%.?0+$", "") .. unit[2]
        end
    end
    return tostring(math.floor(n))
end

local function getCharacterRoot()
    local char = LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
end

--=====================================================================
-- Parse assets
--=====================================================================
local Directory = require(ReplicatedStorage.Data.Assets).Directory

for key, entry in pairs(Directory) do
    local rarityInfo  = entry.Rarity or {}
    local rarityName  = tostring(rarityInfo._id or rarityInfo.DisplayName or "Unknown")

    local pet = {
        id       = key,
        name     = tostring(entry.DisplayName or key),
        icon     = tostring(entry.Icon or ""),
        eggIcon  = entry.Egg and tostring(entry.Egg.Icon or "") or "",
        rarity   = rarityName,
        rank     = tonumber(rarityInfo.RarityNumber) or 0,
        color    = typeof(rarityInfo.Color) == "Color3" and rarityInfo.Color or Color3.fromRGB(200, 200, 200),
        rate     = tonumber(entry.EarningRate) or 0,
        scale    = tonumber(entry.BaseModelScale) or 1,
        idle     = entry.Animations and entry.Animations.Idle or nil,
    }

    pets[#pets + 1] = pet

    if rarityRank[rarityName] == nil then
        rarityRank[rarityName] = pet.rank
        rarityList[#rarityList + 1] = rarityName
    end
end

table.sort(pets, function(a, b)
    if a.rank ~= b.rank then return a.rank > b.rank end
    return a.name < b.name
end)

table.sort(rarityList, function(a, b)
    if a == "All" then return true end
    if b == "All" then return false end
    return (rarityRank[a] or 0) > (rarityRank[b] or 0)
end)

--=====================================================================
-- World helpers
--=====================================================================
local function getSpawnFolder()
    local folder = Workspace:FindFirstChild("__ValtSpawns")
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = "__ValtSpawns"
        folder.Parent = Workspace
    end
    return folder
end

local function getOwnPlot()
    local plots = Workspace:FindFirstChild("Plots")
    if not plots then return nil end

    local myName = LocalPlayer.Name
    for _, plot in ipairs(plots:GetChildren()) do
        local sign = plot:FindFirstChild("PlotSign")
        if sign then
            for _, d in ipairs(sign:GetDescendants()) do
                if d:IsA("TextLabel") and d.Text == myName then
                    return plot
                end
            end
        end
    end
    return nil
end

local function getPlotSpawnPosition(index)
    local plot = getOwnPlot()
    if not plot then return nil end

    local center = plot:FindFirstChild("CenterPoint") or plot:FindFirstChild("SpawnPoint")
    if not center then return nil end

    local i      = index or 0
    local angle  = (i % 10) * (math.pi * 0.2)
    local radius = math.floor(i / 10) * 3.5 + 5

    return center.Position + Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
end

local function resolveGroundPosition(pos, model)
    if not CONFIG.GROUND then
        return pos + Vector3.new(0, model:GetExtentsSize().Y * 0.5, 0)
    end

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = { model, LocalPlayer.Character, getSpawnFolder() }
    params.IgnoreWater = true

    local result = Workspace:Raycast(pos + Vector3.new(0, 40, 0), Vector3.new(0, -300, 0), params)
    local y = result and result.Position.Y or pos.Y

    return Vector3.new(pos.X, y + model:GetExtentsSize().Y * 0.5, pos.Z)
end

--=====================================================================
-- Visual setup
--=====================================================================
local function attachNametag(model, pet)
    local primary = model.PrimaryPart
    if not primary then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ValtTag"
    billboard.Size = UDim2.fromOffset(220, 72)
    billboard.StudsOffsetWorldSpace = Vector3.new(0, model:GetExtentsSize().Y * 0.65 + 2, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 400
    billboard.Parent = primary

    if pet.icon ~= "" then
        local img = Instance.new("ImageLabel")
        img.BackgroundTransparency = 1
        img.AnchorPoint = Vector2.new(0.5, 0)
        img.Position = UDim2.new(0.5, 0, 0, 0)
        img.Size = UDim2.fromOffset(34, 34)
        img.Image = pet.icon
        img.ScaleType = Enum.ScaleType.Fit
        img.Parent = billboard
    end

    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Position = UDim2.new(0, 0, 0, 34)
    title.Size = UDim2.new(1, 0, 0, 22)
    title.Font = Enum.Font.GothamBold
    title.TextScaled = true
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextStrokeTransparency = 0.4
    title.Text = pet.name
    title.Parent = billboard

    local sub = Instance.new("TextLabel")
    sub.BackgroundTransparency = 1
    sub.Position = UDim2.new(0, 0, 0, 56)
    sub.Size = UDim2.new(1, 0, 0, 16)
    sub.Font = Enum.Font.GothamMedium
    sub.TextScaled = true
    sub.TextColor3 = pet.color
    sub.TextStrokeTransparency = 0.5
    sub.Text = string.format("%s | $%s/s", pet.rarity, abbreviateNumber(pet.rate))
    sub.Parent = billboard
end

local function setupModel(model, pet)
    local scale = CONFIG.SCALE_MULT * (pet.scale or 1)
    if math.abs(scale - 1) > 0.001 then
        pcall(function() model:ScaleTo(scale) end)
    end

    local hasJoints = false
    for _, d in ipairs(model:GetDescendants()) do
        if d:IsA("Motor6D") or d:IsA("Weld") or d:IsA("WeldConstraint") then
            hasJoints = true
            break
        end
    end

    local primary = model.PrimaryPart

    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
            part.CanQuery  = false
            part.CanTouch  = false
            part.Massless  = true

            local anchored = CONFIG.ANCHORED
            if anchored then
                anchored = (not hasJoints) or part == primary
            end
            part.Anchored = anchored
        end
    end

    if primary then
        primary.Anchored = CONFIG.ANCHORED
    end

    return hasJoints
end

local function playIdle(model, pet)
    if not (CONFIG.ANIMATE and pet.idle) then return end

    local ok, err = pcall(function()
        local host = model:FindFirstChildOfClass("Model") or model
        local controller = host:FindFirstChildOfClass("AnimationController")
            or host:FindFirstChildOfClass("Humanoid")

        if not controller then
            controller = Instance.new("AnimationController")
            controller.Parent = host
        end

        local animator = controller:FindFirstChildOfClass("Animator")
        if not animator then
            animator = Instance.new("Animator")
            animator.Parent = controller
        end

        local anim
        if typeof(pet.idle) == "Instance" and pet.idle:IsA("Animation") then
            anim = pet.idle:Clone()
        else
            anim = Instance.new("Animation")
            anim.AnimationId = tostring(pet.idle)
        end

        local trackAnim = animator:LoadAnimation(anim)
        trackAnim.Looped = true
        trackAnim:Play()
    end)

    if not ok then
        warn("[VALT SPAWNER] idle animation failed for " .. pet.name .. ": " .. tostring(err))
    end
end

--=====================================================================
-- Spawn limit
--=====================================================================
local function enforceSpawnLimit()
    while #activeSpawns > CONFIG.MAX_SPAWNS do
        local record = table.remove(activeSpawns, 1)
        if record and record.model then
            pcall(function() record.model:Destroy() end)
        end
    end
end

--=====================================================================
-- Input tracking for tool placement
--=====================================================================
local lastTouchPos = nil

track(UserInputService.TouchTap:Connect(function(pos)
    if pos and pos[1] then lastTouchPos = pos[1] end
end))

track(UserInputService.TouchEnded:Connect(function(part)
    lastTouchPos = part.Position
end))

local function getSpawnPosition()
    local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

    if isMobile and lastTouchPos and Camera then
        local ray = Camera:ViewportPointToRay(lastTouchPos.X, lastTouchPos.Y)
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = { LocalPlayer.Character, Workspace:FindFirstChild("__ValtSpawns") }
        local result = Workspace:Raycast(ray.Origin, ray.Direction * 600, params)
        if result then return result.Position end
    end

    local ok, mouse = pcall(function() return LocalPlayer:GetMouse() end)
    if ok and mouse and mouse.Hit and mouse.Target then
        return mouse.Hit.Position
    end

    local root = getCharacterRoot()
    if root then
        return root.Position + root.CFrame.LookVector * CONFIG.SPAWN_DISTANCE
    end

    return nil
end

--=====================================================================
-- Spawn
--=====================================================================
local function spawnPet(pet, positionOverride)
    if not running then return false, "unloaded" end

    local modelsFolder = ReplicatedStorage:FindFirstChild("AssetModels")
    if modelsFolder then
        modelsFolder = modelsFolder:FindFirstChild(pet.id)
    end
    if not modelsFolder then
        return false, "no model for " .. pet.id
    end

    local root = getCharacterRoot()
    if not root then
        return false, "character not loaded"
    end

    local clone = modelsFolder:Clone()
    clone.Name = "VALT_" .. pet.id

    local jointed = setupModel(clone, pet)
    clone.Parent = getSpawnFolder()

    local targetPos
    if CONFIG.OWN_PLOT_ONLY then
        targetPos = getPlotSpawnPosition(#activeSpawns)
    end

    if not targetPos then
        if typeof(positionOverride) == "Vector3" then
            targetPos = positionOverride
        else
            local index = #activeSpawns
            local angle = (index % 12) * (math.pi / 6)
            local dist  = CONFIG.SPAWN_DISTANCE + math.floor(index / 12) * 6
            targetPos = root.Position + Vector3.new(math.cos(angle) * dist, 0, math.sin(angle) * dist)
        end
    end

    local finalPos = resolveGroundPosition(targetPos, clone)
    local look     = root.Position

    pcall(function()
        clone:PivotTo(CFrame.new(finalPos, Vector3.new(look.X, finalPos.Y, look.Z)))
    end)

    if CONFIG.NAMETAG then
        pcall(attachNametag, clone, pet)
    end

    playIdle(clone, pet)

    local now = os.clock()
    activeSpawns[#activeSpawns + 1] = {
        model     = clone,
        root      = clone.PrimaryPart,
        basePos   = finalPos,
        t0        = now,
        lastPay   = now,
        name      = pet.name,
        rate      = pet.rate,
        tagHeight = clone:GetExtentsSize().Y * 0.65 + 4,
        jointed   = jointed,
    }

    enforceSpawnLimit()
    return true
end

--=====================================================================
-- Clear spawns
--=====================================================================
local function clearSpawns()
    for _, record in ipairs(activeSpawns) do
        if record.model then
            pcall(function() record.model:Destroy() end)
        end
    end
    table.clear(activeSpawns)

    local folder = Workspace:FindFirstChild("__ValtSpawns")
    if folder then
        pcall(function() folder:Destroy() end)
    end
end

--=====================================================================
-- Money popup
--=====================================================================
local function moneyPopup(record)
    if not record.root or not record.root.Parent then return end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ValtCash"
    billboard.Size = UDim2.fromOffset(150, 40)
    billboard.StudsOffsetWorldSpace = Vector3.new(0, record.tagHeight, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = 300
    billboard.Adornee = record.root
    billboard.Parent = record.root

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.fromScale(1, 1)
    label.Font = Enum.Font.LuckiestGuy
    label.TextScaled = true
    label.TextColor3 = Color3.fromRGB(80, 235, 105)
    label.TextStrokeColor3 = Color3.fromRGB(10, 45, 15)
    label.TextStrokeTransparency = 0.15
    label.Text = "+$" .. abbreviateNumber(record.rate)
    label.Parent = billboard

    TweenService:Create(billboard,
        TweenInfo.new(1.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        { StudsOffsetWorldSpace = Vector3.new(0, record.tagHeight + 4.5, 0) }
    ):Play()

    TweenService:Create(label,
        TweenInfo.new(1.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        { TextTransparency = 1, TextStrokeTransparency = 1 }
    ):Play()

    Debris:AddItem(billboard, 1.3)
end

--=====================================================================
-- Tool giving
--=====================================================================
local function giveTool(pet)
    if not running then return false, "unloaded" end

    local modelsFolder = ReplicatedStorage:FindFirstChild("AssetModels")
    if modelsFolder then
        modelsFolder = modelsFolder:FindFirstChild(pet.id)
    end
    if not modelsFolder then
        return false, "no model for " .. pet.id
    end

    local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
    if not backpack then
        return false, "no backpack"
    end

    local tool = Instance.new("Tool")
    tool.Name = pet.name
    tool.ToolTip = string.format("%s | $%s/s - click to place (one use)", pet.rarity, abbreviateNumber(pet.rate))
    tool.CanBeDropped = false
    tool.RequiresHandle = true
    tool.TextureId = pet.icon

    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(1, 1, 1)
    handle.Transparency = 1
    handle.CanCollide = false
    handle.CanQuery = false
    handle.CanTouch = false
    handle.Massless = true
    handle.Parent = tool

    local clone = modelsFolder:Clone()
    clone.Name = "Pet"

    local size   = clone:GetExtentsSize()
    local maxDim = math.max(size.X, size.Y, size.Z)
    if maxDim > CONFIG.HAND_MAX_STUDS then
        local factor = CONFIG.HAND_MAX_STUDS / maxDim
        pcall(function() clone:ScaleTo(factor ^ 0.5) end)
    end

    local primary = clone.PrimaryPart or clone:FindFirstChildWhichIsA("BasePart", true)

    local hasMotor = false
    for _, d in ipairs(clone:GetDescendants()) do
        if d:IsA("Motor6D") then
            hasMotor = true
            break
        end
    end

    for _, part in ipairs(clone:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Anchored = false
            part.CanCollide = false
            part.CanQuery = false
            part.CanTouch = false
            part.Massless = true
        end
    end

    clone.Parent = tool

    if primary then
        local weld = Instance.new("Weld")
        weld.Part0 = handle
        weld.Part1 = primary
        weld.C0 = CFrame.new(0, clone:GetExtentsSize().Y * 0.4, 0)
        weld.Parent = handle
    end

    if not hasMotor then
        for _, d in ipairs(clone:GetDescendants()) do
            if d:IsA("BasePart") and d ~= primary then
                local wc = Instance.new("WeldConstraint")
                wc.Part0 = primary
                wc.Part1 = d
                wc.Parent = primary
            end
        end
    else
        playIdle(clone, pet)
    end

    tool.Parent = backpack
    activeTools[#activeTools + 1] = tool

    track(tool.Activated:Connect(function()
        local pos = getSpawnPosition()
        local ok, err = spawnPet(pet, pos)
        if not ok then
            warn("[VALT SPAWNER] place failed: " .. tostring(err))
            return
        end

        for i = #activeTools, 1, -1 do
            if activeTools[i] == tool then
                table.remove(activeTools, i)
            end
        end
        pcall(function() tool:Destroy() end)
    end))

    return true
end

local function clearTools()
    for _, tool in ipairs(activeTools) do
        pcall(function() tool:Destroy() end)
    end
    table.clear(activeTools)
end

--=====================================================================
-- Cash visual (fake local counter)
--=====================================================================
local cashVisual = {
    label = nil,
    base  = 0,
    bonus = 0,
    shown = 0,
    ours  = nil,
    conn  = nil,
}

local MULTIPLIERS = { K = 1e3, M = 1e6, B = 1e9, T = 1e12 }

local function parseMoney(text)
    local numStr, suffix = tostring(
