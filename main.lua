local Library = {}
local TweenService    = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService      = game:GetService("RunService")
local CoreGui         = game:GetService("CoreGui")

-- ── Modern Color Palette (matching the image) ──────────────
local Colors = {
	BG            = Color3.fromRGB(20, 20, 25),
	Panel         = Color3.fromRGB(28, 28, 33),
	Element       = Color3.fromRGB(35, 35, 40),
	ElementHover  = Color3.fromRGB(42, 42, 48),
	TitleBar      = Color3.fromRGB(25, 25, 30),
	Text          = Color3.fromRGB(220, 220, 225),
	TextDim       = Color3.fromRGB(130, 130, 140),
	TextActive    = Color3.fromRGB(255, 255, 255),
	Accent        = Color3.fromRGB(80, 200, 200),    -- Cyan/Teal
	AccentDark    = Color3.fromRGB(60, 180, 180),
	Divider       = Color3.fromRGB(45, 45, 50),
}

-- ── Helpers ─────────────────────────────────────────────────
local function Tween(instance, props, duration, style, direction)
	duration  = duration  or 0.2
	style     = style     or Enum.EasingStyle.Quart
	direction = direction or Enum.EasingDirection.Out
	return TweenService:Create(instance, TweenInfo.new(duration, style, direction), props)
end

local function TweenPlay(instance, props, duration, style, direction)
	local t = Tween(instance, props, duration, style, direction)
	t:Play()
	return t
end

