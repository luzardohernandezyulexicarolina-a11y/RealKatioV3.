local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local old = nil
pcall(function()
    old = game:GetService("CoreGui"):FindFirstChild("KATIO_V1")
    if old then old:Destroy() end
end)

local gui = Instance.new("ScreenGui")
gui.Name = "KATIO_V1"
gui.ResetOnSpawn = false

pcall(function()
    gui.Parent = game:GetService("CoreGui")
end)
if not gui.Parent then
    gui.Parent = LP:WaitForChild("PlayerGui")
end

local rainbow = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,100)),
    ColorSequenceKeypoint.new(0.25, Color3.fromRGB(255,220,0)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,255,80)),
    ColorSequenceKeypoint.new(0.75, Color3.fromRGB(0,150,255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(200,0,255))
})

local function gradient(obj)
    local g = Instance.new("UIGradient")
    g.Color = rainbow
    g.Parent = obj
    return g
end

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,245,0,390)
frame.Position = UDim2.new(1,-255,0.25,0)
frame.BackgroundColor3 = Color3.fromRGB(15,15,22)
frame.BorderSizePixel = 0
frame.Parent = gui

Instance.new("UICorner",frame).CornerRadius = UDim.new(0,14)

local stroke = Instance.new("UIStroke")
stroke.Thickness = 3
stroke.Parent = frame
gradient(stroke)

local header = Instance.new("TextLabel")
header.Size = UDim2.new(1,-65,0,42)
header.Position = UDim2.new(0,8,0,3)
header.BackgroundTransparency = 1
header.Text = "🥷Real Katio V1 👑"
header.TextColor3 = Color3.new(1,1,1)
header.TextScaled = true
header.Font = Enum.Font.GothamBold
header.Parent = frame

local close = Instance.new("TextButton")
close.Size = UDim2.new(0,30,0,30)
close.Position = UDim2.new(1,-37,0,7)
close.Text = "X"
close.TextScaled = true
close.TextColor3 = Color3.new(1,1,1)
close.BackgroundColor3 = Color3.fromRGB(180,25,35)
close.Parent = frame
Instance.new("UICorner",close).CornerRadius = UDim.new(0,8)

local minimize = Instance.new("TextButton")
minimize.Size = UDim2.new(0,30,0,30)
minimize.Position = UDim2.new(1,-72,0,7)
minimize.Text = "−"
minimize.TextScaled = true
minimize.TextColor3 = Color3.new(1,1,1)
minimize.BackgroundColor3 = Color3.fromRGB(55,45,75)
minimize.Parent = frame
Instance.new("UICorner",minimize).CornerRadius = UDim.new(0,8)

local launcher = Instance.new("TextButton")
launcher.Size = UDim2.new(0,115,0,42)
launcher.Position = UDim2.new(0,15,0.45,0)
launcher.Text = "🥷 KATIO"
launcher.TextScaled = true
launcher.TextColor3 = Color3.new(1,1,1)
launcher.BackgroundColor3 = Color3.fromRGB(20,20,30)
launcher.Visible = false
launcher.Parent = gui
Instance.new("UICorner",launcher).CornerRadius = UDim.new(0,12)
local ls = Instance.new("UIStroke",launcher)
ls.Thickness = 3
gradient(ls)

-- Drag menu
local dragging, dragStart, startPos

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

minimize.MouseButton1Click:Connect(function()
    frame.Visible = false
    launcher.Visible = true
end)

close.MouseButton1Click:Connect(function()
    frame.Visible = false
    launcher.Visible = true
end)

launcher.MouseButton1Click:Connect(function()
    frame.Visible = true
    launcher.Visible = false
end)

local function getChar()
    return LP.Character
end

local function getHum()
    local c = getChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function getRoot()
    local c = getChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end

local states = {
    invincible = false,
    esp = false,
    speed = false,
    fly = false,
    infiniteJump = false,
    noclip = false
}

local flySpeed = 50
local bodyVelocity, bodyGyro
local descending = false
local forceField

local function makeButton(text,y,height,callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,-16,0,height or 38)
    b.Position = UDim2.new(0,8,0,y)
    b.BackgroundColor3 = Color3.fromRGB(39,39,52)
    b.TextColor3 = Color3.new(1,1,1)
    b.TextScaled = true
    b.Font = Enum.Font.GothamBold
    b.Text = text
    b.Parent = frame
    Instance.new("UICorner",b).CornerRadius = UDim.new(0,9)
    local s = Instance.new("UIStroke",b)
    s.Thickness = 1.5
    gradient(s)
    b.MouseButton1Click:Connect(callback)
    return b
end

local function toggleButton(label,y,key,callback)
    local b
    b = makeButton(label.." : OFF",y,38,function()
        states[key] = not states[key]
        b.Text = label.." : "..(states[key] and "ON" or "OFF")
        callback(states[key])
    end)
    return b
end

-- INVINCIBLE (local ForceField)
local function setInvincible(on)
    local c = getChar()
    if not c then return end

    if on then
        if not c:FindFirstChild("KATIO_ForceField") then
            local ff = Instance.new("ForceField")
            ff.Name = "KATIO_ForceField"
            ff.Visible = false
            ff.Parent = c
        end
    else
        local ff = c:FindFirstChild("KATIO_ForceField")
        if ff then ff:Destroy() end
    end
end

-- ESP PLAYERS
local function clearESP()
    for _,p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local h = p.Character:FindFirstChild("KATIO_ESP")
            if h then h:Destroy() end
            local tag = p.Character:FindFirstChild("KATIO_TAG")
            if tag then tag:Destroy() end
        end
    end
