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
local flySpeed = 60
local fovSize = 120
local flyingUp = false
local flyingDown = false

local gui = Instance.new("ScreenGui")
gui.Name = "RealKatioHubV5"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- MENU PRINCIPAL
local main = Instance.new("Frame")
main.Name = "Main"
main.Parent = gui
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.Size = UDim2.new(0.76, 0, 0.94, 0)
main.Position = UDim2.new(0.5, 0, 0.5, 0)
main.BackgroundColor3 = Color3.fromRGB(8, 10, 25)
main.BorderSizePixel = 0
main.ClipsDescendants = true

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 18)

local stroke = Instance.new("UIStroke", main)
stroke.Thickness = 4
stroke.Color = Color3.fromRGB(255, 255, 0)

local gradient = Instance.new("UIGradient", main)
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 10, 35)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 5, 25))
})

task.spawn(function()
    while gui.Parent do
        stroke.Color = Color3.fromHSV((tick() % 5) / 5, 1, 1)
        task.wait(0.04)
    end
end)

-- BOTON K
local openButton = Instance.new("TextButton")
openButton.Parent = gui
openButton.Size = UDim2.fromOffset(60, 60)
openButton.Position = UDim2.new(0, 18, 0.45, 0)
openButton.Text = "K"
openButton.TextScaled = true
openButton.Font = Enum.Font.GothamBlack
openButton.TextColor3 = Color3.new(1, 1, 1)
openButton.BackgroundColor3 = Color3.fromRGB(255, 220, 0)
openButton.ZIndex = 20

Instance.new("UICorner", openButton).CornerRadius = UDim.new(1, 0)

openButton.Activated:Connect(function()
    main.Visible = not main.Visible
end)

-- ENCABEZADO
local header = Instance.new("TextButton")
header.Parent = main
header.Size = UDim2.new(1, 0, 0, 65)
header.BackgroundTransparency = 1
header.Text = "xX REAL KATIO HUB Xx"
header.TextColor3 = Color3.new(1, 1, 1)
header.Font = Enum.Font.GothamBlack
header.TextScaled = true

-- ARRASTRAR MENU
local dragging = false
local dragStart
local startPosition

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPosition = main.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and (
        input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseMovement
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

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- CERRAR
local close = Instance.new("TextButton")
close.Parent = main
close.Size = UDim2.fromOffset(42, 42)
close.Position = UDim2.new(1, -48, 0, 8)
close.Text = "X"
close.TextScaled = true
close.Font = Enum.Font.GothamBold
close.TextColor3 = Color3.new(1, 1, 1)
close.BackgroundColor3 = Color3.fromRGB(200, 35, 45)
close.ZIndex = 5

Instance.new("UICorner", close).CornerRadius = UDim.new(0, 8)

close.Activated:Connect(function()
    main.Visible = false
end)

-- BARRA LATERAL
local sidebar = Instance.new("Frame")
sidebar.Parent = main
sidebar.Position = UDim2.new(0, 12, 0, 75)
sidebar.Size = UDim2.new(0.27, -12, 1, -88)
sidebar.BackgroundTransparency = 1

local sideLayout = Instance.new("UIListLayout")
sideLayout.Parent = sidebar
sideLayout.Padding = UDim.new(0, 10)
sideLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- CONTENIDO
local content = Instance.new("ScrollingFrame")
content.Parent = main
content.Position = UDim2.new(0.29, 0, 0, 75)
content.Size = UDim2.new(0.70, -12, 1, -88)
content.BackgroundColor3 = Color3.fromRGB(15, 25, 42)
content.BorderSizePixel = 0
content.ScrollBarThickness = 5
content.AutomaticCanvasSize = Enum.AutomaticSize.Y
content.CanvasSize = UDim2.new(0, 0, 0, 0)

Instance.new("UICorner", content).CornerRadius = UDim.new(0, 12)

local layout = Instance.new("UIListLayout")
layout.Parent = content
layout.Padding = UDim.new(0, 9)

local padding = Instance.new("UIPadding")
padding.Parent = content
padding.PaddingTop = UDim.new(0, 12)
padding.PaddingLeft = UDim.new(0, 10)
padding.PaddingRight = UDim.new(0, 10)

-- FUNCIONES DE INTERFAZ
local function makeButton(parent, text, height)
    local b = Instance.new("TextButton")
    b.Parent = parent
    b.Size = UDim2.new(1, -5, 0, height or 45)
    b.BackgroundColor3 = Color3.fromRGB(30, 105, 150)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Text = text
    b.TextScaled = true
    b.Font = Enum.Font.GothamBold

    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 9)
    return b
end

