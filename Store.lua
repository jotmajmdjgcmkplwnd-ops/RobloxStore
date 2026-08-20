--==================================================
-- STORE ALL IN ONE
-- LocalScript / 自作Robloxゲーム用
--==================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

--==================================================
-- CLEAN
--==================================================

local old = playerGui:FindFirstChild("StoreUI")
if old then old:Destroy() end

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
-- 最初から存在
-- 保存処理はしない
--==================================================

local PRESET1_FLY = true
local PRESET1_FLY_SPEED = 60
local PRESET1_LOOK = true

-- 自分は初期値にしない
local preset1LookPlayer = nil

--==================================================
-- STATE
--==================================================

local flyEnabled = false
local ragdollEnabled = false
local lookEnabled = false
local thirdPerson = false

local selectedPlayer = player

local flyConnection
local lookConnection
local orbitConnection

local flyVelocity
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
	background = Color3.fromRGB(7,8,12),
	panel = Color3.fromRGB(15,17,23),
	panel2 = Color3.fromRGB(22,24,32),

	white = Color3.fromRGB(245,245,248),
	gray = Color3.fromRGB(155,158,168),

	border = Color3.fromRGB(65,68,80),

	red = Color3.fromRGB(235,65,75),
	green = Color3.fromRGB(75,220,135),
	blue = Color3.fromRGB(85,160,255)
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

local function corner(obj,r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0,r)
	c.Parent = obj
end

local function stroke(obj,color,thickness)
	local s = Instance.new("UIStroke")
	s.Color = color or C.border
	s.Thickness = thickness or 1.5
	s.Transparency = 0
	s.Parent = obj
	return s
end

local function tween(obj,time,props,style,direction)
	local info = TweenInfo.new(
		time or .2,
		style or Enum.EasingStyle.Quart,
		direction or Enum.EasingDirection.Out
	)

	local t = TweenService:Create(obj,info,props)
	t:Play()
	return t
end

local function buttonPress(b)
	local original = b.Size

	tween(
		b,
		0.07,
		{Size = UDim2.new(
			original.X.Scale,
			original.X.Offset-4,
			original.Y.Scale,
			original.Y.Offset-4
		)}
	)

	task.delay(0.07,function()
		if b and b.Parent then
			tween(b,0.12,{Size = original})
		end
	end)
end

local function makeButton(parent,text)
	local b = Instance.new("TextButton")

	b.Size = UDim2.new(1,0,0,58)
	b.BackgroundColor3 = C.panel2
	b.BorderSizePixel = 0
	b.Text = text
	b.Font = Enum.Font.GothamBold
	b.TextSize = 18
	b.TextColor3 = C.white
	b.AutoButtonColor = false
	b.Parent = parent

	corner(b,11)
	stroke(b)

	b.MouseEnter:Connect(function()
		tween(b,0.15,{
			BackgroundColor3 = Color3.fromRGB(34,37,48)
		})
	end)

	b.MouseLeave:Connect(function()
		tween(b,0.15,{
			BackgroundColor3 = C.panel2
		})
	end)

	b.MouseButton1Click:Connect(function()
		buttonPress(b)
	end)

	return b
end

local function setButtonState(b,name,state)
	b.Text = name.."     "..(state and "ON" or "OFF")

	tween(
		b,
		0.18,
		{
			TextColor3 = state and C.green or C.white
		}
	)
end

local function getRoot(plr)
	local c = plr and plr.Character
	return c and c:FindFirstChild("HumanoidRootPart")
end

local function getPlayerIcon(plr)
	local ok,img = pcall(function()
		return Players:GetUserThumbnailAsync(
			plr.UserId,
			Enum.ThumbnailType.HeadShot,
			Enum.ThumbnailSize.Size100x100
		)
	end)

	return ok and img or ""
end

--==================================================
-- STORE BUTTON
--==================================================

local store = Instance.new("TextButton")

store.Name = "StoreButton"
store.AnchorPoint = Vector2.new(0,0.5)
store.Position = UDim2.new(0.02,0,0.5,0)
store.Size = UDim2.new(0,155,0,58)

store.BackgroundColor3 = C.panel
store.BorderSize
