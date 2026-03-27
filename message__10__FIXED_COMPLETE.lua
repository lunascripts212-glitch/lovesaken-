if not WYNF_OBFUSCATED then
    WYNF_NO_VIRTUALIZE = function(fn) return fn end
    WYNF_JIT           = function(fn) return fn end
    WYNF_JIT_MAX       = function(fn) return fn end
end
pcall(function()
local v1=game:GetService("ReplicatedStorage"):FindFirstChild("InGameExplorer_Shared")
if not v1 then return end
pcall(function() local a,b=pcall(require,v1:FindFirstChild("LogShared")) if a and b then for k in pairs(b) do pcall(function()b[k]=function()end end) end end end)
pcall(function() local a,b=pcall(require,v1:FindFirstChild("InGameExplorerShared")) if a and b then for k in pairs(b) do pcall(function()b[k]=function()end end) end end end)
pcall(function() local a,b=pcall(require,v1:FindFirstChild("Replicator")) if a and b then for k in pairs(b) do pcall(function()b[k]=function()end end) end end end)
pcall(function() local v9=v1:FindFirstChild("InGameExplorer_RemoteFunction") if v9 then v9.OnClientInvoke=function()end end end)
pcall(function() local v10=v1:FindFirstChild("InGameExplorer_RemoteEvent") if v10 then v10.OnClientEvent:Connect(function()end) end end)
end)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local isfolder = isfolder or function() return false end
local makefolder = makefolder or function() end
local writefile = writefile or function() end
local isfile = isfile or function() return false end
local readfile = readfile or function() return "" end
local getcustomasset = getcustomasset or function(p) return p end
local delfile = delfile or function() end
local cfgData = {}
local cfgFile = "hub/cfg.json"
if not isfolder("hub") then makefolder("hub") end
if isfile(cfgFile) then
    local ok, d = pcall(function() return HttpService:JSONDecode(readfile(cfgFile)) end)
    if ok and d then cfgData = d end
end
local function set(k, v)
    if v == "true" then v = true elseif v == "false" then v = false end
    local n = tonumber(v); if n ~= nil and type(v) ~= "boolean" then v = n end
    cfgData[k] = v
    writefile(cfgFile, HttpService:JSONEncode(cfgData))
end
local function get(k, def)
    return cfgData[k] ~= nil and cfgData[k] or def
end
local testRemote = nil
pcall(function()
 testRemote = ReplicatedStorage
 :WaitForChild("Modules", 10)
 :WaitForChild("Network", 10)
 :WaitForChild("RemoteEvent", 10)
end)
local bufs = {
 Block = buffer.fromstring("\3\5\0\0\0Block"),
 Punch = buffer.fromstring("\3\5\0\0\0Punch"),
 Charge = buffer.fromstring("\3\5\0\0\0Charge"),
 Clone = buffer.fromstring("\3\5\0\0\0Clone"),
}
local _rem = nil
local function fire(t)
    if not _rem or not _rem.Parent then
        local net = ReplicatedStorage:FindFirstChild("Modules") and ReplicatedStorage.Modules:FindFirstChild("Network")
        if net then
            for _, c in ipairs(net:GetChildren()) do
                if c:IsA("RemoteEvent") then _rem = c; break end
            end
        end
        if not _rem then _rem = testRemote end
    end
    if not _rem then return end
    local b = bufs[t] or bufs.Block
    _rem:FireServer("UseActorAbility", {[1] = b})
    _rem:FireServer(t)
end
local WindUI = nil
pcall(function()
 WindUI = loadstring(game:HttpGet(
 "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"
 ))()
end)
if not WindUI then
 pcall(function()
 game:GetService("StarterGui"):SetCore("SendNotification",
 { Title = "Error", Text = "Failed to load WindUI", Duration = 5 })
 end)
 return
end
WindUI:SetTheme(get("uiTheme", "Dark"))
local Window = WindUI:CreateWindow({
    Title = "hub", Icon = "box",
    Author = "hub", Folder = "hub",
    Size = UDim2.fromOffset(650, 560),
    Transparent = true, Resizable = true, Theme = get("uiTheme","Dark"),
    SideBarWidth = 200, HideSearchBar = false,
})
Window:EditOpenButton({
    Title = "hub", Icon = "box",
    CornerRadius = UDim.new(0, 20), StrokeThickness = 2,
    Color = ColorSequence.new(Color3.fromHex("#A78BFA"), Color3.fromHex("#EC4899")),
    Enabled = true, Draggable = true,
})
local UIS = game:GetService("UserInputService")
local guiOpen = true
UIS.InputBegan:Connect(function(input)
    if input.KeyCode ~= Enum.KeyCode.K then return end
    if UIS:GetFocusedTextBox() then return end
    local ok = pcall(function() Window:Toggle() end)
    if ok then return end
    guiOpen = not guiOpen
    for _, gui in ipairs(game:GetService("CoreGui"):GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Name:lower():find("hub") or gui.Name:lower():find("wind") then
            gui.Enabled = guiOpen; return
        end
    end
end)
local S = {
 autoBlockAudioOn   = (function(v) if type(v)=="boolean" then return v end if v=="true" then return true end if v=="false" then return false end return true end)(get("autoBlockAudioOn", true)),
 detectionRange     = tonumber(get("detectionRange",     18))   or 18,
 blockdelay         = tonumber(get("blockdelay",         0))    or 0,
 facingCheckEnabled = (function(v) if type(v)=="boolean" then return v end if v=="true" then return true end if v=="false" then return false end return true end)(get("facingCheckEnabled", true)),
 doubleblocktech    = (function(v) if type(v)=="boolean" then return v end if v=="true" then return true end if v=="false" then return false end return true end)(get("doubleblocktech", true)),
 autoblocktype      = get("autoblocktype",        "Block"),
 abMissChance       = tonumber(get("abMissChance",       0))    or 0,
 antiBaitEnabled    = (function(v) if type(v)=="boolean" then return v end if v=="true" then return true end if v=="false" then return false end return false end)(get("antiBaitEnabled", false)),
 hitboxDraggingTech = (function(v) if type(v)=="boolean" then return v end if v=="true" then return true end if v=="false" then return false end return true end)(get("hitboxDraggingTech", true)),
 Dspeed             = tonumber(get("Dspeed",             12))   or 12,
 Ddelay             = tonumber(get("Ddelay",             0))    or 0,
 rotateDelay        = tonumber(get("rotateDelay",        0))    or 0,
 hdtMissChance      = tonumber(get("hdtMissChance",      0))    or 0,
 hdtMode            = get("hdtMode",              "180_TURN"),
 rctEnabled         = (function(v) if type(v)=="boolean" then return v end if v=="true" then return true end if v=="false" then return false end return false end)(get("rctEnabled", false)),
 rctFlickDelay      = tonumber(get("rctFlickDelay",      0.08)) or 0.08,
 rctFlickAngle      = tonumber(get("rctFlickAngle",      120))  or 120,
 rctFlickSpeed      = tonumber(get("rctFlickSpeed",      0.06)) or 0.06,
 rctFlickDir        = get("rctFlickDir",          "Right"),
 rctAutoLedge       = (function(v) if type(v)=="boolean" then return v end if v=="true" then return true end if v=="false" then return false end return false end)(get("rctAutoLedge", false)),
 rctMissChance      = tonumber(get("rctMissChance",      0))    or 0,
 characterLockOn    = (function(v) if type(v)=="boolean" then return v end if v=="true" then return true end if v=="false" then return false end return true end)(get("characterLockOn", true)),
 lockMaxDistance    = tonumber(get("lockMaxDistance",    30))   or 30,
 predictionValue    = tonumber(get("predictionValue",    4))    or 4,
 aimPunchEnabled    = (function(v) if type(v)=="boolean" then return v end if v=="true" then return true end if v=="false" then return false end return true end)(get("aimPunchEnabled", true)),
 aimWindow          = tonumber(get("aimWindow",          0.7))  or 0.7,
 autoPunchOn        = (function(v) if type(v)=="boolean" then return v end if v=="true" then return true end if v=="false" then return false end return true end)(get("autoPunchOn", true)),
 killerCirclesVisible = (function(v) if type(v)=="boolean" then return v end if v=="true" then return true end if v=="false" then return false end return false end)(get("killerCirclesVisible", false)),
 facingVisualOn       = (function(v) if type(v)=="boolean" then return v end if v=="true" then return true end if v=="false" then return false end return false end)(get("facingVisualOn", false)),
 staminaCustomEnabled = (function(v) if type(v)=="boolean" then return v end if v=="true" then return true end if v=="false" then return false end return false end)(get("staminaCustomEnabled", false)),
 staminaLossValue     = tonumber(get("staminaLossValue",     10))  or 10,
 staminaGainValue     = tonumber(get("staminaGainValue",     20))  or 20,
 staminaMaxValue      = tonumber(get("staminaMaxValue",      100)) or 100,
 staminaCurrentValue  = tonumber(get("staminaCurrentValue",  100)) or 100,
 staminaLossDisabled  = (function(v) if type(v)=="boolean" then return v end if v=="true" then return true end if v=="false" then return false end return false end)(get("staminaLossDisabled", false)),
 genFlowSolverEnabled = (function(v) if type(v)=="boolean" then return v end if v=="true" then return true end if v=="false" then return false end return false end)(get("genFlowSolverEnabled", false)),
 genFlowNodeDelay     = tonumber(get("genFlowNodeDelay",     0.04)) or 0.04,
 genFlowLineDelay     = tonumber(get("genFlowLineDelay",     0.60)) or 0.60,
 lmsAutoPlay      = (function(v) if type(v)=="boolean" then return v end if v=="true" then return true end if v=="false" then return false end return false end)(get("lmsAutoPlayEnabled", false)),
 lmsSelectedSong  = get("selectedLMSSong",    "Eternal Hope"),
}
local STRICT_FACING_DOT = 0.70
local BAIT_KILLERS = { "John Doe","Slasher","c00lkidd","Jason","1x1x1x1","Noli","Sixer","Nosferatu" }
local KILLER_NAMES = { "c00lkidd","Jason","JohnDoe","1x1x1x1","Noli","Slasher","Sixer" }
local PUNCH_ANIM_SET, BLOCK_ANIM_SET = {}, {}
do
 local punchIds = {
 "87259391926321","140703210927645","136007065400978","129843313690921",
 "86709774283672","108807732150251","138040001965654","86096387000557",
 }
 local blockIds = {
 "72722244508749","96959123077498","95802026624883","100926346851492","120748030255574"
 }
 for _, v in ipairs(punchIds) do PUNCH_ANIM_SET[v] = true end
 for _, v in ipairs(blockIds) do BLOCK_ANIM_SET[v] = true end
end
local TRIGGER_SOUNDS = {
 ["102228729296384"]=true,["140242176732868"]=true,["112809109188560"]=true,
 ["136323728355613"]=true,["115026634746636"]=true,["84116622032112"]=true,
 ["108907358619313"]=true,["127793641088496"]=true,["86174610237192"]=true,
 ["95079963655241"]=true,["101199185291628"]=true,["119942598489800"]=true,
 ["84307400688050"]=true,["113037804008732"]=true,["105200830849301"]=true,
 ["75330693422988"]=true,["82221759983649"]=true,["81702359653578"]=true,
 ["108610718831698"]=true,["112395455254818"]=true,["109431876587852"]=true,
 ["109348678063422"]=true,["85853080745515"]=true,["12222216"]=true,
 ["105840448036441"]=true,["114742322778642"]=true,["119583605486352"]=true,
 ["79980897195554"]=true,["71805956520207"]=true,["79391273191671"]=true,
 ["89004992452376"]=true,["101553872555606"]=true,["101698569375359"]=true,
 ["106300477136129"]=true,["116581754553533"]=true,["117231507259853"]=true,
 ["119089145505438"]=true,["121954639447247"]=true,["125213046326879"]=true,
 ["131406927389838"]=true,["117173212095661"]=true,["71834552297085"]=true,
 ["805165833096"]=true,["80516583309685"]=true,["76959687420003"]=true,
 ["107444859834748"]=true,["86833981571073"]=true,["110372418055226"]=true,
 ["86494585504534"]=true,["121369993837377"]=true,["132331977491979"]=true,
 ["18782451032"]=true,["80587845277702"]=true,["94317217837143"]=true,
 ["136728245733659"]=true,["104910828105172"]=true,["98111231282218"]=true,
 ["71310583817000"]=true,["124903763333174"]=true,["72425554233832"]=true,
 ["131123355704017"]=true,["128856426573270"]=true,["128195973631079"]=true,
 ["128367348686124"]=true,["105204810054381"]=true,["98675142200448"]=true,
}
local function getKillersFolder()
 local p = Workspace:FindFirstChild("Players")
 return p and p:FindFirstChild("Killers")
end
local function getSurvivorsFolder()
 local p = Workspace:FindFirstChild("Players")
 return p and p:FindFirstChild("Survivors")
end
local function getIngameFolder()
 local m = Workspace:FindFirstChild("Map")
 return m and m:FindFirstChild("Ingame")
end
local function getCurrentMapFolder()
 local ig = getIngameFolder()
 return ig and ig:FindFirstChild("Map")
end
local isStrictlyFacing = WYNF_JIT_MAX(function(myRoot, targetRoot, killerName)
    if not S.facingCheckEnabled then return true end
    if not myRoot or not targetRoot then return false end
    local diff = myRoot.Position - targetRoot.Position
    if diff.Magnitude < 0.01 then return true end
    local dir = diff.Unit
    local dot = targetRoot.CFrame.LookVector:Dot(dir)
    local bait = false
    if killerName then
        for _, n in ipairs(BAIT_KILLERS) do
            if killerName:find(n) then bait = true; break end
        end
    end
    if bait then
        local vel = Vector3.zero
        pcall(function()
            vel = targetRoot.AssemblyLinearVelocity
        end)
        if vel.Magnitude < 0.01 then
            pcall(function() vel = targetRoot.Velocity end)
        end
        local side = math.abs(vel:Dot(targetRoot.CFrame.RightVector))
        if side > 3 then return false end
        return dot > STRICT_FACING_DOT + 0.05
    end
    return dot > STRICT_FACING_DOT
end)
local function nearestKiller()
 local myChar = LocalPlayer.Character; if not myChar then return nil end
 local myRoot = myChar:FindFirstChild("HumanoidRootPart"); if not myRoot then return nil end
 local kf = getKillersFolder(); if not kf then return nil end
 local best, bestD = nil, math.huge
 for _, k in pairs(kf:GetChildren()) do
 local hrp = k:FindFirstChild("HumanoidRootPart")
 if hrp then
 local d = (hrp.Position - myRoot.Position).Magnitude
 if d < bestD then best, bestD = k, d end
 end
 end
 return best
end
local rollMiss = WYNF_JIT_MAX(function(chance)
 if chance <= 0 then return false end
 if chance >= 100 then return true end
 return math.random(1, 100) <= chance
end)
local anim = nil
local function reloadAnim()
 local c = LocalPlayer.Character; if not c then anim = nil; return end
 local h = c:FindFirstChildOfClass("Humanoid")
 anim = h and h:FindFirstChildOfClass("Animator") or nil
end
if LocalPlayer.Character then reloadAnim() end
LocalPlayer.CharacterAdded:Connect(function() task.wait(0.5); reloadAnim() end)
local hdt = {}
do
 local _debounce = false
 local _lastTime = 0
 local HDT_CD = 0.5
 local _conn = nil
 local function doPattern(hrp)
 local mode = S.hdtMode
 if mode == "180_TURN" then
 hrp.CFrame = CFrame.lookAt(hrp.Position, hrp.Position - hrp.CFrame.LookVector)
 elseif mode == "LEFT_SPIN" then
 for _ = 1, 5 do hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(36), 0); task.wait(0.02) end
 elseif mode == "RIGHT_SPIN" then
 for _ = 1, 5 do hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(-36), 0); task.wait(0.02) end
 end
 end
 local function startChargeAim(fallback)
 fallback = fallback or 1.2
 local sw = tick()
 local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
 local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
 if hum then hum.AutoRotate = false end
 while tick() - sw < fallback do
 pcall(function()
 local nk = nearestKiller()
 if nk and root then
 local tHRP = nk:FindFirstChild("HumanoidRootPart")
 if tHRP then
 if S.rotateDelay > 0 then task.wait(S.rotateDelay) end
 root.CFrame = CFrame.lookAt(root.Position, tHRP.Position)
 end
 end
 end)
 task.wait()
 end
 if hum then hum.AutoRotate = true end
 end
 local function beginDrag(killerModel)
 if _debounce then return end
 if not killerModel or not killerModel.Parent then return end
 local char = LocalPlayer.Character; if not char then return end
 local hrp = char:FindFirstChild("HumanoidRootPart")
 local hum = char:FindFirstChildOfClass("Humanoid")
 if not hrp or not hum then return end
 local tHRP = killerModel:FindFirstChild("HumanoidRootPart"); if not tHRP then return end
 _debounce = true
 local oldW = hum.WalkSpeed; hum.WalkSpeed = 0
 pcall(doPattern, hrp)
 local bv = Instance.new("BodyVelocity")
 bv.MaxForce = Vector3.new(1e5, 0, 1e5); bv.Velocity = Vector3.zero; bv.Parent = hrp
 local conn
 conn = RunService.Heartbeat:Connect(function()
 if not _debounce then
 conn:Disconnect(); if bv and bv.Parent then bv:Destroy() end
 hum.WalkSpeed = oldW; return
 end
 if not (char and char.Parent) or not (killerModel and killerModel.Parent) then
 _debounce = false; return
 end
 local curTHRP = killerModel:FindFirstChild("HumanoidRootPart")
 if not curTHRP then _debounce = false; return end
 local to = curTHRP.Position - hrp.Position
 local h2 = Vector3.new(to.X, 0, to.Z)
 bv.Velocity = h2.Magnitude > 0.01 and h2.Unit * S.Dspeed or Vector3.zero
 if to.Magnitude <= 2.0 then _debounce = false end
 end)
 task.delay(0.4, function() _debounce = false end)
 end
 local function onBlockAnimPlayed(track)
 pcall(function()
 if not S.hitboxDraggingTech or _debounce then return end
 local now = tick(); if now - _lastTime < HDT_CD then return end
 local id = tostring(track.Animation and track.Animation.AnimationId or ""):match("%d+")
 if not id or not BLOCK_ANIM_SET[id] then return end
 if rollMiss(S.hdtMissChance) then return end
 _lastTime = now
 local nearest = nearestKiller(); if not nearest then return end
 task.spawn(function()
 if S.Ddelay > 0 then task.wait(S.Ddelay) end
 beginDrag(nearest)
 startChargeAim(0.4)
 end)
 end)
 end
 function hdt.setup(anim)
 if _conn then _conn:Disconnect() end
 if not anim then return end
 _conn = anim.AnimationPlayed:Connect(onBlockAnimPlayed)
 end