function Library:CreateWindow(Title)
	Title = Title or "Meru"

	local prev = CoreGui:FindFirstChild("MeruHub_UI")
	if prev then prev:Destroy() end

	-- ── Hover System ────────────────────────────────────────
	local HoverTargets = {}

	local function RegisterHover(guiObj, onEnter, onLeave)
		table.insert(HoverTargets, { instance = guiObj, onEnter = onEnter, onLeave = onLeave, inside = false })
	end

	local function IsMouseOver(guiObj)
		local pos = UserInputService:GetMouseLocation()
		local abs = guiObj.AbsolutePosition
		local sz  = guiObj.AbsoluteSize
		return pos.X >= abs.X and pos.X <= abs.X + sz.X
			and pos.Y >= abs.Y and pos.Y <= abs.Y + sz.Y
	end

	UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
		for _, h in ipairs(HoverTargets) do
			if h.instance and h.instance.Parent then
				local over = IsMouseOver(h.instance)
				if over and not h.inside then
					h.inside = true;  h.onEnter()
				elseif not over and h.inside then
					h.inside = false; h.onLeave()
				end
			end
		end
	end)

	-- ── ScreenGui ───────────────────────────────────────────
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name         = "MeruHub_UI"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.Parent       = CoreGui

	-- ── Notification System ─────────────────────────────────
	function Library:Notify(Text, Duration, Type)
		Duration = Duration or 3
		Type = Type or "info"
		
		local typeColors = {
			success = {accent = Color3.fromRGB(80, 200, 120)},
			warning = {accent = Color3.fromRGB(255, 180, 80)},
			error = {accent = Color3.fromRGB(255, 100, 100)},
			info = {accent = Colors.Accent}
		}
		
		local theme = typeColors[Type] or typeColors.info
		
		local Notification = Instance.new("Frame")
		Notification.Size             = UDim2.new(0, 300, 0, 60)
		Notification.Position         = UDim2.new(1, 320, 1, -80)
		Notification.BackgroundColor3 = Colors.Panel
		Notification.Parent           = ScreenGui
		Instance.new("UICorner", Notification).CornerRadius = UDim.new(0, 10)

		local AccentBar = Instance.new("Frame")
		AccentBar.Size             = UDim2.new(0, 3, 1, 0)
		AccentBar.BackgroundColor3 = theme.accent
		AccentBar.BorderSizePixel  = 0
		AccentBar.Parent           = Notification

		local Message = Instance.new("TextLabel")
		Message.Size                   = UDim2.new(1, -20, 1, -10)
		Message.Position               = UDim2.new(0, 15, 0, 5)
		Message.BackgroundTransparency = 1
		Message.Text                   = Text
		Message.TextColor3             = Colors.Text
		Message.Font                   = Enum.Font.GothamMedium
		Message.TextSize               = 13
		Message.TextXAlignment         = Enum.TextXAlignment.Left
		Message.TextWrapped            = true
		Message.Parent                 = Notification

		TweenPlay(Notification, { Position = UDim2.new(1, -320, 1, -80) }, 0.4, Enum.EasingStyle.Back)

		task.delay(Duration, function()
			if Notification and Notification.Parent then
				TweenPlay(Notification, { Position = UDim2.new(1, 320, 1, -80) }, 0.3)
				task.delay(0.35, function()
					if Notification and Notification.Parent then Notification:Destroy() end
				end)
			end
		end)
	end

	-- ── Main Window ─────────────────────────────────────────
	local WindowSize = UDim2.new(0, 520, 0, 420)
	local Minimized = false

	local MainFrame = Instance.new("Frame")
	MainFrame.Size             = UDim2.new(0, 0, 0, 0)
	MainFrame.AnchorPoint      = Vector2.new(0.5, 0.5)
	MainFrame.Position         = UDim2.new(0.5, 0, 0.5, 0)
	MainFrame.BackgroundColor3 = Colors.BG
	MainFrame.ClipsDescendants = true
	MainFrame.Parent           = ScreenGui
	Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

	-- ── Title Bar ───────────────────────────────────────────
	local TitleBar = Instance.new("Frame")
	TitleBar.Size             = UDim2.new(1, 0, 0, 45)
	TitleBar.BackgroundColor3 = Colors.TitleBar
	TitleBar.Parent           = MainFrame
	Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 12)

	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.Size                   = UDim2.new(1, -100, 1, 0)
	TitleLabel.Position               = UDim2.new(0, 20, 0, 0)
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Text                   = Title
	TitleLabel.TextColor3             = Colors.TextActive
	TitleLabel.Font                   = Enum.Font.GothamBold
	TitleLabel.TextSize               = 16
	TitleLabel.TextXAlignment         = Enum.TextXAlignment.Left
	TitleLabel.Parent                 = TitleBar

	-- Settings icon (left)
	local SettingsIcon = Instance.new("ImageLabel")
	SettingsIcon.Size             = UDim2.new(0, 20, 0, 20)
	SettingsIcon.Position         = UDim2.new(0, 15, 0.5, -10)
	SettingsIcon.BackgroundTransparency = 1
	SettingsIcon.Image            = "rbxassetid://7733964719"
	SettingsIcon.ImageColor3      = Colors.TextDim
	SettingsIcon.Parent           = TitleBar

	-- Minimize button
	local MinButton = Instance.new("TextButton")
	MinButton.Size                   = UDim2.new(0, 35, 0, 35)
	MinButton.Position               = UDim2.new(1, -80, 0.5, -17.5)
	MinButton.BackgroundTransparency = 1
	MinButton.Text                   = "─"
	MinButton.TextColor3             = Colors.TextDim
	MinButton.TextSize               = 18
	MinButton.Font                   = Enum.Font.GothamBold
	MinButton.Parent                 = TitleBar

	-- Close button
	local CloseButton = Instance.new("TextButton")
	CloseButton.Size                   = UDim2.new(0, 35, 0, 35)
	CloseButton.Position               = UDim2.new(1, -45, 0.5, -17.5)
	CloseButton.BackgroundTransparency = 1
	CloseButton.Text                   = "×"
	CloseButton.TextColor3             = Color3.fromRGB(255, 100, 100)
	CloseButton.TextSize               = 22
	CloseButton.Font                   = Enum.Font.GothamBold
	CloseButton.Parent                 = TitleBar

	RegisterHover(MinButton,
		function() MinButton.TextColor3 = Colors.TextActive end,
		function() MinButton.TextColor3 = Colors.TextDim end
	)

	RegisterHover(CloseButton,
		function() CloseButton.TextColor3 = Color3.fromRGB(255, 150, 150) end,
		function() CloseButton.TextColor3 = Color3.fromRGB(255, 100, 100) end
	)

	MinButton.MouseButton1Click:Connect(function()
		Minimized = not Minimized
		TweenPlay(MainFrame, { Size = Minimized and UDim2.new(0, 520, 0, 45) or WindowSize }, 0.3)
	end)

	CloseButton.MouseButton1Click:Connect(function()
		TweenPlay(MainFrame, { Size = UDim2.new(0, 0, 0, 0) }, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In)
		task.delay(0.3, function()
			if ScreenGui and ScreenGui.Parent then ScreenGui:Destroy() end
		end)
	end)

	-- ── Left Sidebar ────────────────────────────────────────
	local Sidebar = Instance.new("Frame")
	Sidebar.Size             = UDim2.new(0, 180, 1, -45)
	Sidebar.Position         = UDim2.new(0, 0, 0, 45)
	Sidebar.BackgroundColor3 = Colors.Panel
	Sidebar.Parent           = MainFrame

	local TabContainer = Instance.new("ScrollingFrame")
	TabContainer.Size                   = UDim2.new(1, 0, 1, 0)
	TabContainer.BackgroundTransparency = 1
	TabContainer.ScrollBarThickness     = 0
	TabContainer.BorderSizePixel        = 0
	TabContainer.Parent                 = Sidebar

	local TabList = Instance.new("UIListLayout", TabContainer)
	TabList.Padding = UDim.new(0, 5)
	Instance.new("UIPadding", TabContainer).PaddingTop = UDim.new(0, 15)
	Instance.new("UIPadding", TabContainer).PaddingLeft = UDim.new(0, 12)
	Instance.new("UIPadding", TabContainer).PaddingRight = UDim.new(0, 12)

	-- ── Content Area ────────────────────────────────────────
	local ContentContainer = Instance.new("Frame")
	ContentContainer.Size                   = UDim2.new(1, -180, 1, -45)
	ContentContainer.Position               = UDim2.new(0, 180, 0, 45)
	ContentContainer.BackgroundTransparency = 1
	ContentContainer.Parent                 = MainFrame

	-- ── Dragging ────────────────────────────────────────────
	local Dragging = false
	local DragStart, StartPos

	TitleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			Dragging = true
			DragStart = input.Position
			StartPos = MainFrame.Position
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local Delta = input.Position - DragStart
			MainFrame.Position = UDim2.new(
				StartPos.X.Scale, StartPos.X.Offset + Delta.X,
				StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y
			)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			Dragging = false
		end
	end)

	-- ── Tab System ──────────────────────────────────────────
	local Tabs = {}
	local AllTabs = {}
	local ActiveTab = nil

	function Tabs:CreateTab(TabName, Icon)
		local TabButton = Instance.new("TextButton")
		TabButton.Size             = UDim2.new(1, 0, 0, 38)
		TabButton.BackgroundColor3 = Colors.Element
		TabButton.Text             = ""
		TabButton.AutoButtonColor  = false
		TabButton.Parent           = TabContainer
		Instance.new("UICorner", TabButton).CornerRadius = UDim.new(0, 8)

		local TabLabel = Instance.new("TextLabel")
		TabLabel.Size                   = UDim2.new(1, -15, 1, 0)
		TabLabel.Position               = UDim2.new(0, 15, 0, 0)
		TabLabel.BackgroundTransparency = 1
		TabLabel.Text                   = TabName
		TabLabel.TextColor3             = Colors.TextDim
		TabLabel.Font                   = Enum.Font.GothamMedium
		TabLabel.TextSize               = 14
		TabLabel.TextXAlignment         = Enum.TextXAlignment.Left
		TabLabel.Parent                 = TabButton

		local Page = Instance.new("ScrollingFrame")
		Page.Size                   = UDim2.new(1, 0, 1, 0)
		Page.BackgroundTransparency = 1
		Page.Visible                = false
		Page.ScrollBarThickness     = 4
		Page.ScrollBarImageColor3   = Colors.Accent
		Page.BorderSizePixel        = 0
		Page.AutomaticCanvasSize    = Enum.AutomaticSize.Y
		Page.CanvasSize             = UDim2.new(0, 0, 0, 0)
		Page.Parent                 = ContentContainer

		local PageList = Instance.new("UIListLayout", Page)
		PageList.Padding = UDim.new(0, 12)
		Instance.new("UIPadding", Page).PaddingTop = UDim.new(0, 15)
		Instance.new("UIPadding", Page).PaddingLeft = UDim.new(0, 15)
		Instance.new("UIPadding", Page).PaddingRight = UDim.new(0, 15)
		Instance.new("UIPadding", Page).PaddingBottom = UDim.new(0, 15)

		table.insert(AllTabs, {button = TabButton, label = TabLabel, page = Page})
		local myIndex = #AllTabs

		local function ActivateTab()
			for _, tab in ipairs(AllTabs) do
				tab.page.Visible = false
				tab.button.BackgroundColor3 = Colors.Element
				tab.label.TextColor3 = Colors.TextDim
			end
			Page.Visible = true
			TabButton.BackgroundColor3 = Colors.Accent
			TabLabel.TextColor3 = Colors.TextActive
			ActiveTab = myIndex
		end

		RegisterHover(TabButton,
			function()
				if ActiveTab ~= myIndex then
					TabButton.BackgroundColor3 = Colors.ElementHover
				end
			end,
			function()
				if ActiveTab ~= myIndex then
					TabButton.BackgroundColor3 = Colors.Element
				end
			end
		)

		TabButton.MouseButton1Click:Connect(ActivateTab)

		if #AllTabs == 1 then
			task.wait()
			ActivateTab()
		end

		-- ── Elements ────────────────────────────────────────
		local Elements = {}

		function Elements:CreateSection(SectionName)
			local SectionLabel = Instance.new("TextLabel")
			SectionLabel.Size                   = UDim2.new(1, 0, 0, 25)
			SectionLabel.BackgroundTransparency = 1
			SectionLabel.Text                   = SectionName
			SectionLabel.TextColor3             = Colors.Text
			SectionLabel.Font                   = Enum.Font.GothamBold
			SectionLabel.TextSize               = 15
			SectionLabel.TextXAlignment         = Enum.TextXAlignment.Left
			SectionLabel.Parent                 = Page
		end

		function Elements:CreateToggle(Text, Subtitle, Callback, Default)
			local Toggled = Default or false

			local ToggleFrame = Instance.new("Frame")
			ToggleFrame.Size             = UDim2.new(1, 0, 0, Subtitle and 55 or 45)
			ToggleFrame.BackgroundColor3 = Colors.Element
			ToggleFrame.Parent           = Page
			Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 10)

			local ToggleButton = Instance.new("TextButton")
			ToggleButton.Size                   = UDim2.new(1, 0, 1, 0)
			ToggleButton.BackgroundTransparency = 1
			ToggleButton.Text                   = ""
			ToggleButton.AutoButtonColor        = false
			ToggleButton.Parent                 = ToggleFrame

			local Label = Instance.new("TextLabel")
			Label.Size                   = UDim2.new(1, -70, 0, Subtitle and 20 or 45)
			Label.Position               = UDim2.new(0, 18, 0, Subtitle and 10 or 0)
			Label.BackgroundTransparency = 1
			Label.Text                   = Text
			Label.TextColor3             = Colors.Text
			Label.Font                   = Enum.Font.GothamMedium
			Label.TextSize               = 14
			Label.TextXAlignment         = Enum.TextXAlignment.Left
			Label.TextYAlignment         = Subtitle and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center
			Label.Parent                 = ToggleFrame

			if Subtitle then
				local SubLabel = Instance.new("TextLabel")
				SubLabel.Size                   = UDim2.new(1, -70, 0, 18)
				SubLabel.Position               = UDim2.new(0, 18, 0, 30)
				SubLabel.BackgroundTransparency = 1
				SubLabel.Text                   = Subtitle
				SubLabel.TextColor3             = Colors.TextDim
				SubLabel.Font                   = Enum.Font.Gotham
				SubLabel.TextSize               = 12
				SubLabel.TextXAlignment         = Enum.TextXAlignment.Left
				SubLabel.Parent                 = ToggleFrame
			end

			local Switch = Instance.new("Frame")
			Switch.Size             = UDim2.new(0, 46, 0, 26)
			Switch.Position         = UDim2.new(1, -60, 0.5, -13)
			Switch.BackgroundColor3 = Toggled and Colors.Accent or Color3.fromRGB(60, 60, 70)
			Switch.Parent           = ToggleFrame
			Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)

			local Knob = Instance.new("Frame")
			Knob.Size             = UDim2.new(0, 22, 0, 22)
			Knob.Position         = UDim2.new(0, Toggled and 22 or 2, 0, 2)
			Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Knob.Parent           = Switch
			Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

			local function UpdateToggle()
				Toggled = not Toggled
				TweenPlay(Switch, {BackgroundColor3 = Toggled and Colors.Accent or Color3.fromRGB(60, 60, 70)}, 0.2)
				TweenPlay(Knob, {Position = UDim2.new(0, Toggled and 22 or 2, 0, 2)}, 0.25, Enum.EasingStyle.Back)
				if Callback then Callback(Toggled) end
			end

			ToggleButton.MouseButton1Click:Connect(UpdateToggle)
		end

		function Elements:CreateSlider(Text, Min, Max, Callback, Default)
			local Value = Default or Min

			local SliderFrame = Instance.new("Frame")
			SliderFrame.Size             = UDim2.new(1, 0, 0, 60)
			SliderFrame.BackgroundColor3 = Colors.Element
			SliderFrame.Parent           = Page
			Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0, 10)

			local Title = Instance.new("TextLabel")
			Title.Size                   = UDim2.new(1, -80, 0, 20)
			Title.Position               = UDim2.new(0, 18, 0, 12)
			Title.BackgroundTransparency = 1
			Title.Text                   = Text
			Title.TextColor3             = Colors.Text
			Title.Font                   = Enum.Font.GothamMedium
			Title.TextSize               = 14
			Title.TextXAlignment         = Enum.TextXAlignment.Left
			Title.Parent                 = SliderFrame

			local ValueLabel = Instance.new("TextLabel")
			ValueLabel.Size                   = UDim2.new(0, 50, 0, 20)
			ValueLabel.Position               = UDim2.new(1, -65, 0, 12)
			ValueLabel.BackgroundTransparency = 1
			ValueLabel.Text                   = tostring(Value)
			ValueLabel.TextColor3             = Colors.TextDim
			ValueLabel.Font                   = Enum.Font.GothamMedium
			ValueLabel.TextSize               = 14
			ValueLabel.TextXAlignment         = Enum.TextXAlignment.Right
			ValueLabel.Parent                 = SliderFrame

			local Bar = Instance.new("Frame")
			Bar.Size             = UDim2.new(1, -36, 0, 6)
			Bar.Position         = UDim2.new(0, 18, 1, -20)
			Bar.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
			Bar.BorderSizePixel  = 0
			Bar.Parent           = SliderFrame
			Instance.new("UICorner", Bar).CornerRadius = UDim.new(1, 0)

			local Fill = Instance.new("Frame")
			Fill.Size             = UDim2.new(0, 0, 1, 0)
			Fill.BackgroundColor3 = Colors.Accent
			Fill.BorderSizePixel  = 0
			Fill.Parent           = Bar
			Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

			local function SetValue(pct)
				pct = math.clamp(pct, 0, 1)
				Fill.Size = UDim2.new(pct, 0, 1, 0)
				Value = math.round(Min + (Max - Min) * pct)
				ValueLabel.Text = tostring(Value)
				if Callback then Callback(Value) end
			end

			SetValue((Value - Min) / (Max - Min))

			local dragging = false

			Bar.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = true
					local mx = UserInputService:GetMouseLocation().X
					local pct = (mx - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X
					SetValue(pct)
				end
			end)

			UserInputService.InputChanged:Connect(function(input)
				if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
					local mx = UserInputService:GetMouseLocation().X
					local pct = (mx - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X
					SetValue(pct)
				end
			end)

			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = false
				end
			end)
		end

		function Elements:CreateButton(Text, Callback)
			local Button = Instance.new("TextButton")
			Button.Size             = UDim2.new(1, 0, 0, 45)
			Button.BackgroundColor3 = Colors.Element
			Button.Text             = Text
			Button.TextColor3       = Colors.Text
			Button.Font             = Enum.Font.GothamMedium
			Button.TextSize         = 14
			Button.AutoButtonColor  = false
			Button.Parent           = Page
			Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 10)

			RegisterHover(Button,
				function() Button.BackgroundColor3 = Colors.ElementHover end,
				function() Button.BackgroundColor3 = Colors.Element end
			)

			Button.MouseButton1Click:Connect(function()
				if Callback then Callback() end
			end)
		end

		return Elements
	end

	-- ── Open Animation ──────────────────────────────────────
	task.defer(function()
		TweenPlay(MainFrame, {Size = WindowSize}, 0.4, Enum.EasingStyle.Back)
		task.wait(0.5)
		Library:Notify("Welcome to " .. Title, 3, "success")
	end)

	return Tabs
end

return Library
