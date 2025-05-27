local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

local HitboxSettings = {
    Enabled = false,
    Size = Vector3.new(8, 8, 8),
    Transparency = 0.7,
    Color = Color3.fromRGB(255, 255, 255),
    Material = Enum.Material.ForceField,
    VisualEnabled = true,
}

local KillAuraSettings = {
    Enabled = false,
    Range = 8,
    Delay = 0.1,
    SyncWithHitbox = true
}

local ORIGINAL_SIZES = {}
local ActiveHitboxes = {}
local lastAttackTime = 0

local Window = WindUI:CreateWindow({
    Title = "Slavan Hub",
    Icon = "zap",
    Author = "by NotAka",
    Folder = "SlavanHub",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
    User = {
        Enabled = false
    },
    SideBarWidth = 180,
    HasOutline = true,
})

local Tabs = {
    HitboxTab = Window:Tab({ Title = "Hitboxes", Icon = "target" }),
    KillAuraTab = Window:Tab({ Title = "Kill Aura", Icon = "crosshair" }),
    VisualTab = Window:Tab({ Title = "Visual", Icon = "eye" }),
}

local function IsValidR6Character(character)
    if not character then return false end
    return character:FindFirstChild("Humanoid") and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Torso")
end

local function CreateVisualHitbox(player)
    if not HitboxSettings.VisualEnabled or not player.Character or not IsValidR6Character(player.Character) then return end
    
    local character = player.Character
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    local existingVisual = character:FindFirstChild("VisualHitbox")
    if existingVisual then existingVisual:Destroy() end
    
    local visualHitbox = Instance.new("Part")
    visualHitbox.Name = "VisualHitbox"
    visualHitbox.Anchored = true
    visualHitbox.CanCollide = false
    visualHitbox.Transparency = HitboxSettings.Transparency
    visualHitbox.Color = HitboxSettings.Color
    visualHitbox.Material = HitboxSettings.Material
    visualHitbox.Size = HitboxSettings.Size
    visualHitbox.CFrame = humanoidRootPart.CFrame
    visualHitbox.Parent = character
    
    ActiveHitboxes[player] = visualHitbox
    
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if character.Parent and humanoidRootPart.Parent and visualHitbox.Parent then
            visualHitbox.CFrame = humanoidRootPart.CFrame
            visualHitbox.Size = HitboxSettings.Size
            visualHitbox.Transparency = HitboxSettings.Transparency
            visualHitbox.Color = HitboxSettings.Color
            visualHitbox.Material = HitboxSettings.Material
        else
            connection:Disconnect()
            if ActiveHitboxes[player] == visualHitbox then
                ActiveHitboxes[player] = nil
            end
            if visualHitbox.Parent then
                visualHitbox:Destroy()
            end
        end
    end)
end

local function ExpandHitbox(player)
    if player == LocalPlayer then return end
    if not player.Character or not IsValidR6Character(player.Character) then return end
    
    local character = player.Character
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    if not ORIGINAL_SIZES[player] then
        ORIGINAL_SIZES[player] = humanoidRootPart.Size
    end
    
    humanoidRootPart.Size = HitboxSettings.Size
    humanoidRootPart.Transparency = 1
    
    CreateVisualHitbox(player)
end

local function RestoreHitbox(player)
    if not player.Character or not IsValidR6Character(player.Character) then return end
    
    local character = player.Character
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end
    
    if ORIGINAL_SIZES[player] then
        humanoidRootPart.Size = ORIGINAL_SIZES[player]
        humanoidRootPart.Transparency = 1
    end
    
    local visualHitbox = character:FindFirstChild("VisualHitbox")
    if visualHitbox then visualHitbox:Destroy() end
    
    if ActiveHitboxes[player] then
        ActiveHitboxes[player] = nil
    end
end

local function ApplyHitboxesToAll()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if HitboxSettings.Enabled then
                ExpandHitbox(player)
            else
                RestoreHitbox(player)
            end
        end
    end
