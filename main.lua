--[[
	MeruLib - ImGui-style Roblox UI for games
	Flat, dark, collapsible sections
]]

local UserInputService = game:GetService("UserInputService")
local Debris = game:GetService("Debris")

local lib = {}

-- ImGui colors
local C = {
	Bg = Color3.fromRGB(13, 13, 15),
	ChildBg = Color3.fromRGB(20, 20, 24),
	Border = Color3.fromRGB(55, 55, 65),
	Text = Color3.fromRGB(255, 255, 255),
	TextDim = Color3.fromRGB(140, 140, 150),
	Header = Color3.fromRGB(26, 26, 32),
	HeaderHover = Color3.fromRGB(40, 40, 48),
	Button = Color3.fromRGB(45, 45, 55),
	ButtonHover = Color3.fromRGB(55, 55, 68),
	ButtonActive = Color3.fromRGB(35, 75, 130),
	SliderGrab = Color3.fromRGB(70, 130, 220),
	FrameBg = Color3.fromRGB(30, 30, 38),
}

local function parentGui(gui)
	if syn and syn.protect_gui then syn.protect_gui(gui) end
	gui.Parent = gethui and gethui() or game:GetService("CoreGui")
end

local function pad(inst, l, r, t, b)
	local u = Instance.new("UIPadding")
	u.PaddingLeft = UDim.new(0, l or 8)
	u.PaddingRight = UDim.new(0, r or 8)
	u.PaddingTop = UDim.new(0, t or 6)
	u.PaddingBottom = UDim.new(0, b or 6)
	u.Parent = inst
	return u
end

