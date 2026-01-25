--// ImGui System - Complete Remake
--// No External Assets Required

local ImGui = {
    Windows = {},
    ToggleKey = Enum.KeyCode.RightShift
}

--// Services 
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local PlayerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

local IsStudio = RunService:IsStudio()
local GuiParent = IsStudio and PlayerGui or CoreGui

--// Theme
local THEME = {
    Background = Color3.fromRGB(10, 10, 10),
    Section = Color3.fromRGB(20, 20, 20),
    Border = Color3.fromRGB(35, 35, 35),
    Accent = Color3.fromRGB(100, 100, 100),
    Text = Color3.fromRGB(255, 255, 255),
    Green = Color3.fromRGB(0, 255, 0),
    Red = Color3.fromRGB(255, 0, 0)
}

local Animation = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

--// Utility: Create styled elements
local function CreateButton(Parent, Text, Callback)
    local Btn = Instance.new("TextButton")
    Btn.Parent = Parent
    Btn.Name = "Button"
    Btn.Text = Text
    Btn.BackgroundColor3 = THEME.Section
    Btn.BorderColor3 = THEME.Border
    Btn.TextColor3 = THEME.Text
    Btn.TextSize = 14
    Btn.Font = Enum.Font.GothamBold
    Btn.Size = UDim2.new(1, -10, 0, 35)
    Btn.Position = UDim2.new(0, 5, 0, 0)
    Btn.Activated:Connect(Callback)
    return Btn
end

local function CreateLabel(Parent, Text)
    local Lbl = Instance.new("TextLabel")
    Lbl.Parent = Parent
    Lbl.Name = "Label"
    Lbl.Text = Text
    Lbl.BackgroundColor3 = THEME.Background
    Lbl.BorderColor3 = THEME.Border
    Lbl.TextColor3 = THEME.Text
    Lbl.TextSize = 13
    Lbl.Font = Enum.Font.Gotham
    Lbl.Size = UDim2.new(1, 0, 1, 0)
    return Lbl
end

local function CreateFrame(Parent, Name)
    local Frm = Instance.new("Frame")
    Frm.Parent = Parent
    Frm.Name = Name
    Frm.BackgroundColor3 = THEME.Background
    Frm.BorderColor3 = THEME.Border
    return Frm
end

