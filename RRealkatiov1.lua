local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local noclip = false
local autoJump = false
local infiniteJump = false
local flying = false
local flyUp = false
local flyDown = false

local flySpeed = 55
local rainbowHue = 0
local oldCollisions = {}

local gui = Instance.new("ScreenGui")
gui.Name = "RealKatioV1"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- MAIN MENU
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 260, 0, 365)
main.Position = UDim2.new(0.5, -130, 0.5, -180)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 30)
main.Parent = gui

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

local stroke = Instance.new("UIStroke")
stroke.Thickness = 3
stroke.Parent = main

-- TITLE
local title = Instance.new("TextButton")
title.Size = UDim2.new(1, -45, 0, 45)
title.BackgroundTransparency = 1
title.Text = "REAL KATIO V1"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 21
title.Font = Enum.Font.GothamBold
title.Parent = main

-- CLOSE
local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 35, 0, 35)
close.Position = UDim2.new(1, -40, 0, 5)
close.Text = "X"
close.TextColor3 = Color3.new(1, 1, 1)
close.BackgroundColor3 = Color3.fromRGB(180, 35, 45)
close.TextSize = 18
close.Parent = main

Instance.new("UICorner", close).CornerRadius = UDim.new(0, 8)

-- REOPEN
local reopen = Instance.new("TextButton")
reopen.Size = UDim2.new(0, 120, 0, 40)
reopen.Position = UDim2.new(0, 15, 0.5, 0)
reopen.Text = "REAL KATIO"
reopen.TextColor3 = Color3.new(1, 1, 1)
reopen.BackgroundColor3 = Color3.fromRGB(50, 50, 150)
reopen.Visible = false
reopen.Parent = gui

Instance.new("UICorner", reopen).CornerRadius = UDim.new(0, 8)

close.MouseButton1Click:Connect(function()
    main.Visible = false
    reopen.Visible = true
end)

reopen.MouseButton1Click:Connect(function()
    main.Visible = true
    reopen.Visible = false
end)

-- DRAG MENU
local dragging = false
local dragStart
local startPosition

title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = main.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then
        local delta = input.Position - dragStart

        main.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- BUTTON CREATOR
local function makeButton(name, y)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -24, 0, 38)
    button.Position = UDim2.new(0, 12, 0, y)
    button.BackgroundColor3 = Color3.fromRGB(35, 45, 90)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.TextSize = 15
    button.Font = Enum.Font.GothamBold
    button.Text = name .. ": OFF"
    button.Parent = main

    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 8)

    return button
end

local noclipButton = makeButton("NOCLIP", 55)
local jumpButton = makeButton("AUTO JUMP", 100)
local infiniteButton = makeButton("INFINITE JUMP", 145)
local flyButton = makeButton("FLY", 190)

-- FLY MOBILE CONTROLS
local upButton = makeButton("FLY UP", 235)
local downButton = makeButton("FLY DOWN", 280)

-- NOCLIP
noclipButton.MouseButton1Click:Connect(function()
    noclip = not noclip
    noclipButton.Text = "NOCLIP: " .. (noclip and "ON" or "OFF")
end)

RunService.Stepped:Connect(function()
    local character = player.Character

    if character then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                if noclip then
                    if oldCollisions[part] == nil then
                        oldCollisions[part] = part.CanCollide
                    end
                    part.CanCollide = false
                elseif oldCollisions[part] ~= nil then
                    part.CanCollide = oldCollisions[part]
                    oldCollisions[part] = nil
                end
            end
        end
    end
end)

-- AUTO JUMP
jumpButton.MouseButton1Click:Connect(function()
    autoJump = not autoJump
    jumpButton.Text = "AUTO JUMP: " .. (autoJump and "ON" or "OFF")
end)

RunService.Heartbeat:Connect(function()
    if autoJump then
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")

        if humanoid and humanoid.FloorMaterial ~= Enum.Material.Air then
            humanoid.Jump = true
        end
    end
end)

-- INFINITE JUMP
infiniteButton.MouseButton1Click:Connect(function()
    infiniteJump = not infiniteJump
    infiniteButton.Text = "INFINITE JUMP: " ..
        (infiniteJump and "ON" or "OFF")
end)

UserInputService.JumpRequest:Connect(function()
    if infiniteJump then
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")

        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- FLY
local bodyVelocity
local bodyGyro

local function stopFly()
    flying = false

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

    if not root then return end

    flying = true

    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
    bodyVelocity.Velocity = Vector3.zero
    bodyVelocity.Parent = root

    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
    bodyGyro.P = 10000
    bodyGyro.Parent = root
end

flyButton.MouseButton1Click:Connect(function()
    if flying then
        stopFly()
        flyButton.Text = "FLY: OFF"
    else
        startFly()
        flyButton.Text = "FLY: ON"
    end
end)

-- MOBILE UP/DOWN
upButton.MouseButton1Down:Connect(function()
    flyUp = true
end)

upButton.MouseButton1Up:Connect(function()
    flyUp = false
end)

downButton.MouseButton1Down:Connect(function()
    flyDown = true
end)

downButton.MouseButton1Up:Connect(function()
    flyDown = false
end)

-- PC FLY CONTROLS
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end

    if input.KeyCode == Enum.KeyCode.Space then
        flyUp = true
    elseif input.KeyCode == Enum.KeyCode.LeftControl then
        flyDown = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Space then
        flyUp = false
    elseif input.KeyCode == Enum.KeyCode.LeftControl then
        flyDown = false
    end
end)

RunService.RenderStepped:Connect(function()
    if flying and bodyVelocity and bodyGyro then
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")

        if not humanoid then return end

        local direction = humanoid.MoveDirection
        local vertical = 0

        if flyUp then
            vertical = vertical + 1
        end

        if flyDown then
            vertical = vertical - 1
        end

        bodyVelocity.Velocity =
            direction * flySpeed + Vector3.new(0, vertical * flySpeed, 0)

        bodyGyro.CFrame = camera.CFrame
    end
end)

-- RAINBOW EFFECT
task.spawn(function()
    while gui.Parent do
        rainbowHue = (rainbowHue + 0.008) % 1

        local color = Color3.fromHSV(rainbowHue, 1, 1)

        stroke.Color = color
        title.TextColor3 = color

        task.wait(0.04)
    end
end)

-- RESPAWN
player.CharacterAdded:Connect(function()
    stopFly()
    oldCollisions = {}

    flyButton.Text = "FLY: OFF"
end)

print("REAL KATIO V1 LOADED")
