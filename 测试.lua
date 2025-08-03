-- LocalScript 放 StarterPlayerScripts
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local savedPositions = {}

-- UI 创建
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "CyberTeleportUI"
screenGui.ResetOnSpawn = false

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 400, 0, 300)
frame.Position = UDim2.new(0.5, -200, 0.5, -150)
frame.BackgroundColor3 = Color3.fromRGB(10, 10, 30)
frame.BorderSizePixel = 0
frame.BackgroundTransparency = 0.1

local uiStroke = Instance.new("UIStroke", frame)
uiStroke.Thickness = 2
uiStroke.Color = Color3.fromRGB(0, 255, 255)

local UICorner = Instance.new("UICorner", frame)
UICorner.CornerRadius = UDim.new(0, 10)

local title = Instance.new("TextLabel", frame)
title.Text = "🧭 Cyber坐标系统"
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(0, 255, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 22

local coordsLabel = Instance.new("TextLabel", frame)
coordsLabel.Position = UDim2.new(0, 10, 0, 40)
coordsLabel.Size = UDim2.new(1, -20, 0, 30)
coordsLabel.BackgroundTransparency = 1
coordsLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
coordsLabel.Font = Enum.Font.Code
coordsLabel.TextSize = 18
coordsLabel.Text = "坐标: 等待中..."

local saveBtn = Instance.new("TextButton", frame)
saveBtn.Position = UDim2.new(0, 10, 0, 80)
saveBtn.Size = UDim2.new(0, 120, 0, 30)
saveBtn.Text = "📌 保存当前位置"
saveBtn.BackgroundColor3 = Color3.fromRGB(0, 50, 80)
saveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
saveBtn.Font = Enum.Font.SourceSans
saveBtn.TextSize = 18
Instance.new("UICorner", saveBtn)

local coordList = Instance.new("ScrollingFrame", frame)
coordList.Position = UDim2.new(0, 10, 0, 120)
coordList.Size = UDim2.new(1, -20, 0, 160)
coordList.CanvasSize = UDim2.new(0, 0, 0, 0)
coordList.ScrollBarThickness = 4
coordList.BackgroundTransparency = 0.2
coordList.BackgroundColor3 = Color3.fromRGB(0, 20, 40)

local listLayout = Instance.new("UIListLayout", coordList)
listLayout.Padding = UDim.new(0, 5)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- 实时刷新坐标
RunService.RenderStepped:Connect(function()
	local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if hrp then
		local pos = hrp.Position
		coordsLabel.Text = string.format("坐标: X=%.2f, Y=%.2f, Z=%.2f", pos.X, pos.Y, pos.Z)
	else
		coordsLabel.Text = "坐标: 等待角色加载..."
	end
end)

-- 更新UI函数
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

		btn.MouseButton1Click:Connect(function()
			local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
			if hrp then
				hrp.CFrame = CFrame.new(pos)
			end
		end)

		btn.MouseButton2Click:Connect(function()
			table.remove(savedPositions, i)
			refreshList()
		end)

		btn.Parent = coordList
	end

	coordList.CanvasSize = UDim2.new(0, 0, 0, #savedPositions * 35)
end

-- 保存按钮逻辑修复
saveBtn.MouseButton1Click:Connect(function()
	local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if hrp then
		local pos = hrp.Position
		table.insert(savedPositions, pos)
		refreshList()
	end
end)
