local Library = {}

-- ── Services ───────────────────────────────────────────────────────────────
local TweenService    = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService      = game:GetService("RunService")
local CoreGui         = game:GetService("CoreGui")
local Players         = game:GetService("Players")
local Stats           = game:GetService("Stats")

-- ── Constants & Theme ──────────────────────────────────────────────────────
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Theme = {
	Background    = Color3.fromRGB(20, 20, 24),
	Sidebar       = Color3.fromRGB(25, 25, 30), 
	Element       = Color3.fromRGB(34, 34, 38),
	ElementHover  = Color3.fromRGB(42, 42, 46),
	Text          = Color3.fromRGB(240, 240, 245),
	TextDim       = Color3.fromRGB(150, 150, 155),
	Accent        = Color3.fromRGB(0, 255, 180), -- Brighter Cyan/Mint
	Divider       = Color3.fromRGB(50, 50, 55),
	Transparency  = 0.1 -- Glass effect intensity (0 to 1)
}

-- ── Utility Functions ──────────────────────────────────────────────────────
local Utility = {}

function Utility:Tween(instance, properties, duration, style, direction)
	local info = TweenInfo.new(duration or 0.2, style or Enum.EasingStyle.Quart, direction or Enum.EasingDirection.Out)
	local tween = TweenService:Create(instance, info, properties)
	tween:Play()
	return tween
end

function Utility:GetTextSize(text, font, size)
	return game:GetService("TextService"):GetTextSize(text, size, font, Vector2.new(10000, 10000))
end

-- ── Main Library ───────────────────────────────────────────────────────────

