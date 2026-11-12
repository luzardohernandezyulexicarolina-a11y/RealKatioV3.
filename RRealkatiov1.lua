local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")

local player = Players.LocalPlayer
local noclip = false
local autoJump = false

local gui = Instance.new("ScreenGui")
gui.Name = "RealKatioV1"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 240, 0, 255)
main.Position = UDim2.new(0.5, -120, 0.5, -127)
main.BackgroundColor3 = Color3.fromRGB(8, 20, 55)
main.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = main

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(0, 140, 255)
stroke.Thickness = 2
stroke.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 0, 40)
title.BackgroundTransparency = 1
title.Text = "REAL KATIO V1"
title.TextColor3 = Color3.fromRGB(0, 170, 255)
title.TextSize = 20
title.Font = Enum.Font.GothamBold
title.Parent = main

local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 35, 0, 35)
close.Position = UDim2.new(1, -38, 0, 3)
close.Text = "X"
close.TextColor3 = Color3.new(1, 1, 1)
close.BackgroundColor3 = Color3.fromRGB(180, 30, 45)
close.Parent = main

local reopen = Instance.new("TextButton")
reopen.Size = UDim2.new(0, 110, 0, 40)
reopen.Position = UDim2.new(0, 15, 0.5, 0)
reopen.Text = "REAL KATIO"
reopen.BackgroundColor3 = Color3.fromRGB(0, 90, 200)
reopen.TextColor3 = Color3.new(1, 1, 1)
reopen.Visible = false
reopen.Parent = gui

close.MouseButton1Click:Connect(function()
    main.Visible = false
    reopen.Visible = true
end)

reopen.MouseButton1Click:Connect(function()
    main.Visible = true
    reopen.Visible = false
end)

local function makeButton(text, y)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -24, 0, 42)
    button.Position = UDim2.new(0, 12, 0, y)
    button.BackgroundColor3 = Color3.fromRGB(15, 75, 155)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.TextSize = 15
    button.Font = Enum.Font.GothamBold
    button.Text = text
    button.Parent = main

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = button

    return button
end

local noclipButton = makeButton("NOCLIP: OFF", 52)
local jumpButton = makeButton("AUTO JUMP: OFF", 102)
local afkButton = makeButton("ANTI-AFK: ON", 152)

noclipButton.MouseButton1Click:Connect(function()
    noclip = not noclip
    noclipButton.Text = "NOCLIP: " .. (noclip and "ON" or "OFF")
end)

jumpButton.MouseButton1Click:Connect(function()
    autoJump = not autoJump
    jumpButton.Text = "AUTO JUMP: " .. (autoJump and "ON" or "OFF")
end)

RunService.Stepped:Connect(function()
    local character = player.Character
    if character and noclip then
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
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

player.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)
