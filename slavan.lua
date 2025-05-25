local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({ Title = "Slavan Hub, SubTitle = "by NotAka", TabWidth = 160, Size = UDim2.fromOffset(500, 400), Acrylic = true, Theme = "Dark", MinimizeKey = Enum.KeyCode.LeftControl })
local Tabs = { Main = Window:AddTab({ Title = "Main", Icon = "swords" }), Settings = Window:AddTab({ Title = "Settings", Icon = "settings" }) }
local Options = Fluent.Options

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Player = Players.LocalPlayer

local autoParryEnabled = false
local parryConnSim, parryConnChild
local autoSpamEnabled = false
local spamConn
local ballData = {}
local MousePosition = Vector2.new(0, 0)

local function GetBalls()
    local balls = {}
    for _, b in ipairs(workspace.Balls:GetChildren()) do
        if b:GetAttribute("realBall") then
            table.insert(balls, b)
        end
    end
    return balls
end

local function ResetParry()
    if parryConnSim then parryConnSim:Disconnect() parryConnSim = nil end
    if parryConnChild then parryConnChild:Disconnect() parryConnChild = nil end
    for _, data in pairs(ballData) do
        if data.parryConnAttr then data.parryConnAttr:Disconnect() end
    end
    ballData = {}
end

local function bindParryAttr(ball)
    if not ballData[ball] then
        ballData[ball] = {
            IsParried = false,
            Cooldown = 0,
            lastVel = Vector3.new(0,0,0),
            lastPos = Vector3.new(0,0,0),
            lastAccel = Vector3.new(0,0,0),
            parryConnAttr = nil
        }
    end
    if ballData[ball].parryConnAttr then
        ballData[ball].parryConnAttr:Disconnect()
    end
    ballData[ball].parryConnAttr = ball:GetAttributeChangedSignal("target"):Connect(function()
        ballData[ball].IsParried = false
        ballData[ball].Cooldown = 0
        ballData[ball].lastVel = Vector3.new(0,0,0)
        ballData[ball].lastPos = Vector3.new(0,0,0)
        ballData[ball].lastAccel = Vector3.new(0,0,0)
    end)
end

local function setupParry()
    ResetParry()
    for _, ball in ipairs(GetBalls()) do
        bindParryAttr(ball)
    end
    parryConnChild = workspace.Balls.ChildAdded:Connect(function(child)
        if not autoParryEnabled then return end
        if child:GetAttribute("realBall") then
            bindParryAttr(child)
        end
    end)
    parryConnSim = RunService.Heartbeat:Connect(function(delta)
        if not autoParryEnabled then return end
        local hrp = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local ballsToParry = {}

        for _, ball in ipairs(GetBalls()) do
            if not ballData[ball] then
                bindParryAttr(ball)
            end
            local data = ballData[ball]
            if ball.Anchored or not ball:FindFirstChild("zoomies") then continue end

            local pos = ball.Position
            local vel = ball.zoomies.VectorVelocity
            local speed = vel.Magnitude
            if speed < 0.5 then continue end

            local accel = (vel - data.lastVel) / delta
            local velUnit = vel.Unit
            local tangentialAccel = accel:Dot(velUnit)
            local normalAccel = accel - tangentialAccel * velUnit
            local normalAccelMag = normalAccel.Magnitude
            local curvatureMeasure = normalAccelMag / speed
            local t = math.clamp(curvatureMeasure / 10, 0, 1)
            local baseThreshold = 0.45 - 0.1 * t

            data.lastVel = vel
            data.lastPos = pos

            local pingOffset = Player:GetNetworkPing() * 1000
            local pingFactor = math.clamp(pingOffset / 1000, 0, 0.15)
            local dynamicThreshold = baseThreshold + pingFactor * 0.15
            dynamicThreshold = dynamicThreshold * (1 - math.clamp(speed / 350, 0, 0.3))

            local toTarget = hrp.Position - pos
            local forwardDir = velUnit
            local forwardDist = toTarget:Dot(forwardDir)
            local timeToHit = forwardDist / speed

            local predictedPos = pos + vel * timeToHit + 0.5 * accel * timeToHit * timeToHit
            local distToPredicted = (hrp.Position - predictedPos).Magnitude

            if distToPredicted > 30 then continue end

            if ball:GetAttribute("target") == Player.Name and not data.IsParried and timeToHit >= 0.1 and timeToHit <= dynamicThreshold then
                table.insert(ballsToParry, { Ball = ball, Data = data })
            end
        end

        if #ballsToParry > 0 then
            local screenPos = Vector2.new(MousePosition.X, MousePosition.Y)
            for i = 1, #ballsToParry do
                VirtualInputManager:SendMouseButtonEvent(screenPos.X, screenPos.Y, 0, true, game, 0)
                VirtualInputManager:SendMouseButtonEvent(screenPos.X, screenPos.Y, 0, false, game, 0)
            end
            for _, parryInfo in ipairs(ballsToParry) do
                local data = parryInfo.Data
                data.IsParried = true
                data.Cooldown = tick()
            end
        end

        for _, ball in ipairs(GetBalls()) do
            local data = ballData[ball]
            if data and tick() - data.Cooldown >= 0.5 then
                data.IsParried = false
            end
        end
    end)
end

local function setupSpam()
    if spamConn then spamConn:Disconnect() spamConn = nil end
    local lastClickTime = 0
    local clickCooldown = 0.05
    spamConn = RunService.Heartbeat:Connect(function()
        if not autoSpamEnabled then return end
        if tick() - lastClickTime >= clickCooldown then
            VirtualInputManager:SendMouseButtonEvent(MousePosition.X, MousePosition.Y, 0, true, game, 0)
            VirtualInputManager:SendMouseButtonEvent(MousePosition.X, MousePosition.Y, 0, false, game, 0)
            keypress(0x46)
            lastClickTime = tick()
        end
    end)
end

UserInputService.InputChanged:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseMovement then
        MousePosition = i.Position
    end
end)

local sect = Tabs.Main:AddSection("Auto Controls")
Tabs.Main:AddToggle("AutoParry", { Title = "Auto Parry", Default = false }):OnChanged(function()
    autoParryEnabled = Options.AutoParry.Value
    if autoParryEnabled then
        setupParry()
        Fluent:Notify({ Title = "Slavan Hub", Content = "Auto Parry Enabled", Duration = 2 })
    else
        ResetParry()
    end
end)
Tabs.Main:AddKeybind("AutoSpamBind", {
    Title = "Auto Spam Toggle",
    Description = "Toggles auto spam on/off",
    Mode = "Toggle",
    Default = "E",
    Callback = function(Value)
        autoSpamEnabled = Value
        if autoSpamEnabled then
            setupSpam()
            Fluent:Notify({ Title = "Slavan Hub", Content = "Auto Spam Enabled", Duration = 2 })
        else
            if spamConn then spamConn:Disconnect() spamConn = nil end
            Fluent:Notify({ Title = "Slavan Hub", Content = "Auto Spam Disabled", Duration = 2 })
        end
    end
})

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("SlavanHub")
SaveManager:SetFolder("SlavanHub/BladeBall")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)
Fluent:Notify({ Title = "Slavan Hub", Content = "Script Loaded", Duration = 3 })
SaveManager:LoadAutoloadConfig()
