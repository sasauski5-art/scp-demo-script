-- ============================================================
-- VANTA Script by sasauski5
-- GitHub: github.com/sasauski5-art/scp-demo-script
-- Do not redistribute without credit
-- ============================================================
-- VANTA full: silent + ESP + NoRecoil + RapidFire + Hitmarker + NoFallDamage + InstantReload + AntiDecon + GrenadeESP + GrenadeTimer

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local lp = Players.LocalPlayer

local function NewDrawing(dtype, props)
    local d = Drawing.new(dtype)
    for k, v in pairs(props) do d[k] = v end
    return d
end

print("[VANTA] loading...")

-- ============================================================
-- 1. SILENT AIM
-- ============================================================
do
    local Config = {
        FOV = 125,
        TeamCheck = true,
        VisibleOnly = false,
        WatchdogInterval = 5,
        TargetCacheTime = 0.05,
        MaxDistance = 15000,
    }

    local function isEnemy(plr)
        if not Config.TeamCheck then return true end
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
            local facePoint = asPart(char:FindFirstChild("FacePoint"))
            if facePoint then return facePoint end
            local head = asPart(char:FindFirstChild("Head"))
            if head then return head end
            local upperTorso = asPart(char:FindFirstChild("UpperTorso"))
            if upperTorso then return upperTorso end
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
            local upperTorso = asPart(char:FindFirstChild("UpperTorso"))
            if upperTorso then return upperTorso end
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
    local cachedTarget = nil
    local cachedTargetTime = 0

    local function getTargetPart()
        local now = tick()
        if cachedTarget and now - cachedTargetTime < Config.TargetCacheTime then
            if cachedTarget.Parent and cachedTarget.Parent.Parent then
                return cachedTarget
            end
            cachedTarget = nil
        end
        local closest, shortest = nil, Config.FOV
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
            if rootDist > Config.FOV + 100 then continue end
            local part = getHitPart(plr)
            if not part then continue end
            if Config.VisibleOnly and not hasLineOfSight(part) then continue end
            local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
            if not onScreen then continue end
            local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
            if dist < shortest then
                shortest = dist
                closest = part
            end
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
                local direction = (target.Position - origin).Unit * Config.MaxDistance
                local params = RaycastParams.new()
                params.FilterType = Enum.RaycastFilterType.Include
                params.FilterDescendantsInstances = { target }
                local newResult = workspace:Raycast(origin, direction, params)
                if newResult and newResult.Instance == target then
                    return oldDelegate(self, newResult, velocity, bullet, id)
                end
            end
            return oldDelegate(self, rayResult, velocity, bullet, id)
        end
    end

    local function hookAllCasters()
        local count = 0
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
                            local oldDelegate = conn.Delegate
                            if type(oldDelegate) == "function" then
                                conn.Delegate = buildDelegate(oldDelegate)
                                hookedCasters[caster] = true
                                count += 1
                            end
                        end
                    end
                end
            end
        end
        return count
    end

    local function watchCharacter(char)
        if not char then return end
        char.ChildAdded:Connect(function(child)
            if child:IsA("Tool") then
                task.wait(0.3)
                hookAllCasters()
            end
        end)
        char.ChildRemoved:Connect(function(child)
            if child:IsA("Tool") then
                task.wait(0.3)
                hookAllCasters()
            end
        end)
    end

    local function watchBackpack(bp)
        if not bp then return end
        bp.ChildAdded:Connect(function(child)
            if child:IsA("Tool") then
                task.wait(0.3)
                hookAllCasters()
            end
        end)
    end

    if lp.Character then watchCharacter(lp.Character) end
    if lp.Backpack then watchBackpack(lp.Backpack) end
    lp.CharacterAdded:Connect(function(char)
        watchCharacter(char)
        task.wait(1)
        hookAllCasters()
    end)
    lp.ChildAdded:Connect(function(child)
        if child.Name == "Backpack" then watchBackpack(child) end
    end)

    task.spawn(function()
        while true do
            task.wait(Config.WatchdogInterval)
            pcall(hookAllCasters)
        end
    end)

    task.wait(1)
    local n = hookAllCasters()
    print("[VANTA] silent loaded — hooked", n, "casters")
end