end

local function addESP(p)
    if p == LP or not p.Character then return end
    local c = p.Character
    if c:FindFirstChild("KATIO_ESP") then return end

    local h = Instance.new("Highlight")
    h.Name = "KATIO_ESP"
    h.FillColor = Color3.fromRGB(255,0,200)
    h.OutlineColor = Color3.fromRGB(0,255,255)
    h.FillTransparency = 0.55
    h.Parent = c

    local head = c:FindFirstChild("Head")
    if head then
        local bill = Instance.new("BillboardGui")
        bill.Name = "KATIO_TAG"
        bill.Size = UDim2.new(0,130,0,25)
        bill.StudsOffset = Vector3.new(0,2.5,0)
        bill.AlwaysOnTop = true
        bill.Adornee = head
        bill.Parent = c

        local txt = Instance.new("TextLabel")
        txt.Size = UDim2.new(1,0,1,0)
        txt.BackgroundTransparency = 1
        txt.Text = p.DisplayName
        txt.TextColor3 = Color3.fromRGB(0,255,255)
        txt.TextStrokeTransparency = 0
        txt.TextScaled = true
        txt.Parent = bill
    end
end

local function updateESP()
    if states.esp then
        for _,p in ipairs(Players:GetPlayers()) do
            addESP(p)
        end
    else
        clearESP()
    end
end

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        task.wait(1)
        updateESP()
    end)
end)

-- FLY
local function stopFly()
    states.fly = false
    if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
    if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
    local h = getHum()
    if h then h.PlatformStand = false end
end

local function startFly()
    local root = getRoot()
    local hum = getHum()
    if not root or not hum then return end

    if bodyVelocity then bodyVelocity:Destroy() end
    if bodyGyro then bodyGyro:Destroy() end

    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(1e9,1e9,1e9)
    bodyVelocity.P = 1e5
    bodyVelocity.Velocity = Vector3.zero
    bodyVelocity.Parent = root

    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(1e9,1e9,1e9)
    bodyGyro.P = 1e5
    bodyGyro.CFrame = Camera.CFrame
    bodyGyro.Parent = root

    hum.PlatformStand = false
end

RunService.RenderStepped:Connect(function()
    if states.fly then
        local root = getRoot()
        local hum = getHum()

        if not root or not hum then
            stopFly()
            return
        end

        if not bodyVelocity or not bodyVelocity.Parent then
            startFly()
        end

        if bodyVelocity then
            local move = hum.MoveDirection
            local vertical = 0

            if UIS:IsKeyDown(Enum.KeyCode.Space) then
                vertical = flySpeed
            elseif UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
                vertical = -flySpeed
            end

            if descending then
                vertical = -flySpeed
            end

            bodyVelocity.Velocity =
                move * flySpeed + Vector3.new(0,vertical,0)

            if bodyGyro then
                bodyGyro.CFrame = Camera.CFrame
            end
        end
    end
end)

-- MOBILE DESCEND BUTTON
local downButton = makeButton("⬇ DESCEND (MÓVIL)",350,32,function()
    descending = not descending
    downButton.Text = descending and "⬆ DEJAR DE BAJAR" or "⬇ DESCEND (MÓVIL)"
end)

-- OPTIONS
toggleButton("🛡️ Invincible",49,"invincible",setInvincible)
toggleButton("👥 SP / ESP",91,"esp",updateESP)
toggleButton("⚡ Speed +",133,"speed",function(on)
    local h = getHum()
    if h then h.WalkSpeed = on and 32 or 16 end
end)

makeButton("🏃 Speed Normal",175,34,function()
    states.speed = false
    local h = getHum()
    if h then h.WalkSpeed = 16 end
end)

toggleButton("🚀 Fly ON / OFF",213,"fly",function(on)
    if on then
        descending = false
        startFly()
    else
        stopFly()
    end
end)

makeButton("🚀 Fly Speed +  ("..flySpeed..")",255,32,function()
    flySpeed = math.min(flySpeed + 10,250)
    frame:FindFirstChildWhichIsA("TextButton",true)
end)

local flyLabel = makeButton("🎚️ Fly Speed: 50",290,32,function()
    flySpeed = math.min(flySpeed + 10,250)
    flyLabel.Text = "🎚️ Fly Speed: "..flySpeed
end)

makeButton("♾️ Infinite Jump: ON / OFF",325,32,function()
    states.infiniteJump = not states.infiniteJump
end)

toggleButton("👻 Noclip",385,"noclip",function() end)

-- Infinite jump
UIS.JumpRequest:Connect(function()
    if states.infiniteJump then
        local h = getHum()
        if h then
            h:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- Noclip
RunService.Stepped:Connect(function()
    if states.noclip then
        local c = getChar()
        if c then
            for _,part in ipairs(c:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end
end)

-- Rainbow animation
task.spawn(function()
    local hue = 0
    while gui.Parent do
        hue = (hue + 2) % 360
        local color = Color3.fromHSV(hue/360,1,1)
        header.TextColor3 = color
        stroke.Color = color
        task.wait(0.04)
    end
end)

-- Respawn support
LP.CharacterAdded:Connect(function()
    task.wait(1)
    if states.invincible then setInvincible(true) end
    if states.fly then startFly() end
    if states.esp then updateESP() end
end)

print("🥷 REAL KATIO V1 👑 CARGADO")
             
