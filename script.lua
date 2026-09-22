-- ============================================================
-- VANTA Script v14
-- Do not redistribute without credit
-- ============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local Stats = game:GetService("Stats")
local Camera = workspace.CurrentCamera
local lp = Players.LocalPlayer

local Debug = false
local function log(...) if Debug then print("[VANTA]", ...) end end

local function NewDrawing(dtype, props)
    local d = Drawing.new(dtype)
    for k, v in pairs(props) do d[k] = v end
    return d
end

log("loading v14...")

-- ============================================================
-- PEALLIB MENU
-- ============================================================
local repo = 'https://raw.githubusercontent.com/pealz1/PealLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local Window = Library:CreateWindow({ Title = 'VANTA', Center = true, AutoShow = true })

local Tabs = {
    Visuals = Window:AddTab('Visuals'),
    Aim = Window:AddTab('Aim'),
    Misc = Window:AddTab('Misc'),
    Settings = Window:AddTab('Settings'),
}

-- VISUALS
local Visuals = Tabs.Visuals
local ESPBox = Visuals:AddLeftGroupbox('ESP')
ESPBox:AddToggle('ESP_Enabled', { Text = 'Enable ESP', Default = true, Callback = function(v) getgenv().ESP_Enabled = v end })
ESPBox:AddToggle('ESP_Chams', { Text = 'Chams (Bones)', Default = true, Callback = function(v) getgenv().ESP_Chams = v end })
ESPBox:AddToggle('ESP_Box', { Text = 'Box', Default = false, Callback = function(v) getgenv().ESP_Box = v end })
ESPBox:AddToggle('ESP_Name', { Text = 'Name', Default = true, Callback = function(v) getgenv().ESP_Name = v end })
ESPBox:AddToggle('ESP_Team', { Text = 'Team', Default = true, Callback = function(v) getgenv().ESP_Team = v end })
ESPBox:AddToggle('ESP_Distance', { Text = 'Distance', Default = true, Callback = function(v) getgenv().ESP_Distance = v end })
ESPBox:AddToggle('ESP_Health', { Text = 'Health Bar', Default = true, Callback = function(v) getgenv().ESP_Health = v end })
ESPBox:AddToggle('ESP_Tracer', { Text = 'Tracer', Default = true, Callback = function(v) getgenv().ESP_Tracer = v end })
ESPBox:AddToggle('ESP_HeadDot', { Text = 'Head Dot', Default = true, Callback = function(v) getgenv().ESP_HeadDot = v end })
ESPBox:AddSlider('ESP_MaxDistance', { Text = 'Max Distance', Default = 500, Min = 100, Max = 2000, Rounding = 0, Callback = function(v) getgenv().ESP_MaxDistance = v end })

local FOVBox = Visuals:AddRightGroupbox('FOV')
FOVBox:AddToggle('FOV_Enabled', { Text = 'Enable FOV', Default = true, Callback = function(v) getgenv().FOV_Enabled = v end })
FOVBox:AddSlider('FOV_Default', { Text = 'Default FOV', Default = 90, Min = 30, Max = 120, Rounding = 0, Callback = function(v) getgenv().FOV_Default = v end })
FOVBox:AddSlider('FOV_Zoom', { Text = 'Zoom FOV', Default = 30, Min = 10, Max = 90, Rounding = 0, Callback = function(v) getgenv().FOV_Zoom = v end })
FOVBox:AddLabel('Zoom Key'):AddKeyPicker('FOV_Key', { Default = 'Z', Mode = 'Hold', Text = 'Zoom', Callback = function(v) getgenv().FOV_Key = v end })

local FogBox = Visuals:AddRightGroupbox('No Fog')
FogBox:AddToggle('NoFog_Enabled', { Text = 'Enable No Fog', Default = true, Callback = function(v) getgenv().NoFog_Enabled = v end })
FogBox:AddToggle('AntiFlash_Enabled', { Text = 'Anti-Flash', Default = true, Callback = function(v) getgenv().AntiFlash_Enabled = v end })

local ItemBox = Visuals:AddRightGroupbox('Item Chams')
ItemBox:AddToggle('ItemESP_Enabled', { Text = 'Enable Item ESP', Default = true, Callback = function(v) getgenv().ItemESP_Enabled = v end })
ItemBox:AddSlider('ItemESP_MaxDistance', { Text = 'Max Distance', Default = 300, Min = 50, Max = 1000, Rounding = 0, Callback = function(v) getgenv().ItemESP_MaxDistance = v end })

local DoorBox = Visuals:AddRightGroupbox('Door/Elevator ESP')
DoorBox:AddToggle('DoorESP_Enabled', { Text = 'Enable Door ESP', Default = false, Callback = function(v) getgenv().DoorESP_Enabled = v end })
DoorBox:AddSlider('DoorESP_MaxDistance', { Text = 'Max Distance', Default = 300, Min = 50, Max = 1000, Rounding = 0, Callback = function(v) getgenv().DoorESP_MaxDistance = v end })

-- AIM
local Aim = Tabs.Aim
local SilentBox = Aim:AddLeftGroupbox('Silent Aim')
SilentBox:AddToggle('Silent_Enabled', { Text = 'Enable Silent', Default = true, Callback = function(v) getgenv().Silent_Enabled = v end })
SilentBox:AddSlider('Silent_FOV', { Text = 'FOV', Default = 60, Min = 10, Max = 200, Rounding = 0, Callback = function(v) getgenv().Silent_FOV = v end })
SilentBox:AddToggle('Silent_TeamCheck', { Text = 'Team Check', Default = true, Callback = function(v) getgenv().Silent_TeamCheck = v end })
SilentBox:AddToggle('Silent_Wallbang', { Text = 'Wallbang (shoot through walls)', Default = false, Callback = function(v) getgenv().Silent_Wallbang = v end })

local SmoothBox = Aim:AddLeftGroupbox('Smooth Aimbot')
SmoothBox:AddToggle('Smooth_Enabled', { Text = 'Enable Smooth Aimbot', Default = false, Callback = function(v) getgenv().Smooth_Enabled = v end })
SmoothBox:AddSlider('Smooth_Strength', { Text = 'Smoothness', Default = 5, Min = 1, Max = 20, Rounding = 0, Callback = function(v) getgenv().Smooth_Strength = v end })
SmoothBox:AddToggle('Smooth_TeamCheck', { Text = 'Team Check', Default = true, Callback = function(v) getgenv().Smooth_TeamCheck = v end })
SmoothBox:AddLabel('Smooth Key'):AddKeyPicker('Smooth_Key', { Default = 'C', Mode = 'Hold', Text = 'Smooth Aim', Callback = function(v) getgenv().Smooth_Key = v end })

