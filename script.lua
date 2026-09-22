-- ============================================================
-- VANTA Script v10.1 — оптимизация
-- один общий rescan вместо множества getgc
-- UpdateESP на 30 Hz
-- hookCasterFire под тумблером
-- ============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Camera = workspace.CurrentCamera
local lp = Players.LocalPlayer

local function NewDrawing(dtype, props)
    local d = Drawing.new(dtype)
    for k, v in pairs(props) do d[k] = v end
    return d
end

-- бенчмарк
local DEBUG_PERF = false
local function bench(name, fn)
    if not DEBUG_PERF then return fn() end
    local t0 = tick()
    local r = fn()
    local dt = (tick() - t0) * 1000
    if dt > 2 then print(string.format("[VANTA perf] %s: %.1f ms", name, dt)) end
    return r
end

print("[VANTA] loading v10.1 (optimized)...")

-- ============================================================
-- PEALLIB MENU
-- ============================================================
local repo = 'https://raw.githubusercontent.com/pealz1/PealLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local Window = Library:CreateWindow({
    Title = 'VANTA',
    Center = true,
    AutoShow = true,
})

local Tabs = {
    Visuals = Window:AddTab('Visuals'),
    Aim = Window:AddTab('Aim'),
    Misc = Window:AddTab('Misc'),
    Settings = Window:AddTab('Settings'),
}

-- ============================================================
-- VISUALS
-- ============================================================
local Visuals = Tabs.Visuals
local ESPBox = Visuals:AddLeftGroupbox('ESP')
ESPBox:AddToggle('ESP_Enabled',   { Text = 'Enable ESP',   Default = true, Callback = function(v) getgenv().ESP_Enabled = v end })
ESPBox:AddToggle('ESP_Box',       { Text = 'Box',          Default = true, Callback = function(v) getgenv().ESP_Box = v end })
ESPBox:AddToggle('ESP_Name',      { Text = 'Name',         Default = true, Callback = function(v) getgenv().ESP_Name = v end })
ESPBox:AddToggle('ESP_Team',      { Text = 'Team',         Default = true, Callback = function(v) getgenv().ESP_Team = v end })
ESPBox:AddToggle('ESP_Distance',  { Text = 'Distance',     Default = true, Callback = function(v) getgenv().ESP_Distance = v end })
ESPBox:AddToggle('ESP_Health',    { Text = 'Health Bar',   Default = true, Callback = function(v) getgenv().ESP_Health = v end })
ESPBox:AddToggle('ESP_Tracer',    { Text = 'Tracer',       Default = true, Callback = function(v) getgenv().ESP_Tracer = v end })
ESPBox:AddToggle('ESP_HeadDot',   { Text = 'Head Dot',     Default = true, Callback = function(v) getgenv().ESP_HeadDot = v end })
ESPBox:AddToggle('ESP_Highlight', { Text = 'Highlight',    Default = true, Callback = function(v) getgenv().ESP_Highlight = v end })
ESPBox:AddSlider('ESP_MaxDistance', { Text = 'Max Distance', Default = 500, Min = 100, Max = 2000, Rounding = 0, Callback = function(v) getgenv().ESP_MaxDistance = v end })

local FOVBox = Visuals:AddRightGroupbox('FOV')
FOVBox:AddToggle('FOV_Enabled', { Text = 'Enable FOV', Default = true, Callback = function(v) getgenv().FOV_Enabled = v end })
FOVBox:AddSlider('FOV_Default', { Text = 'Default FOV', Default = 90, Min = 30, Max = 120, Rounding = 0, Callback = function(v) getgenv().FOV_Default = v end })
FOVBox:AddSlider('FOV_Zoom',    { Text = 'Zoom FOV',    Default = 30, Min = 10, Max = 90,  Rounding = 0, Callback = function(v) getgenv().FOV_Zoom = v end })
FOVBox:AddLabel('Zoom Key'):AddKeyPicker('FOV_Key', { Default = 'Z', Mode = 'Hold', Text = 'Zoom', Callback = function(v) getgenv().FOV_Key = v end })

local FogBox = Visuals:AddRightGroupbox('No Fog')
FogBox:AddToggle('NoFog_Enabled',     { Text = 'Enable No Fog', Default = true, Callback = function(v) getgenv().NoFog_Enabled = v end })
FogBox:AddToggle('AntiFlash_Enabled', { Text = 'Anti-Flash',    Default = true, Callback = function(v) getgenv().AntiFlash_Enabled = v end })

-- ============================================================
-- AIM
-- ============================================================
local Aim = Tabs.Aim
local SilentBox = Aim:AddLeftGroupbox('Silent Aim')
SilentBox:AddToggle('Silent_Enabled',   { Text = 'Enable Silent', Default = true, Callback = function(v) getgenv().Silent_Enabled = v end })
SilentBox:AddSlider('Silent_FOV',       { Text = 'FOV',           Default = 125, Min = 30, Max = 360, Rounding = 0, Callback = function(v) getgenv().Silent_FOV = v end })
SilentBox:AddToggle('Silent_TeamCheck', { Text = 'Team Check',    Default = true, Callback = function(v) getgenv().Silent_TeamCheck = v end })
SilentBox:AddToggle('Silent_Wallbang',  { Text = 'Wallbang',      Default = true, Callback = function(v) getgenv().Silent_Wallbang = v end })
SilentBox:AddToggle('Silent_HookFire',  { Text = 'Hook caster.Fire (медленно)', Default = false, Callback = function(v) getgenv().Silent_HookFire = v end })

local RecoilBox = Aim:AddLeftGroupbox('No Recoil')
RecoilBox:AddToggle('NoRecoil_Enabled', { Text = 'Enable No Recoil', Default = true, Callback = function(v) getgenv().NoRecoil_Enabled = v end })

