--// Written by depso
--// MIT License
--// Copyright (c) 2024 Depso
--// Fixed & Self-Contained (No External Assets)

local ImGui = {
    Windows = {},
    Animation = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    ToggleKey = Enum.KeyCode.RightShift
}

--// Services 
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local PlayerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")

--// Strict Black Theme
local THEME = {
    Background = Color3.fromRGB(10, 10, 10),
    Section = Color3.fromRGB(15, 15, 15),
    Border = Color3.fromRGB(30, 30, 30),
    Accent = Color3.fromRGB(200, 200, 200)
}

local IsStudio = RunService:IsStudio()
local GuiParent = IsStudio and PlayerGui or CoreGui

--// Create Window
function ImGui:CreateWindow(Config)
    local Screen = Instance.new("ScreenGui", GuiParent)
    Screen.Name = "Hub_" .. (Config.Title or "Main")
    Screen.ResetOnSpawn = false
    
    local Window = Instance.new("Frame")
    Window.Parent = Screen
    Window.Name = "Window"
    Window.BackgroundColor3 = THEME.Background
    Window.BorderColor3 = THEME.Border
    Window.BorderMode = Enum.BorderMode.Outline
    Window.BorderSizePixel = 2
    Window.Size = Config.Size or UDim2.fromOffset(450, 350)
    Window.Position = UDim2.fromOffset(100, 100)
    Window.ClipsDescendants = true
    
    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Parent = Window
    TitleBar.Name = "TitleBar"
    TitleBar.BackgroundColor3 = THEME.Section
    TitleBar.BorderSizePixel = 0
    TitleBar.Size = UDim2.new(1, 0, 0, 32)
    TitleBar.Active = true
    TitleBar.Selectable = true
    
    local TitleText = Instance.new("TextLabel")
    TitleText.Parent = TitleBar
    TitleText.Name = "Title"
    TitleText.Text = Config.Title or "Hub Menu"
    TitleText.BackgroundTransparency = 1
    TitleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleText.TextSize = 14
    TitleText.Font = Enum.Font.GothamBold
    TitleText.Size = UDim2.new(1, -40, 1, 0)
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.Padding = UDim.new(0, 8)
    
    -- Minimize Button
    local MinBtn = Instance.new("TextButton")
    MinBtn.Parent = TitleBar
    MinBtn.Name = "MinimizeBtn"
    MinBtn.Text = "-"
    MinBtn.BackgroundColor3 = THEME.Accent
    MinBtn.BorderColor3 = THEME.Border
    MinBtn.BorderSizePixel = 1
    MinBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    MinBtn.TextSize = 16
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.Size = UDim2.new(0, 32, 1, 0)
    MinBtn.Position = UDim2.new(1, -32, 0, 0)
    
    -- Content
    local Content = Instance.new("Frame")
    Content.Parent = Window
    Content.Name = "Content"
    Content.BackgroundColor3 = THEME.Background
    Content.BorderSizePixel = 0
    Content.Size = UDim2.new(1, 0, 1, -32)
    Content.Position = UDim2.new(0, 0, 0, 32)
    
    -- Tab Bar
    local TabBar = Instance.new("Frame")
    TabBar.Parent = Content
    TabBar.Name = "TabBar"
    TabBar.BackgroundColor3 = THEME.Background
    TabBar.BorderSizePixel = 0
    TabBar.Size = UDim2.new(1, 0, 0, 28)
    
    local TabLayout = Instance.new("UIListLayout")
    TabLayout.Parent = TabBar
    TabLayout.FillDirection = Enum.FillDirection.Horizontal
    TabLayout.Padding = UDim.new(0, 4)
    
    local TabPadding = Instance.new("UIPadding")
    TabPadding.Parent = TabBar
    TabPadding.PaddingLeft = UDim.new(0, 4)
    
    -- Body (Pages)
    local Body = Instance.new("Frame")
    Body.Parent = Content
    Body.Name = "Body"
    Body.BackgroundColor3 = THEME.Background
    Body.BorderSizePixel = 0
    Body.Size = UDim2.new(1, 0, 1, -28)
    Body.Position = UDim2.new(0, 0, 0, 28)
    Body.ClipsDescendants = true
    
    -- Drag
    local Dragging, DragStart, StartPos
    
    TitleBar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
            DragStart = i.Position
            StartPos = Window.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement and Dragging then
            local Delta = i.Position - DragStart
            Window.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = false
        end
    end)
    
    -- Minimize
    local IsMinimized = false
    local StoredHeight = (Config.Size and Config.Size.Y.Offset) or 350
    
    MinBtn.Activated:Connect(function()
        IsMinimized = not IsMinimized
        if IsMinimized then
            TweenService:Create(Window, self.Animation, {Size = UDim2.new(0, Window.Size.X.Offset, 0, 32)}):Play()
            Content.Visible = false
        else
            Content.Visible = true
            TweenService:Create(Window, self.Animation, {Size = UDim2.new(0, Window.Size.X.Offset, 0, StoredHeight)}):Play()
        end
    end)
    
    -- Toggle Keybind
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == self.ToggleKey then
            Screen.Enabled = not Screen.Enabled
        end
    end)
    
    local Lib = { CurrentPage = nil, CurrentTab = nil }
    
    function Lib:CreateTab(Name)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Parent = TabBar
        TabBtn.Name = Name
        TabBtn.Text = Name
        TabBtn.BackgroundColor3 = THEME.Background
        TabBtn.BorderColor3 = THEME.Border
        TabBtn.BorderSizePixel = 1
        TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        TabBtn.TextSize = 12
        TabBtn.Font = Enum.Font.GothamBold
        TabBtn.Size = UDim2.new(0, 80, 1, -4)
        
        local Page = Instance.new("ScrollingFrame")
        Page.Parent = Body
        Page.Name = Name .. "_Page"
        Page.BackgroundColor3 = THEME.Background
        Page.BorderSizePixel = 0
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.Position = UDim2.new(0, 0, 0, 0)
        Page.Visible = false
        Page.ScrollBarThickness = 6
        Page.ScrollBarImageColor3 = THEME.Accent
        
        local PageLayout = Instance.new("UIListLayout")
        PageLayout.Parent = Page
        PageLayout.Padding = UDim.new(0, 4)
        PageLayout.FillDirection = Enum.FillDirection.Vertical
        
        local PagePadding = Instance.new("UIPadding")
        PagePadding.Parent = Page
        PagePadding.PaddingLeft = UDim.new(0, 6)
        PagePadding.PaddingRight = UDim.new(0, 6)
        PagePadding.PaddingTop = UDim.new(0, 6)
        
        TabBtn.Activated:Connect(function()
            if self.CurrentPage then self.CurrentPage.Visible = false end
            if self.CurrentTab then self.CurrentTab.BackgroundColor3 = THEME.Background end
            Page.Visible = true
            TabBtn.BackgroundColor3 = THEME.Section
            self.CurrentPage = Page
            self.CurrentTab = TabBtn
        end)
        
        if not self.CurrentPage then
            Page.Visible = true
            TabBtn.BackgroundColor3 = THEME.Section
            self.CurrentPage = Page
            self.CurrentTab = TabBtn
        end
        
        local Elements = {}
        
        function Elements:Button(Text, Callback)
            local Btn = Instance.new("TextButton")
            Btn.Parent = Page
            Btn.Name = "Button"
            Btn.Text = Text
            Btn.BackgroundColor3 = THEME.Section
            Btn.BorderColor3 = THEME.Border
            Btn.BorderSizePixel = 1
            Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            Btn.TextSize = 13
            Btn.Font = Enum.Font.GothamBold
            Btn.Size = UDim2.new(1, 0, 0, 30)
            Btn.Activated:Connect(Callback)
            return Btn
        end
        
        function Elements:Toggle(Text, Default, Callback)
            local Enabled = Default or false
            local Tog = Instance.new("TextButton")
            Tog.Parent = Page
            Tog.Name = "Toggle"
            Tog.BackgroundColor3 = THEME.Section
            Tog.BorderColor3 = THEME.Border
            Tog.BorderSizePixel = 1
            Tog.TextSize = 13
            Tog.Font = Enum.Font.GothamBold
            Tog.Size = UDim2.new(1, 0, 0, 30)
            
            local function Update()
                Tog.Text = Text .. ": " .. (Enabled and "[ ON ]" or "[ OFF ]")
                Tog.TextColor3 = Enabled and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
            end
            
            Tog.Activated:Connect(function()
                Enabled = not Enabled
                Update()
                Callback(Enabled)
            end)
            Update()
            return Tog
        end
        
        function Elements:Slider(Text, Min, Max, Default, Callback)
            local Container = Instance.new("Frame")
            Container.Parent = Page
            Container.Name = "SliderContainer"
            Container.BackgroundTransparency = 1
            Container.BorderSizePixel = 0
            Container.Size = UDim2.new(1, 0, 0, 50)
            
            local Label = Instance.new("TextLabel")
            Label.Parent = Container
            Label.Name = "Label"
            Label.Text = Text .. ": " .. (Default or Min)
            Label.BackgroundTransparency = 1
            Label.TextColor3 = Color3.fromRGB(255, 255, 255)
            Label.TextSize = 12
            Label.Font = Enum.Font.Gotham
            Label.Size = UDim2.new(1, 0, 0, 16)
            
            local SliderBg = Instance.new("Frame")
            SliderBg.Parent = Container
            SliderBg.Name = "SliderBg"
            SliderBg.BackgroundColor3 = THEME.Section
            SliderBg.BorderColor3 = THEME.Border
            SliderBg.BorderSizePixel = 1
            SliderBg.Size = UDim2.new(1, 0, 0, 12)
            SliderBg.Position = UDim2.new(0, 0, 0, 20)
            
            local Grab = Instance.new("Frame")
            Grab.Parent = SliderBg
            Grab.Name = "Grab"
            Grab.BackgroundColor3 = THEME.Accent
            Grab.BorderColor3 = THEME.Border
            Grab.BorderSizePixel = 1
            Grab.Size = UDim2.new(0, 8, 1, 0)
            
            local function Set(val)
                val = math.clamp(math.floor(val), Min, Max)
                local perc = (val - Min) / (Max - Min)
                Grab.Position = UDim2.fromScale(perc, 0)
                Label.Text = Text .. ": " .. val
                Callback(val)
            end
            
            SliderBg.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    local move; move = UserInputService.InputChanged:Connect(function(e)
                        if e.UserInputType == Enum.UserInputType.MouseMovement then
                            local perc = math.clamp((e.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
                            Set(Min + (Max - Min) * perc)
                        end
                    end)
                    UserInputService.InputEnded:Connect(function(e)
                        if e.UserInputType == Enum.UserInputType.MouseButton1 then
                            move:Disconnect()
                        end
                    end)
                end
            end)
            
            Set(Default or Min)
            return Container
        end
        
        return Elements
    end
    
    return Lib
end

return ImGui
