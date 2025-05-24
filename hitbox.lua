local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local settings = {
    hitboxEnabled = true,
    hitboxSize = Vector3.new(10000, 10000, 10000),
    minHitboxSize = 20,
    maxHitboxSize = 500,
    hitboxTransparency = 1,
    highlightEntities = false,
    highlightColor = Color3.fromRGB(255, 0, 0),
    
    updateInterval = 0.2,
    debugMode = true,
    
    dungeonEnemies = {
        "Bear", "Goblin", "Bear Cub", "Goblin Archer", "Goblin Brute", "Goblin Witch",
        "Wolf", "Crowling", "Direwolf", "Giant Crow", "Tengu Crow", "Tengu Crow Sorcerer",
        "Skeleton Pirate", "Merfolk", "Coral Skeleton", "Merfolk Spearman", "Deadeye Skeleton", "Merfolk Priest",
        "Dark Ritualist", "Knight", "Hellforged Goblin", "Hellforged Archer", "Dark Priest", "Obsidian Knight",
        "Golem", "Jaguar", "Baboon", "Jagged Jaguar", "Baboon Brute", "Stonespeaker Golem",
        "Harpy", "Djinn", "Storm Harpy", "Tempest Djinn", "Holy Harpy", "Storm Djinn"
    },
    
    bossNames = {
        "Blackbeard", "Bol'zarog", "Loto Elderagyn", "Melchior", "Sea Serpent", "Ursolare", "Yukiona", "Okurio"
    },
    
    entityFolders = {
        "Enemies", "Mobs", "Monsters", "Bosses", "NPCs", "Entities", "Spawns",
        "ShatteredForest", "OrionsPeak", "DeadmansCove", "FlamingDepths", "MosscrownJungle", "AstralAbyss"
    }
}

local modified = {}
local lastScanTime = 0
local modifiedCount = 0

local function debugPrint(...)
    if settings.debugMode then
        print("[DH Hitboxes]", ...)
    end
end

local function updateCharacterReferences()
    Character = LocalPlayer.Character
    if Character then
        Humanoid = Character:WaitForChild("Humanoid")
        HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
        debugPrint("Character references updated")
    end
end

local function isValidEntity(model)
    if not model or typeof(model) ~= "Instance" or not model:IsA("Model") then return false end
    if not model.Parent then return false end
    
    local success = pcall(function() return model.Name end)
    if not success then return false end
    
    local player = Players:GetPlayerFromCharacter(model)
    if player then return false end
    
    for _, enemyName in ipairs(settings.dungeonEnemies) do
        if model.Name == enemyName or model.Name:lower():find(enemyName:lower()) then
            return true, "enemy", enemyName
        end
    end
    
    for _, bossName in ipairs(settings.bossNames) do
        if model.Name == bossName or model.Name:lower():find(bossName:lower()) then
            return true, "boss", bossName
        end
    end
    
    local hasHumanoid = false
    local hasHRP = false
    local hasHealth = false
    
    pcall(function()
        hasHumanoid = model:FindFirstChildOfClass("Humanoid") ~= nil
        hasHRP = model:FindFirstChild("HumanoidRootPart") ~= nil
        local humanoid = model:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.Health > 0 then
            hasHealth = true
        end
    end)
    
    if hasHumanoid or hasHRP or hasHealth then
        return true, "entity", model.Name
    end
    
    return false
end

local function modifyHitbox(model)
    if modified[model] or not model.Parent then return end
    
    local success = pcall(function()
        local partsToModify = {}
        
        if model:FindFirstChild("HumanoidRootPart") then
            table.insert(partsToModify, model.HumanoidRootPart)
        end
        
        if model.PrimaryPart and not table.find(partsToModify, model.PrimaryPart) then
            table.insert(partsToModify, model.PrimaryPart)
        end
        
        if #partsToModify == 0 then
            for _, child in ipairs(model:GetDescendants()) do
                if child:IsA("BasePart") then
                    table.insert(partsToModify, child)
                    break
                end
            end
        end
        
        if #partsToModify > 0 then
            modified[model] = { parts = {}, model = model }
            
            for _, part in ipairs(partsToModify) do
                if part and part.Parent then
                    modified[model].parts[part] = {
                        originalSize = part.Size,
                        originalTransparency = part.Transparency,
                        originalCanCollide = part.CanCollide
                    }
                    
                    part.Size = settings.hitboxSize
                    part.Transparency = settings.hitboxTransparency
                    part.CanCollide = false
                    
                    if settings.highlightEntities then
                        local highlight = Instance.new("Highlight")
                        highlight.Name = "EntityHighlight"
                        highlight.FillColor = settings.highlightColor
                        highlight.OutlineColor = Color3.fromRGB(0, 0, 0)
                        highlight.FillTransparency = 0.7
                        highlight.OutlineTransparency = 0
                        highlight.Parent = part
                    end
                end
            end
            
            modifiedCount = modifiedCount + 1
        end
    end)
    
    if success then
        debugPrint("Modified hitbox:", model.Name)
    end
end

local function scanForEntities()
    if not settings.hitboxEnabled then return end
    
    local currentTime = tick()
    if currentTime - lastScanTime < settings.updateInterval then return end
    lastScanTime = currentTime
    
    local containersToCheck = { workspace }
    
    for _, containerName in ipairs({"Enemies", "Mobs", "Monsters", "Bosses", "Game", "World", "Dungeons"}) do
        pcall(function()
            if workspace:FindFirstChild(containerName) then
                table.insert(containersToCheck, workspace[containerName])
            end
        end)
    end
    
    for _, container in ipairs(containersToCheck) do
        if container then
            pcall(function()
                for _, child in ipairs(container:GetChildren()) do
                    if isValidEntity(child) then
                        modifyHitbox(child)
                    end
                end
                
                for _, folder in ipairs(container:GetChildren()) do
                    if folder:IsA("Folder") or folder:IsA("Model") then
                        for _, entity in ipairs(folder:GetChildren()) do
                            if isValidEntity(entity) then
                                modifyHitbox(entity)
                            end
                        end
                    end
                end
            end)
        end
    end