local FireBox = Aim:AddRightGroupbox('Rapid Fire')
FireBox:AddToggle('RapidFire_Enabled', { Text = 'Enable Rapid Fire', Default = true, Callback = function(v) getgenv().RapidFire_Enabled = v end })
FireBox:AddSlider('RapidFire_Rate',    { Text = 'Fire Rate', Default = 0.03, Min = 0.01, Max = 0.1, Rounding = 2, Callback = function(v) getgenv().RapidFire_Rate = v end })

local HitBox = Aim:AddRightGroupbox('Hitmarker')
HitBox:AddToggle('Hitmarker_Enabled',  { Text = 'Enable Hitmarker', Default = true, Callback = function(v) getgenv().Hitmarker_Enabled = v end })
HitBox:AddToggle('KillEffect_Enabled', { Text = 'Kill Effect',      Default = true, Callback = function(v) getgenv().KillEffect_Enabled = v end })

-- ============================================================
-- MISC
-- ============================================================
local Misc = Tabs.Misc
local ReloadBox = Misc:AddLeftGroupbox('Reload')
ReloadBox:AddToggle('InstantReload_Enabled', { Text = 'Instant Reload', Default = true, Callback = function(v) getgenv().InstantReload_Enabled = v end })

local FallBox = Misc:AddLeftGroupbox('Fall Damage')
FallBox:AddToggle('NoFallDamage_Enabled', { Text = 'No Fall Damage', Default = true, Callback = function(v) getgenv().NoFallDamage_Enabled = v end })

local WeaponBox = Misc:AddRightGroupbox('Weapon Info')
WeaponBox:AddToggle('WeaponInfo_Enabled', { Text = 'Show Weapon', Default = true, Callback = function(v) getgenv().WeaponInfo_Enabled = v end })

local PerfBox = Misc:AddRightGroupbox('Debug')
PerfBox:AddToggle('Perf_Enabled', { Text = 'Perf logging', Default = false, Callback = function(v) DEBUG_PERF = v; print("[VANTA] perf", v and "on" or "off") end })

-- ============================================================
-- SETTINGS
-- ============================================================
local SettingsTab = Tabs.Settings
local ConfigBox = SettingsTab:AddLeftGroupbox('Config')
ConfigBox:AddButton('Save Config',  function() Library:SaveConfig('vanta_config') end)
ConfigBox:AddButton('Load Config',  function() Library:LoadConfig('vanta_config') end)
ConfigBox:AddButton('Reset Config', function() Library:ResetConfig() end)

Library:OnUnload(function() print("[VANTA] unloaded") end)
print("[VANTA] menu loaded")

-- ============================================================
-- 1. CUSTOM FOV
-- ============================================================
do
    local currentFOV = 90
    local isWeaponZooming = false

    local function applyFOV()
        if not isWeaponZooming and getgenv().FOV_Enabled ~= false then
            Camera.FieldOfView = currentFOV
        end
    end

    local function watchWeapon(tool)
        if not tool or not tool:IsA("Tool") then return end
        isWeaponZooming = tool:GetAttribute("ADS") or tool:GetAttribute("isZoomed") or false
        applyFOV()
        tool:GetAttributeChangedSignal("ADS"):Connect(function()
            isWeaponZooming = tool:GetAttribute("ADS") or false
            if not isWeaponZooming then applyFOV() end
        end)
        tool:GetAttributeChangedSignal("isZoomed"):Connect(function()
            isWeaponZooming = tool:GetAttribute("isZoomed") or false
            if not isWeaponZooming then applyFOV() end
        end)
    end

    local function watchCharacter(char)
        if not char then return end
        for _, v in pairs(char:GetChildren()) do
            if v:IsA("Tool") then watchWeapon(v) end
        end
        char.ChildAdded:Connect(function(child)
            if child:IsA("Tool") then watchWeapon(child) end
        end)
        char.ChildRemoved:Connect(function(child)
            if child:IsA("Tool") then
                isWeaponZooming = false
                applyFOV()
            end
        end)
    end

    if lp.Character then watchCharacter(lp.Character) end
    lp.CharacterAdded:Connect(function(char)
        currentFOV = getgenv().FOV_Default or 90
        Camera.FieldOfView = currentFOV
        isWeaponZooming = false
        watchCharacter(char)
    end)

    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        local key = getgenv().FOV_Key or 'Z'
        if input.KeyCode == Enum.KeyCode[key] then
            Camera.FieldOfView = getgenv().FOV_Zoom or 30
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        local key = getgenv().FOV_Key or 'Z'
        if input.KeyCode == Enum.KeyCode[key] then applyFOV() end
    end)

    task.spawn(function()
        while true do
            task.wait(0.1)
            currentFOV = getgenv().FOV_Default or 90
            if not isWeaponZooming and Camera.FieldOfView ~= currentFOV
               and Camera.FieldOfView ~= (getgenv().FOV_Zoom or 30) then
                Camera.FieldOfView = currentFOV
            end
        end
    end)
    print("[VANTA] custom FOV loaded")
end