local TriggerBox = Aim:AddLeftGroupbox('Triggerbot')
TriggerBox:AddToggle('Trigger_Enabled', { Text = 'Enable Triggerbot', Default = false, Callback = function(v) getgenv().Trigger_Enabled = v end })
TriggerBox:AddSlider('Trigger_Radius', { Text = 'Radius (px)', Default = 3, Min = 1, Max = 20, Rounding = 0, Callback = function(v) getgenv().Trigger_Radius = v end })
TriggerBox:AddSlider('Trigger_Delay', { Text = 'Delay (ms)', Default = 50, Min = 0, Max = 500, Rounding = 0, Callback = function(v) getgenv().Trigger_Delay = v end })
TriggerBox:AddToggle('Trigger_TeamCheck', { Text = 'Team Check', Default = true, Callback = function(v) getgenv().Trigger_TeamCheck = v end })

local RecoilBox = Aim:AddLeftGroupbox('No Recoil')
RecoilBox:AddToggle('NoRecoil_Enabled', { Text = 'Enable No Recoil', Default = true, Callback = function(v) getgenv().NoRecoil_Enabled = v end })

local FireBox = Aim:AddRightGroupbox('Rapid Fire')
FireBox:AddToggle('RapidFire_Enabled', { Text = 'Enable Rapid Fire', Default = true, Callback = function(v) getgenv().RapidFire_Enabled = v end })
FireBox:AddSlider('RapidFire_Rate', { Text = 'Fire Rate', Default = 0.03, Min = 0.01, Max = 0.1, Rounding = 2, Callback = function(v) getgenv().RapidFire_Rate = v end })

local HitBox = Aim:AddRightGroupbox('Hitmarker')
HitBox:AddToggle('Hitmarker_Enabled', { Text = 'Enable Hitmarker', Default = true, Callback = function(v) getgenv().Hitmarker_Enabled = v end })
HitBox:AddToggle('KillEffect_Enabled', { Text = 'Kill Effect', Default = true, Callback = function(v) getgenv().KillEffect_Enabled = v end })

-- MISC
local Misc = Tabs.Misc
local ReloadBox = Misc:AddLeftGroupbox('Reload')
ReloadBox:AddToggle('InstantReload_Enabled', { Text = 'Instant Reload', Default = true, Callback = function(v) getgenv().InstantReload_Enabled = v end })

local FallBox = Misc:AddLeftGroupbox('Fall Damage')
FallBox:AddToggle('NoFallDamage_Enabled', { Text = 'No Fall Damage', Default = true, Callback = function(v) getgenv().NoFallDamage_Enabled = v end })

local PickupBox = Misc:AddLeftGroupbox('Auto Pickup')
PickupBox:AddToggle('AutoPickup_Enabled', { Text = 'Enable Auto Pickup', Default = false, Callback = function(v) getgenv().AutoPickup_Enabled = v end })
PickupBox:AddSlider('AutoPickup_Range', { Text = 'Range', Default = 8, Min = 3, Max = 20, Rounding = 0, Callback = function(v) getgenv().AutoPickup_Range = v end })
PickupBox:AddToggle('AutoPickup_Keycards', { Text = 'Keycards', Default = true, Callback = function(v) getgenv().AutoPickup_Keycards = v end })
PickupBox:AddToggle('AutoPickup_Medkits', { Text = 'Medkits', Default = true, Callback = function(v) getgenv().AutoPickup_Medkits = v end })
PickupBox:AddToggle('AutoPickup_Ammo', { Text = 'Ammo', Default = false, Callback = function(v) getgenv().AutoPickup_Ammo = v end })
PickupBox:AddToggle('AutoPickup_Weapons', { Text = 'Weapons', Default = false, Callback = function(v) getgenv().AutoPickup_Weapons = v end })
PickupBox:AddToggle('AutoPickup_SCPItems', { Text = 'SCP Items', Default = true, Callback = function(v) getgenv().AutoPickup_SCPItems = v end })

local WeaponBox = Misc:AddRightGroupbox('Weapon Info')
WeaponBox:AddToggle('WeaponInfo_Enabled', { Text = 'Show Weapon', Default = true, Callback = function(v) getgenv().WeaponInfo_Enabled = v end })

local WMBox = Misc:AddRightGroupbox('Watermark')
WMBox:AddToggle('Watermark_Enabled', { Text = 'Enable Watermark', Default = true, Callback = function(v) getgenv().Watermark_Enabled = v end })

-- SETTINGS
local Settings = Tabs.Settings
local ConfigBox = Settings:AddLeftGroupbox('Config')
ConfigBox:AddToggle('Config_Autosave', { Text = 'Auto Save on Exit', Default = true, Callback = function(v) getgenv().Config_Autosave = v end })
ConfigBox:AddButton('Save Config', function() Library:SaveConfig('vanta_config') end)
ConfigBox:AddButton('Load Config', function() Library:LoadConfig('vanta_config') end)
ConfigBox:AddButton('Reset Config', function() Library:ResetConfig() end)

Library:OnUnload(function()
    if getgenv().Config_Autosave ~= false then
        pcall(function() Library:SaveConfig('vanta_config') end)
    end
    log("unloaded")
end)

task.spawn(function()
    while true do
        task.wait(60)
        if getgenv().Config_Autosave ~= false then
            pcall(function() Library:SaveConfig('vanta_config') end)
        end
    end
end)

log("menu loaded")

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
        for _, v in pairs(char:GetChildren()) do if v:IsA("Tool") then watchWeapon(v) end end
        char.ChildAdded:Connect(function(child) if child:IsA("Tool") then watchWeapon(child) end end)
        char.ChildRemoved:Connect(function(child)
            if child:IsA("Tool") then isWeaponZooming = false applyFOV() end
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
        if input.KeyCode == Enum.KeyCode[key] then Camera.FieldOfView = getgenv().FOV_Zoom or 30 end
    end)
    UserInputService.InputEnded:Connect(function(input)
        local key = getgenv().FOV_Key or 'Z'
        if input.KeyCode == Enum.KeyCode[key] then applyFOV() end
    end)
    task.spawn(function()
        while true do
            task.wait(0.05)
            currentFOV = getgenv().FOV_Default or 90
            if not isWeaponZooming and Camera.FieldOfView ~= currentFOV and Camera.FieldOfView ~= (getgenv().FOV_Zoom or 30) then
                Camera.FieldOfView = currentFOV
            end
        end
    end)
    log("FOV loaded")
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
                pcall(function() v.Density = 0 end)
                pcall(function() v.Haze = 0 end)
                pcall(function() v.Glare = 0 end)
            end
            if v:IsA("BlurEffect") then pcall(function() v.Size = 0 end) end
            if v:IsA("ColorCorrectionEffect") then
                pcall(function() v.Brightness = 0 end)
                pcall(function() v.Contrast = 0 end)
                pcall(function() v.Saturation = 0 end)
            end
            if v:IsA("SunRaysEffect") then pcall(function() v.Intensity = 0 end) end
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
        while true do task.wait(0.5) pcall(applyNoFog) end
    end)
    log("no fog loaded")
