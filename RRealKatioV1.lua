local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local guiParent = player:WaitForChild("PlayerGui")

local old = guiParent:FindFirstChild("KATIO_V1")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "KATIO_V1"
gui.ResetOnSpawn = false
gui.Parent = guiParent

local function round(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = obj
end

local function outline(obj)
    local s = Instance.new("UIStroke")
    s.Thickness = 2
    s.Color = Color3.fromRGB(0,255,255)
    s.Parent = obj
    return s
end

-- ARRASTRAR CON EL DEDO
local function makeDraggable(obj, target)
    local dragging = false
    local dragStart, startPos

    obj.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = target.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and (
            input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseMovement
        ) then
            local delta = input.Position - dragStart
            target.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- BOTON KATIO
local launcher = Instance.new("TextButton")
launcher.Size = UDim2.fromOffset(125,48)
launcher.Position = UDim2.new(0,15,0.48,0)
launcher.BackgroundColor3 = Color3.fromRGB(15,15,25)
launcher.Text = "KATIO"
launcher.TextColor3 = Color3.new(1,1,1)
launcher.TextScaled = true
launcher.Font = Enum.Font.GothamBold
launcher.Parent = gui
round(launcher,12)
local launcherStroke = outline(launcher)
makeDraggable(launcher,launcher)

-- MENU
local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(280,390)
frame.Position = UDim2.new(0,15,0.20,0)
frame.BackgroundColor3 = Color3.fromRGB(12,12,24)
frame.Visible = false
frame.Parent = gui
round(frame,15)
local frameStroke = outline(frame)

-- ENCABEZADO
local header = Instance.new("Frame")
header.Size = UDim2.new(1,0,0,48)
header.BackgroundColor3 = Color3.fromRGB(25,20,45)
header.Parent = frame
round(header,12)
makeDraggable(header,frame)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,-45,1,0)
title.Position = UDim2.new(0,5,0,0)
title.BackgroundTransparency = 1
title.Text = "🥷 KATIO 👑"
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.new(1,1,1)
title.Parent = header

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(38,38)
close.Position = UDim2.new(1,-42,0,5)
close.Text = "X"
close.TextScaled = true
close.BackgroundColor3 = Color3.fromRGB(150,20,50)
close.TextColor3 = Color3.new(1,1,1)
close.Parent = header
round(close,10)

close.MouseButton1Click:Connect(function()
    frame.Visible = false
    launcher.Visible = true
end)

launcher.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
end)

-- LISTA DESLIZABLE
local scroll = Instance.new("ScrollingFrame")
scroll.Position = UDim2.new(0,7,0,55)
scroll.Size = UDim2.new(1,-14,1,-63)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 5
scroll.CanvasSize = UDim2.new(0,0,0,0)
scroll.Parent = frame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0,7)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.Parent = scroll

layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scroll.CanvasSize = UDim2.new(
        0,0,0,layout.AbsoluteContentSize.Y + 15
    )
end)

local function character()
    return player.Character
end

local function humanoid()
    local c = character()
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function root()
    local c = character()
    return c and c:FindFirstChild("HumanoidRootPart")
end

-- CREAR BOTONES
local function button(name, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,-8,0,43)
    b.BackgroundColor3 = Color3.fromRGB(35,30,55)
    b.TextColor3 = Color3.new(1,1,1)
    b.Text = name
    b.TextScaled = true
    b.Font = Enum.Font.GothamBold
    b.Parent = scroll
    round(b,10)
    outline(b)

    b.Activated:Connect(callback)
    return b
end

-- TOGGLES CORREGIDOS
local function toggle(name, callback)
    local active = false
    local b

    b = button(name.." : OFF",function()
        active = not active
        b.Text = name.." : "..(active and "ON" or "OFF")
        b.BackgroundColor3 = active
            and Color3.fromRGB(20,110,70)
            or Color3.fromRGB(35,30,55)

        local success, err = pcall(callback,active)
        if not success then
            warn("KATIO ERROR:",err)
        end
    end)

    return b
end

-- SPEED
local speed = 32

toggle("⚡ SPEED",function(on)
    local h = humanoid()
    if h then
        h.WalkSpeed = on and speed or 16
    end
end)

button("🏃 SPEED NORMAL",function()
    local h = humanoid()
    if h then h.WalkSpeed = 16 end
end)

-- FLY
local flying = false
local flySpeed = 50
local up = false
local down = false
local bv, bg

local function stopFly()
    flying = false
    up = false
    down = false

    if bv then bv:Destroy() bv = nil end
    if bg then bg:Destroy() bg = nil end
end