local function clearContent()
    for _, v in ipairs(content:GetChildren()) do
        if v:IsA("GuiObject") and v ~= layout and v ~= padding then
            v:Destroy()
        end
    end
end

local function addLabel(text)
    local l = Instance.new("TextLabel")
    l.Parent = content
    l.Size = UDim2.new(1, -5, 0, 42)
    l.BackgroundTransparency = 1
    l.TextColor3 = Color3.new(1, 1, 1)
    l.Text = text
    l.TextScaled = true
    l.Font = Enum.Font.GothamBold
    return l
end

local function addToggle(name, getter, setter)
    local b = makeButton(content, "", 48)

    local function refresh()
        b.Text = name .. " : " .. (getter() and "ON" or "OFF")
        b.BackgroundColor3 = getter()
            and Color3.fromRGB(20, 145, 85)
            or Color3.fromRGB(30, 105, 150)
    end

    b.Activated:Connect(function()
        setter(not getter())
        refresh()
    end)

    refresh()
end

-- CIRCULO FOV
local circle = Instance.new("Frame")
circle.Name = "FOVCircle"
circle.Parent = gui
circle.AnchorPoint = Vector2.new(0.5, 0.5)
circle.Position = UDim2.new(0.5, 0, 0.5, 0)
circle.Size = UDim2.fromOffset(fovSize, fovSize)
circle.BackgroundTransparency = 1
circle.Visible = false

Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)

local circleStroke = Instance.new("UIStroke", circle)
circleStroke.Thickness = 2
circleStroke.Color = Color3.fromRGB(0, 255, 255)

-- CONTROLES FLY MOVIL
local flyControls = Instance.new("Frame")
flyControls.Parent = gui
flyControls.Size = UDim2.fromOffset(115, 112)

-- Separado del botón de salto, hacia el centro de la pantalla
flyControls.Position = UDim2.new(1, -265, 0.40, 0)
flyControls.BackgroundTransparency = 1
flyControls.Visible = false
flyControls.ZIndex = 15

local upButton = Instance.new("TextButton")
upButton.Parent = flyControls
upButton.Size = UDim2.fromOffset(55, 48)
upButton.Position = UDim2.fromOffset(30, 0)
upButton.Text = "▲"
upButton.TextScaled = true
upButton.BackgroundColor3 = Color3.fromRGB(20, 145, 85)
upButton.TextColor3 = Color3.new(1, 1, 1)
upButton.ZIndex = 16

Instance.new("UICorner", upButton).CornerRadius = UDim.new(0, 10)

local downButton = Instance.new("TextButton")
downButton.Parent = flyControls
downButton.Size = UDim2.fromOffset(55, 48)
downButton.Position = UDim2.fromOffset(30, 58)
downButton.Text = "▼"
downButton.TextScaled = true
downButton.BackgroundColor3 = Color3.fromRGB(170, 65, 55)
downButton.TextColor3 = Color3.new(1, 1, 1)
downButton.ZIndex = 16

Instance.new("UICorner", downButton).CornerRadius = UDim.new(0, 10)

local function connectHold(button, callback)
    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
            callback(true)
        end
    end)

    button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
            callback(false)
        end
    end)
end

connectHold(upButton, function(value)
    flyingUp = value
end)

connectHold(downButton, function(value)
    flyingDown = value
end)

-- HOME
local function home()
    clearContent()
    addLabel("🥷 BIENVENIDO A REAL KATIO 👑")
    addLabel("REAL KATIO HUB V5")
    addLabel("MOBILE EDITION")
    addLabel("¡Disfruta el menú!")
end

-- FACTURES
local function features()
    clearContent()
    addLabel("🚀 FACTURES")

    addToggle("Fly", function()
        return fly
    end, function(v)
        fly = v
        flyControls.Visible = v

        if not v then
            flyingUp = false
            flyingDown = false
        end
    end)

    addToggle("Speed", function()
        return speed
    end, function(v)
        speed = v
    end)

    addToggle("Infinite Jump", function()
        return infJump
    end, function(v)
        infJump = v
    end)

    local speedLabel = addLabel("Fly Speed: " .. flySpeed)

    local minus = makeButton(content, "Fly Speed -", 42)
    minus.Activated:Connect(function()
        flySpeed = math.max(10, flySpeed - 10)
        speedLabel.Text = "Fly Speed: " .. flySpeed
    end)

    local plus = makeButton(content, "Fly Speed +", 42)
    plus.Activated:Connect(function()
        flySpeed = math.min(200, flySpeed + 10)
        speedLabel.Text = "Fly Speed: " .. flySpeed
    end)
end

