-- LocalScript，建议放在StarterPlayerScripts中
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local savedPositions = {}

-- UI 创建
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "CyberTeleportUI"

-- 赛博风格主框架
local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 400, 0, 300)
frame.Position = UDim2.new(0.5, -200, 0.5, -150)
frame.BackgroundColor3 = Color3.fromRGB(10, 10, 30)
frame.BorderSizePixel = 0
frame.BackgroundTransparency = 0.1

-- 闪烁霓虹边框
local uiStroke = Instance.new("UIStroke", frame)
uiStroke.Thickness = 2
uiStroke.Color = Color3.fromRGB(0, 255, 255)

-- UI美化
local UICorner = Instance.new("UICorner", frame)
UICorner.CornerRadius = UDim.new(0, 10)

-- 标题
local title = Instance.new("TextLabel", frame)
title.Text = "🧭 Cyber坐标系统"
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(0, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 22

-- 显示当前坐标
local coordsLabel = Instance.new("TextLabel", frame)
coordsLabel.Position = UDim2.new(0, 10, 0, 40)
coordsLabel.Size = UDim2.new(1, -20, 0, 30)
coordsLabel.BackgroundTransparency = 1
coordsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
coordsLabel.Font = Enum.Font.Code
coordsLabel.TextSize = 18
coordsLabel.Text = "坐标: 等待中..."

-- 保存按钮
local saveBtn = Instance.new("TextButton", frame)
saveBtn.Position = UDim2.new(0, 10, 0, 80)
saveBtn.Size = UDim2.new(0, 120, 0, 30)
saveBtn.Text = "📌 保存当前位置"
saveBtn.BackgroundColor3 = Color3.fromRGB(0, 50, 80)
saveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
saveBtn.Font = Enum.Font.SourceSans
saveBtn.TextSize = 18
Instance.new("UICorner", saveBtn)

-- 坐标列表
local coordList = Instance.new("ScrollingFrame", frame)
coordList.Position = UDim2.new(0, 10, 0, 120)
coordList.Size = UDim2.new(1, -20, 0, 150)
coordList.CanvasSize = UDim2.new(0, 0, 0, 0)
coordList.ScrollBarThickness = 4
coordList.BackgroundTransparency = 0.2
coordList.BackgroundColor3 = Color3.fromRGB(0, 20, 40)

-- UIListLayout
local listLayout = Instance.new("UIListLayout", coordList)
listLayout.Padding = UDim.new(0, 5)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- 动态更新坐标
task.spawn(function()
	while true do
		local pos = player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.HumanoidRootPart.Position
		if pos then
			coordsLabel.Text = string.format("坐标: X=%.2f, Y=%.2f, Z=%.2f", pos.X, pos.Y, pos.Z)
		end
		task.wait(0.5)
	end
end)

-- 更新坐标列表UI
local function refreshList()
	coordList:ClearAllChildren()
	listLayout.Parent = coordList

	for i, pos in ipairs(savedPositions) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, 0, 0, 30)
		btn.BackgroundColor3 = Color3.fromRGB(20, 80, 100)
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		btn.Font = Enum.Font.SourceSansBold
		btn.TextSize = 16
		btn.Text = string.format("📍 #%d: X=%.1f Y=%.1f Z=%.1f", i, pos.X, pos.Y, pos.Z)
		Instance.new("UICorner", btn)

		-- 点击传送
		btn.MouseButton1Click:Connect(function()
			if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
				player.Character.HumanoidRootPart.CFrame = CFrame.new(pos)
			end
		end)

		-- 右键删除
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
	local pos = player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character.HumanoidRootPart.Position
	if pos then
		table.insert(savedPositions, pos)
		refreshList()
	end
end)