local function startFly()
    local r = root()
    if not r then return end

    stopFly()
    flying = true

    bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e9,1e9,1e9)
    bv.Velocity = Vector3.zero
    bv.Parent = r

    bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(1e9,1e9,1e9)
    bg.P = 10000
    bg.CFrame = workspace.CurrentCamera.CFrame
    bg.Parent = r
end

toggle("🚀 FLY",function(on)
    if on then
        startFly()
    else
        stopFly()
    end
end)

button("⬆ SUBIR",function()
    up = not up
    down = false
end)

button("⬇ BAJAR",function()
    down = not down
    up = false
end)

button("⏹ DETENER ALTURA",function()
    up = false
    down = false
end)

local speedButton
speedButton = button("🎚 FLY SPEED: 50",function()
    flySpeed = flySpeed + 10
    if flySpeed > 250 then flySpeed = 10 end
    speedButton.Text = "🎚 FLY SPEED: "..flySpeed
end)

RunService.RenderStepped:Connect(function()
    if flying and bv and bv.Parent then
        local h = humanoid()
        local camera = workspace.CurrentCamera

        if h and camera then
            local vertical = 0

            if up or UIS:IsKeyDown(Enum.KeyCode.Space) then
                vertical = flySpeed
            elseif down or UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
                vertical = -flySpeed
            end

            bv.Velocity =
                h.MoveDirection * flySpeed
                + Vector3.new(0,vertical,0)

            if bg then
                bg.CFrame = camera.CFrame
            end
        end
    end
end)

-- INFINITE JUMP
local infinite = false

toggle("♾ INFINITE JUMP",function(on)
    infinite = on
end)

UIS.JumpRequest:Connect(function()
    if infinite then
        local h = humanoid()
        if h then
            h:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- NOCLIP
local noclip = false
local oldCollision = {}

toggle("👻 NOCLIP",function(on)
    noclip = on

    if not on then
        for part,value in pairs(oldCollision) do
            if part and part.Parent then
                part.CanCollide = value
            end
        end
        table.clear(oldCollision)
    end
end)

RunService.Stepped:Connect(function()
    if noclip then
        local c = character()
        if c then
            for _,part in ipairs(c:GetDescendants()) do
                if part:IsA("BasePart") then
                    if oldCollision[part] == nil then
                        oldCollision[part] = part.CanCollide
                    end
                    part.CanCollide = false
                end
            end
        end
    end
end)

-- INVISIBLE LOCAL
local invisible = false
local oldTransparency = {}

toggle("👻 INVISIBLE LOCAL",function(on)
    invisible = on
    local c = character()
    if not c then return end

    if on then
        table.clear(oldTransparency)

        for _,part in ipairs(c:GetDescendants()) do
            if part:IsA("BasePart") then
                oldTransparency[part] = part.LocalTransparencyModifier
                part.LocalTransparencyModifier = 1
            elseif part:IsA("Decal") then
                oldTransparency[part] = part.Transparency
                part.Transparency = 1
            end
        end
    else
        for part,value in pairs(oldTransparency) do
            if part and part.Parent then
                if part:IsA("BasePart") then
                    part.LocalTransparencyModifier = value
                elseif part:IsA("Decal") then
                    part.Transparency = value
                end
            end
        end
        table.clear(oldTransparency)
    end
end)

-- ESP
local esp = false
local highlights = {}

local function clearESP()
    for _,h in pairs(highlights) do
        if h then h:Destroy() end
    end
    table.clear(highlights)
end

local function updateESP()
    clearESP()
    if not esp then return end

    for _,p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local h = Instance.new("Highlight")
            h.FillColor = Color3.fromRGB(255,0,200)
            h.OutlineColor = Color3.fromRGB(0,255,255)
            h.Parent = p.Character
            table.insert(highlights,h)
        end
    end
end

toggle("👥 ESP PLAYERS",function(on)
    esp = on
    updateESP()
end)

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        task.wait(1)
        updateESP()
    end)
end)

Players.PlayerRemoving:Connect(function()
    updateESP()
end)

-- REINICIO DEL PERSONAJE
player.CharacterAdded:Connect(function()
    task.wait(1)

    if flying then
        startFly()
    end

    if noclip then
        table.clear(oldCollision)
    end

    if invisible then
        local c = character()
        if c then
            for _,part in ipairs(c:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.LocalTransparencyModifier = 1
                elseif part:IsA("Decal") then
                    part.Transparency = 1
                end
            end
        end
    end
end)

-- ARCOIRIS ANIMADO
task.spawn(function()
    local hue = 0

    while gui.Parent do
        hue = (hue + 0.005) % 1
        local color = Color3.fromHSV(hue,1,1)

        frameStroke.Color = color
        launcherStroke.Color = color
        title.TextColor3 = color

        task.wait(0.03)
    end
end)

print("KATIO V1 CARGADO CORRECTAMENTE")
