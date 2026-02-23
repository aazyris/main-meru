--!strict
-- MeruLib - lightweight Roblox UI library (executor-friendly)

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local LOCAL_PLAYER = Players.LocalPlayer

local lib = {}
lib.__index = lib

export type Theme = {
	Background: Color3,
	Surface: Color3,
	Surface2: Color3,
	Stroke: Color3,
	Accent: Color3,
	Text: Color3,
	TextMuted: Color3,
	Shadow: Color3,
	Corner: number,
	Transparency: number,
	Font: Enum.Font,
}

local DEFAULT_THEME: Theme = {
	Background = Color3.fromRGB(18, 18, 20),
	Surface = Color3.fromRGB(26, 26, 30),
	Surface2 = Color3.fromRGB(34, 34, 40),
	Stroke = Color3.fromRGB(55, 55, 70),
	Accent = Color3.fromRGB(61, 132, 255),
	Text = Color3.fromRGB(245, 245, 245),
	TextMuted = Color3.fromRGB(185, 185, 195),
	Shadow = Color3.fromRGB(0, 0, 0),
	Corner = 14,
	Transparency = 0.18,
	Font = Enum.Font.Gotham,
}

local function deepMergeTheme(base: Theme, patch: any): Theme
	local out: any = {}
	for k, v in pairs(base :: any) do
		out[k] = v
	end
	if type(patch) == "table" then
		for k, v in pairs(patch) do
			out[k] = v
		end
	end
	return out :: Theme
end

local function tween(inst: Instance, time: number, props: {[string]: any})
	local tw = TweenService:Create(inst, TweenInfo.new(time, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), props)
	tw:Play()
	return tw
end

local function safeParentGui(scrgui: ScreenGui)
	local cg = game:GetService("CoreGui")
	if syn and syn.protect_gui then
		syn.protect_gui(scrgui)
		scrgui.Parent = cg
		return
	end
	if gethui then
		scrgui.Parent = gethui()
		return
	end
	scrgui.Parent = cg
end

local function findExisting(name: string): ScreenGui?
	local cg = game:GetService("CoreGui")
	if gethui then
		local hui = gethui()
		local found = hui:FindFirstChild(name)
		if found and found:IsA("ScreenGui") then
			return found
		end
	end
	local found = cg:FindFirstChild(name)
	if found and found:IsA("ScreenGui") then
		return found
	end
	return nil
end

type Window = {
	_gui: ScreenGui,
	_main: Frame,
	_tabsBar: ScrollingFrame,
	_workArea: Frame,
	_title: TextLabel,
	_searchBox: TextBox,
	_profileGear: ImageButton,
	_visible: boolean,
	_toggleBusy: boolean,
	_theme: Theme,
	_themed: {Instance},
	_tabs: {any},
	_selectedTab: any?,
	_dragConn: RBXScriptConnection?,
	_renderConn: RBXScriptConnection?,
	_keybindConn: RBXScriptConnection?,
}

type Tab = {
	Name: string,
	_button: TextButton,
	_container: ScrollingFrame,
	_parent: any,
	_controls: {Instance},
}

local function addCorner(inst: Instance, radiusPx: number)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radiusPx)
	c.Parent = inst
	return c
end

local function addStroke(inst: Instance, color: Color3, thickness: number, transparency: number?)
	local s = Instance.new("UIStroke")
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Color = color
	s.Thickness = thickness
	if transparency ~= nil then
		s.Transparency = transparency
	end
	s.Parent = inst
	return s
end

local function addPadding(inst: Instance, pad: number)
	local p = Instance.new("UIPadding")
	p.PaddingLeft = UDim.new(0, pad)
	p.PaddingRight = UDim.new(0, pad)
	p.PaddingTop = UDim.new(0, pad)
	p.PaddingBottom = UDim.new(0, pad)
	p.Parent = inst
	return p
end

local function mkLabel(parent: Instance, theme: Theme, text: string, sizeY: number, bold: boolean?)
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.Text = text
	l.TextColor3 = theme.TextMuted
	l.Font = bold and Enum.Font.GothamMedium or theme.Font
	l.TextSize = 18
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.TextWrapped = true
	l.Size = UDim2.new(1, 0, 0, sizeY)
	l.Parent = parent
	return l
end

local function mkButton(parent: Instance, theme: Theme, text: string, height: number)
	local b = Instance.new("TextButton")
	b.AutoButtonColor = false
	b.Text = text
	b.Font = Enum.Font.GothamMedium
	b.TextSize = 18
	b.TextColor3 = theme.Text
	b.BackgroundColor3 = theme.Surface2
	b.BackgroundTransparency = 0.12
	b.Size = UDim2.new(1, 0, 0, height)
	b.Parent = parent
	addCorner(b, 10)
	addStroke(b, theme.Stroke, 1, 0.4)
	return b
end

local function mkFieldRow(parent: Instance, theme: Theme, labelText: string, height: number)
	local row = Instance.new("Frame")
	row.BackgroundTransparency = 1
	row.Size = UDim2.new(1, 0, 0, height)
	row.Parent = parent

	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.Text = labelText
	l.TextColor3 = theme.TextMuted
	l.Font = theme.Font
	l.TextSize = 18
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Size = UDim2.new(0.55, 0, 1, 0)
	l.Parent = row

	return row, l
