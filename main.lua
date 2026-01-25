--// Depso Modern: Translucent Hub Edition
local Lib = { Windows = {} }

local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local Theme = {
    Main = Color3.fromRGB(20, 20, 25),
    Dark = Color3.fromRGB(15, 15, 20),
    Accent = Color3.fromRGB(100, 100, 120), -- Lighter slate glow
    Text = Color3.fromRGB(255, 255, 255),
    Font = Enum.Font.GothamMedium
}

local function create(class, props)
    local inst = Instance.new(class)
    for i, v in next, props do inst[i] = v end
    return inst
end

local function tween(obj, info, goal)
    TS:Create(obj, TweenInfo.new(info, Enum.EasingStyle.Sine), goal):Play()
end

local function makeDrag(f, h)
    local d, s, st
    h.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d, st, s = true, i.Position, f.Position end end)
    UIS.InputChanged:Connect(function(i)
        if d and i.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = i.Position - st
            tween(f, 0.1, {Position = UDim2.new(s.X.Scale, s.X.Offset + delta.X, s.Y.Scale, s.Y.Offset + delta.Y)})
        end
    end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d = false end end)
end

function Lib:CreateWindow(title)
    local Screen = create("ScreenGui", {Parent = CoreGui, Name = "DepsoHub"})
    local Main = create("Frame", {Parent = Screen, Size = UDim2.fromOffset(500, 350), Position = UDim2.fromOffset(100, 100), BackgroundColor3 = Theme.Main, BackgroundTransparency = 0.15})
    create("UICorner", {Parent = Main, CornerRadius = UDim.new(0, 8)})
    create("UIStroke", {Parent = Main, Color = Color3.new(1,1,1), Transparency = 0.85})

    local Header = create("Frame", {Parent = Main, Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1})
    local Title = create("TextLabel", {Parent = Header, Text = title:upper(), Size = UDim2.new(1, -60, 1, 0), Position = UDim2.fromOffset(15, 0), TextColor3 = Theme.Text, Font = Theme.Font, TextSize = 14, TextXAlignment = "Left", BackgroundTransparency = 1})
    
    local MinBtn = create("TextButton", {Parent = Header, Text = "—", Size = UDim2.fromOffset(40, 40), Position = UDim2.new(1, -40, 0, 0), BackgroundTransparency = 1, TextColor3 = Theme.Text, Font = Enum.Font.GothamBold})
    
    local Sidebar = create("ScrollingFrame", {Parent = Main, Size = UDim2.new(0, 140, 1, -50), Position = UDim2.fromOffset(10, 45), BackgroundColor3 = Theme.Dark, BackgroundTransparency = 0.4, CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = "Y", ScrollBarThickness = 0})
    create("UICorner", {Parent = Sidebar, CornerRadius = UDim.new(0, 6)})
    create("UIListLayout", {Parent = Sidebar, Padding = UDim.new(0, 4)})
    create("UIPadding", {Parent = Sidebar, PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 5), PaddingTop = UDim.new(0, 5)})

    local Container = create("Frame", {Parent = Main, Size = UDim2.new(1, -170, 1, -55), Position = UDim2.fromOffset(160, 45), BackgroundTransparency = 1})

    makeDrag(Main, Header)

    local min, oldS = false, Main.Size
    MinBtn.MouseButton1Click:Connect(function()
        min = not min
        tween(Main, 0.3, {Size = min and UDim2.fromOffset(Main.Size.X.Offset, 40) or oldS})
        Sidebar.Visible, Container.Visible = not min, not min
    end)

    local Tabs = { First = nil }
    local API = {}

    function API:Category(name)
        local Page = create("ScrollingFrame", {Parent = Container, Size = UDim2.new(1, 0, 1, 0), Visible = false, BackgroundTransparency = 1, CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = "Y", ScrollBarThickness = 2})
        create("UIListLayout", {Parent = Page, Padding = UDim.new(0, 6)})
        
        local TabBtn = create("TextButton", {Parent = Sidebar, Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = Theme.Accent, BackgroundTransparency = 1, Text = name, Font = Theme.Font, TextSize = 13, TextColor3 = Color3.fromRGB(180, 180, 180)})
        create("UICorner", {Parent = TabBtn, CornerRadius = UDim.new(0, 4)})

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(Container:GetChildren()) do if v:IsA("ScrollingFrame") then v.Visible = false end end
            for _, v in pairs(Sidebar:GetChildren()) do if v:IsA("TextButton") then tween(v, 0.2, {BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(180,180,180)}) end end
            Page.Visible = true
            tween(TabBtn, 0.2, {BackgroundTransparency = 0.6, TextColor3 = Theme.Text})
        end)

        if not Tabs.First then Tabs.First = Page; Page.Visible = true; tween(TabBtn, 0, {BackgroundTransparency = 0.6, TextColor3 = Theme.Text}) end

        local Entry = {}
        function Entry:Button(txt, cb)
            local b = create("TextButton", {Parent = Page, Size = UDim2.new(1, -10, 0, 30), BackgroundColor3 = Theme.Accent, BackgroundTransparency = 0.8, Text = txt, Font = Theme.Font, TextSize = 12, TextColor3 = Theme.Text})
            create("UICorner", {Parent = b, CornerRadius = UDim.new(0, 4)})
            b.MouseEnter:Connect(function() tween(b, 0.2, {BackgroundTransparency = 0.6}) end)
            b.MouseLeave:Connect(function() tween(b, 0.2, {BackgroundTransparency = 0.8}) end)
            b.MouseButton1Click:Connect(cb)
        end

        function Entry:Checkbox(txt, cb)
            local enabled = false
            local b = create("TextButton", {Parent = Page, Size = UDim2.new(1, -10, 0, 30), BackgroundColor3 = Theme.Accent, BackgroundTransparency = 0.8, Text = "  " .. txt, Font = Theme.Font, TextSize = 12, TextColor3 = Theme.Text, TextXAlignment = "Left"})
            local indicator = create("Frame", {Parent = b, Size = UDim2.fromOffset(16, 16), Position = UDim2.new(1, -25, 0.5, -8), BackgroundColor3 = Color3.new(0,0,0), BackgroundTransparency = 0.5})
            create("UICorner", {Parent = b, CornerRadius = UDim.new(0, 4)})
            create("UICorner", {Parent = indicator, CornerRadius = UDim.new(0, 4)})

            b.MouseButton1Click:Connect(function()
                enabled = not enabled
                tween(indicator, 0.2, {BackgroundColor3 = enabled and Color3.fromRGB(100, 255, 100) or Color3.new(0,0,0)})
                cb(enabled)
            end)
        end

        function Entry:Slider(txt, min, max, def, cb)
            local SFrame = create("Frame", {Parent = Page, Size = UDim2.new(1, -10, 0, 45), BackgroundTransparency = 1})
            local lab = create("TextLabel", {Parent = SFrame, Text = txt.." : "..def, Size = UDim2.new(1,0,0,20), BackgroundTransparency = 1, TextColor3 = Theme.Text, Font = Theme.Font, TextSize = 12, TextXAlignment = "Left"})
            local bar = create("Frame", {Parent = SFrame, Size = UDim2.new(1, 0, 0, 6), Position = UDim2.new(0,0,0,28), BackgroundColor3 = Theme.Dark})
            local fill = create("Frame", {Parent = bar, Size = UDim2.new((def-min)/(max-min), 0, 1, 0), BackgroundColor3 = Theme.Accent})
            create("UICorner", {Parent = bar, CornerRadius = UDim.new(1, 0)})
            create("UICorner", {Parent = fill, CornerRadius = UDim.new(1, 0)})
            
            local sliding = false
            local function update()
                local p = math.clamp((UIS:GetMouseLocation().X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                local val = math.floor(min + (max-min) * p)
                tween(fill, 0.1, {Size = UDim2.new(p, 0, 1, 0)})
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
