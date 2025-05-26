-- Core Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local SoundService = game:GetService("SoundService")
local TextService = game:GetService("TextService")
local Debris = game:GetService("Debris")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Load WindUI library
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- Error protection
local function SafeCall(func, ...)
    local success, result = pcall(func, ...)
    return success and result or nil
end

-- Check available functions for saving settings
local canSaveSettings = (writefile ~= nil and readfile ~= nil and isfile ~= nil)

-- ESP Settings
local ESP = {
    Enabled = false,
    ShowNames = false,
    NameSize = 14,
    NameFont = Enum.Font.GothamBold,
    Chams = false,
    ChamsTransparency = 0.5,
    ShowDistance = false,
    ShowBoxes = false,
    ShowHealth = false,
    ShowTracers = false,
    MaxRenderDistance = 2000,
    UseTeamColors = false,
    CurrentSchemeIndex = 1,
    Version = "v4.2 WindUI Edition",
    BoxThickness = 1.5,
    TracerThickness = 1.2,
    NameOutline = false,
    Rainbow = false,
    RainbowSpeed = 1.0,
    
    -- Keybind settings
    Keybinds = {
        ToggleESP = Enum.KeyCode.RightAlt,
        ToggleChams = Enum.KeyCode.RightControl,
        ToggleMenu = Enum.KeyCode.Delete,
        ReloadESP = Enum.KeyCode.Home,
        ToggleJumpEffect = Enum.KeyCode.J -- New key for jump effects
    },
    
    -- Jump effect settings
    JumpEffect = {
        Enabled = false,
        CurrentEffectIndex = 1,  -- Current effect scheme
        ShowOnJump = false,      -- Show on jump
        ShowOnLand = false,      -- Show on landing
        EffectThickness = 1.2,   -- Effect line thickness
        ParticleCount = 20,      -- Particle count
        CircleRadius = 4.5,      -- Circle radius
        MaxExpandRadius = 8,     -- Maximum expansion radius
        AnimDuration = 0.7,      -- Animation duration
        Segments = 72,           -- Segment count (smoothness)
        LayerCount = 4,          -- Layer count
        Rainbow = false,         -- Rainbow effect
        RainbowSpeed = 1.0,      -- Rainbow speed
        EnableParticles = false, -- Enable particles
        EnableWaves = false,     -- Enable waves
        EnableGlow = false,      -- Enable glow
        EnablePulse = false      -- Enable pulse
    },
    
    -- Available fonts
    AvailableFonts = {
        [1] = {Name = "Gotham", Font = Enum.Font.Gotham},
        [2] = {Name = "Gotham Bold", Font = Enum.Font.GothamBold},
        [3] = {Name = "Oswald", Font = Enum.Font.Oswald},
        [4] = {Name = "Source Sans", Font = Enum.Font.SourceSans},
        [5] = {Name = "Arial", Font = Enum.Font.Arial},
        [6] = {Name = "Patrick Hand", Font = Enum.Font.PatrickHand},
        [7] = {Name = "Bangers", Font = Enum.Font.Bangers},
        [8] = {Name = "System", Font = Enum.Font.SourceSansBold},
        [9] = {Name = "Narrow", Font = Enum.Font.SourceSansLight},
        [10] = {Name = "Cartoon", Font = Enum.Font.Cartoon}
    },
    
    -- Current selected font
    CurrentFontIndex = 2,
    
    -- Setting presets
    Presets = {
        {
            Name = "Standard",
            Settings = {
                Enabled = true,
                ShowNames = true,
                NameSize = 14,
                Chams = true,
                ChamsTransparency = 0.5,
                ShowDistance = true,
                ShowBoxes = false,
                ShowHealth = false,
                ShowTracers = true
            }
        },
        {
            Name = "Combat",
            Settings = {
                Enabled = true,
                ShowNames = true,
                NameSize = 16,
                Chams = true,
                ChamsTransparency = 0.3,
                ShowDistance = true,
                ShowBoxes = true,
                ShowHealth = true,
                ShowTracers = true
            }
        },
        {
            Name = "Minimal",
            Settings = {
                Enabled = true,
                ShowNames = true,
                NameSize = 12,
                Chams = false,
                ShowDistance = false,
                ShowBoxes = false,
                ShowHealth = false,
                ShowTracers = false
            }
        },
        {
            Name = "Stealth",
            Settings = {
                Enabled = true,
                ShowNames = false,
                Chams = true,
                ChamsTransparency = 0.8,
                ShowDistance = false,
                ShowBoxes = false,
                ShowHealth = false,
                ShowTracers = false
            }
        }
    }
}

-- Create 30 jump effect schemes with nice names
ESP.JumpEffect.EffectSchemes = {
    -- 1-10: Basic effects
    {
        Name = "Classic",
        Type = "Circle",
        Colors = {
            Color3.fromRGB(255, 0, 0),     -- Red
            Color3.fromRGB(255, 100, 100), -- Light red
            Color3.fromRGB(255, 50, 50),   -- Medium red
        }
    },
    {
        Name = "Neon Blue",
        Type = "Circle",
        Colors = {
            Color3.fromRGB(0, 120, 255),    -- Neon blue
            Color3.fromRGB(100, 180, 255),  -- Light blue
            Color3.fromRGB(50, 150, 255),   -- Medium blue
        }
    },
    {
        Name = "Green Pulse",
        Type = "Circle",
        Colors = {
            Color3.fromRGB(0, 250, 100),   -- Neon green
            Color3.fromRGB(100, 255, 150), -- Light green
            Color3.fromRGB(50, 200, 100),  -- Medium green
        }
    },
    {
        Name = "Purple Aura",
        Type = "Circle",
        Colors = {
            Color3.fromRGB(170, 0, 255),    -- Purple
            Color3.fromRGB(200, 100, 255),  -- Light purple
            Color3.fromRGB(140, 50, 200),   -- Dark purple
        }
    },
    {
        Name = "Golden Trail",
        Type = "Circle",
        Colors = {
            Color3.fromRGB(255, 200, 0),    -- Gold
            Color3.fromRGB(255, 230, 100),  -- Light gold
            Color3.fromRGB(200, 170, 0),    -- Dark gold
        }
    },
    {
        Name = "Cyberpunk",
        Type = "Hex",
        Colors = {
            Color3.fromRGB(255, 0, 150),    -- Magenta
            Color3.fromRGB(0, 220, 255),    -- Cyber blue
            Color3.fromRGB(255, 240, 0),    -- Bright yellow
        }
    },
    {
        Name = "Digital Wave",
        Type = "Wave",
        Colors = {
            Color3.fromRGB(0, 150, 200),    -- Blue
            Color3.fromRGB(0, 220, 255),    -- Cyan
            Color3.fromRGB(100, 200, 255),  -- Light blue
        }
    },
    {
        Name = "Fire Circle",
        Type = "Circle",
        Colors = {
            Color3.fromRGB(255, 100, 0),    -- Orange
            Color3.fromRGB(255, 50, 0),     -- Red-orange
            Color3.fromRGB(255, 200, 0),    -- Yellow-orange
        }
    },
    {
        Name = "Ice Flash",
        Type = "Circle",
        Colors = {
            Color3.fromRGB(200, 240, 255),  -- White with blue tint
            Color3.fromRGB(150, 200, 255),  -- Light blue
            Color3.fromRGB(100, 170, 255),  -- Blue
        }
    },
    {
        Name = "Dark Matter",
        Type = "Circle",
        Colors = {
            Color3.fromRGB(40, 0, 80),      -- Dark purple
            Color3.fromRGB(80, 0, 160),     -- Purple
            Color3.fromRGB(120, 0, 200),    -- Light purple
        }
    },
    
    -- 11-20: Combined effects
    {
        Name = "Radioactive",
        Type = "Hex",
        Colors = {
            Color3.fromRGB(170, 255, 0),    -- Toxic green
            Color3.fromRGB(100, 200, 0),    -- Green
            Color3.fromRGB(200, 255, 100),  -- Light green
        }
    },
    {
        Name = "Electric",
        Type = "Wave",
        Colors = {
            Color3.fromRGB(60, 170, 255),   -- Electric blue
            Color3.fromRGB(100, 200, 255),  -- Light blue
            Color3.fromRGB(220, 240, 255),  -- White with blue tint
        }
    },
    {
        Name = "Sunset",
        Type = "Circle",
        Colors = {
            Color3.fromRGB(255, 100, 50),   -- Orange-red
            Color3.fromRGB(255, 150, 50),   -- Orange
            Color3.fromRGB(255, 200, 100),  -- Yellow-orange
        }
    },
    {
        Name = "Galaxy",
        Type = "Hex",
        Colors = {
            Color3.fromRGB(100, 0, 200),    -- Purple
            Color3.fromRGB(200, 0, 255),    -- Pink-purple
            Color3.fromRGB(0, 100, 200),    -- Blue
        }
    },
    {
        Name = "Neon City",
        Type = "Wave",
        Colors = {
            Color3.fromRGB(255, 0, 100),    -- Neon pink
            Color3.fromRGB(0, 200, 255),    -- Neon blue
            Color3.fromRGB(255, 240, 0),    -- Neon yellow
        }
    },
    {
        Name = "Pixelated",
        Type = "Hex",
        Colors = {
            Color3.fromRGB(255, 50, 50),    -- Red
            Color3.fromRGB(50, 100, 255),   -- Blue
            Color3.fromRGB(50, 200, 50),    -- Green
        }
    },
    {
        Name = "Amethyst",
        Type = "Circle",
        Colors = {
            Color3.fromRGB(170, 80, 220),   -- Amethyst
            Color3.fromRGB(200, 130, 255),  -- Light amethyst
            Color3.fromRGB(140, 50, 180),   -- Dark amethyst
        }
    },
    {
        Name = "Emerald",
        Type = "Circle",
        Colors = {
            Color3.fromRGB(0, 180, 90),     -- Emerald
            Color3.fromRGB(50, 220, 120),   -- Light emerald
            Color3.fromRGB(0, 150, 80),     -- Dark emerald
        }
    },
    {
        Name = "Ruby",
        Type = "Circle",
        Colors = {
            Color3.fromRGB(200, 0, 50),     -- Ruby
            Color3.fromRGB(255, 50, 100),   -- Light ruby
            Color3.fromRGB(160, 0, 40),     -- Dark ruby
        }
    },
    {
        Name = "Sapphire",
        Type = "Circle",
        Colors = {
            Color3.fromRGB(0, 50, 200),     -- Sapphire
            Color3.fromRGB(50, 100, 255),   -- Light sapphire
            Color3.fromRGB(0, 30, 150),     -- Dark sapphire
        }
    },
    
    -- 21-30: Special effects
    {
        Name = "Pastel Rainbow",
        Type = "Circle",
        Colors = {
            Color3.fromRGB(255, 170, 200),  -- Pastel pink
            Color3.fromRGB(170, 230, 255),  -- Pastel blue
            Color3.fromRGB(200, 255, 170),  -- Pastel green
            Color3.fromRGB(255, 255, 170),  -- Pastel yellow
            Color3.fromRGB(210, 170, 255),  -- Pastel purple
        }
    },
    {
        Name = "Monochrome",
        Type = "Hex",
        Colors = {
            Color3.fromRGB(255, 255, 255),  -- White
            Color3.fromRGB(180, 180, 180),  -- Light gray
            Color3.fromRGB(100, 100, 100),  -- Gray
            Color3.fromRGB(50, 50, 50),     -- Dark gray
        }
    },
    {
        Name = "Prismatic",
        Type = "Wave",
        Colors = {
            Color3.fromRGB(255, 0, 0),      -- Red
            Color3.fromRGB(255, 165, 0),    -- Orange
            Color3.fromRGB(255, 255, 0),    -- Yellow
            Color3.fromRGB(0, 255, 0),      -- Green
            Color3.fromRGB(0, 0, 255),      -- Blue
            Color3.fromRGB(130, 0, 255),    -- Purple
        }
    },
    {
        Name = "Coral Reef",
        Type = "Circle",
        Colors = {
            Color3.fromRGB(255, 150, 130),  -- Coral
            Color3.fromRGB(130, 210, 255),  -- Sea
            Color3.fromRGB(160, 255, 210),  -- Aquamarine
            Color3.fromRGB(255, 210, 160),  -- Sand
        }
    },
    {
        Name = "Night Sky",
        Type = "Hex",
        Colors = {
            Color3.fromRGB(10, 20, 50),     -- Dark blue
            Color3.fromRGB(40, 50, 100),    -- Blue
            Color3.fromRGB(70, 80, 150),    -- Light blue
            Color3.fromRGB(200, 200, 255),  -- Star
        }
    },
    {
        Name = "Volcanic",
        Type = "Wave",
        Colors = {
            Color3.fromRGB(50, 0, 0),       -- Dark red
            Color3.fromRGB(150, 20, 0),     -- Red
            Color3.fromRGB(200, 50, 0),     -- Orange-red
            Color3.fromRGB(255, 150, 0),    -- Orange
            Color3.fromRGB(255, 200, 0),    -- Yellow
        }
    },
    {
        Name = "Cyber Glitch",
        Type = "Hex",
        Colors = {
            Color3.fromRGB(255, 0, 100),    -- Pink
            Color3.fromRGB(0, 255, 255),    -- Cyan
            Color3.fromRGB(255, 255, 0),    -- Yellow
            Color3.fromRGB(0, 0, 0),        -- Black
        }
    },
    {
        Name = "Mirage",
        Type = "Circle",
        Colors = {
            Color3.fromRGB(255, 220, 180),  -- Pale orange
            Color3.fromRGB(255, 180, 180),  -- Pale pink
            Color3.fromRGB(180, 180, 255),  -- Pale blue
            Color3.fromRGB(180, 255, 220),  -- Pale mint
        }
    },
    {
        Name = "Quantum Leap",
        Type = "Wave",
        Colors = {
            Color3.fromRGB(0, 80, 200),     -- Dark blue
            Color3.fromRGB(80, 0, 200),     -- Purple
            Color3.fromRGB(0, 200, 200),    -- Turquoise
            Color3.fromRGB(200, 0, 200),    -- Magenta
        }
    },
    {
        Name = "Rainbow Dust",
        Type = "Circle",
        Colors = {
            Color3.fromRGB(255, 0, 0),      -- Red
            Color3.fromRGB(255, 165, 0),    -- Orange
            Color3.fromRGB(255, 255, 0),    -- Yellow
            Color3.fromRGB(0, 255, 0),      -- Green
            Color3.fromRGB(0, 0, 255),      -- Blue
            Color3.fromRGB(130, 0, 255),    -- Purple
        }
    }
}

