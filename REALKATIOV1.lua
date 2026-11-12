local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local speed = 16
local flySpeed = 50
local flying = false
local noclip = false
local infiniteJump = false
local superJump = false
local fullBright = false
local esp = false

local gui = Instance.new("ScreenGui")
gui.Name = "RealKatioV1"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- COLORES ARCOIRIS

local hue = 0

local function rainbow()
    hue = (hue + 0.004) % 1
    return Color3.fromHSV(hue, 1, 1)
end

-- BOTON FLOTANTE

local open = Instance.new("TextButton")
open.Parent = gui
open.Size = UDim2.fromOffset(65,65)
open.Position = UDim2.new(0,20,0.4,0)
open.Text = "🥷"
open.TextSize = 32
open.BackgroundColor3 = Color3.new(1,0,0)
open.BorderSizePixel = 0

Instance.new("UICorner",open).CornerRadius = UDim.new(1,0)

-- MENU

local frame = Instance.new("Frame")
frame.Parent = gui
frame.Size = UDim2.fromOffset(290,430)
frame.Position = UDim2.new(0.5,-145,0.5,-215)
frame.BackgroundColor3 = Color3.fromRGB(20,20,25)
frame.BorderSizePixel = 0
frame.Visible = false

Instance.new("UICorner",frame)

-- TITULO

local title = Instance.new("TextLabel")
title.Parent = frame
title.Size = UDim2.new(1,0,0,45)
title.BackgroundTransparency = 1
title.Text = "🥷Real Katio V1 👑"
title.TextColor3 = Color3.new(1,1,1)
title.TextSize = 21
title.Font = Enum.Font.GothamBold

-- CERRAR

local close = Instance.new("TextButton")
close.Parent = frame
close.Size = UDim2.fromOffset(35,35)
close.Position = UDim2.new(1,-40,0,5)
close.Text = "X"
close.TextSize = 20
close.BackgroundColor3 = Color3.fromRGB(180,30,30)
close.TextColor3 = Color3.new(1,1,1)

close.MouseButton1Click:Connect(function()
    frame.Visible = false
end)

open.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
end)

-- MENU DESLIZABLE

local dragging = false
local dragStart
local startPos

