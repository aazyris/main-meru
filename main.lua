--// Written by depso
--// MIT License
--// Copyright (c) 2024 Depso

local ImGui = {
    Windows = {},
    -- Smooth animation settings
    Animation = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    UIAssetId = "rbxassetid://76246418997296",
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

--// Smooth Dragging Logic
local function MakeSmooth(Frame, Handle)
    local Dragging, DragInput, DragStart, StartPos

    Handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
            DragStart = input.Position
            StartPos = Frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)

    Handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            DragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == DragInput and Dragging then
            local Delta = input.Position - DragStart
            Frame.Position = UDim2.new(
                StartPos.X.Scale, 
                StartPos.X.Offset + Delta.X, 
                StartPos.Y.Scale, 
                StartPos.Y.Offset + Delta.Y
            )
        end
    end)
end

function ImGui:CreateWindow(Config)
    local UI = game:GetObjects(self.UIAssetId)[1]
    local Window = UI.Prefabs.Window:Clone()
    local Screen = Instance.new("ScreenGui", GuiParent)
    Screen.Name = "Hub_" .. (Config.Title or "Main")
    Screen.ResetOnSpawn = false
    
    Window.Parent = Screen
    Window.BackgroundColor3 = THEME.Background
    Window.BorderColor3 = THEME.Border
    Window.ClipsDescendants = true
    
    local Content = Window.Content
    local Body, TitleBar, ToolBar = Content.Body, Content.TitleBar, Content.ToolBar
    local ResizeBtn = Window:FindFirstChild("ResizeGrab") or Window:FindFirstChild("Resize", true)

    -- Black out components
    Body.BackgroundColor3 = THEME.Background
    ToolBar.BackgroundColor3 = THEME.Background
    TitleBar.BackgroundColor3 = THEME.Background
    TitleBar.Left.Title.Text = Config.Title or "Hub Menu"
    
    -- Force Expand/Resize button to Black
    if ResizeBtn then
        ResizeBtn.BackgroundColor3 = THEME.Background
        ResizeBtn.ImageColor3 = THEME.Accent
        ResizeBtn.AutoButtonColor = false
        -- Smooth Resizing
        local Resizing, ResizeStart, StartSize
        ResizeBtn.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                Resizing, ResizeStart, StartSize = true, i.Position, Window.AbsoluteSize
            end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if Resizing and i.UserInputType == Enum.UserInputType.MouseMovement then
                local Delta = i.Position - ResizeStart
                Window.Size = UDim2.fromOffset(
                    math.max(250, StartSize.X + Delta.X), 
                    math.max(150, StartSize.Y + Delta.Y)
                )
            end
        end)
        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then Resizing = false end
        end)
    end

    -- Apply Smooth Dragging
    MakeSmooth(Window, TitleBar)

    -- FIXED: Minimize Logic & Arrow Animation
    local Arrow = TitleBar.Left.Toggle.ToggleButton
    local IsMinimized = false
    local StoredHeight = Config.Size and Config.Size.Y.Offset or 350
    
    Arrow.Rotation = 90 -- Start Expanded
    Arrow.Activated:Connect(function()
        IsMinimized = not IsMinimized
        
        -- Full Minimize Height (Just the TitleBar)
        local TargetHeight = IsMinimized and 32 or StoredHeight
        local TargetRotation = IsMinimized and 0 or 90
        
        if not IsMinimized then Body.Visible = true end
        
        -- Animate Size
        local SizeTween = TweenService:Create(Window, self.Animation, {Size = UDim2.new(0, Window.Size.X.Offset, 0, TargetHeight)})
        SizeTween:Play()
        
        -- Animate Arrow Rotation
        TweenService:Create(Arrow, self.Animation, {Rotation = TargetRotation}):Play()
        
        SizeTween.Completed:Connect(function()
            if IsMinimized then Body.Visible = false end
        end)
    end)

    -- Toggle Hub Visibility Key
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == self.ToggleKey then
            Screen.Enabled = not Screen.Enabled
        end
    end)

    local Lib = { CurrentPage = nil }

    function Lib:CreateTab(Name)
        local TabBtn = ToolBar.TabButton:Clone()
        TabBtn.Parent = ToolBar; TabBtn.Text = Name; TabBtn.Visible = true
        TabBtn.BackgroundColor3 = THEME.Background
        TabBtn.BorderSizePixel = 0

        local Page = Body.Template:Clone()
        Page.Parent = Body; Page.Visible = false; Page.BackgroundColor3 = THEME.Background

        -- Tab Switching Fix
        TabBtn.Activated:Connect(function()
            if self.CurrentPage then self.CurrentPage.Visible = false end
            Page.Visible = true
            self.CurrentPage = Page
            for _, b in pairs(ToolBar:GetChildren()) do 
                if b:IsA("TextButton") then b.BackgroundTransparency = 1 end 
            end
            TabBtn.BackgroundTransparency = 0.8
        end)

        if not self.CurrentPage then Page.Visible = true; self.CurrentPage = Page; TabBtn.BackgroundTransparency = 0.8 end

        local Elements = {}
        function Elements:Button(Text, Callback)
            local Btn = UI.Prefabs.Button:Clone()
            Btn.Parent = Page; Btn.Text = Text; Btn.Visible = true
            Btn.BackgroundColor3 = THEME.Section
            Btn.Activated:Connect(Callback)
            return Btn
        end

        function Elements:Toggle(Text, Default, Callback)
            local Enabled = Default or false
            local Tog = UI.Prefabs.Button:Clone()
            Tog.Parent = Page; Tog.Visible = true; Tog.BackgroundColor3 = THEME.Section
            local function Update()
                Tog.Text = Text .. ": " .. (Enabled and "[ ON ]" or "[ OFF ]")
                Tog.TextColor3 = Enabled and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 80, 80)
            end
            Tog.Activated:Connect(function()
                Enabled = not Enabled; Update(); Callback(Enabled)
            end)
            Update(); return Tog
        end

        return Elements
    end

    Window.Size = Config.Size or UDim2.fromOffset(450, 350)
    return Lib
end

return ImGui