end

local function UpdateAllHitboxes()
    for player, hitbox in pairs(ActiveHitboxes) do
        if hitbox and hitbox.Parent then
            hitbox.Size = HitboxSettings.Size
            hitbox.Transparency = HitboxSettings.Transparency
            hitbox.Color = HitboxSettings.Color
            hitbox.Material = HitboxSettings.Material
        end
    end
end

local function GetDistance(player)
    if not LocalPlayer.Character or not player.Character then return 999 end
    if not LocalPlayer.Character.HumanoidRootPart or not player.Character.HumanoidRootPart then return 999 end
    
    local myPos = LocalPlayer.Character.HumanoidRootPart.Position
    local theirPos = player.Character.HumanoidRootPart.Position
    
    return (myPos - theirPos).Magnitude
end

local function FindClosestTarget()
    local closestPlayer = nil
    local closestDistance = KillAuraSettings.Range
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and IsValidR6Character(player.Character) then
            local distance = GetDistance(player)
            if distance < closestDistance then
                closestDistance = distance
                closestPlayer = player
            end
        end
    end
    
    return closestPlayer, closestDistance
end

local function KillAuraLoop()
    if not KillAuraSettings.Enabled then return end
    if not LocalPlayer.Character or not IsValidR6Character(LocalPlayer.Character) then return end
    
    local currentTime = tick()
    if currentTime - lastAttackTime < KillAuraSettings.Delay then return end
    
    local target, distance = FindClosestTarget()
    
    if target then
        mouse1click()
        lastAttackTime = currentTime
    end
end

local function OnPlayerAdded(player)
    if player == LocalPlayer then return end
    
    player.CharacterAdded:Connect(function(character)
        wait(2)
        if HitboxSettings.Enabled and IsValidR6Character(character) then
            ExpandHitbox(player)
        end
    end)
    
    if player.Character and IsValidR6Character(player.Character) then
        if HitboxSettings.Enabled then
            ExpandHitbox(player)
        end
    end
end

local function OnPlayerRemoving(player)
    ORIGINAL_SIZES[player] = nil
    if ActiveHitboxes[player] then
        ActiveHitboxes[player] = nil
    end
end

Players.PlayerAdded:Connect(OnPlayerAdded)
Players.PlayerRemoving:Connect(OnPlayerRemoving)

for _, player in pairs(Players:GetPlayers()) do
    OnPlayerAdded(player)
end

Tabs.HitboxTab:Toggle({
    Title = "Enable Hitboxes",
    Value = HitboxSettings.Enabled,
    Callback = function(state)
        HitboxSettings.Enabled = state
        ApplyHitboxesToAll()
        
        if KillAuraSettings.SyncWithHitbox then
            KillAuraSettings.Range = HitboxSettings.Size.X
        end
    end
})

Tabs.HitboxTab:Slider({
    Title = "Hitbox Size",
    Value = { Min = 4, Max = 20, Default = 8 },
    Callback = function(value)
        HitboxSettings.Size = Vector3.new(value, value, value)
        UpdateAllHitboxes()
        
        if KillAuraSettings.SyncWithHitbox then
            KillAuraSettings.Range = value
        end
    end
})

Tabs.HitboxTab:Button({
    Title = "Size: 8",
    Callback = function()
        HitboxSettings.Size = Vector3.new(8, 8, 8)
        UpdateAllHitboxes()
        if KillAuraSettings.SyncWithHitbox then
            KillAuraSettings.Range = 8
        end
    end
})

Tabs.HitboxTab:Button({
    Title = "Size: 12",
    Callback = function()
        HitboxSettings.Size = Vector3.new(12, 12, 12)
        UpdateAllHitboxes()
        if KillAuraSettings.SyncWithHitbox then
            KillAuraSettings.Range = 12
        end
    end
})