end
if anim then hdt.setup(anim) end
LocalPlayer.CharacterAdded:Connect(function(char)
 task.wait(0.6)
 local hum = char:WaitForChild("Humanoid", 5)
 if hum then
 local anim = hum:WaitForChild("Animator", 5)
 if anim then anim = anim; hdt.setup(anim) end
 end
end)
local rct = {}
do
 local _debounce = false
 local _lastCharge = 0
 local CHARGE_CD = 10
 local RCT_SCAN_DIRS = {
 Vector3.new( 1, 0, 0), Vector3.new(-1, 0, 0),
 Vector3.new( 0, 0, 1), Vector3.new( 0, 0, -1),
 Vector3.new( 1, 0, 1).Unit, Vector3.new(-1, 0, 1).Unit,
 Vector3.new( 1, 0, -1).Unit, Vector3.new(-1, 0, -1).Unit,
 }
 local function findLedgeAngle(killerHRP)
 local bestDir, bestDrop = nil, 4
 local origin = killerHRP.Position + Vector3.new(0, 0.5, 0)
 local rp = RaycastParams.new()
 rp.FilterType = Enum.RaycastFilterType.Exclude
 pcall(function() rp.FilterDescendantsInstances = {killerHRP.Parent} end)
 for _, dir in ipairs(RCT_SCAN_DIRS) do
 local result = Workspace:Raycast(origin + dir * 3, Vector3.new(0, -10, 0), rp)
 local floorY = result and result.Position.Y or (origin.Y - 10)
 local drop = origin.Y - floorY
 if drop > bestDrop then bestDrop = drop; bestDir = dir end
 end
 if not bestDir then return nil end
 return math.atan2(-bestDir.X, -bestDir.Z)
 end
 local function doFlick()
 if _debounce then return end
 if rollMiss(S.rctMissChance) then return end
 _debounce = true
 task.spawn(function()
 pcall(function()
 task.wait(S.rctFlickDelay)
 local char = LocalPlayer.Character; if not char then _debounce = false; return end
 local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then _debounce = false; return end
 local hum = char:FindFirstChildOfClass("Humanoid")
 local base = math.atan2(-hrp.CFrame.LookVector.X, -hrp.CFrame.LookVector.Z)
 local target
 if S.rctAutoLedge then
 local km = nearestKiller()
 local khrp = km and km:FindFirstChild("HumanoidRootPart")
 target = khrp and findLedgeAngle(khrp) or base
 else
 local rad = math.rad(S.rctFlickAngle)
 if S.rctFlickDir == "Right" then target = base - rad
 elseif S.rctFlickDir == "Left" then target = base + rad
 elseif S.rctFlickDir == "Back" then target = base + math.pi
 else target = base - rad end
 end
 local elapsed, dt = 0, 0.016
 if hum then hum.AutoRotate = false end
 while elapsed < S.rctFlickSpeed do
 pcall(function()
 local t = math.min(elapsed / S.rctFlickSpeed, 1)
 hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, base + (target - base) * t, 0)
 end)
 elapsed = elapsed + dt; task.wait(dt)
 end
 pcall(function() hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, target, 0) end)
 if hum then hum.AutoRotate = true end
 end)
 _debounce = false
 end)
 end
 function rct.fire()
 local now = tick()
 if now - _lastCharge < CHARGE_CD then
 WindUI:Notify({Title="RCT",Content="Cooldown: "..math.ceil(CHARGE_CD-(now-_lastCharge)).."s",Icon="alert",Duration=2})
 return
 end
 _lastCharge = now
 fire("Charge")
 doFlick()
 end
