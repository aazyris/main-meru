local Library = {}

-- ── Services ───────────────────────────────────────────────────────────────
local TweenService    = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService      = game:GetService("RunService")
local CoreGui         = game:GetService("CoreGui")
local Players         = game:GetService("Players")
local HttpService     = game:GetService("HttpService")

-- ── Constants & Theme ──────────────────────────────────────────────────────
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local Theme = {
	Background    = Color3.fromRGB(20, 20, 24),
	Sidebar       = Color3.fromRGB(28, 28, 32), 
	Element       = Color3.fromRGB(34, 34, 38),
	ElementHover  = Color3.fromRGB(42, 42, 46),
	TitleBar      = Color3.fromRGB(28, 28, 32),
	Text          = Color3.fromRGB(240, 240, 245),
	TextDim       = Color3.fromRGB(150, 150, 155),
	Accent        = Color3.fromRGB(100, 210, 210), -- Cyan Accent
	AccentDark    = Color3.fromRGB(80, 180, 180),
	Divider       = Color3.fromRGB(50, 50, 55),
	Success       = Color3.fromRGB(100, 255, 120),
	Error         = Color3.fromRGB(255, 100, 100),
}

-- ── Utility Functions ──────────────────────────────────────────────────────
local Utility = {}

function Utility:Tween(instance, properties, duration, style, direction)
	local info = TweenInfo.new(duration or 0.2, style or Enum.EasingStyle.Quart, direction or Enum.EasingDirection.Out)
	local tween = TweenService:Create(instance, info, properties)
	tween:Play()
	return tween
end

function Utility:GetTextSize(text, font, size, width)
	return game:GetService("TextService"):GetTextSize(text, size, font, Vector2.new(width, 10000))
end

function Utility:ConnectHover(instance, onEnter, onLeave)
	instance.MouseEnter:Connect(onEnter)
	instance.MouseLeave:Connect(onLeave)
end

-- ── Library Main ───────────────────────────────────────────────────────────

