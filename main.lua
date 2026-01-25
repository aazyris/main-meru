--// Depso Pro: Hard Dark & White (v4.5)
local Lib = { Windows = {} }

local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local Theme = {
    Main = Color3.fromRGB(0, 0, 0),       -- Pure Black
    Accent = Color3.fromRGB(255, 255, 255), -- Pure White
    Text = Color3.fromRGB(255, 255, 255),
    Font = Enum.Font.GothamBold,
    Opacity = 0.3 -- Backplate transparency
}

local function create(class, props)
    local inst = Instance.new(class)
    for i, v in next, props do inst[i] = v end
    return inst
end

local function tween(obj, info, goal)
    local t = TS:Create(obj, TweenInfo.new(info, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), goal)
    t:Play()
    return t
end

function Lib:CreateWindow(title)
    local Screen = create("ScreenGui", {Parent = CoreGui, Name = "DepsoHub", ResetOnSpawn = false})
    
    local Main = create("Frame", {
        Parent = Screen, 
        Size = UDim2.fromOffset(550, 400), 
        Position = UDim2.fromOffset(100, 100), 
        BackgroundColor3 = Theme.Main,
        BackgroundTransparency = Theme.Opacity,
        BorderSizePixel = 0,
        ClipsDescendants = true
    })
    create("UICorner", {Parent = Main, CornerRadius = UDim.new(0, 10)})
    create("UIStroke", {Parent = Main, Color = Theme.Accent, Transparency = 0.7, Thickness = 1.5})

    -- Header (Drag Area)
    local Header = create("Frame", {Parent = Main, Size = UDim2.new(1, 0, 0, 45), BackgroundTransparency = 1})
    create("TextLabel", {Parent = Header, Text = title:upper(), Size = UDim2.new(1, -100, 1, 0), Position = UDim2.fromOffset(15, 0), TextColor3 = Theme.Text, Font = Theme.Font, TextSize = 14, TextXAlignment = "Left", BackgroundTransparency = 1})
    
    -- Minimize Arrow
    local MinBtn = create("TextLabel", {Parent = Header, Size = UDim2.fromOffset(35, 35), Position = UDim2.new(1, -45, 0, 5), BackgroundTransparency = 1, Text = "▼", TextColor3 = Theme.Text, Font = Enum.Font.GothamBold, TextSize = 14})
    local MinClick = create("TextButton", {Parent = MinBtn, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = ""})

    -- Window Expander (Resize Handle)
    local ResizeBtn = create("TextLabel", {
        Parent = Main,
        Size = UDim2.fromOffset(25, 25),
        Position = UDim2.new(1, -25, 1, -25),
        BackgroundTransparency = 1,
        Text = "◢", -- Clear visual handle
        TextColor3 = Theme.Accent,
        TextSize = 22,
        ZIndex = 10
    })
    local ResizeClick = create("TextButton", {Parent = ResizeBtn, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = ""})

    -- Content Wrapper (This hides everything when minimized)
    local Content = create("Frame", {Parent = Main, Size = UDim2.new(1, 0, 1, -45), Position = UDim2.fromOffset(0, 45), BackgroundTransparency = 1})

    local Sidebar = create("ScrollingFrame", {Parent = Content, Size = UDim2.new(0, 150, 1, -15), Position = UDim2.fromOffset(10, 5), BackgroundColor3 = Color3.new(0,0,0), BackgroundTransparency = 0.5, CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = "Y", ScrollBarThickness = 0})
    create("UICorner", {Parent = Sidebar, CornerRadius = UDim.new(0, 8)})
    create("UIListLayout", {Parent = Sidebar, Padding = UDim.new(0, 5)})
    create("UIPadding", {Parent = Sidebar, PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingTop = UDim.new(0, 8)})

    local Container = create("Frame", {Parent = Content, Size = UDim2.new(1, -180, 1, -15), Position = UDim2.fromOffset(170, 5), BackgroundColor3 = Color3.new(0,0,0), BackgroundTransparency = 0.7})
    create("UICorner", {Parent = Container, CornerRadius = UDim.new(0, 8)})
    create("UIStroke", {Parent = Container, Color = Theme.Accent, Transparency = 0.9, Thickness = 1})

    -- Resizing Script
    local resizing = false
    ResizeClick.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then resizing = true end end)
    UIS.InputChanged:Connect(function(i) 
        if resizing and i.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = UIS:GetMouseLocation()
            local newX = math.clamp(mousePos.X - Main.AbsolutePosition.X, 400, 800)
            local newY = math.clamp(mousePos.Y - Main.AbsolutePosition.Y, 250, 600)
            Main.Size = UDim2.fromOffset(newX, newY)
        end
    end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then resizing = false end end)

    -- Dragging Script
    local dragging, dragStart, startPos
    Header.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true dragStart = i.Position startPos = Main.Position end end)
    UIS.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = i.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

    -- Minimize Script
    local minimized, savedSize = false, Main.Size
    MinClick.MouseButton1Click:Connect(function()
        minimized = not minimized
        tween(MinBtn, 0.3, {Rotation = minimized and -90 or 0})
        if minimized then
            savedSize = Main.Size
            Content.Visible = false
            ResizeBtn.Visible = false
            tween(Main, 0.3, {Size = UDim2.fromOffset(Main.Size.X.Offset, 45)})
        else
            local t = tween(Main, 0.3, {Size = savedSize})
            t.Completed:Wait()
            if not minimized then
                Content.Visible = true
                ResizeBtn.Visible = true
            end
        end
    end)

    local API = { FirstPage = nil }
    
    function API:Category(name)
        local Page = create("ScrollingFrame", {Parent = Container, Size = UDim2.new(1, -10, 1, -10), Position = UDim2.fromOffset(5,5), Visible = false, BackgroundTransparency = 1, CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = "Y", ScrollBarThickness = 2, ScrollBarImageColor3 = Theme.Accent})
        create("UIListLayout", {Parent = Page, Padding = UDim.new(0, 8)})
        
        local TabBtn = create("TextButton", {Parent = Sidebar, Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = Theme.Accent, BackgroundTransparency = 1, Text = name, Font = Theme.Font, TextSize = 12, TextColor3 = Color3.fromRGB(180, 180, 180)})
        create("UICorner", {Parent = TabBtn, CornerRadius = UDim.new(0, 6)})

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(Container:GetChildren()) do if v:IsA("ScrollingFrame") then v.Visible = false end end
            for _, v in pairs(Sidebar:GetChildren()) do if v:IsA("TextButton") then tween(v, 0.2, {BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(180,180,180)}) end end
            Page.Visible = true
            tween(TabBtn, 0.2, {BackgroundTransparency = 0.1, TextColor3 = Color3.new(0,0,0)}) -- Inverse for highlight
        end)
        
        if not API.FirstPage then API.FirstPage = Page; Page.Visible = true; tween(TabBtn, 0, {BackgroundTransparency = 0.1, TextColor3 = Color3.new(0,0,0)}) end

        local Entry = {}
        function Entry:Button(txt, cb)
            local b = create("TextButton", {Parent = Page, Size = UDim2.new(1, -5, 0, 35), BackgroundColor3 = Color3.new(0,0,0), BackgroundTransparency = 0.5, Text = txt, Font = Theme.Font, TextSize = 12, TextColor3 = Theme.Text})
            create("UICorner", {Parent = b, CornerRadius = UDim.new(0, 6)})
            create("UIStroke", {Parent = b, Color = Theme.Accent, Transparency = 0.8})
            b.MouseButton1Click:Connect(cb)
        end

        function Entry:Toggle(txt, cb)
            local enabled = false
            local b = create("TextButton", {Parent = Page, Size = UDim2.new(1, -5, 0, 35), BackgroundColor3 = Color3.new(0,0,0), BackgroundTransparency = 0.5, Text = "  "..txt, Font = Theme.Font, TextSize = 12, TextColor3 = Theme.Text, TextXAlignment = "Left"})
            create("UICorner", {Parent = b, CornerRadius = UDim.new(0, 6)})
            local box = create("Frame", {Parent = b, Size = UDim2.fromOffset(34, 18), Position = UDim2.new(1, -45, 0.5, -9), BackgroundColor3 = Color3.fromRGB(40,40,40)})
            create("UICorner", {Parent = box, CornerRadius = UDim.new(1, 0)})
            local dot = create("Frame", {Parent = box, Size = UDim2.fromOffset(12, 12), Position = UDim2.new(0, 3, 0.5, -6), BackgroundColor3 = Color3.new(1,1,1)})
            create("UICorner", {Parent = dot, CornerRadius = UDim.new(1, 0)})
            b.MouseButton1Click:Connect(function()
                enabled = not enabled
                tween(dot, 0.2, {Position = enabled and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)})
                tween(box, 0.2, {BackgroundColor3 = enabled and Theme.Accent or Color3.fromRGB(40,40,40)})
                cb(enabled)
            end)
        end

        function Entry:Slider(txt, min, max, def, cb)
            local SFrame = create("Frame", {Parent = Page, Size = UDim2.new(1, -5, 0, 45), BackgroundTransparency = 1})
            local lab = create("TextLabel", {Parent = SFrame, Text = txt.." : "..def, Size = UDim2.new(1,0,0,20), BackgroundTransparency = 1, TextColor3 = Theme.Text, Font = Theme.Font, TextSize = 11, TextXAlignment = "Left"})
            local bar = create("Frame", {Parent = SFrame, Size = UDim2.new(1, 0, 0, 4), Position = UDim2.new(0,0,0,30), BackgroundColor3 = Color3.fromRGB(50,50,50)})
            local fill = create("Frame", {Parent = bar, Size = UDim2.new((def-min)/(max-min), 0, 1, 0), BackgroundColor3 = Theme.Accent})
            local sliding = false
            local function update()
                local p = math.clamp((UIS:GetMouseLocation().X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                local val = math.floor(min + (max-min) * p)
                fill.Size = UDim2.new(p, 0, 1, 0)
                lab.Text = txt.." : "..val
                cb(val)
            end
            bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding = true update() end end)
            UIS.InputChanged:Connect(function(i) if sliding and i.UserInputType == Enum.UserInputType.MouseMovement then update() end end)
            UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end end)
        end

        return Entry
    end
    return API
end

return Lib