-- Create 50 color schemes with nice names
ESP.ColorSchemes = {
    -- 1-10: Basic
    {
        Name = "Red",
        Enemy = Color3.fromRGB(255, 0, 0),
        Team = Color3.fromRGB(0, 255, 0),
        NameColor = Color3.fromRGB(255, 255, 255),
        BoxColor = Color3.fromRGB(255, 0, 0),
        TracerColor = Color3.fromRGB(255, 0, 0)
    },
    {
        Name = "Blue",
        Enemy = Color3.fromRGB(0, 100, 255),
        Team = Color3.fromRGB(0, 255, 255),
        NameColor = Color3.fromRGB(255, 255, 255),
        BoxColor = Color3.fromRGB(0, 100, 255),
        TracerColor = Color3.fromRGB(0, 100, 255)
    },
    {
        Name = "Green",
        Enemy = Color3.fromRGB(0, 200, 0),
        Team = Color3.fromRGB(150, 255, 150),
        NameColor = Color3.fromRGB(255, 255, 255),
        BoxColor = Color3.fromRGB(0, 200, 0),
        TracerColor = Color3.fromRGB(0, 200, 0)
    },
    {
        Name = "Gold",
        Enemy = Color3.fromRGB(255, 215, 0),
        Team = Color3.fromRGB(255, 255, 150),
        NameColor = Color3.fromRGB(255, 255, 255),
        BoxColor = Color3.fromRGB(255, 215, 0),
        TracerColor = Color3.fromRGB(255, 215, 0)
    },
    {
        Name = "Purple",
        Enemy = Color3.fromRGB(128, 0, 255),
        Team = Color3.fromRGB(200, 150, 255),
        NameColor = Color3.fromRGB(255, 255, 255),
        BoxColor = Color3.fromRGB(128, 0, 255),
        TracerColor = Color3.fromRGB(128, 0, 255)
    },
    {
        Name = "Pink",
        Enemy = Color3.fromRGB(255, 0, 150),
        Team = Color3.fromRGB(255, 150, 200),
        NameColor = Color3.fromRGB(255, 255, 255),
        BoxColor = Color3.fromRGB(255, 0, 150),
        TracerColor = Color3.fromRGB(255, 0, 150)
    },
    {
        Name = "Orange",
        Enemy = Color3.fromRGB(255, 128, 0),
        Team = Color3.fromRGB(255, 200, 100),
        NameColor = Color3.fromRGB(255, 255, 255),
        BoxColor = Color3.fromRGB(255, 128, 0),
        TracerColor = Color3.fromRGB(255, 128, 0)
    },
    {
        Name = "Navy Blue",
        Enemy = Color3.fromRGB(0, 0, 128),
        Team = Color3.fromRGB(100, 100, 255),
        NameColor = Color3.fromRGB(255, 255, 255),
        BoxColor = Color3.fromRGB(0, 0, 128),
        TracerColor = Color3.fromRGB(0, 0, 128)
    },
    {
        Name = "Turquoise",
        Enemy = Color3.fromRGB(0, 180, 180),
        Team = Color3.fromRGB(100, 255, 255),
        NameColor = Color3.fromRGB(255, 255, 255),
        BoxColor = Color3.fromRGB(0, 180, 180),
        TracerColor = Color3.fromRGB(0, 180, 180)
    },
    {
        Name = "Black",
        Enemy = Color3.fromRGB(10, 10, 10),
        Team = Color3.fromRGB(150, 150, 150),
        NameColor = Color3.fromRGB(255, 255, 255),
        BoxColor = Color3.fromRGB(10, 10, 10),
        TracerColor = Color3.fromRGB(10, 10, 10)
    },
    
    -- 11-20: Neon versions
    {
        Name = "Neon Red",
        Enemy = Color3.fromRGB(255, 0, 60),
        Team = Color3.fromRGB(100, 255, 100),
        NameColor = Color3.fromRGB(255, 200, 200),
        BoxColor = Color3.fromRGB(255, 0, 60),
        TracerColor = Color3.fromRGB(255, 0, 60)
    },
    {
        Name = "Neon Blue",
        Enemy = Color3.fromRGB(50, 120, 255),
        Team = Color3.fromRGB(50, 255, 255),
        NameColor = Color3.fromRGB(200, 220, 255),
        BoxColor = Color3.fromRGB(50, 120, 255),
        TracerColor = Color3.fromRGB(50, 120, 255)
    },
    {
        Name = "Neon Green",
        Enemy = Color3.fromRGB(0, 255, 100),
        Team = Color3.fromRGB(150, 255, 200),
        NameColor = Color3.fromRGB(220, 255, 220),
        BoxColor = Color3.fromRGB(0, 255, 100),
        TracerColor = Color3.fromRGB(0, 255, 100)
    },
    {
        Name = "Neon Yellow",
        Enemy = Color3.fromRGB(255, 255, 0),
        Team = Color3.fromRGB(255, 255, 150),
        NameColor = Color3.fromRGB(255, 255, 200),
        BoxColor = Color3.fromRGB(255, 255, 0),
        TracerColor = Color3.fromRGB(255, 255, 0)
    },
    {
        Name = "Neon Purple",
        Enemy = Color3.fromRGB(180, 0, 255),
        Team = Color3.fromRGB(220, 150, 255),
        NameColor = Color3.fromRGB(230, 200, 255),
        BoxColor = Color3.fromRGB(180, 0, 255),
        TracerColor = Color3.fromRGB(180, 0, 255)
    },
    {
        Name = "Neon Pink",
        Enemy = Color3.fromRGB(255, 0, 200),
        Team = Color3.fromRGB(255, 150, 230),
        NameColor = Color3.fromRGB(255, 200, 230),
        BoxColor = Color3.fromRGB(255, 0, 200),
        TracerColor = Color3.fromRGB(255, 0, 200)
    },
    {
        Name = "Neon Cyan",
        Enemy = Color3.fromRGB(0, 220, 255),
        Team = Color3.fromRGB(150, 230, 255),
        NameColor = Color3.fromRGB(200, 240, 255),
        BoxColor = Color3.fromRGB(0, 220, 255),
        TracerColor = Color3.fromRGB(0, 220, 255)
    },
    {
        Name = "Neon Orange",
        Enemy = Color3.fromRGB(255, 128, 50),
        Team = Color3.fromRGB(255, 200, 150),
        NameColor = Color3.fromRGB(255, 220, 200),
        BoxColor = Color3.fromRGB(255, 128, 50),
        TracerColor = Color3.fromRGB(255, 128, 50)
    },
    {
        Name = "Neon Crimson",
        Enemy = Color3.fromRGB(255, 0, 100),
        Team = Color3.fromRGB(255, 150, 180),
        NameColor = Color3.fromRGB(255, 200, 220),
        BoxColor = Color3.fromRGB(255, 0, 100),
        TracerColor = Color3.fromRGB(255, 0, 100)
    },
    {
        Name = "Neon White",
        Enemy = Color3.fromRGB(240, 240, 240),
        Team = Color3.fromRGB(200, 200, 200),
        NameColor = Color3.fromRGB(255, 255, 255),
        BoxColor = Color3.fromRGB(240, 240, 240),
        TracerColor = Color3.fromRGB(240, 240, 240)
    },
    
    -- 21-30: Pastel
    {
        Name = "Pastel Pink",
        Enemy = Color3.fromRGB(255, 160, 200),
        Team = Color3.fromRGB(230, 200, 230),
        NameColor = Color3.fromRGB(255, 255, 255),
        BoxColor = Color3.fromRGB(255, 160, 200),
        TracerColor = Color3.fromRGB(255, 160, 200)
    },
    {
        Name = "Pastel Blue",
        Enemy = Color3.fromRGB(160, 210, 255),
        Team = Color3.fromRGB(200, 230, 255),
        NameColor = Color3.fromRGB(255, 255, 255),
        BoxColor = Color3.fromRGB(160, 210, 255),
        TracerColor = Color3.fromRGB(160, 210, 255)
    },
    {
        Name = "Pastel Green",
        Enemy = Color3.fromRGB(180, 255, 180),
        Team = Color3.fromRGB(220, 255, 220),
        NameColor = Color3.fromRGB(255, 255, 255),
        BoxColor = Color3.fromRGB(180, 255, 180),
        TracerColor = Color3.fromRGB(180, 255, 180)
    },
    {
        Name = "Pastel Yellow",
        Enemy = Color3.fromRGB(255, 255, 160),
        Team = Color3.fromRGB(255, 255, 200),
        NameColor = Color3.fromRGB(255, 255, 255),
        BoxColor = Color3.fromRGB(255, 255, 160),
        TracerColor = Color3.fromRGB(255, 255, 160)
    },
    {
        Name = "Pastel Lavender",
        Enemy = Color3.fromRGB(210, 180, 255),
        Team = Color3.fromRGB(230, 210, 255),
        NameColor = Color3.fromRGB(255, 255, 255),
        BoxColor = Color3.fromRGB(210, 180, 255),
        TracerColor = Color3.fromRGB(210, 180, 255)
    },
    {
        Name = "Pastel Peach",
        Enemy = Color3.fromRGB(255, 210, 180),
        Team = Color3.fromRGB(255, 230, 210),
        NameColor = Color3.fromRGB(255, 255, 255),
        BoxColor = Color3.fromRGB(255, 210, 180),
        TracerColor = Color3.fromRGB(255, 210, 180)
    },
    {
        Name = "Pastel Mint",
        Enemy = Color3.fromRGB(180, 255, 210),
        Team = Color3.fromRGB(210, 255, 230),
        NameColor = Color3.fromRGB(255, 255, 255),
        BoxColor = Color3.fromRGB(180, 255, 210),
        TracerColor = Color3.fromRGB(180, 255, 210)
    },
    {
        Name = "Pastel Lavender",
        Enemy = Color3.fromRGB(200, 180, 255),
        Team = Color3.fromRGB(220, 210, 255),
        NameColor = Color3.fromRGB(255, 255, 255),
        BoxColor = Color3.fromRGB(200, 180, 255),
        TracerColor = Color3.fromRGB(200, 180, 255)
    },
    {
        Name = "Pastel Turquoise",
        Enemy = Color3.fromRGB(180, 255, 255),
        Team = Color3.fromRGB(210, 255, 255),
        NameColor = Color3.fromRGB(255, 255, 255),
        BoxColor = Color3.fromRGB(180, 255, 255),
        TracerColor = Color3.fromRGB(180, 255, 255)
    },
    {
        Name = "Pastel Cream",
        Enemy = Color3.fromRGB(255, 240, 210),
        Team = Color3.fromRGB(255, 250, 230),
        NameColor = Color3.fromRGB(255, 255, 255),
        BoxColor = Color3.fromRGB(255, 240, 210),
        TracerColor = Color3.fromRGB(255, 240, 210)
    },
    
    -- 31-40: Dark
    {
        Name = "Dark Red",
        Enemy = Color3.fromRGB(140, 0, 0),
        Team = Color3.fromRGB(200, 50, 50),
        NameColor = Color3.fromRGB(255, 255, 255),
        BoxColor = Color3.fromRGB(140, 0, 0),
        TracerColor = Color3.fromRGB(140, 0, 0)
    },
    {
        Name = "Dark Blue",
        Enemy = Color3.fromRGB(0, 0, 100),
        Team = Color3.fromRGB(50, 50, 200),
        NameColor = Color3.fromRGB(255, 255, 255),
        BoxColor = Color3.fromRGB(0, 0, 100),
        TracerColor = Color3.fromRGB(0, 0, 100)
    },
    {
        Name = "Dark Green",
        Enemy = Color3.fromRGB(0, 90, 0),
        Team = Color3.fromRGB(50, 150, 50),
        NameColor = Color3.fromRGB(255, 255, 255),
        BoxColor = Color3.fromRGB(0, 90, 0),
        TracerColor = Color3.fromRGB(0, 90, 0)
    },
    {
        Name = "Brown",
        Enemy = Color3.fromRGB(120, 60, 0),
        Team = Color3.fromRGB(180, 120, 60),
        NameColor = Color3.fromRGB(255, 255, 255),
        BoxColor = Color3.fromRGB(120, 60, 0),
        TracerColor = Color3.fromRGB(120, 60, 0)
    },
    {
        Name = "Dark Purple",
        Enemy = Color3.fromRGB(80, 0, 80),
        Team = Color3.fromRGB(140, 60, 140),
        NameColor = Color3.fromRGB(255, 255, 255),
        BoxColor = Color3.fromRGB(80, 0, 80),
        TracerColor = Color3.fromRGB(80, 0, 80)
    },
    {
        Name = "Burgundy",
        Enemy = Color3.fromRGB(120, 0, 40),
        Team = Color3.fromRGB(180, 60, 100),
        NameColor = Color3.fromRGB(255, 255, 255),
        BoxColor = Color3.fromRGB(120, 0, 40),
        TracerColor = Color3.fromRGB(120, 0, 40)
    },
    {
        Name = "Dark Turquoise",
        Enemy = Color3.fromRGB(0, 80, 80),
        Team = Color3.fromRGB(60, 140, 140),
        NameColor = Color3.fromRGB(255, 255, 255),
        BoxColor = Color3.fromRGB(0, 80, 80),
        TracerColor = Color3.fromRGB(0, 80, 80)
    },
    {
        Name = "Dark Gray",
        Enemy = Color3.fromRGB(50, 50, 50),
        Team = Color3.fromRGB(100, 100, 100),
        NameColor = Color3.fromRGB(255, 255, 255),
        BoxColor = Color3.fromRGB(50, 50, 50),
        TracerColor = Color3.fromRGB(50, 50, 50)
    },
    {
        Name = "Dark Olive",
        Enemy = Color3.fromRGB(80, 80, 0),
        Team = Color3.fromRGB(140, 140, 60),
        NameColor = Color3.fromRGB(255, 255, 255),
        BoxColor = Color3.fromRGB(80, 80, 0),
        TracerColor = Color3.fromRGB(80, 80, 0)
    },
    {
        Name = "Dark Indigo",
        Enemy = Color3.fromRGB(40, 0, 100),
        Team = Color3.fromRGB(100, 60, 160),
        NameColor = Color3.fromRGB(255, 255, 255),
        BoxColor = Color3.fromRGB(40, 0, 100),
        TracerColor = Color3.fromRGB(40, 0, 100)
    },
    
    -- 41-50: Contrast and special
    {
        Name = "Contrast Red-Blue",
        Enemy = Color3.fromRGB(255, 0, 0),
        Team = Color3.fromRGB(0, 0, 255),
        NameColor = Color3.fromRGB(255, 255, 255),
        BoxColor = Color3.fromRGB(255, 0, 0),
        TracerColor = Color3.fromRGB(255, 0, 0)
    },
    {
        Name = "Contrast Blue-Yellow",
        Enemy = Color3.fromRGB(0, 0, 255),
        Team = Color3.fromRGB(255, 255, 0),
        NameColor = Color3.fromRGB(255, 255, 255),
        BoxColor = Color3.fromRGB(0, 0, 255),
        TracerColor = Color3.fromRGB(0, 0, 255)
    },
    {
        Name = "Contrast Green-Purple",
        Enemy = Color3.fromRGB(0, 255, 0),
        Team = Color3.fromRGB(255, 0, 255),
        NameColor = Color3.fromRGB(255, 255, 255),
        BoxColor = Color3.fromRGB(0, 255, 0),
        TracerColor = Color3.fromRGB(0, 255, 0)
    },
    {
        Name = "Acid",
        Enemy = Color3.fromRGB(180, 255, 0),
        Team = Color3.fromRGB(0, 255, 180),
        NameColor = Color3.fromRGB(255, 255, 255),
        BoxColor = Color3.fromRGB(180, 255, 0),
        TracerColor = Color3.fromRGB(180, 255, 0)
    },
    {
        Name = "Cyan",
        Enemy = Color3.fromRGB(0, 255, 255),
        Team = Color3.fromRGB(150, 255, 255),
        NameColor = Color3.fromRGB(255, 255, 255),
        BoxColor = Color3.fromRGB(0, 255, 255),
        TracerColor = Color3.fromRGB(0, 255, 255)
    },
    {
        Name = "Crimson",
        Enemy = Color3.fromRGB(255, 0, 80),
        Team = Color3.fromRGB(255, 150, 180),
        NameColor = Color3.fromRGB(255, 255, 255),
        BoxColor = Color3.fromRGB(255, 0, 80),
        TracerColor = Color3.fromRGB(255, 0, 80)
    },
    {
        Name = "Lime",
        Enemy = Color3.fromRGB(180, 255, 0),
        Team = Color3.fromRGB(220, 255, 150),
        NameColor = Color3.fromRGB(255, 255, 255),
        BoxColor = Color3.fromRGB(180, 255, 0),
        TracerColor = Color3.fromRGB(180, 255, 0)
    },
    {
        Name = "Coral",
        Enemy = Color3.fromRGB(255, 128, 80),
        Team = Color3.fromRGB(255, 180, 150),
        NameColor = Color3.fromRGB(255, 255, 255),
        BoxColor = Color3.fromRGB(255, 128, 80),
        TracerColor = Color3.fromRGB(255, 128, 80)
    },
    {
        Name = "Amethyst",
        Enemy = Color3.fromRGB(153, 102, 204),
        Team = Color3.fromRGB(200, 170, 230),
        NameColor = Color3.fromRGB(255, 255, 255),
        BoxColor = Color3.fromRGB(153, 102, 204),
        TracerColor = Color3.fromRGB(153, 102, 204)
    },
    {
        Name = "Rainbow",
        Enemy = Color3.fromRGB(255, 0, 0), -- Replaced with rainbowColor
        Team = Color3.fromRGB(0, 255, 0),  -- Replaced with rainbowColor
        NameColor = Color3.fromRGB(255, 255, 255),
        BoxColor = Color3.fromRGB(255, 0, 0), -- Replaced with rainbowColor
        TracerColor = Color3.fromRGB(255, 0, 0) -- Replaced with rainbowColor
    }
}

