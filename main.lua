--// Depso Pro: Black & White Edition (v4.4 - Fixed & Expanded)
local Lib = { Windows = {} }

local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local Theme = {
    Main = Color3.fromRGB(0, 0, 0),       
    Dark = Color3.fromRGB(0, 0, 0),       
    Accent = Color3.fromRGB(255, 255, 255), 
    Text = Color3.fromRGB(255, 255, 255),
    Font = Enum.Font.GothamMedium,
    Opacity = 0.35 
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
        Size = UDim2.fromOffset(520, 380), 
        Position = UDim2.fromOffset(100, 100), 
        BackgroundColor3 = Theme.Main,
        BackgroundTransparency = Theme.Opacity,
        BorderSizePixel = 0,
        ClipsDescendants = true -- Crucial for clean minimize
    })
    create("UICorner", {Parent = Main, CornerRadius = UDim.new(0, 10)})
    create("UIStroke", {Parent = Main, Color = Theme.Accent, Transparency = 0.8, Thickness = 1})

    local Header = create("Frame", {Parent = Main, Size = UDim2.new(1, 0, 0, 45), BackgroundTransparency = 1})
    create("TextLabel", {Parent = Header, Text = title:upper(), Size = UDim2.new(1, -100, 1, 0), Position = UDim2.fromOffset(15, 0), TextColor3 = Theme.Text, Font = Theme.Font, TextSize = 13, TextXAlignment = "Left", BackgroundTransparency = 1})
    
    -- Arrow Minimize Button
    local MinBtn = create("TextLabel", {
        Parent = Header, 
        Size = UDim2.fromOffset(35, 35), 
        Position = UDim2.new(1, -45, 0, 5), 
        BackgroundTransparency = 1, 
        Text = "▼", 
        TextColor3 = Theme.Text, 
        Font = Enum.Font.GothamBold, 
        TextSize = 14
    })
    local MinClick = create("TextButton", {Parent = MinBtn, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = ""})

    -- The Resizer Handle (Expander)
    local ResizeHandle = create("TextLabel", {
        Parent = Main,
        Size = UDim2.fromOffset(20, 20),
        Position = UDim2.new(1, -20, 1, -20),
        BackgroundTransparency = 1,
        Text = "◢",
        TextColor3 = Theme.Text,
        TextTransparency = 0.5,
        TextSize = 18,
        ZIndex = 5
    })
    local ResizeClick = create("TextButton", {Parent = ResizeHandle, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = ""})

    local Sidebar = create("ScrollingFrame", {Parent = Main, Size = UDim2.new(0, 150, 1, -60), Position = UDim2.fromOffset(10, 50), BackgroundColor3 = Theme.Dark, BackgroundTransparency = 0.4, CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = "Y", ScrollBarThickness = 0})
    create("UICorner", {Parent = Sidebar, CornerRadius = UDim.new(0, 8)})
    create("UIListLayout", {Parent = Sidebar, Padding = UDim.new(0, 5)})
    create("UIPadding", {Parent = Sidebar, PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), PaddingTop = UDim.new(0, 8)})

    local Container = create("Frame", {
        Parent = Main, 
        Size = UDim2.new(1, -180, 1, -60), 
        Position = UDim2.fromOffset(170, 50), 
        BackgroundTransparency = 0.8, -- Subtle background for clarity
        BackgroundColor3 = Color3.new(0,0,0)
    })
    create("UICorner", {Parent = Container, CornerRadius = UDim.new(0, 8)})

    -- Dragging Logic
    local d, s, st
    Header.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d, st, s = true, i.Position, Main.Position end end)
    UIS.InputChanged:Connect(function(i) if d and i.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = i.Position - st
        Main.Position = UDim2.new(s.X.Scale, s.X.Offset + delta.X, s.Y.Scale, s.Y.Offset + delta.Y)
    end end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d = false end end)

    -- Resizing Logic
    local rd, rs, rst
    ResizeClick.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then rd, rst, rs = true, i.Position, Main.Size end end)
    UIS.InputChanged:Connect(function(i) if rd and i.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = i.Position - rst
        Main.Size = UDim2.new(0, math.max(400, rs.X.Offset + delta.X), 0, math.max(200, rs.Y.Offset + delta.Y))
    end end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then rd = false end end)

    -- Minimize Logic (Fixed ghosting)
    local minimized, oldSize = false, Main.Size
    MinClick.MouseButton1Click:Connect(function()
        minimized = not minimized
        tween(MinBtn, 0.3, {Rotation = minimized and -90 or 0})
        
        if minimized then
            oldSize = Main.Size
            Sidebar.Visible = false
            Container.Visible = false
            ResizeHandle.Visible = false
            tween(Main, 0.4, {Size = UDim2.fromOffset(Main.Size.X.Offset, 45)})
        else
            local t = tween(Main, 0.4, {Size = oldSize})
            t.Completed:Wait()
            if not minimized then
                Sidebar.Visible = true
                Container.Visible = true
                ResizeHandle.Visible = true
            end
        end
    end)

    local API = { FirstPage = nil }
    
    function API:Category(name)
        local Page = create("ScrollingFrame", {Parent = Container, Size = UDim2.new(1, -10, 1, -10), Position = UDim2.fromOffset(5,5), Visible = false, BackgroundTransparency = 1, CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = "Y", ScrollBarThickness = 2})
        create("UIListLayout", {Parent = Page, Padding = UDim.new(0, 8)})
        
        local TabBtn = create("TextButton", {Parent = Sidebar, Size = UDim2.new(1, 0, 0, 35), BackgroundColor3 = Theme.Accent, BackgroundTransparency = 1, Text = name, Font = Theme.Font, TextSize = 12, TextColor3 = Color3.fromRGB(150, 150, 150)})
        create("UICorner", {Parent = TabBtn, CornerRadius = UDim.new(0, 6)})

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(Container:GetChildren()) do if v:IsA("ScrollingFrame") then v.Visible = false end end
            for _, v in pairs(Sidebar:GetChildren()) do if v:IsA("TextButton") then tween(v, 0.3, {BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(150,150,150)}) end end
            Page.Visible = true
            tween(TabBtn, 0.3, {BackgroundTransparency = 0.85, TextColor3 = Theme.Text})
        end)
        
        if not API.FirstPage then API.FirstPage = Page; Page.Visible = true; tween(TabBtn, 0, {BackgroundTransparency = 0.85, TextColor3 = Theme.Text}) end

        local function AddToggle(parent, txt, cb)
            local enabled = false
            local b = create("TextButton", {Parent = parent, Size = UDim2.new(1, -5, 0, 35), BackgroundColor3 = Theme.Dark, BackgroundTransparency = 0.6, Text = "  "..txt, Font = Theme.Font, TextSize = 12, TextColor3 = Theme.Text, TextXAlignment = "Left"})
            create("UICorner", {Parent = b, CornerRadius = UDim.new(0, 6)})
            
            local box = create("Frame", {Parent = b, Size = UDim2.fromOffset(34, 18), Position = UDim2.new(1, -45, 0.5, -9), BackgroundColor3 = Color3.fromRGB(30, 30, 30)})
            create("UICorner", {Parent = box, CornerRadius = UDim.new(1, 0)})
            local dot = create("Frame", {Parent = box, Size = UDim2.fromOffset(12, 12), Position = UDim2.new(0, 3, 0.5, -6), BackgroundColor3 = Color3.new(200,200,200)})
            create("UICorner", {Parent = dot, CornerRadius = UDim.new(1, 0)})

            b.MouseButton1Click:Connect(function()
                enabled = not enabled
                tween(dot, 0.3, {Position = enabled and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6), BackgroundColor3 = enabled and Color3.new(0,0,0) or Color3.new(1,1,1)})
                tween(box, 0.3, {BackgroundColor3 = enabled and Theme.Accent or Color3.fromRGB(30, 30, 30)})
                cb(enabled)
            end)
        end

        local Entry = {}
        function Entry:Toggle(txt, cb) AddToggle(Page, txt, cb) end
        function Entry:Button(txt, cb)
            local b = create("TextButton", {Parent = Page, Size = UDim2.new(1, -5, 0, 35), BackgroundColor3 = Theme.Dark, BackgroundTransparency = 0.6, Text = txt, Font = Theme.Font, TextSize = 12, TextColor3 = Theme.Text})
            create("UICorner", {Parent = b, CornerRadius = UDim.new(0, 6)})
            b.MouseButton1Click:Connect(cb)
        end
        function Entry:Slider(txt, min, max, def, cb)
            local SFrame = create("Frame", {Parent = Page, Size = UDim2.new(1, -5, 0, 50), BackgroundTransparency = 1})
            local lab = create("TextLabel", {Parent = SFrame, Text = txt.." • "..def, Size = UDim2.new(1,0,0,20), BackgroundTransparency = 1, TextColor3 = Theme.Text, Font = Theme.Font, TextSize = 11, TextXAlignment = "Left"})
            local bar = create("Frame", {Parent = SFrame, Size = UDim2.new(1, 0, 0, 6), Position = UDim2.new(0,0,0,30), BackgroundColor3 = Theme.Dark, BackgroundTransparency = 0.5})
            create("UICorner", {Parent = bar})
            local fill = create("Frame", {Parent = bar, Size = UDim2.new((def-min)/(max-min), 0, 1, 0), BackgroundColor3 = Theme.Accent})
            create("UICorner", {Parent = fill})
            local sliding = false
            local function update()
                local p = math.clamp((UIS:GetMouseLocation().X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                local val = math.floor(min + (max-min) * p)
                tween(fill, 0.15, {Size = UDim2.new(p, 0, 1, 0)})
                lab.Text = txt.." • "..val
                cb(val)
            end
            bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding = true update() end end)
            UIS.InputChanged:Connect(function(i) if sliding and i.UserInputType == Enum.UserInputType.MouseMovement then update() end end)
            UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end end)
        end
        function Entry:Folder(name)
            local expanded = false
            local FMain = create("Frame", {Parent = Page, Size = UDim2.new(1, -5, 0, 35), BackgroundColor3 = Theme.Dark, BackgroundTransparency = 0.75, ClipsDescendants = true})
            create("UICorner", {Parent = FMain, CornerRadius = UDim.new(0, 6)})
            local FLayout = create("UIListLayout", {Parent = FMain, Padding = UDim.new(0, 5)})
            local HeaderBtn = create("TextButton", {Parent = FMain, Size = UDim2.new(1, 0, 0, 35), Text = "  ▼ "..name, Font = Theme.Font, TextSize = 12, TextColor3 = Theme.Text, BackgroundTransparency = 1, TextXAlignment = "Left"})
            local ContentFrame = create("Frame", {Parent = FMain, Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, AutomaticSize = "Y"})
            create("UIListLayout", {Parent = ContentFrame, Padding = UDim.new(0, 5)})
            create("UIPadding", {Parent = ContentFrame, PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10)})
            HeaderBtn.MouseButton1Click:Connect(function()
                expanded = not expanded
                HeaderBtn.Text = expanded and "  ▲ "..name or "  ▼ "..name
                tween(FMain, 0.4, {Size = expanded and UDim2.new(1, -5, 0, ContentFrame.AbsoluteSize.Y + 45) or UDim2.new(1, -5, 0, 35)})
            end)
            local FolderAPI = {}
            function FolderAPI:Button(t, c) 
                local b = create("TextButton", {Parent = ContentFrame, Size = UDim2.new(1,0,0,30), BackgroundColor3 = Theme.Accent, BackgroundTransparency = 0.9, Text = t, Font = Theme.Font, TextColor3 = Theme.Text, TextSize = 11})
                create("UICorner", {Parent = b, CornerRadius = UDim.new(0, 4)})
                b.MouseButton1Click:Connect(c)
            end
            function FolderAPI:Toggle(t, c) AddToggle(ContentFrame, t, c) end
            return FolderAPI
        end
        return Entry
    end
    return API
end

return Lib