end

-- ============================================================
-- 3. SILENT AIM + WALLBANG
-- ============================================================
do
    local function isEnemy(plr)
        if getgenv().Silent_TeamCheck == false then return true end
        if not lp.Team or not plr.Team then return true end
        return plr.Team ~= lp.Team
    end
    local function asPart(inst)
        if not inst then return nil end
        if inst:IsA("BasePart") then return inst end
        if inst:IsA("Attachment") and inst.Parent and inst.Parent:IsA("BasePart") then return inst.Parent end
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
            local fp = asPart(char:FindFirstChild("FacePoint"))
            if fp then return fp end
            local head = asPart(char:FindFirstChild("Head"))
            if head then return head end
            local ut = asPart(char:FindFirstChild("UpperTorso"))
            if ut then return ut end
            local spine = collisions and asPart(collisions:FindFirstChild("spine"))
            if spine then return spine end
            local matthew = asPart(char:FindFirstChild("Matthew"))
            if matthew then return matthew end
            local body = asPart(char:FindFirstChild("Body"))
            if body then return body end
            local mask = asPart(char:FindFirstChild("Mask"))
            if mask then return mask end
        else
            local head = asPart(char:FindFirstChild("Head"))
            if head then return head end
            local ut = asPart(char:FindFirstChild("UpperTorso"))
            if ut then return ut end
        end
        return nil
    end
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
    local hookedCasters = {}
    local cachedTarget, cachedTargetTime = nil, 0
    local function getTargetPart()
        if getgenv().Silent_Enabled == false then return nil end
        local now = tick()
        if cachedTarget and now - cachedTargetTime < 0.02 then
            if cachedTarget.Parent and cachedTarget.Parent.Parent then return cachedTarget end
            cachedTarget = nil
        end
        local fov = getgenv().Silent_FOV or 60
        local wallbang = getgenv().Silent_Wallbang == true
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
            local rS, rO = Camera:WorldToViewportPoint(root.Position)
            if not rO then continue end
            local rD = (Vector2.new(rS.X, rS.Y) - center).Magnitude
            if rD > fov then continue end
            local part = getHitPart(plr)
            if not part then continue end
            if not wallbang and not hasLineOfSight(part) then continue end
            local sP, oS = Camera:WorldToViewportPoint(part.Position)
            if not oS then continue end
            local d = (Vector2.new(sP.X, sP.Y) - center).Magnitude
            if d < shortest then shortest = d closest = part end
        end
        cachedTarget = closest
        cachedTargetTime = now
        return closest
    end
    local function buildDelegate(oldDelegate)
        return function(self, rayResult, velocity, bullet, id)
            local target = getTargetPart()
            if target then
                local origin = Camera.CFrame.Position
                local direction = target.Position - origin
                local params = RaycastParams.new()
                if getgenv().Silent_Wallbang == true then
                    params.FilterType = Enum.RaycastFilterType.Include
                    params.FilterDescendantsInstances = { target }
                else
                    params.FilterType = Enum.RaycastFilterType.Exclude
                    params.FilterDescendantsInstances = { lp.Character, Camera }
                end
                local newResult = workspace:Raycast(origin, direction, params)
                if newResult then return oldDelegate(self, newResult, velocity, bullet, id) end
            end
            return oldDelegate(self, rayResult, velocity, bullet, id)
        end
    end
    local function hookAllCasters()
        for _, obj in pairs(getgc(true)) do
            if type(obj) ~= "function" then continue end
            local ok, ups = pcall(debug.getupvalues, obj)
            if not ok or not ups then continue end
            for k, v in pairs(ups) do
                if type(v) == "table" and rawget(v, "caster") then
                    local caster = rawget(v, "caster")
                    if not hookedCasters[caster] then
                        local rayHit = caster.RayHit
                        if rayHit and rayHit.Connections and rayHit.Connections[1] then
                            local conn = rayHit.Connections[1]
                            local oldD = conn.Delegate
                            if type(oldD) == "function" then
                                conn.Delegate = buildDelegate(oldD)
                                hookedCasters[caster] = true
                            end
                        end
                    end
                end
            end
        end
    end
    local function watchCharacter(char)
        if not char then return end
        char.ChildAdded:Connect(function(child) if child:IsA("Tool") then task.wait(0.3) hookAllCasters() end end)
        char.ChildRemoved:Connect(function(child) if child:IsA("Tool") then task.wait(0.3) hookAllCasters() end end)
    end
    if lp.Character then watchCharacter(lp.Character) end
    lp.CharacterAdded:Connect(function(char) watchCharacter(char) task.wait(1) hookAllCasters() end)
    task.spawn(function() while true do task.wait(15) pcall(hookAllCasters) end end)
    task.wait(1)
    hookAllCasters()
    log("silent + wallbang loaded")
end

-- ============================================================
-- 4. SMOOTH AIMBOT
-- ============================================================
do
    local function isEnemy(plr)
        if getgenv().Smooth_TeamCheck == false then return true end
        if not lp.Team or not plr.Team then return true end
        return plr.Team ~= lp.Team
    end
    local function findTarget()
        local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        local closest, shortest = nil, 200
        for _, plr in pairs(Players:GetPlayers()) do
            if plr == lp then continue end
            if not isEnemy(plr) then continue end
            local char = plr.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if not hum or hum.Health <= 0 then continue end
            local head = char:FindFirstChild("Head")
            if not head then continue end
            local sP, oS = Camera:WorldToViewportPoint(head.Position)
            if not oS or sP.Z < 0 then continue end
            local d = (Vector2.new(sP.X, sP.Y) - center).Magnitude
            if d < shortest then shortest = d closest = head end
        end
        return closest
    end
    local function smooth()
        if getgenv().Smooth_Enabled ~= true then return end
        local key = getgenv().Smooth_Key or 'C'
        if not UserInputService:IsKeyDown(Enum.KeyCode[key]) then return end
        local target = findTarget()
        if not target then return end
        local strength = getgenv().Smooth_Strength or 5
        local cam = Camera.CFrame
        local targetCF = CFrame.new(cam.Position, target.Position)
        Camera.CFrame = cam:Lerp(targetCF, 1 / strength)
    end
    RunService.RenderStepped:Connect(function() pcall(smooth) end)
    log("smooth loaded")