title.InputBegan:Connect(function(input)
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

-- LISTA DE OPCIONES

local scroll = Instance.new("ScrollingFrame")
scroll.Parent = frame
scroll.Position = UDim2.fromOffset(10,50)
scroll.Size = UDim2.new(1,-20,1,-60)
scroll.BackgroundTransparency = 1
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 5
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.CanvasSize = UDim2.new()

local layout = Instance.new("UIListLayout")
layout.Parent = scroll
layout.Padding = UDim.new(0,7)

local function makeButton(name,callback)
    local b = Instance.new("TextButton")
    b.Parent = scroll
    b.Size = UDim2.new(1,-8,0,38)
    b.BackgroundColor3 = Color3.fromRGB(45,45,55)
    b.TextColor3 = Color3.new(1,1,1)
    b.TextSize = 15
    b.Font = Enum.Font.GothamBold
    b.Text = name
    b.BorderSizePixel = 0
    Instance.new("UICorner",b)
    b.MouseButton1Click:Connect(callback)
    return b
end

-- PERSONAJE

local function character()
    return player.Character
end

local function humanoid()
    local c = character()
    return c and c:FindFirstChildOfClass("Humanoid")
end

-- 1 SPEED

makeButton("⚡ Speed +",function()
    speed = math.min(speed + 5,200)
    if humanoid() then humanoid().WalkSpeed = speed end
end)

-- 2 SPEED NORMAL

makeButton("🚶 Speed Normal",function()
    speed = 16
    if humanoid() then humanoid().WalkSpeed = 16 end
end)

-- 3 FLY

local flyVelocity
local flyGyro
local flyConnection

local function stopFly()
    flying = false
    if flyConnection then flyConnection:Disconnect() end
    if flyVelocity then flyVelocity:Destroy() end
    if flyGyro then flyGyro:Destroy() end
    flyVelocity = nil
    flyGyro = nil
end

makeButton("🕊 Fly ON / OFF",function()
    if flying then
        stopFly()
        return
    end

    local c = character()
    local root = c and c:FindFirstChild("HumanoidRootPart")
    local hum = humanoid()
    if not root or not hum then return end

    flying = true

    flyVelocity = Instance.new("BodyVelocity")
    flyVelocity.MaxForce = Vector3.new(1e6,1e6,1e6)
    flyVelocity.Velocity = Vector3.zero
    flyVelocity.Parent = root

    flyGyro = Instance.new("BodyGyro")
    flyGyro.MaxTorque = Vector3.new(1e6,1e6,1e6)
    flyGyro.P = 10000
    flyGyro.Parent = root

    flyConnection = RunService.RenderStepped:Connect(function()
        if not flying or not root.Parent then
            stopFly()
            return
        end

        local move = Vector3.zero
        local cf = camera.CFrame

        if UIS:IsKeyDown(Enum.KeyCode.W) then move += cf.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then move -= cf.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then move -= cf.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then move += cf.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.yAxis end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.yAxis end

        if move.Magnitude > 0 then
            flyVelocity.Velocity = move.Unit * flySpeed
        else
            flyVelocity.Velocity = Vector3.zero
        end

        flyGyro.CFrame = cf
    end)
end)

-- 4 VELOCIDAD DE VUELO

makeButton("🚀 Fly Speed +",function()
    flySpeed = math.min(flySpeed + 10,500)
end)

makeButton("🐢 Fly Speed -",function()
    flySpeed = math.max(flySpeed - 10,10)
end)

-- 5 INFINITE JUMP

makeButton("♾ Infinite Jump ON / OFF",function()
    infiniteJump = not infiniteJump
end)

UIS.JumpRequest:Connect(function()
    if infiniteJump then
        local h = humanoid()
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- 6 NOCLIP

makeButton("👻 Noclip ON / OFF",function()
    noclip = not noclip
end)

RunService.Stepped:Connect(function()
    if noclip and character() then
        for _,v in pairs(character():GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end
end)

-- 7 SUPER JUMP

makeButton("🦘 Super Jump ON / OFF",function()
    superJump = not superJump
    local h = humanoid()
    if h then h.UseJumpPower = true end
    if h then h.JumpPower = superJump and 120 or 50 end
end)

-- 8 FULL BRIGHT

makeButton("💡 Full Bright ON / OFF",function()
    fullBright = not fullBright
    Lighting.Brightness = fullBright and 3 or 1
    Lighting.ClockTime = fullBright and 14 or 12
    Lighting.GlobalShadows = not fullBright
end)

-- 9 FOV +

makeButton("👁 FOV +",function()
    camera.FieldOfView = math.min(camera.FieldOfView + 5,120)
end)

-- 10 FOV NORMAL

makeButton("👁 FOV Normal",function()
    camera.FieldOfView = 70
end)

-- 11 RESET

makeButton("🔄 Reset Character",function()
    local h = humanoid()
    if h then h.Health = 0 end
end)

-- 12 REJOIN

makeButton("🔁 Rejoin Server",function()
    TeleportService:Teleport(game.PlaceId,player)
end)

-- 13 OCULTAR MENU

makeButton("🙈 Hide Menu",function()
    frame.Visible = false
end)

-- 14 REABRIR MENU

makeButton("📱 Reopen Menu",function()
    frame.Visible = true
end)

-- 15 STOP FLY

makeButton("🛑 Stop Fly",function()
    stopFly()
end)

-- 16 REFRESH CHARACTER

makeButton("🔄 Refresh Character",function()
    player:LoadCharacter()
end)

-- 17 RESETEAR VELOCIDADES

makeButton("⚙ Reset Fly Speed",function()
    flySpeed = 50
    speed = 16
    if humanoid() then humanoid().WalkSpeed = 16 end
end)

-- ARCOIRIS AUTOMATICO

RunService.RenderStepped:Connect(function()
    local color = rainbow()
    open.BackgroundColor3 = color
    title.TextColor3 = color
    frame.BorderColor3 = color
    frame.BorderSizePixel = 2
end)

-- REINICIAR ESTADOS AL RESPAWN

player.CharacterAdded:Connect(function()
    stopFly()
    task.wait(1)
    if humanoid() then
        humanoid().WalkSpeed = speed
    end
end)

print("🥷 REAL KATIO V1 👑 CARGADO")
