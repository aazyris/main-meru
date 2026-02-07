local Library = {}
local TweenService    = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService      = game:GetService("RunService")
local CoreGui         = game:GetService("CoreGui")

-- ── Modern Color Palette (matching the image exactly) ──────────────
local Colors = {
	BG            = Color3.fromRGB(28, 28, 32),      -- Main background
	Panel         = Color3.fromRGB(22, 22, 26),      -- Sidebar darker
	Element       = Color3.fromRGB(38, 38, 42),      -- Element background
	ElementHover  = Color3.fromRGB(45, 45, 50),
	TitleBar      = Color3.fromRGB(24, 24, 28),
	Text          = Color3.fromRGB(235, 235, 240),
	TextDim       = Color3.fromRGB(140, 140, 145),
	TextActive    = Color3.fromRGB(255, 255, 255),
	Accent        = Color3.fromRGB(100, 210, 210),   -- Cyan
	AccentDark    = Color3.fromRGB(80, 190, 190),
	Divider       = Color3.fromRGB(50, 50, 55),
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
		if not guiObj or not guiObj.Parent then return false end
		local pos = UserInputService:GetMouseLocation()
		local abs = guiObj.AbsolutePosition
		local sz  = guiObj.AbsoluteSize
		-- Add a 2 pixel buffer to prevent accidental triggers
		return pos.X >= abs.X + 2 and pos.X <= abs.X + sz.X - 2
			and pos.Y >= abs.Y + 2 and pos.Y <= abs.Y + sz.Y - 2
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
	MainFrame.BackgroundTransparency = 0.05  -- Slight transparency
	MainFrame.ClipsDescendants = true
	MainFrame.Parent           = ScreenGui
	Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
	
	-- Add subtle shadow effect
	local Shadow = Instance.new("ImageLabel")
	Shadow.Name = "Shadow"
	Shadow.Size = UDim2.new(1, 40, 1, 40)
	Shadow.Position = UDim2.new(0, -20, 0, -20)
	Shadow.BackgroundTransparency = 1
	Shadow.Image = "rbxassetid://5554236805"
	Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
	Shadow.ImageTransparency = 0.6
	Shadow.ZIndex = 0
	Shadow.Parent = MainFrame

	-- ── Title Bar ───────────────────────────────────────────
	local TitleBar = Instance.new("Frame")
	TitleBar.Size             = UDim2.new(1, 0, 0, 50)
	TitleBar.BackgroundColor3 = Colors.TitleBar
	TitleBar.BackgroundTransparency = 0.1
	TitleBar.Parent           = MainFrame
	Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 12)
	
	-- Bottom border line
	local TitleBorder = Instance.new("Frame")
	TitleBorder.Size = UDim2.new(1, 0, 0, 1)
	TitleBorder.Position = UDim2.new(0, 0, 1, 0)
	TitleBorder.BackgroundColor3 = Colors.Divider
	TitleBorder.BackgroundTransparency = 0.5
	TitleBorder.BorderSizePixel = 0
	TitleBorder.Parent = TitleBar

	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.Size                   = UDim2.new(1, -100, 1, 0)
	TitleLabel.Position               = UDim2.new(0, 25, 0, 0)
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Text                   = Title
	TitleLabel.TextColor3             = Colors.TextActive
	TitleLabel.Font                   = Enum.Font.GothamBold
	TitleLabel.TextSize               = 16
	TitleLabel.TextXAlignment         = Enum.TextXAlignment.Left
	TitleLabel.Parent                 = TitleBar

	-- Settings icon removed to match image
	
	-- Minimize button
	local MinArrow = Instance.new("TextLabel")
	MinArrow.Size                   = UDim2.new(0, 35, 0, 35)
	MinArrow.Position               = UDim2.new(1, -80, 0.5, -17.5)
	MinArrow.BackgroundTransparency = 1
	MinArrow.Text                   = ">"
	MinArrow.TextColor3             = Colors.TextDim
	MinArrow.TextSize               = 20
	MinArrow.Font                   = Enum.Font.GothamBold
	MinArrow.Rotation               = 90  -- Points down
	MinArrow.Parent                 = TitleBar
	
	local MinButton = Instance.new("TextButton")
	MinButton.Size                   = UDim2.new(0, 40, 0, 40)
	MinButton.Position               = UDim2.new(1, -85, 0.5, -20)
	MinButton.BackgroundTransparency = 1
	MinButton.Text                   = ""
	MinButton.Parent                 = TitleBar

	-- Close button
	local CloseButton = Instance.new("TextButton")
	CloseButton.Size                   = UDim2.new(0, 35, 0, 35)
	CloseButton.Position               = UDim2.new(1, -45, 0.5, -17.5)
	CloseButton.BackgroundTransparency = 1
	CloseButton.Text                   = "×"
	CloseButton.TextColor3             = Colors.TextActive  -- White
	CloseButton.TextSize               = 22
	CloseButton.Font                   = Enum.Font.GothamBold
	CloseButton.Parent                 = TitleBar

	RegisterHover(MinButton,
		function() 
			MinArrow.TextColor3 = Colors.TextActive
			TweenPlay(MinArrow, { TextSize = 22 }, 0.15)
		end,
		function() 
			MinArrow.TextColor3 = Colors.TextDim
			TweenPlay(MinArrow, { TextSize = 20 }, 0.15)
		end
	)

	RegisterHover(CloseButton,
		function() 
			CloseButton.TextColor3 = Color3.fromRGB(255, 120, 120)
			TweenPlay(CloseButton, { TextSize = 24 }, 0.15)
		end,
		function() 
			CloseButton.TextColor3 = Colors.TextActive
			TweenPlay(CloseButton, { TextSize = 22 }, 0.15)
		end
	)

	MinButton.MouseButton1Click:Connect(function()
		Minimized = not Minimized
		
		-- Rotate arrow: 90° = down, -90° = up
		if Minimized then
			TweenPlay(MinArrow, { Rotation = -90 }, 0.25, Enum.EasingStyle.Back)
			-- Hide profile when minimized
			if ProfileContainer then
				ProfileContainer.Visible = false
			end
		else
			TweenPlay(MinArrow, { Rotation = 90 }, 0.25, Enum.EasingStyle.Back)
			-- Show profile when restored
			if ProfileContainer then
				ProfileContainer.Visible = true
			end
		end
		
		TweenPlay(MainFrame, { Size = Minimized and UDim2.new(0, 520, 0, 50) or WindowSize }, 0.3, Enum.EasingStyle.Quart)
	end)

	CloseButton.MouseButton1Click:Connect(function()
		TweenPlay(MainFrame, { Size = UDim2.new(0, 0, 0, 0) }, 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In)
		task.delay(0.3, function()
			if ScreenGui and ScreenGui.Parent then ScreenGui:Destroy() end
		end)
	end)

	-- ── Left Sidebar ────────────────────────────────────────
	local Sidebar = Instance.new("Frame")
	Sidebar.Size             = UDim2.new(0, 75, 1, -50)
	Sidebar.Position         = UDim2.new(0, 0, 0, 50)
	Sidebar.BackgroundColor3 = Colors.Panel
	Sidebar.BackgroundTransparency = 0.1
	Sidebar.BorderSizePixel  = 0
	Sidebar.Parent           = MainFrame
	
	-- Right border
	local SidebarBorder = Instance.new("Frame")
	SidebarBorder.Size = UDim2.new(0, 1, 1, 0)
	SidebarBorder.Position = UDim2.new(1, 0, 0, 0)
	SidebarBorder.BackgroundColor3 = Colors.Divider
	SidebarBorder.BackgroundTransparency = 0.5
	SidebarBorder.BorderSizePixel = 0
	SidebarBorder.Parent = Sidebar

	local TabContainer = Instance.new("ScrollingFrame")
	TabContainer.Size                   = UDim2.new(1, 0, 1, -75)
	TabContainer.BackgroundTransparency = 1
	TabContainer.ScrollBarThickness     = 0
	TabContainer.BorderSizePixel        = 0
	TabContainer.Parent                 = Sidebar

	local TabList = Instance.new("UIListLayout", TabContainer)
	TabList.Padding = UDim.new(0, 6)
	Instance.new("UIPadding", TabContainer).PaddingTop = UDim.new(0, 15)
	Instance.new("UIPadding", TabContainer).PaddingLeft = UDim.new(0, 12)
	Instance.new("UIPadding", TabContainer).PaddingRight = UDim.new(0, 12)

	-- ── Player Profile (Bottom Left) ────────────────────────
	local ProfileContainer = Instance.new("Frame")
	ProfileContainer.Size             = UDim2.new(1, 0, 0, 60)
	ProfileContainer.Position         = UDim2.new(0, 0, 1, -60)
	ProfileContainer.BackgroundTransparency = 1
	ProfileContainer.Parent           = Sidebar

	local ProfileButton = Instance.new("TextButton")
	ProfileButton.Size                   = UDim2.new(0, 50, 0, 50)
	ProfileButton.Position               = UDim2.new(0.5, -25, 0, 5)
	ProfileButton.BackgroundColor3       = Colors.Element
	ProfileButton.Text                   = ""
	ProfileButton.AutoButtonColor        = false
	ProfileButton.Parent                 = ProfileContainer
	Instance.new("UICorner", ProfileButton).CornerRadius = UDim.new(1, 0)

	-- Get player avatar
	local Players = game:GetService("Players")
	local LocalPlayer = Players.LocalPlayer
	
	local function GetPlayerAvatar()
		local userId = LocalPlayer.UserId
		local thumbType = Enum.ThumbnailType.HeadShot
		local thumbSize = Enum.ThumbnailSize.Size150x150
		local content, isReady = Players:GetUserThumbnailAsync(userId, thumbType, thumbSize)
		return content
	end
	
	local AvatarImage = Instance.new("ImageLabel")
	AvatarImage.Size             = UDim2.new(1, 0, 1, 0)
	AvatarImage.BackgroundTransparency = 1
	AvatarImage.Image            = GetPlayerAvatar()
	AvatarImage.Parent           = ProfileButton
	Instance.new("UICorner", AvatarImage).CornerRadius = UDim.new(1, 0)

	RegisterHover(ProfileButton,
		function() 
			TweenPlay(ProfileButton, { Size = UDim2.new(0, 54, 0, 54) }, 0.2)
			ProfileButton.Position = UDim2.new(0.5, -27, 0, 3)
		end,
		function() 
			TweenPlay(ProfileButton, { Size = UDim2.new(0, 50, 0, 50) }, 0.2)
			ProfileButton.Position = UDim2.new(0.5, -25, 0, 5)
		end
	)

	-- ── Content Area ────────────────────────────────────────
	local ContentContainer = Instance.new("Frame")
	ContentContainer.Size                   = UDim2.new(1, -75, 1, -50)
	ContentContainer.Position               = UDim2.new(0, 75, 0, 50)
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

	function Tabs:CreateTab(TabName, IconAssetId)
		local TabButton = Instance.new("TextButton")
		TabButton.Size             = UDim2.new(1, 0, 0, 50)
		TabButton.BackgroundColor3 = Colors.Element
		TabButton.BackgroundTransparency = 1
		TabButton.Text             = ""
		TabButton.AutoButtonColor  = false
		TabButton.Parent           = TabContainer
		Instance.new("UICorner", TabButton).CornerRadius = UDim.new(0, 12)

		-- Icon circle background
		local IconBg = Instance.new("Frame")
		IconBg.Size = UDim2.new(0, 42, 0, 42)
		IconBg.Position = UDim2.new(0.5, -21, 0.5, -21)
		IconBg.BackgroundColor3 = Colors.Element
		IconBg.BackgroundTransparency = 0.3
		IconBg.Parent = TabButton
		Instance.new("UICorner", IconBg).CornerRadius = UDim.new(1, 0)
		
		-- Subtle glow effect
		local IconGlow = Instance.new("UIStroke", IconBg)
		IconGlow.Color = Colors.Accent
		IconGlow.Thickness = 0
		IconGlow.Transparency = 0.5

		-- Tab icon - either image or text
		if IconAssetId and type(IconAssetId) == "string" and IconAssetId:match("rbxassetid://") then
			-- Use image icon
			local TabIcon = Instance.new("ImageLabel")
			TabIcon.Size                   = UDim2.new(0.7, 0, 0.7, 0)
			TabIcon.Position               = UDim2.new(0.15, 0, 0.15, 0)
			TabIcon.BackgroundTransparency = 1
			TabIcon.Image                  = IconAssetId
			TabIcon.ImageColor3            = Colors.TextDim
			TabIcon.Parent                 = IconBg
		else
			-- Use text letter
			local TabLabel = Instance.new("TextLabel")
			TabLabel.Size                   = UDim2.new(1, 0, 1, 0)
			TabLabel.BackgroundTransparency = 1
			TabLabel.Text                   = TabName:sub(1, 1):upper()
			TabLabel.TextColor3             = Colors.TextDim
			TabLabel.Font                   = Enum.Font.GothamBold
			TabLabel.TextSize               = 18
			TabLabel.Parent                 = IconBg
		end

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
		PageList.Padding = UDim.new(0, 10)  -- More spacing between elements
		Instance.new("UIPadding", Page).PaddingTop = UDim.new(0, 20)
		Instance.new("UIPadding", Page).PaddingLeft = UDim.new(0, 20)
		Instance.new("UIPadding", Page).PaddingRight = UDim.new(0, 20)
		Instance.new("UIPadding", Page).PaddingBottom = UDim.new(0, 20)

		table.insert(AllTabs, {button = TabButton, iconBg = IconBg, page = Page, glow = IconGlow})
		local myIndex = #AllTabs

		local function ActivateTab()
			for _, tab in ipairs(AllTabs) do
				tab.page.Visible = false
				TweenPlay(tab.iconBg, {BackgroundColor3 = Colors.Element, BackgroundTransparency = 0.3}, 0.25)
				TweenPlay(tab.glow, {Thickness = 0}, 0.25)
				-- Handle both image and text icons
				for _, child in ipairs(tab.iconBg:GetChildren()) do
					if child:IsA("ImageLabel") then
						TweenPlay(child, {ImageColor3 = Colors.TextDim}, 0.25)
					elseif child:IsA("TextLabel") then
						TweenPlay(child, {TextColor3 = Colors.TextDim}, 0.25)
					end
				end
			end
			Page.Visible = true
			TweenPlay(IconBg, {BackgroundColor3 = Colors.Accent, BackgroundTransparency = 0}, 0.25)
			TweenPlay(IconGlow, {Thickness = 2}, 0.25)
			-- Handle both image and text icons
			for _, child in ipairs(IconBg:GetChildren()) do
				if child:IsA("ImageLabel") then
					TweenPlay(child, {ImageColor3 = Colors.TextActive}, 0.25)
				elseif child:IsA("TextLabel") then
					TweenPlay(child, {TextColor3 = Colors.TextActive}, 0.25)
				end
			end
			ActiveTab = myIndex
		end

		RegisterHover(TabButton,
			function()
				if ActiveTab ~= myIndex then
					TweenPlay(IconBg, {BackgroundTransparency = 0, BackgroundColor3 = Colors.ElementHover}, 0.2)
					for _, child in ipairs(IconBg:GetChildren()) do
						if child:IsA("ImageLabel") then
							TweenPlay(child, {ImageColor3 = Colors.Text}, 0.2)
						elseif child:IsA("TextLabel") then
							TweenPlay(child, {TextColor3 = Colors.Text}, 0.2)
						end
					end
				end
			end,
			function()
				if ActiveTab ~= myIndex then
					TweenPlay(IconBg, {BackgroundTransparency = 0.3, BackgroundColor3 = Colors.Element}, 0.2)
					for _, child in ipairs(IconBg:GetChildren()) do
						if child:IsA("ImageLabel") then
							TweenPlay(child, {ImageColor3 = Colors.TextDim}, 0.2)
						elseif child:IsA("TextLabel") then
							TweenPlay(child, {TextColor3 = Colors.TextDim}, 0.2)
						end
					end
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
			local SectionFrame = Instance.new("Frame")
			SectionFrame.Size                   = UDim2.new(1, 0, 0, 35)
			SectionFrame.BackgroundTransparency = 1
			SectionFrame.Parent                 = Page

			local SectionLabel = Instance.new("TextLabel")
			SectionLabel.Size                   = UDim2.new(1, 0, 1, 0)
			SectionLabel.Position               = UDim2.new(0, 0, 0, 10)
			SectionLabel.BackgroundTransparency = 1
			SectionLabel.Text                   = SectionName
			SectionLabel.TextColor3             = Colors.Text
			SectionLabel.Font                   = Enum.Font.GothamBold
			SectionLabel.TextSize               = 15
			SectionLabel.TextXAlignment         = Enum.TextXAlignment.Left
			SectionLabel.TextYAlignment         = Enum.TextYAlignment.Top
			SectionLabel.Parent                 = SectionFrame
		end

		function Elements:CreateToggle(Text, Subtitle, Callback, Default)
			local Toggled = Default or false

			local ToggleFrame = Instance.new("Frame")
			ToggleFrame.Size             = UDim2.new(1, 0, 0, Subtitle and 60 or 50)
			ToggleFrame.BackgroundColor3 = Colors.Element
			ToggleFrame.BackgroundTransparency = 0.2
			ToggleFrame.Parent           = Page
			Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 10)

			local ToggleButton = Instance.new("TextButton")
			ToggleButton.Size                   = UDim2.new(1, 0, 1, 0)
			ToggleButton.BackgroundTransparency = 1
			ToggleButton.Text                   = ""
			ToggleButton.AutoButtonColor        = false
			ToggleButton.Parent                 = ToggleFrame

			local Label = Instance.new("TextLabel")
			Label.Size                   = UDim2.new(1, -80, 0, Subtitle and 22 or 50)
			Label.Position               = UDim2.new(0, 20, 0, Subtitle and 12 or 0)
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
				SubLabel.Size                   = UDim2.new(1, -80, 0, 18)
				SubLabel.Position               = UDim2.new(0, 20, 0, 34)
				SubLabel.BackgroundTransparency = 1
				SubLabel.Text                   = Subtitle
				SubLabel.TextColor3             = Colors.TextDim
				SubLabel.Font                   = Enum.Font.Gotham
				SubLabel.TextSize               = 12
				SubLabel.TextXAlignment         = Enum.TextXAlignment.Left
				SubLabel.Parent                 = ToggleFrame
			end

			local Switch = Instance.new("Frame")
			Switch.Size             = UDim2.new(0, 48, 0, 28)
			Switch.Position         = UDim2.new(1, -65, 0.5, -14)
			Switch.BackgroundColor3 = Toggled and Colors.Accent or Color3.fromRGB(55, 55, 65)
			Switch.Parent           = ToggleFrame
			Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)

			local Knob = Instance.new("Frame")
			Knob.Size             = UDim2.new(0, 24, 0, 24)
			Knob.Position         = UDim2.new(0, Toggled and 22 or 2, 0, 2)
			Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Knob.Parent           = Switch
			Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

			RegisterHover(ToggleFrame,
				function() 
					TweenPlay(ToggleFrame, {BackgroundTransparency = 0}, 0.2)
				end,
				function() 
					TweenPlay(ToggleFrame, {BackgroundTransparency = 0.2}, 0.2)
				end
			)

			local function UpdateToggle()
				Toggled = not Toggled
				TweenPlay(Switch, {BackgroundColor3 = Toggled and Colors.Accent or Color3.fromRGB(55, 55, 65)}, 0.25)
				TweenPlay(Knob, {Position = UDim2.new(0, Toggled and 22 or 2, 0, 2)}, 0.3, Enum.EasingStyle.Back)
				if Callback then Callback(Toggled) end
			end

			ToggleButton.MouseButton1Click:Connect(UpdateToggle)
		end

		function Elements:CreateSlider(Text, Min, Max, Callback, Default)
			local Value = Default or Min

			local SliderFrame = Instance.new("Frame")
			SliderFrame.Size             = UDim2.new(1, 0, 0, 65)
			SliderFrame.BackgroundColor3 = Colors.Element
			SliderFrame.BackgroundTransparency = 0.2
			SliderFrame.Parent           = Page
			Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0, 10)

			local Title = Instance.new("TextLabel")
			Title.Size                   = UDim2.new(1, -90, 0, 22)
			Title.Position               = UDim2.new(0, 20, 0, 14)
			Title.BackgroundTransparency = 1
			Title.Text                   = Text
			Title.TextColor3             = Colors.Text
			Title.Font                   = Enum.Font.GothamMedium
			Title.TextSize               = 14
			Title.TextXAlignment         = Enum.TextXAlignment.Left
			Title.Parent                 = SliderFrame

			local ValueLabel = Instance.new("TextLabel")
			ValueLabel.Size                   = UDim2.new(0, 60, 0, 22)
			ValueLabel.Position               = UDim2.new(1, -75, 0, 14)
			ValueLabel.BackgroundTransparency = 1
			ValueLabel.Text                   = tostring(Value)
			ValueLabel.TextColor3             = Colors.TextDim
			ValueLabel.Font                   = Enum.Font.GothamBold
			ValueLabel.TextSize               = 14
			ValueLabel.TextXAlignment         = Enum.TextXAlignment.Right
			ValueLabel.Parent                 = SliderFrame

			local BarContainer = Instance.new("Frame")
			BarContainer.Size             = UDim2.new(1, -40, 0, 8)
			BarContainer.Position         = UDim2.new(0, 20, 1, -22)
			BarContainer.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
			BarContainer.BorderSizePixel  = 0
			BarContainer.Parent           = SliderFrame
			Instance.new("UICorner", BarContainer).CornerRadius = UDim.new(1, 0)

			local Fill = Instance.new("Frame")
			Fill.Size             = UDim2.new(0, 0, 1, 0)
			Fill.BackgroundColor3 = Colors.Accent
			Fill.BorderSizePixel  = 0
			Fill.Parent           = BarContainer
			Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
			
			-- Animated gradient on fill
			local Gradient = Instance.new("UIGradient", Fill)
			Gradient.Color = ColorSequence.new{
				ColorSequenceKeypoint.new(0, Colors.Accent),
				ColorSequenceKeypoint.new(1, Colors.AccentDark)
			}

			local function SetValue(pct)
				pct = math.clamp(pct, 0, 1)
				TweenPlay(Fill, {Size = UDim2.new(pct, 0, 1, 0)}, 0.15)
				Value = math.round(Min + (Max - Min) * pct)
				ValueLabel.Text = tostring(Value)
				if Callback then Callback(Value) end
			end

			SetValue((Value - Min) / (Max - Min))

			local dragging = false

			BarContainer.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = true
					local mx = UserInputService:GetMouseLocation().X
					local pct = (mx - BarContainer.AbsolutePosition.X) / BarContainer.AbsoluteSize.X
					SetValue(pct)
				end
			end)

			UserInputService.InputChanged:Connect(function(input)
				if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
					local mx = UserInputService:GetMouseLocation().X
					local pct = (mx - BarContainer.AbsolutePosition.X) / BarContainer.AbsoluteSize.X
					SetValue(pct)
				end
			end)

			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = false
				end
			end)
			
			RegisterHover(SliderFrame,
				function() 
					TweenPlay(SliderFrame, {BackgroundTransparency = 0}, 0.2)
				end,
				function() 
					TweenPlay(SliderFrame, {BackgroundTransparency = 0.2}, 0.2)
				end
			)
		end

		function Elements:CreateButton(Text, Callback)
			local Button = Instance.new("TextButton")
			Button.Size             = UDim2.new(1, 0, 0, 50)
			Button.BackgroundColor3 = Colors.Element
			Button.BackgroundTransparency = 0.2
			Button.Text             = Text
			Button.TextColor3       = Colors.Text
			Button.Font             = Enum.Font.GothamMedium
			Button.TextSize         = 14
			Button.AutoButtonColor  = false
			Button.Parent           = Page
			Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 10)

			RegisterHover(Button,
				function() 
					TweenPlay(Button, {BackgroundTransparency = 0, BackgroundColor3 = Colors.ElementHover}, 0.2)
					TweenPlay(Button, {TextColor3 = Colors.TextActive}, 0.2)
				end,
				function() 
					TweenPlay(Button, {BackgroundTransparency = 0.2, BackgroundColor3 = Colors.Element}, 0.2)
					TweenPlay(Button, {TextColor3 = Colors.Text}, 0.2)
				end
			)

			Button.MouseButton1Click:Connect(function()
				-- Click animation
				TweenPlay(Button, {BackgroundTransparency = 0, BackgroundColor3 = Colors.Accent}, 0.1)
				task.wait(0.1)
				TweenPlay(Button, {BackgroundTransparency = 0.2, BackgroundColor3 = Colors.Element}, 0.2)
				if Callback then Callback() end
			end)
		end

		function Elements:CreateDropdown(Text, Options, Callback)
			local Selected = Options[1] or ""
			local Open = false

			local DropdownFrame = Instance.new("Frame")
			DropdownFrame.Size             = UDim2.new(1, 0, 0, 50)
			DropdownFrame.BackgroundColor3 = Colors.Element
			DropdownFrame.BackgroundTransparency = 0.2
			DropdownFrame.ClipsDescendants = false
			DropdownFrame.Parent           = Page
			Instance.new("UICorner", DropdownFrame).CornerRadius = UDim.new(0, 10)

			local DropdownButton = Instance.new("TextButton")
			DropdownButton.Size                   = UDim2.new(1, 0, 1, 0)
			DropdownButton.BackgroundTransparency = 1
			DropdownButton.Text                   = ""
			DropdownButton.AutoButtonColor        = false
			DropdownButton.Parent                 = DropdownFrame

			local Label = Instance.new("TextLabel")
			Label.Size                   = UDim2.new(1, -100, 1, 0)
			Label.Position               = UDim2.new(0, 20, 0, 0)
			Label.BackgroundTransparency = 1
			Label.Text                   = Text
			Label.TextColor3             = Colors.Text
			Label.Font                   = Enum.Font.GothamMedium
			Label.TextSize               = 14
			Label.TextXAlignment         = Enum.TextXAlignment.Left
			Label.Parent                 = DropdownFrame

			local ValueLabel = Instance.new("TextLabel")
			ValueLabel.Size                   = UDim2.new(0, 120, 1, 0)
			ValueLabel.Position               = UDim2.new(1, -145, 0, 0)
			ValueLabel.BackgroundTransparency = 1
			ValueLabel.Text                   = Selected
			ValueLabel.TextColor3             = Colors.TextDim
			ValueLabel.Font                   = Enum.Font.Gotham
			ValueLabel.TextSize               = 13
			ValueLabel.TextXAlignment         = Enum.TextXAlignment.Right
			ValueLabel.TextTruncate           = Enum.TextTruncate.AtEnd
			ValueLabel.Parent                 = DropdownFrame

			local Arrow = Instance.new("TextLabel")
			Arrow.Size                   = UDim2.new(0, 20, 1, 0)
			Arrow.Position               = UDim2.new(1, -30, 0, 0)
			Arrow.BackgroundTransparency = 1
			Arrow.Text                   = "▼"
			Arrow.TextColor3             = Colors.TextDim
			Arrow.Font                   = Enum.Font.Gotham
			Arrow.TextSize               = 10
			Arrow.Rotation               = 0
			Arrow.Parent                 = DropdownFrame

			local OptionsFrame = Instance.new("ScrollingFrame")
			OptionsFrame.Size             = UDim2.new(1, 0, 0, math.min(#Options * 38 + 10, 200))
			OptionsFrame.Position         = UDim2.new(0, 0, 1, 5)
			OptionsFrame.BackgroundColor3 = Colors.Panel
			OptionsFrame.BackgroundTransparency = 0.05
			OptionsFrame.BorderSizePixel  = 0
			OptionsFrame.Visible          = false
			OptionsFrame.ScrollBarThickness = 4
			OptionsFrame.ScrollBarImageColor3 = Colors.Accent
			OptionsFrame.CanvasSize       = UDim2.new(0, 0, 0, #Options * 38 + 10)
			OptionsFrame.Parent           = DropdownFrame
			Instance.new("UICorner", OptionsFrame).CornerRadius = UDim.new(0, 8)
			
			local stroke = Instance.new("UIStroke", OptionsFrame)
			stroke.Color = Colors.Divider
			stroke.Thickness = 1
			stroke.Transparency = 0.5

			local OptionsList = Instance.new("UIListLayout", OptionsFrame)
			OptionsList.Padding = UDim.new(0, 3)
			Instance.new("UIPadding", OptionsFrame).PaddingTop = UDim.new(0, 5)
			Instance.new("UIPadding", OptionsFrame).PaddingBottom = UDim.new(0, 5)
			Instance.new("UIPadding", OptionsFrame).PaddingLeft = UDim.new(0, 5)
			Instance.new("UIPadding", OptionsFrame).PaddingRight = UDim.new(0, 5)

			for _, option in ipairs(Options) do
				local OptionButton = Instance.new("TextButton")
				OptionButton.Size             = UDim2.new(1, -10, 0, 35)
				OptionButton.BackgroundColor3 = Colors.Element
				OptionButton.BackgroundTransparency = 1
				OptionButton.Text             = option
				OptionButton.TextColor3       = Colors.Text
				OptionButton.Font             = Enum.Font.Gotham
				OptionButton.TextSize         = 13
				OptionButton.AutoButtonColor  = false
				OptionButton.Parent           = OptionsFrame
				Instance.new("UICorner", OptionButton).CornerRadius = UDim.new(0, 6)

				RegisterHover(OptionButton,
					function() 
						TweenPlay(OptionButton, {BackgroundTransparency = 0, BackgroundColor3 = Colors.ElementHover}, 0.15)
					end,
					function() 
						TweenPlay(OptionButton, {BackgroundTransparency = 1}, 0.15)
					end
				)

				OptionButton.MouseButton1Click:Connect(function()
					Selected = option
					ValueLabel.Text = option
					Open = false
					OptionsFrame.Visible = false
					TweenPlay(Arrow, {Rotation = 0}, 0.2)
					if Callback then Callback(option) end
				end)
			end

			RegisterHover(DropdownFrame,
				function() 
					TweenPlay(DropdownFrame, {BackgroundTransparency = 0}, 0.2)
				end,
				function() 
					if not Open then
						TweenPlay(DropdownFrame, {BackgroundTransparency = 0.2}, 0.2)
					end
				end
			)

			DropdownButton.MouseButton1Click:Connect(function()
				Open = not Open
				OptionsFrame.Visible = Open
				TweenPlay(Arrow, {Rotation = Open and 180 or 0}, 0.25)
				if Open then
					DropdownFrame.BackgroundTransparency = 0
				else
					DropdownFrame.BackgroundTransparency = 0.2
				end
			end)
		end

		function Elements:CreateTextbox(Text, Placeholder, Callback)
			local TextboxFrame = Instance.new("Frame")
			TextboxFrame.Size             = UDim2.new(1, 0, 0, 50)
			TextboxFrame.BackgroundColor3 = Colors.Element
			TextboxFrame.BackgroundTransparency = 0.2
			TextboxFrame.Parent           = Page
			Instance.new("UICorner", TextboxFrame).CornerRadius = UDim.new(0, 10)

			local Label = Instance.new("TextLabel")
			Label.Size                   = UDim2.new(0.35, 0, 1, 0)
			Label.Position               = UDim2.new(0, 20, 0, 0)
			Label.BackgroundTransparency = 1
			Label.Text                   = Text
			Label.TextColor3             = Colors.Text
			Label.Font                   = Enum.Font.GothamMedium
			Label.TextSize               = 14
			Label.TextXAlignment         = Enum.TextXAlignment.Left
			Label.Parent                 = TextboxFrame

			local Textbox = Instance.new("TextBox")
			Textbox.Size             = UDim2.new(0.6, -30, 0, 32)
			Textbox.Position         = UDim2.new(0.4, 0, 0.5, -16)
			Textbox.BackgroundColor3 = Colors.Panel
			Textbox.BackgroundTransparency = 0.3
			Textbox.Text             = ""
			Textbox.PlaceholderText  = Placeholder or ""
			Textbox.TextColor3       = Colors.Text
			Textbox.PlaceholderColor3 = Colors.TextDim
			Textbox.Font             = Enum.Font.Gotham
			Textbox.TextSize         = 13
			Textbox.Parent           = TextboxFrame
			Instance.new("UICorner", Textbox).CornerRadius = UDim.new(0, 6)
			Instance.new("UIPadding", Textbox).PaddingLeft = UDim.new(0, 10)

			Textbox.Focused:Connect(function()
				TweenPlay(Textbox, {BackgroundTransparency = 0}, 0.2)
			end)

			Textbox.FocusLost:Connect(function()
				TweenPlay(Textbox, {BackgroundTransparency = 0.3}, 0.2)
				if Callback then Callback(Textbox.Text) end
			end)
			
			RegisterHover(TextboxFrame,
				function() 
					TweenPlay(TextboxFrame, {BackgroundTransparency = 0}, 0.2)
				end,
				function() 
					TweenPlay(TextboxFrame, {BackgroundTransparency = 0.2}, 0.2)
				end
			)
		end

		function Elements:CreateKeybind(Text, DefaultKey, Callback)
			local CurrentKey = DefaultKey or "None"
			local Binding = false

			local KeybindFrame = Instance.new("Frame")
			KeybindFrame.Size             = UDim2.new(1, 0, 0, 50)
			KeybindFrame.BackgroundColor3 = Colors.Element
			KeybindFrame.BackgroundTransparency = 0.2
			KeybindFrame.Parent           = Page
			Instance.new("UICorner", KeybindFrame).CornerRadius = UDim.new(0, 10)

			local Label = Instance.new("TextLabel")
			Label.Size                   = UDim2.new(1, -130, 1, 0)
			Label.Position               = UDim2.new(0, 20, 0, 0)
			Label.BackgroundTransparency = 1
			Label.Text                   = Text
			Label.TextColor3             = Colors.Text
			Label.Font                   = Enum.Font.GothamMedium
			Label.TextSize               = 14
			Label.TextXAlignment         = Enum.TextXAlignment.Left
			Label.Parent                 = KeybindFrame

			local KeyButton = Instance.new("TextButton")
			KeyButton.Size             = UDim2.new(0, 110, 0, 32)
			KeyButton.Position         = UDim2.new(1, -125, 0.5, -16)
			KeyButton.BackgroundColor3 = Colors.Panel
			KeyButton.BackgroundTransparency = 0.3
			KeyButton.Text             = CurrentKey
			KeyButton.TextColor3       = Colors.TextDim
			KeyButton.Font             = Enum.Font.GothamMedium
			KeyButton.TextSize         = 13
			KeyButton.AutoButtonColor  = false
			KeyButton.Parent           = KeybindFrame
			Instance.new("UICorner", KeyButton).CornerRadius = UDim.new(0, 6)

			RegisterHover(KeyButton,
				function()
					if not Binding then
						TweenPlay(KeyButton, {BackgroundTransparency = 0}, 0.2)
					end
				end,
				function()
					if not Binding then
						TweenPlay(KeyButton, {BackgroundTransparency = 0.3}, 0.2)
					end
				end
			)

			KeyButton.MouseButton1Click:Connect(function()
				Binding = true
				KeyButton.Text = "..."
				TweenPlay(KeyButton, {BackgroundColor3 = Colors.Accent, TextColor3 = Colors.TextActive}, 0.2)
			end)

			UserInputService.InputBegan:Connect(function(input)
				if Binding then
					if input.KeyCode ~= Enum.KeyCode.Unknown then
						CurrentKey = input.KeyCode.Name
						KeyButton.Text = CurrentKey
						TweenPlay(KeyButton, {BackgroundColor3 = Colors.Panel, TextColor3 = Colors.TextDim}, 0.2)
						Binding = false
						if Callback then Callback(CurrentKey) end
					end
				end
			end)
			
			RegisterHover(KeybindFrame,
				function() 
					TweenPlay(KeybindFrame, {BackgroundTransparency = 0}, 0.2)
				end,
				function() 
					TweenPlay(KeybindFrame, {BackgroundTransparency = 0.2}, 0.2)
				end
			)
		end

		return Elements
	end

	-- ── UI Toggle Keybind ──────────────────────────────────
	local UIVisible = true
	local ToggleKey = Enum.KeyCode.RightShift
	
	function Library:SetToggleKey(key)
		ToggleKey = key
	end
	
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.KeyCode == ToggleKey then
			UIVisible = not UIVisible
			MainFrame.Visible = UIVisible
		end
	end)

	-- ── Open Animation ──────────────────────────────────────
	task.defer(function()
		TweenPlay(MainFrame, {Size = WindowSize}, 0.4, Enum.EasingStyle.Back)
		task.wait(0.5)
		Library:Notify("Welcome to " .. Title, 3, "success")
	end)

	return Tabs
end

return Library