end

-- ============================================================
-- 5. TRIGGERBOT
-- ============================================================
do
    local lastActivate = 0
    local BASE_COOLDOWN = 0.05
    local function isEnemyChar(char)
        local plr = Players:GetPlayerFromCharacter(char)
        if not plr or plr == lp then return false end
        if getgenv().Trigger_TeamCheck == false then return true end
        if not lp.Team or not plr.Team then return true end
        return plr.Team ~= lp.Team
    end
    local function isWeapon(tool)
        if not tool or not tool:IsA("Tool") then return false end
        if tool:GetAttribute("Firearm") then return true end
        if tool:FindFirstChild("Settings") then return true end
        return false
    end
    local function getCrosshairTarget()
        local radius = getgenv().Trigger_Radius or 3
        local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        local closest, shortest = nil, radius
        for _, plr in pairs(Players:GetPlayers()) do
            if plr == lp then continue end
            if not isEnemyChar(plr.Character) then continue end
            local char = plr.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if not hum or hum.Health <= 0 then continue end
            local head = char:FindFirstChild("Head")
            if not head or not head:IsA("BasePart") then continue end
            local sP, oS = Camera:WorldToViewportPoint(head.Position)
            if not oS or sP.Z < 0 then continue end
            local d = (Vector2.new(sP.X, sP.Y) - center).Magnitude
            if d < shortest then shortest = d closest = char end
        end
        return closest
    end
    local function trigger()
        if getgenv().Trigger_Enabled ~= true then return end
        local now = tick()
        local userDelay = (getgenv().Trigger_Delay or 50) / 1000
        local effectiveDelay = math.max(userDelay, BASE_COOLDOWN)
        if now - lastActivate < effectiveDelay then return end
        local target = getCrosshairTarget()
        if not target then return end
        lastActivate = now
        local char = lp.Character
        local tool = char and char:FindFirstChildOfClass("Tool")
        if not isWeapon(tool) then return end
        pcall(function() tool:Activate() end)
    end
    RunService.Heartbeat:Connect(function() pcall(trigger) end)
    log("triggerbot loaded")
end