end

local function resetHitboxes()
    for model, data in pairs(modified) do
        if model and model.Parent then
            for part, partData in pairs(data.parts) do
                if part and part:IsDescendantOf(game) then
                    pcall(function()
                        part.Size = partData.originalSize
                        part.Transparency = partData.originalTransparency  
                        part.CanCollide = partData.originalCanCollide
                        
                        local highlight = part:FindFirstChild("EntityHighlight")
                        if highlight then highlight:Destroy() end
                    end)
                end
            end
        end
    end
    modified = {}
    modifiedCount = 0
    debugPrint("All hitboxes reset")
end

local Window = Fluent:CreateWindow({
    Title = "Dungeon Heroes Hitbox Mod",
    SubTitle = "Working hitboxes for all enemies",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local HitboxTab = Window:AddTab({ Title = "Hitboxes", Icon = "target" })
local SettingsTab = Window:AddTab({ Title = "Settings", Icon = "settings" })

HitboxTab:AddParagraph({
    Title = "Enemy Hitbox Modifier",
    Content = "Modifies hitboxes of all enemies in the game for easier combat"
})

local MainStatus = HitboxTab:AddParagraph({
    Title = "Current Status",
    Content = "Hitboxes: " .. (settings.hitboxEnabled and "✅" or "❌") .. " | Modified Entities: " .. modifiedCount
})

local HitboxToggle = HitboxTab:AddToggle("HitboxToggle", {
    Title = "Enable Hitboxes",
    Description = "Modifies enemy hitboxes for easier targeting",
    Default = settings.hitboxEnabled
})

HitboxToggle:OnChanged(function(Value)
    settings.hitboxEnabled = Value
    if Value then
        scanForEntities()
    else
        resetHitboxes()
    end
end)

local SizeSlider = HitboxTab:AddSlider("HitboxSize", {
    Title = "Hitbox Size",
    Description = "Size of the modified hitboxes",
    Default = settings.hitboxSize.X,
    Min = settings.minHitboxSize,
    Max = settings.maxHitboxSize,
    Rounding = 0,
    Callback = function(Value)
        settings.hitboxSize = Vector3.new(Value, Value, Value)
        if settings.hitboxEnabled then
            for model, data in pairs(modified) do
                if model and model.Parent then
                    for part, _ in pairs(data.parts) do
                        if part and part:IsDescendantOf(game) then
                            pcall(function() part.Size = settings.hitboxSize end)
                        end
                    end
                end
            end
        end
    end
})

local TransparencySlider = HitboxTab:AddSlider("HitboxTransparency", {
    Title = "Transparency",
    Description = "Visual transparency of hitboxes (1 = invisible)",
    Default = settings.hitboxTransparency,
    Min = 0,
    Max = 1,
    Rounding = 2,
    Callback = function(Value)
        settings.hitboxTransparency = Value
        if settings.hitboxEnabled then
            for model, data in pairs(modified) do
                if model and model.Parent then
                    for part, _ in pairs(data.parts) do
                        if part and part:IsDescendantOf(game) then
                            pcall(function() part.Transparency = settings.hitboxTransparency end)
                        end
                    end
                end
            end
        end
    end
})

local HighlightToggle = HitboxTab:AddToggle("HighlightToggle", {
    Title = "Highlight Entities",
    Description = "Shows colored highlights on modified entities",
    Default = settings.highlightEntities
})

HighlightToggle:OnChanged(function(Value)
    settings.highlightEntities = Value
    if settings.hitboxEnabled then
        resetHitboxes()
        scanForEntities()
    end
end)

HitboxTab:AddButton({
    Title = "Full Scan",
    Description = "Scan all areas for entities to modify",
    Callback = function()
        scanForEntities()
    end
})

HitboxTab:AddButton({
    Title = "Reset All Hitboxes", 
    Description = "Reverts all hitbox modifications",
    Callback = function()
        resetHitboxes()
    end
})

RunService.Heartbeat:Connect(function()
    pcall(function()
        if not Character or not Character.Parent then
            updateCharacterReferences()
        end
        
        if settings.hitboxEnabled then
            scanForEntities()
        end
        
        MainStatus:SetDesc("Hitboxes: " .. (settings.hitboxEnabled and "✅" or "❌") .. " | Modified Entities: " .. modifiedCount)
    end)
end)

LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    wait(1)
    updateCharacterReferences()
    debugPrint("Character respawned, systems reloaded")
end)

workspace.ChildAdded:Connect(function(child)
    wait(0.5)
    if settings.hitboxEnabled and isValidEntity(child) then
        modifyHitbox(child)
    end
end)

SaveManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetFolder("DungeonHeroesHitbox")
SaveManager:BuildConfigSection(SettingsTab)

InterfaceManager:SetLibrary(Fluent)
InterfaceManager:SetFolder("DungeonHeroesHitbox") 
InterfaceManager:BuildInterfaceSection(SettingsTab)

updateCharacterReferences()
if settings.hitboxEnabled then
    scanForEntities()
end

debugPrint("Dungeon Heroes Hitbox Mod loaded successfully!")
