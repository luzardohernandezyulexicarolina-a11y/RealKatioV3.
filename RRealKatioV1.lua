local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local old = player.PlayerGui:FindFirstChild("KATIO_V1")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "KATIO_V1"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(260, 360)
frame.Position = UDim2.new(0.5,-130,0.2,0)
frame.BackgroundColor3 = Color3.fromRGB(15,15,25)
frame.Parent = gui

Instance.new("UICorner",frame).CornerRadius = UDim.new(0,12)

local stroke = Instance.new("UIStroke",frame)
stroke.Thickness = 3

local header = Instance.new("TextButton")
header.Size = UDim2.new(1,0,0,42)
header.BackgroundColor3 = Color3.fromRGB(30,25,45)
header.Text = "🥷 REAL KATIO V1 👑"
header.TextColor3 = Color3.new(1,1,1)
header.TextScaled = true
header.Parent = frame

-- MENÚ MÓVIL Y DESLIZABLE
local dragging = false
local dragStart, startPos

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and (
        input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseMovement
    ) then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale,startPos.X.Offset + delta.X,
            startPos.Y.Scale,startPos.Y.Offset + delta.Y
        )
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- BOTÓN CERRAR Y REABRIR
local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(35,30)
close.Position = UDim2.new(1,-40,0,5)
close.Text = "X"
close.TextScaled = true
close.Parent = frame

local reopen = Instance.new("TextButton")
reopen.Size = UDim2.fromOffset(110,40)
reopen.Position = UDim2.new(0,10,0.5,0)
reopen.Text = "🥷 KATIO"
reopen.Visible = false
reopen.Parent = gui

close.MouseButton1Click:Connect(function()
    frame.Visible = false
    reopen.Visible = true
end)

reopen.MouseButton1Click:Connect(function()
    frame.Visible = true
    reopen.Visible = false
end)

-- OPCIONES CON DESPLAZAMIENTO
local scroll = Instance.new("ScrollingFrame")
scroll.Position = UDim2.new(0,5,0,48)
scroll.Size = UDim2.new(1,-10,1,-55)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 7
scroll.CanvasSize = UDim2.new(0,0,0,650)
scroll.Parent = frame

local layout = Instance.new("UIListLayout",scroll)
layout.Padding = UDim.new(0,7)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

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

local function button(name,callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,-10,0,42)
    b.BackgroundColor3 = Color3.fromRGB(40,40,60)
    b.TextColor3 = Color3.new(1,1,1)
    b.TextScaled = true
    b.Font = Enum.Font.GothamBold
    b.Text = name
    b.Parent = scroll
    Instance.new("UICorner",b).CornerRadius = UDim.new(0,8)
    b.MouseButton1Click:Connect(callback)
    return b
end

local function toggle(name,callback)
    local active = false
    local b = button(name.." : OFF",function()
        active = not active
        b.Text = name.." : "..(active and "ON" or "OFF")
        callback(active)
    end)
    return b
end

-- SPEED
toggle("⚡ SPEED",function(on)
    local h = humanoid()
    if h then h.WalkSpeed = on and 32 or 16 end
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
    bg.P = 1e5
    bg.Parent = r
end

toggle("🚀 FLY",function(on)
    if on then startFly() else stopFly() end
end)

button("⬆ SUBIR",function()
    up = not up
    down = false
end)

button("⬇ BAJAR",function()
    down = not down
    up = false
end)

button("⏹ DETENER SUBIR/BAJAR",function()
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
        if not h then return end

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
end)

-- INFINITE JUMP
local infinite = false

toggle("♾️ INFINITE JUMP",function(on)
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

toggle("👻 NOCLIP",function(on)
    noclip = on
end)

RunService.Stepped:Connect(function()
    if noclip then
        local c = character()
        if c then
            for _,part in ipairs(c:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)

-- INVISIBLE LOCAL
local invisible = false

toggle("👻 INVISIBLE LOCAL",function(on)
    invisible = on
    local c = character()
    if not c then return end

    for _,part in ipairs(c:GetDescendants()) do
        if part:IsA("BasePart") then
            part.LocalTransparencyModifier = on and 1 or 0
        elseif part:IsA("Decal") then
            part.Transparency = on and 1 or 0
        end
    end
end)

-- ESP VISUAL
local esp = false
local highlights = {}

local function updateESP()
    for _,h in pairs(highlights) do
        h:Destroy()
    end
    table.clear(highlights)

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

-- COLORES ARCOÍRIS
task.spawn(function()
    local hue = 0
    while gui.Parent do
        hue = (hue + 0.005) % 1
        local color = Color3.fromHSV(hue,1,1)
        stroke.Color = color
        header.TextColor3 = color
        task.wait(0.03)
    end
end)

player.CharacterAdded:Connect(function()
    task.wait(1)
    if flying then startFly() end
    if invisible then
        local c = character()
        if c then
            for _,part in ipairs(c:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.LocalTransparencyModifier = 1
                end
            end
        end
    end
end)

print("🥷 REAL KATIO V1 👑 CARGADO")