-- ============================================================
-- 2. ESP ИГРОКОВ
-- ============================================================
do
    local Config = {
        Enabled = true,
        MaxDistance = 500,
        ShowBox = true,
        ShowTracer = true,
        ShowHeadDot = true,
        ShowName = true,
        ShowDistance = true,
        ShowHealth = true,
        ShowTeam = true,
        ShowOffscreenArrows = true,
        BoxThickness = 1,
        CornerLength = 0.25,
        UseCornerBox = true,
        TracerOrigin = "bottom",
        EnemyColor = Color3.fromRGB(255, 60, 60),
        TeamColor = Color3.fromRGB(60, 255, 60),
        NameColor = Color3.fromRGB(255, 255, 255),
        DistanceColor = Color3.fromRGB(180, 180, 180),
        HeadDotColor = Color3.fromRGB(255, 255, 255),
        ArrowColor = Color3.fromRGB(255, 80, 80),
        ArrowSize = 14,
        ArrowOffset = 40,
        TeamCheck = true,
        UseHighlight = true,
        HighlightTransparency = 0.7,
        HighlightOutlineTransparency = 0.2,
    }

    local function isEnemy(plr)
        if not Config.TeamCheck then return true end
        if not lp.Team or not plr.Team then return true end
        return plr.Team ~= lp.Team
    end

    local function getTeamColor(plr)
        if not isEnemy(plr) then return Config.TeamColor end
        return Config.EnemyColor
    end

    local espCache = {}

    local function CreateHighlight(char)
        if not Config.UseHighlight then return nil end
        local ok, hl = pcall(function()
            local h = Instance.new("Highlight")
            h.Name = "VantaPlayerESP"
            h.FillTransparency = Config.HighlightTransparency
            h.OutlineTransparency = Config.HighlightOutlineTransparency
            h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            h.Adornee = char
            h.Parent = char
            return h
        end)
        if ok then return hl end
        return nil
    end

    local function CreateESP(plr)
        if espCache[plr] then return espCache[plr] end
        local data = {
            L1 = NewDrawing("Line", { Thickness=Config.BoxThickness, Visible=false }),
            L2 = NewDrawing("Line", { Thickness=Config.BoxThickness, Visible=false }),
            L3 = NewDrawing("Line", { Thickness=Config.BoxThickness, Visible=false }),
            L4 = NewDrawing("Line", { Thickness=Config.BoxThickness, Visible=false }),
            C1 = NewDrawing("Line", { Thickness=Config.BoxThickness+1, Visible=false }),
            C2 = NewDrawing("Line", { Thickness=Config.BoxThickness+1, Visible=false }),
            C3 = NewDrawing("Line", { Thickness=Config.BoxThickness+1, Visible=false }),
            C4 = NewDrawing("Line", { Thickness=Config.BoxThickness+1, Visible=false }),
            TopBar = NewDrawing("Line", { Thickness=2, Visible=false }),
            HpBg   = NewDrawing("Line", { Thickness=5, Color=Color3.fromRGB(0,0,0), Visible=false }),
            HpFill = NewDrawing("Line", { Thickness=4, Color=Color3.fromRGB(0,255,0), Visible=false }),
            Name = NewDrawing("Text", { Size=13, Center=true, Outline=true, Visible=false }),
            Team = NewDrawing("Text", { Size=11, Center=true, Outline=true, Visible=false }),
            Dist = NewDrawing("Text", { Size=11, Center=true, Outline=true, Visible=false }),
            Tracer  = NewDrawing("Line",     { Thickness=1, Visible=false }),
            HeadDot = NewDrawing("Circle",   { Thickness=1, Filled=true, NumSides=16, Radius=3, Visible=false }),
            Arrow   = NewDrawing("Triangle", { Thickness=2, Filled=true, Visible=false }),
            Highlight = nil,
            LastColor = nil,
        }
        espCache[plr] = data
        return data
    end

    local KEYS = {
        "L1","L2","L3","L4","C1","C2","C3","C4",
        "TopBar","HpBg","HpFill",
        "Name","Team","Dist",
        "Tracer","HeadDot","Arrow"
    }

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

    local function DrawCornerBox(data, x, y, w, h)
        local cl = math.floor(w * Config.CornerLength)
        local cs = math.floor(h * Config.CornerLength)
        data.C1.From=Vector2.new(x,y);     data.C1.To=Vector2.new(x+cl,y)
        data.C2.From=Vector2.new(x,y);     data.C2.To=Vector2.new(x,y+cs)
        data.C3.From=Vector2.new(x+w,y);   data.C3.To=Vector2.new(x+w-cl,y)
        data.C4.From=Vector2.new(x+w,y);   data.C4.To=Vector2.new(x+w,y+cs)
        data.L1.From=Vector2.new(x,y+h);   data.L1.To=Vector2.new(x+cl,y+h)
        data.L2.From=Vector2.new(x,y+h);   data.L2.To=Vector2.new(x,y+h-cs)
        data.L3.From=Vector2.new(x+w,y+h); data.L3.To=Vector2.new(x+w-cl,y+h)
        data.L4.From=Vector2.new(x+w,y+h); data.L4.To=Vector2.new(x+w,y+h-cs)
        for _, k in ipairs({"L1","L2","L3","L4","C1","C2","C3","C4"}) do
            data[k].Visible = true
        end
    end

    local function DrawFullBox(data, x, y, w, h)
        data.L1.From=Vector2.new(x,y);     data.L1.To=Vector2.new(x+w,y)
        data.L2.From=Vector2.new(x+w,y);   data.L2.To=Vector2.new(x+w,y+h)
        data.L3.From=Vector2.new(x+w,y+h); data.L3.To=Vector2.new(x,y+h)
        data.L4.From=Vector2.new(x,y+h);   data.L4.To=Vector2.new(x,y)
        for _, k in ipairs({"L1","L2","L3","L4"}) do data[k].Visible = true end
        for _, k in ipairs({"C1","C2","C3","C4"}) do data[k].Visible = false end
    end

    local function DrawArrow(data, worldPos)
        local vp = Camera.ViewportSize
        local center = Vector2.new(vp.X/2, vp.Y/2)
        local screenPos, onScreen = Camera:WorldToViewportPoint(worldPos)
        if onScreen and screenPos.Z > 0 then data.Arrow.Visible = false return end
        local dir = Vector2.new(screenPos.X, screenPos.Y) - center
        if dir.Magnitude < 1 then data.Arrow.Visible = false return end
        dir = dir.Unit
        local radius = math.min(vp.X, vp.Y) / 2 - Config.ArrowOffset
        local pos = center + dir * radius
        local perp = Vector2.new(-dir.Y, dir.X) * (Config.ArrowSize / 2)
        local tip = pos + dir * Config.ArrowSize
        data.Arrow.PointA = tip
        data.Arrow.PointB = pos - perp
        data.Arrow.PointC = pos + perp
        data.Arrow.Color = Config.ArrowColor
        data.Arrow.Visible = true
    end

    local function UpdateESP()
        if not Config.Enabled then
            for _, data in pairs(espCache) do HideESP(data) end
            return
        end
        local vp = Camera.ViewportSize
        local center = Vector2.new(vp.X/2, vp.Y/2)
        local tracerFrom = if Config.TracerOrigin == "bottom"
            then Vector2.new(vp.X/2, vp.Y) else center

        for plr, data in pairs(espCache) do
            if plr == lp then HideESP(data) continue end

            local char = plr.Character
            local hum  = char and char:FindFirstChildOfClass("Humanoid")
            if not char or not hum or hum.Health <= 0 or not char.Parent then
                HideESP(data) continue
            end

            if not isEnemy(plr) then HideESP(data) continue end

            local root = char:FindFirstChild("HumanoidRootPart")
            if not root then HideESP(data) continue end

            local rootScreen, rootOn = Camera:WorldToViewportPoint(root.Position)
            local distance = (Camera.CFrame.Position - root.Position).Magnitude

            if not rootOn or distance > Config.MaxDistance then
                HideESP(data)
                if Config.ShowOffscreenArrows and distance <= Config.MaxDistance then
                    DrawArrow(data, root.Position)
                end
                continue
            end

            local hipHeight = hum.HipHeight > 0 and hum.HipHeight or 2.5
            local topPos,    topOn    = Camera:WorldToViewportPoint(
                root.Position + Vector3.new(0, hipHeight + 1.5, 0))
            local bottomPos, bottomOn = Camera:WorldToViewportPoint(
                root.Position + Vector3.new(0, -hipHeight, 0))
            if not topOn or not bottomOn then HideESP(data) continue end

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
                data.HeadDot.Color = Config.HeadDotColor
            end

            if Config.ShowBox then
                if Config.UseCornerBox then
                    DrawCornerBox(data, x, y, width, height)
                else
                    DrawFullBox(data, x, y, width, height)
                end
                data.TopBar.From    = Vector2.new(x - 2, y - 1)
                data.TopBar.To      = Vector2.new(x + width + 2, y - 1)
                data.TopBar.Visible = true
            end

            if Config.ShowTracer then
                data.Tracer.From    = tracerFrom
                data.Tracer.To      = Vector2.new(bottomPos.X, bottomPos.Y)
                data.Tracer.Visible = true
            else data.Tracer.Visible = false end

            if Config.ShowHeadDot then
                local head = char:FindFirstChild("Head")
                if head and head:IsA("BasePart") then
                    local hp, hs = Camera:WorldToViewportPoint(head.Position)
                    if hs then
                        data.HeadDot.Position = Vector2.new(hp.X, hp.Y)
                        data.HeadDot.Visible  = true
                    else data.HeadDot.Visible = false end
                else data.HeadDot.Visible = false end
            end

            if Config.ShowName then
                data.Name.Text     = plr.Name
                data.Name.Position = Vector2.new(centerX, y - 30)
                data.Name.Color    = Config.NameColor
                data.Name.Visible  = true
            else data.Name.Visible = false end

            if Config.ShowTeam then
                data.Team.Text     = plr.Team and plr.Team.Name or "?"
                data.Team.Position = Vector2.new(centerX, y - 18)
                data.Team.Color    = color
                data.Team.Visible  = true
            else data.Team.Visible = false end

            if Config.ShowDistance then
                data.Dist.Text     = string.format("[%.0fm]", distance)
                data.Dist.Position = Vector2.new(centerX, y + height + 3)
                data.Dist.Color    = Config.DistanceColor
                data.Dist.Visible  = true
            else data.Dist.Visible = false end

            if Config.ShowHealth then
                local maxHp   = hum.MaxHealth > 0 and hum.MaxHealth or 100
                local hpRatio = math.clamp(hum.Health/maxHp, 0, 1)
                local barX = x - 8
                data.HpBg.From    = Vector2.new(barX, y)
                data.HpBg.To      = Vector2.new(barX, y + height)
                data.HpBg.Color   = Color3.fromRGB(0,0,0)
                data.HpBg.Visible = true
                local fillH = height * hpRatio
                data.HpFill.From    = Vector2.new(barX, y + height)
                data.HpFill.To      = Vector2.new(barX, y + height - fillH)
                data.HpFill.Color   = Color3.fromRGB(
                    math.floor(255*(1-hpRatio)),
                    math.floor(255*hpRatio), 0)
                data.HpFill.Visible = true
            else
                data.HpBg.Visible   = false
                data.HpFill.Visible = false
            end

            if not data.Highlight then data.Highlight = CreateHighlight(char) end
            if data.Highlight then
                data.Highlight.FillColor    = color
                data.Highlight.OutlineColor = color
                data.Highlight.Adornee      = char
                data.Highlight.Enabled      = true
            end

            data.Arrow.Visible = false
        end
    end

    local function AttachPlayer(plr)
        if plr == lp then return end
        CreateESP(plr)
        plr.CharacterAdded:Connect(function(char)
            local data = espCache[plr]
            if data and data.Highlight then
                pcall(function() data.Highlight:Destroy() end)
                data.Highlight = nil
            end
        end)
        plr.CharacterRemoving:Connect(function()
            local data = espCache[plr]
            if data and data.Highlight then
                pcall(function() data.Highlight:Destroy() end)
                data.Highlight = nil
            end
        end)
    end

    for _, plr in pairs(Players:GetPlayers()) do AttachPlayer(plr) end
    Players.PlayerAdded:Connect(AttachPlayer)
    Players.PlayerRemoving:Connect(function(plr)
        local data = espCache[plr]
        if data then DestroyESP(data) espCache[plr] = nil end
    end)

    RunService.RenderStepped:Connect(function() pcall(UpdateESP) end)
    print("[VANTA] player ESP loaded")
