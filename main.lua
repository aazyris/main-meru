-- Save this as your Library Source
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
    local TitleCorner = Instance.new("UICorner")
    local TitleLabel = Instance.new("TextLabel")
    local CloseButton = Instance.new("TextButton")
    local ResizeButton = Instance.new("ImageButton")
    local Container = Instance.new("ScrollingFrame")
    local UIList = Instance.new("UIListLayout")

    -- Window Properties
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    MainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
    MainFrame.Size = UDim2.new(0, 300, 0, 200)
    MainFrame.ClipsDescendants = true

    MainCorner.CornerRadius = UDim.new(0, 8)
    MainCorner.Parent = MainFrame

    TitleBar.Size = UDim2.new(1, 0, 0, 30)
    TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    TitleBar.Parent = MainFrame

    TitleCorner.CornerRadius = UDim.new(0, 8)
    TitleCorner.Parent = TitleBar

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

    ResizeButton.Size = UDim2.new(0, 15, 0, 15)
    ResizeButton.Position = UDim2.new(1, -15, 1, -15)
    ResizeButton.BackgroundTransparency = 1
    ResizeButton.Image = "rbxassetid://3926307971" -- Sharp corner icon
    ResizeButton.ImageColor3 = Color3.fromRGB(255, 255, 255)
    ResizeButton.ZIndex = 10
    ResizeButton.Parent = MainFrame

    Container.Name = "Container"
    Container.Parent = MainFrame
    Container.Position = UDim2.new(0, 5, 0, 35)
    Container.Size = UDim2.new(1, -10, 1, -45)
    Container.BackgroundTransparency = 1
    Container.ScrollBarThickness = 2

    UIList.Parent = Container
    UIList.Padding = UDim.new(0, 5)
    UIList.SortOrder = Enum.SortOrder.LayoutOrder

    -- Internal Logic for Drag and Resize
    local CurrentRestingSize = MainFrame.Size
    
    -- Dragging Logic with Animation
    TitleBar.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            local StartPos = MainFrame.Position
            local MouseStart = Input.Position
            
            -- Pop Up Animation
            local PopSize = UDim2.new(0, CurrentRestingSize.X.Offset + 10, 0, CurrentRestingSize.Y.Offset + 10)
            TweenService:Create(MainFrame, TweenInfo.new(0.2), {Size = PopSize}):Play()

            local MoveCon
            MoveCon = UserInputService.InputChanged:Connect(function(MoveInput)
                if MoveInput.UserInputType == Enum.UserInputType.MouseMovement then
                    local Delta = MoveInput.Position - MouseStart
                    MainFrame.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
                end
            end)

            UserInputService.InputEnded:Connect(function(EndInput)
                if EndInput.UserInputType == Enum.UserInputType.MouseButton1 then
                    MoveCon:Disconnect()
                    TweenService:Create(MainFrame, TweenInfo.new(0.2), {Size = CurrentRestingSize}):Play()
                end
            end)
        end
    end)

    -- Resize Logic
    ResizeButton.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            local StartSize = MainFrame.AbsoluteSize
            local MouseStart = Input.Position

            local ResizeCon
            ResizeCon = UserInputService.InputChanged:Connect(function(MoveInput)
                if MoveInput.UserInputType == Enum.UserInputType.MouseMovement then
                    local Delta = MoveInput.Position - MouseStart
                    local NewSize = UDim2.new(0, math.max(200, StartSize.X + Delta.X), 0, math.max(100, StartSize.Y + Delta.Y))
                    MainFrame.Size = NewSize
                    CurrentRestingSize = NewSize
                end
            end)

            UserInputService.InputEnded:Connect(function(EndInput)
                if EndInput.UserInputType == Enum.UserInputType.MouseButton1 then
                    ResizeCon:Disconnect()
                end
            end)
        end
    end)

    -- Elements Functions
    local Elements = {}

    function Elements:CreateButton(Text, Callback)
        local Button = Instance.new("TextButton")
        local BCorner = Instance.new("UICorner")
        
        Button.Size = UDim2.new(1, 0, 0, 30)
        Button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        Button.Text = Text
        Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        Button.Font = Enum.Font.Gotham
        Button.TextSize = 13
        Button.Parent = Container

        BCorner.CornerRadius = UDim.new(0, 4)
        BCorner.Parent = Button

        Button.MouseButton1Click:Connect(function()
            pcall(Callback)
        end)
    end

    return Elements
end

return Library