-- Sounds for UI
local Sounds = {
    Click = {ID = "rbxassetid://6026984224", Volume = 0.5},
    Hover = {ID = "rbxassetid://6026984216", Volume = 0.2},
    Toggle = {ID = "rbxassetid://6026984216", Volume = 0.3},
    Notification = {ID = "rbxassetid://6026984224", Volume = 0.6},
    Error = {ID = "rbxassetid://6022668945", Volume = 0.5}
}

-- Load sounds
local function LoadSounds()
    local soundContainer = Instance.new("Folder")
    soundContainer.Name = "SlavanHubSounds"
    soundContainer.Parent = SoundService
    
    for name, soundInfo in pairs(Sounds) do
        local sound = Instance.new("Sound")
        sound.Name = name
        sound.SoundId = soundInfo.ID
        sound.Volume = soundInfo.Volume
        sound.Parent = soundContainer
    end
    
    return soundContainer
end

-- Sound container
local SoundContainer = LoadSounds()

-- Function to play sounds
local function PlaySound(soundName)
    local sound = SoundContainer:FindFirstChild(soundName)
    if sound then
        sound:Play()
    end
end

-- Get current color scheme
function ESP:GetCurrentScheme()
    return self.ColorSchemes[self.CurrentSchemeIndex]
end