end

-- ============================================================
-- 3. NO RECOIL
-- ============================================================
do
    local Config = { WatchdogInterval = 3, ClearOnToolChange = true }
    local cachedTables = {}
    local lastToolHash = 0

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
        for obj in pairs(cachedTables) do
            if type(obj) == "table" then clearOne(obj)
            else cachedTables[obj] = nil end
        end
        if next(cachedTables) == nil then
            scanWeapons()
            for obj in pairs(cachedTables) do clearOne(obj) end
        end
    end

    local function toolHash(char)
        if not char then return 0 end
        local h = 0
        for _, c in pairs(char:GetChildren()) do
            if c:IsA("Tool") then h += 1 end
        end
        local bp = lp:FindFirstChildOfClass("Backpack")
        if bp then
            for _, c in pairs(bp:GetChildren()) do
                if c:IsA("Tool") then h += 1 end
            end
        end
        return h
    end

    local function watchCharacter(char)
        if not char then return end
        char.ChildAdded:Connect(function(child)
            if child:IsA("Tool") and Config.ClearOnToolChange then
                task.wait(0.3)
                cachedTables = {}
                scanWeapons()
                clearRecoil()
            end
        end)
        char.ChildRemoved:Connect(function(child)
            if child:IsA("Tool") and Config.ClearOnToolChange then
                task.wait(0.3)
                cachedTables = {}
                scanWeapons()
                clearRecoil()
            end
        end)
    end

    if lp.Character then watchCharacter(lp.Character) end
    lp.CharacterAdded:Connect(function(char)
        watchCharacter(char)
        task.wait(1)
        cachedTables = {}
        scanWeapons()
        clearRecoil()
    end)

    task.spawn(function()
        while true do
            task.wait(Config.WatchdogInterval)
            local h = toolHash(lp.Character)
            if h ~= lastToolHash then
                lastToolHash = h
                cachedTables = {}
                scanWeapons()
            end
            pcall(clearRecoil)
        end
    end)

    task.wait(1)
    scanWeapons()
    clearRecoil()
    print("[VANTA] norecoil loaded")
