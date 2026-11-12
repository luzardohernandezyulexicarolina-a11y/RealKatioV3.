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

local main = Instance.new("Frame",gui)
main.Size = UDim2.new(0,600,0,440)
main.Position = UDim2.new(.5,-300,.5,-220)
main.BackgroundColor3 = Color3.fromRGB(15,15,25)
main.BorderSizePixel = 0

local corner = Instance.new("UICorner",main)
corner.CornerRadius = UDim.new(0,20)

local stroke = Instance.new("UIStroke",main)
stroke.Thickness = 4

local gradient = Instance.new("UIGradient",main)
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,Color3.fromRGB(255,0,120)),
    ColorSequenceKeypoint.new(.5,Color3.fromRGB(0,180,255)),
    ColorSequenceKeypoint.new(1,Color3.fromRGB(170,0,255))
})

task.spawn(function()
    while gui.Parent do
        gradient.Rotation = (gradient.Rotation + 1) % 360
        stroke.Color = Color3.fromHSV((tick()%5)/5,1,1)
        task.wait(.03)
    end
end)

-- HEADER
local header = Instance.new("TextButton",main)
header.Size = UDim2.new(1,0,0,75)
header.Text = "👑 REAL KATIO HUB"
header.TextColor3 = Color3.new(1,1,1)
header.TextScaled = true
header.Font = Enum.Font.GothamBold
header.BackgroundTransparency = 1

-- DRAG
local dragging, dragStart, startPos

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(
            startPos.X.Scale,startPos.X.Offset+delta.X,
            startPos.Y.Scale,startPos.Y.Offset+delta.Y
        )
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- CLOSE
local close = Instance.new("TextButton",main)
close.Size = UDim2.new(0,55,0,50)
close.Position = UDim2.new(1,-65,0,10)
close.Text = "X"
close.TextScaled = true
close.BackgroundColor3 = Color3.fromRGB(220,40,40)
close.TextColor3 = Color3.new(1,1,1)
close.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- SIDEBAR
local sidebar = Instance.new("Frame",main)
sidebar.Position = UDim2.new(0,10,0,90)
sidebar.Size = UDim2.new(0,150,1,-105)
sidebar.BackgroundTransparency = 1

local content = Instance.new("ScrollingFrame",main)
content.Position = UDim2.new(0,175,0,90)
content.Size = UDim2.new(1,-190,1,-105)
content.BackgroundColor3 = Color3.fromRGB(15,25,40)
content.BorderSizePixel = 0
content.ScrollBarThickness = 5
content.CanvasSize = UDim2.new(0,0,0,600)

local layout = Instance.new("UIListLayout",content)
layout.Padding = UDim.new(0,9)

local function button(parent,text,height)
    local b = Instance.new("TextButton",parent)
    b.Size = UDim2.new(1,-8,0,height or 48)
    b.Text = text
    b.TextScaled = true
    b.Font = Enum.Font.GothamBold
    b.TextColor3 = Color3.new(1,1,1)
    b.BackgroundColor3 = Color3.fromRGB(35,100,145)
    Instance.new("UICorner",b).CornerRadius = UDim.new(0,12)
    return b
end

local function clear()
    for _,v in ipairs(content:GetChildren()) do
        if v:IsA("TextButton") or v:IsA("TextLabel")
        or v:IsA("Frame") then
            v:Destroy()
        end
    end
end

local function toggle(name,get,set)
    local b = button(content,name.." : "..(get() and "ON" or "OFF"),52)
    b.MouseButton1Click:Connect(function()
        set(not get())
        b.Text = name.." : "..(get() and "ON" or "OFF")
    end)
end

local function label(text)
    local l = Instance.new("TextLabel",content)
    l.Size = UDim2.new(1,-8,0,38)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = Color3.new(1,1,1)
    l.TextScaled = true
    l.Font = Enum.Font.GothamBold
end

-- HOME
local function home()
    clear()
    label("🥷 BIENVENIDO A REAL KATIO 👑")
    label("REAL KATIO HUB V1")
    label("Tu menú personalizado")
end

-- FEATURES
local function features()
    clear()
    label("🚀 FACTURES")
    toggle("Volar (Fly)",function() return fly end,function(v) fly=v end)
    toggle("Speed",function() return speed end,function(v) speed=v end)
    toggle("Infini Jum",function() return infJump end,function(v) infJump=v end)
end

-- PLAYER
local function playerTab()
    clear()
    label("👤 PLAYER")
    toggle("Invincible SP",function() return invincible end,function(v) invincible=v end)
end

-- FOV
local function fovTab()
    clear()
    label("🎯 FOV CIRCLE")

    local circle = Instance.new("Frame",gui)
    circle.Name = "FOVCircle"
    circle.AnchorPoint = Vector2.new(.5,.5)
    circle.Position = UDim2.new(.5,0,.5,0)
    circle.Size = UDim2.new(0,fovSize,0,fovSize)
    circle.BackgroundTransparency = 1
    Instance.new("UICorner",circle).CornerRadius = UDim.new(1,0)

    local s = Instance.new("UIStroke",circle)
    s.Thickness = 2
    s.Color = Color3.fromRGB(0,255,255)

    local minus = button(content,"- FOV",45)
    minus.MouseButton1Click:Connect(function()
        fovSize = math.max(40,fovSize-10)
        circle.Size = UDim2.new(0,fovSize,0,fovSize)
    end)

    local plus = button(content,"+ FOV",45)
    plus.MouseButton1Click:Connect(function()
        fovSize = math.min(500,fovSize+10)
        circle.Size = UDim2.new(0,fovSize,0,fovSize)
    end)
end

-- NAVIGATION
local function nav(name,callback)
    local b = button(sidebar,name,58)
    b.MouseButton1Click:Connect(callback)
end

nav("🏠 Home",home)
nav("🚀 Factures",features)
nav("👤 Player",playerTab)
nav("🎯 FOV",fovTab)

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

            if UIS:IsKeyDown(Enum.KeyCode.W) then direction += cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.S) then direction -= cam.CFrame.LookVector end
            if UIS:IsKeyDown(Enum.KeyCode.A) then direction -= cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.D) then direction += cam.CFrame.RightVector end
            if UIS:IsKeyDown(Enum.KeyCode.Space) then direction += Vector3.yAxis end
            if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then direction -= Vector3.yAxis end

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
print("👑 REAL KATIO HUB LOADED")
