-- ── MERU ULTIMATE LIBRARY [FINAL EDITION] ─────────────────────────────────
local Library = {
	Flags = {},
	ConfigFolder = "MeruConfigs",
	Theme = {
		Background = Color3.fromRGB(18, 18, 22),
		Sidebar    = Color3.fromRGB(24, 24, 28),
		Element    = Color3.fromRGB(30, 30, 35),
		Hover      = Color3.fromRGB(40, 40, 45),
		Text       = Color3.fromRGB(255, 255, 255),
		TextDim    = Color3.fromRGB(160, 160, 160),
		Accent     = Color3.fromRGB(255, 255, 255), -- PURE WHITE ACCENT
		Divider    = Color3.fromRGB(50, 50, 55),
		Shadow     = Color3.fromRGB(0, 0, 0),
		Opacity    = 0.1 -- Glass Transparency
	}
}

-- ── Services ──────────────────────────────────────────────────────────────
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local RunService       = game:GetService("RunService")
local CoreGui          = game:GetService("CoreGui")
local Players          = game:GetService("Players")
local HttpService      = game:GetService("HttpService")
local Stats            = game:GetService("Stats")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ── Utility Functions ─────────────────────────────────────────────────────
local Utility = {}

function Utility:Tween(instance, props, time, style, dir)
	local info = TweenInfo.new(time or 0.2, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out)
	local tween = TweenService:Create(instance, info, props)
	tween:Play()
	return tween
end

function Utility:Ripple(obj)
	task.spawn(function()
		local Ripple = Instance.new("ImageLabel")
		Ripple.Name = "Ripple"
		Ripple.Parent = obj
		Ripple.BackgroundColor3 = Library.Theme.Text
		Ripple.BackgroundTransparency = 1
		Ripple.BorderSizePixel = 0
		Ripple.Image = "rbxassetid://266543268"
		Ripple.ImageColor3 = Color3.fromRGB(255, 255, 255)
		Ripple.ImageTransparency = 0.8
		Ripple.ScaleType = Enum.ScaleType.Fit
		
		local mouse = UserInputService:GetMouseLocation()
		local relativeX = mouse.X - obj.AbsolutePosition.X
		local relativeY = mouse.Y - obj.AbsolutePosition.Y
		Ripple.Position = UDim2.new(0, relativeX, 0, relativeY)
		Ripple.Size = UDim2.new(0, 0, 0, 0)
		
		local targetSize = math.max(obj.AbsoluteSize.X, obj.AbsoluteSize.Y) * 2
		
		Utility:Tween(Ripple, {Size = UDim2.new(0, targetSize, 0, targetSize), Position = UDim2.new(0, relativeX - targetSize/2, 0, relativeY - targetSize/2), ImageTransparency = 1}, 0.5)
		task.wait(0.5)
		Ripple:Destroy()
	end)
end

function Utility:MakeDraggable(frame, handle)
	local dragging, dragInput, dragStart, startPos
	
	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
		end
	end)
	
	handle.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			dragInput = input
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			Utility:Tween(frame, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}, 0.05)
		end
	end)
	
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
end

-- ── File System ───────────────────────────────────────────────────────────
local ConfigSystem = {}

function ConfigSystem:Init()
	if not isfolder(Library.ConfigFolder) then
		makefolder(Library.ConfigFolder)
	end
end

function ConfigSystem:Save(name)
	local json = HttpService:JSONEncode(Library.Flags)
	writefile(Library.ConfigFolder .. "/" .. name .. ".json", json)
end

function ConfigSystem:Load(name)
	if isfile(Library.ConfigFolder .. "/" .. name .. ".json") then
		local content = readfile(Library.ConfigFolder .. "/" .. name .. ".json")
		local data = HttpService:JSONDecode(content)
		
		for flag, value in pairs(data) do
			if Library.Flags[flag] ~= nil then
				-- Logic to update UI would go here, 
				-- for now we update the value table
				Library.Flags[flag] = value
				-- In a full system, you would fire the callback here
			end
		end
		return true
	end
	return false
end