end
local sndBlock = {}
do
 local trackedSounds = {}
 local blockedUntil  = {}
 local lastBlockTime = 0
 local BLOCK_CD      = 0.1
 local function extractId(sound)
  return tostring(sound.SoundId):match("%d+")
 end
 local function getSoundPart(sound)
  if not sound.Parent then return nil end
  if sound.Parent:IsA("BasePart") then return sound.Parent end
  if sound.Parent:IsA("Attachment") and sound.Parent.Parent
     and sound.Parent.Parent:IsA("BasePart") then
   return sound.Parent.Parent
  end
  return nil
 end
 local function getCharFromPart(part)
  local m = part:FindFirstAncestorOfClass("Model")
  return m and m:FindFirstChildOfClass("Humanoid") and m or nil
 end
 local function tryBlock(sound)
  local now = tick()
  if blockedUntil[sound] and now < blockedUntil[sound] then return end
  if now - lastBlockTime < BLOCK_CD then return end
  local id = extractId(sound)
  if not id or not TRIGGER_SOUNDS[id] then return end
  local myChar = LocalPlayer.Character; if not myChar then return end
  local myRoot = myChar:FindFirstChild("HumanoidRootPart"); if not myRoot then return end
  local kf = Workspace:FindFirstChild("Players") and Workspace.Players:FindFirstChild("Killers")
  local killerModel = nil
  if kf then
   local closest, closestDist = nil, S.detectionRange
   for _, v in ipairs(kf:GetChildren()) do
    local hrp2 = v:FindFirstChild("HumanoidRootPart")
    if hrp2 then
     local dist = (hrp2.Position - myRoot.Position).Magnitude
     if dist <= closestDist then
      closestDist = dist
      closest = v
     end
    end
   end
   killerModel = closest
  end
  if not killerModel then
   local part = getSoundPart(sound); if not part then return end
   local char = getCharFromPart(part); if not char then return end
   local plr = Players:GetPlayerFromCharacter(char)
   if not plr or plr == LocalPlayer then return end
   killerModel = char
  end
  local hrp = killerModel:FindFirstChild("HumanoidRootPart"); if not hrp then return end
  if (hrp.Position - myRoot.Position).Magnitude > S.detectionRange then return end
  if not isStrictlyFacing(myRoot, hrp, killerModel.Name) then return end

  if S.antiBaitEnabled then
   local vel = Vector3.zero
   pcall(function() vel = hrp.AssemblyLinearVelocity end)
   if vel.Magnitude < 0.1 then pcall(function() vel = hrp.Velocity end) end
   local dist = (hrp.Position - myRoot.Position).Magnitude
   local toUs = (myRoot.Position - hrp.Position)
   -- killer clearly running away from us, not attacking
   if toUs.Magnitude > 0.1 then
    local movingAway = vel:Dot(toUs.Unit) < -3
    if movingAway then return end
   end
   -- beyond realistic hit range for any killer in forsaken
   -- c00lkidd/jason have larger hitboxes, ping adds ~1-2 studs on top
   -- 13 studs covers everything including lag compensation
   if dist > 13 then return end
   -- strafing sideways with no forward movement = classic bait
   -- but dont block this if killer is close enough to hit regardless
   if dist > 6 then
    local sideSpeed = math.abs(vel:Dot(hrp.CFrame.RightVector))
    local towardUs = vel:Dot(toUs.Unit)
    -- moving sideways fast and NOT moving toward us = bait
    if sideSpeed > 6 and towardUs < 0 then return end
   end
  end

  if rollMiss(S.abMissChance) then return end
  lastBlockTime = now
  blockedUntil[sound] = now + 0.3
  local function doFire()
   if S.autoblocktype == "Block" then
    fire("Block")
    if S.doubleblocktech then fire("Punch") end
   elseif S.autoblocktype == "Charge" then
    fire("Charge")
   elseif S.autoblocktype == "7n7 Clone" then
    fire("Clone")
   end
  end
  if S.blockdelay > 0 then
   task.delay(S.blockdelay, doFire)
  else
   doFire()
  end
 end
 function sndBlock.tick()
  if not S.autoBlockAudioOn then return end
  for sound in pairs(trackedSounds) do
   if not sound or not sound.Parent then
    trackedSounds[sound] = nil
    blockedUntil[sound] = nil
   elseif sound.IsPlaying then
    tryBlock(sound)
   end
  end
 end
 local function registerSound(sound)
  if not sound or not sound:IsA("Sound") then return end
  if trackedSounds[sound] then return end
  local id = extractId(sound)
  if not id or not TRIGGER_SOUNDS[id] then return end
  trackedSounds[sound] = true
  sound.Destroying:Connect(function()
   trackedSounds[sound] = nil
   blockedUntil[sound] = nil
  end)
 end
 function sndBlock.setup()
  local kf = getKillersFolder(); if not kf then return end
  for _, d in pairs(kf:GetDescendants()) do
   if d:IsA("Sound") then registerSound(d) end
  end
  kf.DescendantAdded:Connect(function(d)
   if d:IsA("Sound") then registerSound(d) end
  end)
 end
