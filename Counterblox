if not _G.ZuniHub or not _G.ZuniHub.Ready then return end
local Z = _G.ZuniHub
if Z.MeuModuloLoaded then return end
Z.MeuModuloLoaded = true
Z.ModuleName = "Counter Blox"
local C, S, UI = Z.Colors, Z.SavedStates, Z.UI
local Player = game:GetService("Players").LocalPlayer

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

-- ============================================================
-- CONFIGURAÇÕES PADRÃO
-- ============================================================
if S.cb_esp_enabled == nil then S.cb_esp_enabled = false end
if S.cb_esp_box == nil then S.cb_esp_box = true end
if S.cb_esp_name == nil then S.cb_esp_name = true end
if S.cb_esp_health == nil then S.cb_esp_health = true end
if S.cb_esp_weapon == nil then S.cb_esp_weapon = true end
if S.cb_esp_distance == nil then S.cb_esp_distance = false end
if S.cb_esp_tracer == nil then S.cb_esp_tracer = true end
if S.cb_esp_head_dot == nil then S.cb_esp_head_dot = false end
if S.cb_esp_max_dist == nil then S.cb_esp_max_dist = 500 end
if S.cb_wallhack_enabled == nil then S.cb_wallhack_enabled = false end
if S.cb_aimbot_enabled == nil then S.cb_aimbot_enabled = false end
if S.cb_aimbot_fov == nil then S.cb_aimbot_fov = 120 end
if S.cb_aimbot_smooth == nil then S.cb_aimbot_smooth = 0.35 end
if S.cb_aimbot_max_dist == nil then S.cb_aimbot_max_dist = 400 end
if S.cb_aimbot_key == nil then S.cb_aimbot_key = "RMB" end

-- ============================================================
-- ESTADO INTERNO
-- ============================================================
local espObjects = {}
local wallhackObjects = {}
local aimbotTarget = nil
local aimbotHolding = false
local cachedWeapons = {}

local function getWeaponName(plr)
    local char = plr.Character
    if not char then return "?" end
    local weapon = char:FindFirstChild("Weapon")
    if weapon and weapon:IsA("Tool") then return weapon.Name end
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then return tool.Name end
    for _, v in ipairs(char:GetChildren()) do
        if v:IsA("Tool") then return v.Name end
    end
    return "Desarmado"
end

local function isAlive(plr)
    local char = plr.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    return true
end

local function isTeammate(plr)
    if not plr.Team or not Player.Team then return false end
    return plr.Team == Player.Team
end

local function worldToScreen(pos)
    local screen, onScreen = Camera:WorldToScreenPoint(pos)
    return Vector2.new(screen.X, screen.Y), onScreen
end

local function getDistance(plr)
    if not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then return 0 end
    local myChar = Player.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return 0 end
    return (myChar.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).Magnitude
end

-- ============================================================
-- ESP / WALLHACK
-- ============================================================
local function destroyESP(plr)
    if espObjects[plr] then
        for _, obj in pairs(espObjects[plr]) do
            if obj and obj.Destroy then pcall(obj.Destroy, obj) end
        end
        espObjects[plr] = nil
    end
end

local function destroyWallhack(plr)
    if wallhackObjects[plr] then
        pcall(function() wallhackObjects[plr]:Destroy() end)
        wallhackObjects[plr] = nil
    end
end

local function createWallhack(plr)
    if not S.cb_wallhack_enabled then return end
    if not isAlive(plr) or isTeammate(plr) then return end
    if wallhackObjects[plr] then return end
    local char = plr.Character
    if not char then return end
    local hl = Instance.new("Highlight")
    hl.Name = "ZuniWH"
    hl.Adornee = char
    hl.FillColor = C.Danger
    hl.OutlineColor = C.Text
    hl.FillTransparency = 0.55
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = char
    wallhackObjects[plr] = hl
end