-- Get current font
function ESP:GetCurrentFont()
    return self.AvailableFonts[self.CurrentFontIndex].Font
end

-- Get current jump effect scheme
function ESP:GetCurrentJumpEffect()
    return self.JumpEffect.EffectSchemes[self.JumpEffect.CurrentEffectIndex]
end

-- Load preset
function ESP:LoadPreset(presetIndex)
    local preset = self.Presets[presetIndex]
    if not preset then return end
    
    for key, value in pairs(preset.Settings) do
        if self[key] ~= nil then
            self[key] = value
        end
    end
    
    ApplyChamsToAllPlayers()
    WindUI:Notify({
        Title = "Preset Loaded",
        Content = "Preset: " .. preset.Name,
        Duration = 2
    })
end

-- Rainbow color
local rainbowColor = Color3.fromRGB(255, 0, 0)
local rainbowHue = 0

-- Update rainbow color
local function UpdateRainbowColor(deltaTime)
    if not ESP.Rainbow and not ESP.JumpEffect.Rainbow then return end
    
    -- Update main rainbow color for ESP
    if ESP.Rainbow then
        rainbowHue = (rainbowHue + deltaTime * ESP.RainbowSpeed) % 1
        rainbowColor = Color3.fromHSV(rainbowHue, 1, 1)
        
        -- Update all elements with rainbow color
        ApplyChamsToAllPlayers()
    end
end

-- Create main window
local Window = WindUI:CreateWindow({
    Title = "Slavan Hub " .. ESP.Version,
    Icon = "eye",
    Author = "NotAka",
    Folder = "SlavanHub",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
    HasOutline = true,
})

-- Configure UI open button
Window:EditOpenButton({
    Title = "Slavan Hub",
    Icon = "eye",
    CornerRadius = UDim.new(0, 16),
    StrokeThickness = 2,
    Color = ColorSequence.new(
        Color3.fromRGB(128, 0, 255),
        Color3.fromRGB(0, 150, 255)
    ),
    Draggable = true,
})

-- Create tabs
local Tabs = {
    ESPTab = Window:Tab({ Title = "ESP", Icon = "eye", Desc = "Main ESP settings" }),
    AppearanceTab = Window:Tab({ Title = "Appearance", Icon = "palette", Desc = "ESP appearance settings" }),
    JumpEffectsTab = Window:Tab({ Title = "Jump Effects", Icon = "activity", Desc = "Jump effect settings" }),
    SettingsTab = Window:Tab({ Title = "Settings", Icon = "settings", Desc = "Script settings" }),
    KeybindsTab = Window:Tab({ Title = "Keybinds", Icon = "keyboard", Desc = "Hotkey settings" }),
    InfoTab = Window:Tab({ Title = "Information", Icon = "info", ShowTabTitle = true }),
}

-- Function to display notifications
function ShowNotification(message, duration)
    WindUI:Notify({
        Title = "Slavan Hub",
        Content = message,
        Duration = duration or 3
    })
end

-- ESP TAB
-- Main settings
Tabs.ESPTab:Paragraph({
    Title = "Slavan Hub " .. ESP.Version,
    Desc = "Advanced ESP script with customizable elements and jump effects by NotAka",
    Image = "eye"
})

Tabs.ESPTab:Toggle({
    Title = "Enable ESP",
    Value = ESP.Enabled,
    Callback = function(Value)
        ESP.Enabled = Value
        ApplyChamsToAllPlayers()
    end
})

Tabs.ESPTab:Toggle({
    Title = "Show Names",
    Value = ESP.ShowNames,
    Callback = function(Value)
        ESP.ShowNames = Value
        ApplyChamsToAllPlayers()
    end
})

Tabs.ESPTab:Toggle({
    Title = "Show Distance",
    Value = ESP.ShowDistance,
    Callback = function(Value)
        ESP.ShowDistance = Value
        ApplyChamsToAllPlayers()
    end
})

Tabs.ESPTab:Toggle({
    Title = "Highlight Through Walls",
    Value = ESP.Chams,
    Callback = function(Value)
        ESP.Chams = Value
        ApplyChamsToAllPlayers()
    end
})

-- Additional settings
Tabs.ESPTab:Section({ Title = "Additional" })

Tabs.ESPTab:Toggle({
    Title = "Show Boxes",
    Value = ESP.ShowBoxes,
    Callback = function(Value)
        ESP.ShowBoxes = Value
        ApplyChamsToAllPlayers()
    end
})

Tabs.ESPTab:Toggle({
    Title = "Show Tracers",
    Value = ESP.ShowTracers,
    Callback = function(Value)
        ESP.ShowTracers = Value
        UpdateTracerSettings()
        ApplyChamsToAllPlayers()
    end
})

Tabs.ESPTab:Toggle({
    Title = "Show Health",
    Value = ESP.ShowHealth,
    Callback = function(Value)
        ESP.ShowHealth = Value
        ApplyChamsToAllPlayers()
    end
})

Tabs.ESPTab:Toggle({
    Title = "Use Team Colors",
    Value = ESP.UseTeamColors,
    Callback = function(Value)
        ESP.UseTeamColors = Value
        ApplyChamsToAllPlayers()
    end
})

-- APPEARANCE TAB
-- Appearance settings
Tabs.AppearanceTab:Section({ Title = "Settings" })

Tabs.AppearanceTab:Slider({
    Title = "Highlight Transparency",
    Value = {
        Min = 0,
        Max = 1,
        Default = ESP.ChamsTransparency,
    },
    Callback = function(Value)
        ESP.ChamsTransparency = Value
        ApplyChamsToAllPlayers()
    end
})

Tabs.AppearanceTab:Slider({
    Title = "Name Size",
    Value = {
        Min = 10,
        Max = 24,
        Default = ESP.NameSize,
    },
    Callback = function(Value)
        ESP.NameSize = Value
        ApplyChamsToAllPlayers()
    end
})

Tabs.AppearanceTab:Slider({
    Title = "Box Thickness",
    Value = {
        Min = 1,
        Max = 5,
        Default = ESP.BoxThickness,
    },
    Callback = function(Value)
        ESP.BoxThickness = Value
        ApplyChamsToAllPlayers()
    end
})

Tabs.AppearanceTab:Slider({
    Title = "Tracer Thickness",
    Value = {
        Min = 0.5,
        Max = 5,
        Default = ESP.TracerThickness,
    },
    Callback = function(Value)
        ESP.TracerThickness = Value
        ApplyChamsToAllPlayers()
    end
})

Tabs.AppearanceTab:Toggle({
    Title = "Text Outline",
    Value = ESP.NameOutline,
    Callback = function(Value)
        ESP.NameOutline = Value
        ApplyChamsToAllPlayers()
    end
})

-- Distance settings
Tabs.AppearanceTab:Section({ Title = "Distance" })

Tabs.AppearanceTab:Slider({
    Title = "Max Render Distance",
    Value = {
        Min = 500,
        Max = 5000,
        Default = ESP.MaxRenderDistance,
    },
    Callback = function(Value)
        ESP.MaxRenderDistance = Value
        ApplyChamsToAllPlayers()
    end
})

-- Rainbow settings
Tabs.AppearanceTab:Section({ Title = "Rainbow Mode" })

Tabs.AppearanceTab:Toggle({
    Title = "Enable Rainbow Effect",
    Value = ESP.Rainbow,
    Callback = function(Value)
        ESP.Rainbow = Value
        ApplyChamsToAllPlayers()
    end
})

Tabs.AppearanceTab:Slider({
    Title = "Rainbow Speed",
    Value = {
        Min = 0.1,
        Max = 2,
        Default = ESP.RainbowSpeed,
    },
    Callback = function(Value)
        ESP.RainbowSpeed = Value
    end
})

-- Color scheme selection
Tabs.AppearanceTab:Section({ Title = "Color Schemes" })

local colorSchemeNames = {}
for i, scheme in ipairs(ESP.ColorSchemes) do
    table.insert(colorSchemeNames, scheme.Name)
end

local colorSchemeDropdown = Tabs.AppearanceTab:Dropdown({
    Title = "Select Color Scheme",
    Values = colorSchemeNames,
    Value = colorSchemeNames[ESP.CurrentSchemeIndex],
    Callback = function(selectedScheme)
        for i, schemeName in ipairs(colorSchemeNames) do
            if schemeName == selectedScheme then
                ESP.CurrentSchemeIndex = i
                break
            end
        end
        ApplyChamsToAllPlayers()
    end
})

-- Font selection
Tabs.AppearanceTab:Section({ Title = "Fonts" })

local fontNames = {}
for i, fontInfo in ipairs(ESP.AvailableFonts) do
    table.insert(fontNames, fontInfo.Name)
end

local fontDropdown = Tabs.AppearanceTab:Dropdown({
    Title = "Select Font",
    Values = fontNames,
    Value = fontNames[ESP.CurrentFontIndex],
    Callback = function(selectedFont)
        for i, fontName in ipairs(fontNames) do
            if fontName == selectedFont then
                ESP.CurrentFontIndex = i
                break
            end
        end
        ApplyChamsToAllPlayers()
    end
})

-- JUMP EFFECTS TAB
-- Main settings
Tabs.JumpEffectsTab:Section({ Title = "Main Settings" })

Tabs.JumpEffectsTab:Toggle({
    Title = "Enable Jump Effect",
    Value = ESP.JumpEffect.Enabled,
    Callback = function(Value)
        ESP.JumpEffect.Enabled = Value
        ShowNotification("Jump effect " .. (Value and "enabled" or "disabled"))
    end
})

Tabs.JumpEffectsTab:Toggle({
    Title = "On Jump",
    Value = ESP.JumpEffect.ShowOnJump,
    Callback = function(Value)
        ESP.JumpEffect.ShowOnJump = Value
    end
})

Tabs.JumpEffectsTab:Toggle({
    Title = "On Landing",
    Value = ESP.JumpEffect.ShowOnLand,
    Callback = function(Value)
        ESP.JumpEffect.ShowOnLand = Value
    end
})

Tabs.JumpEffectsTab:Toggle({
    Title = "Enable Particles",
    Value = ESP.JumpEffect.EnableParticles,
    Callback = function(Value)
        ESP.JumpEffect.EnableParticles = Value
    end
})

-- Additional jump effect settings
Tabs.JumpEffectsTab:Section({ Title = "Additional" })

Tabs.JumpEffectsTab:Toggle({
    Title = "Enable Waves",
    Value = ESP.JumpEffect.EnableWaves,
    Callback = function(Value)
        ESP.JumpEffect.EnableWaves = Value
    end
})

Tabs.JumpEffectsTab:Toggle({
    Title = "Enable Glow",
    Value = ESP.JumpEffect.EnableGlow,
    Callback = function(Value)
        ESP.JumpEffect.EnableGlow = Value
    end
})

Tabs.JumpEffectsTab:Toggle({
    Title = "Enable Pulse",
    Value = ESP.JumpEffect.EnablePulse,
    Callback = function(Value)
        ESP.JumpEffect.EnablePulse = Value
    end
})

