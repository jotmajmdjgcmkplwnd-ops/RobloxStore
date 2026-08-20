--==================================================
-- STORE ALL IN ONE
-- LocalScript / 自作Robloxゲーム用
--==================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--==================================================
-- CLEAN OLD UI
--==================================================

local old = playerGui:FindFirstChild("StoreUI")
if old then
	old:Destroy()
end

--==================================================
-- SETTINGS
--==================================================

local UI_SCALE = 0.85
local UI_X = 0.50
local UI_Y = 0.50

local FLY_SPEED = 60
local RAGDOLL_ANGLE = 60

local OBJECT_ORBIT_ENABLED = false
local OBJECT_ORBIT_RANGE = 30
local OBJECT_ORBIT_SPEED = 2
local OBJECT_ORBIT_HEIGHT = 8
local OBJECT_ORBIT_TILT = 0

--==================================================
-- PRESET 1
-- 最初から存在するプリセット
-- 永続保存はしない
--==================================================

local PRESET1_FLY = true
local PRESET1_FLY_SPEED = 60
local PRESET1_LOOK = true

-- 自分は初期対象にしない
local preset1LookPlayer = nil

--==================================================
-- STATE
--==================================================

-- 最初からFly ON
local flyEnabled = true

local ragdollEnabled = false
local lookEnabled = false
local thirdPerson = false

local selectedPlayer = player

local flyConnection = nil
local lookConnection = nil
local orbitConnection = nil

local ragdollData = {}

local flyUpHeld = false
local flyDownHeld = false

local orbitObjects = {}
local orbitAngle = 0
local orbitScanTimer = 0

--==================================================
-- COLORS
--==================================================

local C = {
	background = Color3.fromRGB(8,9,13),
	panel = Color3.fromRGB(17,18,24),
	panel2 = Color3.fromRGB(23,24,31),

	white = Color3.fromRGB(245,245,248),
	gray = Color3.fromRGB(160,162,170),

	border = Color3.fromRGB(70,72,82),

	red = Color3.fromRGB(225,75,80),
	green = Color3.fromRGB(80,210,130),
	blue = Color3.fromRGB(90,165,255)
}

--==================================================
-- GUI
--==================================================

local gui = Instance.new("ScreenGui")
gui.Name = "StoreUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

--==================================================
-- HELPERS
--==================================================

local function corner(obj, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius)
	c.Parent = obj
end

local function stroke(obj, color, thickness)
	local s = Instance.new("UIStroke")
	s.Color = color or C.border
	s.Thickness = thickness or 1.5
	s.Parent = obj
	return s
end

local function makeButton(parent, text)
	local b = Instance.new("TextButton")

	b.Size = UDim2.new(1,0,0,58)
	b.BackgroundColor3 = C.panel2
	b.BorderSizePixel = 0

	b.Text = text
	b.Font = Enum.Font.GothamBold
	b.TextSize = 19
	b.TextColor3 = C.white

	b.AutoButtonColor = false
	b.Parent = parent

	corner(b,11)
	stroke(b)

	return b
end

local function setButtonState(b, name, state)
	b.Text = name .. "     " .. (state and "ON" or "OFF")
	b.TextColor3 = state and C.green or C.white
end

local function getCharacter(plr)
	return plr and plr.Character
end

local function getRoot(plr)
	local character = getCharacter(plr)

	if not character then
		return nil
	end

	return character:FindFirstChild("HumanoidRootPart")
end

--==================================================
-- PLAYER ICON
--==================================================

local function getPlayerIcon(plr)
	local success, image = pcall(function()
		return Players:GetUserThumbnailAsync(
			plr.UserId,
			Enum.ThumbnailType.HeadShot,
			Enum.ThumbnailSize.Size100x100
		)
	end)

	if success and image and image ~= "" then
		return image
	end

	return ""
end

--==================================================
-- STORE BUTTON
--==================================================

local store = Instance.new("TextButton")

store.Name = "StoreButton"
store.AnchorPoint = Vector2.new(0,0.5)
store.Position = UDim2.new(0.02,0,0.5,0)
store.Size = UDim2.new(0,150,0,55)

store.BackgroundColor3 = C.panel
store.BorderSizePixel = 0

store.Text = "▣  STORE"
store.Font = Enum.Font.GothamBold
store.TextSize = 20
store.TextColor3 = C.white

store.AutoButtonColor = false
store.ZIndex = 1000
store.Parent = gui

corner(store,14)
stroke(store)

--==================================================
-- MAIN
--==================================================

local main = Instance.new("Frame")

main.Name = "Main"
main.AnchorPoint = Vector2.new(0.5,0.5)
main.Position = UDim2.fromScale(UI_X,UI_Y)
main.Size = UDim2.fromScale(0.82,0.78)

main.BackgroundColor3 = C.background
main.BorderSizePixel 