Tabs.HitboxTab:Button({
    Title = "Size: 16",
    Callback = function()
        HitboxSettings.Size = Vector3.new(16, 16, 16)
        UpdateAllHitboxes()
        if KillAuraSettings.SyncWithHitbox then
            KillAuraSettings.Range = 16
        end
    end
})

Tabs.KillAuraTab:Toggle({
    Title = "Enable Kill Aura",
    Value = KillAuraSettings.Enabled,
    Callback = function(state)
        KillAuraSettings.Enabled = state
    end
})

Tabs.KillAuraTab:Toggle({
    Title = "Sync with Hitbox",
    Value = KillAuraSettings.SyncWithHitbox,
    Callback = function(state)
        KillAuraSettings.SyncWithHitbox = state
        if state then
            KillAuraSettings.Range = HitboxSettings.Size.X
        end
    end
})

Tabs.KillAuraTab:Slider({
    Title = "Attack Range",
    Value = { Min = 4, Max = 25, Default = KillAuraSettings.Range },
    Callback = function(value)
        KillAuraSettings.Range = value
    end
})

Tabs.KillAuraTab:Slider({
    Title = "Attack Delay (sec)",
    Value = { Min = 0.02, Max = 0.5, Default = KillAuraSettings.Delay },
    Callback = function(value)
        KillAuraSettings.Delay = value
    end
})

Tabs.KillAuraTab:Button({
    Title = "Fast Attack (0.05 sec)",
    Callback = function()
        KillAuraSettings.Delay = 0.05
    end
})

Tabs.KillAuraTab:Button({
    Title = "Very Fast Attack (0.03 sec)",
    Callback = function()
        KillAuraSettings.Delay = 0.03
    end
})

Tabs.VisualTab:Toggle({
    Title = "Show Hitboxes",
    Value = HitboxSettings.VisualEnabled,
    Callback = function(state)
        HitboxSettings.VisualEnabled = state
        if state then
            ApplyHitboxesToAll()
        else
            for player, hitbox in pairs(ActiveHitboxes) do
                if hitbox then hitbox:Destroy() end
            end
            ActiveHitboxes = {}
        end
    end
})

Tabs.VisualTab:Slider({
    Title = "Hitbox Transparency",
    Value = { Min = 0, Max = 1, Default = HitboxSettings.Transparency },
    Callback = function(value)
        HitboxSettings.Transparency = value
        UpdateAllHitboxes()
    end
})

Tabs.VisualTab:Colorpicker({
    Title = "Hitbox Color",
    Default = HitboxSettings.Color,
    Callback = function(color)
        HitboxSettings.Color = color
        UpdateAllHitboxes()
    end
})

local materialOptions = {"ForceField", "Neon", "Glass", "Plastic", "Metal", "CorrodedMetal"}
Tabs.VisualTab:Dropdown({
    Title = "Hitbox Material",
    Values = materialOptions,
    Value = "ForceField",
    Callback = function(option)
        HitboxSettings.Material = Enum.Material[option]
        UpdateAllHitboxes()
    end
})

Tabs.VisualTab:Button({
    Title = "Update All Hitboxes",
    Callback = function()
        ApplyHitboxesToAll()
    end
})

Tabs.VisualTab:Button({
    Title = "Clear All Hitboxes",
    Callback = function()
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                RestoreHitbox(player)
            end
        end
        HitboxSettings.Enabled = false
        KillAuraSettings.Enabled = false
    end
})

RunService.PreSimulation:Connect(KillAuraLoop)

spawn(function()
    while wait(5) do
        if HitboxSettings.Enabled then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and IsValidR6Character(player.Character) then
                    local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
                    if humanoidRootPart and humanoidRootPart.Size ~= HitboxSettings.Size then
                        ExpandHitbox(player)
                    end
                end
            end
        end
    end
end)

Window:SetToggleKey(Enum.KeyCode.Insert)
