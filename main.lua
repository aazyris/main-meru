--// Depso Classic: Hub Edition
local Lib = { Windows = {} }

local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local Theme = {
    Main = Color3.fromRGB(20, 20, 25),
    Dark = Color3.fromRGB(15, 15, 20),
    Accent = Color3.fromRGB(80, 80, 90),
    Text = Color3.fromRGB(255, 255, 255),
    Font = Enum.Font.Code
}

local function create(class, props)
    local inst = Instance.new(class)
    for i, v in next, props do inst[i] = v end
    return inst
end

--// Drag & Resize Logic
local function makeDrag(f, h)
    local d, s, st
    h.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d, st, s = true, i.Position, f.Position end end)
    UIS.InputChanged:Connect(function(i)
        if d and i.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = i.Position - st
            TS:Create(f, TweenInfo.new(0.1), {Position = UDim2.new(s.X.Scale, s.X.Offset + delta.X, s.Y.Scale, s.Y.Offset + delta.Y)}):Play()
        end
    end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d = false end end)
end

local function makeResize(f, h)
    local d, s, st
    h.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d, st, s = true, i.Position, f.Size end end)
    UIS.InputChanged:Connect(function(i)
        if d and i.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = i.Position - st
            f.Size = UDim2.new(0, math.max(350, s.X.Offset + delta.X), 0, math.max(200, s.Y.Offset + delta.Y))
        end
    end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then d = false end end)
end

function Lib:CreateWindow(title)
    local Screen = create("ScreenGui", {Parent = CoreGui, Name = "DepsoHub"})
    local Main = create("Frame", {Parent = Screen, Size = UDim2.fromOffset(450, 300), Position = UDim2.fromOffset(100, 100), BackgroundColor3 = Theme.Main, BackgroundTransparency = 0.2, ClipsDescendants = true})
    create("UIStroke", {Parent = Main, Color = Color3.new(1,1,1), Transparency = 0.8})

    -- Header
    local Header = create("Frame", {Parent = Main, Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = Theme.Dark, BackgroundTransparency = 0.5})
    create("TextLabel", {Parent = Header, Text = "  " .. title:upper(), Size = UDim2.new(1, -60, 1, 0), TextColor3 = Theme.Text, Font = Theme.Font, TextXAlignment = "Left", BackgroundTransparency = 1})
    
    -- Minimize Button
    local MinBtn = create("TextButton", {Parent = Header, Text = "▼", Size = UDim2.fromOffset(30, 30), Position = UDim2.new(1, -30, 0, 0), BackgroundTransparency = 1, TextColor3 = Theme.Text})
    
    -- Resize Handle
    local RSZ = create("TextButton", {Parent = Main, Text = "◢", Size = UDim2.fromOffset(15, 15), Position = UDim2.new(1, -15, 1, -15), BackgroundTransparency = 1, TextColor3 = Theme.Text, TextTransparency = 0.5})

    -- Sidebar (Categories)
    local Sidebar = create("ScrollingFrame", {Parent = Main, Size = UDim2.new(0, 120, 1, -30), Position = UDim2.fromOffset(0, 30), BackgroundColor3 = Theme.Dark, BackgroundTransparency = 0.5, CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = "Y", ScrollBarThickness = 0})
    create("UIListLayout", {Parent = Sidebar, Padding = UDim.new(0, 2)})

    -- Container for Pages
    local Container = create("Frame", {Parent = Main, Size = UDim2.new(1, -130, 1, -40), Position = UDim2.fromOffset(125, 35), BackgroundTransparency = 1})

    makeDrag(Main, Header)
    makeResize(Main, RSZ)

    -- Min Logic
    local min = false
    local oldS = Main.Size
    MinBtn.MouseButton1Click:Connect(function()
        min = not min
        if min then oldS = Main.Size end
        TS:Create(Main, TweenInfo.new(0.2), {Size = min and UDim2.fromOffset(Main.Size.X.Offset, 30) or oldS}):Play()
        MinBtn.Text = min and "▲" or "▼"
    end)

    local Tabs = { First = nil }
    local API = {}

    function API:Category(name)
        local Page = create("ScrollingFrame", {Parent = Container, Size = UDim2.new(1, 0, 1, 0), Visible = false, BackgroundTransparency = 1, CanvasSize = UDim2.new(0,0,0,0), AutomaticCanvasSize = "Y", ScrollBarThickness = 2})
        create("UIListLayout", {Parent = Page, Padding = UDim.new(0, 5)})
        
        local TabBtn = create("TextButton", {Parent = Sidebar, Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 0.8, BackgroundColor3 = Theme.Accent, Text = name, Font = Theme.Font, TextColor3 = Theme.Text})
        
        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(Container:GetChildren()) do v.Visible = false end
            Page.Visible = true
        end)

        if not Tabs.First then Tabs.First = Page; Page.Visible = true end

        local Entry = {}
        function Entry:Button(txt, cb)
            create("TextButton", {Parent = Page, Size = UDim2.new(1, -5, 0, 25), BackgroundColor3 = Theme.Accent, BackgroundTransparency = 0.7, Text = txt, Font = Theme.Font, TextColor3 = Theme.Text}).MouseButton1Click:Connect(cb)
        end
        function Entry:Checkbox(txt, cb)
            local enabled = false
            local b = create("TextButton", {Parent = Page, Size = UDim2.new(1, -5, 0, 25), BackgroundColor3 = Theme.Accent, BackgroundTransparency = 0.8, Text = "[ ] "..txt, Font = Theme.Font, TextColor3 = Theme.Text, TextXAlignment = "Left"})
            b.MouseButton1Click:Connect(function()
                enabled = not enabled
                b.Text = enabled and "[X] "..txt or "[ ] "..txt
                b.BackgroundTransparency = enabled and 0.5 or 0.8
                cb(enabled)
            end)
        end
        return Entry
    end
    return API
end

return Lib