local function createESP(plr)
    if not S.cb_esp_enabled then return end
    if not isAlive(plr) or isTeammate(plr) then return end
    if espObjects[plr] then return end

    local char = plr.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    if not head then return end

    local objs = {}

    -- Box
    if S.cb_esp_box then
        local box = Drawing.new("Square")
        box.Visible = false
        box.Color = C.Text
        box.Thickness = 1
        box.Filled = false
        box.Transparency = 0.85
        objs.box = box
    end

    -- Name + Health + Weapon Billboard
    if S.cb_esp_name or S.cb_esp_health or S.cb_esp_weapon then
        local bg = Instance.new("BillboardGui")
        bg.Name = "ZuniESP"
        bg.Size = UDim2.new(0, 180, 0, 52)
        bg.StudsOffset = Vector3.new(0, 2.8, 0)
        bg.AlwaysOnTop = true
        bg.MaxDistance = S.cb_esp_max_dist
        bg.Adornee = head
        bg.Parent = head

        local container = Instance.new("Frame")
        container.Size = UDim2.new(1, 0, 1, 0)
        container.BackgroundTransparency = 1
        container.Parent = bg

        local nameLbl = nil
        if S.cb_esp_name then
            nameLbl = Instance.new("TextLabel")
            nameLbl.Size = UDim2.new(1, 0, 0, 14)
            nameLbl.Position = UDim2.new(0, 0, 0, 0)
            nameLbl.BackgroundTransparency = 1
            nameLbl.Text = plr.Name
            nameLbl.TextColor3 = C.Text
            nameLbl.TextStrokeTransparency = 0
            nameLbl.TextStrokeColor3 = Color3.new(0, 0, 0)
            nameLbl.Font = Enum.Font.GothamBold
            nameLbl.TextSize = 12
            nameLbl.Parent = container
        end

        local hpLbl = nil
        if S.cb_esp_health then
            hpLbl = Instance.new("TextLabel")
            hpLbl.Size = UDim2.new(1, 0, 0, 12)
            hpLbl.Position = UDim2.new(0, 0, 0, 14)
            hpLbl.BackgroundTransparency = 1
            hpLbl.TextColor3 = C.Success
            hpLbl.TextStrokeTransparency = 0
            hpLbl.TextStrokeColor3 = Color3.new(0, 0, 0)
            hpLbl.Font = Enum.Font.GothamMedium
            hpLbl.TextSize = 10
            hpLbl.Parent = container
        end

        local wpLbl = nil
        if S.cb_esp_weapon then
            wpLbl = Instance.new("TextLabel")
            wpLbl.Size = UDim2.new(1, 0, 0, 12)
            wpLbl.Position = UDim2.new(0, 0, 0, 26)
            wpLbl.BackgroundTransparency = 1
            wpLbl.TextColor3 = C.Warning
            wpLbl.TextStrokeTransparency = 0
            wpLbl.TextStrokeColor3 = Color3.new(0, 0, 0)
            wpLbl.Font = Enum.Font.GothamMedium
            wpLbl.TextSize = 10
            wpLbl.Text = "Arma: ?"
            wpLbl.Parent = container
        end

        local distLbl = nil
        if S.cb_esp_distance then
            distLbl = Instance.new("TextLabel")
            distLbl.Size = UDim2.new(1, 0, 0, 12)
            distLbl.Position = UDim2.new(0, 0, 0, 38)
            distLbl.BackgroundTransparency = 1
            distLbl.TextColor3 = C.TextDim
            distLbl.TextStrokeTransparency = 0
            distLbl.TextStrokeColor3 = Color3.new(0, 0, 0)
            distLbl.Font = Enum.Font.GothamMedium
            distLbl.TextSize = 10
            distLbl.Parent = container
        end

        objs.billboard = bg
        objs.nameLbl = nameLbl
        objs.hpLbl = hpLbl
        objs.wpLbl = wpLbl
        objs.distLbl = distLbl
    end

    -- Tracer
    if S.cb_esp_tracer then
        local tracer = Drawing.new("Line")
        tracer.Visible = false
        tracer.Color = C.AccentLight
        tracer.Thickness = 1
        tracer.Transparency = 0.8
        objs.tracer = tracer
    end

    -- Head Dot
    if S.cb_esp_head_dot then
        local dot = Drawing.new("Circle")
        dot.Visible = false
        dot.Color = C.Danger
        dot.Thickness = 2
        dot.Filled = true
        dot.Radius = 3
        objs.dot = dot
    end

    espObjects[plr] = objs
end