end

-- ============================================================
-- 4. RAPID FIRE
-- ============================================================
do
    local FIRE_RATE = 0.03
    local function patchSettings(t)
        if type(t) ~= "table" then return end
        for k, v in pairs(t) do
            local n = tostring(k):lower()
            if n == "firerate" then t[k] = FIRE_RATE end
        end
    end
    local function scanSettings()
        for _, obj in pairs(getgc(true)) do
            if type(obj) ~= "table" then continue end
            local hasFR, hasDmg = false, false
            for k in pairs(obj) do
                local n = tostring(k):lower()
                if n == "firerate" then hasFR = true end
                if n == "damage"   then hasDmg = true end
            end
            if hasFR and hasDmg then patchSettings(obj) end
        end
    end

    scanSettings()

    local function watchChar(c)
        c.ChildAdded:Connect(function(child)
            if child:IsA("Tool") then
                task.wait(0.5)
                scanSettings()
            end
        end)
    end

    if lp.Character then watchChar(lp.Character) end
    lp.CharacterAdded:Connect(watchChar)
    print("[VANTA] rapidfire loaded — FireRate =", FIRE_RATE)
end

-- ============================================================
-- 5. HITMARKER
-- ============================================================
do
    local Config = {
        Enabled = true,
        Size = 10,
        Thickness = 1.5,
        Gap = 4,
        Duration = 0.15,
        NormalColor   = Color3.fromRGB(255, 255, 255),
        HeadshotColor = Color3.fromRGB(255, 50, 50),
        KillColor     = Color3.fromRGB(255, 200, 0),
    }

    local lines = {}
    for i = 1, 4 do
        lines[i] = Drawing.new("Line")
        lines[i].Thickness = Config.Thickness
        lines[i].Color     = Config.NormalColor
        lines[i].Visible   = false
    end

    local activeMarkers = {}

    local function DrawMarker(x, y, color)
        local gap  = Config.Gap
        local size = Config.Size
        lines[1].From = Vector2.new(x-gap-size, y-gap-size)
        lines[1].To   = Vector2.new(x-gap, y-gap)
        lines[2].From = Vector2.new(x+gap, y-gap)
        lines[2].To   = Vector2.new(x+gap+size, y-gap-size)
        lines[3].From = Vector2.new(x-gap-size, y+gap+size)
        lines[3].To   = Vector2.new(x-gap, y+gap)
        lines[4].From = Vector2.new(x+gap, y+gap)
        lines[4].To   = Vector2.new(x+gap+size, y+gap+size)
        for i = 1, 4 do
            lines[i].Color   = color
            lines[i].Visible = true
        end
    end

    local function HideMarker()
        for i = 1, 4 do lines[i].Visible = false end
    end

    local function ShowHitmarker(isHeadshot, isKill)
        local color = Config.NormalColor
        if isKill then color = Config.KillColor
        elseif isHeadshot then color = Config.HeadshotColor end
        local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        DrawMarker(center.X, center.Y, color)
        table.insert(activeMarkers, { startTime = tick() })
    end

    RunService.RenderStepped:Connect(function()
        if not Config.Enabled then HideMarker() activeMarkers = {} return end
        local now = tick()
        local anyActive = false
        for i = #activeMarkers, 1, -1 do
            if now - activeMarkers[i].startTime >= Config.Duration then
                table.remove(activeMarkers, i)
            else
                anyActive = true
            end
        end
        if not anyActive then HideMarker() end
    end)

    local hookedCasters = {}

    local function isEnemyChar(char)
        local plr = Players:GetPlayerFromCharacter(char)
        if not plr then return false end
        if plr == lp then return false end
        if not lp.Team or not plr.Team then return true end
        return plr.Team ~= lp.Team
    end

    local function hookHitmarkerCasters()
        for _, obj in pairs(getgc(true)) do
            if type(obj) ~= "function" then continue end
            local ok, ups = pcall(debug.getupvalues, obj)
            if not ok or not ups then continue end
            for k, v in pairs(ups) do
                if type(v) == "table" and rawget(v, "caster") then
                    local caster = rawget(v, "caster")
                    if not hookedCasters[caster] and caster.RayHit then
                        hookedCasters[caster] = true
                        caster.RayHit:Connect(function(_, rayResult, _, _, _)
                            if not rayResult or not rayResult.Instance then return end
                            local hitPart = rayResult.Instance
                            local char = hitPart:FindFirstAncestorWhichIsA("Model")
                            if not char then return end
                            local hum = char:FindFirstChildOfClass("Humanoid")
                            if not hum then return end
                            if not isEnemyChar(char) then return end
                            local isHeadshot = (hitPart.Name == "Head")
                            local isKill     = (hum.Health <= 0)
                            ShowHitmarker(isHeadshot, isKill)
                        end)
                    end
                end
            end
        end
    end

    task.spawn(function()
        while true do
            task.wait(5)
            pcall(hookHitmarkerCasters)
        end
    end)

    task.wait(1)
    hookHitmarkerCasters()
    print("[VANTA] hitmarker loaded")
