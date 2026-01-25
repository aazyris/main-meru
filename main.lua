--// Meru Hub UI Library (inspired by ImGui)
--// MIT License
local Lib = { Windows = {} }

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Theme = {
    Main = Color3.fromRGB(0, 0, 0),       -- Pure Black
    Accent = Color3.fromRGB(255, 255, 255), -- Pure White
    Text = Color3.fromRGB(255, 255, 255),
    MutedText = Color3.fromRGB(180, 180, 180),
    Soft = Color3.fromRGB(18, 18, 18),
    Stroke = Color3.fromRGB(255, 255, 255),
    Font = Enum.Font.GothamBold,
    Opacity = 0.3 -- Backplate transparency
}

local function create(class, props)
    local inst = Instance.new(class)
    for i, v in next, props do inst[i] = v end
    return inst
end

local function tween(obj, info, goal)
    local t = TweenService:Create(obj, TweenInfo.new(info, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), goal)
    t:Play()
    return t
end

local function isFn(x)
    return type(x) == "function"
end

local Animations = {
    Buttons = {
        MouseEnter = { BackgroundTransparency = 0.5 },
        MouseLeave = { BackgroundTransparency = 0.7 },
    },
    Tabs = {
        MouseEnter = { BackgroundTransparency = 0.5 },
        MouseLeave = { BackgroundTransparency = 1 },
    },
    Inputs = {
        MouseEnter = { BackgroundTransparency = 0 },
        MouseLeave = { BackgroundTransparency = 0.5 },
    },
    WindowBorder = {
        Selected = { Transparency = 0, Thickness = 1.5 },
        Deselected = { Transparency = 0.7, Thickness = 1.5 },
    }
}

local function applyAnimations(guiObject, className)
    local cfg = Animations[className]
    if not cfg then return end
    if cfg.MouseEnter then
        guiObject.MouseEnter:Connect(function()
            tween(guiObject, 0.1, cfg.MouseEnter)
        end)
    end
    if cfg.MouseLeave then
        guiObject.MouseLeave:Connect(function()
            tween(guiObject, 0.1, cfg.MouseLeave)
        end)
        tween(guiObject, 0, cfg.MouseLeave)
    end
end

