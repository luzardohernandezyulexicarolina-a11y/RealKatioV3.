local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local flying = false
local noclip = false
local infiniteJump = false
local flySpeed = 60

local gui = Instance.new("ScreenGui")
gui.Name = "RealKatioV1"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

-- MENU
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 230, 0, 300)
frame.Position = UDim2.new(0.3, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "🌈 REAL KATIO V1"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextScaled = true
title.Parent = frame

-- RAINBOW
task.spawn(function()
    local hue = 0
    while gui.Parent do
        hue = (hue + 0.005) % 1
        frame.BackgroundColor3 =
            Color3.fromHSV(hue, 1, 1)
        task.wait(0.03)
    end
end)

local function createButton(name, position, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 190, 0, 38)
    button.Position = UDim2.new(0, 20, 0, position)
    button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.TextScaled = true
    button.Text = name
    button.Parent = frame

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = button

    button.MouseButton1Click:Connect(callback)
    return button
end

-- NOCLIP
local noclipButton

noclipButton = createButton("Noclip: OFF", 50, function()
    noclip = not noclip
    noclipButton.Text = "Noclip: " .. (noclip and "ON" or "OFF")
end)

RunService.Stepped:Connect(function()
    if noclip and player.Character then
        for _, part in pairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- INFINITE JUMP
local jumpButton

jumpButton = createButton("Infinite Jump: OFF", 100, function()
    infiniteJump = not infiniteJump
    jumpButton.Text = "Infinite Jump: " ..
        (infiniteJump and "ON" or "OFF")
end)

UIS.JumpRequest:Connect(function()
    if infiniteJump then
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- FLY
local flyButton
local upButton
local downButton

local bodyVelocity
local bodyGyro
local up = false
local down = false

local function stopFly()
    flying = false
    up = false
    down = false

    if bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end

    if bodyGyro then
        bodyGyro:Destroy()
        bodyGyro = nil
    end
end

local function startFly()
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")

    if not root or not humanoid then return end

    flying = true

    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    bodyVelocity.Velocity = Vector3.zero
    bodyVelocity.Parent = root

    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
    bodyGyro.P = 10000
    bodyGyro.Parent = root

    RunService:BindToRenderStep(
        "RealKatioFly",
        Enum.RenderPriority.Character.Value + 1,
        function()
            if not flying or not root.Parent then
                RunService:UnbindFromRenderStep("RealKatioFly")
                return
            end

            local camera = workspace.CurrentCamera
            local direction = humanoid.MoveDirection
            local vertical = (up and 1 or 0) - (down and 1 or 0)

            bodyVelocity.Velocity =
                direction * flySpeed +
                Vector3.new(0, vertical * flySpeed, 0)

            bodyGyro.CFrame = camera.CFrame
        end
    )
end

flyButton = createButton("Fly: OFF", 150, function()
    if flying then
        stopFly()
        flyButton.Text = "Fly: OFF"
    else
        startFly()
        flyButton.Text = "Fly: ON"
    end
end)

-- MOBILE FLY CONTROLS
upButton = createButton("SUBIR ▲", 200, function()
    up = not up
    upButton.Text = up and "SUBIR: ON" or "SUBIR ▲"
end)

downButton = createButton("BAJAR ▼", 245, function()
    down = not down
    downButton.Text = down and "BAJAR: ON" or "BAJAR ▼"
end)

-- HIDE / SHOW MENU
local hideButton = Instance.new("TextButton")
hideButton.Size = UDim2.new(0, 35, 0, 35)
hideButton.Position = UDim2.new(1, -38, 0, 3)
hideButton.Text = "X"
hideButton.TextScaled = true
hideButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
hideButton.TextColor3 = Color3.new(1, 1, 1)
hideButton.Parent = frame

local reopen = Instance.new("TextButton")
reopen.Size = UDim2.new(0, 100, 0, 40)
reopen.Position = UDim2.new(0, 10, 0.5, 0)
reopen.Text = "REAL KATIO"
reopen.TextScaled = true
reopen.BackgroundColor3 = Color3.fromRGB(255, 0, 255)
reopen.TextColor3 = Color3.new(1, 1, 1)
reopen.Visible = false
reopen.Parent = gui

hideButton.MouseButton1Click:Connect(function()
    frame.Visible = false
    reopen.Visible = true
end)

reopen.MouseButton1Click:Connect(function()
    frame.Visible = true
    reopen.Visible = false
end)

print("REAL KATIO V1 loaded!")