end

-- ============================================================
-- 6. NO FALL DAMAGE
-- ============================================================
do
    local function attachStateChanged(char)
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        hum.StateChanged:Connect(function(_, newState)
            if newState == Enum.HumanoidStateType.Landed then
                hum:SetAttribute("ClientTeleportTime", DateTime.now().UnixTimestampMillis)
            end
        end)
    end

    if lp.Character then attachStateChanged(lp.Character) end
    lp.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        attachStateChanged(char)
    end)

    print("[VANTA] no fall damage loaded")
end

-- ============================================================
-- 7. INSTANT RELOAD
-- ============================================================
do
    local Config = { Enabled = true, Threshold = 1, Cooldown = 0.1 }
    local gunInstances = {}
    local lastReload = 0

    local function findGuns()
        for _, obj in pairs(getgc(true)) do
            if type(obj) ~= "table" then continue end
            local settings = rawget(obj, "settings")
            local gunTool = rawget(obj, "gunTool")
            if type(settings) == "table" and typeof(gunTool) == "Instance" then
                gunInstances[obj] = true
            end
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
        if not Config.Enabled then return end
        local now = tick()
        if now - lastReload < Config.Cooldown then return end
        for gun in pairs(gunInstances) do
            local settings = rawget(gun, "settings")
            local gunTool = rawget(gun, "gunTool")
            if type(settings) ~= "table" or typeof(gunTool) ~= "Instance" then
                gunInstances[gun] = nil
                continue
            end
            local mag = gunTool:GetAttribute("CurrentMagazineCount") or settings.CurrentMagazineCount
            local magSize = settings.MagazineSize
            if type(mag) ~= "number" or type(magSize) ~= "number" then continue end
            if mag <= Config.Threshold and not gun.reloading and not gun.unloading then
                local reloadFn = getReloadMethod(gun)
                if reloadFn then
                    lastReload = now
                    task.spawn(function()
                        local wasEquipping = gun.equipping
                        gun.equipping = false
                        pcall(reloadFn, gun)
                        gun.equipping = wasEquipping
                    end)
                end
            end
        end
    end

    findGuns()
    lp.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        gunInstances = {}
        findGuns()
    end)
    if lp.Character then
        task.wait(0.5)
        findGuns()
    end
    task.spawn(function()
        while true do
            task.wait(0.1)
            pcall(instantReload)
        end
    end)
    task.spawn(function()
        while true do
            task.wait(3)
            pcall(findGuns)
        end
    end)
    print("[VANTA] instant reload loaded")
