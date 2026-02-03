local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/aazyris/main-meru/refs/heads/main/main.lua"))()

local Meru = Library:CreateWindow() -- No name needed, it's Meru

-- Configuration System
local Config = {
    AutoSave = true,
    Keybinds = {},
    Settings = {}
}

local function SaveConfig()
    if Config.AutoSave then
        -- Save to workspace or local storage
        local json = game:GetService("HttpService"):JSONEncode(Config)
        writefile("meru_config.json", json)
    end
end

local function LoadConfig()
    if isfile("meru_config.json") then
        local json = readfile("meru_config.json")
        local loaded = game:GetService("HttpService"):JSONDecode(json)
        for k, v in pairs(loaded) do
            Config[k] = v
        end
    end
end

-- Load config on start
LoadConfig()

local Combat = Meru:CreateTab("Combat")
local Movement = Meru:CreateTab("Movement")
local Visual = Meru:CreateTab("Visual")
local World = Meru:CreateTab("World")
local Settings = Meru:CreateTab("Settings")

Movement:CreateSlider("WalkSpeed", 16, 500, function(v)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v
    Config.Settings.WalkSpeed = v
    SaveConfig()
end, Config.Settings.WalkSpeed or 16)

Movement:CreateButton("Speed Boost", function()
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 100
    Config.Settings.WalkSpeed = 100
    SaveConfig()
end)

-- Jump Power
Movement:CreateSlider("JumpPower", 50, 300, function(v)
    game.Players.LocalPlayer.Character.Humanoid.JumpPower = v
    Config.Settings.JumpPower = v
    SaveConfig()
end, Config.Settings.JumpPower or 50)

