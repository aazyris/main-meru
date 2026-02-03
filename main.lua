local Library = {}
local TweenService    = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService      = game:GetService("RunService")
local CoreGui         = game:GetService("CoreGui")

-- ── Palette ─────────────────────────────────────────────────
local Colors = {
	BG            = Color3.fromRGB(15, 15, 15),
	Panel         = Color3.fromRGB(25, 25, 25),
	Element       = Color3.fromRGB(35, 35, 35),
	ElementHover  = Color3.fromRGB(45, 45, 45),
	ElementActive = Color3.fromRGB(55, 55, 55),
	TitleBar      = Color3.fromRGB(20, 20, 20),
	Text          = Color3.fromRGB(240, 240, 240),
	TextDim       = Color3.fromRGB(140, 140, 140),
	TextActive    = Color3.fromRGB(255, 255, 255),
	Accent        = Color3.fromRGB(80, 80, 80),
	Ripple        = Color3.fromRGB(100, 100, 100),
}

-- ── Helpers ─────────────────────────────────────────────────
local function Tween(instance, props, duration, style, direction)
	duration  = duration  or 0.18
	style     = style     or Enum.EasingStyle.Quart
	direction = direction or Enum.EasingDirection.Out
	return TweenService:Create(instance, TweenInfo.new(duration, style, direction), props)
end

-- plays and returns the tween (so caller can :Wait() if needed)
local function TweenPlay(instance, props, duration, style, direction)
	local t = Tween(instance, props, duration, style, direction)
	t:Play()
	return t
end

-- ── Notification System ─────────────────────────────────────
local Notifications = {}
local NotificationQueue = {}