end

-- ============================================================
-- 8. ANTI-DECONTAMINATION
-- ============================================================
do
    local function disableDecon()
        for _, v in pairs(workspace:GetDescendants()) do
            if v:IsA("Script") or v:IsA("LocalScript") then
                local n = v.Name:lower()
                if n:find("decon") or n:find("decontam") then
                    v.Disabled = true
                end
            end
        end
    end
    task.spawn(function()
        task.wait(3)
        pcall(disableDecon)
    end)
    task.spawn(function()
        while true do
            task.wait(10)
            pcall(disableDecon)
        end
    end)
    print("[VANTA] anti-decon loaded")
end

-- ============================================================
-- 9. GRENADE ESP
-- ============================================================
do
    local Config = { Enabled = true, MaxDistance = 300, LineColor = Color3.fromRGB(255, 100, 0), TextColor = Color3.fromRGB(255, 200, 0) }
    local grenades = {}

    local function isGrenade(inst)
        if not inst:IsA("BasePart") and not inst:IsA("Model") then return false end
        local n = inst.Name:lower()
        if n:find("grenade") or n:find("frag") or n:find("flashbang") or n:find("scp-018") then return true end
        if inst.Name == "LiveGrenade" then return true end
        return false
    end

    local function getPos(g)
        if g:IsA("BasePart") then return g.Position end
        if g:IsA("Model") then
            local p = g.PrimaryPart or g:FindFirstChildWhichIsA("BasePart")
            if p then return p.Position end
        end
        return nil
    end

    local function createGrenadeESP(g)
        if grenades[g] then return grenades[g] end
        local data = {
            Line = NewDrawing("Line", { Thickness=2, Color=Config.LineColor, Visible=false }),
            Dot = NewDrawing("Circle", { Thickness=1, Filled=true, NumSides=16, Radius=5, Color=Config.LineColor, Visible=false }),
            Text = NewDrawing("Text", { Size=12, Center=true, Outline=true, Color=Config.TextColor, Visible=false }),
            LastText = nil,
        }
        grenades[g] = data
        return data
    end

    local function destroyGrenadeESP(data)
        if not data then return end
        if data.Line then pcall(function() data.Line:Remove() end) end
        if data.Dot then pcall(function() data.Dot:Remove() end) end
        if data.Text then pcall(function() data.Text:Remove() end) end
    end

    local function updateGrenadeESP()
        if not Config.Enabled then return end
        local camPos = Camera.CFrame.Position
        local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        for g, data in pairs(grenades) do
            if not g or not g.Parent then
                destroyGrenadeESP(data)
                grenades[g] = nil
                continue
            end
            local pos = getPos(g)
            if not pos then
                data.Line.Visible = false
                data.Dot.Visible = false
                data.Text.Visible = false
                continue
            end
            local dist = (camPos - pos).Magnitude
            if dist > Config.MaxDistance then
                data.Line.Visible = false
                data.Dot.Visible = false
                data.Text.Visible = false
                continue
            end
            local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
            if not onScreen or screenPos.Z < 0 then
                data.Line.Visible = false
                data.Dot.Visible = false
                data.Text.Visible = false
                continue
            end
            data.Line.From = Vector2.new(center.X, Camera.ViewportSize.Y)
            data.Line.To = Vector2.new(screenPos.X, screenPos.Y)
            data.Line.Color = Config.LineColor
            data.Line.Visible = true
            data.Dot.Position = Vector2.new(screenPos.X, screenPos.Y)
            data.Dot.Color = Config.LineColor
            data.Dot.Visible = true
            local text = string.format("GRENADE [%.0fm]", dist)
            if data.LastText ~= text then
                data.Text.Text = text
                data.LastText = text
            end
            data.Text.Position = Vector2.new(screenPos.X, screenPos.Y - 20)
            data.Text.Color = Config.TextColor
            data.Text.Visible = true
        end
    end

    local function scanGrenades()
        for _, v in pairs(workspace:GetDescendants()) do
            if isGrenade(v) and not grenades[v] then
                createGrenadeESP(v)
            end
        end
    end

    task.spawn(function() scanGrenades() end)
    workspace.DescendantAdded:Connect(function(child)
        if isGrenade(child) then
            task.wait(0.1)
            createGrenadeESP(child)
        end
    end)
    task.spawn(function()
        while true do
            task.wait(3)
            pcall(scanGrenades)
        end
    end)
    RunService.RenderStepped:Connect(function() pcall(updateGrenadeESP) end)
    print("[VANTA] grenade ESP loaded")