function Library:CreateWindow(Settings)
	Settings = Settings or {}
	local TitleName = Settings.Title or "Meru Hub"
	local ToggleKey = Settings.ToggleKey or Enum.KeyCode.RightControl

	-- Protection against multiple instances
	if CoreGui:FindFirstChild("Meru_UI_V2") then
		CoreGui["Meru_UI_V2"]:Destroy()
	end

	-- 1. ScreenGui Setup
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "Meru_UI_V2"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.IgnoreGuiInset = true
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	
	-- Protect GUI from detection (if executor supports it)
	if syn and syn.protect_gui then 
		syn.protect_gui(ScreenGui) 
		ScreenGui.Parent = CoreGui
	elseif gethui then 
		ScreenGui.Parent = gethui() 
	else 
		ScreenGui.Parent = CoreGui 
	end

	-- 2. Main Frame
	local MainFrame = Instance.new("Frame")
	MainFrame.Name = "MainFrame"
	MainFrame.Size = UDim2.new(0, 650, 0, 450) -- Slightly larger for better layout
	MainFrame.Position = UDim2.new(0.5, -325, 0.5, -225)
	MainFrame.BackgroundColor3 = Theme.Background
	MainFrame.BorderSizePixel = 0
	MainFrame.ClipsDescendants = false -- Important for Dropdowns/Shadows
	MainFrame.Parent = ScreenGui
	
	local MainCorner = Instance.new("UICorner", MainFrame)
	MainCorner.CornerRadius = UDim.new(0, 10)

	-- Shadow
	local Shadow = Instance.new("ImageLabel")
	Shadow.Name = "Shadow"
	Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
	Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
	Shadow.Size = UDim2.new(1, 140, 1, 140)
	Shadow.BackgroundTransparency = 1
	Shadow.Image = "rbxassetid://6014261993" -- Smooth shadow
	Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
	Shadow.ImageTransparency = 0.5
	Shadow.ZIndex = -1
	Shadow.SliceCenter = Rect.new(49, 49, 450, 450)
	Shadow.ScaleType = Enum.ScaleType.Slice
	Shadow.SliceScale = 1
	Shadow.Parent = MainFrame

	-- 3. Dragging Logic (Smooth)
	local Dragging, DragInput, DragStart, StartPos
	
	local function UpdateDrag(input)
		local delta = input.Position - DragStart
		local targetPos = UDim2.new(
			StartPos.X.Scale, StartPos.X.Offset + delta.X,
			StartPos.Y.Scale, StartPos.Y.Offset + delta.Y
		)
		Utility:Tween(MainFrame, {Position = targetPos}, 0.1, Enum.EasingStyle.Sine)
	end

	MainFrame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			Dragging = true
			DragStart = input.Position
			StartPos = MainFrame.Position
			
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					Dragging = false
				end
			end)
		end
	end)

	MainFrame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			DragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == DragInput and Dragging then
			UpdateDrag(input)
		end
	end)

	-- 4. Sidebar (Left)
	local Sidebar = Instance.new("Frame")
	Sidebar.Name = "Sidebar"
	Sidebar.Size = UDim2.new(0, 160, 1, 0)
	Sidebar.BackgroundColor3 = Theme.Sidebar
	Sidebar.BorderSizePixel = 0
	Sidebar.Parent = MainFrame
	
	local SidebarCorner = Instance.new("UICorner", Sidebar)
	SidebarCorner.CornerRadius = UDim.new(0, 10)
	
	-- Fix corner clipping by adding a filler on the right side of sidebar
	local SidebarFiller = Instance.new("Frame")
	SidebarFiller.Size = UDim2.new(0, 10, 1, 0)
	SidebarFiller.Position = UDim2.new(1, -10, 0, 0)
	SidebarFiller.BackgroundColor3 = Theme.Sidebar
	SidebarFiller.BorderSizePixel = 0
	SidebarFiller.Parent = Sidebar

	local SidebarDivider = Instance.new("Frame")
	SidebarDivider.Size = UDim2.new(0, 1, 1, 0)
	SidebarDivider.Position = UDim2.new(1, 0, 0, 0)
	SidebarDivider.BackgroundColor3 = Theme.Divider
	SidebarDivider.BorderSizePixel = 0
	SidebarDivider.Parent = Sidebar

	-- Title
	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.Size = UDim2.new(1, -20, 0, 50)
	TitleLabel.Position = UDim2.new(0, 15, 0, 0)
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Text = TitleName
	TitleLabel.TextColor3 = Theme.Accent
	TitleLabel.Font = Enum.Font.GothamBold
	TitleLabel.TextSize = 20
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	TitleLabel.Parent = Sidebar

	-- Tab Container
	local TabContainer = Instance.new("ScrollingFrame")
	TabContainer.Name = "TabContainer"
	TabContainer.Size = UDim2.new(1, 0, 1, -110) -- Space for profile + title
	TabContainer.Position = UDim2.new(0, 0, 0, 60)
	TabContainer.BackgroundTransparency = 1
	TabContainer.ScrollBarThickness = 2
	TabContainer.ScrollBarImageColor3 = Theme.Accent
	TabContainer.BorderSizePixel = 0
	TabContainer.Parent = Sidebar

	local TabListLayout = Instance.new("UIListLayout", TabContainer)
	TabListLayout.Padding = UDim.new(0, 5)
	TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder

	local TabPadding = Instance.new("UIPadding", TabContainer)
	TabPadding.PaddingLeft = UDim.new(0, 10)
	TabPadding.PaddingRight = UDim.new(0, 10)

	-- Profile Section (Bottom Left)
	local ProfileFrame = Instance.new("Frame")
	ProfileFrame.Name = "ProfileFrame"
	ProfileFrame.Size = UDim2.new(1, -20, 0, 40)
	ProfileFrame.Position = UDim2.new(0, 10, 1, -50)
	ProfileFrame.BackgroundColor3 = Theme.Element
	ProfileFrame.Parent = Sidebar
	
	local ProfileCorner = Instance.new("UICorner", ProfileFrame)
	ProfileCorner.CornerRadius = UDim.new(0, 6)

	local Avatar = Instance.new("ImageLabel")
	Avatar.Size = UDim2.new(0, 30, 0, 30)
	Avatar.Position = UDim2.new(0, 5, 0.5, -15)
	Avatar.BackgroundColor3 = Theme.Background
	Avatar.Image = "https://www.roblox.com/headshot-thumbnail/image?userId="..LocalPlayer.UserId.."&width=420&height=420&format=png"
	Avatar.Parent = ProfileFrame
	
	local AvatarCorner = Instance.new("UICorner", Avatar)
	AvatarCorner.CornerRadius = UDim.new(1, 0)

	local Username = Instance.new("TextLabel")
	Username.Size = UDim2.new(1, -45, 1, 0)
	Username.Position = UDim2.new(0, 40, 0, 0)
	Username.BackgroundTransparency = 1
	Username.Text = LocalPlayer.Name
	Username.TextColor3 = Theme.Text
	Username.Font = Enum.Font.GothamMedium
	Username.TextSize = 12
	Username.TextXAlignment = Enum.TextXAlignment.Left
	Username.Parent = ProfileFrame

	-- 5. Content Area
	local ContentArea = Instance.new("Frame")
	ContentArea.Name = "ContentArea"
	ContentArea.Size = UDim2.new(1, -160, 1, 0)
	ContentArea.Position = UDim2.new(0, 160, 0, 0)
	ContentArea.BackgroundTransparency = 1
	ContentArea.ClipsDescendants = true
	ContentArea.Parent = MainFrame

	-- Top Bar (Minimize/Close)
	local TopBar = Instance.new("Frame")
	TopBar.Size = UDim2.new(1, 0, 0, 40)
	TopBar.BackgroundTransparency = 1
	TopBar.Parent = ContentArea

	local CloseBtn = Instance.new("TextButton")
	CloseBtn.Size = UDim2.new(0, 40, 0, 40)
	CloseBtn.Position = UDim2.new(1, -40, 0, 0)
	CloseBtn.BackgroundTransparency = 1
	CloseBtn.Text = "×"
	CloseBtn.TextColor3 = Theme.TextDim
	CloseBtn.TextSize = 24
	CloseBtn.Font = Enum.Font.GothamMedium
	CloseBtn.Parent = TopBar

	local MinBtn = Instance.new("TextButton")
	MinBtn.Size = UDim2.new(0, 40, 0, 40)
	MinBtn.Position = UDim2.new(1, -80, 0, 0)
	MinBtn.BackgroundTransparency = 1
	MinBtn.Text = "-"
	MinBtn.TextColor3 = Theme.TextDim
	MinBtn.TextSize = 24
	MinBtn.Font = Enum.Font.GothamMedium
	MinBtn.Parent = TopBar

	-- Pages Container
	local PagesContainer = Instance.new("Frame")
	PagesContainer.Name = "Pages"
	PagesContainer.Size = UDim2.new(1, 0, 1, -50)
	PagesContainer.Position = UDim2.new(0, 0, 0, 50)
	PagesContainer.BackgroundTransparency = 1
	PagesContainer.Parent = ContentArea

	-- ── Minimize Logic ────────────────────────────────────────────────────────
	local Minimized = false
	local OldSize = MainFrame.Size

	local function ToggleMinimize()
		Minimized = not Minimized
		if Minimized then
			OldSize = MainFrame.Size
			-- Fade out contents
			Utility:Tween(ContentArea, {GroupTransparency = 1}, 0.2)
			Utility:Tween(Sidebar, {GroupTransparency = 1}, 0.2)
			task.wait(0.1)
			Sidebar.Visible = false
			ContentArea.Visible = false
			
			-- Shrink Frame
			Utility:Tween(MainFrame, {Size = UDim2.new(0, 50, 0, 50)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In)
			
			-- Create a Restore Button
			local RestoreBtn = Instance.new("ImageButton")
			RestoreBtn.Name = "RestoreBtn"
			RestoreBtn.Size = UDim2.new(1, 0, 1, 0)
			RestoreBtn.BackgroundTransparency = 1
			RestoreBtn.Image = "rbxassetid://11484556740" -- Logo icon or similar
			RestoreBtn.ImageColor3 = Theme.Accent
			RestoreBtn.Parent = MainFrame
			
			RestoreBtn.MouseButton1Click:Connect(function()
				RestoreBtn:Destroy()
				ToggleMinimize()
			end)
		else
			if MainFrame:FindFirstChild("RestoreBtn") then MainFrame.RestoreBtn:Destroy() end
			
			-- Expand Frame
			Utility:Tween(MainFrame, {Size = OldSize}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
			task.wait(0.2)
			Sidebar.Visible = true
			ContentArea.Visible = true
			Utility:Tween(ContentArea, {GroupTransparency = 0}, 0.2)
			Utility:Tween(Sidebar, {GroupTransparency = 0}, 0.2)
		end
	end

	MinBtn.MouseButton1Click:Connect(ToggleMinimize)
	
	CloseBtn.MouseEnter:Connect(function() Utility:Tween(CloseBtn, {TextColor3 = Theme.Error}, 0.2) end)
	CloseBtn.MouseLeave:Connect(function() Utility:Tween(CloseBtn, {TextColor3 = Theme.TextDim}, 0.2) end)
	CloseBtn.MouseButton1Click:Connect(function()
		ScreenGui:Destroy()
	end)

	-- ── Tooltip System ────────────────────────────────────────────────────────
	local TooltipLabel = Instance.new("TextLabel")
	TooltipLabel.Size = UDim2.new(0, 0, 0, 20)
	TooltipLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
	TooltipLabel.TextColor3 = Theme.Text
	TooltipLabel.TextSize = 12
	TooltipLabel.Font = Enum.Font.Gotham
	TooltipLabel.Visible = false
	TooltipLabel.ZIndex = 100
	TooltipLabel.Parent = ScreenGui
	Instance.new("UICorner", TooltipLabel).CornerRadius = UDim.new(0, 4)
	Instance.new("UIPadding", TooltipLabel).PaddingLeft = UDim.new(0, 5)
	Instance.new("UIPadding", TooltipLabel).PaddingRight = UDim.new(0, 5)

	local function AddTooltip(element, text)
		if not text then return end
		element.MouseEnter:Connect(function()
			TooltipLabel.Text = text
			TooltipLabel.Size = UDim2.new(0, Utility:GetTextSize(text, Enum.Font.Gotham, 12, 500).X + 10, 0, 20)
			TooltipLabel.Visible = true
		end)
		element.MouseLeave:Connect(function()
			TooltipLabel.Visible = false
		end)
		element.MouseMoved:Connect(function()
			local m = UserInputService:GetMouseLocation()
			TooltipLabel.Position = UDim2.new(0, m.X + 15, 0, m.Y + 15)
		end)
	end

	-- ── Notification System ───────────────────────────────────────────────────
	local NotifyContainer = Instance.new("Frame")
	NotifyContainer.Size = UDim2.new(0, 300, 1, 0)
	NotifyContainer.Position = UDim2.new(1, -310, 0, 0)
	NotifyContainer.BackgroundTransparency = 1
	NotifyContainer.Parent = ScreenGui
	
	local NotifyList = Instance.new("UIListLayout", NotifyContainer)
	NotifyList.Padding = UDim.new(0, 5)
	NotifyList.VerticalAlignment = Enum.VerticalAlignment.Bottom
	NotifyList.SortOrder = Enum.SortOrder.LayoutOrder

	function Library:Notify(Config)
		local Title = Config.Title or "Notification"
		local Content = Config.Content or ""
		local Duration = Config.Duration or 3
		local Image = Config.Image or "rbxassetid://11326467362" -- Info Icon
		
		local Frame = Instance.new("Frame")
		Frame.Size = UDim2.new(1, 0, 0, 60)
		Frame.BackgroundColor3 = Theme.Sidebar
		Frame.BackgroundTransparency = 1 -- Start invisible
		Frame.Parent = NotifyContainer
		Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)
		
		local Glow = Instance.new("UIStroke", Frame)
		Glow.Color = Theme.Divider
		Glow.Thickness = 1
		Glow.Transparency = 1

		local Icon = Instance.new("ImageLabel")
		Icon.Size = UDim2.new(0, 24, 0, 24)
		Icon.Position = UDim2.new(0, 12, 0, 18)
		Icon.BackgroundTransparency = 1
		Icon.Image = Image
		Icon.ImageColor3 = Theme.Accent
		Icon.ImageTransparency = 1
		Icon.Parent = Frame

		local TitleLbl = Instance.new("TextLabel")
		TitleLbl.Position = UDim2.new(0, 45, 0, 10)
		TitleLbl.Size = UDim2.new(1, -50, 0, 20)
		TitleLbl.BackgroundTransparency = 1
		TitleLbl.Text = Title
		TitleLbl.TextColor3 = Theme.Text
		TitleLbl.Font = Enum.Font.GothamBold
		TitleLbl.TextSize = 14
		TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
		TitleLbl.TextTransparency = 1
		TitleLbl.Parent = Frame

		local DescLbl = Instance.new("TextLabel")
		DescLbl.Position = UDim2.new(0, 45, 0, 30)
		DescLbl.Size = UDim2.new(1, -50, 0, 20)
		DescLbl.BackgroundTransparency = 1
		DescLbl.Text = Content
		DescLbl.TextColor3 = Theme.TextDim
		DescLbl.Font = Enum.Font.Gotham
		DescLbl.TextSize = 12
		DescLbl.TextXAlignment = Enum.TextXAlignment.Left
		DescLbl.TextTransparency = 1
		DescLbl.Parent = Frame

		-- Animate In
		Utility:Tween(Frame, {BackgroundTransparency = 0.1}, 0.3)
		Utility:Tween(Glow, {Transparency = 0}, 0.3)
		Utility:Tween(Icon, {ImageTransparency = 0}, 0.3)
		Utility:Tween(TitleLbl, {TextTransparency = 0}, 0.3)
		Utility:Tween(DescLbl, {TextTransparency = 0}, 0.3)

		task.delay(Duration, function()
			Utility:Tween(Frame, {BackgroundTransparency = 1}, 0.3)
			Utility:Tween(Glow, {Transparency = 1}, 0.3)
			Utility:Tween(Icon, {ImageTransparency = 1}, 0.3)
			Utility:Tween(TitleLbl, {TextTransparency = 1}, 0.3)
			Utility:Tween(DescLbl, {TextTransparency = 1}, 0.3)
			task.wait(0.3)
			Frame:Destroy()
		end)
	end

	-- ── Tab System ────────────────────────────────────────────────────────────
	local Tabs = {}
	local FirstTab = true

	function Tabs:Tab(Config)
		local TabName = Config.Name or "Tab"
		local TabIcon = Config.Icon or ""

		local TabButton = Instance.new("TextButton")
		TabButton.Name = TabName
		TabButton.Size = UDim2.new(1, 0, 0, 32)
		TabButton.BackgroundColor3 = Theme.Background
		TabButton.BackgroundTransparency = 1
		TabButton.Text = ""
		TabButton.AutoButtonColor = false
		TabButton.Parent = TabContainer

		local TabCorner = Instance.new("UICorner", TabButton)
		TabCorner.CornerRadius = UDim.new(0, 6)

		local Title = Instance.new("TextLabel")
		Title.Size = UDim2.new(1, -10, 1, 0)
		Title.Position = UDim2.new(0, 10, 0, 0)
		Title.BackgroundTransparency = 1
		Title.Text = TabName
		Title.TextColor3 = Theme.TextDim
		Title.Font = Enum.Font.GothamMedium
		Title.TextSize = 13
		Title.TextXAlignment = Enum.TextXAlignment.Left
		Title.Parent = TabButton

		-- Page
		local Page = Instance.new("ScrollingFrame")
		Page.Name = TabName .. "_Page"
		Page.Size = UDim2.new(1, 0, 1, 0)
		Page.BackgroundTransparency = 1
		Page.ScrollBarThickness = 2
		Page.ScrollBarImageColor3 = Theme.Accent
		Page.BorderSizePixel = 0
		Page.Visible = false
		Page.Parent = PagesContainer

		local PageList = Instance.new("UIListLayout", Page)
		PageList.Padding = UDim.new(0, 5)
		PageList.SortOrder = Enum.SortOrder.LayoutOrder

		local PagePadding = Instance.new("UIPadding", Page)
		PagePadding.PaddingTop = UDim.new(0, 5)
		PagePadding.PaddingBottom = UDim.new(0, 5)
		PagePadding.PaddingLeft = UDim.new(0, 10)
		PagePadding.PaddingRight = UDim.new(0, 10)

		-- Functions
		local function Activate()
			-- Reset all tabs
			for _, t in pairs(TabContainer:GetChildren()) do
				if t:IsA("TextButton") then
					Utility:Tween(t, {BackgroundTransparency = 1}, 0.2)
					Utility:Tween(t:FindFirstChild("TextLabel"), {TextColor3 = Theme.TextDim, Position = UDim2.new(0, 10, 0, 0)}, 0.2)
				end
			end
			for _, p in pairs(PagesContainer:GetChildren()) do
				p.Visible = false
			end

			-- Active State
			Utility:Tween(TabButton, {BackgroundTransparency = 0}, 0.2)
			Utility:Tween(Title, {TextColor3 = Theme.Accent, Position = UDim2.new(0, 15, 0, 0)}, 0.2)
			Page.Visible = true
		end

		TabButton.MouseButton1Click:Connect(Activate)

		if FirstTab then
			Activate()
			FirstTab = false
		end

		-- ── Elements ──────────────────────────────────────────────────────────
		local Elements = {}

		function Elements:Section(Text)
			local SectionFrame = Instance.new("Frame")
			SectionFrame.Size = UDim2.new(1, 0, 0, 25)
			SectionFrame.BackgroundTransparency = 1
			SectionFrame.Parent = Page

			local Label = Instance.new("TextLabel")
			Label.Size = UDim2.new(1, 0, 1, 0)
			Label.Position = UDim2.new(0, 2, 0, 0)
			Label.BackgroundTransparency = 1
			Label.Text = Text
			Label.TextColor3 = Theme.Accent
			Label.Font = Enum.Font.GothamBold
			Label.TextSize = 12
			Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.Parent = SectionFrame
		end

		function Elements:Button(Config)
			local Name = Config.Name or "Button"
			local Callback = Config.Callback or function() end
			local Tip = Config.Tooltip

			local ButtonFrame = Instance.new("Frame")
			ButtonFrame.Size = UDim2.new(1, 0, 0, 36)
			ButtonFrame.BackgroundColor3 = Theme.Element
			ButtonFrame.Parent = Page
			Instance.new("UICorner", ButtonFrame).CornerRadius = UDim.new(0, 6)

			local ButtonBtn = Instance.new("TextButton")
			ButtonBtn.Size = UDim2.new(1, 0, 1, 0)
			ButtonBtn.BackgroundTransparency = 1
			ButtonBtn.Text = Name
			ButtonBtn.TextColor3 = Theme.Text
			ButtonBtn.Font = Enum.Font.Gotham
			ButtonBtn.TextSize = 13
			ButtonBtn.Parent = ButtonFrame
			
			if Tip then AddTooltip(ButtonBtn, Tip) end

			Utility:ConnectHover(ButtonBtn,
				function() Utility:Tween(ButtonFrame, {BackgroundColor3 = Theme.ElementHover}, 0.2) end,
				function() Utility:Tween(ButtonFrame, {BackgroundColor3 = Theme.Element}, 0.2) end
			)

			ButtonBtn.MouseButton1Click:Connect(function()
				Utility:Tween(ButtonFrame, {BackgroundColor3 = Theme.AccentDark}, 0.1)
				task.wait(0.1)
				Utility:Tween(ButtonFrame, {BackgroundColor3 = Theme.ElementHover}, 0.2)
				Callback()
			end)
		end

		function Elements:Toggle(Config)
			local Name = Config.Name or "Toggle"
			local Default = Config.Default or false
			local Callback = Config.Callback or function() end
			local Tip = Config.Tooltip

			local Toggled = Default

			local ToggleFrame = Instance.new("Frame")
			ToggleFrame.Size = UDim2.new(1, 0, 0, 36)
			ToggleFrame.BackgroundColor3 = Theme.Element
			ToggleFrame.Parent = Page
			Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 6)

			local Label = Instance.new("TextLabel")
			Label.Size = UDim2.new(1, -60, 1, 0)
			Label.Position = UDim2.new(0, 12, 0, 0)
			Label.BackgroundTransparency = 1
			Label.Text = Name
			Label.TextColor3 = Theme.Text
			Label.Font = Enum.Font.Gotham
			Label.TextSize = 13
			Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.Parent = ToggleFrame

			local CheckFrame = Instance.new("Frame")
			CheckFrame.Size = UDim2.new(0, 42, 0, 22)
			CheckFrame.Position = UDim2.new(1, -50, 0.5, -11)
			CheckFrame.BackgroundColor3 = Toggled and Theme.Accent or Color3.fromRGB(50, 50, 55)
			CheckFrame.Parent = ToggleFrame
			Instance.new("UICorner", CheckFrame).CornerRadius = UDim.new(1, 0)

			local Circle = Instance.new("Frame")
			Circle.Size = UDim2.new(0, 18, 0, 18)
			Circle.Position = Toggled and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
			Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			Circle.Parent = CheckFrame
			Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)
			
			local ButtonBtn = Instance.new("TextButton")
			ButtonBtn.Size = UDim2.new(1, 0, 1, 0)
			ButtonBtn.BackgroundTransparency = 1
			ButtonBtn.Text = ""
			ButtonBtn.Parent = ToggleFrame
			
			if Tip then AddTooltip(ButtonBtn, Tip) end

			local function Update()
				Toggled = not Toggled
				Utility:Tween(CheckFrame, {BackgroundColor3 = Toggled and Theme.Accent or Color3.fromRGB(50, 50, 55)}, 0.2)
				Utility:Tween(Circle, {Position = Toggled and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)}, 0.2, Enum.EasingStyle.Back)
				Callback(Toggled)
			end

			ButtonBtn.MouseButton1Click:Connect(Update)
		end

		function Elements:Slider(Config)
			local Name = Config.Name or "Slider"
			local Min = Config.Min or 0
			local Max = Config.Max or 100
			local Default = Config.Default or Min
			local Callback = Config.Callback or function() end

			local SliderFrame = Instance.new("Frame")
			SliderFrame.Size = UDim2.new(1, 0, 0, 50)
			SliderFrame.BackgroundColor3 = Theme.Element
			SliderFrame.Parent = Page
			Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0, 6)

			local Label = Instance.new("TextLabel")
			Label.Size = UDim2.new(1, 0, 0, 25)
			Label.Position = UDim2.new(0, 12, 0, 0)
			Label.BackgroundTransparency = 1
			Label.Text = Name
			Label.TextColor3 = Theme.Text
			Label.Font = Enum.Font.Gotham
			Label.TextSize = 13
			Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.Parent = SliderFrame

			local ValueLabel = Instance.new("TextLabel")
			ValueLabel.Size = UDim2.new(0, 40, 0, 25)
			ValueLabel.Position = UDim2.new(1, -50, 0, 0)
			ValueLabel.BackgroundTransparency = 1
			ValueLabel.Text = tostring(Default)
			ValueLabel.TextColor3 = Theme.TextDim
			ValueLabel.Font = Enum.Font.Gotham
			ValueLabel.TextSize = 13
			ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
			ValueLabel.Parent = SliderFrame

			local SlideBg = Instance.new("Frame")
			SlideBg.Size = UDim2.new(1, -24, 0, 6)
			SlideBg.Position = UDim2.new(0, 12, 0, 32)
			SlideBg.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
			SlideBg.Parent = SliderFrame
			Instance.new("UICorner", SlideBg).CornerRadius = UDim.new(1, 0)

			local Fill = Instance.new("Frame")
			Fill.Size = UDim2.new((Default - Min) / (Max - Min), 0, 1, 0)
			Fill.BackgroundColor3 = Theme.Accent
			Fill.Parent = SlideBg
			Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
			
			local Trigger = Instance.new("TextButton")
			Trigger.Size = UDim2.new(1, 0, 1, 0)
			Trigger.BackgroundTransparency = 1
			Trigger.Text = ""
			Trigger.Parent = SliderFrame

			local Dragging = false
			
			local function Set(value)
				value = math.clamp(value, Min, Max)
				local percent = (value - Min) / (Max - Min)
				ValueLabel.Text = math.round(value)
				Utility:Tween(Fill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.1)
				Callback(value)
			end

			Trigger.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					Dragging = true
				end
			end)

			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					Dragging = false
				end
			end)

			UserInputService.InputChanged:Connect(function(input)
				if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
					local SizeX = SlideBg.AbsoluteSize.X
					local PosX = SlideBg.AbsolutePosition.X
					local MouseX = UserInputService:GetMouseLocation().X
					local Percent = math.clamp((MouseX - PosX) / SizeX, 0, 1)
					local Value = Min + (Max - Min) * Percent
					Set(Value)
				end
			end)
		end

		function Elements:Dropdown(Config)
			local Name = Config.Name or "Dropdown"
			local Options = Config.Options or {}
			local Callback = Config.Callback or function() end
			local Default = Config.Default or Options[1]

			local IsOpen = false
			local CurrentValue = Default

			local DropFrame = Instance.new("Frame")
			DropFrame.Size = UDim2.new(1, 0, 0, 36)
			DropFrame.BackgroundColor3 = Theme.Element
			DropFrame.Parent = Page
			DropFrame.ZIndex = 2
			Instance.new("UICorner", DropFrame).CornerRadius = UDim.new(0, 6)

			local Label = Instance.new("TextLabel")
			Label.Size = UDim2.new(1, -30, 1, 0)
			Label.Position = UDim2.new(0, 12, 0, 0)
			Label.BackgroundTransparency = 1
			Label.Text = Name .. ": " .. tostring(CurrentValue)
			Label.TextColor3 = Theme.Text
			Label.Font = Enum.Font.Gotham
			Label.TextSize = 13
			Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.Parent = DropFrame

			local Arrow = Instance.new("ImageLabel")
			Arrow.Size = UDim2.new(0, 20, 0, 20)
			Arrow.Position = UDim2.new(1, -25, 0.5, -10)
			Arrow.BackgroundTransparency = 1
			Arrow.Image = "rbxassetid://6031091004"
			Arrow.ImageColor3 = Theme.TextDim
			Arrow.Parent = DropFrame

			local ButtonBtn = Instance.new("TextButton")
			ButtonBtn.Size = UDim2.new(1, 0, 1, 0)
			ButtonBtn.BackgroundTransparency = 1
			ButtonBtn.Text = ""
			ButtonBtn.Parent = DropFrame
			
			-- Container logic to allow overlay
			local ListContainer = Instance.new("ScrollingFrame")
			ListContainer.Name = "DropdownList"
			ListContainer.Size = UDim2.new(1, 0, 0, 0) -- starts closed
			ListContainer.Position = UDim2.new(0, 0, 1, 5)
			ListContainer.BackgroundColor3 = Theme.Sidebar
			ListContainer.BorderSizePixel = 0
			ListContainer.Visible = false
			ListContainer.ScrollBarThickness = 2
			ListContainer.ScrollBarImageColor3 = Theme.Accent
			ListContainer.ZIndex = 5 -- High ZIndex to sit on top
			ListContainer.Parent = DropFrame
			Instance.new("UICorner", ListContainer).CornerRadius = UDim.new(0, 6)
			
			local ListLayout = Instance.new("UIListLayout", ListContainer)
			ListLayout.Padding = UDim.new(0, 2)
			
			local function Toggle()
				IsOpen = not IsOpen
				
				if IsOpen then
					-- Calculate height
					local count = #Options
					local height = math.min(count * 30, 150)
					
					-- Ensure we are on top
					DropFrame.ZIndex = 10 
					
					ListContainer.Visible = true
					Utility:Tween(Arrow, {Rotation = 180}, 0.2)
					Utility:Tween(ListContainer, {Size = UDim2.new(1, 0, 0, height)}, 0.2)
				else
					Utility:Tween(Arrow, {Rotation = 0}, 0.2)
					Utility:Tween(ListContainer, {Size = UDim2.new(1, 0, 0, 0)}, 0.2)
					task.wait(0.2)
					ListContainer.Visible = false
					DropFrame.ZIndex = 2 -- Reset
				end
			end

			-- Refresh Options
			local function Refresh()
				for _, v in pairs(ListContainer:GetChildren()) do
					if v:IsA("TextButton") then v:Destroy() end
				end
				
				for _, opt in pairs(Options) do
					local Item = Instance.new("TextButton")
					Item.Size = UDim2.new(1, 0, 0, 30)
					Item.BackgroundColor3 = Theme.Element
					Item.BackgroundTransparency = 1
					Item.Text = opt
					Item.TextColor3 = Theme.TextDim
					Item.Font = Enum.Font.Gotham
					Item.TextSize = 13
					Item.ZIndex = 6
					Item.Parent = ListContainer
					
					Item.MouseEnter:Connect(function() 
						Utility:Tween(Item, {TextColor3 = Theme.Text, BackgroundTransparency = 0.8}, 0.1) 
					end)
					Item.MouseLeave:Connect(function() 
						Utility:Tween(Item, {TextColor3 = Theme.TextDim, BackgroundTransparency = 1}, 0.1) 
					end)
					
					Item.MouseButton1Click:Connect(function()
						CurrentValue = opt
						Label.Text = Name .. ": " .. tostring(CurrentValue)
						Callback(opt)
						Toggle()
					end)
				end
				
				ListContainer.CanvasSize = UDim2.new(0, 0, 0, #Options * 32)
			end
			
			Refresh()
			ButtonBtn.MouseButton1Click:Connect(Toggle)
		end

		function Elements:ColorPicker(Config)
			local Name = Config.Name or "Color"
			local Default = Config.Default or Color3.fromRGB(255, 255, 255)
			local Callback = Config.Callback or function() end

			local PickerFrame = Instance.new("Frame")
			PickerFrame.Size = UDim2.new(1, 0, 0, 36)
			PickerFrame.BackgroundColor3 = Theme.Element
			PickerFrame.Parent = Page
			Instance.new("UICorner", PickerFrame).CornerRadius = UDim.new(0, 6)

			local Label = Instance.new("TextLabel")
			Label.Size = UDim2.new(1, -50, 1, 0)
			Label.Position = UDim2.new(0, 12, 0, 0)
			Label.BackgroundTransparency = 1
			Label.Text = Name
			Label.TextColor3 = Theme.Text
			Label.Font = Enum.Font.Gotham
			Label.TextSize = 13
			Label.TextXAlignment = Enum.TextXAlignment.Left
			Label.Parent = PickerFrame

			local ColorPreview = Instance.new("TextButton")
			ColorPreview.Size = UDim2.new(0, 30, 0, 20)
			ColorPreview.Position = UDim2.new(1, -40, 0.5, -10)
			ColorPreview.BackgroundColor3 = Default
			ColorPreview.Text = ""
			ColorPreview.Parent = PickerFrame
			Instance.new("UICorner", ColorPreview).CornerRadius = UDim.new(0, 4)

			-- Basic HSV Picker Logic (Simplified for stability in this context)
			-- Ideally opens a modal, but here we toggle size
			local Open = false
			local Palette = Instance.new("ImageButton")
			Palette.Size = UDim2.new(1, -20, 0, 100)
			Palette.Position = UDim2.new(0, 10, 0, 40)
			Palette.Image = "rbxassetid://4155801252" -- Rainbow gradient
			Palette.Visible = false
			Palette.Parent = PickerFrame
			
			ColorPreview.MouseButton1Click:Connect(function()
				Open = not Open
				if Open then
					Utility:Tween(PickerFrame, {Size = UDim2.new(1, 0, 0, 150)}, 0.2)
					Palette.Visible = true
				else
					Utility:Tween(PickerFrame, {Size = UDim2.new(1, 0, 0, 36)}, 0.2)
					Palette.Visible = false
				end
			end)
			
			local Dragging = false
			Palette.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = true end end)
			UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end end)
			
			UserInputService.InputChanged:Connect(function(input)
				if Dragging and Open and input.UserInputType == Enum.UserInputType.MouseMovement then
					local m = UserInputService:GetMouseLocation()
					local r = Palette.AbsolutePosition
					local s = Palette.AbsoluteSize
					local x = math.clamp((m.X - r.X) / s.X, 0, 1)
					local y = math.clamp((m.Y - r.Y) / s.Y, 0, 1)
					
					local color = Color3.fromHSV(x, 1-y, 1)
					ColorPreview.BackgroundColor3 = color
					Callback(color)
				end
			end)
		end

		return Elements
	end

	return Tabs
end

return Library
