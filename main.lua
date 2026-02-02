local Library = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- Shared palette
local Colors = {
	BG = Color3.fromRGB(18, 18, 22),
	Panel = Color3.fromRGB(26, 26, 32),
	Element = Color3.fromRGB(34, 34, 42),
	ElementHover = Color3.fromRGB(44, 44, 54),
	ElementActive = Color3.fromRGB(52, 52, 66),
	TitleBar = Color3.fromRGB(22, 22, 28),
	Text = Color3.fromRGB(220, 220, 228),
	TextDim = Color3.fromRGB(130, 130, 140),
	TextActive = Color3.fromRGB(255, 255, 255),
	Accent = Color3.fromRGB(90, 160, 255),
	AccentHover = Color3.fromRGB(110, 180, 255),
}

local function Tween(instance, props, duration, style, direction)
	duration = duration or 0.18
	style = style or Enum.EasingStyle.Quart
	direction = direction or Enum.EasingDirection.Out
	TweenService:Create(instance, TweenInfo.new(duration, style, direction), props):Play()
end

-- Hover helper: tweens BackgroundColor3 in/out
local function AddHover(button, normal, hover)
	button.MouseEntered:Connect(function() Tween(button, { BackgroundColor3 = hover }, 0.12) end)
	button.MouseLeaving:Connect(function() Tween(button, { BackgroundColor3 = normal }, 0.12) end)
end