Tabs.JumpEffectsTab:Toggle({
    Title = "Rainbow Effect",
    Value = ESP.JumpEffect.Rainbow,
    Callback = function(Value)
        ESP.JumpEffect.Rainbow = Value
    end
})

-- Jump effect parameter settings
Tabs.JumpEffectsTab:Section({ Title = "Effect Parameters" })

Tabs.JumpEffectsTab:Slider({
    Title = "Circle Radius",
    Value = {
        Min = 2,
        Max = 8,
        Default = ESP.JumpEffect.CircleRadius,
    },
    Callback = function(Value)
        ESP.JumpEffect.CircleRadius = Value
    end
})

Tabs.JumpEffectsTab:Slider({
    Title = "Max Expansion Radius",
    Value = {
        Min = 5,
        Max = 15,
        Default = ESP.JumpEffect.MaxExpandRadius,
    },
    Callback = function(Value)
        ESP.JumpEffect.MaxExpandRadius = Value
    end
})

Tabs.JumpEffectsTab:Slider({
    Title = "Line Thickness",
    Value = {
        Min = 0.5,
        Max = 3,
        Default = ESP.JumpEffect.EffectThickness,
    },
    Callback = function(Value)
        ESP.JumpEffect.EffectThickness = Value
    end
})

Tabs.JumpEffectsTab:Slider({
    Title = "Particle Count",
    Value = {
        Min = 10,
        Max = 50,
        Default = ESP.JumpEffect.ParticleCount,
    },
    Callback = function(Value)
        ESP.JumpEffect.ParticleCount = Value
    end
})

-- Jump effect scheme selection
Tabs.JumpEffectsTab:Section({ Title = "Effect Schemes" })

local jumpEffectNames = {}
for i, scheme in ipairs(ESP.JumpEffect.EffectSchemes) do
    table.insert(jumpEffectNames, scheme.Name)
end

local jumpEffectDropdown = Tabs.JumpEffectsTab:Dropdown({
    Title = "Select Effect",
    Values = jumpEffectNames,
    Value = jumpEffectNames[ESP.JumpEffect.CurrentEffectIndex],
    Callback = function(selectedEffect)
        for i, effectName in ipairs(jumpEffectNames) do
            if effectName == selectedEffect then
                ESP.JumpEffect.CurrentEffectIndex = i
                ShowNotification("Selected effect: " .. effectName)
                break
            end
        end
    end
})

-- SETTINGS TAB
-- Presets
Tabs.SettingsTab:Section({ Title = "Presets" })

local presetNames = {}
for i, preset in ipairs(ESP.Presets) do
    table.insert(presetNames, preset.Name)
end

local presetDropdown = Tabs.SettingsTab:Dropdown({
    Title = "Select Preset",
    Values = presetNames,
    Value = "Select a preset",
    Callback = function(selectedPreset)
        for i, presetName in ipairs(presetNames) do
            if presetName == selectedPreset then
                ESP:LoadPreset(i)
                break
            end
        end
    end
})

-- Settings management
Tabs.SettingsTab:Section({ Title = "Settings Management" })

-- Functions for saving/loading settings
function SaveSettings()
    if not canSaveSettings then 
        ShowNotification("Save function not available in your exploit")
        return false 
    end
    
    local settings = {
        Enabled = ESP.Enabled,
        ShowNames = ESP.ShowNames,
        NameSize = ESP.NameSize,
        CurrentFontIndex = ESP.CurrentFontIndex,
        Chams = ESP.Chams,
        ChamsTransparency = ESP.ChamsTransparency,
        ShowDistance = ESP.ShowDistance,
        ShowBoxes = ESP.ShowBoxes,
        ShowHealth = ESP.ShowHealth,
        ShowTracers = ESP.ShowTracers,
        MaxRenderDistance = ESP.MaxRenderDistance,
        UseTeamColors = ESP.UseTeamColors,
        CurrentSchemeIndex = ESP.CurrentSchemeIndex,
        BoxThickness = ESP.BoxThickness,
        TracerThickness = ESP.TracerThickness,
        NameOutline = ESP.NameOutline,
        Rainbow = ESP.Rainbow,
        RainbowSpeed = ESP.RainbowSpeed,
        
        -- Jump effect settings
        JumpEffect = {
            Enabled = ESP.JumpEffect.Enabled,
            CurrentEffectIndex = ESP.JumpEffect.CurrentEffectIndex,
            ShowOnJump = ESP.JumpEffect.ShowOnJump,
            ShowOnLand = ESP.JumpEffect.ShowOnLand,
            EffectThickness = ESP.JumpEffect.EffectThickness,
            ParticleCount = ESP.JumpEffect.ParticleCount,
            CircleRadius = ESP.JumpEffect.CircleRadius,
            MaxExpandRadius = ESP.JumpEffect.MaxExpandRadius,
            AnimDuration = ESP.JumpEffect.AnimDuration,
            Segments = ESP.JumpEffect.Segments,
            LayerCount = ESP.JumpEffect.LayerCount,
            Rainbow = ESP.JumpEffect.Rainbow,
            RainbowSpeed = ESP.JumpEffect.RainbowSpeed,
            EnableParticles = ESP.JumpEffect.EnableParticles,
            EnableWaves = ESP.JumpEffect.EnableWaves,
            EnableGlow = ESP.JumpEffect.EnableGlow,
            EnablePulse = ESP.JumpEffect.EnablePulse
        },
        
        Keybinds = {
            ToggleESP = tostring(ESP.Keybinds.ToggleESP),
            ToggleChams = tostring(ESP.Keybinds.ToggleChams),
            ToggleMenu = tostring(ESP.Keybinds.ToggleMenu),
            ReloadESP = tostring(ESP.Keybinds.ReloadESP),
            ToggleJumpEffect = tostring(ESP.Keybinds.ToggleJumpEffect)
        }
    }
    
    -- Serialize to JSON
    local success, result = pcall(function()
        local json = HttpService:JSONEncode(settings)
        writefile("slavan_hub_settings.json", json)
        return true
    end)
    
    return success and result
end

function LoadSettings()
    if not canSaveSettings then 
        ShowNotification("Load function not available in your exploit")
        return false 
    end
    
    local success, settings = pcall(function()
        if isfile("slavan_hub_settings.json") then
            local json = readfile("slavan_hub_settings.json")
            return HttpService:JSONDecode(json)
        end
        return nil
    end)
    
    if success and settings then
        -- Load main settings
        for key, value in pairs(settings) do
            if key ~= "Keybinds" and key ~= "JumpEffect" then
                ESP[key] = value
            end
        end
        
        -- Load jump effect settings
        if settings.JumpEffect then
            for key, value in pairs(settings.JumpEffect) do
                ESP.JumpEffect[key] = value
            end
        end
        
        -- Load keybinds
        if settings.Keybinds then
            for key, valueStr in pairs(settings.Keybinds) do
                local keyCode = Enum.KeyCode[valueStr]
                if keyCode then
                    ESP.Keybinds[key] = keyCode
                end
            end
        end
        
        return true
    end
    
    return false
end

Tabs.SettingsTab:Button({
    Title = "Save Settings",
    Callback = function()
        if SaveSettings() then
            ShowNotification("Settings successfully saved")
        else
            ShowNotification("Failed to save settings")
        end
    end
})

Tabs.SettingsTab:Button({
    Title = "Load Settings",
    Callback = function()
        if LoadSettings() then
            ShowNotification("Settings successfully loaded")
            ApplyChamsToAllPlayers()
        else
            ShowNotification("Failed to load settings")
        end
    end
})

Tabs.SettingsTab:Button({
    Title = "Reset All Settings",
    Callback = function()
        Window:Dialog({
            Title = "Reset Settings?",
            Content = "Are you sure you want to reset all settings to default values?",
            Icon = "alert-triangle",
            Buttons = {
                {
                    Title = "Cancel",
                    Variant = "Secondary",
                    Callback = function()
                        ShowNotification("Settings reset canceled")
                    end
                },
                {
                    Title = "Yes, reset",
                    Variant = "Primary",
                    Callback = function()
                        ESP = {
                            Enabled = false,
                            ShowNames = false,
                            NameSize = 14,
                            NameFont = Enum.Font.GothamBold,
                            Chams = false,
                            ChamsTransparency = 0.5,
                            ShowDistance = false,
                            ShowBoxes = false,
                            ShowHealth = false,
                            ShowTracers = false,
                            MaxRenderDistance = 2000,
                            UseTeamColors = false,
                            CurrentSchemeIndex = 1,
                            Version = "v4.2 WindUI Edition",
                            BoxThickness = 1.5,
                            TracerThickness = 1.2,
                            NameOutline = false,
                            Rainbow = false,
                            RainbowSpeed = 1.0,
                            Keybinds = {
                                ToggleESP = Enum.KeyCode.RightAlt,
                                ToggleChams = Enum.KeyCode.RightControl,
                                ToggleMenu = Enum.KeyCode.Delete,
                                ReloadESP = Enum.KeyCode.Home,
                                ToggleJumpEffect = Enum.KeyCode.J
                            },
                            JumpEffect = {
                                Enabled = false,
                                CurrentEffectIndex = 1,
                                ShowOnJump = false,
                                ShowOnLand = false,
                                EffectThickness = 1.2,
                                ParticleCount = 20,
                                CircleRadius = 4.5,
                                MaxExpandRadius = 8,
                                AnimDuration = 0.7,
                                Segments = 72,
                                LayerCount = 4,
                                Rainbow = false,
                                RainbowSpeed = 1.0,
                                EnableParticles = false,
                                EnableWaves = false,
                                EnableGlow = false,
                                EnablePulse = false,
                                EffectSchemes = ESP.JumpEffect.EffectSchemes
                            },
                            CurrentFontIndex = 2,
                            AvailableFonts = ESP.AvailableFonts,
                            ColorSchemes = ESP.ColorSchemes,
                            Presets = ESP.Presets
                        }
                        ApplyChamsToAllPlayers()
                        ShowNotification("Settings reset to defaults")
                    end
                }
            }
        })
    end
})

-- KEYBINDS TAB
-- Keybind settings
Tabs.KeybindsTab:Section({ Title = "Configure Keybinds" })

-- Function to create keybind button
local function CreateKeybindButton(title, keycode, callback)
    Tabs.KeybindsTab:Keybind({
        Title = title,
        Value = keycode.Name,
        Callback = function(keyName)
            local key = Enum.KeyCode[keyName]
            if key then
                callback(key)
                ShowNotification("Key set: " .. keyName)
            end
        end
    })
end

CreateKeybindButton("Toggle ESP On/Off", ESP.Keybinds.ToggleESP, function(key)
    ESP.Keybinds.ToggleESP = key
end)

CreateKeybindButton("Toggle Highlight", ESP.Keybinds.ToggleChams, function(key)
    ESP.Keybinds.ToggleChams = key
end)

CreateKeybindButton("Toggle Menu", ESP.Keybinds.ToggleMenu, function(key)
    ESP.Keybinds.ToggleMenu = key
    Window:SetToggleKey(key)
end)

CreateKeybindButton("Refresh ESP", ESP.Keybinds.ReloadESP, function(key)
    ESP.Keybinds.ReloadESP = key
end)

CreateKeybindButton("Toggle Jump Effects", ESP.Keybinds.ToggleJumpEffect, function(key)
    ESP.Keybinds.ToggleJumpEffect = key
end)