--// Main CreateWindow
function ImGui:CreateWindow(Config)
    local Title = Config.Title or "Window"
    local Size = Config.Size or UDim2.fromOffset(500, 400)
    
    local Screen = Instance.new("ScreenGui", GuiParent)
    Screen.Name = "Hub_" .. Title
    Screen.ResetOnSpawn = false
    
    local Window = CreateFrame(Screen, "Window")
    Window.Size = Size
    Window.Position = UDim2.fromOffset(100, 100)
    Window.BorderMode = Enum.BorderMode.Outline
    Window.BorderSizePixel = 2
    
    -- Title Bar
    local TitleBar = CreateFrame(Window, "TitleBar")
    TitleBar.Size = UDim2.new(1, 0, 0, 35)
    TitleBar.Position = UDim2.new(0, 0, 0, 0)
    TitleBar.BackgroundColor3 = THEME.Section
    TitleBar.BorderSizePixel = 0
    TitleBar.Active = true
    TitleBar.Selectable = true
    
    local TitleLabel = CreateLabel(TitleBar, Title)
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.TextSize = 16
    TitleLabel.TextColor3 = THEME.Text
    TitleLabel.Padding = UDim.new(0, 10)
    
    -- Minimize Button
    local MinBtn = Instance.new("TextButton")
    MinBtn.Parent = TitleBar
    MinBtn.Name = "MinimizeBtn"
    MinBtn.Text = "-"
    MinBtn.BackgroundColor3 = THEME.Accent
    MinBtn.BorderColor3 = THEME.Border
    MinBtn.TextColor3 = THEME.Text
    MinBtn.TextSize = 18
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.Size = UDim2.new(0, 35, 1, 0)
    MinBtn.Position = UDim2.new(1, -40, 0, 0)
    MinBtn.BorderSizePixel = 1
    
    -- Content Area
    local Content = CreateFrame(Window, "Content")
    Content.Size = UDim2.new(1, 0, 1, -35)
    Content.Position = UDim2.new(0, 0, 0, 35)
    Content.BorderSizePixel = 0
    
    -- Tabs Container
    local TabContainer = CreateFrame(Content, "TabContainer")
    TabContainer.Size = UDim2.new(1, 0, 0, 30)
    TabContainer.Position = UDim2.new(0, 0, 0, 0)
    TabContainer.BackgroundColor3 = THEME.Background
    TabContainer.BorderSizePixel = 0
    
    local TabLayout = Instance.new("UIListLayout")
    TabLayout.Parent = TabContainer
    TabLayout.FillDirection = Enum.FillDirection.Horizontal
    TabLayout.Padding = UDim.new(0, 2)
    
    -- Pages Container
    local PageContainer = CreateFrame(Content, "PageContainer")
    PageContainer.Size = UDim2.new(1, 0, 1, -30)
    PageContainer.Position = UDim2.new(0, 0, 0, 30)
    PageContainer.BorderSizePixel = 0
    PageContainer.ClipsDescendants = true
    
    -- Drag functionality
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
    
    -- Minimize functionality
    local IsMinimized = false
    local StoredHeight = Size.Y.Offset
    
    MinBtn.Activated:Connect(function()
        IsMinimized = not IsMinimized
        if IsMinimized then
            TweenService:Create(Window, Animation, {Size = UDim2.new(0, Window.Size.X.Offset, 0, 35)}):Play()
            Content.Visible = false
        else
            Content.Visible = true
            TweenService:Create(Window, Animation, {Size = UDim2.new(0, Window.Size.X.Offset, 0, StoredHeight)}):Play()
        end
    end)
    
    -- Toggle keybind
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == self.ToggleKey then
            Screen.Enabled = not Screen.Enabled
        end
    end)
    
    local Lib = { CurrentPage = nil, CurrentTab = nil }
    
    function Lib:CreateTab(Name)
        local TabBtn = Instance.new("TextButton")
        TabBtn.Parent = TabContainer
        TabBtn.Name = Name
        TabBtn.Text = Name
        TabBtn.BackgroundColor3 = THEME.Background
        TabBtn.BorderColor3 = THEME.Border
        TabBtn.TextColor3 = THEME.Text
        TabBtn.TextSize = 13
        TabBtn.Font = Enum.Font.GothamBold
        TabBtn.Size = UDim2.new(0, 100, 1, -2)
        TabBtn.Position = UDim2.new(0, 5, 0, 1)
        TabBtn.BorderSizePixel = 1
        
        local Page = CreateFrame(PageContainer, Name .. "_Page")
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.Position = UDim2.new(0, 0, 0, 0)
        Page.BorderSizePixel = 0
        Page.Visible = false
        
        local ScrollFrame = Instance.new("ScrollingFrame")
        ScrollFrame.Parent = Page
        ScrollFrame.Name = "Scroll"
        ScrollFrame.Size = UDim2.new(1, 0, 1, 0)
        ScrollFrame.Position = UDim2.new(0, 0, 0, 0)
        ScrollFrame.BackgroundTransparency = 1
        ScrollFrame.BorderSizePixel = 0
        ScrollFrame.ScrollBarThickness = 8
        ScrollFrame.ScrollBarImageColor3 = THEME.Accent
        
        local PageLayout = Instance.new("UIListLayout")
        PageLayout.Parent = ScrollFrame
        PageLayout.Padding = UDim.new(0, 5)
        PageLayout.FillDirection = Enum.FillDirection.Vertical
        
        local PagePadding = Instance.new("UIPadding")
        PagePadding.Parent = ScrollFrame
        PagePadding.PaddingLeft = UDim.new(0, 5)
        PagePadding.PaddingRight = UDim.new(0, 5)
        PagePadding.PaddingTop = UDim.new(0, 5)
        PagePadding.PaddingBottom = UDim.new(0, 5)
        
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
            local BtnContainer = Instance.new("Frame")
            BtnContainer.Parent = ScrollFrame
            BtnContainer.Name = "ButtonContainer"
            BtnContainer.BackgroundTransparency = 1
            BtnContainer.BorderSizePixel = 0
            BtnContainer.Size = UDim2.new(1, -10, 0, 35)
            
            local Btn = Instance.new("TextButton")
            Btn.Parent = BtnContainer
            Btn.Name = "Button"
            Btn.Text = Text
            Btn.BackgroundColor3 = THEME.Section
            Btn.BorderColor3 = THEME.Border
            Btn.TextColor3 = THEME.Text
            Btn.TextSize = 14
            Btn.Font = Enum.Font.GothamBold
            Btn.Size = UDim2.new(1, 0, 1, 0)
            Btn.BorderSizePixel = 1
            Btn.Activated:Connect(Callback)
            return Btn
        end
        
        function Elements:Toggle(Text, Default, Callback)
            local Enabled = Default or false
            
            local TogContainer = Instance.new("Frame")
            TogContainer.Parent = ScrollFrame
            TogContainer.Name = "ToggleContainer"
            TogContainer.BackgroundTransparency = 1
            TogContainer.BorderSizePixel = 0
            TogContainer.Size = UDim2.new(1, -10, 0, 35)
            
            local Tog = Instance.new("TextButton")
            Tog.Parent = TogContainer
            Tog.Name = "Toggle"
            Tog.BackgroundColor3 = THEME.Section
            Tog.BorderColor3 = THEME.Border
            Tog.TextColor3 = THEME.Text
            Tog.TextSize = 14
            Tog.Font = Enum.Font.GothamBold
            Tog.Size = UDim2.new(1, 0, 1, 0)
            Tog.BorderSizePixel = 1
            
            local function Update()
                Tog.Text = Text .. ": " .. (Enabled and "[ ON ]" or "[ OFF ]")
                Tog.TextColor3 = Enabled and THEME.Green or THEME.Red
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
            local SldContainer = Instance.new("Frame")
            SldContainer.Parent = ScrollFrame
            SldContainer.Name = "SliderContainer"
            SldContainer.BackgroundTransparency = 1
            SldContainer.BorderSizePixel = 0
            SldContainer.Size = UDim2.new(1, -10, 0, 60)
            
            local Lbl = Instance.new("TextLabel")
            Lbl.Parent = SldContainer
            Lbl.Name = "Label"
            Lbl.Text = Text .. ": " .. (Default or Min)
            Lbl.BackgroundTransparency = 1
            Lbl.BorderSizePixel = 0
            Lbl.TextColor3 = THEME.Text
            Lbl.TextSize = 13
            Lbl.Font = Enum.Font.Gotham
            Lbl.Size = UDim2.new(1, 0, 0, 20)
            
            local SldBg = Instance.new("Frame")
            SldBg.Parent = SldContainer
            SldBg.Name = "Background"
            SldBg.BackgroundColor3 = THEME.Section
            SldBg.BorderColor3 = THEME.Border
            SldBg.Size = UDim2.new(1, 0, 0, 15)
            SldBg.Position = UDim2.new(0, 0, 0, 25)
            SldBg.BorderSizePixel = 1
            
            local Grab = Instance.new("Frame")
            Grab.Parent = SldBg
            Grab.Name = "Grab"
            Grab.BackgroundColor3 = THEME.Accent
            Grab.BorderColor3 = THEME.Border
            Grab.Size = UDim2.new(0, 10, 1, 0)
            Grab.BorderSizePixel = 1
            
            local function Set(val)
                val = math.clamp(math.floor(val), Min, Max)
                local perc = (val - Min) / (Max - Min)
                Grab.Position = UDim2.fromScale(perc, 0)
                Lbl.Text = Text .. ": " .. val
                Callback(val)
            end
            
            SldBg.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then
                    local move; move = UserInputService.InputChanged:Connect(function(e)
                        if e.UserInputType == Enum.UserInputType.MouseMovement then
                            local perc = math.clamp((e.Position.X - SldBg.AbsolutePosition.X) / SldBg.AbsoluteSize.X, 0, 1)
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
            return SldBg
        end
        
        return Elements
    end
    
    return Lib
end

return ImGui