end

-- ============================================================
-- 10. GRENADE TIMER
-- ============================================================
do
    local Config = { Enabled = true, MaxDistance = 200, TextSize = 14, Color = Color3.fromRGB(255, 50, 50), WarnColor = Color3.fromRGB(255, 200, 0), WarnTime = 1.5 }
    local GRENADE_FUSE = 4
    local grenadeTimers = {}

    local function isLiveGrenade(inst)
        if inst.Name == "LiveGrenade" then return true end
        if inst:IsA("BasePart") and inst.Name:lower():find("grenade") then
            local parent = inst.Parent
            if parent and parent:IsA("Model") and parent.Name == "LiveGrenade" then return true end
        end
        return false
    end

    local function getPos(g)
        if g:IsA("BasePart") then return g.Position end
        if g:IsA("Model") then
            local p = g.PrimaryPart or g:FindFirstChildWhichIsA("BasePart")
            if p then return p.Position end
        end
        return nil
    end

    local function createTimer(g)
        if grenadeTimers[g] then return grenadeTimers[g] end
        local text = NewDrawing("Text", { Size = Config.TextSize, Center = true, Outline = true, Color = Config.Color, Visible = false })
        local data = { Text = text, SpawnTime = tick(), LastText = nil }
        grenadeTimers[g] = data
        return data
    end

    local function destroyTimer(data)
        if data and data.Text then
            pcall(function() data.Text:Remove() end)
        end
    end

    local function updateTimers()
        if not Config.Enabled then return end
        local camPos = Camera.CFrame.Position
        for g, data in pairs(grenadeTimers) do
            if not g or not g.Parent then
                destroyTimer(data)
                grenadeTimers[g] = nil
                continue
            end
            local pos = getPos(g)
            if not pos then data.Text.Visible = false continue end
            local dist = (camPos - pos).Magnitude
            if dist > Config.MaxDistance then data.Text.Visible = false continue end
            local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
            if not onScreen or screenPos.Z < 0 then data.Text.Visible = false continue end

            local elapsed = tick() - data.SpawnTime
            local remaining = math.max(0, GRENADE_FUSE - elapsed)
            local text = string.format("%.1fs", remaining)
            if data.LastText ~= text then
                data.Text.Text = text
                data.LastText = text
            end
            if remaining < Config.WarnTime then data.Text.Color = Config.WarnColor
            else data.Text.Color = Config.Color end
            data.Text.Position = Vector2.new(screenPos.X, screenPos.Y - 30)
            data.Text.Visible = true
        end
    end

    local function scanTimers()
        for _, v in pairs(workspace:GetDescendants()) do
            if isLiveGrenade(v) and not grenadeTimers[v] then
                createTimer(v)
            end
        end
    end

    task.spawn(function() scanTimers() end)
    workspace.DescendantAdded:Connect(function(child)
        if isLiveGrenade(child) then
            task.wait(0.05)
            createTimer(child)
        end
    end)
    task.spawn(function()
        while true do
            task.wait(2)
            pcall(scanTimers)
        end
    end)
    RunService.RenderStepped:Connect(function() pcall(updateTimers) end)
    print("[VANTA] grenade timer loaded")
end

print("[VANTA] all loaded")
