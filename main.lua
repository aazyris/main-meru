local Library = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

function Library:CreateWindow() -- Hub name is now locked inside
    local Name = "Meru"
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = CoreGui
    ScreenGui.Name = Name .. "_Hub"
    ScreenGui.ResetOnSpawn = false

    local MainFrame = Instance.new("Frame")
    local MainCorner = Instance.new("UICorner")
    local LeftPanel = Instance.new("Frame")
    local TabContainer = Instance.new("ScrollingFrame")
    local ContentContainer = Instance.new("Frame")
    
    local TitleBar = Instance.new("Frame")
    local TitleLabel = Instance.new("TextLabel")
    local CloseButton = Instance.new("TextButton")

    -- Bigger Window Size: 500x350
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    MainFrame.BackgroundTransparency = 0.15
    MainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
    MainFrame.Size = UDim2.new(0, 500, 0, 350)
    MainFrame.ClipsDescendants = true
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
    TitleLabel.TextSize = 16
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

    LeftPanel.Parent = MainFrame
    LeftPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    LeftPanel.Position = UDim2.new(0, 0, 0, 35)
    LeftPanel.Size = UDim2.new(0, 130, 1, -35)

    TabContainer.Parent = LeftPanel
    TabContainer.Size = UDim2.new(1, 0, 1, -10)
    TabContainer.Position = UDim2.new(0, 0, 0, 5)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 0
    Instance.new("UIListLayout", TabContainer).Padding = UDim.new(0, 5)
    TabContainer.UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    ContentContainer.Parent = MainFrame
    ContentContainer.Position = UDim2.new(0, 140, 0, 45)
    ContentContainer.Size = UDim2.new(1, -150, 1, -55)
    ContentContainer.BackgroundTransparency = 1

    -- Toggle visibility with LeftControl
    UserInputService.InputBegan:Connect(function(io, p)
        if not p and io.KeyCode == Enum.KeyCode.LeftControl then
            ScreenGui.Enabled = not ScreenGui.Enabled
        end
    end)

    -- Dragging
    TitleBar.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            local StartPos = MainFrame.Position
            local MouseStart = Input.Position
            local MoveCon = UserInputService.InputChanged:Connect(function(MoveInput)
                if MoveInput.UserInputType == Enum.UserInputType.MouseMovement then
                    local Delta = MoveInput.Position - MouseStart
                    MainFrame.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
                end
            end)
            UserInputService.InputEnded:Connect(function(EndInput)
                if EndInput.UserInputType == Enum.UserInputType.MouseButton1 then MoveCon:Disconnect() end
            end)
        end
    end)

    local Tabs = {}
    local FirstTab = true

    function Tabs:CreateTab(TabName)
        local TabButton = Instance.new("TextButton")
        local Page = Instance.new("ScrollingFrame")
        
        TabButton.Size = UDim2.new(0, 115, 0, 32)
        TabButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        TabButton.Text = TabName
        TabButton.TextColor3 = Color3.fromRGB(150, 150, 150)
        TabButton.Font = Enum.Font.Gotham
        TabButton.Parent = TabContainer
        Instance.new("UICorner", TabButton)

        Page.Parent = ContentContainer
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.ScrollBarThickness = 2
        Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        local PageList = Instance.new("UIListLayout", Page)
        PageList.Padding = UDim.new(0, 8)

        if FirstTab then
            Page.Visible = true
            TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            FirstTab = false
        end

        TabButton.MouseButton1Click:Connect(function()
            for _, v in pairs(ContentContainer:GetChildren()) do if v:IsA("ScrollingFrame") then v.Visible = false end end
            for _, v in pairs(TabContainer:GetChildren()) do if v:IsA("TextButton") then v.TextColor3 = Color3.fromRGB(150, 150, 150) end end
            Page.Visible = true
            TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        end)

        local Elements = {}

        function Elements:CreateButton(Text, Callback)
            local Button = Instance.new("TextButton")
            Button.Size = UDim2.new(1, -5, 0, 38)
            Button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            Button.Text = "  " .. Text
            Button.TextColor3 = Color3.fromRGB(255, 255, 255)
            Button.Font = Enum.Font.Gotham
            Button.TextXAlignment = Enum.TextXAlignment.Left
            Button.Parent = Page
            Instance.new("UICorner", Button)
            Button.MouseButton1Click:Connect(Callback)
        end

        function Elements:CreateSlider(Text, Min, Max, Callback)
            local SliderFrame = Instance.new("Frame")
            local Title = Instance.new("TextLabel")
            local Bar = Instance.new("Frame")
            local Fill = Instance.new("Frame")
            local Circle = Instance.new("Frame")
            
            SliderFrame.Size = UDim2.new(1, -5, 0, 50)
            SliderFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
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

            Bar.Size = UDim2.new(1, -40, 0, 4)
            Bar.Position = UDim2.new(0, 20, 0, 35)
            Bar.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            Bar.Parent = SliderFrame

            Fill.Size = UDim2.new(0, 0, 1, 0)
            Fill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
            Fill.Parent = Bar

            Circle.Size = UDim2.new(0, 14, 0, 14)
            Circle.AnchorPoint = Vector2.new(0.5, 0.5)
            Circle.Position = UDim2.new(0, 0, 0.5, 0)
            Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Circle.Parent = Fill -- Parented to Fill so it stays at the end
            Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)

            local function Update()
                local MousePos = UserInputService:GetMouseLocation().X
                local BarPos = Bar.AbsolutePosition.X
                local BarSize = Bar.AbsoluteSize.X
                local Percentage = math.clamp((MousePos - BarPos) / BarSize, 0, 1)
                
                Fill.Size = UDim2.new(Percentage, 0, 1, 0)
                Circle.Position = UDim2.new(1, 0, 0.5, 0) -- Stays locked to the Fill edge
                
                local Value = math.floor(Min + (Max - Min) * Percentage)
                Title.Text = Text .. ": " .. tostring(Value)
                Callback(Value)
            end

            local Dragging = false
            SliderFrame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    Dragging = true
                    Update()
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    Update()
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    Dragging = false
                end
            end)
        end

        return Elements
    end

    return Tabs
end

return Library
