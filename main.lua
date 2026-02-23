--[[
	MeruLib - Roblox UI Library
	Executor-friendly, multi-game ready
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

local Player = Players.LocalPlayer

local lib = {}

-- Theme
local DEFAULT_THEME = {
	Bg = Color3.fromRGB(15, 15, 18),
	Surface = Color3.fromRGB(22, 22, 28),
	Surface2 = Color3.fromRGB(32, 32, 40),
	Stroke = Color3.fromRGB(50, 50, 62),
	Accent = Color3.fromRGB(88, 166, 255),
	Text = Color3.fromRGB(250, 250, 252),
	TextDim = Color3.fromRGB(160, 165, 180),
	Corner = 12,
	Trans = 0.08,
	Font = Enum.Font.Gotham,
}

local function merge(t, patch)
	local out = {}
	for k, v in pairs(t) do out[k] = v end
	if patch then for k, v in pairs(patch) do out[k] = v end end
	return out
end

local function tween(inst, t, props)
	TweenService:Create(inst, TweenInfo.new(t, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props):Play()
end

local function corner(inst, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 8)
	c.Parent = inst
	return c
end

local function stroke(inst, col, thick, trans)
	local s = Instance.new("UIStroke")
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Color = col
	s.Thickness = thick or 1
	s.Transparency = trans or 0.5
	s.Parent = inst
	return s
end

local function pad(inst, p)
	local u = Instance.new("UIPadding")
	u.PaddingLeft = UDim.new(0, p)
	u.PaddingRight = UDim.new(0, p)
	u.PaddingTop = UDim.new(0, p)
	u.PaddingBottom = UDim.new(0, p)
	u.Parent = inst
	return u
end

local function parentGui(gui)
	if syn and syn.protect_gui then
		syn.protect_gui(gui)
	end
	local target = gethui and gethui() or game:GetService("CoreGui")
	gui.Parent = target
end

function lib.init(opts)
	opts = opts or {}
	local theme = merge(DEFAULT_THEME, opts.Theme)
	local name = opts.Name or "MeruUI"
	local size = opts.Size or Vector2.new(720, 500)
	local title = opts.Title or "Meru"

	-- Remove old
	local cg = gethui and gethui() or game:GetService("CoreGui")
	local old = cg:FindFirstChild(name)
	if old and opts.DeletePrevious then
		local m = old:FindFirstChild("Main")
		if m then tween(m, 0.3, {Position = m.Position + UDim2.new(0, 0, 1.5, 0)}) end
		Debris:AddItem(old, 0.4)
	end

	local gui = Instance.new("ScreenGui")
	gui.Name = name
	gui.ResetOnSpawn = false
	parentGui(gui)

	-- Main window
	local main = Instance.new("Frame")
	main.Name = "Main"
	main.Parent = gui
	main.AnchorPoint = Vector2.new(0.5, 0.5)
	main.Position = UDim2.new(0.5, 0, 0.5, 0)
	main.Size = UDim2.new(0, size.X, 0, size.Y)
	main.BackgroundColor3 = theme.Bg
	main.BackgroundTransparency = theme.Trans
	corner(main, theme.Corner)
	stroke(main, theme.Stroke, 1, 0.4)

	pad(main, 12)

	-- Top bar (drag + title + mac buttons)
	local top = Instance.new("Frame")
	top.Name = "Top"
	top.Parent = main
	top.BackgroundTransparency = 1
	top.Size = UDim2.new(1, 0, 0, 42)

	local mac = Instance.new("Frame")
	mac.Parent = top
	mac.BackgroundTransparency = 1
	mac.Size = UDim2.new(0, 80, 0, 42)
	local macList = Instance.new("UIListLayout")
	macList.FillDirection = Enum.FillDirection.Horizontal
	macList.SortOrder = Enum.SortOrder.LayoutOrder
	macList.Padding = UDim.new(0, 6)
	macList.VerticalAlignment = Enum.VerticalAlignment.Center
	macList.Parent = mac

	local function dot(c)
		local b = Instance.new("TextButton")
		b.Text = ""
		b.AutoButtonColor = false
		b.BackgroundColor3 = c
		b.Size = UDim2.new(0, 12, 0, 12)
		b.Parent = mac
		corner(b, 99)
		stroke(b, Color3.new(0, 0, 0), 1, 0.7)
		return b
	end

	local closeBtn = dot(Color3.fromRGB(255, 95, 86))
	local minBtn = dot(Color3.fromRGB(255, 189, 47))
	local maxBtn = dot(Color3.fromRGB(39, 201, 63))

	local titleLbl = Instance.new("TextLabel")
	titleLbl.Parent = top
	titleLbl.BackgroundTransparency = 1
	titleLbl.Position = UDim2.new(0, 95, 0, 0)
	titleLbl.Size = UDim2.new(1, -95, 1, 0)
	titleLbl.Font = Enum.Font.GothamMedium
	titleLbl.TextSize = 18
	titleLbl.TextColor3 = theme.Text
	titleLbl.TextXAlignment = Enum.TextXAlignment.Left
	titleLbl.Text = title

	-- Body: sidebar + content
	local body = Instance.new("Frame")
	body.Parent = main
	body.BackgroundTransparency = 1
	body.Position = UDim2.new(0, 0, 0, 48)
	body.Size = UDim2.new(1, 0, 1, -48)

	-- Sidebar
	local sidebar = Instance.new("Frame")
	sidebar.Parent = body
	sidebar.BackgroundTransparency = 1
	sidebar.Size = UDim2.new(0, 220, 1, 0)

	-- Search
	local search = Instance.new("Frame")
	search.Parent = sidebar
	search.Size = UDim2.new(1, 0, 0, 34)
	search.BackgroundColor3 = theme.Surface
	search.BackgroundTransparency = theme.Trans
	corner(search, 8)
	stroke(search, theme.Stroke, 1, 0.6)
	pad(search, 8)

	local searchBox = Instance.new("TextBox")
	searchBox.Parent = search
	searchBox.BackgroundTransparency = 1
	searchBox.Size = UDim2.new(1, 0, 1, 0)
	searchBox.Font = theme.Font
	searchBox.TextSize = 14
	searchBox.PlaceholderText = "Search..."
	searchBox.PlaceholderColor3 = theme.TextDim
	searchBox.TextColor3 = theme.Text
	searchBox.TextXAlignment = Enum.TextXAlignment.Left
	searchBox.ClearTextOnFocus = false

	-- Tab list
	local tabList = Instance.new("ScrollingFrame")
	tabList.Parent = sidebar
	tabList.Position = UDim2.new(0, 0, 0, 42)
	tabList.Size = UDim2.new(1, 0, 1, -110)
	tabList.BackgroundTransparency = 1
	tabList.BorderSizePixel = 0
	tabList.ScrollBarThickness = 2
	tabList.ScrollBarImageColor3 = theme.Stroke
	tabList.AutomaticCanvasSize = Enum.AutomaticSize.Y
	tabList.CanvasSize = UDim2.new(0, 0, 0, 0)

	local tabLayout = Instance.new("UIListLayout")
	tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
	tabLayout.Padding = UDim.new(0, 4)
	tabLayout.Parent = tabList

	-- Profile
	local profile = Instance.new("Frame")
	profile.Parent = sidebar
	profile.Position = UDim2.new(0, 0, 1, -62)
	profile.Size = UDim2.new(1, 0, 0, 62)
	profile.BackgroundColor3 = theme.Surface
	profile.BackgroundTransparency = theme.Trans
	corner(profile, 10)
	stroke(profile, theme.Stroke, 1, 0.5)
	pad(profile, 10)

	local ava = Instance.new("ImageLabel")
	ava.Parent = profile
	ava.BackgroundTransparency = 1
	ava.Size = UDim2.new(0, 38, 0, 38)
	ava.Position = UDim2.new(0, 0, 0.5, -19)
	corner(ava, 99)
	if Player then
		ava.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. Player.UserId .. "&width=150&height=150&format=png"
	end

	local pName = Instance.new("TextLabel")
	pName.Parent = profile
	pName.BackgroundTransparency = 1
	pName.Position = UDim2.new(0, 48, 0, 0)
	pName.Size = UDim2.new(1, -80, 1, 0)
	pName.Font = Enum.Font.GothamMedium
	pName.TextSize = 14
	pName.TextColor3 = theme.Text
	pName.TextXAlignment = Enum.TextXAlignment.Left
	pName.TextTruncate = Enum.TextTruncate.AtEnd
	pName.Text = Player and Player.Name or "Player"

	local gear = Instance.new("ImageButton")
	gear.Parent = profile
	gear.BackgroundTransparency = 1
	gear.Size = UDim2.new(0, 22, 0, 22)
	gear.Position = UDim2.new(1, -22, 0.5, -11)
	gear.Image = "rbxassetid://6031280882"
	gear.ImageColor3 = theme.TextDim

	-- Content area
	local content = Instance.new("Frame")
	content.Parent = body
	content.Position = UDim2.new(0, 232, 0, 0)
	content.Size = UDim2.new(1, -232, 1, 0)
	content.BackgroundColor3 = theme.Surface
	content.BackgroundTransparency = theme.Trans
	corner(content, theme.Corner)
	stroke(content, theme.Stroke, 1, 0.4)
	pad(content, 14)

	local contentTitle = Instance.new("TextLabel")
	contentTitle.Parent = content
	contentTitle.BackgroundTransparency = 1
	contentTitle.Size = UDim2.new(1, 0, 0, 24)
	contentTitle.Font = Enum.Font.GothamMedium
	contentTitle.TextSize = 16
	contentTitle.TextColor3 = theme.Text
	contentTitle.TextXAlignment = Enum.TextXAlignment.Left
	contentTitle.Text = ""

	-- State
	local tabs = {}
	local selectedTab = nil
	local visible = opts.Visible ~= false
	local busy = false

	-- Drag
	local dragStart, startPos
	top.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragStart = input.Position
			startPos = main.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragStart = nil end
			end)
		end
	end)
	top.InputChanged:Connect(function(input)
		if dragStart and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local d = input.Position - dragStart
			main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
	end)

	-- Mac buttons
	closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

	local function setVisible(v)
		if busy then return end
		busy = true
		visible = v
		if v then
			main.Visible = true
			tween(main, 0.3, {Position = UDim2.new(0.5, 0, 0.5, 0)})
		else
			tween(main, 0.3, {Position = main.Position + UDim2.new(0, 0, 1.2, 0)})
			task.delay(0.32, function() main.Visible = false end)
		end
		task.delay(0.32, function() busy = false end)
	end

	minBtn.MouseButton1Click:Connect(function() setVisible(not visible) end)
	maxBtn.MouseButton1Click:Connect(function() end)

	if opts.ToggleKey then
		UserInputService.InputBegan:Connect(function(input, gp)
			if not gp and input.KeyCode == opts.ToggleKey then
				setVisible(not visible)
			end
		end)
	end

	-- Search filter
	searchBox:GetPropertyChangedSignal("Text"):Connect(function()
		local q = string.upper(searchBox.Text)
		for _, t in ipairs(tabs) do
			t.btn.Visible = q == "" or string.find(string.upper(t.name), q) ~= nil
		end
	end)

	-- Notify
	local function notify(t1, t2, icon)
		for _, c in ipairs(gui:GetChildren()) do
			if c:IsA("Frame") and c.Name == "Notif" then
				c.Position = c.Position + UDim2.new(0, 0, 0, 72)
			end
		end
		local n = Instance.new("Frame")
		n.Name = "Notif"
		n.Parent = gui
		n.AnchorPoint = Vector2.new(1, 0)
		n.Position = UDim2.new(1, -16, 0, 16)
		n.Size = UDim2.new(0, 320, 0, 68)
		n.BackgroundColor3 = theme.Surface
		n.BackgroundTransparency = theme.Trans
		corner(n, 10)
		stroke(n, theme.Stroke, 1, 0.4)
		pad(n, 12)

		local ic = Instance.new("ImageLabel")
		ic.Parent = n
		ic.BackgroundTransparency = 1
		ic.Size = UDim2.new(0, 28, 0, 28)
		ic.Image = icon or "rbxassetid://6031280882"
		ic.ImageColor3 = theme.Text

		local wrap = Instance.new("Frame")
		wrap.Parent = n
		wrap.BackgroundTransparency = 1
		wrap.Position = UDim2.new(0, 40, 0, 0)
		wrap.Size = UDim2.new(1, -40, 1, 0)

		local lbl1 = Instance.new("TextLabel")
		lbl1.Parent = wrap
		lbl1.BackgroundTransparency = 1
		lbl1.Size = UDim2.new(1, 0, 0, 20)
		lbl1.Font = Enum.Font.GothamMedium
		lbl1.TextSize = 15
		lbl1.TextColor3 = theme.Text
		lbl1.TextXAlignment = Enum.TextXAlignment.Left
		lbl1.Text = t1

		local lbl2 = Instance.new("TextLabel")
		lbl2.Parent = wrap
		lbl2.BackgroundTransparency = 1
		lbl2.Position = UDim2.new(0, 0, 0, 20)
		lbl2.Size = UDim2.new(1, 0, 1, -20)
		lbl2.Font = theme.Font
		lbl2.TextSize = 13
		lbl2.TextColor3 = theme.TextDim
		lbl2.TextXAlignment = Enum.TextXAlignment.Left
		lbl2.TextYAlignment = Enum.TextYAlignment.Top
		lbl2.TextWrapped = true
		lbl2.Text = t2

		Debris:AddItem(n, 5)
	end

	-- Tab select
	local function selectTab(tab)
		if selectedTab == tab then return end
		selectedTab = tab
		for _, t in ipairs(tabs) do
			local sel = t == tab
			t.panel.Visible = sel
			t.btn.BackgroundTransparency = sel and 0.2 or 1
			t.btn.TextColor3 = sel and theme.Text or theme.TextDim
		end
		contentTitle.Text = tab.name
	end

	-- API
	local api = {}

	function api:Notify(t1, t2, icon) notify(t1, t2 or "", icon) end
	function api:Destroy() gui:Destroy() end

	function api:Tab(name)
		local btn = Instance.new("TextButton")
		btn.Parent = tabList
		btn.Size = UDim2.new(1, -4, 0, 34)
		btn.BackgroundTransparency = 1
		btn.Text = "  " .. name
		btn.Font = Enum.Font.GothamMedium
		btn.TextSize = 15
		btn.TextColor3 = theme.TextDim
		btn.TextXAlignment = Enum.TextXAlignment.Left
		btn.AutoButtonColor = false
		corner(btn, 8)

		local panel = Instance.new("ScrollingFrame")
		panel.Parent = content
		panel.Position = UDim2.new(0, 0, 0, 30)
		panel.Size = UDim2.new(1, 0, 1, -30)
		panel.BackgroundTransparency = 1
		panel.BorderSizePixel = 0
		panel.ScrollBarThickness = 2
		panel.ScrollBarImageColor3 = theme.Stroke
		panel.AutomaticCanvasSize = Enum.AutomaticSize.Y
		panel.CanvasSize = UDim2.new(0, 0, 0, 0)
		panel.Visible = false

		local pl = Instance.new("UIListLayout")
		pl.SortOrder = Enum.SortOrder.LayoutOrder
		pl.Padding = UDim.new(0, 8)
		pl.Parent = panel

		local tab = { name = name, btn = btn, panel = panel }
		table.insert(tabs, tab)

		if not selectedTab then selectTab(tab) end
		btn.MouseButton1Click:Connect(function() selectTab(tab) end)

		local sec = {}

		function sec:Select() selectTab(tab) end

		function sec:Divider(text)
			local l = Instance.new("TextLabel")
			l.Parent = panel
			l.BackgroundTransparency = 1
			l.Size = UDim2.new(1, 0, 0, 24)
			l.Font = Enum.Font.GothamMedium
			l.TextSize = 14
			l.TextColor3 = theme.Text
			l.TextXAlignment = Enum.TextXAlignment.Left
			l.Text = text
			return l
		end

		function sec:Label(text)
			local l = Instance.new("TextLabel")
			l.Parent = panel
			l.BackgroundTransparency = 1
			l.Size = UDim2.new(1, 0, 0, 20)
			l.Font = theme.Font
			l.TextSize = 14
			l.TextColor3 = theme.TextDim
			l.TextXAlignment = Enum.TextXAlignment.Left
			l.Text = text
			return l
		end

		function sec:Paragraph(title, body)
			local f = Instance.new("Frame")
			f.Parent = panel
			f.Size = UDim2.new(1, 0, 0, 70)
			f.BackgroundColor3 = theme.Surface2
			f.BackgroundTransparency = 0.15
			corner(f, 8)
			stroke(f, theme.Stroke, 1, 0.5)
			pad(f, 10)

			local t1 = Instance.new("TextLabel")
			t1.Parent = f
			t1.BackgroundTransparency = 1
			t1.Size = UDim2.new(1, 0, 0, 18)
			t1.Font = Enum.Font.GothamMedium
			t1.TextSize = 14
			t1.TextColor3 = theme.Text
			t1.TextXAlignment = Enum.TextXAlignment.Left
			t1.Text = title

			local t2 = Instance.new("TextLabel")
			t2.Parent = f
			t2.BackgroundTransparency = 1
			t2.Position = UDim2.new(0, 0, 0, 20)
			t2.Size = UDim2.new(1, 0, 1, -20)
			t2.Font = theme.Font
			t2.TextSize = 13
			t2.TextColor3 = theme.TextDim
			t2.TextXAlignment = Enum.TextXAlignment.Left
			t2.TextYAlignment = Enum.TextYAlignment.Top
			t2.TextWrapped = true
			t2.Text = body
			return f
		end

		function sec:Button(text, cb)
			local b = Instance.new("TextButton")
			b.Parent = panel
			b.Size = UDim2.new(1, 0, 0, 38)
			b.BackgroundColor3 = theme.Surface2
			b.BackgroundTransparency = 0.15
			b.Text = text
			b.Font = Enum.Font.GothamMedium
			b.TextSize = 15
			b.TextColor3 = theme.Accent
			b.AutoButtonColor = false
			corner(b, 8)
			stroke(b, theme.Accent, 1, 0.4)
			if cb then
				b.MouseButton1Click:Connect(function()
					b.TextSize = 13
					task.delay(0.05, function() if b.Parent then b.TextSize = 15 end end)
					cb()
				end)
			end
			return b
		end

		function sec:Toggle(text, default, cb)
			local on = default == true
			local row = Instance.new("Frame")
			row.Parent = panel
			row.Size = UDim2.new(1, 0, 0, 36)
			row.BackgroundTransparency = 1

			local lbl = Instance.new("TextLabel")
			lbl.Parent = row
			lbl.Size = UDim2.new(0.6, 0, 1, 0)
			lbl.BackgroundTransparency = 1
			lbl.Text = text
			lbl.Font = theme.Font
			lbl.TextSize = 14
			lbl.TextColor3 = theme.TextDim
			lbl.TextXAlignment = Enum.TextXAlignment.Left

			local track = Instance.new("TextButton")
			track.Parent = row
			track.Size = UDim2.new(0, 52, 0, 26)
			track.Position = UDim2.new(1, -52, 0.5, -13)
			track.Text = ""
			track.AutoButtonColor = false
			track.BackgroundColor3 = on and theme.Accent or Color3.fromRGB(55, 58, 68)
			track.BackgroundTransparency = 0.2
			corner(track, 99)

			local knob = Instance.new("Frame")
			knob.Parent = track
			knob.Size = UDim2.new(0, 22, 0, 22)
			knob.Position = on and UDim2.new(1, -24, 0.5, -11) or UDim2.new(0, 2, 0.5, -11)
			knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			corner(knob, 99)

			local function update()
				track.BackgroundColor3 = on and theme.Accent or Color3.fromRGB(55, 58, 68)
				tween(knob, 0.1, {Position = on and UDim2.new(1, -24, 0.5, -11) or UDim2.new(0, 2, 0.5, -11)})
			end

			local function flip()
				on = not on
				update()
				if cb then cb(on) end
			end

			track.MouseButton1Click:Connect(flip)
			update()
			return row
		end

		function sec:Textbox(text, placeholder, cb)
			local row = Instance.new("Frame")
			row.Parent = panel
			row.Size = UDim2.new(1, 0, 0, 36)
			row.BackgroundTransparency = 1

			local lbl = Instance.new("TextLabel")
			lbl.Parent = row
			lbl.Size = UDim2.new(0.5, 0, 1, 0)
			lbl.BackgroundTransparency = 1
			lbl.Text = text
			lbl.Font = theme.Font
			lbl.TextSize = 14
			lbl.TextColor3 = theme.TextDim
			lbl.TextXAlignment = Enum.TextXAlignment.Left

			local box = Instance.new("Frame")
			box.Parent = row
			box.Size = UDim2.new(0, 200, 0, 28)
			box.Position = UDim2.new(1, -200, 0.5, -14)
			box.BackgroundColor3 = theme.Surface2
			box.BackgroundTransparency = 0.2
			corner(box, 6)
			stroke(box, theme.Stroke, 1, 0.5)

			local tb = Instance.new("TextBox")
			tb.Parent = box
			tb.Size = UDim2.new(1, -12, 1, 0)
			tb.Position = UDim2.new(0, 6, 0, 0)
			tb.BackgroundTransparency = 1
			tb.Font = theme.Font
			tb.TextSize = 14
			tb.PlaceholderText = placeholder or "Type..."
			tb.PlaceholderColor3 = theme.TextDim
			tb.TextColor3 = theme.Text
			tb.TextXAlignment = Enum.TextXAlignment.Left
			tb.ClearTextOnFocus = false

			if cb then tb.FocusLost:Connect(function() cb(tb.Text) end) end
			return tb
		end

		function sec:Slider(text, minV, maxV, default, cb)
			local val = math.clamp(default or minV, minV, maxV)
			local row = Instance.new("Frame")
			row.Parent = panel
			row.Size = UDim2.new(1, 0, 0, 48)
			row.BackgroundTransparency = 1

			local lbl = Instance.new("TextLabel")
			lbl.Parent = row
			lbl.Size = UDim2.new(0.5, 0, 0, 18)
			lbl.BackgroundTransparency = 1
			lbl.Text = text
			lbl.Font = theme.Font
			lbl.TextSize = 14
			lbl.TextColor3 = theme.TextDim
			lbl.TextXAlignment = Enum.TextXAlignment.Left

			local valLbl = Instance.new("TextLabel")
			valLbl.Parent = row
			valLbl.Size = UDim2.new(0, 200, 0, 18)
			valLbl.Position = UDim2.new(1, -200, 0, 0)
			valLbl.BackgroundTransparency = 1
			valLbl.Font = Enum.Font.GothamMedium
			valLbl.TextSize = 13
			valLbl.TextColor3 = theme.TextDim
			valLbl.TextXAlignment = Enum.TextXAlignment.Right
			valLbl.Text = tostring(val)

			local track = Instance.new("Frame")
			track.Parent = row
			track.Size = UDim2.new(0, 200, 0, 6)
			track.Position = UDim2.new(1, -200, 0, 26)
			track.BackgroundColor3 = theme.Surface2
			track.BackgroundTransparency = 0.2
			corner(track, 99)
			stroke(track, theme.Stroke, 1, 0.6)

			local fill = Instance.new("Frame")
			fill.Parent = track
			fill.Size = UDim2.new((val - minV) / (maxV - minV), 0, 1, 0)
			fill.BackgroundColor3 = theme.Accent
			fill.BackgroundTransparency = 0.1
			corner(fill, 99)

			local hit = Instance.new("TextButton")
			hit.Parent = track
			hit.Size = UDim2.new(1, 0, 3, 0)
			hit.Position = UDim2.new(0, 0, -1, 0)
			hit.Text = ""
			hit.BackgroundTransparency = 1

			local dragging
			local function setVal(x)
				local rel = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
				val = minV + (maxV - minV) * rel
				val = math.floor(val * 100 + 0.5) / 100
				fill.Size = UDim2.new(rel, 0, 1, 0)
				valLbl.Text = tostring(val)
				if cb then cb(val) end
			end

			hit.MouseButton1Down:Connect(function() dragging = true setVal(UserInputService:GetMouseLocation().X) end)
			UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
			UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then setVal(UserInputService:GetMouseLocation().X) end end)
			return row
		end

		function sec:Dropdown(text, items, default, cb)
			local sel = default or items[1] or ""
			local row = Instance.new("Frame")
			row.Parent = panel
			row.Size = UDim2.new(1, 0, 0, 36)
			row.BackgroundTransparency = 1
			row.ClipsDescendants = true

			local lbl = Instance.new("TextLabel")
			lbl.Parent = row
			lbl.Size = UDim2.new(0.5, 0, 1, 0)
			lbl.BackgroundTransparency = 1
			lbl.Text = text
			lbl.Font = theme.Font
			lbl.TextSize = 14
			lbl.TextColor3 = theme.TextDim
			lbl.TextXAlignment = Enum.TextXAlignment.Left

			local btn = Instance.new("TextButton")
			btn.Parent = row
			btn.Size = UDim2.new(0, 200, 0, 28)
			btn.Position = UDim2.new(1, -200, 0.5, -14)
			btn.Text = sel
			btn.Font = Enum.Font.GothamMedium
			btn.TextSize = 13
			btn.TextColor3 = theme.Text
			btn.TextXAlignment = Enum.TextXAlignment.Left
			btn.AutoButtonColor = false
			btn.BackgroundColor3 = theme.Surface2
			btn.BackgroundTransparency = 0.2
			corner(btn, 6)
			stroke(btn, theme.Stroke, 1, 0.5)
			pad(btn, 8)

			local list = Instance.new("Frame")
			list.Parent = row
			list.Size = UDim2.new(0, 200, 0, 0)
			list.Position = UDim2.new(1, -200, 1, 4)
			list.BackgroundColor3 = theme.Surface
			list.BackgroundTransparency = theme.Trans
			list.ClipsDescendants = true
			list.Visible = false
			corner(list, 6)
			stroke(list, theme.Stroke, 1, 0.5)
			pad(list, 6)

			local sl = Instance.new("UIListLayout")
			sl.SortOrder = Enum.SortOrder.LayoutOrder
			sl.Padding = UDim.new(0, 4)
			sl.Parent = list

			for _, it in ipairs(items) do
				local b = Instance.new("TextButton")
				b.Parent = list
				b.Size = UDim2.new(1, -12, 0, 28)
				b.Text = it
				b.Font = theme.Font
				b.TextSize = 13
				b.TextColor3 = theme.Text
				b.AutoButtonColor = false
				b.BackgroundColor3 = theme.Surface2
				b.BackgroundTransparency = 0.5
				corner(b, 4)
				b.MouseButton1Click:Connect(function()
					sel = it
					btn.Text = it
					tween(list, 0.15, {Size = UDim2.new(0, 200, 0, 0)})
					task.delay(0.16, function() list.Visible = false end)
					if cb then cb(it) end
				end)
			end

			btn.MouseButton1Click:Connect(function()
				if list.Visible then
					tween(list, 0.15, {Size = UDim2.new(0, 200, 0, 0)})
					task.delay(0.16, function() list.Visible = false end)
				else
					list.Visible = true
					local h = math.min(140, 12 + #items * 32)
					tween(list, 0.15, {Size = UDim2.new(0, 200, 0, h)})
				end
			end)
			return row
		end

		function sec:Keybind(text, defaultKey, cb)
			local key = defaultKey or Enum.KeyCode.Unknown
			local row = Instance.new("Frame")
			row.Parent = panel
			row.Size = UDim2.new(1, 0, 0, 36)
			row.BackgroundTransparency = 1

			local lbl = Instance.new("TextLabel")
			lbl.Parent = row
			lbl.Size = UDim2.new(0.5, 0, 1, 0)
			lbl.BackgroundTransparency = 1
			lbl.Text = text
			lbl.Font = theme.Font
			lbl.TextSize = 14
			lbl.TextColor3 = theme.TextDim
			lbl.TextXAlignment = Enum.TextXAlignment.Left

			local btn = Instance.new("TextButton")
			btn.Parent = row
			btn.Size = UDim2.new(0, 200, 0, 28)
			btn.Position = UDim2.new(1, -200, 0.5, -14)
			btn.Text = key ~= Enum.KeyCode.Unknown and key.Name or "Unbound"
			btn.Font = Enum.Font.GothamMedium
			btn.TextSize = 13
			btn.TextColor3 = theme.Text
			btn.AutoButtonColor = false
			btn.BackgroundColor3 = theme.Surface2
			btn.BackgroundTransparency = 0.2
			corner(btn, 6)
			stroke(btn, theme.Stroke, 1, 0.5)

			btn.MouseButton1Click:Connect(function()
				btn.Text = "..."
				local conn
				conn = UserInputService.InputBegan:Connect(function(input, gp)
					if gp then return end
					if input.KeyCode ~= Enum.KeyCode.Unknown then
						key = input.KeyCode
						btn.Text = key.Name
						conn:Disconnect()
						if cb then cb(key) end
					end
				end)
			end)
			return row
		end

		return sec
	end

	-- Settings tab
	local settings = api:Tab("Settings")
	settings:Divider("Interface")
	settings:Toggle("Show UI", visible, setVisible)
	settings:Keybind("Toggle Key", opts.ToggleKey or Enum.KeyCode.RightShift, function(k)
		opts.ToggleKey = k
		notify("Settings", "Toggle key: " .. k.Name)
	end)
	settings:Divider("Theme")
	settings:Button("Accent: Blue", function() theme.Accent = Color3.fromRGB(88, 166, 255) notify("Theme", "Blue") end)
	settings:Button("Accent: Purple", function() theme.Accent = Color3.fromRGB(170, 90, 255) notify("Theme", "Purple") end)
	settings:Button("Accent: Green", function() theme.Accent = Color3.fromRGB(60, 220, 110) notify("Theme", "Green") end)

	gear.MouseButton1Click:Connect(function() settings:Select() end)

	if not visible then main.Visible = false end

	return api
end

return lib
