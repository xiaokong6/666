-- 放在 StarterPlayerScripts 的 LocalScript

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local savedPositions = {}

-- UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CyberTeleportUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 400, 0, 300)
frame.Position = UDim2.new(0.5, -200, 0.5, -150)
frame.BackgroundColor3 = Color3.fromRGB(10, 10, 30)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 0
frame.Parent = screenGui

local stroke = Instance.new("UIStroke", frame)
stroke.Thickness = 2
stroke.Color = Color3.fromRGB(0, 255, 255)

local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.Text = "🧭 Cyber坐标系统"
title.TextColor3 = Color3.fromRGB(0, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 22
title.Parent = frame

-- 最小化按钮
local minimizeBtn = Instance.new("TextButton", frame)
minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
minimizeBtn.Position = UDim2.new(1, -35, 0, 0)
minimizeBtn.Text = "-"
minimizeBtn.BackgroundColor3 = Color3.fromRGB(20, 40, 60)
minimizeBtn.TextColor3 = Color3.fromRGB(0, 255, 255)
minimizeBtn.Font = Enum.Font.SourceSansBold
minimizeBtn.TextSize = 22
Instance.new("UICorner", minimizeBtn)

-- 显示坐标
local coordsLabel = Instance.new("TextLabel", frame)
coordsLabel.Position = UDim2.new(0, 10, 0, 40)
coordsLabel.Size = UDim2.new(1, -20, 0, 30)
coordsLabel.BackgroundTransparency = 1
coordsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
coordsLabel.Font = Enum.Font.Code
coordsLabel.TextSize = 18
coordsLabel.Text = "坐标: 等待中..."
coordsLabel.Parent = frame

-- 保存按钮
local saveBtn = Instance.new("TextButton", frame)
saveBtn.Position = UDim2.new(0, 10, 0, 80)
saveBtn.Size = UDim2.new(0, 180, 0, 30)
saveBtn.Text = "📌 保存当前位置"
saveBtn.BackgroundColor3 = Color3.fromRGB(0, 50, 80)
saveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
saveBtn.Font = Enum.Font.SourceSans
saveBtn.TextSize = 18
Instance.new("UICorner", saveBtn)
saveBtn.Parent = frame

-- 坐标列表
local coordList = Instance.new("ScrollingFrame", frame)
coordList.Position = UDim2.new(0, 10, 0, 120)
coordList.Size = UDim2.new(1, -20, 0, 160)
coordList.BackgroundTransparency = 0.2
coordList.BackgroundColor3 = Color3.fromRGB(0, 20, 40)
coordList.ScrollBarThickness = 4
coordList.CanvasSize = UDim2.new(0, 0, 0, 0)
coordList.Parent = frame

local layout = Instance.new("UIListLayout", coordList)
layout.Padding = UDim.new(0, 5)
layout.SortOrder = Enum.SortOrder.LayoutOrder

-- 实时刷新坐标显示
RunService.RenderStepped:Connect(function()
	local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if hrp then
		local pos = hrp.Position
		coordsLabel.Text = string.format("坐标: X=%.2f, Y=%.2f, Z=%.2f", pos.X, pos.Y, pos.Z)
	else
		coordsLabel.Text = "坐标: 等待加载..."
	end
end)

-- 更新列表 UI
local function refreshList()
	for _, child in ipairs(coordList:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end

	for i, pos in ipairs(savedPositions) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, 0, 0, 30)
		btn.BackgroundColor3 = Color3.fromRGB(20, 80, 100)
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		btn.Font = Enum.Font.SourceSansBold
		btn.TextSize = 16
		btn.Text = string.format("📍 #%d: X=%.1f Y=%.1f Z=%.1f", i, pos.X, pos.Y, pos.Z)
		Instance.new("UICorner", btn)

		-- 传送
		btn.MouseButton1Click:Connect(function()
			local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
			if hrp then
				hrp.CFrame = CFrame.new(pos)
			end
		end)

		-- 删除
		btn.MouseButton2Click:Connect(function()
			table.remove(savedPositions, i)
			refreshList()
		end)

		btn.Parent = coordList
	end

	coordList.CanvasSize = UDim2.new(0, 0, 0, #savedPositions * 35)
end

-- 保存坐标
saveBtn.MouseButton1Click:Connect(function()
	local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if hrp then
		local pos = hrp.Position
		table.insert(savedPositions, pos)
		refreshList()
	end
end)

-- 最小化功能
local minimized = false
minimizeBtn.MouseButton1Click:Connect(function()
	minimized = not minimized
	for _, child in ipairs(frame:GetChildren()) do
		if child ~= title and child ~= minimizeBtn then
			child.Visible = not minimized
		end
	end
	if minimized then
		frame.Size = UDim2.new(0, 400, 0, 40)
	else
		frame.Size = UDim2.new(0, 400, 0, 300)
	end
end)

-- H 键隐藏/显示 UI
UIS.InputBegan:Connect(function(input, isTyping)
	if isTyping then return end
	if input.KeyCode == Enum.KeyCode.H then
		screenGui.Enabled = not screenGui.Enabled
	end
end)