function Library:CreateWindow(Settings)
	Settings = Settings or {}
	local TitleName = Settings.Title or "Meru Hub"
	
	if CoreGui:FindFirstChild("Meru_UI_Ultimate") then
		CoreGui["Meru_UI_Ultimate"]:Destroy()
	end

	-- 1. ScreenGui
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "Meru_UI_Ultimate"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.IgnoreGuiInset = true
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	
	if syn and syn.protect_gui then 
		syn.protect_gui(ScreenGui) 
		ScreenGui.Parent = CoreGui
	elseif gethui then 
		ScreenGui.Parent = gethui() 
	else 
		ScreenGui.Parent = CoreGui 
	end

	-- 2. Watermark (New Feature)
	local Watermark = Instance.new("Frame")
	Watermark.Name = "Watermark"
	Watermark.Size = UDim2.new(0, 200, 0, 30)
	Watermark.Position = UDim2.new(0, 20, 0, 20)
	Watermark.BackgroundColor3 = Theme.Background
	Watermark.BackgroundTransparency = 0.2
	Watermark.Parent = ScreenGui
	Instance.new("UICorner", Watermark).CornerRadius = UDim.new(0, 6)
	
	local WatermarkStroke = Instance.new("UIStroke", Watermark)
	WatermarkStroke.Color = Theme.Accent
	WatermarkStroke.Thickness = 1
	WatermarkStroke.Transparency = 0.5

	local WatermarkText = Instance.new("TextLabel")
	WatermarkText.Size = UDim2.new(1, 0, 1, 0)
	WatermarkText.BackgroundTransparency = 1
	WatermarkText.TextColor3 = Theme.Text
	WatermarkText.Font = Enum.Font.GothamMedium
	WatermarkText.TextSize = 12
	WatermarkText.Parent = Watermark

	task.spawn(function()
		while Watermark.Parent do
			local fps = math.floor(workspace:GetRealPhysicsFPS())
			local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValueString():split(" ")[1] or 0)
			local time = os.date("%H:%M:%S")
			WatermarkText.Text = string.format("%s | FPS: %d | Ping: %dms | %s", TitleName, fps, ping, time)
			Watermark.Size = UDim2.new(0, WatermarkText.TextBounds.X + 20, 0, 30)
			task.wait(1)
		end
	end)

	-- 3. Main Frame
	local MainFrame = Instance.new("Frame")
	MainFrame.Name = "MainFrame"
	MainFrame.Size = UDim2.new(0, 700, 0, 450)
	MainFrame.Position = UDim2.new(0.5, -350, 0.5, -225)
	MainFrame.BackgroundColor3 = Theme.Background
	MainFrame.BackgroundTransparency = Theme.Transparency -- Opacity added here
	MainFrame.BorderSizePixel = 0
	MainFrame.ClipsDescendants = true -- Changed to true for cleaner minimize
	MainFrame.Parent = ScreenGui
	
	local MainCorner = Instance.new("UICorner", MainFrame)
	MainCorner.CornerRadius = UDim.new(0, 8)

	local MainStroke = Instance.new("UIStroke", MainFrame)
	MainStroke.Color = Theme.Divider
	MainStroke.Thickness = 1

	-- Dragging
	local Dragging, DragInput, DragStart, StartPos
	MainFrame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			Dragging = true
			DragStart = input.Position
			StartPos = MainFrame.Position
		end
	end)
	MainFrame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then DragInput = input end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if input == DragInput and Dragging then
			local delta = input.Position - DragStart
			Utility:Tween(MainFrame, {Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + delta.X, StartPos.Y.Scale, StartPos.Y.Offset + delta.Y)}, 0.05)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end
	end)

	-- 4. Sidebar Layout
	local Sidebar = Instance.new("Frame")
	Sidebar.Name = "Sidebar"
	Sidebar.Size = UDim2.new(0, 180, 1, 0)
	Sidebar.BackgroundColor3 = Theme.Sidebar
	Sidebar.BackgroundTransparency = Theme.Transparency -- Opacity
	Sidebar.BorderSizePixel = 0
	Sidebar.Parent = MainFrame
	
	local SidebarDivider = Instance.new("Frame")
	SidebarDivider.Size = UDim2.new(0, 1, 1, 0)
	SidebarDivider.Position = UDim2.new(1, 0, 0, 0)
	SidebarDivider.BackgroundColor3 = Theme.Divider
	SidebarDivider.BorderSizePixel = 0
	SidebarDivider.Parent = Sidebar

	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.Size = UDim2.new(1, -20, 0, 50)
	TitleLabel.Position = UDim2.new(0, 15, 0, 0)
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Text = TitleName
	TitleLabel.TextColor3 = Theme.Accent
	TitleLabel.Font = Enum.Font.GothamBold
	TitleLabel.TextSize = 22
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	TitleLabel.Parent = Sidebar

	-- Tab Container
	local TabContainer = Instance.new("ScrollingFrame")
	TabContainer.Size = UDim2.new(1, 0, 1, -100) -- Space for Settings + Profile
	TabContainer.Position = UDim2.new(0, 0, 0, 60)
	TabContainer.BackgroundTransparency = 1
	TabContainer.ScrollBarThickness = 0
	TabContainer.Parent = Sidebar
	local TabList = Instance.new("UIListLayout", TabContainer)
	TabList.Padding = UDim.new(0, 5)
	TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center

	-- Bottom Section (Settings + Profile)
	local BottomContainer = Instance.new("Frame")
	BottomContainer.Size = UDim2.new(1, 0, 0, 90)
	BottomContainer.Position = UDim2.new(0, 0, 1, -90)
	BottomContainer.BackgroundTransparency = 1
	BottomContainer.Parent = Sidebar

	-- Profile
	local ProfileFrame = Instance.new("Frame")
	ProfileFrame.Size = UDim2.new(1, -20, 0, 40)
	ProfileFrame.Position = UDim2.new(0, 10, 1, -50)
	ProfileFrame.BackgroundColor3 = Theme.Element
	ProfileFrame.BackgroundTransparency = 0.5
	ProfileFrame.Parent = BottomContainer
	Instance.new("UICorner", ProfileFrame).CornerRadius = UDim.new(0, 6)

	local Avatar = Instance.new("ImageLabel")
	Avatar.Size = UDim2.new(0, 28, 0, 28)
	Avatar.Position = UDim2.new(0, 6, 0.5, -14)
	Avatar.BackgroundColor3 = Theme.Background
	Avatar.Image = "https://www.roblox.com/headshot-thumbnail/image?userId="..LocalPlayer.UserId.."&width=420&height=420&format=png"
	Avatar.Parent = ProfileFrame
	Instance.new("UICorner", Avatar).CornerRadius = UDim.new(1, 0)

	local Username = Instance.new("TextLabel")
	Username.Size = UDim2.new(1, -45, 1, 0)
	Username.Position = UDim2.new(0, 42, 0, 0)
	Username.BackgroundTransparency = 1
	Username.Text = LocalPlayer.Name
	Username.TextColor3 = Theme.Text
	Username.Font = Enum.Font.GothamMedium
	Username.TextSize = 11
	Username.TextXAlignment = Enum.TextXAlignment.Left
	Username.Parent = ProfileFrame

	-- Settings Button (Pinned)
	local SettingsBtn = Instance.new("TextButton")
	SettingsBtn.Size = UDim2.new(1, -20, 0, 30)
	SettingsBtn.Position = UDim2.new(0, 10, 0, 0)
	SettingsBtn.BackgroundColor3 = Theme.Element
	SettingsBtn.BackgroundTransparency = 1 -- Transparent until hovered
	SettingsBtn.Text = "Settings"
	SettingsBtn.TextColor3 = Theme.TextDim
	SettingsBtn.Font = Enum.Font.GothamMedium
	SettingsBtn.TextSize = 13
	SettingsBtn.Parent = BottomContainer
	Instance.new("UICorner", SettingsBtn).CornerRadius = UDim.new(0, 6)

	-- 5. Content Area
	local ContentArea = Instance.new("Frame")
	ContentArea.Name = "ContentArea"
	ContentArea.Size = UDim2.new(1, -180, 1, 0)
	ContentArea.Position = UDim2.new(0, 180, 0, 0)
	ContentArea.BackgroundTransparency = 1
	ContentArea.Parent = MainFrame

	local PagesContainer = Instance.new("Frame")
	PagesContainer.Size = UDim2.new(1, 0, 1, -50)
	PagesContainer.Position = UDim2.new(0, 0, 0, 50)
	PagesContainer.BackgroundTransparency = 1
	PagesContainer.Parent = ContentArea

	-- Minimize Logic
	local TopBar = Instance.new("Frame")
	TopBar.Size = UDim2.new(1, 0, 0, 40)
	TopBar.BackgroundTransparency = 1
	TopBar.Parent = ContentArea

	local MinBtn = Instance.new("TextButton")
	MinBtn.Size = UDim2.new(0, 40, 0, 40)
	MinBtn.Position = UDim2.new(1, -40, 0, 0)
	MinBtn.BackgroundTransparency = 1
	MinBtn.Text = "-"
	MinBtn.TextColor3 = Theme.TextDim
	MinBtn.TextSize = 24
	MinBtn.Font = Enum.Font.Gotham
	MinBtn.Parent = TopBar

	local Minimized = false
	local OldSize = MainFrame.Size
	
	-- Restore Button (The button that appears when minimized)
	local RestoreBtn = Instance.new("TextButton")
	RestoreBtn.Name = "RestoreBtn"
	RestoreBtn.Size = UDim2.new(1, 0, 1, 0)
	RestoreBtn.BackgroundColor3 = Theme.Background
	RestoreBtn.BackgroundTransparency = 0.1
	RestoreBtn.Text = "M" -- Icon placeholder
	RestoreBtn.TextColor3 = Theme.Accent
	RestoreBtn.Font = Enum.Font.GothamBold
	RestoreBtn.TextSize = 20
	RestoreBtn.Visible = false
	RestoreBtn.Parent = MainFrame
	Instance.new("UICorner", RestoreBtn).CornerRadius = UDim.new(0, 8)
	Instance.new("UIStroke", RestoreBtn).Color = Theme.Accent
	Instance.new("UIStroke", RestoreBtn).Thickness = 1

	local function ToggleMinimize()
		Minimized = not Minimized
		
		if Minimized then
			OldSize = MainFrame.Size
			
			-- 1. Hide contents immediately to prevent glitching
			Sidebar.Visible = false
			ContentArea.Visible = false
			
			-- 2. Shrink Window
			local Tween = Utility:Tween(MainFrame, {Size = UDim2.new(0, 50, 0, 50)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
			
			-- 3. Show Restore Button after tween
			Tween.Completed:Connect(function()
				RestoreBtn.Visible = true
			end)
		else
			-- 1. Hide Restore Button
			RestoreBtn.Visible = false
			
			-- 2. Expand Window
			local Tween = Utility:Tween(MainFrame, {Size = OldSize}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
			
			-- 3. Show contents only after expanded
			Tween.Completed:Connect(function()
				Sidebar.Visible = true
				ContentArea.Visible = true
			end)
		end
	end

	MinBtn.MouseButton1Click:Connect(ToggleMinimize)
	RestoreBtn.MouseButton1Click:Connect(ToggleMinimize)

	-- ── Notifications ──────────────────────────────────────────────────────────
	local NotifyContainer = Instance.new("Frame")
	NotifyContainer.Size = UDim2.new(0, 250, 1, 0)
	NotifyContainer.Position = UDim2.new(0, 20, 0, 0) -- Left side notifications
	NotifyContainer.BackgroundTransparency = 1
	NotifyContainer.Parent = ScreenGui
	local NotifyList = Instance.new("UIListLayout", NotifyContainer)
	NotifyList.VerticalAlignment = Enum.VerticalAlignment.Bottom
	NotifyList.Padding = UDim.new(0, 5)

	function Library:Notify(Config)
		local Title = Config.Title or "System"
		local Msg = Config.Content or "Notification"
		
		local NFrame = Instance.new("Frame")
		NFrame.Size = UDim2.new(1, 0, 0, 0) -- Grow animation
		NFrame.BackgroundColor3 = Theme.Sidebar
		NFrame.BackgroundTransparency = 0.1
		NFrame.ClipsDescendants = true
		NFrame.Parent = NotifyContainer
		Instance.new("UICorner", NFrame).CornerRadius = UDim.new(0, 6)
		Instance.new("UIStroke", NFrame).Color = Theme.Divider
		
		local NTitle = Instance.new("TextLabel")
		NTitle.Position = UDim2.new(0, 10, 0, 5)
		NTitle.Size = UDim2.new(1, -20, 0, 20)
		NTitle.BackgroundTransparency = 1
		NTitle.Text = Title
		NTitle.TextColor3 = Theme.Accent
		NTitle.Font = Enum.Font.GothamBold
		NTitle.TextSize = 12
		NTitle.TextXAlignment = Enum.TextXAlignment.Left
		NTitle.Parent = NFrame
		
		local NText = Instance.new("TextLabel")
		NText.Position = UDim2.new(0, 10, 0, 25)
		NText.Size = UDim2.new(1, -20, 0, 20)
		NText.BackgroundTransparency = 1
		NText.Text = Msg
		NText.TextColor3 = Theme.Text
		NText.Font = Enum.Font.Gotham
		NText.TextSize = 11
		NText.TextXAlignment = Enum.TextXAlignment.Left
		NText.TextWrapped = true
		NText.Parent = NFrame

		Utility:Tween(NFrame, {Size = UDim2.new(1, 0, 0, 50)}, 0.3)
		
		task.delay(Config.Duration or 3, function()
			Utility:Tween(NFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.3).Completed:Connect(function()
				NFrame:Destroy()
			end)
		end)
	end

	-- ── Tabs System ────────────────────────────────────────────────────────────
	local Tabs = {}
	
	-- Function to switch tabs
	local function SwitchTab(TargetPage, TargetButton)
		for _, page in pairs(PagesContainer:GetChildren()) do page.Visible = false end
		for _, btn in pairs(TabContainer:GetChildren()) do
			if btn:IsA("TextButton") then
				Utility:Tween(btn, {BackgroundTransparency = 1}, 0.2)
				Utility:Tween(btn.Title, {TextColor3 = Theme.TextDim}, 0.2)
			end
		end
		-- Reset Settings Btn
		Utility:Tween(SettingsBtn, {BackgroundTransparency = 1, TextColor3 = Theme.TextDim}, 0.2)
		
		TargetPage.Visible = true
		if TargetButton then
			Utility:Tween(TargetButton, {BackgroundTransparency = 0}, 0.2)
			if TargetButton:FindFirstChild("Title") then
				Utility:Tween(TargetButton.Title, {TextColor3 = Theme.Accent}, 0.2)
			else
				Utility:Tween(TargetButton, {TextColor3 = Theme.Accent}, 0.2)
			end
		end
	end

	-- Create Settings Page
	local SettingsPage = Instance.new("ScrollingFrame")
	SettingsPage.Name = "SettingsPage"
	SettingsPage.Size = UDim2.new(1, 0, 1, 0)
	SettingsPage.BackgroundTransparency = 1
	SettingsPage.ScrollBarThickness = 2
	SettingsPage.Visible = false
	SettingsPage.Parent = PagesContainer
	local SetList = Instance.new("UIListLayout", SettingsPage)
	SetList.Padding = UDim.new(0, 5)
	Instance.new("UIPadding", SettingsPage).PaddingLeft = UDim.new(0, 10)
	Instance.new("UIPadding", SettingsPage).PaddingRight = UDim.new(0, 10)
	Instance.new("UIPadding", SettingsPage).PaddingTop = UDim.new(0, 10)

	SettingsBtn.MouseButton1Click:Connect(function()
		SwitchTab(SettingsPage, SettingsBtn)
	end)

	function Tabs:Tab(Config)
		local Name = Config.Name or "Tab"
		
		local TabBtn = Instance.new("TextButton")
		TabBtn.Size = UDim2.new(0, 160, 0, 32)
		TabBtn.BackgroundTransparency = 1
		TabBtn.BackgroundColor3 = Theme.Element
		TabBtn.Text = ""
		TabBtn.Parent = TabContainer
		Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

		local TabTitle = Instance.new("TextLabel")
		TabTitle.Name = "Title"
		TabTitle.Size = UDim2.new(1, -20, 1, 0)
		TabTitle.Position = UDim2.new(0, 15, 0, 0)
		TabTitle.BackgroundTransparency = 1
		TabTitle.Text = Name
		TabTitle.TextColor3 = Theme.TextDim
		TabTitle.Font = Enum.Font.GothamMedium
		TabTitle.TextSize = 13
		TabTitle.TextXAlignment = Enum.TextXAlignment.Left
		TabTitle.Parent = TabBtn

		local Page = Instance.new("ScrollingFrame")
		Page.Name = Name .. "Page"
		Page.Size = UDim2.new(1, 0, 1, 0)
		Page.BackgroundTransparency = 1
		Page.ScrollBarThickness = 2
		Page.Visible = false
		Page.Parent = PagesContainer
		
		local PageList = Instance.new("UIListLayout", Page)
		PageList.Padding = UDim.new(0, 5)
		
		local Pad = Instance.new("UIPadding", Page)
		Pad.PaddingLeft = UDim.new(0, 10)
		Pad.PaddingRight = UDim.new(0, 10)
		Pad.PaddingTop = UDim.new(0, 10)

		TabBtn.MouseButton1Click:Connect(function()
			SwitchTab(Page, TabBtn)
		end)
		
		-- Select first tab by default
		if #TabContainer:GetChildren() == 2 then -- 1 layout + 1 btn
			SwitchTab(Page, TabBtn)
		end

		local Elements = {}
		
		-- Helper for adding elements to correct page (Settings or Normal)
		local function GetParent()
			return Page
		end

		function Elements:Button(Config)
			local BtnName = Config.Name or "Button"
			local Callback = Config.Callback or function() end
			
			local Frame = Instance.new("Frame")
			Frame.Size = UDim2.new(1, 0, 0, 34)
			Frame.BackgroundColor3 = Theme.Element
			Frame.BackgroundTransparency = 0.2
			Frame.Parent = GetParent()
			Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 4)

			local Btn = Instance.new("TextButton")
			Btn.Size = UDim2.new(1, 0, 1, 0)
			Btn.BackgroundTransparency = 1
			Btn.Text = BtnName
			Btn.TextColor3 = Theme.Text
			Btn.Font = Enum.Font.Gotham
			Btn.TextSize = 13
			Btn.Parent = Frame
			
			Btn.MouseEnter:Connect(function() Utility:Tween(Frame, {BackgroundColor3 = Theme.ElementHover}, 0.2) end)
			Btn.MouseLeave:Connect(function() Utility:Tween(Frame, {BackgroundColor3 = Theme.Element}, 0.2) end)
			
			Btn.MouseButton1Click:Connect(function()
				Utility:Tween(Btn, {TextSize = 11}, 0.1)
				task.wait(0.1)
				Utility:Tween(Btn, {TextSize = 13}, 0.1)
				Callback()
			end)
		end

		function Elements:Toggle(Config)
			local TogName = Config.Name or "Toggle"
			local Default = Config.Default or false
			local Callback = Config.Callback or function() end
			local State = Default

			local Frame = Instance.new("Frame")
			Frame.Size = UDim2.new(1, 0, 0, 34)
			Frame.BackgroundColor3 = Theme.Element
			Frame.BackgroundTransparency = 0.2
			Frame.Parent = GetParent()
			Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 4)

			local Label = Instance.new("TextLabel")
			Label.Size = UDim2.new(1, -50, 1, 0)
			Label.Position = UDim2.new(0, 10, 0, 0)
			Label.BackgroundTransparency = 1
			Label.Text = TogName
			Label.TextColor3 = Theme.Text
			Label.Font = Enum.Font.Gotham
			Label.TextSize = 13
			Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.Parent = Frame

			local Indicator = Instance.new("Frame")
			Indicator.Size = UDim2.new(0, 20, 0, 20)
			Indicator.Position = UDim2.new(1, -25, 0.5, -10)
			Indicator.BackgroundColor3 = State and Theme.Accent or Theme.Sidebar
			Indicator.Parent = Frame
			Instance.new("UICorner", Indicator).CornerRadius = UDim.new(0, 4)

			local Trigger = Instance.new("TextButton")
			Trigger.Size = UDim2.new(1, 0, 1, 0)
			Trigger.BackgroundTransparency = 1
			Trigger.Text = ""
			Trigger.Parent = Frame

			Trigger.MouseButton1Click:Connect(function()
				State = not State
				Utility:Tween(Indicator, {BackgroundColor3 = State and Theme.Accent or Theme.Sidebar}, 0.2)
				Callback(State)
			end)
		end

		function Elements:Textbox(Config)
			local BoxName = Config.Name or "Textbox"
			local PlaceHolder = Config.Placeholder or "..."
			local Callback = Config.Callback or function() end

			local Frame = Instance.new("Frame")
			Frame.Size = UDim2.new(1, 0, 0, 34)
			Frame.BackgroundColor3 = Theme.Element
			Frame.BackgroundTransparency = 0.2
			Frame.Parent = GetParent()
			Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 4)

			local Label = Instance.new("TextLabel")
			Label.Size = UDim2.new(0, 100, 1, 0)
			Label.Position = UDim2.new(0, 10, 0, 0)
			Label.BackgroundTransparency = 1
			Label.Text = BoxName
			Label.TextColor3 = Theme.Text
			Label.Font = Enum.Font.Gotham
			Label.TextSize = 13
			Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.Parent = Frame

			local InputBox = Instance.new("TextBox")
			InputBox.Size = UDim2.new(0, 120, 0, 24)
			InputBox.Position = UDim2.new(1, -130, 0.5, -12)
			InputBox.BackgroundColor3 = Theme.Sidebar
			InputBox.TextColor3 = Theme.Text
			InputBox.PlaceholderText = PlaceHolder
			InputBox.Text = ""
			InputBox.Font = Enum.Font.Gotham
			InputBox.TextSize = 12
			InputBox.Parent = Frame
			Instance.new("UICorner", InputBox).CornerRadius = UDim.new(0, 4)

			InputBox.FocusLost:Connect(function(enter)
				if enter then Callback(InputBox.Text) end
			end)
		end

		function Elements:Keybind(Config)
			local Name = Config.Name or "Keybind"
			local Default = Config.Default or Enum.KeyCode.E
			local Callback = Config.Callback or function() end
			
			local CurrentKey = Default

			local Frame = Instance.new("Frame")
			Frame.Size = UDim2.new(1, 0, 0, 34)
			Frame.BackgroundColor3 = Theme.Element
			Frame.BackgroundTransparency = 0.2
			Frame.Parent = GetParent()
			Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 4)

			local Label = Instance.new("TextLabel")
			Label.Size = UDim2.new(1, -80, 1, 0)
			Label.Position = UDim2.new(0, 10, 0, 0)
			Label.BackgroundTransparency = 1
			Label.Text = Name
			Label.TextColor3 = Theme.Text
			Label.Font = Enum.Font.Gotham
			Label.TextSize = 13
			Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.Parent = Frame

			local KeyBtn = Instance.new("TextButton")
			KeyBtn.Size = UDim2.new(0, 70, 0, 24)
			KeyBtn.Position = UDim2.new(1, -75, 0.5, -12)
			KeyBtn.BackgroundColor3 = Theme.Sidebar
			KeyBtn.Text = CurrentKey.Name
			KeyBtn.TextColor3 = Theme.TextDim
			KeyBtn.Font = Enum.Font.Gotham
			KeyBtn.TextSize = 12
			KeyBtn.Parent = Frame
			Instance.new("UICorner", KeyBtn).CornerRadius = UDim.new(0, 4)

			local Binding = false

			KeyBtn.MouseButton1Click:Connect(function()
				Binding = true
				KeyBtn.Text = "..."
				KeyBtn.TextColor3 = Theme.Accent
			end)

			UserInputService.InputBegan:Connect(function(input)
				if Binding then
					if input.UserInputType == Enum.UserInputType.Keyboard then
						CurrentKey = input.KeyCode
						KeyBtn.Text = CurrentKey.Name
						KeyBtn.TextColor3 = Theme.TextDim
						Binding = false
						Callback(CurrentKey)
					elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 then
						-- Cancel bind
						KeyBtn.Text = CurrentKey.Name
						KeyBtn.TextColor3 = Theme.TextDim
						Binding = false
					end
				elseif input.KeyCode == CurrentKey then
					-- Fire callback if needed (usually handled by user, but nice to have)
				end
			end)
		end

		return Elements
	end
	
	-- Populate Settings Page automatically
	local SettingsTab = {
		Button = function(_, C) 
			local F = Instance.new("Frame") -- Mock
			F.Parent = SettingsPage
			-- Reuse Logic manually for settings if needed, 
			-- but for simplicity we can just expose a "Settings" tab object
		end
	}
	
	-- Return a wrapper so you can add to settings
	function Library:Settings()
		-- Return a fake "Tab" object that parents to SettingsPage
		local wrapper = {}
		function wrapper:Button(C) Tabs:Tab({Name="T"}).Button(nil, C) end -- Simplification hack
		-- In reality, you'd refactor the `Elements` function to accept a parent.
		-- Let's fix the `GetParent` scope above.
		
		-- FIX: We will just manually create the UI elements for settings here:
		local Elem = {}
		
		function Elem:Button(Config)
			local Frame = Instance.new("Frame")
			Frame.Size = UDim2.new(1, 0, 0, 34)
			Frame.BackgroundColor3 = Theme.Element
			Frame.BackgroundTransparency = 0.2
			Frame.Parent = SettingsPage
			Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 4)
			
			local Btn = Instance.new("TextButton")
			Btn.Size = UDim2.new(1, 0, 1, 0)
			Btn.BackgroundTransparency = 1
			Btn.Text = Config.Name
			Btn.TextColor3 = Theme.Text
			Btn.Font = Enum.Font.Gotham
			Btn.TextSize = 13
			Btn.Parent = Frame
			Btn.MouseButton1Click:Connect(Config.Callback)
		end
		return Elem
	end

	return Tabs
end

return Library
