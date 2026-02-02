local Library = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

function Library:CreateWindow(Name)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = CoreGui
    ScreenGui.Name = Name .. "_Hub"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local MainFrame = Instance.new("Frame")
    local MainCorner = Instance.new("UICorner")
    local TitleBar = Instance.new("Frame")
    local TitleLabel = Instance.new("TextLabel")
    local CloseButton = Instance.new("TextButton")
    local Container = Instance.new("ScrollingFrame")
    local UIList = Instance.new("UIListLayout")

    -- Fixed Hub Size (Perfect for all games)
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    MainFrame.BackgroundTransparency = 0.15 -- Opacity back
    MainFrame.Position = UDim2.new(0.5, -150, 0.5, -125)
    MainFrame.Size = UDim2.new(0, 320, 0, 250)
    MainFrame.ClipsDescendants = true

    MainCorner.CornerRadius = UDim.new(0, 8)
    MainCorner.Parent = MainFrame

    TitleBar.Size = UDim2.new(1, 0, 0, 35)
    TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    TitleBar.Parent = MainFrame

    TitleLabel.Size = UDim2.new(1, -40, 1, 0)
    TitleLabel.Position = UDim2.new(0, 12, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = Name
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 14
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TitleBar

    CloseButton.Size = UDim2.new(0, 35, 0, 35)
    CloseButton.Position = UDim2.new(1, -35, 0, 0)
    CloseButton.BackgroundTransparency = 1
    CloseButton.Text = "×"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 22
    CloseButton.Parent = TitleBar
    CloseButton.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

    Container.Parent = MainFrame
    Container.Position = UDim2.new(0, 10, 0, 45)
    Container.Size = UDim2.new(1, -20, 1, -55)
    Container.BackgroundTransparency = 1
    Container.ScrollBarThickness = 3
    Container.CanvasSize = UDim2.new(0, 0, 0, 0)
    Container.AutomaticCanvasSize = Enum.AutomaticSize.Y

    UIList.Parent = Container
    UIList.Padding = UDim.new(0, 7)
    UIList.SortOrder = Enum.SortOrder.LayoutOrder

    -- Dragging Logic with Pop Animation
    TitleBar.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            local StartPos = MainFrame.Position
            local MouseStart = Input.Position
            
            TweenService:Create(MainFrame, TweenInfo.new(0.2), {Size = UDim2.new(0, 330, 0, 260)}):Play()

            local MoveCon = UserInputService.InputChanged:Connect(function(MoveInput)
                if MoveInput.UserInputType == Enum.UserInputType.MouseMovement then
                    local Delta = MoveInput.Position - MouseStart
                    MainFrame.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
                end
            end)

            UserInputService.InputEnded:Connect(function(EndInput)
                if EndInput.UserInputType == Enum.UserInputType.MouseButton1 then
                    MoveCon:Disconnect()
                    TweenService:Create(MainFrame, TweenInfo.new(0.2), {Size = UDim2.new(0, 320, 0, 250)}):Play()
                end
            end)
        end
    end)

    local Elements = {}

    -- 1. BUTTON
    function Elements:CreateButton(Text, Callback)
        local Button = Instance.new("TextButton")
        local BCorner = Instance.new("UICorner")
        Button.Size = UDim2.new(1, 0, 0, 35)
        Button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        Button.Text = "  " .. Text
        Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        Button.Font = Enum.Font.Gotham
        Button.TextSize = 13
        Button.TextXAlignment = Enum.TextXAlignment.Left
        Button.Parent = Container
        BCorner.CornerRadius = UDim.new(0, 6)
        BCorner.Parent = Button
        Button.MouseButton1Click:Connect(Callback)
    end

    -- 2. TOGGLE
    function Elements:CreateToggle(Text, Callback)
        local Toggled = false
        local Button = Instance.new("TextButton")
        local Indicator = Instance.new("Frame")
        local ICorner = Instance.new("UICorner")

        Button.Size = UDim2.new(1, 0, 0, 35)
        Button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        Button.Text = "  " .. Text
        Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        Button.Font = Enum.Font.Gotham
        Button.TextSize = 13
        Button.TextXAlignment = Enum.TextXAlignment.Left
        Button.Parent = Container
        Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 6)

        Indicator.Size = UDim2.new(0, 24, 0, 24)
        Indicator.Position = UDim2.new(1, -30, 0.5, -12)
        Indicator.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        Indicator.Parent = Button
        ICorner.Parent = Indicator

        Button.MouseButton1Click:Connect(function()
            Toggled = not Toggled
            TweenService:Create(Indicator, TweenInfo.new(0.2), {BackgroundColor3 = Toggled and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(50, 50, 50)}):Play()
            Callback(Toggled)
        end)
    end

    -- 3. SLIDER
    function Elements:CreateSlider(Text, Min, Max, Callback)
        local SliderFrame = Instance.new("Frame")
        local Title = Instance.new("TextLabel")
        local Bar = Instance.new("Frame")
        local Fill = Instance.new("Frame")
        
        SliderFrame.Size = UDim2.new(1, 0, 0, 45)
        SliderFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        SliderFrame.Parent = Container
        Instance.new("UICorner", SliderFrame)

        Title.Size = UDim2.new(1, 0, 0, 20)
        Title.Position = UDim2.new(0, 10, 0, 5)
        Title.Text = Text
        Title.TextColor3 = Color3.fromRGB(200, 200, 200)
        Title.BackgroundTransparency = 1
        Title.Font = Enum.Font.Gotham
        Title.TextSize = 12
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.Parent = SliderFrame

        Bar.Size = UDim2.new(1, -20, 0, 4)
        Bar.Position = UDim2.new(0, 10, 0, 30)
        Bar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        Bar.Parent = SliderFrame

        Fill.Size = UDim2.new(0, 0, 1, 0)
        Fill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        Fill.Parent = Bar

        local function Update(Input)
            local Size = math.clamp((Input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
            Fill.Size = UDim2.new(Size, 0, 1, 0)
            local Value = math.floor(Min + (Max - Min) * Size)
            Title.Text = Text .. ": " .. tostring(Value)
            Callback(Value)
        end

        Bar.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                Update(Input)
                local Move = UserInputService.InputChanged:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseMovement then Update(Input) end
                end)
                UserInputService.InputEnded:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then Move:Disconnect() end
                end)
            end
        end)
    end

    return Elements
end

return Library
