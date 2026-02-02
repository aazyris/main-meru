local Library = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

function Library:CreateWindow(Name)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Parent = CoreGui
    ScreenGui.Name = Name .. "_Lib"

    local MainFrame = Instance.new("Frame")
    local MainCorner = Instance.new("UICorner")
    local TitleBar = Instance.new("Frame")
    local TitleLabel = Instance.new("TextLabel")
    local CloseButton = Instance.new("TextButton")
    local ResizeGrip = Instance.new("ImageLabel") -- Better Resize Icon
    local Container = Instance.new("ScrollingFrame")
    local UIList = Instance.new("UIListLayout")

    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    MainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
    MainFrame.Size = UDim2.new(0, 300, 0, 220)
    MainFrame.ClipsDescendants = true

    MainCorner.CornerRadius = UDim.new(0, 8)
    MainCorner.Parent = MainFrame

    TitleBar.Size = UDim2.new(1, 0, 0, 30)
    TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    TitleBar.Parent = MainFrame

    TitleLabel.Size = UDim2.new(1, -40, 1, 0)
    TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = Name
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 14
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TitleBar

    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -30, 0, 0)
    CloseButton.BackgroundTransparency = 1
    CloseButton.Text = "×"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 20
    CloseButton.Parent = TitleBar
    CloseButton.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

    -- Fixed Resize Icon
    ResizeGrip.Name = "ResizeGrip"
    ResizeGrip.Parent = MainFrame
    ResizeGrip.AnchorPoint = Vector2.new(1, 1)
    ResizeGrip.Position = UDim2.new(1, -2, 1, -2)
    ResizeGrip.Size = UDim2.new(0, 15, 0, 15)
    ResizeGrip.BackgroundTransparency = 1
    ResizeGrip.Image = "rbxassetid://3926307971"
    ResizeGrip.ImageColor3 = Color3.fromRGB(255, 255, 255)
    ResizeGrip.ZIndex = 10

    Container.Parent = MainFrame
    Container.Position = UDim2.new(0, 10, 0, 40)
    Container.Size = UDim2.new(1, -20, 1, -50)
    Container.BackgroundTransparency = 1
    Container.ScrollBarThickness = 2
    Container.CanvasSize = UDim2.new(0, 0, 0, 0)
    Container.AutomaticCanvasSize = Enum.AutomaticSize.Y

    UIList.Parent = Container
    UIList.Padding = UDim.new(0, 6)
    UIList.SortOrder = Enum.SortOrder.LayoutOrder

    -- Dragging Logic
    local CurrentRestingSize = MainFrame.Size
    TitleBar.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            local StartPos = MainFrame.Position
            local MouseStart = Input.Position
            
            -- Pop Animation
            TweenService:Create(MainFrame, TweenInfo.new(0.2), {Size = UDim2.new(0, CurrentRestingSize.X.Offset + 10, 0, CurrentRestingSize.Y.Offset + 10)}):Play()

            local MoveCon = UserInputService.InputChanged:Connect(function(MoveInput)
                if MoveInput.UserInputType == Enum.UserInputType.MouseMovement then
                    local Delta = MoveInput.Position - MouseStart
                    MainFrame.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
                end
            end)

            local EndCon
            EndCon = UserInputService.InputEnded:Connect(function(EndInput)
                if EndInput.UserInputType == Enum.UserInputType.MouseButton1 then
                    MoveCon:Disconnect()
                    EndCon:Disconnect()
                    TweenService:Create(MainFrame, TweenInfo.new(0.2), {Size = CurrentRestingSize}):Play()
                end
            end)
        end
    end)

    -- Resize Logic
    ResizeGrip.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            local StartSize = MainFrame.AbsoluteSize
            local MouseStart = Input.Position

            local ResizeCon = UserInputService.InputChanged:Connect(function(MoveInput)
                if MoveInput.UserInputType == Enum.UserInputType.MouseMovement then
                    local Delta = MoveInput.Position - MouseStart
                    local NewSize = UDim2.new(0, math.max(200, StartSize.X + Delta.X), 0, math.max(120, StartSize.Y + Delta.Y))
                    MainFrame.Size = NewSize
                    CurrentRestingSize = NewSize
                end
            end)

            local EndCon
            EndCon = UserInputService.InputEnded:Connect(function(EndInput)
                if EndInput.UserInputType == Enum.UserInputType.MouseButton1 then
                    ResizeCon:Disconnect()
                    EndCon:Disconnect()
                end
            end)
        end
    end)

    local Elements = {}

    function Elements:CreateButton(Text, Callback)
        local Button = Instance.new("TextButton")
        local BCorner = Instance.new("UICorner")
        Button.Size = UDim2.new(1, 0, 0, 32)
        Button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        Button.Text = "  " .. Text
        Button.TextColor3 = Color3.fromRGB(200, 200, 200)
        Button.Font = Enum.Font.Gotham
        Button.TextSize = 13
        Button.TextXAlignment = Enum.TextXAlignment.Left
        Button.Parent = Container
        BCorner.CornerRadius = UDim.new(0, 4)
        BCorner.Parent = Button
        
        Button.MouseButton1Click:Connect(Callback)
    end

    function Elements:CreateToggle(Text, Callback)
        local Toggled = false
        local Button = Instance.new("TextButton")
        local BCorner = Instance.new("UICorner")
        local Indicator = Instance.new("Frame")
        local ICorner = Instance.new("UICorner")

        Button.Size = UDim2.new(1, 0, 0, 32)
        Button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        Button.Text = "  " .. Text
        Button.TextColor3 = Color3.fromRGB(200, 200, 200)
        Button.Font = Enum.Font.Gotham
        Button.TextSize = 13
        Button.TextXAlignment = Enum.TextXAlignment.Left
        Button.Parent = Container
        BCorner.CornerRadius = UDim.new(0, 4)
        BCorner.Parent = Button

        Indicator.Size = UDim2.new(0, 20, 0, 20)
        Indicator.Position = UDim2.new(1, -26, 0.5, -10)
        Indicator.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        Indicator.Parent = Button
        ICorner.CornerRadius = UDim.new(0, 4)
        ICorner.Parent = Indicator

        Button.MouseButton1Click:Connect(function()
            Toggled = not Toggled
            TweenService:Create(Indicator, TweenInfo.new(0.2), {BackgroundColor3 = Toggled and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(50, 50, 50)}):Play()
            Callback(Toggled)
        end)
    end

    return Elements
end

return Library
