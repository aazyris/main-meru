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

--// Strict Black Theme
local THEME = {
    Background = Color3.fromRGB(12, 12, 12),
    Section = Color3.fromRGB(18, 18, 18),
    Border = Color3.fromRGB(25, 25, 25),
    Text = Color3.fromRGB(255, 255, 255)
}

local IsStudio = RunService:IsStudio()
local GuiParent = IsStudio and PlayerGui or CoreGui

--// Utility: Dragging and Resizing Logic
local function ApplyInteractions(Frame, Handle, ResizeHandle)
    -- Draggable
    local Dragging, DragInput, DragStart, StartPos
    Handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
            DragStart = input.Position
            StartPos = Frame.Position
        end
    end)
    -- Resizable
    local Resizing, ResizeStart, StartSize
    ResizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            Resizing = true
            ResizeStart = input.Position
            StartSize = Frame.AbsoluteSize
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if Dragging then
                local delta = input.Position - DragStart
                Frame.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + delta.X, StartPos.Y.Scale, StartPos.Y.Offset + delta.Y)
            elseif Resizing then
                local delta = input.Position - ResizeStart
                Frame.Size = UDim2.fromOffset(math.max(200, StartSize.X + delta.X), math.max(100, StartSize.Y + delta.Y))
            end
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then 
            Dragging = false 
            Resizing = false
        end
    end)
end

function ImGui:CreateWindow(Config)
    local UI = game:GetObjects(self.UIAssetId)[1]
    local Window = UI.Prefabs.Window:Clone()
    local Screen = Instance.new("ScreenGui", GuiParent)
    Screen.Name = "Blackout_" .. (Config.Title or "Menu")
    
    Window.Parent = Screen
    Window.BackgroundColor3 = THEME.Background
    Window.BorderColor3 = THEME.Border
    Window.ClipsDescendants = true
    
    local Content = Window.Content
    local Body = Content.Body
    local TitleBar = Content.TitleBar
    local ToolBar = Content.ToolBar
    local ResizeBtn = Window:FindFirstChild("ResizeGrab") or Window:FindFirstChild("Resize", true)

    -- Sync Colors (No Split)
    Body.BackgroundColor3 = THEME.Background
    ToolBar.BackgroundColor3 = THEME.Background
    TitleBar.BackgroundColor3 = THEME.Background
    TitleBar.Left.Title.Text = Config.Title or "Menu"
    
    ApplyInteractions(Window, TitleBar, ResizeBtn)

    -- Improved Minimize (Dark)
    local IsMinimized = false
    local StoredHeight = Config.Size and Config.Size.Y.Offset or 350
    
    TitleBar.Left.Toggle.ToggleButton.Activated:Connect(function()
        IsMinimized = not IsMinimized
        if not IsMinimized then 
            Body.Visible = true 
            TweenService:Create(Window, self.Animation, {Size = UDim2.new(0, Window.Size.X.Offset, 0, StoredHeight)}):Play()
        else
            StoredHeight = Window.Size.Y.Offset
            local t = TweenService:Create(Window, self.Animation, {Size = UDim2.new(0, Window.Size.X.Offset, 0, 32)})
            t:Play()
            t.Completed:Connect(function() if IsMinimized then Body.Visible = false end end)
        end
    end)

    local Lib = {}
    local CurrentPage = nil

    function Lib:CreateTab(Name)
        local TabBtn = ToolBar.TabButton:Clone()
        TabBtn.Parent = ToolBar
        TabBtn.Text = Name
        TabBtn.BackgroundColor3 = THEME.Background
        TabBtn.Visible = true

        local Page = Body.Template:Clone()
        Page.Parent = Body
        Page.Visible = false
        Page.BackgroundColor3 = THEME.Background

        TabBtn.Activated:Connect(function()
            if CurrentPage then CurrentPage.Visible = false end
            Page.Visible = true
            CurrentPage = Page
            -- Reset other tab colors
            for _, b in pairs(ToolBar:GetChildren()) do if b:IsA("TextButton") then b.BackgroundTransparency = 1 end end
            TabBtn.BackgroundTransparency = 0.8
            TabBtn.BackgroundColor3 = THEME.Section
        end)

        -- Initialize First Tab
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
            -- Simplified Slider Logic
            Sld.MouseButton1Down:Connect(function()
                local move; move = UserInputService.InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement then
                        local perc = math.clamp((input.Position.X - Sld.AbsolutePosition.X) / Sld.AbsoluteSize.X, 0, 1)
                        Sld.Grab.Position = UDim2.fromScale(perc, 0.5)
                        Callback(math.floor(Min + (Max - Min) * perc))
                    end
                end)
                UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then move:Disconnect() end end)
            end)
            return Sld
        end

        return Elements
    end

    Window.Size = Config.Size or UDim2.fromOffset(450, 350)
    return Lib
end

return ImGui