-- ============================================================
-- 2. NO FOG
-- ============================================================
do
    local function applyNoFog()
        if getgenv().NoFog_Enabled == false then return end
        pcall(function()
            Lighting.FogEnd = 100000
            Lighting.FogStart = 100000
            Lighting.FogColor = Color3.fromRGB(0, 0, 0)
            Lighting.Ambient = Color3.fromRGB(128, 128, 128)
            Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        end)
        for _, v in pairs(Lighting:GetChildren()) do
            if v:IsA("Atmosphere") then
                pcall(function() v.Density = 0; v.Haze = 0; v.Glare = 0 end)
            elseif v:IsA("BlurEffect") then
                pcall(function() v.Size = 0 end)
            elseif v:IsA("ColorCorrectionEffect") then
                pcall(function() v.Brightness = 0; v.Contrast = 0; v.Saturation = 0 end)
            elseif v:IsA("SunRaysEffect") then
                pcall(function() v.Intensity = 0 end)
            end
        end
    end

    applyNoFog()
    Lighting:GetPropertyChangedSignal("FogEnd"):Connect(applyNoFog)
    Lighting:GetPropertyChangedSignal("FogStart"):Connect(applyNoFog)
    Lighting:GetPropertyChangedSignal("FogColor"):Connect(applyNoFog)
    Lighting.ChildAdded:Connect(applyNoFog)
    Lighting.ChildRemoved:Connect(applyNoFog)
    lp.CharacterAdded:Connect(applyNoFog)

    task.spawn(function()
        while true do task.wait(1); pcall(applyNoFog) end
    end)
    print("[VANTA] no fog loaded")
end

-- ============================================================
-- ОБЩИЙ РЕЕСТР ДЛЯ RESCAN
-- ============================================================
local REG = {
    silentHookedCasters = {},   -- [caster] = true
    casterToInstance    = {},   -- [caster] = t_8
    hookedFire          = {},   -- [caster] = true
    recoilTables        = {},   -- [obj] = true
    rapidSettings       = {},   -- [obj] = true
    gunInstances        = {},   -- [obj] = true
    hitHookedCasters    = {},   -- [caster] = true
}

-- ============================================================
-- 3. UTIL-ФУНКЦИИ, ОБЩИЕ ДЛЯ МОДУЛЕЙ
-- ============================================================
local function isEnemy(plr)
    if not lp.Team or not plr.Team then return true end
    return plr.Team ~= lp.Team
end

local function asPart(inst)
    if not inst then return nil end
    if inst:IsA("BasePart") then return inst end
    if inst:IsA("Attachment") and inst.Parent and inst.Parent:IsA("BasePart") then
        return inst.Parent
    end
    return nil
end

local function isSCP(plr)
    if plr.Team and plr.Team.Name == "SCP" then return true end
    local char = plr.Character
    if not char then return false end
    if char:FindFirstChild("Body") and char:FindFirstChild("Mask") then return true end
    if char:FindFirstChild("Matthew") then return true end
    if char:FindFirstChild("SCP") then return true end
    if char:FindFirstChild("Collisions") and char.Collisions:FindFirstChild("spine") then return true end
    for _, v in pairs(char:GetChildren()) do
        if v:IsA("MeshPart") then
            local n = v.Name:lower()
            if n:find("cube") or n:find("scp939") or n:find("neutre") then return true end
        end
    end
    return false
end

local function getHitPart(plr)
    local char = plr.Character
    if not char then return nil end
    if isSCP(plr) then
        local collisions = char:FindFirstChild("Collisions")
        if collisions then
            local headCol = asPart(collisions:FindFirstChild("Head"))
            if headCol then return headCol end
        end
        local fp = asPart(char:FindFirstChild("FacePoint"));  if fp then return fp end
        local h  = asPart(char:FindFirstChild("Head"));       if h  then return h  end
        local ut = asPart(char:FindFirstChild("UpperTorso")); if ut then return ut end
        local sp = collisions and asPart(collisions:FindFirstChild("spine")); if sp then return sp end
        local mt = asPart(char:FindFirstChild("Matthew"));    if mt then return mt end
        local bd = asPart(char:FindFirstChild("Body"));       if bd then return bd end
        local mk = asPart(char:FindFirstChild("Mask"));       if mk then return mk end
    else
        local h  = asPart(char:FindFirstChild("Head"));       if h  then return h  end
        local ut = asPart(char:FindFirstChild("UpperTorso")); if ut then return ut end
    end
    return nil
end