end

local function applyThemeTo(window: Window)
	local theme = window._theme
	for _, inst in ipairs(window._themed) do
		if inst:IsA("Frame") then
			-- keep per-instance colors
		elseif inst:IsA("TextLabel") then
			if inst.Name == "Title" then
				inst.TextColor3 = theme.Text
			else
				inst.TextColor3 = theme.TextMuted
			end
		elseif inst:IsA("TextButton") then
			-- leave, handled in creators
		elseif inst:IsA("UIStroke") then
			inst.Color = theme.Stroke
		end
	end
end

local function setupSmoothDrag(window: Window, dragArea: GuiObject)
	local main = window._main
	local dragging = false
	local dragStart = Vector2.zero
	local startPos = main.Position
	local targetPos = main.Position

	local function setTarget(inputPos: Vector2)
		local delta = inputPos - dragStart
		targetPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end

	dragArea.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = main.Position
			targetPos = startPos
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	dragArea.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			setTarget(input.Position)
		end
	end)

	window._renderConn = RunService.RenderStepped:Connect(function(dt)
		if not dragging then
			return
		end
		-- smooth interpolation without spawning endless tweens
		local alpha = math.clamp(dt * 18, 0, 1)
		main.Position = main.Position:Lerp(targetPos, alpha)
	end)
end

local function setTabSelected(window: Window, tab: Tab)
	if window._selectedTab == tab then
		return
	end
	window._selectedTab = tab
	for _, t in ipairs(window._tabs) do
		local isSelected = t == tab
		t._container.Visible = isSelected
		t._button.BackgroundTransparency = isSelected and 0.25 or 1
		t._button.TextColor3 = isSelected and window._theme.Text or window._theme.TextMuted
	end
end

local function filterTabs(window: Window, query: string)
	local q = string.upper(query or "")
	for _, t in ipairs(window._tabs) do
		if q == "" then
			t._button.Visible = true
		else
			t._button.Visible = string.find(string.upper(t.Name), q, 1, true) ~= nil
		end
	end
end

local function makeTempNotify(window: Window, titleText: string, bodyText: string, icon: string?)
	local scrgui = window._gui
	for _, child in ipairs(scrgui:GetChildren()) do
		if child:IsA("Frame") and child.Name == "MeruTempNotif" then
			child.Position = child.Position + UDim2.new(0, 0, 0, 86)
		end
	end

	local theme = window._theme
	local root = Instance.new("Frame")
	root.Name = "MeruTempNotif"
	root.Parent = scrgui
	root.AnchorPoint = Vector2.new(1, 0)
	root.Position = UDim2.new(1, -18, 0, 18)
	root.Size = UDim2.new(0, 360, 0, 74)
	root.BackgroundColor3 = theme.Surface
	root.BackgroundTransparency = theme.Transparency
	root.ZIndex = 200
	addCorner(root, 12)
	addStroke(root, theme.Stroke, 1, 0.35)

	local shadow = Instance.new("ImageLabel")
	shadow.Name = "Shadow"
	shadow.Parent = root
	shadow.BackgroundTransparency = 1
	shadow.AnchorPoint = Vector2.new(0.5, 0.5)
	shadow.Position = UDim2.new(0.5, 0, 0.5, 2)
	shadow.Size = UDim2.new(1, 44, 1, 44)
	shadow.ZIndex = 199
	shadow.Image = "rbxassetid://313486536"
	shadow.ImageColor3 = theme.Shadow
	shadow.ImageTransparency = 0.55
	shadow.ScaleType = Enum.ScaleType.Slice
	shadow.SliceCenter = Rect.new(10, 10, 118, 118)

	local pad = Instance.new("UIPadding")
	pad.PaddingLeft = UDim.new(0, 12)
	pad.PaddingRight = UDim.new(0, 12)
	pad.PaddingTop = UDim.new(0, 10)
	pad.PaddingBottom = UDim.new(0, 10)
	pad.Parent = root

	local iconImg = Instance.new("ImageLabel")
	iconImg.BackgroundTransparency = 1
	iconImg.Size = UDim2.new(0, 30, 0, 30)
	iconImg.Position = UDim2.new(0, 0, 0, 0)
	iconImg.ZIndex = 201
	iconImg.Image = icon or "rbxassetid://6031280882"
	iconImg.ImageColor3 = theme.Text
	iconImg.ScaleType = Enum.ScaleType.Fit
	iconImg.Parent = root

	local textWrap = Instance.new("Frame")
	textWrap.BackgroundTransparency = 1
	textWrap.Position = UDim2.new(0, 42, 0, 0)
	textWrap.Size = UDim2.new(1, -42, 1, 0)
	textWrap.ZIndex = 201
	textWrap.Parent = root

	local t1 = Instance.new("TextLabel")
	t1.BackgroundTransparency = 1
	t1.Text = titleText
	t1.TextColor3 = theme.Text
	t1.Font = Enum.Font.GothamMedium
	t1.TextSize = 18
	t1.TextXAlignment = Enum.TextXAlignment.Left
	t1.Size = UDim2.new(1, 0, 0, 22)
	t1.ZIndex = 201
	t1.Parent = textWrap

	local t2 = Instance.new("TextLabel")
	t2.BackgroundTransparency = 1
	t2.Text = bodyText
	t2.TextColor3 = theme.TextMuted
	t2.Font = theme.Font
	t2.TextSize = 14
	t2.TextXAlignment = Enum.TextXAlignment.Left
	t2.TextYAlignment = Enum.TextYAlignment.Top
	t2.TextWrapped = true
	t2.Position = UDim2.new(0, 0, 0, 22)
	t2.Size = UDim2.new(1, 0, 1, -22)
	t2.ZIndex = 201
	t2.Parent = textWrap

	root.Position = root.Position + UDim2.new(0, 30, 0, 0)
	root.BackgroundTransparency = 1
	tween(root, 0.25, {Position = UDim2.new(1, -18, 0, 18), BackgroundTransparency = theme.Transparency})
	task.delay(4.5, function()
		if root and root.Parent then
			tween(root, 0.25, {Position = root.Position + UDim2.new(0, 30, 0, 0), BackgroundTransparency = 1})
			game:GetService("Debris"):AddItem(root, 0.3)
		end
	end)