end
local ESP = {}
do
 ESP.Colors = {
 Killer = Color3.fromRGB(255, 140, 170),
 Survivor = Color3.fromRGB(140, 255, 200),
 Generator = Color3.fromRGB(255, 230, 140),
 Item = Color3.fromRGB(255, 200, 140),
 Sentry = Color3.fromRGB(200, 200, 200),
 Dispenser = Color3.fromRGB(140, 200, 255),
 FakeGen = Color3.fromRGB(100, 100, 100),
 MinionC00l = Color3.fromRGB(255, 80, 80),
 Minion1x1 = Color3.fromRGB( 80, 255, 80),
 }
 ESP.Settings = {
 Style = get("espStyle", "Glow"),
 ShowDistance = get("espShowDistance", true),
 ShowHealth = get("espShowHealth", true),
 Transparency = get("espTransparency", 0.35),
 TextSize = get("espTextSize", 14),
 }
 ESP.Enabled = {
 Killers = get("espKillersEnabled", false),
 Survivors = get("espSurvivorsEnabled", false),
 Generators = get("espGeneratorsEnabled", false),
 Items = get("espItemsEnabled", false),
 Sentries = get("espSentryEnabled", false),
 Dispensers = get("espDispenserEnabled", false),
 FakeGens = get("espFakeGenEnabled", false),
 MinionC00l = get("espMinionC00lEnabled", false),
 Minion1x1 = get("espMinion1x1Enabled", false),
 }
 local Conns = { health={}, progress={}, players={}, map={} }
 local Initialized = false
 local function hlColors(color)
 local ft = ESP.Settings.Transparency
 if ESP.Settings.Style == "Glow" then
 color = Color3.new(math.min(color.R*1.2,1), math.min(color.G*1.2,1), math.min(color.B*1.2,1))
 ft = ft * 0.8
 elseif ESP.Settings.Style == "Outline" or ESP.Settings.Style == "Minimal" then
 ft = 1
 end
 return color, color, ft
 end
 local function espAdd(obj, tag, color, isPlayer)
 pcall(function()
 if not obj or not obj.Parent or obj:FindFirstChild(tag) then return end
 local root = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Part")
 or obj:FindFirstChild("Handle") or obj.PrimaryPart
 if not root then
 for _, d in ipairs(obj:GetDescendants()) do if d:IsA("BasePart") then root = d; break end end
 end
 if not root then return end
 local fc, oc, ft = hlColors(color)
 if ESP.Settings.Style ~= "Minimal" then
 local hl = Instance.new("Highlight")
 hl.Name = tag; hl.FillColor = fc; hl.FillTransparency = ft
 hl.OutlineColor = oc; hl.OutlineTransparency = 0.1
 hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
 hl.Adornee = obj; hl.Parent = obj
 end
 local bb = Instance.new("BillboardGui")
 bb.Name = tag.."_BB"; bb.Adornee = root
 bb.Size = UDim2.new(0, 140, 0, isPlayer and 32 or 28)
 bb.StudsOffset = Vector3.new(0, isPlayer and 4.5 or 3.5, 0)
 bb.AlwaysOnTop = true; bb.MaxDistance = 1000; bb.Parent = obj
 local lbl = Instance.new("TextLabel")
 lbl.Size = UDim2.new(1,0,1,0); lbl.BackgroundTransparency = 1
 lbl.TextColor3 = Color3.new(1,1,1); lbl.TextStrokeTransparency = 0.3
 lbl.TextStrokeColor3 = color; lbl.TextSize = ESP.Settings.TextSize
 lbl.Font = Enum.Font.GothamBold; lbl.Text = obj.Name; lbl.Parent = bb
 local function distText()
 if ESP.Settings.ShowDistance and LocalPlayer.Character
 and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and root and root.Parent then
 local ok, dist = pcall(function()
 return (LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude
 end)
 if ok then return string.format(" | %.0fm", dist) end
 end
 return ""
 end
 if isPlayer then
 local hum = obj:FindFirstChildOfClass("Humanoid")
 if hum and ESP.Settings.ShowHealth then
 local function upd()
 pcall(function()
 if not (lbl and lbl.Parent) then return end
 lbl.Text = obj.Name..distText().." "
 ..math.floor((hum.Health/math.max(hum.MaxHealth,1))*100).."%"
 end)
 end
 upd(); Conns.health[obj] = hum.HealthChanged:Connect(upd)
 else
 local function upd()
 pcall(function() if not(lbl and lbl.Parent)then return end; lbl.Text=obj.Name..distText() end)
 end
 upd()
 task.spawn(function()
 while obj and obj.Parent and lbl and lbl.Parent do task.wait(1); pcall(upd) end
 end)
 end
 else
 local prog = obj:FindFirstChild("Progress") or obj:FindFirstChild("GeneratorProgress")
 if prog and prog:IsA("NumberValue") then
 local function upd()
 pcall(function()
 if not(lbl and lbl.Parent) then return end
 lbl.Text = obj.Name..distText().." "..math.floor(prog.Value).."%"
 end)
 end
 upd(); Conns.progress[obj] = prog.Changed:Connect(upd)
 else
 local function upd()
 pcall(function() if not(lbl and lbl.Parent)then return end; lbl.Text=obj.Name..distText() end)
 end
 upd()
 task.spawn(function()
 while obj and obj.Parent and lbl and lbl.Parent do task.wait(1); pcall(upd) end
 end)
 end
 end
 end)
 end
 local function espRemove(obj, tag)
 pcall(function()
 if not obj then return end
 local hl = obj:FindFirstChild(tag); if hl then hl:Destroy() end
 local bb = obj:FindFirstChild(tag.."_BB"); if bb then bb:Destroy() end
 if Conns.health[obj] then pcall(function() Conns.health[obj]:Disconnect() end); Conns.health[obj] = nil end
 if Conns.progress[obj] then pcall(function() Conns.progress[obj]:Disconnect() end); Conns.progress[obj] = nil end
 end)
 end
 local MINION_C00L_PATS = {"minion","clone","pizza","c00l","delivery"}
 local MINION_1X1_PATS = {"minion","rotten","forsaken","revive","1x1","infection"}
 local function isMinionC00l(name)
 name = name:lower()
 for _, p in ipairs(MINION_C00L_PATS) do if name:find(p) then return true end end
 end
 local function isMinion1x1(name)
 name = name:lower()
 for _, p in ipairs(MINION_1X1_PATS) do if name:find(p) then return true end end
 end
 local function isRealPlayer(model)
 for _, plr in ipairs(Players:GetPlayers()) do
 if plr.Character == model then return true end
 end
 return false
 end
 local function applyFromFolder(folder, tag, color, isPlayer, filterFn)
 if not folder then return end
 local items = {}
 for _, k in ipairs(folder:GetChildren()) do
 if k:IsA("Model") and (not filterFn or filterFn(k)) then
 table.insert(items, k)
 end
 end
 for _,_v in ipairs(items) do espAdd(_v, tag, color, isPlayer) end
 end
 local function removeFromFolder(folder, tag)
 if not folder then return end
 local items = {}
 for _, k in ipairs(folder:GetChildren()) do table.insert(items, k) end
 for _,_v in ipairs(items) do espRemove(_v, tag) end
 end
 local function mapApply(tag, color, namePat)
 local m = getCurrentMapFolder(); if not m then return end
 local items = {}
 for _, o in ipairs(m:GetChildren()) do if namePat(o.Name) then table.insert(items, o) end end
 for _,_v in ipairs(items) do espAdd(_v, tag, color, false) end
 end
 local function mapRemove(tag, namePat)
 local m = getCurrentMapFolder(); if not m then return end
 local items = {}
 for _, o in ipairs(m:GetChildren()) do if namePat(o.Name) then table.insert(items, o) end end
 for _,_v in ipairs(items) do espRemove(_v, tag) end
 end
 local function igApply(tag, color, namePat)
 local ig = getIngameFolder(); if not ig then return end
 local items = {}
 for _, o in ipairs(ig:GetChildren()) do if namePat(o.Name) then table.insert(items, o) end end
 for _,_v in ipairs(items) do espAdd(_v, tag, color, false) end
 end
 local function igRemove(tag, namePat)
 local ig = getIngameFolder(); if not ig then return end
 local items = {}
 for _, o in ipairs(ig:GetChildren()) do if namePat(o.Name) then table.insert(items, o) end end
 for _,_v in ipairs(items) do espRemove(_v, tag) end
 end
 local function hasGen(n) n=n:lower(); return n:find("generator") and true or false end
 local function hasItem(n) n=n:lower(); return (n:find("bloxycola") or n:find("medkit")) and true or false end
 local function hasSent(n) return n:lower():find("sentry") and true or false end
 local function hasDisp(n) return n:lower():find("dispenser") and true or false end
 local function hasFake(n) n=n:lower(); return (n:find("fake") and n:find("generator")) and true or false end
 function ESP.applyKillers() applyFromFolder(getKillersFolder(), "_ek", ESP.Colors.Killer, true) end
 function ESP.removeKillers() removeFromFolder(getKillersFolder(), "_ek") end
 function ESP.applySurvivors() applyFromFolder(getSurvivorsFolder(), "_es", ESP.Colors.Survivor, true) end
 function ESP.removeSurvivors() removeFromFolder(getSurvivorsFolder(), "_es") end
 function ESP.applyGenerators() mapApply("_eg", ESP.Colors.Generator, hasGen) end
 function ESP.removeGenerators() mapRemove("_eg", hasGen) end
 function ESP.applyItems() mapApply("_ei", ESP.Colors.Item, hasItem) end
 function ESP.removeItems() mapRemove("_ei", hasItem) end
 function ESP.applySentries() igApply("_esy", ESP.Colors.Sentry, hasSent) end
 function ESP.removeSentries() igRemove("_esy", hasSent) end
 function ESP.applyDispensers() igApply("_ed", ESP.Colors.Dispenser, hasDisp) end
 function ESP.removeDispensers() igRemove("_ed",hasDisp) end
 function ESP.applyFakeGens() mapApply("_efg", ESP.Colors.FakeGen, hasFake) end
 function ESP.removeFakeGens() mapRemove("_efg", hasFake) end
 local function minionScan(tag, color, checkFn)
 local items = {}
 local function scan(folder)
 if not folder then return end
 for _, child in ipairs(folder:GetChildren()) do
 if child:IsA("Model") and not isRealPlayer(child) and checkFn(child.Name) then
 table.insert(items, child)
 end
 for _, gc in ipairs(child:GetChildren()) do
 if gc:IsA("Model") and not isRealPlayer(gc) and checkFn(gc.Name) then
 table.insert(items, gc)
 end
 end
 end
 end
 scan(getKillersFolder()); scan(getIngameFolder())
 for _,_v in ipairs(items) do espAdd(_v, tag, color, false) end
 end
 local function minionRemove(tag)
 local function scan(folder)
 if not folder then return end
 local items = {}
 for _, child in ipairs(folder:GetChildren()) do
 if child:FindFirstChild(tag) then table.insert(items, child) end
 for _, gc in ipairs(child:GetChildren()) do
 if gc:FindFirstChild(tag) then table.insert(items, gc) end
 end
 end
 for _,_v in ipairs(items) do espRemove(_v, tag) end
 end
 scan(getKillersFolder()); scan(getIngameFolder())
 end
 function ESP.applyMinionC00l() minionScan("_emc", ESP.Colors.MinionC00l, isMinionC00l) end
 function ESP.removeMinionC00l() minionRemove("_emc") end
 function ESP.applyMinion1x1() minionScan("_em1", ESP.Colors.Minion1x1, isMinion1x1) end
 function ESP.removeMinion1x1() minionRemove("_em1") end
 function ESP.refresh()
 pcall(function()
 local function rf(hl, fc, oc, ft)
 if not hl or not hl:IsA("Highlight") then return end
 hl.FillColor=fc; hl.FillTransparency=ft; hl.OutlineColor=oc; hl.OutlineTransparency=0.1
 end
 local function sf(folder, tag, fc, oc, ft)
 if not folder then return end
 for _, obj in ipairs(folder:GetChildren()) do
 local hl = obj:FindFirstChild(tag); if hl then rf(hl, fc, oc, ft) end
 local bb = obj:FindFirstChild(tag.."_BB")
 if bb then local l = bb:FindFirstChildOfClass("TextLabel"); if l then l.TextSize = ESP.Settings.TextSize end end
 end
 end
 local tagMap = {
 {tag="_ek", color=ESP.Colors.Killer},
 {tag="_es", color=ESP.Colors.Survivor},
 {tag="_eg", color=ESP.Colors.Generator},
 {tag="_ei", color=ESP.Colors.Item},
 {tag="_esy", color=ESP.Colors.Sentry},
 {tag="_ed", color=ESP.Colors.Dispenser},
 {tag="_efg", color=ESP.Colors.FakeGen},
 {tag="_emc",color=ESP.Colors.MinionC00l},
 {tag="_em1", color=ESP.Colors.Minion1x1},
 }
 local pf = Workspace:FindFirstChild("Players")
 for _, t in ipairs(tagMap) do
 local fc, oc, ft = hlColors(t.color)
 if pf then
 sf(pf:FindFirstChild("Killers"), t.tag, fc, oc, ft)
 sf(pf:FindFirstChild("Survivors"), t.tag, fc, oc, ft)
 end
 sf(getIngameFolder(), t.tag, fc, oc, ft)
 sf(getCurrentMapFolder(), t.tag, fc, oc, ft)
 end
 end)
 end
 function ESP.init()
 pcall(function()
 for _, c in pairs(Conns.players) do pcall(function() c:Disconnect() end) end
 for _, c in pairs(Conns.map) do pcall(function() c:Disconnect() end) end
 Conns.players = {}; Conns.map = {}
 task.wait(0.1)
 local pf = Workspace:FindFirstChild("Players"); if not pf then return end
 local kf = pf:FindFirstChild("Killers")
 if kf then
 table.insert(Conns.players, kf.ChildAdded:Connect(function(c)
 task.wait(0.2); if not (c and c.Parent) then return end
 if ESP.Enabled.Killers and c:IsA("Model") then espAdd(c,"_ek",ESP.Colors.Killer,true) end
 if c:IsA("Model") and not isRealPlayer(c) then
 if ESP.Enabled.MinionC00l and isMinionC00l(c.Name) then espAdd(c,"_emc",ESP.Colors.MinionC00l,false) end
 if ESP.Enabled.Minion1x1 and isMinion1x1(c.Name) then espAdd(c,"_em1", ESP.Colors.Minion1x1, false) end
 end
 end))
 table.insert(Conns.players, kf.ChildRemoved:Connect(function(c)
 espRemove(c,"_ek"); espRemove(c,"_emc"); espRemove(c,"_em1")
 end))
 end
 task.wait(0.1)
 local sf2 = pf:FindFirstChild("Survivors")
 if sf2 then
 table.insert(Conns.players, sf2.ChildAdded:Connect(function(c)
 task.wait(0.2)
 if ESP.Enabled.Survivors and c:IsA("Model") then espAdd(c,"_es",ESP.Colors.Survivor,true) end
 end))
 table.insert(Conns.players, sf2.ChildRemoved:Connect(function(c) espRemove(c,"_es") end))
 end
 task.wait(0.1)
 local ig = getIngameFolder()
 if ig then
 table.insert(Conns.map, ig.ChildAdded:Connect(function(child)
 if child.Name == "Map" then
 task.wait(0.5)
 if ESP.Enabled.Generators then task.spawn(ESP.applyGenerators) end
 if ESP.Enabled.Items then task.spawn(ESP.applyItems) end
 if ESP.Enabled.FakeGens then task.spawn(ESP.applyFakeGens) end
 end
 task.wait(0.1)
 if ESP.Enabled.Sentries and hasSent(child.Name) then espAdd(child,"_esy", ESP.Colors.Sentry, false) end
 if ESP.Enabled.Dispensers and hasDisp(child.Name) then espAdd(child,"_ed",ESP.Colors.Dispenser,false) end
 end))
 end
 task.spawn(function()
 task.wait(1)
 if ESP.Enabled.Killers then ESP.applyKillers() end
 if ESP.Enabled.Survivors then ESP.applySurvivors() end
 if ESP.Enabled.Generators then ESP.applyGenerators() end
 if ESP.Enabled.Items then ESP.applyItems() end
 if ESP.Enabled.Sentries then ESP.applySentries() end
 if ESP.Enabled.Dispensers then ESP.applyDispensers() end
 if ESP.Enabled.FakeGens then ESP.applyFakeGens() end
 if ESP.Enabled.MinionC00l then ESP.applyMinionC00l() end
 if ESP.Enabled.Minion1x1 then ESP.applyMinion1x1() end
 end)
 Initialized = true
 end)
 end
 function ESP.scan()
 if ESP.Enabled.Killers then
 local kf = getKillersFolder()
 if kf then
 for _, k in ipairs(kf:GetChildren()) do
 if k:IsA("Model") and not k:FindFirstChild("_ek") then
 espAdd(k, "_ek", ESP.Colors.Killer, true)
 end
 end
 end
 end
 if ESP.Enabled.Survivors then
 local sf = getSurvivorsFolder()
 if sf then
 for _, s in ipairs(sf:GetChildren()) do
 if s:IsA("Model") and s ~= LocalPlayer.Character and not s:FindFirstChild("_es") then
 espAdd(s, "_es", ESP.Colors.Survivor, true)
 end
 end
 end
 end
 end
 task.spawn(function()
 task.wait(3); local att = 0
 while att < 10 and not Initialized do
 pcall(ESP.init)
 if not Initialized then att = att + 1; task.wait(2) end
 end
 end)
 LocalPlayer.CharacterAdded:Connect(function() task.wait(4); pcall(ESP.init) end)
 Workspace.ChildAdded:Connect(function(c) if c.Name == "Map" then task.wait(2); pcall(ESP.init) end end)
end
local TaphESP = {}
do
 TaphESP.tripwire = { enabled=get("taphTripwireESP",false), color=Color3.fromRGB(220,20,60), label=" Tripwire", tracked={} }
 TaphESP.tripmine = { enabled=get("taphTripmineESP",false), color=Color3.fromRGB(255,140,0), label=" Subspace Mine", tracked={} }
 local _watched = {}
 local function isTripwire(n) return n:lower():find("tripwire") ~= nil end
 local function isTripmine(n) n=n:lower(); return n:find("tripmine") ~= nil or n:find("subspace") ~= nil end
 local function isPlayerDesc(obj)
 for _, plr in ipairs(Players:GetPlayers()) do
 local ch = plr.Character
 if ch and obj:IsDescendantOf(ch) then return true end
 end
 return false
 end
 local function findRoot(obj)
 if obj:IsA("BasePart") and not isPlayerDesc(obj) then return obj end
 if obj.PrimaryPart and not isPlayerDesc(obj.PrimaryPart) then return obj.PrimaryPart end
 for _, tag in ipairs({"Handle","Wire","Mine","Plate","Base","Trigger","Part"}) do
 local p = obj:FindFirstChild(tag)
 if p and p:IsA("BasePart") and not isPlayerDesc(p) then return p end
 end
 for _, d in ipairs(obj:GetDescendants()) do
 if d:IsA("BasePart") and not isPlayerDesc(d) then return d end
 end
 end
 local function applyESP(obj, cfg)
 pcall(function()
 if not obj or not obj.Parent or isPlayerDesc(obj) then return end
 local root = findRoot(obj); if not root then return end
 if root:FindFirstChild("_te") then return end
 local tag = Instance.new("BoolValue"); tag.Name = "_te"; tag.Parent = root
 local hl = Instance.new("Highlight")
 hl.FillColor=cfg.color; hl.FillTransparency=0.25
 hl.OutlineColor=cfg.color; hl.OutlineTransparency=0
 hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
 hl.Adornee=root; hl.Parent=root
 local bb = Instance.new("BillboardGui")
 bb.Name="_tl"; bb.Adornee=root
 bb.Size=UDim2.new(0,120,0,20); bb.StudsOffset=Vector3.new(0,-0.6,0)
 bb.AlwaysOnTop=true; bb.MaxDistance=80; bb.Parent=root
 local lbl = Instance.new("TextLabel")
 lbl.Size=UDim2.new(1,0,1,0); lbl.BackgroundTransparency=1
 lbl.Text=cfg.label; lbl.TextColor3=cfg.color
 lbl.TextStrokeColor3=Color3.new(0,0,0); lbl.TextStrokeTransparency=0.2
 lbl.TextSize=11; lbl.Font=Enum.Font.GothamBold; lbl.Parent=bb
 local cleanConn
 cleanConn = root.AncestryChanged:Connect(function()
 if root.Parent then return end
 pcall(function() cleanConn:Disconnect() end)
 pcall(function() hl:Destroy(); tag:Destroy(); bb:Destroy() end)
 TaphESP.tripwire.tracked[obj]=nil; TaphESP.tripmine.tracked[obj]=nil
 end)
 end)
 end
 local function removeESP(obj)
 pcall(function()
 if not obj then return end
 local function clean(p)
 if not p then return end
 local t = p:FindFirstChild("_te"); if t then t:Destroy() end
 local h = p:FindFirstChildWhichIsA("Highlight"); if h then h:Destroy() end
 local b = p:FindFirstChild("_tl"); if b then b:Destroy() end
 end
 if obj:IsA("BasePart") then clean(obj)
 else for _, d in ipairs(obj:GetDescendants()) do if d:IsA("BasePart") then clean(d) end end end
 end)
 end
 local function checkObj(obj)
 pcall(function()
 if not obj or isPlayerDesc(obj) then return end
 local name = obj.Name
 if isTripwire(name) and TaphESP.tripwire.enabled and not TaphESP.tripwire.tracked[obj] then
 TaphESP.tripwire.tracked[obj] = true
 task.delay(0.15, function() applyESP(obj, TaphESP.tripwire) end)
 end
 if isTripmine(name) and TaphESP.tripmine.enabled and not TaphESP.tripmine.tracked[obj] then
 TaphESP.tripmine.tracked[obj] = true
 task.delay(0.15, function() applyESP(obj, TaphESP.tripmine) end)
 end
 end)
 end
 local function watchFolder(folder)
 pcall(function()
 if not folder or _watched[folder] then return end
 _watched[folder] = true
 folder.ChildAdded:Connect(function(c)
 task.wait(0.1)
 if isPlayerDesc(c) then return end
 checkObj(c)
 if c:IsA("Model") or c:IsA("Folder") then
 for _, gc in ipairs(c:GetChildren()) do checkObj(gc) end
 c.ChildAdded:Connect(function(gc) task.wait(0.05); checkObj(gc) end)
 end
 end)
 for _, c in ipairs(folder:GetChildren()) do checkObj(c) end
 end)
 end
 function TaphESP.setup()
 pcall(function()
 local ingame = Workspace:FindFirstChild("Map") and Workspace.Map:FindFirstChild("Ingame")
 if ingame then
 watchFolder(ingame)
 ingame.ChildAdded:Connect(function(child)
 task.wait(0.1)
 if not isPlayerDesc(child) then watchFolder(child); checkObj(child) end
 end)
 for _, child in ipairs(ingame:GetChildren()) do watchFolder(child) end
 end
 for _, d in ipairs(Workspace:GetDescendants()) do
 if not isPlayerDesc(d) and (isTripwire(d.Name) or isTripmine(d.Name)) then checkObj(d) end
 end
 end)
 end
 function TaphESP.refresh()
 pcall(function()
 local function scan(cfg, checkFn)
 for obj in pairs(cfg.tracked) do
 if not cfg.enabled then removeESP(obj); cfg.tracked[obj] = nil end
 end
 if cfg.enabled then
 for _, d in ipairs(Workspace:GetDescendants()) do
 if not isPlayerDesc(d) and checkFn(d.Name) and not cfg.tracked[d] then
 cfg.tracked[d] = true
 task.delay(0.05, function() applyESP(d, cfg) end)
 end
 end
 end
 end
 scan(TaphESP.tripwire, isTripwire)
 scan(TaphESP.tripmine, isTripmine)
 end)
 end
 function TaphESP.reset() _watched = {} end
end
local ov = {}
do
 local detectionCircles = {}
 local facingVisuals = {}
 local function addCircle(killer)
 pcall(function()
 if not killer or not killer:FindFirstChild("HumanoidRootPart") or detectionCircles[killer] then return end
 local hrp = killer.HumanoidRootPart
 local c = Instance.new("CylinderHandleAdornment")
 c.Name="_kdc"; c.Adornee=hrp
 c.Color3=ESP.Colors.Killer; c.AlwaysOnTop=true; c.ZIndex=1; c.Transparency=0.6
 c.Radius=S.detectionRange; c.Height=0.12
 c.CFrame=CFrame.new(0,-(hrp.Size.Y/2+0.05),0)*CFrame.Angles(math.rad(90),0,0)
 c.Parent=hrp; detectionCircles[killer]=c
 end)
 end
 local function removeCircle(killer)
 pcall(function()
 if detectionCircles[killer] then detectionCircles[killer]:Destroy(); detectionCircles[killer]=nil end
 end)
 end
 local function updateFacing(killer, visual)
 pcall(function()
 if not(killer and visual and visual.Parent) then return end
 local hrp = killer:FindFirstChild("HumanoidRootPart"); if not hrp then return end
 local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
 local inRange, facing = false, false
 if myRoot then
 inRange = (hrp.Position - myRoot.Position).Magnitude <= S.detectionRange
 if inRange then facing = isStrictlyFacing(myRoot, hrp, killer.Name) end
 end
 if inRange and facing then visual.Color3=Color3.fromRGB(120,255,120); visual.Transparency=0.3
 elseif inRange then visual.Color3=Color3.fromRGB(255,120,120); visual.Transparency=0.6
 else visual.Color3=Color3.fromRGB(255,255,120); visual.Transparency=0.85 end
 local frac = math.acos(math.clamp(STRICT_FACING_DOT,-1,1))/math.pi
 visual.Radius=math.max(1,S.detectionRange*(0.20+0.80*frac)); visual.Height=0.12
 visual.CFrame=CFrame.new(0,-(hrp.Size.Y/2+0.05),-S.detectionRange*(0.35+0.15*frac))*CFrame.Angles(math.rad(90),0,0)
 end)
 end
 local function addFacing(killer)
 pcall(function()
 if not killer or not killer:IsA("Model") or facingVisuals[killer] then return end
 local hrp = killer:FindFirstChild("HumanoidRootPart"); if not hrp then return end
 local v = Instance.new("CylinderHandleAdornment")
 v.Name="_fcv"; v.Adornee=hrp
 v.AlwaysOnTop=true; v.ZIndex=2; v.Transparency=0.55
 v.Color3=Color3.fromRGB(120,255,120); v.Parent=hrp
 facingVisuals[killer]=v; updateFacing(killer,v)
 end)
 end
 local function removeFacing(killer)
 pcall(function()
 local v = facingVisuals[killer]; if v then v:Destroy(); facingVisuals[killer]=nil end
 end)
 end
 function ov.refreshCircles()
 local kf = getKillersFolder(); if not kf then return end
 local items = {}; for _, k in ipairs(kf:GetChildren()) do table.insert(items, k) end
 for _,_v in ipairs(items) do
  if S.killerCirclesVisible then addCircle(_v) else removeCircle(_v) end
 end
 end
 function ov.refreshFacing()
 local kf = getKillersFolder(); if not kf then return end
 local items = {}; for _, k in ipairs(kf:GetChildren()) do table.insert(items, k) end
 for _,_v in ipairs(items) do
  if S.facingVisualOn then if _v:FindFirstChild("HumanoidRootPart") then addFacing(_v) end
  else removeFacing(_v) end
 end
 end
 function ov.setupListeners()
 pcall(function()
 local kf = getKillersFolder()
 if not kf then
 for _ = 1, 5 do task.wait(1); kf = getKillersFolder(); if kf then break end end
 if not kf then return end
 end
 kf.ChildAdded:Connect(function(killer)
 if S.killerCirclesVisible then task.spawn(function() if killer:WaitForChild("HumanoidRootPart",5) then addCircle(killer) end end) end
 if S.facingVisualOn then task.spawn(function() if killer:WaitForChild("HumanoidRootPart",5) then addFacing(killer) end end) end
 end)
 kf.ChildRemoved:Connect(function(killer) removeCircle(killer); removeFacing(killer) end)
 end)
 end
 function ov.tick()
 for killer, circle in pairs(detectionCircles) do
 if circle and circle.Parent then circle.Radius = S.detectionRange
 elseif circle then pcall(function() circle:Destroy() end); detectionCircles[killer] = nil end
 end
 for killer, visual in pairs(facingVisuals) do
 if not killer or not killer.Parent or not killer:FindFirstChild("HumanoidRootPart") then
 if visual then pcall(function() visual:Destroy() end) end
 facingVisuals[killer] = nil
 else
 updateFacing(killer, visual)
 end
 end
 end
end
task.spawn(ov.setupListeners)
local stam = {}
do
 function stam.apply()
 pcall(function()
 local ok, st = pcall(function()
 return require(ReplicatedStorage.Systems.Character.Game.Sprinting)
 end)
 if ok and st then
 if st.Init and not st.DefaultsSet then st.Init() end
 st.StaminaLoss = S.staminaLossValue
 st.StaminaGain = S.staminaGainValue
 st.MaxStamina = S.staminaMaxValue
 st.Stamina = S.staminaCurrentValue
 st.StaminaLossDisabled = S.staminaLossDisabled
 if st.__staminaChangedEvent then st.__staminaChangedEvent:Fire() end
 end
 end)
 pcall(function()
 local char = LocalPlayer.Character; if not char then return end
 local sv = char:FindFirstChild("Stamina") or char:FindFirstChild("StaminaValue")
 if sv and sv:IsA("NumberValue") then sv.Value = S.staminaCurrentValue end
 local hum = char:FindFirstChildOfClass("Humanoid")
 if hum then
 hum:SetAttribute("Stamina", S.staminaCurrentValue)
 hum:SetAttribute("MaxStamina", S.staminaMaxValue)
 end
 if testRemote then
 testRemote:FireServer("SetStaminaDisabled", S.staminaLossDisabled)
 testRemote:FireServer("UpdateStamina", S.staminaCurrentValue)
 end
 end)
 end
end
LocalPlayer.CharacterAdded:Connect(function()
 task.wait(1); if S.staminaCustomEnabled then pcall(stam.apply) end
end)
local LMS = {}
do
 local LMS_FOLDER = "hub/sng"
 local LMS_TRACKS = {
 ["Eternal Hope"] = "https://www.sndup.net/hbbdc/d",
 ["Vanity"] = "https://sndup.net/pbfc6/d",
 ["Hacklord"] = "https://www.sndup.net/3ggm8/d",
 ["Compass"] = "https://www.sndup.net/m897m/d",
 ["Scrapped Sixer"] = "https://sndup.net/jwx39/d",
 ["ONE BOUNCE"] = "https://www.sndup.net/hrjch/d",
 ["Meet Your Making"] = "https://www.sndup.net/w5kzs/d",
 }
 local downloaded = {}
 local originalId = nil
 local thread = nil
 pcall(function()
 if not isfolder("hub") then makefolder("hub") end
 if not isfolder(LMS_FOLDER) then makefolder(LMS_FOLDER) end
 end)
 local function download(songName, callback)
 local url = LMS_TRACKS[songName]; if not url then if callback then callback(nil) end; return end
 local safe = songName:gsub("[^%w]","_")
 local path = LMS_FOLDER.."/"..safe..".mp3"
 if not isfile(path) then
 local ok, data = pcall(function() return game:HttpGet(url) end)
 if not ok or not data or #data == 0 then if callback then callback(nil) end; return end
 pcall(function() writefile(path, data) end)
 end
 local asset; local ok2 = pcall(function() asset = getcustomasset(path) end)
 if not ok2 or not asset then if callback then callback(nil) end; return end
 downloaded[songName] = asset; if callback then callback(asset) end
 return asset
 end
 local function findSound()
 local function check(sound)
 if not sound or not sound:IsA("Sound") then return false end
 local n = sound.Name:lower()
 return n == "lastsurvivor" or n:find("last") or n:find("lms") or n:find("survivor")
 end
 for _, loc in ipairs({Workspace:FindFirstChild("Sounds"), Workspace:FindFirstChild("Themes"),
 Workspace:FindFirstChild("Music"), Lighting, SoundService}) do
 if loc then for _, s in ipairs(loc:GetChildren()) do if check(s) then return s end end end
 end
 for _, s in ipairs(Workspace:GetDescendants()) do if check(s) then return s end end
 for _, s in ipairs(ReplicatedStorage:GetDescendants()) do if check(s) then return s end end
 end
 local function isActive()
 local ok, r = pcall(function()
 local pf = Workspace:FindFirstChild("Players")
 if pf then
 local sf = pf:FindFirstChild("Survivors")
 if sf then
 local alive = 0
 for _, s in ipairs(sf:GetChildren()) do
 local h = s:FindFirstChildOfClass("Humanoid")
 if h and h.Health > 0 then alive = alive + 1 end
 end
 if alive == 1 then return true end
 if alive > 1 then return false end
 end
 end
 local sound = findSound()
 return sound ~= nil and sound.IsPlaying
 end)
 return ok and r or false
 end
 local function applySong(songName)
 local sound = findSound(); if not sound then return false end
 if not originalId then originalId = sound.SoundId end
 local asset = downloaded[songName] or download(songName)
 if not asset then return false end
 pcall(function()
 sound:Stop(); sound.SoundId = asset; sound.Volume = 0.55
 task.wait(0.05); sound:Play()
 end)
 return true
 end
 function LMS.reset()
 pcall(function()
 local sound = findSound()
 if sound and originalId then
 sound:Stop(); sound.SoundId = originalId; task.wait(0.05); sound:Play()
 end
 end)
 end
 function LMS.go()
 if thread then pcall(function() task.cancel(thread) end) end
 thread = task.spawn(function()
 if not downloaded[S.lmsSelectedSong] then
 task.spawn(function() download(S.lmsSelectedSong) end)
 end
 local wasActive = false
 while S.lmsAutoPlay do
 local active = false
 pcall(function()
 active = isActive()
 if active and not wasActive then
 wasActive = true; applySong(S.lmsSelectedSong)
 elseif active and wasActive then
 local sound = findSound()
 if sound then
 local ca = downloaded[S.lmsSelectedSong]
 if ca and sound.SoundId ~= ca then applySong(S.lmsSelectedSong) end
 end
 elseif not active and wasActive then
 wasActive = false
 end
 end)
 task.wait(active and 3 or 1)
 end
 end)
 end
 function LMS.halt()
 if thread then pcall(function() task.cancel(thread) end); thread = nil end
 LMS.reset()
 end
 function LMS.playNow() return applySong(S.lmsSelectedSong) end
 function LMS.download(name) return download(name) end
 LMS.tracks = LMS_TRACKS
end
LocalPlayer.CharacterAdded:Connect(function()
 task.wait(3); if S.lmsAutoPlay then LMS.go() end
end)
if S.lmsAutoPlay then task.spawn(LMS.start) end
do
 local function gDir(cr,cc,or2,oc)
 if or2<cr then return"up" elseif or2>cr then return"down"
 elseif oc<cc then return"left" else return"right" end
 end
 local function gConns(prev,curr,nxt)
 local conn={}
 if prev and curr then
 local d=gDir(curr.row,curr.col,prev.row,prev.col)
 if d=="up"then d="down" elseif d=="down"then d="up"
 elseif d=="left"then d="right" else d="left" end; conn[d]=true
 end
 if nxt and curr then local d=gDir(curr.row,curr.col,nxt.row,nxt.col); if d then conn[d]=true end end
 return conn
 end
 local function gNB(r1,c1,r2,c2)
 if r2==r1-1 and c2==c1 then return"up" end; if r2==r1+1 and c2==c1 then return"down" end
 if r2==r1 and c2==c1-1 then return"left" end; if r2==r1 and c2==c1+1 then return"right" end; return false
 end
 local function gKey(n) return n.row.."-"..n.col end
 local function gOrder(path, endpoints)
 if not path or #path==0 then return path end
 local inPath={}; for _,n in ipairs(path) do inPath[gKey(n)]=n end
 local startNode
 for _,ep in ipairs(endpoints or{}) do
 for _,n in ipairs(path) do
 if n.row==ep.row and n.col==ep.col then startNode={row=ep.row,col=ep.col}; break end
 end; if startNode then break end
 end
 if not startNode then
 for _,n in ipairs(path) do
 local nb=0
 for _,d in ipairs({{-1,0},{1,0},{0,-1},{0,1}}) do
 if inPath[(n.row+d[1]).."-"..(n.col+d[2])] then nb=nb+1 end
 end
 if nb==1 then startNode={row=n.row,col=n.col}; break end
 end
 end
 if not startNode then startNode={row=path[1].row,col=path[1].col} end
 local remaining,ordered={},{}
 for _,n in ipairs(path) do remaining[gKey(n)]={row=n.row,col=n.col} end
 local current=startNode; table.insert(ordered,{row=current.row,col=current.col}); remaining[gKey(current)]=nil
 local iter=0
 while next(remaining) and iter<100 do
 iter=iter+1; local found=false
 for k,node in pairs(remaining) do
 if gNB(current.row,current.col,node.row,node.col) then
 table.insert(ordered,{row=node.row,col=node.col})
 remaining[k]=nil; current=node; found=true; break
 end
 end; if not found then break end
 end; return ordered
 end
 local function gDraw(puzzle)
 pcall(function()
 if not puzzle or not puzzle.Solution then return end
 local indices={}; for i=1,#puzzle.Solution do table.insert(indices,i) end
 for i=#indices,2,-1 do local j=math.random(1,i); indices[i],indices[j]=indices[j],indices[i] end
 for _,ci in ipairs(indices) do
 local path=puzzle.Solution[ci]
 local ordered=gOrder(path,puzzle.targetPairs and puzzle.targetPairs[ci])
 puzzle.paths[ci]={}
 for i,node in ipairs(ordered) do
 table.insert(puzzle.paths[ci],{row=node.row,col=node.col})
 local conn=gConns(ordered[i-1],node,ordered[i+1])
 puzzle.gridConnections=puzzle.gridConnections or{}
 puzzle.gridConnections[gKey(node)]=conn
 pcall(function() puzzle:updateGui() end); task.wait(S.genFlowNodeDelay)
 end
 task.wait(S.genFlowLineDelay); pcall(function() puzzle:checkForWin() end)
 end
 end)
 end
 local ok2,mod2=pcall(function()
 return ReplicatedStorage:FindFirstChild("Modules")
 and ReplicatedStorage.Modules:FindFirstChild("Misc")
 and ReplicatedStorage.Modules.Misc:FindFirstChild("FlowGameManager")
 and ReplicatedStorage.Modules.Misc.FlowGameManager:FindFirstChild("FlowGame")
 end)
 if ok2 and mod2 then
 local ok3, FlowGame = pcall(function() return require(mod2) end)
 if ok3 and FlowGame then
 local oldNew = FlowGame.new
 FlowGame.new = function(...)
 local puzzle = oldNew(...)
 if S.genFlowSolverEnabled then
 task.spawn(function()
 task.wait(0.3)
 if puzzle and puzzle.Solution then pcall(gDraw, puzzle) end
 end)
 end
 return puzzle
 end
 end
 end
end
local function doAimPunch()
 pcall(function()
 if not S.aimPunchEnabled then return end
 local myChar = LocalPlayer.Character; if not myChar then return end
 local myRoot = myChar:FindFirstChild("HumanoidRootPart"); if not myRoot then return end
 local kf = Workspace:FindFirstChild("Players") and Workspace.Players:FindFirstChild("Killers")
 if not kf then return end
 local nearest, nDist = nil, math.huge
 for _, killer in pairs(kf:GetChildren()) do
 local hrp = killer:FindFirstChild("HumanoidRootPart")
 if hrp then
 local d = (hrp.Position - myRoot.Position).Magnitude
 if d <= S.lockMaxDistance and d < nDist then nDist=d; nearest=killer end
 end
 end
 if not nearest then return end
 local tHRP = nearest:FindFirstChild("HumanoidRootPart"); if not tHRP then return end
 local hum = myChar:FindFirstChildOfClass("Humanoid"); if hum then hum.AutoRotate = false end
 task.spawn(function()
 local st = tick()
 while tick()-st < S.aimWindow do
 pcall(function()
 local c = LocalPlayer.Character; local r = c and c:FindFirstChild("HumanoidRootPart")
 if not r or not tHRP or not tHRP.Parent then return end
 local vel = Vector3.zero
 pcall(function() vel = tHRP.AssemblyLinearVelocity end)
 if vel.Magnitude < 0.01 then pcall(function() vel = tHRP.Velocity end) end
 local pd = vel.Magnitude > 0.5 and vel.Unit or tHRP.CFrame.LookVector
 if pd ~= pd then pd = Vector3.zero end
 r.CFrame = CFrame.lookAt(r.Position, tHRP.Position + (pd * S.predictionValue) + (vel * 0.1))
 end)
 task.wait()
 end
 local c = LocalPlayer.Character
 if c then local h = c:FindFirstChildOfClass("Humanoid"); if h then h.AutoRotate = true end end
 end)
 end)
end
do
 local frame = 0
 local lastAimPunchFrame = 0
 local AIM_PUNCH_CD = 10
local hbFn = WYNF_JIT(function()
  frame = frame + 1
  local myChar = LocalPlayer.Character
  local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
  if myChar and myRoot then
   -- aim punch: triggers when survivor punches, locks aim at nearest killer
   if S.characterLockOn and anim and (frame - lastAimPunchFrame) >= AIM_PUNCH_CD then
    for _, track in ipairs(anim:GetPlayingAnimationTracks()) do
     local id = tostring(track.Animation and track.Animation.AnimationId or ""):match("%d+")
     if id and PUNCH_ANIM_SET[id] then
      lastAimPunchFrame = frame
      task.spawn(doAimPunch)
      break
     end
    end
   end
   -- auto punch: fires punch at any killer within 10 studs
   if S.autoPunchOn and frame % 2 == 0 then
    local kf = getKillersFolder()
    if kf then
     for _, killer in ipairs(kf:GetChildren()) do
      local r = killer:FindFirstChild("HumanoidRootPart")
      if r and (r.Position - myRoot.Position).Magnitude <= 10 then
       fire("Punch"); break
      end
     end
    end
   end
  end
  sndBlock.tick()
  if frame % 2 == 0 then ov.tick() end
  if frame % 30 == 0 then ESP.scan() end
 end)
 RunService.Heartbeat:Connect(function()
  pcall(hbFn)
 end)
end
local Tabs = {}
pcall(function()
 Tabs.Combat = Window:Tab({Title="Combat", Icon="sword"})
 Tabs.Visuals = Window:Tab({Title="Visuals", Icon="eye"})
 Tabs.Player = Window:Tab({Title="Player", Icon="user"})
 Tabs.World = Window:Tab({Title="World", Icon="globe"})
 Tabs.Music = Window:Tab({Title="Music", Icon="music"})
 Tabs.Config = Window:Tab({Title="Config", Icon="settings"})
end)
do
 local tab = Tabs.Combat
 pcall(function()
 local sAB = tab:Section({Title="Auto Block", Opened=true})
 sAB:Toggle({Title="Auto Block (Audio)",Value=S.autoBlockAudioOn,Callback=function(v)
 pcall(function() S.autoBlockAudioOn=v; set("autoBlockAudioOn",v); if v then task.spawn(sndBlock.setup) end end)
 end})
 sAB:Dropdown({Title="Block Type",Values={"Block","Charge","7n7 Clone"},Value=S.autoblocktype,Callback=function(v)
 S.autoblocktype=v; set("autoblocktype",v)
 end})
 sAB:Slider({Title="Block Delay",Value={Min=0,Max=0.5,Default=S.blockdelay},Step=0.01,Callback=function(v)
 S.blockdelay=(tonumber(v) or S.blockdelay); set("blockdelay",S.blockdelay)
 end})
 sAB:Slider({Title="Detection Range",Value={Min=5,Max=50,Default=S.detectionRange},Step=1,Callback=function(v)
 S.detectionRange=(tonumber(v) or S.detectionRange); set("detectionRange",S.detectionRange)
 end})
 sAB:Toggle({Title="Facing Check",Value=S.facingCheckEnabled,Callback=function(v)
 S.facingCheckEnabled=v; set("facingCheckEnabled",v)
 end})
 sAB:Toggle({Title="Double Punch Tech",Value=S.doubleblocktech,Callback=function(v)
 S.doubleblocktech=v; set("doubleblocktech",v)
 end})
 sAB:Toggle({Title="Anti-Bait",Value=S.antiBaitEnabled,Callback=function(v)
  S.antiBaitEnabled=v; set("antiBaitEnabled",v)
 end})
 sAB:Slider({Title=" Block Miss Chance",Value={Min=0,Max=100,Default=S.abMissChance},Step=1,Callback=function(v)
 S.abMissChance=(tonumber(v) or S.abMissChance); set("abMissChance",S.abMissChance)
 end})
 end)
 pcall(function()
 local sHDT = tab:Section({Title="HDT Tech", Opened=true})
 sHDT:Toggle({Title="Hitbox Dragging",Value=S.hitboxDraggingTech,Callback=function(v)
 S.hitboxDraggingTech=v; set("hitboxDraggingTech",v)
 end})
 sHDT:Slider({Title="HDT Speed",Value={Min=1,Max=30,Default=S.Dspeed},Step=0.5,Callback=function(v)
 S.Dspeed=(tonumber(v) or S.Dspeed); set("Dspeed",S.Dspeed)
 end})
 sHDT:Slider({Title="HDT Delay",Value={Min=0,Max=0.5,Default=S.Ddelay},Step=0.01,Callback=function(v)
 S.Ddelay=(tonumber(v) or S.Ddelay); set("Ddelay",S.Ddelay)
 end})
 sHDT:Slider({Title="Rotate Delay",Value={Min=0,Max=0.5,Default=S.rotateDelay},Step=0.01,Callback=function(v)
 S.rotateDelay=(tonumber(v) or S.rotateDelay); set("rotateDelay",S.rotateDelay)
 end})
 sHDT:Slider({Title=" HDT Miss Chance",Value={Min=0,Max=100,Default=S.hdtMissChance},Step=1,Callback=function(v)
 S.hdtMissChance=(tonumber(v) or S.hdtMissChance); set("hdtMissChance",S.hdtMissChance)
 end})
 sHDT:Dropdown({Title="HDT Mode",Values={"180_TURN","LEFT_SPIN","RIGHT_SPIN"},Value=S.hdtMode,Callback=function(v)
 S.hdtMode=v; set("hdtMode",v)
 end})
 end)
 pcall(function()
 local sRCT = tab:Section({Title=" Reverse Charge Tech (RCT)", Opened=true})
 sRCT:Toggle({Title="Enable RCT",Value=S.rctEnabled,Callback=function(v)
 pcall(function()
 S.rctEnabled=v; set("rctEnabled",v)
 WindUI:Notify({Title="RCT",Content=v and"Active"or"Disabled",Icon="zap",Duration=2})
 end)
 end})
 sRCT:Button({Title=" Fire Charge + Flick",Callback=function()
 pcall(function()
 if not S.rctEnabled then WindUI:Notify({Title="RCT",Content="Enable RCT first!",Icon="alert",Duration=2}); return end
 rct.fire()
 end)
 end})
 sRCT:Dropdown({Title="Flick Direction",Values={"Right","Left","Back","Auto"},Value=S.rctFlickDir,Callback=function(v)
 S.rctFlickDir=v; set("rctFlickDir",v)
 end})
 sRCT:Toggle({Title="Auto Ledge",Value=S.rctAutoLedge,Callback=function(v)
 S.rctAutoLedge=v; set("rctAutoLedge",v)
 end})
 sRCT:Slider({Title="Flick Angle",Value={Min=45,Max=180,Default=S.rctFlickAngle},Step=5,Callback=function(v)
 S.rctFlickAngle=(tonumber(v) or S.rctFlickAngle); set("rctFlickAngle",S.rctFlickAngle)
 end})
 sRCT:Slider({Title="Flick Delay",Value={Min=0,Max=0.3,Default=S.rctFlickDelay},Step=0.01,Callback=function(v)
 S.rctFlickDelay=(tonumber(v) or S.rctFlickDelay); set("rctFlickDelay",S.rctFlickDelay)
 end})
 sRCT:Slider({Title="Flick Speed",Value={Min=0.02,Max=0.2,Default=S.rctFlickSpeed},Step=0.01,Callback=function(v)
 S.rctFlickSpeed=(tonumber(v) or S.rctFlickSpeed); set("rctFlickSpeed",S.rctFlickSpeed)
 end})
 sRCT:Slider({Title=" RCT Miss Chance",Value={Min=0,Max=100,Default=S.rctMissChance},Step=1,Callback=function(v)
 S.rctMissChance=(tonumber(v) or S.rctMissChance); set("rctMissChance",S.rctMissChance)
 end})
 end)
 pcall(function()
 local sPunch = tab:Section({Title="Auto Punch", Opened=true})
 sPunch:Toggle({Title="Auto Punch",Value=S.autoPunchOn,Callback=function(v)
 S.autoPunchOn=v; set("autoPunchOn",v)
 end})
 local sLock = tab:Section({Title="Lock (Survivor Side)", Opened=true})
 sLock:Toggle({Title="Aim Punch (Lock on Punch)",Value=S.characterLockOn,Callback=function(v)
 S.characterLockOn=v; set("characterLockOn",v)
 end})
 sLock:Slider({Title="Max Distance",Value={Min=5,Max=100,Default=S.lockMaxDistance},Step=5,Callback=function(v)
 S.lockMaxDistance=(tonumber(v) or S.lockMaxDistance); set("lockMaxDistance",S.lockMaxDistance)
 end})
 sLock:Slider({Title="Prediction",Value={Min=0,Max=15,Default=S.predictionValue},Step=0.5,Callback=function(v)
 S.predictionValue=(tonumber(v) or S.predictionValue); set("predictionValue",S.predictionValue)
 end})
 local sOV = tab:Section({Title="Obsidian Vision", Opened=true})
 sOV:Toggle({Title="Detection Circles",Value=S.killerCirclesVisible,Callback=function(v)
 pcall(function() S.killerCirclesVisible=v; set("killerCirclesVisible",v); ov.refreshCircles() end)
 end})
 sOV:Toggle({Title="Facing Visual",Value=S.facingVisualOn,Callback=function(v)
 pcall(function() S.facingVisualOn=v; set("facingVisualOn",v); ov.refreshFacing() end)
 end})
 end)
end
do
 local tab = Tabs.Visuals
 pcall(function()
 local sp = tab:Section({Title="Player ESP", Opened=true})
 sp:Toggle({Title="Killers ",Value=ESP.Enabled.Killers,Callback=function(v)
 pcall(function() ESP.Enabled.Killers=v; set("espKillersEnabled",v); if v then ESP.applyKillers() else ESP.removeKillers() end end)
 end})
 sp:Toggle({Title="Survivors ",Value=ESP.Enabled.Survivors,Callback=function(v)
 pcall(function() ESP.Enabled.Survivors=v; set("espSurvivorsEnabled",v); if v then ESP.applySurvivors() else ESP.removeSurvivors() end end)
 end})
 local sw = tab:Section({Title="World ESP", Opened=true})
 sw:Toggle({Title="Generators ",Value=ESP.Enabled.Generators,Callback=function(v)
 pcall(function() ESP.Enabled.Generators=v; set("espGeneratorsEnabled",v); if v then ESP.applyGenerators() else ESP.removeGenerators() end end)
 end})
 sw:Toggle({Title="Items ",Value=ESP.Enabled.Items,Callback=function(v)
 pcall(function() ESP.Enabled.Items=v; set("espItemsEnabled",v); if v then ESP.applyItems() else ESP.removeItems() end end)
 end})
 end)
 pcall(function()
 local sb = tab:Section({Title="Builderman ESP", Opened=true})
 sb:Toggle({Title="Sentry ",Value=ESP.Enabled.Sentries,Callback=function(v)
 pcall(function() ESP.Enabled.Sentries=v; set("espSentryEnabled",v); if v then ESP.applySentries() else ESP.removeSentries() end end)
 end})
 sb:Toggle({Title="Dispenser ",Value=ESP.Enabled.Dispensers,Callback=function(v)
 pcall(function() ESP.Enabled.Dispensers=v; set("espDispenserEnabled",v); if v then ESP.applyDispensers() else ESP.removeDispensers() end end)
 end})
 local sf = tab:Section({Title="Fake Generator ESP", Opened=true})
 sf:Toggle({Title="Fake Generators ",Value=ESP.Enabled.FakeGens,Callback=function(v)
 pcall(function() ESP.Enabled.FakeGens=v; set("espFakeGenEnabled",v); if v then ESP.applyFakeGens() else ESP.removeFakeGens() end end)
 end})
 end)
 pcall(function()
 local sm = tab:Section({Title=" Minion ESP", Opened=true})
 sm:Toggle({Title="c00lkidd Minions ",Value=ESP.Enabled.MinionC00l,Callback=function(v)
 pcall(function() ESP.Enabled.MinionC00l=v; set("espMinionC00lEnabled",v); if v then ESP.applyMinionC00l() else ESP.removeMinionC00l() end end)
 end})
 sm:Toggle({Title="1x1x1x1 Minions ",Value=ESP.Enabled.Minion1x1,Callback=function(v)
 pcall(function() ESP.Enabled.Minion1x1=v; set("espMinion1x1Enabled",v); if v then ESP.applyMinion1x1() else ESP.removeMinion1x1() end end)
 end})
 sm:Button({Title=" Force Rescan Minions",Callback=function()
 pcall(function()
 if ESP.Enabled.MinionC00l then ESP.removeMinionC00l(); task.wait(0.2); ESP.applyMinionC00l() end
 if ESP.Enabled.Minion1x1 then ESP.removeMinion1x1(); task.wait(0.2); ESP.applyMinion1x1() end
 WindUI:Notify({Title="Minion ESP",Content="Rescanned!",Icon="refresh-cw",Duration=2})
 end)
 end})
 end)
 pcall(function()
 local st = tab:Section({Title=" Taph Trap ESP", Opened=true})
 st:Toggle({Title="Tripwire ESP ",Value=TaphESP.tripwire.enabled,Callback=function(v)
 pcall(function() TaphESP.tripwire.enabled=v; set("taphTripwireESP",v); if v then task.spawn(TaphESP.setup) end; task.spawn(TaphESP.refresh) end)
 end})
 st:Toggle({Title="Tripmine ESP ",Value=TaphESP.tripmine.enabled,Callback=function(v)
 pcall(function() TaphESP.tripmine.enabled=v; set("taphTripmineESP",v); if v then task.spawn(TaphESP.setup) end; task.spawn(TaphESP.refresh) end)
 end})
 st:Button({Title=" Force Rescan",Callback=function()
 pcall(function()
 TaphESP.reset(); task.spawn(TaphESP.setup); task.spawn(TaphESP.refresh)
 WindUI:Notify({Title="Taph",Content="Rescanning...",Icon="search",Duration=2})
 end)
 end})
 local ss = tab:Section({Title="Style Settings", Opened=true})
 ss:Dropdown({Title="ESP Style",Values={"Glow","Outline","Minimal"},Value=ESP.Settings.Style,Callback=function(v)
 pcall(function() ESP.Settings.Style=v; set("espStyle",v); ESP.refresh() end)
 end})
 ss:Toggle({Title="Show Distance",Value=ESP.Settings.ShowDistance,Callback=function(v)
 pcall(function() ESP.Settings.ShowDistance=v; set("espShowDistance",v) end)
 end})
 ss:Toggle({Title="Show Health",Value=ESP.Settings.ShowHealth,Callback=function(v)
 pcall(function() ESP.Settings.ShowHealth=v; set("espShowHealth",v) end)
 end})
 ss:Slider({Title="Transparency",Value={Min=0,Max=1,Default=ESP.Settings.Transparency},Step=0.05,Callback=function(v)
 pcall(function() ESP.Settings.Transparency=v; set("espTransparency",v); ESP.refresh() end)
 end})
 ss:Button({Title=" Force Refresh ESP",Callback=function()
 pcall(function()
 if ESP.Enabled.Killers then ESP.removeKillers() end
 if ESP.Enabled.Survivors then ESP.removeSurvivors() end
 if ESP.Enabled.Generators then ESP.removeGenerators() end
 if ESP.Enabled.Items then ESP.removeItems() end
 if ESP.Enabled.Sentries then ESP.removeSentries() end
 if ESP.Enabled.Dispensers then ESP.removeDispensers() end
 if ESP.Enabled.FakeGens then ESP.removeFakeGens() end
 task.wait(0.5)
 if ESP.Enabled.Killers then ESP.applyKillers() end
 if ESP.Enabled.Survivors then ESP.applySurvivors() end
 if ESP.Enabled.Generators then ESP.applyGenerators() end
 if ESP.Enabled.Items then ESP.applyItems() end
 if ESP.Enabled.Sentries then ESP.applySentries() end
 if ESP.Enabled.Dispensers then ESP.applyDispensers() end
 if ESP.Enabled.FakeGens then ESP.applyFakeGens() end
 WindUI:Notify({Title="ESP",Content="Refreshed!",Duration=2})
 end)
 end})
 end)
end
do
 local tab = Tabs.Player
 pcall(function()
 local ss = tab:Section({Title="Stamina Control", Opened=true})
 ss:Toggle({Title=" Custom Stamina",Value=S.staminaCustomEnabled,Callback=function(v)
 pcall(function() S.staminaCustomEnabled=v; set("staminaCustomEnabled",v); if v then pcall(stam.apply) end end)
 end})
 ss:Toggle({Title="Disable Stamina Loss",Value=S.staminaLossDisabled,Callback=function(v)
 pcall(function() S.staminaLossDisabled=v; set("staminaLossDisabled",v); if S.staminaCustomEnabled then pcall(stam.apply) end end)
 end})
 ss:Slider({Title="Loss Rate",Value={Min=0,Max=50,Default=S.staminaLossValue},Step=1,Callback=function(v)
 pcall(function() S.staminaLossValue=(tonumber(v) or S.staminaLossValue); set("staminaLossValue",S.staminaLossValue); if S.staminaCustomEnabled then pcall(stam.apply) end end)
 end})
 ss:Slider({Title="Gain Rate",Value={Min=0,Max=50,Default=S.staminaGainValue},Step=1,Callback=function(v)
 pcall(function() S.staminaGainValue=(tonumber(v) or S.staminaGainValue); set("staminaGainValue",S.staminaGainValue); if S.staminaCustomEnabled then pcall(stam.apply) end end)
 end})
 ss:Slider({Title="Max Stamina",Value={Min=50,Max=500,Default=S.staminaMaxValue},Step=10,Callback=function(v)
 pcall(function() S.staminaMaxValue=(tonumber(v) or S.staminaMaxValue); set("staminaMaxValue",S.staminaMaxValue); if S.staminaCustomEnabled then pcall(stam.apply) end end)
 end})
 end)
end
do
 local tab = Tabs.World
 pcall(function()
 local sg = tab:Section({Title="Generator Solver", Opened=true})
 sg:Toggle({Title=" Auto Solve",Value=S.genFlowSolverEnabled,Callback=function(v)
 S.genFlowSolverEnabled=v; set("genFlowSolverEnabled",v)
 end})
 sg:Slider({Title="Node Speed",Value={Min=0.01,Max=0.5,Default=S.genFlowNodeDelay},Step=0.01,Callback=function(v)
 S.genFlowNodeDelay=(tonumber(v) or S.genFlowNodeDelay); set("genFlowNodeDelay",S.genFlowNodeDelay)
 end})
 sg:Slider({Title="Line Delay",Value={Min=0,Max=1,Default=S.genFlowLineDelay},Step=0.01,Callback=function(v)
 S.genFlowLineDelay=(tonumber(v) or S.genFlowLineDelay); set("genFlowLineDelay",S.genFlowLineDelay)
 end})
 end)
end
do
 local tab = Tabs.Music
 pcall(function()
 local opts = {}
 for name in pairs(LMS.tracks) do table.insert(opts, name) end
 table.sort(opts)
 local sl = tab:Section({Title="LMS Custom Music", Opened=true})
 sl:Toggle({Title=" Auto-Play LMS Music",Value=S.lmsAutoPlay,Callback=function(v)
 pcall(function()
 S.lmsAutoPlay=v; set("lmsAutoPlayEnabled",v)
 if v then LMS.go(); WindUI:Notify({Title="LMS",Content="Monitor started ",Icon="music",Duration=2})
 else LMS.halt(); WindUI:Notify({Title="LMS",Content="Disabled",Icon="music-off",Duration=2}) end
 end)
 end})
 sl:Dropdown({Title="Select Song",Values=opts,Value=S.lmsSelectedSong,Callback=function(v)
 pcall(function() 
  S.lmsSelectedSong=v
  set("selectedLMSSong",v)
 end)
 task.spawn(function() LMS.download(v) end)
 end})
 sl:Button({Title=" Play Now",Callback=function()
 pcall(function()
 if LMS.playNow() then WindUI:Notify({Title="LMS",Content="Now playing: "..S.lmsSelectedSong,Icon="music",Duration=3})
 else WindUI:Notify({Title="Error",Content="Sound not found",Icon="alert",Duration=3}) end
 end)
 end})
 sl:Button({Title=" Reset",Callback=function()
 pcall(function() LMS.reset(); WindUI:Notify({Title="LMS",Content="Reset",Icon="music-off",Duration=2}) end)
 end})
 end)
end
do
 local tab = Tabs.Config
 pcall(function()
 local st = tab:Section({Title=" Theme", Opened=true})
 st:Dropdown({
 Title="Theme",
 Values={"Dark","Light","Rose","Plant","Rainbow","Midnight","Violet",
 "CottonCandy","MonokaiPro","Indigo","Sky","Crimson","Amber","Emerald","Red"},
 Value=get("uiTheme","Dark"),
 Callback=function(t) pcall(function() WindUI:SetTheme(t); set("uiTheme",t) end) end
 })
 local sc = tab:Section({Title="Configuration", Opened=true})
 sc:Button({Title=" Save Config",Callback=function()
 pcall(function() writefile(cfgFile, HttpService:JSONEncode(cfgData)); WindUI:Notify({Title="Saved ",Duration=2}) end)
 end})
 sc:Button({Title=" Load Config",Callback=function()
 pcall(function()
 if false then WindUI:Notify({Title="Loaded ",Duration=2})
 else WindUI:Notify({Title="No config found",Duration=2}) end
 end)
 end})
 sc:Button({Title=" Reset Config",Callback=function()
 pcall(function()
 delfile(cfgFile); cfgData={}
 WindUI:Notify({Title="Config reset",Duration=2})
 end)
 end})
 end)
end
task.spawn(function()
 pcall(function()
 if not LocalPlayer.Character then LocalPlayer.CharacterAdded:Wait() end
 task.wait(1)
 task.spawn(sndBlock.setup)
 reloadAnim()
 if anim then hdt.setup(anim) end
 task.wait(1)
 task.spawn(TaphESP.setup)
 end)
end)
LocalPlayer.CharacterAdded:Connect(function()
 task.wait(0.5)
 pcall(function()
 task.spawn(sndBlock.setup)
 reloadAnim()
 if anim then hdt.setup(anim) end
 task.wait(1)
 pcall(ESP.init)
 end)
end)
LocalPlayer.OnTeleport:Connect(function()
 pcall(function() if S.lmsAutoPlay then LMS.halt() end end)
end)
task.wait(1)
WindUI:Notify({
Title="hub",Content="",Icon="box",Duration=3})