-- ============================================================
-- 4. SILENT AIM + WALLBANG
-- ============================================================
do
    local cachedTarget, cachedTargetTime = nil, 0

    local function hasLineOfSight(part)
        local origin = Camera.CFrame.Position
        local direction = part.Position - origin
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = { lp.Character, Camera }
        local result = workspace:Raycast(origin, direction, params)
        if not result then return true end
        return result.Instance == part or result.Instance:IsDescendantOf(part.Parent)
    end

    local function getTargetPart()
        if getgenv().Silent_Enabled == false then return nil end
        local now = tick()
        if cachedTarget and now - cachedTargetTime < 0.02 then
            if cachedTarget.Parent and cachedTarget.Parent.Parent then
                return cachedTarget
            end
            cachedTarget = nil
        end
        local fov = getgenv().Silent_FOV or 125
        local wallbang = getgenv().Silent_Wallbang ~= false
        local closest, shortest = nil, fov
        local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        for _, plr in pairs(Players:GetPlayers()) do
            if plr == lp then continue end
            if not isEnemy(plr) then continue end
            local char = plr.Character
            if not char then continue end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum or hum.Health <= 0 then continue end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then continue end
            local rootScreen, rootOn = Camera:WorldToViewportPoint(root.Position)
            if not rootOn then continue end
            local rootDist = (Vector2.new(rootScreen.X, rootScreen.Y) - center).Magnitude
            if rootDist > fov + 100 then continue end
            local part = getHitPart(plr)
            if not part then continue end
            if not wallbang and not hasLineOfSight(part) then continue end
            local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
            if not onScreen then continue end
            local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
            if dist < shortest then shortest = dist; closest = part end
        end
        cachedTarget = closest
        cachedTargetTime = now
        return closest
    end

    local function buildSyntheticResult(target, origin)
        local pos = target.Position
        local dir = pos - origin
        return {
            Instance = target,
            Position = pos,
            Normal   = -dir.Unit,
            Distance = dir.Magnitude,
            Material = Enum.Material.Plastic,
        }
    end

    local function delegateField(conn)
        if type(conn.Delegate) == "function" then return "Delegate" end
        if type(conn.func)     == "function" then return "func" end
        if type(conn._func)    == "function" then return "_func" end
        if type(conn.callback) == "function" then return "callback" end
        return nil
    end

    local function buildDelegate(oldDelegate, caster)
        return function(self, rayResult, velocity, bullet, id)
            local target = getTargetPart()
            if target then
                local inst = REG.casterToInstance[caster]
                local origin
                if inst and inst.firePoint and inst.firePoint.WorldPosition then
                    origin = inst.firePoint.WorldPosition
                else
                    origin = Camera.CFrame.Position
                end
                local synthetic = buildSyntheticResult(target, origin)
                return oldDelegate(self, synthetic, velocity, bullet, id)
            end
            return oldDelegate(self, rayResult, velocity, bullet, id)
        end
    end

    local function hookCasterFire(caster)
        if REG.hookedFire[caster] then return end
        if getgenv().Silent_HookFire ~= true then return end
        if type(hookfunction) ~= "function" then return end
        local fireFn = caster.Fire
        if type(fireFn) ~= "function" then return end
        local ok = pcall(function()
            local oldFire = fireFn
            caster.Fire = hookfunction(fireFn, function(self, origin, direction, maxDist, behavior, bulletId)
                local target = getTargetPart()
                if target and origin then
                    direction = (target.Position - origin).Unit
                end
                return oldFire(self, origin, direction, maxDist, behavior, bulletId)
            end)
        end)
        if ok then REG.hookedFire[caster] = true end
    end

    -- вызывается из общего rescan; obj = элемент getgc(true)
    local function tryHookCasterFromObj(obj)
        if type(obj) ~= "table" then return end
        local caster = rawget(obj, "caster")
        if not caster then return end
        REG.casterToInstance[caster] = obj

        if not REG.silentHookedCasters[caster] then
            local rayHit = caster.RayHit
            if rayHit and rayHit.Connections then
                local hooked = false
                for _, conn in ipairs(rayHit.Connections) do
                    local field = delegateField(conn)
                    if field and not conn._vantaHooked then
                        local old = conn[field]
                        conn[field] = buildDelegate(old, caster)
                        conn._vantaHooked = true
                        hooked = true
                    end
                end
                if hooked then REG.silentHookedCasters[caster] = true end
            end
        end

        pcall(hookCasterFire, caster)
    end

    -- экспорт в общий rescan
    _G.__vanta_tryHookCaster = tryHookCasterFromObj
    _G.__vanta_getTargetPart = getTargetPart
    print("[VANTA] silent + wallbang loaded")
end