function Library:Notify(Text, Duration, Type)
	Duration = Duration or 3
	Type = Type or "info" -- info, success, warning, error
	
	local Notification = Instance.new("Frame")
	Notification.Size             = UDim2.new(0, 320, 0, 70)
	Notification.Position         = UDim2.new(1, 340, 0, 20)
	Notification.BackgroundColor3 = Type == "success" and Color3.fromRGB(40, 120, 40) 
	                               or Type == "warning" and Color3.fromRGB(180, 120, 0)
	                               or Type == "error" and Color3.fromRGB(180, 40, 40)
	                               or Colors.Element
	Notification.Parent           = ScreenGui
	Instance.new("UICorner", Notification).CornerRadius = UDim.new(0, 8)
	Instance.new("UIStroke", Notification).Color = Colors.Accent
	Instance.new("UIStroke", Notification).Thickness = 1

	-- Icon background
	local IconBg = Instance.new("Frame")
	IconBg.Size             = UDim2.new(0, 32, 0, 32)
	IconBg.Position         = UDim2.new(0, 12, 0.5, -16)
	IconBg.BackgroundColor3 = Type == "success" and Color3.fromRGB(60, 140, 60)
	                         or Type == "warning" and Color3.fromRGB(200, 140, 20)
	                         or Type == "error" and Color3.fromRGB(200, 60, 60)
	                         or Colors.Accent
	IconBg.Parent           = Notification
	Instance.new("UICorner", IconBg).CornerRadius = UDim.new(1, 0)

	-- Icon
	local Icon = Instance.new("TextLabel")
	Icon.Size             = UDim2.new(1, 0, 1, 0)
	Icon.BackgroundTransparency = 1
	Icon.Text             = Type == "success" and "✓" 
	                     or Type == "warning" and "!"
	                     or Type == "error" and "×"
	                     or "i"
	Icon.TextColor3       = Colors.TextActive
	Icon.Font             = Enum.Font.GothamBold
	Icon.TextSize         = 18
	Icon.Parent           = IconBg

	-- Title
	local Title = Instance.new("TextLabel")
	Title.Size                   = UDim2.new(1, -60, 0, 20)
	Title.Position               = UDim2.new(0, 55, 0, 8)
	Title.BackgroundTransparency = 1
	Title.Text                   = Type == "success" and "Success"
	                         or Type == "warning" and "Warning"
	                         or Type == "error" and "Error"
	                         or "Information"
	Title.TextColor3             = Colors.TextActive
	Title.Font                   = Enum.Font.GothamBold
	Title.TextSize               = 14
	Title.TextXAlignment         = Enum.TextXAlignment.Left
	Title.Parent                 = Notification

	-- Message
	local Message = Instance.new("TextLabel")
	Message.Size                   = UDim2.new(1, -60, 0, 30)
	Message.Position               = UDim2.new(0, 55, 0, 28)
	Message.BackgroundTransparency = 1
	Message.Text                   = Text
	Message.TextColor3             = Colors.Text
	Message.Font                   = Enum.Font.Gotham
	Message.TextSize               = 12
	Message.TextXAlignment         = Enum.TextXAlignment.Left
	Message.TextYAlignment         = Enum.TextYAlignment.Top
	Message.TextWrapped           = true
	Message.Parent                 = Notification

	-- Progress bar
	local Progress = Instance.new("Frame")
	Progress.Size             = UDim2.new(1, 0, 0, 2)
	Progress.Position         = UDim2.new(0, 0, 1, -2)
	Progress.BackgroundColor3 = Colors.Accent
	Progress.Parent           = Notification

	-- Slide in animation
	TweenPlay(Notification, { Position = UDim2.new(1, -340, 0, 20) }, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

	-- Progress bar animation
	TweenPlay(Progress, { Size = UDim2.new(0, 0, 0, 2) }, Duration, Enum.EasingStyle.Linear)

	-- Auto remove
	task.delay(Duration, function()
		if Notification and Notification.Parent then
			TweenPlay(Notification, { Position = UDim2.new(1, 340, 0, 20) }, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
			task.delay(0.35, function()
				if Notification and Notification.Parent then Notification:Destroy() end
			end)
		end
	end)
end

-- ── Detached Circular Menu ─────────────────────────────────────
	local CircleMenu = {
		Expanded = false,
		Buttons = {},
		Dragging = false,
		DragStart = nil,
		StartPos = nil,
		CurrentPos = Vector2.new(100, 100),
		TargetPos = Vector2.new(100, 100)
	}

	-- Main circle button
	local MainCircle = Instance.new("TextButton")
	MainCircle.Size             = UDim2.new(0, 60, 0, 60)
	MainCircle.Position         = UDim2.new(0, CircleMenu.CurrentPos.X, 0, CircleMenu.CurrentPos.Y)
	MainCircle.BackgroundColor3 = Colors.Accent
	MainCircle.AnchorPoint      = Vector2.new(0.5, 0.5)
	MainCircle.Parent           = ScreenGui
	MainCircle.Text             = ""
	Instance.new("UICorner", MainCircle).CornerRadius = UDim.new(1, 0)

	-- Main button icon
	local MainIcon = Instance.new("TextLabel")
	MainIcon.Size             = UDim2.new(1, 0, 1, 0)
	MainIcon.BackgroundTransparency = 1
	MainIcon.Text             = "☰"
	MainIcon.TextColor3       = Colors.TextActive
	MainIcon.Font             = Enum.Font.GothamBold
	MainIcon.TextSize         = 24
	MainIcon.Parent           = MainCircle

	-- Drag functionality for main circle
	MainCircle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			CircleMenu.Dragging = true
			CircleMenu.DragStart = input.Position
			CircleMenu.StartPos = CircleMenu.CurrentPos
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if CircleMenu.Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - CircleMenu.DragStart
			CircleMenu.TargetPos = Vector2.new(
				CircleMenu.StartPos.X + delta.X,
				CircleMenu.StartPos.Y + delta.Y
			)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 and CircleMenu.Dragging then
			CircleMenu.Dragging = false
		end
	end)

	-- Smooth drag animation
	RunService.Heartbeat:Connect(function(dt)
		if not CircleMenu.Dragging then
			CircleMenu.CurrentPos = CircleMenu.CurrentPos:Lerp(CircleMenu.TargetPos, 0.15)
			MainCircle.Position = UDim2.new(0, CircleMenu.CurrentPos.X, 0, CircleMenu.CurrentPos.Y)
		else
			MainCircle.Position = UDim2.new(0, CircleMenu.TargetPos.X, 0, CircleMenu.TargetPos.Y)
		end
	end)

	-- Create expandable buttons
	local function CreateCircleButton(index, total, text, callback)
		local angle = (index - 1) * (2 * math.pi / total) - math.pi/2
		local radius = 80
		
		local Button = Instance.new("TextButton")
		Button.Size             = UDim2.new(0, 50, 0, 50)
		Button.Position         = UDim2.new(0, 0, 0, 0)
		Button.BackgroundColor3 = Colors.ElementHover
		Button.AnchorPoint      = Vector2.new(0.5, 0.5)
		Button.Visible          = false
		Button.Text             = ""
		Button.Parent           = ScreenGui
		Instance.new("UICorner", Button).CornerRadius = UDim.new(1, 0)

		local Icon = Instance.new("TextLabel")
		Icon.Size             = UDim2.new(1, 0, 1, 0)
		Icon.BackgroundTransparency = 1
		Icon.Text             = text
		Icon.TextColor3       = Colors.TextActive
		Icon.Font             = Enum.Font.GothamBold
		Icon.TextSize         = 16
		Icon.Parent           = Button

		Button.MouseButton1Click:Connect(callback)
		table.insert(CircleMenu.Buttons, {Button = Button, Angle = angle, Radius = radius})
	end

	-- Add some example buttons
	CreateCircleButton(1, 4, "C", function() Library:Notify("Combat tab", 2, "info") end)
	CreateCircleButton(2, 4, "M", function() Library:Notify("Movement tab", 2, "info") end)
	CreateCircleButton(3, 4, "V", function() Library:Notify("Visual tab", 2, "info") end)
	CreateCircleButton(4, 4, "S", function() Library:Notify("Settings tab", 2, "info") end)

	-- Toggle expand/collapse
	MainCircle.MouseButton1Click:Connect(function()
		if not CircleMenu.Dragging then
			CircleMenu.Expanded = not CircleMenu.Expanded
			
			if CircleMenu.Expanded then
				-- Expand animation
				for i, buttonData in ipairs(CircleMenu.Buttons) do
					buttonData.Button.Visible = true
					local targetX = math.cos(buttonData.Angle) * buttonData.Radius
					local targetY = math.sin(buttonData.Angle) * buttonData.Radius
					
					TweenPlay(buttonData.Button, {
						Position = UDim2.new(0, CircleMenu.CurrentPos.X + targetX, 0, CircleMenu.CurrentPos.Y + targetY),
						Size = UDim2.new(0, 50, 0, 50)
					}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
				end
				MainIcon.Text = "×"
			else
				-- Collapse animation
				for _, buttonData in ipairs(CircleMenu.Buttons) do
					TweenPlay(buttonData.Button, {
						Position = UDim2.new(0, CircleMenu.CurrentPos.X, 0, CircleMenu.CurrentPos.Y),
						Size = UDim2.new(0, 0, 0, 0)
					}, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
					
					task.delay(0.2, function()
						buttonData.Button.Visible = false
					end)
				end
				MainIcon.Text = "☰"
			end
		end
	end)

	function Library:CreateWindow()
	local Name = "Meru"

	-- kill previous
	local prev = CoreGui:FindFirstChild(Name .. "_Hub")
	if prev then prev:Destroy() end

	-- ── Hover poller (CoreGui-safe) ─────────────────────────
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
	ScreenGui.Name         = Name .. "_Hub"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.Parent       = CoreGui

	-- ── Main Frame ──────────────────────────────────────────
	local WindowSize    = UDim2.new(0, 600, 0, 450)
	local MinimizedSize = UDim2.new(0, 600, 0, 35)
	local Minimized     = false
	local Resizing      = false
	local ResizeStart   = nil
	local StartSize     = nil

	local MainFrame = Instance.new("Frame")
	MainFrame.BackgroundColor3       = Colors.BG
	MainFrame.BackgroundTransparency = 0.08
	MainFrame.AnchorPoint           = Vector2.new(0.5, 0.5)
	MainFrame.Position              = UDim2.new(0.5, 0, 0.5, 0)
	MainFrame.Size                  = UDim2.new(0, 0, 0, 0)   -- starts at zero → open anim
	MainFrame.ClipsDescendants      = true
	MainFrame.Parent                = ScreenGui
	Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

	-- ── Resize Handle ─────────────────────────────────────────
	local ResizeHandle = Instance.new("Frame")
	ResizeHandle.Size             = UDim2.new(0, 20, 0, 20)
	ResizeHandle.Position         = UDim2.new(1, -20, 1, -20)
	ResizeHandle.BackgroundColor3 = Colors.Accent
	ResizeHandle.BackgroundTransparency = 0.7
	ResizeHandle.Parent           = MainFrame
	Instance.new("UICorner", ResizeHandle).CornerRadius = UDim.new(0, 0, 0, 4, 0, 0)

	-- Resize icon
	local ResizeIcon = Instance.new("TextLabel")
	ResizeIcon.Size             = UDim2.new(1, 0, 1, 0)
	ResizeIcon.BackgroundTransparency = 1
	ResizeIcon.Text             = "⤡"
	ResizeIcon.TextColor3       = Colors.TextActive
	ResizeIcon.Font             = Enum.Font.Gotham
	ResizeIcon.TextSize         = 12
	ResizeIcon.Parent           = ResizeHandle

	-- ── Title Bar ───────────────────────────────────────────
	local TitleBar = Instance.new("Frame")
	TitleBar.Size             = UDim2.new(1, 0, 0, 35)
	TitleBar.BackgroundColor3 = Colors.TitleBar
	TitleBar.Parent           = MainFrame

	-- thin accent line along the bottom edge of the title bar
	local TitleSep = Instance.new("Frame")
	TitleSep.Size             = UDim2.new(1, 0, 0, 1)
	TitleSep.Position         = UDim2.new(0, 0, 1, -1)
	TitleSep.BackgroundColor3 = Colors.Accent
	TitleSep.BackgroundTransparency = 0.55
	TitleSep.Parent           = TitleBar

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
	MinButton.Size                   = UDim2.new(0, 40, 1, 0)
	MinButton.Position               = UDim2.new(1, -75, 0, 0)
	MinButton.BackgroundColor3 = Colors.ElementHover
	MinButton.Text                   = "─"
	MinButton.TextColor3             = Colors.TextActive
	MinButton.TextSize               = 20
	MinButton.Font                   = Enum.Font.GothamBold
	MinButton.Parent                 = TitleBar
	Instance.new("UICorner", MinButton).CornerRadius = UDim.new(0, 6)

	RegisterHover(MinButton,
		function() 
			MinButton.BackgroundColor3 = Colors.ElementActive
			TweenPlay(MinButton, { Size = UDim2.new(0, 45, 1, 0) }, 0.2, Enum.EasingStyle.Quart)
		end,
		function() 
			MinButton.BackgroundColor3 = Colors.ElementHover
			TweenPlay(MinButton, { Size = UDim2.new(0, 40, 1, 0) }, 0.2, Enum.EasingStyle.Quart)
		end
	)

	MinButton.MouseButton1Click:Connect(function()
		Minimized = not Minimized
		MinButton.Text = Minimized and "⬆" or "─"
		TweenPlay(MainFrame, { Size = Minimized and MinimizedSize or WindowSize }, 0.3, Enum.EasingStyle.Quart)
	end)

	-- Close button
	local CloseButton = Instance.new("TextButton")
	CloseButton.Size                   = UDim2.new(0, 40, 1, 0)
	CloseButton.Position               = UDim2.new(1, -30, 0, 0)
	CloseButton.BackgroundColor3 = Color3.fromRGB(60, 20, 20)
	CloseButton.Text                   = "×"
	CloseButton.TextColor3             = Color3.fromRGB(255, 100, 100)
	CloseButton.TextSize               = 22
	CloseButton.Font                   = Enum.Font.GothamBold
	CloseButton.Parent                 = TitleBar
	Instance.new("UICorner", CloseButton).CornerRadius = UDim.new(0, 6)

	RegisterHover(CloseButton,
		function() 
			CloseButton.BackgroundColor3 = Color3.fromRGB(80, 30, 30)
			TweenPlay(CloseButton, { Size = UDim2.new(0, 45, 1, 0) }, 0.2, Enum.EasingStyle.Quart)
		end,
		function() 
			CloseButton.BackgroundColor3 = Color3.fromRGB(60, 20, 20)
			TweenPlay(CloseButton, { Size = UDim2.new(0, 40, 1, 0) }, 0.2, Enum.EasingStyle.Quart)
		end
	)

	CloseButton.MouseButton1Click:Connect(function()
		-- shrink + fade out simultaneously
		TweenPlay(MainFrame, {
			Size                  = UDim2.new(0, 0, 0, 0),
			BackgroundTransparency = 1
		}, 0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
		task.delay(0.25, function()
			if ScreenGui and ScreenGui.Parent then ScreenGui:Destroy() end
		end)
	end)

	-- ── Left Panel ──────────────────────────────────────────
	local LeftPanel = Instance.new("Frame")
	LeftPanel.BackgroundColor3 = Colors.Panel
	LeftPanel.Position         = UDim2.new(0, 0, 0, 35)
	LeftPanel.Size             = UDim2.new(0, 130, 1, -35)
	LeftPanel.Parent           = MainFrame

	-- vertical separator between panel and content
	local PanelSep = Instance.new("Frame")
	PanelSep.Size             = UDim2.new(0, 1, 1, 0)
	PanelSep.Position         = UDim2.new(1, -1, 0, 0)
	PanelSep.BackgroundColor3 = Colors.Accent
	PanelSep.BackgroundTransparency = 0.7
	PanelSep.Parent           = LeftPanel

	local TabContainer = Instance.new("ScrollingFrame")
	TabContainer.Size                   = UDim2.new(1, 0, 1, 0)
	TabContainer.BackgroundTransparency = 1
	TabContainer.ScrollBarThickness     = 0
	TabContainer.AutomaticCanvasSize    = Enum.AutomaticSize.Y
	TabContainer.Parent                 = LeftPanel

	local TabList = Instance.new("UIListLayout", TabContainer)
	TabList.Padding             = UDim.new(0, 4)
	TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
	Instance.new("UIPadding", TabContainer).PaddingTop = UDim.new(0, 8)

	-- ── Content area ────────────────────────────────────────
	local ContentContainer = Instance.new("Frame")
	ContentContainer.Position               = UDim2.new(0, 130, 0, 35)
	ContentContainer.Size                   = UDim2.new(1, -130, 1, -35)
	ContentContainer.BackgroundTransparency = 1
	ContentContainer.Parent                 = MainFrame

	-- ── Drag ────────────────────────────────────────────────
	local Dragging   = false
	local DragStart  = nil
	local StartPos   = nil
	local TargetPos  = Vector2.new(0, 0)
	local CurrentPos = Vector2.new(0, 0)
	local DragConnection = nil

	local LERP_SPEED = 0.18
	local DRAG_GROW  = 12

	local function GetRestSize()
		return Minimized and MinimizedSize or WindowSize
	end

	local function StartLerpLoop()
		DragConnection = RunService.Heartbeat:Connect(function(dt)
			CurrentPos = CurrentPos:Lerp(TargetPos, math.min(LERP_SPEED / dt, 1))
			MainFrame.Position = UDim2.new(
				StartPos.X.Scale,  CurrentPos.X,
				StartPos.Y.Scale,  CurrentPos.Y
			)
		end)
	end

	local function StopLerpLoop()
		if DragConnection then
			DragConnection:Disconnect()
			DragConnection = nil
		end
	end

	TitleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			Dragging  = true
			DragStart = input.Position
			StartPos  = MainFrame.Position

			CurrentPos = Vector2.new(StartPos.X.Offset, StartPos.Y.Offset)
			TargetPos  = CurrentPos

			local rest = GetRestSize()
			TweenPlay(MainFrame, {
				Size = UDim2.new(0, rest.X.Offset + DRAG_GROW * 2, 0, rest.Y.Offset + DRAG_GROW * 2)
			}, 0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

			StartLerpLoop()
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local Delta = input.Position - DragStart
			TargetPos = Vector2.new(
				StartPos.X.Offset + Delta.X,
				StartPos.Y.Offset + Delta.Y
			)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 and Dragging then
			Dragging = false
			StopLerpLoop()
			MainFrame.Position = UDim2.new(
				StartPos.X.Scale,  CurrentPos.X,
				StartPos.Y.Scale,  CurrentPos.Y
			)
			TweenPlay(MainFrame, { Size = GetRestSize() }, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		end
	end)

	-- ── Resize Functionality ─────────────────────────────────────
	local Resizing = false
	local ResizeStart = nil
	local StartSize = nil

	ResizeHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			Resizing = true
			ResizeStart = input.Position
			StartSize = MainFrame.AbsoluteSize
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if Resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - ResizeStart
			local newSize = Vector2.new(
				math.max(400, StartSize.X + delta.X),
				math.max(300, StartSize.Y + delta.Y)
			)
			WindowSize = UDim2.new(0, newSize.X, 0, newSize.Y)
			MainFrame.Size = WindowSize
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 and Resizing then
			Resizing = false
		end
	end)

	-- ── Tab system ──────────────────────────────────────────
	local Tabs        = {}
	local AllTabs     = {}
	local ActiveIndex = nil

	-- stagger-animates every child element inside a page
	-- each element fades in with a small delay between them
	local function AnimatePageIn(page)
		local children = {}
		for _, child in ipairs(page:GetChildren()) do
			if child:IsA("GuiObject")
				and not child:IsA("UIListLayout")
				and not child:IsA("UIPadding")
			then
				table.insert(children, child)
			end
		end

		for i, child in ipairs(children) do
			-- hide element + all its text labels instantly
			child.Visible = false
			child.BackgroundTransparency = 1
			for _, sub in ipairs(child:GetDescendants()) do
				if sub:IsA("TextLabel") or sub:IsA("TextButton") then
					sub.TextTransparency = 1
				end
			end

			task.delay(0.055 * i, function()
				if not child or not child.Parent then return end
				child.Visible = true

				-- fade bg in
				TweenPlay(child, { BackgroundTransparency = 0 }, 0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

				-- fade all text children in (slightly delayed for layered feel)
				task.delay(0.04, function()
					for _, sub in ipairs(child:GetDescendants()) do
						if sub:IsA("TextLabel") or sub:IsA("TextButton") then
							TweenPlay(sub, { TextTransparency = 0 }, 0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
						end
					end
				end)
			end)
		end
	end

	local function ActivateTab(index)
		if ActiveIndex == index then return end
		-- deactivate all
		for _, t in ipairs(AllTabs) do
			t.page.Visible = false
			t.button.TextColor3       = Colors.TextDim
			t.button.BackgroundColor3 = Colors.Element
			-- shrink accent bar height to 0
			TweenPlay(t.accent, { Size = UDim2.new(0, 3, 0, 0) }, 0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
		end
		-- activate chosen
		local t = AllTabs[index]
		t.page.Visible            = true
		t.button.TextColor3       = Colors.TextActive
		t.button.BackgroundColor3 = Colors.ElementHover
		-- grow accent bar from 0 → full height
		t.accent.Size = UDim2.new(0, 3, 0, 0)
		TweenPlay(t.accent, { Size = UDim2.new(0, 3, 1, -12) }, 0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		ActiveIndex = index

		-- stagger the page elements in
		AnimatePageIn(t.page)
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

		-- Accent bar (animates height on switch)
		local AccentBar = Instance.new("Frame")
		AccentBar.Size                   = UDim2.new(0, 3, 0, 0)   -- starts collapsed
		AccentBar.Position               = UDim2.new(0, 4, 0.5, 0)
		AccentBar.AnchorPoint            = Vector2.new(0, 0.5)
		AccentBar.BackgroundColor3       = Colors.Accent
		AccentBar.Parent                 = TabButton
		Instance.new("UICorner", AccentBar).CornerRadius = UDim.new(0, 2)

		-- Page
		local Page = Instance.new("ScrollingFrame")
		Page.Size                   = UDim2.new(1, 0, 1, 0)
		Page.BackgroundTransparency = 1
		Page.Visible                = false
		Page.ScrollBarThickness     = 8
		Page.ScrollBarImageColor3   = Colors.Accent
		Page.ScrollBarImageTransparency = 0.3
		Page.AutomaticCanvasSize    = Enum.AutomaticSize.Y
		-- Smooth scrolling
		Page.ElasticBehavior = true
		Page.ScrollingDirection = Enum.ScrollingDirection.Y
		Page.Parent                 = ContentContainer

		-- Custom scrollbar styling
		local ScrollingFrame = Page
		ScrollingFrame:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
			-- Smooth scroll animation
			local targetPos = ScrollingFrame.CanvasPosition
			TweenPlay(ScrollingFrame, { CanvasPosition = targetPos }, 0.1, Enum.EasingStyle.Quart)
		end)

		Instance.new("UIListLayout", Page).Padding = UDim.new(0, 6)
		Instance.new("UIPadding", Page).PaddingTop  = UDim.new(0, 8)

		-- Register
		table.insert(AllTabs, { button = TabButton, accent = AccentBar, page = Page })
		local myIndex = #AllTabs

		RegisterHover(TabButton,
			function() if ActiveIndex ~= myIndex then TabButton.BackgroundColor3 = Colors.ElementHover end end,
			function() if ActiveIndex ~= myIndex then TabButton.BackgroundColor3 = Colors.Element    end end
		)

		TabButton.MouseButton1Click:Connect(function()
			ActivateTab(myIndex)
		end)

		-- auto-select first tab
		if #AllTabs == 1 then
			-- slight delay so elements are created first, then animate
			task.delay(0, function() ActivateTab(1) end)
		end

		-- ── Elements ────────────────────────────────────────
		local Elements = {}

		-- ── ripple helper ───────────────────────────────────
		-- spawns a small expanding transparent circle from the click point
		local function SpawnRipple(parent)
			local mouse = UserInputService:GetMouseLocation()
			local relX  = mouse.X - parent.AbsolutePosition.X
			local relY  = mouse.Y - parent.AbsolutePosition.Y

			local Ripple = Instance.new("Frame")
			Ripple.Name                   = "Ripple"
			Ripple.Size                   = UDim2.new(0, 0, 0, 0)
			Ripple.AnchorPoint            = Vector2.new(0.5, 0.5)
			Ripple.Position               = UDim2.new(0, relX, 0, relY)
			Ripple.BackgroundColor3       = Colors.Ripple
			Ripple.BackgroundTransparency = 0.45
			Ripple.ZIndex                 = 10
			Ripple.Parent                 = parent
			Instance.new("UICorner", Ripple).CornerRadius = UDim.new(1, 0)

			-- expand + fade out
			TweenPlay(Ripple, {
				Size                  = UDim2.new(0, 80, 0, 80),
				BackgroundTransparency = 1
			}, 0.45, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

			task.delay(0.46, function()
				if Ripple and Ripple.Parent then Ripple:Destroy() end
			end)
		end

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

			RegisterHover(Button,
				function() Button.BackgroundColor3 = Colors.ElementHover end,
				function() Button.BackgroundColor3 = Colors.Element    end
			)

			Button.MouseButton1Down:Connect(function()
				Button.BackgroundColor3 = Colors.ElementActive
				SpawnRipple(Button)
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

			SetPercent((Value - Min) / (Max - Min))

			local function PercentFromMouse()
				local mx = UserInputService:GetMouseLocation().X
				local bx = Bar.AbsolutePosition.X
				local bw = Bar.AbsoluteSize.X
				if bw == 0 then return 0 end
				return (mx - bx) / bw
			end

			-- thumb pulse: briefly grow then shrink back
			local function PulseThumb()
				TweenPlay(Thumb, { Size = UDim2.new(0, 20, 0, 20) }, 0.1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
				task.delay(0.1, function()
					if Thumb and Thumb.Parent then
						TweenPlay(Thumb, { Size = UDim2.new(0, 14, 0, 14) }, 0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
					end
				end)
			end

			local sDragging = false

			Bar.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					sDragging = true
					SetPercent(PercentFromMouse())
					PulseThumb()
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

		function Elements:CreateToggle(Text, Callback, Default)
			local Toggled = Default or false
			
			local ToggleFrame = Instance.new("Frame")
			ToggleFrame.Size             = UDim2.new(1, -16, 0, 36)
			ToggleFrame.BackgroundColor3 = Colors.Element
			ToggleFrame.ClipsDescendants = true
			ToggleFrame.Parent           = Page
			Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 6)

			-- Label
			local Label = Instance.new("TextLabel")
			Label.Size                   = UDim2.new(1, -60, 1, 0)
			Label.Position               = UDim2.new(0, 14, 0, 0)
			Label.BackgroundTransparency = 1
			Label.Text                   = Text
			Label.TextColor3             = Colors.Text
			Label.Font                   = Enum.Font.Gotham
			Label.TextSize               = 13
			Label.TextXAlignment         = Enum.TextXAlignment.Left
			Label.Parent                 = ToggleFrame

			-- Toggle Switch
			local Switch = Instance.new("Frame")
			Switch.Size             = UDim2.new(0, 44, 0, 22)
			Switch.Position         = UDim2.new(1, -50, 0.5, -11)
			Switch.BackgroundColor3 = Toggled and Colors.Accent or Color3.fromRGB(60, 60, 70)
			Switch.Parent           = ToggleFrame
			Instance.new("UICorner", Switch).CornerRadius = UDim.new(0, 11)

			-- Switch Knob
			local Knob = Instance.new("Frame")
			Knob.Size             = UDim2.new(0, 18, 0, 18)
			Knob.Position         = UDim2.new(0, Toggled and 24 or 2, 0, 2)
			Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Knob.Parent           = Switch
			Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

			RegisterHover(ToggleFrame,
				function() ToggleFrame.BackgroundColor3 = Colors.ElementHover end,
				function() ToggleFrame.BackgroundColor3 = Colors.Element    end
			)

			local function UpdateToggle()
				Toggled = not Toggled
				TweenPlay(Switch, { BackgroundColor3 = Toggled and Colors.Accent or Color3.fromRGB(60, 60, 70) }, 0.2, Enum.EasingStyle.Quart)
				TweenPlay(Knob, { Position = UDim2.new(0, Toggled and 24 or 2, 0, 2) }, 0.2, Enum.EasingStyle.Back)
				if Callback then Callback(Toggled) end
			end

			ToggleFrame.MouseButton1Click:Connect(UpdateToggle)
			Switch.MouseButton1Click:Connect(UpdateToggle)
			Knob.MouseButton1Click:Connect(UpdateToggle)
		end

		function Elements:CreateTextbox(Text, Placeholder, Callback)
			local TextboxFrame = Instance.new("Frame")
			TextboxFrame.Size             = UDim2.new(1, -16, 0, 52)
			TextboxFrame.BackgroundColor3 = Colors.Element
			TextboxFrame.ClipsDescendants = true
			TextboxFrame.Parent           = Page
			Instance.new("UICorner", TextboxFrame).CornerRadius = UDim.new(0, 6)

			-- Label
			local Label = Instance.new("TextLabel")
			Label.Size                   = UDim2.new(1, -16, 0, 20)
			Label.Position               = UDim2.new(0, 12, 0, 6)
			Label.BackgroundTransparency = 1
			Label.Text                   = Text
			Label.TextColor3             = Colors.Text
			Label.Font                   = Enum.Font.Gotham
			Label.TextSize               = 12
			Label.TextXAlignment         = Enum.TextXAlignment.Left
			Label.Parent                 = TextboxFrame

			-- Textbox
			local Textbox = Instance.new("TextBox")
			Textbox.Size             = UDim2.new(1, -24, 0, 20)
			Textbox.Position         = UDim2.new(0, 12, 0, 28)
			Textbox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
			Textbox.Text              = ""
			Textbox.PlaceholderText   = Placeholder or ""
			Textbox.TextColor3        = Colors.Text
			Textbox.PlaceholderColor3 = Colors.TextDim
			Textbox.Font              = Enum.Font.Gotham
			Textbox.TextSize          = 12
			Textbox.Parent            = TextboxFrame
			Instance.new("UICorner", Textbox).CornerRadius = UDim.new(0, 4)

			RegisterHover(Textbox,
				function() Textbox.BackgroundColor3 = Color3.fromRGB(50, 50, 60) end,
				function() Textbox.BackgroundColor3 = Color3.fromRGB(40, 40, 50) end
			)

			Textbox.FocusLost:Connect(function()
				if Callback then Callback(Textbox.Text) end
			end)
		end

		function Elements:CreateDropdown(Text, Options, Callback)
			local Selected = nil
			local Open = false
			
			local DropdownFrame = Instance.new("Frame")
			DropdownFrame.Size             = UDim2.new(1, -16, 0, 36)
			DropdownFrame.BackgroundColor3 = Colors.Element
			DropdownFrame.ClipsDescendants = true
			DropdownFrame.Parent           = Page
			Instance.new("UICorner", DropdownFrame).CornerRadius = UDim.new(0, 6)

			-- Label
			local Label = Instance.new("TextLabel")
			Label.Size                   = UDim2.new(1, -40, 1, 0)
			Label.Position               = UDim2.new(0, 14, 0, 0)
			Label.BackgroundTransparency = 1
			Label.Text                   = Text
			Label.TextColor3             = Colors.Text
			Label.Font                   = Enum.Font.Gotham
			Label.TextSize               = 13
			Label.TextXAlignment         = Enum.TextXAlignment.Left
			Label.Parent                 = DropdownFrame

			-- Dropdown Arrow
			local Arrow = Instance.new("TextLabel")
			Arrow.Size             = UDim2.new(0, 20, 1, 0)
			Arrow.Position         = UDim2.new(1, -20, 0, 0)
			Arrow.BackgroundTransparency = 1
			Arrow.Text             = "▼"
			Arrow.TextColor3       = Colors.TextDim
			Arrow.Font             = Enum.Font.Gotham
			Arrow.TextSize         = 10
			Arrow.Parent           = DropdownFrame

			-- Options Container
			local OptionsContainer = Instance.new("Frame")
			OptionsContainer.Size             = UDim2.new(1, -16, 0, 0)
			OptionsContainer.Position         = UDim2.new(0, 0, 1, 0)
			OptionsContainer.BackgroundColor3 = Colors.Element
			OptionsContainer.Visible          = false
			OptionsContainer.Parent           = Page
			Instance.new("UICorner", OptionsContainer).CornerRadius = UDim.new(0, 6)

			local OptionsList = Instance.new("UIListLayout", OptionsContainer)
			OptionsList.Padding = UDim.new(0, 2)

			-- Create option buttons
			for i, option in ipairs(Options) do
				local OptionButton = Instance.new("TextButton")
				OptionButton.Size             = UDim2.new(1, -8, 0, 28)
				OptionButton.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
				OptionButton.Text             = option
				OptionButton.TextColor3       = Colors.Text
				OptionButton.Font             = Enum.Font.Gotham
				OptionButton.TextSize         = 12
				OptionButton.Parent           = OptionsContainer
				Instance.new("UICorner", OptionButton).CornerRadius = UDim.new(0, 4)

				OptionButton.MouseButton1Click:Connect(function()
					Selected = option
					Label.Text = Text .. ": " .. option
					Open = false
					OptionsContainer.Visible = false
					Arrow.Text = "▼"
					TweenPlay(DropdownFrame, { Size = UDim2.new(1, -16, 0, 36) }, 0.2, Enum.EasingStyle.Quart)
					if Callback then Callback(option) end
				end)

				RegisterHover(OptionButton,
					function() OptionButton.BackgroundColor3 = Colors.ElementHover end,
					function() OptionButton.BackgroundColor3 = Color3.fromRGB(40, 40, 50) end
				)
			end

			-- Update container size
			OptionsContainer.AutomaticSize = Enum.AutomaticSize.Y

			RegisterHover(DropdownFrame,
				function() DropdownFrame.BackgroundColor3 = Colors.ElementHover end,
				function() DropdownFrame.BackgroundColor3 = Colors.Element    end
			)

			DropdownFrame.MouseButton1Click:Connect(function()
				Open = not Open
				OptionsContainer.Visible = Open
				Arrow.Text = Open and "▲" or "▼"
				
				if Open then
					TweenPlay(DropdownFrame, { Size = UDim2.new(1, -16, 0, 36 + OptionsContainer.AbsoluteSize.Y) }, 0.2, Enum.EasingStyle.Quart)
				else
					TweenPlay(DropdownFrame, { Size = UDim2.new(1, -16, 0, 36) }, 0.2, Enum.EasingStyle.Quart)
				end
			end)
		end

		function Elements:CreateColorPicker(Text, Callback, Default)
			local SelectedColor = Default or Color3.fromRGB(255, 255, 255)
			
			local ColorFrame = Instance.new("Frame")
			ColorFrame.Size             = UDim2.new(1, -16, 0, 52)
			ColorFrame.BackgroundColor3 = Colors.Element
			ColorFrame.ClipsDescendants = true
			ColorFrame.Parent           = Page
			Instance.new("UICorner", ColorFrame).CornerRadius = UDim.new(0, 6)

			-- Label
			local Label = Instance.new("TextLabel")
			Label.Size                   = UDim2.new(1, -60, 0, 20)
			Label.Position               = UDim2.new(0, 12, 0, 6)
			Label.BackgroundTransparency = 1
			Label.Text                   = Text
			Label.TextColor3             = Colors.Text
			Label.Font                   = Enum.Font.Gotham
			Label.TextSize               = 12
			Label.TextXAlignment         = Enum.TextXAlignment.Left
			Label.Parent                 = ColorFrame

			-- Color Display
			local ColorDisplay = Instance.new("Frame")
			ColorDisplay.Size             = UDim2.new(0, 44, 0, 22)
			ColorDisplay.Position         = UDim2.new(1, -50, 0, 6)
			ColorDisplay.BackgroundColor3 = SelectedColor
			ColorDisplay.Parent           = ColorFrame
			Instance.new("UICorner", ColorDisplay).CornerRadius = UDim.new(0, 4)

			-- Color Preview
			local Preview = Instance.new("Frame")
			Preview.Size             = UDim2.new(1, -24, 0, 20)
			Preview.Position         = UDim2.new(0, 12, 0, 28)
			Preview.BackgroundColor3 = SelectedColor
			Preview.Parent           = ColorFrame
			Instance.new("UICorner", Preview).CornerRadius = UDim.new(0, 4)

			RegisterHover(ColorFrame,
				function() ColorFrame.BackgroundColor3 = Colors.ElementHover end,
				function() ColorFrame.BackgroundColor3 = Colors.Element    end
			)

			ColorFrame.MouseButton1Click:Connect(function()
				-- Simple color picker with preset colors
				local colors = {
					Color3.fromRGB(255, 0, 0),
					Color3.fromRGB(0, 255, 0),
					Color3.fromRGB(0, 0, 255),
					Color3.fromRGB(255, 255, 0),
					Color3.fromRGB(255, 0, 255),
					Color3.fromRGB(0, 255, 255),
					Color3.fromRGB(255, 255, 255),
					Color3.fromRGB(0, 0, 0)
				}
				SelectedColor = colors[math.random(#colors)]
				ColorDisplay.BackgroundColor3 = SelectedColor
				Preview.BackgroundColor3 = SelectedColor
				if Callback then Callback(SelectedColor) end
			end)
		end

		return Elements
	end

	-- ── Open animation (runs after everything is built) ────
	task.defer(function()
		-- bounce open from zero
		TweenPlay(MainFrame, { Size = WindowSize }, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		-- restore bg transparency (was 0.08 but frame starts invisible at size 0)
		MainFrame.BackgroundTransparency = 0.08
	end)

	return Tabs
end

return Library
