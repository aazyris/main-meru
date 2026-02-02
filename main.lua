local Library = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local Colors = {
	BG            = Color3.fromRGB(18, 18, 22),
	Panel         = Color3.fromRGB(26, 26, 32),
	Element       = Color3.fromRGB(34, 34, 42),
	ElementHover  = Color3.fromRGB(44, 44, 54),
	ElementActive = Color3.fromRGB(52, 52, 66),
	TitleBar      = Color3.fromRGB(22, 22, 28),
	Text          = Color3.fromRGB(220, 220, 228),
	TextDim       = Color3.fromRGB(130, 130, 140),
	TextActive    = Color3.fromRGB(255, 255, 255),
	Accent        = Color3.fromRGB(90, 160, 255),
}

local function Tween(instance, props, duration, style, direction)
	duration  = duration  or 0.18
	style     = style     or Enum.EasingStyle.Quart
	direction = direction or Enum.EasingDirection.Out
	TweenService:Create(instance, TweenInfo.new(duration, style, direction), props):Play()
end

function Library:CreateWindow()
	local Name = "Meru"

	-- Kill any previous instance cleanly
	local prev = CoreGui:FindFirstChild(Name .. "_Hub")
	if prev then prev:Destroy() end

	-- ── Hover system (CoreGui-safe) ─────────────────────────
	-- CoreGui doesn't fire MouseEntered/MouseLeaving.
	-- Instead we poll mouse position on every InputChanged and
	-- check which registered GuiObject the mouse is over.
	local HoverTargets = {}   -- { instance, onEnter, onLeave, inside }

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

	-- Single shared connection — fires for every mouse move
	UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
		for _, h in ipairs(HoverTargets) do
			if h.instance and h.instance.Parent then
				local over = IsMouseOver(h.instance)
				if over and not h.inside then
					h.inside = true
					h.onEnter()
				elseif not over and h.inside then
					h.inside = false
					h.onLeave()
				end
			end
		end
	end)

	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name         = Name .. "_Hub"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.Parent       = CoreGui

	-- ── Main Frame ──────────────────────────────────────────
	local WindowSize    = UDim2.new(0, 500, 0, 350)
	local MinimizedSize = UDim2.new(0, 500, 0, 35)
	local Minimized     = false

	local MainFrame = Instance.new("Frame")
	MainFrame.BackgroundColor3       = Colors.BG
	MainFrame.BackgroundTransparency = 0.08
	MainFrame.AnchorPoint           = Vector2.new(0.5, 0.5)
	MainFrame.Position              = UDim2.new(0.5, 0, 0.5, 0)
	MainFrame.Size                  = WindowSize
	MainFrame.ClipsDescendants      = true
	MainFrame.Parent                = ScreenGui
	Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

	-- ── Title Bar ───────────────────────────────────────────
	local TitleBar = Instance.new("Frame")
	TitleBar.Size             = UDim2.new(1, 0, 0, 35)
	TitleBar.BackgroundColor3 = Colors.TitleBar
	TitleBar.Parent           = MainFrame

	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.Size                   = UDim2.new(1, -80, 1, 0)
	TitleLabel.Position               = UDim2.new(0, 14, 0, 0)
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Text                   = Name
	TitleLabel.TextColor3             = Colors.TextActive
	TitleLabel.Font                   = Enum.Font.GothamBold
	TitleLabel.TextSize               = 15
	TitleLabel.TextXAlignment         = Enum.TextXAlignment.Left
	TitleLabel.Parent                 = TitleBar

	-- Minimize button
	local MinButton = Instance.new("TextButton")
	MinButton.Size                   = UDim2.new(0, 35, 1, 0)
	MinButton.Position               = UDim2.new(1, -70, 0, 0)
	MinButton.BackgroundTransparency = 1
	MinButton.Text                   = "─"
	MinButton.TextColor3             = Colors.TextDim
	MinButton.TextSize               = 18
	MinButton.Font                   = Enum.Font.Gotham
	MinButton.Parent                 = TitleBar

	-- Hover via poller
	RegisterHover(MinButton,
		function() MinButton.TextColor3 = Colors.TextActive end,
		function() MinButton.TextColor3 = Colors.TextDim end
	)

	MinButton.MouseButton1Click:Connect(function()
		Minimized = not Minimized
		Tween(MainFrame, { Size = Minimized and MinimizedSize or WindowSize }, 0.3, Enum.EasingStyle.Quart)
	end)

	-- Close button
	local CloseButton = Instance.new("TextButton")
	CloseButton.Size                   = UDim2.new(0, 35, 1, 0)
	CloseButton.Position               = UDim2.new(1, -35, 0, 0)
	CloseButton.BackgroundTransparency = 1
	CloseButton.Text                   = "×"
	CloseButton.TextColor3             = Colors.TextDim
	CloseButton.TextSize               = 20
	CloseButton.Font                   = Enum.Font.Gotham
	CloseButton.Parent                 = TitleBar

	-- Hover via poller
	RegisterHover(CloseButton,
		function() CloseButton.TextColor3 = Color3.fromRGB(255, 100, 100) end,
		function() CloseButton.TextColor3 = Colors.TextDim end
	)

	CloseButton.MouseButton1Click:Connect(function()
		Tween(MainFrame, { Size = UDim2.new(0, 0, 0, 0) }, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
		task.delay(0.25, function()
			if ScreenGui and ScreenGui.Parent then
				ScreenGui:Destroy()
			end
		end)
	end)

	-- ── Left Panel ──────────────────────────────────────────
	local LeftPanel = Instance.new("Frame")
	LeftPanel.BackgroundColor3 = Colors.Panel
	LeftPanel.Position         = UDim2.new(0, 0, 0, 35)
	LeftPanel.Size             = UDim2.new(0, 130, 1, -35)
	LeftPanel.Parent           = MainFrame

	local TabContainer = Instance.new("ScrollingFrame")
	TabContainer.Size                   = UDim2.new(1, 0, 1, 0)
	TabContainer.BackgroundTransparency = 1
	TabContainer.ScrollBarThickness     = 0
	TabContainer.AutomaticCanvasSize    = Enum.AutomaticSize.Y
	TabContainer.Parent                 = LeftPanel

	local TabList = Instance.new("UIListLayout")
	TabList.Padding             = UDim.new(0, 4)
	TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
	TabList.Parent              = TabContainer

	Instance.new("UIPadding", TabContainer).PaddingTop = UDim.new(0, 8)

	-- ── Content area ────────────────────────────────────────
	local ContentContainer = Instance.new("Frame")
	ContentContainer.Position               = UDim2.new(0, 130, 0, 35)
	ContentContainer.Size                   = UDim2.new(1, -130, 1, -35)
	ContentContainer.BackgroundTransparency = 1
	ContentContainer.Parent                 = MainFrame

	-- ── Drag ────────────────────────────────────────────────
	local Dragging, DragStart, StartPos

	TitleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			Dragging  = true
			DragStart = input.Position
			StartPos  = MainFrame.Position
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local Delta = input.Position - DragStart
			MainFrame.Position = UDim2.new(
				StartPos.X.Scale,  StartPos.X.Offset + Delta.X,
				StartPos.Y.Scale,  StartPos.Y.Offset + Delta.Y
			)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			Dragging = false
		end
	end)

	-- ── Tab system ──────────────────────────────────────────
	local Tabs = {}

	-- Central registry: every tab's references stored here so
	-- ActivateTab can reliably touch all of them.
	local AllTabs    = {}   -- [i] = { button, accent, page }
	local ActiveIndex = nil

	local function ActivateTab(index)
		if ActiveIndex == index then return end
		-- deactivate all
		for _, t in ipairs(AllTabs) do
			t.page.Visible                  = false
			t.button.TextColor3             = Colors.TextDim
			t.button.BackgroundColor3       = Colors.Element
			t.accent.BackgroundTransparency = 1
		end
		-- activate chosen
		local t = AllTabs[index]
		t.page.Visible                  = true
		t.button.TextColor3             = Colors.TextActive
		t.button.BackgroundColor3       = Colors.ElementHover
		t.accent.BackgroundTransparency = 0
		ActiveIndex = index
	end

	function Tabs:CreateTab(TabName)
		local TabButton = Instance.new("TextButton")
		TabButton.Size             = UDim2.new(0, 110, 0, 32)
		TabButton.BackgroundColor3 = Colors.Element
		TabButton.Text             = TabName
		TabButton.TextColor3       = Colors.TextDim
		TabButton.Font             = Enum.Font.Gotham
		TabButton.TextSize         = 13
		TabButton.Parent           = TabContainer
		Instance.new("UICorner", TabButton).CornerRadius = UDim.new(0, 6)

		-- Accent bar
		local AccentBar = Instance.new("Frame")
		AccentBar.Size                   = UDim2.new(0, 3, 1, -12)
		AccentBar.Position               = UDim2.new(0, 4, 0.5, 0)
		AccentBar.AnchorPoint            = Vector2.new(0, 0.5)
		AccentBar.BackgroundColor3       = Colors.Accent
		AccentBar.BackgroundTransparency = 1
		AccentBar.Parent                 = TabButton
		Instance.new("UICorner", AccentBar).CornerRadius = UDim.new(0, 2)

		-- Page
		local Page = Instance.new("ScrollingFrame")
		Page.Size                   = UDim2.new(1, 0, 1, 0)
		Page.BackgroundTransparency = 1
		Page.Visible                = false
		Page.ScrollBarThickness     = 3
		Page.ScrollBarImageColor3   = Colors.Accent
		Page.AutomaticCanvasSize    = Enum.AutomaticSize.Y
		Page.Parent                 = ContentContainer

		Instance.new("UIListLayout", Page).Padding = UDim.new(0, 6)
		Instance.new("UIPadding", Page).PaddingTop  = UDim.new(0, 8)

		-- Register & capture index
		table.insert(AllTabs, { button = TabButton, accent = AccentBar, page = Page })
		local myIndex = #AllTabs

		-- Hover via poller (only visually change when not the active tab)
		RegisterHover(TabButton,
			function() if ActiveIndex ~= myIndex then TabButton.BackgroundColor3 = Colors.ElementHover end end,
			function() if ActiveIndex ~= myIndex then TabButton.BackgroundColor3 = Colors.Element end end
		)

		-- Click
		TabButton.MouseButton1Click:Connect(function()
			ActivateTab(myIndex)
		end)

		-- Auto-select first tab created
		if #AllTabs == 1 then
			ActivateTab(1)
		end

		-- ── Elements ────────────────────────────────────────
		local Elements = {}

		function Elements:CreateButton(Text, Callback)
			local Button = Instance.new("TextButton")
			Button.Size             = UDim2.new(1, -16, 0, 36)
			Button.BackgroundColor3 = Colors.Element
			Button.Text             = Text
			Button.TextColor3       = Colors.Text
			Button.Font             = Enum.Font.Gotham
			Button.TextSize         = 13
			Button.TextXAlignment   = Enum.TextXAlignment.Left
			Button.ClipsDescendants = true
			Button.Parent           = Page
			Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 6)
			Instance.new("UIPadding", Button).PaddingLeft  = UDim.new(0, 14)

			-- Hover via poller
			RegisterHover(Button,
				function() Button.BackgroundColor3 = Colors.ElementHover end,
				function() Button.BackgroundColor3 = Colors.Element end
			)

			-- Press flash
			Button.MouseButton1Down:Connect(function()
				Button.BackgroundColor3 = Colors.ElementActive
			end)
			Button.MouseButton1Click:Connect(function()
				Button.BackgroundColor3 = Colors.ElementHover
				if Callback then Callback() end
			end)
		end

		function Elements:CreateSlider(Text, Min, Max, Callback, Default)
			local Value = Default or Min

			local SliderFrame = Instance.new("Frame")
			SliderFrame.Size             = UDim2.new(1, -16, 0, 52)
			SliderFrame.BackgroundColor3 = Colors.Element
			SliderFrame.ClipsDescendants = true
			SliderFrame.Parent           = Page
			Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0, 6)

			-- Label
			local Title = Instance.new("TextLabel")
			Title.Size                   = UDim2.new(1, -60, 0, 20)
			Title.Position               = UDim2.new(0, 12, 0, 6)
			Title.BackgroundTransparency = 1
			Title.Text                   = Text
			Title.TextColor3             = Colors.Text
			Title.Font                   = Enum.Font.Gotham
			Title.TextSize               = 12
			Title.TextXAlignment         = Enum.TextXAlignment.Left
			Title.Parent                 = SliderFrame

			-- Value readout
			local ValueLabel = Instance.new("TextLabel")
			ValueLabel.Size                   = UDim2.new(0, 44, 0, 20)
			ValueLabel.Position               = UDim2.new(1, -48, 0, 6)
			ValueLabel.BackgroundTransparency = 1
			ValueLabel.Text                   = tostring(Value)
			ValueLabel.TextColor3             = Colors.Accent
			ValueLabel.Font                   = Enum.Font.GothamBold
			ValueLabel.TextSize               = 12
			ValueLabel.TextXAlignment         = Enum.TextXAlignment.Right
			ValueLabel.Parent                 = SliderFrame

			-- Track
			local Bar = Instance.new("Frame")
			Bar.Size             = UDim2.new(1, -24, 0, 4)
			Bar.Position         = UDim2.new(0, 12, 0, 36)
			Bar.BackgroundColor3 = Color3.fromRGB(50, 50, 58)
			Bar.Parent           = SliderFrame
			Instance.new("UICorner", Bar).CornerRadius = UDim.new(1, 0)

			-- Fill
			local Fill = Instance.new("Frame")
			Fill.Size             = UDim2.new(0, 0, 1, 0)
			Fill.BackgroundColor3 = Colors.Accent
			Fill.Parent           = Bar
			Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

			-- Thumb
			local Thumb = Instance.new("Frame")
			Thumb.Size             = UDim2.new(0, 14, 0, 14)
			Thumb.AnchorPoint      = Vector2.new(0.5, 0.5)
			Thumb.Position         = UDim2.new(0, 0, 0.5, 0)
			Thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Thumb.ZIndex           = 2
			Thumb.Parent           = Bar
			Instance.new("UICorner", Thumb).CornerRadius = UDim.new(1, 0)

			-- ── Slider logic ────────────────────────────────
			local function SetPercent(pct)
				pct = math.clamp(pct, 0, 1)
				Fill.Size      = UDim2.new(pct, 0, 1, 0)
				Thumb.Position = UDim2.new(pct, 0, 0.5, 0)
				Value          = math.round(Min + (Max - Min) * pct)
				ValueLabel.Text = tostring(Value)
				if Callback then Callback(Value) end
			end

			SetPercent((Value - Min) / (Max - Min))   -- draw initial state

			local function PercentFromMouse()
				local mx = UserInputService:GetMouseLocation().X
				local bx = Bar.AbsolutePosition.X
				local bw = Bar.AbsoluteSize.X
				if bw == 0 then return 0 end
				return (mx - bx) / bw
			end

			local sDragging = false

			-- InputBegan on Bar (not the whole frame) so the
			-- mouse position actually lines up on first click.
			Bar.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					sDragging = true
					SetPercent(PercentFromMouse())
				end
			end)

			UserInputService.InputChanged:Connect(function(input)
				if sDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
					SetPercent(PercentFromMouse())
				end
			end)

			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					sDragging = false
				end
			end)
		end

		return Elements
	end

	return Tabs
end

return Library
