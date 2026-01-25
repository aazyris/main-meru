--// Depso Classic: Translucent Edition (GitHub Version)
local Lib = { Windows = {} }

local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local Theme = {
    Main = Color3.fromRGB(20, 20, 25),
    Accent = Color3.fromRGB(80, 80, 90),
    Text = Color3.fromRGB(255, 255, 255),
    Font = Enum.Font.Code
}

--// Helper: Quick Instance Creator
local function create(class, props)
    local inst = Instance.new(class)
    for i, v in next, props do inst[i] = v end
    return inst
end

--// Helper: Smooth Drag
local function makeDrag(frame, handle)
    local dragging, startPos, dragStart
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging, dragStart, startPos = true, i.Position, frame.Position
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = i.Position - dragStart
            TS:Create(frame, TweenInfo.new(0.1), {
                Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            }):Play()
        end
    end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
end

function Lib:CreateWindow(title)
    local Screen = create("ScreenGui", {Parent = CoreGui, Name = "Depso_"..title})
    
    local Main = create("Frame", {
        Parent = Screen, Size = UDim2.fromOffset(300, 350), 
        Position = UDim2.fromOffset(100, 100), 
        BackgroundColor3 = Theme.Main, BackgroundTransparency = 0.25,
        ClipsDescendants = true
    })
    create("UIStroke", {Parent = Main, Color = Color3.new(1,1,1), Transparency = 0.8})

    local TitleBar = create("Frame", {Parent = Main, Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = Color3.new(0,0,0), BackgroundTransparency = 0.5})
    create("TextLabel", {Parent = TitleBar, Text = "  "..title:upper(), Size = UDim2.new(1,0,1,0), TextColor3 = Theme.Text, Font = Theme.Font, TextXAlignment = "Left", BackgroundTransparency = 1})
    
    local Content = create("ScrollingFrame", {
        Parent = Main, Size = UDim2.new(1, -10, 1, -40), Position = UDim2.fromOffset(5, 35),
        BackgroundTransparency = 1, CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = "Y", ScrollBarThickness = 2
    })
    create("UIListLayout", {Parent = Content, Padding = UDim.new(0, 5), HorizontalAlignment = "Center"})

    makeDrag(Main, TitleBar)

    local API = {}

    -- Simple Button
    function API:Button(text, callback)
        local B = create("TextButton", {
            Parent = Content, Size = UDim2.new(1, -10, 0, 25), 
            BackgroundColor3 = Theme.Accent, BackgroundTransparency = 0.7,
            Text = text, Font = Theme.Font, TextColor3 = Theme.Text
        })
        B.MouseButton1Click:Connect(callback)
    end

    -- Simple Checkbox
    function API:Checkbox(text, callback)
        local active = false
        local B = create("TextButton", {
            Parent = Content, Size = UDim2.new(1, -10, 0, 25), 
            BackgroundColor3 = Theme.Accent, BackgroundTransparency = 0.8,
            Text = " [ ] "..text, Font = Theme.Font, TextColor3 = Theme.Text, TextXAlignment = "Left"
        })
        B.MouseButton1Click:Connect(function()
            active = not active
            B.Text = active and " [X] "..text or " [ ] "..text
            B.BackgroundTransparency = active and 0.5 or 0.8
            callback(active)
        end)
    end

    return API
end

return Lib