end

function lib.init(options: {
	Title: string?,
	ToggleKey: Enum.KeyCode?,
	DeletePrevious: boolean?,
	Visible: boolean?,
	Theme: Theme?,
	Size: Vector2?,
	Name: string?,
}): any
	options = options or {}

	local theme = deepMergeTheme(DEFAULT_THEME, options.Theme)
	local guiName = options.Name or "MeruUI"

	local existing = findExisting(guiName)
	if existing and options.DeletePrevious then
		local oldMain = existing:FindFirstChild("Main")
		if oldMain and oldMain:IsA("Frame") then
			tween(oldMain, 0.35, {Position = oldMain.Position + UDim2.new(0, 0, 1.2, 0)})
		end
		game:GetService("Debris"):AddItem(existing, 0.5)
	end

	local scrgui = Instance.new("ScreenGui")
	scrgui.Name = guiName
	scrgui.ResetOnSpawn = false
	scrgui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	safeParentGui(scrgui)

	local window: Window = {
		_gui = scrgui,
		_main = nil :: any,
		_tabsBar = nil :: any,
		_workArea = nil :: any,
		_title = nil :: any,
		_searchBox = nil :: any,
		_profileGear = nil :: any,
		_visible = options.Visible ~= false,
		_toggleBusy = false,
		_theme = theme,
		_themed = {},
		_tabs = {},
		_selectedTab = nil,
		_dragConn = nil,
		_renderConn = nil,
		_keybindConn = nil,
	}

	-- Main frame
	local main = Instance.new("Frame")
	main.Name = "Main"
	main.Parent = scrgui
	main.AnchorPoint = Vector2.new(0.5, 0.5)
	main.Position = UDim2.new(0.5, 0, 0.5, 0)
	local size = options.Size or Vector2.new(760, 560)
	main.Size = UDim2.new(0, size.X, 0, size.Y)
	main.BackgroundColor3 = theme.Background
	main.BackgroundTransparency = theme.Transparency
	addCorner(main, theme.Corner)
	addStroke(main, theme.Stroke, 1, 0.35)
	table.insert(window._themed, main)

	local shadow = Instance.new("ImageLabel")
	shadow.Name = "Shadow"
	shadow.Parent = main
	shadow.BackgroundTransparency = 1
	shadow.AnchorPoint = Vector2.new(0.5, 0.5)
	shadow.Position = UDim2.new(0.5, 0, 0.5, 10)
	shadow.Size = UDim2.new(1, 80, 1, 80)
	shadow.ZIndex = 0
	shadow.Image = "rbxassetid://313486536"
	shadow.ImageColor3 = theme.Shadow
	shadow.ImageTransparency = 0.62
	shadow.ScaleType = Enum.ScaleType.Slice
	shadow.SliceCenter = Rect.new(10, 10, 118, 118)

	-- Layout
	local rootPad = Instance.new("UIPadding")
	rootPad.PaddingLeft = UDim.new(0, 14)
	rootPad.PaddingRight = UDim.new(0, 14)
	rootPad.PaddingTop = UDim.new(0, 12)
	rootPad.PaddingBottom = UDim.new(0, 12)
	rootPad.Parent = main

	local topbar = Instance.new("Frame")
	topbar.Name = "Topbar"
	topbar.Parent = main
	topbar.BackgroundTransparency = 1
	topbar.Size = UDim2.new(1, 0, 0, 44)

	local macBtns = Instance.new("Frame")
	macBtns.Name = "MacButtons"
	macBtns.Parent = topbar
	macBtns.BackgroundTransparency = 1
	macBtns.Size = UDim2.new(0, 92, 0, 44)
	macBtns.Position = UDim2.new(0, 0, 0, 0)

	local list = Instance.new("UIListLayout")
	list.FillDirection = Enum.FillDirection.Horizontal
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.VerticalAlignment = Enum.VerticalAlignment.Center
	list.Padding = UDim.new(0, 8)
	list.Parent = macBtns

	local function mkDot(color: Color3)
		local b = Instance.new("TextButton")
		b.AutoButtonColor = false
		b.Text = ""
		b.BackgroundColor3 = color
		b.Size = UDim2.new(0, 14, 0, 14)
		b.Parent = macBtns
		addCorner(b, 999)
		addStroke(b, Color3.fromRGB(0, 0, 0), 1, 0.75)
		return b
	end

	local closeBtn = mkDot(Color3.fromRGB(254, 94, 86))
	local minBtn = mkDot(Color3.fromRGB(255, 189, 46))
	local maxBtn = mkDot(Color3.fromRGB(39, 200, 63))

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Parent = topbar
	title.BackgroundTransparency = 1
	title.Position = UDim2.new(0, 110, 0, 0)
	title.Size = UDim2.new(1, -110, 1, 0)
	title.Font = Enum.Font.GothamMedium
	title.TextSize = 20
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Text = options.Title or "Meru"
	title.TextColor3 = theme.Text
	table.insert(window._themed, title)

	-- Body columns
	local body = Instance.new("Frame")
	body.Name = "Body"
	body.Parent = main
	body.BackgroundTransparency = 1
	body.Position = UDim2.new(0, 0, 0, 52)
	body.Size = UDim2.new(1, 0, 1, -52)

	local sidebar = Instance.new("Frame")
	sidebar.Name = "Sidebar"
	sidebar.Parent = body
	sidebar.BackgroundTransparency = 1
	sidebar.Size = UDim2.new(0, 250, 1, 0)

	local workArea = Instance.new("Frame")
	workArea.Name = "WorkArea"
	workArea.Parent = body
	workArea.Position = UDim2.new(0, 260, 0, 0)
	workArea.Size = UDim2.new(1, -260, 1, 0)
	workArea.BackgroundColor3 = theme.Surface
	workArea.BackgroundTransparency = theme.Transparency
	addCorner(workArea, theme.Corner)
	addStroke(workArea, theme.Stroke, 1, 0.35)
	table.insert(window._themed, workArea)

	-- Search box
	local search = Instance.new("Frame")
	search.Name = "Search"
	search.Parent = sidebar
	search.BackgroundColor3 = theme.Surface
	search.BackgroundTransparency = theme.Transparency
	search.Size = UDim2.new(1, 0, 0, 36)
	addCorner(search, 10)
	addStroke(search, theme.Stroke, 1, 0.5)
	addPadding(search, 10)
	table.insert(window._themed, search)

	local searchIcon = Instance.new("ImageButton")
	searchIcon.Name = "SearchIcon"
	searchIcon.Parent = search
	searchIcon.BackgroundTransparency = 1
	searchIcon.Size = UDim2.new(0, 18, 0, 18)
	searchIcon.Position = UDim2.new(0, 0, 0.5, -9)
	searchIcon.Image = "rbxassetid://2804603863"
	searchIcon.ImageColor3 = theme.TextMuted

	local searchBox = Instance.new("TextBox")
	searchBox.Name = "SearchBox"
	searchBox.Parent = search
	searchBox.BackgroundTransparency = 1
	searchBox.Position = UDim2.new(0, 26, 0, 0)
	searchBox.Size = UDim2.new(1, -26, 1, 0)
	searchBox.ClearTextOnFocus = false
	searchBox.Font = theme.Font
	searchBox.TextSize = 16
	searchBox.PlaceholderText = "Search tabs..."
	searchBox.PlaceholderColor3 = theme.TextMuted
	searchBox.TextColor3 = theme.Text
	searchBox.TextXAlignment = Enum.TextXAlignment.Left

	searchIcon.MouseButton1Click:Connect(function()
		searchBox:CaptureFocus()
	end)

	-- Tabs list
	local tabsBar = Instance.new("ScrollingFrame")
	tabsBar.Name = "Tabs"
	tabsBar.Parent = sidebar
	tabsBar.BackgroundTransparency = 1
	tabsBar.BorderSizePixel = 0
	tabsBar.Position = UDim2.new(0, 0, 0, 46)
	tabsBar.Size = UDim2.new(1, 0, 1, -118)
	tabsBar.ScrollBarThickness = 2
	tabsBar.ScrollBarImageColor3 = theme.Stroke
	tabsBar.AutomaticCanvasSize = Enum.AutomaticSize.Y
	tabsBar.CanvasSize = UDim2.new(0, 0, 0, 0)

	local tabPad = Instance.new("UIPadding")
	tabPad.PaddingTop = UDim.new(0, 2)
	tabPad.PaddingBottom = UDim.new(0, 2)
	tabPad.Parent = tabsBar

	local tabsList = Instance.new("UIListLayout")
	tabsList.SortOrder = Enum.SortOrder.LayoutOrder
	tabsList.Padding = UDim.new(0, 8)
	tabsList.Parent = tabsBar

	-- Profile footer
	local profile = Instance.new("Frame")
	profile.Name = "Profile"
	profile.Parent = sidebar
	profile.BackgroundColor3 = theme.Surface
	profile.BackgroundTransparency = theme.Transparency
	profile.Position = UDim2.new(0, 0, 1, -62)
	profile.Size = UDim2.new(1, 0, 0, 62)
	addCorner(profile, 10)
	addStroke(profile, theme.Stroke, 1, 0.5)
	addPadding(profile, 10)
	table.insert(window._themed, profile)

	local avatar = Instance.new("ImageLabel")
	avatar.Name = "Avatar"
	avatar.Parent = profile
	avatar.BackgroundTransparency = 1
	avatar.Size = UDim2.new(0, 40, 0, 40)
	avatar.Position = UDim2.new(0, 0, 0.5, -20)
	addCorner(avatar, 999)
	if LOCAL_PLAYER then
		avatar.Image = ("https://www.roblox.com/headshot-thumbnail/image?userId=%d&width=150&height=150&format=png"):format(LOCAL_PLAYER.UserId)
	end

	local pname = Instance.new("TextLabel")
	pname.Name = "PlayerName"
	pname.Parent = profile
	pname.BackgroundTransparency = 1
	pname.Position = UDim2.new(0, 50, 0, 0)
	pname.Size = UDim2.new(1, -90, 1, 0)
	pname.Font = Enum.Font.GothamMedium
	pname.TextSize = 16
	pname.TextXAlignment = Enum.TextXAlignment.Left
	pname.TextColor3 = theme.Text
	pname.TextTruncate = Enum.TextTruncate.AtEnd
	pname.Text = LOCAL_PLAYER and LOCAL_PLAYER.Name or "Player"

	local gear = Instance.new("ImageButton")
	gear.Name = "Gear"
	gear.Parent = profile
	gear.BackgroundTransparency = 1
	gear.Size = UDim2.new(0, 24, 0, 24)
	gear.Position = UDim2.new(1, -24, 0.5, -12)
	gear.Image = "rbxassetid://6031280882"
	gear.ImageColor3 = theme.TextMuted

	-- Work area title
	local workPad = Instance.new("UIPadding")
	workPad.PaddingLeft = UDim.new(0, 14)
	workPad.PaddingRight = UDim.new(0, 14)
	workPad.PaddingTop = UDim.new(0, 12)
	workPad.PaddingBottom = UDim.new(0, 12)
	workPad.Parent = workArea

	local workTitle = Instance.new("TextLabel")
	workTitle.Name = "WorkTitle"
	workTitle.Parent = workArea
	workTitle.BackgroundTransparency = 1
	workTitle.Size = UDim2.new(1, 0, 0, 26)
	workTitle.Font = Enum.Font.GothamMedium
	workTitle.TextSize = 18
	workTitle.TextXAlignment = Enum.TextXAlignment.Left
	workTitle.TextColor3 = theme.Text
	workTitle.Text = " "

	-- Assign window refs
	window._main = main
	window._tabsBar = tabsBar
	window._workArea = workArea
	window._title = title
	window._searchBox = searchBox
	window._profileGear = gear

	-- Close / minimize / maximize
	closeBtn.MouseButton1Click:Connect(function()
		scrgui:Destroy()
	end)

	local function setVisible(vis: boolean)
		if window._toggleBusy then
			return
		end
		window._toggleBusy = true
		window._visible = vis
		if vis then
			main.Visible = true
			tween(main, 0.35, {Position = UDim2.new(0.5, 0, 0.5, 0)})
			task.wait(0.36)
		else
			tween(main, 0.35, {Position = main.Position + UDim2.new(0, 0, 1.2, 0)})
			task.wait(0.36)
			main.Visible = false
		end
		window._toggleBusy = false
	end

	minBtn.MouseButton1Click:Connect(function()
		setVisible(not window._visible)
	end)

	maxBtn.MouseButton1Click:Connect(function()
		makeTempNotify(window, "Meru", "Resize/maximize is not implemented (yet).", "rbxassetid://6031280882")
	end)

	if options.ToggleKey then
		window._keybindConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
			if gameProcessed then
				return
			end
			if input.KeyCode == options.ToggleKey then
				setVisible(not window._visible)
			end
		end)
	end

	-- Smooth drag (use topbar as handle)
	setupSmoothDrag(window, topbar)

	-- Search
	searchBox:GetPropertyChangedSignal("Text"):Connect(function()
		filterTabs(window, searchBox.Text)
	end)

	-- Window API
	local api = {}

	function api:Destroy()
		if window._renderConn then
			window._renderConn:Disconnect()
		end
		if window._keybindConn then
			window._keybindConn:Disconnect()
		end
		if window._gui then
			window._gui:Destroy()
		end
	end

	function api:SetTheme(patch: Theme)
		window._theme = deepMergeTheme(window._theme, patch)
		applyThemeTo(window)
	end

	function api:Notify(titleText: string, bodyText: string, icon: string?)
		makeTempNotify(window, titleText, bodyText, icon)
	end

	function api:Tab(name: string)
		local theme2 = window._theme

		local tabBtn = Instance.new("TextButton")
		tabBtn.Name = "TabButton"
		tabBtn.Parent = tabsBar
		tabBtn.BackgroundTransparency = 1
		tabBtn.Size = UDim2.new(1, -2, 0, 36)
		tabBtn.AutoButtonColor = false
		tabBtn.Font = Enum.Font.GothamMedium
		tabBtn.TextSize = 16
		tabBtn.TextXAlignment = Enum.TextXAlignment.Left
		tabBtn.Text = "  " .. name
		tabBtn.TextColor3 = theme2.TextMuted
		addCorner(tabBtn, 10)

		local tabContainer = Instance.new("ScrollingFrame")
		tabContainer.Name = ("Tab_%s"):format(name)
		tabContainer.Parent = workArea
		tabContainer.BackgroundTransparency = 1
		tabContainer.BorderSizePixel = 0
		tabContainer.Position = UDim2.new(0, 0, 0, 32)
		tabContainer.Size = UDim2.new(1, 0, 1, -32)
		tabContainer.ScrollBarThickness = 2
		tabContainer.ScrollBarImageColor3 = theme2.Stroke
		tabContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
		tabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
		tabContainer.Visible = false

		local pad = Instance.new("UIPadding")
		pad.PaddingTop = UDim.new(0, 6)
		pad.PaddingBottom = UDim.new(0, 6)
		pad.Parent = tabContainer

		local list2 = Instance.new("UIListLayout")
		list2.SortOrder = Enum.SortOrder.LayoutOrder
		list2.Padding = UDim.new(0, 10)
		list2.Parent = tabContainer

		local tab: Tab = {
			Name = name,
			_button = tabBtn,
			_container = tabContainer,
			_parent = api,
			_controls = {},
		}

		table.insert(window._tabs, tab)
		if not window._selectedTab then
			setTabSelected(window, tab)
			workTitle.Text = name
		end

		tabBtn.MouseButton1Click:Connect(function()
			setTabSelected(window, tab)
			workTitle.Text = name
		end)

		local tApi = {}

		function tApi:Select()
			setTabSelected(window, tab)
			workTitle.Text = name
		end

		function tApi:Divider(text: string)
			local d = mkLabel(tabContainer, window._theme, text, 28, true)
			d.TextColor3 = window._theme.Text
			d.TextSize = 16
			d.TextTransparency = 0.08
			table.insert(tab._controls, d)
			return d
		end

		function tApi:Label(text: string)
			local l = mkLabel(tabContainer, window._theme, text, 22, false)
			table.insert(tab._controls, l)
			return l
		end

		function tApi:Paragraph(titleText2: string, bodyText2: string)
			local box = Instance.new("Frame")
			box.BackgroundColor3 = window._theme.Surface2
			box.BackgroundTransparency = 0.12
			box.Size = UDim2.new(1, 0, 0, 80)
			box.Parent = tabContainer
			addCorner(box, 10)
			addStroke(box, window._theme.Stroke, 1, 0.5)
			addPadding(box, 10)

			local t = Instance.new("TextLabel")
			t.BackgroundTransparency = 1
			t.Text = titleText2
			t.Font = Enum.Font.GothamMedium
			t.TextSize = 16
			t.TextColor3 = window._theme.Text
			t.TextXAlignment = Enum.TextXAlignment.Left
			t.Size = UDim2.new(1, 0, 0, 20)
			t.Parent = box

			local b = Instance.new("TextLabel")
			b.BackgroundTransparency = 1
			b.Text = bodyText2
			b.Font = window._theme.Font
			b.TextSize = 14
			b.TextColor3 = window._theme.TextMuted
			b.TextXAlignment = Enum.TextXAlignment.Left
			b.TextYAlignment = Enum.TextYAlignment.Top
			b.TextWrapped = true
			b.Position = UDim2.new(0, 0, 0, 22)
			b.Size = UDim2.new(1, 0, 1, -22)
			b.Parent = box

			table.insert(tab._controls, box)
			return box
		end

		function tApi:Button(text: string, callback: (() -> ())?)
			local b = mkButton(tabContainer, window._theme, text, 40)
			if callback then
				b.MouseButton1Click:Connect(function()
					local old = b.TextSize
					b.TextSize = old - 2
					task.delay(0.06, function()
						if b and b.Parent then
							b.TextSize = old
						end
					end)
					task.spawn(callback)
				end)
			end
			table.insert(tab._controls, b)
			return b
		end

		function tApi:Toggle(text: string, default: boolean?, callback: ((boolean) -> ())?)
			local state = default == true
			local row, _ = mkFieldRow(tabContainer, window._theme, text, 40)

			local track = Instance.new("TextButton")
			track.AutoButtonColor = false
			track.Text = ""
			track.Size = UDim2.new(0, 60, 0, 28)
			track.Position = UDim2.new(1, -60, 0.5, -14)
			track.BackgroundColor3 = state and window._theme.Accent or Color3.fromRGB(60, 60, 70)
			track.BackgroundTransparency = 0.15
			track.Parent = row
			addCorner(track, 999)

			local knob = Instance.new("Frame")
			knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			knob.Size = UDim2.new(0, 24, 0, 24)
			knob.Position = state and UDim2.new(1, -26, 0.5, -12) or UDim2.new(0, 2, 0.5, -12)
			knob.Parent = track
			addCorner(knob, 999)

			local function render()
				tween(track, 0.12, {BackgroundColor3 = state and window._theme.Accent or Color3.fromRGB(60, 60, 70)})
				tween(knob, 0.12, {Position = state and UDim2.new(1, -26, 0.5, -12) or UDim2.new(0, 2, 0.5, -12)})
			end

			local function flip()
				state = not state
				render()
				if callback then
					task.spawn(callback, state)
				end
			end

			track.MouseButton1Click:Connect(flip)
			row.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					flip()
				end
			end)

			render()
			table.insert(tab._controls, row)
			return row
		end

		function tApi:Textbox(text: string, placeholder: string?, callback: ((string) -> ())?)
			local row, _ = mkFieldRow(tabContainer, window._theme, text, 40)

			local box = Instance.new("Frame")
			box.BackgroundColor3 = window._theme.Surface2
			box.BackgroundTransparency = 0.12
			box.Size = UDim2.new(0, 220, 0, 30)
			box.Position = UDim2.new(1, -220, 0.5, -15)
			box.Parent = row
			addCorner(box, 10)
			addStroke(box, window._theme.Stroke, 1, 0.6)

			local tb = Instance.new("TextBox")
			tb.BackgroundTransparency = 1
			tb.Size = UDim2.new(1, -14, 1, 0)
			tb.Position = UDim2.new(0, 7, 0, 0)
			tb.ClearTextOnFocus = false
			tb.Font = window._theme.Font
			tb.TextSize = 16
			tb.PlaceholderText = placeholder or "Type..."
			tb.PlaceholderColor3 = window._theme.TextMuted
			tb.TextColor3 = window._theme.Text
			tb.TextXAlignment = Enum.TextXAlignment.Left
			tb.Parent = box

			if callback then
				tb.FocusLost:Connect(function()
					task.spawn(callback, tb.Text)
				end)
			end

			table.insert(tab._controls, row)
			return tb
		end

		function tApi:Slider(text: string, min: number, max: number, defaultVal: number?, callback: ((number) -> ())?)
			local value = math.clamp(defaultVal or min, min, max)
			local row, _ = mkFieldRow(tabContainer, window._theme, text, 54)

			local track = Instance.new("Frame")
			track.BackgroundColor3 = window._theme.Surface2
			track.BackgroundTransparency = 0.12
			track.Size = UDim2.new(0, 220, 0, 8)
			track.Position = UDim2.new(1, -220, 0.5, 6)
			track.Parent = row
			addCorner(track, 999)
			addStroke(track, window._theme.Stroke, 1, 0.65)

			local fill = Instance.new("Frame")
			fill.BackgroundColor3 = window._theme.Accent
			fill.BackgroundTransparency = 0.05
			fill.Size = UDim2.new(0, 0, 1, 0)
			fill.Parent = track
			addCorner(fill, 999)

			local vlabel = Instance.new("TextLabel")
			vlabel.BackgroundTransparency = 1
			vlabel.Font = Enum.Font.GothamMedium
			vlabel.TextSize = 14
			vlabel.TextColor3 = window._theme.TextMuted
			vlabel.TextXAlignment = Enum.TextXAlignment.Right
			vlabel.Position = UDim2.new(1, -220, 0, 0)
			vlabel.Size = UDim2.new(0, 220, 0, 20)
			vlabel.Parent = row

			local drag = false
			local function setFromX(x: number)
				local rel = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
				value = min + (max - min) * rel
				value = math.floor(value * 100 + 0.5) / 100
				fill.Size = UDim2.new(rel, 0, 1, 0)
				vlabel.Text = tostring(value)
				if callback then
					task.spawn(callback, value)
				end
			end

			local function render()
				local rel = (value - min) / (max - min)
				fill.Size = UDim2.new(rel, 0, 1, 0)
				vlabel.Text = tostring(value)
			end

			local clickArea = Instance.new("TextButton")
			clickArea.AutoButtonColor = false
			clickArea.Text = ""
			clickArea.BackgroundTransparency = 1
			clickArea.Size = UDim2.new(1, 0, 3, 0)
			clickArea.Position = UDim2.new(0, 0, -1, 0)
			clickArea.Parent = track

			clickArea.MouseButton1Down:Connect(function()
				drag = true
				setFromX(UserInputService:GetMouseLocation().X)
			end)

			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					drag = false
				end
			end)

			UserInputService.InputChanged:Connect(function(input)
				if drag and input.UserInputType == Enum.UserInputType.MouseMovement then
					setFromX(UserInputService:GetMouseLocation().X)
				end
			end)

			render()
			table.insert(tab._controls, row)
			return row
		end

		function tApi:Dropdown(text: string, items: {string}, defaultItem: string?, callback: ((string) -> ())?)
			local selected = defaultItem or (items[1] or "")
			local row, _ = mkFieldRow(tabContainer, window._theme, text, 40)

			local btn = Instance.new("TextButton")
			btn.AutoButtonColor = false
			btn.Text = selected
			btn.Font = Enum.Font.GothamMedium
			btn.TextSize = 14
			btn.TextColor3 = window._theme.Text
			btn.TextXAlignment = Enum.TextXAlignment.Left
			btn.BackgroundColor3 = window._theme.Surface2
			btn.BackgroundTransparency = 0.12
			btn.Size = UDim2.new(0, 220, 0, 30)
			btn.Position = UDim2.new(1, -220, 0.5, -15)
			btn.Parent = row
			addCorner(btn, 10)
			addStroke(btn, window._theme.Stroke, 1, 0.6)
			addPadding(btn, 8)

			local open = false
			local listFrame = Instance.new("Frame")
			listFrame.BackgroundColor3 = window._theme.Surface
			listFrame.BackgroundTransparency = window._theme.Transparency
			listFrame.Size = UDim2.new(0, 220, 0, 0)
			listFrame.Position = UDim2.new(1, -220, 1, 6)
			listFrame.ClipsDescendants = true
			listFrame.Visible = false
			listFrame.Parent = row
			addCorner(listFrame, 10)
			addStroke(listFrame, window._theme.Stroke, 1, 0.55)

			local sf = Instance.new("ScrollingFrame")
			sf.BackgroundTransparency = 1
			sf.BorderSizePixel = 0
			sf.Size = UDim2.new(1, 0, 1, 0)
			sf.ScrollBarThickness = 2
			sf.AutomaticCanvasSize = Enum.AutomaticSize.Y
			sf.CanvasSize = UDim2.new(0, 0, 0, 0)
			sf.Parent = listFrame
			addPadding(sf, 6)

			local ll = Instance.new("UIListLayout")
			ll.SortOrder = Enum.SortOrder.LayoutOrder
			ll.Padding = UDim.new(0, 6)
			ll.Parent = sf

			local function choose(item: string)
				selected = item
				btn.Text = item
				if callback then
					task.spawn(callback, item)
				end
			end

			for _, item in ipairs(items) do
				local it = mkButton(sf, window._theme, item, 32)
				it.TextSize = 14
				it.MouseButton1Click:Connect(function()
					choose(item)
					open = false
					tween(listFrame, 0.12, {Size = UDim2.new(0, 220, 0, 0)})
					task.delay(0.13, function()
						if listFrame and listFrame.Parent then
							listFrame.Visible = false
						end
					end)
				end)
			end

			if selected ~= "" then
				choose(selected)
			end

			btn.MouseButton1Click:Connect(function()
				open = not open
				if open then
					listFrame.Visible = true
					local desired = math.min(160, 12 + (#items * 38))
					tween(listFrame, 0.12, {Size = UDim2.new(0, 220, 0, desired)})
				else
					tween(listFrame, 0.12, {Size = UDim2.new(0, 220, 0, 0)})
					task.delay(0.13, function()
						if listFrame and listFrame.Parent then
							listFrame.Visible = false
						end
					end)
				end
			end)

			table.insert(tab._controls, row)
			return row
		end

		function tApi:Keybind(text: string, defaultKey: Enum.KeyCode?, callback: ((Enum.KeyCode) -> ())?)
			local key = defaultKey or Enum.KeyCode.Unknown
			local row, _ = mkFieldRow(tabContainer, window._theme, text, 40)

			local btn = Instance.new("TextButton")
			btn.AutoButtonColor = false
			btn.Text = (key ~= Enum.KeyCode.Unknown) and key.Name or "Unbound"
			btn.Font = Enum.Font.GothamMedium
			btn.TextSize = 14
			btn.TextColor3 = window._theme.Text
			btn.BackgroundColor3 = window._theme.Surface2
			btn.BackgroundTransparency = 0.12
			btn.Size = UDim2.new(0, 220, 0, 30)
			btn.Position = UDim2.new(1, -220, 0.5, -15)
			btn.Parent = row
			addCorner(btn, 10)
			addStroke(btn, window._theme.Stroke, 1, 0.6)

			local waiting = false
			btn.MouseButton1Click:Connect(function()
				if waiting then
					return
				end
				waiting = true
				btn.Text = "Press a key..."
				local conn: RBXScriptConnection?
				conn = UserInputService.InputBegan:Connect(function(input, gp)
					if gp then
						return
					end
					if input.KeyCode ~= Enum.KeyCode.Unknown then
						key = input.KeyCode
						btn.Text = key.Name
						waiting = false
						if conn then
							conn:Disconnect()
						end
						if callback then
							task.spawn(callback, key)
						end
					end
				end)
			end)

			table.insert(tab._controls, row)
			return row
		end

		return tApi
	end

	-- Default Settings tab
	local settingsTab = api:Tab("Settings")
	settingsTab:Divider("Interface")
	settingsTab:Toggle("Show UI", window._visible, function(v)
		setVisible(v)
	end)
	settingsTab:Keybind("Toggle Key", options.ToggleKey or Enum.KeyCode.RightShift, function(kc)
		options.ToggleKey = kc
		makeTempNotify(window, "Settings", ("Toggle key set to %s"):format(kc.Name))
	end)
	settingsTab:Divider("Theme")
	settingsTab:Button("Accent: Blue", function()
		window._theme.Accent = Color3.fromRGB(61, 132, 255)
		makeTempNotify(window, "Theme", "Accent set to Blue.")
	end)
	settingsTab:Button("Accent: Purple", function()
		window._theme.Accent = Color3.fromRGB(170, 90, 255)
		makeTempNotify(window, "Theme", "Accent set to Purple.")
	end)
	settingsTab:Button("Accent: Green", function()
		window._theme.Accent = Color3.fromRGB(60, 220, 110)
		makeTempNotify(window, "Theme", "Accent set to Green.")
	end)

	gear.MouseButton1Click:Connect(function()
		settingsTab:Select()
	end)

	if not window._visible then
		main.Visible = false
	end

	return api
end

return lib