function lib.init(opts)
	opts = opts or {}
	local name = opts.Name or "MeruUI"
	local w = opts.Size and opts.Size.X or 380
	local h = opts.Size and opts.Size.Y or 420
	local title = opts.Title or "Meru"

	local cg = gethui and gethui() or game:GetService("CoreGui")
	local old = cg:FindFirstChild(name)
	if old and opts.DeletePrevious then old:Destroy() end

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
	main.Size = UDim2.new(0, w, 0, h)
	main.BackgroundColor3 = C.Bg
	main.BorderSizePixel = 0

	local border = Instance.new("UIStroke")
	border.Color = C.Border
	border.Thickness = 1
	border.Transparency = 0.3
	border.Parent = main

	-- Title bar
	local titleBar = Instance.new("Frame")
	titleBar.Parent = main
	titleBar.Size = UDim2.new(1, 0, 0, 24)
	titleBar.BackgroundColor3 = C.Header
	titleBar.BorderSizePixel = 0

	local titleLbl = Instance.new("TextLabel")
	titleLbl.Parent = titleBar
	titleLbl.Size = UDim2.new(1, -60, 1, 0)
	titleLbl.Position = UDim2.new(0, 8, 0, 0)
	titleLbl.BackgroundTransparency = 1
	titleLbl.Font = Enum.Font.RobotoMono
	titleLbl.TextSize = 13
	titleLbl.TextColor3 = C.Text
	titleLbl.TextXAlignment = Enum.TextXAlignment.Left
	titleLbl.Text = title

	local closeBtn = Instance.new("TextButton")
	closeBtn.Parent = titleBar
	closeBtn.Size = UDim2.new(0, 24, 0, 24)
	closeBtn.Position = UDim2.new(1, -24, 0, 0)
	closeBtn.BackgroundTransparency = 1
	closeBtn.Text = "x"
	closeBtn.TextColor3 = C.TextDim
	closeBtn.TextSize = 14
	closeBtn.Font = Enum.Font.RobotoMono
	closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

	-- Content
	local content = Instance.new("ScrollingFrame")
	content.Parent = main
	content.Position = UDim2.new(0, 0, 0, 24)
	content.Size = UDim2.new(1, 0, 1, -24)
	content.BackgroundColor3 = C.Bg
	content.BorderSizePixel = 0
	content.ScrollBarThickness = 4
	content.ScrollBarImageColor3 = C.Border
	content.CanvasSize = UDim2.new(0, 0, 0, 0)
	content.AutomaticCanvasSize = Enum.AutomaticSize.Y
	pad(content, 4, 4, 4, 4)

	local list = Instance.new("UIListLayout")
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Padding = UDim.new(0, 2)
	list.Parent = content

	-- Drag
	local dragStart, startPos
	titleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragStart = input.Position
			startPos = main.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragStart = nil end
			end)
		end
	end)
	titleBar.InputChanged:Connect(function(input)
		if dragStart and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local d = input.Position - dragStart
			main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
	end)

	-- Toggle key
	if opts.ToggleKey then
		UserInputService.InputBegan:Connect(function(input, gp)
			if not gp and input.KeyCode == opts.ToggleKey then
				main.Visible = not main.Visible
			end
		end)
	end

	-- Notify
	local function notify(msg)
		local n = Instance.new("Frame")
		n.Parent = gui
		n.AnchorPoint = Vector2.new(0.5, 1)
		n.Position = UDim2.new(0.5, 0, 1, -12)
		n.Size = UDim2.new(0, math.min(#msg * 7 + 24, 400), 0, 28)
		n.BackgroundColor3 = C.ChildBg
		n.BorderSizePixel = 0
		local sb = Instance.new("UIStroke")
		sb.Color = C.Border
		sb.Thickness = 1
		sb.Parent = n
		local l = Instance.new("TextLabel")
		l.Parent = n
		l.BackgroundTransparency = 1
		l.Size = UDim2.new(1, -16, 1, 0)
		l.Position = UDim2.new(0, 8, 0, 0)
		l.Font = Enum.Font.RobotoMono
		l.TextSize = 12
		l.TextColor3 = C.Text
		l.TextXAlignment = Enum.TextXAlignment.Left
		l.Text = msg
		Debris:AddItem(n, 3)
	end

	local api = {}
	function api:Destroy() gui:Destroy() end
	function api:Notify(msg) notify(msg) end

	-- Section (collapsible)
	function api:Section(label, defaultOpen)
		local open = defaultOpen == true
		local header = Instance.new("TextButton")
		header.Parent = content
		header.Size = UDim2.new(1, -8, 0, 22)
		header.BackgroundColor3 = C.Header
		header.BorderSizePixel = 0
		header.Text = ""
		header.AutoButtonColor = false

		local arrow = Instance.new("TextLabel")
		arrow.Parent = header
		arrow.Size = UDim2.new(0, 16, 1, 0)
		arrow.Position = UDim2.new(0, 4, 0, 0)
		arrow.BackgroundTransparency = 1
		arrow.Font = Enum.Font.RobotoMono
		arrow.TextSize = 12
		arrow.TextColor3 = C.TextDim
		arrow.Text = open and "v" or ">"
		arrow.TextXAlignment = Enum.TextXAlignment.Left

		local lbl = Instance.new("TextLabel")
		lbl.Parent = header
		lbl.Size = UDim2.new(1, -24, 1, 0)
		lbl.Position = UDim2.new(0, 20, 0, 0)
		lbl.BackgroundTransparency = 1
		lbl.Font = Enum.Font.RobotoMono
		lbl.TextSize = 12
		lbl.TextColor3 = C.Text
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Text = label

		local body = Instance.new("Frame")
		body.Parent = content
		body.Size = UDim2.new(1, -12, 0, 0)
		body.BackgroundTransparency = 1
		body.Visible = open

		local bl = Instance.new("UIListLayout")
		bl.SortOrder = Enum.SortOrder.LayoutOrder
		bl.Padding = UDim.new(0, 2)
		bl.Parent = body
		bl:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			body.Size = UDim2.new(1, -12, 0, bl.AbsoluteContentSize.Y + 4)
		end)
		pad(body, 12, 4, 4, 4)

		header.MouseButton1Click:Connect(function()
			open = not open
			body.Visible = open
			arrow.Text = open and "v" or ">"
		end)
		header.MouseEnter:Connect(function() header.BackgroundColor3 = C.HeaderHover end)
		header.MouseLeave:Connect(function() header.BackgroundColor3 = C.Header end)

		local sec = {}

		function sec:Button(text, cb)
			local b = Instance.new("TextButton")
			b.Parent = body
			b.Size = UDim2.new(1, 0, 0, 24)
			b.BackgroundColor3 = C.Button
			b.BorderSizePixel = 0
			b.Text = "  " .. text
			b.Font = Enum.Font.RobotoMono
			b.TextSize = 12
			b.TextColor3 = C.Text
			b.TextXAlignment = Enum.TextXAlignment.Left
			b.AutoButtonColor = false
			if cb then b.MouseButton1Click:Connect(cb) end
			b.MouseEnter:Connect(function() b.BackgroundColor3 = C.ButtonHover end)
			b.MouseLeave:Connect(function() b.BackgroundColor3 = C.Button end)
			return b
		end

		function sec:Checkbox(label, default, cb)
			local on = default == true
			local row = Instance.new("TextButton")
			row.Parent = body
			row.Size = UDim2.new(1, 0, 0, 22)
			row.BackgroundTransparency = 1
			row.Text = ""
			row.AutoButtonColor = false

			local box = Instance.new("Frame")
			box.Parent = row
			box.Size = UDim2.new(0, 14, 0, 14)
			box.Position = UDim2.new(0, 0, 0.5, -7)
			box.BackgroundColor3 = C.FrameBg
			box.BorderSizePixel = 0
			local boxStroke = Instance.new("UIStroke")
			boxStroke.Color = C.Border
			boxStroke.Thickness = 1
			boxStroke.Parent = box

			local check = Instance.new("TextLabel")
			check.Parent = box
			check.Size = UDim2.new(1, 0, 1, 0)
			check.BackgroundTransparency = 1
			check.Text = "x"
			check.Font = Enum.Font.RobotoMono
			check.TextSize = 10
			check.TextColor3 = C.SliderGrab
			check.Visible = on

			local lbl = Instance.new("TextLabel")
			lbl.Parent = row
			lbl.Size = UDim2.new(1, -24, 1, 0)
			lbl.Position = UDim2.new(0, 22, 0, 0)
			lbl.BackgroundTransparency = 1
			lbl.Text = label
			lbl.Font = Enum.Font.RobotoMono
			lbl.TextSize = 12
			lbl.TextColor3 = C.Text
			lbl.TextXAlignment = Enum.TextXAlignment.Left

			row.MouseButton1Click:Connect(function()
				on = not on
				check.Visible = on
				if cb then cb(on) end
			end)
			return row
		end

		function sec:Slider(label, minV, maxV, default, cb)
			local val = math.clamp(default or minV, minV, maxV)
			local row = Instance.new("Frame")
			row.Parent = body
			row.Size = UDim2.new(1, 0, 0, 36)
			row.BackgroundTransparency = 1

			local lbl = Instance.new("TextLabel")
			lbl.Parent = row
			lbl.Size = UDim2.new(0.5, -4, 0, 16)
			lbl.BackgroundTransparency = 1
			lbl.Text = label
			lbl.Font = Enum.Font.RobotoMono
			lbl.TextSize = 11
			lbl.TextColor3 = C.TextDim
			lbl.TextXAlignment = Enum.TextXAlignment.Left

			local valLbl = Instance.new("TextLabel")
			valLbl.Parent = row
			valLbl.Size = UDim2.new(0.5, -4, 0, 16)
			valLbl.Position = UDim2.new(0.5, 0, 0, 0)
			valLbl.BackgroundTransparency = 1
			valLbl.Text = tostring(val)
			valLbl.Font = Enum.Font.RobotoMono
			valLbl.TextSize = 11
			valLbl.TextColor3 = C.TextDim
			valLbl.TextXAlignment = Enum.TextXAlignment.Right

			local track = Instance.new("Frame")
			track.Parent = row
			track.Size = UDim2.new(1, 0, 0, 4)
			track.Position = UDim2.new(0, 0, 0, 20)
			track.BackgroundColor3 = C.FrameBg
			track.BorderSizePixel = 0

			local fill = Instance.new("Frame")
			fill.Parent = track
			fill.Size = UDim2.new((val - minV) / (maxV - minV), 0, 1, 0)
			fill.BackgroundColor3 = C.SliderGrab
			fill.BorderSizePixel = 0

			local hit = Instance.new("TextButton")
			hit.Parent = track
			hit.Size = UDim2.new(1, 0, 4, 0)
			hit.Position = UDim2.new(0, 0, -2, 0)
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

		function sec:Combo(label, items, default, cb)
			local sel = default or items[1] or ""
			local row = Instance.new("Frame")
			row.Parent = body
			row.Size = UDim2.new(1, 0, 0, 24)
			row.BackgroundTransparency = 1

			local lbl = Instance.new("TextLabel")
			lbl.Parent = row
			lbl.Size = UDim2.new(0.4, 0, 1, 0)
			lbl.BackgroundTransparency = 1
			lbl.Text = label
			lbl.Font = Enum.Font.RobotoMono
			lbl.TextSize = 11
			lbl.TextColor3 = C.TextDim
			lbl.TextXAlignment = Enum.TextXAlignment.Left

			local btn = Instance.new("TextButton")
			btn.Parent = row
			btn.Size = UDim2.new(0.55, -4, 0, 22)
			btn.Position = UDim2.new(0.45, 0, 0, 0)
			btn.Text = "  " .. sel
			btn.Font = Enum.Font.RobotoMono
			btn.TextSize = 11
			btn.TextColor3 = C.Text
			btn.TextXAlignment = Enum.TextXAlignment.Left
			btn.AutoButtonColor = false
			btn.BackgroundColor3 = C.Button
			btn.BorderSizePixel = 0

			local list = Instance.new("Frame")
			list.Parent = row
			list.Size = UDim2.new(0.55, -4, 0, 0)
			list.Position = UDim2.new(0.45, 0, 1, 2)
			list.BackgroundColor3 = C.ChildBg
			list.BorderSizePixel = 0
			list.ClipsDescendants = true
			list.Visible = false
			list.ZIndex = 10

			local ll = Instance.new("UIListLayout")
			ll.SortOrder = Enum.SortOrder.LayoutOrder
			ll.Parent = list

			for _, it in ipairs(items) do
				local b = Instance.new("TextButton")
				b.Parent = list
				b.Size = UDim2.new(1, 0, 0, 20)
				b.Text = "  " .. it
				b.Font = Enum.Font.RobotoMono
				b.TextSize = 11
				b.TextColor3 = C.Text
				b.TextXAlignment = Enum.TextXAlignment.Left
				b.AutoButtonColor = false
				b.BackgroundTransparency = 1
				b.ZIndex = 11
				b.MouseButton1Click:Connect(function()
					sel = it
					btn.Text = "  " .. sel
					list.Visible = false
					list.Size = UDim2.new(0.55, -4, 0, 0)
					if cb then cb(it) end
				end)
			end

			btn.MouseButton1Click:Connect(function()
				if list.Visible then
					list.Visible = false
					list.Size = UDim2.new(0.55, -4, 0, 0)
				else
					list.Visible = true
					list.Size = UDim2.new(0.55, -4, 0, math.min(#items * 22, 120))
				end
			end)
			return row
		end

		function sec:Input(label, placeholder, cb)
			local row = Instance.new("Frame")
			row.Parent = body
			row.Size = UDim2.new(1, 0, 0, 24)
			row.BackgroundTransparency = 1

			local lbl = Instance.new("TextLabel")
			lbl.Parent = row
			lbl.Size = UDim2.new(0.35, 0, 1, 0)
			lbl.BackgroundTransparency = 1
			lbl.Text = label
			lbl.Font = Enum.Font.RobotoMono
			lbl.TextSize = 11
			lbl.TextColor3 = C.TextDim
			lbl.TextXAlignment = Enum.TextXAlignment.Left

			local box = Instance.new("Frame")
			box.Parent = row
			box.Size = UDim2.new(0.6, -4, 0, 20)
			box.Position = UDim2.new(0.38, 0, 0, 0)
			box.BackgroundColor3 = C.FrameBg
			box.BorderSizePixel = 0

			local tb = Instance.new("TextBox")
			tb.Parent = box
			tb.Size = UDim2.new(1, -10, 1, 0)
			tb.Position = UDim2.new(0, 5, 0, 0)
			tb.BackgroundTransparency = 1
			tb.Font = Enum.Font.RobotoMono
			tb.TextSize = 11
			tb.PlaceholderText = placeholder or ""
			tb.PlaceholderColor3 = C.TextDim
			tb.TextColor3 = C.Text
			tb.TextXAlignment = Enum.TextXAlignment.Left
			tb.ClearTextOnFocus = false

			if cb then tb.FocusLost:Connect(function() cb(tb.Text) end) end
			return tb
		end

		function sec:Keybind(label, defaultKey, cb)
			local key = defaultKey or Enum.KeyCode.Unknown
			local row = Instance.new("Frame")
			row.Parent = body
			row.Size = UDim2.new(1, 0, 0, 24)
			row.BackgroundTransparency = 1

			local lbl = Instance.new("TextLabel")
			lbl.Parent = row
			lbl.Size = UDim2.new(0.5, 0, 1, 0)
			lbl.BackgroundTransparency = 1
			lbl.Text = label
			lbl.Font = Enum.Font.RobotoMono
			lbl.TextSize = 11
			lbl.TextColor3 = C.TextDim
			lbl.TextXAlignment = Enum.TextXAlignment.Left

			local btn = Instance.new("TextButton")
			btn.Parent = row
			btn.Size = UDim2.new(0.45, -4, 0, 20)
			btn.Position = UDim2.new(0.52, 0, 0, 0)
			btn.Text = key ~= Enum.KeyCode.Unknown and key.Name or "..."
			btn.Font = Enum.Font.RobotoMono
			btn.TextSize = 11
			btn.TextColor3 = C.Text
			btn.AutoButtonColor = false
			btn.BackgroundColor3 = C.Button
			btn.BorderSizePixel = 0

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

		function sec:Text(str)
			local l = Instance.new("TextLabel")
			l.Parent = body
			l.Size = UDim2.new(1, 0, 0, 18)
			l.BackgroundTransparency = 1
			l.Text = str
			l.Font = Enum.Font.RobotoMono
			l.TextSize = 11
			l.TextColor3 = C.TextDim
			l.TextXAlignment = Enum.TextXAlignment.Left
			l.TextWrapped = true
			return l
		end

		function sec:Separator()
			local s = Instance.new("Frame")
			s.Parent = body
			s.Size = UDim2.new(1, 0, 0, 1)
			s.BackgroundColor3 = C.Border
			s.BackgroundTransparency = 0.5
			s.BorderSizePixel = 0
			return s
		end

		return sec
	end

	return api
end

return lib