local function updateESP(plr)
    local objs = espObjects[plr]
    if not objs then return end
    if not isAlive(plr) or not S.cb_esp_enabled then
        destroyESP(plr)
        return
    end

    local char = plr.Character
    local head = char and char:FindFirstChild("Head")
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not head or not hrp or not hum then
        destroyESP(plr)
        return
    end

    local dist = getDistance(plr)
    if dist > S.cb_esp_max_dist then
        if objs.box then objs.box.Visible = false end
        if objs.billboard then objs.billboard.Enabled = false end
        if objs.tracer then objs.tracer.Visible = false end
        if objs.dot then objs.dot.Visible = false end
        return
    end

    local headScreen, headOn = worldToScreen(head.Position + Vector3.new(0, 1, 0))
    local rootScreen, rootOn = worldToScreen(hrp.Position - Vector3.new(0, 3, 0))
    if not headOn and not rootOn then
        if objs.box then objs.box.Visible = false end
        if objs.billboard then objs.billboard.Enabled = false end
        if objs.tracer then objs.tracer.Visible = false end
        if objs.dot then objs.dot.Visible = false end
        return
    end

    if objs.box and headOn and rootOn then
        local h = math.abs(rootScreen.Y - headScreen.Y)
        local w = h * 0.55
        local x = headScreen.X - w / 2
        local y = headScreen.Y
        objs.box.Size = Vector2.new(w, h)
        objs.box.Position = Vector2.new(x, y)
        objs.box.Visible = true
    end

    if objs.billboard then
        objs.billboard.Enabled = true
        objs.billboard.MaxDistance = S.cb_esp_max_dist
        if objs.nameLbl then objs.nameLbl.Text = plr.Name end
        if objs.hpLbl then
            local hp = math.floor(hum.Health)
            local maxHp = math.floor(hum.MaxHealth)
            objs.hpLbl.Text = hp .. " / " .. maxHp
            local ratio = hum.Health / hum.MaxHealth
            if ratio > 0.6 then objs.hpLbl.TextColor3 = C.Success
            elseif ratio > 0.3 then objs.hpLbl.TextColor3 = C.Warning
            else objs.hpLbl.TextColor3 = C.Danger end
        end
        if objs.wpLbl then
            objs.wpLbl.Text = "Arma: " .. getWeaponName(plr)
        end
        if objs.distLbl then
            objs.distLbl.Text = "Dist: " .. math.floor(dist) .. "m"
        end
    end

    if objs.tracer then
        local screenPos = headScreen
        if screenPos then
            local vp = Camera.ViewportSize
            objs.tracer.From = Vector2.new(vp.X / 2, vp.Y)
            objs.tracer.To = screenPos
            objs.tracer.Visible = true
        else
            objs.tracer.Visible = false
        end
    end

    if objs.dot and headOn then
        objs.dot.Position = headScreen
        objs.dot.Visible = true
    elseif objs.dot then
        objs.dot.Visible = false
    end
end

-- ============================================================
-- AIMBOT
-- ============================================================
local function getClosestToCursor()
    local mouse = UIS:GetMouseLocation()
    local best = nil
    local bestDist = S.cb_aimbot_fov

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == Player then continue end
        if not isAlive(plr) or isTeammate(plr) then continue end
        local char = plr.Character
        local head = char and char:FindFirstChild("Head")
        if not head then continue end
        local dist = getDistance(plr)
        if dist > S.cb_aimbot_max_dist then continue end

        local screen, onScreen = worldToScreen(head.Position)
        if onScreen then
            local d = (mouse - screen).Magnitude
            if d < bestDist then
                bestDist = d
                best = plr
            end
        end
    end
    return best
end

local function doAimbot()
    if not S.cb_aimbot_enabled then return end
    if not aimbotHolding then return end

    local target = getClosestToCursor()
    if not target then return end
    local char = target.Character
    local head = char and char:FindFirstChild("Head")
    if not head then return end

    local targetPos = head.Position
    local camPos = Camera.CFrame.Position
    local goal = CFrame.new(camPos, targetPos)
    Camera.CFrame = Camera.CFrame:Lerp(goal, S.cb_aimbot_smooth)
end

-- ============================================================
-- LOOPS
-- ============================================================
Z.PageLoop("cb_esp_loop", function()
    if not Z.Alive then return end
    for plr, _ in pairs(espObjects) do
        updateESP(plr)
    end
    if S.cb_esp_enabled then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= Player then
                if isAlive(plr) and not isTeammate(plr) then
                    createESP(plr)
                else
                    destroyESP(plr)
                end
            end
        end
    else
        for plr, _ in pairs(espObjects) do
            destroyESP(plr)
        end
    end
end)

