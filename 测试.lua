-- LocalScript 放到 StarterPlayerScripts
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local UIS = game:GetService("UserInputService")

local savedPositions = {}

-- 创建 ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CyberTeleportUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

-- 主框架
local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 400, 0, 320)
frame.Position = UDim2.new(0.5, -200, 0.5, -160)
frame.BackgroundColor3 = Color3.fromRGB(10, 10, 30)
frame.BackgroundTransparency = 0.1
frame.BorderSizePixel = 0
Instance.new("UICorner", frame)
Instance.new("UIStroke", frame).Color = Color3.fromRGB(0, 255, 255)

-- 标题
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "🧭 Cyber坐标系统"
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(0, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 22

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

-- 隐藏按钮
local toggleBtn = Instance.new("TextButton", frame)
toggleBtn.Size = UDim2.new(0, 30, 0, 30)
toggleBtn.Position = UDim2.new(1, -70, 0, 0)
toggleBtn.Text = "👁"
toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
toggleBtn.TextColor3 = Color3.fromRGB(0, 255, 255)
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.TextSize = 18
Instance.new("UICorner", toggleBtn)

-- 坐标显示
local coordsLabel = Instance.new("TextLabel", frame)
coordsLabel.Position = UDim2.new(0, 10, 0, 40)
coordsLabel.Size = UDim2.new(1, -20, 0, 25)
coordsLabel.BackgroundTransparency = 1
coordsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
coordsLabel.Font = Enum.Font.Code
coordsLabel.TextSize = 18
coordsLabel.Text = "坐标: 等待中..."

-- 保存按钮
local saveBtn = Instance.new("TextButton", frame)
saveBtn.Position = UDim2.new(0, 10, 0, 70)
saveBtn.Size = UDim2.new(0, 180, 0, 30)
saveBtn.Text = "📌 保存当前位置"
saveBtn.BackgroundColor3 = Color3.fromRGB(0, 50, 80)
saveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
saveBtn.Font = Enum.Font.SourceSans
saveBtn.TextSize = 18
Instance.new("UICorner", saveBtn)

-- 列表框架
local coordList = Instance.new("ScrollingFrame", frame)
coordList.Position = UDim2.new(0, 10, 0, 110)
coordList.Size = UDim2.new(1, -20, 0, 200)
coordList.CanvasSize = UDim2.new(0, 0, 0, 0)
coordList.ScrollBarThickness = 4
coordList.BackgroundTransparency = 0.2
coordList.BackgroundColor3 = Color3.fromRGB(0, 20, 40)

local layout = Instance.new("UIListLayout", coordList)
layout.Padding = UDim.new(0, 5)
layout.SortOrder = Enum.SortOrder.LayoutOrder

-- UI层级关系
title.Parent = frame
coordsLabel.Parent = frame
saveBtn.Parent = frame
coordList.Parent = frame

-- 实时坐标更新
RunService.RenderStepped:Connect(function()
	local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if hrp then
		local pos = hrp.Position
		coordsLabel.Text = string.format("坐标: X=%.2f, Y=%.2f, Z=%.2f", pos.X, pos.Y, pos.Z)
	else
		coordsLabel.Text = "坐标: 加载中..."
	end
end)

-- 更新坐标列表 UI
local function refreshList()
	for _, child in ipairs(coordList:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end

	for i, pos in ipairs(savedPositions) do
		local item = Instance.new("Frame")
		item.Size = UDim2.new(1, 0, 0, 30)
		item.BackgroundColor3 = Color3.fromRGB(20, 80, 100)
		Instance.new("UICorner", item)

		local label = Instance.new("TextLabel", item)
		label.Text = string.format("📍 #%d: X=%.1f Y=%.1f Z=%.1f", i, pos.X, pos.Y, pos.Z)
		label.Size = UDim2.new(0.55, 0, 1, 0)
		label.BackgroundTransparency = 1
		label.TextColor3 = Color3.fromRGB(255, 255, 255)
		label.Font = Enum.Font.SourceSans
		label.TextSize = 16
		label.TextXAlignment = Enum.TextXAlignment.Left

		local teleportBtn = Instance.new("TextButton", item)
		teleportBtn.Text = "🧭"
		teleportBtn.Size = UDim2.new(0, 30, 0, 30)
		teleportBtn.Position = UDim2.new(0.65, 0, 0, 0)
		teleportBtn.BackgroundColor3 = Color3.fromRGB(30, 150, 100)
		teleportBtn.TextColor3 = Color3.new(1, 1, 1)
		teleportBtn.Font = Enum.Font.SourceSansBold
		teleportBtn.TextSize = 20
		Instance.new("UICorner", teleportBtn)

		local deleteBtn = Instance.new("TextButton", item)
		deleteBtn.Text = "🗑"
		deleteBtn.Size = UDim2.new(0, 30, 0, 30)
		deleteBtn.Position = UDim2.new(0.8, 0, 0, 0)
		deleteBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
		deleteBtn.TextColor3 = Color3.new(1, 1, 1)
		deleteBtn.Font = Enum.Font.SourceSansBold
		deleteBtn.TextSize = 20
		Instance.new("UICorner", deleteBtn)

		teleportBtn.MouseButton1Click:Connect(function()
			local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
			if hrp then
				hrp.CFrame = CFrame.new(pos)
			end
		end)

		deleteBtn.MouseButton1Click:Connect(function()
			table.remove(savedPositions, i)
			refreshList()
		end)

		item.Parent = coordList
	end

	coordList.CanvasSize = UDim2.new(0, 0, 0, #savedPositions * 35)
end

-- 保存按钮逻辑
saveBtn.MouseButton1Click:Connect(function()
	local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if hrp then
		local pos = hrp.Position
		table.insert(savedPositions, pos)
		refreshList()
	end
end)

-- 最小化逻辑
local isMinimized = false
minimizeBtn.MouseButton1Click:Connect(function()
	isMinimized = not isMinimized
	coordsLabel.Visible = not isMinimized
	saveBtn.Visible = not isMinimized
	coordList.Visible = not isMinimized
end)

-- 显示隐藏 UI
local isHidden = false
toggleBtn.MouseButton1Click:Connect(function()
	isHidden = not isHidden
	frame.Visible = not isHidden
end)
