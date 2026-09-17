--!strict

-- Place this LocalScript in StarterPlayer > StarterPlayerScripts.

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local espEnabled: boolean = false
local tracked: {[Player]: {billboard: BillboardGui}} = {}

local function createGui(): ()
	local playerGui = LocalPlayer:WaitForChild("PlayerGui")

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "PlayerESPMenu"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui

	local frame = Instance.new("Frame")
	frame.Name = "Menu"
	frame.Size = UDim2.fromOffset(220, 90)
	frame.Position = UDim2.fromOffset(20, 20)
	frame.BackgroundColor3 = Color3.fromRGB(28, 31, 38)
	frame.BorderSizePixel = 0
	frame.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = frame

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -20, 0, 26)
	title.Position = UDim2.fromOffset(10, 8)
	title.BackgroundTransparency = 1
	title.Text = "Player ESP"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextSize = 18
	title.Font = Enum.Font.GothamBold
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = frame

	local toggle = Instance.new("TextButton")
	toggle.Name = "Toggle"
	toggle.Size = UDim2.new(1, -20, 0, 36)
	toggle.Position = UDim2.fromOffset(10, 43)
	toggle.BackgroundColor3 = Color3.fromRGB(170, 55, 55)
	toggle.BorderSizePixel = 0
	toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
	toggle.TextSize = 15
	toggle.Font = Enum.Font.GothamMedium
	toggle.Text = "ESP: OFF"
	toggle.Parent = frame

	local toggleCorner = Instance.new("UICorner")
	toggleCorner.CornerRadius = UDim.new(0, 6)
	toggleCorner.Parent = toggle

	toggle.Activated:Connect(function()
		espEnabled = not espEnabled
		toggle.Text = espEnabled and "ESP: ON" or "ESP: OFF"
		toggle.BackgroundColor3 = espEnabled
			and Color3.fromRGB(45, 155, 85)
			or Color3.fromRGB(170, 55, 55)

		for player, data in pairs(tracked) do
			if data.billboard then
				data.billboard.Enabled = espEnabled
			end
		end
	end)
end

local function removeEsp(player: Player): ()
	local data = tracked[player]
	if data and data.billboard then
		data.billboard:Destroy()
	end
	tracked[player] = nil
end

local function addEsp(player: Player, character: Model): ()
	if player == LocalPlayer then
		return
	end

	removeEsp(player)

	local head = character:WaitForChild("Head", 5)
	local humanoid = character:WaitForChild("Humanoid", 5)
	if not head or not humanoid then
		return
	end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "PlayerESP"
	billboard.Adornee = head
	billboard.Size = UDim2.fromOffset(180, 55)
	billboard.StudsOffset = Vector3.new(0, 3, 0)
	billboard.AlwaysOnTop = true
	billboard.Enabled = espEnabled
	billboard.Parent = head

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, 0, 0, 24)
	nameLabel.BackgroundTransparency = 1
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextStrokeTransparency = 0.35
	nameLabel.TextSize = 16
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.Text = player.DisplayName .. " (" .. player.Name .. ")"
	nameLabel.Parent = billboard

	local healthBack = Instance.new("Frame")
	healthBack.Size = UDim2.new(1, -20, 0, 10)
	healthBack.Position = UDim2.fromOffset(10, 30)
	healthBack.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
	healthBack.BorderSizePixel = 0
	healthBack.Parent = billboard

	local healthBackCorner = Instance.new("UICorner")
	healthBackCorner.CornerRadius = UDim.new(0, 4)
	healthBackCorner.Parent = healthBack

	local healthBar = Instance.new("Frame")
	healthBar.Name = "HealthBar"
	healthBar.Size = UDim2.fromScale(1, 1)
	healthBar.BackgroundColor3 = Color3.fromRGB(55, 205, 90)
	healthBar.BorderSizePixel = 0
	healthBar.Parent = healthBack

	local healthText = Instance.new("TextLabel")
	healthText.Name = "HealthText"
	healthText.Size = UDim2.fromScale(1, 1)
	healthText.BackgroundTransparency = 1
	healthText.TextColor3 = Color3.fromRGB(255, 255, 255)
	healthText.TextStrokeTransparency = 0.25
	healthText.TextSize = 11
	healthText.Font = Enum.Font.GothamBold
	healthText.TextXAlignment = Enum.TextXAlignment.Center
	healthText.TextYAlignment = Enum.TextYAlignment.Center
	healthText.ZIndex = 2
	healthText.Parent = healthBack

	local healthCorner = Instance.new("UICorner")
	healthCorner.CornerRadius = UDim.new(0, 4)
	healthCorner.Parent = healthBar

	local function updateHealth()
		local health: number = math.max(humanoid.Health, 0)
		local maxHealth: number = math.max(humanoid.MaxHealth, 1)
		local ratio: number = math.clamp(health / maxHealth, 0, 1)
		healthBar.Size = UDim2.fromScale(ratio, 1)
		healthText.Text = string.format("%d / %d", math.floor(health + 0.5), math.floor(maxHealth + 0.5))
		healthBar.BackgroundColor3 = Color3.fromRGB(
			255 - math.floor(200 * ratio),
			55 + math.floor(150 * ratio),
			60
		)
	end

	humanoid.HealthChanged:Connect(updateHealth)
	updateHealth()
	tracked[player] = { billboard = billboard }
end

local function trackPlayer(player: Player): ()
	if player == LocalPlayer then
		return
	end

	player.CharacterAdded:Connect(function(character)
		addEsp(player, character)
	end)

	if player.Character then
		addEsp(player, player.Character)
	end
end

createGui()

for _, player in ipairs(Players:GetPlayers()) do
	trackPlayer(player)
end

Players.PlayerAdded:Connect(trackPlayer)
Players.PlayerRemoving:Connect(removeEsp)