function ConfigSystem:Delete(name)
	if isfile(Library.ConfigFolder .. "/" .. name .. ".json") then
		delfile(Library.ConfigFolder .. "/" .. name .. ".json")
	end
end

function ConfigSystem:List()
	local files = {}
	if isfolder(Library.ConfigFolder) then
		for _, file in pairs(listfiles(Library.ConfigFolder)) do
			if file:sub(-5) == ".json" then
				table.insert(files, file:match("([^/]+)%.json$"))
			end
		end
	end
	return files
end

-- ── UI Construction ───────────────────────────────────────────────────────

function Library:CreateWindow(Settings)
	Settings = Settings or {}
	local Title = Settings.Title or "Meru Ultimate"
	
	-- Cleanup
	if CoreGui:FindFirstChild("MeruUltimate") then
		CoreGui.MeruUltimate:Destroy()
	end
	
	ConfigSystem:Init()

	-- ScreenGui
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "MeruUltimate"
	ScreenGui.IgnoreGuiInset = true
	ScreenGui.Parent = CoreGui
	
	if syn and syn.protect_gui then syn.protect_gui(ScreenGui) end

	-- ── Watermark ─────────────────────────────────────────────────────────
	local Watermark = Instance.new("Frame")
	Watermark.Name = "Watermark"
	Watermark.Size = UDim2.new(0, 0, 0, 26)
	Watermark.Position = UDim2.new(0.01, 0, 0.01, 0)
	Watermark.BackgroundColor3 = Library.Theme.Background
	Watermark.BackgroundTransparency = 0.2
	Watermark.BorderSizePixel = 0
	Watermark.Parent = ScreenGui
	Instance.new("UICorner", Watermark).CornerRadius = UDim.new(0, 6)
	local WmStroke = Instance.new("UIStroke", Watermark)
	WmStroke.Color = Library.Theme.Accent
	WmStroke.Thickness = 1
	WmStroke.Transparency = 0.6
	
	local WmText = Instance.new("TextLabel")
	WmText.Size = UDim2.new(0, 0, 1, 0)
	WmText.Position = UDim2.new(0, 10, 0, 0)
	WmText.BackgroundTransparency = 1
	WmText.TextColor3 = Library.Theme.Text
	WmText.Font = Enum.Font.GothamMedium
	WmText.TextSize = 12
	WmText.AutomaticSize = Enum.AutomaticSize.X
	WmText.Parent = Watermark

	task.spawn(function()
		while Watermark.Parent do
			local fps = math.floor(workspace:GetRealPhysicsFPS())
			local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString():split(" ")[1] or 0)
			local time = os.date("%X")
			WmText.Text = string.format("<b>%s</b>  |  FPS: %s  |  Ping: %sms  |  %s", Title, fps, ping, time)
			WmText.RichText = true
			Watermark.Size = UDim2.new(0, WmText.AbsoluteSize.X + 20, 0, 26)
			task.wait(1)
		end
	end)

	-- ── Main Frame ────────────────────────────────────────────────────────
	local Main = Instance.new("Frame")
	Main.Name = "Main"
	Main.Size = UDim2.new(0, 750, 0, 500)
	Main.Position = UDim2.new(0.5, -375, 0.5, -250)
	Main.BackgroundColor3 = Library.Theme.Background
	Main.BackgroundTransparency = Library.Theme.Opacity
	Main.BorderSizePixel = 0
	Main.ClipsDescendants = true
	Main.Parent = ScreenGui
	
	Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
	local MainStroke = Instance.new("UIStroke", Main)
	MainStroke.Color = Library.Theme.Divider
	MainStroke.Thickness = 1

	-- Dragging Logic
	local DragCover = Instance.new("Frame")
	DragCover.Name = "DragCover" -- Invisible frame at top to handle drag
	DragCover.Size = UDim2.new(1, 0, 0, 50)
	DragCover.BackgroundTransparency = 1
	DragCover.Parent = Main
	Utility:MakeDraggable(Main, DragCover)

	-- ── Sidebar ───────────────────────────────────────────────────────────
	local Sidebar = Instance.new("Frame")
	Sidebar.Name = "Sidebar"
	Sidebar.Size = UDim2.new(0, 200, 1, 0)
	Sidebar.BackgroundColor3 = Library.Theme.Sidebar
	Sidebar.BackgroundTransparency = Library.Theme.Opacity
	Sidebar.BorderSizePixel = 0
	Sidebar.Parent = Main
	
	local SideLine = Instance.new("Frame")
	SideLine.Size = UDim2.new(0, 1, 1, 0)
	SideLine.Position = UDim2.new(1, 0, 0, 0)
	SideLine.BackgroundColor3 = Library.Theme.Divider
	SideLine.BorderSizePixel = 0
	SideLine.Parent = Sidebar

	local TitleLbl = Instance.new("TextLabel")
	TitleLbl.Size = UDim2.new(1, -20, 0, 50)
	TitleLbl.Position = UDim2.new(0, 20, 0, 0)
	TitleLbl.BackgroundTransparency = 1
	TitleLbl.Text = Title
	TitleLbl.TextColor3 = Library.Theme.Accent -- WHITE
	TitleLbl.Font = Enum.Font.GothamBold
	TitleLbl.TextSize = 22
	TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
	TitleLbl.Parent = Sidebar

	-- Search Bar
	local SearchFrame = Instance.new("Frame")
	SearchFrame.Size = UDim2.new(1, -30, 0, 30)
	SearchFrame.Position = UDim2.new(0, 15, 0, 55)
	SearchFrame.BackgroundColor3 = Library.Theme.Element
	SearchFrame.BackgroundTransparency = 0.5
	SearchFrame.Parent = Sidebar
	Instance.new("UICorner", SearchFrame).CornerRadius = UDim.new(0, 6)
	
	local SearchIcon = Instance.new("ImageLabel")
	SearchIcon.Size = UDim2.new(0, 16, 0, 16)
	SearchIcon.Position = UDim2.new(0, 8, 0.5, -8)
	SearchIcon.BackgroundTransparency = 1
	SearchIcon.Image = "rbxassetid://6031154871" -- Search icon
	SearchIcon.ImageColor3 = Library.Theme.TextDim
	SearchIcon.Parent = SearchFrame

	local SearchBox = Instance.new("TextBox")
	SearchBox.Size = UDim2.new(1, -30, 1, 0)
	SearchBox.Position = UDim2.new(0, 30, 0, 0)
	SearchBox.BackgroundTransparency = 1
	SearchBox.PlaceholderText = "Search..."
	SearchBox.PlaceholderColor3 = Library.Theme.TextDim
	SearchBox.TextColor3 = Library.Theme.Text
	SearchBox.Font = Enum.Font.Gotham
	SearchBox.TextSize = 13
	SearchBox.Parent = SearchFrame

	-- Tab Container
	local TabHolder = Instance.new("ScrollingFrame")
	TabHolder.Size = UDim2.new(1, 0, 1, -150)
	TabHolder.Position = UDim2.new(0, 0, 0, 95)
	TabHolder.BackgroundTransparency = 1
	TabHolder.ScrollBarThickness = 0
	TabHolder.Parent = Sidebar
	
	local TabList = Instance.new("UIListLayout", TabHolder)
	TabList.Padding = UDim.new(0, 5)
	TabList.SortOrder = Enum.SortOrder.LayoutOrder

	-- Bottom Profile
	local Profile = Instance.new("Frame")
	Profile.Size = UDim2.new(1, 0, 0, 50)
	Profile.Position = UDim2.new(0, 0, 1, -50)
	Profile.BackgroundTransparency = 1
	Profile.Parent = Sidebar
	
	local Avatar = Instance.new("ImageLabel")
	Avatar.Size = UDim2.new(0, 32, 0, 32)
	Avatar.Position = UDim2.new(0, 15, 0.5, -16)
	Avatar.BackgroundColor3 = Library.Theme.Background
	Avatar.Image = "https://www.roblox.com/headshot-thumbnail/image?userId="..LocalPlayer.UserId.."&width=420&height=420&format=png"
	Avatar.Parent = Profile
	Instance.new("UICorner", Avatar).CornerRadius = UDim.new(1, 0)
	
	local UserLbl = Instance.new("TextLabel")
	UserLbl.Size = UDim2.new(0, 100, 0, 20)
	UserLbl.Position = UDim2.new(0, 55, 0.5, -10)
	UserLbl.BackgroundTransparency = 1
	UserLbl.Text = LocalPlayer.Name
	UserLbl.TextColor3 = Library.Theme.Text
	UserLbl.Font = Enum.Font.GothamMedium
	UserLbl.TextSize = 13
	UserLbl.TextXAlignment = Enum.TextXAlignment.Left
	UserLbl.Parent = Profile

	-- Settings Button
	local SettingsBtn = Instance.new("TextButton")
	SettingsBtn.Name = "SettingsBtn"
	SettingsBtn.Size = UDim2.new(0, 24, 0, 24)
	SettingsBtn.Position = UDim2.new(1, -35, 0.5, -12)
	SettingsBtn.BackgroundTransparency = 1
	SettingsBtn.Text = ""
	SettingsBtn.Parent = Profile
	
	local SetIcon = Instance.new("ImageLabel")
	SetIcon.Size = UDim2.new(1, 0, 1, 0)
	SetIcon.BackgroundTransparency = 1
	SetIcon.Image = "rbxassetid://6031280882" -- Cog
	SetIcon.ImageColor3 = Library.Theme.TextDim
	SetIcon.Parent = SettingsBtn
	
	-- ── Content Area ──────────────────────────────────────────────────────
	local Content = Instance.new("Frame")
	Content.Name = "Content"
	Content.Size = UDim2.new(1, -200, 1, 0)
	Content.Position = UDim2.new(0, 200, 0, 0)
	Content.BackgroundTransparency = 1
	Content.Parent = Main

	local PageContainer = Instance.new("Frame")
	PageContainer.Size = UDim2.new(1, 0, 1, -60)
	PageContainer.Position = UDim2.new(0, 0, 0, 60)
	PageContainer.BackgroundTransparency = 1
	PageContainer.Parent = Content

	-- Top Bar Actions
	local TopActions = Instance.new("Frame")
	TopActions.Size = UDim2.new(1, 0, 0, 50)
	TopActions.BackgroundTransparency = 1
	TopActions.Parent = Content
	
	local CloseBtn = Instance.new("TextButton")
	CloseBtn.Size = UDim2.new(0, 40, 0, 40)
	CloseBtn.Position = UDim2.new(1, -40, 0, 5)
	CloseBtn.BackgroundTransparency = 1
	CloseBtn.Text = "×"
	CloseBtn.TextColor3 = Library.Theme.TextDim
	CloseBtn.TextSize = 28
	CloseBtn.Parent = TopActions
	CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
	
	local MinBtn = Instance.new("TextButton")
	MinBtn.Size = UDim2.new(0, 40, 0, 40)
	MinBtn.Position = UDim2.new(1, -80, 0, 5)
	MinBtn.BackgroundTransparency = 1
	MinBtn.Text = "–"
	MinBtn.TextColor3 = Library.Theme.TextDim
	MinBtn.TextSize = 28
	MinBtn.Parent = TopActions

	-- ── Minimized Widget (Draggable) ──────────────────────────────────────
	local MinWidget = Instance.new("Frame")
	MinWidget.Size = UDim2.new(0, 50, 0, 50)
	MinWidget.Position = UDim2.new(0.9, 0, 0.8, 0)
	MinWidget.BackgroundColor3 = Library.Theme.Background
	MinWidget.Visible = false
	MinWidget.Parent = ScreenGui
	Instance.new("UICorner", MinWidget).CornerRadius = UDim.new(0, 10)
	Instance.new("UIStroke", MinWidget).Color = Library.Theme.Accent
	
	local MinIcon = Instance.new("TextLabel")
	MinIcon.Size = UDim2.new(1, 0, 1, 0)
	MinIcon.BackgroundTransparency = 1
	MinIcon.Text = "M"
	MinIcon.TextColor3 = Library.Theme.Accent
	MinIcon.Font = Enum.Font.GothamBold
	MinIcon.TextSize = 24
	MinIcon.Parent = MinWidget

	local MinBtnTrigger = Instance.new("TextButton")
	MinBtnTrigger.Size = UDim2.new(1, 0, 1, 0)
	MinBtnTrigger.BackgroundTransparency = 1
	MinBtnTrigger.Text = ""
	MinBtnTrigger.Parent = MinWidget
	
	Utility:MakeDraggable(MinWidget, MinBtnTrigger)

	-- Logic
	local function ToggleUI()
		if Main.Visible then
			Utility:Tween(Main, {Size = UDim2.new(0, 0, 0, 0), Position = MinWidget.Position}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
			task.wait(0.3)
			Main.Visible = false
			MinWidget.Visible = true
			MinWidget.Size = UDim2.new(0, 0, 0, 0)
			Utility:Tween(MinWidget, {Size = UDim2.new(0, 50, 0, 50)}, 0.3)
		else
			MinWidget.Visible = false
			Main.Visible = true
			Utility:Tween(Main, {Size = UDim2.new(0, 750, 0, 500), Position = UDim2.new(0.5, -375, 0.5, -250)}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		end
	end
	
	MinBtn.MouseButton1Click:Connect(ToggleUI)
	MinBtnTrigger.MouseButton1Click:Connect(ToggleUI)

	-- ── Tooltip ──────────────────────────────────────────────────────────
	local Tooltip = Instance.new("TextLabel")
	Tooltip.Size = UDim2.new(0, 0, 0, 24)
	Tooltip.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	Tooltip.TextColor3 = Color3.fromRGB(255, 255, 255)
	Tooltip.TextSize = 12
	Tooltip.Font = Enum.Font.Gotham
	Tooltip.Visible = false
	Tooltip.ZIndex = 100
	Tooltip.Parent = ScreenGui
	Instance.new("UICorner", Tooltip).CornerRadius = UDim.new(0, 4)

	local function AddTooltip(obj, text)
		if not text then return end
		obj.MouseEnter:Connect(function()
			Tooltip.Visible = true
			Tooltip.Text = " " .. text .. " "
			Tooltip.AutomaticSize = Enum.AutomaticSize.X
		end)
		obj.MouseLeave:Connect(function() Tooltip.Visible = false end)
		obj.MouseMoved:Connect(function()
			local m = UserInputService:GetMouseLocation()
			Tooltip.Position = UDim2.new(0, m.X + 15, 0, m.Y)
		end)
	end

	-- ── Tab System ────────────────────────────────────────────────────────
	local Tabs = {}
	local SettingsTab = nil -- Forward declaration
	
	local function SwitchPage(page, btn)
		for _, p in pairs(PageContainer:GetChildren()) do p.Visible = false end
		for _, b in pairs(TabHolder:GetChildren()) do
			if b:IsA("TextButton") then
				Utility:Tween(b, {BackgroundTransparency = 1}, 0.2)
				Utility:Tween(b.Label, {TextColor3 = Library.Theme.TextDim, Position = UDim2.new(0, 15, 0, 0)}, 0.2)
			end
		end
		-- Reset Settings Icon
		Utility:Tween(SetIcon, {ImageColor3 = Library.Theme.TextDim, Rotation = 0}, 0.2)

		page.Visible = true
		if btn then
			Utility:Tween(btn, {BackgroundTransparency = 0}, 0.2)
			Utility:Tween(btn.Label, {TextColor3 = Library.Theme.Accent, Position = UDim2.new(0, 20, 0, 0)}, 0.2)
		end
	end

	function Tabs:Tab(Config)
		local Name = Config.Name or "Tab"
		
		local Btn = Instance.new("TextButton")
		Btn.Name = Name
		Btn.Size = UDim2.new(1, -20, 0, 36)
		Btn.Position = UDim2.new(0, 10, 0, 0)
		Btn.BackgroundTransparency = 1
		Btn.BackgroundColor3 = Library.Theme.Element
		Btn.Text = ""
		Btn.Parent = TabHolder
		Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

		local Label = Instance.new("TextLabel")
		Label.Name = "Label"
		Label.Size = UDim2.new(1, 0, 1, 0)
		Label.Position = UDim2.new(0, 15, 0, 0)
		Label.BackgroundTransparency = 1
		Label.Text = Name
		Label.TextColor3 = Library.Theme.TextDim
		Label.Font = Enum.Font.GothamMedium
		Label.TextSize = 13
		Label.TextXAlignment = Enum.TextXAlignment.Left
		Label.Parent = Btn

		local Page = Instance.new("ScrollingFrame")
		Page.Name = Name
		Page.Size = UDim2.new(1, 0, 1, 0)
		Page.BackgroundTransparency = 1
		Page.ScrollBarThickness = 2
		Page.Visible = false
		Page.Parent = PageContainer
		
		local PList = Instance.new("UIListLayout", Page)
		PList.Padding = UDim.new(0, 8)
		PList.SortOrder = Enum.SortOrder.LayoutOrder
		
		local Pad = Instance.new("UIPadding", Page)
		Pad.PaddingLeft = UDim.new(0, 20)
		Pad.PaddingRight = UDim.new(0, 20)
		Pad.PaddingTop = UDim.new(0, 10)

		Btn.MouseButton1Click:Connect(function()
			Utility:Ripple(Btn)
			SwitchPage(Page, Btn)
		end)

		-- Elements
		local Elements = {}
		
		function Elements:Section(Text)
			local F = Instance.new("Frame")
			F.Size = UDim2.new(1, 0, 0, 30)
			F.BackgroundTransparency = 1
			F.Parent = Page
			
			local L = Instance.new("TextLabel")
			L.Size = UDim2.new(1, 0, 1, 0)
			L.Position = UDim2.new(0, 2, 0, 5)
			L.BackgroundTransparency = 1
			L.Text = Text
			L.TextColor3 = Library.Theme.Accent -- WHITE
			L.Font = Enum.Font.GothamBold
			L.TextSize = 12
			L.TextXAlignment = Enum.TextXAlignment.Left
			L.Parent = F
		end

		function Elements:Toggle(Config)
			local Name = Config.Name
			local Default = Config.Default or false
			local Callback = Config.Callback or function() end
			local Flag = Config.Flag or Name
			
			Library.Flags[Flag] = Default

			local Frame = Instance.new("Frame")
			Frame.Size = UDim2.new(1, 0, 0, 40)
			Frame.BackgroundColor3 = Library.Theme.Element
			Frame.Parent = Page
			Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)
			AddTooltip(Frame, Config.Tooltip)

			local Text = Instance.new("TextLabel")
			Text.Size = UDim2.new(1, -60, 1, 0)
			Text.Position = UDim2.new(0, 15, 0, 0)
			Text.BackgroundTransparency = 1
			Text.Text = Name
			Text.TextColor3 = Library.Theme.Text
			Text.Font = Enum.Font.GothamMedium
			Text.TextSize = 13
			Text.TextXAlignment = Enum.TextXAlignment.Left
			Text.Parent = Frame

			local Switch = Instance.new("Frame")
			Switch.Size = UDim2.new(0, 40, 0, 20)
			Switch.Position = UDim2.new(1, -55, 0.5, -10)
			Switch.BackgroundColor3 = Default and Library.Theme.Accent or Color3.fromRGB(50, 50, 55)
			Switch.Parent = Frame
			Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)

			local Circle = Instance.new("Frame")
			Circle.Size = UDim2.new(0, 16, 0, 16)
			Circle.Position = Default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
			Circle.BackgroundColor3 = Library.Theme.Background
			Circle.Parent = Switch
			Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)

			local Btn = Instance.new("TextButton")
			Btn.Size = UDim2.new(1, 0, 1, 0)
			Btn.BackgroundTransparency = 1
			Btn.Text = ""
			Btn.Parent = Frame

			Btn.MouseButton1Click:Connect(function()
				Utility:Ripple(Frame)
				local state = not Library.Flags[Flag]
				Library.Flags[Flag] = state
				
				Utility:Tween(Switch, {BackgroundColor3 = state and Library.Theme.Accent or Color3.fromRGB(50, 50, 55)}, 0.2)
				Utility:Tween(Circle, {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}, 0.2)
				Callback(state)
			end)
		end

		function Elements:Button(Config)
			local Frame = Instance.new("Frame")
			Frame.Size = UDim2.new(1, 0, 0, 40)
			Frame.BackgroundColor3 = Library.Theme.Element
			Frame.Parent = Page
			Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)
			AddTooltip(Frame, Config.Tooltip)

			local Btn = Instance.new("TextButton")
			Btn.Size = UDim2.new(1, 0, 1, 0)
			Btn.BackgroundTransparency = 1
			Btn.Text = Config.Name
			Btn.TextColor3 = Library.Theme.Text
			Btn.Font = Enum.Font.GothamMedium
			Btn.TextSize = 13
			Btn.Parent = Frame

			Btn.MouseButton1Click:Connect(function()
				Utility:Ripple(Frame)
				Config.Callback()
			end)
		end
		
		function Elements:Slider(Config)
			local Name = Config.Name
			local Min, Max = Config.Min, Config.Max
			local Default = Config.Default or Min
			local Callback = Config.Callback or function() end
			local Flag = Config.Flag or Name
			
			Library.Flags[Flag] = Default

			local Frame = Instance.new("Frame")
			Frame.Size = UDim2.new(1, 0, 0, 55)
			Frame.BackgroundColor3 = Library.Theme.Element
			Frame.Parent = Page
			Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)
			AddTooltip(Frame, Config.Tooltip)
			
			local Title = Instance.new("TextLabel")
			Title.Size = UDim2.new(1, 0, 0, 30)
			Title.Position = UDim2.new(0, 15, 0, 0)
			Title.BackgroundTransparency = 1
			Title.Text = Name
			Title.TextColor3 = Library.Theme.Text
			Title.Font = Enum.Font.GothamMedium
			Title.TextSize = 13
			Title.TextXAlignment = Enum.TextXAlignment.Left
			Title.Parent = Frame
			
			local ValueLbl = Instance.new("TextLabel")
			ValueLbl.Size = UDim2.new(1, -15, 0, 30)
			ValueLbl.BackgroundTransparency = 1
			ValueLbl.Text = tostring(Default)
			ValueLbl.TextColor3 = Library.Theme.TextDim
			ValueLbl.Font = Enum.Font.Gotham
			ValueLbl.TextSize = 13
			ValueLbl.TextXAlignment = Enum.TextXAlignment.Right
			ValueLbl.Parent = Frame
			
			local Bar = Instance.new("Frame")
			Bar.Size = UDim2.new(1, -30, 0, 4)
			Bar.Position = UDim2.new(0, 15, 0, 35)
			Bar.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
			Bar.Parent = Frame
			Instance.new("UICorner", Bar).CornerRadius = UDim.new(1, 0)
			
			local Fill = Instance.new("Frame")
			Fill.Size = UDim2.new((Default - Min) / (Max - Min), 0, 1, 0)
			Fill.BackgroundColor3 = Library.Theme.Accent
			Fill.Parent = Bar
			Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
			
			local Trigger = Instance.new("TextButton")
			Trigger.Size = UDim2.new(1, 0, 1, 0)
			Trigger.BackgroundTransparency = 1
			Trigger.Text = ""
			Trigger.Parent = Frame
			
			local dragging = false
			local function Update(input)
				local sizeX = Bar.AbsoluteSize.X
				local posX = Bar.AbsolutePosition.X
				local pct = math.clamp((input.Position.X - posX) / sizeX, 0, 1)
				local val = math.floor(Min + (Max - Min) * pct)
				
				Library.Flags[Flag] = val
				ValueLbl.Text = tostring(val)
				Utility:Tween(Fill, {Size = UDim2.new(pct, 0, 1, 0)}, 0.05)
				Callback(val)
			end
			
			Trigger.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = true
					Update(input)
				end
			end)
			UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
			UserInputService.InputChanged:Connect(function(input) if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then Update(input) end end)
		end

		return Elements
	end

	-- ── Create Settings Page Automatically ────────────────────────────────
	local SettingsPage = Instance.new("ScrollingFrame")
	SettingsPage.Name = "Settings"
	SettingsPage.Size = UDim2.new(1, 0, 1, 0)
	SettingsPage.BackgroundTransparency = 1
	SettingsPage.Visible = false
	SettingsPage.Parent = PageContainer
	Instance.new("UIListLayout", SettingsPage).Padding = UDim.new(0, 8)
	Instance.new("UIPadding", SettingsPage).PaddingLeft = UDim.new(0, 20)
	Instance.new("UIPadding", SettingsPage).PaddingTop = UDim.new(0, 10)

	SettingsBtn.MouseButton1Click:Connect(function()
		SwitchPage(SettingsPage, nil)
		Utility:Tween(SetIcon, {ImageColor3 = Library.Theme.Accent, Rotation = 180}, 0.3)
	end)

	-- Populate Settings Page with Config System
	do
		local SLabel = Instance.new("TextLabel")
		SLabel.Size = UDim2.new(1, 0, 0, 30)
		SLabel.BackgroundTransparency = 1
		SLabel.Text = "Configuration"
		SLabel.TextColor3 = Library.Theme.Accent
		SLabel.Font = Enum.Font.GothamBold
		SLabel.TextSize = 14
		SLabel.TextXAlignment = Enum.TextXAlignment.Left
		SLabel.Parent = SettingsPage

		local NameBox = Instance.new("TextBox")
		NameBox.Size = UDim2.new(1, -40, 0, 40)
		NameBox.BackgroundColor3 = Library.Theme.Element
		NameBox.TextColor3 = Library.Theme.Text
		NameBox.PlaceholderText = "Config Name..."
		NameBox.Text = ""
		NameBox.Font = Enum.Font.Gotham
		NameBox.TextSize = 13
		NameBox.Parent = SettingsPage
		Instance.new("UICorner", NameBox).CornerRadius = UDim.new(0, 6)

		local function MakeBtn(Text, Callback, Color)
			local Btn = Instance.new("TextButton")
			Btn.Size = UDim2.new(1, -40, 0, 35)
			Btn.BackgroundColor3 = Color or Library.Theme.Element
			Btn.Text = Text
			Btn.TextColor3 = Library.Theme.Text
			Btn.Font = Enum.Font.GothamMedium
			Btn.TextSize = 13
			Btn.Parent = SettingsPage
			Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
			Btn.MouseButton1Click:Connect(function() 
				Utility:Ripple(Btn)
				Callback() 
			end)
		end

		MakeBtn("Save Config", function()
			if NameBox.Text ~= "" then
				ConfigSystem:Save(NameBox.Text)
			end
		end, Color3.fromRGB(40, 100, 60))

		MakeBtn("Load Config", function()
			if NameBox.Text ~= "" then
				ConfigSystem:Load(NameBox.Text)
			end
		end)

		MakeBtn("Delete Config", function()
			if NameBox.Text ~= "" then
				ConfigSystem:Delete(NameBox.Text)
			end
		end, Color3.fromRGB(100, 40, 40))
		
		-- File List (Simple)
		local ListLabel = Instance.new("TextLabel")
		ListLabel.Size = UDim2.new(1, 0, 0, 100)
		ListLabel.BackgroundTransparency = 1
		ListLabel.Text = "Available Configs: \n" .. table.concat(ConfigSystem:List(), "\n")
		ListLabel.TextColor3 = Library.Theme.TextDim
		ListLabel.Font = Enum.Font.Gotham
		ListLabel.TextSize = 12
		ListLabel.TextXAlignment = Enum.TextXAlignment.Left
		ListLabel.TextYAlignment = Enum.TextYAlignment.Top
		ListLabel.Parent = SettingsPage
		
		MakeBtn("Refresh List", function()
			ListLabel.Text = "Available Configs: \n" .. table.concat(ConfigSystem:List(), "\n")
		end)
	end

	return Tabs
end

return Library