-- Instructions for using keybinds
Tabs.KeybindsTab:Section({ Title = "Instructions" })

Tabs.KeybindsTab:Paragraph({
    Title = "Using Keybinds",
    Desc = "To change a keybind, click on the current key and then press a new key on your keyboard. Keybinds work even when the menu is closed."
})

-- INFORMATION TAB
Tabs.InfoTab:Paragraph({
    Title = "Slavan Hub " .. ESP.Version,
    Desc = "Advanced ESP script with extended functionality, customizable interface and jump effects by NotAka.\n\nFeatures:\n• Customizable keybinds\n• Various fonts\n• Color schemes\n• Jump effects\n• Rainbow effect\n• Settings saving",
    Image = "eye"
})

Tabs.InfoTab:Section({ Title = "Acknowledgements" })

Tabs.InfoTab:Paragraph({
    Title = "Thanks for using",
    Desc = "Thank you for using Slavan Hub!\n\nIf you have suggestions or questions, contact us through Discord.\n\nEnjoy using!"
})

-- Function to check part visibility
local function IsPartVisible(part)
    local camera = workspace.CurrentCamera
    local character = LocalPlayer.Character
    
    if not camera or not character or not part then return false end
    
    local ignoreList = {character}
    local ray = Ray.new(camera.CFrame.Position, part.Position - camera.CFrame.Position)
    local hit, position = workspace:FindPartOnRayWithIgnoreList(ray, ignoreList)
    
    if hit and hit:IsDescendantOf(part.Parent) then
        return true
    end
    
    return false
end

-- Function to check team
local function IsSameTeam(player1, player2)
    if not player1 or not player2 then return false end
    
    -- Check by Team
    if player1.Team and player2.Team then
        return player1.Team == player2.Team
    end
    
    -- Check by TeamColor
    if player1.TeamColor and player2.TeamColor then
        return player1.TeamColor == player2.TeamColor
    end
    
    return false
end

-- Function to get character position
local function GetPosition(character)
    if not character then return end
    
    local root = character:FindFirstChild("HumanoidRootPart")
    if root then return root.Position end
    
    local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
    if torso then return torso.Position end
    
    local head = character:FindFirstChild("Head")
    if head then return head.Position end
    
    -- If nothing found, try any part
    for _, child in pairs(character:GetChildren()) do
        if child:IsA("BasePart") then
            return child.Position
        end
    end
end

-- Function to get health
local function GetHealth(character)
    if not character then return 0, 0 end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return 0, 0 end
    
    return humanoid.Health, humanoid.MaxHealth
end

-- Function to calculate distance
local function GetDistance(position)
    if not LocalPlayer or not LocalPlayer.Character then return 0 end
    
    local myPosition = GetPosition(LocalPlayer.Character)
    if not myPosition then return 0 end
    
    return (position - myPosition).Magnitude
end

