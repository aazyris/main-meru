--// Depso ImGui: Exact Structural Replica
--// Optimized for Black & White Aesthetic

local ImGui = {
	Animations = {
		Buttons = {
			MouseEnter = { BackgroundTransparency = 0.5 },
			MouseLeave = { BackgroundTransparency = 0.7 } 
		},
		WindowBorder = {
			Selected = { Transparency = 0, Thickness = 1.2 },
			Deselected = { Transparency = 0.7, Thickness = 1 }
		}
	},
	Windows = {},
	Animation = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
}

--// Services & References
local function CloneRef(service) return game:GetService(service) end
local UIS = CloneRef("UserInputService")
local TS = CloneRef("TweenService")
local CoreGui = CloneRef("CoreGui")

function ImGui:Tween(obj, props)
	local t = TS:Create(obj, self.Animation, props)
	t:Play()
	return t
end

--// This mimics Depso's "MergeMetatables" to make the UI behave like a real library
function ImGui:Merge(Class, Instance)
	return setmetatable(Class, {
		__index = Instance,
		__newindex = function(_, k, v) Instance[k] = v end
	})
end

function ImGui:CreateWindow(title)
	local Screen = Instance.new("ScreenGui", CoreGui)
	Screen.Name = "DepsoImGui"

	local Main = Instance.new("Frame", Screen)
	Main.Size = UDim2.fromOffset(550, 400)
	Main.Position = UDim2.fromOffset(100, 100)
	Main.BackgroundColor3 = Color3.new(0,0,0)
	Main.BackgroundTransparency = 0.3
	Main.BorderSizePixel = 0
	Main.ClipsDescendants = true

	local Stroke = Instance.new("UIStroke", Main)
	Stroke.Color = Color3.new(1,1,1)
	Stroke.Transparency = 0.7
	Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

	-- Header Area
	local Header = Instance.new("Frame", Main)
	Header.Size = UDim2.new(1, 0, 0, 35)
	Header.BackgroundTransparency = 1

	local Title = Instance.new("TextLabel", Header)
	Title.Text = "  " .. title:upper()
	Title.Size = UDim2.new(1, 0, 1, 0)
	Title.TextColor3 = Color3.new(1,1,1)
	Title.Font = Enum.Font.GothamBold
	Title.TextSize = 12
	Title.TextXAlignment = "Left"
	Title.BackgroundTransparency = 1

	local MinBtn = Instance.new("TextButton", Header)
	MinBtn.Size = UDim2.fromOffset(30, 30)
	MinBtn.Position = UDim2.new(1, -35, 0, 2)
	MinBtn.Text = "▼"
	MinBtn.TextColor3 = Color3.new(1,1,1)
	MinBtn.BackgroundTransparency = 1

	-- Resize Expander (The ◢ handle)
	local ResizeBtn = Instance.new("TextButton", Main)
	ResizeBtn.Size = UDim2.fromOffset(18, 18)
	ResizeBtn.Position = UDim2.new(1, -18, 1, -18)
	ResizeBtn.Text = "◢"
	ResizeBtn.TextColor3 = Color3.new(1,1,1)
	ResizeBtn.BackgroundTransparency = 1
	ResizeBtn.ZIndex = 10

	-- Body Containers
	local Sidebar = Instance.new("ScrollingFrame", Main)
	Sidebar.Size = UDim2.new(0, 130, 1, -50)
	Sidebar.Position = UDim2.fromOffset(10, 40)
	Sidebar.BackgroundTransparency = 0.6
	Sidebar.BackgroundColor3 = Color3.new(0,0,0)
	Sidebar.ScrollBarThickness = 0
	Instance.new("UIListLayout", Sidebar).Padding = UDim.new(0, 5)
	Instance.new("UIPadding", Sidebar).PaddingTop = UDim.new(0, 5)

	local Container = Instance.new("Frame", Main)
	Container.Size = UDim2.new(1, -160, 1, -50)
	Container.Position = UDim2.fromOffset(150, 40)
	Container.BackgroundTransparency = 0.8
	Container.BackgroundColor3 = Color3.new(0,0,0)
	Instance.new("UICorner", Container)

	-- Drag Logic
	Header.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			local startPos = Main.Position
			local startMouse = input.Position
			local con
			con = UIS.InputChanged:Connect(function(move)
				if move.UserInputType == Enum.UserInputType.MouseMovement then
					local delta = move.Position - startMouse
					Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
				end
			end)
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then con:Disconnect() end
			end)
		end
	end)

	-- Resize Logic
	ResizeBtn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			local con
			con = UIS.InputChanged:Connect(function(move)
				if move.UserInputType == Enum.UserInputType.MouseMovement then
					local mouse = UIS:GetMouseLocation()
					Main.Size = UDim2.fromOffset(math.max(mouse.X - Main.AbsolutePosition.X, 400), math.max(mouse.Y - Main.AbsolutePosition.Y, 250))
				end
			end)
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then con:Disconnect() end
			end)
		end
	end)

	-- Minimize Logic
	local minimized = false
	MinBtn.MouseButton1Click:Connect(function()
		minimized = not minimized
		ImGui:Tween(MinBtn, {Rotation = minimized and -90 or 0})
		ImGui:Tween(Main, {Size = minimized and UDim2.fromOffset(Main.Size.X.Offset, 35) or UDim2.fromOffset(Main.Size.X.Offset, 400)})
	end)

	local WinAPI = { Pages = {} }

	function WinAPI:Category(name)
		local Page = Instance.new("ScrollingFrame", Container)
		Page.Size = UDim2.new(1, -10, 1, -10)
		Page.Position = UDim2.fromOffset(5, 5)
		Page.Visible = false
		Page.BackgroundTransparency = 1
		Page.ScrollBarThickness = 2
		Instance.new("UIListLayout", Page).Padding = UDim.new(0, 5)

		local Tab = Instance.new("TextButton", Sidebar)
		Tab.Size = UDim2.new(1, -10, 0, 28)
		Tab.Position = UDim2.fromOffset(5, 0)
		Tab.Text = name
		Tab.TextColor3 = Color3.fromRGB(150, 150, 150)
		Tab.BackgroundColor3 = Color3.new(1,1,1)
		Tab.BackgroundTransparency = 1
		Instance.new("UICorner", Tab)

		Tab.MouseButton1Click:Connect(function()
			for _, p in pairs(Container:GetChildren()) do if p:IsA("ScrollingFrame") then p.Visible = false end end
			for _, t in pairs(Sidebar:GetChildren()) do if t:IsA("TextButton") then t.BackgroundTransparency = 1 t.TextColor3 = Color3.fromRGB(150,150,150) end end
			Page.Visible = true
			Tab.BackgroundTransparency = 0.1
			Tab.TextColor3 = Color3.new(0,0,0)
		end)

		if #Sidebar:GetChildren() == 2 then -- First tab check
			Page.Visible = true
			Tab.BackgroundTransparency = 0.1
			Tab.TextColor3 = Color3.new(0,0,0)
		end

		local PageAPI = {}

		function PageAPI:Button(txt, cb)
			local b = Instance.new("TextButton", Page)
			b.Size = UDim2.new(1, -5, 0, 30)
			b.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
			b.Text = txt
			b.TextColor3 = Color3.new(1,1,1)
			b.Font = Enum.Font.Gotham
			Instance.new("UICorner", b)
			b.MouseButton1Click:Connect(cb)
			
			-- Hover Animation
			b.MouseEnter:Connect(function() ImGui:Tween(b, {BackgroundTransparency = 0.5}) end)
			b.MouseLeave:Connect(function() ImGui:Tween(b, {BackgroundTransparency = 0}) end)
		end

		function PageAPI:Toggle(txt, cb)
			local state = false
			local t = Instance.new("TextButton", Page)
			t.Size = UDim2.new(1, -5, 0, 30)
			t.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
			t.Text = "  " .. txt
			t.TextColor3 = Color3.new(1,1,1)
			t.TextXAlignment = "Left"
			Instance.new("UICorner", t)

			local box = Instance.new("Frame", t)
			box.Size = UDim2.fromOffset(26, 14)
			box.Position = UDim2.new(1, -35, 0.5, -7)
			box.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
			Instance.new("UICorner", box).CornerRadius = UDim.new(1,0)

			t.MouseButton1Click:Connect(function()
				state = not state
				ImGui:Tween(box, {BackgroundColor3 = state and Color3.new(1,1,1) or Color3.new(0.2,0.2,0.2)})
				cb(state)
			end)
		end

		return PageAPI
	end

	return WinAPI
end

return ImGui
