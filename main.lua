--// Written by depso
--// MIT License
--// Copyright (c) 2024 Depso

local ImGui = {
    Animations = {
        Buttons = {
            MouseEnter = {BackgroundTransparency = 0.5},
            MouseLeave = {BackgroundTransparency = 0.7}
        },
        Tabs = {
            MouseEnter = {BackgroundTransparency = 0.5},
            MouseLeave = {BackgroundTransparency = 1}
        },
    },
    Windows = {},
    Animation = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    UIAssetId = "rbxassetid://76246418997296"
}

--// Services 
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

--// Local Variables
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Mouse = LocalPlayer:GetMouse()
local IsStudio = RunService:IsStudio()
local NullFunction = function() end

--// Colors (Forced Black Theme)
local THEME = {
    Main = Color3.fromRGB(15, 15, 15),
    Darker = Color3.fromRGB(10, 10, 10),
    Border = Color3.fromRGB(30, 30, 30),
    Accent = Color3.fromRGB(255, 255, 255)
}

--// Prefabs
function ImGui:FetchUI()
    local CacheName = "DepsoImGui"
    if _G[CacheName] then return _G[CacheName] end

    local UI = nil
    if not IsStudio then
        UI = game:GetObjects(ImGui.UIAssetId)[1]
    else
        UI = PlayerGui:FindFirstChild("DepsoImGui") or (script:FindFirstChild("DepsoImGui"))
    end

    _G[CacheName] = UI
    return UI
end

local UI = ImGui:FetchUI()
local Prefabs = UI.Prefabs
Prefabs.Visible = false

--// Internal Utilities
local function ApplyTheme(Obj)
    if Obj:IsA("GuiObject") then
        Obj.BackgroundColor3 = THEME.Main
        Obj.BorderColor3 = THEME.Border
        if Obj:IsA("TextLabel") or Obj:IsA("TextButton") then
            Obj.TextColor3 = THEME.Accent
        end
    end
end

function ImGui:MergeMetatables(Class, Instance)
    return setmetatable({}, {
        __index = function(_, k)
            local s, v = pcall(function() return Instance[k] end)
            if s and typeof(v) == "function" then return function(_, ...) return v(Instance, ...) end end
            return (s and v ~= nil) and v or Class[k]
        end,
        __newindex = function(_, k, v) if Class[k] ~= nil then Class[k] = v else Instance[k] = v end end
    })
end

function ImGui:ApplyDraggable(Frame, Header)
    local Dragging, StartPos, FramePos
    Header.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging, StartPos, FramePos = true, i.Position, Frame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if Dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local Delta = i.Position - StartPos
            Frame.Position = UDim2.new(FramePos.X.Scale, FramePos.X.Offset + Delta.X, FramePos.Y.Scale, FramePos.Y.Offset + Delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end end)
end

--// UI Class
function ImGui:ContainerClass(Frame, Window)
    local Container = {}
    
    function Container:Button(Config)
        local Btn = Prefabs.Button:Clone()
        Btn.Parent = Frame
        Btn.Text = Config.Text or "Button"
        Btn.Visible = true
        ApplyTheme(Btn)
        Btn.Activated:Connect(function() (Config.Callback or NullFunction)() end)
        return Btn
    end

    function Container:Label(Config)
        local Lbl = Prefabs.Label:Clone()
        Lbl.Parent = Frame
        Lbl.Text = Config.Text or "Label"
        Lbl.Visible = true
        ApplyTheme(Lbl)
        return Lbl
    end

    function Container:Slider(Config)
        local Sld = Prefabs.Slider:Clone()
        Sld.Parent = Frame
        Sld.Visible = true
        ApplyTheme(Sld)
        local Grab, ValTxt = Sld.Grab, Sld.ValueText
        local Dragging = false

        local function Set(Val, Ratio)
            local Min, Max = Config.MinValue or 0, Config.MaxValue or 100
            local Perc = Ratio and math.clamp(Val, 0, 1) or math.clamp((Val - Min) / (Max - Min), 0, 1)
            Grab.Position = UDim2.fromScale(Perc, 0.5)
            local Final = Min + (Max - Min) * Perc
            ValTxt.Text = (Config.Format or "%.0f"):format(Final)
            if Config.Callback then Config.Callback(Final) end
        end

        Sld.MouseButton1Down:Connect(function() Dragging = true end)
        UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end end)
        UserInputService.InputChanged:Connect(function(i)
            if Dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
                Set((i.Position.X - Sld.AbsolutePosition.X) / Sld.AbsoluteSize.X, true)
            end
        end)
        Set(Config.Value or 0)
        return Sld
    end

    return Container
end

function ImGui:CreateWindow(Config)
    local Screen = Instance.new("ScreenGui", IsStudio and PlayerGui or CoreGui)
    Screen.Name = "ImGui_" .. (Config.Title or "Menu")
    Screen.ResetOnSpawn = false

    local Window = Prefabs.Window:Clone()
    Window.Parent = Screen
    Window.Visible = true
    Window.ClipsDescendants = true
    Window.BackgroundColor3 = THEME.Main

    local Content = Window.Content
    local Body, TitleBar, ToolBar = Content.Body, Content.TitleBar, Content.ToolBar
    TitleBar.BackgroundColor3 = THEME.Darker
    Body.BackgroundColor3 = THEME.Main

    ImGui:ApplyDraggable(Window, TitleBar)
    TitleBar.Left.Title.Text = Config.Title or "Menu"

    -- Minimize Logic
    local ToggleBtn = TitleBar.Left.Toggle.ToggleButton
    local IsMinimized, StoredH = false, Config.Size and Config.Size.Y.Offset or 350

    local function SetOpen(Open)
        IsMinimized = not Open
        if Open then
            Body.Visible = true
            TweenService:Create(Window, ImGui.Animation, {Size = UDim2.new(Window.Size.X.Scale, Window.Size.X.Offset, 0, StoredH)}):Play()
            TweenService:Create(ToggleBtn, ImGui.Animation, {Rotation = 90}):Play()
        else
            StoredH = Window.Size.Y.Offset
            TweenService:Create(Window, ImGui.Animation, {Size = UDim2.new(Window.Size.X.Scale, Window.Size.X.Offset, 0, 30)}):Play()
            TweenService:Create(ToggleBtn, ImGui.Animation, {Rotation = 0}):Play()
            task.delay(0.15, function() if IsMinimized then Body.Visible = false end end)
        end
    end

    ToggleBtn.Activated:Connect(function() SetOpen(IsMinimized) end)
    TitleBar.Close.Activated:Connect(function() Screen:Destroy() end)

    local WinObj = {
        CreateTab = function(_, TabConfig)
            local TabBtn = ToolBar.TabButton:Clone()
            TabBtn.Parent = ToolBar
            TabBtn.Text = TabConfig.Name or "Tab"
            TabBtn.Visible = true
            ApplyTheme(TabBtn)

            local Page = Body.Template:Clone()
            Page.Parent = Body
            Page.Visible = TabConfig.Visible or false
            Page.BackgroundColor3 = THEME.Main

            TabBtn.Activated:Connect(function()
                for _, p in next, Body:GetChildren() do if p:IsA("ScrollingFrame") then p.Visible = false end end
                Page.Visible = true
            end)

            return ImGui:ContainerClass(Page, Window)
        end,
        Center = function()
            Window.Position = UDim2.new(0.5, -Window.AbsoluteSize.X/2, 0.5, -Window.AbsoluteSize.Y/2)
        end
    }

    if Config.Size then Window.Size = Config.Size end
    WinObj.Center()
    return WinObj
end

return ImGui