-- Function to create circle effect on jump/landing
local function createJumpCircleEffect(position)
    if not ESP.JumpEffect.Enabled then return end
    
    -- Create container for effects
    local effectsFolder = Instance.new("Folder")
    effectsFolder.Name = "JumpEffects"
    effectsFolder.Parent = workspace
    
    -- Get current effect scheme
    local scheme = ESP:GetCurrentJumpEffect()
    local colors = scheme.Colors
    
    -- Effect parameters from settings
    local initialRadius = ESP.JumpEffect.CircleRadius
    local maxRadius = ESP.JumpEffect.MaxExpandRadius
    local duration = ESP.JumpEffect.AnimDuration
    local segments = ESP.JumpEffect.Segments
    local layerCount = ESP.JumpEffect.LayerCount
    
    -- Create folder for current effect
    local effectFolder = Instance.new("Folder")
    effectFolder.Name = "JumpEffect_" .. tostring(math.random(1000, 9999))
    effectFolder.Parent = effectsFolder
    
    -- Function to get rainbow color
    local function getJumpRainbowColor(offset)
        if ESP.JumpEffect.Rainbow then
            local frequency = ESP.JumpEffect.RainbowSpeed
            local timeOffset = tick() * frequency + offset
            return Color3.fromHSV(timeOffset % 1, 1, 1)
        else
            -- If rainbow is off, return color from current scheme
            local colorIndex = (math.floor(offset * 10) % #colors) + 1
            return colors[colorIndex]
        end
    end
    
    -- Create multi-layer rings
    for layer = 1, layerCount do
        local layerRadius = initialRadius * (1 + (layer-1) * 0.15)
        
        -- Create circle or hexagon segments
        local stepSize = scheme.Type == "Hex" and (math.pi / 3) or (math.pi * 2 / segments)
        local numPoints = scheme.Type == "Hex" and 6 or segments
        
        for i = 1, numPoints do
            local angle
            if scheme.Type == "Hex" then
                angle = (i - 1) * math.pi / 3
            else
                angle = (i / segments) * math.pi * 2
            end
            
            local x = math.cos(angle) * layerRadius
            local z = math.sin(angle) * layerRadius
            
            -- Create segment
            local segment = Instance.new("Part")
            segment.Name = "Segment_" .. layer .. "_" .. i
            segment.Anchored = true
            segment.CanCollide = false
            segment.Size = Vector3.new(ESP.JumpEffect.EffectThickness, 0.04, ESP.JumpEffect.EffectThickness)
            segment.Position = position + Vector3.new(x, 0.05 + layer * 0.02, z)
            
            -- Set segment color
            if ESP.JumpEffect.Rainbow then
                segment.Color = getJumpRainbowColor(i / numPoints + layer * 0.2)
            else
                local colorIndex = ((i + layer) % #colors) + 1
                segment.Color = colors[colorIndex]
            end
            
            segment.Material = Enum.Material.Neon
            segment.Transparency = 0 + (layer - 1) * 0.15
            segment.Parent = effectFolder
            
            -- Animate segment
            spawn(function()
                -- Fast expansion with fade out
                TweenService:Create(
                    segment,
                    TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    {
                        Position = position + Vector3.new(x, 0.05 + layer * 0.02, z) * (maxRadius / initialRadius),
                        Transparency = 1,
                        Size = segment.Size * 0.5
                    }
                ):Play()
                
                -- Add pulse effect if enabled
                if ESP.JumpEffect.EnablePulse and layer == 1 then
                    for p = 1, 2 do
                        TweenService:Create(
                            segment, 
                            TweenInfo.new(0.05, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
                            {Size = segment.Size * 1.5}
                        ):Play()
                        wait(0.05)
                        
                        TweenService:Create(
                            segment, 
                            TweenInfo.new(0.05, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
                            {Size = segment.Size}
                        ):Play()
                        wait(0.05)
                    end
                end
            end)
        end
        
        -- If wave effect, create additional lines between points
        if scheme.Type == "Wave" then
            for i = 1, numPoints do
                local angle1 = (i / numPoints) * math.pi * 2
                local angle2 = ((i + 1) % numPoints + 1) / numPoints * math.pi * 2
                
                local x1 = math.cos(angle1) * layerRadius
                local z1 = math.sin(angle1) * layerRadius
                local x2 = math.cos(angle2) * layerRadius
                local z2 = math.sin(angle2) * layerRadius
                
                -- Create connecting line
                local line = Instance.new("Part")
                line.Name = "WaveLine_" .. layer .. "_" .. i
                line.Anchored = true
                line.CanCollide = false
                
                -- Calculate size and position of line
                local center = position + Vector3.new((x1 + x2) / 2, 0.05 + layer * 0.02, (z1 + z2) / 2)
                local direction = Vector3.new(x2 - x1, 0, z2 - z1)
                local distance = direction.Magnitude
                
                line.Size = Vector3.new(distance, 0.02, ESP.JumpEffect.EffectThickness * 0.5)
                line.CFrame = CFrame.new(center, center + Vector3.new(direction.X, 0, direction.Z))
                
                if ESP.JumpEffect.Rainbow then
                    line.Color = getJumpRainbowColor((i + 0.5) / numPoints + layer * 0.2)
                else
                    line.Color = colors[(i % #colors) + 1]
                end
                
                line.Material = Enum.Material.Neon
                line.Transparency = 0.3 + (layer - 1) * 0.15
                line.Parent = effectFolder
                
                -- Animate line
                TweenService:Create(
                    line,
                    TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    {
                        Position = line.Position * (maxRadius / initialRadius),
                        Size = line.Size * (maxRadius / initialRadius),
                        Transparency = 1
                    }
                ):Play()
            end
        end
    end
    
    -- Create inner disc
    local innerDisc = Instance.new("Part")
    innerDisc.Name = "InnerDisc"
    innerDisc.Anchored = true
    innerDisc.CanCollide = false
    innerDisc.Size = Vector3.new(initialRadius * 1.8, 0.01, initialRadius * 1.8)
    innerDisc.CFrame = CFrame.new(position + Vector3.new(0, 0.02, 0))
    innerDisc.Color = ESP.JumpEffect.Rainbow and getJumpRainbowColor(0) or colors[1]
    innerDisc.Material = Enum.Material.Neon
    innerDisc.Transparency = 0.4
    innerDisc.Shape = Enum.PartType.Cylinder
    innerDisc.Orientation = Vector3.new(0, 0, 90)
    innerDisc.Parent = effectFolder
    
    -- Animate inner disc
    TweenService:Create(
        innerDisc,
        TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {
            Size = Vector3.new(maxRadius * 2, 0.01, maxRadius * 2),
            Transparency = 1
        }
    ):Play()
    
    -- Add glow effect if enabled
    if ESP.JumpEffect.EnableGlow then
        local glow = Instance.new("Part")
        glow.Name = "OuterGlow"
        glow.Anchored = true
        glow.CanCollide = false
        glow.Size = Vector3.new(initialRadius * 2.2, 0.01, initialRadius * 2.2)
        glow.CFrame = CFrame.new(position + Vector3.new(0, 0.01, 0))
        glow.Color = ESP.JumpEffect.Rainbow and getJumpRainbowColor(0.5) or colors[1]
        glow.Material = Enum.Material.Neon
        glow.Transparency = 0.5
        glow.Shape = Enum.PartType.Cylinder
        glow.Orientation = Vector3.new(0, 0, 90)
        glow.Parent = effectFolder
        
        -- Animate glow
        TweenService:Create(
            glow,
            TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {
                Size = Vector3.new(maxRadius * 2.5, 0.01, maxRadius * 2.5),
                Transparency = 1
            }
        ):Play()
    end
    
    -- Add wave effect if enabled
    if ESP.JumpEffect.EnableWaves then
        for i = 1, 3 do
            wait(i * 0.05)
            
            local wave = Instance.new("Part")
            wave.Name = "Wave_" .. i
            wave.Anchored = true
            wave.CanCollide = false
            wave.Size = Vector3.new(initialRadius * 1.5, 0.01, initialRadius * 1.5)
            wave.CFrame = CFrame.new(position + Vector3.new(0, 0.01 + i * 0.01, 0))
            wave.Color = ESP.JumpEffect.Rainbow and getJumpRainbowColor(i * 0.3) or colors[i % #colors + 1]
            wave.Material = Enum.Material.Neon
            wave.Transparency = 0.6
            wave.Shape = Enum.PartType.Cylinder
            wave.Orientation = Vector3.new(0, 0, 90)
            wave.Parent = effectFolder
            
            -- Animate wave
            TweenService:Create(
                wave,
                TweenInfo.new(duration * 0.7, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
                {
                    Size = Vector3.new(maxRadius * 3, 0.01, maxRadius * 3),
                    Transparency = 1
                }
            ):Play()
        end
    end
    
    -- Add particles
    if ESP.JumpEffect.EnableParticles then
        for i = 1, ESP.JumpEffect.ParticleCount do
            local angle = (i / ESP.JumpEffect.ParticleCount) * math.pi * 2
            local distance = initialRadius * 0.7
            local x = math.cos(angle) * distance
            local z = math.sin(angle) * distance
            
            local particle = Instance.new("Part")
            particle.Name = "Particle_" .. i
            particle.Anchored = true
            particle.CanCollide = false
            particle.Size = Vector3.new(0.15, 0.15, 0.15)
            particle.Position = position + Vector3.new(x, 0.2, z)
            
            -- Set particle color
            if ESP.JumpEffect.Rainbow then
                particle.Color = getJumpRainbowColor(i / ESP.JumpEffect.ParticleCount)
            else
                particle.Color = colors[i % #colors + 1]
            end
            
            particle.Material = Enum.Material.Neon
            particle.Transparency = 0
            particle.Shape = Enum.PartType.Ball
            particle.Parent = effectFolder
            
            -- Animate particle
            spawn(function()
                local endPos = position + Vector3.new(x, 1.2, z) * 3
                TweenService:Create(
                    particle,
                    TweenInfo.new(duration * 0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
                    {
                        Position = endPos,
                        Transparency = 1,
                        Size = Vector3.new(0.05, 0.05, 0.05)
                    }
                ):Play()
            end)
        end
    end
    
    -- Remove effect after animation completes
    Debris:AddItem(effectFolder, duration + 0.1)
end

-- Function to set up jump and landing detection
local function setupJumpEffectDetection()
    local function onCharacterAdded(character)
        if not character then return end
        
        local humanoid = character:WaitForChild("Humanoid")
        if not humanoid then return end
        
        -- Check if it's an R6 character
        if humanoid.RigType ~= Enum.HumanoidRigType.R6 then
            return -- Only work with R6
        end
        
        local rootPart = character:WaitForChild("HumanoidRootPart")
        if not rootPart then return end
        
        local isJumping = false
        local lastJumpTime = 0
        local lastLandTime = 0
        local jumpCooldown = 0.05
        
        -- Use RunService for fastest reaction
        local connection = RunService.Heartbeat:Connect(function()
            -- Check jump state
            local state = humanoid:GetState()
            
            -- Effect on jump
            if state == Enum.HumanoidStateType.Jumping and not isJumping then
                local currentTime = tick()
                if currentTime - lastJumpTime > jumpCooldown then
                    isJumping = true
                    lastJumpTime = currentTime
                    
                    -- Get jump position
                    local jumpPosition = rootPart.Position - Vector3.new(0, rootPart.Size.Y/2, 0)
                    
                    -- Create jump effect if enabled
                    if ESP.JumpEffect.ShowOnJump then
                        createJumpCircleEffect(jumpPosition)
                    end
                end
            elseif isJumping and (state == Enum.HumanoidStateType.Landed or state == Enum.HumanoidStateType.GettingUp) then
                -- Effect on landing
                isJumping = false
                local currentTime = tick()
                if currentTime - lastLandTime > jumpCooldown then
                    lastLandTime = currentTime
                    
                    -- Get landing position
                    local landPosition = rootPart.Position - Vector3.new(0, rootPart.Size.Y/2, 0)
                    
                    -- Create landing effect if enabled
                    if ESP.JumpEffect.ShowOnLand then
                        createJumpCircleEffect(landPosition)
                    end
                end
            end
        end)
        
        -- Clean up connection when character is removed
        character.AncestryChanged:Connect(function(_, parent)
            if parent == nil and connection then
                connection:Disconnect()
            end
        end)
    end
    
    -- Connect handler to current and future player characters
    LocalPlayer.CharacterAdded:Connect(onCharacterAdded)
    if LocalPlayer.Character then
        onCharacterAdded(LocalPlayer.Character)
    end
end

-- APPLY ESP FUNCTION TO PLAYER
local function ApplyESP(player)
    if not player or player == LocalPlayer or not player.Character then return end
    
    -- Check if ESP is enabled
    if not ESP.Enabled then
        -- Remove all ESP elements
        for _, obj in pairs(player.Character:GetChildren()) do
            if obj.Name:match("ESP_") then
                obj:Destroy()
            end
        end
        return
    end
    
    -- Character position
    local position = GetPosition(player.Character)
    if not position then return end
    
    -- Check distance
    local distance = GetDistance(position)
    if distance > ESP.MaxRenderDistance then
        -- Remove all ESP elements if character is too far
        for _, obj in pairs(player.Character:GetChildren()) do
            if obj.Name:match("ESP_") then
                obj:Destroy()
            end
        end
        return
    end
    
    -- Check team
    local isTeammate = IsSameTeam(player, LocalPlayer)
    
    -- Get color scheme
    local scheme = ESP:GetCurrentScheme()
    
    -- Determine color based on team and settings
    local espColor
    if ESP.Rainbow then
        espColor = rainbowColor
    elseif ESP.UseTeamColors and player.Team and player.TeamColor then
        espColor = player.TeamColor.Color
    else
        espColor = isTeammate and scheme.Team or scheme.Enemy
    end
    
    -- Create/update chams (highlight through walls)
    if ESP.Chams then
        local chamsPart = player.Character:FindFirstChild("ESP_Chams")
        if not chamsPart then
            local highlight = Instance.new("Highlight")
            highlight.Name = "ESP_Chams"
            highlight.FillTransparency = ESP.ChamsTransparency
            highlight.OutlineTransparency = 0.2
            highlight.FillColor = espColor
            highlight.OutlineColor = espColor
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.Parent = player.Character
        else
            chamsPart.FillTransparency = ESP.ChamsTransparency
            chamsPart.FillColor = espColor
            chamsPart.OutlineColor = espColor
        end
    else
        local chamsPart = player.Character:FindFirstChild("ESP_Chams")
        if chamsPart then
            chamsPart:Destroy()
        end
    end
    
    -- Create/update names
    if ESP.ShowNames then
        local nameESP = player.Character:FindFirstChild("ESP_Name")
        if not nameESP then
            local billboardGui = Instance.new("BillboardGui")
            billboardGui.Name = "ESP_Name"
            billboardGui.AlwaysOnTop = true
            billboardGui.Size = UDim2.new(0, 200, 0, 50)
            billboardGui.StudsOffset = Vector3.new(0, 2.5, 0)
            billboardGui.Adornee = player.Character:FindFirstChild("Head") or player.Character:FindFirstChild("HumanoidRootPart")
            
            local nameLabel = Instance.new("TextLabel")
            nameLabel.Size = UDim2.new(1, 0, 1, 0)
            nameLabel.BackgroundTransparency = 1
            nameLabel.Font = ESP:GetCurrentFont()
            nameLabel.TextSize = ESP.NameSize
            nameLabel.TextColor3 = ESP.Rainbow and rainbowColor or scheme.NameColor
            nameLabel.Text = player.Name
            nameLabel.TextStrokeTransparency = ESP.NameOutline and 0 or 1
            nameLabel.Parent = billboardGui
            
            billboardGui.Parent = player.Character
        else
            local nameLabel = nameESP:FindFirstChildOfClass("TextLabel")
            if nameLabel then
                nameLabel.Font = ESP:GetCurrentFont()
                nameLabel.TextSize = ESP.NameSize
                nameLabel.TextColor3 = ESP.Rainbow and rainbowColor or scheme.NameColor
                nameLabel.TextStrokeTransparency = ESP.NameOutline and 0 or 1
            end
        end
    else
        local nameESP = player.Character:FindFirstChild("ESP_Name")
        if nameESP then
            nameESP:Destroy()
        end
    end
    
    -- Create/update distance
    if ESP.ShowDistance then
        local distanceESP = player.Character:FindFirstChild("ESP_Distance")
        if not distanceESP then
            local billboardGui = Instance.new("BillboardGui")
            billboardGui.Name = "ESP_Distance"
            billboardGui.AlwaysOnTop = true
            billboardGui.Size = UDim2.new(0, 200, 0, 50)
            billboardGui.StudsOffset = Vector3.new(0, -2, 0)
            billboardGui.Adornee = player.Character:FindFirstChild("HumanoidRootPart") or player.Character:FindFirstChild("Head")
            
            local distanceLabel = Instance.new("TextLabel")
            distanceLabel.Size = UDim2.new(1, 0, 1, 0)
            distanceLabel.BackgroundTransparency = 1
            distanceLabel.Font = ESP:GetCurrentFont()
            distanceLabel.TextSize = ESP.NameSize - 2
            distanceLabel.TextColor3 = ESP.Rainbow and rainbowColor or scheme.NameColor
            distanceLabel.Text = math.floor(distance) .. "m"
            distanceLabel.TextStrokeTransparency = ESP.NameOutline and 0 or 1
            distanceLabel.Parent = billboardGui
            
            billboardGui.Parent = player.Character
        else
            local distanceLabel = distanceESP:FindFirstChildOfClass("TextLabel")
            if distanceLabel then
                distanceLabel.Text = math.floor(distance) .. "m"
                distanceLabel.Font = ESP:GetCurrentFont()
                distanceLabel.TextColor3 = ESP.Rainbow and rainbowColor or scheme.NameColor
                distanceLabel.TextStrokeTransparency = ESP.NameOutline and 0 or 1
            end
        end
    else
        local distanceESP = player.Character:FindFirstChild("ESP_Distance")
        if distanceESP then
            distanceESP:Destroy()
        end
    end
    
    -- Create/update boxes
    if ESP.ShowBoxes then
        local boxESP = player.Character:FindFirstChild("ESP_Box")
        if not boxESP then
            -- Determine character size
            local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                local boxGui = Instance.new("BillboardGui")
                boxGui.Name = "ESP_Box"
                boxGui.AlwaysOnTop = true
                boxGui.Size = UDim2.new(4, 0, 5, 0)
                boxGui.StudsOffset = Vector3.new(0, 0, 0)
                boxGui.Adornee = rootPart
                
                -- Frame
                local boxFrame = Instance.new("Frame")
                boxFrame.Size = UDim2.new(1, 0, 1, 0)
                boxFrame.BackgroundTransparency = 1
                boxFrame.BorderSizePixel = 0
                boxFrame.Parent = boxGui
                
                -- Create box lines with fixed thickness
                local boxThickness = math.clamp(ESP.BoxThickness, 1, 5)
                
                -- Create 4 lines for box with explicit size
                local top = Instance.new("Frame")
                top.Name = "TopLine"
                top.BackgroundColor3 = ESP.Rainbow and rainbowColor or (isTeammate and scheme.Team or scheme.BoxColor)
                top.BorderSizePixel = 0
                top.BackgroundTransparency = 0.3
                top.Position = UDim2.new(0, 0, 0, 0)
                top.Size = UDim2.new(1, 0, 0, boxThickness)
                top.Parent = boxFrame
                
                local bottom = Instance.new("Frame")
                bottom.Name = "BottomLine"
                bottom.BackgroundColor3 = ESP.Rainbow and rainbowColor or (isTeammate and scheme.Team or scheme.BoxColor)
                bottom.BorderSizePixel = 0
                bottom.BackgroundTransparency = 0.3
                bottom.Position = UDim2.new(0, 0, 1, -boxThickness)
                bottom.Size = UDim2.new(1, 0, 0, boxThickness)
                bottom.Parent = boxFrame
                
                local left = Instance.new("Frame")
                left.Name = "LeftLine"
                left.BackgroundColor3 = ESP.Rainbow and rainbowColor or (isTeammate and scheme.Team or scheme.BoxColor)
                left.BorderSizePixel = 0
                left.BackgroundTransparency = 0.3
                left.Position = UDim2.new(0, 0, 0, 0)
                left.Size = UDim2.new(0, boxThickness, 1, 0)
                left.Parent = boxFrame
                
                local right = Instance.new("Frame")
                right.Name = "RightLine"
                right.BackgroundColor3 = ESP.Rainbow and rainbowColor or (isTeammate and scheme.Team or scheme.BoxColor)
                right.BorderSizePixel = 0
                right.BackgroundTransparency = 0.3
                right.Position = UDim2.new(1, -boxThickness, 0, 0)
                right.Size = UDim2.new(0, boxThickness, 1, 0)
                right.Parent = boxFrame
                
                boxGui.Parent = player.Character
            end
        else
            -- Update box color and thickness
            local boxFrame = boxESP:FindFirstChildOfClass("Frame")
            if boxFrame then
                local boxThickness = math.clamp(ESP.BoxThickness, 1, 5)
                
                -- Update line thickness and color
                for _, line in pairs(boxFrame:GetChildren()) do
                    if line:IsA("Frame") then
                        line.BackgroundColor3 = ESP.Rainbow and rainbowColor or (isTeammate and scheme.Team or scheme.BoxColor)
                        
                        -- Update line sizes based on position
                        if line.Name == "TopLine" or line.Name == "BottomLine" then
                            line.Size = UDim2.new(1, 0, 0, boxThickness)
                        elseif line.Name == "LeftLine" or line.Name == "RightLine" then
                            line.Size = UDim2.new(0, boxThickness, 1, 0)
                        end
                        
                        -- Update bottom and right line positions
                        if line.Name == "BottomLine" then
                            line.Position = UDim2.new(0, 0, 1, -boxThickness)
                        elseif line.Name == "RightLine" then
                            line.Position = UDim2.new(1, -boxThickness, 0, 0)
                        end
                    end
                end
            end
        end
    else
        local boxESP = player.Character:FindFirstChild("ESP_Box")
        if boxESP then
            boxESP:Destroy()
        end
    end
    
    -- Create/update health indicator (side of player)
    if ESP.ShowHealth then
        local healthESP = player.Character:FindFirstChild("ESP_Health")
        if not healthESP then
            local billboardGui = Instance.new("BillboardGui")
            billboardGui.Name = "ESP_Health"
            billboardGui.AlwaysOnTop = true
            billboardGui.Size = UDim2.new(0, 5, 0, 50) -- Narrow vertical bar
            billboardGui.StudsOffset = Vector3.new(3, 0, 0) -- Offset to right of player
            billboardGui.Adornee = player.Character:FindFirstChild("HumanoidRootPart") or player.Character:FindFirstChild("Head")
            
            -- Health bar background
            local healthBackground = Instance.new("Frame")
            healthBackground.Size = UDim2.new(1, 0, 1, 0)
            healthBackground.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            healthBackground.BorderSizePixel = 0
            healthBackground.Parent = billboardGui
            
            -- Rounded corners
            local healthCorner = Instance.new("UICorner")
            healthCorner.CornerRadius = UDim.new(0, 2)
            healthCorner.Parent = healthBackground
            
            -- Health bar (vertical)
            local health, maxHealth = GetHealth(player.Character)
            local healthBar = Instance.new("Frame")
            healthBar.Size = UDim2.new(1, 0, health / maxHealth, 0)
            healthBar.Position = UDim2.new(0, 0, 1 - health / maxHealth, 0) -- Bottom to top
            healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            healthBar.BorderSizePixel = 0
            healthBar.Name = "HealthBar"
            healthBar.Parent = healthBackground
            
            -- Rounded corners for bar
            local barCorner = Instance.new("UICorner")
            barCorner.CornerRadius = UDim.new(0, 2)
            barCorner.Parent = healthBar
            
            billboardGui.Parent = player.Character
        else
            -- Update health bar
            local healthBackground = healthESP:FindFirstChildOfClass("Frame")
            if healthBackground then
                local healthBar = healthBackground:FindFirstChild("HealthBar")
                if healthBar then
                    local health, maxHealth = GetHealth(player.Character)
                    healthBar.Size = UDim2.new(1, 0, health / maxHealth, 0)
                    healthBar.Position = UDim2.new(0, 0, 1 - health / maxHealth, 0) -- Bottom to top
                    
                    -- Change color based on health
                    if health / maxHealth > 0.7 then
                        healthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                    elseif health / maxHealth > 0.3 then
                        healthBar.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
                    else
                        healthBar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                    end
                end
            end
        end
    else
        local healthESP = player.Character:FindFirstChild("ESP_Health")
        if healthESP then
            healthESP:Destroy()
        end
    end
end

-- Function to apply ESP to all players
function ApplyChamsToAllPlayers()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            ApplyESP(player)
        end
    end
end

-- Handle player added and removed
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        task.wait(0.5) -- Wait for character to load
        ApplyESP(player)
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    -- Nothing to do, ESP elements will be removed with character
end)

-- Handle character changes for current players
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        player.CharacterAdded:Connect(function(character)
            task.wait(0.5)
            ApplyESP(player)
        end)
        
        if player.Character then
            ApplyESP(player)
        end
    end
end

-- IMPORTANT: Save connection to prevent garbage collection
local tracerUpdateConnection = nil

-- Function to update tracers
local function UpdateTracers()
    -- Check if tracers are enabled
    if not ESP or not ESP.Enabled or not ESP.ShowTracers then
        -- Remove all tracers if disabled
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local tracerLine = player.Character:FindFirstChild("ESP_Tracer")
                if tracerLine then
                    tracerLine:Destroy()
                end
            end
        end
        return
    end
    
    -- Update tracers for all players
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local rootPart = player.Character:FindFirstChild("HumanoidRootPart") or 
                           player.Character:FindFirstChild("Head")
            
            if rootPart then
                local isTeammate = IsSameTeam(player, LocalPlayer)
                local scheme = ESP:GetCurrentScheme()
                
                -- Determine tracer color
                local tracerColor
                if ESP.Rainbow then
                    tracerColor = rainbowColor
                elseif ESP.UseTeamColors and player.Team and player.TeamColor then
                    tracerColor = player.TeamColor.Color
                else
                    tracerColor = isTeammate and scheme.Team or scheme.TracerColor
                end
                
                -- Get character position on screen
                local rootPos = rootPart.Position
                local screenPos, onScreen = Camera:WorldToViewportPoint(rootPos)
                
                -- Check if character is in field of view and within distance
                local distance = GetDistance(rootPos)
                if onScreen and distance <= ESP.MaxRenderDistance then
                    -- Check for tracer
                    local tracerLine = player.Character:FindFirstChild("ESP_Tracer")
                    if not tracerLine then
                        -- Create tracer as line connecting screen center and character
                        local tracerPart = Instance.new("Part")
                        tracerPart.Name = "ESP_Tracer"
                        tracerPart.Anchored = true
                        tracerPart.CanCollide = false
                        tracerPart.Material = Enum.Material.Neon
                        tracerPart.Transparency = 0.5
                        tracerPart.Color = tracerColor
                        tracerPart.Size = Vector3.new(ESP.TracerThickness, ESP.TracerThickness, (Camera.CFrame.Position - rootPos).Magnitude)
                        
                        -- Position tracer
                        local midpoint = (Camera.CFrame.Position + rootPos) / 2
                        tracerPart.CFrame = CFrame.new(midpoint, rootPos)
                        
                        tracerPart.Parent = player.Character
                    else
                        -- Update tracer
                        tracerLine.Color = tracerColor
                        tracerLine.Size = Vector3.new(ESP.TracerThickness, ESP.TracerThickness, (Camera.CFrame.Position - rootPos).Magnitude)
                        
                        -- Position tracer
                        local midpoint = (Camera.CFrame.Position + rootPos) / 2
                        tracerLine.CFrame = CFrame.new(midpoint, rootPos)
                    end
                else
                    -- Remove tracer if player is not visible or too far
                    local tracerLine = player.Character:FindFirstChild("ESP_Tracer")
                    if tracerLine then
                        tracerLine:Destroy()
                    end
                end
            end
        end
    end
end

-- Initialize tracers and subscribe to RenderStepped
local function InitializeTracers()
    -- Disconnect previous connection if it exists
    if tracerUpdateConnection then
        tracerUpdateConnection:Disconnect()
        tracerUpdateConnection = nil
    end
    
    -- Create new connection only if tracers are enabled
    if ESP.Enabled and ESP.ShowTracers then
        tracerUpdateConnection = RunService.RenderStepped:Connect(function()
            pcall(UpdateTracers)  -- Use pcall to protect from errors
        end)
    end
end

-- Function to update tracer settings
function UpdateTracerSettings()
    InitializeTracers()
end

-- Key handlers
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == ESP.Keybinds.ToggleESP then
        ESP.Enabled = not ESP.Enabled
        ApplyChamsToAllPlayers()
        ShowNotification(ESP.Enabled and "ESP enabled" or "ESP disabled")
    elseif input.KeyCode == ESP.Keybinds.ToggleChams then
        ESP.Chams = not ESP.Chams
        ApplyChamsToAllPlayers()
        ShowNotification(ESP.Chams and "Highlight enabled" or "Highlight disabled")
    elseif input.KeyCode == ESP.Keybinds.ToggleMenu then
        Window:Toggle()
        PlaySound("Click")
    elseif input.KeyCode == ESP.Keybinds.ReloadESP then
        ApplyChamsToAllPlayers()
        ShowNotification("ESP refreshed")
    elseif input.KeyCode == ESP.Keybinds.ToggleJumpEffect then
        ESP.JumpEffect.Enabled = not ESP.JumpEffect.Enabled
        ShowNotification(ESP.JumpEffect.Enabled and "Jump effect enabled" or "Jump effect disabled")
    end
end)

-- Update rainbow color and ESP each frame
local renderSteppedConnection = RunService.RenderStepped:Connect(function(deltaTime)
    -- Update rainbow color
    if ESP.Rainbow or ESP.JumpEffect.Rainbow then
        rainbowHue = (rainbowHue + deltaTime * ESP.RainbowSpeed) % 1
        rainbowColor = Color3.fromHSV(rainbowHue, 1, 1)
    end
    
    -- Update ESP for all players
    if ESP.Enabled then
        -- Update other ESP elements for all players
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                pcall(function() ApplyESP(player) end)
            end
        end
    end
end)

-- Function called at first script run and when tracer settings change
InitializeTracers()

-- Start jump effect system
setupJumpEffectDetection()

-- Show welcome notification
ShowNotification("Slavan Hub " .. ESP.Version .. " loaded!")