-- PLAYER
local function playerTab()
    clearContent()
    addLabel("👤 PLAYER")

    addToggle("Invincible SP", function()
        return invincible
    end, function(v)
        invincible = v
    end)

    addLabel("ForceField local; no garantiza")
    addLabel("invulnerabilidad en todos los juegos.")
end

-- FOV
local function fovTab()
    clearContent()
    addLabel("🎯 FOV CIRCLE")

    local toggleCircle = makeButton(
        content,
        "FOV Circle: " .. (circle.Visible and "ON" or "OFF"),
        45
    )

    toggleCircle.Activated:Connect(function()
        circle.Visible = not circle.Visible
        toggleCircle.Text = "FOV Circle: " ..
            (circle.Visible and "ON" or "OFF")
    end)

    local sizeLabel = addLabel("FOV: " .. fovSize)

    local minus = makeButton(content, "- FOV", 42)
    minus.Activated:Connect(function()
        fovSize = math.max(40, fovSize - 10)
        circle.Size = UDim2.fromOffset(fovSize, fovSize)
        sizeLabel.Text = "FOV: " .. fovSize
    end)

    local plus = makeButton(content, "+ FOV", 42)
    plus.Activated:Connect(function()
        fovSize = math.min(500, fovSize + 10)
        circle.Size = UDim2.fromOffset(fovSize, fovSize)
        sizeLabel.Text = "FOV: " .. fovSize
    end)
end

-- NAVEGACION
local function addTab(name, callback)
    local b = makeButton(sidebar, name, 52)
    b.Activated:Connect(callback)
end

addTab("HOME", home)
addTab("FACTURES", features)
addTab("PLAYER", playerTab)
addTab("FOV", fovTab)

-- INFINITE JUMP
UIS.JumpRequest:Connect(function()
    if infJump and humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- FLY
local bodyVelocity
local bodyGyro
local oldAutoRotate = true

local function stopFly()
    if bodyVelocity then
        bodyVelocity:Destroy()
        bodyVelocity = nil
    end

    if bodyGyro then
        bodyGyro:Destroy()
        bodyGyro = nil
    end

    if humanoid then
        humanoid.AutoRotate = oldAutoRotate
    end

    flyingUp = false
    flyingDown = false
    flyControls.Visible = false
end

local function startFly()
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root or not humanoid then return end

    oldAutoRotate = humanoid.AutoRotate
    humanoid.AutoRotate = false

    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Name = "KatioFlyVelocity"
    bodyVelocity.MaxForce = Vector3.new(1000000, 1000000, 1000000)
    bodyVelocity.P = 25000
    bodyVelocity.Velocity = Vector3.zero
    bodyVelocity.Parent = root

    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.Name = "KatioFlyGyro"
    bodyGyro.MaxTorque = Vector3.new(1000000, 1000000, 1000000)
    bodyGyro.P = 15000
    bodyGyro.CFrame = root.CFrame
    bodyGyro.Parent = root

    flyControls.Visible = true
end

RunService.Heartbeat:Connect(function()
    if not character or not character.Parent then return end

    humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    humanoid.WalkSpeed = speed and 32 or 16

    if fly then
        if not bodyVelocity or not bodyVelocity.Parent then
            startFly()
        end

        local root = character:FindFirstChild("HumanoidRootPart")
        local camera = workspace.CurrentCamera

        if bodyVelocity and root and camera then
            local move = humanoid.MoveDirection

            -- Dirección del joystick
            local direction = Vector3.new(move.X, 0, move.Z)

            -- Subir y bajar
            local vertical = 0

            if flyingUp or UIS:IsKeyDown(Enum.KeyCode.Space) then
                vertical = vertical + 1
            end

            if flyingDown
            or UIS:IsKeyDown(Enum.KeyCode.LeftShift)
            or UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
                vertical = vertical - 1
            end

            bodyVelocity.Velocity =
                direction * flySpeed
                + Vector3.new(0, vertical * flySpeed, 0)

            bodyGyro.CFrame = CFrame.lookAt(
                root.Position,
                root.Position + camera.CFrame.LookVector
            )
        end
    else
        if bodyVelocity or bodyGyro then
            stopFly()
        end
    end

    -- FORCEFIELD LOCAL
    if invincible and not character:FindFirstChild("KatioForceField") then
        local ff = Instance.new("ForceField")
        ff.Name = "KatioForceField"
        ff.Parent = character
    elseif not invincible then
        local ff = character:FindFirstChild("KatioForceField")
        if ff then
            ff:Destroy()
        end
    end
end)

-- REAPARECER
player.CharacterAdded:Connect(function(char)
    stopFly()
    character = char
    humanoid = char:WaitForChild("Humanoid")
end)

home()

print("🥷 REAL KATIO HUB V5 LOADED 👑")
