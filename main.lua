--// Written by depso
--// MIT License
--// Copyright (c) 2024 Depso

local ImGui = {
    Windows = {},
    Animation = TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    UIAssetId = "rbxassetid://76246418997296"
}

--// Services 
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local PlayerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")

--// Theme Configuration (Strict Black)
local THEME = {
    Background = Color3.fromRGB(12, 12, 12), -- Deep Black
    Section = Color3.fromRGB(18, 18, 18),    -- Slightly lighter for options
    Border = Color3.fromRGB(30, 30, 30),     -- Dark Grey border
    Text = Color3.fromRGB(255, 255, 255),
    Accent = Color3.fromRGB(40, 40, 40)      -- For hover effects
}

local IsStudio = RunService:IsStudio()
local GuiParent = IsStudio and PlayerGui or CoreGui

--// Helper: Smooth Dragging
local function MakeDraggable(Frame, Handle)
    local Dragging, DragInput, DragStart, StartPos
    Handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
            DragStart = input.Position
            StartPos = Frame.Position
        end
    end)
    Handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then DragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            local delta = input.Position - DragStart
            Frame.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + delta.X, StartPos.Y.Scale, StartPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end
    end)
end

--// Engine Setup
function ImGui:CreateWindow(Config)
    local UI = game:GetObjects(self.UIAssetId)[1]
    local Window = UI.Prefabs.Window:Clone()
    local Screen = Instance.new("ScreenGui", GuiParent)
    Screen.Name = "ImGui_Blackout"
    
    Window.Parent = Screen
    Window.BackgroundColor3 = THEME.Background
    Window.BorderSizePixel = 1
    Window.BorderColor3 = THEME.Border
    Window.ClipsDescendants = true
    
    local Content = Window.Content
    local Body = Content.Body
    local TitleBar = Content.TitleBar
    local ToolBar = Content.ToolBar
    
    -- Color Synchronization
    Body.BackgroundColor3 = THEME.Background
    ToolBar.BackgroundColor3 = THEME.Background -- Sidebar now matches options
    TitleBar.BackgroundColor3 = THEME.Background
    TitleBar.Left.Title.Text = Config.Title or "Main Menu"
    
    MakeDraggable(Window, TitleBar)

    -- Fixed Minimize (Dark & Compact)
    local IsMinimized = false
    local StoredHeight = Config.Size and Config.Size.Y.Offset or 350
    
    TitleBar.Left.Toggle.ToggleButton.Activated:Connect(function()
        IsMinimized = not IsMinimized
        local TargetHeight = IsMinimized and 35 or StoredHeight
        
        if not IsMinimized then Body.Visible = true end
        
        local t = TweenService:Create(Window, self.Animation, {Size = UDim2.new(0, Window.Size.X.Offset, 0, TargetHeight)})
        t:Play()
        
        t.Completed:Connect(function()
            if IsMinimized then Body.Visible = false end
        end)
    end)

    local Lib = {}
    local CurrentPage = nil

    function Lib:CreateTab(Name)
        local TabBtn = ToolBar.TabButton:Clone()
        TabBtn.Parent = ToolBar
        TabBtn.Text = Name
        TabBtn.BackgroundColor3 = THEME.Background
        TabBtn.BorderColor3 = THEME.Border
        TabBtn.Visible = true

        local Page = Body.Template:Clone()
        Page.Parent = Body
        Page.Visible = false
        Page.BackgroundColor3 = THEME.Background

        -- Fix Category Switching Glitch
        TabBtn.Activated:Connect(function()
            if CurrentPage then CurrentPage.Visible = false end
            Page.Visible = true
            CurrentPage = Page
            
            -- Visual feedback for active tab
            for _, btn in pairs(ToolBar:GetChildren()) do
                if btn:IsA("TextButton") then btn.BackgroundTransparency = 1 end
            end
            TabBtn.BackgroundTransparency = 0.8
        end)

        -- Default first tab
        if not CurrentPage then
            Page.Visible = true
            CurrentPage = Page
            TabBtn.BackgroundTransparency = 0.8
        end

        local Elements = {}

        function Elements:Button(Text, Callback)
            local Btn = UI.Prefabs.Button:Clone()
            Btn.Parent = Page
            Btn.Text = Text
            Btn.BackgroundColor3 = THEME.Section
            Btn.BorderColor3 = THEME.Border
            Btn.Visible = true
            Btn.Activated:Connect(Callback)
            return Btn
        end

        function Elements:Slider(Text, Min, Max, Default, Callback)
            local Sld = UI.Prefabs.Slider:Clone()
            Sld.Parent = Page
            Sld.Label.Text = Text
            Sld.BackgroundColor3 = THEME.Section
            Sld.Visible = true
            
            local Grab = Sld.Grab
            local function Update(val)
                local perc = math.clamp((val - Min) / (Max - Min), 0, 1)
                Grab.Position = UDim2.fromScale(perc, 0.5)
                Callback(val)
            end
            
            Sld.MouseButton1Down:Connect(function()
                local move; move = UserInputService.InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement then
                        local relativeX = input.Position.X - Sld.AbsolutePosition.X
                        local perc = math.clamp(relativeX / Sld.AbsoluteSize.X, 0, 1)
                        Update(Min + (Max - Min) * perc)
                    end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then move:Disconnect() end
                end)
            end)
            return Sld
        end

        return Elements
    end

    Window.Size = Config.Size or UDim2.fromOffset(450, 350)
    return Lib
end

return ImGui
