--// Depso ImGui Overhaul: B&W Edition
--// Refactored for modularity and performance

local ImGui = {
    Animations = {
        Buttons = {
            MouseEnter = { BackgroundTransparency = 0.5 },
            MouseLeave = { BackgroundTransparency = 0.7 } 
        },
        Tabs = {
            MouseEnter = { BackgroundTransparency = 0.5 },
            MouseLeave = { BackgroundTransparency = 1 } 
        }
    },
    Windows = {},
    Animation = TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    UIAssetId = "rbxassetid://76246418997296",
    Theme = {
        Main = Color3.fromRGB(0, 0, 0),
        Accent = Color3.fromRGB(255, 255, 255),
        Opacity = 0.3
    }
}

--// Services
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

function ImGui:Tween(obj, goal, info)
    local t = TS:Create(obj, info or self.Animation, goal)
    t:Play()
    return t
end

--// Window Creation
function ImGui:CreateWindow(title)
    local Screen = Instance.new("ScreenGui", CoreGui)
    Screen.Name = "DepsoImGui_Window"
    
    local Main = Instance.new("Frame", Screen)
    Main.Size = UDim2.fromOffset(550, 400)
    Main.Position = UDim2.fromOffset(100, 100)
    Main.BackgroundColor3 = self.Theme.Main
    Main.BackgroundTransparency = self.Theme.Opacity
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
    local Stroke = Instance.new("UIStroke", Main)
    Stroke.Color = self.Theme.Accent
    Stroke.Transparency = 0.7
    
    -- Header
    local Header = Instance.new("Frame", Main)
    Header.Size = UDim2.new(1, 0, 0, 40)
    Header.BackgroundTransparency = 1
    
    local Title = Instance.new("TextLabel", Header)
    Title.Text = title:upper()
    Title.Size = UDim2.new(1, -80, 1, 0)
    Title.Position = UDim2.fromOffset(15, 0)
    Title.TextColor3 = self.Theme.Accent
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 13
    Title.TextXAlignment = "Left"
    Title.BackgroundTransparency = 1

    -- Minimize Arrow
    local MinBtn = Instance.new("TextButton", Header)
    MinBtn.Size = UDim2.fromOffset(35, 35)
    MinBtn.Position = UDim2.new(1, -45, 0, 2)
    MinBtn.BackgroundTransparency = 1
    MinBtn.Text = "▼"
    MinBtn.TextColor3 = self.Theme.Accent
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.TextSize = 12

    -- Resize Handle
    local ResizeBtn = Instance.new("TextButton", Main)
    ResizeBtn.Size = UDim2.fromOffset(20, 20)
    ResizeBtn.Position = UDim2.new(1, -20, 1, -20)
    ResizeBtn.BackgroundTransparency = 1
    ResizeBtn.Text = "◢"
    ResizeBtn.TextColor3 = self.Theme.Accent
    ResizeBtn.TextSize = 18
    ResizeBtn.ZIndex = 10

    -- Layout
    local Content = Instance.new("Frame", Main)
    Content.Size = UDim2.new(1, 0, 1, -40)
    Content.Position = UDim2.fromOffset(0, 40)
    Content.BackgroundTransparency = 1

    local Sidebar = Instance.new("ScrollingFrame", Content)
    Sidebar.Size = UDim2.new(0, 140, 1, -20)
    Sidebar.Position = UDim2.fromOffset(10, 5)
    Sidebar.BackgroundTransparency = 0.6
    Sidebar.BackgroundColor3 = Color3.new(0,0,0)
    Sidebar.BorderSizePixel = 0
    Sidebar.ScrollBarThickness = 0
    Instance.new("UIListLayout", Sidebar).Padding = UDim.new(0, 4)
    Instance.new("UICorner", Sidebar)

    local Container = Instance.new("Frame", Content)
    Container.Size = UDim2.new(1, -170, 1, -20)
    Container.Position = UDim2.fromOffset(160, 5)
    Container.BackgroundTransparency = 0.8
    Container.BackgroundColor3 = Color3.new(0,0,0)
    Instance.new("UICorner", Container)

    --// Dragging & Resizing Logic (Standard ImGui implementation)
    local function makeDraggable()
        local dragInput, dragStart, startPos
        Header.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragStart = input.Position
                startPos = Main.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then dragStart = nil end
                end)
            end
        end)
        UIS.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement and dragStart then
                local delta = input.Position - dragStart
                Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
    end
    makeDraggable()

    local resizing = false
    ResizeBtn.MouseButton1Down:Connect(function() resizing = true end)
    UIS.InputChanged:Connect(function(input)
        if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mouse = UIS:GetMouseLocation()
            Main.Size = UDim2.fromOffset(math.max(mouse.X - Main.AbsolutePosition.X, 400), math.max(mouse.Y - Main.AbsolutePosition.Y, 250))
        end
    end)
    UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then resizing = false end end)

    local API = { FirstTab = nil }

    function API:Category(name)
        local Page = Instance.new("ScrollingFrame", Container)
        Page.Size = UDim2.new(1, -10, 1, -10)
        Page.Position = UDim2.fromOffset(5, 5)
        Page.BackgroundTransparency = 1
        Page.Visible = false
        Page.ScrollBarThickness = 2
        Page.ScrollBarImageColor3 = self.Theme.Accent
        Instance.new("UIListLayout", Page).Padding = UDim.new(0, 6)

        local TabBtn = Instance.new("TextButton", Sidebar)
        TabBtn.Size = UDim2.new(1, -10, 0, 30)
        TabBtn.BackgroundColor3 = self.Theme.Accent
        TabBtn.BackgroundTransparency = 1
        TabBtn.Text = name
        TabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
        TabBtn.Font = Enum.Font.GothamMedium
        TabBtn.TextSize = 11
        Instance.new("UICorner", TabBtn)

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(Container:GetChildren()) do if v:IsA("ScrollingFrame") then v.Visible = false end end
            for _, v in pairs(Sidebar:GetChildren()) do if v:IsA("TextButton") then 
                ImGui:Tween(v, {BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(150,150,150)}) 
            end end
            Page.Visible = true
            ImGui:Tween(TabBtn, {BackgroundTransparency = 0.8, TextColor3 = Color3.new(1,1,1)})
        end)

        if not API.FirstTab then API.FirstTab = Page; Page.Visible = true; TabBtn.BackgroundTransparency = 0.8; TabBtn.TextColor3 = Color3.new(1,1,1) end

        local Elements = {}

        function Elements:Button(txt, callback)
            local b = Instance.new("TextButton", Page)
            b.Size = UDim2.new(1, -5, 0, 32)
            b.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
            b.BackgroundTransparency = 0.5
            b.Text = txt
            b.TextColor3 = Color3.new(1,1,1)
            b.Font = Enum.Font.Gotham
            b.TextSize = 12
            Instance.new("UICorner", b)
            b.MouseButton1Click:Connect(callback)
            return b
        end

        function Elements:Toggle(txt, callback)
            local state = false
            local t = Instance.new("TextButton", Page)
            t.Size = UDim2.new(1, -5, 0, 32)
            t.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
            t.BackgroundTransparency = 0.5
            t.Text = "  " .. txt
            t.TextColor3 = Color3.new(1,1,1)
            t.Font = Enum.Font.Gotham
            t.TextSize = 12
            t.TextXAlignment = "Left"
            Instance.new("UICorner", t)

            local box = Instance.new("Frame", t)
            box.Size = UDim2.fromOffset(30, 16)
            box.Position = UDim2.new(1, -40, 0.5, -8)
            box.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
            Instance.new("UICorner", box).CornerRadius = UDim.new(1, 0)

            local dot = Instance.new("Frame", box)
            dot.Size = UDim2.fromOffset(10, 10)
            dot.Position = UDim2.new(0, 3, 0.5, -5)
            dot.BackgroundColor3 = Color3.new(1,1,1)
            Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

            t.MouseButton1Click:Connect(function()
                state = not state
                ImGui:Tween(dot, {Position = state and UDim2.new(1, -13, 0.5, -5) or UDim2.new(0, 3, 0.5, -5)})
                ImGui:Tween(box, {BackgroundColor3 = state and Color3.new(1,1,1) or Color3.new(0.2, 0.2, 0.2)})
                ImGui:Tween(dot, {BackgroundColor3 = state and Color3.new(0,0,0) or Color3.new(1,1,1)})
                callback(state)
            end)
        end

        function Elements:Slider(txt, min, max, def, callback)
            local sframe = Instance.new("Frame", Page)
            sframe.Size = UDim2.new(1, -5, 0, 40)
            sframe.BackgroundTransparency = 1
            
            local label = Instance.new("TextLabel", sframe)
            label.Text = txt .. " : " .. def
            label.Size = UDim2.new(1, 0, 0, 15)
            label.BackgroundTransparency = 1
            label.TextColor3 = Color3.new(1,1,1)
            label.Font = Enum.Font.Gotham
            label.TextSize = 11
            label.TextXAlignment = "Left"

            local bar = Instance.new("Frame", sframe)
            bar.Size = UDim2.new(1, 0, 0, 4)
            bar.Position = UDim2.new(0, 0, 0, 25)
            bar.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
            
            local fill = Instance.new("Frame", bar)
            fill.Size = UDim2.new((def-min)/(max-min), 0, 1, 0)
            fill.BackgroundColor3 = Color3.new(1,1,1)

            local sliding = false
            local function update()
                local input = UIS:GetMouseLocation()
                local percent = math.clamp((input.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                local val = math.floor(min + (max-min) * percent)
                fill.Size = UDim2.new(percent, 0, 1, 0)
                label.Text = txt .. " : " .. val
                callback(val)
            end

            bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding = true update() end end)
            UIS.InputChanged:Connect(function(i) if sliding and i.UserInputType == Enum.UserInputType.MouseMovement then update() end end)
            UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end end)
        end

        return Elements
    end

    return API
end

return ImGui