-- ============================================================
-- 5. ESP — 30 Hz
-- ============================================================
do
    local espCache = {}

    local function getTeamColor(plr)
        if not isEnemy(plr) then return Color3.fromRGB(60, 255, 60) end
        return Color3.fromRGB(255, 60, 60)
    end

    local function CreateHighlight(char)
        if getgenv().ESP_Highlight == false then return nil end
        local ok, hl = pcall(function()
            local h = Instance.new("Highlight")
            h.Name = "VantaPlayerESP"
            h.FillTransparency = 0.7
            h.OutlineTransparency = 0.2
            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            h.Adornee = char
            h.Parent = char
            return h
        end)
        return ok and hl or nil
    end

    local function CreateESP(plr)
        if espCache[plr] then return espCache[plr] end
        local data = {
            L1 = NewDrawing("Line", { Thickness=1, Visible=false }),
            L2 = NewDrawing("Line", { Thickness=1, Visible=false }),
            L3 = NewDrawing("Line", { Thickness=1, Visible=false }),
            L4 = NewDrawing("Line", { Thickness=1, Visible=false }),
            C1 = NewDrawing("Line", { Thickness=2, Visible=false }),
            C2 = NewDrawing("Line", { Thickness=2, Visible=false }),
            C3 = NewDrawing("Line", { Thickness=2, Visible=false }),
            C4 = NewDrawing("Line", { Thickness=2, Visible=false }),
            TopBar = NewDrawing("Line", { Thickness=2, Visible=false }),
            HpBg   = NewDrawing("Line", { Thickness=5, Color=Color3.fromRGB(0,0,0),   Visible=false }),
            HpFill = NewDrawing("Line", { Thickness=4, Color=Color3.fromRGB(0,255,0), Visible=false }),
            Name = NewDrawing("Text", { Size=13, Center=true, Outline=true, Visible=false }),
            Team = NewDrawing("Text", { Size=11, Center=true, Outline=true, Visible=false }),
            Dist = NewDrawing("Text", { Size=11, Center=true, Outline=true, Visible=false }),
            Tracer  = NewDrawing("Line",   { Thickness=1, Visible=false }),
            HeadDot = NewDrawing("Circle", { Thickness=1, Filled=true, NumSides=16, Radius=3, Visible=false }),
            Highlight = nil,
            LastColor = nil,
        }
        espCache[plr] = data
        return data
    end

    local KEYS = {"L1","L2","L3","L4","C1","C2","C3","C4","TopBar","HpBg","HpFill","Name","Team","Dist","Tracer","HeadDot"}

    local function HideESP(data)
        for _, k in ipairs(KEYS) do data[k].Visible = false end
        if data.Highlight then data.Highlight.Enabled = false end
    end

    local function DestroyESP(data)
        if not data then return end
        for _, k in ipairs(KEYS) do
            if data[k] then pcall(function() data[k]:Remove() end) end
        end
        if data.Highlight then pcall(function() data.Highlight:Destroy() end) end
    end

    local function UpdateESP()
        if getgenv().ESP_Enabled == false then
            for _, data in pairs(espCache) do HideESP(data) end
            return
        end
        local vp = Camera.ViewportSize
        local maxDist = getgenv().ESP_MaxDistance or 500
        for plr, data in pairs(espCache) do
            if plr == lp then HideESP(data) continue end
            local char = plr.Character
            local hum  = char and char:FindFirstChildOfClass("Humanoid")
            if not char or not hum or hum.Health <= 0 or not char.Parent then HideESP(data) continue end
            if not isEnemy(plr) then HideESP(data) continue end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then HideESP(data) continue end
            local rootScreen, rootOn = Camera:WorldToViewportPoint(root.Position)
            local distance = (Camera.CFrame.Position - root.Position).Magnitude
            if not rootOn or distance > maxDist then HideESP(data) continue end

            local hipHeight = hum.HipHeight > 0 and hum.HipHeight or 2.5
            local topPos    = Camera:WorldToViewportPoint(root.Position + Vector3.new(0, hipHeight + 1.5, 0))
            local bottomPos = Camera:WorldToViewportPoint(root.Position + Vector3.new(0, -hipHeight, 0))
            local height  = math.max(math.abs(bottomPos.Y - topPos.Y), 20)
            local width   = height * 0.55
            local centerX = rootScreen.X
            local x = centerX - width/2
            local y = topPos.Y
            local color = getTeamColor(plr)
            if data.LastColor ~= color then
                data.LastColor = color
                for _, k in ipairs({"L1","L2","L3","L4","C1","C2","C3","C4","TopBar","Tracer"}) do
                    data[k].Color = color
                end
                data.HeadDot.Color = Color3.fromRGB(255, 255, 255)
            end
            if getgenv().ESP_Box ~= false then
                local cl = math.floor(width * 0.25)
                local cs = math.floor(height * 0.25)
                data.C1.From = Vector2.new(x,y);              data.C1.To = Vector2.new(x+cl,y)
                data.C2.From = Vector2.new(x,y);              data.C2.To = Vector2.new(x,y+cs)
                data.C3.From = Vector2.new(x+width,y);        data.C3.To = Vector2.new(x+width-cl,y)
                data.C4.From = Vector2.new(x+width,y);        data.C4.To = Vector2.new(x+width,y+cs)
                data.L1.From = Vector2.new(x,y+height);       data.L1.To = Vector2.new(x+cl,y+height)
                data.L2.From = Vector2.new(x,y+height);       data.L2.To = Vector2.new(x,y+height-cs)
                data.L3.From = Vector2.new(x+width,y+height); data.L3.To = Vector2.new(x+width-cl,y+height)
                data.L4.From = Vector2.new(x+width,y+height); data.L4.To = Vector2.new(x+width,y+height-cs)
                for _, k in ipairs({"L1","L2","L3","L4","C1","C2","C3","C4"}) do data[k].Visible = true end
                data.TopBar.From = Vector2.new(x - 2, y - 1)
                data.TopBar.To = Vector2.new(x + width + 2, y - 1)
                data.TopBar.Visible = true
            end
            if getgenv().ESP_Tracer ~= false then
                data.Tracer.From = Vector2.new(vp.X/2, vp.Y)
                data.Tracer.To = Vector2.new(bottomPos.X, bottomPos.Y)
                data.Tracer.Visible = true
            else data.Tracer.Visible = false end
            if getgenv().ESP_HeadDot ~= false then
                local head = char:FindFirstChild("Head")
                if head and head:IsA("BasePart") then
                    local hp, hs = Camera:WorldToViewportPoint(head.Position)
                    if hs then
                        data.HeadDot.Position = Vector2.new(hp.X, hp.Y)
                        data.HeadDot.Visible = true
                    else data.HeadDot.Visible = false end
                else data.HeadDot.Visible = false end
            end
            if getgenv().ESP_Name ~= false then
                data.Name.Text = plr.Name
                data.Name.Position = Vector2.new(centerX, y - 30)
                data.Name.Color = Color3.fromRGB(255, 255, 255)
                data.Name.Visible = true
            else data.Name.Visible = false end
            if getgenv().ESP_Team ~= false then
                data.Team.Text = plr.Team and plr.Team.Name or "?"
                data.Team.Position = Vector2.new(centerX, y - 18)
                data.Team.Color = color
                data.Team.Visible = true
            else data.Team.Visible = false end
            if getgenv().ESP_Distance ~= false then
                data.Dist.Text = string.format("[%.0fm]", distance)
                data.Dist.Position = Vector2.new(centerX, y + height + 3)
                data.Dist.Color = Color3.fromRGB(180, 180, 180)
                data.Dist.Visible = true
            else data.Dist.Visible = false end
            if getgenv().ESP_Health ~= false then
                local maxHp = hum.MaxHealth > 0 and hum.MaxHealth or 100
                local hpRatio = math.clamp(hum.Health/maxHp, 0, 1)
                local barX = x - 8
                data.HpBg.From = Vector2.new(barX, y)
                data.HpBg.To = Vector2.new(barX, y + height)
                data.HpBg.Color = Color3.fromRGB(0,0,0)
                data.HpBg.Visible = true
                local fillH = height * hpRatio
                data.HpFill.From = Vector2.new(barX, y + height)
                data.HpFill.To = Vector2.new(barX, y + height - fillH)
                data.HpFill.Color = Color3.fromRGB(math.floor(255*(1-hpRatio)), math.floor(255*hpRatio), 0)
                data.HpFill.Visible = true
            else
                data.HpBg.Visible = false
                data.HpFill.Visible = false
            end
            if not data.Highlight then data.Highlight = CreateHighlight(char) end
            if data.Highlight then
                data.Highlight.FillColor = color
                data.Highlight.OutlineColor = color
                data.Highlight.Adornee = char
                data.Highlight.Enabled = true
            end
        end
    end

    local function AttachPlayer(plr)
        if plr == lp then return end
        CreateESP(plr)
        local function dropHL()
            local data = espCache[plr]
            if data and data.Highlight then
                pcall(function() data.Highlight:Destroy() end)
                data.Highlight = nil
            end
        end
        plr.CharacterAdded:Connect(dropHL)
        plr.CharacterRemoving:Connect(dropHL)
    end

    for _, plr in pairs(Players:GetPlayers()) do AttachPlayer(plr) end
    Players.PlayerAdded:Connect(AttachPlayer)
    Players.PlayerRemoving:Connect(function(plr)
        local data = espCache[plr]
        if data then DestroyESP(data); espCache[plr] = nil end
    end)

    -- отдельный поток 30 Hz, не RenderStepped
    task.spawn(function()
        while true do
            task.wait(1/30)
            pcall(UpdateESP)
        end
    end)
    print("[VANTA] player ESP loaded (30 Hz)")