function Library:CreateWindow()
	local Name = "Meru"

	-- Guard: destroy any existing window first
	if CoreGui:FindFirstChild(Name .. "_Hub") then
		CoreGui:FindFirstChild(Name .. "_Hub"):Destroy()
	end

	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Parent = CoreGui
	ScreenGui.Name = Name .. "_Hub"
	ScreenGui.ResetOnSpawn = false

	-- ── Main Frame ──────────────────────────────────────────
	local WindowSize = UDim2.new(0, 500, 0, 350)
	local MinimizedSize = UDim2.new(0, 500, 0, 35)
	local Minimized = false

	local MainFrame = Instance.new("Frame")
	MainFrame.Parent = ScreenGui
	MainFrame.BackgroundColor3 = Colors.BG
	MainFrame.BackgroundTransparency = 0.08
	MainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
	MainFrame.Size = UDim2.new(0, 0, 0, 0) -- start collapsed for open animation
	MainFrame.ClipsDescendants = true
	MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

	-- Drop shadow via ImageLabel
	local Shadow = Instance.new("ImageLabel")
	Shadow.Parent = ScreenGui
	Shadow.BackgroundTransparency = 1
	Shadow.Size = UDim2.new(0, 540, 0, 390)
	Shadow.Position = UDim2.new(0.5, -270, 0.5, -195)
	Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
	Shadow.Image = "rbxassetid://5454449833" -- Roblox stock shadow
	Shadow.ImageTransparency = 0.55
	Shadow.ZIndex = -1

	-- Animate shadow along with frame
	local function SyncShadow()
		Shadow.Size = UDim2.new(0, MainFrame.Size.X.Offset + 40, 0, MainFrame.Size.Y.Offset + 40)
		Shadow.Position = UDim2.new(
			MainFrame.Position.X.Scale, MainFrame.Position.X.Offset - 20,
			MainFrame.Position.Y.Scale, MainFrame.Position.Y.Offset - 20
		)
	end

	-- Opening animation
	task.defer(function()
		Tween(MainFrame, { Size = WindowSize }, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		task.delay(0.35, SyncShadow)
	end)

	-- ── Title Bar ───────────────────────────────────────────
	local TitleBar = Instance.new("Frame")
	TitleBar.Parent = MainFrame
	TitleBar.Size = UDim2.new(1, 0, 0, 35)
	TitleBar.BackgroundColor3 = Colors.TitleBar

	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.Parent = TitleBar
	TitleLabel.Size = UDim2.new(1, -80, 1, 0)
	TitleLabel.Position = UDim2.new(0, 14, 0, 0)
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Text = Name
	TitleLabel.TextColor3 = Colors.TextActive
	TitleLabel.Font = Enum.Font.GothamBold
	TitleLabel.TextSize = 15
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

	-- Minimize button
	local MinButton = Instance.new("TextButton")
	MinButton.Parent = TitleBar
	MinButton.Size = UDim2.new(0, 35, 1, 0)
	MinButton.Position = UDim2.new(1, -70, 0, 0)
	MinButton.BackgroundTransparency = 1
	MinButton.Text = "─"
	MinButton.TextColor3 = Colors.TextDim
	MinButton.TextSize = 18
	MinButton.Font = Enum.Font.Gotham
	AddHover(MinButton, Color3.new(0,0,0), Colors.ElementActive) -- transparent hover tint handled via text
	MinButton.MouseEntered:Connect(function() Tween(MinButton, { TextColor3 = Colors.TextActive }, 0.1) end)
	MinButton.MouseLeaving:Connect(function() Tween(MinButton, { TextColor3 = Colors.TextDim }, 0.1) end)

	MinButton.MouseButton1Click:Connect(function()
		Minimized = not Minimized
		local target = Minimized and MinimizedSize or WindowSize
		Tween(MainFrame, { Size = target }, 0.3, Enum.EasingStyle.Quart)
		task.delay(0.3, SyncShadow)
	end)

	-- Close button
	local CloseButton = Instance.new("TextButton")
	CloseButton.Parent = TitleBar
	CloseButton.Size = UDim2.new(0, 35, 1, 0)
	CloseButton.Position = UDim2.new(1, -35, 0, 0)
	CloseButton.BackgroundTransparency = 1
	CloseButton.Text = "×"
	CloseButton.TextColor3 = Colors.TextDim
	CloseButton.TextSize = 20
	CloseButton.Font = Enum.Font.Gotham
	CloseButton.MouseEntered:Connect(function() Tween(CloseButton, { TextColor3 = Color3.fromRGB(255, 100, 100) }, 0.1) end)
	CloseButton.MouseLeaving:Connect(function() Tween(CloseButton, { TextColor3 = Colors.TextDim }, 0.1) end)
	CloseButton.MouseButton1Click:Connect(function()
		Tween(MainFrame, { Size = UDim2.new(0, 0, 0, 0) }, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
		task.delay(0.22, function() ScreenGui:Destroy() end)
	end)

	-- ── Left Panel (tabs) ───────────────────────────────────
	local LeftPanel = Instance.new("Frame")
	LeftPanel.Parent = MainFrame
	LeftPanel.BackgroundColor3 = Colors.Panel
	LeftPanel.Position = UDim2.new(0, 0, 0, 35)
	LeftPanel.Size = UDim2.new(0, 130, 1, -35)

	local TabContainer = Instance.new("ScrollingFrame")
	TabContainer.Parent = LeftPanel
	TabContainer.Size = UDim2.new(1, 0, 1, 0)
	TabContainer.Position = UDim2.new(0, 0, 0, 0)
	TabContainer.BackgroundTransparency = 1
	TabContainer.ScrollBarThickness = 0
	TabContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
	local TabList = Instance.new("UIListLayout", TabContainer)
	TabList.Padding = UDim.new(0, 4)
	TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
	Instance.new("UIPadding", TabContainer).PaddingTop = UDim.new(0, 8)

	-- ── Content area ────────────────────────────────────────
	local ContentContainer = Instance.new("Frame")
	ContentContainer.Parent = MainFrame
	ContentContainer.Position = UDim2.new(0, 130, 0, 35)
	ContentContainer.Size = UDim2.new(1, -130, 1, -35)
	ContentContainer.BackgroundTransparency = 1

	-- ── Drag logic (no pop-scale, just smooth move + shadow sync) ──
	local Dragging, DragStart, StartPos
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
			SyncShadow()
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 and Dragging then
			Dragging = false
		end
	end)

	-- ── Tab system ──────────────────────────────────────────
	local Tabs = {}
	local ActiveTab = nil

	function Tabs:CreateTab(TabName)
		local TabButton = Instance.new("TextButton")
		TabButton.Parent = TabContainer
		TabButton.Size = UDim2.new(0, 110, 0, 32)
		TabButton.BackgroundColor3 = Colors.Element
		TabButton.Text = TabName
		TabButton.TextColor3 = Colors.TextDim
		TabButton.Font = Enum.Font.Gotham
		TabButton.TextSize = 13
		Instance.new("UICorner", TabButton).CornerRadius = UDim.new(0, 6)

		-- Subtle left-side accent bar (inactive = transparent)
		local Accent = Instance.new("Frame")
		Accent.Parent = TabButton
		Accent.Size = UDim2.new(0, 3, 1, -12)
		Accent.Position = UDim2.new(0, 4, 0.5, 0)
		Accent.AnchorPoint = Vector2.new(0, 0.5)
		Accent.BackgroundColor3 = Colors.Accent
		Accent.BackgroundTransparency = 1
		Instance.new("UICorner", Accent).CornerRadius = UDim.new(0, 2)

		-- Page (content scroll)
		local Page = Instance.new("ScrollingFrame")
		Page.Parent = ContentContainer
		Page.Size = UDim2.new(1, 0, 1, 0)
		Page.BackgroundTransparency = 1
		Page.Visible = false
		Page.ScrollBarThickness = 3
		Page.ScrollBarImageColor3 = Colors.Accent
		Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
		local PageList = Instance.new("UIListLayout", Page)
		PageList.Padding = UDim.new(0, 6)
		Instance.new("UIPadding", Page).PaddingTop = UDim.new(0, 8)

		local function SetActive(isActive)
			if isActive then
				TabButton.TextColor3 = Colors.TextActive
				TabButton.BackgroundColor3 = Colors.ElementHover
				Accent.BackgroundTransparency = 0
			else
				TabButton.TextColor3 = Colors.TextDim
				TabButton.BackgroundColor3 = Colors.Element
				Accent.BackgroundTransparency = 1
			end
		end

		-- Hover (only when not active)
		TabButton.MouseEntered:Connect(function()
			if ActiveTab ~= TabButton then
				Tween(TabButton, { BackgroundColor3 = Colors.ElementHover }, 0.1)
			end
		end)
		TabButton.MouseLeaving:Connect(function()
			if ActiveTab ~= TabButton then
				Tween(TabButton, { BackgroundColor3 = Colors.Element }, 0.1)
			end
		end)

		TabButton.MouseButton1Click:Connect(function()
			if ActiveTab == TabButton then return end
			-- Deactivate all
			for _, child in pairs(ContentContainer:GetChildren()) do
				if child:IsA("ScrollingFrame") then child.Visible = false end
			end
			for _, child in pairs(TabContainer:GetChildren()) do
				if child:IsA("TextButton") then
					child.TextColor3 = Colors.TextDim
					child.BackgroundColor3 = Colors.Element
					-- hide accent bar
					local acc = child:FindFirstChild("Frame")
					if acc then acc.BackgroundTransparency = 1 end
				end
			end
			-- Activate this one
			Page.Visible = true
			SetActive(true)
			ActiveTab = TabButton
		end)

		-- Auto-select first tab
		if ActiveTab == nil then
			Page.Visible = true
			SetActive(true)
			ActiveTab = TabButton
		end

		-- ── Elements ────────────────────────────────────────
		local Elements = {}

		function Elements:CreateButton(Text, Callback)
			local Button = Instance.new("TextButton")
			Button.Parent = Page
			Button.Size = UDim2.new(1, -16, 0, 36)
			Button.BackgroundColor3 = Colors.Element
			Button.Text = Text
			Button.TextColor3 = Colors.Text
			Button.Font = Enum.Font.Gotham
			Button.TextSize = 13
			Button.TextXAlignment = Enum.TextXAlignment.Left
			Button.ClipsDescendants = true
			Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 6)
			Instance.new("UIPadding", Button).PaddingLeft = UDim.new(0, 14)
			AddHover(Button, Colors.Element, Colors.ElementHover)

			-- Press flash
			Button.MouseButton1Down:Connect(function()
				Tween(Button, { BackgroundColor3 = Colors.ElementActive }, 0.06)
			end)
			Button.MouseButton1Up:Connect(function()
				Tween(Button, { BackgroundColor3 = Colors.ElementHover }, 0.1)
				if Callback then Callback() end
			end)
			-- Use Up instead of Click so the flash is visible
			Button.MouseButton1Click:Connect(function() end) -- block default
		end

		function Elements:CreateSlider(Text, Min, Max, Callback, Default)
			local Value = Default or Min

			local SliderFrame = Instance.new("Frame")
			SliderFrame.Parent = Page
			SliderFrame.Size = UDim2.new(1, -16, 0, 52)
			SliderFrame.BackgroundColor3 = Colors.Element
			SliderFrame.ClipsDescendants = true
			Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0, 6)

			local Title = Instance.new("TextLabel")
			Title.Parent = SliderFrame
			Title.Size = UDim2.new(1, -20, 0, 20)
			Title.Position = UDim2.new(0, 12, 0, 6)
			Title.BackgroundTransparency = 1
			Title.Text = Text .. ": " .. tostring(Value)
			Title.TextColor3 = Colors.Text
			Title.Font = Enum.Font.Gotham
			Title.TextSize = 12
			Title.TextXAlignment = Enum.TextXAlignment.Left

			-- Value label on the right
			local ValueLabel = Instance.new("TextLabel")
			ValueLabel.Parent = SliderFrame
			ValueLabel.Size = UDim2.new(0, 40, 0, 20)
			ValueLabel.Position = UDim2.new(1, -46, 0, 6)
			ValueLabel.BackgroundTransparency = 1
			ValueLabel.Text = tostring(Value)
			ValueLabel.TextColor3 = Colors.Accent
			ValueLabel.Font = Enum.Font.GothamBold
			ValueLabel.TextSize = 12
			ValueLabel.TextXAlignment = Enum.TextXAlignment.Right

			-- Track bar
			local Bar = Instance.new("Frame")
			Bar.Parent = SliderFrame
			Bar.Size = UDim2.new(1, -24, 0, 4)
			Bar.Position = UDim2.new(0, 12, 0, 36)
			Bar.BackgroundColor3 = Color3.fromRGB(50, 50, 58)
			Instance.new("UICorner", Bar).CornerRadius = UDim.new(1, 0)

			-- Fill
			local Fill = Instance.new("Frame")
			Fill.Parent = Bar
			Fill.Size = UDim2.new(0, 0, 1, 0)
			Fill.BackgroundColor3 = Colors.Accent
			Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

			-- Draggable circle (thumb)
			local Thumb = Instance.new("Frame")
			Thumb.Parent = Bar
			Thumb.Size = UDim2.new(0, 14, 0, 14)
			Thumb.AnchorPoint = Vector2.new(0.5, 0.5)
			Thumb.Position = UDim2.new(0, 0, 0.5, 0)
			Thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Thumb.ZIndex = 2
			Instance.new("UICorner", Thumb).CornerRadius = UDim.new(1, 0)

			-- Glow on thumb (ImageLabel trick — simple white shadow)
			local ThumbGlow = Instance.new("Frame")
			ThumbGlow.Parent = Thumb
			ThumbGlow.Size = UDim2.new(1, 6, 1, 6)
			ThumbGlow.AnchorPoint = Vector2.new(0.5, 0.5)
			ThumbGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
			ThumbGlow.BackgroundColor3 = Colors.Accent
			ThumbGlow.BackgroundTransparency = 0.6
			ThumbGlow.ZIndex = 1
			Instance.new("UICorner", ThumbGlow).CornerRadius = UDim.new(1, 0)

			local function SetPercent(pct)
				pct = math.clamp(pct, 0, 1)
				Fill.Size = UDim2.new(pct, 0, 1, 0)
				Thumb.Position = UDim2.new(pct, 0, 0.5, 0)
				Value = math.round(Min + (Max - Min) * pct)
				Title.Text = Text .. ": " .. tostring(Value)
				ValueLabel.Text = tostring(Value)
				if Callback then Callback(Value) end
			end

			-- Set initial position
			SetPercent((Value - Min) / (Max - Min))

			local function GetPercent()
				local mx = UserInputService:GetMouseLocation().X
				local bx = Bar.AbsolutePosition.X
				local bw = Bar.AbsoluteSize.X
				return (mx - bx) / bw
			end

			local sDragging = false

			local function OnStart()
				sDragging = true
				SetPercent(GetPercent())
			end

			SliderFrame.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					OnStart()
				end
			end)

			UserInputService.InputChanged:Connect(function(input)
				if sDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
					SetPercent(GetPercent())
				end
			end)

			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 and sDragging then
					sDragging = false
				end
			end)
		end

		return Elements
	end

	return Tabs
end

return Library