function Lib:CreateWindow(title)
    local player = Players.LocalPlayer
    local playerGui = player and player:FindFirstChildOfClass("PlayerGui")
    if not playerGui and player then
        playerGui = player:WaitForChild("PlayerGui")
    end
    if not playerGui then
        error("Lib:CreateWindow must be called from a LocalScript (PlayerGui not found)")
    end

    local existing = playerGui:FindFirstChild("MeruHub")
    if existing then
        existing:Destroy()
    end

    local Screen = create("ScreenGui", {Parent = playerGui, Name = "MeruHub", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling})
    Screen.IgnoreGuiInset = true

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
    local MainStroke = create("UIStroke", {Parent = Main, Color = Theme.Accent, Transparency = 0.7, Thickness = 1.5})

    -- Header (Drag Area)
    local Header = create("Frame", {Parent = Main, Size = UDim2.new(1, 0, 0, 45), BackgroundTransparency = 1})
    create("TextLabel", {Parent = Header, Text = title:upper(), Size = UDim2.new(1, -100, 1, 0), Position = UDim2.fromOffset(15, 0), TextColor3 = Theme.Text, Font = Theme.Font, TextSize = 14, TextXAlignment = "Left", BackgroundTransparency = 1})

    -- Minimize Arrow
    local MinBtn = create("TextLabel", {Parent = Header, Size = UDim2.fromOffset(35, 35), Position = UDim2.new(1, -45, 0, 5), BackgroundTransparency = 1, Text = "▼", TextColor3 = Theme.Text, Font = Enum.Font.GothamBold, TextSize = 14})
    local MinClick = create("TextButton", {Parent = MinBtn, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = ""})

    local CloseBtn = create("TextLabel", {Parent = Header, Size = UDim2.fromOffset(35, 35), Position = UDim2.new(1, -80, 0, 5), BackgroundTransparency = 1, Text = "×", TextColor3 = Theme.Text, Font = Enum.Font.GothamBold, TextSize = 18})
    local CloseClick = create("TextButton", {Parent = CloseBtn, Size = UDim2.new(1,0,1,0), BackgroundTransparency = 1, Text = ""})

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

    -- Window select border effect (ImGui-style)
    Main.MouseEnter:Connect(function()
        tween(MainStroke, 0.1, Animations.WindowBorder.Selected)
    end)
    Main.MouseLeave:Connect(function()
        tween(MainStroke, 0.1, Animations.WindowBorder.Deselected)
    end)

    -- Resizing Script
    local resizing = false
    ResizeClick.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then resizing = true end end)
    UserInputService.InputChanged:Connect(function(i) 
        if resizing and i.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = UserInputService:GetMouseLocation()
            local newX = math.clamp(mousePos.X - Main.AbsolutePosition.X, 400, 800)
            local newY = math.clamp(mousePos.Y - Main.AbsolutePosition.Y, 250, 600)
            Main.Size = UDim2.fromOffset(newX, newY)
        end
    end)
    CloseClick.MouseButton1Click:Connect(function()
        Screen:Destroy()
    end)

    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then resizing = false end end)

    -- Dragging Script
    local dragging, dragStart, startPos
    Header.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true dragStart = i.Position startPos = Main.Position end end)
    UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = i.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

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

        local TabBtn = create("TextButton", {Parent = Sidebar, Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = Theme.Soft, BackgroundTransparency = 0.5, Text = name, Font = Theme.Font, TextSize = 12, TextColor3 = Theme.MutedText})
        create("UICorner", {Parent = TabBtn, CornerRadius = UDim.new(0, 6)})
        create("UIStroke", {Parent = TabBtn, Color = Theme.Stroke, Transparency = 0.85, Thickness = 1})
        applyAnimations(TabBtn, "Buttons")

        TabBtn.MouseButton1Click:Connect(function()
            for _, v in pairs(Container:GetChildren()) do if v:IsA("ScrollingFrame") then v.Visible = false end end
            for _, v in pairs(Sidebar:GetChildren()) do if v:IsA("TextButton") then tween(v, 0.2, {BackgroundTransparency = 0.5, TextColor3 = Theme.MutedText}) end end
            Page.Visible = true
            tween(TabBtn, 0.2, {BackgroundTransparency = 0.2, TextColor3 = Theme.Text})
        end)

        if not API.FirstPage then API.FirstPage = Page; Page.Visible = true; tween(TabBtn, 0, {BackgroundTransparency = 0.2, TextColor3 = Theme.Text}) end

        local Entry = {}
        function Entry:Section(txt)
            local f = create("Frame", {Parent = Page, Size = UDim2.new(1, -5, 0, 20), BackgroundTransparency = 1})
            create("TextLabel", {Parent = f, Text = txt:upper(), Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, TextColor3 = Theme.MutedText, Font = Theme.Font, TextSize = 11, TextXAlignment = "Left"})
        end

        function Entry:Label(txt)
            local l = create("TextLabel", {Parent = Page, Text = txt, Size = UDim2.new(1, -5, 0, 18), BackgroundTransparency = 1, TextColor3 = Theme.Text, Font = Theme.Font, TextSize = 11, TextXAlignment = "Left"})
            return l
        end

        function Entry:Button(txt, cb)
            local b = create("TextButton", {Parent = Page, Size = UDim2.new(1, -5, 0, 35), BackgroundColor3 = Color3.new(0,0,0), BackgroundTransparency = 0.7, Text = txt, Font = Theme.Font, TextSize = 12, TextColor3 = Theme.Text})
            create("UICorner", {Parent = b, CornerRadius = UDim.new(0, 6)})
            create("UIStroke", {Parent = b, Color = Theme.Accent, Transparency = 0.8})
            applyAnimations(b, "Buttons")
            if isFn(cb) then b.MouseButton1Click:Connect(cb) end
        end

        function Entry:Toggle(txt, default, cb)
            if isFn(default) and cb == nil then
                cb = default
                default = false
            end
            local enabled = false
            if type(default) == "boolean" then enabled = default end
            local b = create("TextButton", {Parent = Page, Size = UDim2.new(1, -5, 0, 35), BackgroundColor3 = Color3.new(0,0,0), BackgroundTransparency = 0.7, Text = "  "..txt, Font = Theme.Font, TextSize = 12, TextColor3 = Theme.Text, TextXAlignment = "Left"})
            create("UICorner", {Parent = b, CornerRadius = UDim.new(0, 6)})
            applyAnimations(b, "Buttons")
            local box = create("Frame", {Parent = b, Size = UDim2.fromOffset(34, 18), Position = UDim2.new(1, -45, 0.5, -9), BackgroundColor3 = Color3.fromRGB(40,40,40)})
            create("UICorner", {Parent = box, CornerRadius = UDim.new(1, 0)})
            local dot = create("Frame", {Parent = box, Size = UDim2.fromOffset(12, 12), Position = UDim2.new(0, 3, 0.5, -6), BackgroundColor3 = Color3.new(1,1,1)})
            create("UICorner", {Parent = dot, CornerRadius = UDim.new(1, 0)})

            if enabled then
                dot.Position = UDim2.new(1, -15, 0.5, -6)
                box.BackgroundColor3 = Theme.Accent
            end

            b.MouseButton1Click:Connect(function()
                enabled = not enabled
                tween(dot, 0.2, {Position = enabled and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)})
                tween(box, 0.2, {BackgroundColor3 = enabled and Theme.Accent or Color3.fromRGB(40,40,40)})
                if isFn(cb) then cb(enabled) end
            end)
        end

        function Entry:Textbox(txt, placeholder, cb)
            if isFn(placeholder) and cb == nil then
                cb = placeholder
                placeholder = ""
            end
            local row = create("Frame", {Parent = Page, Size = UDim2.new(1, -5, 0, 40), BackgroundTransparency = 1})
            create("TextLabel", {Parent = row, Text = txt, Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1, TextColor3 = Theme.Text, Font = Theme.Font, TextSize = 11, TextXAlignment = "Left"})
            local box = create("TextBox", {Parent = row, Size = UDim2.new(1, 0, 0, 20), Position = UDim2.new(0, 0, 0, 18), BackgroundColor3 = Theme.Soft, BackgroundTransparency = 0.5, Text = "", PlaceholderText = placeholder or "", TextColor3 = Theme.Text, PlaceholderColor3 = Theme.MutedText, Font = Theme.Font, TextSize = 12, ClearTextOnFocus = false})
            create("UICorner", {Parent = box, CornerRadius = UDim.new(0, 6)})
            create("UIStroke", {Parent = box, Color = Theme.Accent, Transparency = 0.85})
            applyAnimations(box, "Inputs")
            box.FocusLost:Connect(function(enterPressed)
                if isFn(cb) then cb(box.Text, enterPressed) end
            end)
            return box
        end

        function Entry:Dropdown(txt, list, def, cb)
            if isFn(def) and cb == nil then
                cb = def
                def = nil
            end

            list = list or {}
            local selected = def

            local mainBtn = create("TextButton", {Parent = Page, Size = UDim2.new(1, -5, 0, 35), BackgroundColor3 = Color3.new(0,0,0), BackgroundTransparency = 0.7, Text = "  "..txt, Font = Theme.Font, TextSize = 12, TextColor3 = Theme.Text, TextXAlignment = "Left"})
            create("UICorner", {Parent = mainBtn, CornerRadius = UDim.new(0, 6)})
            create("UIStroke", {Parent = mainBtn, Color = Theme.Accent, Transparency = 0.85})
            applyAnimations(mainBtn, "Buttons")

            local valueLabel = create("TextLabel", {Parent = mainBtn, Size = UDim2.new(0, 140, 1, 0), Position = UDim2.new(1, -170, 0, 0), BackgroundTransparency = 1, Text = selected and tostring(selected) or "", TextColor3 = Theme.MutedText, Font = Theme.Font, TextSize = 11, TextXAlignment = "Right"})
            local arrow = create("TextLabel", {Parent = mainBtn, Size = UDim2.fromOffset(20, 20), Position = UDim2.new(1, -28, 0.5, -10), BackgroundTransparency = 1, Text = "▼", TextColor3 = Theme.MutedText, Font = Theme.Font, TextSize = 12})

            local listFrame = create("Frame", {Parent = Page, Size = UDim2.new(1, -5, 0, 0), BackgroundColor3 = Theme.Soft, BackgroundTransparency = 0.15, ClipsDescendants = true})
            create("UICorner", {Parent = listFrame, CornerRadius = UDim.new(0, 6)})
            create("UIStroke", {Parent = listFrame, Color = Theme.Accent, Transparency = 0.9})
            local layout = create("UIListLayout", {Parent = listFrame, Padding = UDim.new(0, 4)})
            create("UIPadding", {Parent = listFrame, PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6), PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6)})

            local expanded = false
            local buttons = {}

            local function rebuild()
                for _, b in ipairs(buttons) do b:Destroy() end
                table.clear(buttons)
                for _, opt in ipairs(list) do
                    local b = create("TextButton", {Parent = listFrame, Size = UDim2.new(1, 0, 0, 26), BackgroundColor3 = Color3.new(0,0,0), BackgroundTransparency = 0.6, Text = tostring(opt), Font = Theme.Font, TextSize = 12, TextColor3 = Theme.Text})
                    create("UICorner", {Parent = b, CornerRadius = UDim.new(0, 6)})
                    applyAnimations(b, "Tabs")
                    b.MouseButton1Click:Connect(function()
                        selected = opt
                        valueLabel.Text = tostring(opt)
                        expanded = false
                        tween(arrow, 0.2, {Rotation = 0})
                        tween(listFrame, 0.2, {Size = UDim2.new(1, -5, 0, 0)})
                        if isFn(cb) then cb(opt) end
                    end)
                    table.insert(buttons, b)
                end
            end

            rebuild()

            mainBtn.MouseButton1Click:Connect(function()
                expanded = not expanded
                tween(arrow, 0.2, {Rotation = expanded and -90 or 0})
                local targetY = expanded and math.clamp(layout.AbsoluteContentSize.Y + 12, 28, 180) or 0
                tween(listFrame, 0.2, {Size = UDim2.new(1, -5, 0, targetY)})
            end)

            if selected ~= nil and isFn(cb) then
                cb(selected)
            end

            return {
                Set = function(_, v)
                    selected = v
                    valueLabel.Text = tostring(v)
                    if isFn(cb) then cb(v) end
                end,
                Refresh = function(_, newList)
                    list = newList or {}
                    rebuild()
                end
            }
        end

        function Entry:Keybind(txt, defaultKey, cb)
            if isFn(defaultKey) and cb == nil then
                cb = defaultKey
                defaultKey = nil
            end

            local key = defaultKey
            local waiting = false

            local b = create("TextButton", {Parent = Page, Size = UDim2.new(1, -5, 0, 35), BackgroundColor3 = Color3.new(0,0,0), BackgroundTransparency = 0.7, Text = "  "..txt, Font = Theme.Font, TextSize = 12, TextColor3 = Theme.Text, TextXAlignment = "Left"})
            create("UICorner", {Parent = b, CornerRadius = UDim.new(0, 6)})
            create("UIStroke", {Parent = b, Color = Theme.Accent, Transparency = 0.85})
            applyAnimations(b, "Buttons")

            local keyLabel = create("TextLabel", {Parent = b, Size = UDim2.new(0, 120, 1, 0), Position = UDim2.new(1, -130, 0, 0), BackgroundTransparency = 1, Text = key and key.Name or "None", TextColor3 = Theme.MutedText, Font = Theme.Font, TextSize = 11, TextXAlignment = "Right"})

                b.MouseButton1Click:Connect(function()
                waiting = true
                keyLabel.Text = "..."
            end)

            UserInputService.InputBegan:Connect(function(input, gpe)
                if gpe then return end
                if waiting then
                    if input.KeyCode.Name == "Escape" then
                        key = input.KeyCode
                        keyLabel.Text = key.Name
                        waiting = false
                        return
                    end
                end

                if key and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == key then
                    if isFn(cb) then cb() end
                end
            end)

            return {
                Set = function(_, newKey)
                    key = newKey
                    keyLabel.Text = newKey and newKey.Name or "None"
                end
            }
        end

        function Entry:Slider(txt, min, max, def, cb)
            local SFrame = create("Frame", {Parent = Page, Size = UDim2.new(1, -5, 0, 45), BackgroundTransparency = 1})
            end

            function Entry:Textbox(txt, placeholder, cb)
                if isFn(placeholder) and cb == nil then
                    cb = placeholder
                    placeholder = ""
                end
                local row = create("Frame", {Parent = Page, Size = UDim2.new(1, -5, 0, 40), BackgroundTransparency = 1})
                create("TextLabel", {Parent = row, Text = txt, Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1, TextColor3 = Theme.Text, Font = Theme.Font, TextSize = 11, TextXAlignment = "Left"})
                local box = create("TextBox", {Parent = row, Size = UDim2.new(1, 0, 0, 20), Position = UDim2.new(0, 0, 0, 18), BackgroundColor3 = Theme.Soft, BackgroundTransparency = 0.5, Text = "", PlaceholderText = placeholder or "", TextColor3 = Theme.Text, PlaceholderColor3 = Theme.MutedText, Font = Theme.Font, TextSize = 12, ClearTextOnFocus = false})
                create("UICorner", {Parent = box, CornerRadius = UDim.new(0, 6)})
                create("UIStroke", {Parent = box, Color = Theme.Accent, Transparency = 0.85})
                applyAnimations(box, "Inputs")
                box.FocusLost:Connect(function(enterPressed)
                    if isFn(cb) then cb(box.Text, enterPressed) end
                end)
                return box
            end

            function Entry:Dropdown(txt, list, def, cb)
                if isFn(def) and cb == nil then
                    cb = def
                    def = nil
                end

                list = list or {}
                local selected = def

                local mainBtn = create("TextButton", {Parent = Page, Size = UDim2.new(1, -5, 0, 35), BackgroundColor3 = Color3.new(0,0,0), BackgroundTransparency = 0.7, Text = "  "..txt, Font = Theme.Font, TextSize = 12, TextColor3 = Theme.Text, TextXAlignment = "Left"})
                create("UICorner", {Parent = mainBtn, CornerRadius = UDim.new(0, 6)})
                create("UIStroke", {Parent = mainBtn, Color = Theme.Accent, Transparency = 0.85})
                applyAnimations(mainBtn, "Buttons")

                local valueLabel = create("TextLabel", {Parent = mainBtn, Size = UDim2.new(0, 140, 1, 0), Position = UDim2.new(1, -170, 0, 0), BackgroundTransparency = 1, Text = selected and tostring(selected) or "", TextColor3 = Theme.MutedText, Font = Theme.Font, TextSize = 11, TextXAlignment = "Right"})
                local arrow = create("TextLabel", {Parent = mainBtn, Size = UDim2.fromOffset(20, 20), Position = UDim2.new(1, -28, 0.5, -10), BackgroundTransparency = 1, Text = "▼", TextColor3 = Theme.MutedText, Font = Theme.Font, TextSize = 12})

                local listFrame = create("Frame", {Parent = Page, Size = UDim2.new(1, -5, 0, 0), BackgroundColor3 = Theme.Soft, BackgroundTransparency = 0.15, ClipsDescendants = true})
                create("UICorner", {Parent = listFrame, CornerRadius = UDim.new(0, 6)})
                create("UIStroke", {Parent = listFrame, Color = Theme.Accent, Transparency = 0.9})
                local layout = create("UIListLayout", {Parent = listFrame, Padding = UDim.new(0, 4)})
                create("UIPadding", {Parent = listFrame, PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6), PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6)})

                local expanded = false
                local buttons = {}

                local function rebuild()
                    for _, b in ipairs(buttons) do b:Destroy() end
                    table.clear(buttons)
                    for _, opt in ipairs(list) do
                        local b = create("TextButton", {Parent = listFrame, Size = UDim2.new(1, 0, 0, 26), BackgroundColor3 = Color3.new(0,0,0), BackgroundTransparency = 0.6, Text = tostring(opt), Font = Theme.Font, TextSize = 12, TextColor3 = Theme.Text})
                        create("UICorner", {Parent = b, CornerRadius = UDim.new(0, 6)})
                        applyAnimations(b, "Tabs")
                        b.MouseButton1Click:Connect(function()
                            selected = opt
                            valueLabel.Text = tostring(opt)
                            expanded = false
                            tween(arrow, 0.2, {Rotation = 0})
                            tween(listFrame, 0.2, {Size = UDim2.new(1, -5, 0, 0)})
                            if isFn(cb) then cb(opt) end
                        end)
                        table.insert(buttons, b)
                    end
                end

                rebuild()

                mainBtn.MouseButton1Click:Connect(function()
                    expanded = not expanded
                    tween(arrow, 0.2, {Rotation = expanded and -90 or 0})
                    local targetY = expanded and math.clamp(layout.AbsoluteContentSize.Y + 12, 28, 180) or 0
                    tween(listFrame, 0.2, {Size = UDim2.new(1, -5, 0, targetY)})
                end)

                if selected ~= nil and isFn(cb) then
                    cb(selected)
                end

                return {
                    Set = function(_, v)
                        selected = v
                        valueLabel.Text = tostring(v)
                        if isFn(cb) then cb(v) end
                    end,
                    Refresh = function(_, newList)
                        list = newList or {}
                        rebuild()
                    end
                }
            end

            function Entry:Keybind(txt, defaultKey, cb)
                if isFn(defaultKey) and cb == nil then
                    cb = defaultKey
                    defaultKey = nil
                end

                local key = defaultKey
                local waiting = false

                local b = create("TextButton", {Parent = Page, Size = UDim2.new(1, -5, 0, 35), BackgroundColor3 = Color3.new(0,0,0), BackgroundTransparency = 0.7, Text = "  "..txt, Font = Theme.Font, TextSize = 12, TextColor3 = Theme.Text, TextXAlignment = "Left"})
                create("UICorner", {Parent = b, CornerRadius = UDim.new(0, 6)})
                create("UIStroke", {Parent = b, Color = Theme.Accent, Transparency = 0.85})
                applyAnimations(b, "Buttons")

                local keyLabel = create("TextLabel", {Parent = b, Size = UDim2.new(0, 120, 1, 0), Position = UDim2.new(1, -130, 0, 0), BackgroundTransparency = 1, Text = key and key.Name or "None", TextColor3 = Theme.MutedText, Font = Theme.Font, TextSize = 11, TextXAlignment = "Right"})

                b.MouseButton1Click:Connect(function()
                    waiting = true
                    keyLabel.Text = "..."
                end)

                UserInputService.InputBegan:Connect(function(input, gpe)
                    if gpe then return end
                    if waiting then
                        if input.KeyCode.Name == "Escape" then
                            key = input.KeyCode
                            keyLabel.Text = key.Name
                            waiting = false
                            return
                        end
                    end

                    if key and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == key then
                        if isFn(cb) then cb() end
                    end
                end)

                return {
                    Set = function(_, newKey)
                        key = newKey
                        keyLabel.Text = newKey and newKey.Name or "None"
                    end
                }
            end

            function Entry:Slider(txt, min, max, def, cb)
                local SFrame = create("Frame", {Parent = Page, Size = UDim2.new(1, -5, 0, 45), BackgroundTransparency = 1})
                local lab = create("TextLabel", {Parent = SFrame, Text = txt.." : "..def, Size = UDim2.new(1,0,0,20), BackgroundTransparency = 1, TextColor3 = Theme.Text, Font = Theme.Font, TextSize = 11, TextXAlignment = "Left"})
                local bar = create("Frame", {Parent = SFrame, Size = UDim2.new(1, 0, 0, 4), Position = UDim2.new(0,0,0,30), BackgroundColor3 = Color3.fromRGB(50,50,50)})
                local fill = create("Frame", {Parent = bar, Size = UDim2.new((def-min)/(max-min), 0, 1, 0), BackgroundColor3 = Theme.Accent})
                local sliding = false

                local function update()
                    local p = math.clamp((UserInputService:GetMouseLocation().X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                    local val = math.floor(min + (max-min) * p)
                    fill.Size = UDim2.new(p, 0, 1, 0)
                    lab.Text = txt.." : "..val
                    if isFn(cb) then cb(val) end
                end
                bar.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding = true update() end end)
                UserInputService.InputChanged:Connect(function(i) if sliding and i.UserInputType == Enum.UserInputType.MouseMovement then update() end end)
                UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end end)
            end

            return Entry
        end
        return API
    end
    return Lib

return Lib