end

-- ============================================================
-- 6. NO RECOIL — только через общий rescan
-- ============================================================
do
    local SAFE_RECOIL = {1, 0, 0, 0.5, 1}

    local function clearOne(obj)
        local rp = rawget(obj, "recoilPattern")
        if type(rp) ~= "table" then return end
        for i = #rp, 1, -1 do rp[i] = nil end
        rp[1] = {table.unpack(SAFE_RECOIL)}
        if rawget(obj, "curshots") ~= nil then obj.curshots = 0 end
    end

    -- вызывается из общего rescan
    local function tryRecoilFromObj(obj)
        if type(obj) ~= "table" then return end
        local rp = rawget(obj, "recoilPattern")
        if type(rp) ~= "table" or #rp == 0 then return end
        if type(rawget(obj, "settings")) ~= "table" then return end
        if rawget(obj, "gunTool") == nil then return end
        REG.recoilTables[obj] = true
        clearOne(obj)
    end

    _G.__vanta_tryRecoil = tryRecoilFromObj

    -- периодически чистим уже известные таблицы
    task.spawn(function()
        while true do
            task.wait(1)
            if getgenv().NoRecoil_Enabled ~= false then
                for obj in pairs(REG.recoilTables) do
                    if type(obj) == "table" then clearOne(obj)
                    else REG.recoilTables[obj] = nil end
                end
            end
        end
    end)
    print("[VANTA] norecoil loaded")
end

-- ============================================================
-- 7. RAPID FIRE — только через общий rescan
-- ============================================================
do
    local function patch(t)
        local rate = getgenv().RapidFire_Rate or 0.03
        for k in pairs(t) do
            if tostring(k):lower() == "firerate" then t[k] = rate end
        end
    end

    local function tryRapidFromObj(obj)
        if type(obj) ~= "table" then return end
        local hasFR, hasDmg, hasFM = false, false, false
        for k in pairs(obj) do
            local n = tostring(k):lower()
            if n == "firerate" then hasFR = true end
            if n == "damage"   then hasDmg = true end
            if n == "firemode" then hasFM  = true end
        end
        if hasFR and hasDmg and hasFM then
            REG.rapidSettings[obj] = true
            patch(obj)
        end
    end

    _G.__vanta_tryRapid = tryRapidFromObj

    task.spawn(function()
        while true do
            task.wait(5)
            if getgenv().RapidFire_Enabled ~= false then
                for obj in pairs(REG.rapidSettings) do
                    if type(obj) == "table" then patch(obj)
                    else REG.rapidSettings[obj] = nil end
                end
            end
        end
    end)
    print("[VANTA] rapidfire loaded")
end