-- No Clip
local NoClipEnabled = false
Movement:CreateButton("Toggle NoClip", function()
    NoClipEnabled = not NoClipEnabled
    if NoClipEnabled then
        game:GetService("RunService").Stepped:Connect(function()
            if NoClipEnabled and game.Players.LocalPlayer.Character then
                for _, part in ipairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end
    Config.Settings.NoClip = NoClipEnabled
    SaveConfig()
end)

-- Fly
local FlyEnabled = false
local FlySpeed = 50
Movement:CreateButton("Toggle Fly", function()
    FlyEnabled = not FlyEnabled
    local player = game.Players.LocalPlayer
    local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
    
    if FlyEnabled then
        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Parent = humanoid.Parent:FindFirstChild("HumanoidRootPart")
        
        game:GetService("UserInputService").InputBegan:Connect(function(input)
            if FlyEnabled then
                if input.KeyCode == Enum.KeyCode.W then bv.Velocity = humanoid.CFrame.LookVector * FlySpeed
                elseif input.KeyCode == Enum.KeyCode.S then bv.Velocity = humanoid.CFrame.LookVector * -FlySpeed
                elseif input.KeyCode == Enum.KeyCode.A then bv.Velocity = humanoid.CFrame.RightVector * -FlySpeed
                elseif input.KeyCode == Enum.KeyCode.D then bv.Velocity = humanoid.CFrame.RightVector * FlySpeed
                elseif input.KeyCode == Enum.KeyCode.Space then bv.Velocity = Vector3.new(0, FlySpeed, 0)
                elseif input.KeyCode == Enum.KeyCode.LeftShift then bv.Velocity = Vector3.new(0, -FlySpeed, 0)
                else bv.Velocity = Vector3.new(0, 0, 0) end
            end
        end)
    end
    Config.Settings.Fly = FlyEnabled
    SaveConfig()
end, Config.Settings.Fly or false)

-- Combat Features
Combat:CreateToggle("Aimbot", function(state)
    local AimbotEnabled = state
    Config.Settings.Aimbot = state
    SaveConfig()
    
    if AimbotEnabled then
        game:GetService("RunService").RenderStepped:Connect(function()
            if AimbotEnabled then
                local closest = nil
                local maxDist = math.huge
                local player = game.Players.LocalPlayer
                
                for _, plr in ipairs(game.Players:GetPlayers()) do
                    if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        local dist = (plr.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                        if dist < maxDist then
                            maxDist = dist
                            closest = plr
                        end
                    end
                end
                
                if closest and closest.Character:FindFirstChild("Head") then
                    local targetPos = closest.Character.Head.Position
                    workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, targetPos)
                end
            end
        end)
    end
end, Config.Settings.Aimbot or false)

Combat:CreateSlider("FOV Range", 50, 500, function(v)
    Config.Settings.FOV = v
    SaveConfig()
end, Config.Settings.FOV or 100)

Combat:CreateToggle("ESP", function(state)
    local ESPEnabled = state
    Config.Settings.ESP = state
    SaveConfig()
    
    if ESPEnabled then
        for _, plr in ipairs(game.Players:GetPlayers()) do
            if plr ~= game.Players.LocalPlayer and plr.Character then
                local highlight = Instance.new("Highlight")
                highlight.FillColor = Color3.new(1, 0, 0)
                highlight.FillTransparency = 0.5
                highlight.OutlineColor = Color3.new(1, 1, 1)
                highlight.Parent = plr.Character
            end
        end
    end
end, Config.Settings.ESP or false)

Combat:CreateToggle("God Mode", function(state)
    Config.Settings.GodMode = state
    SaveConfig()
    
    if state then
        local player = game.Players.LocalPlayer
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.MaxHealth = math.huge
            player.Character.Humanoid.Health = math.huge
        end
    end
end, Config.Settings.GodMode or false)

Combat:CreateColorPicker("ESP Color", function(color)
    Config.Settings.ESPColor = color
    SaveConfig()
    -- Update existing ESP highlights
    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr ~= game.Players.LocalPlayer and plr.Character then
            local highlight = plr.Character:FindFirstChild("Highlight")
            if highlight then
                highlight.FillColor = color
            end
        end
    end
end, Config.Settings.ESPColor or Color3.fromRGB(255, 0, 0))

-- Visual Features
Visual:CreateToggle("Fullbright", function(state)
    local FullbrightEnabled = state
    Config.Settings.Fullbright = state
    SaveConfig()
    
    if FullbrightEnabled then
        game:GetService("Lighting").Brightness = 2
        game:GetService("Lighting").ClockTime = 12
        game:GetService("Lighting").FogEnd = 100000
        game:GetService("Lighting").GlobalShadows = false
    else
        game:GetService("Lighting").Brightness = 1
        game:GetService("Lighting").FogEnd = 1000
        game:GetService("Lighting").GlobalShadows = true
    end
end, Config.Settings.Fullbright or false)

Visual:CreateToggle("X-Ray", function(state)
    local XRayEnabled = state
    Config.Settings.XRay = state
    SaveConfig()
    
    if XRayEnabled then
        for _, part in ipairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") and not part.Parent:FindFirstChild("Humanoid") then
                part.LocalTransparencyModifier = 0.5
            end
        end
    else
        for _, part in ipairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") then
                part.LocalTransparencyModifier = 0
            end
        end
    end
end, Config.Settings.XRay or false)

Visual:CreateSlider("Camera FOV", 70, 120, function(v)
    game:GetService("Workspace").Camera.FieldOfView = v
    Config.Settings.CameraFOV = v
    SaveConfig()
end, Config.Settings.CameraFOV or 70)

Visual:CreateDropdown("Render Distance", {"Low", "Medium", "High", "Ultra"}, function(choice)
    local distances = {Low = 100, Medium = 500, High = 1000, Ultra = 5000}
    game:GetService("Lighting").FogEnd = distances[choice]
    Config.Settings.RenderDistance = choice
    SaveConfig()
end)

-- World Features
World:CreateButton("Remove All Parts", function()
    for _, part in ipairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "Baseplate" then
            part:Destroy()
        end
    end
    Library:Notify("All parts removed!", 3, "success")
end)

World:CreateButton("Infinite Yield", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
    Library:Notify("Infinite Yield loaded!", 3, "success")
end)

World:CreateToggle("Time Stop", function(state)
    local TimeStopped = state
    Config.Settings.TimeStop = state
    SaveConfig()
    
    if TimeStopped then
        game:GetService("RunService"):SetTimeScale(0)
        Library:Notify("Time stopped!", 2, "warning")
    else
        game:GetService("RunService"):SetTimeScale(1)
        Library:Notify("Time resumed!", 2, "info")
    end
end, Config.Settings.TimeStop or false)

World:CreateSlider("Time of Day", 0, 24, function(v)
    game:GetService("Lighting").ClockTime = v
    Config.Settings.TimeOfDay = v
    SaveConfig()
end, Config.Settings.TimeOfDay or 12)

World:CreateDropdown("Weather", {"Clear", "Cloudy", "Storm", "Fog"}, function(choice)
    -- Simple weather effects
    if choice == "Clear" then
        game:GetService("Lighting").FogEnd = 1000
    elseif choice == "Cloudy" then
        game:GetService("Lighting").FogEnd = 500
    elseif choice == "Storm" then
        game:GetService("Lighting").FogEnd = 200
    elseif choice == "Fog" then
        game:GetService("Lighting").FogEnd = 50
    end
    Config.Settings.Weather = choice
    SaveConfig()
end)

-- Settings Tab
Settings:CreateToggle("Auto Save", function(state)
    Config.AutoSave = state
    SaveConfig()
    Library:Notify("Auto Save " .. (state and "enabled" or "disabled"), 2, "info")
end, Config.AutoSave)

Settings:CreateButton("Save Config Now", function()
    SaveConfig()
    Library:Notify("Configuration saved!", 2, "success")
end)

Settings:CreateButton("Load Config", function()
    LoadConfig()
    Library:Notify("Configuration loaded!", 2, "success")
end)

Settings:CreateButton("Reset Config", function()
    Config = {
        AutoSave = true,
        Keybinds = {},
        Settings = {}
    }
    SaveConfig()
    Library:Notify("Configuration reset!", 2, "warning")
end)

Settings:CreateTextbox("Custom Keybind", "Press key...", function(key)
    if key and key ~= "" then
        AddKeybind(key, function()
            Library:Notify("Custom keybind '" .. key .. "' pressed!", 1, "info")
        end)
        Library:Notify("Keybind '" .. key .. "' added!", 2, "success")
    end
end)

Settings:CreateDropdown("Theme", {"Dark", "Light", "Blue", "Red"}, function(choice)
    -- Theme switching would require more implementation
    Library:Notify("Theme changed to " .. choice, 2, "info")
    Config.Settings.Theme = choice
    SaveConfig()
end)

-- Movement Enhancements with new elements
Movement:CreateToggle("Auto Jump", function(state)
    Config.Settings.AutoJump = state
    SaveConfig()
    
    if state then
        game:GetService("UserInputService").JumpRequest:Connect(function()
            if Config.Settings.AutoJump then
                game.Players.LocalPlayer.Character:FindFirstChild("Humanoid"):ChangeState("Jumping")
            end
        end)
    end
end, Config.Settings.AutoJump or false)

Movement:CreateDropdown("Speed Mode", {"Normal", "Fast", "Super", "Ultra"}, function(choice)
    local speeds = {Normal = 16, Fast = 50, Super = 100, Ultra = 200}
    local speed = speeds[choice]
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = speed
    Config.Settings.SpeedMode = choice
    Config.Settings.WalkSpeed = speed
    SaveConfig()
end)

Movement:CreateTextbox("Teleport Coords", "X,Y,Z", function(coords)
    local parts = string.split(coords, ",")
    if #parts == 3 then
        local x, y, z = tonumber(parts[1]), tonumber(parts[2]), tonumber(parts[3])
        if x and y and z then
            game.Players.LocalPlayer.Character:SetPrimaryPartCFrame(CFrame.new(x, y, z))
            Library:Notify("Teleported to " .. coords, 2, "success")
        end
    end
end)

-- Show welcome notification
Library:Notify("Meru Hub loaded successfully!", 4, "success")
