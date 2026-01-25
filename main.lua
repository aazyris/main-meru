--// Written by depso
--// MIT License
--// Copyright (c) 2024 Depso

local ImGui = {
    Windows = {},
    Animation = TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
    UIAssetId = "rbxassetid://76246418997296",
    ToggleKey = Enum.KeyCode.RightShift -- Global key to hide/show
}

--// Services 
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local PlayerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

--// Strict Black Theme
local THEME = {
    Background = Color3.fromRGB(10, 10, 10),
    Section = Color3.fromRGB(15, 15, 15),
    Border = Color3.fromRGB(25, 25, 25),
    Accent = Color3.fromRGB(200, 200, 200)
}

--// Hub Essentials: Notification System
function ImGui:Notify(Title, Text)
    print(("[HUB]: %s - %s"):format(Title, Text))
    -- You can expand this with a custom UI popup later
end

function ImGui:CreateWindow(Config)
    local UI = game:GetObjects(self.UIAssetId)[1]
    local Window = UI.Prefabs.Window:Clone()
    local Screen = Instance.new("ScreenGui", (game:GetService("RunService"):IsStudio() and PlayerGui or CoreGui))
    Screen.Name = "Hub_" .. (Config.Title or "Loader")
    
    Window.Parent = Screen
    Window.BackgroundColor3 = THEME.Background
    Window.BorderColor3 = THEME.Border
    Window.ClipsDescendants = true
    
    local Content = Window.Content
    local Body, TitleBar, ToolBar = Content.Body, Content.TitleBar, Content.ToolBar
    local ResizeBtn = Window:FindFirstChild("ResizeGrab") or Window:FindFirstChild("Resize", true)

    -- Black out the Expand Button
    if ResizeBtn then
        ResizeBtn.BackgroundColor3 = THEME.Background
        ResizeBtn.ImageColor3 = THEME.Accent
    end

    -- Sync Colors
    Body.BackgroundColor3 = THEME.Background
    ToolBar.BackgroundColor3 = THEME.Background
    TitleBar.BackgroundColor3 = THEME.Background
    TitleBar.Left.Title.Text = Config.Title or "Hub Menu"
    
    -- Interaction: Drag & Expand
    local function SetupInteractions()
        local Dragging, Resizing, DragStart, ResizeStart, StartPos, StartSize
        
        TitleBar.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                Dragging, DragStart, StartPos = true, i.Position, Window.Position
            end
        end)

        ResizeBtn.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                Resizing, ResizeStart, StartSize = true, i.Position, Window.AbsoluteSize
            end
        end)

        UserInputService.InputChanged:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseMovement then
                if Dragging then
                    local Delta = i.Position - DragStart
                    Window.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
                elseif Resizing then
                    local Delta = i.Position - ResizeStart
                    Window.Size = UDim2.fromOffset(math.max(250, StartSize.X + Delta.X), math.max(150, StartSize.Y + Delta.Y))
                end
            end
        end)

        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then Draging, Resizing = false, false end
        end)
    end
    SetupInteractions()

    -- Correct Arrow Animation & Full Minimize
    local Arrow = TitleBar.Left.Toggle.ToggleButton
    local IsMinimized = false
    local StoredSizeY = Config.Size and Config.Size.Y.Offset or 350
    
    Arrow.Activated:Connect(function()
        IsMinimized = not IsMinimized
        local TargetY = IsMinimized and 30 or StoredSizeY
        local TargetRot = IsMinimized and 0 or 90
        
        if not IsMinimized then Body.Visible = true end
        
        TweenService:Create(Window, self.Animation, {Size = UDim2.new(0, Window.Size.X.Offset, 0, TargetY)}):Play()
        TweenService:Create(Arrow, self.Animation, {Rotation = TargetRot}):Play()
        
        task.delay(0.2, function() if IsMinimized then Body.Visible = false end end)
    end)

    -- Global Toggle (Keybind to hide menu)
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == self.ToggleKey then
            Screen.Enabled = not Screen.Enabled
        end
    end)

    local Lib = { CurrentPage = nil }

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
            if self.CurrentPage then self.CurrentPage.Visible = false end
            Page.Visible = true
            self.CurrentPage = Page
            for _, b in pairs(ToolBar:GetChildren()) do if b:IsA("TextButton") then b.BackgroundTransparency = 1 end end
            TabBtn.BackgroundTransparency = 0.8
        end)

        if not self.CurrentPage then Page.Visible = true; self.CurrentPage = Page; TabBtn.BackgroundTransparency = 0.8 end

        local Elements = {}
        function Elements:Button(Text, Callback)
            local Btn = UI.Prefabs.Button:Clone()
            Btn.Parent = Page; Btn.Text = Text; Btn.Visible = true
            Btn.BackgroundColor3 = THEME.Section
            Btn.Activated:Connect(Callback)
        end
        
        function Elements:Toggle(Text, Default, Callback)
            -- Hubs need toggles!
            local Tog = UI.Prefabs.Button:Clone() -- Reuse button prefab for simplicity
            local Enabled = Default or false
            Tog.Parent = Page; Tog.Text = Text .. ": " .. (Enabled and "ON" or "OFF"); Tog.Visible = true
            Tog.Activated:Connect(function()
                Enabled = not Enabled
                Tog.Text = Text .. ": " .. (Enabled and "ON" or "OFF")
                Callback(Enabled)
            end)
        end

        return Elements
    end

    Window.Size = Config.Size or UDim2.fromOffset(450, 350)
    return Lib
end

return ImGui
