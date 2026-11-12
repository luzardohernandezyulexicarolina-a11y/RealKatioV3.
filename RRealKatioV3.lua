
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local fly = false
local speed = false
local infJump = false
local invincible = false
local flySpeed = 50
local fovSize = 120

local gui = Instance.new("ScreenGui")
gui.Name = "RealKatioHub"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- MAIN MENU
local main = Instance.new("Frame",gui)
main.Name = "Main"
main.Size = UDim2.new(0.88,0,0.72,0)
main.Position = UDim2.new(0.06,0,0.14,0)
main.BackgroundColor3 = Color3.fromRGB(15,15,25)
main.BorderSizePixel = 0

Instance.new("UICorner",main).CornerRadius = UDim.new(0,14)

local stroke = Instance.new("UIStroke",main)
stroke.Thickness = 3

local gradient = Instance.new("UIGradient",main)
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,Color3.fromRGB(255,0,120)),
    ColorSequenceKeypoint.new(0.5,Color3.fromRGB(0,180,255)),
    ColorSequenceKeypoint.new(1,Color3.fromRGB(170,0,255))
})

task.spawn(function()
    while gui.Parent do
        gradient.Rotation = (gradient.Rotation + 1) % 360
        stroke.Color = Color3.fromHSV((tick()%5)/5,1,1)
        task.wait(0.03)
    end
end)

-- FLOATING K BUTTON
local openButton = Instance.new("TextButton",gui)
openButton.Size = UDim2.new(0,48,0,48)
openButton.Position = UDim2.new(0,15,0.45,0)
openButton.Text = "K"
openButton.TextScaled = true
openButton.Font = Enum.Font.GothamBold
openButton.TextColor3 = Color3.new(1,1,1)
openButton.BackgroundColor3 = Color3.fromRGB(150,0,255)
openButton.ZIndex = 10

Instance.new("UICorner",openButton).CornerRadius = UDim.new(1,0)

local kStroke = Instance.new("UIStroke",openButton)
kStroke.Thickness = 3

task.spawn(function()
    while gui.Parent do
        openButton.BackgroundColor3 =
            Color3.fromHSV((tick()%5)/5,1,1)
        kStroke.Color =
            Color3.fromHSV((tick()%5)/5,1,1)
        task.wait(0.04)
    end
end)

openButton.MouseButton1Click:Connect(function()
    main.Visible = not main.Visible
end)

-- HEADER
local header = Instance.new("TextButton",main)
header.Size = UDim2.new(1,0,0,42)
header.Text = "🥷 REAL KATIO HUB 👑"
header.TextColor3 = Color3.new(1,1,1)
header.TextScaled = true
header.Font = Enum.Font.GothamBold
header.BackgroundTransparency = 1

-- DRAG MENU
local dragging = false
local dragStart
local startPos

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and (
        input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseMovement
    ) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- CLOSE BUTTON
local close = Instance.new("TextButton",main)
close.Size = UDim2.new(0,32,0,30)
close.Position = UDim2.new(1,-38,0,6)
close.Text = "X"
close.TextScaled = true
close.BackgroundColor3 = Color3.fromRGB(220,40,40)
close.TextColor3 = Color3.new(1,1,1)

close.MouseButton1Click:Connect(function()
    main.Visible = false
end)

-- SIDEBAR
local sidebar = Instance.new("Frame",main)
sidebar.Position = UDim2.new(0,6,0,48)
sidebar.Size = UDim2.new(0.29,-6,1,-55)
sidebar.BackgroundTransparency = 1

local sideLayout = Instance.new("UIListLayout",sidebar)
sideLayout.Padding = UDim.new(0,6)

-- CONTENT
local content = Instance.new("ScrollingFrame",main)
content.Position = UDim2.new(0.30,0,0,48)
content.Size = UDim2.new(0.70,-6,1,-55)
content.BackgroundColor3 = Color3.fromRGB(15,25,40)
content.BorderSizePixel = 0
content.ScrollBarThickness = 3
content.CanvasSize = UDim2.new(0,0,0,650)
content.AutomaticCanvasSize = Enum.AutomaticSize.Y

Instance.new("UICorner",content).CornerRadius = UDim.new(0,10)

local layout = Instance.new("UIListLayout",content)
layout.Padding = UDim.new(0,7)

local padding = Instance.new("UIPadding",content)
padding.PaddingTop = UDim.new(0,8)
padding.PaddingLeft = UDim.new(0,6)
padding.PaddingRight = UDim.new(0,6)

-- BUTTON FUNCTION
local function button(parent,text,height)
    local b = Instance.new("TextButton",parent)
    b.Size = UDim2.new(1,-5,0,height or 40)
    b.Text = text
    b.TextScaled = true
    b.Font = Enum.Font.GothamBold
    b.TextColor3 = Color3.new(1,1,1)
    b.BackgroundColor3 = Color3.fromRGB(35,100,145)
    Instance.new("UICorner",b).CornerRadius = UDim.new(0,9)
    return b
end

local function clear()
    for _,v in ipairs(content:GetChildren()) do
        if v:IsA("GuiObject") and v ~= layout and v ~= padding then
            v:Destroy()
        end
    end
end

