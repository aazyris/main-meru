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
    local LeftPanel = Instance.new("Frame") -- Category Side
    local TabContainer = Instance.new("ScrollingFrame")
    local ContentContainer = Instance.new("Frame") -- Elements Side
    
    local TitleBar = Instance.new("Frame")
    local TitleLabel = Instance.new("TextLabel")
    local CloseButton = Instance.new("TextButton")

    -- Larger Hub Size (450x300)
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    MainFrame.BackgroundTransparency = 0.15
    MainFrame.Position = UDim2.new(0.5, -225, 0.5, -150)
    MainFrame.Size = UDim2.new(0, 450, 0, 300)
    MainFrame.ClipsDescendants = true
    MainCorner.Parent = MainFrame

    -- Title Bar
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

    -- Sidebar (Categories)
    LeftPanel.Name = "LeftPanel"
    LeftPanel.Parent = MainFrame
    LeftPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    LeftPanel.Position = UDim2.new(0, 0, 0, 35)
    LeftPanel.Size = UDim2.new(0, 120, 1, -35)

    TabContainer.Parent = LeftPanel
    TabContainer.Size = UDim2.new(1, 0, 1, -10)
    TabContainer.Position = UDim2.new(0, 0, 0, 5)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 0
    local TabList = Instance.new("UIListLayout", TabContainer)
    TabList.Padding = UDim.new(0, 5)
    TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center

    -- Content Area
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Parent = MainFrame
    ContentContainer.Position = UDim2.new(0, 125, 0, 40)
    ContentContainer.Size = UDim2.new(1, -130, 1, -45)
    ContentContainer.BackgroundTransparency = 1

    -- Dragging Logic
    TitleBar.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            local StartPos = MainFrame.Position
            local MouseStart = Input.Position
            TweenService:Create(MainFrame, TweenInfo.new(0.2), {Size = UDim2.new(0, 460, 0, 310)}):Play()
            local MoveCon = UserInputService.InputChanged:Connect(function(MoveInput)
                if MoveInput.UserInputType == Enum.UserInputType.MouseMovement then
                    local Delta = MoveInput.Position - MouseStart
                    MainFrame.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
                end
            end)
            UserInputService.InputEnded:Connect(function(EndInput)
                if EndInput.UserInputType == Enum.UserInputType.MouseButton1 then
                    MoveCon:Disconnect()
                    TweenService:Create(MainFrame, TweenInfo.new(0.2), {Size = UDim2.new(0, 450, 0, 300)}):Play()
                end
            end)
        end
    end)

    local Tabs = {}
    local FirstTab = true

    function Tabs:CreateTab(TabName)
        local TabButton = Instance.new("TextButton")
        local Page = Instance.new("ScrollingFrame")
        local PageList = Instance.new("UIListLayout")

        TabButton.Size = UDim2.new(0, 100, 0, 30)
        TabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        TabButton.Text = TabName
        TabButton.TextColor3 = Color3.fromRGB(150, 150, 150)
        TabButton.Font = Enum.Font.Gotham
        TabButton.TextSize = 12
        TabButton.Parent = TabContainer
        Instance.new("UICorner", TabButton)

        Page.Name = TabName .. "_Page"
        Page.Parent = ContentContainer
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.ScrollBarThickness = 2
        Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        PageList.Parent = Page
        PageList.Padding = UDim.new(0, 6)

        if FirstTab then
            Page.Visible = true
            TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            TabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            FirstTab = false
        end

        TabButton.MouseButton1Click:Connect(function()
            for _, v in pairs(ContentContainer:GetChildren()) do v.Visible = false end
            for _, v in pairs(TabContainer:GetChildren()) do 
                if v:IsA("TextButton") then 
                    v.TextColor3 = Color3.fromRGB(150, 150, 150)
                    v.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                end 
            end
            Page.Visible = true
            TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            TabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        end)

        local Elements = {}

        function Elements:CreateButton(Text, Callback)
            local Button = Instance.new("TextButton")
            Button.Size = UDim2.new(1, 0, 0, 32)
            Button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            Button.Text = "  " .. Text
            Button.TextColor3 = Color3.fromRGB(255, 255, 255)
            Button.Font = Enum.Font.Gotham
            Button.TextSize = 13
            Button.TextXAlignment = Enum.TextXAlignment.Left
            Button.Parent = Page
            Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 6)
            Button.MouseButton1Click:Connect(Callback)
        end

        function Elements:CreateToggle(Text, Callback)
            local Toggled = false
            local Button = Instance.new("TextButton")
            local Indicator = Instance.new("Frame")
            Button.Size = UDim2.new(1, 0, 0, 32)
            Button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            Button.Text = "  " .. Text
            Button.TextColor3 = Color3.fromRGB(255, 255, 255)
            Button.Font = Enum.Font.Gotham
            Button.TextSize = 13
            Button.TextXAlignment = Enum.TextXAlignment.Left
            Button.Parent = Page
            Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 6)
            Indicator.Size = UDim2.new(0, 20, 0, 20)
            Indicator.Position = UDim2.new(1, -26, 0.5, -10)
            Indicator.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            Indicator.Parent = Button
            Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0)
            Button.MouseButton1Click:Connect(function()
                Toggled = not Toggled
                TweenService:Create(Indicator, TweenInfo.new(0.2), {BackgroundColor3 = Toggled and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(50, 50, 50)}):Play()
                Callback(Toggled)
            end)
        end

        function Elements:CreateSlider(Text, Min, Max, Callback)
            local SliderFrame = Instance.new("Frame")
            local Title = Instance.new("TextLabel")
            local Bar = Instance.new("Frame")
            local Fill = Instance.new("Frame")
            local Circle = Instance.new("Frame") -- The Handle
            
            SliderFrame.Size = UDim2.new(1, 0, 0, 45)
            SliderFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
            SliderFrame.Parent = Page
            Instance.new("UICorner", SliderFrame)

            Title.Size = UDim2.new(1, 0, 0, 20)
            Title.Position = UDim2.new(0, 10, 0, 5)
            Title.Text = Text .. ": " .. Min
            Title.TextColor3 = Color3.fromRGB(200, 200, 200)
            Title.BackgroundTransparency = 1
            Title.Font = Enum.Font.Gotham
            Title.TextSize = 12
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.Parent = SliderFrame

            Bar.Size = UDim2.new(1, -30, 0, 4)
            Bar.Position = UDim2.new(0, 15, 0, 32)
            Bar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            Bar.Parent = SliderFrame

            Fill.Size = UDim2.new(0, 0, 1, 0)
            Fill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
            Fill.Parent = Bar

            Circle.Size = UDim2.new(0, 12, 0, 12)
            Circle.AnchorPoint = Vector2.new(0.5, 0.5)
            Circle.Position = UDim2.new(0, 0, 0.5, 0)
            Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Circle.Parent = Fill
            Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)

            local function Update(Input)
                local Size = math.clamp((Input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                Fill.Size = UDim2.new(Size, 0, 1, 0)
                local Value = math.floor(Min + (Max - Min) * Size)
                Title.Text = Text .. ": " .. tostring(Value)
                Callback(Value)
            end

            SliderFrame.InputBegan:Connect(function(Input)
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

    return Tabs
end

return Library