-- ============================================================
-- 6. ESP CHAMS
-- ============================================================
do
    local espCache = {}
    local BONE_PAIRS = {
        {"Head", "UpperTorso"},
        {"UpperTorso", "LowerTorso"},
        {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
        {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
        {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
        {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"},
    }
    local function isEnemy(plr)
        if getgenv().ESP_TeamCheck == false then return true end
        if not lp.Team or not plr.Team then return true end
        return plr.Team ~= lp.Team
    end
    local function getTeamColor(plr)
        if not isEnemy(plr) then return Color3.fromRGB(60, 255, 60) end
        return Color3.fromRGB(255, 60, 60)
    end
    local function CreateESP(plr)
        if espCache[plr] then return espCache[plr] end
        local bones = {}
        for i = 1, #BONE_PAIRS do
            bones[i] = NewDrawing("Line", { Thickness = 2, Visible = false })
        end
        local data = {
            Bones = bones,
            L1 = NewDrawing("Line", { Thickness=1, Visible=false }),
            L2 = NewDrawing("Line", { Thickness=1, Visible=false }),
            L3 = NewDrawing("Line", { Thickness=1, Visible=false }),
            L4 = NewDrawing("Line", { Thickness=1, Visible=false }),
            HpBg   = NewDrawing("Line", { Thickness=5, Color=Color3.fromRGB(0,0,0), Visible=false }),
            HpFill = NewDrawing("Line", { Thickness=4, Color=Color3.fromRGB(0,255,0), Visible=false }),
            Name = NewDrawing("Text", { Size=13, Center=true, Outline=true, Visible=false }),
            Team = NewDrawing("Text", { Size=11, Center=true, Outline=true, Visible=false }),
            Dist = NewDrawing("Text", { Size=11, Center=true, Outline=true, Visible=false }),
            Tracer  = NewDrawing("Line",   { Thickness=1, Visible=false }),
            HeadDot = NewDrawing("Circle", { Thickness=1, Filled=true, NumSides=16, Radius=3, Visible=false }),
            LastColor = nil,
        }
        espCache[plr] = data
        return data
    end
    local KEYS = {"L1","L2","L3","L4","HpBg","HpFill","Name","Team","Dist","Tracer","HeadDot"}
    local function HideESP(data)
        for _, k in ipairs(KEYS) do data[k].Visible = false end
        for _, b in ipairs(data.Bones) do b.Visible = false end
    end
    local function DestroyESP(data)
        if not data then return end
        for _, k in ipairs(KEYS) do if data[k] then pcall(function() data[k]:Remove() end) end end
        for _, b in ipairs(data.Bones) do pcall(function() b:Remove() end) end
    end
    local function UpdateESP()
        if getgenv().ESP_Enabled == false then
            for _, d in pairs(espCache) do HideESP(d) end
            return
        end
        local vp = Camera.ViewportSize
        local maxDist = getgenv().ESP_MaxDistance or 500
        for plr, data in pairs(espCache) do
            if plr == lp then HideESP(data) continue end
            local char = plr.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if not char or not hum or hum.Health <= 0 or not char.Parent then HideESP(data) continue end
            if not isEnemy(plr) then HideESP(data) continue end
            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then HideESP(data) continue end
            local rS, rO = Camera:WorldToViewportPoint(root.Position)
            local distance = (Camera.CFrame.Position - root.Position).Magnitude
            if not rO or distance > maxDist then HideESP(data) continue end
            local color = getTeamColor(plr)
            if data.LastColor ~= color then
                data.LastColor = color
                for _, k in ipairs({"L1","L2","L3","L4","Tracer"}) do data[k].Color = color end
                for _, b in ipairs(data.Bones) do b.Color = color end
                data.HeadDot.Color = Color3.fromRGB(255, 255, 255)
            end
            if getgenv().ESP_Chams ~= false then
                for i, pair in ipairs(BONE_PAIRS) do
                    local p1 = char:FindFirstChild(pair[1])
                    local p2 = char:FindFirstChild(pair[2])
                    if p1 and p2 and p1:IsA("BasePart") and p2:IsA("BasePart") then
                        local s1, o1 = Camera:WorldToViewportPoint(p1.Position)
                        local s2, o2 = Camera:WorldToViewportPoint(p2.Position)
                        if o1 and o2 and s1.Z > 0 and s2.Z > 0 then
                            data.Bones[i].From = Vector2.new(s1.X, s1.Y)
                            data.Bones[i].To = Vector2.new(s2.X, s2.Y)
                            data.Bones[i].Visible = true
                        else
                            data.Bones[i].Visible = false
                        end
                    else
                        data.Bones[i].Visible = false
                    end
                end
            else
                for _, b in ipairs(data.Bones) do b.Visible = false end
            end
            if getgenv().ESP_Box == true then
                local hipHeight = hum.HipHeight > 0 and hum.HipHeight or 2.5
                local tp = Camera:WorldToViewportPoint(root.Position + Vector3.new(0, hipHeight + 1.5, 0))
                local bp = Camera:WorldToViewportPoint(root.Position + Vector3.new(0, -hipHeight, 0))
                local h = math.max(math.abs(bp.Y - tp.Y), 20)
                local w = h * 0.55
                local x = rS.X - w/2
                local y = tp.Y
                data.L1.From=Vector2.new(x,y); data.L1.To=Vector2.new(x+w,y); data.L1.Visible=true
                data.L2.From=Vector2.new(x+w,y); data.L2.To=Vector2.new(x+w,y+h); data.L2.Visible=true
                data.L3.From=Vector2.new(x+w,y+h); data.L3.To=Vector2.new(x,y+h); data.L3.Visible=true
                data.L4.From=Vector2.new(x,y+h); data.L4.To=Vector2.new(x,y); data.L4.Visible=true
            end
            if getgenv().ESP_Tracer ~= false then
                data.Tracer.From = Vector2.new(vp.X/2, vp.Y)
                data.Tracer.To   = Vector2.new(rS.X, rS.Y)
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
            else data.HeadDot.Visible = false end
            if getgenv().ESP_Name ~= false then
                data.Name.Text = plr.Name
                data.Name.Position = Vector2.new(rS.X, rS.Y - 40)
                data.Name.Color = Color3.fromRGB(255,255,255)
                data.Name.Visible = true
            else data.Name.Visible = false end
            if getgenv().ESP_Team ~= false then
                data.Team.Text = plr.Team and plr.Team.Name or "?"
                data.Team.Position = Vector2.new(rS.X, rS.Y - 28)
                data.Team.Color = color
                data.Team.Visible = true
            else data.Team.Visible = false end
            if getgenv().ESP_Distance ~= false then
                data.Dist.Text = string.format("[%.0fm]", distance)
                data.Dist.Position = Vector2.new(rS.X, rS.Y + 20)
                data.Dist.Color = Color3.fromRGB(180,180,180)
                data.Dist.Visible = true
            else data.Dist.Visible = false end
            if getgenv().ESP_Health ~= false then
                local maxHp = hum.MaxHealth > 0 and hum.MaxHealth or 100
                local ratio = math.clamp(hum.Health/maxHp, 0, 1)
                local barX = rS.X - 25
                data.HpBg.From = Vector2.new(barX, rS.Y - 20)
                data.HpBg.To = Vector2.new(barX, rS.Y + 20)
                data.HpBg.Color = Color3.fromRGB(0,0,0)
                data.HpBg.Visible = true
                local fillH = 40 * ratio
                data.HpFill.From = Vector2.new(barX, rS.Y + 20)
                data.HpFill.To = Vector2.new(barX, rS.Y + 20 - fillH)
                data.HpFill.Color = Color3.fromRGB(math.floor(255*(1-ratio)), math.floor(255*ratio), 0)
                data.HpFill.Visible = true
            else
                data.HpBg.Visible = false
                data.HpFill.Visible = false
            end
        end
    end
    local function AttachPlayer(plr) if plr == lp then return end CreateESP(plr) end
    for _, plr in pairs(Players:GetPlayers()) do AttachPlayer(plr) end
    Players.PlayerAdded:Connect(AttachPlayer)
    Players.PlayerRemoving:Connect(function(plr)
        local d = espCache[plr]
        if d then DestroyESP(d) espCache[plr] = nil end
    end)
    RunService.RenderStepped:Connect(function() pcall(UpdateESP) end)
    log("ESP loaded")
end

-- ============================================================
-- 7. NO RECOIL
-- ============================================================
do
    local cachedTables = {}
    local function looksLikeWeapon(obj)
        if type(obj) ~= "table" then return false end
        local rp = rawget(obj, "recoilPattern")
        if type(rp) ~= "table" then return false end
        if rawget(obj, "settings") == nil and rawget(obj, "caster") == nil then return false end
        return true
    end
    local function clearOne(obj)
        local rp = rawget(obj, "recoilPattern")
        if type(rp) ~= "table" then return false end
        if next(rp) == nil then return false end
        table.clear(rp)
        if rawget(obj, "curshts") ~= nil then obj.curshts = 0 end
        return true
    end
    local function scanWeapons()
        for _, obj in pairs(getgc(true)) do
            if looksLikeWeapon(obj) then cachedTables[obj] = true end
        end
    end
    local function clearRecoil()
        if getgenv().NoRecoil_Enabled == false then return end
        for obj in pairs(cachedTables) do
            if type(obj) == "table" then clearOne(obj) else cachedTables[obj] = nil end
        end
        if next(cachedTables) == nil then
            scanWeapons()
            for obj in pairs(cachedTables) do clearOne(obj) end
        end
    end
    lp.CharacterRemoving:Connect(function() cachedTables = {} end)
    task.spawn(function() while true do task.wait(5) pcall(clearRecoil) end end)
    task.wait(1)
    scanWeapons()
    clearRecoil()
    log("norecoil loaded")
end

-- ============================================================
-- 8. RAPID FIRE
-- ============================================================
do
    local function patchSettings(t)
        if type(t) ~= "table" then return end
        local rate = getgenv().RapidFire_Rate or 0.03
        for k, v in pairs(t) do
            if tostring(k):lower() == "firerate" then t[k] = rate end
        end
    end
    local function scanSettings()
        if getgenv().RapidFire_Enabled == false then return end
        for _, obj in pairs(getgc(true)) do
            if type(obj) ~= "table" then continue end
            local hasFR, hasDmg = false, false
            for k in pairs(obj) do
                local n = tostring(k):lower()
                if n == "firerate" then hasFR = true end
                if n == "damage" then hasDmg = true end
            end
            if hasFR and hasDmg then patchSettings(obj) end
        end
    end
    task.spawn(function() while true do task.wait(15) pcall(scanSettings) end end)
    scanSettings()
    log("rapidfire loaded")
end

-- ============================================================
-- 9. HITMARKER + KILL EFFECT
-- ============================================================
do
    local lines = {}
    for i = 1, 4 do
        lines[i] = Drawing.new("Line")
        lines[i].Thickness = 1.5
        lines[i].Color = Color3.fromRGB(255, 255, 255)
        lines[i].Visible = false
    end
    local killText = NewDrawing("Text", { Size=24, Center=true, Outline=true, Color=Color3.fromRGB(255,50,50), Visible=false })
    local killOutline = NewDrawing("Text", { Size=26, Center=true, Outline=false, Color=Color3.fromRGB(0,0,0), Visible=false })
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
        lines[2].From = Vector2.new(center.X+gap, center.Y-gap); lines[2].To = Vector2.new(center.X+gap+size, center.Y-gap-size)
        lines[3].From = Vector2.new(center.X-gap-size, center.Y+gap+size); lines[3].To = Vector2.new(center.X-gap, center.Y+gap)
        lines[4].From = Vector2.new(center.X+gap, center.Y+gap); lines[4].To = Vector2.new(center.X+gap+size, center.Y+gap+size)
        for i = 1, 4 do lines[i].Color = color lines[i].Visible = true end
        table.insert(activeHit, { startTime = tick() })
    end
    local function triggerKillEffect()
        if getgenv().KillEffect_Enabled == false then return end
        local vp = Camera.ViewportSize
        local center = Vector2.new(vp.X/2, vp.Y/2)
        killText.Text = "KILL" killText.Position = center killText.Visible = true
        killOutline.Text = "KILL" killOutline.Position = center killOutline.Visible = true
        flashLines[1].From = Vector2.new(0, 0); flashLines[1].To = Vector2.new(vp.X, 0)
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
            if now - activeHit[i].startTime >= 0.15 then table.remove(activeHit, i) else anyHit = true end
        end
        if not anyHit then for i = 1, 4 do lines[i].Visible = false end end
        for i = #activeKill, 1, -1 do
            local k = activeKill[i]
            local p = (now - k.startTime) / 0.6
            if p >= 1 then
                killText.Visible = false killOutline.Visible = false
                for j = 1, 4 do flashLines[j].Visible = false end
                table.remove(activeKill, i)
            else
                killText.Transparency = p killOutline.Transparency = p
                killText.Size = 24 + math.floor(p * 10)
                killOutline.Size = 26 + math.floor(p * 10)
            end
        end
    end)
    local hookedCasters = {}
    local lastHit = 0
    local function isEnemyChar(char)
        local plr = Players:GetPlayerFromCharacter(char)
        if not plr or plr == lp then return false end
        if not lp.Team or not plr.Team then return true end
        return plr.Team ~= lp.Team
    end
    local function hookAll()
        for _, obj in pairs(getgc(true)) do
            if type(obj) ~= "function" then continue end
            local ok, ups = pcall(debug.getupvalues, obj)
            if not ok or not ups then continue end
            for k, v in pairs(ups) do
                if type(v) == "table" and rawget(v, "caster") then
                    local caster = rawget(v, "caster")
                    if not hookedCasters[caster] and caster.RayHit then
                        hookedCasters[caster] = true
                        caster.RayHit:Connect(function(_, rR, _, _, _)
                            if not rR or not rR.Instance then return end
                            local hp = rR.Instance
                            local char = hp:FindFirstAncestorWhichIsA("Model")
                            if not char then return end
                            local hum = char:FindFirstChildOfClass("Humanoid")
                            if not hum or not isEnemyChar(char) then return end
                            local now = tick()
                            if now - lastHit < 0.05 then return end
                            lastHit = now
                            ShowHitmarker(hp.Name == "Head", hum.Health <= 0)
                            if hum.Health <= 0 then triggerKillEffect() end
                        end)
                    end
                end
            end
        end
    end
    task.spawn(function() while true do task.wait(5) pcall(hookAll) end end)
    task.wait(1)
    hookAll()
    log("hitmarker loaded")
end

-- ============================================================
-- 10. NO FALL DAMAGE
-- ============================================================
do
    local disabledChars = {}
    local function disable(char)
        if not char or disabledChars[char] then return end
        local fd = char:FindFirstChild("FallDamage")
        if fd and fd:IsA("LocalScript") then
            fd.Disabled = true
            disabledChars[char] = true
        end
    end
    local function watch(char)
        if not char then return end
        task.wait(0.3)
        disable(char)
        char.ChildAdded:Connect(function(child)
            if child.Name == "FallDamage" and child:IsA("LocalScript") then
                child.Disabled = true
                disabledChars[char] = true
            end
        end)
    end
    if lp.Character then watch(lp.Character) end
    lp.CharacterAdded:Connect(watch)
    lp.CharacterRemoving:Connect(function(char) disabledChars[char] = nil end)
    log("no fall damage loaded")
end

-- ============================================================
-- 11. INSTANT RELOAD
-- ============================================================
do
    local gunInstances = {}
    local lastReload = 0
    local reloadingNow = false
    local function findGuns()
        for _, obj in pairs(getgc(true)) do
            if type(obj) ~= "table" then continue end
            local s = rawget(obj, "settings")
            local g = rawget(obj, "gunTool")
            if type(s) == "table" and typeof(g) == "Instance" then gunInstances[obj] = true end
        end
    end
    local function getReloadMethod(gun)
        local mt = getmetatable(gun)
        if mt and type(mt.__index) == "table" then
            local m = rawget(mt.__index, "Reload")
            if type(m) == "function" then return m end
        end
        return rawget(gun, "Reload")
    end
    local function instantReload()
        if getgenv().InstantReload_Enabled == false or reloadingNow then return end
        local now = tick()
        if now - lastReload < 0.2 then return end
        for gun in pairs(gunInstances) do
            local s = rawget(gun, "settings")
            local g = rawget(gun, "gunTool")
            if type(s) ~= "table" or typeof(g) ~= "Instance" then gunInstances[gun] = nil continue end
            local mag = g:GetAttribute("CurrentMagazineCount") or s.CurrentMagazineCount
            if type(mag) ~= "number" then continue end
            if mag == 0 and not gun.reloading and not gun.unloading then
                local fn = getReloadMethod(gun)
                if fn then
                    lastReload = now
                    reloadingNow = true
                    task.spawn(function()
                        local we = gun.equipping
                        gun.equipping = false
                        pcall(fn, gun)
                        gun.equipping = we
                        task.wait(2)
                        reloadingNow = false
                    end)
                end
            end
        end
    end
    findGuns()
    lp.CharacterAdded:Connect(function()
        task.wait(0.5)
        gunInstances = {}
        findGuns()
    end)
    task.spawn(function() while true do task.wait(0.2) pcall(instantReload) end end)
    task.spawn(function() while true do task.wait(10) pcall(findGuns) end end)
    log("instant reload loaded")
end

-- ============================================================
-- 12. ANTI-FLASH
-- ============================================================
do
    local function clear()
        if getgenv().AntiFlash_Enabled == false then return end
        local pg = lp:FindFirstChildOfClass("PlayerGui")
        if not pg then return end
        for _, v in pairs(pg:GetDescendants()) do
            if v:IsA("ImageLabel") or v:IsA("Frame") or v:IsA("TextLabel") then
                local n = v.Name:lower()
                if n:find("flash") or n:find("blind") or n:find("whiteout") or n:find("blackout") then
                    v.Visible = false
                end
            end
        end
    end
    task.spawn(function() while true do task.wait(0.05) pcall(clear) end end)
    log("anti-flash loaded")
end

-- ============================================================
-- 13. WEAPON INFO
-- ============================================================
do
    local weaponTexts = {}
    local function isEnemy(plr)
        if not lp.Team or not plr.Team then return true end
        return plr.Team ~= lp.Team
    end
    local function createText(plr)
        if weaponTexts[plr] then return weaponTexts[plr] end
        weaponTexts[plr] = NewDrawing("Text", { Size=11, Center=true, Outline=true, Color=Color3.fromRGB(255,200,100), Visible=false })
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
            local sP, oS = Camera:WorldToViewportPoint(root.Position + Vector3.new(0, 2, 0))
            if not oS or sP.Z < 0 then text.Visible = false continue end
            local tool = char:FindFirstChildOfClass("Tool")
            if not tool then text.Visible = false continue end
            text.Text = tool.Name
            text.Position = Vector2.new(sP.X, sP.Y + 50)
            text.Visible = true
        end
    end
    for _, plr in pairs(Players:GetPlayers()) do if plr ~= lp then createText(plr) end end
    Players.PlayerAdded:Connect(function(plr) if plr ~= lp then createText(plr) end end)
    Players.PlayerRemoving:Connect(function(plr)
        if weaponTexts[plr] then pcall(function() weaponTexts[plr]:Remove() end) weaponTexts[plr] = nil end
    end)
    task.spawn(function() while true do task.wait(0.1) pcall(update) end end)
    log("weapon info loaded")
end

-- ============================================================
-- 14. ITEM CHAMS (кэш)
-- ============================================================
do
    local itemHighlights = {}
    local itemCache = {}
    local function getItemColor(name)
        local n = name:lower()
        if n:find("keycard") or n:find("card") then return Color3.fromRGB(80, 160, 255) end
        if n:find("medkit") or n:find("medical") or n:find("pill") then return Color3.fromRGB(80, 255, 80) end
        if n:find("ammo") or n:find("magazine") then return Color3.fromRGB(255, 200, 0) end
        if n:find("scp") then return Color3.fromRGB(200, 80, 255) end
        return Color3.fromRGB(255, 80, 80)
    end
    local function isHeld(item)
        local p = item.Parent
        while p and p ~= workspace do
            if p:FindFirstChildOfClass("Humanoid") then return true end
            p = p.Parent
        end
        return false
    end
    local function createHL(item)
        if itemHighlights[item] then return itemHighlights[item] end
        local ok, h = pcall(function()
            local hl = Instance.new("Highlight")
            hl.Name = "VantaItem"
            hl.FillTransparency = 0.5
            hl.OutlineTransparency = 0.3
            hl.DepthMode = Enum.HighlightDepthMode.Occlusion
            local c = getItemColor(item.Name)
            hl.FillColor = c
            hl.OutlineColor = c
            hl.Adornee = item
            hl.Parent = item
            return hl
        end)
        if ok then itemHighlights[item] = h end
        return itemHighlights[item]
    end
    local function destroyHL(item)
        local h = itemHighlights[item]
        if h then pcall(function() h:Destroy() end) itemHighlights[item] = nil end
        itemCache[item] = nil
    end
    local function addItem(item)
        if not item or not item:IsA("Tool") then return end
        if itemCache[item] then return end
        if isHeld(item) then return end
        if not item:FindFirstChild("Handle") then return end
        itemCache[item] = true
        local maxDist = getgenv().ItemESP_MaxDistance or 300
        local camPos = Camera.CFrame.Position
        if (camPos - item.Handle.Position).Magnitude <= maxDist then createHL(item) end
    end
    task.spawn(function()
        while true do
            task.wait(1)
            if getgenv().ItemESP_Enabled == false then
                for item in pairs(itemHighlights) do destroyHL(item) end
            else
                local maxDist = getgenv().ItemESP_MaxDistance or 300
                local camPos = Camera.CFrame.Position
                for item in pairs(itemCache) do
                    if not item or not item.Parent or isHeld(item) then
                        destroyHL(item)
                    else
                        local h = itemHighlights[item]
                        local dist = (camPos - item.Handle.Position).Magnitude
                        if dist <= maxDist and not h then
                            createHL(item)
                        elseif dist > maxDist and h then
                            destroyHL(item)
                            itemCache[item] = true
                        end
                    end
                end
            end
        end
    end)
    task.spawn(function()
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Tool") then addItem(v) end
        end
    end)
    workspace.DescendantAdded:Connect(function(child)
        if child:IsA("Tool") then task.wait(0.2) addItem(child) end
    end)
    log("item chams loaded (cache)")
end

-- ============================================================
-- 15. DOOR ESP (кэш)
-- ============================================================
do
    local doorHLs = {}
    local doorCache = {}
    local function isDoor(inst)
        local n = inst.Name:lower()
        if n:find("door") or n:find("gate") or n:find("elevator") or n:find("lift") or n:find("airlock") then
            return true
        end
        return false
    end
    local function createHL(inst)
        if doorHLs[inst] then return doorHLs[inst] end
        local ok, h = pcall(function()
            local hl = Instance.new("Highlight")
            hl.Name = "VantaDoor"
            hl.FillTransparency = 0.7
            hl.OutlineTransparency = 0.2
            hl.DepthMode = Enum.HighlightDepthMode.Occlusion
            hl.FillColor = Color3.fromRGB(255, 200, 0)
            hl.OutlineColor = Color3.fromRGB(255, 200, 0)
            hl.Adornee = inst
            hl.Parent = inst
            return hl
        end)
        if ok then doorHLs[inst] = h end
        return doorHLs[inst]
    end
    local function destroyHL(inst)
        local h = doorHLs[inst]
        if h then pcall(function() h:Destroy() end) doorHLs[inst] = nil end
        doorCache[inst] = nil
    end
    local function getPos(inst)
        return inst.PrimaryPart and inst.PrimaryPart.Position or (inst:FindFirstChildWhichIsA("BasePart") and inst:FindFirstChildWhichIsA("BasePart").Position)
    end
    local function addDoor(inst)
        if not inst or not inst:IsA("Model") then return end
        if doorCache[inst] then return end
        if not isDoor(inst) then return end
        doorCache[inst] = true
        local pos = getPos(inst)
        if not pos then return end
        local maxDist = getgenv().DoorESP_MaxDistance or 300
        if (Camera.CFrame.Position - pos).Magnitude <= maxDist then createHL(inst) end
    end
    task.spawn(function()
        while true do
            task.wait(1)
            if getgenv().DoorESP_Enabled == false then
                for inst in pairs(doorHLs) do destroyHL(inst) end
            else
                local maxDist = getgenv().DoorESP_MaxDistance or 300
                local camPos = Camera.CFrame.Position
                for inst in pairs(doorCache) do
                    if not inst or not inst.Parent then
                        destroyHL(inst)
                    else
                        local h = doorHLs[inst]
                        local pos = getPos(inst)
                        if pos then
                            local dist = (camPos - pos).Magnitude
                            if dist <= maxDist and not h then
                                createHL(inst)
                            elseif dist > maxDist and h then
                                destroyHL(inst)
                                doorCache[inst] = true
                            end
                        end
                    end
                end
            end
        end
    end)
    task.spawn(function()
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Model") then addDoor(v) end
        end
    end)
    workspace.DescendantAdded:Connect(function(child)
        if child:IsA("Model") then task.wait(0.2) addDoor(child) end
    end)
    log("door ESP loaded (cache)")
end

-- ============================================================
-- 16. AUTO PICKUP (кэш)
-- ============================================================
do
    local itemCache = {}
    local function getRoot()
        local char = lp.Character
        return char and char:FindFirstChild("HumanoidRootPart")
    end
    local function isKeycard(name) local n = name:lower() return n:find("keycard") or n:find("card") end
    local function isMedkit(name) local n = name:lower() return n:find("medkit") or n:find("medical") or n:find("pill") end
    local function isAmmo(name) local n = name:lower() return n:find("ammo") or n:find("magazine") end
    local function isWeapon(name) local n = name:lower() return n:find("e-11") or n:find("p90") or n:find("logic") or n:find("usp") or n:find("com-15") end
    local function isSCPItem(name) local n = name:lower() return n:find("scp-") end
    local function shouldPickup(name)
        if getgenv().AutoPickup_Keycards ~= false and isKeycard(name) then return true end
        if getgenv().AutoPickup_Medkits ~= false and isMedkit(name) then return true end
        if getgenv().AutoPickup_Ammo == true and isAmmo(name) then return true end
        if getgenv().AutoPickup_Weapons == true and isWeapon(name) then return true end
        if getgenv().AutoPickup_SCPItems ~= false and isSCPItem(name) then return true end
        return false
    end
    local function addItem(tool)
        if not tool or not tool:IsA("Tool") then return end
        if itemCache[tool] then return end
        if not shouldPickup(tool.Name) then return end
        if not tool:FindFirstChild("Handle") then return end
        itemCache[tool] = true
    end
    local function tryPickup()
        if getgenv().AutoPickup_Enabled ~= true then return end
        local root = getRoot()
        if not root then return end
        local range = getgenv().AutoPickup_Range or 8
        for tool in pairs(itemCache) do
            if not tool or not tool.Parent then
                itemCache[tool] = nil
            else
                local held = false
                local p = tool.Parent
                while p and p ~= workspace do
                    if p:FindFirstChildOfClass("Humanoid") then held = true break end
                    p = p.Parent
                end
                if not held and tool:FindFirstChild("Handle") then
                    local dist = (root.Position - tool.Handle.Position).Magnitude
                    if dist <= range and firetouchinterest then
                        pcall(firetouchinterest, root, tool.Handle, 0)
                        task.wait()
                        pcall(firetouchinterest, root, tool.Handle, 1)
                    end
                end
            end
        end
    end
    task.spawn(function()
        while true do
            task.wait(0.5)
            pcall(tryPickup)
        end
    end)
    task.spawn(function()
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Tool") then addItem(v) end
        end
    end)
    workspace.DescendantAdded:Connect(function(child)
        if child:IsA("Tool") then task.wait(0.2) addItem(child) end
    end)
    log("auto pickup loaded (cache)")
end

-- ============================================================
-- 17. WATERMARK CS:GO
-- ============================================================
do
    local watermark = NewDrawing("Text", {
        Size = 16, Center = false, Outline = true,
        Color = Color3.fromRGB(255, 255, 255), Visible = true,
        Position = Vector2.new(0, 0),
    })
    local fps = 0
    local fpsCounter = 0
    local lastFpsTime = tick()
    RunService.RenderStepped:Connect(function()
        fpsCounter = fpsCounter + 1
        local now = tick()
        if now - lastFpsTime >= 1 then
            fps = fpsCounter
            fpsCounter = 0
            lastFpsTime = now
        end
    end)
    task.spawn(function()
        while true do
            task.wait(0.5)
            if getgenv().Watermark_Enabled == false then
                watermark.Visible = false
            else
                watermark.Visible = true
                local ping = 0
                pcall(function()
                    ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
                end)
                local time = os.date("%H:%M:%S")
                watermark.Text = string.format("VANTA | FPS: %d | PING: %dms | %s", fps, ping, time)
                local vp = Camera.ViewportSize
                local bounds = watermark.TextBounds
                watermark.Position = Vector2.new(vp.X - bounds.X - 10, 10)
            end
        end
    end)
    log("watermark loaded")
endlog("all loaded v14")
