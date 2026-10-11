--[[
 12Hub — Full Menu
 Tab 1 Player: Speed 3-mode first + player controls
 + Tool Aimbot + Drop Jump/Stand + Insta Reset V1/V2 + TP Down / TP Best keybinds
 Tab 2 ESP: Player ESP + Tracker + Anti Lag + Nuke Optimize + Trap/Subspace ESP
 Tab 3 Settings: mobile action buttons, shape, reset
 Close menu: nút − | Open: mini kéo được | NO keybind to open/close
]]

repeat task.wait() until game:IsLoaded()
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local RS = game:GetService("RunService")
local RunService = RS
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local LP = Players.LocalPlayer
if not LP then
	repeat task.wait() until Players.LocalPlayer
	LP = Players.LocalPlayer
end
local PlayerGui = LP:WaitForChild("PlayerGui", 30) or LP:FindFirstChild("PlayerGui") or game:GetService("CoreGui")

pcall(function()
	for _, n in ipairs({
 "Rana.VSHubFullMenu", "Rana.VSHubFullMini", "Rana.VS_LaPeakMenu", "Rana.VSHybridMenu", "Rana.VSHybridGui", "Rana.VSIntro", "Rana.VSHubIntro",
	}) do
 local g = PlayerGui:FindFirstChild(n)
 if g then g:Destroy() end
	end
	local CoreGui = game:GetService("CoreGui")
	for _, n in ipairs({"12Hub_AllGearOnTop", "ZenoneTop_AnimeUI"}) do
		local g = CoreGui:FindFirstChild(n)
		if g then g:Destroy() end
	end
end)

----------------------------------------------------------------
-- COLORS / STATE
----------------------------------------------------------------
local C = {
	-- Empire-style palette
	bg = Color3.fromRGB(12, 12, 16), bg2 = Color3.fromRGB(18, 18, 24),
	card = Color3.fromRGB(24, 24, 32), stroke = Color3.fromRGB(60, 60, 80),
	accent = Color3.fromRGB(255, 20, 147), text = Color3.fromRGB(255, 255, 255),
	textDim = Color3.fromRGB(160, 160, 180), on = Color3.fromRGB(60, 220, 110),
	off = Color3.fromRGB(40, 40, 52), box = Color3.fromRGB(32, 32, 44),
	danger = Color3.fromRGB(220, 70, 90),
	modeOnBg = Color3.fromRGB(255, 20, 147), modeOnTxt = Color3.fromRGB(255, 255, 255),
	modeOffBg = Color3.fromRGB(255, 255, 255), modeOffTxt = Color3.fromRGB(25, 25, 30),
	btnOn = Color3.fromRGB(50, 210, 100), -- xanh khi ON (Empire style)
	btnOff = Color3.fromRGB(16, 16, 22),
}


local St = {
	antiGummy = true, antiBee = false, antiRagdoll = false, antiPaint = true, antiBoogie = true,
	antiTrap = false, antiTrapGear = "Cupid's Wings",
	-- Trap ESP / Anti-Trap extensions
	trapESP = false, trapDistanceESP = true, trapOutlineESP = true, subspaceESP = true,
	antiTrapZeroM = false, trapScanRange = 250,
	toolAim = true, speedOn = true, infJump = true,
	activeMode = "Normal",
	modes = {
 Normal = { norm = 60, steal = 30 },
 Lagger = { norm = 40, steal = 24 },
 Custom = { norm = 47, steal = 22 },
	},
	dropMode = 2, -- 1 Stand/Fling, 2 Jump
	instaMode = "V1",
	mobileBtns = true, guiLock = false, -- default ON: Drop / Insta / TP buttons
	showStealBtn = true, -- mobile action visibility
	medOn = false, psOn = false,
	btnShape = "FOUNDED", -- FOUNDED | CIRCLE | SQUARE
	btnScale = 0.75,
	menuScale = 0.8,
	btnSizes = { drop = 70, insta = 70, tp = 70, tpBest = 70, sentry = 70, steal = 70, med = 70, ps = 70, antiTrap = 70, websinger = 70 },
	keys = {
 Drop = Enum.KeyCode.X,
 TPDown = Enum.KeyCode.F,
 InstaReset = Enum.KeyCode.Z,
 DestroySentry = Enum.KeyCode.H,
 AutoSteal = nil,
 TpBest = Enum.KeyCode.B,
 MedEquip = Enum.KeyCode.M,
 AntiTrap = Enum.KeyCode.N,
		Websinger = Enum.KeyCode.G,
	},
	speedKeys = { Normal = Enum.KeyCode.T, Lagger = Enum.KeyCode.E, Custom = Enum.KeyCode.F },
	esp = false, tracer = false, antiLag = false, nukeOptimiserEnabled = false,
	antiKick = true, wallOpacity = 0.12, speedMethod = "Velocity",
	destroySentry = false,
	spamLaser = false, spamPaint = false,
	counterLaser = false, counterBoogie = false, counterSwapBody = false,
	equipOnDrop = false,
}
local ToggleRefs = {} -- để Reset All cập nhật UI

-- Legacy menu handles kept only as nil compatibility references.
local Main = nil
local Mini = nil
local MiniGui = nil
local applyMenuScale = function() end
local setTab = function() end
local pageSpeed, pagePlayer, pageVis, pageSpam, pageCounter, pageSet, pageKeys = nil,nil,nil,nil,nil,nil,nil

local CFG = "12HubOntop.json"
local _saveToken = 0
function autoSaveDebounced()
	_saveToken = _saveToken + 1
	local t = _saveToken
	task.delay(0.35, function()
 if t == _saveToken then pcall(saveCfg) end
	end)
end
function _serializeValue(v, depth)
	depth = depth or 0
	if depth > 6 then return nil end
	local t = typeof(v)
	if t == "number" or t == "string" or t == "boolean" then
 return v
	elseif t == "EnumItem" then
 return v.Name
	elseif t == "table" then
 local out = {}
 for k2, v2 in pairs(v) do
 local kt = type(k2)
 if kt == "string" or kt == "number" then
 local sv = _serializeValue(v2, depth + 1)
 if sv ~= nil then out[k2] = sv end
 end
 end
 return out
	end
	return nil
end
function saveCfg()
	local d = {}
	-- dump TOÀN BỘ St (mọi key có thể JSON được)
	for k, v in pairs(St) do
 if type(k) == "string" then
 -- không lưu base/pet TP — chỉ nhớ vị trí panel
 if k == "_saveBase" or k == "_savePet" or k == "saveBase" or k == "savePet"
 or k == "_delayBase" or k == "_delayPet" then
 -- skip
 elseif k == "modes" or k == "keys" or k == "speedKeys" then
 -- skip, handle below
 else
 local sv = _serializeValue(v)
 if sv ~= nil then d[k] = sv end
 end
 end
	end
	d.modes = {}
	for k, m in pairs(St.modes or {}) do
 if type(m) == "table" then
 d.modes[k] = {
 norm = tonumber(m.norm) or 16,
 steal = tonumber(m.steal) or 16,
 }
 end
	end
	d.keys = {}
	for k, v in pairs(St.keys or {}) do
 d.keys[k] = (typeof(v) == "EnumItem" and v.Name) or tostring(v)
	end
	d.speedKeys = {}
	for k, v in pairs(St.speedKeys or {}) do
		d.speedKeys[k] = (typeof(v) == "EnumItem" and v.Name) or tostring(v)
	end
	local ok, err = pcall(function()
 if not writefile then error("no writefile") end
 d._saveBase = nil
	d._savePet = nil
	d.saveBase = nil
	d.savePet = nil
	d._delayBase = nil
	d._delayPet = nil
	writefile(CFG, HttpService:JSONEncode(d))
	end)
	if not ok then
 warn("[12Hub] saveCfg fail:", err)
	end
	return ok
end
function loadCfg()
	local ok, data = pcall(function()
 if isfile and readfile then
 if isfile(CFG) then
 return HttpService:JSONDecode(readfile(CFG))
 end
 for _, old in ipairs({"Rana.VSAllgear.json", "RaraOnflop.json", "Rana.VSHub_FullMenu_v1.json", "Rana.VSHub_Config.json", "Rana.VS.json"}) do
 if isfile(old) then
 local d = HttpService:JSONDecode(readfile(old))
 pcall(function() writefile(CFG, HttpService:JSONEncode(d)) end)
 return d
 end
 end
 end
	end)
	if not (ok and type(data) == "table") then return false end
	for k, v in pairs(data) do
 if type(k) == "string" and k ~= "modes" and k ~= "keys" then
 St[k] = v
 end
	end
	if type(data.modes) == "table" then
 for k, m in pairs(data.modes) do
 if type(m) == "table" then
 St.modes[k] = St.modes[k] or { norm = 59, steal = 30 }
 St.modes[k].norm = tonumber(m.norm) or St.modes[k].norm
 St.modes[k].steal = tonumber(m.steal) or St.modes[k].steal
 end
 end
	end
	if type(data.keys) == "table" then
 St.keys = St.keys or {}
 for k, name in pairs(data.keys) do
  local keyName = tostring(name)
  if keyName == "None" then
   St.keys[k] = "None"
  else
   pcall(function()
    local keyCode = Enum.KeyCode[keyName]
    if keyCode then St.keys[k] = keyCode end
   end)
  end
 end
	end
	if type(data.speedKeys) == "table" then
		St.speedKeys = St.speedKeys or {}
		for k, name in pairs(data.speedKeys) do
   local keyName = tostring(name)
   if keyName == "None" then
    St.speedKeys[k] = "None"
   else
    pcall(function()
     local keyCode = Enum.KeyCode[keyName]
     if keyCode then St.speedKeys[k] = keyCode end
    end)
   end
		end
	end
	if type(data.btnSizes) == "table" then
 St.btnSizes = data.btnSizes
 for k,v in pairs(St.btnSizes) do
 St.btnSizes[k] = math.clamp(tonumber(v) or 70, 20, 200)
 end
 -- Migrate the previous built-in mobile-button default (50) to the new default 70.
 for _, k in ipairs({"drop","insta","tp","tpBest","sentry","steal","med","ps","antiTrap","websinger"}) do
  if tonumber(St.btnSizes[k]) == 50 then St.btnSizes[k] = 70 end
 end
	end
 St.btnSizes = St.btnSizes or {}
 for _, k in ipairs({"drop","insta","tp","tpBest","sentry","steal","med","ps","antiTrap","websinger"}) do
  St.btnSizes[k] = math.clamp(tonumber(St.btnSizes[k]) or 70, 20, 200)
 end
	if type(data._btnPos) == "table" then St._btnPos = data._btnPos end
	St.stealRadius = tonumber(St.stealRadius) or 60
	if St.stealVer == "V1" or St.stealVer == "V2" then St.stealVer = "Normal-" .. St.stealVer end
	if St.stealVer ~= "Normal-V1" and St.stealVer ~= "Normal-V2" and St.stealVer ~= "Semi-V1" and St.stealVer ~= "Semi-V2" then St.stealVer = "Normal-V2" end
	if St.btnShape == "Round" then St.btnShape = "CIRCLE" elseif St.btnShape == "Box" then St.btnShape = "FOUNDED" elseif St.btnShape == "Square" then St.btnShape = "SQUARE" end
	if St.btnShape ~= "FOUNDED" and St.btnShape ~= "CIRCLE" and St.btnShape ~= "SQUARE" then St.btnShape = "FOUNDED" end
	local savedMode, savedVersion = tostring(St.stealVer):match("^(Normal|Semi)%-(V[12])$")
	selectedStealMode = savedMode or "Normal"
	autoStealV2Version = savedVersion or "V2"
	if type(St.modes) == "table" then
		if St.modes.Normal and tonumber(St.modes.Normal.norm) == 59 then St.modes.Normal.norm = 60 end
		if St.modes.Lagger and tonumber(St.modes.Lagger.norm) == 18 then St.modes.Lagger.norm = 40 end
		if St.modes.Custom and tonumber(St.modes.Custom.norm) == 33 then St.modes.Custom.norm = 47 end
		if St.modes.Custom and tonumber(St.modes.Custom.steal) == 33 then St.modes.Custom.steal = 22 end
	end
	St.stealBarScale = tonumber(St.stealBarScale) or 1
	if St.showStealBtn == nil then St.showStealBtn = true end
	autoStealRadius = St.stealRadius
	return true
end
local _menuScaleConfigLoaded = loadCfg()
-- Menu scale defaults to 80%; migrate the old built-in 100% default only once.
do
    local loadedMenuScale = tonumber(St.menuScale)
    if St._menuScaleDefaultMigrated ~= true then
        if not loadedMenuScale or math.abs(loadedMenuScale - 1.0) < 0.0001 then
            loadedMenuScale = 0.8
        end
        St._menuScaleDefaultMigrated = true
    end
    St.menuScale = math.clamp(loadedMenuScale or 0.8, 0.5, 1.3)
    if _menuScaleConfigLoaded then pcall(saveCfg) end
end
if St.instaMode ~= "V1" and St.instaMode ~= "V2" then St.instaMode = "V1" end
-- Trap/anti-trap defaults are applied after config load so older configs migrate cleanly.
St.antiTrapGear = tostring(St.antiTrapGear or "Cupid's Wings")
St.trapESP = St.trapESP == true
St.trapDistanceESP = St.trapDistanceESP ~= false
St.trapOutlineESP = St.trapOutlineESP ~= false
St.subspaceESP = St.subspaceESP ~= false
-- Auto Equip Trap 0M shares the Anti Trap master toggle; do not restore a stale ON state.
St.antiTrapZeroM = St.antiTrap == true
St.trapScanRange = math.clamp(tonumber(St.trapScanRange) or 250, 10, 1000)
St.nukeOptimiserEnabled = St.nukeOptimiserEnabled == true
-- Legacy 3-mode GUI size values are ignored; the speed buttons use a fixed size.
St.speedModeSizes = nil
St.speedModeScale = nil
-- One-time migration for the requested mobile PS / MED layout:
-- both stay directly above the first two action buttons (DROP / INSTA).
do
    if St._mobilePSMedLayoutV1 ~= true then
        St._btnPos = St._btnPos or {}
        St._btnPos.A_ps = nil
        St._btnPos.A_med = nil
        St._mobilePSMedLayoutV1 = true
        pcall(saveCfg)
    end
end

-- Body Lock has been removed completely. Strip any keys from older configs.
St.bodyLock = nil
St.bodyLockRange = nil

local _RanaPersistedStealVer = tostring(St.stealVer or "Normal-V2")
local _savedStealMode, _savedStealVersion = _RanaPersistedStealVer:match("^(Normal|Semi)%-(V[12])$")
selectedStealMode = _savedStealMode or ((tostring(selectedStealMode or "Normal") == "Semi") and "Semi" or "Normal")
autoStealV2Version = _savedStealVersion or "V2"
selectedNormalMode = (selectedStealMode == "Normal" and autoStealV2Version) or "V2"
selectedSemiMode = (selectedStealMode == "Semi" and autoStealV2Version) or "V2"
St.stealVer = selectedStealMode .. "-" .. autoStealV2Version
task.spawn(function()
	while true do
 task.wait(3)
 local ok, err = pcall(saveCfg)
 if not ok then warn("[12Hub] autosave 3s fail:", err) end
	end
end)

----------------------------------------------------------------
----------------------------------------------------------------
-- SPEED LOOP — full Bubble velocity loop adapted to La Peak state
-- Replaces the old multi-method speed block with direct AssemblyLinearVelocity control.
----------------------------------------------------------------
local speedConnection = nil
local currentSpeedValue = 16

local _spd = _spd or {
    root = nil,
    velChecked = setmetatable({}, {__mode = "k"}),
    hooked = false,
    lastMoveDir = Vector3.zero,
}

local MOVE_KEYS = {
    [Enum.KeyCode.W] = true, [Enum.KeyCode.A] = true, [Enum.KeyCode.S] = true, [Enum.KeyCode.D] = true,
    [Enum.KeyCode.Up] = true, [Enum.KeyCode.Down] = true, [Enum.KeyCode.Left] = true, [Enum.KeyCode.Right] = true,
}

function getCharParts()
    local char = LP.Character
    if not char then return nil, nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return nil, nil end
    return hum, root
end

function isCarryingBrainrot(char)
    if not char then return false end
    local ok, st = pcall(function() return LP:GetAttribute("Stealing") end)
    if ok and st == true then return true end
    local ok2, st2 = pcall(function() return char:GetAttribute("Stealing") end)
    if ok2 and st2 == true then return true end
    for _, v in ipairs(char:GetChildren()) do
        if v:IsA("Tool") or v:IsA("Model") or v:IsA("Folder") then
            local n = string.lower(tostring(v.Name))
            if n:find("brainrot", 1, true) or n:find("carriedbrain", 1, true) then
                return true
            end
        end
    end
    return false
end

function getActiveMoveSpeed()
    local mode = St.activeMode
    if not mode or not St.modes[mode] then
        mode = "Normal"
        St.activeMode = "Normal"
    end
    local m = St.modes[mode] or {norm = 59, steal = 30}
    local norm = math.clamp(tonumber(m.norm) or 59, 1, 200)
    local steal = math.clamp(tonumber(m.steal) or 30, 1, 200)
    if isCarryingBrainrot(LP.Character) then
        return steal
    end
    return norm
end

local function _setupSpeedRoot(char)
    _spd.velChecked = setmetatable({}, {__mode = "k"})
    if not char then
        _spd.root = nil
        return nil
    end
    local hrp = char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart", 5)
    if hrp then
        _spd.root = hrp
        _spd.velChecked[hrp] = true
    end
    return hrp
end

local function _hookSpeedVelocityRead(hrp)
    if hrp then
        _spd.root = hrp
        _spd.velChecked[hrp] = true
    end
    if _spd.hooked then return end
    if type(getrawmetatable) ~= "function" or type(setreadonly) ~= "function" or type(newcclosure) ~= "function" or type(checkcaller) ~= "function" then
        return
    end
    pcall(function()
        local mt = getrawmetatable(game)
        if not mt then return end
        local originalIndex = rawget(mt, "__index")
        if type(originalIndex) ~= "function" and type(originalIndex) ~= "table" then return end
        local replacementIndex = newcclosure(function(obj, key)
            local value = if type(originalIndex) == "function" then originalIndex(obj, key) else originalIndex[key]
            if not checkcaller() and _spd.velChecked[obj] and (key == "AssemblyLinearVelocity" or key == "Velocity") and typeof(value) == "Vector3" and value.Magnitude > 20 then
                return value.Unit * 20
            end
            return value
        end)
        setreadonly(mt, false)
        mt.__index = replacementIndex
        _spd.hooked = true
        setreadonly(mt, true)
    end)
end

local function _resetSpeedDirection()
    _spd.lastMoveDir = Vector3.zero
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hum and hrp and hum.MoveDirection.Magnitude <= 0.05 then
        local v = hrp.AssemblyLinearVelocity
        hrp.AssemblyLinearVelocity = Vector3.new(0, v.Y, 0)
    end
end
_G.__BubbleResetSpeedDirection = _resetSpeedDirection

local function _isSpeedRagdoll(hum)
    if not hum then return true end
    local st = hum:GetState()
    return hum.PlatformStand
        or st == Enum.HumanoidStateType.Physics
        or st == Enum.HumanoidStateType.Ragdoll
        or st == Enum.HumanoidStateType.FallingDown
end

local function _applyBubbleVelocitySpeed(dir, speed)
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp or hum.Health <= 0 then return end
    if type(speed) ~= "number" or speed ~= speed or speed <= 0 or speed == math.huge then return end

    local verticalVelocity = hrp.AssemblyLinearVelocity.Y
    if _G._ZurichHub_MovementBlocked == true or _G._BubbleHub_MovementBlocked == true then
        hrp.AssemblyLinearVelocity = Vector3.new(0, math.min(verticalVelocity, 0), 0)
        return
    end

    if dir and dir.Magnitude > 0.05 then
        pcall(function()
            if hrp.SetNetworkOwner then hrp:SetNetworkOwner(LP) end
        end)
        local unit = dir.Unit
        hrp.AssemblyLinearVelocity = Vector3.new(unit.X * speed, verticalVelocity, unit.Z * speed)
    else
        hrp.AssemblyLinearVelocity = Vector3.new(0, verticalVelocity, 0)
    end
end

local function _stopBubbleSpeedLoop()
    if speedConnection then
        pcall(function() speedConnection:Disconnect() end)
        speedConnection = nil
    end
    if _G.__speedBoostConn then
        pcall(function() _G.__speedBoostConn:Disconnect() end)
        _G.__speedBoostConn = nil
    end
    _resetSpeedDirection()
end

local function _startBubbleSpeedLoop()
    _stopBubbleSpeedLoop()
    if not St.speedOn then return end

    currentSpeedValue = getActiveMoveSpeed()
    local char = LP.Character
    if char then
        _hookSpeedVelocityRead(_setupSpeedRoot(char))
    end

    speedConnection = RS.RenderStepped:Connect(function()
        if not St.speedOn then return end

        local charNow = LP.Character
        local hum = charNow and charNow:FindFirstChildOfClass("Humanoid")
        local hrp = charNow and charNow:FindFirstChild("HumanoidRootPart")
        if not hum or not hrp or hum.Health <= 0 then return end

        if _G.dropActive or _G.IsDropping then
            _resetSpeedDirection()
            return
        end

        if _isSpeedRagdoll(hum) then
            _spd.lastMoveDir = Vector3.zero
            return
        end

        if _spd.root ~= hrp or not _spd.velChecked[hrp] then
            _spd.lastMoveDir = Vector3.zero
            _hookSpeedVelocityRead(_setupSpeedRoot(charNow))
        end

        local dir
        if hum.MoveDirection.Magnitude > 0 then
            _spd.lastMoveDir = hum.MoveDirection
            dir = hum.MoveDirection
        elseif _spd.lastMoveDir.Magnitude > 0 then
            local held = false
            for key in pairs(MOVE_KEYS) do
                if UIS:IsKeyDown(key) then
                    held = true
                    break
                end
            end
            if held then
                dir = _spd.lastMoveDir
            end
        end

        local spd = getActiveMoveSpeed()
        currentSpeedValue = spd
        _applyBubbleVelocitySpeed(dir, spd)
    end)
    _G.__speedBoostConn = speedConnection
end

function stopSpeedBoost()
    _stopBubbleSpeedLoop()
end

function startSpeedBoost()
    _startBubbleSpeedLoop()
end

function setSpeedOn(on)
    St.speedOn = on and true or false
    if St.speedOn then
        _startBubbleSpeedLoop()
    else
        _stopBubbleSpeedLoop()
    end
    saveCfg()
end

function setActiveMode(mode)
    if not St.modes[mode] then return end
    St.activeMode = mode
    currentSpeedValue = getActiveMoveSpeed()
    if St.speedOn then
        _startBubbleSpeedLoop()
    end
    if _G.RanaVSRefreshModeBar then pcall(_G.RanaVSRefreshModeBar) end
    if _G.RanaVSRefreshV2ModeBar then pcall(_G.RanaVSRefreshV2ModeBar) end
    if _G.RanaVSRefreshModeCards then pcall(_G.RanaVSRefreshModeCards) end
    if _G.RanaVSRefreshSpeedTab then pcall(_G.RanaVSRefreshSpeedTab) end
    pcall(saveCfg)
end

-- INFINITE JUMP — FULL EMPIRE (hold + manual 2 mode)
----------------------------------------------------------------
InfJumpState = { enabled = false, mode = "hold", jumpHeld = false }
local _holdInfJumpConn = nil

function stopHoldInfJump()
	if _holdInfJumpConn then
 pcall(function() _holdInfJumpConn:Disconnect() end)
 _holdInfJumpConn = nil
	end
end

function startHoldInfJump()
	stopHoldInfJump()
	-- FULL Empire hold infinite jump (Velocity)
	_holdInfJumpConn = RS.Heartbeat:Connect(function()
 if not InfJumpState.enabled then return end
 local char = LP.Character
 if not char then return end
 local root = char:FindFirstChild("HumanoidRootPart")
 local hum = char:FindFirstChildOfClass("Humanoid")
 if not root or not hum then return end
 local isJumpHeld = UIS:IsKeyDown(Enum.KeyCode.Space) or (hum.Jump == true) or (InfJumpState.jumpHeld == true)
 local vel = root.Velocity
 pcall(function()
 local av = root.AssemblyLinearVelocity
 if av then vel = av end
 end)
 if isJumpHeld and vel.Y < 35 then
 local nv = Vector3.new(vel.X, 55, vel.Z)
 pcall(function() root.Velocity = nv end)
 pcall(function() root.AssemblyLinearVelocity = nv end)
 end
 if vel.Y < -120 then
 local nv = Vector3.new(vel.X, -120, vel.Z)
 pcall(function() root.Velocity = nv end)
 pcall(function() root.AssemblyLinearVelocity = nv end)
 end
	end)
end

function startInfJump()
	InfJumpState.enabled = true
	InfJumpState.mode = St.infJumpMode or "hold"
	startHoldInfJump()
end

function stopInfJump()
	InfJumpState.enabled = false
	InfJumpState.jumpHeld = false
	stopHoldInfJump()
end

function setInfJump(on)
	St.infJump = on and true or false
	if St.infJump then startInfJump() else stopInfJump() end
	saveCfg()
end

function setInfJumpMode(mode)
	-- "hold" | "manual" — Empire dùng cùng loop; manual chỉ pulse jumpHeld
	St.infJumpMode = mode
	InfJumpState.mode = mode
	if St.infJump then startInfJump() end
	saveCfg()
end

-- Mobile JumpButton + Space (Empire)
if not _G._VisEmpireJumpHook then
	_G._VisEmpireJumpHook = true
	task.spawn(function()
 local pg = LP:WaitForChild("PlayerGui", 15)
 if not pg then return end
 local function hookJumpButton(btn)
 if btn:IsA("GuiButton") and btn.Name == "JumpButton" and not btn:GetAttribute("Rana.VSInfJumpHooked") then
 btn:SetAttribute("Rana.VSInfJumpHooked", true)
 btn.MouseButton1Down:Connect(function()
 if InfJumpState.enabled then InfJumpState.jumpHeld = true end
 end)
 btn.MouseButton1Up:Connect(function()
 InfJumpState.jumpHeld = false
 end)
 end
 end
 for _, d in ipairs(pg:GetDescendants()) do hookJumpButton(d) end
 pg.DescendantAdded:Connect(hookJumpButton)
	end)
	UIS.JumpRequest:Connect(function()
 if not InfJumpState.enabled then return end
 if InfJumpState.mode == "manual" then
 InfJumpState.jumpHeld = true
 task.defer(function() InfJumpState.jumpHeld = false end)
 end
	end)
	UIS.InputEnded:Connect(function(inp)
 if inp.KeyCode == Enum.KeyCode.Space then
 InfJumpState.jumpHeld = false
 end
	end)
end


-- ANTI KICK (Empire full) — LUÔN BẬT, không bao giờ OFF
----------------------------------------------------------------
local AntiKickState = { enabled = true, brainrotDetected = false, conn = nil }
function enableAntiKick()
	AntiKickState.enabled = true
	St.antiKick = true
	-- namecall Kick shield (executor)
	pcall(function()
 if hookmetamethod and not _G._FAGAntiKickHooked then
 _G._FAGAntiKickHooked = true
 local old
 old = hookmetamethod(game, "__namecall", function(self, ...)
 local method = (getnamecallmethod and getnamecallmethod()) or ""
 if tostring(method) == "Kick" then
 if self == LP or (typeof(self) == "Instance" and self:IsA("Player") and self == LP) then
 return -- block LocalPlayer:Kick
 end
 end
 return old(self, ...)
 end)
 end
	end)
	-- block Players.LocalPlayer:Kick via hookfunction if available
	pcall(function()
 if hookfunction and not _G._FAGKickFnHooked then
 _G._FAGKickFnHooked = true
 local oldKick = LP.Kick
 if typeof(oldKick) == "function" then
 hookfunction(oldKick, function(self, ...)
 return -- never kick self
 end)
 end
 end
	end)
	if AntiKickState.conn then return end
	AntiKickState.conn = task.spawn(function()
 while true do -- forever
 AntiKickState.enabled = true
 St.antiKick = true
 task.wait(0.5)
 local char = LP.Character
 local found = false
 if char then
 for _, tool in ipairs(char:GetChildren()) do
 if tool:IsA("Tool") then
 local n = tool.Name:lower()
 if n:find("brainrot") or n:find("skibidi") or n:find("toilet") then
 found = true
 break
 end
 end
 end
 end
 AntiKickState.brainrotDetected = found
 end
	end)
end
function disableAntiKick()
	-- KHÔNG BAO GIỜ TẮT — bỏ qua
	enableAntiKick()
end
function setAntiKick(on)
	enableAntiKick()
	saveCfg()
end
task.defer(enableAntiKick)



-- VX7 Anti Ragdoll V1 / V2 FULL CORE
-- Replaced the previous La Peak Anti Ragdoll implementation.
St.antiRagdollMode = (St.antiRagdollMode == "V2") and "V2" or "V1"
_G.__LaPeakVX7AR = _G.__LaPeakVX7AR or {
    conn = nil,
    character = nil,
    humanoid = nil,
    root = nil,
    lastFalling = nil,
}

local function _vx7ARCacheCharacter()
    local char = LP.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not char or not hum or not root then
        return false
    end
    local S = _G.__LaPeakVX7AR
    S.character, S.humanoid, S.root = char, hum, root
    pcall(function()
        if workspace.CurrentCamera then
            workspace.CurrentCamera.CameraSubject = hum
        end
    end)
    return true
end

local function _vx7ARIsRagdolled()
    local S = _G.__LaPeakVX7AR
    local hum = S.humanoid
    if not hum or not hum.Parent then
        return false
    end
    local state = hum:GetState()
    if state == Enum.HumanoidStateType.Physics
        or state == Enum.HumanoidStateType.Ragdoll
        or hum.PlatformStand then
        S.lastFalling = nil
        return true
    end
    if state == Enum.HumanoidStateType.FallingDown then
        S.lastFalling = S.lastFalling or os.clock()
        return os.clock() - S.lastFalling >= 0.18
    end
    S.lastFalling = nil
    local et = LP:GetAttribute("RagdollEndTime")
    return et ~= nil and (et - workspace:GetServerTimeNow()) > 0
end

local function _vx7ARRemoveConstraints()
    local char = _G.__LaPeakVX7AR.character
    if not char then return end
    for _, descendant in ipairs(char:GetDescendants()) do
        if descendant:IsA("BallSocketConstraint")
            or (descendant:IsA("Attachment") and descendant.Name:find("RagdollAttachment")) then
            pcall(function() descendant:Destroy() end)
        end
    end
end

local function _vx7ARForceExit()
    local S = _G.__LaPeakVX7AR
    local hum, root = S.humanoid, S.root
    if not hum or not root or not hum.Parent or not root.Parent then return end
    local batTpEnabled = false
    pcall(function()
        batTpEnabled = Config and (Config.batTpEnabled or Config._smartBatTpDriving) or false
    end)
    pcall(function()
        LP:SetAttribute("RagdollEndTime", workspace:GetServerTimeNow())
    end)
    if hum.Health > 0 then
        pcall(function() hum:ChangeState(Enum.HumanoidStateType.Running) end)
    end
    root.Anchored = false
    if not batTpEnabled then
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        if Config and Config._vxSyncSpoof then
            pcall(Config._vxSyncSpoof, Vector3.zero)
        end
    end
    if not batTpEnabled and not (Config and Config.batAimbotToggled) then
        pcall(function()
            root.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, math.rad(root.Orientation.Y), 0)
        end)
    end
    pcall(function()
        if workspace.CurrentCamera then workspace.CurrentCamera.CameraSubject = hum end
    end)
end

local function _vx7ARRecoverV2()
    local S = _G.__LaPeakVX7AR
    local char, hum, root = S.character, S.humanoid, S.root
    if not char or not hum or not root then return end
    pcall(function()
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        root.Velocity = Vector3.zero
        root.RotVelocity = Vector3.zero
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        for _, descendant in ipairs(char:GetDescendants()) do
            if descendant:IsA("Motor6D") or descendant:IsA("Constraint") then
                descendant.Enabled = true
            end
        end
        if workspace.CurrentCamera then workspace.CurrentCamera.CameraSubject = hum end
        local playerScripts = LP:FindFirstChild("PlayerScripts")
        local playerModule = playerScripts and playerScripts:FindFirstChild("PlayerModule")
        local controlModule = playerModule and playerModule:FindFirstChild("ControlModule")
        if controlModule then
            local ok, module = pcall(require, controlModule)
            if ok and module and module.Enable then pcall(module.Enable, module) end
        end
        hum.AutoRotate = true
        hum.PlatformStand = false
        hum.Sit = false
    end)
end

local function _vx7ARStartV1()
    local S = _G.__LaPeakVX7AR
    if S.conn and S.conn.Connected then return end
    if S.conn then pcall(function() S.conn:Disconnect() end); S.conn = nil end
    if not _vx7ARCacheCharacter() then return end
    S.conn = RS.RenderStepped:Connect(function()
        if not St.antiRagdoll or St.antiRagdollMode ~= "V1" then return end
        if Config and Config._instaResetInProgress then return end
        if not S.humanoid or not S.humanoid.Parent or not S.root or not S.root.Parent then
            _vx7ARCacheCharacter()
            return
        end
        if _vx7ARIsRagdolled() then
            _vx7ARRemoveConstraints()
            _vx7ARForceExit()
        end
    end)
end

local function _vx7ARStartV2()
    local S = _G.__LaPeakVX7AR
    if S.conn and S.conn.Connected then return end
    if S.conn then pcall(function() S.conn:Disconnect() end); S.conn = nil end
    if not _vx7ARCacheCharacter() then return end
    S.conn = RS.Heartbeat:Connect(function()
        if not St.antiRagdoll or St.antiRagdollMode ~= "V2" then return end
        if Config and Config._instaResetInProgress then return end
        local char = LP.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        if not hum or not root or hum.Health <= 0 then return end
        if _G.dropActive then return end
        local state = hum:GetState()
        if state == Enum.HumanoidStateType.Physics
            or state == Enum.HumanoidStateType.Ragdoll
            or state == Enum.HumanoidStateType.FallingDown then
            local now = os.clock()
            local S2 = _G.__LaPeakVX7AR
            if state ~= Enum.HumanoidStateType.FallingDown or now - (S2.lastFalling or now) >= 0.15 then
                S2.lastFalling = now
                pcall(function()
                    hum:ChangeState(Enum.HumanoidStateType.GettingUp)
                    root.Velocity = Vector3.zero
                    root.RotVelocity = Vector3.zero
                    root.AssemblyLinearVelocity = Vector3.zero
                    root.AssemblyAngularVelocity = Vector3.zero
                    for _, descendant in ipairs(char:GetDescendants()) do
                        if descendant:IsA("Motor6D") or descendant:IsA("Constraint") then
                            descendant.Enabled = true
                        end
                    end
                    if workspace.CurrentCamera then workspace.CurrentCamera.CameraSubject = hum end
                    local playerScripts = LP:FindFirstChild("PlayerScripts")
                    local playerModule = playerScripts and playerScripts:FindFirstChild("PlayerModule")
                    local controlModule = playerModule and playerModule:FindFirstChild("ControlModule")
                    if controlModule then
                        local ok, module = pcall(require, controlModule)
                        if ok and module and module.Enable then pcall(module.Enable, module) end
                    end
                    hum.AutoRotate = true
                    hum.PlatformStand = false
                    hum.Sit = false
                end)
            end
        end
    end)
end

local function startAntiRagdoll()
    St.antiRagdoll = true
    local S = _G.__LaPeakVX7AR
    if S.conn then pcall(function() S.conn:Disconnect() end); S.conn = nil end
    if St.antiRagdollMode == "V2" then
        _vx7ARStartV2()
    else
        _vx7ARStartV1()
    end
end

local function stopAntiRagdoll()
    St.antiRagdoll = false
    local S = _G.__LaPeakVX7AR
    if S.conn then pcall(function() S.conn:Disconnect() end); S.conn = nil end
    S.character, S.humanoid, S.root, S.lastFalling = nil, nil, nil, nil
end


function setAntiRagdollMode(mode)
    mode = tostring(mode or "V1"):upper()
    St.antiRagdollMode = (mode == "V2") and "V2" or "V1"
    if St.antiRagdoll then
        pcall(stopAntiRagdoll)
        pcall(startAntiRagdoll)
    end
    pcall(function() if _G.RanaVSRefreshAntiRagMode then _G.RanaVSRefreshAntiRagMode() end end)
    pcall(saveCfg)
end
_G.RanaVSSetAntiRagdollMode = setAntiRagdollMode

local function setAntiRagdoll(on)
    St.antiRagdoll = on == true
    if St.antiRagdoll then startAntiRagdoll() else stopAntiRagdoll() end
    if type(saveCfg) == "function" then
        task.defer(function() pcall(saveCfg) end)
    end
end

-- Keep Anti Ragdoll alive across respawns and transient runtime disconnects.
local _adaptAntiRagdollCharacterConn
local _adaptAntiRagdollWatchdogStarted = false
local function _adaptAntiRagdollRuntimeAlive()
    if not St.antiRagdoll then return true end
    local S = _G.__LaPeakVX7AR
    return S and S.conn and S.conn.Connected == true
end

if not _adaptAntiRagdollCharacterConn then
    _adaptAntiRagdollCharacterConn = LP.CharacterAdded:Connect(function()
        if not St.antiRagdoll then return end
        task.delay(0.35, function()
            if St.antiRagdoll then
                pcall(startAntiRagdoll)
                
            end
        end)
    end)
end

if not _adaptAntiRagdollWatchdogStarted then
    _adaptAntiRagdollWatchdogStarted = true
    task.spawn(function()
        while task.wait(0.25) do
            if St.antiRagdoll and not _adaptAntiRagdollRuntimeAlive() then
                pcall(startAntiRagdoll)
            end
            
        end
    end)
end


-- ANTI GUMMY / BOOGIE / PAINTBALL (RanaVS full) — LUÔN BẬT
--------------------------------------------------------------
-- Anti Gummy / Boogie / Bee / Paintball (from Tp Heatseeker)
-- Always ON, no GUI
-- ============================================================
if not _G._FAG_VisAntiGummyFullLoaded then
	_G._FAG_VisAntiGummyFullLoaded = true
	task.spawn(function()
 local Players = game:GetService("Players")
 local RunService = game:GetService("RunService")
 local Lighting = game:GetService("Lighting")
 local ReplicatedStorage = game:GetService("ReplicatedStorage")
 local LocalPlayer = Players.LocalPlayer

 local AntiGummy, AntiBoogie, AntiBee = true, true, false -- no Anti Bee
 local ANTI_PAINTBALL_ALWAYS_ON = true

 local function ResetTool(Char)
 if not Char then Char = LocalPlayer.Character end
 if not Char then return end
 pcall(function()
 LocalPlayer:SetAttribute("BlockTools", false)
 LocalPlayer:SetAttribute("Web", false)
 Char:SetAttribute("BackpackReady", true)
 end)
 end

 local function ClearEffect()
 if AntiBee then
 for _, V in pairs(Lighting:GetChildren()) do
 if V.Name == "BeeBlur" or V.Name == "Flashbang" then
 pcall(function() V:Destroy() end)
 end
 end
 local Ctrl = ReplicatedStorage:FindFirstChild("Controllers")
 if Ctrl then
 local BC = Ctrl:FindFirstChild("BeeLauncherController")
 if BC then
 local B = BC:FindFirstChild("Buzzing")
 if B then pcall(function() B:Stop() end) end
 end
 end
 end
 if AntiBoogie then
 for _, V in pairs(Lighting:GetChildren()) do
 if V.Name == "DiscoEffect" then
 pcall(function() V:Destroy() end)
 end
 end
 local Ctrl = ReplicatedStorage:FindFirstChild("Controllers")
 if Ctrl then
 local BC = Ctrl:FindFirstChild("BoogieBombController")
 if BC then
 local B = BC:FindFirstChild("BOOM")
 if B then pcall(function() B:Stop() end) end
 end
 end
 end
 end

 local function getMainHudGui()
 local pg = LocalPlayer:FindFirstChild("PlayerGui")
 return pg and pg:FindFirstChild("Main")
 end

 local function isPaintballSplatGui(gui)
 if not gui or gui.Parent ~= getMainHudGui() then return false end
 if not (gui:IsA("ImageLabel") or gui:IsA("ImageButton")) then return false end
 if gui:GetAttribute("__UGPaintballIgnore") or gui:GetAttribute("__UGPaintballShrunk") then return false end
 return math.abs(gui.Rotation) > 0.01
 end

 local function shrinkPaintballSplat(gui)
 if not gui or gui:GetAttribute("__UGPaintballShrunk") then return end
 gui:SetAttribute("__UGPaintballShrunk", true)
 gui.Size = UDim2.fromOffset(6, 6)
 end

 local function runAntiPaintballSweep()
 if not ANTI_PAINTBALL_ALWAYS_ON then return end
 task.spawn(function()
 for _ = 1, 8 do
 local main = getMainHudGui()
 if not main then break end
 for _, c in ipairs(main:GetChildren()) do
 if isPaintballSplatGui(c) then
 pcall(shrinkPaintballSplat, c)
 end
 end
 task.wait(0.05)
 end
 end)
 end

 -- Paintball continuous sweep
 task.spawn(function()
 while task.wait(0.25) do
 if ANTI_PAINTBALL_ALWAYS_ON then
 pcall(runAntiPaintballSweep)
 end
 end
 end)

 -- Event-driven Anti Gummy / Boogie / Bee.
 -- Do not scan Lighting every Heartbeat: that can cause unnecessary FPS drops.
 -- Anti Bee is handled by the dedicated event-driven block below.
 task.spawn(function()
     while task.wait(0.5) do
         if AntiGummy then
             pcall(ResetTool)
         end
         if AntiBoogie then
             pcall(ClearEffect)
         end
     end
 end)

 -- Also clear on Lighting child added (instant)
 pcall(function()
 Lighting.ChildAdded:Connect(function(child)
 if not child then return end
 local n = child.Name
 if AntiBee and (n == "BeeBlur" or n == "Flashbang") then
 task.defer(function() pcall(function() child:Destroy() end) end)
 end
 if AntiBoogie and n == "DiscoEffect" then
 task.defer(function() pcall(function() child:Destroy() end) end)
 end
 end)
 end)

 -- Paintball: shrink when new splat appears on Main HUD
 pcall(function()
 local function hookMain(main)
 if not main or main:GetAttribute("_VisAntiPaintballHooked") then return end
 main:SetAttribute("_VisAntiPaintballHooked", true)
 main.ChildAdded:Connect(function(c)
 task.defer(function()
 if isPaintballSplatGui(c) then
 pcall(shrinkPaintballSplat, c)
 end
 end)
 end)
 end
 local pg = LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 10)
 if pg then
 hookMain(pg:FindFirstChild("Main"))
 pg.ChildAdded:Connect(function(ch)
 if ch.Name == "Main" then
 task.defer(function() hookMain(ch) end)
 end
 end)
 end
 end)

 -- CharacterAdded: ensure tools unblocked
 LocalPlayer.CharacterAdded:Connect(function(char)
 task.defer(function()
 pcall(ResetTool, char)
 end)
 end)

 print("[Vis AllGear] Anti Gummy / Boogie / Bee / Paintball ON (silent)")
	end)
end

-- Setters: luôn ON, không OFF được
function setAntiGummy(on)
	St.antiGummy = true
	AntiFX.gummy = true
	saveCfg()
end

-- ============================================================================
-- ANTI BEE — MERGED FULL ENGINE
-- Sources integrated:
--   1) La Peak's existing Anti Bee block
--   2) antibee.lua.txt: broad visual blacklist + FOV 70 + touch/gamepad move loop
--   3) message (7).txt: exact Bee/Lighting names + BeeLauncherController sound
--
-- Design:
--   - One toggle controls the complete system.
--   - Event-driven first, with targeted sweeps so it does not scan Lighting every
--     Heartbeat.
--   - Covers both class-based post-effects and game-specific named Bee effects.
--   - Re-checks after respawn and catches recreated Bee/Buzzing instances.
--   - Restores FOV/sound state when disabled instead of leaving permanent changes.
-- ============================================================================
do
    local AntiBeeFull = {
        enabled = false,
        conns = {},
        originalMoveFunction = nil,
        controlsProtected = false,
        originalFOV = nil,
        savedSoundVolumes = {},
        hookedSounds = {},
        movementLockUntil = 0,
        movementLockDuration = 0.45,
    }

    -- Class/type blacklist from the standalone Anti Bee source.
    local effectClasses = {
        "BlurEffect", "ColorCorrectionEffect", "BloomEffect", "SunRaysEffect",
        "DepthOfFieldEffect", "Atmosphere", "Sky", "Smoke", "ParticleEmitter",
        "Beam", "Trail", "Highlight", "PostEffect", "SurfaceAppearance", "Fire",
        "Sparkles", "Explosion", "PointLight", "SpotLight", "SurfaceLight",
        "Shadows", "Blur", "Fog", "ColorGradingEffect", "ToneMappingEffect",
        "VignetteEffect", "GodRays", "Glare", "ChromaticAberrationEffect",
        "DistortionEffect", "LensFlare", "SunFlare", "LightInfluence",
        "AmbientOcclusionEffect", "RefractionEffect", "HeatDistortion",
        "GlitchEffect", "ScreenSpaceReflection", "MotionBlur", "VolumetricLight",
        "RainEffect", "SnowEffect", "LightningEffect", "NeonGlow", "ContrastCorrection",
        "ShadowMap", "Bloom", "Clouds", "FogVolume", "WaterEffect", "WindEffect",
        "PixelateEffect", "FilmGrainEffect", "CRTShader", "NightVisionEffect",
        "InfraredEffect", "HazeEffect", "ColorBalanceEffect", "DynamicLight",
        "AmbientEffect", "ScreenDistortion", "ScanlineEffect", "UnderwaterEffect",
        "ThermalVision", "ShockwaveEffect", "FlashEffect", "ExplosionLight",
        "VFXPart", "GlitchScreen", "ScreenFlash", "OverlayEffect", "ShadowEffect",
        "GhostEffect", "FogEmitter", "WindEmitter", "HeatWave", "SunGlow",
        "ColorOverlay", "VisionDistort", "EchoEffect", "ScreenOverlay", "VisualEffect",
        "LightingEffect", "CameraEffect", "WeatherEffect", "SmokeTrail", "FireTrail",
        "NeonEffect", "RefractionLayer", "PostProcessingEffect", "VisualNoise",
        "ScreenNoise",
    }

    -- Game-specific names found across the supplied Anti Bee implementations.
    local effectNames = {
        BeeBlur = true,
        Flashbang = true,
        Blue = true,
        DiscoEffect = true,
        ColorCorrection = true,
    }

    local SOUND_NAMES = {
        Buzzing = true,
    }

    local function isBlacklisted(obj)
        if not obj then return false end

        local n = obj.Name
        if effectNames[n] then
            return true
        end

        for _, className in ipairs(effectClasses) do
            local ok, result = pcall(function()
                return obj:IsA(className)
            end)
            if ok and result then
                return true
            end
        end

        return false
    end

    local function lockMovementForBee()
        if not AntiBeeFull.enabled then return end
        AntiBeeFull.movementLockUntil = math.max(
            AntiBeeFull.movementLockUntil or 0,
            os.clock() + (AntiBeeFull.movementLockDuration or 0.45)
        )
    end

    local function beeMovementLocked()
        return AntiBeeFull.enabled and os.clock() < (AntiBeeFull.movementLockUntil or 0)
    end

    local function rememberAndSilenceSound(sound)
        if not sound or not sound:IsA("Sound") then return end
        -- Buzzing is one of the exact Bee-hit signals from the supplied Anti Bee sources.
        lockMovementForBee()
        if not AntiBeeFull.savedSoundVolumes[sound] then
            AntiBeeFull.savedSoundVolumes[sound] = sound.Volume
        end
        pcall(function()
            sound:Stop()
            sound.Volume = 0
        end)
    end

    local function hookBuzzingSound(sound)
        if not sound or not sound:IsA("Sound") then return end
        rememberAndSilenceSound(sound)

        if AntiBeeFull.hookedSounds[sound] then
            return
        end
        AntiBeeFull.hookedSounds[sound] = true

        table.insert(AntiBeeFull.conns, sound.Played:Connect(function()
            if AntiBeeFull.enabled and sound.Parent then
                task.defer(function()
                    if AntiBeeFull.enabled and sound.Parent then
                        rememberAndSilenceSound(sound)
                    end
                end)
            end
        end))
    end

    local function restoreSoundVolumes()
        for sound, volume in pairs(AntiBeeFull.savedSoundVolumes) do
            if sound and sound.Parent then
                pcall(function()
                    sound.Volume = volume
                end)
            end
        end
        AntiBeeFull.savedSoundVolumes = {}
        AntiBeeFull.hookedSounds = {}
    end

    local function scanLighting()
        local root = Lighting
        if not root then return end

        for _, obj in ipairs(root:GetDescendants()) do
            if isBlacklisted(obj) then
                -- These are the Bee/Disco visual-hit signals supplied by the
                -- reference Anti Bee implementations. Lock movement before removal.
                if effectNames[obj.Name] then
                    lockMovementForBee()
                end
                pcall(function()
                    obj:Destroy()
                end)
            end
        end
    end

    local function scanForBeeSounds()
        -- Supplied source #3: ReplicatedStorage.Controllers.BeeLauncherController.Buzzing
        pcall(function()
            local controllers = ReplicatedStorage:FindFirstChild("Controllers")
            local beeController = controllers and controllers:FindFirstChild("BeeLauncherController")
            local buzzing = beeController and beeController:FindFirstChild("Buzzing", true)
            if buzzing and buzzing:IsA("Sound") then
                hookBuzzingSound(buzzing)
            end
        end)

        -- Supplied source #2/#3: PlayerScripts/Bee/.../Buzzing
        pcall(function()
            local playerScripts = LP:FindFirstChild("PlayerScripts")
            if not playerScripts then return end

            local beeRoot = playerScripts:FindFirstChild("Bee", true)
            if beeRoot then
                local buzzing = beeRoot:FindFirstChild("Buzzing", true)
                if buzzing and buzzing:IsA("Sound") then
                    hookBuzzingSound(buzzing)
                end
            end

            -- Extra catch-all for recreated/renamed Bee sound instances that still
            -- use the supplied "Buzzing" sound name.
            for _, obj in ipairs(playerScripts:GetDescendants()) do
                if obj:IsA("Sound") and SOUND_NAMES[obj.Name] then
                    hookBuzzingSound(obj)
                end
            end
        end)
    end

    local function disconnectAll()
        for _, conn in ipairs(AntiBeeFull.conns) do
            pcall(function()
                conn:Disconnect()
            end)
        end
        AntiBeeFull.conns = {}
        AntiBeeFull.controlsProtected = false
    end

    local function protectControls()
        if AntiBeeFull.controlsProtected then return end

        pcall(function()
            local playerScripts = LP:FindFirstChild("PlayerScripts")
            local playerModule = playerScripts and playerScripts:FindFirstChild("PlayerModule")
            if not playerModule then return end

            local controlsModule = require(playerModule)
            local controls = controlsModule and controlsModule.GetControls and controlsModule:GetControls()
            if not controls then return end

            if not AntiBeeFull.originalMoveFunction then
                AntiBeeFull.originalMoveFunction = controls.moveFunction
            end

            local protectedMove = function(self, moveVector, relativeToCamera)
                if AntiBeeFull.originalMoveFunction then
                    -- While a Bee-hit signal is active, discard the player's movement
                    -- vector briefly so the Bee cannot reverse/flip the character.
                    if beeMovementLocked() then
                        return AntiBeeFull.originalMoveFunction(self, Vector3.zero, relativeToCamera)
                    end
                    return AntiBeeFull.originalMoveFunction(self, moveVector, relativeToCamera)
                end
            end

            controls.moveFunction = protectedMove
            AntiBeeFull.controlsProtected = true

            local acc = 0
            table.insert(AntiBeeFull.conns, RunService.Heartbeat:Connect(function(dt)
                if not AntiBeeFull.enabled then return end
                acc += dt
                if acc < 0.50 then return end
                acc = 0

                pcall(function()
                    if controls.moveFunction ~= protectedMove then
                        controls.moveFunction = protectedMove
                    end
                end)
            end))
        end)
    end

    local function restoreControls()
        if not AntiBeeFull.originalMoveFunction then
            AntiBeeFull.controlsProtected = false
            return
        end

        pcall(function()
            local playerScripts = LP:FindFirstChild("PlayerScripts")
            local playerModule = playerScripts and playerScripts:FindFirstChild("PlayerModule")
            if not playerModule then return end

            local controlsModule = require(playerModule)
            local controls = controlsModule and controlsModule.GetControls and controlsModule:GetControls()
            if controls then
                controls.moveFunction = AntiBeeFull.originalMoveFunction
            end
        end)

        AntiBeeFull.originalMoveFunction = nil
        AntiBeeFull.controlsProtected = false
    end

    local function applyFOVLock()
        local cam = workspace.CurrentCamera
        if not cam then return end

        if AntiBeeFull.originalFOV == nil then
            AntiBeeFull.originalFOV = cam.FieldOfView
        end

        cam.FieldOfView = 70
    end

    local function restoreFOV()
        local cam = workspace.CurrentCamera
        if cam and AntiBeeFull.originalFOV ~= nil then
            pcall(function()
                cam.FieldOfView = AntiBeeFull.originalFOV
            end)
        end
        AntiBeeFull.originalFOV = nil
    end

    local function handleLightingAdded(obj)
        if not AntiBeeFull.enabled or not obj then return end
        if not obj:IsDescendantOf(Lighting) then return end

        task.defer(function()
            if not AntiBeeFull.enabled or not obj.Parent then return end
            if not obj:IsDescendantOf(Lighting) then return end
            if isBlacklisted(obj) then
                if effectNames[obj.Name] then
                    lockMovementForBee()
                end
                pcall(function()
                    obj:Destroy()
                end)
            end
        end)
    end

    local function handleDescendantAdded(obj)
        if not AntiBeeFull.enabled or not obj then return end

        -- Lighting effect protection.
        handleLightingAdded(obj)

        -- Sound protection for recreated Bee/Buzzing objects.
        if obj:IsA("Sound") and SOUND_NAMES[obj.Name] then
            task.defer(function()
                if AntiBeeFull.enabled and obj.Parent then
                    hookBuzzingSound(obj)
                end
            end)
        end
    end

    local function startAntiBee()
        if AntiBeeFull.enabled then return end

        disconnectAll()
        AntiBeeFull.enabled = true

        -- Immediate cleanup on enable.
        scanLighting()
        scanForBeeSounds()
        protectControls()
        applyFOVLock()

        -- Fast event-driven Lighting protection.
        table.insert(AntiBeeFull.conns, Lighting.DescendantAdded:Connect(handleLightingAdded))

        -- Catch recreated Bee/Buzzing nodes under PlayerScripts.
        pcall(function()
            local playerScripts = LP:FindFirstChild("PlayerScripts")
            if playerScripts then
                table.insert(AntiBeeFull.conns, playerScripts.DescendantAdded:Connect(function(obj)
                    if not AntiBeeFull.enabled then return end
                    handleDescendantAdded(obj)
                end))
            end
        end)

        -- Catch Bee controller descendants when the controller is recreated.
        pcall(function()
            table.insert(AntiBeeFull.conns, ReplicatedStorage.DescendantAdded:Connect(function(obj)
                if not AntiBeeFull.enabled or not obj then return end
                if obj.Name == "Buzzing" and obj:IsA("Sound") then
                    local beeController = obj:FindFirstAncestor("BeeLauncherController")
                    if beeController then
                        task.defer(function()
                            if AntiBeeFull.enabled and obj.Parent then
                                hookBuzzingSound(obj)
                            end
                        end)
                    end
                end
            end))
        end)

        -- The hook above listens to Sound.Played, matching the supplied
        -- controller-level anti-Bee behavior while also surviving recreated sounds.

        -- FPS-safe movement protection. Do not call Humanoid:Move every frame.
        -- PlayerModule.moveFunction is already protected above; only force zero
        -- movement during the short Bee lock, at a low frequency.
        local beeTick = 0
        table.insert(AntiBeeFull.conns, RunService.Heartbeat:Connect(function(dt)
            if not AntiBeeFull.enabled then return end
            beeTick += dt
            if beeTick < 0.10 then return end
            beeTick = 0

            if beeMovementLocked() then
                local char = LP.Character
                local humanoid = char and char:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    pcall(function() humanoid:Move(Vector3.zero, true) end)
                end
            end

            local cam = workspace.CurrentCamera
            if cam and math.abs(cam.FieldOfView - 70) > 0.05 then
                cam.FieldOfView = 70
            end
        end))

        -- Respawn recovery.
        table.insert(AntiBeeFull.conns, LP.CharacterAdded:Connect(function()
            task.defer(function()
                if not AntiBeeFull.enabled then return end
                scanLighting()
                scanForBeeSounds()
                protectControls()
                applyFOVLock()
            end)
        end))

        _G.RanaVS_AntiBeeFullActive = true
    end

    local function stopAntiBee()
        AntiBeeFull.enabled = false
        AntiBeeFull.movementLockUntil = 0
        disconnectAll()
        restoreControls()
        restoreSoundVolumes()
        restoreFOV()
        _G.RanaVS_AntiBeeFullActive = false
    end

    function setAntiBee(on)
        local enable = on == true
        St.antiBee = enable

        if enable then
            startAntiBee()
        else
            stopAntiBee()
        end

        pcall(saveCfg)
        if _G.RanaVSRefreshAntiBeeBtn then
            pcall(_G.RanaVSRefreshAntiBeeBtn)
        end
    end

    _G.RanaVSSetAntiBee = setAntiBee
    _G.RanaVSStartAntiBee = startAntiBee
    _G.RanaVSStopAntiBee = stopAntiBee
end
-- ============================================================================
-- ============================================================================
-- ANTI TRAP — merged detector/equip logic from Anti trampa.lua
-- Standalone AntiTrap GUI removed: 12Hub owns the UI.
-- Adds zero-meter trap detection, fuzzy 5-gear tool matching, and trap ESP.
-- ============================================================================
do
	local AntiTrapState = {
		enabled = false,
		gear = "Cupid's Wings",
		stuckTime = 0,
		lastPosition = nil,
		lastEquip = 0,
		lastTrapEquip = 0,
		lastZeroMScan = 0,
		conn = nil,
	}

	local ANTI_TRAP_CHECK_TIME = 0.025
	local ANTI_TRAP_MOVEMENT_THRESHOLD = 0.015
	local ANTI_TRAP_COOLDOWN = 0.15
	-- "0M" is treated as touching/overlapping range with a small physics epsilon.
	local ANTI_TRAP_ZERO_M_EPSILON = 1.25

	local ANTI_TRAP_GEARS = {
		"Cupid's Wings",
		"Santa's Sleigh",
		"Witch's Broom",
		"Flying Carpet",
		"Waverider",
	}

	local TRAP_NAME_WORDS = {
		"trap",
		"tripmine",
		"trip mine",
		"landmine",
		"land mine",
		"beartrap",
		"bear trap",
		"snare",
		"subspace",
	}

	local TOOL_ALIASES = {
		["Cupid's Wings"] = {"cupid's wings", "cupids wings", "cupid wings", "cupid"},
		["Santa's Sleigh"] = {"santa's sleigh", "santas sleigh", "santa sleigh", "sleigh", "santa"},
		["Witch's Broom"] = {"witch's broom", "witchs broom", "witch broom", "broom", "witch"},
		["Flying Carpet"] = {"flying carpet", "carpet"},
		["Waverider"] = {"waverider", "wave rider", "waverider", "rider", "wave"},
	}

	for _, gearName in ipairs(ANTI_TRAP_GEARS) do
		if St.antiTrapGear == gearName then
			AntiTrapState.gear = gearName
			break
		end
	end
	St.antiTrapGear = AntiTrapState.gear

	local function normalizeToolName(name)
		name = tostring(name or ""):lower()
		name = name:gsub("[%[%]%(%){}]", " ")
		name = name:gsub("[^%w%s]", " ")
		name = name:gsub("%s+", " ")
		return name:gsub("^%s+", ""):gsub("%s+$", "")
	end

	local function compactName(name)
		return normalizeToolName(name):gsub("%s+", "")
	end

	local function scoreToolName(targetName, candidateName)
		local target = compactName(targetName)
		local candidate = compactName(candidateName)
		if target == "" or candidate == "" then return 0 end
		if target == candidate then return 1000 end

		local best = 0
		local aliases = TOOL_ALIASES[targetName] or {}
		for _, alias in ipairs(aliases) do
			local a = compactName(alias)
			if a ~= "" then
				if candidate == a then
					best = math.max(best, 950)
				elseif candidate:find(a, 1, true) or a:find(candidate, 1, true) then
					best = math.max(best, 850)
				end
			end
		end

		if candidate:find(target, 1, true) then
			best = math.max(best, 900)
		elseif target:find(candidate, 1, true) and #candidate >= 4 then
			best = math.max(best, 780)
		end

		local targetTokens = {}
		for tok in normalizeToolName(targetName):gmatch("%S+") do
			targetTokens[tok] = true
		end
		local candidateTokens = {}
		for tok in normalizeToolName(candidateName):gmatch("%S+") do
			candidateTokens[tok] = true
		end

		local overlap, total = 0, 0
		for tok in pairs(targetTokens) do
			total += 1
			if candidateTokens[tok] then overlap += 1 end
		end
		if total > 0 and overlap > 0 then
			best = math.max(best, 600 + math.floor(300 * overlap / total))
		end
		return best
	end

	local function getAllPlayerTools()
		local out, seen = {}, {}
		local function scan(container)
			if not container then return end
			for _, obj in ipairs(container:GetDescendants()) do
				if obj:IsA("Tool") and not seen[obj] then
					seen[obj] = true
					table.insert(out, obj)
				end
			end
			for _, obj in ipairs(container:GetChildren()) do
				if obj:IsA("Tool") and not seen[obj] then
					seen[obj] = true
					table.insert(out, obj)
				end
			end
		end
		scan(LP:FindFirstChildOfClass("Backpack"))
		scan(LP.Character)
		return out
	end

	local function antiTrapFindTool(name)
		if type(name) ~= "string" or name == "" then return nil end
		local bestTool, bestScore = nil, -1
		for _, tool in ipairs(getAllPlayerTools()) do
			local score = scoreToolName(name, tool.Name)
			if score > bestScore then
				bestScore = score
				bestTool = tool
			end
		end
		-- Require a real name match; prevents equipping an unrelated tool.
		if bestScore >= 600 then
			return bestTool
		end
		return nil
	end

	-- ------------------------------------------------------------
	-- TRAP CANDIDATE / POSITION HELPERS
	-- ------------------------------------------------------------
	local TrapESP = {
		data = {},
		candidates = {},
		lastScan = 0,
		visualAccum = 0,
		heartbeat = nil,
		visualConn = nil,
		_conns = {},
	}

	local function containsTrapWord(name)
		local s = tostring(name or ""):lower()
		for _, word in ipairs(TRAP_NAME_WORDS) do
			if s:find(word, 1, true) then
				return true
			end
		end
		return false
	end

	local function isLocalCharacterObject(obj)
		local char = LP.Character
		return char and obj and obj:IsDescendantOf(char)
	end

	local function trapRootFromObject(obj)
		if not obj then return nil end
		if isLocalCharacterObject(obj) then return nil end

		local current = obj
		local best = nil
		for _ = 1, 8 do
			if not current or current == workspace then break end
			if containsTrapWord(current.Name) then
				if current:IsA("Model") or current:IsA("BasePart") then
					best = current
				end
			end
			current = current.Parent
		end
		if best then return best end
		if containsTrapWord(obj.Name) and (obj:IsA("Model") or obj:IsA("BasePart")) then
			return obj
		end
		return nil
	end

	local function trapPosition(obj)
		if not obj or not obj.Parent then return nil end
		if obj:IsA("BasePart") then return obj.Position end
		if obj:IsA("Model") then
			local ok, cf = pcall(function() return obj:GetPivot() end)
			if ok and cf then return cf.Position end
			local p = obj:FindFirstChildWhichIsA("BasePart", true)
			return p and p.Position or nil
		end
		if obj:IsA("Attachment") then return obj.WorldPosition end
		local p = obj:FindFirstChildWhichIsA("BasePart", true)
		return p and p.Position or nil
	end

	local function collectTrapCandidates()
		local map = {}
		for _, obj in ipairs(workspace:GetDescendants()) do
			if (obj:IsA("Model") or obj:IsA("BasePart")) and not isLocalCharacterObject(obj) then
				local root = trapRootFromObject(obj)
				if root then
					map[root] = true
				end
			end
		end
		TrapESP.candidates = map
		TrapESP.lastScan = os.clock()
		return map
	end

	local function getTrapCandidates()
		-- Full workspace scan is only used to seed the cache once; subsequent
		-- additions/removals update TrapESP.candidates incrementally.
		if TrapESP.lastScan <= 0 then
			return collectTrapCandidates()
		end
		return TrapESP.candidates
	end

	local function nearestTrap()
		local char = LP.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if not hrp then return nil, math.huge end

		local best, bestDistance = nil, math.huge
		local maxRange = tonumber(St.trapScanRange) or 250
		for trap in pairs(getTrapCandidates()) do
			local pos = trapPosition(trap)
			if pos then
				local d = (hrp.Position - pos).Magnitude
				if d < bestDistance and d <= maxRange then
					best, bestDistance = trap, d
				end
			end
		end
		return best, bestDistance
	end

	local function isSubspaceTrap(trap)
		return trap and containsTrapWord(trap.Name) and tostring(trap.Name):lower():find("subspace", 1, true) ~= nil
	end

	-- ------------------------------------------------------------
	-- TRAP ESP
	-- ------------------------------------------------------------
	local function getTrapAdorneePart(trap)
		if not trap then return nil end
		if trap:IsA("BasePart") then return trap end
		return trap:FindFirstChildWhichIsA("BasePart", true)
	end

	local function trapEspCleanup(trap)
		local d = TrapESP.data[trap]
		if not d then return end
		pcall(function() if d.hl then d.hl:Destroy() end end)
		pcall(function() if d.bb then d.bb:Destroy() end end)
		TrapESP.data[trap] = nil
	end

	local function trapEspSetup(trap)
		if not St.trapESP then return end
		if isSubspaceTrap(trap) and not St.subspaceESP then return end
		local adorneePart = getTrapAdorneePart(trap)
		if not trap or not adorneePart then return end
		trapEspCleanup(trap)

		local hl = Instance.new("Highlight")
		hl.Name = "12Hub_TrapOutline"
		hl.Adornee = trap
		hl.FillColor = isSubspaceTrap(trap) and Color3.fromRGB(180, 70, 255) or Color3.fromRGB(255, 70, 70)
		hl.FillTransparency = 0.86
		hl.OutlineColor = isSubspaceTrap(trap) and Color3.fromRGB(220, 120, 255) or Color3.fromRGB(255, 80, 80)
		hl.OutlineTransparency = St.trapOutlineESP and 0 or 1
		hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		hl.Parent = trap

		local bb
		if St.trapDistanceESP or St.subspaceESP then
			bb = Instance.new("BillboardGui")
			bb.Name = "12Hub_TrapDistance"
			bb.Adornee = adorneePart
			bb.Size = UDim2.fromOffset(120, 28)
			bb.StudsOffset = Vector3.new(0, 2.2, 0)
			bb.AlwaysOnTop = true
			bb.MaxDistance = math.max(tonumber(St.trapScanRange) or 250, 100)
			bb.Parent = trap

			local label = Instance.new("TextLabel")
			label.Name = "Distance"
			label.Size = UDim2.fromScale(1, 1)
			label.BackgroundTransparency = 1
			label.TextColor3 = Color3.new(1, 1, 1)
			label.TextStrokeTransparency = 0.35
			label.Font = Enum.Font.GothamBlack
			label.TextSize = 11
			label.Parent = bb
		end

		TrapESP.data[trap] = {hl = hl, bb = bb, part = adorneePart}
	end

	local function refreshTrapVisuals()
		for trap in pairs(TrapESP.data) do
			if not trap or not trap.Parent then
				trapEspCleanup(trap)
			end
		end
		if not St.trapESP then
			for trap in pairs(TrapESP.data) do trapEspCleanup(trap) end
			return
		end
		for trap in pairs(getTrapCandidates()) do
			if not TrapESP.data[trap] then
				trapEspSetup(trap)
			end
		end
	end

	local function setTrapESP(on)
		St.trapESP = on == true
		if St.trapESP then
			collectTrapCandidates()
			refreshTrapVisuals()
		else
			for trap in pairs(TrapESP.data) do trapEspCleanup(trap) end
		end
		pcall(saveCfg)
	end

	local function setTrapDistanceESP(on)
		St.trapDistanceESP = on == true
		if St.trapESP then
			for trap in pairs(TrapESP.data) do trapEspCleanup(trap) end
			refreshTrapVisuals()
		end
		pcall(saveCfg)
	end

	local function setTrapOutlineESP(on)
		St.trapOutlineESP = on == true
		for trap,d in pairs(TrapESP.data) do
			if d.hl then d.hl.OutlineTransparency = St.trapOutlineESP and 0 or 1 end
		end
		pcall(saveCfg)
	end

	local function setSubspaceESP(on)
		St.subspaceESP = on == true
		if St.trapESP then
			for trap in pairs(TrapESP.data) do trapEspCleanup(trap) end
			refreshTrapVisuals()
		end
		pcall(saveCfg)
	end

	local function setTrapScanRange(n)
		St.trapScanRange = math.clamp(tonumber(n) or 250, 10, 1000)
		pcall(saveCfg)
	end

	local function setAntiTrapZeroM(on)
		-- Alias the ESP control to the same master switch as the Anti Trap toggle/button.
		local enabled = on == true
		if type(setAntiTrap) == "function" then
			setAntiTrap(enabled)
		else
			St.antiTrap = enabled
			St.antiTrapZeroM = enabled
			if enabled and TrapESP.lastScan <= 0 then collectTrapCandidates() end
			pcall(saveCfg)
		end
	end

	-- Render distance text without creating per-trap Heartbeat connections.
	TrapESP.visualConn = RunService.RenderStepped:Connect(function(deltaTime)
		if not St.trapESP then return end
		TrapESP.visualAccum = TrapESP.visualAccum + (tonumber(deltaTime) or 0)
		if TrapESP.visualAccum < 0.10 then return end
		TrapESP.visualAccum = 0
		local char = LP.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if not hrp then return end
		for trap,d in pairs(TrapESP.data) do
			local pos = trapPosition(trap)
			if not pos or not trap.Parent then
				trapEspCleanup(trap)
			else
				if d.bb then
					local label = d.bb:FindFirstChild("Distance")
					if label then
						local meters = math.max(0, math.floor((hrp.Position - pos).Magnitude * 10 + 0.5) / 10)
						if isSubspaceTrap(trap) then
							label.Text = "SUBSPACE • " .. tostring(meters) .. "M"
							label.TextColor3 = Color3.fromRGB(220, 130, 255)
							label.Visible = St.subspaceESP or St.trapDistanceESP
						else
							label.Text = "TRAP • " .. tostring(meters) .. "M"
							label.TextColor3 = Color3.new(1, 1, 1)
							label.Visible = St.trapDistanceESP
						end
					end
				end
				if d.hl then
					d.hl.OutlineTransparency = St.trapOutlineESP and 0 or 1
				end
			end
		end
	end)

	-- Incremental trap cache: a workspace-wide scan per new effect/object was
	-- causing repeated FPS drops. Seed once; thereafter update only the changed object.
	table.insert(TrapESP._conns, workspace.DescendantAdded:Connect(function(obj)
		if not obj or (not obj:IsA("Model") and not obj:IsA("BasePart")) then return end
		if isLocalCharacterObject(obj) then return end
		local root = trapRootFromObject(obj)
		if not root or not root.Parent then return end
		TrapESP.candidates[root] = true
		if St.trapESP and not TrapESP.data[root] then
			task.defer(function()
				if St.trapESP and root.Parent and not TrapESP.data[root] then trapEspSetup(root) end
			end)
		end
	end))
	table.insert(TrapESP._conns, workspace.DescendantRemoving:Connect(function(obj)
		TrapESP.candidates[obj] = nil
		if TrapESP.data[obj] then trapEspCleanup(obj) end
	end))

	local function antiTrapEquipAndInstantUnequip(reason)
		if not AntiTrapState.enabled then return false end
		local selectedToolName = AntiTrapState.gear
		if not selectedToolName then return false end

		local now = os.clock()
		if now - AntiTrapState.lastEquip < ANTI_TRAP_COOLDOWN then return false end
		AntiTrapState.lastEquip = now

		local character = LP.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		if not humanoid or humanoid.Health <= 0 then return false end

		-- Resolve the currently selected gear every trigger so the gear selector is authoritative.
		local tool = antiTrapFindTool(selectedToolName)
		if not tool then return false end
		local equipped = pcall(function()
			humanoid:EquipTool(tool)
		end)
		if not equipped then return false end

		AntiTrapState.lastEquipReason = reason
		task.spawn(function()
			pcall(function()
				-- Give Roblox one simulation step to register the equip before activating it.
				RunService.Heartbeat:Wait()
				local activeCharacter = LP.Character
				local activeHumanoid = activeCharacter and activeCharacter:FindFirstChildOfClass("Humanoid")
				if not activeCharacter or not activeHumanoid or activeHumanoid.Health <= 0 then return end
				if not tool or not tool.Parent then return end
				if tool.Parent ~= activeCharacter then activeHumanoid:EquipTool(tool) end
				tool:Activate()
				task.wait(0.05)
				activeHumanoid:UnequipTools()
			end)
		end)
		return true
	end

	local function stopAntiTrap()
		AntiTrapState.enabled = false
		AntiTrapState.stuckTime = 0
		AntiTrapState.lastPosition = nil
		if AntiTrapState.conn then
			pcall(function() AntiTrapState.conn:Disconnect() end)
			AntiTrapState.conn = nil
		end
		_G.RanaVS_AntiTrapActive = false
	end

	local function startAntiTrap()
		stopAntiTrap()
		AntiTrapState.enabled = true
		if St.antiTrapZeroM and TrapESP.lastScan <= 0 then collectTrapCandidates() end

		AntiTrapState.conn = RunService.Heartbeat:Connect(function(deltaTime)
			if not AntiTrapState.enabled then return end
			if not AntiTrapState.gear then return end

			local character = LP.Character
			if not character then return end

			local humanoid = character:FindFirstChildOfClass("Humanoid")
			local root = character:FindFirstChild("HumanoidRootPart")
			if not humanoid or not root or humanoid.Health <= 0 then return end

			-- Full Anti trampa movement detector.
			if not AntiTrapState.lastPosition then
				AntiTrapState.lastPosition = root.Position
			else
				local tryingToMove = humanoid.MoveDirection.Magnitude > 0.05
				local distance = (root.Position - AntiTrapState.lastPosition).Magnitude
				local actuallyMoving = distance > ANTI_TRAP_MOVEMENT_THRESHOLD

				if tryingToMove and not actuallyMoving then
					AntiTrapState.stuckTime += deltaTime
				else
					AntiTrapState.stuckTime = 0
				end
				AntiTrapState.lastPosition = root.Position

				if AntiTrapState.stuckTime >= ANTI_TRAP_CHECK_TIME then
					AntiTrapState.stuckTime = 0
					if (os.clock() - AntiTrapState.lastEquip) >= ANTI_TRAP_COOLDOWN then
						task.spawn(antiTrapEquipAndInstantUnequip, "STUCK")
					end
				end
			end

			-- ESP trap 0M trigger: auto-equip when a recognized trap is at contact range.
			if St.antiTrapZeroM and (os.clock() - AntiTrapState.lastZeroMScan) >= 0.10 then
				AntiTrapState.lastZeroMScan = os.clock()
				local trap, distance = nearestTrap()
				if trap and distance <= ANTI_TRAP_ZERO_M_EPSILON then
					if (os.clock() - AntiTrapState.lastTrapEquip) >= ANTI_TRAP_COOLDOWN then
						AntiTrapState.lastTrapEquip = os.clock()
						task.spawn(antiTrapEquipAndInstantUnequip, isSubspaceTrap(trap) and "SUBSPACE_0M" or "TRAP_0M")
					end
				end
			end
		end)

		_G.RanaVS_AntiTrapActive = true
	end

	function setAntiTrap(on)
		local enable = on == true
		-- One master state: Player toggle, mobile Anti Trap button, and ESP Auto Equip 0M.
		St.antiTrap = enable
		St.antiTrapZeroM = enable
		if enable then
			startAntiTrap()
		else
			stopAntiTrap()
		end
		pcall(saveCfg)
		if ToggleRefs and ToggleRefs.antiTrap and ToggleRefs.antiTrap.setVisual then
			pcall(ToggleRefs.antiTrap.setVisual, enable)
		end
		if ToggleRefs and ToggleRefs.antiTrapZeroM and ToggleRefs.antiTrapZeroM.setVisual then
			pcall(ToggleRefs.antiTrapZeroM.setVisual, enable)
		end
		pcall(function()
			if _G.RanaVSRefreshAntiTrapBtn then _G.RanaVSRefreshAntiTrapBtn() end
		end)
	end

	function setAntiTrapGear(name)
		name = tostring(name or "")
		for _, gearName in ipairs(ANTI_TRAP_GEARS) do
			if name == gearName then
				AntiTrapState.gear = gearName
				St.antiTrapGear = gearName
				AntiTrapState.lastPosition = nil
				pcall(saveCfg)
				return true
			end
		end
		return false
	end

	function getAntiTrapToolMatch()
		return antiTrapFindTool(AntiTrapState.gear)
	end

	_G.RanaVSSetAntiTrap = setAntiTrap
	_G.RanaVSSetAntiTrapGear = setAntiTrapGear
	_G.RanaVSAntiTrapGears = ANTI_TRAP_GEARS
	_G.RanaVSFindAntiTrapTool = getAntiTrapToolMatch
	_G.RanaVSNearestTrap = nearestTrap
	_G.RanaVSSetTrapESP = setTrapESP
	_G.RanaVSSetTrapDistanceESP = setTrapDistanceESP
	_G.RanaVSSetTrapOutlineESP = setTrapOutlineESP
	_G.RanaVSSetSubspaceESP = setSubspaceESP
	_G.RanaVSSetTrapScanRange = setTrapScanRange
	_G.RanaVSSetAntiTrapZeroM = setAntiTrapZeroM

	LP.CharacterAdded:Connect(function()
		AntiTrapState.lastPosition = nil
		AntiTrapState.stuckTime = 0
	end)

	-- Initialize trap cache without forcing the UI/ESP on.
	task.defer(function()
		pcall(collectTrapCandidates)
		if St.trapESP then pcall(refreshTrapVisuals) end
	end)
end

function setAntiBoogie(on)
	St.antiBoogie = true
	AntiFX.boogie = true
	saveCfg()
end
function setAntiPaint(on)
	St.antiPaint = true
	AntiFX.paint = true
	saveCfg()
end

----------------------------------------------------------------
-- TOOL AIMBOT (RanaVS full) — LUÔN BẬT
----------------------------------------------------------------
local aimOn = true
local TOOLS = { ["Web Slinger"] = true, ["Paintball Gun"] = true, ["Laser Cape"] = true }
local hooked = {}
local mouseMod, lastAimUp = nil, 0
function getMouse()
	if mouseMod then return mouseMod end
	pcall(function()
 local pkg = ReplicatedStorage:FindFirstChild("Packages")
 if pkg then mouseMod = require(pkg:WaitForChild("PlayerMouse", 5)) end
	end)
	return mouseMod
end
function bestEnemy()
	local char = LP.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	local cam = workspace.CurrentCamera
	if not root or not cam then return nil end
	local best, score = nil, math.huge
	local camPos, camDir = cam.CFrame.Position, cam.CFrame.LookVector
	for _, plr in ipairs(Players:GetPlayers()) do
 if plr ~= LP and plr.Character then
 local r = plr.Character:FindFirstChild("HumanoidRootPart")
 local h = plr.Character:FindFirstChildOfClass("Humanoid")
 if r and h and h.Health > 0 then
 local d = (r.Position - root.Position).Magnitude
 if d <= 100 then
 local to = r.Position - camPos
 if to.Magnitude > 0.01 then
 local ang = math.deg(math.acos(math.clamp(camDir:Dot(to.Unit), -1, 1)))
 local sc = d + (ang > 200 and 1000 or 0)
 if sc < score then score, best = sc, r end
 end
 end
 end
 end
	end
	return best
end
function overrideMouse()
	if not aimOn then return end
	local pm = getMouse()
	if not pm then return end
	local e = bestEnemy()
	if e and e.Parent then
 local vel = e.AssemblyLinearVelocity or Vector3.zero
 pcall(function()
 pm.Hit = CFrame.new(e.Position + vel * 0.1)
 pm.Target = e
 end)
	end
end
function hookTool(tool)
	if hooked[tool] or not tool then return end
	hooked[tool] = true
	tool.Activated:Connect(overrideMouse)
	tool.Equipped:Connect(function()
 task.wait(0.1)
 local pm = getMouse()
 if pm and aimOn then
 local old = pm.Button1Down
 pm.Button1Down = function(...)
 overrideMouse()
 if old then old(...) end
 end
 end
	end)
end
function watchTools(parent)
	if not parent then return end
	for _, c in ipairs(parent:GetChildren()) do
 if TOOLS[c.Name] then hookTool(c) end
	end
	parent.ChildAdded:Connect(function(c)
 task.wait(0.05)
 if TOOLS[c.Name] then hookTool(c) end
	end)
end
watchTools(LP.Backpack)
if LP.Character then watchTools(LP.Character) end
LP.CharacterAdded:Connect(function(c)
	task.wait(0.2)
	watchTools(c)
	watchTools(LP.Backpack)
end)
RS.RenderStepped:Connect(function()
	if not aimOn then return end
	if tick() - lastAimUp > 0.1 then lastAimUp = tick(); bestEnemy() end
	if UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then overrideMouse() end
end)
function setToolAim(on)
	-- LUÔN BẬT tool aimbot
	aimOn = true
	St.toolAim = true
	local char = LP.Character
	if char then pcall(watchTools, char) end
	local bp = LP:FindFirstChild("Backpack")
	if bp then pcall(watchTools, bp) end
	saveCfg()
end
-- boot tool aim
task.defer(function()
	aimOn = true
	St.toolAim = true
	pcall(function()
 if LP.Character then watchTools(LP.Character) end
 if LP.Backpack then watchTools(LP.Backpack) end
	end)
end)

----------------------------------------------------------------
-- DROP JUMP / STAND (Vis Clean)
----------------------------------------------------------------
local dropActive = false
local DROP_SPD, DROP_DUR = 200, 0.28
function runDrop()
	if dropActive then return end
	local char = LP.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not root or not hum then return end
	local mode = tonumber(St.dropMode) or 2
	if mode == 1 then
 -- Stand / Fling style burst
 dropActive = true
 local t0 = tick()
 local conn
 conn = RS.Heartbeat:Connect(function()
 if not dropActive or tick() - t0 > 0.25 then
 if conn then conn:Disconnect() end
 dropActive = false
 if root and root.Parent then
 root.AssemblyLinearVelocity = Vector3.zero
 end
 return
 end
 local r = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
 if not r then return end
 local v = Vector3.new(0, r.AssemblyLinearVelocity.Y, 0)
 r.AssemblyLinearVelocity = v * 10000 + Vector3.new(0, 10000, 0)
 end)
 return
	end
	-- Jump ascend
	dropActive = true
	local t0 = tick()
	local conn
	conn = RS.Heartbeat:Connect(function()
 local c = LP.Character
 local r = c and c:FindFirstChild("HumanoidRootPart")
 if not r or not dropActive then
 if conn then conn:Disconnect() end
 dropActive = false
 return
 end
 if tick() - t0 >= DROP_DUR then
 if conn then conn:Disconnect() end
 local rp = RaycastParams.new()
 rp.FilterDescendantsInstances = { c }
 rp.FilterType = Enum.RaycastFilterType.Exclude
 local rr = workspace:Raycast(r.Position, Vector3.new(0, -3000, 0), rp)
 if rr then
 local h2 = c:FindFirstChildOfClass("Humanoid")
 local off = ((h2 and h2.HipHeight) or 2) + (r.Size.Y / 2)
 r.CFrame = CFrame.new(r.Position.X, rr.Position.Y + off, r.Position.Z)
 end
 r.AssemblyLinearVelocity = Vector3.zero
 r.AssemblyAngularVelocity = Vector3.zero
 dropActive = false
 return
 end
 r.AssemblyLinearVelocity = Vector3.new(r.AssemblyLinearVelocity.X, DROP_SPD, r.AssemblyLinearVelocity.Z)
	end)
end

----------------------------------------------------------------
-- INSTA RESET V1 / V2 (Vis; V1 camera lock removed)
----------------------------------------------------------------
local _resetBusy = false
local _resetCD = false
local INST_V2_POS = CFrame.new(2000.5, 9911.9, 4000.2)
-- INSTA RESET V2 — adapted LaPeak/VX7 reset core
local _VX7IR = {
    busy = false,
    character = nil,
    respawnConn = nil,
    token = nil,
    collisions = {},
}

_G._AdaptInstantResetBusy = false
_G.AdaptInstantResetInProgress = false
_G.AdaptInstantResetVersion = 2

local function _VX7IRSetButton(on)
    local e = actRefs and actRefs.insta
    if e and e.btn then
        pcall(function()
            applyActBtnState(e.btn, on == true, "INSTA\nRESET", "INSTA\nRESET")
        end)
    end
end

local function _VX7IRClearVelocity(root)
    if not root then return end
    pcall(function()
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
    end)
end

_VX7IR.finish = function(newHumanoid)
    if _VX7IR.respawnConn then
        pcall(function() _VX7IR.respawnConn:Disconnect() end)
        _VX7IR.respawnConn = nil
    end

    for part, oldCanCollide in pairs(_VX7IR.collisions) do
        if part and part.Parent then
            pcall(function() part.CanCollide = oldCanCollide end)
        end
    end
    _VX7IR.collisions = {}

    local character = LP.Character
    local humanoid = newHumanoid or (character and character:FindFirstChildOfClass("Humanoid"))
    local camera = workspace.CurrentCamera
    if camera then
        pcall(function()
            if humanoid then camera.CameraSubject = humanoid end
            camera.CameraType = Enum.CameraType.Custom
        end)
    end

    _VX7IR.busy = false
    _VX7IR.character = nil
    _VX7IR.token = nil
    _G._AdaptInstantResetBusy = false
    _G.AdaptInstantResetInProgress = false
    _resetBusy = false
    _resetCD = false
    _VX7IRSetButton(false)
end

_G.AdaptInstantReset = function()
    if _VX7IR.busy then return end

    local character = LP.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if not root or not humanoid then return end

    local token = {}
    _VX7IR.busy = true
    _VX7IR.character = character
    _VX7IR.token = token
    _G._AdaptInstantResetBusy = true
    _G.AdaptInstantResetInProgress = true
    _G.AdaptInstantResetVersion = 2
    _resetBusy = true
    _VX7IRSetButton(true)

    _VX7IR.respawnConn = LP.CharacterAdded:Connect(function(newCharacter)
        local conn = _VX7IR.respawnConn
        _VX7IR.respawnConn = nil
        if conn then pcall(function() conn:Disconnect() end) end

        task.wait(0.1)
        local newHumanoid = newCharacter:WaitForChild("Humanoid", 3)
        if _VX7IR.token ~= token then return end
        _VX7IR.finish(newHumanoid)
    end)

    local ok, err = pcall(function()
        local camera = workspace.CurrentCamera
        if camera then
            camera.CameraType = Enum.CameraType.Scriptable
            camera.CFrame = camera.CFrame
        end

        for _, descendant in ipairs(character:GetDescendants()) do
            if descendant:IsA("BasePart") then
                _VX7IR.collisions[descendant] = descendant.CanCollide
                descendant.CanCollide = false
            end
        end

        _VX7IRClearVelocity(root)

        if sethiddenproperty then
            pcall(sethiddenproperty, root, "PhysicsRepRootPart", nil)
        end

        root.AssemblyLinearVelocity = Vector3.new(0, 3000000, 0)
    end)

    if not ok then
        _VX7IR.finish()
        warn("LaPeak/VX7 Insta Reset: " .. tostring(err))
        return
    end

    task.delay(5, function()
        if _VX7IR.token ~= token then return end
        if LP.Character == character and root.Parent then
            _VX7IRClearVelocity(root)
        end
        _VX7IR.finish()
    end)
end

_G.AdaptStopInstantReset = function()
    if not _VX7IR.busy then return end
    local token = _VX7IR.token
    _VX7IR.token = nil
    if _VX7IR.respawnConn then
        pcall(function() _VX7IR.respawnConn:Disconnect() end)
        _VX7IR.respawnConn = nil
    end
    if token then _VX7IR.finish() end
end

_G.AdaptGetInstantResetState = function()
    return _VX7IR.busy == true
end

LP.CharacterAdded:Connect(function(character)
    if not _VX7IR.busy then return end
    local token = _VX7IR.token
    _VX7IR.token = nil
    if _VX7IR.respawnConn then
        pcall(function() _VX7IR.respawnConn:Disconnect() end)
        _VX7IR.respawnConn = nil
    end
    if token then
        task.defer(function()
            if LP.Character == character then
                _VX7IR.finish(character:FindFirstChildOfClass("Humanoid"))
            end
        end)
    end
end)

function InstaResetV2()
    _G.AdaptInstantReset()
end

function InstaResetV1()
    -- V1: RARA INSTA RESET CORE. InstaResetV2 remains unchanged.
    if _resetCD or _resetBusy then return end

    local character = LP.Character
    if not character or not character.Parent then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return end
    local root = humanoid.RootPart or character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    _resetCD = true
    _resetBusy = true
    _VX7IRSetButton(true)

    task.spawn(function()
        local FLING_TIME = 0.4
        local FLING_POWER = 50000
        local USE_VOID = true
        local VOID_TIME = 0.6
        local RESET_TIMEOUT = 6
        local newCharacter = nil
        local addedConnection = nil
        local respawnConnection = nil
        local savedTransparency = {}

        local function hideLocally(obj)
            if not obj then return end
            if obj:IsA("BasePart") then
                if savedTransparency[obj] == nil then
                    savedTransparency[obj] = { kind = "BasePart", value = obj.LocalTransparencyModifier }
                end
                obj.LocalTransparencyModifier = 1
            elseif obj:IsA("Decal") or obj:IsA("Texture") then
                if savedTransparency[obj] == nil then
                    savedTransparency[obj] = { kind = "Transparency", value = obj.Transparency }
                end
                obj.Transparency = 1
            end
        end

        local function unlockCharacter()
            pcall(function() humanoid.PlatformStand = false end)
            pcall(function() humanoid.Sit = false end)
            pcall(function() humanoid.AutoRotate = true end)
        end

        local function aliveRoot()
            if root and root.Parent then return root end
            root = humanoid.RootPart or character:FindFirstChild("HumanoidRootPart")
            if root and root.Parent then return root end
            return nil
        end

        local function cleanup()
            if respawnConnection then
                pcall(function() respawnConnection:Disconnect() end)
                respawnConnection = nil
            end
            if addedConnection then
                pcall(function() addedConnection:Disconnect() end)
                addedConnection = nil
            end

            -- If the character did not respawn, undo local hiding so the player is not left invisible.
            if not newCharacter and LP.Character == character then
                for obj, oldValue in pairs(savedTransparency) do
                    if obj and obj.Parent then
                        pcall(function()
                            if oldValue.kind == "BasePart" then
                                obj.LocalTransparencyModifier = oldValue.value
                            else
                                obj.Transparency = oldValue.value
                            end
                        end)
                    end
                end
            end

            -- Do not lock/freeze the camera during V1 reset; restore normal follow afterwards.
            pcall(function()
                local currentCamera = workspace.CurrentCamera
                local targetCharacter = newCharacter or LP.Character
                local targetHumanoid = targetCharacter and targetCharacter:FindFirstChildOfClass("Humanoid")
                if currentCamera then
                    currentCamera.CameraType = Enum.CameraType.Custom
                    if targetHumanoid then currentCamera.CameraSubject = targetHumanoid end
                end
            end)
            _resetCD = false
            _resetBusy = false
            _VX7IRSetButton(false)
        end

        local ok, err = pcall(function()
            for _, obj in ipairs(character:GetDescendants()) do
                pcall(hideLocally, obj)
            end
            addedConnection = character.DescendantAdded:Connect(function(obj)
                pcall(hideLocally, obj)
            end)
            respawnConnection = LP.CharacterAdded:Connect(function(newChar)
                newCharacter = newChar
            end)

            unlockCharacter()
            for _, obj in ipairs(character:GetDescendants()) do
                if obj:IsA("BasePart") then
                    pcall(function() obj.Anchored = false end)
                    pcall(function() obj.CanCollide = false end)
                elseif obj.Name == "SeatWeld" then
                    pcall(function() obj:Destroy() end)
                end
            end

            local started = os.clock()
            local flingUntil = os.clock() + FLING_TIME
            while not newCharacter and os.clock() < flingUntil and humanoid.Parent do
                unlockCharacter()
                pcall(function() humanoid.HipHeight = 1e30 end)
                local liveRoot = aliveRoot()
                if liveRoot then
                    pcall(function() liveRoot.Anchored = false end)
                    pcall(function() liveRoot.AssemblyLinearVelocity = Vector3.new(0, FLING_POWER, 0) end)
                    pcall(function() liveRoot.Velocity = Vector3.new(0, FLING_POWER, 0) end)
                end
                RunService.Heartbeat:Wait()
            end

            if USE_VOID and not newCharacter then
                local floor = -500
                pcall(function() floor = workspace.FallenPartsDestroyHeight end)
                local voidUntil = os.clock() + VOID_TIME
                while not newCharacter and os.clock() < voidUntil do
                    local liveRoot = aliveRoot()
                    if not liveRoot then break end
                    pcall(function() liveRoot.CFrame = CFrame.new(0, floor - 500, 0) end)
                    pcall(function() liveRoot.AssemblyLinearVelocity = Vector3.new(0, -FLING_POWER, 0) end)
                    RunService.Heartbeat:Wait()
                end
            end

            while not newCharacter and os.clock() - started < RESET_TIMEOUT do
                if humanoid.Parent then
                    pcall(function() humanoid.Health = 0 end)
                    pcall(function() humanoid:ChangeState(Enum.HumanoidStateType.Dead) end)
                end
                if character.Parent then pcall(function() character:BreakJoints() end) end
                task.wait(0.1)
            end
        end)

        cleanup()
        if not ok then
            warn("RARA Insta Reset V1: " .. tostring(err))
        end
    end)
end


function doInstaReset()
    if St.instaMode == "V2" then
        InstaResetV2()
    else
        InstaResetV1()
    end
end

----------------------------------------------------------------
-- TP DOWN (Vis)
----------------------------------------------------------------
function doTPDown(force)
	local char = LP.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not hrp or not hum or hum.Health <= 0 then return end
	if not force then
 if hum.FloorMaterial ~= Enum.Material.Air then return end
 if hrp.Position.Y < 20 then return end
	end
	hrp.CFrame = CFrame.new(hrp.Position.X, -7, hrp.Position.Z)
 * CFrame.Angles(0, select(2, hrp.CFrame:ToEulerAnglesYXZ()), 0)
	hrp.AssemblyLinearVelocity = Vector3.zero
end

----------------------------------------------------------------
-- ESP + TRACER + ANTI LAG
----------------------------------------------------------------
local ESP = { on = false, data = {}, conns = {} }
function espCleanup(plr)
	local d = ESP.data[plr]
	if not d then return end
	pcall(function() if d.hl then d.hl:Destroy() end end)
	pcall(function() if d.bb then d.bb:Destroy() end end)
	pcall(function() if d.tracer then d.tracer:Remove() end end)
	ESP.data[plr] = nil
end
function espSetup(plr, char)
	if not ESP.on or plr == LP or not char then return end
	espCleanup(plr)
	local hrp = char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart", 3)
	local head = char:FindFirstChild("Head")
	if not hrp then return end
	local hl = Instance.new("Highlight")
	hl.Adornee = char
	hl.FillColor = Color3.fromRGB(35, 35, 35)
	hl.FillTransparency = 0.7
	hl.OutlineColor = Color3.fromRGB(255, 255, 255)
	hl.OutlineTransparency = 0
	hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	hl.Parent = char
	local bb, tracer
	if head then
 bb = Instance.new("BillboardGui")
 bb.Adornee = head
 bb.Size = UDim2.new(0, 100, 0, 20)
 bb.StudsOffset = Vector3.new(0, 2.5, 0)
 bb.AlwaysOnTop = true
 bb.Parent = head
 local t = Instance.new("TextLabel", bb)
 t.Size = UDim2.new(1, 0, 1, 0)
 t.BackgroundTransparency = 1
 t.Text = plr.DisplayName or plr.Name
 t.TextColor3 = Color3.new(1, 1, 1)
 t.TextSize = 12
 t.Font = Enum.Font.GothamBold
 t.TextStrokeTransparency = 0.5
	end
	if St.tracer then
 tracer = Drawing and Drawing.new and Drawing.new("Line")
 if tracer then
 tracer.Thickness = 1
 tracer.Color = Color3.fromRGB(255, 255, 255)
 tracer.Visible = true
 end
	end
	ESP.data[plr] = { hl = hl, bb = bb, tracer = tracer, hrp = hrp }
end
function startESP()
	if ESP.on then return end
	ESP.on = true
	for _, plr in ipairs(Players:GetPlayers()) do
 if plr ~= LP and plr.Character then espSetup(plr, plr.Character) end
 table.insert(ESP.conns, plr.CharacterAdded:Connect(function(c)
 task.defer(espSetup, plr, c)
 end))
	end
	table.insert(ESP.conns, Players.PlayerAdded:Connect(function(plr)
 table.insert(ESP.conns, plr.CharacterAdded:Connect(function(c)
 task.defer(espSetup, plr, c)
 end))
	end))
	table.insert(ESP.conns, RS.RenderStepped:Connect(function()
 if not St.tracer then return end
 local cam = workspace.CurrentCamera
 local my = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
 if not cam or not my then return end
 local origin = cam:WorldToViewportPoint(my.Position)
 for plr, d in pairs(ESP.data) do
 if d.tracer and d.hrp and d.hrp.Parent then
 local p, onScreen = cam:WorldToViewportPoint(d.hrp.Position)
 d.tracer.From = Vector2.new(origin.X, origin.Y)
 d.tracer.To = Vector2.new(p.X, p.Y)
 d.tracer.Visible = onScreen and p.Z > 0
 elseif d.tracer then
 d.tracer.Visible = false
 end
 end
	end))
end
function stopESP()
	ESP.on = false
	for _, c in ipairs(ESP.conns) do pcall(function() c:Disconnect() end) end
	ESP.conns = {}
	for plr in pairs(ESP.data) do espCleanup(plr) end
end
function setESP(on)
	St.esp = on
	if on then startESP() else stopESP() end
	saveCfg()
end
function setTracer(on)
	St.tracer = on
	if St.esp then stopESP(); startESP() end
	saveCfg()
end

-- Anti Lag (full implementation from source file 2)
antiLagVisualEnabled = St.antiLag == true
_G.AdaptZombieAntiLag = _G.AdaptZombieAntiLag or {
    conn=nil,
    active=false,
    defBrightness=nil,
    defFog=nil,
    defDiffuse=nil,
    defSpecular=nil,
}

function _applyAntiLagObj(obj)
    pcall(function()
        if obj:IsA("BasePart") then
            obj.Material = Enum.Material.Plastic
            obj.Reflectance = 0
            obj.CastShadow = false
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            obj.Transparency = 1
        elseif obj:IsA("ParticleEmitter")
            or obj:IsA("Trail")
            or obj:IsA("Beam")
            or obj:IsA("Fire")
            or obj:IsA("Smoke")
            or obj:IsA("Sparkles") then
            obj.Enabled = false
        elseif obj:IsA("AnimationController") or obj:IsA("Animator") then
            for _,tr in ipairs(obj:GetPlayingAnimationTracks()) do
                pcall(function() tr:Stop(0) end)
            end
        end
    end)
end

function enableAntiLag()
    antiLagVisualEnabled = true
    local S = _G.AdaptZombieAntiLag
    if S.active == true and S.conn and S.conn.Connected then return end
    S.active = true
    S.defBrightness = S.defBrightness or Lighting.Brightness
    S.defFog = S.defFog or Lighting.FogEnd
    S.defDiffuse = S.defDiffuse or Lighting.EnvironmentDiffuseScale
    S.defSpecular = S.defSpecular or Lighting.EnvironmentSpecularScale

    Lighting.GlobalShadows = false
    Lighting.FogEnd = 1e10
    Lighting.EnvironmentDiffuseScale = 0
    Lighting.EnvironmentSpecularScale = 0

    for _,e in pairs(Lighting:GetChildren()) do
        pcall(function()
            if e:IsA("BlurEffect")
                or e:IsA("SunRaysEffect")
                or e:IsA("ColorCorrectionEffect")
                or e:IsA("BloomEffect")
                or e:IsA("DepthOfFieldEffect") then
                e.Enabled = false
            end
        end)
    end

    if S.conn then S.conn:Disconnect() end
    S.conn = workspace.DescendantAdded:Connect(function(obj)
        if S.active then _applyAntiLagObj(obj) end
    end)
    antiLagDescConn = S.conn
    S.scanGeneration = (tonumber(S.scanGeneration) or 0) + 1
    local scanGeneration = S.scanGeneration
    local scanItems = workspace:GetDescendants()
    task.spawn(function()
        for index, obj in ipairs(scanItems) do
            if not S.active or S.scanGeneration ~= scanGeneration then return end
            _applyAntiLagObj(obj)
            if index % 160 == 0 then task.wait() end
        end
    end)
end

function disableAntiLag()
    antiLagVisualEnabled = false
    local S = _G.AdaptZombieAntiLag
    S.active = false
    S.scanGeneration = (tonumber(S.scanGeneration) or 0) + 1

    if S.conn then
        S.conn:Disconnect()
        S.conn = nil
    end
    antiLagDescConn = nil

    pcall(function()
        Lighting.GlobalShadows = true
        if S.defBrightness then Lighting.Brightness = S.defBrightness end
        if S.defFog then Lighting.FogEnd = S.defFog end
        if S.defDiffuse then Lighting.EnvironmentDiffuseScale = S.defDiffuse end
        if S.defSpecular then Lighting.EnvironmentSpecularScale = S.defSpecular end

        for _,e in pairs(Lighting:GetChildren()) do
            pcall(function()
                if e:IsA("BlurEffect")
                    or e:IsA("SunRaysEffect")
                    or e:IsA("ColorCorrectionEffect")
                    or e:IsA("BloomEffect")
                    or e:IsA("DepthOfFieldEffect") then
                    e.Enabled = true
                end
            end)
        end
    end)
end

-- Compatibility alias for any legacy caller.
function applyDerender(obj)
    _applyAntiLagObj(obj)
end

function setAntiLag(on)
    St.antiLag = on == true
    if St.antiLag then
        enableAntiLag()
    else
        disableAntiLag()
    end
    saveCfg()
end


-- Nuke Optimize (full implementation from source file 2).
-- This feature can remove clothing/textures and some map objects; it is OFF by default.
V = V or {}
nukeOptimiserEnabled = St.nukeOptimiserEnabled == true
_nukeOptimizerOn = false
_nukeOptimizerConns = {}
_nukeOptimizerThreads = {}
function enableNukeOptimizer()
if _nukeOptimizerOn then return end
_nukeOptimizerOn = true
nukeOptimiserEnabled = true
V.nukeOptEnabled = true
local MaterialService = game:GetService("MaterialService")
local XMin, XMax = -560, -240
local ClothingClasses = {"Shirt","Pants","ShirtGraphic","Accessory","Hat","HairAccessory","FaceAccessory","NeckAccessory","ShoulderAccessory","FrontAccessory","BackAccessory","WaistAccessory"}
local BASE_NAMES = {"baseplate","spawnlocation","spawn location","spawn"}
function SafeDestroy(obj)
if obj and obj.Name == "Overhead" then return end
pcall(function() obj:Destroy() end)
end
function IsClothing(obj)
for _, className in ipairs(ClothingClasses) do
if obj:IsA(className) then return true end
end
return false
end
function IsCharacterPart(obj)
if not obj then return false end
local ancestor = obj
while ancestor and ancestor ~= workspace do
    if ancestor:IsA("Model") and Players:GetPlayerFromCharacter(ancestor) then return true end
    ancestor = ancestor.Parent
end
return false
end
function IsOutOfRange(obj)
if obj:IsA("BasePart") then
local x = obj.Position.X
return x < XMin or x > XMax
end
return false
end
function IsBase(obj)
if not obj:IsA("BasePart") then return false end
local nl = obj.Name:lower()
for _, n in ipairs(BASE_NAMES) do
if nl:find(n, 1, true) then return true end
end
return false
end
function IsInBase(obj)
local p = obj.Parent
while p and p ~= workspace do
if IsBase(p) then return true end
p = p.Parent
end
return false
end
function MakeTransparent(obj)
pcall(function()
if IsBase(obj) and not IsCharacterPart(obj) then
obj.Transparency = 1
obj.CastShadow = false
end
end)
end
function StripObject(obj)
pcall(function()
if obj:IsA("Texture") or obj:IsA("Decal") or obj:IsA("SpecialMesh") then
SafeDestroy(obj)
elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
pcall(function() obj.Enabled = false end)
SafeDestroy(obj)
elseif obj:IsA("SurfaceAppearance") then
SafeDestroy(obj)
elseif obj:IsA("BasePart") then
obj.CastShadow = false
obj.Material = Enum.Material.Plastic
obj.MaterialVariant = ""
obj.Reflectance = 0
end
end)
end
function CleanObject(obj)
pcall(function()
if obj:IsA("SurfaceAppearance") then
SafeDestroy(obj)
elseif obj:IsA("Decal") or obj:IsA("Texture") then
if not (obj.Name == "face" and obj.Parent and obj.Parent.Name == "Head") then SafeDestroy(obj) end
elseif obj:IsA("SpecialMesh") then
obj.TextureId = ""
elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
SafeDestroy(obj)
elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
SafeDestroy(obj)
elseif obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") or obj:IsA("Explosion") then
SafeDestroy(obj)
elseif obj:IsA("Animation") or obj:IsA("AnimationController") then
SafeDestroy(obj)
elseif obj:IsA("BasePart") then
obj.CastShadow = false
obj.Material = Enum.Material.Plastic
obj.MaterialVariant = ""
obj.Reflectance = 0
end
end)
end
function ApplyGreySky()
pcall(function()
for _, obj in ipairs(Lighting:GetChildren()) do
if obj:IsA("Sky") then obj:Destroy() end
end
local sky = Instance.new("Sky")
sky.SkyboxBk = ""; sky.SkyboxDn = ""; sky.SkyboxFt = ""
sky.SkyboxLf = ""; sky.SkyboxRt = ""; sky.SkyboxUp = ""
sky.CelestialBodiesShown = false
sky.Name = "_AdaptDuelsNukeSky"
sky.Parent = Lighting
end)
end
function OptimizeLighting()
pcall(function()
Lighting.GlobalShadows = false
Lighting.FogEnd = 9e9
Lighting.FogStart = 9e9
Lighting.EnvironmentDiffuseScale = 0
Lighting.EnvironmentSpecularScale = 0
Lighting.Brightness = 1.5
Lighting.Ambient = Color3.fromRGB(60,60,60)
for _, v in ipairs(Lighting:GetChildren()) do
if v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("SunRaysEffect") or v:IsA("DepthOfFieldEffect") or v:IsA("Atmosphere") or v:IsA("Clouds") then
v:Destroy()
end
end
ApplyGreySky()
end)
end
function ApplyTerrain()
pcall(function()
local terrain = workspace:FindFirstChildOfClass("Terrain")
if terrain then
terrain.Decoration = false
terrain.WaterWaveSize = 0
terrain.WaterWaveSpeed = 0
terrain.WaterReflectance = 0
terrain.WaterTransparency = 1
end
end)
end
function OptimizeCharacter(char)
if not char then return end
task.spawn(function()
task.wait(0.3)
if not _nukeOptimizerOn then return end
for _, obj in ipairs(char:GetDescendants()) do
if IsClothing(obj) then SafeDestroy(obj) else CleanObject(obj) end
end
end)
end
pcall(function()
settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
end)
pcall(function() if setfpscap then setfpscap(999) end end)
table.insert(_nukeOptimizerThreads, task.spawn(function()
if not game:IsLoaded() then game.Loaded:Wait() end
OptimizeLighting()
ApplyTerrain()
local optimizerItems = workspace:GetDescendants()
for index, obj in ipairs(optimizerItems) do
if not _nukeOptimizerOn then return end
if IsBase(obj) then
MakeTransparent(obj)
elseif IsClothing(obj) then
SafeDestroy(obj)
elseif IsInBase(obj) then
elseif IsCharacterPart(obj) then
elseif IsOutOfRange(obj) then
SafeDestroy(obj)
else
CleanObject(obj)
StripObject(obj)
end
if index % 180 == 0 then task.wait() end
end
end))
table.insert(_nukeOptimizerConns, workspace.DescendantAdded:Connect(function(obj)
if not _nukeOptimizerOn then return end
task.defer(function()
if not _nukeOptimizerOn then return end
if IsBase(obj) then MakeTransparent(obj); return end
if IsClothing(obj) then
SafeDestroy(obj)
elseif IsInBase(obj) then
elseif IsCharacterPart(obj) then
elseif IsOutOfRange(obj) then
SafeDestroy(obj)
else
CleanObject(obj)
StripObject(obj)
end
end)
end))
table.insert(_nukeOptimizerConns, Lighting.DescendantAdded:Connect(function(obj)
if not _nukeOptimizerOn then return end
if obj:IsA("Atmosphere") or obj:IsA("Clouds") or obj:IsA("PostEffect") then SafeDestroy(obj) end
end))
table.insert(_nukeOptimizerConns, MaterialService.DescendantAdded:Connect(function(obj)
if not _nukeOptimizerOn then return end
SafeDestroy(obj)
end))
for _, plr in ipairs(Players:GetPlayers()) do
OptimizeCharacter(plr.Character)
table.insert(_nukeOptimizerConns, plr.CharacterAdded:Connect(OptimizeCharacter))
end
table.insert(_nukeOptimizerConns, Players.PlayerAdded:Connect(function(plr)
table.insert(_nukeOptimizerConns, plr.CharacterAdded:Connect(OptimizeCharacter))
end))
table.insert(_nukeOptimizerThreads, task.spawn(function()
while _nukeOptimizerOn do
task.wait(15)
pcall(function() collectgarbage("collect") end)
end
end))
end
function disableNukeOptimizer()
_nukeOptimizerOn = false
nukeOptimiserEnabled = false
V.nukeOptEnabled = false
for _, c in ipairs(_nukeOptimizerConns) do pcall(function() c:Disconnect() end) end
_nukeOptimizerConns = {}
_nukeOptimizerThreads = {}
end

function setNukeOptimizer(on)
    St.nukeOptimiserEnabled = on == true
    nukeOptimiserEnabled = St.nukeOptimiserEnabled
    if St.nukeOptimiserEnabled then
        enableNukeOptimizer()
    else
        disableNukeOptimizer()
    end
    saveCfg()
end



----------------------------------------------------------------
-- INFINITE JUMP (Vis BloodHounds hold)
----------------------------------------------------------------
local InfJump = { enabled = false, conn = nil, last = 0 }
-- (InfJump moved above with BloodHounds speed)

-- AUTO DESTROY V2 — Rara engine connected to 12Hub's existing Destroy controls
----------------------------------------------------------------
do -- isolate engine locals; leave every 12Hub button label/keybind unchanged
    local autoDestroyV2Enabled = false
    local destroyV2Running = false
    local destroyV2Task = nil
    local activeAttackCount = 0
    local turretAttackBusy = setmetatable({}, { __mode = "k" })
    local turretAttackQueued = setmetatable({}, { __mode = "k" })
    local turretAttackCooldownUntil = setmetatable({}, { __mode = "k" })

    -- Rara Auto Destroy V2 settings
    local MAX_CONCURRENT = 2
    local MAX_ATTEMPTS = 18
    local MAX_DISTANCE = 250
    local TURRET_ATTACK_RETRY_DELAY = 0.15
    local ATTACK_INTERVAL = 0.045

    local function isEnemyTurret(obj)
        if not obj or not obj:IsA("BasePart") then return false end
        local name = obj.Name
        local nameLower = name:lower()
        local ownerId = name:match("^Sentry_(%d+)$") or name:match("^sentry_(%d+)$")
        if not ownerId then
            ownerId = name:match("^CandySentry_(%d+)$")
                or name:match("^Candy_Sentry_(%d+)$")
                or name:match("^candy_sentry_(%d+)$")
                or name:match("^candysentry_(%d+)$")
                or nameLower:match("^candy[_%-]?sentry_(%d+)$")
        end
        if not ownerId and nameLower:find("candy") and nameLower:find("sentry") then
            ownerId = name:match("(%d+)$")
        end
        if not ownerId then ownerId = name:match("^[Tt]urret_(%d+)$") end
        if not ownerId and nameLower:find("sentry") then ownerId = name:match("(%d+)$") end
        return ownerId ~= nil and tostring(ownerId) ~= tostring(LP.UserId)
    end

    local function setTurretNoClip(turret)
        if not isEnemyTurret(turret) then return end
        pcall(function()
            turret.CanCollide = false
            turret.Anchored = true
            turret.AssemblyLinearVelocity = Vector3.zero
            turret.AssemblyAngularVelocity = Vector3.zero
        end)
    end

    local function getTurretTimeLabel(turret)
        if not turret or not turret.Parent then return nil end
        local setupFrame = turret:FindFirstChild("SetupFrame")
        local mainFrame = setupFrame and setupFrame:FindFirstChild("MainFrame")
        local timeLabel = mainFrame and mainFrame:FindFirstChild("Time")
        if timeLabel and timeLabel:IsA("TextLabel") then return timeLabel end
        for _, d in ipairs(turret:GetDescendants()) do
            if d:IsA("TextLabel") then
                local n = d.Name:lower()
                if n == "time" or n == "timer" or n == "countdown" then return d end
            end
        end
        return nil
    end

    local function shouldAttackTurret(turret)
        if LP:GetAttribute("Stealing") ~= nil then return false end
        if not isEnemyTurret(turret) then return false end
        setTurretNoClip(turret)
        local timeLabel = getTurretTimeLabel(turret)
        if timeLabel then
            local ok, text = pcall(function() return timeLabel.Text end)
            if not ok then return false end
            text = tostring(text or ""):gsub("^%s+", ""):gsub("%s+$", "")
            if text == "" then return false end
            if string.find(text, "^%d+%s*[sS]!?$") then return true end
            if string.find(text, "^%d+$") then return true end
            return false
        end
        return true
    end

    local function bringTurretInFront(turret, hrp)
        if not turret or not hrp then return end
        local forward = hrp.CFrame.LookVector
        local targetPos = hrp.Position + forward * 2.8 + Vector3.new(0, 1.15, 0)
        local targetCf = CFrame.lookAt(targetPos, targetPos + forward)
        pcall(function()
            turret.AssemblyLinearVelocity = Vector3.zero
            turret.AssemblyAngularVelocity = Vector3.zero
            turret.CFrame = targetCf
        end)
    end

    local function findBatV2()
        local char = LP.Character
        if not char then return nil end
        local backpack = LP:FindFirstChild("Backpack")
        local bat = char:FindFirstChild("Bat") or (backpack and backpack:FindFirstChild("Bat"))
        if bat then return bat end
        for _, t in ipairs(char:GetChildren()) do
            if t:IsA("Tool") and t.Name:lower():find("bat") then return t end
        end
        if backpack then
            for _, t in ipairs(backpack:GetChildren()) do
                if t:IsA("Tool") and t.Name:lower():find("bat") then return t end
            end
        end
        return nil
    end

    local function ensureBatEquippedV2(hum, char)
        if not hum or not char then return nil end
        local held = char:FindFirstChildOfClass("Tool")
        if held and (held.Name == "Bat" or held.Name:lower():find("bat")) then return held end
        local bat = findBatV2()
        if not bat then return nil end
        pcall(function() hum:EquipTool(bat) end)
        return char:FindFirstChild("Bat") or bat
    end

    local function attackTurretV2(turret)
        local now = os.clock()
        if turretAttackBusy[turret] or turretAttackQueued[turret] then return end
        if activeAttackCount >= MAX_CONCURRENT then return end
        if not shouldAttackTurret(turret) then return end
        if (turretAttackCooldownUntil[turret] or 0) > now then return end
        turretAttackQueued[turret] = true
        turretAttackCooldownUntil[turret] = now + TURRET_ATTACK_RETRY_DELAY
        task.spawn(function()
            turretAttackQueued[turret] = nil
            if activeAttackCount >= MAX_CONCURRENT then return end
            if turretAttackBusy[turret] or not shouldAttackTurret(turret) then return end
            activeAttackCount = activeAttackCount + 1
            turretAttackBusy[turret] = true
            local ok, err = xpcall(function()
                local attempts = 0
                local batReady = false
                while attempts < MAX_ATTEMPTS and autoDestroyV2Enabled do
                    if not turret or not turret.Parent or not shouldAttackTurret(turret) then break end
                    local char = LP.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    if not hrp or not hum or hum.Health <= 0 then break end
                    local okDistance, distance = pcall(function() return (turret.Position - hrp.Position).Magnitude end)
                    if okDistance and distance > MAX_DISTANCE then break end
                    setTurretNoClip(turret)
                    bringTurretInFront(turret, hrp)
                    local bat
                    if not batReady then
                        bat = ensureBatEquippedV2(hum, char)
                        batReady = bat ~= nil
                    else
                        bat = char:FindFirstChild("Bat") or findBatV2()
                        local held = char:FindFirstChildOfClass("Tool")
                        if held and held.Name ~= "Bat" and not held.Name:lower():find("bat") then break end
                    end
                    if bat then pcall(function() bat:Activate() end) end
                    attempts = attempts + 1
                    task.wait(ATTACK_INTERVAL)
                end
            end, debug.traceback)
            turretAttackBusy[turret] = nil
            activeAttackCount = math.max(0, activeAttackCount - 1)
            if not ok then warn("Destroy V2 error:", err) end
        end)
    end

    local function startDestroyV2Loop()
        if destroyV2Task then return end
        destroyV2Running = true
        destroyV2Task = task.spawn(function()
            while destroyV2Running do
                if autoDestroyV2Enabled then
                    local pending = {}
                    for _, obj in ipairs(workspace:GetDescendants()) do
                        if isEnemyTurret(obj) then
                            setTurretNoClip(obj)
                            if shouldAttackTurret(obj) and not turretAttackBusy[obj] then
                                table.insert(pending, obj)
                            end
                        end
                    end
                    local char = LP.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp and #pending > 0 then
                        table.sort(pending, function(a, b)
                            local da = (a.Position - hrp.Position).Magnitude
                            local db = (b.Position - hrp.Position).Magnitude
                            return da < db
                        end)
                        for i = 1, math.min(MAX_CONCURRENT, #pending) do
                            attackTurretV2(pending[i])
                        end
                    end
                end
                task.wait(0.25)
            end
        end)
    end

    local function stopDestroyV2Loop()
        destroyV2Running = false
        if destroyV2Task then
            pcall(task.cancel, destroyV2Task)
            destroyV2Task = nil
        end
        activeAttackCount = 0
        for k in pairs(turretAttackBusy) do turretAttackBusy[k] = nil end
        for k in pairs(turretAttackQueued) do turretAttackQueued[k] = nil end
        for k in pairs(turretAttackCooldownUntil) do turretAttackCooldownUntil[k] = nil end
    end

    -- Adapter only: keep 12Hub's existing DESTROY button, keybind, and config.
    function setDestroySentry(on)
        autoDestroyV2Enabled = (on == true)
        St.destroySentry = autoDestroyV2Enabled
        if autoDestroyV2Enabled then
            startDestroyV2Loop()
        else
            stopDestroyV2Loop()
        end
        if ToggleRefs and ToggleRefs.destroySentry and ToggleRefs.destroySentry.setVisual then
            pcall(ToggleRefs.destroySentry.setVisual, autoDestroyV2Enabled)
        end
        if _G.RanaVSRefreshSentryBtn then pcall(_G.RanaVSRefreshSentryBtn) end
        pcall(saveCfg)
    end
end -- end Rara Auto Destroy V2 engine

----------------------------------------------------------------
-- SPAM LASER CAPE / PAINTBALL (activate only, no auto-equip)
----------------------------------------------------------------
local spamConn = nil
function startSpamLoop()
	if spamConn then return end
	spamConn = RS.Heartbeat:Connect(function()
 local char = LP.Character
 if not char then return end
 local tool = char:FindFirstChildOfClass("Tool")
 if not tool then return end
 local n = tool.Name
 if St.spamLaser and n == "Laser Cape" then
 if aimOn then overrideMouse() end
 pcall(function() tool:Activate() end)
 elseif St.spamPaint and n == "Paintball Gun" then
 if aimOn then overrideMouse() end
 pcall(function() tool:Activate() end)
 end
	end)
end
function stopSpamLoopIfIdle()
	if not St.spamLaser and not St.spamPaint then
 if spamConn then pcall(function() spamConn:Disconnect() end) spamConn = nil end
	end
end
function setSpamLaser(on)
	St.spamLaser = on and true or false
	if St.spamLaser then startSpamLoop() else stopSpamLoopIfIdle() end
	saveCfg()
end
function setSpamPaint(on)
	St.spamPaint = on and true or false
	if St.spamPaint then startSpamLoop() else stopSpamLoopIfIdle() end
	saveCfg()
end

----------------------------------------------------------------
-- COUNTER: Laser Cape / Boogie Bomb / Swap Body / Equip on Drop
----------------------------------------------------------------
local counterConn = nil
local COUNTER_TOOL_NAMES = {
	laser = { "Laser Cape", "LaserCape", "laser cape" },
	boogie = { "Boogie Bomb", "BoogieBomb", "boogie bomb", "Disco Ball" },
	swap = { "Body Swap Potion", "Swap Body", "Body Swap", "SwapBody", "Potion of Body Swap" },
}

local function findToolByNames(names)
	local char = LP.Character
	local bp = LP:FindFirstChild("Backpack")
	for _, nm in ipairs(names) do
 if char then
 local t = char:FindFirstChild(nm)
 if t and t:IsA("Tool") then return t end
 end
 if bp then
 local t = bp:FindFirstChild(nm)
 if t and t:IsA("Tool") then return t end
 end
	end
	-- fuzzy
	local function scan(parent)
 if not parent then return nil end
 for _, ch in ipairs(parent:GetChildren()) do
 if ch:IsA("Tool") then
 local ln = string.lower(ch.Name)
 for _, nm in ipairs(names) do
 if ln:find(string.lower(nm), 1, true) then return ch end
 end
 end
 end
 return nil
	end
	return scan(char) or scan(bp)
end

local function equipAndActivate(tool)
	if not tool then return end
	local char = LP.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if not hum then return end
	pcall(function()
 if tool.Parent ~= char then
 hum:EquipTool(tool)
 end
	end)
	task.defer(function()
 pcall(function() tool:Activate() end)
	end)
end

function startCounterLoop()
	-- No spam Activate khi chọn counter — chỉ dùng lúc Drop
	if counterConn then
 pcall(function() counterConn:Disconnect() end)
 counterConn = nil
	end
end

function stopCounterLoopIfIdle()
	if not (St.counterLaser or St.counterBoogie or St.counterSwapBody or St.equipOnDrop) then
 if counterConn then pcall(function() counterConn:Disconnect() end) counterConn = nil end
	end
end

local function _counterExclusive(which)
	-- Chỉ 1 counter ON: OFF các cái còn lại
	St.counterLaser = (which == "laser")
	St.counterBoogie = (which == "boogie")
	St.counterSwapBody = (which == "swap")
	if ToggleRefs then
 for k, flag in pairs({counterLaser = (which=="laser"), counterBoogie = (which=="boogie"), counterSwapBody = (which=="swap")}) do
 local r = ToggleRefs[k]
 if r and r.setVisual then pcall(r.setVisual, flag) end
 end
	end
end

function setCounterLaser(on)
	if on then
 _counterExclusive("laser")
 -- chỉ lưu lựa chọn; equip+activate x2 khi Drop
 stopCounterLoopIfIdle()
	else
 St.counterLaser = false
 stopCounterLoopIfIdle()
	end
	saveCfg()
end
function setCounterBoogie(on)
	if on then
 _counterExclusive("boogie")
 -- chỉ lưu lựa chọn; equip+activate x2 khi Drop
 stopCounterLoopIfIdle()
	else
 St.counterBoogie = false
 stopCounterLoopIfIdle()
	end
	saveCfg()
end
function setCounterSwapBody(on)
	if on then
 _counterExclusive("swap")
 -- chỉ lưu lựa chọn; equip+activate x2 khi Drop
 stopCounterLoopIfIdle()
	else
 St.counterSwapBody = false
 stopCounterLoopIfIdle()
	end
	saveCfg()
end
function setEquipOnDrop(on)
	St.equipOnDrop = on and true or false
	saveCfg()
end

-- Equip + activate khi Drop xong
_G.RanaVSCounterOnDrop = function()
	-- Counter đã chọn: equip 1 + activate 2 khi Drop (Fling & Jump)
	local anyCounter = St.counterLaser or St.counterBoogie or St.counterSwapBody
	if not anyCounter and not St.equipOnDrop then return end
	if _G._VisCounterDropBusy == true then return end
	_G._VisCounterDropBusy = true
	task.spawn(function()
 local char = LP.Character
 local hum = char and char:FindFirstChildOfClass("Humanoid")
 local prevTool = char and char:FindFirstChildOfClass("Tool")
 local prevName = prevTool and prevTool.Name or nil
 task.wait(0.2)
 local function runOnce(names)
 local tool = findToolByNames(names)
 if not tool then return end
 equipAndActivate(tool) -- equip + activate #1
 task.wait(0.15)
 pcall(function() tool:Activate() end) -- activate #2
 task.wait(0.1)
 end
 if St.counterLaser then runOnce(COUNTER_TOOL_NAMES.laser) end
 if St.counterBoogie then runOnce(COUNTER_TOOL_NAMES.boogie) end
 if St.counterSwapBody then runOnce(COUNTER_TOOL_NAMES.swap) end
 task.wait(0.1)
 pcall(function()
 local c = LP.Character
 local h = c and c:FindFirstChildOfClass("Humanoid")
 if not h or not prevName then return end
 local pl = string.lower(prevName)
 local isCounter = false
 for _, names in pairs(COUNTER_TOOL_NAMES) do
 for _, nm in ipairs(names) do
 if pl:find(string.lower(nm), 1, true) then isCounter = true break end
 end
 if isCounter then break end
 end
 if not isCounter then
 local bp = LP:FindFirstChild("Backpack")
 local t = (c and c:FindFirstChild(prevName)) or (bp and bp:FindFirstChild(prevName))
 if t and t:IsA("Tool") then h:EquipTool(t) end
 end
 end)
 _G._VisCounterDropBusy = false
	end)
end

-- Bật toggle Counter: equip 1 + activate 2 (một lần)
_G.RanaVSCounterOneShot = function(kind)
	if _G._VisCounterDropBusy then return end
	_G._VisCounterDropBusy = true
	task.spawn(function()
 local names = COUNTER_TOOL_NAMES[kind]
 if not names then _G._VisCounterDropBusy = false return end
 local tool = findToolByNames(names)
 if tool then
 equipAndActivate(tool)
 task.wait(0.15)
 pcall(function() tool:Activate() end)
 end
 _G._VisCounterDropBusy = false
	end)
end



function corner(p, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r or 10)
	c.Parent = p
	return c
end
function stroke(p, col)
	local s = Instance.new("UIStroke")
	s.Color = col or C.stroke
	s.Thickness = 1
	s.Transparency = 0.35
	s.Parent = p
	return s
end

-- ============================================================================
-- LEGACY RANA MAIN MENU REMOVED
-- All old Main/Tab/mini menu construction is deleted. The only main menu UI
-- is the LaPeak shell built later in this file.
-- ============================================================================

----------------------------------------------------------------
-- MOBILE: 3 mode + Drop + Insta + TP
----------------------------------------------------------------
local ModeGui = Instance.new("ScreenGui")
ModeGui.Name = "Rana.VSHubModeBar"
ModeGui.ResetOnSpawn = false
ModeGui.IgnoreGuiInset = true
ModeGui.DisplayOrder = 2501
ModeGui.Enabled = false
ModeGui.Parent = PlayerGui

local ActGui = Instance.new("ScreenGui")
ActGui.Name = "Rana.VSHubActionButtons"
ActGui.ResetOnSpawn = false
ActGui.IgnoreGuiInset = true
ActGui.DisplayOrder = 2500
ActGui.Enabled = false
ActGui.Parent = PlayerGui

local modeRefs = {}
local actRefs = {}

-- Shape chỉ áp dụng cho ACTION buttons (Drop/Insta/TP/Sentry/Steal).
-- 3-mode speed (Normal/Lagger/Custom) LUÔN giữ style mặc định (Pill) như video.
function applyCorner(btn, forceShape)
	if not btn then return end
	local shape = tostring(forceShape or St.btnShape or "FOUNDED"):upper()
	if shape == "ROUND" then shape = "CIRCLE" elseif shape == "BOX" then shape = "FOUNDED" end
	-- Xoá hết UICorner cũ rồi tạo lại (tránh kẹt radius cũ)
	for _, ch in ipairs(btn:GetChildren()) do
 if ch:IsA("UICorner") then pcall(function() ch:Destroy() end) end
	end
	local rad
	if shape == "CIRCLE" then
 rad = UDim.new(1, 0)
 elseif shape == "SQUARE" then
 rad = UDim.new(0, 4)
 else
 rad = UDim.new(0, 12)
 end
	local c = Instance.new("UICorner")
	c.Name = "ShapeCorner"
	c.CornerRadius = rad
	c.Parent = btn
	-- đồng bộ ảnh nền / dim
	for _, ch in ipairs(btn:GetChildren()) do
 if ch:IsA("ImageLabel") or (ch:IsA("Frame") and ch.Name ~= "BtnTextOverlay") then
 for _, sub in ipairs(ch:GetChildren()) do
 if sub:IsA("UICorner") then pcall(function() sub:Destroy() end) end
 end
 local c2 = Instance.new("UICorner")
 c2.Name = "ShapeCorner"
 c2.CornerRadius = rad
 c2.Parent = ch
 end
	end
end

function applyCornerToChildren(btn, shape)
	if not btn then return end
	shape = tostring(shape or St.btnShape or "FOUNDED"):upper()
	if shape == "ROUND" then shape = "CIRCLE" elseif shape == "BOX" then shape = "FOUNDED" end
	local rad
	if shape == "CIRCLE" then rad = UDim.new(1, 0)
	elseif shape == "SQUARE" then rad = UDim.new(0, 4)
	else rad = UDim.new(0, 12)
	end
	for _, ch in ipairs(btn:GetChildren()) do
 if ch:IsA("ImageLabel") or (ch:IsA("Frame") and ch.Name ~= "BtnTextOverlay") then
 for _, sub in ipairs(ch:GetChildren()) do
 if sub:IsA("UICorner") then pcall(function() sub:Destroy() end) end
 end
 local c = Instance.new("UICorner")
 c.Name = "ShapeCorner"
 c.CornerRadius = rad
 c.Parent = ch
 end
	end
end

local MOB_BTN_IMAGE_IDS = {
	126832513729779, 81347949983999, 76940707345653, 100648743625857,
	73857705647948, 86237559415852, 81474116937197, 86668822094069,
	108384375206363, 86791880986403, 126414648469223,
}
function applyEmpireBtnBg(btn, index)
	if not btn then return end
	local old = btn:FindFirstChild("BtnBgImage")
	if old then old:Destroy() end
	local list = MOB_BTN_IMAGE_IDS
	local id = list[((tonumber(index) or 1) - 1) % #list + 1]
	if not id or id <= 0 then return end
	-- nền đậm hơn (12Hub style) nhưng chữ vẫn đọc được
	btn.BackgroundTransparency = 0.35
	btn.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
	local bgImg = Instance.new("ImageLabel")
	bgImg.Name = "BtnBgImage"
	bgImg.BackgroundTransparency = 1
	bgImg.Image = "rbxassetid://" .. tostring(id)
	bgImg.ImageTransparency = 0.08 -- đậm hơn (thấp = rõ ảnh hơn)
	bgImg.ScaleType = Enum.ScaleType.Crop
	bgImg.Size = UDim2.new(1, 0, 1, 0)
	bgImg.ZIndex = (btn.ZIndex or 1)
	bgImg.Active = false
	bgImg.Selectable = false
	bgImg.Parent = btn
	-- lớp tối nhẹ để chữ trắng nổi
	local dim = Instance.new("Frame")
	dim.Name = "BtnDim"
	dim.Size = UDim2.new(1, 0, 1, 0)
	dim.BackgroundColor3 = Color3.new(0, 0, 0)
	dim.BackgroundTransparency = 0.45
	dim.BorderSizePixel = 0
	dim.ZIndex = (btn.ZIndex or 1) + 1
	dim.Active = false
	dim.Selectable = false
	dim.Parent = btn
	local currentShape = tostring(St.btnShape or "FOUNDED"):upper()
	if currentShape == "ROUND" then currentShape = "CIRCLE" elseif currentShape == "BOX" then currentShape = "FOUNDED" end
	local rad
	if currentShape == "CIRCLE" then rad = UDim.new(1, 0)
	elseif currentShape == "SQUARE" then rad = UDim.new(0, 4)
	else rad = UDim.new(0, 12)
	end
	local c = Instance.new("UICorner")
	c.CornerRadius = rad
	c.Parent = bgImg
	local c2 = Instance.new("UICorner")
	c2.CornerRadius = rad
	c2.Parent = dim
	-- chữ trên cùng
	btn.TextTransparency = 0
	btn.TextStrokeTransparency = 0.4
	btn.TextStrokeColor3 = Color3.new(0, 0, 0)
	pcall(function() btn.ZIndex = math.max(btn.ZIndex or 1, 100) end)
	-- Empire gradient stroke on button
	local st = btn:FindFirstChildOfClass("UIStroke")
	if st and not st:FindFirstChild("EmpireOutlineGrad") then
 st.Thickness = 1.6
 st.Transparency = 0.1
 local g = Instance.new("UIGradient")
 g.Name = "EmpireOutlineGrad"
 g.Color = ColorSequence.new({
 ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
 ColorSequenceKeypoint.new(0.35, Color3.fromRGB(255, 80, 180)),
 ColorSequenceKeypoint.new(0.7, Color3.fromRGB(180, 80, 255)),
 ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
 })
 g.Parent = st
 task.spawn(function()
 local t0 = tick()
 while st and st.Parent do
 g.Rotation = ((tick() - t0) * 50) % 360
 task.wait(0.04)
 end
 end)
	end
end

----------------------------------------------------------------
-- SPEED V2 MODE BAR (full GUI from RanaVS Clean) — 3 mode
----------------------------------------------------------------
local v2BarButtons = {}
function _G.RanaVSBuildV2ModeBar()
	_G.RanaVSSpeedMethod = "V2"
	pcall(function()
 local old = PlayerGui:FindFirstChild("Rana.VSV2ModeBar")
 if old then old:Destroy() end
	end)
	if not St.mobileBtns then return end
 local sc = 1
	local function modeHeight(modeName)
		return 50
	end
	local V2_BTN_W = math.max(72, math.floor(88 * sc))
	local V2_CORNER = 12	local MODE_COLORS = {
 Normal = {
 onBg = Color3.fromRGB(255, 200, 210), onTxt = Color3.fromRGB(30, 20, 30),
 offBg = Color3.fromRGB(255, 255, 255), offTxt = Color3.fromRGB(25, 25, 30),
 stroke = Color3.fromRGB(255, 160, 180),
 },
 Lagger = {
 onBg = Color3.fromRGB(255, 200, 210), onTxt = Color3.fromRGB(30, 20, 30),
 offBg = Color3.fromRGB(255, 255, 255), offTxt = Color3.fromRGB(25, 25, 30),
 stroke = Color3.fromRGB(255, 160, 180),
 },
 Custom = {
 onBg = Color3.fromRGB(255, 200, 210), onTxt = Color3.fromRGB(30, 20, 30),
 offBg = Color3.fromRGB(255, 255, 255), offTxt = Color3.fromRGB(25, 25, 30),
 stroke = Color3.fromRGB(255, 160, 180),
 },
	}
	local gui = Instance.new("ScreenGui")
	gui.Name = "Rana.VSV2ModeBar"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.DisplayOrder = 95
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = PlayerGui
	v2BarButtons = {}
	local function styleV2Btn(btn, modeName, active)
 local col = MODE_COLORS[modeName] or MODE_COLORS.Normal
 btn.BackgroundColor3 = active and col.onBg or col.offBg
 btn.TextColor3 = active and col.onTxt or col.offTxt
 btn.Font = active and Enum.Font.GothamBlack or Enum.Font.GothamBold
 local st = btn:FindFirstChild("V2BaseStroke") or btn:FindFirstChildOfClass("UIStroke")
 if st then
   st.Name = "V2BaseStroke"
   st.Color = active and col.stroke or Color3.fromRGB(210,210,220)
   st.Transparency = active and 0.10 or 0.36
   st.Thickness = active and 1.55 or 1
 end
 local oldGlow=btn:FindFirstChild("V2ActiveGradient")
 if oldGlow then oldGlow:Destroy() end
 if active then
   local edge=Instance.new("UIStroke")
   edge.Name="V2ActiveGradient"
   edge.Thickness=2.2
   edge.Transparency=0.02
   edge.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
   edge.Parent=btn
   local g=Instance.new("UIGradient")
   g.Color=ColorSequence.new({
     ColorSequenceKeypoint.new(0.00,Color3.fromRGB(255,255,255)),
     ColorSequenceKeypoint.new(0.32,Color3.fromRGB(205,150,255)),
     ColorSequenceKeypoint.new(0.58,Color3.fromRGB(255,255,255)),
     ColorSequenceKeypoint.new(1.00,Color3.fromRGB(157,55,235)),
   })
   g.Parent=edge
   task.spawn(function()
     local rot=0
     while edge and edge.Parent do
       rot=(rot+2)%360
       g.Rotation=rot
       task.wait(0.03)
     end
   end)
 end
 end	
local function posFromSaved(modeName, order)
 local key = "V2_" .. modeName
 local t = St._btnPos and St._btnPos[key]
 if type(t) == "table" and t[1] ~= nil then
 return UDim2.new(t[1], t[2], t[3], t[4])
 end
 local gap = 10
 local total = (V2_BTN_W + gap) * 3 - gap
 return UDim2.new(0.5, -total / 2 + (order - 1) * (V2_BTN_W + gap), 1, -118)
	end
	local function saveV2Pos(modeName, holder)
 St._btnPos = St._btnPos or {}
 St._btnPos["V2_" .. modeName] = {
 holder.Position.X.Scale, holder.Position.X.Offset,
 holder.Position.Y.Scale, holder.Position.Y.Offset,
 }
 pcall(saveCfg)
	end
	local function makeV2ModeBtn(modeName, label, order)
 local holder = Instance.new("Frame")
 holder.Name = "V2MH_" .. modeName
 holder.Size = UDim2.new(0, V2_BTN_W, 0, modeHeight(modeName))
 holder.Position = posFromSaved(modeName, order)
 holder.BackgroundTransparency = 1
 holder.BorderSizePixel = 0
 holder.ZIndex = 10
 holder.Active = true
 holder.Parent = gui
 local btn = Instance.new("TextButton")
 btn.Name = "V2Bar_" .. modeName
 btn.Size = UDim2.new(1, 0, 1, 0)
 btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
 btn.Text = label
 btn.TextColor3 = Color3.fromRGB(25, 25, 30)
 btn.Font = Enum.Font.GothamBlack
 btn.TextSize = 13
 btn.AutoButtonColor = false
 btn.ZIndex = 12
 btn.Parent = holder
 Instance.new("UICorner", btn).CornerRadius = UDim.new(0, V2_CORNER)
 local st = Instance.new("UIStroke", btn)
 st.Thickness = 1
 st.Transparency = 0.35
 st.Color = Color3.fromRGB(210, 210, 220)
 st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
 styleV2Btn(btn, modeName, St.activeMode == modeName)
 local activeInput, pressPos, holderStart = nil, nil, nil
 local moved, lastClick = false, 0
 local function runClick()
 local now = tick()
 if now - lastClick < 0.08 then return end
 lastClick = now
 if type(setActiveMode) == "function" then
 setActiveMode(modeName)
 else
 St.activeMode = modeName
 end
 for n, e in pairs(v2BarButtons) do
 if e and e.btn then styleV2Btn(e.btn, n, n == modeName) end
 end
 -- sync old modeRefs if any
 for n, e in pairs(modeRefs or {}) do
 if e and e.style then pcall(e.style, n == modeName)
 elseif e and e.btn then
 e.btn.BackgroundColor3 = (n == modeName) and Color3.fromRGB(255, 200, 210) or Color3.fromRGB(255, 255, 255)
 end
 end
 end
 btn.InputBegan:Connect(function(input)
 if input.UserInputType ~= Enum.UserInputType.Touch and input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
 activeInput = input
 pressPos = input.Position
 holderStart = holder.Position
 moved = false
 input.Changed:Connect(function()
 if input.UserInputState ~= Enum.UserInputState.End or activeInput ~= input then return end
 activeInput = nil
 if not moved then
 runClick()
 elseif not St.guiLock then
 saveV2Pos(modeName, holder)
 end
 end)
 end)
 btn.Activated:Connect(function()
 if moved then return end
 runClick()
 end)
 UIS.InputChanged:Connect(function(input)
 if not activeInput or not pressPos or not holderStart then return end
 if activeInput.UserInputType == Enum.UserInputType.Touch then
 if input ~= activeInput then return end
 elseif activeInput.UserInputType == Enum.UserInputType.MouseButton1 then
 if input.UserInputType ~= Enum.UserInputType.MouseMovement then return end
 else return end
 local dx = input.Position.X - pressPos.X
 local dy = input.Position.Y - pressPos.Y
 if math.abs(dx) > 4 or math.abs(dy) > 4 then moved = true end
 if moved and not St.guiLock then
 holder.Position = UDim2.new(holderStart.X.Scale, holderStart.X.Offset + dx, holderStart.Y.Scale, holderStart.Y.Offset + dy)
 end
 end)
 v2BarButtons[modeName] = { holder = holder, btn = btn }
 return btn
	end
	makeV2ModeBtn("Normal", "NORMAL", 1)
	makeV2ModeBtn("Lagger", "LAGGER", 2)
	makeV2ModeBtn("Custom", "CUSTOM", 3)
	_G.RanaVSRefreshV2ModeBar = function()
 for n, e in pairs(v2BarButtons) do
 if e and e.btn then styleV2Btn(e.btn, n, St.activeMode == n) end
 end
	end
end


function makeModeBtn(name, order)
	-- Size Speed 3Mode: tăng chiều cao; width ổn định
	local sc = 1
	local modeBase = 50
	local V2_CORNER = 12
	local h = modeBase
	local w = 88
	local holder = Instance.new("Frame")
	holder.Name = "M_" .. name
	holder.Size = UDim2.new(0, w, 0, h)
	local gap = 10
	local total = (w + gap) * 3 - gap
	holder.Position = UDim2.new(0.5, -total / 2 + (order - 1) * (w + gap), 1, -118)
	holder.BackgroundTransparency = 1
	holder.BorderSizePixel = 0
	holder.ZIndex = 10
	holder.Active = true
	holder.Parent = ModeGui
	-- restore saved pos
	pcall(function()
 local p = St._btnPos and St._btnPos["M_" .. name]
 if type(p) == "table" and p[1] ~= nil then
 holder.Position = UDim2.new(p[1], p[2], p[3], p[4])
 end
	end)
	local btn = Instance.new("TextButton")
	btn.Name = "ModeBtn"
	btn.Size = UDim2.new(1, 0, 1, 0)
	btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	btn.Text = name:upper()
	if name == "Normal" then btn.Text = "NORMAL" end
	btn.TextColor3 = Color3.fromRGB(25, 25, 30)
	btn.Font = Enum.Font.GothamBlack
	btn.TextSize = math.clamp(math.floor(h * 0.36), 11, 14)
	btn.AutoButtonColor = false
	btn.ZIndex = 12
	btn.Active = true
	btn.Parent = holder
	local corner = Instance.new("UICorner", btn)
	corner.CornerRadius = UDim.new(0, V2_CORNER)
	local st = Instance.new("UIStroke", btn)
	st.Thickness = 1
	st.Transparency = 0.35
	st.Color = Color3.fromRGB(210, 210, 220)
	st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	local function styleMode(on)
 if on then
 btn.BackgroundColor3 = Color3.fromRGB(255, 200, 210)
 btn.TextColor3 = Color3.fromRGB(30, 20, 30)
 st.Color = Color3.fromRGB(255, 160, 180)
 st.Transparency = 0.1
 else
 btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
 btn.TextColor3 = Color3.fromRGB(25, 25, 30)
 st.Color = Color3.fromRGB(210, 210, 220)
 st.Transparency = 0.35
 end
	end
	styleMode(St.activeMode == name)
	local dragging, dragStart, startPos, moved = false, nil, nil, false
	local movedDistance = 0
	local TAP_MAX = 22
	btn.InputBegan:Connect(function(input)
 if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
 dragging = true
 moved = false
 movedDistance = 0
 dragStart = input.Position
 startPos = holder.Position
 end
	end)
	btn.InputChanged:Connect(function(input)
 if not dragging or not dragStart then return end
 if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
 local d = input.Position - dragStart
 movedDistance = d.Magnitude
 if movedDistance > 8 then moved = true end
 if not St.guiLock and moved then
 holder.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
 end
 end
	end)
	local function pick()
 setActiveMode(name)
 -- refresh all mode styles
 for n, e in pairs(modeRefs) do
 if e and e.btn and e.style then
 e.style(St.activeMode == n)
 elseif e and e.btn then
 local on = St.activeMode == n
 e.btn.BackgroundColor3 = on and Color3.fromRGB(255, 200, 210) or Color3.fromRGB(255, 255, 255)
 e.btn.TextColor3 = on and Color3.fromRGB(30, 20, 30) or Color3.fromRGB(25, 25, 30)
 end
 end
 styleMode(true)
	end
	btn.InputEnded:Connect(function(input)
 if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
 if not dragging then return end
 dragging = false
 if not moved and movedDistance < TAP_MAX then
 pick()
 elseif moved and not St.guiLock then
 savePos(holder, "M_" .. name)
 end
 movedDistance = 0
 dragStart = nil
	end)
	btn.MouseButton1Click:Connect(function()
 if moved then return end
 pick()
	end)
	btn.Activated:Connect(function()
 if moved then return end
 pick()
	end)
	modeRefs[name] = { holder = holder, btn = btn, style = styleMode }
end


local psLoopConn = nil
local function findToolExact(toolName)
    local char = LP.Character
    local bp = LP:FindFirstChildOfClass("Backpack")
    local function scan(container)
        if not container then return nil end
        local exact = container:FindFirstChild(toolName)
        if exact and exact:IsA("Tool") and exact.Name == toolName then return exact end
        for _, obj in ipairs(container:GetChildren()) do
            if obj:IsA("Tool") and type(obj.Name) == "string" and obj.Name:lower():sub(1, #toolName) == toolName:lower() then return obj end
        end
        return nil
    end
    return scan(char) or scan(bp)
end

local function equipExactTool(toolName)
    local tool = findToolExact(toolName)
    if not tool then return nil end
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum then pcall(function() hum:EquipTool(tool) end) end
    return tool
end

local function isEquippedExact(toolName)
    local char = LP.Character
    if not char then return false end
    local tool = char:FindFirstChild(toolName)
    if tool and tool:IsA("Tool") and tool.Name == toolName then return true end
    for _, obj in ipairs(char:GetChildren()) do
        if obj:IsA("Tool") and type(obj.Name) == "string" and obj.Name:lower():sub(1, #toolName) == toolName:lower() then return true end
    end
    return false
end

-- Web Slinger support for the mobile action button. This detects the equipped
-- Tool, matching Nova Moon's own readiness check. Target-character CFrame forcing
-- from the source script is intentionally not used; the action calls Tool:Activate().
local function isWebSlingerTool(tool)
    if not tool or not tool:IsA("Tool") then return false end
    local normalized = tostring(tool.Name):lower():gsub("[%s_%-]", "")
    return normalized == "webslinger" or normalized == "websinger"
end

local function findWebSlingerTool()
    local char = LP.Character
    local backpack = LP:FindFirstChildOfClass("Backpack")
    for _, container in ipairs({char, backpack}) do
        if container then
            for _, child in ipairs(container:GetChildren()) do
                if isWebSlingerTool(child) then return child end
            end
        end
    end
    return nil
end

local function isWebSlingerEquipped()
    local char = LP.Character
    if not char then return false end
    for _, child in ipairs(char:GetChildren()) do
        if isWebSlingerTool(child) then return true end
    end
    return false
end


-- ═══════════════════════════════════════════════════════════════
--  NOVAMOON KILL PORT (full logic from NovaMoonHub_NoRed)
--  KILL loop: fling target ±20 studs via Heartbeat, ESP arrow +
--  distance label, death detection, Auto-TP to safe position.
-- ═══════════════════════════════════════════════════════════════
local NM_KILL_GUI_OK = false
local NM_isKilling = false
local NM_killLoop = nil
local NM_currentTarget = nil
local NM_diedConn = nil
local NM_healthConn = nil
local NM_charConn = nil

local NM_SAFE_POSITION_1 = Vector3.new(-474.83, -6.59, 23.09)
local NM_SAFE_POSITION_2 = Vector3.new(-484.00, -4.62, 21.44)

local NM_notifyGui = Instance.new("ScreenGui")
NM_notifyGui.Name = "RanaVS_NMKill_Notify"
NM_notifyGui.ResetOnSpawn = false
NM_notifyGui.IgnoreGuiInset = true
NM_notifyGui.DisplayOrder = 999
local okNg = pcall(function() NM_notifyGui.Parent = (gethui and gethui()) or game:GetService("CoreGui") end)
if not okNg then NM_notifyGui.Parent = PlayerGui end

local function NMNotify(text, green)
    local notif = Instance.new("TextLabel")
    notif.Size = UDim2.new(0, 280, 0, 36)
    notif.Position = UDim2.new(0.5, -140, 0, 10)
    notif.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    notif.BackgroundTransparency = 0.1
    notif.Text = tostring(text)
    notif.Font = Enum.Font.GothamBold
    notif.TextSize = 13
    notif.TextColor3 = green and Color3.fromRGB(120, 220, 130) or Color3.fromRGB(240, 240, 240)
    notif.ZIndex = 999
    notif.Parent = NM_notifyGui
    Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 10)
    local st = Instance.new("UIStroke")
    st.Thickness = 1
    st.Color = Color3.fromRGB(255, 255, 255)
    st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    st.Parent = notif
    task.delay(3, function() notif:Destroy() end)
end

local NM_espGui = Instance.new("ScreenGui")
NM_espGui.Name = "RanaVS_NMKill_ESP"
NM_espGui.ResetOnSpawn = false
NM_espGui.IgnoreGuiInset = true
NM_espGui.DisplayOrder = 998
local okEsp = pcall(function() NM_espGui.Parent = (gethui and gethui()) or game:GetService("CoreGui") end)
if not okEsp then NM_espGui.Parent = PlayerGui end

local NM_arrow = Instance.new("ImageLabel")
NM_arrow.Name = "TargetArrow"
NM_arrow.Size = UDim2.new(0, 36, 0, 36)
NM_arrow.BackgroundTransparency = 1
NM_arrow.Image = "rbxassetid://13221883044"
NM_arrow.ImageColor3 = Color3.fromRGB(255, 255, 255)
NM_arrow.Visible = false
NM_arrow.Parent = NM_espGui

local NM_distLbl = Instance.new("TextLabel")
NM_distLbl.Name = "DistanceText"
NM_distLbl.Size = UDim2.new(0, 100, 0, 20)
NM_distLbl.BackgroundTransparency = 1
NM_distLbl.Text = ""
NM_distLbl.Font = Enum.Font.GothamBold
NM_distLbl.TextSize = 14
NM_distLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
NM_distLbl.TextStrokeTransparency = 0.5
NM_distLbl.Visible = false
NM_distLbl.Parent = NM_espGui

local function NMHasTool(toolName)
    local char = LP.Character
    if not char then return false end
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Tool") and child.Name == toolName then return true end
    end
    for _, handName in ipairs({"RightHand", "LeftHand", "Right Arm", "Left Arm"}) do
        local hand = char:FindFirstChild(handName)
        if hand then
            for _, child in ipairs(hand:GetChildren()) do
                if child.Name == toolName then return true end
            end
        end
    end
    return false
end

local function NMHasWebSlinger()
    return NMHasTool("Web Slinger")
end

local function NMHasFlyingCarpet()
    return NMHasTool("Flying Carpet")
end

local function NMEquipFlyingCarpet()
    local char = LP.Character
    if not char then return false end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return false end
    local backpack = LP:FindFirstChild("Backpack")
    if backpack then
        local carpet = backpack:FindFirstChild("Flying Carpet")
        if carpet and carpet:IsA("Tool") then
            humanoid:EquipTool(carpet)
            NMNotify("✅ Equipped Flying Carpet!", true)
            return true
        end
    end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == "Flying Carpet" and obj:IsA("Tool") then
            local success = pcall(function() obj.Parent = char end)
            if success then
                NMNotify("✅ Picked up Flying Carpet!", true)
                return true
            end
        end
    end
    return false
end

local function NMGetNearestPlayer()
    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil, nil end
    local closest, dist = nil, math.huge
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local part = p.Character.HumanoidRootPart
            local mag = (part.Position - hrp.Position).Magnitude
            if mag < dist then
                dist = mag
                closest = p
            end
        end
    end
    return closest, dist
end

local function NMUpdateESP(target)
    local camera = workspace.CurrentCamera
    if not target or not target.Character or not camera then
        NM_arrow.Visible = false
        NM_distLbl.Visible = false
        return
    end
    local targetHrp = target.Character:FindFirstChild("HumanoidRootPart")
    local myHrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not targetHrp or not myHrp then
        NM_arrow.Visible = false
        NM_distLbl.Visible = false
        return
    end
    local targetPos = targetHrp.Position
    local myPos = myHrp.Position
    local distance = (targetPos - myPos).Magnitude
    local screenPos, onScreen = camera:WorldToViewportPoint(targetPos)
    if onScreen then
        NM_arrow.Position = UDim2.new(0, screenPos.X - 18, 0, screenPos.Y - 45)
        NM_arrow.Rotation = 0
        NM_arrow.ImageColor3 = Color3.fromRGB(255, 255, 255)
    else
        local camPos = camera.CFrame.Position
        local camLook = camera.CFrame.LookVector
        local toTarget = (targetPos - camPos).Unit
        local right = camera.CFrame.RightVector
        local angle = math.atan2(toTarget:Dot(right), toTarget:Dot(camLook))
        local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
        local edgeDist = math.min(camera.ViewportSize.X, camera.ViewportSize.Y) * 0.4
        local arrowX = screenCenter.X + math.sin(angle) * edgeDist
        local arrowY = screenCenter.Y - math.cos(angle) * edgeDist * 0.8
        NM_arrow.Position = UDim2.new(0, arrowX - 18, 0, arrowY - 18)
        NM_arrow.Rotation = math.deg(angle)
        NM_arrow.ImageColor3 = Color3.fromRGB(255, 255, 255)
    end
    NM_arrow.Visible = true
    NM_distLbl.Text = string.format("%.1f studs", distance)
    NM_distLbl.Position = UDim2.new(0, NM_arrow.Position.X.Offset + 42, 0, NM_arrow.Position.Y.Offset + 8)
    NM_distLbl.Visible = true
end

local function NMSetupDeathDetection(target)
    if NM_diedConn then NM_diedConn:Disconnect(); NM_diedConn = nil end
    if NM_healthConn then NM_healthConn:Disconnect(); NM_healthConn = nil end
    if NM_charConn then NM_charConn:Disconnect(); NM_charConn = nil end
    if not target or not target.Character then return end
    local humanoid = target.Character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        NM_diedConn = humanoid.Died:Connect(function()
            task.wait(0.5)
            if _G.RanaVSNMStopKill then _G.RanaVSNMStopKill() end
        end)
        NM_healthConn = humanoid:GetPropertyChangedSignal("Health"):Connect(function()
            if humanoid.Health <= 0 then
                task.wait(0.5)
                if _G.RanaVSNMStopKill then _G.RanaVSNMStopKill() end
            end
        end)
    end
    NM_charConn = target.CharacterRemoving:Connect(function()
        task.wait(0.5)
        if _G.RanaVSNMStopKill then _G.RanaVSNMStopKill() end
    end)
end

local function NMTeleportToSafe()
    local char = LP.Character
    if not char then NMNotify("❌ No character found", false) return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then NMNotify("❌ No HumanoidRootPart", false) return end
    if not NMHasFlyingCarpet() then
        NMNotify("🔄 Getting Flying Carpet...", false)
        local gotCarpet = NMEquipFlyingCarpet()
        if not gotCarpet then
            NMNotify("❌ Flying Carpet not found!", false)
            return
        end
        task.wait(0.5)
    end
    if not NMHasFlyingCarpet() then
        NMNotify("❌ Failed to equip Flying Carpet!", false)
        return
    end
    NMNotify("✅ Teleporting...", true)
    local myPos = hrp.Position
    local dist1 = (NM_SAFE_POSITION_1 - myPos).Magnitude
    local dist2 = (NM_SAFE_POSITION_2 - myPos).Magnitude
    local targetPos = dist1 < dist2 and NM_SAFE_POSITION_1 or NM_SAFE_POSITION_2
    hrp.CFrame = CFrame.new(targetPos)
    NMNotify("✅ Teleported!", true)
end

function _G.RanaVSNMStopKill()
    if not NM_isKilling then return end
    NM_isKilling = false
    NM_currentTarget = nil
    if NM_diedConn then NM_diedConn:Disconnect(); NM_diedConn = nil end
    if NM_healthConn then NM_healthConn:Disconnect(); NM_healthConn = nil end
    if NM_charConn then NM_charConn:Disconnect(); NM_charConn = nil end
    if NM_killLoop then NM_killLoop:Disconnect(); NM_killLoop = nil end
    NM_arrow.Visible = false
    NM_distLbl.Visible = false
    NMNotify("🛑 Kill stopped", false)
    NMTeleportToSafe()
    if _G.RanaVSRefreshWebsingerBtn then task.defer(_G.RanaVSRefreshWebsingerBtn) end
end

function _G.RanaVSNMKillState()
    return NM_isKilling == true
end

function _G.RanaVSNMStartKill()
    if NM_isKilling then return end
    if not NMHasWebSlinger() then
        NMNotify("❌ Need Web Slinger!", false)
        return
    end
    local target, dist = NMGetNearestPlayer()
    if not target then
        NMNotify("❌ No player nearby", false)
        return
    end
    NM_isKilling = true
    NM_currentTarget = target
    NMSetupDeathDetection(target)
    NMNotify(string.format("🎯 Killing %s (%.0f studs)", target.Name, dist or 0), true)
    if _G.RanaVSRefreshWebsingerBtn then task.defer(_G.RanaVSRefreshWebsingerBtn) end

    local above = true
    NM_killLoop = RS.Heartbeat:Connect(function()
        if not NMHasWebSlinger() then
            _G.RanaVSNMStopKill()
            return
        end
        if not NM_currentTarget or not NM_currentTarget.Character then
            _G.RanaVSNMStopKill()
            return
        end
        local tHrp = NM_currentTarget.Character:FindFirstChild("HumanoidRootPart")
        local tHumanoid = NM_currentTarget.Character:FindFirstChildOfClass("Humanoid")
        if not tHrp or not tHumanoid or tHumanoid.Health <= 0 then
            task.wait(0.3)
            _G.RanaVSNMStopKill()
            return
        end
        if above then
            tHrp.CFrame = tHrp.CFrame + Vector3.new(0, 20, 0)
        else
            tHrp.CFrame = tHrp.CFrame + Vector3.new(0, -20, 0)
        end
        above = not above
        NMUpdateESP(NM_currentTarget)
    end)

    task.delay(10, function()
        if NM_isKilling then _G.RanaVSNMStopKill() end
    end)
end

-- Grab detection: Web Slinger rope attached to another player
function _G.RanaVSIsGrabbingPlayer()
    local char = LP.Character
    if not char then return false end
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("RopeConstraint") then
            local a0, a1 = obj.Attachment0, obj.Attachment1
            if a0 and a1 then
                local p0, p1 = a0.Parent, a1.Parent
                local myChar, otherChar = nil, nil
                for _, part in ipairs({p0, p1}) do
                    if part and part:IsA("BasePart") then
                        local pc = part.Parent
                        if pc == char then
                            myChar = pc
                        elseif pc and Players:GetPlayerFromCharacter(pc) and Players:GetPlayerFromCharacter(pc) ~= LP then
                            otherChar = pc
                        end
                    end
                end
                if myChar and otherChar then return true end
            end
        end
    end
    return false
end

function _G.RanaVSNMKillToggle()
    if NM_isKilling then
        _G.RanaVSNMStopKill()
    else
        _G.RanaVSNMStartKill()
    end
end
-- ═══════════════ END NOVAMOON KILL PORT ═══════════════

local function runWebsingerAction()
    -- This action runs only when the user presses the mobile button or its keybind.
    -- It aims the equipped Web Slinger using the existing Tool Aimbot target, then
    -- activates the Tool normally. It does not force another character's CFrame.
    local tool = findWebSlingerTool()
    if not tool then
        warn("[12Hub] Web Slinger not found in Character or Backpack.")
        return
    end

    local char = LP.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if not char or not humanoid or humanoid.Health <= 0 then return end

    if tool.Parent ~= char then
        local equipped = pcall(function() humanoid:EquipTool(tool) end)
        if not equipped then return end
        task.wait(0.12)
    end
    if tool.Parent ~= char then
        warn("[12Hub] Web Slinger could not be equipped.")
        return
    end

    -- Use the same nearby target selected by the existing Tool Aimbot.
    local targetRoot = nil
    if type(bestEnemy) == "function" then
        local ok, result = pcall(bestEnemy)
        if ok then targetRoot = result end
    end
    if not targetRoot or not targetRoot.Parent or not targetRoot:IsA("BasePart") then
        warn("[12Hub] No valid nearby Tool Aimbot target (within its normal range).")
        if _G.RanaVSRefreshWebsingerBtn then task.defer(_G.RanaVSRefreshWebsingerBtn) end
        return
    end

    local targetCharacter = targetRoot.Parent
    local targetHumanoid = targetCharacter:FindFirstChildOfClass("Humanoid")
    local targetPlayer = Players:GetPlayerFromCharacter(targetCharacter)
    if not targetPlayer or targetPlayer == LP or not targetHumanoid or targetHumanoid.Health <= 0 then
        warn("[12Hub] Aimbot target is no longer valid.")
        return
    end

    -- Set the PlayerMouse aim immediately before activation so this press uses
    -- the current target rather than waiting for the next RenderStepped update.
    local pm = nil
    if type(getMouse) == "function" then
        local ok, result = pcall(getMouse)
        if ok then pm = result end
    end
    if pm then
        pcall(function()
            local velocity = targetRoot.AssemblyLinearVelocity or Vector3.zero
            pm.Hit = CFrame.new(targetRoot.Position + velocity * 0.1)
            pm.Target = targetRoot
        end)
    elseif type(overrideMouse) == "function" then
        pcall(overrideMouse)
    end

    local activated, err = pcall(function() tool:Activate() end)
    if not activated then
        warn("[12Hub] Web Slinger activation failed:", err)
    end

    if _G.RanaVSRefreshWebsingerBtn then
        task.defer(_G.RanaVSRefreshWebsingerBtn)
    end
end

local function refreshToolButtonVisuals()
    local medEquipped = isEquippedExact("Medusa")
    local psEquipped = isEquippedExact("Paintball Gun")
    St.medOn = medEquipped
    St.psOn = psEquipped
    local med = actRefs and actRefs.med
    local ps = actRefs and actRefs.ps
    if med and med.btn then
        applyActBtnState(med.btn, false, "MED\nEQUIP", "MED\nEQUIP")
    end
    if ps and ps.btn then
        applyActBtnState(ps.btn, psEquipped, "PS", "PS")
    end
end

local function setMedButton()
    local tool = equipExactTool("Medusa")
    St.medOn = tool ~= nil and isEquippedExact("Medusa") or false
    refreshToolButtonVisuals()
end

local function stopPS()
    St.psOn = false
    if psLoopConn then
        pcall(function() psLoopConn:Disconnect() end)
        psLoopConn = nil
    end
    refreshToolButtonVisuals()
end

local function startPS()
    local tool = equipExactTool("Paintball Gun")
    if not tool or not isEquippedExact("Paintball Gun") then
        St.psOn = false
        refreshToolButtonVisuals()
        return
    end
    St.psOn = true
    if psLoopConn then pcall(function() psLoopConn:Disconnect() end) end
    psLoopConn = RS.Heartbeat:Connect(function()
        if not St.psOn then return end
        local current = LP.Character and LP.Character:FindFirstChild("Paintball Gun")
        -- Do not re-equip from Backpack. Selecting another Tool must turn PS off.
        if not current or not current:IsA("Tool") or current.Name ~= "Paintball Gun" then
            stopPS()
            return
        end
        pcall(function() current:Activate() end)
    end)
    refreshToolButtonVisuals()
end

local function togglePS()
    if isEquippedExact("Paintball Gun") then
        stopPS()
    else
        startPS()
    end
end

-- LaPeak-style equipped-tool watcher. Visual state is based on the Tool actually
-- held by the player; merely owning the Tool in Backpack does not keep the button ON.
if not _G.__RanaLaPeakToolVisualWatcher then
    _G.__RanaLaPeakToolVisualWatcher = true
    local function hookCharacter(char)
        if not char then return end
        char.ChildAdded:Connect(function(obj)
            if obj:IsA("Tool") and (obj.Name == "Paintball Gun" or obj.Name == "Medusa") then
                task.defer(refreshToolButtonVisuals)
            end
        end)
        char.ChildRemoved:Connect(function(obj)
            if obj:IsA("Tool") and (obj.Name == "Paintball Gun" or obj.Name == "Medusa") then
                task.defer(refreshToolButtonVisuals)
            end
        end)
        task.defer(refreshToolButtonVisuals)
    end
    if LP.Character then hookCharacter(LP.Character) end
    LP.CharacterAdded:Connect(function(char)
        if psLoopConn then pcall(function() psLoopConn:Disconnect() end); psLoopConn = nil end
        St.psOn = false
        St.medOn = false
        hookCharacter(char)
    end)
end
local function flashActionButton(entry)
    if not entry or not entry.btn or not entry.btn.Parent then return end
    local btn = entry.btn
    local stroke = entry.stroke
    local grad = entry.gradient
    btn.BackgroundColor3 = Color3.fromRGB(0,0,0)
    btn.BackgroundTransparency = 0
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Font = Enum.Font.GothamMedium
    if stroke then
        stroke.Color = Color3.fromRGB(255,255,255)
        stroke.Thickness = 1.8
        stroke.Transparency = 0.05
    end
    if grad then
        grad.Color = ColorSequence.new(Color3.fromRGB(0,0,0))
        grad.Transparency = NumberSequence.new(0)
    end
    task.delay(0.12, function()
        if entry.btn and entry.btn.Parent then
            if entry.key == "drop" or entry.key == "tp" or entry.key == "tpBest" or entry.key == "insta" or entry.key == "med" then
                -- Momentary action buttons always return to the normal white/black-text state.
                entry.btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
                entry.btn.BackgroundTransparency = 0
                entry.btn.TextColor3 = Color3.fromRGB(25,25,30)
                entry.btn.Font = Enum.Font.GothamMedium
                if entry.stroke then
                    entry.stroke.Color = Color3.fromRGB(105,105,112)
                    entry.stroke.Thickness = 1.15
                    entry.stroke.Transparency = 0.05
                end
                if entry.gradient then
                    entry.gradient.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255,255,255)),
                        ColorSequenceKeypoint.new(0.45, Color3.fromRGB(235,235,238)),
                        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(170,170,178)),
                    })
                    entry.gradient.Transparency = NumberSequence.new(0)
                end
                entry.btn.Text = entry.offText
            else
                local on = false
                if entry.key == "steal" then on = St.autoSteal == true end
                if entry.key == "sentry" then on = St.destroySentry == true end
                if entry.key == "ps" then on = isEquippedExact("Paintball Gun") end
                applyActBtnState(entry.btn, on, entry.onText, entry.offText)
            end
        end
    end)
end

function makeActBtn(key, label, pos, cb)
    local baseSz = (St.btnSizes[key] or 50)
    local sz = math.max(28, math.floor(baseSz * (St.btnScale or 1)))

    local holder = Instance.new("Frame")
    holder.Name = "A_" .. key
    holder.Size = UDim2.fromOffset(sz, sz)
    holder.Position = pos
    holder.BackgroundTransparency = 1
    holder.Active = true
    holder.ZIndex = 50
    holder.Parent = ActGui

    local btn = Instance.new("TextButton")
    btn.Name = "LaPeakMobileButton"
    btn.Size = UDim2.fromScale(1,1)
    btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
    btn.BackgroundTransparency = 0
    btn.BorderSizePixel = 0
    btn.Text = label
    btn.TextColor3 = Color3.fromRGB(25,25,30)
    btn.TextSize = math.clamp(math.floor(sz * 0.22), 10, 16)
    btn.Font = Enum.Font.GothamMedium
    btn.TextWrapped = true
    btn.AutoButtonColor = false
    btn.Active = true
    btn.Selectable = true
    btn.Modal = false
    btn.ZIndex = 100
    btn.Parent = holder

    applyCorner(btn, St.btnShape or "FOUNDED")
    applyCornerToChildren(btn, St.btnShape or "FOUNDED")

    local stroke = Instance.new("UIStroke")
    stroke.Name = "BtnBorder"
    stroke.Color = Color3.fromRGB(105,105,112)
    stroke.Thickness = 1.15
    stroke.Transparency = 0.05
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent = btn

    local grad = Instance.new("UIGradient")
    grad.Name = "LaPeakButtonGradient"
    grad.Rotation = 90
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255,255,255)),
        ColorSequenceKeypoint.new(0.45, Color3.fromRGB(235,235,238)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(170,170,178)),
    })
    grad.Transparency = NumberSequence.new(0)
    grad.Parent = btn

    local pressScale = Instance.new("UIScale")
    pressScale.Name = "LaPeakPressScale"
    pressScale.Scale = 1
    pressScale.Parent = holder

    local entry = {
        holder=holder, btn=btn, stroke=stroke, gradient=grad, key=key,
        state=false, onText=label, offText=label
    }
    actRefs[key] = entry

    local function paint(active, pressed)
        local on = active == true or pressed == true
        btn.BackgroundColor3 = on and Color3.fromRGB(0,0,0) or Color3.fromRGB(255,255,255)
        btn.BackgroundTransparency = 0
        btn.TextColor3 = on and Color3.fromRGB(255,255,255) or Color3.fromRGB(25,25,30)
        btn.Font = on and Enum.Font.GothamBlack or Enum.Font.GothamMedium
        stroke.Color = on and Color3.fromRGB(255,255,255) or Color3.fromRGB(105,105,112)
        stroke.Thickness = on and 1.8 or 1.15
        stroke.Transparency = 0.05
        if on then
            grad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255,255,255)),
                ColorSequenceKeypoint.new(0.28, Color3.fromRGB(185,185,190)),
                ColorSequenceKeypoint.new(0.62, Color3.fromRGB(72,72,78)),
                ColorSequenceKeypoint.new(1.00, Color3.fromRGB(8,8,10)),
            })
        else
            grad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255,255,255)),
                ColorSequenceKeypoint.new(0.45, Color3.fromRGB(235,235,238)),
                ColorSequenceKeypoint.new(1.00, Color3.fromRGB(170,170,178)),
            })
        end
    end

    entry.setVisual = function(active, pressed)
        entry.state = active == true
        paint(active, pressed)
    end

    local function stateForButton()
        if key == "steal" then return St.autoSteal == true end
        if key == "sentry" then return St.destroySentry == true end
        if key == "ps" then return isEquippedExact("Paintball Gun") end
        if key == "med" then return false end
        if key == "antiTrap" then return St.antiTrap == true end
        if key == "websinger" then return isWebSlingerEquipped() end
        return false
    end

    local down, dragging, inputStart, startPos, dragInput, suppress = false, false, nil, nil, nil, false

    btn.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
        down = true
        dragging = false
        suppress = false
        inputStart = input.Position
        startPos = holder.Position
        btn:SetAttribute("LaPeakPressed", true)
        if key == "drop" or key == "tp" or key == "tpBest" or key == "insta" or key == "med" then
            -- Action buttons use a brief black/white flash only; never keep
            -- the pressed/bold state while the input is held.
            paint(false, false)
        else
            paint(stateForButton(), true)
        end
        pcall(function()
            TS:Create(pressScale, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale=0.92}):Play()
        end)
    end)

    btn.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if not down or St.guiLock or not inputStart then return end
        if input ~= dragInput and input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
        local delta = input.Position - inputStart
        if delta.Magnitude > 6 then dragging = true; suppress = true end
        if dragging then
            holder.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
        if not down then return end
        local wasDrag = dragging
        down = false
        dragging = false
        dragInput = nil
        btn:SetAttribute("LaPeakPressed", false)
        pcall(function()
            TS:Create(pressScale, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale=1}):Play()
        end)
        if wasDrag and not St.guiLock then savePos(holder, "A_" .. key) end
    end)

    btn.Activated:Connect(function()
        -- LaPeak input model: Activated is the click/tap event. Do not require
        -- `down == false` here because on touch Activated may fire before
        -- InputEnded; that old guard made every mobile action look clickable
        -- while never executing its callback.
        if suppress or dragging then
            suppress = false
            return
        end
        pcall(cb)
        if key == "drop" or key == "tp" or key == "tpBest" or key == "insta" or key == "med" then
            flashActionButton(entry)
        elseif key == "steal" then
            task.defer(function() applyActBtnState(btn, St.autoSteal == true, "STEAL ON", "AUTO STEAL") end)
        elseif key == "sentry" then
            task.defer(function() applyActBtnState(btn, St.destroySentry == true, "DESTROY ON", "DESTROY") end)
        elseif key == "ps" then
            task.defer(refreshToolButtonVisuals)
        elseif key == "antiTrap" then
            task.defer(function() applyActBtnState(btn, St.antiTrap == true, "ANTI\nTRAP ON", "ANTI\nTRAP") end)
        elseif key == "websinger" then
            task.defer(function()
                if _G.RanaVSRefreshWebsingerBtn then _G.RanaVSRefreshWebsingerBtn() end
            end)
        else
            paint(stateForButton(), false)
        end
    end)

    entry.onText = (key == "steal" and "STEAL ON") or (key == "sentry" and "DESTROY ON") or (key == "antiTrap" and "ANTI\nTRAP ON") or (key == "websinger" and "KILL") or label
    entry.offText = (key == "steal" and "AUTO STEAL") or (key == "sentry" and "DESTROY") or (key == "antiTrap" and "ANTI\nTRAP") or (key == "tpBest" and "TP\nBEST") or (key == "websinger" and "WEBSINGER") or label
    paint(stateForButton(), false)
    return entry
end

function restorePos(holder, key, defaultPos)
	local t = St._btnPos and St._btnPos[key]
	if type(t) == "table" and t[1] ~= nil then
 holder.Position = UDim2.new(tonumber(t[1]) or 0, tonumber(t[2]) or 0, tonumber(t[3]) or 0, tonumber(t[4]) or 0)
 if t[5] and t[6] then
 local s = tonumber(t[5])
 local h = tonumber(t[6])
 if s and h and s > 10 and h > 10 then
 holder.Size = UDim2.new(0, s, 0, h)
 end
 end
	elseif defaultPos then
 holder.Position = defaultPos
	end
end

function savePos(holder, key)
	St._btnPos = St._btnPos or {}
	St._btnPos[key] = {
 holder.Position.X.Scale, holder.Position.X.Offset,
 holder.Position.Y.Scale, holder.Position.Y.Offset,
 holder.Size.X.Offset, holder.Size.Y.Offset
	}
	saveCfg()
end

function rebuildMobile()
	for _, e in pairs(modeRefs) do if e.holder then e.holder:Destroy() end end
	for _, e in pairs(actRefs) do if e.holder then e.holder:Destroy() end end
	modeRefs, actRefs = {}, {}
	-- Full Speed V2 GUI bar (authoritative 3-mode speed UI)
	pcall(function()
 if ModeGui then
 for _, ch in ipairs(ModeGui:GetChildren()) do
 if ch:IsA("Frame") and tostring(ch.Name):match("^M_") then
 ch.Visible = false
 end
 end
 end
 if _G.RanaVSBuildV2ModeBar then _G.RanaVSBuildV2ModeBar() end
 if St.speedOn then
 currentSpeedValue = getActiveMoveSpeed()
 pcall(startSpeedBoost)
 end
	end)
	makeActBtn("drop", "DROP", UDim2.new(1, -150, 0.5, -40), function()
        runDrop()
        if _G.RanaVSCounterOnDrop then pcall(_G.RanaVSCounterOnDrop) end
    end)
	makeActBtn("insta", "INSTA\nRESET", UDim2.new(1, -80, 0.5, -40), function()
        doInstaReset()
    end)
	makeActBtn("tp", "TP\nDOWN", UDim2.new(1, -230, 0.5, 30), function()
        doTPDown(true)
    end)
	makeActBtn("sentry", "DESTROY", UDim2.new(1, -150, 0.5, 30), function()
 local on = not (St.destroySentry == true)
 if type(setDestroySentry) == "function" then
 setDestroySentry(on)
 else
 St.destroySentry = on
 end
 if _G.RanaVSRefreshSentryBtn then pcall(_G.RanaVSRefreshSentryBtn) end
	end)
	makeActBtn("steal", "AUTO\nSTEAL", UDim2.new(1, -150, 0.5, 100), function()
 local on = not (St.autoSteal == true)
 if type(setAutoSteal) == "function" then
 setAutoSteal(on)
 elseif type(_G.setAutoSteal) == "function" then
 _G.setAutoSteal(on)
  else
  St.autoSteal = on
  autoStealEnabled = on
  end
 if _G.RanaVSRefreshStealBtn then pcall(_G.RanaVSRefreshStealBtn) end
 if ToggleRefs and ToggleRefs.autoSteal and ToggleRefs.autoSteal.setVisual then
 pcall(ToggleRefs.autoSteal.setVisual, St.autoSteal == true)
 end
	end)
	makeActBtn("med", "MED\nEQUIP", UDim2.new(1, -80, 0.5, -110), function()
        setMedButton()
    end)
	makeActBtn("ps", "PS", UDim2.new(1, -150, 0.5, -110), function()
        togglePS()
    end)
	makeActBtn("tpBest", "TP\nBEST", UDim2.new(1, -80, 0.5, 30), function()
	  local action = _G.RanaVSTPBestTeleport
	  if type(action) == "function" then pcall(action) end
	end)
	makeActBtn("antiTrap", "ANTI\nTRAP", UDim2.new(1, -80, 0.5, 100), function()
	  if type(setAntiTrap) == "function" then
		setAntiTrap(not (St.antiTrap == true))
	  end
	  if _G.RanaVSRefreshAntiTrapBtn then pcall(_G.RanaVSRefreshAntiTrapBtn) end
	end)
    makeActBtn("websinger", "WEBSINGER", UDim2.new(1, -230, 0.5, 100), function()
        _G.RanaVSNMKillToggle()
    end)
	-- restore saved positions
	for key, e in pairs(actRefs) do
 if e.holder then restorePos(e.holder, "A_" .. key) end
	end
	for key, e in pairs(modeRefs) do
 if e.holder then restorePos(e.holder, "M_" .. key) end
	end
	_G.RanaVSRefreshModeBar()
	_G.RanaVSRefreshSentryBtn()
	if _G.RanaVSRefreshStealBtn then pcall(_G.RanaVSRefreshStealBtn) end
	if _G.RanaVSRefreshAntiTrapBtn then pcall(_G.RanaVSRefreshAntiTrapBtn) end
end



-- Empire-style: nút ON = xanh đậm rõ, OFF = tối
function applyActBtnState(btn, on, onText, offText)
    if not btn then return end
    on = on == true
    btn.BackgroundColor3 = on and Color3.fromRGB(0,0,0) or Color3.fromRGB(255,255,255)
    btn.BackgroundTransparency = 0
    btn.TextColor3 = on and Color3.fromRGB(255,255,255) or Color3.fromRGB(25,25,30)
    btn.Font = on and Enum.Font.GothamBlack or Enum.Font.GothamMedium
    if onText and on then btn.Text = onText elseif offText and not on then btn.Text = offText end
    local grad = btn:FindFirstChild("LaPeakButtonGradient")
    if grad then
        grad.Color = on and ColorSequence.new({
            ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255,255,255)),
            ColorSequenceKeypoint.new(0.28, Color3.fromRGB(185,185,190)),
            ColorSequenceKeypoint.new(0.62, Color3.fromRGB(72,72,78)),
            ColorSequenceKeypoint.new(1.00, Color3.fromRGB(8,8,10)),
        }) or ColorSequence.new({
            ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255,255,255)),
            ColorSequenceKeypoint.new(0.45, Color3.fromRGB(235,235,238)),
            ColorSequenceKeypoint.new(1.00, Color3.fromRGB(170,170,178)),
        })
        grad.Transparency = NumberSequence.new(0)
    end
    local stroke = btn:FindFirstChild("BtnBorder") or btn:FindFirstChildOfClass("UIStroke")
    if stroke then
        stroke.Color = on and Color3.fromRGB(255,255,255) or Color3.fromRGB(105,105,112)
        stroke.Thickness = on and 1.8 or 1.15
        stroke.Transparency = 0.05
    end
end

function _G.RanaVSRefreshStealBtn()
	local e = actRefs and actRefs.steal
	if not e or not e.holder then return end
	local show = (St.showStealBtn ~= false)
	e.holder.Visible = show
	if e.btn then
 e.btn.Visible = show
 applyActBtnState(e.btn, St.autoSteal == true, "STEAL\nON", "AUTO\nSTEAL")
	end
end

function _G.RanaVSRefreshSentryBtn()
	local e = actRefs and actRefs.sentry
	if e and e.btn then
 applyActBtnState(e.btn, St.destroySentry == true, "DESTROY\nON", "DESTROY")
	end
end


function _G.RanaVSRefreshAntiTrapBtn()
	local e = actRefs and actRefs.antiTrap
	if e and e.btn then
	 applyActBtnState(e.btn, St.antiTrap == true, "ANTI\nTRAP ON", "ANTI\nTRAP")
	end
end

function _G.RanaVSRefreshWebsingerBtn()
    local e = actRefs and actRefs.websinger
    if not e or not e.btn then return end
    local grabbing = (type(_G.RanaVSIsGrabbingPlayer) == "function" and _G.RanaVSIsGrabbingPlayer()) or false
    local equipped = isWebSlingerEquipped() or grabbing
    local killing = (type(_G.RanaVSNMKillState) == "function" and _G.RanaVSNMKillState()) or false
    e.onText = killing and "STOP" or "KILL"
    e.offText = "WEBSINGER"
    applyActBtnState(e.btn, equipped, e.onText, "WEBSINGER")
end

-- Live grab watcher: when the web rope latches onto a player, flip the
-- button text to KILL immediately (NovaMoon grab-detect behavior).
RS.Heartbeat:Connect(function()
    if NM_isKilling then return end
    if _G.RanaVSIsGrabbingPlayer() then
        local e = actRefs and actRefs.websinger
        if e and e.btn and e.btn.Text ~= "KILL" then
            _G.RanaVSRefreshWebsingerBtn()
        end
    end
end)

function _G.RanaVSRefreshModeBar()
	for n, e in pairs(modeRefs) do
 if e and e.btn then
 local on = St.activeMode == n
 applyCorner(e.btn, "FOUNDED")
 if on then
 e.btn.BackgroundColor3 = C.modeOnBg or Color3.fromRGB(255, 20, 147)
 e.btn.BackgroundTransparency = 0
 e.btn.TextColor3 = C.modeOnTxt or Color3.fromRGB(255, 255, 255)
 local tl = e.btn:FindFirstChild("BtnTextOverlay")
 if tl then
 tl.TextColor3 = Color3.fromRGB(255, 255, 255)
 tl.Text = n
 end
 local st = e.btn:FindFirstChildOfClass("UIStroke")
 if st then st.Color = Color3.fromRGB(255, 120, 200); st.Transparency = 0.05 end
 else
 e.btn.BackgroundColor3 = C.modeOffBg or Color3.fromRGB(255, 255, 255)
 e.btn.BackgroundTransparency = 0
 e.btn.TextColor3 = C.modeOffTxt or Color3.fromRGB(25, 25, 30)
 local tl = e.btn:FindFirstChild("BtnTextOverlay")
 if tl then
 tl.TextColor3 = Color3.fromRGB(25, 25, 30)
 tl.Text = n
 end
 local st = e.btn:FindFirstChildOfClass("UIStroke")
 if st then st.Color = Color3.fromRGB(200, 200, 210); st.Transparency = 0.2 end
 end
 end
	end
end

-- Cập nhật size + shape TRỰC TIẾP (không destroy → giữ vị trí kéo)
_G.RanaVSForceApplyShape = function(shape)
	shape = shape or (St and St.btnShape) or "FOUNDED"
	if St then St.btnShape = shape end
	local refs = actRefs
	if type(refs) ~= "table" then return end
	for key, e in pairs(refs) do
 if e and e.btn then
 pcall(function()
 applyCorner(e.btn, shape)
 if applyCornerToChildren then applyCornerToChildren(e.btn, shape) end
 end)
 end
	end
end

function _G.RanaVSUpdateMobileVisuals()
	for n, e in pairs(modeRefs) do
 if e and e.holder and e.btn then
 local w = 98
 local h = 36
 e.holder.Size = UDim2.new(0, w, 0, h)
 e.btn.TextSize = math.clamp(math.floor(h * 0.36), 11, 14)
 local c = e.btn:FindFirstChildOfClass("UICorner") or Instance.new("UICorner", e.btn)
 c.CornerRadius = UDim.new(0, 12) -- V2 bo góc chữ nhật
 if e.style then e.style(St.activeMode == n) end
 end
	end
	for key, e in pairs(actRefs) do
 if e and e.holder and e.btn then
 local base = (St.btnSizes[key] or 70)
 local sz = math.max(28, math.floor(base * (St.btnScale or 1)))
 e.holder.Size = UDim2.new(0, sz, 0, sz)
 e.btn.TextSize = math.clamp(math.floor(sz * 0.22), 10, 16)
 applyCorner(e.btn, St.btnShape or "Round")
 applyCornerToChildren(e.btn, St.btnShape or "Round")
 -- viền
 local s = e.btn:FindFirstChild("BtnBorder") or e.btn:FindFirstChildOfClass("UIStroke")
 if not s then
 s = Instance.new("UIStroke")
 s.Name = "BtnBorder"
 s.Parent = e.btn
 end
 s.Color = Color3.fromRGB(220, 220, 235)
 s.Thickness = 2
 s.Transparency = 0.15
 end
	end
	if _G.RanaVSRefreshModeBar then pcall(_G.RanaVSRefreshModeBar) end
	if _G.RanaVSRefreshSentryBtn then pcall(_G.RanaVSRefreshSentryBtn) end
	if _G.RanaVSRefreshStealBtn then pcall(_G.RanaVSRefreshStealBtn) end
	if _G.RanaVSRefreshAntiTrapBtn then pcall(_G.RanaVSRefreshAntiTrapBtn) end
    if _G.RanaVSRefreshWebsingerBtn then pcall(_G.RanaVSRefreshWebsingerBtn) end
	local med = actRefs and actRefs.med; if med and med.btn then applyActBtnState(med.btn, false, "MED\nEQUIP", "MED\nEQUIP") end
	local ps = actRefs and actRefs.ps; if ps and ps.btn then applyActBtnState(ps.btn, isEquippedExact("Paintball Gun"), "PS", "PS") end
	-- Apply each Speed V2 mode size independently; never use one shared scale.
	pcall(function()
        if _G.RanaVSApplySpeedModeSizes then
            _G.RanaVSApplySpeedModeSizes()
        end
    end)
end

function _G.RanaVSApplyMobile()
	ModeGui.Enabled = false
	ActGui.Enabled = St.mobileBtns == true
	local hasMode = next(modeRefs) ~= nil
	local hasAct = next(actRefs) ~= nil
	if not hasMode or not hasAct then
 rebuildMobile()
	end
	-- luôn áp shape/size (Box/Round/Square) kể cả khi đã có nút
	if _G.RanaVSUpdateMobileVisuals then pcall(_G.RanaVSUpdateMobileVisuals) end
end
function _G.RanaVSResetMobilePos()
	St._btnPos = {}
	rebuildMobile()
	pcall(saveCfg)
end
_G.RanaVSApplyMobile()

----------------------------------------------------------------
-- KEYBINDS (Drop / TP / Insta / Sentry / Auto Steal) — no speed-mode keybind
----------------------------------------------------------------
UIS.InputBegan:Connect(function(input, gp)
	if gp or listening or _G.RanaVSKeybindingCapture == true then return end
	if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
	local k = input.KeyCode
	for modeName, modeKey in pairs(St.speedKeys or {}) do
		if modeKey and k == modeKey then setActiveMode(modeName); return end
	end
	if k == St.keys.Drop then runDrop()
	elseif k == St.keys.TPDown then doTPDown(true)
	elseif k == St.keys.InstaReset then doInstaReset()
	elseif k == St.keys.DestroySentry then setDestroySentry(not St.destroySentry)
	elseif St.keys.AutoSteal and St.keys.AutoSteal ~= "None" and k == St.keys.AutoSteal then
  if type(setAutoSteal) == "function" then
   setAutoSteal(not (St.autoSteal == true))
   if ToggleRefs and ToggleRefs.autoSteal and ToggleRefs.autoSteal.setVisual then
    pcall(ToggleRefs.autoSteal.setVisual, St.autoSteal == true)
   end
  end
	elseif St.keys.TpBest and St.keys.TpBest ~= "None" and k == St.keys.TpBest then
  local action = _G.RanaVSTPBestTeleport
  if type(action) == "function" then pcall(action) end
	elseif St.keys.MedEquip and St.keys.MedEquip ~= "None" and k == St.keys.MedEquip then
  if type(setMedButton) == "function" then pcall(setMedButton) end
	elseif St.keys.AntiTrap and St.keys.AntiTrap ~= "None" and k == St.keys.AntiTrap then
  if type(setAntiTrap) == "function" then pcall(setAntiTrap, not (St.antiTrap == true)) end
  if _G.RanaVSRefreshAntiTrapBtn then pcall(_G.RanaVSRefreshAntiTrapBtn) end
    elseif St.keys.Websinger and St.keys.Websinger ~= "None" and k == St.keys.Websinger then
        if type(runWebsingerAction) == "function" then pcall(runWebsingerAction) end
	end
end)

----------------------------------------------------------------
-- BOOT
----------------------------------------------------------------

-- ============================================================
-- REAPPLY ALL LOGIC (fix/rejoin/respawn) — không nút ảo
-- ============================================================
function reapplyAllLogic(reason)
	reason = tostring(reason or "boot")
	-- Speed
	pcall(function()
 if St.speedOn then
 -- force restart loop
 if speedConnection then
 pcall(function() speedConnection:Disconnect() end)
 speedConnection = nil
 end
 startSpeedBoost()
 if St.activeMode and setActiveMode then setActiveMode(St.activeMode) end
 else
 if stopSpeedBoost then stopSpeedBoost() end
 end
	end)
	-- Inf Jump
	pcall(function()
 if St.infJump then
 InfJumpState.enabled = true
 InfJumpState.mode = St.infJumpMode or "hold"
 if startInfJump then startInfJump() elseif setInfJump then setInfJump(true) end
 else
 if stopInfJump then stopInfJump() end
 end
	end)
	-- Anti Bee
	pcall(function()
	  if St.antiBee then
		if _G.RanaVSStartAntiBee then _G.RanaVSStartAntiBee() end
	  elseif _G.RanaVSStopAntiBee then
		_G.RanaVSStopAntiBee()
	  end
	end)
	-- Anti Trap
	pcall(function()
	  if St.antiTrap then
		if type(setAntiTrap) == "function" then setAntiTrap(true) end
	  elseif type(setAntiTrap) == "function" then
		setAntiTrap(false)
	  end
	end)
	-- Anti ragdoll
	pcall(function()
 if St.antiRagdoll then
 if AntiRagdollV2 then AntiRagdollV2.Enabled = true end
 if startAntiRagdoll then startAntiRagdoll() end
 else
 if stopAntiRagdoll then stopAntiRagdoll() end
 end
	end)
	-- Anti FX flags
	pcall(function()
 if AntiFX then
 AntiFX.gummy = true
 AntiFX.boogie = true
 AntiFX.paint = true
 St.antiGummy = true
 St.antiBoogie = true
 St.antiPaint = true
 end
	end)
	-- Tool aim + rehook
	pcall(function()
 if St.toolAim then
 aimOn = true
 local char = LP.Character
 if char and watchTools then watchTools(char) end
 local bp = LP:FindFirstChild("Backpack")
 if bp and watchTools then watchTools(bp) end
 else
 aimOn = false
 end
	end)
	-- Destroy sentry
	pcall(function()
 if St.destroySentry and setDestroySentry then setDestroySentry(true) end
	end)
	-- ESP / tracer / antilag
	pcall(function() if St.esp and setESP then setESP(true) end end)
	pcall(function() if St.tracer and setTracer then setTracer(true) end end)
	pcall(function() if St.antiLag and setAntiLag then setAntiLag(true) end end)
	-- Spam
	pcall(function() if St.spamLaser and setSpamLaser then setSpamLaser(true) end end)
	pcall(function() if St.spamPaint and setSpamPaint then setSpamPaint(true) end end)
	-- Auto steal
	pcall(function()
 if St.autoSteal then
 if type(setAutoSteal) == "function" then setAutoSteal(true) end
 if _G.RanaVSSyncAutoSteal then pcall(_G.RanaVSSyncAutoSteal) end
 end
	end)
	-- Ragdoll TP
	pcall(function()
	end)
	-- Mobile buttons
	pcall(function()
 if ModeGui then ModeGui.Enabled = St.mobileBtns == true end
 if ActGui then ActGui.Enabled = St.mobileBtns == true end
 if _G.RanaVSApplyMobile then pcall(_G.RanaVSApplyMobile) end
	end)
	-- Sync toggle UI + ép logic chạy nếu đang ON
	pcall(function()
 for name, ref in pairs(ToggleRefs or {}) do
 if ref and St[name] ~= nil then
 local on = St[name] == true
 if ref.setVisual then
 pcall(ref.setVisual, on)
 end
 end
 end
	end)
end
_G.RanaVSReapplyAllLogic = reapplyAllLogic


-- Re-apply ALL saved states so toggles that show ON actually work
pcall(function() setAntiGummy(St.antiGummy ~= false) end)
pcall(function() setAntiBee(St.antiBee == true) end)
pcall(function() setAntiTrap(St.antiTrap == true) end)
pcall(function() setAntiBoogie(St.antiBoogie ~= false) end)
pcall(function() setAntiPaint(St.antiPaint ~= false) end)
pcall(function() setAntiRagdoll(St.antiRagdoll == true) end)
pcall(function() setToolAim(St.toolAim ~= false) end)
pcall(function() setInfJump(St.infJump ~= false) end)
pcall(function() setDestroySentry(St.destroySentry == true) end)
pcall(function() setSpeedOn(St.speedOn ~= false) end)
pcall(function() setActiveMode(St.activeMode or "Normal") end)
pcall(function() setESP(St.esp == true) end)
pcall(function() setTracer(St.tracer == true) end)
pcall(function() setAntiLag(St.antiLag == true) end)
pcall(function() setNukeOptimizer(St.nukeOptimiserEnabled == true) end)
pcall(function() setSpamLaser(St.spamLaser == true) end)
pcall(function() setSpamPaint(St.spamPaint == true) end)
-- Auto Steal after setups exist
task.defer(function()
	pcall(function()
 if type(setAutoSteal) == "function" then
 setAutoSteal(St.autoSteal == true)
 end
 if St.autoSteal and _G.RanaVSSyncAutoSteal then
 pcall(_G.RanaVSSyncAutoSteal)
 end
	end)
end)
-- Legacy menu bootstrap removed; LaPeak menu owns initial tab.
task.defer(function()
	task.wait(0.6)
	pcall(function() if reapplyAllLogic then reapplyAllLogic("boot") end end)
end)
task.defer(function()
	-- rejoin server: re-apply sau 2s (chờ character/plot load)
	task.wait(2)
	pcall(function() if reapplyAllLogic then reapplyAllLogic("boot-delayed") end end)
end)
-- Sync toggle UI to match actual state
task.defer(function()
	-- sync toggle UI
	for name, ref in pairs(ToggleRefs or {}) do
 if ref and ref.set and St[name] ~= nil then
 pcall(function() ref.set(St[name] == true) end)
 end
	end
	-- force-apply runtime features (sau load / rejoin) — logic thật, không chỉ UI
	pcall(function() if St.speedOn and startSpeedBoost then startSpeedBoost() end end)
	pcall(function() if St.antiRagdoll and startAntiRagdoll then startAntiRagdoll() end end)
	pcall(function()
 if St.infJump then
 InfJumpState.enabled = true
 InfJumpState.mode = St.infJumpMode or "hold"
 end
	end)
	pcall(function() if St.toolAim and setToolAim then setToolAim(true) end end)
	pcall(function()
 if ModeGui then ModeGui.Enabled = St.mobileBtns == true end
 if ActGui then ActGui.Enabled = St.mobileBtns == true end
 if next(modeRefs) == nil or next(actRefs) == nil then
 if _G.RanaVSApplyMobile then _G.RanaVSApplyMobile() end
 end
	end)
	pcall(function() if St.activeMode and setActiveMode then setActiveMode(St.activeMode) end end)
	pcall(function() if St.autoSteal and type(setAutoSteal) == "function" then setAutoSteal(true) end end)
	pcall(function() if St.destroySentry and setDestroySentry then setDestroySentry(true) end end)
end)


-- Re-apply features on respawn / rejoin (full logic, không nút ảo)
if _G._VisHubCharReapplyConn then
	pcall(function() _G._VisHubCharReapplyConn:Disconnect() end)
	_G._VisHubCharReapplyConn = nil
end
_G._VisHubCharReapplyConn = LP.CharacterAdded:Connect(function(char)
	task.wait(0.4)
	pcall(function()
 if reapplyAllLogic then
 reapplyAllLogic("CharacterAdded")
 else
 if St.speedOn and startSpeedBoost then
 if speedConnection then pcall(function() speedConnection:Disconnect() end); speedConnection = nil end
 startSpeedBoost()
 end
 if St.infJump and setInfJump then setInfJump(true) end
 if St.antiRagdoll and startAntiRagdoll then startAntiRagdoll() end
 if St.toolAim and setToolAim then setToolAim(true) end
 if St.autoSteal and _G.RanaVSSyncAutoSteal then pcall(_G.RanaVSSyncAutoSteal) end
 end
	end)
end)

print("[12Hub Full] Player(Anti+Speed S2+Aim+Drop+Insta) | ESP | Settings mobile/lock/shape/size")



-- ============================================================
-- EXTENSION: InfJump 2-mode | FULL LAPEAK AUTO STEAL V1/V2 | Steal Bar | Panel TP
-- [12Hub] FULL LAPEAK AUTO STEAL ENGINE: Normal V1/V2 + Semi V1/V2
-- ============================================================
-- AUTO STEAL ENGINE: Ambitious Normal -> Lonely Normal V1
-- Ambitious percentage engine -> Lonely Normal V2 (Pause %; default 75; reset budget 5s)
-- Ambitious Semi V1/V2 -> Lonely Semi V1/V2
-- No public Semi V3 selector; Semi exposes V1/V2 only.
-- ============================================================
_G.AmbitiousStealRadii = _G.AdaptStealRadii or _G.AmbitiousStealRadii or {
    Normal = 62, Semi = 60, SemiV2Radius = 60, SemiV2SemiRadius = 8
}
_G.AdaptStealRadii = _G.AmbitiousStealRadii
_G.AmbitiousStealRadii.Normal = tonumber(_G.AmbitiousStealRadii.Normal) or 62
_G.AmbitiousStealRadii.Semi = tonumber(_G.AmbitiousStealRadii.Semi) or 60
_G.AmbitiousStealRadii.SemiV2Radius = tonumber(_G.AmbitiousStealRadii.SemiV2Radius) or 60
_G.AmbitiousStealRadii.SemiV2SemiRadius = tonumber(_G.AmbitiousStealRadii.SemiV2SemiRadius) or 8
_G.__AdaptSetupNormalAutoSteal = function()
  _G.AmbitiousNormalSteal = _G.AmbitiousNormalSteal or {
    enabled = false,
    radius = 62,
    duration = 1.3,
    animals = {},
    promptCache = {},
    internalCache = {},
    scannerStarted = false,
    scanning = false,
    isStealing = false,
    stealConn = nil,
    refreshThread = nil,
    lastSteal = 0,
    cooldown = 0.08,
  }
  if _G.AmbitiousNormalSteal.stealConn then pcall(function() _G.AmbitiousNormalSteal.stealConn:Disconnect() end); _G.AmbitiousNormalSteal.stealConn = nil end
  _G.AmbitiousNormalSteal.enabled = false
  _G.AmbitiousNormalSteal.isStealing = false

  local function barProgress(p)
    p = math.clamp(tonumber(p) or 0, 0, 1)
    pcall(function()
      if _G.StealBar then
        _G.StealBar.SetState("STEALING")
        _G.StealBar.SetProgress(p)
      end
    end)
  end

  local function resetBar()
    pcall(function()
      if _G.StealBar then _G.StealBar.Reset() end
    end)
  end

  local function getRoot()
    local char = LP.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso")
  end

  local function isMyBase(plotName)
    local plots = workspace:FindFirstChild("Plots")
    local plot = plots and plots:FindFirstChild(plotName)
    if not plot then return false end
    local sign = plot:FindFirstChild("PlotSign")
    local yourBase = sign and sign:FindFirstChild("YourBase")
    return yourBase and yourBase:IsA("BillboardGui") and yourBase.Enabled == true
  end

  local function scanPlots()
    local a = _G.AmbitiousNormalSteal
    a.animals = {}
    local plots = workspace:FindFirstChild("Plots")
    if not plots then return end
    for _, plot in ipairs(plots:GetChildren()) do
      if plot:IsA("Model") and not isMyBase(plot.Name) then
        local podiums = plot:FindFirstChild("AnimalPodiums")
        if podiums then
          for _, podium in ipairs(podiums:GetChildren()) do
            if podium:IsA("Model") then
              local base = podium:FindFirstChild("Base")
              local spawn = base and base:FindFirstChild("Spawn")
              if spawn then
                table.insert(a.animals, {
                  plot = plot.Name,
                  slot = podium.Name,
                  worldPosition = spawn.Position,
                  uid = plot.Name .. "_" .. podium.Name,
                })
              end
            end
          end
        end
      end
    end
  end

  local function ensureScanner()
    local a = _G.AmbitiousNormalSteal
    if a.scannerStarted then return end
    a.scannerStarted = true
    task.spawn(function()
      task.wait(1)
      while _G.AmbitiousNormalSteal do
        if _G.AmbitiousNormalSteal.enabled then
          pcall(scanPlots)
        end
        task.wait(3)
      end
    end)
  end

  local function findPrompt(data)
    if not data then return nil end
    local a = _G.AmbitiousNormalSteal
    local cached = a.promptCache[data.uid]
    if cached and cached.Parent then return cached end
    local plots = workspace:FindFirstChild("Plots")
    local plot = plots and plots:FindFirstChild(data.plot)
    local podiums = plot and plot:FindFirstChild("AnimalPodiums")
    local podium = podiums and podiums:FindFirstChild(data.slot)
    local base = podium and podium:FindFirstChild("Base")
    local spawn = base and base:FindFirstChild("Spawn")
    local attach = spawn and spawn:FindFirstChild("PromptAttachment")
    if not attach then return nil end
    for _, prompt in ipairs(attach:GetChildren()) do
      if prompt:IsA("ProximityPrompt") then
        a.promptCache[data.uid] = prompt
        return prompt
      end
    end
    return nil
  end

  local function cacheCallbacks(prompt)
    local a = _G.AmbitiousNormalSteal
    if a.internalCache[prompt] then return end
    local data = {hold = {}, trigger = {}, ready = true}
    pcall(function()
      if getconnections then
        for _, conn in ipairs(getconnections(prompt.PromptButtonHoldBegan)) do
          if type(conn.Function) == "function" then table.insert(data.hold, conn.Function) end
        end
        for _, conn in ipairs(getconnections(prompt.Triggered)) do
          if type(conn.Function) == "function" then table.insert(data.trigger, conn.Function) end
        end
      end
    end)
    if #data.hold > 0 or #data.trigger > 0 then
      a.internalCache[prompt] = data
    end
  end

  -- Stesso identico check delle modalita' Semi: distanza dal prompt vivo
  -- (prompt.Parent.Parent = la parte Spawn), non da una posizione salvata.
  local function stillInRange(prompt)
    local a = _G.AmbitiousNormalSteal
    local root = getRoot()
    if not root or not prompt.Parent or not prompt.Parent.Parent then return false end
    return (root.Position - prompt.Parent.Parent.Position).Magnitude <= (tonumber(a.radius) or 62)
  end

  local function doSteal(prompt)
    local a = _G.AmbitiousNormalSteal
    if not prompt or not prompt.Parent or a.isStealing then return end
    if tick() - (a.lastSteal or 0) < (a.cooldown or 0.08) then return end
    cacheCallbacks(prompt)
    local data = a.internalCache[prompt]
    if not data or not data.ready then return end
    data.ready = false
    a.isStealing = true
    a.lastSteal = tick()
    pcall(function() if _G.StealBar then _G.StealBar.SetState("STEALING") end end)
    task.spawn(function()
      if #data.hold > 0 then
        for _, fn in ipairs(data.hold) do task.spawn(function() pcall(fn) end) end
      end
      local startTime = tick()
      local dur = 1.3
      a.duration = dur
      -- La barra si riempie in 1.25s e resta piena per gli ultimi 0.05s:
      -- cosi' il 100% e' visibile invece di comparire nello stesso frame del reset.
      local fillDur = math.max(dur - 0.05, 0.05)
      local aborted = false
      while a.enabled and selectedStealMode == "Normal" and tick() - startTime < dur do
        if not stillInRange(prompt) then
          aborted = true
          break
        end
        barProgress((tick() - startTime) / fillDur)
        task.wait(0.02)
      end
      if aborted or not a.enabled or selectedStealMode ~= "Normal" then
        data.ready = true
        a.isStealing = false
        resetBar()
        return
      end
      barProgress(1)
      if #data.trigger > 0 then
        for _, fn in ipairs(data.trigger) do task.spawn(function() pcall(fn) end) end
      end
      pcall(function() if _G.AutoCarrySpeed and _G.AutoCarrySpeed.WatchPickup then _G.AutoCarrySpeed.WatchPickup(1.25) end end)
      -- Engine restarts immediately; only the visual reset is delayed.
      data.ready = true
      a.isStealing = false
      resetBar(3.99)
    end)
  end

  local function nearestAnimal()
    local a = _G.AmbitiousNormalSteal
    local root = getRoot()
    if not root then return nil end
    local radius = tonumber(a.radius) or 62

    -- STESSA SCELTA DEL BERSAGLIO DELLA SEMI.
    -- Prima si guardava la lista costruita dallo scan della Normal, che
    -- contiene TUTTI i podi (anche quelli vuoti), e si usava la
    -- worldPosition salvata al momento della scansione. Due problemi in
    -- uno: si prendeva di mira un podio senza niente sopra, e anche
    -- quando l'animale spariva la posizione vecchia restava buona,
    -- quindi lo steal partiva lo stesso a vuoto.
    -- La lista della Semi nasce invece dall'AnimalList del plot (solo
    -- slot davvero occupati) e la posizione viene risolta ADESSO dal
    -- podio: se non c'e' piu' niente, animalPos ritorna nil e quella
    -- voce non e' un bersaglio.
    -- #list > 0 e non solo "e' una tabella": lo scan condiviso ci mette un
    -- attimo a partire (aspetta ReplicatedStorage), e con la lista ancora
    -- vuota si usciva subito senza bersaglio invece di ripiegare sulla
    -- scansione propria. Era per quello che la Normal sembrava morta
    -- finche' non passavi da Semi e tornavi indietro.
    if _G.AmbitiousStealAnimals then
      local list = _G.AmbitiousStealAnimals()
      if type(list) == "table" and #list > 0 then
        local best, bestDist = nil, math.huge
        for _, data in ipairs(list) do
          local mine = _G.AmbitiousStealIsMyBase and _G.AmbitiousStealIsMyBase(data)
          local occupied = (not _G.AmbitiousStealSlotOccupied)
                           or _G.AmbitiousStealSlotOccupied(data)
          if not mine and occupied then
            local pos = _G.AmbitiousStealAnimalPos and _G.AmbitiousStealAnimalPos(data)
            if pos then
              local dist = (root.Position - pos).Magnitude
              if dist <= radius and dist < bestDist then
                best, bestDist = data, dist
              end
            end
          end
        end
        return best
      end
    end

    -- Ripiego: la Semi non e' ancora stata inizializzata. Anche qui la
    -- posizione si risolve dal vivo, non dalla worldPosition salvata.
    local best, bestDist = nil, math.huge
    for _, data in ipairs(a.animals) do
      if not isMyBase(data.plot) then
        local plots = workspace:FindFirstChild("Plots")
        local plot = plots and plots:FindFirstChild(data.plot)
        local podiums = plot and plot:FindFirstChild("AnimalPodiums")
        local podium = podiums and podiums:FindFirstChild(data.slot)
        if podium then
          local dist = (root.Position - podium:GetPivot().Position).Magnitude
          if dist <= radius and dist < bestDist then
            best, bestDist = data, dist
          end
        end
      end
    end
    return best
  end

  _G.AmbitiousNormalAutoStealSetRadius = function(v)
    _G.AmbitiousNormalSteal.radius = tonumber(v) or _G.AmbitiousNormalSteal.radius or 62
  end

  _G.AmbitiousNormalAutoStealStop = function()
    local a = _G.AmbitiousNormalSteal
    a.enabled = false
    a.isStealing = false
    if a.stealConn then a.stealConn:Disconnect(); a.stealConn = nil end
    resetBar()
  end

  _G.AmbitiousNormalAutoStealStart = function()
    local a = _G.AmbitiousNormalSteal
    a.radius = tonumber(autoStealRadius) or a.radius or 62
    a.duration = 1.3
    a.enabled = true
    ensureScanner()
    pcall(scanPlots)
    -- Lista condivisa con la Semi: va fatta partire, se no resta vuota e
    -- nearestAnimal non ha niente su cui lavorare.
    if _G.AmbitiousStealEnsureScan then pcall(_G.AmbitiousStealEnsureScan) end
    if a.stealConn then a.stealConn:Disconnect(); a.stealConn = nil end
    a.stealConn = RunService.Heartbeat:Connect(function()
      if not a.enabled then return end
      if selectedStealMode ~= "Normal" then _G.AmbitiousNormalAutoStealStop(); return end
      if a.isStealing then return end
      local target = nearestAnimal()
      if not target then return end
      local prompt = findPrompt(target)
      if prompt then doSteal(prompt) end
    end)
  end

  _G.AmbitiousNormalAutoStealSync = function()
    if selectedStealMode == "Normal" and autoStealEnabled then
      _G.AmbitiousNormalAutoStealStart()
    else
      _G.AmbitiousNormalAutoStealStop()
    end
  end
end

_G.__AdaptSetupSemiAutoSteal = function()
  _G.AmbitiousSemiSteal = _G.AmbitiousSemiSteal or {}
  local A = _G.AmbitiousSemiSteal
  if A.conn then pcall(function() A.conn:Disconnect() end); A.conn = nil end
  A.enabled    = false
  A.cooldown   = A.cooldown   or 0.05
  A.primeRange = A.primeRange or 80
  A.radius     = tonumber(autoStealRadius) or A.radius or 60
  -- applica valori salvati dal config (loadAmbitiousConfig gira prima di questo setup)
  local pending = _G._AmbitiousSemiStealPending
  A.autoGrabStopTime       = (pending and pending.autoGrabStopTime)       or A.autoGrabStopTime       or 1.29
  A.autoGrabStopPercent    = (pending and pending.autoGrabStopPercent)    or A.autoGrabStopPercent    or 75
  A.autoGrabSetDelayRadius = (pending and pending.autoGrabSetDelayRadius) or A.autoGrabSetDelayRadius or 8
  A.autoGrabStopEnabled    = true
  _G._AmbitiousSemiStealPending = nil


  A.conn = A.conn
  A.scanThread = A.scanThread
  A.plotSync = A.plotSync or {caches = {}, connections = {}}
  A.animals = A.animals or {}
  A.promptCache = A.promptCache or {}
  A.internalCache = A.internalCache or {}
  A.state = A.state or {active = false, startTime = 0, phase = "idle", label = "", lastResult = "", lastResultTime = 0}

  local function barSet(p, label)
    pcall(function()
      if _G.StealBar then
        _G.StealBar.SetState(label or "STEALING")
        _G.StealBar.SetProgress(math.clamp(tonumber(p) or 0, 0, 1))
      end
    end)
  end

  local function barReset()
    pcall(function()
      if _G.StealBar then _G.StealBar.Reset() end
    end)
  end

  local function rootPart()
    local char = LP.Character
    return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso")) or nil
  end

  local function splitPath(path)
    if typeof(path) == "table" then return path end
    local out = {}
    for part in string.gmatch(tostring(path), "[^%.]+") do
      table.insert(out, tonumber(part) or part)
    end
    return out
  end

  local function resolvePath(path, root)
    local current, parent, key = root, nil, nil
    for _, part in ipairs(splitPath(path)) do
      parent = current
      key = part
      current = current and current[part] or nil
    end
    return current, parent, key
  end

  local function applySyncDiff(channelName, packet)
    local cache = A.plotSync.caches[channelName]
    if typeof(cache) ~= "table" then return end
    local path, action, a, b = packet[1], packet[2], packet[3], packet[4]
    local current, parent, key = resolvePath(path, cache)
    if action == "Changed" then
      if parent ~= nil then parent[key] = a end
    elseif action == "ArrayInsert" then
      if current ~= nil then table.insert(current, b, a) end
    elseif action == "ArrayRemoved" then
      if current ~= nil then table.remove(current, b) end
    elseif action == "DictionaryInsert" then
      if current ~= nil then current[b] = a end
    elseif action == "DictionaryRemoved" then
      if current ~= nil then current[b] = nil end
    end
  end

  local function attachPlotChannel(remote, plots, requestData)
    if A.plotSync.connections[remote] then return end
    local channelName = tostring(remote.Name)
    if not plots:FindFirstChild(channelName) then return end
    if requestData and A.plotSync.caches[channelName] == nil then
      local ok, data = pcall(function() return requestData:InvokeServer(channelName) end)
      A.plotSync.caches[channelName] = (ok and typeof(data) == "table") and data or {}
    elseif A.plotSync.caches[channelName] == nil then
      A.plotSync.caches[channelName] = {}
    end
    A.plotSync.connections[remote] = remote.OnClientEvent:Connect(function(queue)
      for _, packet in ipairs(queue) do applySyncDiff(channelName, packet) end
    end)
  end

  local function ensureSync()
    if A.syncReady then return true end
    local ok = pcall(function()
      local rs = game:GetService("ReplicatedStorage")
      A.packages = rs:WaitForChild("Packages", 10)
      A.datas = rs:WaitForChild("Datas", 10)
      A.plots = workspace:WaitForChild("Plots", 10)
      if not (A.packages and A.datas and A.plots) then return end
      A.animalsData = require(A.datas:WaitForChild("Animals", 10))
      local sync = A.packages:WaitForChild("Synchronizer", 10)
      A.channelFolder = sync:WaitForChild("Channel", 10)
      A.routeRemote = sync:WaitForChild("CommunicationRoute", 10)
      A.requestData = sync:FindFirstChild("RequestData")
      for _, child in ipairs(A.channelFolder:GetChildren()) do
        if child:IsA("RemoteEvent") then attachPlotChannel(child, A.plots, A.requestData) end
      end
      A.channelFolder.ChildAdded:Connect(function(child)
        if child:IsA("RemoteEvent") then attachPlotChannel(child, A.plots, A.requestData) end
      end)
      A.routeRemote.OnClientEvent:Connect(function(actions)
        for _, action in ipairs(actions) do
          local kind, channelName = action[1], tostring(action[2])
          if A.plots and A.plots:FindFirstChild(channelName) then
            if kind == "ListenerAdded" then
              local remote = A.channelFolder and A.channelFolder:FindFirstChild(channelName)
              if remote and remote:IsA("RemoteEvent") then attachPlotChannel(remote, A.plots, A.requestData) end
            elseif kind == "ListenerRemoved" then
              for remote, conn in pairs(A.plotSync.connections) do
                if tostring(remote.Name) == channelName then
                  pcall(function() conn:Disconnect() end)
                  A.plotSync.connections[remote] = nil
                  A.plotSync.caches[channelName] = nil
                  break
                end
              end
            end
          end
        end
      end)
      A.syncReady = true
    end)
    return ok and A.syncReady == true
  end

  local function getPlotOwner(plot)
    local sign = plot and plot:FindFirstChild("PlotSign")
    local frame = sign and sign:FindFirstChild("SurfaceGui") and sign.SurfaceGui:FindFirstChild("Frame")
    local label = frame and frame:FindFirstChild("TextLabel")
    if not label or label.Text == "Empty Base" then return nil end
    return label.Text:gsub("'s [Bb]ase$", ""):gsub("%s+$", "")
  end

  local function isMyBaseAnimal(animalData)
    if not animalData or not animalData.plot or not A.plots then return false end
    local plot = A.plots:FindFirstChild(animalData.plot)
    if not plot then return false end
    local owner = getPlotOwner(plot)
    return owner == LP.DisplayName or owner == LP.Name
  end

  local function podiumFor(animalData)
    local plot = A.plots and A.plots:FindFirstChild(animalData.plot)
    local podiums = plot and plot:FindFirstChild("AnimalPodiums")
    return podiums and podiums:FindFirstChild(animalData.slot) or nil
  end

  local function animalPos(animalData)
    local podium = podiumFor(animalData)
    return podium and podium:GetPivot().Position or nil
  end

  local function distToAnimal(animalData)
    local root = rootPart()
    local pos = animalPos(animalData)
    return root and pos and (root.Position - pos).Magnitude or math.huge
  end

  local function findPromptForAnimal(animalData)
    if not animalData then return nil end
    local cached = A.promptCache[animalData.uid]
    if cached and cached.Parent then return cached end
    local podium = podiumFor(animalData)
    local base = podium and podium:FindFirstChild("Base")
    local spawn = base and base:FindFirstChild("Spawn")
    local attach = spawn and spawn:FindFirstChild("PromptAttachment")
    if not attach then return nil end
    for _, prompt in ipairs(attach:GetChildren()) do
      if prompt:IsA("ProximityPrompt") then
        A.promptCache[animalData.uid] = prompt
        return prompt
      end
    end
    return nil
  end

  local function scanAllPlots()
    if not ensureSync() then return 0 end
    local newCache = {}
    for _, plot in ipairs(A.plots:GetChildren()) do
      local cache = A.plotSync.caches[plot.Name]
      local animalList = cache and cache.AnimalList
      if typeof(animalList) == "table" then
        for slot, animalData in pairs(animalList) do
          if type(animalData) == "table" then
            local animalName = animalData.Index
            local info = A.animalsData and A.animalsData[animalName]
            if info then
              table.insert(newCache, {
                name = info.DisplayName or animalName,
                plot = plot.Name,
                slot = tostring(slot),
                uid = plot.Name .. "_" .. tostring(slot),
              })
            end
          end
        end
      end
    end
    A.animals = newCache
    return #newCache
  end

  local function pickClosest()
    local root = rootPart()
    if not root then return nil end
    local best, bestDist = nil, math.huge
    for _, animalData in ipairs(A.animals) do
      if not isMyBaseAnimal(animalData) then
        local pos = animalPos(animalData)
        local dist = pos and (root.Position - pos).Magnitude or math.huge
        if dist <= (A.primeRange or 80) and dist < bestDist then
          best, bestDist = animalData, dist
        end
      end
    end
    return best
  end

  local function buildCallbacks(prompt)
    if A.internalCache[prompt] then return end
    local data = {holdCallbacks = {}, triggerCallbacks = {}, ready = true}
    local okHold, holds = pcall(getconnections, prompt.PromptButtonHoldBegan)
    if okHold and type(holds) == "table" then
      for _, conn in ipairs(holds) do
        if type(conn.Function) == "function" then table.insert(data.holdCallbacks, conn.Function) end
      end
    end
    local okTrigger, triggers = pcall(getconnections, prompt.Triggered)
    if okTrigger and type(triggers) == "table" then
      for _, conn in ipairs(triggers) do
        if type(conn.Function) == "function" then table.insert(data.triggerCallbacks, conn.Function) end
      end
    end
    if #data.holdCallbacks > 0 or #data.triggerCallbacks > 0 then A.internalCache[prompt] = data end
  end

  -- Valori semi steal
  A.autoGrabStopTime       = A.autoGrabStopTime       or 1.29  -- punto in cui la barra si ferma (V1, secondi)
  A.autoGrabStopPercent    = A.autoGrabStopPercent    or 75    -- Normal V2: Pause %, derivato da Ambitious Semi V3
  A.autoGrabSetDelayRadius = A.autoGrabSetDelayRadius or 8     -- raggio trigger del secondo step
  A.autoGrabStopEnabled    = true                              -- sempre attivo
  A.cooldown = A.cooldown or 0.05

  local function executeSemi(prompt, animalData)
    if not prompt or not prompt.Parent or not animalData then return false end
    buildCallbacks(prompt)
    local data = A.internalCache[prompt]
    if not data or not data.ready then return false end
    data.ready = false
    A.state.active  = true
    A.state.startTime = tick()
    A.state.phase   = "holding"
    A.state.label   = animalData.name or "Animal"

    task.spawn(function()
      local startTime = A.state.startTime
      local duration  = 1.3  -- durata fase hold (secondi)

      -- avvia hold callbacks
      for _, fn in ipairs(data.holdCallbacks) do task.spawn(function() pcall(fn) end) end

      -- ====================== MODALITÀ STOP-AND-WAIT ======================
      -- Normal V2: identica alla base Ambitious Semi engine, ma lo stop e' una
      -- PERCENTUALE della barra. Semi V1 resta a tempo in secondi.
      local stopTime = A.autoGrabStopTime  -- es. 1.29s
      if selectedStealMode == "Normal" and selectedNormalMode == "V2" then
        local pct = math.clamp(tonumber(A.autoGrabStopPercent) or 75, 1, 100)
        stopTime = duration * (pct / 100)
      end

      -- fase 1: avanza fino a stopTime
      while A.enabled and (
        (selectedStealMode == "Semi" and selectedSemiMode ~= "V2")
        or (selectedStealMode == "Normal" and selectedNormalMode == "V2")
      ) do
        local elapsed = tick() - startTime
        if elapsed >= stopTime then break end
        barSet(math.clamp(elapsed / duration, 0, 1), "STEALING")
        local root = rootPart()
        if not root or not prompt.Parent or not prompt.Parent.Parent then break end
        if (root.Position - prompt.Parent.Parent.Position).Magnitude > (tonumber(A.radius) or 60) then break end
        task.wait()
      end

      local stopProgress = math.clamp(stopTime / duration, 0, 1)
      barSet(stopProgress, "STEALING")

      -- fase 2: aspetta entrata nel delayRadius oppure timeout
      -- Budget contato dall'inizio del ciclo. Semi giữ budget Ambitious 2.99s;
      -- Normal V2 dùng reset budget 5s theo yêu cầu.
      -- Dal budget si tolgono sia il tempo gia' speso nella fase 1
      -- (stopTime) sia quello necessario per completare la barra.
      -- stopTime e' sempre in secondi dopo la conversione della percentuale
      -- di Normal V2; Semi V1 usa direttamente il proprio stopTime.
      local phase2Budget = 2.99
      if selectedStealMode == "Normal" and selectedNormalMode == "V2" then
        phase2Budget = 3.99
      end
      local phase2Timeout
      if selectedStealMode == "Normal" and selectedNormalMode == "V2" then
        phase2Timeout = 3.99
      else
        phase2Timeout = math.max(phase2Budget - stopTime - math.max(duration - stopTime, 0), 0.05)
      end
      local phase2Start = tick()

      while A.enabled and (
        (selectedStealMode == "Semi" and selectedSemiMode ~= "V2")
        or (selectedStealMode == "Normal" and selectedNormalMode == "V2")
      ) do
        if tick() - phase2Start >= phase2Timeout then
          -- timeout: reset e riparti subito
          barReset()
          data.ready = true
          A.state.active = false
          A.state.phase  = "idle"
          executeSemi(prompt, animalData)
          return
        end

        if not prompt.Parent or not prompt.Parent.Parent then
          barReset()
          data.ready = true
          A.state.active = false
          A.state.phase  = "idle"
          return
        end

        local root = rootPart()
        if root then
          local dist = (root.Position - prompt.Parent.Parent.Position).Magnitude
          if dist <= (A.autoGrabSetDelayRadius or 8) then
            break  -- entrato nel raggio trigger
          elseif dist > (tonumber(A.radius) or 60) then
            barReset()
            data.ready = true
            A.state.active = false
            A.state.phase  = "idle"
            return
          end
        end
        task.wait()
      end

      -- fase 3: completa la barra da stopProgress a 1 e triggera
      if A.enabled and (
        (selectedStealMode == "Semi" and selectedSemiMode ~= "V2")
        or (selectedStealMode == "Normal" and selectedNormalMode == "V2")
      ) then
        -- Costo REALE della fase 3: nessun pavimento a 0.05, altrimenti il
        -- trigger slitta in avanti (con stopTime 1.29 restavano 0.01s ma se
        -- ne pagavano 0.05, quindi lo steal partiva 40ms tardi e il ciclo
        -- sforava la finestra di 2.99s).
        local fillDuration = math.max(duration - stopTime, 0)
        -- I 50ms sono solo l'anticipo VISIVO della barra: vengono presi da
        -- dentro fillDuration, non aggiunti dopo. Se la fase 3 dura meno di
        -- 50ms l'anticipo si accorcia insieme a lei.
        local barLead   = math.min(0.05, fillDuration)
        local fillRamp  = fillDuration - barLead
        local fillStart = tick()
        while true do
          local fp = (fillRamp > 0) and math.clamp((tick() - fillStart) / fillRamp, 0, 1) or 1
          barSet(stopProgress + fp * (1 - stopProgress), "STEALING")
          if fp >= 1 then break end
          task.wait()
        end
        barSet(1, "STEALING")
        if barLead > 0 then task.wait(barLead) end
        for _, fn in ipairs(data.triggerCallbacks) do task.spawn(function() pcall(fn) end) end
        pcall(function() if _G.AutoCarrySpeed and _G.AutoCarrySpeed.WatchPickup then _G.AutoCarrySpeed.WatchPickup(1.25) end end)
        A.state.lastResult = "Stole " .. tostring(A.state.label)
      else
        A.state.lastResult = "Cancelled"
      end

      -- cleanup: nessun wait extra, ripartenza immediata
      A.state.active         = false
      A.state.phase          = "idle"
      A.state.lastResultTime = tick()
      data.ready = true
      barReset(3.99)
    end)
    return true
  end

  -- ---- lista bersagli condivisa con la modalita' Normal ----
  -- La Normal costruiva una lista sua scorrendo i podi: ci finiva DENTRO
  -- ogni podio esistente, pieno o vuoto che fosse. Questa invece nasce
  -- dall'AnimalList del plot, quindi contiene solo gli slot che hanno
  -- davvero un animale sopra. Esposta su _G perche' il blocco della
  -- Normal sta prima di questo nel file e non vede questi local.
  _G.AmbitiousStealAnimals   = function() return A.animals end
  _G.AmbitiousStealAnimalPos = function(d) return animalPos(d) end
  _G.AmbitiousStealIsMyBase  = function(d) return isMyBaseAnimal(d) end

  -- Lo slot ha ANCORA un animale sopra, adesso.
  -- La lista viene ricostruita ogni 5 secondi, quindi da sola non basta:
  -- un animale appena rubato resta in elenco fino al giro dopo, e il
  -- podio esiste comunque (vuoto), quindi anche la posizione risulta
  -- valida. Le cache dei plot sono invece aggiornate dal vivo dai
  -- RemoteEvent del Synchronizer: chiedendo a loro si sa in quell'istante
  -- se lo slot e' occupato.
  _G.AmbitiousStealSlotOccupied = function(d)
    if not d or not d.plot or not d.slot then return false end
    local cache = A.plotSync and A.plotSync.caches and A.plotSync.caches[d.plot]
    local list = cache and cache.AnimalList
    -- Cache non disponibile: non si puo' dire di no, se no con la sync
    -- non pronta la Normal non partirebbe mai.
    if typeof(list) ~= "table" then return true end
    -- Le chiavi possono essere numeri o stringhe a seconda di come
    -- arrivano dal server: si provano entrambe.
    local entry = list[d.slot] or list[tonumber(d.slot) or -1]
    return type(entry) == "table"
  end

  local function ensureScanThread()
    if A.scanThread then return end
    A.scanThread = task.spawn(function()
      while _G.AmbitiousSemiSteal do
        -- Lo scan gira anche per la Normal, che ora legge da qui.
        if A.enabled or (selectedStealMode == "Semi" or (selectedStealMode == "Normal" and selectedNormalMode == "V2"))
           or (selectedStealMode == "Normal" and autoStealEnabled) then
          pcall(scanAllPlots)
        end
        task.wait(5)
      end
    end)
  end

  -- Avvio dello scan su richiesta. La Normal ora legge da questa lista,
  -- ma il thread che la riempie partiva SOLO dall'avvio della Semi: senza
  -- aver mai acceso la Semi la lista restava vuota e la Normal non
  -- trovava mai un bersaglio. Da qui la puo' far partire chiunque.
  _G.AmbitiousStealEnsureScan = function()
    ensureScanThread()
    task.spawn(function() pcall(scanAllPlots) end)
  end

  _G.AmbitiousSemiAutoStealSetRadius = function(v)
    local n = tonumber(v)
    if n then A.radius = n end
  end

  _G.AmbitiousSemiAutoStealStop = function()
    A.enabled = false
    if A.conn then A.conn:Disconnect(); A.conn = nil end
    A.state.active = false
    A.state.phase = "idle"
    barReset()
  end

  _G.AmbitiousSemiAutoStealStart = function()
    A.radius = tonumber(autoStealRadius) or A.radius or 60
    A.enabled = true
    ensureSync()
    ensureScanThread()
    pcall(scanAllPlots)
    if A.conn then A.conn:Disconnect(); A.conn = nil end
    A.conn = RunService.Heartbeat:Connect(function()
      if not A.enabled then return end
      if not (selectedStealMode == "Semi" or (selectedStealMode == "Normal" and selectedNormalMode == "V2")) then _G.AmbitiousSemiAutoStealStop(); return end
      if A.state.active then return end
      local target = pickClosest()
      if not target then return end
      local prompt = findPromptForAnimal(target)
      if prompt then executeSemi(prompt, target) end
    end)
  end

  _G.AmbitiousSemiAutoStealSync = function()
    if (selectedStealMode == "Semi" or (selectedStealMode == "Normal" and selectedNormalMode == "V2")) and autoStealEnabled then
      _G.AmbitiousSemiAutoStealStart()
    else
      _G.AmbitiousSemiAutoStealStop()
    end
  end
end

-- ===== SEMI V2 ENGINE (logica da Ambitious.lua standalone) =====
_G.__AdaptSetupSemiV2AutoSteal = function()
  _G.AmbitiousSemiV2Steal = _G.AmbitiousSemiV2Steal or {}
  local B = _G.AmbitiousSemiV2Steal
  if B.conn then pcall(function() B.conn:Disconnect() end); B.conn = nil end
  B.enabled    = false
  -- Valori hardcoded (non mostrati in settings)
  B.holdMin    = 1.3
  B.holdMax    = 2.69
  B.entryDelay = 0.3
  B.cooldown   = 0.05
  -- Radius (prime range) e SemiRadius (steal range) presi da AmbitiousStealRadii
  B.radius     = tonumber(_G.AmbitiousStealRadii and _G.AmbitiousStealRadii.SemiV2Radius) or B.radius or 60
  B.semiRadius = tonumber(_G.AmbitiousStealRadii and _G.AmbitiousStealRadii.SemiV2SemiRadius) or B.semiRadius or 8
  B.plotSync   = B.plotSync or {caches = {}, connections = {}}
  B.animals    = B.animals or {}
  B.promptCache = B.promptCache or {}
  B.internalCache = B.internalCache or {}
  B.state = B.state or {active = false, startTime = 0, phase = "idle"}

  local function barSet(p, label)
    pcall(function()
      if _G.StealBar then
        _G.StealBar.SetState(label or "STEALING")
        _G.StealBar.SetProgress(math.clamp(tonumber(p) or 0, 0, 1))
      end
    end)
  end

  local function barReset()
    pcall(function() if _G.StealBar then _G.StealBar.Reset() end end)
  end

  local function rootPart()
    local char = LP.Character
    return char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso")) or nil
  end

  local function splitPath(path)
    if typeof(path) == "table" then return path end
    local out = {}
    for part in string.gmatch(tostring(path), "[^%.]+") do
      table.insert(out, tonumber(part) or part)
    end
    return out
  end

  local function resolvePath(path, root)
    local current, parent, key = root, nil, nil
    for _, part in ipairs(splitPath(path)) do
      parent = current; key = part
      current = current and current[part] or nil
    end
    return current, parent, key
  end

  local function applySyncDiff(channelName, packet)
    local cache = B.plotSync.caches[channelName]
    if typeof(cache) ~= "table" then return end
    local path, action, a, b = packet[1], packet[2], packet[3], packet[4]
    local current, parent, key = resolvePath(path, cache)
    if action == "Changed" then
      if parent ~= nil then parent[key] = a end
    elseif action == "ArrayInsert" then
      if current ~= nil then table.insert(current, b, a) end
    elseif action == "ArrayRemoved" then
      if current ~= nil then table.remove(current, b) end
    elseif action == "DictionaryInsert" then
      if current ~= nil then current[b] = a end
    elseif action == "DictionaryRemoved" then
      if current ~= nil then current[b] = nil end
    end
  end

  local function attachPlotChannel(remote, plots, requestData)
    if B.plotSync.connections[remote] then return end
    local channelName = tostring(remote.Name)
    if not plots:FindFirstChild(channelName) then return end
    if requestData and B.plotSync.caches[channelName] == nil then
      local ok, data = pcall(function() return requestData:InvokeServer(channelName) end)
      B.plotSync.caches[channelName] = (ok and typeof(data) == "table") and data or {}
    elseif B.plotSync.caches[channelName] == nil then
      B.plotSync.caches[channelName] = {}
    end
    B.plotSync.connections[remote] = remote.OnClientEvent:Connect(function(queue)
      for _, packet in ipairs(queue) do applySyncDiff(channelName, packet) end
    end)
  end

  local function ensureSync()
    if B.syncReady then return true end
    local ok = pcall(function()
      local rs = game:GetService("ReplicatedStorage")
      B.packages = rs:WaitForChild("Packages", 10)
      B.datas    = rs:WaitForChild("Datas", 10)
      B.plots    = workspace:WaitForChild("Plots", 10)
      if not (B.packages and B.datas and B.plots) then return end
      B.animalsData = require(B.datas:WaitForChild("Animals", 10))
      local sync = B.packages:WaitForChild("Synchronizer", 10)
      B.channelFolder = sync:WaitForChild("Channel", 10)
      B.routeRemote   = sync:WaitForChild("CommunicationRoute", 10)
      B.requestData   = sync:FindFirstChild("RequestData")
      for _, child in ipairs(B.channelFolder:GetChildren()) do
        if child:IsA("RemoteEvent") then attachPlotChannel(child, B.plots, B.requestData) end
      end
      B.channelFolder.ChildAdded:Connect(function(child)
        if child:IsA("RemoteEvent") then attachPlotChannel(child, B.plots, B.requestData) end
      end)
      B.routeRemote.OnClientEvent:Connect(function(actions)
        for _, action in ipairs(actions) do
          local kind, channelName = action[1], tostring(action[2])
          if B.plots and B.plots:FindFirstChild(channelName) then
            if kind == "ListenerAdded" then
              local remote = B.channelFolder and B.channelFolder:FindFirstChild(channelName)
              if remote and remote:IsA("RemoteEvent") then attachPlotChannel(remote, B.plots, B.requestData) end
            elseif kind == "ListenerRemoved" then
              for remote, conn in pairs(B.plotSync.connections) do
                if tostring(remote.Name) == channelName then
                  pcall(function() conn:Disconnect() end)
                  B.plotSync.connections[remote] = nil
                  B.plotSync.caches[channelName] = nil
                  break
                end
              end
            end
          end
        end
      end)
      B.syncReady = true
    end)
    return ok and B.syncReady == true
  end

  local function getPlotOwner(plot)
    local sign = plot and plot:FindFirstChild("PlotSign")
    local frame = sign and sign:FindFirstChild("SurfaceGui") and sign.SurfaceGui:FindFirstChild("Frame")
    local label = frame and frame:FindFirstChild("TextLabel")
    if not label or label.Text == "Empty Base" then return nil end
    return label.Text:gsub("'s [Bb]ase$", ""):gsub("%s+$", "")
  end

  local function isMyBaseAnimal(animalData)
    if not animalData or not animalData.plot or not B.plots then return false end
    local plot = B.plots:FindFirstChild(animalData.plot)
    if not plot then return false end
    local owner = getPlotOwner(plot)
    return owner == LP.DisplayName or owner == LP.Name
  end

  local function podiumFor(animalData)
    local plot = B.plots and B.plots:FindFirstChild(animalData.plot)
    local podiums = plot and plot:FindFirstChild("AnimalPodiums")
    return podiums and podiums:FindFirstChild(animalData.slot) or nil
  end

  local function animalPos(animalData)
    local podium = podiumFor(animalData)
    return podium and podium:GetPivot().Position or nil
  end

  local function distToAnimal(animalData)
    local root = rootPart()
    local pos = animalPos(animalData)
    return root and pos and (root.Position - pos).Magnitude or math.huge
  end

  local function findPromptForAnimal(animalData)
    if not animalData then return nil end
    local cached = B.promptCache[animalData.uid]
    if cached and cached.Parent then return cached end
    local podium = podiumFor(animalData)
    local base = podium and podium:FindFirstChild("Base")
    local spawn = base and base:FindFirstChild("Spawn")
    local attach = spawn and spawn:FindFirstChild("PromptAttachment")
    if not attach then return nil end
    for _, prompt in ipairs(attach:GetChildren()) do
      if prompt:IsA("ProximityPrompt") then
        B.promptCache[animalData.uid] = prompt
        return prompt
      end
    end
    return nil
  end

  local function scanAllPlots()
    if not ensureSync() then return 0 end
    local newCache = {}
    for _, plot in ipairs(B.plots:GetChildren()) do
      local cache = B.plotSync.caches[plot.Name]
      local animalList = cache and cache.AnimalList
      if typeof(animalList) == "table" then
        for slot, animalData in pairs(animalList) do
          if type(animalData) == "table" then
            local animalName = animalData.Index
            local info = B.animalsData and B.animalsData[animalName]
            if info then
              table.insert(newCache, {
                name = info.DisplayName or animalName,
                plot = plot.Name,
                slot = tostring(slot),
                uid = plot.Name .. "_" .. tostring(slot),
              })
            end
          end
        end
      end
    end
    B.animals = newCache
    return #newCache
  end

  local function pickClosest()
    local root = rootPart()
    if not root then return nil end
    local best, bestDist = nil, math.huge
    for _, animalData in ipairs(B.animals) do
      if not isMyBaseAnimal(animalData) then
        local pos = animalPos(animalData)
        local dist = pos and (root.Position - pos).Magnitude or math.huge
        if dist <= (B.radius or 60) and dist < bestDist then
          best, bestDist = animalData, dist
        end
      end
    end
    return best
  end

  local function buildCallbacks(prompt)
    if B.internalCache[prompt] then return end
    local data = {holdCallbacks = {}, triggerCallbacks = {}, ready = true}
    local okHold, holds = pcall(getconnections, prompt.PromptButtonHoldBegan)
    if okHold and type(holds) == "table" then
      for _, conn in ipairs(holds) do
        if type(conn.Function) == "function" then table.insert(data.holdCallbacks, conn.Function) end
      end
    end
    local okTrigger, triggers = pcall(getconnections, prompt.Triggered)
    if okTrigger and type(triggers) == "table" then
      for _, conn in ipairs(triggers) do
        if type(conn.Function) == "function" then table.insert(data.triggerCallbacks, conn.Function) end
      end
    end
    if #data.holdCallbacks > 0 or #data.triggerCallbacks > 0 then B.internalCache[prompt] = data end
  end

  local function executeV2(prompt, animalData)
    if not prompt or not prompt.Parent or not animalData then return false end
    buildCallbacks(prompt)
    local data = B.internalCache[prompt]
    if not data or not data.ready then return false end
    data.ready = false
    B.state.active    = true
    B.state.startTime = tick()
    B.state.phase     = "holding"
    B.state.barHold   = false

    task.spawn(function()
      local holdMin    = B.holdMin    or 1.3
      local holdMax    = B.holdMax    or 2.69
      local entryDelay = B.entryDelay or 0.3
      local stealRange = B.semiRadius or 8   -- STEAL_RANGE
      local primeRange = B.radius     or 60  -- PRIME_RANGE

      -- avvia hold callbacks
      for _, fn in ipairs(data.holdCallbacks) do task.spawn(function() pcall(fn) end) end

      -- fase 1: aspetta holdMin (con check radius: se esci dal primeRange, abort)
      local t0 = tick()
      while tick() - t0 < holdMin do
        if distToAnimal(animalData) > primeRange then
          barReset()
          B.state.active = false
          B.state.phase  = "idle"
          task.wait(B.cooldown or 0.05)
          data.ready = true
          return
        end
        task.wait()
      end

      B.state.phase = "waitingRange"

      -- fase 2: aspetta entrata nello stealRange o scadenza holdMax
      -- se esci dal primeRange durante l'attesa → abort come Semi V1
      local alreadyInRange = distToAnimal(animalData) <= stealRange
      local fired = false
      while true do
        if tick() - B.state.startTime > holdMax then break end
        if not prompt.Parent then break end
        if selectedStealMode ~= "Semi" or selectedSemiMode ~= "V2" or not B.enabled then break end
        if distToAnimal(animalData) > primeRange then
          -- uscito dal radius durante la barra → reset e stop (uguale a Semi V1)
          barReset()
          B.state.active = false
          B.state.phase  = "idle"
          task.wait(B.cooldown or 0.05)
          data.ready = true
          return
        end
        if distToAnimal(animalData) <= stealRange then
          if not alreadyInRange then task.wait(entryDelay) end
          -- barra piena al momento del trigger (nessuna attesa aggiunta)
          B.state.barHold = true
          barSet(1, "STEALING")
          for _, fn in ipairs(data.triggerCallbacks) do task.spawn(function() pcall(fn) end) end
          pcall(function() if _G.AutoCarrySpeed and _G.AutoCarrySpeed.WatchPickup then _G.AutoCarrySpeed.WatchPickup(1.25) end end)
          fired = true
          break
        end
        task.wait()
      end

      if fired then barReset(3.99) else barReset() end
      B.state.barHold = false
      B.state.active = false
      B.state.phase  = "idle"
      task.wait(B.cooldown or 0.05)
      data.ready = true
    end)
    return true
  end

  local function ensureScanThread()
    if B.scanThread then return end
    B.scanThread = task.spawn(function()
      while _G.AmbitiousSemiV2Steal do
        if B.enabled or (selectedStealMode == "Semi" and selectedSemiMode == "V2") then pcall(scanAllPlots) end
        task.wait(5)
      end
    end)
  end

  _G.AmbitiousSemiV2SetRadius = function(v)
    local n = tonumber(v)
    if n then B.radius = n end
  end

  _G.AmbitiousSemiV2SetSemiRadius = function(v)
    local n = tonumber(v)
    if n then B.semiRadius = n end
  end

  -- RenderStepped dedicato: aggiorna la barra continuamente mentre V2 è attivo
  if B.barConn then pcall(function() B.barConn:Disconnect() end); B.barConn = nil end
  B.barConn = RunService.RenderStepped:Connect(function()
    if not B.state.active then return end
    if B.state.barHold then return end   -- barra piena in attesa del trigger
    local elapsed = tick() - B.state.startTime
    local holdMax = B.holdMax or 2.69
    -- la barra arriva a 1 con 0.05s di anticipo (es. 2.64 invece di 2.69)
    local barFull = math.max(holdMax - 0.05, 0.05)
    local p = math.clamp(elapsed / barFull, 0, 1)
    pcall(function()
      if _G.StealBar then
        _G.StealBar.SetState("STEALING")
        _G.StealBar.SetProgress(p)
      end
    end)
  end)

  _G.AmbitiousSemiV2AutoStealStop = function()
    B.enabled = false
    if B.conn then B.conn:Disconnect(); B.conn = nil end
    B.state.active  = false
    B.state.phase   = "idle"
    B.state.barHold = false
    barReset()
  end

  _G.AmbitiousSemiV2AutoStealStart = function()
    B.radius     = tonumber(_G.AmbitiousStealRadii and _G.AmbitiousStealRadii.SemiV2Radius)     or B.radius     or 60
    B.semiRadius = tonumber(_G.AmbitiousStealRadii and _G.AmbitiousStealRadii.SemiV2SemiRadius) or B.semiRadius or 8
    B.enabled = true
    ensureSync()
    ensureScanThread()
    pcall(scanAllPlots)
    if B.conn then B.conn:Disconnect(); B.conn = nil end
    B.conn = RunService.Heartbeat:Connect(function()
      if not B.enabled then return end
      if selectedStealMode ~= "Semi" or selectedSemiMode ~= "V2" then _G.AmbitiousSemiV2AutoStealStop(); return end
      if B.state.active then return end
      local target = pickClosest()
      if not target then return end
      local prompt = findPromptForAnimal(target)
      if prompt then executeV2(prompt, target) end
    end)
  end

  _G.AmbitiousSemiV2AutoStealSync = function()
    if selectedStealMode == "Semi" and selectedSemiMode == "V2" and autoStealEnabled then
      _G.AmbitiousSemiV2AutoStealStart()
    else
      _G.AmbitiousSemiV2AutoStealStop()
    end
  end
end

_G.AmbitiousAutoStealSync = function()
    if not autoStealEnabled then
        if _G.AmbitiousNormalAutoStealStop then pcall(_G.AmbitiousNormalAutoStealStop) end
        if _G.AmbitiousSemiAutoStealStop then pcall(_G.AmbitiousSemiAutoStealStop) end
        if _G.AmbitiousSemiV2AutoStealStop then pcall(_G.AmbitiousSemiV2AutoStealStop) end
        return
    end

    if selectedStealMode == "Normal" then
        if _G.AmbitiousSemiV2AutoStealStop then pcall(_G.AmbitiousSemiV2AutoStealStop) end
        if selectedNormalMode == "V2" then
            if _G.AmbitiousNormalAutoStealStop then pcall(_G.AmbitiousNormalAutoStealStop) end
            if _G.AmbitiousSemiAutoStealStart then pcall(_G.AmbitiousSemiAutoStealStart) end
        else
            if _G.AmbitiousSemiAutoStealStop then pcall(_G.AmbitiousSemiAutoStealStop) end
            if _G.AmbitiousNormalAutoStealSync then pcall(_G.AmbitiousNormalAutoStealSync) end
        end
    elseif selectedStealMode == "Semi" then
        if _G.AmbitiousNormalAutoStealStop then pcall(_G.AmbitiousNormalAutoStealStop) end
        if selectedSemiMode == "V2" then
            if _G.AmbitiousSemiAutoStealStop then pcall(_G.AmbitiousSemiAutoStealStop) end
            if _G.AmbitiousSemiV2AutoStealSync then pcall(_G.AmbitiousSemiV2AutoStealSync) end
        else
            if _G.AmbitiousSemiV2AutoStealStop then pcall(_G.AmbitiousSemiV2AutoStealStop) end
            if _G.AmbitiousSemiAutoStealSync then pcall(_G.AmbitiousSemiAutoStealSync) end
        end
    end
end

_G.__AdaptSetupNormalAutoSteal()
_G.__AdaptSetupSemiAutoSteal()
_G.__AdaptSetupSemiV2AutoSteal()

_G.AdaptNormalAutoStealStart = _G.AmbitiousNormalAutoStealStart
_G.AdaptNormalAutoStealStop = _G.AmbitiousNormalAutoStealStop
_G.AdaptNormalAutoStealSync = _G.AmbitiousNormalAutoStealSync
_G.AdaptSemiAutoStealStart = _G.AmbitiousSemiAutoStealStart
_G.AdaptSemiAutoStealStop = _G.AmbitiousSemiAutoStealStop
_G.AdaptSemiAutoStealSync = _G.AmbitiousSemiAutoStealSync
_G.AdaptSemiV2AutoStealStart = _G.AmbitiousSemiV2AutoStealStart
_G.AdaptSemiV2AutoStealStop = _G.AmbitiousSemiV2AutoStealStop
_G.AdaptSemiV2AutoStealSync = _G.AmbitiousSemiV2AutoStealSync
_G.AdaptSemiAutoStealSetRadius = _G.AmbitiousSemiAutoStealSetRadius
_G.AdaptAutoStealSync = _G.AmbitiousAutoStealSync
_G.AdaptAutoStealSync = _G.AmbitiousAutoStealSync
task.spawn(function()
while task.wait(30) do
do end
end
end)

----------------------------------------------------------------
-- 12Hub Auto Steal bridge: connect file-1 UI/state to the full
-- LaPeak/Ambitious Normal V1/V2 + Semi V1/V2 engines above.
----------------------------------------------------------------
selectedNormalMode = (tostring(selectedNormalMode) == "V2") and "V2" or "V1"
selectedSemiMode = (tostring(selectedSemiMode) == "V2") and "V2" or "V1"

local function _12HubNormalizeStealSelection(mode, version)
    mode = (tostring(mode) == "Semi") and "Semi" or "Normal"
    version = (tostring(version) == "V1") and "V1" or "V2"
    selectedStealMode = mode
    autoStealV2Version = version
    if mode == "Normal" then
        selectedNormalMode = version
    else
        selectedSemiMode = version
    end
    St.stealVer = mode .. "-" .. version
    autoStealRadius = tonumber(St.stealRadius) or 60
end

local function _12HubSyncAutoSteal()
    _12HubNormalizeStealSelection(selectedStealMode, autoStealV2Version)
    autoStealEnabled = St.autoSteal == true
    _G.autoStealEnabled = autoStealEnabled
    if _G.AdaptAutoStealSync then
        pcall(_G.AdaptAutoStealSync)
    elseif _G.AmbitiousAutoStealSync then
        pcall(_G.AmbitiousAutoStealSync)
    end
end

function setAutoSteal(on)
    St.autoSteal = on and true or false
    autoStealEnabled = St.autoSteal
    _G.autoStealEnabled = autoStealEnabled
    _12HubSyncAutoSteal()
    if _G.RanaVSRefreshStealBtn then pcall(_G.RanaVSRefreshStealBtn) end
    if ToggleRefs and ToggleRefs.autoSteal and ToggleRefs.autoSteal.setVisual then
        pcall(ToggleRefs.autoSteal.setVisual, St.autoSteal)
    end
    pcall(saveCfg)
end

_G.setAutoSteal = setAutoSteal
_G.RanaVSSyncAutoSteal = _12HubSyncAutoSteal

_G.RanaVSSelectAutoSteal = function(mode, version)
    _12HubNormalizeStealSelection(mode, version)
    _12HubSyncAutoSteal()
    pcall(function() if _G.RanaVSRefreshAutoStealSelector then _G.RanaVSRefreshAutoStealSelector() end end)
    pcall(saveCfg)
end

_G.AdaptSetStealPause = function(p)
    local n = tonumber(tostring(p):match("%d+")) or 75
    local allowed = {[70]=true,[75]=true,[80]=true,[85]=true,[90]=true}
    if not allowed[n] then n = 75 end
    St.normalV2PausePercent = n
    _G.AdaptStealPausePreset = tostring(n)
    _G._AmbitiousSemiStealPending = _G._AmbitiousSemiStealPending or {}
    _G._AmbitiousSemiStealPending.autoGrabStopPercent = n
    if _G.AmbitiousSemiSteal then
        _G.AmbitiousSemiSteal.autoGrabStopPercent = n
    end
    -- Normal V2 shares the LaPeak percentage window through the Normal engine.
    if _G.AmbitiousNormalSteal then
        _G.AmbitiousNormalSteal.autoGrabStopPercent = n
    end
    pcall(saveCfg)
    if St.autoSteal then pcall(_12HubSyncAutoSteal) end
end

-- Keep radius synchronized with all four engines.
setStealRadius = function(v)
    local n = math.clamp(tonumber(v) or 60, 1, 250)
    St.stealRadius = n
    autoStealRadius = n
    _G.AmbitiousStealRadii = _G.AmbitiousStealRadii or {}
    _G.AmbitiousStealRadii.Normal = n
    _G.AmbitiousStealRadii.Semi = n
    _G.AmbitiousStealRadii.SemiV2Radius = n
    pcall(function() if _G.AmbitiousNormalAutoStealSetRadius then _G.AmbitiousNormalAutoStealSetRadius(n) end end)
    pcall(function() if _G.AmbitiousSemiAutoStealSetRadius then _G.AmbitiousSemiAutoStealSetRadius(n) end end)
    pcall(function() if _G.AmbitiousSemiV2SetRadius then _G.AmbitiousSemiV2SetRadius(n) end end)
    pcall(saveCfg)
end

-- Initial bridge state: restore the saved Normal/Semi + V1/V2 selector exactly.
_12HubNormalizeStealSelection(selectedStealMode, autoStealV2Version)
if St.normalV2PausePercent == nil then St.normalV2PausePercent = 75 end
_G.AdaptSetStealPause(St.normalV2PausePercent)
-- PANEL TP OLD/COMPACT REMOVED
-- The active TP panel below is the full uploaded allgearonetop GUI renamed to 12Hub.

-- BODY LOCK: removed completely; no runtime, range setting, or UI.
-- UI: Panel tab + Auto Steal + InfJump mode on existing pages
----------------------------------------------------------------
task.defer(function()
	-- Auto steal on Player page
	if not pagePlayer then warn("[12Hub] pagePlayer nil") return end
	section(pagePlayer, "* — AUTO STEAL", 20)
	local function safeSetAS(on)
 if type(setAutoSteal) == "function" then
 setAutoSteal(on)
 else
 St.autoSteal = on and true or false
 end
	end
	toggleNamed(pagePlayer, "Auto Steal", St.autoSteal == true, safeSetAS, 21, "autoSteal")
    -- Auto Steal selector: Mode = Normal/Semi, Version = V1/V2.
    local modeRow = row(pagePlayer, 36, 22)
    local modeLbl = Instance.new("TextLabel")
    modeLbl.Size = UDim2.new(0.28, 0, 1, 0)
    modeLbl.Position = UDim2.new(0, 10, 0, 0)
    modeLbl.BackgroundTransparency = 1
    modeLbl.Text = "Mode"
    modeLbl.TextColor3 = C.text
    modeLbl.TextSize = 12
    modeLbl.Font = Enum.Font.Gotham
    modeLbl.TextXAlignment = Enum.TextXAlignment.Left
    modeLbl.Parent = modeRow

    local function setStealSelector(mode, version)
        mode = (mode == "Semi") and "Semi" or "Normal"
        version = (version == "V2") and "V2" or "V1"
        _12HubNormalizeStealSelection(mode, version)
        _12HubSyncAutoSteal()
        refreshStealSelector()
        saveCfg()
    end

    local modeButtons = {}
    local verButtons = {}
    local function refreshStealSelector()
        for n, x in pairs(modeButtons) do
            local on = selectedStealMode == n
            x.BackgroundColor3 = on and C.accent or C.box
            x.TextColor3 = on and Color3.fromRGB(30,20,30) or C.text
        end
        for n, x in pairs(verButtons) do
            local on = autoStealV2Version == n
            x.BackgroundColor3 = on and C.accent or C.box
            x.TextColor3 = on and Color3.fromRGB(30,20,30) or C.text
        end
    end
    for i, name in ipairs({"Normal", "Semi"}) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 76, 0, 26)
        b.Position = UDim2.new(1, -170 + (i-1)*80, 0.5, -13)
        b.BackgroundColor3 = (selectedStealMode == name) and C.accent or C.box
        b.Text = name
        b.TextColor3 = (selectedStealMode == name) and Color3.fromRGB(30,20,30) or C.text
        b.TextSize = 11
        b.Font = Enum.Font.GothamBold
        b.AutoButtonColor = false
        b.Parent = modeRow
        corner(b, 7)
        modeButtons[name] = b
        local function chooseMode()
            setStealSelector(name, autoStealV2Version)
            refreshStealSelector()
        end
        b.MouseButton1Click:Connect(chooseMode)
        b.Activated:Connect(chooseMode)
    end

    local verRow = row(pagePlayer, 36, 22.5)
    local verLbl = Instance.new("TextLabel")
    verLbl.Size = UDim2.new(0.28, 0, 1, 0)
    verLbl.Position = UDim2.new(0, 10, 0, 0)
    verLbl.BackgroundTransparency = 1
    verLbl.Text = "Version"
    verLbl.TextColor3 = C.text
    verLbl.TextSize = 12
    verLbl.Font = Enum.Font.Gotham
    verLbl.TextXAlignment = Enum.TextXAlignment.Left
    verLbl.Parent = verRow

    for i, name in ipairs({"V1", "V2"}) do
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, 60, 0, 26)
        b.Position = UDim2.new(1, -140 + (i-1)*66, 0.5, -13)
        b.BackgroundColor3 = (autoStealV2Version == name) and C.accent or C.box
        b.Text = name
        b.TextColor3 = (autoStealV2Version == name) and Color3.fromRGB(30,20,30) or C.text
        b.TextSize = 11
        b.Font = Enum.Font.GothamBold
        b.AutoButtonColor = false
        b.Parent = verRow
        corner(b, 7)
        verButtons[name] = b
        local function chooseVersion()
            setStealSelector(selectedStealMode, name)
            refreshStealSelector()
        end
        b.MouseButton1Click:Connect(chooseVersion)
        b.Activated:Connect(chooseVersion)
    end
    refreshStealSelector()
	-- radius box
	local rr = row(pagePlayer, 36, 24)
	local rl = Instance.new("TextLabel")
	rl.Size = UDim2.new(0.5, 0, 1, 0)
	rl.Position = UDim2.new(0, 10, 0, 0)
	rl.BackgroundTransparency = 1
	rl.Text = "Steal Radius"
	rl.TextColor3 = C.text
	rl.TextSize = 12
	rl.Font = Enum.Font.Gotham
	rl.TextXAlignment = Enum.TextXAlignment.Left
	rl.Parent = rr
	numBox(rr, UDim2.new(1, -70, 0.5, -12), 56, St.stealRadius, function(v)
 St.stealRadius = v
 saveCfg()
	end)
	-- force scroll size so AUTO STEAL is visible
	pcall(function()
 local lay = pagePlayer:FindFirstChildOfClass("UIListLayout")
 if lay then
 pagePlayer.CanvasSize = UDim2.new(0, 0, 0, lay.AbsoluteContentSize.Y + 40)
 end
	end)

	-- InfJump mode row near inf jump if exists
	section(pagePlayer, "* — INF JUMP MODE", 217)
	local ij = row(pagePlayer, 36, 218)
	for i, name in ipairs({"hold", "manual"}) do
 local b = Instance.new("TextButton")
 b.Size = UDim2.new(0, 70, 0, 26)
 b.Position = UDim2.new(0, 12 + (i - 1) * 80, 0.5, -13)
 b.BackgroundColor3 = (St.infJumpMode == name) and C.accent or C.box
 b.Text = name
 b.TextColor3 = (St.infJumpMode == name) and Color3.fromRGB(30, 20, 30) or C.text
 b.TextSize = 11
 b.Font = Enum.Font.GothamBold
 b.Parent = ij
 Instance.new("UICorner", b).CornerRadius = UDim.new(0, 7)
 b.MouseButton1Click:Connect(function()
 setInfJumpMode(name)
 for _, ch in ipairs(ij:GetChildren()) do
 if ch:IsA("TextButton") then
 local on = ch.Text == St.infJumpMode
 ch.BackgroundColor3 = on and C.accent or C.box
 ch.TextColor3 = on and Color3.fromRGB(30, 20, 30) or C.text
 end
 end
 end)
	end

	setTab("Player")
end)

print("[12Hub Ext] AutoSteal Normal/Semi V1/V2 + LaPeak bar | InfJump hold/manual | ToolAim ON")



-- ============================================================
-- TP TO BEST (Chilli style) — equip carpet + TP best brainrot
-- ============================================================
function parseGenValue(text)
	if not text then return 0 end
	text = tostring(text):gsub(",", ""):gsub("%s", ""):upper()
	-- $5M/s $1.2B 850M 7M/S 14.8B
	local best = 0
	for num, suffix in text:gmatch("([%d%.]+)([KMBTQA]?)") do
 local n = tonumber(num)
 if n then
 local mul = 1
 if suffix == "K" then mul = 1e3
 elseif suffix == "M" then mul = 1e6
 elseif suffix == "B" then mul = 1e9
 elseif suffix == "T" then mul = 1e12
 elseif suffix == "Q" or suffix == "QA" then mul = 1e15
 end
 local v = n * mul
 if v > best then best = v end
 end
	end
	return best
end

function isStealAction(prompt)
	if not prompt or not prompt:IsA("ProximityPrompt") then return false end
	local act = tostring(prompt.ActionText or ""):lower()
	local obj = tostring(prompt.ObjectText or ""):lower()
	-- EN + ES + VI (Steal)
	if act:find("steal") or act:find("robar") or act:find("steal") or act:find("steal")
 or act:find("grab") or act:find("take") then
 return true
	end
	if obj:find("steal") or obj:find("steal") or obj:find("steal") or obj:find("robar") then
 return true
	end
	-- unicode normalize fallback
	local actRaw = tostring(prompt.ActionText or "")
	if actRaw:find("uop") or actRaw:find("Steal") or actRaw:find("steal") then return true end
	return false
end

function isOwnPlot(plot)
	if not plot then return false end
	local sign = plot:FindFirstChild("PlotSign") or plot:FindFirstChild("Sign")
	if sign then
 for _, d in ipairs(sign:GetDescendants()) do
 if d:IsA("BillboardGui") and (d.Name:lower():find("your") or d.Enabled) then
 if d.Name:lower():find("your") or d.Name:lower():find("base") then
 -- check owner attribute
 end
 end
 end
	end
	-- attribute / string value owner
	local ok, owner = pcall(function()
 return plot:GetAttribute("Owner") or plot:GetAttribute("OwnerId")
	end)
	if ok and owner and tostring(owner) == tostring(LP.UserId) then return true end
	local ok2, ownerName = pcall(function()
 return plot:GetAttribute("OwnerName")
	end)
	if ok2 and ownerName and tostring(ownerName) == LP.Name then return true end
	-- YourBase billboard
	for _, d in ipairs(plot:GetDescendants()) do
 if d:IsA("BillboardGui") and d.Name == "YourBase" and d.Enabled then
 return true
 end
	end
	return false
end

function findBestBrainrot()
	local roots = {}
	for _, name in ipairs({"Plots", "plots", "Bases", "Animals", "Pets", "Map"}) do
 local f = workspace:FindFirstChild(name)
 if f then table.insert(roots, f) end
	end
	if #roots == 0 then table.insert(roots, workspace) end

	local bestPrompt, bestVal, bestPart = nil, -1, nil
	local function consider(d)
 if not d:IsA("ProximityPrompt") then return end
 if not isStealAction(d) then return end
 if d.Enabled == false then return end
 -- skip own character
 if LP.Character and d:IsDescendantOf(LP.Character) then return end
 local part = d.Parent
 if not part then return end
 -- climb out of own plot
 local plot = d
 for _ = 1, 8 do
 if not plot.Parent or plot.Parent == workspace then break end
 plot = plot.Parent
 if isOwnPlot(plot) then return end
 end
 local basePart = part:IsA("BasePart") and part
 or (part:IsA("Model") and part:FindFirstChildWhichIsA("BasePart", true))
 or part:FindFirstAncestorWhichIsA("BasePart")
 if not basePart then return end
 local val = 0
 local searchRoot = part:IsA("Model") and part or part.Parent
 if searchRoot then
 for _, lab in ipairs(searchRoot:GetDescendants()) do
 if lab:IsA("TextLabel") or lab:IsA("TextButton") then
 local t = lab.Text or ""
 if t:find("%$") or t:find("/s") or t:find("/S") or t:upper():find("[KMBT]") then
 local v = parseGenValue(t)
 if v > val then val = v end
 end
 end
 end
 end
 local v2 = parseGenValue(d.ObjectText)
 if v2 > val then val = v2 end
 -- BillboardGui near prompt
 for _, bb in ipairs(workspace:GetDescendants()) do
 if bb:IsA("BillboardGui") and bb.Adornee then
 local okd, dist = pcall(function()
 return (bb.Adornee.Position - basePart.Position).Magnitude
 end)
 if okd and dist and dist < 12 then
 for _, lab in ipairs(bb:GetDescendants()) do
 if lab:IsA("TextLabel") then
 local v = parseGenValue(lab.Text)
 if v > val then val = v end
 end
 end
 end
 end
 end
 if val > bestVal or (val == bestVal and bestVal < 0) then
 bestVal = val
 bestPrompt = d
 bestPart = basePart
 elseif bestPrompt == nil then
 bestVal = val
 bestPrompt = d
 bestPart = basePart
 end
	end

	for _, root in ipairs(roots) do
 if root == workspace then
 -- limit scan
 for _, d in ipairs(workspace:GetDescendants()) do
 if d:IsA("ProximityPrompt") then consider(d) end
 end
 else
 for _, plot in ipairs(root:GetChildren()) do
 if not isOwnPlot(plot) then
 for _, d in ipairs(plot:GetDescendants()) do
 consider(d)
 end
 end
 end
 end
	end
	return bestPart, bestVal, bestPrompt
end

function equipFlyingCarpet(char)
	char = char or LP.Character
	if not char then return false end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then return false end
	local names = {
 "Flying Carpet", "Carpet", "Cloud", "Witch's Broom",
 "Magic Carpet", "Fly Carpet", "FlyingCarpet",
	}
	for _, n in ipairs(names) do
 local g = char:FindFirstChild(n) or LP.Backpack:FindFirstChild(n)
 if g and g:IsA("Tool") then
 pcall(function() hum:EquipTool(g) end)
 return true
 end
	end
	-- fuzzy
	for _, t in ipairs(LP.Backpack:GetChildren()) do
 if t:IsA("Tool") then
 local ln = t.Name:lower()
 if ln:find("carpet") or ln:find("broom") or ln:find("cloud") or ln:find("fly") then
 pcall(function() hum:EquipTool(t) end)
 return true
 end
 end
	end
	for _, t in ipairs(char:GetChildren()) do
 if t:IsA("Tool") then
 local ln = t.Name:lower()
 if ln:find("carpet") or ln:find("broom") or ln:find("cloud") then
 return true
 end
 end
	end
	return false
end

function tpToBestChilli()
	-- removed per request
end
_G.RanaVSTpToBest = tpToBestChilli

-- UI: button on Panel + mobile + keybind
if St.keys.TpBest == nil then St.keys.TpBest = Enum.KeyCode.B end

task.defer(function()
	local pagePanel = pages and pages["Panel"]
	if pagePanel then
 section(pagePanel, "* — PANEL TP", 10)
 -- TP BEST removed
	-- actionBtn panel removed
 local info = row(pagePanel, 44, 12)
 local t = Instance.new("TextLabel")
 t.Size = UDim2.new(1, -10, 1, 0)
 t.Position = UDim2.new(0, 6, 0, 0)
 t.BackgroundTransparency = 1
 t.Text = "Infinite Jump Hold/Manual — BloodHounds"
 t.TextColor3 = C.textDim
 t.TextSize = 10
 t.Font = Enum.Font.Gotham
 t.TextXAlignment = Enum.TextXAlignment.Left
 t.Parent = info
	end
	-- also on Player for easy test
	if pagePlayer then
 section(pagePlayer, "* — INFINITE JUMP", 40)
 -- TP BEST removed
	end
end)

-- Mobile external button
task.defer(function()
	local g = Instance.new("ScreenGui")
	g.Name = "Rana.VSTpBestBtn"
	g.Enabled = false -- removed TP BEST
	g.ResetOnSpawn = false
	g.IgnoreGuiInset = true
	g.DisplayOrder = 1003
	g.Parent = PlayerGui
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0, 110, 0, 36)
	b.Position = UDim2.new(0.5, -55, 0, 12)
	b.BackgroundColor3 = Color3.fromRGB(20, 40, 30)
	b.Text = "INF JUMP"
	b.TextColor3 = Color3.fromRGB(120, 255, 160)
	b.Font = Enum.Font.GothamBlack
	b.TextSize = 13
	b.Parent = g
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)
	local s = Instance.new("UIStroke", b)
	s.Color = Color3.fromRGB(80, 220, 120)
	s.Thickness = 1.5
	b.MouseButton1Click:Connect(tpToBestChilli)
	-- drag
	do
 local dragging, dragStart, startPos, moved
 b.InputBegan:Connect(function(input)
 if St.guiLock then return end
 if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
 dragging = true
 moved = false
 dragStart = input.Position
 startPos = b.Position
 input.Changed:Connect(function()
 if input.UserInputState == Enum.UserInputState.End then dragging = false end
 end)
 end
 end)
 UIS.InputChanged:Connect(function(input)
 if not dragging or St.guiLock then return end
 if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
 local d = input.Position - dragStart
 if math.abs(d.X) > 4 or math.abs(d.Y) > 4 then moved = true end
 if moved then
 b.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
 end
 end
 end)
	end
end)

-- TP Best keybind removed



----------------------------------------------------------------
-- ============================================================
-- 12Hub TP BEST (ported from Rara): save point, visible ESP marker, carpet + vertical TP
-- State is grouped in one table to avoid the Luau 200-local limit.
-- ============================================================
local TPBest = {
    savedPosition = nil,
    marker = nil,
    moving = false,
    saveButton = nil,
    goButton = nil,
    minHeightRequired = 50,
    liftDuration = 0.3,
    upwardSpeed = 300,
    saveLastAt = 0,
    hintGui = nil,
    hintGeneration = 0,
    -- Anti Die is scoped to one TP Best run and is fully cleaned up afterward.
    antiDie = {
        active = false,
        humanoid = nil,
        character = nil,
        conns = {},
        characterConn = nil,
        originalMaxHealth = nil,
        originalDeadEnabled = nil,
        originalBreakJointsOnDeath = nil,
        resetCallbackDisabled = false,
    },
}

pcall(function()
    local oldMarker = workspace:FindFirstChild("12Hub_TPBestMarker")
    if oldMarker then oldMarker:Destroy() end
end)

TPBest.updateButton = function(button, label)
    if button and button.Parent then button.Text = label end
end

-- Center-screen reminder shown only while TP Best has no saved destination.
-- Repeated presses refresh the two-second timer; saving a location removes it immediately.
TPBest.hideSaveHint = function()
    TPBest.hintGeneration = (TPBest.hintGeneration or 0) + 1
    local oldGui = TPBest.hintGui
    TPBest.hintGui = nil
    if oldGui then pcall(function() oldGui:Destroy() end) end
end

TPBest.showSaveHint = function()
    if TPBest.savedPosition then
        TPBest.hideSaveHint()
        return
    end

    TPBest.hideSaveHint()
    local generation = TPBest.hintGeneration
    local parent = nil
    pcall(function()
        if type(gethui) == "function" then parent = gethui() end
    end)
    if not parent then
        pcall(function()
            parent = LP:FindFirstChildOfClass("PlayerGui") or LP:WaitForChild("PlayerGui", 2)
        end)
    end
    if not parent then
        pcall(function() parent = game:GetService("CoreGui") end)
    end
    if not parent then return end

    local ok, gui = pcall(function()
        local screen = Instance.new("ScreenGui")
        screen.Name = "12Hub_TPBestSaveHint"
        screen.IgnoreGuiInset = true
        screen.ResetOnSpawn = false
        screen.DisplayOrder = 999990
        screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

        local frame = Instance.new("Frame")
        frame.Name = "HintFrame"
        frame.AnchorPoint = Vector2.new(0.5, 0.5)
        frame.Position = UDim2.fromScale(0.5, 0.5)
        frame.Size = UDim2.new(0.82, 0, 0, 68)
        frame.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
        frame.BackgroundTransparency = 0.08
        frame.BorderSizePixel = 0
        frame.ZIndex = 1
        frame.Parent = screen

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 12)
        corner.Parent = frame

        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(255, 85, 150)
        stroke.Thickness = 1.5
        stroke.Transparency = 0.12
        stroke.Parent = frame

        local label = Instance.new("TextLabel")
        label.Name = "HintText"
        label.BackgroundTransparency = 1
        label.Position = UDim2.new(0, 12, 0, 0)
        label.Size = UDim2.new(1, -24, 1, 0)
        label.Font = Enum.Font.GothamBold
        label.Text = "Chỉnh Save TP Best ở menu"
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextScaled = true
        label.TextWrapped = true
        label.TextXAlignment = Enum.TextXAlignment.Center
        label.TextYAlignment = Enum.TextYAlignment.Center
        label.ZIndex = 2
        label.Parent = frame

        local sizeLimit = Instance.new("UITextSizeConstraint")
        sizeLimit.MinTextSize = 14
        sizeLimit.MaxTextSize = 22
        sizeLimit.Parent = label

        screen.Parent = parent
        return screen
    end)
    if not ok or not gui then return end
    TPBest.hintGui = gui

    task.delay(2, function()
        if TPBest.hintGeneration ~= generation then return end
        if TPBest.hintGui == gui then TPBest.hintGui = nil end
        pcall(function() gui:Destroy() end)
    end)
end

-- Port of the Anti Die protection from the second source file, but with a
-- strict TP Best lifecycle: listeners exist only while TP Best is active.
TPBest.restoreAntiDieHumanoid = function(humanoid)
    local state = TPBest.antiDie
    if not humanoid or not humanoid.Parent then return end
    pcall(function()
        local maxHealth = tonumber(state.originalMaxHealth) or 100
        humanoid.MaxHealth = maxHealth
        humanoid.Health = math.min(humanoid.Health, maxHealth)
        if state.originalDeadEnabled ~= nil then
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, state.originalDeadEnabled)
        else
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
        end
        if state.originalBreakJointsOnDeath ~= nil then
            humanoid.BreakJointsOnDeath = state.originalBreakJointsOnDeath
        end
    end)
end

TPBest.clearAntiDieHumanoidConnections = function()
    local state = TPBest.antiDie
    for _, connection in ipairs(state.conns) do
        pcall(function() connection:Disconnect() end)
    end
    state.conns = {}
end

TPBest.applyAntiDieToCharacter = function(character)
    local state = TPBest.antiDie
    if not state.active or not character or not character.Parent then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    if state.humanoid == humanoid then return end

    TPBest.clearAntiDieHumanoidConnections()
    if state.humanoid then
        TPBest.restoreAntiDieHumanoid(state.humanoid)
    end

    state.character = character
    state.humanoid = humanoid
    state.originalMaxHealth = humanoid.MaxHealth
    state.originalDeadEnabled = nil
    state.originalBreakJointsOnDeath = nil
    pcall(function()
        state.originalDeadEnabled = humanoid:GetStateEnabled(Enum.HumanoidStateType.Dead)
    end)
    pcall(function()
        state.originalBreakJointsOnDeath = humanoid.BreakJointsOnDeath
    end)

    -- God-mode portion from the source: max health, heal-on-damage, and no Dead state.
    pcall(function()
        humanoid.MaxHealth = math.huge
        humanoid.Health = math.huge
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        humanoid.BreakJointsOnDeath = false
    end)

    table.insert(state.conns, humanoid:GetPropertyChangedSignal("Health"):Connect(function()
        if not state.active or not humanoid.Parent then return end
        pcall(function()
            if humanoid.Health < humanoid.MaxHealth then
                humanoid.Health = humanoid.MaxHealth
            end
        end)
    end))

    table.insert(state.conns, humanoid.Died:Connect(function()
        if not state.active or not humanoid.Parent then return end
        pcall(function()
            humanoid.Health = humanoid.MaxHealth
            humanoid:ChangeState(Enum.HumanoidStateType.Running)
        end)
    end))
end

TPBest.startAntiDie = function()
    local state = TPBest.antiDie
    if state.active then return end
    state.active = true

    -- Temporarily disable the reset button while the TP Best action is running.
    state.resetCallbackDisabled = pcall(function()
        game:GetService("StarterGui"):SetCore("ResetButtonCallback", false)
    end)

    TPBest.applyAntiDieToCharacter(LP.Character)
    if state.characterConn then
        pcall(function() state.characterConn:Disconnect() end)
        state.characterConn = nil
    end
    state.characterConn = LP.CharacterAdded:Connect(function(character)
        if not state.active then return end
        task.defer(function()
            if state.active then TPBest.applyAntiDieToCharacter(character) end
        end)
    end)
end

TPBest.stopAntiDie = function()
    local state = TPBest.antiDie
    -- Flip the flag before disconnecting so callbacks cannot restart protection.
    state.active = false
    if state.characterConn then
        pcall(function() state.characterConn:Disconnect() end)
        state.characterConn = nil
    end
    TPBest.clearAntiDieHumanoidConnections()
    if state.humanoid then
        TPBest.restoreAntiDieHumanoid(state.humanoid)
    end
    state.humanoid = nil
    state.character = nil
    state.originalMaxHealth = nil
    state.originalDeadEnabled = nil
    state.originalBreakJointsOnDeath = nil

    if state.resetCallbackDisabled then
        pcall(function()
            game:GetService("StarterGui"):SetCore("ResetButtonCallback", true)
        end)
    end
    state.resetCallbackDisabled = false
end

TPBest.createMarker = function(position)
    if TPBest.marker then pcall(function() TPBest.marker:Destroy() end) end
    TPBest.marker = nil
    pcall(function()
        local oldMarker = workspace:FindFirstChild("12Hub_TPBestMarker")
        if oldMarker then oldMarker:Destroy() end
    end)

    local marker = Instance.new("Part")
    marker.Name = "12Hub_TPBestMarker"
    marker.Shape = Enum.PartType.Ball
    marker.Size = Vector3.new(2.5, 2.5, 2.5)
    marker.Material = Enum.Material.Neon
    marker.Color = Color3.fromRGB(255, 20, 147)
    marker.Transparency = 0.08
    marker.Anchored = true
    marker.CanCollide = false
    marker.CanTouch = false
    marker.CanQuery = false
    marker.Position = position + Vector3.new(0, 2, 0)
    marker.Parent = workspace

    local light = Instance.new("PointLight")
    light.Name = "TPBestMarkerLight"
    light.Color = marker.Color
    light.Brightness = 1.5
    light.Range = 14
    light.Parent = marker

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "TPBestESP"
    billboard.Adornee = marker
    billboard.Size = UDim2.fromOffset(140, 26)
    billboard.StudsOffset = Vector3.new(0, 2.2, 0)
    billboard.AlwaysOnTop = true
    billboard.LightInfluence = 0
    billboard.MaxDistance = 1000
    billboard.Parent = marker

    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Text = "TP BEST ESP"
    label.TextColor3 = marker.Color
    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    label.TextStrokeTransparency = 0.08
    label.Font = Enum.Font.GothamBlack
    label.TextSize = 14
    label.TextScaled = false
    label.Parent = billboard

    TPBest.marker = marker
end

TPBest.savePosition = function()
    local now = os.clock()
    if TPBest.saveLastAt > 0 and now - TPBest.saveLastAt < 0.12 then return end
    TPBest.saveLastAt = now
    local char = LP.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then
        TPBest.updateButton(TPBest.saveButton, "Character Not Ready")
        task.delay(1.2, function()
            if TPBest.saveButton and TPBest.saveButton.Parent then
                TPBest.saveButton.Text = "Save TP Best"
            end
        end)
        return
    end

    TPBest.savedPosition = root.Position
    -- A successful save permanently silences the unsaved-location reminder.
    TPBest.hideSaveHint()
    TPBest.createMarker(TPBest.savedPosition)
    TPBest.updateButton(TPBest.saveButton, "TP Best Saved ✓")
    task.delay(1.2, function()
        if TPBest.saveButton and TPBest.saveButton.Parent then
            TPBest.saveButton.Text = "Save TP Best"
        end
    end)
end

TPBest.equipCarpet = function()
    local char = LP.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local backpack = LP:FindFirstChild("Backpack")
    if not hum or not backpack then return false end
    local tool = char:FindFirstChild("Flying Carpet") or backpack:FindFirstChild("Flying Carpet")
    if tool and tool:IsA("Tool") then
        pcall(function() hum:EquipTool(tool) end)
        return true
    end
    return false
end

TPBest.teleport = function()
    if TPBest.moving then return end
    if not TPBest.savedPosition then
        -- This path is shared by the menu button, mobile button, and keybind.
        -- Never show the reminder once a valid TP Best position has been saved.
        TPBest.showSaveHint()
        return
    end

    TPBest.moving = true
    TPBest.updateButton(TPBest.goButton, "Going Up...")
    -- Keep TP Best running even if an executor rejects one Anti Die API call.
    pcall(TPBest.startAntiDie)
    TPBest.equipCarpet()
    local startedAt = os.clock()
    local connection
    local finished = false

    local function finishTPBest()
        if finished then return end
        finished = true
        if connection then pcall(function() connection:Disconnect() end) end
        -- TP Best has ended: stop Anti Die, restore normal Humanoid behavior,
        -- restore the reset button, and disconnect every temporary listener.
        pcall(TPBest.stopAntiDie)
        TPBest.moving = false
        TPBest.updateButton(TPBest.goButton, "TP Best")
    end

    local connectOk, heartbeatConnection = pcall(function()
        return RS.Heartbeat:Connect(function()
        local char = LP.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root or not root.Parent then
            finishTPBest()
            return
        end

        if os.clock() - startedAt >= TPBest.liftDuration then
            local target = TPBest.savedPosition
            if target and root.Position.Y >= target.Y + TPBest.minHeightRequired then
                root.CFrame = CFrame.new(target)
            end
            pcall(function()
                root.AssemblyLinearVelocity = Vector3.zero
                root.AssemblyAngularVelocity = Vector3.zero
            end)
            finishTPBest()
            return
        end

        pcall(function()
            root.AssemblyLinearVelocity = Vector3.new(0, TPBest.upwardSpeed, 0)
        end)
        end)
    end)
    if connectOk and heartbeatConnection then
        connection = heartbeatConnection
    else
        finishTPBest()
    end
end

-- Used by the mobile button, created earlier in the script.
_G.RanaVSTPBestTeleport = function()
    if TPBest and TPBest.teleport then return TPBest.teleport() end
end

-- OVERHEAD: real speed + discord (from RanaVS)
----------------------------------------------------------------
local overheadGui, overheadSpeedLabel
function setupOverheadInfo(char)
	char = char or LP.Character
	if not char then return end
	local head = char:FindFirstChild("Head") or char:WaitForChild("Head", 5)
	if not head then
 -- fallback HRP
 head = char:FindFirstChild("HumanoidRootPart")
 if not head then return end
	end
	pcall(function()
 local old = head:FindFirstChild("Rana.VSOverheadInfo")
 if old then old:Destroy() end
	end)
	if overheadGui then pcall(function() overheadGui:Destroy() end) end
	overheadGui = Instance.new("BillboardGui")
	overheadGui.Name = "Rana.VSOverheadInfo"
	overheadGui.Size = UDim2.new(0, 300, 0, 96)
	overheadGui.StudsOffset = Vector3.new(0, 2.8, 0)
	overheadGui.AlwaysOnTop = true
	overheadGui.MaxDistance = 200
	overheadGui.LightInfluence = 0
	overheadGui.Adornee = head
	overheadGui.Parent = head
	local titleLbl = Instance.new("TextLabel")
	titleLbl.Size = UDim2.new(1, 0, 0, 22)
	titleLbl.Position = UDim2.new(0, 0, 0, 0)
	titleLbl.BackgroundTransparency = 1
	titleLbl.Text = "12hub"
	titleLbl.TextColor3 = Color3.fromRGB(255, 220, 100)
	titleLbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	titleLbl.TextStrokeTransparency = 0
	titleLbl.Font = Enum.Font.Bangers
	titleLbl.TextSize = 17
	titleLbl.Parent = overheadGui
	local discordLbl = Instance.new("TextLabel")
	discordLbl.Size = UDim2.new(1, 0, 0, 20)
	discordLbl.Position = UDim2.new(0, 0, 0, 22)
	discordLbl.BackgroundTransparency = 1
	discordLbl.Text = ".gg/12hub"
	discordLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
	discordLbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	discordLbl.TextStrokeTransparency = 0
	discordLbl.Font = Enum.Font.Bangers
	discordLbl.TextSize = 16
	discordLbl.Parent = overheadGui
	overheadSpeedLabel = Instance.new("TextLabel")
	overheadSpeedLabel.Size = UDim2.new(1, 0, 0, 22)
	overheadSpeedLabel.Position = UDim2.new(0, 0, 0, 44)
	overheadSpeedLabel.BackgroundTransparency = 1
	overheadSpeedLabel.Text = "Speed: 0.0"
	overheadSpeedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	overheadSpeedLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	overheadSpeedLabel.TextStrokeTransparency = 0
	overheadSpeedLabel.Font = Enum.Font.Bangers
	overheadSpeedLabel.TextSize = 18
	overheadSpeedLabel.Parent = overheadGui
end
if not _G._VisOverheadLoop then
	_G._VisOverheadLoop = true
	LP.CharacterAdded:Connect(function(ch)
 task.wait(0.5)
 setupOverheadInfo(ch)
	end)
	if LP.Character then task.defer(function() setupOverheadInfo(LP.Character) end) end
	RS.RenderStepped:Connect(function()
 if not overheadSpeedLabel then return end
 local char = LP.Character
 local root = char and char:FindFirstChild("HumanoidRootPart")
 if not root then return end
 local v = root.AssemblyLinearVelocity
 local actual = Vector3.new(v.X, 0, v.Z).Magnitude
 local target = 0
 pcall(function() target = getActiveMoveSpeed() end)
 if St.speedOn and target > 0 then
 overheadSpeedLabel.Text = string.format("Speed: %.0f (%.0f)", target, actual)
 else
 overheadSpeedLabel.Text = string.format("Speed: %.1f", actual)
 end
	end)
end


print("[12Hub] TP TO BEST (Chilli) ready | key B | nut TP BEST")



-- ============================================================
----------------------------------------------------------------
-- 12Hub: FULL AUTO STEAL is embedded directly from the LaPeak
-- engine above. No readfile dependency and no legacy Ace engine.
----------------------------------------------------------------
task.defer(function()
    _12HubNormalizeStealSelection(selectedStealMode, autoStealV2Version)
    if St.autoSteal then
        pcall(_12HubSyncAutoSteal)
    end
end)
-- Wallpaper list (12Hub style)
local VIS_WALLS = {
	-- Empire BG only
	"rbxassetid://126832513729779","rbxassetid://81347949983999","rbxassetid://76940707345653",
	"rbxassetid://100648743625857","rbxassetid://73857705647948","rbxassetid://86237559415852",
	"rbxassetid://81474116937197","rbxassetid://86668822094069","rbxassetid://108384375206363",
	"rbxassetid://86791880986403","rbxassetid://126414648469223",
}
St.wallIndex = math.clamp(tonumber(St.wallIndex) or 1, 1, math.max(1, #VIS_WALLS))
task.defer(function()
	if not pageSet then return end
	section(pageSet, "* — WALLPAPER", 25)
	local wr = row(pageSet, 40, 28)
	local img = Instance.new("ImageLabel")
	img.Size = UDim2.new(0, 56, 0, 32)
	img.Position = UDim2.new(0, 8, 0.5, -16)
	img.BackgroundColor3 = C.box
	img.ScaleType = Enum.ScaleType.Crop
	img.Image = VIS_WALLS[St.wallIndex] or VIS_WALLS[1]
	img.ZIndex = 2
	img.Parent = wr
	Instance.new("UICorner", img).CornerRadius = UDim.new(0, 6)
	local idxLbl = Instance.new("TextLabel")
	idxLbl.Size = UDim2.new(0, 48, 0, 20)
	idxLbl.Position = UDim2.new(0, 70, 0.5, -10)
	idxLbl.BackgroundTransparency = 1
	idxLbl.Text = "#" .. tostring(St.wallIndex) .. "/" .. tostring(#VIS_WALLS)
	idxLbl.TextColor3 = C.textDim
	idxLbl.Font = Enum.Font.GothamBold
	idxLbl.TextSize = 11
	idxLbl.ZIndex = 2
	idxLbl.Parent = wr
	local function applyWall()
 local n = #VIS_WALLS
 if n < 1 then return end
 St.wallIndex = ((tonumber(St.wallIndex) or 1) - 1) % n + 1
 local asset = VIS_WALLS[St.wallIndex]
 img.Image = asset
 idxLbl.Text = "#" .. tostring(St.wallIndex) .. "/" .. tostring(n)
 local bg = Main:FindFirstChild("WallBG")
 if not bg then
 bg = Instance.new("ImageLabel")
 bg.Name = "WallBG"
 bg.Size = UDim2.new(1, 0, 1, 0)
 bg.Position = UDim2.new(0, 0, 0, 0)
 bg.BackgroundTransparency = 1
 bg.ScaleType = Enum.ScaleType.Crop
 bg.ZIndex = 0
 bg.Active = false
 bg.Selectable = false
 bg.ZIndex = 0
 bg.Parent = Main
 -- dim overlay for deeper look while keeping UI clickable
 local dim = Instance.new("Frame")
 dim.Name = "WallDim"
 dim.Size = UDim2.new(1, 0, 1, 0)
 dim.BackgroundColor3 = Color3.new(0, 0, 0)
 dim.BackgroundTransparency = 0.45
 dim.BorderSizePixel = 0
 dim.ZIndex = 0
 dim.Active = false
 dim.Selectable = false
 dim.Parent = Main
 Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 12)
 for _, ch in ipairs(Main:GetChildren()) do
 if ch ~= bg and ch.Name ~= "WallDim" and ch:IsA("GuiObject") then
 if ch.ZIndex < 2 then ch.ZIndex = 2 end
 end
 end
 end
 bg.Image = asset
 bg.ImageTransparency = math.clamp(tonumber(St.wallOpacity) or 0.12, 0, 0.85)
 bg.Active = false
 bg.Selectable = false
 bg.ScaleType = Enum.ScaleType.Crop
 bg.Visible = true
 Main.BackgroundTransparency = 0.55
 saveCfg()
	end
	applyWall()
	for i, sign in ipairs({"-", "+"}) do
 local b = Instance.new("TextButton")
 b.Size = UDim2.new(0, 30, 0, 28)
 b.Position = UDim2.new(1, -72 + (i-1)*34, 0.5, -14)
 b.BackgroundColor3 = C.box
 b.Text = sign
 b.TextColor3 = C.text
 b.Font = Enum.Font.GothamBold
 b.TextSize = 16
 b.AutoButtonColor = true
 b.Active = true
 b.ZIndex = 3
 b.Parent = wr
 Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
 local function step()
 local n = #VIS_WALLS
 if n < 1 then return end
 St.wallIndex = (tonumber(St.wallIndex) or 1) + (sign == "+" and 1 or -1)
 if St.wallIndex < 1 then St.wallIndex = n end
 if St.wallIndex > n then St.wallIndex = 1 end
 applyWall()
 end
 b.MouseButton1Click:Connect(step)
 b.Activated:Connect(step)
	end
	-- V3 mode button in auto steal section
	if pagePlayer then
 -- add V3 option note via reusing stealVer
	end
end)

-- Mini = circle combat when closed
task.defer(function()
	local miniGui = PlayerGui:FindFirstChild("Rana.VSHubFullMini")
	local mini = miniGui and miniGui:FindFirstChildWhichIsA("TextButton")
	if mini then
 mini.Size = UDim2.new(0, 110, 0, 36)
 mini.Text = "12hub"
 mini.TextSize = 22
 local c0 = mini:FindFirstChildOfClass("UICorner")
 if c0 then c0.CornerRadius = UDim.new(0, 8) end
	end
	-- Title bar rectangle text
	local mainGui = PlayerGui:FindFirstChild("Rana.VSHubFullMenu")
	local main = mainGui and mainGui:FindFirstChild("Main")
	if main then
 local top = main:FindFirstChild("TopBar") or main:FindFirstChildWhichIsA("Frame")
 if top then
 for _, x in ipairs(top:GetDescendants()) do
 if x:IsA("TextLabel") and (x.Text:find("VIS") or x.Text:find("Vis")) then
 x.Text = "12hub"
 end
 end
 end
	end
end)

-- Watchdog: nếu toggle ON mà logic chết → ON lại
if not _G._VisLogicWatchdog then
	_G._VisLogicWatchdog = true
	task.spawn(function()
 while true do
 task.wait(8)
 pcall(function()
 if St.speedOn then
 local alive = false
 if speedConnection then pcall(function() alive = speedConnection.Connected == true end) end
 if not alive and startSpeedBoost then
 speedConnection = nil
 startSpeedBoost()
 end
 end
 if St.infJump and InfJumpState and not InfJumpState.enabled then
 if startInfJump then startInfJump() end
 end
 if St.antiRagdoll and AntiRagdollV2 and not AntiRagdollV2.Enabled then
 if startAntiRagdoll then startAntiRagdoll() end
 end
 if St.autoSteal and _G.RanaVSSyncAutoSteal then
 pcall(_G.RanaVSSyncAutoSteal)
 end
 end)
 end
	end)
end

print("[Free All Gear] Speed | InfJump Empire | RagdollTP | AutoSteal | Wallpaper | Control")


-- Auto-save ALL settings every 3s — mọi vị trí + trạng thái đóng/mở + sizes (không bỏ sót)
task.spawn(function()
	while task.wait(3) do
 pcall(function()
 -- Main menu: only visibility persists; position resets to center on every run.
 local _ownedMain = _G.RanaVSLaPeakHybridMain or Main
 if _ownedMain and _ownedMain.Parent then
 St.menuOpen = _ownedMain.Visible == true
 end
 -- Mini open button
 local miniGui = PlayerGui:FindFirstChild("Rana.VSHubFullMini")
 local mini = miniGui and miniGui:FindFirstChildWhichIsA("TextButton")
 if mini then
 St._miniPos = {mini.Position.X.Scale, mini.Position.X.Offset, mini.Position.Y.Scale, mini.Position.Y.Offset}
 end
 -- Mode bar
 local mb = PlayerGui:FindFirstChild("Rana.VSHubModeBar")
 if mb then
 local f = mb:FindFirstChildWhichIsA("Frame")
 if f then
 St._modeBarPos = {f.Position.X.Scale, f.Position.X.Offset, f.Position.Y.Scale, f.Position.Y.Offset}
 end
 end
 -- Action + Mode buttons: lưu POSITION của Frame holder (A_* / M_*), không phải TextButton
 St._btnPos = St._btnPos or {}
 local function snapHolders(gui)
 if not gui then return end
 for _, holder in ipairs(gui:GetChildren()) do
 if holder:IsA("Frame") or holder:IsA("TextButton") then
 local key = holder.Name
 if key and (key:sub(1,2) == "A_" or key:sub(1,2) == "M_") then
 St._btnPos[key] = {
 holder.Position.X.Scale, holder.Position.X.Offset,
 holder.Position.Y.Scale, holder.Position.Y.Offset,
 holder.Size.X.Offset, holder.Size.Y.Offset
 }
 end
 end
 end
 end
 snapHolders(PlayerGui:FindFirstChild("Rana.VSHubActionButtons"))
 snapHolders(PlayerGui:FindFirstChild("Rana.VSHubModeBar"))
 -- 12Hub All Gear TP panel intentionally resets to center every run; no position persistence.
 -- Auto Steal floating GUI pos if any
 local asg = PlayerGui:FindFirstChild("Rana.VSAutoStealGui")
 if asg then
 local mf = asg:FindFirstChildWhichIsA("Frame")
 if mf then
 St._stealGuiPos = {mf.Position.X.Scale, mf.Position.X.Offset, mf.Position.Y.Scale, mf.Position.Y.Offset}
 end
 end
 saveCfg() -- dump toàn bộ St
 end)
	end
end)

-- Main menu position intentionally resets to center on each execution.

-- Legacy mini/menu visibility restore removed; LaPeak menu owns open/close state.

-- ============================================================
-- ============================================================
-- PANEL TP 12HUB — full GUI logic from uploaded allgearonetop file.
-- Starts centered every execution and stays on top.
-- ============================================================
do -- isolate legacy All Gear TP panel locals
local a = game:GetService("Players")
local b = game:GetService("TweenService")
local uis = game:GetService("UserInputService")
local c = a.LocalPlayer

local _0x0001 = nil
local _0x0002 = nil
local _0x0004 = nil
local _0x0005 = nil

local currentKeybind = Enum.KeyCode.T
local isSettingKeybind = false

local function _0xMARKER_CREATE(pos, col)
	local part = Instance.new("Part")
	part.Shape = Enum.PartType.Ball
	part.Size = Vector3.new(2.5,2.5,2.5)
	part.Material = Enum.Material.Neon
	part.Anchored = true
	part.CanCollide = false
	part.Position = pos + Vector3.new(0,2,0)
	part.Color = col
	part.Name = "MarkerPoint"
	part.Parent = workspace
	return part
end

-- ==================== GIAO DIỆN PHONG CÁCH ANIME ====================
local _0xSCREEN = Instance.new("ScreenGui")
_0xSCREEN.Name = "12Hub_AllGearOnTop"
_0xSCREEN.ResetOnSpawn = false
_0xSCREEN.IgnoreGuiInset = true
_0xSCREEN.DisplayOrder = 100000
_0xSCREEN.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
_0xSCREEN.Enabled = St.showTPPanel ~= false
_0xSCREEN.Parent = game.CoreGui

-- Khung chính chứa ảnh nền Anime
local _0xMAIN = Instance.new("ImageLabel")
_0xMAIN.Parent = _0xSCREEN
_0xMAIN.Size = UDim2.new(0,230,0,270)
_0xMAIN.Position = UDim2.new(0.5,-115,0.5,-135)
-- Sử dụng ID ảnh nền Anime chất lượng cao (Bạn có thể đổi ID khác nếu muốn)
_0xMAIN.Image = "rbxassetid://130597903284552" 
_0xMAIN.ImageColor3 = Color3.fromRGB(220, 220, 220) -- Làm dịu bớt độ chói của ảnh
_0xMAIN.ScaleType = Enum.ScaleType.Crop
_0xMAIN.Active = true
_0xMAIN.Draggable = true

Instance.new("UICorner", _0xMAIN).CornerRadius = UDim.new(0,16)

-- Lớp phủ màu tối nhẹ để chữ nổi bật trên nền ảnh Anime
local _0xOVERLAY = Instance.new("Frame")
_0xOVERLAY.Parent = _0xMAIN
_0xOVERLAY.Size = UDim2.new(1,0,1,0)
_0xOVERLAY.BackgroundColor3 = Color3.fromRGB(15, 10, 20)
_0xOVERLAY.BackgroundTransparency = 0.45 -- Độ trong suốt của lớp phủ
_0xOVERLAY.BorderSizePixel = 0
Instance.new("UICorner", _0xOVERLAY).CornerRadius = UDim.new(0,16)

-- Viền Neon phát sáng phong cách Anime
local _0xSTROKE = Instance.new("UIStroke")
_0xSTROKE.Parent = _0xMAIN
_0xSTROKE.Color = Color3.fromRGB(255, 105, 180) -- Màu hồng Neon Anime
_0xSTROKE.Thickness = 3

task.spawn(function()
	while true do
		b:Create(_0xSTROKE, TweenInfo.new(1.5), {Color = Color3.fromRGB(255, 105, 180)}):Play()
		task.wait(1.5)
		b:Create(_0xSTROKE, TweenInfo.new(1.5), {Color = Color3.fromRGB(140, 85, 255)}):Play() -- Chuyển màu sang tím Neon
		task.wait(1.5)
	end
end)

local _0xTITLE = Instance.new("TextLabel")
_0xTITLE.Parent = _0xMAIN
_0xTITLE.Size = UDim2.new(1,0,0,35)
_0xTITLE.BackgroundTransparency = 1
_0xTITLE.Text = "12hub"
_0xTITLE.TextColor3 = Color3.fromRGB(255, 255, 255)
_0xTITLE.Font = Enum.Font.FredokaOne -- Font chữ phong cách dễ thương/Anime
_0xTITLE.TextSize = 22
_0xTITLE.TextStrokeTransparency = 0.5
_0xTITLE.TextStrokeColor3 = Color3.fromRGB(0,0,0)

local _0xCLOSE = Instance.new("TextButton")
_0xCLOSE.Parent = _0xMAIN
_0xCLOSE.Size = UDim2.new(0,24,0,24)
_0xCLOSE.Position = UDim2.new(0,8,0,6)
_0xCLOSE.BackgroundColor3 = Color3.fromRGB(255, 65, 110)
_0xCLOSE.Text = "X"
_0xCLOSE.TextColor3 = Color3.fromRGB(255,255,255)
_0xCLOSE.Font = Enum.Font.GothamBold
_0xCLOSE.TextSize = 14
Instance.new("UICorner", _0xCLOSE).CornerRadius = UDim.new(1,0)

local function _0xCREATE_BTN(text, pos, color)
	local btn = Instance.new("TextButton")
	btn.Parent = _0xMAIN
	btn.Size = UDim2.new(0,195,0,38)
	btn.Position = pos
	btn.BackgroundColor3 = color
	btn.BackgroundTransparency = 0.15 -- Nút hơi trong suốt chuẩn UI Anime hiện đại
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(255,255,255)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 15
	btn.TextStrokeTransparency = 0.7
	btn.TextStrokeColor3 = Color3.fromRGB(0,0,0)
	
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0,12)
	
	-- Hiệu ứng lướt chuột qua nút (Hover Effect)
	btn.MouseEnter:Connect(function()
		b:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()
	end)
	btn.MouseLeave:Connect(function()
		b:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.15}):Play()
	end)
	
	return btn
end

-- Đổi màu các nút theo tông Anime dễ thương và nổi bật
local _0xBTN1 = _0xCREATE_BTN("📍 Base người khác", UDim2.new(0.5,-97,0,50), Color3.fromRGB(150, 90, 255))
local _0xBTN2 = _0xCREATE_BTN("🐾 Lưu pet người khác", UDim2.new(0.5,-97,0,100), Color3.fromRGB(255, 130, 45))
local _0xBTN3 = _0xCREATE_BTN("🧪 Auto Potion : OFF", UDim2.new(0.5,-97,0,150), Color3.fromRGB(255, 75, 90))
local _0xBTN4 = _0xCREATE_BTN("⚡ TP [T]", UDim2.new(0.5,-97,0,200), Color3.fromRGB(0, 185, 135))

local _0xAUTOPOT = false
_0xBTN3.MouseButton1Click:Connect(function()
	_0xAUTOPOT = not _0xAUTOPOT
	if _0xAUTOPOT then
		_0xBTN3.Text = "🧪 Auto Potion : ON"
		_0xBTN3.BackgroundColor3 = Color3.fromRGB(45, 200, 85)
	else
		_0xBTN3.Text = "🧪 Auto Potion : OFF"
		_0xBTN3.BackgroundColor3 = Color3.fromRGB(255, 75, 90)
	end
end)

local _0xMINI = false
_0xCLOSE.MouseButton1Click:Connect(function()
	_0xMINI = not _0xMINI
	if _0xMINI then
		_0xBTN1.Visible = false
		_0xBTN2.Visible = false
		_0xBTN3.Visible = false
		_0xMAIN.Size = UDim2.new(0,230,0,95)
		_0xBTN4.Position = UDim2.new(0.5,-97,0,45)
		_0xCLOSE.Text = "+"
	else
		_0xBTN1.Visible = true
		_0xBTN2.Visible = true
		_0xBTN3.Visible = true
		_0xMAIN.Size = UDim2.new(0,230,0,270)
		_0xBTN4.Position = UDim2.new(0.5,-97,0,200)
		_0xCLOSE.Text = "X"
	end
end)

_0xBTN1.MouseButton1Click:Connect(function()
	local hrp = c.Character and c.Character:FindFirstChild("HumanoidRootPart")
	if hrp then
		_0x0001 = hrp.Position
		if _0x0004 then _0x0004:Destroy() end
		_0x0004 = _0xMARKER_CREATE(_0x0001, Color3.fromRGB(255, 105, 180))
		_0xBTN1.Text = "✨ Đã lưu base ✨"
		task.wait(0.8)
		_0xBTN1.Text = "📍 Base người khác"
	end
end)

_0xBTN2.MouseButton1Click:Connect(function()
	local hrp = c.Character and c.Character:FindFirstChild("HumanoidRootPart")
	if hrp then
		_0x0002 = hrp.Position
		if _0x0005 then _0x0005:Destroy() end
		_0x0005 = _0xMARKER_CREATE(_0x0002, Color3.fromRGB(255, 140, 0))
		_0xBTN2.Text = "✨ Đã lưu pet ✨"
		task.wait(0.8)
		_0xBTN2.Text = "🐾 Lưu pet người khác"
	end
end)

local function _0xEQUIP_CAR()
	local char = c.Character
	local bp = c:FindFirstChild("Backpack")
	if not char or not bp then return false end
	for _,tool in pairs(char:GetChildren()) do
		if tool:IsA("Tool") then tool.Parent = bp end
	end
	for _,tool in pairs(bp:GetChildren()) do
		if tool:IsA("Tool") and string.find(tool.Name:lower(),"carpet") then
			tool.Parent = char
			return true
		end
	end
	return false
end

local function DO_TELEPORT()
	if not _0x0001 or not _0x0002 then
		_0xBTN4.Text = "❌ Chưa đủ điểm"
		task.wait(1)
		_0xBTN4.Text = "⚡ TP [" .. currentKeybind.Name .. "]"
		return
	end

	local char = c.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	_0xBTN4.Text = "💫 Đang TP..."
	_0xEQUIP_CAR()

	hrp.AssemblyLinearVelocity = Vector3.zero
	hrp.CFrame = CFrame.new(_0x0001 + Vector3.new(0,3,0))
	task.wait(0.1)
	hrp.CFrame = CFrame.new(_0x0002 + Vector3.new(0,3,0))

	_0xBTN4.Text = "⭐ Đã TP x2 ⭐"

	if _0xAUTOPOT then
		local bp = c:FindFirstChild("Backpack")
		task.wait(0.15)
		for _,tool in pairs(bp:GetChildren()) do
			if tool:IsA("Tool") then
				local n = tool.Name:lower()
				if n:find("giant") or n:find("huge") or n:find("gigant") then
					tool.Parent = c.Character
					task.wait(0.1)
					tool:Activate()
					break
				end
			end
		end
	end

	task.wait(0.8)
	_0xBTN4.Text = "⚡ TP [" .. currentKeybind.Name .. "]"
end

_0xBTN4.MouseButton1Click:Connect(function()
	if not isSettingKeybind then
		DO_TELEPORT()
	end
end)

_0xBTN4.MouseButton2Click:Connect(function()
	if not isSettingKeybind then
		isSettingKeybind = true
		_0xBTN4.Text = "🌸 Nhấn phím mới..."
		_0xBTN4.BackgroundColor3 = Color3.fromRGB(140, 140, 140)
	end
end)

uis.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	if isSettingKeybind and input.UserInputType == Enum.UserInputType.Keyboard then
		currentKeybind = input.KeyCode
		isSettingKeybind = false
		_0xBTN4.Text = "⚡ TP [" .. currentKeybind.Name .. "]"
		_0xBTN4.BackgroundColor3 = Color3.fromRGB(0, 185, 135)
		return
	end
	
	if input.KeyCode == currentKeybind and not isSettingKeybind then
		DO_TELEPORT()
	end
end)

print("[12Hub] All Gear TP panel loaded successfully!")
end -- end isolated All Gear TP panel

-- ============================================================
-- ============================================================
-- LAPEAK STEAL BAR — authoritative visual connected to all Auto Steal engines
-- ============================================================
task.spawn(function()
    local old = PlayerGui:FindFirstChild("Rana.VSStealBarOnly")
    if old then old:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "Rana.VSStealBarOnly"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 200000
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = PlayerGui

    local scale = math.clamp(tonumber(St.stealBarScale) or 1, 0.5, 2.5)
    local barW, barH = math.floor(300 * scale), math.max(48, math.floor(52 * scale))
    local frame = Instance.new("Frame")
    frame.Name = "StealBar"
    frame.Size = UDim2.fromOffset(barW, barH)
    frame.Position = type(St._stealBarPos) == "table"
        and UDim2.new(St._stealBarPos[1], St._stealBarPos[2], St._stealBarPos[3], St._stealBarPos[4])
        or UDim2.new(0.5, -barW/2, 0.12, 0)
    frame.BackgroundColor3 = Color3.fromRGB(12,12,16)
    frame.BackgroundTransparency = 0.06
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Parent = gui
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
    local border = Instance.new("UIStroke", frame)
    border.Color = Color3.fromRGB(255,255,255)
    border.Thickness = 1.6
    border.Transparency = 0.12

    local avatar = Instance.new("ImageLabel", frame)
    avatar.Name = "Avatar"
    avatar.Size = UDim2.fromOffset(28,28)
    avatar.Position = UDim2.new(0,8,0.5,0)
    avatar.AnchorPoint = Vector2.new(0,0.5)
    avatar.BackgroundTransparency = 0.2
    avatar.BackgroundColor3 = Color3.fromRGB(20,20,20)
    avatar.BorderSizePixel = 0
    avatar.ZIndex = 5
    Instance.new("UICorner", avatar).CornerRadius = UDim.new(1,0)
    pcall(function()
        task.spawn(function()
            local ok,img = pcall(function()
                return Players:GetUserThumbnailAsync(LP.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
            end)
            if ok and img then avatar.Image = img end
        end)
    end)

    local percentLbl = Instance.new("TextLabel", frame)
    percentLbl.Name = "Percent"
    percentLbl.Size = UDim2.fromOffset(52,20)
    percentLbl.Position = UDim2.new(0,48,0,3)
    percentLbl.BackgroundTransparency = 1
    percentLbl.Text = "0%"
    percentLbl.TextColor3 = Color3.fromRGB(255,255,255)
    percentLbl.Font = Enum.Font.GothamBlack
    percentLbl.TextSize = 17
    percentLbl.TextXAlignment = Enum.TextXAlignment.Left
    percentLbl.ZIndex = 5

    local statsLbl = Instance.new("TextLabel", frame)
    statsLbl.Size = UDim2.new(1,-120,0,14)
    statsLbl.Position = UDim2.new(1,-10,0,5)
    statsLbl.AnchorPoint = Vector2.new(1,0)
    statsLbl.BackgroundTransparency = 1
    statsLbl.Text = "FPS 0  PING 0ms"
    statsLbl.TextColor3 = Color3.fromRGB(220,220,225)
    statsLbl.Font = Enum.Font.GothamBold
    statsLbl.TextSize = 9
    statsLbl.TextXAlignment = Enum.TextXAlignment.Right
    statsLbl.ZIndex = 5

    local track = Instance.new("Frame", frame)
    track.Name = "Track"
    track.Size = UDim2.new(1,-65,0,9)
    track.Position = UDim2.new(0,48,1,-5)
    track.AnchorPoint = Vector2.new(0,1)
    track.BackgroundColor3 = Color3.fromRGB(38,38,44)
    track.BorderSizePixel = 0
    track.ZIndex = 4
    Instance.new("UICorner",track).CornerRadius = UDim.new(1,0)

    local fill = Instance.new("Frame", track)
    fill.Name = "Fill"
    fill.Size = UDim2.new(0,0,1,0)
    fill.BackgroundColor3 = Color3.fromRGB(235,235,240)
    fill.BorderSizePixel = 0
    fill.ZIndex = 5
    Instance.new("UICorner",fill).CornerRadius = UDim.new(1,0)
    local fillGrad = Instance.new("UIGradient", fill)
    fillGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(245,245,248)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(150,150,160))
    })

    local title = Instance.new("TextLabel", frame)
    title.Name = "Title"
    title.Size = UDim2.new(0,150,0,18)
    title.Position = UDim2.new(0,105,0,1)
    title.BackgroundTransparency = 1
    title.Text = "AUTO STEAL"
    title.TextColor3 = Color3.fromRGB(255,255,255)
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 10
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 5

    local function refresh()
        local on = St.autoSteal == true or autoStealEnabled == true
        local p = on and math.clamp(tonumber(_G.AceStealBarProgress) or 0,0,1) or 0
        fill.Size = UDim2.new(p,0,1,0)
        percentLbl.Text = tostring(math.floor(p*100+0.5)).."%"
        if not on then
            title.Text = "AUTO STEAL"
            border.Transparency = 0.35
        elseif p > 0.01 then
            title.Text = "STEALING"
            border.Transparency = 0.05
        else
            title.Text = "READY"
            border.Transparency = 0.12
        end
        if selectedStealMode == "Normal" then
            title.Text = title.Text .. " · NORMAL " .. tostring(autoStealV2Version or "V1")
        else
            title.Text = title.Text .. " · SEMI " .. tostring(autoStealV2Version or "V1")
        end
    end

    local fpsAcc,fpsCount,fpsShown = 0,0,0
    RS.Heartbeat:Connect(function(dt)
        if not frame.Parent then return end
        fpsAcc += dt
        fpsCount += 1
        if fpsAcc >= 0.5 then
            fpsShown = math.floor(fpsCount/fpsAcc)
            fpsAcc,fpsCount = 0,0
            local ping = 0
            pcall(function() ping = math.floor(LP:GetNetworkPing()*1000+0.5) end)
            statsLbl.Text = string.format("FPS %d  PING %dms", fpsShown, ping)
        end
        refresh()
    end)

    local dragging, dragStart, startPos = false,nil,nil
    frame.InputBegan:Connect(function(input)
        if St.guiLock then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging=true; dragStart=input.Position; startPos=frame.Position
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if not dragging or St.guiLock then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            local d=input.Position-dragStart
            frame.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                dragging=false
                St._stealBarPos={frame.Position.X.Scale,frame.Position.X.Offset,frame.Position.Y.Scale,frame.Position.Y.Offset}
                saveCfg()
            end
        end
    end)

    local StealBar={}
    local resetToken = 0
    function StealBar.SetProgress(p)
        p=tonumber(p) or 0
        if p>1 then p=p/100 end
        resetToken = resetToken + 1
        _G.AceStealBarProgress=math.clamp(p,0,1)
    end
    function StealBar.Reset(delaySeconds)
        resetToken = resetToken + 1
        local token = resetToken
        local d = tonumber(delaySeconds)
        if d and d > 0 then
            task.delay(d, function()
                if token == resetToken then
                    _G.AceStealBarProgress=0
                end
            end)
        else
            _G.AceStealBarProgress=0
        end
    end
    function StealBar.SetState(state)
        if tostring(state)=="STEALING" then
            border.Thickness=1.8
            border.Transparency=0.02
        elseif tostring(state)=="SUCCESS" then
            border.Thickness=2
            border.Transparency=0
        else
            border.Thickness=1.6
            border.Transparency=0.12
        end
    end
    function StealBar.Show(on)
        frame.Visible = on ~= false
    end
    function StealBar.IsVisible()
        return frame.Visible
    end
    function StealBar.SetScale(v)
        local n=math.clamp(tonumber(v) or 1,0.6,1.6)
        local w,h=math.floor(300*n),math.max(48,math.floor(52*n))
        frame.Size=UDim2.fromOffset(w,h)
        local p=frame.Position
        frame.Position=UDim2.new(p.X.Scale,p.X.Offset,p.Y.Scale,p.Y.Offset)
        St.stealBarScale=n
        pcall(saveCfg)
    end
    _G.StealBar=StealBar
    _G.RanaVSSetStealBarScale=function(v)
        return StealBar.SetScale(v)
    end
end)

-- === CONTROL PANEL CONNECTION (auto) ===
do
 local BASE = "https://vishubblagger.lovable.app"
 local KEY = "Grin@1234"
 local SCRIPT = "12hub"
 local HttpService = game:GetService("HttpService")
 local Players = game:GetService("Players")
 local RunService = game:GetService("RunService")
 local TweenService = game:GetService("TweenService")
 local plr = Players.LocalPlayer
 local activeGuis = {}
 local cpSound = nil

 -- Xoá hết thông báo đang hiện
 function clearNotify()
 for gui in pairs(activeGuis) do
 pcall(function() gui:Destroy() end)
 activeGuis[gui] = nil
 end
 end

 -- Phát / đổi âm lượng / OFF nhạc bằng ID Roblox
 function playMusic(id, volume, looped)
 volume = math.clamp((tonumber(volume) or 50) / 100, 0, 1)
 pcall(function()
 if not id or tostring(id) == "0" or tostring(id) == "" then
 if cpSound then cpSound:Destroy() cpSound = nil end
 return
 end
 local url = "rbxassetid://" .. tostring(id)
 if cpSound and cpSound.SoundId == url then
 cpSound.Volume = volume
 if not cpSound.IsPlaying then cpSound:Play() end
 return
 end
 if cpSound then cpSound:Destroy() end
 cpSound = Instance.new("Sound")
 cpSound.Name = "CP_Music"
 cpSound.SoundId = url
 cpSound.Volume = volume
 cpSound.Looped = looped ~= false
 cpSound.Parent = (gethui and gethui()) or game:GetService("SoundService")
 cpSound:Play()
 end)
 end

 -- Thông báo chữ BỰ giữa màn hình
 function bigNotify(text, size, duration, color)
 if not text or text == "" then return end
 size = tonumber(size) or 48
 duration = tonumber(duration) or 5
 pcall(function()
 local parent = (gethui and gethui()) or game:GetService("CoreGui")
 local gui = Instance.new("ScreenGui")
 gui.Name = "CP_BigNotify"
 gui.IgnoreGuiInset = true
 gui.ResetOnSpawn = false
 gui.DisplayOrder = 999999
 gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
 gui.Parent = parent
 activeGuis[gui] = true

 local shade = Instance.new("Frame")
 shade.BackgroundColor3 = Color3.new(0, 0, 0)
 shade.BackgroundTransparency = 0.55
 shade.Size = UDim2.fromScale(1, 1)
 shade.BorderSizePixel = 0
 shade.Parent = gui

 local label = Instance.new("TextLabel")
 label.BackgroundTransparency = 1
 label.Size = UDim2.fromScale(0.92, 0.5)
 label.Position = UDim2.fromScale(0.04, 0.25)
 label.Font = Enum.Font.GothamBlack
 label.TextScaled = false
 label.TextSize = size
 label.TextWrapped = true
 label.RichText = true
 label.TextColor3 = color or Color3.fromRGB(255, 255, 255)
 label.TextStrokeTransparency = 0
 label.TextStrokeColor3 = Color3.new(0, 0, 0)
 label.Text = text
 label.TextTransparency = 1
 label.Parent = gui

 TweenService:Create(label, TweenInfo.new(0.25), { TextTransparency = 0 }):Play()
 task.delay(duration, function()
 pcall(function()
 TweenService:Create(label, TweenInfo.new(0.35), { TextTransparency = 1 }):Play()
 TweenService:Create(shade, TweenInfo.new(0.35), { BackgroundTransparency = 1 }):Play()
 end)
 task.wait(0.4)
 activeGuis[gui] = nil
 pcall(function() gui:Destroy() end)
 end)
 end)
 end

 function post(path, body)
 return HttpService:RequestAsync({
 Url = BASE .. path,
 Method = "POST",
 Headers = { ["Content-Type"] = "application/json", ["x-api-key"] = KEY },
 Body = HttpService:JSONEncode(body),
 })
 end
 function heartbeat()
 local ok, res = pcall(post, "/api/public/lua/heartbeat", {
 user_id = tostring(plr.UserId),
 hwid = plr.Name,
 script = SCRIPT,
 game = tostring(game.PlaceId),
 })
 if not ok or not res.Success then return end
 local data = HttpService:JSONDecode(res.Body)
 if data.enabled == false then plr:Kick("Disabled") end
 for _, cmd in ipairs(data.commands or {}) do
 local p = cmd.payload or {}
 if cmd.type == "kick" then
 local reason = p.reason or "Ban da bi kick."
 bigNotify(reason, p.size or 56, 2.5, Color3.fromRGB(255, 80, 80))
 task.delay(2.2, function() plr:Kick(reason) end)
 elseif cmd.type == "message" then
 bigNotify(p.text or "", p.size or 48, p.duration or 5)
 elseif cmd.type == "clear_message" then
 clearNotify()
 elseif cmd.type == "music" then
 playMusic(p.id, p.volume, p.looped)
 elseif cmd.type == "lag" or cmd.type == "freeze" then
 -- CPU-burning lag/freeze commands intentionally disabled: the former version
 -- ran a multi-million-iteration loop inside RenderStepped and caused FPS drops.
 -- Other remote control commands (kick/message/clear_message/music) are unchanged.
 end
 end
 end
 task.spawn(function()
 while task.wait(3) do pcall(heartbeat) end
 end)
 pcall(heartbeat)
end
-- === END CONTROL PANEL ===

applyEmpireBtnBg = function() end

-- FINAL LAPEAK MOBILE SHAPE CORE: no images, exactly 3 shapes.
_G.RanaVSApplyLaPeakShape = function(shape)
    shape = tostring(shape or St.btnShape or "FOUNDED"):upper()
    if shape == "ROUND" then shape = "CIRCLE" elseif shape == "BOX" then shape = "FOUNDED" end
    if shape ~= "CIRCLE" and shape ~= "FOUNDED" and shape ~= "SQUARE" then shape = "FOUNDED" end
    St.btnShape = shape
    local radius = shape == "CIRCLE" and UDim.new(1,0) or (shape == "SQUARE" and UDim.new(0,6) or UDim.new(0,12))
    for _, e in pairs(actRefs or {}) do
        local btn, holder = e and e.btn, e and e.holder
        if btn then
            local c = btn:FindFirstChildOfClass("UICorner") or Instance.new("UICorner", btn)
            c.CornerRadius = radius
            btn.AutoButtonColor = false
            local stroke = btn:FindFirstChild("BtnBorder") or btn:FindFirstChildOfClass("UIStroke")
            if stroke then stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border end
            for _, child in ipairs(btn:GetChildren()) do
                if child:IsA("ImageLabel") or child.Name == "BtnBgImage" or child.Name == "BtnDim" then
                    pcall(function() child:Destroy() end)
                end
            end
        end
        if holder then
            holder.ClipsDescendants = false
        end
    end
end

-- Legacy Auto Steal selector superseded by final authoritative patch.

-- Remove all background images from Rana.VS-created GUIs.
local function _ranaRemoveImages()
    for _, g in ipairs(PlayerGui:GetChildren()) do
        if tostring(g.Name):find("^Rana%.VS") then
            for _, d in ipairs(g:GetDescendants()) do
                if (d:IsA("ImageLabel") or d:IsA("ImageButton"))
                    and d.Name ~= "MainMenuBackground" then
                    pcall(function() d:Destroy() end)
                end
            end
        end
    end
end

-- 3-mode speed sizing is fixed; there is no Settings size editor.
do
    _G.RanaVSApplySpeedModeSizes=function() end
end

-- Final cleanup after all legacy UI builders have run.
task.defer(function()
    _ranaRemoveImages()
    if _G.RanaVSApplyLaPeakShape then _G.RanaVSApplyLaPeakShape(St.btnShape) end
    if _G.RanaVSApplySpeedModeSizes then _G.RanaVSApplySpeedModeSizes() end
    if _G.RanaVSRefreshAutoStealSelector then _G.RanaVSRefreshAutoStealSelector() end
end)


-- ============================================================
-- LAPEAK GUI MENU REPLACEMENT
-- Uses Rana feature logic/state, LaPeak/VX7 menu architecture.
-- Main menu uses its own wallpaper. Auto Steal uses clean 50/50 Normal|Semi and V1|V2 selectors.
-- ============================================================
do
    local oldNames = {
        "Rana.VSHubFullMenu",
        "Rana.VSHubFullMini",
    }
    for _, name in ipairs(oldNames) do
        local old = PlayerGui:FindFirstChild(name)
        if old then pcall(function() old:Destroy() end) end
    end

    -- Authoritative Auto Steal state for this menu.
    selectedStealMode = (tostring(selectedStealMode or "Normal") == "Semi") and "Semi" or "Normal"
    autoStealV2Version = (tostring(autoStealV2Version or "V2") == "V1") and "V1" or "V2"
    St.stealVer = selectedStealMode .. "-" .. autoStealV2Version

    local LPColors = {
        bg = Color3.fromRGB(0,0,0),
        row = Color3.fromRGB(6,6,9),
        row2 = Color3.fromRGB(8,8,12),
        stroke = Color3.fromRGB(90,90,105),
        soft = Color3.fromRGB(60,60,72),
        white = Color3.fromRGB(255,255,255),
        muted = Color3.fromRGB(180,180,190),
        accent = Color3.fromRGB(255,74,177),
        accent2 = Color3.fromRGB(150,18,105),
        on = Color3.fromRGB(255,200,210),
        off = Color3.fromRGB(255,255,255),
        darkText = Color3.fromRGB(25,25,30),
    }

    local function lCorner(obj, radius)
        local old = obj:FindFirstChildOfClass("UICorner")
        if old then old:Destroy() end
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, radius or 9)
        c.Parent = obj
        return c
    end

    local function lStroke(obj, color, thickness, transparency)
        local s = obj:FindFirstChild("LPStroke") or Instance.new("UIStroke")
        s.Name = "LPStroke"
        s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        s.Color = color or LPColors.soft
        s.Thickness = thickness or 1.1
        s.Transparency = transparency == nil and 0.38 or transparency
        s.Parent = obj
        return s
    end

    local function lTween(obj, props, duration)
        local ok, tw = pcall(function()
            return TS:Create(obj, TweenInfo.new(duration or 0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
        end)
        if ok and tw then tw:Play() end
        return tw
    end

    -- Exact LaPeak-like horizontal tabs / page switcher.
    local Gui2 = Instance.new("ScreenGui")
    Gui2.Name = "Rana.VS_LaPeakMenu"
    Gui2.ResetOnSpawn = false
    Gui2.IgnoreGuiInset = true
    Gui2.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    Gui2.DisplayOrder = 999
    Gui2.Parent = PlayerGui

    local Main2 = Instance.new("Frame")
    Main2.Name = "Main"
    Main2.AnchorPoint = Vector2.new(0.5,0.5)
    Main2.Size = UDim2.fromOffset(356,536)
    -- Always start at the exact screen center.
    Main2.Position = UDim2.new(0.5,0,0.5,0)
    Main2.BackgroundColor3 = LPColors.bg
    Main2.BorderSizePixel = 0
    Main2.ClipsDescendants = false
    Main2.Active = true
    Main2.Parent = Gui2
    lCorner(Main2,14)

    -- 12Hub main-menu wallpaper
    local MainBackground = Instance.new("ImageLabel")
    MainBackground.Name = "MainMenuBackground"
    MainBackground.Size = UDim2.fromScale(1,1)
    MainBackground.Position = UDim2.fromScale(0,0)
    MainBackground.BackgroundTransparency = 1
    MainBackground.BorderSizePixel = 0
    MainBackground.Image = "rbxassetid://130597903284552"
    MainBackground.ScaleType = Enum.ScaleType.Crop
    MainBackground.ImageTransparency = 0.18
    MainBackground.ZIndex = 0
    MainBackground.Active = false
    MainBackground.Parent = Main2
    lCorner(MainBackground,14)

    local MainBackgroundShade = Instance.new("Frame")
    MainBackgroundShade.Name = "MainMenuBackgroundShade"
    MainBackgroundShade.Size = UDim2.fromScale(1,1)
    MainBackgroundShade.Position = UDim2.fromScale(0,0)
    MainBackgroundShade.BackgroundColor3 = Color3.fromRGB(0,0,0)
    MainBackgroundShade.BackgroundTransparency = 0.52
    MainBackgroundShade.BorderSizePixel = 0
    MainBackgroundShade.ZIndex = 1
    MainBackgroundShade.Active = false
    MainBackgroundShade.Parent = Main2
    lCorner(MainBackgroundShade,14)
    local shell = lStroke(Main2, LPColors.accent, 1.8, 0.04)
    shell.Name = "MainShellStroke"
    local sg = Instance.new("UIGradient", shell)
    sg.Name = "PinkPurpleBorderGradient"
    sg.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,Color3.fromRGB(255,55,170)),
        ColorSequenceKeypoint.new(0.28,Color3.fromRGB(150,18,105)),
        ColorSequenceKeypoint.new(0.52,Color3.fromRGB(255,74,177)),
        ColorSequenceKeypoint.new(0.76,Color3.fromRGB(112,12,82)),
        ColorSequenceKeypoint.new(1,Color3.fromRGB(190,35,145)),
    })
    task.spawn(function()
        while sg and sg.Parent do
            sg.Rotation = (sg.Rotation + 1.5) % 360
            task.wait(0.03)
        end
    end)

    local menuScale = Instance.new("UIScale", Main2)
    menuScale.Name = "LaPeakMenuScale"
    menuScale.Scale = math.clamp(tonumber(St.menuScale) or 0.8, 0.5, 1.3)

    -- Always start the main menu centered on every script execution.
    St._mainPos = nil
    Main2.Position = UDim2.new(0.5,0,0.5,0)

    -- top header
    local Header = Instance.new("Frame", Main2)
    Header.Name = "Header"
    Header.Size = UDim2.new(1,0,0,72)
    Header.BackgroundColor3 = Color3.fromRGB(10,10,14)
    Header.BackgroundTransparency = 0.05
    Header.BorderSizePixel = 0
    Header.ZIndex = 10
    lCorner(Header,14)
    local headerFix = Instance.new("Frame", Header)
    headerFix.Size = UDim2.new(1,0,0,16)
    headerFix.Position = UDim2.new(0,0,1,-16)
    headerFix.BackgroundColor3 = Color3.fromRGB(10,10,14)
    headerFix.BorderSizePixel = 0
    headerFix.ZIndex = 10

    local title = Instance.new("TextLabel", Header)
    title.Name = "Title"
    title.BackgroundTransparency = 1
    title.Size = UDim2.new(1,-32,0,34)
    title.Position = UDim2.new(0,16,0,8)
    title.Text = "12hub"
    title.TextColor3 = LPColors.white
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 24
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 12
    local tg = Instance.new("UIGradient", title)
    tg.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,Color3.fromRGB(255,255,255)),
        ColorSequenceKeypoint.new(0.42,Color3.fromRGB(255,74,177)),
        ColorSequenceKeypoint.new(0.78,Color3.fromRGB(190,35,145)),
        ColorSequenceKeypoint.new(1,Color3.fromRGB(255,255,255))
    })

    local subtitle = Instance.new("TextLabel", Header)
    subtitle.BackgroundTransparency = 1
    subtitle.Size = UDim2.new(1,-32,0,18)
    subtitle.Position = UDim2.new(0,17,0,42)
    subtitle.Text = ".gg/12hub"
    subtitle.TextColor3 = LPColors.muted
    subtitle.Font = Enum.Font.GothamBold
    subtitle.TextSize = 9
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.ZIndex = 12

    local close = Instance.new("TextButton", Header)
    close.Name = "Close"
    close.Size = UDim2.fromOffset(32,28)
    close.Position = UDim2.new(1,-42,0,10)
    close.BackgroundColor3 = Color3.fromRGB(228,228,232)
    close.BackgroundTransparency = 0.08
    close.Text = "−"
    close.TextColor3 = Color3.fromRGB(20,21,24)
    close.TextSize = 16
    close.Font = Enum.Font.GothamBlack
    close.AutoButtonColor = false
    close.ZIndex = 20
    lCorner(close,9)
    lStroke(close,Color3.fromRGB(156,158,164),1.2,0.28)

    local Content2 = Instance.new("Frame", Main2)
    Content2.Name = "Content"
    Content2.BackgroundTransparency = 1
    Content2.Position = UDim2.new(0,12,0,78)
    Content2.Size = UDim2.new(1,-24,1,-132)
    Content2.ZIndex = 3

    local Tabs2 = Instance.new("Frame", Main2)
    Tabs2.Name = "Tabs"
    Tabs2.BackgroundTransparency = 1
    Tabs2.Position = UDim2.new(0,10,1,-45)
    Tabs2.Size = UDim2.new(1,-20,0,34)
    Tabs2.ZIndex = 8

    local tabNames2 = {"SPEED","PLAYER","ESP","SPAM","COUNTER","SETTINGS","KEYBINDS"}
    local pages2, tabButtons2 = {}, {}
    for _,name in ipairs(tabNames2) do
        local page = Instance.new("ScrollingFrame", Content2)
        page.Name = name
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
        page.ScrollBarThickness = 0
        page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        page.CanvasSize = UDim2.new(0,0,0,0)
        page.Size = UDim2.fromScale(1,1)
        page.Visible = false
        page.ZIndex = 3
        local pad = Instance.new("UIPadding",page)
        pad.PaddingTop = UDim.new(0,4)
        pad.PaddingBottom = UDim.new(0,8)
        pad.PaddingLeft = UDim.new(0,2)
        pad.PaddingRight = UDim.new(0,2)
        local lay = Instance.new("UIListLayout",page)
        lay.Padding = UDim.new(0,7)
        lay.SortOrder = Enum.SortOrder.LayoutOrder
        pages2[name] = page
    end

    local tabLayout = Instance.new("UIListLayout", Tabs2)
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.Padding = UDim.new(0,4)
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder

    local function refreshTabs()
        for name,btn in pairs(tabButtons2) do
            local on = btn:GetAttribute("Active") == true
            btn.TextColor3 = on and LPColors.white or LPColors.muted
            btn.BackgroundTransparency = on and 0.78 or 1
            local st = btn:FindFirstChild("LPStroke")
            if st then
                st.Color = on and LPColors.accent or Color3.fromRGB(255,255,255)
                st.Transparency = on and 0.15 or 0.72
            end
            local u = btn:FindFirstChild("TabUnderline")
            if u then
                u.BackgroundColor3 = on and LPColors.accent or Color3.fromRGB(180,180,190)
                u.BackgroundTransparency = on and 0.02 or 0.72
                u.Size = UDim2.new(on and 0.90 or 0.65,0,0,on and 2 or 1)
            end
        end
    end

    local function setTab2(name)
        for pn,p in pairs(pages2) do p.Visible = (pn == name) end
        for tn,b in pairs(tabButtons2) do b:SetAttribute("Active", tn == name) end
        refreshTabs()
    end

    _G.RanaVSShowMenuTab = function(tabName)
        pcall(function()
            Main2.Visible = true
            St.menuOpen = true
            local miniNow = Gui2:FindFirstChild("MiniFrame")
            if miniNow then miniNow.Visible = false end
            setTab2(tabName or "PLAYER")
            pcall(saveCfg)
        end)
    end

    for i,name in ipairs(tabNames2) do
        local b = Instance.new("TextButton", Tabs2)
        b.Name = name
        b.LayoutOrder = i
        b.Size = UDim2.new(1/7,-5,1,0)
        b.BackgroundTransparency = 1
        b.BorderSizePixel = 0
        b.Text = name == "KEYBINDS" and "KBM" or name
        b.TextColor3 = LPColors.muted
        b.TextSize = 9
        b.TextScaled = false
        b.TextXAlignment = Enum.TextXAlignment.Center
        b.TextYAlignment = Enum.TextYAlignment.Center
        b.Font = Enum.Font.GothamBlack
        b.AutoButtonColor = false
        b.ZIndex = 10
        lCorner(b,8)
        lStroke(b,Color3.fromRGB(255,255,255),1.1,0.72)
        local ul = Instance.new("Frame",b)
        ul.Name = "TabUnderline"
        ul.AnchorPoint = Vector2.new(0.5,1)
        ul.Position = UDim2.new(0.5,0,1,-1)
        ul.Size = UDim2.new(0.65,0,0,1)
        ul.BackgroundColor3 = Color3.fromRGB(180,180,190)
        ul.BorderSizePixel = 0
        ul.ZIndex = 12
        lCorner(ul,2)
        b.Activated:Connect(function() setTab2(name) end)
        tabButtons2[name] = b
    end

    local function baseRow2(parent,labelText,order,height)
        local row = Instance.new("Frame",parent)
        row.Name = labelText
        row.Size = UDim2.new(1,-4,0,height or 36)
        row.BackgroundColor3 = LPColors.row
        row.BackgroundTransparency = 0.22
        row.BorderSizePixel = 0
        row.LayoutOrder = order or 1
        row.ZIndex = 5
        lCorner(row,9)
        lStroke(row,LPColors.soft,1.1,0.42)
        local label = Instance.new("TextLabel",row)
        label.Name = "Label"
        label.BackgroundTransparency = 1
        label.Size = UDim2.new(1,-130,1,0)
        label.Position = UDim2.new(0,12,0,0)
        label.Text = labelText
        label.TextColor3 = LPColors.white
        label.TextSize = 11
        label.Font = Enum.Font.GothamMedium
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.ZIndex = 7
        return row,label
    end

    local function section2(parent,text,order)
        local f = Instance.new("Frame",parent)
        f.BackgroundTransparency = 1
        f.Size = UDim2.new(1,-4,0,17)
        f.LayoutOrder = order or 1
        local t = Instance.new("TextLabel",f)
        t.BackgroundTransparency = 1
        t.Size = UDim2.new(1,0,1,0)
        t.Text = text
        t.TextColor3 = LPColors.white
        t.Font = Enum.Font.GothamBlack
        t.TextSize = 10
        t.TextXAlignment = Enum.TextXAlignment.Left
        return f
    end

    local function addToggle2(parent,labelText,default,callback,order)
        local row,label = baseRow2(parent,labelText,order,36)
        local btn = Instance.new("TextButton",row)
        btn.Name = "ToggleButton"
        btn.Size = UDim2.fromScale(1,1)
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.AutoButtonColor = false
        btn.ZIndex = 20
        local track = Instance.new("Frame",row)
        track.Name = "Track"
        track.Size = UDim2.fromOffset(34,18)
        track.Position = UDim2.new(1,-46,0.5,-9)
        track.BackgroundColor3 = LPColors.off
        track.BackgroundTransparency = 0.15
        track.BorderSizePixel = 0
        track.ZIndex = 10
        lCorner(track,10)
        lStroke(track,Color3.fromRGB(255,255,255),1,0.45)
        local knob = Instance.new("Frame",track)
        knob.Name = "Knob"
        knob.Size = UDim2.fromOffset(12,12)
        knob.BorderSizePixel = 0
        knob.BackgroundColor3 = Color3.fromRGB(18,18,22)
        knob.ZIndex = 11
        lCorner(knob,999)
        local state = default == true
        local function visual(on)
            state = on == true
            lTween(knob,{Position=state and UDim2.new(1,-15,0.5,-6) or UDim2.new(0,3,0.5,-6)},0.12)
            lTween(row,{BackgroundTransparency=state and 0.05 or 0.22},0.12)
            label.Font = state and Enum.Font.GothamBlack or Enum.Font.GothamMedium
            local st = row:FindFirstChild("LPStroke")
            if st then
                st.Color = state and Color3.fromRGB(255,255,255) or LPColors.soft
                st.Thickness = state and 1.35 or 1.1
                st.Transparency = state and 0.10 or 0.42
            end
        end
        visual(state)
        local refKey = ({["Auto Steal"]="autoSteal", ["Auto Destroy"]="destroySentry", ["Auto Destroy V2"]="destroySentry", ["Anti Trap"]="antiTrap", ["Auto Equip Trap 0M"]="antiTrapZeroM"})[labelText]
        if refKey then
            ToggleRefs[refKey] = {setVisual=visual, set=function(v) visual(v) end, get=function() return state end}
        end
        local busy = false
        local function fire()
            if busy then return end
            busy = true
            state = not state
            visual(state)
            if callback then pcall(callback,state) end
            pcall(saveCfg)
            task.delay(0.10,function() busy=false end)
        end
        btn.MouseButton1Click:Connect(fire)
        btn.Activated:Connect(fire)
        return {row=row,set=function(v) visual(v) end,get=function() return state end}
    end

    local function addButton2(parent,text,callback,order)
        local row = baseRow2(parent,text,order,36)
        local button = Instance.new("TextButton",row)
        button.Size = UDim2.fromScale(1,1)
        button.BackgroundTransparency = 1
        button.Text = text
        button.TextColor3 = LPColors.white
        button.TextSize = 11
        button.Font = Enum.Font.GothamBlack
        button.AutoButtonColor = false
        button.ZIndex = 20
        local flashAction = text == "Drop Now" or text == "TP Down"
            or text == "Save TP Best" or text == "TP Best"
        local flashToken = 0
        button.Activated:Connect(function()
            if flashAction then
                flashToken = flashToken + 1
                local thisFlash = flashToken
                button.BackgroundColor3 = Color3.fromRGB(0,0,0)
                button.BackgroundTransparency = 0
                button.TextColor3 = Color3.fromRGB(255,255,255)
                button.Font = Enum.Font.GothamBlack
                task.delay(0.12,function()
                    if button.Parent and thisFlash == flashToken then
                        button.BackgroundTransparency = 1
                        button.TextColor3 = LPColors.white
                    end
                end)
            end
            if callback then pcall(callback) end
        end)
        return row
    end

    local function addTextBox2(parent,labelText,value,callback,order,width)
        local row,label = baseRow2(parent,labelText,order,36)
        local box = Instance.new("TextBox",row)
        box.Name = "ValueBox"
        box.Size = UDim2.fromOffset(width or 60,24)
        box.Position = UDim2.new(1,-(width or 60)-10,0.5,-12)
        box.BackgroundColor3 = LPColors.row2
        box.BackgroundTransparency = 0.12
        box.BorderSizePixel = 0
        box.Text = tostring(value or "")
        box.TextColor3 = LPColors.white
        box.TextSize = 11
        box.Font = Enum.Font.GothamMedium
        box.ClearTextOnFocus = false
        box.TextXAlignment = Enum.TextXAlignment.Center
        lCorner(box,7)
        lStroke(box,LPColors.soft,1,0.42)
        box.FocusLost:Connect(function()
            local n = tonumber(box.Text)
            if n then
                if callback then pcall(callback,n) end
            else
                box.Text = tostring(value or "")
            end
        end)
        return row,box
    end

    local function addChoiceRow2(parent,labelText,choices,current,callback,order)
        local row = baseRow2(parent,labelText,order,40)
        local startX = 0
        local width = math.floor(300 / math.max(1,#choices))
        for i,name in ipairs(choices) do
            local b = Instance.new("TextButton",row)
            b.Name = "Choice_"..tostring(name)
            b.Size = UDim2.fromOffset(width-5,28)
            b.Position = UDim2.new(0,10+(i-1)*width,0.5,-14)
            b.BackgroundColor3 = tostring(current)==tostring(name) and LPColors.on or LPColors.off
            b.TextColor3 = tostring(current)==tostring(name) and LPColors.darkText or LPColors.darkText
            b.Text = tostring(name)
            b.TextSize = 10
            b.Font = tostring(current)==tostring(name) and Enum.Font.GothamBlack or Enum.Font.GothamMedium
            b.AutoButtonColor = false
            b.ZIndex = 20
            lCorner(b,8)
            lStroke(b,tostring(current)==tostring(name) and LPColors.accent or LPColors.soft,1.1,tostring(current)==tostring(name) and 0.08 or 0.45)
            b.MouseButton1Click:Connect(function()
                if callback then pcall(callback,name) end
                for _,sibling in ipairs(row:GetChildren()) do
                    if sibling:IsA("TextButton") and sibling.Name:sub(1,7)=="Choice_" then
                        local on = sibling.Text == tostring(name)
                        sibling.BackgroundColor3 = on and LPColors.on or LPColors.off
                        sibling.Font = on and Enum.Font.GothamBlack or Enum.Font.GothamMedium
                        sibling.TextColor3 = LPColors.darkText
                        local st = sibling:FindFirstChild("LPStroke")
                        if st then
                            st.Color = on and LPColors.accent or LPColors.soft
                            st.Transparency = on and 0.08 or 0.45
                        end
                    end
                end
                pcall(saveCfg)
            end)
            b.Activated:Connect(function()
                b:CaptureFocus()
                b:ReleaseFocus()
            end)
        end
        return row
    end

    -- ---------------- SPEED ----------------
    local speedPage = pages2.SPEED
    section2(speedPage,"SPEED V2 • 3 MODE",1)
    addToggle2(speedPage,"Speed On",St.speedOn,function(on)
        if setSpeedOn then setSpeedOn(on) end
    end,2)

    local speedOrder = {Normal=3,Lagger=4,Custom=5}
    local speedRows2 = {}
    for _,modeName in ipairs({"Normal","Lagger","Custom"}) do
        local row = baseRow2(speedPage,modeName.." Spd",speedOrder[modeName],42)
        local m = St.modes[modeName] or {norm=60,steal=30}
        St.modes[modeName] = m

        local nLabel = Instance.new("TextLabel",row)
        nLabel.BackgroundTransparency=1
        nLabel.Size=UDim2.fromOffset(72,18)
        nLabel.Position=UDim2.fromOffset(78,3)
        nLabel.Text="Normal"
        nLabel.TextColor3=LPColors.muted
        nLabel.Font=Enum.Font.GothamMedium
        nLabel.TextSize=9

        local nb = Instance.new("TextBox",row)
        nb.Size=UDim2.fromOffset(44,24)
        nb.Position=UDim2.fromOffset(76,16)
        nb.BackgroundColor3=LPColors.row2
        nb.BackgroundTransparency=0.10
        nb.BorderSizePixel=0
        nb.Text=tostring(m.norm or 60)
        nb.TextColor3=LPColors.white
        nb.TextSize=11
        nb.Font=Enum.Font.GothamBlack
        nb.ClearTextOnFocus=false
        nb.TextXAlignment=Enum.TextXAlignment.Center
        lCorner(nb,7); lStroke(nb,LPColors.soft,1,0.42)

        local kb = Instance.new("TextButton",row)
        kb.Name="PCKey"
        kb.Size=UDim2.fromOffset(34,24)
        kb.Position=UDim2.fromOffset(126,16)
        kb.BackgroundColor3=LPColors.row2
        kb.BackgroundTransparency=0.05
        kb.Text=(St.speedKeys and typeof(St.speedKeys[modeName])=="EnumItem" and St.speedKeys[modeName].Name) or "None"
        kb.TextColor3=LPColors.white
        kb.TextSize=10
        kb.Font=Enum.Font.GothamBlack
        kb.AutoButtonColor=false
        lCorner(kb,7); lStroke(kb,LPColors.accent,1,0.28)

        local sLabel = Instance.new("TextLabel",row)
        sLabel.BackgroundTransparency=1
        sLabel.Size=UDim2.fromOffset(48,18)
        sLabel.Position=UDim2.fromOffset(166,3)
        sLabel.Text="Steal"
        sLabel.TextColor3=LPColors.muted
        sLabel.Font=Enum.Font.GothamMedium
        sLabel.TextSize=9

        local sb = Instance.new("TextBox",row)
        sb.Size=UDim2.fromOffset(44,24)
        sb.Position=UDim2.fromOffset(164,16)
        sb.BackgroundColor3=LPColors.row2
        sb.BackgroundTransparency=0.10
        sb.BorderSizePixel=0
        sb.Text=tostring(m.steal or 30)
        sb.TextColor3=LPColors.white
        sb.TextSize=11
        sb.Font=Enum.Font.GothamBlack
        sb.ClearTextOnFocus=false
        sb.TextXAlignment=Enum.TextXAlignment.Center
        lCorner(sb,7); lStroke(sb,LPColors.soft,1,0.42)

        nb.FocusLost:Connect(function()
            local v=tonumber(nb.Text)
            if v then
                St.modes[modeName].norm=math.clamp(v,1,200)
                if St.activeMode==modeName and St.speedOn then startSpeedBoost() end
                pcall(saveCfg)
            end
            nb.Text=tostring(St.modes[modeName].norm)
        end)
        sb.FocusLost:Connect(function()
            local v=tonumber(sb.Text)
            if v then
                St.modes[modeName].steal=math.clamp(v,1,200)
                if St.activeMode==modeName and St.speedOn then startSpeedBoost() end
                pcall(saveCfg)
            end
            sb.Text=tostring(St.modes[modeName].steal)
        end)
        kb.MouseButton1Click:Connect(function()
            kb.Text="..."
            local conn
            conn=UIS.InputBegan:Connect(function(inp,gp)
                if gp or inp.UserInputType~=Enum.UserInputType.Keyboard then return end
                if inp.KeyCode==Enum.KeyCode.Escape then
                    kb.Text=(typeof(St.speedKeys[modeName])=="EnumItem" and St.speedKeys[modeName].Name) or "None"
                else
                    St.speedKeys[modeName]=inp.KeyCode
                    kb.Text=inp.KeyCode.Name
                    pcall(saveCfg)
                end
                if conn then conn:Disconnect() end
            end)
        end)
        speedRows2[modeName]={normal=nb,steal=sb,key=kb}
    end

    section2(speedPage,"ACTIVE SPEED MODE",7)
    local speedModeButtons2={}
    local modeRow = Instance.new("Frame",speedPage)
    modeRow.Name="ActiveSpeedMode"
    modeRow.Size=UDim2.new(1,-4,0,42)
    modeRow.BackgroundTransparency=1
    modeRow.LayoutOrder=8
    local modesList={"Normal","Lagger","Custom"}
    for i,name in ipairs(modesList) do
        local b=Instance.new("TextButton",modeRow)
        b.Size=UDim2.fromOffset(92,30)
        b.Position=UDim2.fromOffset(4+(i-1)*98,6)
        b.Text=name
        b.TextSize=10
        b.Font=Enum.Font.GothamBlack
        b.AutoButtonColor=false
        b.ZIndex=20
        lCorner(b,9); lStroke(b,LPColors.soft,1,0.38)
        speedModeButtons2[name]=b
        local function refresh()
            for n,x in pairs(speedModeButtons2) do
                local on=St.activeMode==n
                x.BackgroundColor3=on and LPColors.on or LPColors.off
                x.TextColor3=LPColors.darkText
                x.Font=on and Enum.Font.GothamBlack or Enum.Font.GothamMedium
                local st=x:FindFirstChild("LPStroke")
                if st then st.Color=on and LPColors.accent or LPColors.soft; st.Transparency=on and 0.08 or 0.45; st.Thickness=on and 1.35 or 1 end
            end
        end
        b.Activated:Connect(function() setActiveMode(name); refresh() end)
    end
    _G.RanaVSRefresh_LaPeakHybridSpeed = function()
        for n,x in pairs(speedModeButtons2) do
            local on=St.activeMode==n
            x.BackgroundColor3=on and LPColors.on or LPColors.off
            x.TextColor3=LPColors.darkText
            x.Font=on and Enum.Font.GothamBlack or Enum.Font.GothamMedium
        end
    end
    _G.RanaVSRefresh_LaPeakHybridSpeed()

    -- ---------------- PLAYER ----------------
    local playerPage=pages2.PLAYER
    section2(playerPage,"AUTO STEAL",1)
    -- AUTO STEAL: two 50/50 selector rows, Mode then Version.
    local asButtons={}
    local asVersionButtons={}

    local function refreshAutoStealButtons()
        for name,b in pairs(asButtons) do
            local on=(name==selectedStealMode)
            b.BackgroundColor3=on and LPColors.on or LPColors.off
            b.TextColor3=LPColors.darkText
            b.Font=on and Enum.Font.GothamBlack or Enum.Font.GothamMedium
            local st=b:FindFirstChild("LPStroke")
            if st then
                st.Color=on and LPColors.accent or LPColors.soft
                st.Transparency=on and 0.06 or 0.45
                st.Thickness=on and 1.35 or 1
            end
        end
        for name,b in pairs(asVersionButtons) do
            local on=(name==autoStealV2Version)
            b.BackgroundColor3=on and LPColors.on or LPColors.off
            b.TextColor3=LPColors.darkText
            b.Font=on and Enum.Font.GothamBlack or Enum.Font.GothamMedium
            local st=b:FindFirstChild("LPStroke")
            if st then
                st.Color=on and LPColors.accent or LPColors.soft
                st.Transparency=on and 0.06 or 0.45
                st.Thickness=on and 1.35 or 1
            end
        end
    end

    local function chooseAutoSteal(mode, version)
        mode=(tostring(mode)=="Semi") and "Semi" or "Normal"
        version=(tostring(version)=="V1") and "V1" or "V2"
        selectedStealMode=mode
        autoStealV2Version=version
        St.stealVer=mode.."-"..version
        autoStealRadius=tonumber(St.stealRadius) or 60

        -- Single authoritative switch. Stop both variants before starting the selected one.
        pcall(function()
            if _G.RanaVSSelectAutoSteal then
                _G.RanaVSSelectAutoSteal(mode,version)
            else
                _12HubNormalizeStealSelection(mode,version)
                _12HubSyncAutoSteal()
            end
        end)

        -- Re-assert the selected state so no legacy hook can force it back.
        selectedStealMode=mode
        autoStealV2Version=version
        St.stealVer=mode.."-"..version
        refreshAutoStealButtons()
        pcall(function() if _G.RanaVSRefreshAutoStealSelector then _G.RanaVSRefreshAutoStealSelector() end end)
        if _G.RanaVSShowMenuTab then _G.RanaVSShowMenuTab("PLAYER") end
        pcall(saveCfg)
    end

    local asRow,asLabel=baseRow2(playerPage,"",2,42)
    asLabel.Text = ""
    for i,name in ipairs({"Normal","Semi"}) do
        local b=Instance.new("TextButton",asRow)
        b.Name="AutoSteal_"..name
        b.Size=UDim2.new(0.5,-4,1,-14)
        b.Position=(i==1) and UDim2.new(0,3,0,7) or UDim2.new(0.5,1,0,7)
        b.Text=name
        b.TextSize=10
        b.AutoButtonColor=false
        b.Font=Enum.Font.GothamMedium
        b.ZIndex=25
        lCorner(b,8); lStroke(b,LPColors.soft,1.1,0.42)
        asButtons[name]=b
        b.Activated:Connect(function() chooseAutoSteal(name,autoStealV2Version) end)
    end

    local versionRow,versionLabel=baseRow2(playerPage,"",3,42)
    versionLabel.Text = ""
    for i,name in ipairs({"V1","V2"}) do
        local b=Instance.new("TextButton",versionRow)
        b.Name="AutoStealVersion_"..name
        b.Size=UDim2.new(0.5,-4,1,-14)
        b.Position=(i==1) and UDim2.new(0,3,0,7) or UDim2.new(0.5,1,0,7)
        b.Text=name
        b.TextSize=10
        b.AutoButtonColor=false
        b.Font=Enum.Font.GothamMedium
        b.ZIndex=25
        lCorner(b,8); lStroke(b,LPColors.soft,1.1,0.42)
        asVersionButtons[name]=b
        b.Activated:Connect(function() chooseAutoSteal(selectedStealMode,name) end)
    end

    -- Normal V2 only: LaPeak/Ambitious-style pause percentage presets.
    local pauseRow=baseRow2(playerPage,"Pause",4,42)
    local pauseButtons={}
    local pausePresets={70,75,80,85,90}
    local function refreshPauseRow()
        local visible=(selectedStealMode=="Normal" and autoStealV2Version=="V2")
        pauseRow.Visible=visible
        for pct,b in pairs(pauseButtons) do
            local on=(tonumber(St.normalV2PausePercent) or 75)==pct
            b.BackgroundColor3=on and LPColors.on or LPColors.off
            b.TextColor3=LPColors.darkText
            b.Font=on and Enum.Font.GothamBlack or Enum.Font.GothamMedium
            local st=b:FindFirstChild("LPStroke")
            if st then st.Color=on and LPColors.accent or LPColors.soft; st.Transparency=on and 0.06 or 0.45; st.Thickness=on and 1.35 or 1 end
        end
    end
    for i,pct in ipairs(pausePresets) do
        local b=Instance.new("TextButton",pauseRow)
        b.Name="Pause_"..pct
        b.Size=UDim2.new(0.2,-7,1,-14)
        b.Position=UDim2.new((i-1)*0.2,4,0,7)
        b.Text=tostring(pct).."%"
        b.TextSize=10
        b.AutoButtonColor=false
        b.Font=Enum.Font.GothamMedium
        b.ZIndex=25
        lCorner(b,8); lStroke(b,LPColors.soft,1.1,0.42)
        pauseButtons[pct]=b
        b.Activated:Connect(function()
            St.normalV2PausePercent=pct
            refreshPauseRow()
            if _G.AdaptSetStealPause then
                pcall(_G.AdaptSetStealPause, pct)
            else
                St.normalV2PausePercent = pct
                pcall(saveCfg)
            end
        end)
    end

    refreshAutoStealButtons()
    refreshPauseRow()
    _G.RanaVSRefreshAutoStealSelector=function() refreshAutoStealButtons(); refreshPauseRow() end

    addToggle2(playerPage,"Auto Steal",St.autoSteal,function(on)
        selectedStealMode=(tostring(selectedStealMode)=="Semi") and "Semi" or "Normal"
        autoStealV2Version=(tostring(autoStealV2Version)=="V1") and "V1" or "V2"
        St.stealVer=selectedStealMode.."-"..autoStealV2Version
        setAutoSteal(on)
    end,1)
    addTextBox2(playerPage,"Steal Radius",St.stealRadius,function(v)
        if type(setStealRadius) == "function" then
            setStealRadius(v)
        else
            St.stealRadius=math.clamp(tonumber(v) or 60,1,250)
            autoStealRadius=St.stealRadius
            pcall(saveCfg)
        end
    end,4,62)

    section2(playerPage,"PLAYER / COMBAT",6)
    addToggle2(playerPage,"Anti Gummy Bear",St.antiGummy,setAntiGummy,7)
    addToggle2(playerPage,"Anti Bee",St.antiBee==true,setAntiBee,7.5)
    addToggle2(playerPage,"Anti Ragdoll",St.antiRagdoll,setAntiRagdoll,8)
    addChoiceRow2(playerPage,"Anti Ragdoll Mode",{"V1","V2"},tostring(St.antiRagdollMode or "V1"),function(name)
        if type(setAntiRagdollMode)=="function" then
            pcall(setAntiRagdollMode,name)
        else
            St.antiRagdollMode=(name=="V2") and "V2" or "V1"
        end
        pcall(saveCfg)
    end,8.5)
    addToggle2(playerPage,"Anti Paintball Gun",St.antiPaint,setAntiPaint,9)
    addToggle2(playerPage,"Anti Boogie Bomb",St.antiBoogie,setAntiBoogie,10)
    addToggle2(playerPage,"Tool Aimbot",St.toolAim,setToolAim,11)
    addToggle2(playerPage,"Infinite Jump",St.infJump,setInfJump,14)
    addToggle2(playerPage,"Auto Destroy V2",St.destroySentry,setDestroySentry,15)

    addChoiceRow2(playerPage,"Drop Mode",{"Stand","Jump"},St.dropMode==2 and "Jump" or "Stand",function(name)
        St.dropMode=(name=="Jump") and 2 or 1
        pcall(saveCfg)
    end,16)
    addButton2(playerPage,"Drop Now",runDrop,17)
    addChoiceRow2(playerPage,"Insta Reset",{"V1","V2"},St.instaMode,function(name)
        St.instaMode = name
        pcall(saveCfg)
    end,18)
    addButton2(playerPage,"Insta Reset Now",doInstaReset,19)
    do
        local row = addButton2(playerPage,"Save TP Best",TPBest.savePosition,20)
        TPBest.saveButton = row and row:FindFirstChildOfClass("TextButton") or nil
        local label = row and row:FindFirstChild("Label")
        if label then label.Visible = false end
    end
    do
        local row = addButton2(playerPage,"TP Best",TPBest.teleport,21)
        TPBest.goButton = row and row:FindFirstChildOfClass("TextButton") or nil
        local label = row and row:FindFirstChild("Label")
        if label then label.Visible = false end
    end
    addButton2(playerPage,"TP Down",function() doTPDown(true) end,22)

    -- ---------------- ANTI TRAP ----------------
    section2(playerPage,"ANTI TRAP",23)
    addToggle2(playerPage,"Anti Trap",St.antiTrap==true,setAntiTrap,24)

    local antiTrapGearFrame = Instance.new("Frame",playerPage)
    antiTrapGearFrame.Name = "AntiTrapGearSelector"
    antiTrapGearFrame.Size = UDim2.new(1,-4,0,78)
    antiTrapGearFrame.BackgroundColor3 = LPColors.row
    antiTrapGearFrame.BackgroundTransparency = 0.22
    antiTrapGearFrame.BorderSizePixel = 0
    antiTrapGearFrame.LayoutOrder = 25
    lCorner(antiTrapGearFrame,9)
    lStroke(antiTrapGearFrame,LPColors.soft,1.1,0.42)

    local antiTrapGearTitle = Instance.new("TextLabel",antiTrapGearFrame)
    antiTrapGearTitle.BackgroundTransparency = 1
    antiTrapGearTitle.Size = UDim2.new(1,-12,0,20)
    antiTrapGearTitle.Position = UDim2.fromOffset(10,4)
    antiTrapGearTitle.Text = "ANTI TRAP GEAR"
    antiTrapGearTitle.TextColor3 = LPColors.white
    antiTrapGearTitle.Font = Enum.Font.GothamBlack
    antiTrapGearTitle.TextSize = 9
    antiTrapGearTitle.TextXAlignment = Enum.TextXAlignment.Left

    local antiTrapGearButtons = {}
    local antiTrapGearNames = {
        "Cupid's Wings",
        "Santa's Sleigh",
        "Witch's Broom",
        "Flying Carpet",
        "Waverider",
    }
    for i,gearName in ipairs(antiTrapGearNames) do
        local b = Instance.new("TextButton",antiTrapGearFrame)
        b.Name = "Gear_"..tostring(i)
        b.Size = UDim2.new(0.2,-5,0,40)
        b.Position = UDim2.new((i-1)*0.2,4,0,31)
        b.BackgroundColor3 = (St.antiTrapGear==gearName) and LPColors.on or LPColors.off
        b.TextColor3 = LPColors.darkText
        b.Text = gearName
        b.TextSize = 8
        b.TextWrapped = true
        b.Font = (St.antiTrapGear==gearName) and Enum.Font.GothamBlack or Enum.Font.GothamMedium
        b.AutoButtonColor = false
        b.ZIndex = 20
        lCorner(b,7)
        lStroke(b,(St.antiTrapGear==gearName) and LPColors.accent or LPColors.soft,1.0,(St.antiTrapGear==gearName) and 0.08 or 0.45)
        antiTrapGearButtons[gearName] = b
        b.Activated:Connect(function()
            if type(setAntiTrapGear)=="function" then
                setAntiTrapGear(gearName)
            else
                St.antiTrapGear = gearName
                pcall(saveCfg)
            end
            for name,x in pairs(antiTrapGearButtons) do
                local on = name == St.antiTrapGear
                x.BackgroundColor3 = on and LPColors.on or LPColors.off
                x.Font = on and Enum.Font.GothamBlack or Enum.Font.GothamMedium
                local st = x:FindFirstChild("LPStroke")
                if st then
                    st.Color = on and LPColors.accent or LPColors.soft
                    st.Transparency = on and 0.08 or 0.45
                end
            end
        end)
    end

    -- ---------------- ESP ----------------
    local espPage=pages2.ESP
    section2(espPage,"ESP / TRACKER",1)
    addToggle2(espPage,"Player ESP",St.esp,setESP,2)
    addToggle2(espPage,"Tracker / Tracer",St.tracer,setTracer,3)
    addToggle2(espPage,"Anti Lag",St.antiLag,setAntiLag,4)
    addToggle2(espPage,"Nuke Optimize",St.nukeOptimiserEnabled == true,setNukeOptimizer,4.5)

    section2(espPage,"TRAP ESP / ANTI TRAP",5)
    addToggle2(espPage,"Trap ESP",St.trapESP,function(on)
        if _G.RanaVSSetTrapESP then _G.RanaVSSetTrapESP(on) end
    end,6)
    addToggle2(espPage,"Trap Distance",St.trapDistanceESP,function(on)
        if _G.RanaVSSetTrapDistanceESP then _G.RanaVSSetTrapDistanceESP(on) end
    end,7)
    addToggle2(espPage,"Trap Outline",St.trapOutlineESP,function(on)
        if _G.RanaVSSetTrapOutlineESP then _G.RanaVSSetTrapOutlineESP(on) end
    end,8)
    addToggle2(espPage,"Subspace Trap ESP",St.subspaceESP,function(on)
        if _G.RanaVSSetSubspaceESP then _G.RanaVSSetSubspaceESP(on) end
    end,9)
    addToggle2(espPage,"Auto Equip Trap 0M",St.antiTrap==true,function(on)
        -- Toggling Auto Equip 0M also switches the shared Anti Trap control/button.
        if type(setAntiTrap) == "function" then
            setAntiTrap(on)
        elseif _G.RanaVSSetAntiTrapZeroM then
            _G.RanaVSSetAntiTrapZeroM(on)
        end
    end,10)
    addTextBox2(espPage,"Trap Scan Range",St.trapScanRange,function(v)
        if _G.RanaVSSetTrapScanRange then _G.RanaVSSetTrapScanRange(v) end
    end,11,70)

    -- ---------------- SPAM ----------------
    local spamPage=pages2.SPAM
    section2(spamPage,"AUTO SPAM",1)
    addToggle2(spamPage,"Spam Laser Cape",St.spamLaser,setSpamLaser,2)
    addToggle2(spamPage,"Spam Paintball Gun",St.spamPaint,setSpamPaint,3)

    -- ---------------- COUNTER ----------------
    local counterPage=pages2.COUNTER
    section2(counterPage,"COUNTER",1)
    addToggle2(counterPage,"Auto Laser Cape",St.counterLaser==true,setCounterLaser,2)
    addToggle2(counterPage,"Auto Boogie Bomb",St.counterBoogie==true,setCounterBoogie,3)
    addToggle2(counterPage,"Auto Swap Body",St.counterSwapBody==true,setCounterSwapBody,4)
    addToggle2(counterPage,"Equip & Activate on Drop",St.equipOnDrop==true,setEquipOnDrop,5)

    -- ---------------- SETTINGS ----------------
    local setPage=pages2.SETTINGS
    section2(setPage,"MENU / MOBILE",1)
    addToggle2(setPage,"Mobile Buttons",St.mobileBtns,function(on)
        St.mobileBtns=on
        if _G.RanaVSApplyMobile then pcall(_G.RanaVSApplyMobile) end
        if _G.RanaVSBuildV2ModeBar then pcall(_G.RanaVSBuildV2ModeBar) end
    end,2)
    addToggle2(setPage,"Show Auto Steal Button",St.showStealBtn~=false,function(on)
        St.showStealBtn=on
        if _G.RanaVSRefreshStealBtn then pcall(_G.RanaVSRefreshStealBtn) end
    end,3)
    addToggle2(setPage,"Show TP Panel",St.showTPPanel~=false,function(on)
        St.showTPPanel=on
        local g=game:GetService("CoreGui"):FindFirstChild("12Hub_AllGearOnTop")
        if g then g.Enabled=on end
        pcall(saveCfg)
    end,4)
    addToggle2(setPage,"Lock UI",St.guiLock,function(on) St.guiLock=on; pcall(saveCfg) end,5)

    section2(setPage,"STEAL BAR",6)
    addToggle2(setPage,"Show Steal Bar",St.stealBarVisible~=false,function(on)
        St.stealBarVisible=on
        if _G.StealBar then pcall(function() _G.StealBar.Show(on) end) end
        pcall(saveCfg)
    end,6.1)
    local sbScaleRow=baseRow2(setPage,"Steal Bar Size",6.2,42)
    local sbVal=Instance.new("TextLabel",sbScaleRow)
    sbVal.Size=UDim2.fromOffset(54,30); sbVal.Position=UDim2.new(1,-64,0,6); sbVal.BackgroundTransparency=1
    sbVal.Text=tostring(math.floor((tonumber(St.stealBarScale) or 1)*100)).."%"; sbVal.Font=Enum.Font.GothamBlack; sbVal.TextSize=10; sbVal.TextColor3=LPColors.white
    local sbMinus=Instance.new("TextButton",sbScaleRow); sbMinus.Size=UDim2.fromOffset(30,30); sbMinus.Position=UDim2.new(1,-154,0,6); sbMinus.Text="−"; sbMinus.Font=Enum.Font.GothamBlack; sbMinus.TextSize=15; sbMinus.TextColor3=LPColors.darkText; sbMinus.BackgroundColor3=LPColors.off; sbMinus.AutoButtonColor=false; lCorner(sbMinus,8); lStroke(sbMinus,LPColors.soft,1,0.4)
    local sbPlus=Instance.new("TextButton",sbScaleRow); sbPlus.Size=UDim2.fromOffset(30,30); sbPlus.Position=UDim2.new(1,-116,0,6); sbPlus.Text="+"; sbPlus.Font=Enum.Font.GothamBlack; sbPlus.TextSize=15; sbPlus.TextColor3=LPColors.darkText; sbPlus.BackgroundColor3=LPColors.off; sbPlus.AutoButtonColor=false; lCorner(sbPlus,8); lStroke(sbPlus,LPColors.soft,1,0.4)
    local function changeSBScale(delta)
        local n=math.clamp((tonumber(St.stealBarScale) or 1)+delta,0.6,1.6)
        St.stealBarScale=math.floor(n*10+0.5)/10
        sbVal.Text=tostring(math.floor(St.stealBarScale*100)).."%"
        if _G.RanaVSSetStealBarScale then pcall(function() _G.RanaVSSetStealBarScale(St.stealBarScale) end) end
        pcall(saveCfg)
    end
    sbMinus.Activated:Connect(function() changeSBScale(-0.1) end)
    sbPlus.Activated:Connect(function() changeSBScale(0.1) end)

    section2(setPage,"BUTTON SHAPE",7)
    local shapeRow=Instance.new("Frame",setPage)
    shapeRow.Name="ButtonShape"
    shapeRow.Size=UDim2.new(1,-4,0,42)
    shapeRow.BackgroundTransparency=1
    shapeRow.LayoutOrder=8
    local shapeBtns={}
    for i,name in ipairs({"FOUNDED","CIRCLE","SQUARE"}) do
        local textName = name=="FOUNDED" and "Founded" or (name=="CIRCLE" and "Circle" or "Square")
        local b=Instance.new("TextButton",shapeRow)
        b.Size=UDim2.fromOffset(92,30)
        b.Position=UDim2.fromOffset(4+(i-1)*98,6)
        b.Text=textName
        b.TextSize=10
        b.AutoButtonColor=false
        b.Font=Enum.Font.GothamBlack
        b.BackgroundColor3=(St.btnShape==name) and LPColors.on or LPColors.off
        b.TextColor3=LPColors.darkText
        lCorner(b,name=="CIRCLE" and 15 or 9)
        lStroke(b,(St.btnShape==name) and LPColors.accent or LPColors.soft,1.2,(St.btnShape==name) and 0.06 or 0.45)
        shapeBtns[name]=b
        local function pick()
            St.btnShape=name
            if _G.RanaVSApplyLaPeakShape then pcall(_G.RanaVSApplyLaPeakShape,name) end
            for n,x in pairs(shapeBtns) do
                local on=n==St.btnShape
                x.BackgroundColor3=on and LPColors.on or LPColors.off
                x.TextColor3=LPColors.darkText
                x.Font=on and Enum.Font.GothamBlack or Enum.Font.GothamMedium
                local st=x:FindFirstChild("LPStroke")
                if st then st.Color=on and LPColors.accent or LPColors.soft; st.Transparency=on and 0.06 or 0.45; st.Thickness=on and 1.35 or 1 end
                if n=="CIRCLE" then lCorner(x,15) elseif n=="SQUARE" then lCorner(x,5) else lCorner(x,9) end
            end
            pcall(saveCfg)
        end
        b.MouseButton1Click:Connect(pick)
        b.Activated:Connect(pick)
    end

    section2(setPage,"8 MOBILE BUTTON SIZE",10)
    local mobileSizeRows = {
        {"drop","Drop"}, {"insta","Insta Reset"}, {"tp","TP Down"}, {"tpBest","TP Best"},
        {"sentry","Destroy"}, {"steal","Auto Steal"}, {"med","Med"}, {"ps","PS"},
        {"antiTrap","Anti Trap"}, {"websinger","Websinger / Kill"},
    }
    for i,pair in ipairs(mobileSizeRows) do
        local key,labelText=pair[1],pair[2]
        local r=baseRow2(setPage,"Size "..labelText,10+i,34)
        local val=Instance.new("TextBox",r)
        val.Size=UDim2.fromOffset(44,27)
        val.Position=UDim2.new(1,-112,0.5,-14)
        val.BackgroundColor3=LPColors.row2
        val.TextColor3=LPColors.white
        val.Font=Enum.Font.GothamBlack
        val.TextSize=11
        val.TextXAlignment=Enum.TextXAlignment.Center
        val.ClearTextOnFocus=false
        val.TextEditable=true
        val.MultiLine=false
        val.PlaceholderText="70"
        val.Text=tostring((St.btnSizes and St.btnSizes[key]) or 70)
        lCorner(val,7); lStroke(val,LPColors.soft,1,0.42)
        local minus=Instance.new("TextButton",r)
        local plus=Instance.new("TextButton",r)
        for _,b in ipairs({minus,plus}) do
            b.Size=UDim2.fromOffset(27,27)
            b.BackgroundColor3=LPColors.row2
            b.TextColor3=LPColors.white
            b.Font=Enum.Font.GothamBlack
            b.TextSize=14
            b.AutoButtonColor=false
            lCorner(b,7); lStroke(b,LPColors.soft,1,0.42)
        end
        minus.Position=UDim2.new(1,-66,0.5,-14); minus.Text="-"
        plus.Position=UDim2.new(1,-35,0.5,-14); plus.Text="+"
        local function getCurrent()
            St.btnSizes=St.btnSizes or {}
            return math.clamp(math.floor(tonumber(St.btnSizes[key]) or 70),20,200)
        end
        local function refreshValue()
            val.Text=tostring(getCurrent())
        end
        local function change(delta)
            local nextValue=math.clamp(getCurrent()+delta,20,200)
            St.btnSizes[key]=nextValue
            val.Text=tostring(nextValue)
            if _G.RanaVSApplyMobile then pcall(_G.RanaVSApplyMobile) end
            pcall(saveCfg)
        end
        local function commitTypedValue()
            local n=tonumber(val.Text)
            if n then
                n=math.clamp(math.floor(n),20,200)
                St.btnSizes[key]=n
            end
            refreshValue()
            if _G.RanaVSApplyMobile then pcall(_G.RanaVSApplyMobile) end
            pcall(saveCfg)
        end
        val.Focused:Connect(function()
            val.Text=""
        end)
        val.FocusLost:Connect(function()
            commitTypedValue()
        end)
        minus.Activated:Connect(function() change(-5) end)
        plus.Activated:Connect(function() change(5) end)
    end

    section2(setPage,"MENU SIZE",25)
    do
        local r=baseRow2(setPage,"Menu Size",26,36)
        local val=Instance.new("TextLabel",r)
        val.Size=UDim2.fromOffset(48,24)
        val.Position=UDim2.new(1,-105,0.5,-12)
        val.BackgroundTransparency=1
        val.Text=tostring(math.floor((St.menuScale or 0.8)*100)).."%"
        val.TextColor3=LPColors.white; val.Font=Enum.Font.GothamBlack; val.TextSize=11
        local minus=Instance.new("TextButton",r); local plus=Instance.new("TextButton",r)
        for _,b in ipairs({minus,plus}) do
            b.Size=UDim2.fromOffset(27,27); b.BackgroundColor3=LPColors.row2
            b.TextColor3=LPColors.white; b.Font=Enum.Font.GothamBlack; b.TextSize=14; b.AutoButtonColor=false
            lCorner(b,7); lStroke(b,LPColors.soft,1,0.42)
        end
        minus.Position=UDim2.new(1,-66,0.5,-14); minus.Text="-"
        plus.Position=UDim2.new(1,-35,0.5,-14); plus.Text="+"
        local function change(delta)
            St.menuScale=math.clamp((tonumber(St.menuScale) or 0.8)+delta,0.5,1.3)
            menuScale.Scale=St.menuScale
            val.Text=tostring(math.floor(St.menuScale*100)).."%"
            pcall(saveCfg)
        end
        -- Activated works with mouse, touch, and gamepad; connect once per tap.
        minus.Activated:Connect(function() change(-0.05) end)
        plus.Activated:Connect(function() change(0.05) end)
    end
    addButton2(setPage,"Reset Mobile Positions",function()
        if _G.RanaVSResetMobilePos then pcall(_G.RanaVSResetMobilePos) end
        pcall(saveCfg)
    end,28)
    addButton2(setPage,"Save Now",function() pcall(saveCfg) end,29)

    -- ---------------- KEYBINDS ----------------
    local kbPage=pages2.KEYBINDS
    section2(kbPage,"PC KEYBINDS",1)

    -- Shared keybind-row builder; X and Backspace/Delete explicitly persist None.
    local function addKeybindRow2(parent,labelText,keyName,isSpeed,order)
        local row=baseRow2(parent,labelText,order,36)
        local bind=Instance.new("TextButton",row)
        bind.Name="KeybindButton"
        bind.Size=UDim2.fromOffset(62,26)
        bind.Position=UDim2.new(1,-96,0.5,-13)
        bind.BackgroundColor3=LPColors.row2
        bind.TextColor3=LPColors.white
        bind.TextSize=9
        bind.Font=Enum.Font.GothamBlack
        bind.AutoButtonColor=false
        lCorner(bind,7); lStroke(bind,LPColors.soft,1,0.42)

        local clear=Instance.new("TextButton",row)
        clear.Name="ClearKeybind"
        clear.Size=UDim2.fromOffset(20,20)
        clear.Position=UDim2.new(1,-27,0.5,-10)
        clear.BackgroundColor3=Color3.fromRGB(65,28,38)
        clear.Text="x"
        clear.TextColor3=Color3.fromRGB(255,225,230)
        clear.TextSize=11
        clear.Font=Enum.Font.GothamBlack
        clear.AutoButtonColor=false
        lCorner(clear,6); lStroke(clear,LPColors.soft,1,0.45)

        local captureConnection=nil
        local waitingForKey=false
        local function keyTable()
            return isSpeed and St.speedKeys or St.keys
        end
        local function refreshKeyText()
            local key=keyTable() and keyTable()[keyName]
            bind.Text=(typeof(key)=="EnumItem" and key.Name) or "None"
        end
        local function stopCapture()
            waitingForKey=false
            if captureConnection then
                pcall(function() captureConnection:Disconnect() end)
                captureConnection=nil
            end
            _G.RanaVSKeybindingCapture=false
            if _G.RanaVSStopKeybindCapture==stopCapture then
                _G.RanaVSStopKeybindCapture=nil
            end
            refreshKeyText()
        end
        local function listenForKey()
            if _G.RanaVSStopKeybindCapture then
                pcall(_G.RanaVSStopKeybindCapture)
            end
            waitingForKey=true
            _G.RanaVSKeybindingCapture=true
            _G.RanaVSStopKeybindCapture=stopCapture
            bind.Text="..."
            captureConnection=UIS.InputBegan:Connect(function(inp,gp)
                if gp or inp.UserInputType~=Enum.UserInputType.Keyboard then return end
                if inp.KeyCode==Enum.KeyCode.Escape then
                    stopCapture()
                    return
                end
                if inp.KeyCode==Enum.KeyCode.Backspace or inp.KeyCode==Enum.KeyCode.Delete then
                    keyTable()[keyName]="None"
                else
                    keyTable()[keyName]=inp.KeyCode
                end
                stopCapture()
                pcall(saveCfg)
            end)
        end
        bind.Activated:Connect(function()
            if waitingForKey then
                stopCapture()
            else
                listenForKey()
            end
        end)
        clear.Activated:Connect(function()
            if _G.RanaVSStopKeybindCapture then
                pcall(_G.RanaVSStopKeybindCapture)
            end
            keyTable()[keyName]="None"
            refreshKeyText()
            pcall(saveCfg)
        end)
        refreshKeyText()
        return row
    end

    local kbDefs={{"Drop","Drop"},{"TP Down","TPDown"},{"Insta Reset","InstaReset"},{"Destroy","DestroySentry"},{"Auto Steal","AutoSteal"}}
    for i,def in ipairs(kbDefs) do
        addKeybindRow2(kbPage,def[1],def[2],false,i+1)
    end

    section2(kbPage,"SPEED 3-MODE HOTKEYS",8)
    for i,modeName in ipairs({"Normal","Lagger","Custom"}) do
        addKeybindRow2(kbPage,modeName,modeName,true,i+8)
    end

    section2(kbPage,"EXTERNAL BUTTON KEYBINDS",12)
    addKeybindRow2(kbPage,"Anti Trap","AntiTrap",false,13)
    addKeybindRow2(kbPage,"Med Equip","MedEquip",false,14)
    addKeybindRow2(kbPage,"TP Best","TpBest",false,15)
    -- Websinger's PC hotkey is independently configurable/clearable.
    addKeybindRow2(kbPage,"Websinger / Kill","Websinger",false,16)

    -- Close/open behavior matching LaPeak.
    local mini=Instance.new("TextButton",Gui2)
    mini.Name="MiniFrame"
    mini.Size=UDim2.fromOffset(112,34)
    mini.Position=UDim2.new(0,14,0.48,-17)
    mini.BackgroundColor3=Color3.fromRGB(14,14,18)
    mini.BackgroundTransparency=0.08
    mini.Text="12hub"
    mini.TextColor3=LPColors.white
    mini.TextSize=11
    mini.Font=Enum.Font.GothamBlack
    mini.AutoButtonColor=false
    mini.Visible=false
    mini.ZIndex=30
    lCorner(mini,16)
    lStroke(mini,Color3.fromRGB(255,255,255),1.2,0.35)

    local function closeMenu2()
        Main2.Visible=false
        mini.Visible=true
        St.menuOpen=false
        pcall(saveCfg)
    end
    local function openMenu2()
        -- Match file 2: each open places the main menu at exact screen center.
        Main2.AnchorPoint = Vector2.new(0.5, 0.5)
        Main2.Position = UDim2.new(0.5, 0, 0.5, 0)
        St._mainPos = nil
        Main2.Visible=true
        mini.Visible=false
        St.menuOpen=true
        pcall(saveCfg)
    end
    close.MouseButton1Click:Connect(closeMenu2)
    close.Activated:Connect(closeMenu2)
    mini.MouseButton1Click:Connect(openMenu2)
    mini.Activated:Connect(openMenu2)

    -- 12Hub authoritative open/close entry points.
    _G["12HubOpenMainMenu"] = openMenu2
    _G["12HubCloseMainMenu"] = closeMenu2
    _G["12HubToggleMainMenu"] = function()
        if Main2.Visible then
            closeMenu2()
        else
            openMenu2()
        end
    end
    Gui2.Enabled = true
    Main2.Active = true
    mini.Active = true

    -- Keep the menu/mini reliably available after character reset/respawn.
    if _G.__12HubMenuRespawnConn then
        pcall(function() _G.__12HubMenuRespawnConn:Disconnect() end)
        _G.__12HubMenuRespawnConn = nil
    end
    _G.__12HubMenuRespawnConn = LP.CharacterAdded:Connect(function()
        task.delay(0.45, function()
            pcall(function()
                if not Gui2.Parent then
                    Gui2.Parent = PlayerGui
                end
                Gui2.Enabled = true
                if St.menuOpen == false then
                    Main2.Visible = false
                    mini.Visible = true
                else
                    Main2.Visible = true
                    mini.Visible = false
                    St.menuOpen = true
                end
            end)
        end)
    end)

    -- Dragging + lock. Uses LaPeak lock semantics.
    do
        local dragging=false
        local dragStart,startPos
        Main2.InputBegan:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
                dragging=true
                dragStart=inp.Position
                startPos=Main2.Position
            end
        end)
        UIS.InputChanged:Connect(function(inp)
            if not dragging then return end
            if inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch then
                local d=inp.Position-dragStart
                Main2.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
            end
        end)
        UIS.InputEnded:Connect(function(inp)
            if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
                if dragging then
                    dragging=false
                    St._mainPos={Main2.Position.X.Scale,Main2.Position.X.Offset,Main2.Position.Y.Scale,Main2.Position.Y.Offset}
                    pcall(saveCfg)
                end
            end
        end)
    end

    -- LaPeak idle fade: PC only, full menu returns on interaction.
    do
        local IDLE=5
        local fadeState=false
        local activityToken=0
        local baseAlpha=setmetatable({}, {__mode="k"})
        local watched={Content2,Tabs2,Header,close}
        local function remember(o)
            if not o or baseAlpha[o] then return end
            local d={}
            pcall(function()
                if o:IsA("GuiObject") then d.bg=o.BackgroundTransparency end
                if o:IsA("TextLabel") or o:IsA("TextButton") or o:IsA("TextBox") then d.text=o.TextTransparency end
                if o:IsA("UIStroke") then d.stroke=o.Transparency end
            end)
            baseAlpha[o]=d
        end
        local function setFade(on)
            fadeState=on
            for _,root in ipairs(watched) do
                remember(root)
                for _,d in ipairs(root:GetDescendants()) do remember(d) end
            end
            for o,d in pairs(baseAlpha) do
                if o and o.Parent and d then
                    local p={}
                    if d.bg~=nil then p.BackgroundTransparency=on and math.max(d.bg,0.78) or d.bg end
                    if d.text~=nil then p.TextTransparency=on and math.max(d.text,0.60) or d.text end
                    if d.stroke~=nil then p.Transparency=on and math.max(d.stroke,0.74) or d.stroke end
                    if next(p) then lTween(o,p,0.40) end
                end
            end
        end
        local function touch()
            activityToken += 1
            local token=activityToken
            if fadeState then setFade(false) end
            task.delay(IDLE,function()
                if token==activityToken and Main2.Visible and not St.guiLock then
                    setFade(true)
                end
            end)
        end
        for _,root in ipairs({Main2}) do
            root.InputBegan:Connect(touch)
            root.InputChanged:Connect(touch)
        end
        UIS.InputBegan:Connect(function(inp)
            if Main2.Visible and (inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch or inp.UserInputType==Enum.UserInputType.Keyboard) then
                touch()
            end
        end)
        touch()
    end

    -- Remove legacy menu images but keep the requested 12Hub wallpaper.
    for _,d in ipairs(Main2:GetDescendants()) do
        if (d:IsA("ImageLabel") or d:IsA("ImageButton"))
            and d.Name ~= "MainMenuBackground" then
            pcall(function() d:Destroy() end)
        end
    end

    selectedStealMode=(tostring(selectedStealMode or "Normal")=="Semi") and "Semi" or "Normal"
    autoStealV2Version=(tostring(autoStealV2Version or "V2")=="V1") and "V1" or "V2"
    St.stealVer=selectedStealMode.."-"..autoStealV2Version
    -- RARA-style startup placement: always center the main menu on each execution.
    Main2.AnchorPoint = Vector2.new(0.5, 0.5)
    Main2.Position = UDim2.new(0.5, 0, 0.5, 0)
    St._mainPos = nil
    Gui2.Enabled = true
    if St.menuOpen == false then
        Main2.Visible=false
        mini.Visible=true
    else
        Main2.Visible=true
        mini.Visible=false
        St.menuOpen=true
    end
    setTab2("SPEED")
    pcall(function()
        if _G.RanaVSApplyLaPeakShape then _G.RanaVSApplyLaPeakShape(St.btnShape or "FOUNDED") end
    end)
    pcall(function()
        if _G.RanaVSBuildV2ModeBar then _G.RanaVSBuildV2ModeBar() end
    end)
    pcall(function() if _G.StealBar then _G.StealBar.Show(St.stealBarVisible ~= false) end end)

    _G.RanaVSLaPeakHybridMain = Main2
    _G.RanaVSLaPeakHybridGui = Gui2
    _G.RanaVSLaPeakHybridPages = pages2
end
-- ============================================================================
-- ============================================================================
-- 12HUB FINAL AUTO STEAL STATE REPAIR
-- Uses only the four embedded LaPeak/Ambitious engines.
-- ============================================================================
do
    local pages = _G.RanaVSLaPeakHybridPages or {}
    local playerPage = pages.PLAYER

    local persisted = tostring(St.stealVer or "Normal-V2")
    local mode, version = persisted:match("^(Normal|Semi)%-(V[12])$")
    mode = mode or "Normal"
    version = version or "V2"

    selectedStealMode = mode
    autoStealV2Version = version
    if mode == "Normal" then
        selectedNormalMode = version
    else
        selectedSemiMode = version
    end
    St.stealVer = mode .. "-" .. version
    autoStealEnabled = St.autoSteal == true
    _G.autoStealEnabled = autoStealEnabled

    _G.RanaVSSelectAutoSteal = function(newMode, newVersion)
        _12HubNormalizeStealSelection(newMode, newVersion)
        _12HubSyncAutoSteal()
        pcall(function() if _G.RanaVSRefreshAutoStealSelector then _G.RanaVSRefreshAutoStealSelector() end end)
        pcall(saveCfg)
    end

    setAutoSteal = function(on)
        St.autoSteal = on and true or false
        autoStealEnabled = St.autoSteal
        _G.autoStealEnabled = autoStealEnabled
        _12HubSyncAutoSteal()
        pcall(function()
            if ToggleRefs and ToggleRefs.autoSteal and ToggleRefs.autoSteal.setVisual then
                ToggleRefs.autoSteal.setVisual(St.autoSteal)
            end
        end)
        pcall(function() if _G.RanaVSRefreshStealBtn then _G.RanaVSRefreshStealBtn() end end)
        pcall(saveCfg)
    end
    _G.setAutoSteal = setAutoSteal
    _G.RanaVSSyncAutoSteal = _12HubSyncAutoSteal

    if playerPage then
        pcall(function()
            if _G.RanaVSRefreshAutoStealSelector then
                _G.RanaVSRefreshAutoStealSelector()
            end
        end)
    end

    pcall(function() _12HubSyncAutoSteal() end)
end
-- FINAL LAPEAK MOBILE STATE NORMALIZER
-- ============================================================
do
    local function normalizeMobileActionVisuals()
        local refs = actRefs or {}
        for key,e in pairs(refs) do
            if e and e.btn then
                local on = false
                if key == "steal" then on = St.autoSteal == true
                elseif key == "sentry" then on = St.destroySentry == true
                elseif key == "ps" then on = isEquippedExact("Paintball Gun")
                elseif key == "med" then on = false
                elseif key == "antiTrap" then on = St.antiTrap == true end
                if key == "steal" then
                    applyActBtnState(e.btn,on,"STEAL ON","AUTO STEAL")
                elseif key == "sentry" then
                    applyActBtnState(e.btn,on,"DESTROY ON","DESTROY")
                elseif key == "ps" then
                    applyActBtnState(e.btn,on,"PS","PS")
                elseif key == "med" then
                    applyActBtnState(e.btn,false,"MED\nEQUIP","MED\nEQUIP")
                elseif key == "antiTrap" then
                    applyActBtnState(e.btn,on,"ANTI\nTRAP ON","ANTI\nTRAP")
                elseif key == "websinger" then
                    on = isWebSlingerEquipped()
                    applyActBtnState(e.btn,on,"KILL","WEBSINGER")
                end
            end
        end
    end
    _G.RanaVSRefreshMobileButtonStates = normalizeMobileActionVisuals
    pcall(normalizeMobileActionVisuals)
    task.spawn(function()
        while task.wait(0.5) do
            if _G.RanaVSRefreshWebsingerBtn then
                pcall(_G.RanaVSRefreshWebsingerBtn)
            end
        end
    end)
end