local function label(text)
    local l = Instance.new("TextLabel",content)
    l.Size = UDim2.new(1,-5,0,35)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = Color3.new(1,1,1)
    l.TextScaled = true
    l.Font = Enum.Font.GothamBold
end

local function toggle(name,get,set)
    local b = button(content,name.." : "..(get() and "ON" or "OFF"),42)

    b.MouseButton1Click:Connect(function()
        set(not get())
        b.Text = name.." : "..(get() and "ON" or "OFF")
    end)
end

-- FOV CIRCLE
local circle = Instance.new("Frame",gui)
circle.Name = "FOVCircle"
circle.AnchorPoint = Vector2.new(0.5,0.5)
circle.Position = UDim2.new(0.5,0,0.5,0)
circle.Size = UDim2.new(0,fovSize,0,fovSize)
circle.BackgroundTransparency = 1
circle.Visible = false

Instance.new("UICorner",circle).CornerRadius = UDim.new(1,0)

local circleStroke = Instance.new("UIStroke",circle)
circleStroke.Thickness = 2
circleStroke.Color = Color3.fromRGB(0,255,255)

-- HOME
local function home()
    clear()
    label("🥷 BIENVENIDO A REAL KATIO 👑")
    label("REAL KATIO HUB V3")
    label("Mobile Edition")
    label("Made for Real Katio")
end

-- FEATURES
local function features()
    clear()
    label("🚀 FACTURES")

    toggle("Fly",function()
        return fly
    end,function(v)
        fly = v
    end)

    toggle("Speed",function()
        return speed
    end,function(v)
        speed = v
    end)

    toggle("Infinite Jump",function()
        return infJump
    end,function(v)
        infJump = v
    end)

    local minus = button(content,"Fly Speed -",40)
    minus.MouseButton1Click:Connect(function()
        flySpeed = math.max(10,flySpeed-10)
    end)

    local plus = button(content,"Fly Speed +",40)
    plus.MouseButton1Click:Connect(function()
        flySpeed = math.min(200,flySpeed+10)
    end)

    label("Fly Speed: "..flySpeed)
end

-- PLAYER
local function playerTab()
    clear()
    label("👤 PLAYER")

    toggle("Invincible SP",function()
        return invincible
    end,function(v)
        invincible = v
    end)
end

-- FOV
local function fovTab()
    clear()
    label("🎯 FOV CIRCLE")

    circle.Visible = not circle.Visible

    local minus = button(content,"- FOV",40)
    minus.MouseButton1Click:Connect(function()
        fovSize = math.max(40,fovSize-10)
        circle.Size = UDim2.new(0,fovSize,0,fovSize)
    end)

    local plus = button(content,"+ FOV",40)
    plus.MouseButton1Click:Connect(function()
        fovSize = math.min(500,fovSize+10)
        circle.Size = UDim2.new(0,fovSize,0,fovSize)
    end)

    label("FOV: "..fovSize)
end

-- NAVIGATION
local function nav(name,callback)
    local b = button(sidebar,name,38)
    b.TextScaled = true
    b.MouseButton1Click:Connect(callback)
end

nav("HOME",home)
nav("FACTURES",features)
nav("PLAYER",playerTab)
nav("FOV",fovTab)

-- INFINITE JUMP
UIS.JumpRequest:Connect(function()
    if infJump and humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- CHARACTER FEATURES
local bodyVelocity

RunService.Heartbeat:Connect(function()
    if not character or not character.Parent then return end

    humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    humanoid.WalkSpeed = speed and 32 or 16

    if fly then
        if not bodyVelocity or not bodyVelocity.Parent then
            local root = character:FindFirstChild("HumanoidRootPart")
            if root then
                bodyVelocity = Instance.new("BodyVelocity")
                bodyVelocity.MaxForce = Vector3.new(1e6,1e6,1e6)
                bodyVelocity.Parent = root
            end
        end

        if bodyVelocity then
            local cam = workspace.CurrentCamera
            local direction = Vector3.zero

            if UIS:IsKeyDown(Enum.KeyCode.W) then
                direction += cam.CFrame.LookVector
            end
            if UIS:IsKeyDown(Enum.KeyCode.S) then
                direction -= cam.CFrame.LookVector
            end
            if UIS:IsKeyDown(Enum.KeyCode.A) then
                direction -= cam.CFrame.RightVector
            end
            if UIS:IsKeyDown(Enum.KeyCode.D) then
                direction += cam.CFrame.RightVector
            end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then
                direction += Vector3.yAxis
            end
            if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then
                direction -= Vector3.yAxis
            end

            bodyVelocity.Velocity = direction.Magnitude > 0
                and direction.Unit * flySpeed or Vector3.zero
        end
    elseif bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end

    if invincible and not character:FindFirstChild("KatioForceField") then
        local ff = Instance.new("ForceField")
        ff.Name = "KatioForceField"
        ff.Parent = character
    elseif not invincible then
        local ff = character:FindFirstChild("KatioForceField")
        if ff then ff:Destroy() end
    end
end)

player.CharacterAdded:Connect(function(char)
    character = char
    humanoid = char:WaitForChild("Humanoid")
    bodyVelocity = nil
end)

home()
print("REAL KATIO HUB V3 LOADED")