Z.PageLoop("cb_wh_loop", function()
    if not Z.Alive then return end
    if S.cb_wallhack_enabled then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= Player and isAlive(plr) and not isTeammate(plr) then
                createWallhack(plr)
            end
        end
    else
        for plr, _ in pairs(wallhackObjects) do
            destroyWallhack(plr)
        end
    end
end)

Z.PageLoop("cb_aim_loop", function()
    if not Z.Alive then return end
    doAimbot()
end)

-- ============================================================
-- INPUT
-- ============================================================
local function isAimbotKey(input)
    if S.cb_aimbot_key == "RMB" then return input.UserInputType == Enum.UserInputType.MouseButton2 end
    if S.cb_aimbot_key == "LMB" then return input.UserInputType == Enum.UserInputType.MouseButton1 end
    if S.cb_aimbot_key == "E" then return input.KeyCode == Enum.KeyCode.E end
    if S.cb_aimbot_key == "Q" then return input.KeyCode == Enum.KeyCode.Q end
    return false
end

Z.Track(UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if isAimbotKey(input) then aimbotHolding = true end
end))

Z.Track(UIS.InputEnded:Connect(function(input, gpe)
    if isAimbotKey(input) then aimbotHolding = false end
end))

-- ============================================================
-- PLAYER EVENTS
-- ============================================================
Z.Track(Players.PlayerRemoving:Connect(function(plr)
    destroyESP(plr)
    destroyWallhack(plr)
end))

-- ============================================================
-- UI
-- ============================================================
local function LoadMain()
    -- ESP
    Z.Sep("ESP / Visuals")
    Z.Toggle("Ativar ESP", S.cb_esp_enabled, function(v)
        S.cb_esp_enabled = v
        if not v then
            for plr, _ in pairs(espObjects) do destroyESP(plr) end
        end
    end)
    Z.Toggle("Box", S.cb_esp_box, function(v) S.cb_esp_box = v end)
    Z.Toggle("Nome", S.cb_esp_name, function(v) S.cb_esp_name = v end)
    Z.Toggle("Vida", S.cb_esp_health, function(v) S.cb_esp_health = v end)
    Z.Toggle("Arma na Mao", S.cb_esp_weapon, function(v) S.cb_esp_weapon = v end)
    Z.Toggle("Distancia", S.cb_esp_distance, function(v) S.cb_esp_distance = v end)
    Z.Toggle("Tracer", S.cb_esp_tracer, function(v) S.cb_esp_tracer = v end)
    Z.Toggle("Ponto na Cabeca", S.cb_esp_head_dot, function(v) S.cb_esp_head_dot = v end)
    Z.Slider("Distancia Max ESP", 50, 2000, S.cb_esp_max_dist, function(v) S.cb_esp_max_dist = v end)

    -- Wallhack
    Z.Sep("Wallhack")
    Z.Toggle("Ativar Wallhack", S.cb_wallhack_enabled, function(v)
        S.cb_wallhack_enabled = v
        if not v then
            for plr, _ in pairs(wallhackObjects) do destroyWallhack(plr) end
        end
    end)

    -- Aimbot
    Z.Sep("Aimbot")
    Z.Toggle("Ativar Aimbot", S.cb_aimbot_enabled, function(v)
        S.cb_aimbot_enabled = v
        if not v then aimbotHolding = false end
    end)
    Z.Slider("FOV", 10, 500, S.cb_aimbot_fov, function(v) S.cb_aimbot_fov = v end)
    Z.Slider("Suavidade", 0.05, 1, S.cb_aimbot_smooth, function(v) S.cb_aimbot_smooth = v end)
    Z.Slider("Distancia Max", 50, 1000, S.cb_aimbot_max_dist, function(v) S.cb_aimbot_max_dist = v end)
    Z.Dropdown("Tecla de Mira", {"RMB", "LMB", "E", "Q"}, S.cb_aimbot_key, function(v)
        S.cb_aimbot_key = v
    end)

    Z.Info("Aimbot: Segure a tecla selecionada para puxar a mira na cabeca do inimigo mais proximo do cursor.")
    Z.Info("ESP mostra Nome, Vida e Arma na mao em tempo real.")
end

Z.AddTab("Counter Blox", "crosshair", LoadMain)
Z.SelectTab("Counter Blox")
Z.Notify("Counter Blox", "Modulo carregado. ESP detalhado + Aimbot na cabeca prontos.", 4)