-- ============================================================
-- 8. HITMARKER + KILL EFFECT — через общий rescan
-- ============================================================
do
    local lines = {}
    for i = 1, 4 do
        lines[i] = Drawing.new("Line")
        lines[i].Thickness = 1.5
        lines[i].Color = Color3.fromRGB(255, 255, 255)
        lines[i].Visible = false
    end

    local killText    = NewDrawing("Text", { Size=24, Center=true, Outline=true,  Color=Color3.fromRGB(255,50,50), Visible=false })
    local killOutline = NewDrawing("Text", { Size=26, Center=true, Outline=false, Color=Color3.fromRGB(0,0,0),     Visible=false })
    local flashLines = {}
    for i = 1, 4 do
        flashLines[i] = Drawing.new("Line")
        flashLines[i].Thickness = 4
        flashLines[i].Color = Color3.fromRGB(255, 0, 0)
        flashLines[i].Visible = false
    end

    local activeHit, activeKill = {}, {}

    local function ShowHitmarker(isHeadshot, isKill)
        if getgenv().Hitmarker_Enabled == false then return end
        local color = Color3.fromRGB(255, 255, 255)
        if isKill then color = Color3.fromRGB(255, 200, 0)
        elseif isHeadshot then color = Color3.fromRGB(255, 50, 50) end
        local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        local gap, size = 4, 10
        lines[1].From = Vector2.new(center.X-gap-size, center.Y-gap-size); lines[1].To = Vector2.new(center.X-gap, center.Y-gap)
        lines[2].From = Vector2.new(center.X+gap, center.Y-gap);           lines[2].To = Vector2.new(center.X+gap+size, center.Y-gap-size)
        lines[3].From = Vector2.new(center.X-gap-size, center.Y+gap+size); lines[3].To = Vector2.new(center.X-gap, center.Y+gap)
        lines[4].From = Vector2.new(center.X+gap, center.Y+gap);           lines[4].To = Vector2.new(center.X+gap+size, center.Y+gap+size)
        for i = 1, 4 do lines[i].Color = color; lines[i].Visible = true end
        table.insert(activeHit, { startTime = tick() })
    end

    local function triggerKillEffect()
        if getgenv().KillEffect_Enabled == false then return end
        local vp = Camera.ViewportSize
        local center = Vector2.new(vp.X / 2, vp.Y / 2)
        killText.Text = "KILL"; killText.Position = center; killText.Visible = true
        killOutline.Text = "KILL"; killOutline.Position = center; killOutline.Visible = true
        flashLines[1].From = Vector2.new(0, 0);   flashLines[1].To = Vector2.new(vp.X, 0)
        flashLines[2].From = Vector2.new(vp.X, 0); flashLines[2].To = Vector2.new(vp.X, vp.Y)
        flashLines[3].From = Vector2.new(vp.X, vp.Y); flashLines[3].To = Vector2.new(0, vp.Y)
        flashLines[4].From = Vector2.new(0, vp.Y); flashLines[4].To = Vector2.new(0, 0)
        for i = 1, 4 do flashLines[i].Visible = true end
        local snd = Instance.new("Sound")
        snd.SoundId = "rbxassetid://131961136"
        snd.Volume = 1
        snd.Parent = game:GetService("SoundService")
        snd:Play()
        task.delay(2, function() snd:Destroy() end)
        table.insert(activeKill, { startTime = tick() })
    end

    RunService.RenderStepped:Connect(function()
        local now = tick()
        local anyHit = false
        for i = #activeHit, 1, -1 do
            if now - activeHit[i].startTime >= 0.15 then table.remove(activeHit, i)
            else anyHit = true end
        end
        if not anyHit then for i = 1, 4 do lines[i].Visible = false end end
        for i = #activeKill, 1, -1 do
            local k = activeKill[i]
            local progress = (now - k.startTime) / 0.6
            if progress >= 1 then
                killText.Visible = false
                killOutline.Visible = false
                for j = 1, 4 do flashLines[j].Visible = false end
                table.remove(activeKill, i)
            else
                killText.Transparency = progress
                killOutline.Transparency = progress
                killText.Size = 24 + math.floor(progress * 10)
                killOutline.Size = 26 + math.floor(progress * 10)
            end
        end
    end)

    local lastHit = 0

    local function isEnemyChar(char)
        local plr = Players:GetPlayerFromCharacter(char)
        if not plr or plr == lp then return false end
        if not lp.Team or not plr.Team then return true end
        return plr.Team ~= lp.Team
    end

    local function tryHitHooksFromObj(obj)
        if type(obj) ~= "table" then return end
        local caster = rawget(obj, "caster")
        if not caster then return end
        if REG.hitHookedCasters[caster] then return end
        if not caster.RayHit then return end
        REG.hitHookedCasters[caster] = true
        caster.RayHit:Connect(function(_, rayResult)
            if not rayResult or not rayResult.Instance then return end
            local hitPart = rayResult.Instance
            local char = hitPart:FindFirstAncestorWhichIsA("Model")
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum or not isEnemyChar(char) then return end
            local now = tick()
            if now - lastHit < 0.05 then return end
            lastHit = now
            ShowHitmarker(hitPart.Name == "Head", hum.Health <= 0)
            if hum.Health <= 0 then triggerKillEffect() end
        end)
    end

    _G.__vanta_tryHitHooks = tryHitHooksFromObj
    print("[VANTA] hitmarker + kill effect loaded")
end

-- ============================================================
-- 9. NO FALL DAMAGE
-- ============================================================
do
    local disabledChars = {}
    local function disableFallDamage(char)
        if not char or disabledChars[char] then return end
        local fd = char:FindFirstChild("FallDamage")
        if fd and fd:IsA("LocalScript") then
            fd.Disabled = true
            disabledChars[char] = true
        end
    end
    local function watchCharacter(char)
        if not char then return end
        task.wait(0.3)
        disableFallDamage(char)
        char.ChildAdded:Connect(function(child)
            if child.Name == "FallDamage" and child:IsA("LocalScript") then
                child.Disabled = true
                disabledChars[char] = true
            end
        end)
    end
    if lp.Character then watchCharacter(lp.Character) end
    lp.CharacterAdded:Connect(watchCharacter)
    lp.CharacterRemoving:Connect(function(char) disabledChars[char] = nil end)
    print("[VANTA] no fall damage loaded")
end

-- ============================================================
-- 10. INSTANT RELOAD — через общий rescan
-- ============================================================
do
    local lastReload = 0
    local reloadingNow = false

    local function getReloadMethod(gun)
        local mt = getmetatable(gun)
        if mt and type(mt.__index) == "table" then
            local m = rawget(mt.__index, "Reload")
            if type(m) == "function" then return m end
        end
        return rawget(gun, "Reload")
    end

    local function tryGunFromObj(obj)
        if type(obj) ~= "table" then return end
        local settings = rawget(obj, "settings")
        local gunTool  = rawget(obj, "gunTool")
        if type(settings) == "table" and typeof(gunTool) == "Instance" then
            REG.gunInstances[obj] = true
        end
    end

    _G.__vanta_tryGun = tryGunFromObj

    task.spawn(function()
        while true do
            task.wait(0.25)
            if getgenv().InstantReload_Enabled ~= false and not reloadingNow then
                local now = tick()
                if now - lastReload >= 0.2 then
                    for gun in pairs(REG.gunInstances) do
                        local settings = rawget(gun, "settings")
                        local gunTool  = rawget(gun, "gunTool")
                        if type(settings) ~= "table" or typeof(gunTool) ~= "Instance" then
                            REG.gunInstances[gun] = nil
                            continue
                        end
                        local mag = gunTool:GetAttribute("CurrentMagazineCount") or settings.CurrentMagazineCount
                        if type(mag) == "number" and mag <= 1 and not gun.reloading and not gun.unloading then
                            local reloadFn = getReloadMethod(gun)
                            if reloadFn then
                                lastReload = now
                                reloadingNow = true
                                task.spawn(function()
                                    local wasEquipping = gun.equipping
                                    gun.equipping = false
                                    pcall(reloadFn, gun)
                                    gun.equipping = wasEquipping
                                    task.wait(2)
                                    reloadingNow = false
                                end)
                            end
                        end
                    end
                end
            end
        end
    end)
    print("[VANTA] instant reload loaded")
