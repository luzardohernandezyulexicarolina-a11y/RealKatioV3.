local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- CONFIGURACION
local SPEED_NORMAL = 16
local SPEED_BOOST = 32
local FLY_SPEED = 45
local fovSize = 150

local speedEnabled = false
local flyEnabled = false
local fovEnabled = false
local noclickEnabled = false
local aimbotEnabled = false

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "RealKatioV1"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 300, 0, 470)
mainFrame.Position = UDim2.new(0.5, -150, 0.5, -235)
mainFrame.BackgroundColor3 = Color3.fromRGB(15,15,20)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0,14)
corner.Parent = mainFrame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(255,0,85)
stroke.Thickness = 2
stroke.Parent = mainFrame

-- TITULO
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,45)
title.BackgroundTransparency = 1
title.Text = "REAL KATIO V2"
title.TextColor3 = Color3.fromRGB(255,0,85)
title.TextScaled = true
title.Font = Enum.Font.GothamBlack
title.Parent = mainFrame

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1,0,0,22)
subtitle.Position = UDim2.new(0,0,0,42)
subtitle.BackgroundTransparency = 1
subtitle.Text = "PREMIUM MOBILE MENU"
subtitle.TextColor3 = Color3.fromRGB(160,160,160)
subtitle.TextScaled = true
subtitle.Parent = mainFrame

-- BOTONES
local function crearBoton(nombre, y, callback)
    local boton = Instance.new("TextButton")
    boton.Size = UDim2.new(0.85,0,0,42)
    boton.Position = UDim2.new(0.075,0,0,y)
    boton.BackgroundColor3 = Color3.fromRGB(45,45,55)
    boton.Text = nombre .. " : OFF"
    boton.TextColor3 = Color3.new(1,1,1)
    boton.TextScaled = true
    boton.Font = Enum.Font.GothamBold
    boton.Parent = mainFrame

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0,8)
    c.Parent = boton

    local estado = false

    boton.Activated:Connect(function()
        estado = not estado

        boton.Text = nombre .. (estado and " : ON" or " : OFF")

        boton.BackgroundColor3 = estado
            and Color3.fromRGB(180,0,65)
            or Color3.fromRGB(45,45,55)

        callback(estado)
    end)

    return boton
end

-- SPEED
crearBoton("SPEED",75,function(estado)
    speedEnabled = estado

    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")

    if humanoid then
        humanoid.WalkSpeed = estado and SPEED_BOOST or SPEED_NORMAL
    end
end)

-- FOV RGB
local fovCircle = Instance.new("Frame")
fovCircle.AnchorPoint = Vector2.new(0.5,0.5)
fovCircle.Position = UDim2.new(0.5,0,0.5,0)
fovCircle.Size = UDim2.new(0,fovSize*2,0,fovSize*2)
fovCircle.BackgroundTransparency = 1
fovCircle.Visible = false
fovCircle.Parent = screenGui

local fovStroke = Instance.new("UIStroke")
fovStroke.Thickness = 2
fovStroke.Parent = fovCircle

local fovCorner = Instance.new("UICorner")
fovCorner.CornerRadius = UDim.new(1,0)
fovCorner.Parent = fovCircle

crearBoton("FOV RGB",125,function(estado)
    fovEnabled = estado
    fovCircle.Visible = estado
end)

RunService.RenderStepped:Connect(function()
    fovStroke.Color = Color3.fromHSV((tick()%5)/5,1,1)
end)

-- FLY
local flyConnection

crearBoton("FLY",175,function(estado)
    flyEnabled = estado

    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end

    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local root = character and character:FindFirstChild("HumanoidRootPart")

    if not root or not humanoid then return end

    if estado then
        flyConnection = RunService.RenderStepped:Connect(function()
            if not root.Parent then return end

            local direction = humanoid.MoveDirection
            local vertical = 0

            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                vertical = FLY_SPEED
            elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                vertical = -FLY_SPEED
            end

            root.AssemblyLinearVelocity =
                direction * FLY_SPEED +
                Vector3.new(0,vertical,0)
        end)
    else
        root.AssemblyLinearVelocity = Vector3.zero
    end
end)

-- NOCLICK
crearBoton("NOCLICK",225,function(estado)
    noclickEnabled = estado
    print("NOCLICK:",estado)
end)

-- AIMBOT NPC
crearBoton("NPC TRAINING",275,function(estado)
    aimbotEnabled = estado
    print("NPC TRAINING:",estado)
end)

-- FOV SIZE
local fovLabel = Instance.new("TextLabel")
fovLabel.Size = UDim2.new(0.85,0,0,25)
fovLabel.Position = UDim2.new(0.075,0,0,330)
fovLabel.BackgroundTransparency = 1
fovLabel.Text = "FOV SIZE: "..fovSize
fovLabel.TextColor3 = Color3.new(1,1,1)
fovLabel.TextScaled = true
fovLabel.Parent = mainFrame

local minus = Instance.new("TextButton")
minus.Size = UDim2.new(0,50,0,35)
minus.Position = UDim2.new(0.2,0,0,365)
minus.Text = "-"
minus.Parent = mainFrame

local plus = Instance.new("TextButton")
plus.Size = UDim2.new(0,50,0,35)
plus.Position = UDim2.new(0.65,0,0,365)
plus.Text = "+"
plus.Parent = mainFrame

local function actualizarFOV()
    fovCircle.Size = UDim2.new(0,fovSize*2,0,fovSize*2)
    fovLabel.Text = "FOV SIZE: "..fovSize
end

minus.Activated:Connect(function()
    fovSize = math.max(30,fovSize-10)
    actualizarFOV()
end)

plus.Activated:Connect(function()
    fovSize = math.min(400,fovSize+10)
    actualizarFOV()
end)

-- ARRASTRAR MENU
local dragging = false
local dragStart
local startPosition

title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = mainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (
        input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch
    ) then
        local delta = input.Position - dragStart

        mainFrame.Position = UDim2.new(
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

-- REAPARECER
player.CharacterAdded:Connect(function()
    task.wait(1)

    if speedEnabled then
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")

        if humanoid then
            humanoid.WalkSpeed = SPEED_BOOST
        end
    end
end)

print("REAL KATIO V2 LOADED")
