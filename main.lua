--// Depso Classic: Translucent Edition (Library)
local DepsoLib = { Windows = {} }

local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

--// Theme Configuration
local Theme = {
    MainColor = Color3.fromRGB(20, 20, 25),
    Transparency = 0.25,
    DarkerColor = Color3.fromRGB(15, 15, 20),
    AccentColor = Color3.fromRGB(80, 80, 90),
    BorderColor = Color3.fromRGB(255, 255, 255),
    BorderTransparency = 0.8,
    TextColor = Color3.fromRGB(230, 230, 230),
    Font = Enum.Font.Code,
}

--// Helper: Smooth Dragging
local function MakeDraggable(frame, handle)
    local dragStart, startPos
    local dragging = false

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            TS:Create(frame, TweenInfo.new(0.08, Enum.EasingStyle.Quint), {
                Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            }):Play()
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
end

--// Helper: Resize Logic
local function MakeResizable(frame, handle)
    local dragging = false
    local startSize, startMousePos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            startSize = frame.Size
            startMousePos = input.Position
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - startMousePos
            frame.Size = UDim2.new(0, math.max(220, startSize.X.Offset + delta.X), 0, math.max(100, startSize.Y.Offset + delta.Y))
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
end

function DepsoLib:CreateWindow(title)
    local MenuTag = "Depso_" .. title:gsub("%s+", "")
    if CoreGui:FindFirstChild(MenuTag) then CoreGui[MenuTag]:Destroy() end

    local Screen = Instance.new("ScreenGui", CoreGui); Screen.Name = MenuTag

    -- Main Window
    local Main = Instance.new("Frame", Screen)
    Main.Size = UDim2.fromOffset(300, 350)
    Main.Position = UDim2.fromOffset(100, 100)
    Main.BackgroundColor3 = Theme.MainColor
    Main.BackgroundTransparency = Theme.Transparency
    Main.ClipsDescendants = true
    
    local MainStroke = Instance.new("UIStroke", Main)
    MainStroke.Color = Theme.BorderColor
    MainStroke.Transparency = Theme.BorderTransparency

    -- Title Bar
    local TitleBar = Instance.new("Frame", Main)
    TitleBar.Size = UDim2.new(1, 0, 0, 30)
    TitleBar.BackgroundColor3 = Theme.DarkerColor
    TitleBar.BorderSizePixel = 0

    local TitleLabel = Instance.new("TextLabel", TitleBar)
    TitleLabel.Size = UDim2.new(1, -60, 1, 0)
    TitleLabel.Position = UDim2.fromOffset(10, 0)
    TitleLabel.Text = title:upper()
    TitleLabel.Font = Theme.Font
    TitleLabel.TextSize = 14
    TitleLabel.TextColor3 = Theme.TextColor
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    -- Minimize Arrow
    local MinBtn = Instance.new("TextButton", TitleBar)
    MinBtn.Size = UDim2.fromOffset(30, 30)
    MinBtn.Position = UDim2.new(1, -30, 0, 0)
    MinBtn.BackgroundTransparency = 1
    MinBtn.Text = "▼"
    MinBtn.TextColor3 = Theme.TextColor
    MinBtn.Font = Theme.Font
    MinBtn.TextSize = 12

    -- Resize Handle
    local ResizeHandle = Instance.new("TextButton", Main)
    ResizeHandle.Size = UDim2.fromOffset(15, 15)
    ResizeHandle.Position = UDim2.new(1, -15, 1, -15)
    ResizeHandle.BackgroundTransparency = 1
    ResizeHandle.Text = "◢"
    ResizeHandle.TextColor3 = Theme.TextColor
    ResizeHandle.TextTransparency = 0.5
    ResizeHandle.ZIndex = 5

    local Content = Instance.new("ScrollingFrame", Main)
    Content.Size = UDim2.new(1, -10, 1, -40)
    Content.Position = UDim2.fromOffset(5, 35)
    Content.BackgroundTransparency = 1
    Content.BorderSizePixel = 0
    Content.ScrollBarThickness = 2
    Content.ScrollBarImageColor3 = Theme.AccentColor
    Content.CanvasSize = UDim2.new(0, 0, 0, 0)
    Content.AutomaticCanvasSize = Enum.AutomaticSize.Y

    local Layout = Instance.new("UIListLayout", Content)
    Layout.Padding = UDim.new(0, 6)
    Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    MakeDraggable(Main, TitleBar)
    MakeResizable(Main, ResizeHandle)

    local minimized = false
    local oldSize = Main.Size
    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        Content.Visible = not minimized
        ResizeHandle.Visible = not minimized
        if minimized then
            oldSize = Main.Size
            TS:Create(Main, TweenInfo.new(0.3), {Size = UDim2.fromOffset(Main.Size.X.Offset, 30)}):Play()
        else
            TS:Create(Main, TweenInfo.new(0.3), {Size = oldSize}):Play()
        end
        MinBtn.Text = minimized and "▲" or "▼"
    end)

    local Elements = {}

    --// Element: Label
    function Elements:Label(text)
        local Lab = Instance.new("TextLabel", Content)
        Lab.Size = UDim2.new(1, -10, 0, 20)
        Lab.BackgroundTransparency = 1
        Lab.Text = text
        Lab.Font = Theme.Font
        Lab.TextColor3 = Theme.TextColor
        Lab.TextSize = 12
        Lab.TextXAlignment = Enum.TextXAlignment.Left
    end

    --// Element: Button
    function Elements:Button(text, callback)
        local Btn = Instance.new("TextButton", Content)
        Btn.Size = UDim2.new(1, -10, 0, 28)
        Btn.BackgroundColor3 = Theme.AccentColor
        Btn.BackgroundTransparency = 0.7
        Btn.Text = text
        Btn.Font = Theme.Font
        Btn.TextColor3 = Theme.TextColor
        Btn.TextSize = 12
        
        Btn.MouseButton1Click:Connect(function()
            Btn.BackgroundTransparency = 0.4
            task.wait(0.1)
            Btn.BackgroundTransparency = 0.7
            callback()
        end)
    end

    --// Element: Checkbox
    function Elements:Checkbox(text, callback)
        local active = false
        local Btn = Instance.new("TextButton", Content)
        Btn.Size = UDim2.new(1, -10, 0, 28)
        Btn.BackgroundColor3 = Theme.AccentColor
        Btn.BackgroundTransparency = 0.8
        Btn.Text = "  [ ] " .. text
        Btn.Font = Theme.Font
        Btn.TextColor3 = Theme.TextColor
        Btn.TextSize = 12
        Btn.TextXAlignment = Enum.TextXAlignment.Left
        
        Btn.MouseButton1Click:Connect(function()
            active = not active
            Btn.Text = active and "  [X] " .. text or "  [ ] " .. text
            Btn.BackgroundTransparency = active and 0.5 or 0.8
            callback(active)
        end)
    end

    --// Element: Slider
    function Elements:Slider(text, min, max, default, callback)
        local SFrame = Instance.new("Frame", Content)
        SFrame.Size = UDim2.new(1, -10, 0, 35)
        SFrame.BackgroundTransparency = 1

        local SLab = Instance.new("TextLabel", SFrame)
        SLab.Size = UDim2.new(1, 0, 0, 15)
        SLab.Text = text .. " : " .. default
        SLab.Font = Theme.Font
        SLab.TextColor3 = Theme.TextColor
        SLab.TextSize = 11
        SLab.BackgroundTransparency = 1
        SLab.TextXAlignment = Enum.TextXAlignment.Left

        local Bar = Instance.new("Frame", SFrame)
        Bar.Size = UDim2.new(1, 0, 0, 10)
        Bar.Position = UDim2.fromOffset(0, 20)
        Bar.BackgroundColor3 = Theme.DarkerColor
        Bar.BorderSizePixel = 0

        local Fill = Instance.new("Frame", Bar)
        Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        Fill.BackgroundColor3 = Theme.AccentColor
        Fill.BorderSizePixel = 0

        local function UpdateSlider()
            local mousePos = UIS:GetMouseLocation().X
            local barPos = Bar.AbsolutePosition.X
            local barSize = Bar.AbsoluteSize.X
            local percent = math.clamp((mousePos - barPos) / barSize, 0, 1)
            local val = math.floor(min + (max - min) * percent)
            
            Fill.Size = UDim2.new(percent, 0, 1, 0)
            SLab.Text = text .. " : " .. val
            callback(val)
        end

        local sliding = false
        Bar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                sliding = true
                UpdateSlider()
            end
        end)

        UIS.InputChanged:Connect(function(input)
            if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
                UpdateSlider()
            end
        end)

        UIS.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
        end)
    end

    return Elements
end

return DepsoLib