end

-- ============================================================
-- 11. ANTI-FLASH
-- ============================================================
do
    local function tryHide(obj)
        if getgenv().AntiFlash_Enabled == false then return end
        if not (obj:IsA("ImageLabel") or obj:IsA("Frame") or obj:IsA("TextLabel")) then return end
        local n = obj.Name:lower()
        if n:find("flash") or n:find("blind") or n:find("white")
           or n:find("blackout") or n:find("black") then
            obj.Visible = false
        end
    end

    task.spawn(function()
        while true do
            task.wait(1)
            local pg = lp:FindFirstChildOfClass("PlayerGui")
            if pg then
                pg.DescendantAdded:Connect(tryHide)
                for _, v in pairs(pg:GetDescendants()) do tryHide(v) end
                break
            end
        end
    end)
    print("[VANTA] anti-flash loaded")
end

-- ============================================================
-- 12. WEAPON INFO — 10 Hz
-- ============================================================
do
    local weaponTexts = {}

    local function createText(plr)
        if weaponTexts[plr] then return weaponTexts[plr] end
        weaponTexts[plr] = NewDrawing("Text", {
            Size = 11, Center = true, Outline = true,
            Color = Color3.fromRGB(255, 200, 100), Visible = false,
        })
        return weaponTexts[plr]
    end

    local function update()
        if getgenv().WeaponInfo_Enabled == false then
            for _, t in pairs(weaponTexts) do t.Visible = false end
            return
        end
        for plr, text in pairs(weaponTexts) do
            if plr == lp or not plr.Character then text.Visible = false continue end
            if not isEnemy(plr) then text.Visible = false continue end
            local char = plr.Character
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum or hum.Health <= 0 then text.Visible = false continue end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then text.Visible = false continue end
            local dist = (Camera.CFrame.Position - root.Position).Magnitude
            if dist > 300 then text.Visible = false continue end
            local screenPos, onScreen = Camera.WorldToViewportPoint(Camera, root.Position + Vector3.new(0, 2, 0))
            if not onScreen or screenPos.Z < 0 then text.Visible = false continue end
            local tool = char:FindFirstChildOfClass("Tool")
            if not tool then text.Visible = false continue end
            text.Text = tool.Name
            text.Position = Vector2.new(screenPos.X, screenPos.Y + 50)
            text.Visible = true
        end
    end

    local function attach(plr)
        if plr == lp then return end
        createText(plr)
    end

    for _, plr in pairs(Players:GetPlayers()) do attach(plr) end
    Players.PlayerAdded:Connect(attach)
    Players.PlayerRemoving:Connect(function(plr)
        if weaponTexts[plr] then
            pcall(function() weaponTexts[plr]:Remove() end)
            weaponTexts[plr] = nil
        end
    end)

    task.spawn(function()
        while true do task.wait(0.1); pcall(update) end
    end)
    print("[VANTA] weapon info loaded")
end

-- ============================================================
-- ОБЩИЙ RESCAN — один getgc на все модули
-- ============================================================
do
    -- триггер немедленного rescan (при смене Tool)
    local rescanNow = false
    local function triggerRescan()
        rescanNow = true
    end

    local function onToolChanged(child)
        if child:IsA("Tool") then
            task.wait(0.3)
            triggerRescan()
        end
    end

    if lp.Character then
        lp.Character.ChildAdded:Connect(onToolChanged)
        lp.Character.ChildRemoved:Connect(onToolChanged)
    end
    if lp.Backpack then
        lp.Backpack.ChildAdded:Connect(onToolChanged)
    end
    lp.CharacterAdded:Connect(function(char)
        char.ChildAdded:Connect(onToolChanged)
        char.ChildRemoved:Connect(onToolChanged)
        task.wait(1)
        triggerRescan()
    end)
    lp.ChildAdded:Connect(function(child)
        if child.Name == "Backpack" then
            child.ChildAdded:Connect(onToolChanged)
        end
    end)

    -- основной цикл rescan
    task.spawn(function()
        -- первый проход сразу
        local function doRescan()
            bench("rescan", function()
                for _, obj in pairs(getgc(true)) do
                    if _G.__vanta_tryHookCaster then pcall(_G.__vanta_tryHookCaster, obj) end
                    if _G.__vanta_tryRecoil     then pcall(_G.__vanta_tryRecoil,     obj) end
                    if _G.__vanta_tryRapid      then pcall(_G.__vanta_tryRapid,      obj) end
                    if _G.__vanta_tryGun        then pcall(_G.__vanta_tryGun,        obj) end
                    if _G.__vanta_tryHitHooks   then pcall(_G.__vanta_tryHitHooks,   obj) end
                end
            end)
        end

        doRescan()
        print("[VANTA] initial rescan done")

        while true do
            task.wait(5)
            if rescanNow then
                rescanNow = false
                doRescan()
            else
                doRescan()
            end
        end
    end)
    print("[VANTA] unified rescan loaded")
end

-- ============================================================
-- WATERMARK
-- ============================================================
do
    local watermark = Drawing.new("Text")
    watermark.Text = "VANTA v10.1"
    watermark.Size = 14
    watermark.Color = Color3.fromRGB(255, 255, 255)
    watermark.Outline = true
    watermark.Position = Vector2.new(0, 10)
    watermark.Visible = true
    watermark.Center = false
    RunService.RenderStepped:Connect(function()
        local vp = Camera.ViewportSize
        watermark.Position = Vector2.new(vp.X - 90, 10)
    end)
    print("[VANTA] watermark loaded")
end

print("[VANTA] all loaded v10.1")
