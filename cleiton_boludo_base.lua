-- ╔══════════════════════════════════════════════════════════════════════╗
-- ║  CLEITON BOLUDO HUB - BASE v7.1 (completa)                         ║
-- ║  UI Black & White (glass + gradientes + glow)                      ║
-- ║  Widgets estáveis, Infinite Jump, Anti-AFK, Home/Player            ║
-- ╚══════════════════════════════════════════════════════════════════════╝

local Players            = game:GetService("Players")
local UIS                = game:GetService("UserInputService")
local TweenService       = game:GetService("TweenService")
local RunService         = game:GetService("RunService")
local TeleportService    = game:GetService("TeleportService")
local MarketplaceService = game:GetService("MarketplaceService")
local TextService        = game:GetService("TextService")

local Player    = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- ═══════════════════════════════════════════════════════════════════════
-- PALETA / FONTES (Preto & Branco)
-- ═══════════════════════════════════════════════════════════════════════
local Colors = {
    Bg          = Color3.fromRGB(8, 8, 8),
    Sidebar     = Color3.fromRGB(15, 15, 15),
    Card        = Color3.fromRGB(22, 22, 22),
    CardHover   = Color3.fromRGB(35, 35, 35),
    CardSoft    = Color3.fromRGB(28, 28, 28),
    Accent      = Color3.fromRGB(255, 255, 255),
    AccentLight = Color3.fromRGB(220, 220, 220),
    AccentDark  = Color3.fromRGB(150, 150, 150),
    Purple      = Color3.fromRGB(200, 200, 200),
    Success     = Color3.fromRGB(255, 255, 255),
    Warning     = Color3.fromRGB(180, 180, 180),
    Danger      = Color3.fromRGB(120, 120, 120),
    Text        = Color3.fromRGB(255, 255, 255),
    TextDim     = Color3.fromRGB(180, 180, 180),
    TextMuted   = Color3.fromRGB(120, 120, 120),
    Border      = Color3.fromRGB(60, 60, 60),
    BorderSoft  = Color3.fromRGB(40, 40, 40),
    Divider     = Color3.fromRGB(45, 45, 45),
}

local F_REG, F_MED, F_BOLD, F_BLACK =
    Enum.Font.Gotham, Enum.Font.GothamMedium, Enum.Font.GothamBold, Enum.Font.GothamBlack

local MOUSE_ICON  = "rbxassetid://11202664265"
local ICON_FAMILY = "rbxasset://LuaPackages/Packages/_Index/BuilderIcons/BuilderIcons/BuilderIcons.json"

local WHITE     = Color3.new(1, 1, 1)
local SOFT_GRAY = Color3.fromRGB(200, 200, 200)

-- ═══════════════════════════════════════════════════════════════════════
-- LIMPEZA + ONDE CRIAR A GUI
-- ═══════════════════════════════════════════════════════════════════════
local function SafeParent()
    local ok, h = pcall(function() return gethui and gethui() end)
    if ok and typeof(h) == "Instance" then return h end
    local ok2, cg = pcall(function() return game:GetService("CoreGui") end)
    if ok2 and cg then
        local t = Instance.new("Folder")
        local ok3 = pcall(function() t.Parent = cg end)
        pcall(function() t:Destroy() end)
        if ok3 then return cg end
    end
    return PlayerGui
end
local GuiParent = SafeParent()

do
    if _G.CleitonBoludoHub then
        pcall(function()
            if _G.CleitonBoludoHub.Destroy then _G.CleitonBoludoHub.Destroy() else _G.CleitonBoludoHub.Alive = false end
        end)
        _G.CleitonBoludoHub = nil
    end
    local roots = { PlayerGui, GuiParent }
    pcall(function() table.insert(roots, game:GetService("CoreGui")) end)
    for _, root in ipairs(roots) do
        pcall(function()
            for _, n in ipairs({ "CleitonBoludo", "CleitonNotify", "CleitonESP", "ZuniHub" }) do
                local g = root:FindFirstChild(n)
                if g then g:Destroy() end
            end
        end)
    end
end

local Z = {
    Version = "7.1", Alive = true, Ready = false,
    Colors = Colors, SavedStates = {}, UI = {}, Connections = {},
    Tabs = {}, TabOrder = {}, CurrentTab = nil,
    ModuleName = "Nenhum", PageGen = 0, IsVisible = false,
    FPS = 60, StartTime = tick(),
}
_G.CleitonBoludoHub = Z
local S = Z.SavedStates

function Z.Track(conn)
    if conn then table.insert(Z.Connections, conn) end
    return conn
end
function Z.DisconnectAll()
    for _, c in ipairs(Z.Connections) do pcall(function() c:Disconnect() end) end
    table.clear(Z.Connections)
end

-- ═══════════════════════════════════════════════════════════════════════
-- HELPERS
-- ═══════════════════════════════════════════════════════════════════════
local function New(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props) do o[k] = v end
    if parent then o.Parent = parent end
    return o
end
local function Corner(o, r) return New("UICorner", { CornerRadius = UDim.new(0, r) }, o) end
local function Stroke(o, color, thick, transp)
    return New("UIStroke", {
        Color = color, Thickness = thick or 1, Transparency = transp or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, o)
end
local function Tween(o, t, props, style, dir)
    local tw = TweenService:Create(o, TweenInfo.new(t, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
    tw:Play()
    return tw
end
local function Label(parent, text, size, color, font, pos, sz, align)
    return New("TextLabel", {
        BackgroundTransparency = 1, Text = text, TextSize = size, TextColor3 = color,
        Font = font or F_REG, Position = pos or UDim2.new(), Size = sz or UDim2.fromScale(1, 1),
        TextXAlignment = align or Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, parent)
end
local function Gradient(o, c0, c1, rot, transparency)
    return New("UIGradient", {
        Color = ColorSequence.new(c0, c1), Rotation = rot or 90,
        Transparency = transparency or NumberSequence.new(0),
    }, o)
end
local function Safe(cb, ...)
    if not cb then return end
    local ok, err = pcall(cb, ...)
    if not ok then warn("[CleitonHub] " .. tostring(err)) end
end
local function IsPointer(i)
    return i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch
end

local function NoEmoji(s)
    s = tostring(s == nil and "" or s)
    local ok, out = pcall(function()
        local t = {}
        for _, cp in utf8.codes(s) do
            local bad = (cp >= 0x1F000 and cp <= 0x1FAFF)
                or (cp >= 0x2600 and cp <= 0x27BF)
                or (cp >= 0x2B00 and cp <= 0x2BFF)
                or (cp >= 0x2300 and cp <= 0x23FF)
                or cp == 0xFE0F or cp == 0x200D or cp == 0x20E3
            if not bad then t[#t + 1] = utf8.char(cp) end
        end
        return table.concat(t)
    end)
    if not ok then return s end
    return (out:gsub("^%s+", ""))
end

local function Icon(name)
    return string.format('<font family="%s">%s</font>', ICON_FAMILY, name)
end

local EMOJI_ICONS = {
    { "🏠", "house" }, { "👤", "person" }, { "🧍", "person" }, { "⚙", "gear" },
    { "🔧", "gear" }, { "📦", "box" }, { "🎒", "backpack" }, { "🍃", "leaf" },
    { "🌿", "leaf" }, { "🌱", "leaf" }, { "🌲", "leaf" },
}
local NAME_ICONS = {
    { "home", "house" }, { "main", "house" }, { "inicio", "house" }, { "início", "house" },
    { "player", "person" }, { "jogador", "person" }, { "players", "person" },
    { "grab", "backpack" }, { "pegar", "backpack" }, { "coleta", "backpack" }, { "item", "backpack" },
    { "chunk", "leaf" }, { "map", "leaf" }, { "mapa", "leaf" },
    { "preset", "box" }, { "misc", "gear" }, { "config", "gear" }, { "setting", "gear" },
}
local function ResolveIcon(icon, tabName)
    icon = tostring(icon or "")
    if icon:find("<font", 1, true) then return icon end
    if icon:match("^[%a][%a%d%-]*$") then return Icon(icon:lower()) end
    for _, pair in ipairs(EMOJI_ICONS) do
        if icon:find(pair[1], 1, true) then return Icon(pair[2]) end
    end
    local lname = string.lower(tostring(tabName or ""))
    for _, pair in ipairs(NAME_ICONS) do
        if lname:find(pair[1], 1, true) then return Icon(pair[2]) end
    end
    return Icon("box")
end

Z.Icon = Icon
Z.Util = {
    New = New, Corner = Corner, Stroke = Stroke, Tween = Tween, Label = Label,
    Gradient = Gradient, Icon = Icon, NoEmoji = NoEmoji,
}

-- ═══════════════════════════════════════════════════════════════════════
-- SCREEN GUIS
-- ═══════════════════════════════════════════════════════════════════════
local Hub = New("ScreenGui", {
    Name = "CleitonBoludo", ResetOnSpawn = false, IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 999,
}, GuiParent)
local NotifyGui = New("ScreenGui", {
    Name = "CleitonNotify", ResetOnSpawn = false, IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 1000,
}, GuiParent)

-- ═══════════════════════════════════════════════════════════════════════
-- NOTIFICAÇÕES
-- ═══════════════════════════════════════════════════════════════════════
local NotifyHolder = New("Frame", {
    BackgroundTransparency = 1, Size = UDim2.new(0, 340, 1, -24), Position = UDim2.new(1, -356, 0, 18),
}, NotifyGui)
New("UIListLayout", { Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder }, NotifyHolder)
local notifyN = 0

function Z.Notify(title, text, color, duration)
    if not Z.Alive or not NotifyHolder.Parent then return end
    color, duration = color or Colors.Accent, duration or 4
    notifyN += 1
    title, text = NoEmoji(title), NoEmoji(text or "")

    local textH = 0
    if text ~= "" then
        local ok, sz = pcall(function()
            return TextService:GetTextSize(text, 12, F_REG, Vector2.new(294, 1000))
        end)
        textH = ok and sz.Y or 16
    end
    local H = math.max(54, 32 + textH + 16)

    local slot = New("Frame", {
        Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, LayoutOrder = notifyN,
    }, NotifyHolder)
    local mover = New("Frame", {
        Size = UDim2.new(1, 0, 0, H), Position = UDim2.fromOffset(70, 0), BackgroundTransparency = 1,
    }, slot)

    local glow = New("Frame", {
        Size = UDim2.new(1, 6, 1, 6), Position = UDim2.fromOffset(-3, -3), BackgroundTransparency = 1, BorderSizePixel = 0,
    }, mover)
    Corner(glow, 16)
    local glowStroke = Stroke(glow, color, 3, 1)

    local toast = New("CanvasGroup", {
        Size = UDim2.fromScale(1, 1), BackgroundColor3 = WHITE, BackgroundTransparency = 0.02,
        BorderSizePixel = 0, GroupTransparency = 1,
    }, mover)
    Corner(toast, 13)
    Gradient(toast, Colors.Card:Lerp(color, 0.1), Colors.Bg, 0)

    local outline = New("Frame", {
        Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 5,
    }, mover)
    Corner(outline, 13)
    local st = Stroke(outline, color, 1, 1)

    local strip = New("Frame", {
        Size = UDim2.new(0, 3, 1, 0), BackgroundColor3 = WHITE, BorderSizePixel = 0,
    }, toast)
    Gradient(strip, color:Lerp(WHITE, 0.3), color, 90)

    local dot = New("Frame", {
        Size = UDim2.fromOffset(8, 8), Position = UDim2.fromOffset(16, 15), BackgroundColor3 = color, BorderSizePixel = 0,
    }, toast)
    Corner(dot, 4)
    Stroke(dot, color, 3, 0.75)

    Label(toast, title, 13, Colors.Text, F_BOLD, UDim2.fromOffset(32, 9), UDim2.new(1, -46, 0, 20))
    if text ~= "" then
        New("TextLabel", {
            BackgroundTransparency = 1, Text = text, Font = F_REG, TextSize = 12, TextColor3 = Colors.TextDim,
            TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
            Position = UDim2.fromOffset(32, 31), Size = UDim2.new(1, -46, 0, textH),
        }, toast)
    end

    New("Frame", {
        Size = UDim2.new(1, 0, 0, 3), Position = UDim2.new(0, 0, 1, -3),
        BackgroundColor3 = WHITE, BackgroundTransparency = 0.94, BorderSizePixel = 0,
    }, toast)
    local bar = New("Frame", {
        Size = UDim2.new(1, 0, 0, 3), Position = UDim2.new(0, 0, 1, -3),
        BackgroundColor3 = WHITE, BorderSizePixel = 0,
    }, toast)
    Gradient(bar, color, color:Lerp(WHITE, 0.45), 0)

    local ease = Enum.EasingStyle.Quad
    Tween(slot, 0.25, { Size = UDim2.new(1, 0, 0, H) }, ease)
    Tween(mover, 0.4, { Position = UDim2.fromOffset(0, 0) }, Enum.EasingStyle.Quint)
    Tween(toast, 0.3, { GroupTransparency = 0 }, ease)
    Tween(st, 0.3, { Transparency = 0.5 }, ease)
    Tween(glowStroke, 0.3, { Transparency = 0.88 }, ease)
    Tween(bar, duration, { Size = UDim2.new(0, 0, 0, 3) }, Enum.EasingStyle.Linear)

    task.delay(duration, function()
        if not slot.Parent then return end
        Tween(mover, 0.25, { Position = UDim2.fromOffset(70, 0) }, ease, Enum.EasingDirection.In)
        Tween(toast, 0.25, { GroupTransparency = 1 }, ease, Enum.EasingDirection.In)
        Tween(st, 0.25, { Transparency = 1 }, ease, Enum.EasingDirection.In)
        Tween(glowStroke, 0.25, { Transparency = 1 }, ease, Enum.EasingDirection.In)
        task.delay(0.22, function()
            if not slot.Parent then return end
            local tw = Tween(slot, 0.2, { Size = UDim2.new(1, 0, 0, 0) }, ease)
            tw.Completed:Connect(function() pcall(function() slot:Destroy() end) end)
        end)
    end)
end

-- ═══════════════════════════════════════════════════════════════════════
-- JANELA PRINCIPAL (glass)
-- ═══════════════════════════════════════════════════════════════════════
local WIN_W, WIN_H = 760, 540

local Main = New("Frame", {
    Name = "Main", Size = UDim2.fromOffset(WIN_W, WIN_H), Position = UDim2.fromScale(0.5, 0.5),
    AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = WHITE, BackgroundTransparency = 0.15,
    BorderSizePixel = 0, Visible = false, Active = true,
}, Hub)
Corner(Main, 18)
Stroke(Main, Colors.Border, 1, 0.4)
Gradient(Main, Colors.Bg, Colors.Sidebar, 135)
local WinScale = New("UIScale", { Scale = 1 }, Main)

local function Viewport()
    local cam = workspace.CurrentCamera
    return cam and cam.ViewportSize or Vector2.new(1280, 720)
end
local function TargetScale()
    local vp = Viewport()
    return math.clamp(math.min((vp.X - 24) / WIN_W, (vp.Y - 24) / WIN_H), 0.5, 1)
end

-- Sidebar ---------------------------------------------------------------
local Sidebar = New("Frame", {
    Size = UDim2.new(0, 200, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, ClipsDescendants = true,
}, Main)
local SideBg = New("Frame", {
    Size = UDim2.new(1, 30, 1, 0), BackgroundColor3 = WHITE, BackgroundTransparency = 0.3, BorderSizePixel = 0,
}, Sidebar)
Corner(SideBg, 18)
Gradient(SideBg, Colors.Sidebar, Colors.Bg, 90)
New("Frame", {
    Size = UDim2.new(0, 1, 1, -36), Position = UDim2.new(1, -1, 0, 18),
    BackgroundColor3 = Colors.Border, BackgroundTransparency = 0.55, BorderSizePixel = 0,
}, Sidebar)

local LogoCard = New("Frame", {
    Size = UDim2.new(1, -28, 0, 62), Position = UDim2.fromOffset(14, 16),
    BackgroundColor3 = Colors.Card, BackgroundTransparency = 0.1, BorderSizePixel = 0, Active = true,
}, Sidebar)
Corner(LogoCard, 14)
Gradient(LogoCard, WHITE, SOFT_GRAY, 90)
Stroke(LogoCard, Colors.Accent, 1, 0.55)
local logoTitle = Label(LogoCard, "CLEITON BOLUDO", 20, WHITE, F_BLACK, UDim2.fromOffset(16, 7), UDim2.new(1, -24, 0, 30))
Gradient(logoTitle, Colors.Text, Colors.AccentLight, 0)
Label(LogoCard, "HUB  v" .. Z.Version, 10, Colors.AccentLight, F_MED, UDim2.fromOffset(17, 37), UDim2.new(1, -24, 0, 16))

local TabsScroll = New("ScrollingFrame", {
    Size = UDim2.new(1, -20, 1, -170), Position = UDim2.fromOffset(10, 94),
    BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 2,
    ScrollBarImageColor3 = Colors.Accent, CanvasSize = UDim2.new(),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
}, Sidebar)
New("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, TabsScroll)
New("UIPadding", {
    PaddingLeft = UDim.new(0, 3), PaddingRight = UDim.new(0, 3), PaddingTop = UDim.new(0, 3), PaddingBottom = UDim.new(0, 3),
}, TabsScroll)

New("TextLabel", {
    BackgroundTransparency = 1, Text = "INSERT ou R-CTRL\nmostra / esconde o hub",
    Font = F_REG, TextSize = 10, TextColor3 = Colors.TextMuted, TextWrapped = true,
    Position = UDim2.new(0, 16, 1, -52), Size = UDim2.new(1, -28, 0, 38),
    TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
}, Sidebar)

-- Conteúdo --------------------------------------------------------------
local Content = New("Frame", {
    Size = UDim2.new(1, -200, 1, 0), Position = UDim2.fromOffset(200, 0), BackgroundTransparency = 1,
}, Main)

local Header = New("Frame", {
    Size = UDim2.new(1, 0, 0, 64), BackgroundTransparency = 1, Active = true,
}, Content)
local TabTitle = Label(Header, "Home", 22, Colors.Text, F_BLACK, UDim2.fromOffset(24, 0), UDim2.new(1, -130, 1, 0))
TabTitle.RichText = true
local hLine = New("Frame", {
    Size = UDim2.new(1, -40, 0, 2), Position = UDim2.fromOffset(20, 64), BackgroundColor3 = WHITE, BorderSizePixel = 0,
}, Content)
Corner(hLine, 1)
New("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Colors.Accent), ColorSequenceKeypoint.new(0.5, Colors.Purple), ColorSequenceKeypoint.new(1, Colors.Accent),
    }),
    Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.15), NumberSequenceKeypoint.new(1, 0.95),
    }),
}, hLine)

local Scroll = New("ScrollingFrame", {
    Size = UDim2.new(1, -40, 1, -92), Position = UDim2.fromOffset(20, 78),
    BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 4,
    ScrollBarImageColor3 = Colors.Accent, CanvasSize = UDim2.new(),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
}, Content)
New("UIListLayout", { Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder }, Scroll)
New("UIPadding", {
    PaddingLeft = UDim.new(0, 2), PaddingRight = UDim.new(0, 10), PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 14),
}, Scroll)

local Popup = New("Frame", {
    Name = "Popup", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 50,
}, Main)

-- ═══════════════════════════════════════════════════════════════════════
-- PÁGINAS
-- ═══════════════════════════════════════════════════════════════════════
local PageConns = {}
local order = 0
local function NextOrder() order += 1 return order end

Z.GUI = { Hub = Hub, Main = Main, Sidebar = Sidebar, Scroll = Scroll, Content = Content, TabTitle = TabTitle }

function Z.GUI.Clear()
    Z.PageGen += 1
    for _, c in ipairs(PageConns) do pcall(function() c:Disconnect() end) end
    table.clear(PageConns)
    for k in pairs(Z.UI) do Z.UI[k] = nil end
    for _, v in ipairs(Scroll:GetChildren()) do
        if not (v:IsA("UIListLayout") or v:IsA("UIPadding")) then v:Destroy() end
    end
    Scroll.CanvasPosition = Vector2.zero
    Scroll.ScrollingEnabled = true
    order = 0
end
function Z.PageTrack(conn) table.insert(PageConns, conn) return conn end
function Z.PageLoop(interval, fn)
    local gen = Z.PageGen
    task.spawn(function()
        while Z.Alive and Z.PageGen == gen do
            local ok, err = pcall(fn)
            if not ok then warn("[Cleiton] PageLoop: " .. tostring(err)) end
            task.wait(interval)
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════
-- WIDGETS
-- ═══════════════════════════════════════════════════════════════════════
local function CardHover(card, on)
    if not card.Parent then return end
    Tween(card, 0.18, { BackgroundColor3 = on and Colors.CardHover or Colors.Card })
end

local function Card(height)
    local f = New("Frame", {
        Size = UDim2.new(1, 0, 0, height), BackgroundColor3 = Colors.Card, BackgroundTransparency = 0.05,
        BorderSizePixel = 0, LayoutOrder = NextOrder(),
    }, Scroll)
    Corner(f, 14)
    Gradient(f, WHITE, SOFT_GRAY, 90)
    local st = Stroke(f, Colors.Border, 1, 0.5)
    f.MouseEnter:Connect(function() CardHover(f, true) end)
    f.MouseLeave:Connect(function() CardHover(f, false) end)
    return f, st
end
Z.Card = Card

function Z.Sep(text)
    local f = New("Frame", { Size = UDim2.new(1, 0, 0, 36), BackgroundTransparency = 1, LayoutOrder = NextOrder() }, Scroll)
    local bar = New("Frame", {
        Size = UDim2.fromOffset(3, 16), Position = UDim2.fromOffset(4, 10),
        BackgroundColor3 = WHITE, BorderSizePixel = 0,
    }, f)
    Corner(bar, 2)
    Gradient(bar, Colors.Accent, Colors.Purple, 90)
    Label(f, NoEmoji(text), 12, Colors.AccentLight, F_BOLD, UDim2.fromOffset(18, 6), UDim2.new(1, -18, 0, 24))
    local line = New("Frame", {
        Size = UDim2.new(1, -4, 0, 1), Position = UDim2.new(0, 2, 1, -4),
        BackgroundColor3 = Colors.Accent, BorderSizePixel = 0,
    }, f)
    New("UIGradient", {
        Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.55), NumberSequenceKeypoint.new(1, 1) }),
    }, line)
    return f
end

function Z.Info(text)
    local l = New("TextLabel", {
        Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1,
        Text = NoEmoji(text), Font = F_REG, TextSize = 12, TextColor3 = Colors.TextDim, TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, LayoutOrder = NextOrder(),
        LineHeight = 1.3,
    }, Scroll)
    New("UIPadding", { PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6), PaddingBottom = UDim.new(0, 4) }, l)
    return l
end

function Z.Stat(name, value)
    local card = Card(46)
    Label(card, NoEmoji(name), 12, Colors.TextDim, F_MED, UDim2.fromOffset(18, 0), UDim2.new(0.5, -18, 1, 0))
    local v = Label(card, tostring(value), 14, Colors.Text, F_BOLD, UDim2.fromScale(0.5, 0), UDim2.new(0.5, -18, 1, 0), Enum.TextXAlignment.Right)
    return {
        Frame = card,
        Set = function(text, color)
            if not v.Parent then return end
            v.Text = tostring(text)
            if color then v.TextColor3 = color end
        end,
    }
end

function Z.Toggle(name, default, callback, desc)
    local card, st = Card(desc and 66 or 54)
    local state = not not default
    Label(card, NoEmoji(name), 14, Colors.Text, F_BOLD, UDim2.fromOffset(18, desc and 11 or 0), UDim2.new(1, -104, 0, desc and 20 or 54))
    if desc then Label(card, NoEmoji(desc), 11, Colors.TextDim, F_REG, UDim2.fromOffset(18, 35), UDim2.new(1, -104, 0, 20)) end

    local track = New("Frame", {
        Size = UDim2.fromOffset(48, 26), AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -18, 0.5, 0),
        BackgroundColor3 = Colors.CardHover, BorderSizePixel = 0,
    }, card)
    Corner(track, 13)
    Gradient(track, WHITE, Color3.fromRGB(180, 186, 214), 90)
    local trackStroke = Stroke(track, Colors.Border, 1, 0.5)
    local knob = New("Frame", {
        Size = UDim2.fromOffset(20, 20), AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 3, 0.5, 0),
        BackgroundColor3 = Colors.Text, BorderSizePixel = 0,
    }, track)
    Corner(knob, 10)
    Gradient(knob, WHITE, Color3.fromRGB(188, 194, 226), 90)
    local knobStroke = Stroke(knob, Colors.Border, 1.5, 0.2)

    local function render(v, animate)
        if not card.Parent then return end
        local t = animate and 0.2 or 0
        Tween(track, t, { BackgroundColor3 = v and Colors.Accent or Colors.CardHover })
        Tween(trackStroke, t, { Color = v and Colors.AccentLight or Colors.Border, Transparency = v and 0.35 or 0.5 })
        Tween(knob, t, { Position = UDim2.new(0, v and 25 or 3, 0.5, 0) }, Enum.EasingStyle.Back)
        Tween(knobStroke, t, {
            Color = v and Colors.AccentLight or Colors.Border,
            Thickness = v and 2.5 or 1.5, Transparency = v and 0.05 or 0.25,
        })
        Tween(st, t, { Color = v and Colors.Accent or Colors.Border, Transparency = v and 0.3 or 0.5 })
    end
    render(state, false)

    local hit = New("TextButton", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", AutoButtonColor = false }, card)
    hit.MouseEnter:Connect(function() CardHover(card, true) end)
    hit.MouseLeave:Connect(function() CardHover(card, false) end)
    hit.MouseButton1Click:Connect(function()
        state = not state
        render(state, true)
        Safe(callback, state)
    end)

    local obj = { Frame = card }
    function obj.Set(v, silent)
        v = not not v
        if v == state then return end
        state = v
        render(v, true)
        if not silent then Safe(callback, v) end
    end
    function obj.Get() return state end
    obj.SetState = obj.Set
    return obj
end

function Z.Slider(name, min, max, default, callback, opts)
    opts = opts or {}
    local step, suffix = opts.step or 1, opts.suffix or ""
    local range = math.max(1e-6, max - min)
    local card = Card(74)

    local function snap(v)
        v = min + math.floor((v - min) / step + 0.5) * step
        return math.clamp(v, min, max)
    end
    local function fmt(v)
        if v == math.floor(v) then return tostring(v) end
        return string.format("%.2f", v)
    end
    local value = snap(default or min)

    Label(card, NoEmoji(name), 14, Colors.Text, F_BOLD, UDim2.fromOffset(18, 12), UDim2.new(1, -148, 0, 20))
    local valLbl = Label(card, "", 12, Colors.AccentLight, F_BLACK, UDim2.new(1, -18, 0, 11), UDim2.fromOffset(92, 22), Enum.TextXAlignment.Center)
    valLbl.AnchorPoint = Vector2.new(1, 0)
    valLbl.BackgroundTransparency = 0.2
    valLbl.BackgroundColor3 = Colors.CardSoft
    Corner(valLbl, 8)
    Stroke(valLbl, Colors.Accent, 1, 0.65)

    local track = New("Frame", {
        Size = UDim2.new(1, -36, 0, 8), Position = UDim2.fromOffset(18, 50),
        BackgroundColor3 = Colors.CardHover, BorderSizePixel = 0,
    }, card)
    Corner(track, 4)
    Stroke(track, Colors.BorderSoft, 1, 0.5)
    local fill = New("Frame", { Size = UDim2.fromScale(0, 1), BackgroundColor3 = WHITE, BorderSizePixel = 0 }, track)
    Corner(fill, 4)
    Gradient(fill, Colors.AccentDark, Colors.Accent, 0)
    local knob = New("Frame", {
        Size = UDim2.fromOffset(18, 18), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0, 0.5),
        BackgroundColor3 = Colors.Text, BorderSizePixel = 0, ZIndex = 2,
    }, track)
    Corner(knob, 9)
    Gradient(knob, WHITE, Color3.fromRGB(190, 196, 228), 90)
    local knobStroke = Stroke(knob, Colors.AccentLight, 2, 0.1)

    local function render()
        local a = (value - min) / range
        fill.Size = UDim2.fromScale(a, 1)
        knob.Position = UDim2.fromScale(a, 0.5)
        valLbl.Text = fmt(value) .. suffix
    end
    render()

    local dragging = false
    local function fromX(x)
        local a = math.clamp((x - track.AbsolutePosition.X) / math.max(1, track.AbsoluteSize.X), 0, 1)
        local v = snap(min + range * a)
        if v ~= value then
            value = v
            render()
            Safe(callback, v)
        end
    end
    local hit = New("TextButton", {
        Size = UDim2.new(1, -20, 0, 34), Position = UDim2.fromOffset(10, 38),
        BackgroundTransparency = 1, Text = "", AutoButtonColor = false,
    }, card)
    hit.MouseEnter:Connect(function() CardHover(card, true) end)
    hit.MouseLeave:Connect(function() CardHover(card, false) end)
    hit.InputBegan:Connect(function(i)
        if IsPointer(i) then
            dragging = true
            Scroll.ScrollingEnabled = false
            Tween(knobStroke, 0.12, { Thickness = 3.5, Transparency = 0 })
            fromX(i.Position.X)
        end
    end)
    Z.PageTrack(UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            fromX(i.Position.X)
        end
    end))
    Z.PageTrack(UIS.InputEnded:Connect(function(i)
        if dragging and IsPointer(i) then
            dragging = false
            Scroll.ScrollingEnabled = true
            Tween(knobStroke, 0.15, { Thickness = 2, Transparency = 0.1 })
        end
    end))

    local obj = { Frame = card }
    function obj.Set(v, silent)
        v = snap(v)
        if v == value then return end
        value = v
        render()
        if not silent then Safe(callback, v) end
    end
    function obj.Get() return value end
    return obj
end

function Z.Button(name, color, callback)
    local b = New("TextButton", {
        Size = UDim2.new(1, 0, 0, 44), BackgroundColor3 = Colors.Card, BackgroundTransparency = 0.05,
        Text = NoEmoji(name), Font = F_BOLD, TextSize = 14, TextColor3 = Colors.Text,
        TextXAlignment = Enum.TextXAlignment.Left, RichText = true, TextTruncate = Enum.TextTruncate.AtEnd,
        BorderSizePixel = 0, AutoButtonColor = false, LayoutOrder = NextOrder(),
    }, Scroll)
    Corner(b, 14)
    Gradient(b, WHITE, Color3.fromRGB(224, 227, 242), 90)
    local st = Stroke(b, Colors.Border, 1, 0.5)
    local press = New("UIScale", { Scale = 1 }, b)
    New("UIPadding", { PaddingLeft = UDim.new(0, 18), PaddingRight = UDim.new(0, 48) }, b)

    New("ImageLabel", {
        Name = "MouseIcon",
        Size = UDim2.fromOffset(22, 22), AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(1, 13, 0.5, 0),
        BackgroundTransparency = 1, BorderSizePixel = 0,
        Image = MOUSE_ICON, ImageColor3 = WHITE, ImageTransparency = 0,
        ScaleType = Enum.ScaleType.Fit, ZIndex = 2,
    }, b)

    local hovering = false
    b.MouseEnter:Connect(function()
        hovering = true
        Tween(b, 0.18, { BackgroundColor3 = Colors.CardHover })
        Tween(st, 0.18, { Color = Colors.Accent, Transparency = 0.2, Thickness = 1.5 })
    end)
    b.MouseLeave:Connect(function()
        hovering = false
        Tween(b, 0.18, { BackgroundColor3 = Colors.Card })
        Tween(st, 0.18, { Color = Colors.Border, Transparency = 0.5, Thickness = 1 })
        Tween(press, 0.12, { Scale = 1 })
    end)
    b.MouseButton1Down:Connect(function()
        Tween(press, 0.08, { Scale = 0.97 })
        Tween(b, 0.08, { BackgroundColor3 = Colors.Card:Lerp(Color3.new(0, 0, 0), 0.25) })
    end)
    b.MouseButton1Up:Connect(function()
        Tween(press, 0.14, { Scale = 1 }, Enum.EasingStyle.Back)
        Tween(b, 0.14, { BackgroundColor3 = hovering and Colors.CardHover or Colors.Card })
    end)
    b.MouseButton1Click:Connect(function() Safe(callback) end)
    return b
end

local function MakeSelect(card, selY, text, hasValue)
    local btn = New("TextButton", {
        Size = UDim2.new(1, -36, 0, 34), Position = UDim2.fromOffset(18, selY),
        BackgroundColor3 = Colors.Bg, BackgroundTransparency = 0.25, Text = "", AutoButtonColor = false, BorderSizePixel = 0,
    }, card)
    Corner(btn, 10)
    Gradient(btn, WHITE, Color3.fromRGB(176, 182, 212), 90)
    local st = Stroke(btn, Colors.Border, 1, 0.35)

    local dot = New("Frame", {
        Size = UDim2.fromOffset(6, 6), AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 13, 0.5, 0),
        BackgroundColor3 = Colors.Accent, BorderSizePixel = 0,
    }, btn)
    Corner(dot, 3)
    local val = Label(btn, text, 13, hasValue and Colors.Text or Colors.TextMuted, F_MED, UDim2.fromOffset(28, 0), UDim2.new(1, -72, 1, 0))

    New("Frame", {
        Size = UDim2.new(0, 1, 1, -14), Position = UDim2.new(1, -38, 0, 7),
        BackgroundColor3 = Colors.Border, BackgroundTransparency = 0.5, BorderSizePixel = 0,
    }, btn)
    local arrow = Label(btn, Icon("chevron-down"), 16, Colors.TextDim, F_BOLD, UDim2.new(1, -38, 0, 0), UDim2.fromOffset(38, 34), Enum.TextXAlignment.Center)
    arrow.RichText = true

    local open = false
    arrow:GetPropertyChangedSignal("Rotation"):Connect(function()
        local o = arrow.Rotation > 90
        if o ~= open then
            open = o
            Tween(st, 0.15, { Color = open and Colors.Accent or Colors.Border, Transparency = open and 0.1 or 0.35 })
            Tween(arrow, 0.15, { TextColor3 = open and Colors.AccentLight or Colors.TextDim })
        end
    end)
    btn.MouseEnter:Connect(function()
        if open then return end
        Tween(btn, 0.15, { BackgroundTransparency = 0.1 })
        Tween(st, 0.15, { Color = Colors.Accent, Transparency = 0.3 })
    end)
    btn.MouseLeave:Connect(function()
        if open then return end
        Tween(btn, 0.15, { BackgroundTransparency = 0.25 })
        Tween(st, 0.15, { Color = Colors.Border, Transparency = 0.35 })
    end)
    return btn, val, arrow
end

local function MakeList(card)
    local catcher = New("TextButton", {
        Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", AutoButtonColor = false,
        BorderSizePixel = 0, Visible = false, ZIndex = 55,
    }, Popup)
    local holder = New("ScrollingFrame", {
        Size = UDim2.fromOffset(0, 0), BackgroundColor3 = WHITE, BackgroundTransparency = 1,
        BorderSizePixel = 0, ScrollBarThickness = 3, ScrollBarImageColor3 = Colors.Accent, ScrollBarImageTransparency = 0.35,
        CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false, ZIndex = 60,
    }, Popup)
    Corner(holder, 14)
    Gradient(holder, Color3.fromRGB(26, 28, 44), Color3.fromRGB(14, 15, 26), 90)
    local st = Stroke(holder, Colors.Accent, 1, 1)
    New("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 2) }, holder)
    New("UIPadding", {
        PaddingTop = UDim.new(0, 6), PaddingBottom = UDim.new(0, 6), PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 8),
    }, holder)
    card.Destroying:Connect(function()
        pcall(function() holder:Destroy() end)
        pcall(function() catcher:Destroy() end)
    end)
    return holder, st, catcher
end

local function ShowList(holder, st, selectBtn, count)
    local want = math.min(220, count * 36 + 12)
    local sc = math.max(WinScale.Scale, 0.01)
    local bp = (selectBtn.AbsolutePosition - Main.AbsolutePosition) / sc
    local bs = selectBtn.AbsoluteSize / sc
    local w = math.min(WIN_W - 16, bs.X + 70)
    local x = math.clamp(bp.X - 35, 8, WIN_W - 8 - w)
    local spaceBelow = WIN_H - 8 - (bp.Y + bs.Y + 6)
    local spaceAbove = bp.Y - 6 - 8
    local up = want > spaceBelow and spaceAbove > spaceBelow
    local h = math.max(48, math.min(want, up and spaceAbove or spaceBelow))

    holder.AnchorPoint = Vector2.new(0, up and 1 or 0)
    holder.Position = UDim2.fromOffset(x, up and (bp.Y - 6) or (bp.Y + bs.Y + 6))
    holder.Size = UDim2.fromOffset(w, 0)
    holder.BackgroundTransparency = 1
    st.Transparency = 1
    holder.Visible = true
    Tween(holder, 0.24, { Size = UDim2.fromOffset(w, h), BackgroundTransparency = 0.02 }, Enum.EasingStyle.Quint)
    Tween(st, 0.24, { Transparency = 0.4 })
end

local function HideList(holder, st)
    Tween(holder, 0.16, { Size = UDim2.fromOffset(holder.Size.X.Offset, 0), BackgroundTransparency = 1 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    Tween(st, 0.16, { Transparency = 1 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
end

local function MakeItem(parent, text, order, selected, onClick)
    local restT = selected and 0.8 or 1
    local item = New("TextButton", {
        Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = WHITE, BackgroundTransparency = restT,
        Text = "", AutoButtonColor = false, BorderSizePixel = 0, LayoutOrder = order,
    }, parent)
    Corner(item, 9)
    Gradient(item, Colors.Accent, Colors.Purple, 0)
    local lbl = Label(item, tostring(text), 13, selected and Colors.AccentLight or Colors.TextDim,
        selected and F_BOLD or F_MED, UDim2.fromOffset(14, 0), UDim2.new(1, -38, 1, 0))
    if selected then
        local dot = New("Frame", {
            Size = UDim2.fromOffset(6, 6), AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -14, 0.5, 0),
            BackgroundColor3 = Colors.AccentLight, BorderSizePixel = 0,
        }, item)
        Corner(dot, 3)
    end
    item.MouseEnter:Connect(function()
        Tween(item, 0.12, { BackgroundTransparency = selected and 0.65 or 0.82 })
        Tween(lbl, 0.12, { TextColor3 = Colors.Text })
    end)
    item.MouseLeave:Connect(function()
        Tween(item, 0.12, { BackgroundTransparency = restT })
        Tween(lbl, 0.12, { TextColor3 = selected and Colors.AccentLight or Colors.TextDim })
    end)
    item.MouseButton1Click:Connect(onClick)
    return item
end

function Z.Dropdown(name, options, default, callback, desc)
    options = options or {}
    local selY = desc and 58 or 36
    local baseH = selY + 34 + 12
    local card = Card(baseH)

    Label(card, NoEmoji(name), 14, Colors.Text, F_BOLD, UDim2.fromOffset(18, 10), UDim2.new(1, -36, 0, 20))
    if desc then Label(card, NoEmoji(desc), 11, Colors.TextDim, F_REG, UDim2.fromOffset(18, 32), UDim2.new(1, -36, 0, 18)) end

    local selectBtn, valLbl, arrow = MakeSelect(card, selY, default and tostring(default) or "Selecionar...", default ~= nil)
    local listHolder, listStroke, catcher = MakeList(card)

    local selected, isOpen, itemButtons = default, false, {}

    local function CloseList()
        if not isOpen then return end
        isOpen = false
        catcher.Visible = false
        Tween(arrow, 0.2, { Rotation = 0 })
        HideList(listHolder, listStroke)
        task.delay(0.18, function() if not isOpen and listHolder.Parent then listHolder.Visible = false end end)
    end

    local function RenderItems()
        for _, b in ipairs(itemButtons) do b:Destroy() end
        table.clear(itemButtons)
        for i, opt in ipairs(options) do
            local item = MakeItem(listHolder, opt, i, opt == selected, function()
                selected = opt
                valLbl.Text, valLbl.TextColor3 = tostring(opt), Colors.Text
                CloseList()
                Safe(callback, opt)
            end)
            table.insert(itemButtons, item)
        end
    end
    RenderItems()

    local function OpenList()
        if isOpen or #options == 0 then return end
        RenderItems()
        isOpen = true
        catcher.Visible = true
        ShowList(listHolder, listStroke, selectBtn, #options)
        Tween(arrow, 0.2, { Rotation = 180 })
    end

    catcher.MouseButton1Click:Connect(CloseList)
    selectBtn.MouseButton1Click:Connect(function() if isOpen then CloseList() else OpenList() end end)

    local obj = { Frame = card }
    function obj.SetOptions(newOptions)
        local wasOpen = isOpen
        options = newOptions or {}
        RenderItems()
        if selected ~= nil and not table.find(options, selected) then
            selected = nil
            valLbl.Text, valLbl.TextColor3 = "Selecionar...", Colors.TextMuted
        end
        if wasOpen then isOpen = false; OpenList() end
    end
    function obj.Get() return selected end
    function obj.Set(v, silent)
        selected = v
        valLbl.Text = v and tostring(v) or "Selecionar..."
        valLbl.TextColor3 = v and Colors.Text or Colors.TextMuted
        if not silent then Safe(callback, v) end
    end
    return obj
end

function Z.PlayerDropdown(name, callback, desc)
    local selY = desc and 58 or 36
    local baseH = selY + 34 + 12
    local card = Card(baseH)

    Label(card, NoEmoji(name), 14, Colors.Text, F_BOLD, UDim2.fromOffset(18, 10), UDim2.new(1, -36, 0, 20))
    if desc then Label(card, NoEmoji(desc), 11, Colors.TextDim, F_REG, UDim2.fromOffset(18, 32), UDim2.new(1, -36, 0, 18)) end

    local selectBtn, valLbl, arrow = MakeSelect(card, selY, "Selecionar jogador...", false)
    local listHolder, listStroke, catcher = MakeList(card)

    local selected, isOpen, itemButtons = nil, false, {}

    local function CloseList()
        if not isOpen then return end
        isOpen = false
        catcher.Visible = false
        Tween(arrow, 0.2, { Rotation = 0 })
        HideList(listHolder, listStroke)
        task.delay(0.18, function() if not isOpen and listHolder.Parent then listHolder.Visible = false end end)
    end

    local function RenderItems()
        for _, b in ipairs(itemButtons) do b:Destroy() end
        table.clear(itemButtons)
        for i, p in ipairs(Players:GetPlayers()) do
            if p ~= Player then
                local item = MakeItem(listHolder, p.Name, i, p == selected, function()
                    selected = p
                    valLbl.Text, valLbl.TextColor3 = p.Name, Colors.Text
                    CloseList()
                    Safe(callback, p)
                end)
                table.insert(itemButtons, item)
            end
        end
    end

    local function OpenList()
        if isOpen then return end
        RenderItems()
        if #itemButtons == 0 then
            Z.Notify("Players", "Nenhum outro jogador no servidor.", Colors.Warning, 2)
            return
        end
        isOpen = true
        catcher.Visible = true
        ShowList(listHolder, listStroke, selectBtn, #itemButtons)
        Tween(arrow, 0.2, { Rotation = 180 })
    end

    catcher.MouseButton1Click:Connect(CloseList)
    selectBtn.MouseButton1Click:Connect(function() if isOpen then CloseList() else OpenList() end end)

    Z.PageTrack(Players.PlayerAdded:Connect(function() if isOpen then RenderItems() end end))
    Z.PageTrack(Players.PlayerRemoving:Connect(function(p)
        if selected == p then
            selected = nil
            valLbl.Text, valLbl.TextColor3 = "Selecionar jogador...", Colors.TextMuted
        end
        if isOpen then RenderItems() end
    end))

    local obj = { Frame = card }
    function obj.Get() return selected end
    function obj.Set(p, silent)
        selected = p
        valLbl.Text = p and p.Name or "Selecionar jogador..."
        valLbl.TextColor3 = p and Colors.Text or Colors.TextMuted
        if not silent then Safe(callback, p) end
    end
    return obj
end

-- ═══════════════════════════════════════════════════════════════════════
-- ARRASTAR
-- ═══════════════════════════════════════════════════════════════════════
local function MakeDraggable(handle, target, onClick, clampFn)
    local dragging, moved, origin, startPos = false, false, nil, nil
    handle.InputBegan:Connect(function(i)
        if IsPointer(i) then
            dragging, moved = true, false
            origin, startPos = i.Position, target.Position
        end
    end)
    Z.Track(UIS.InputChanged:Connect(function(i)
        if not dragging then return end
        if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
            local d = i.Position - origin
            if not moved and d.Magnitude > 6 then moved = true end
            if moved then
                local x, y = startPos.X.Offset + d.X, startPos.Y.Offset + d.Y
                if clampFn then x, y = clampFn(x, y) end
                target.Position = UDim2.new(startPos.X.Scale, x, startPos.Y.Scale, y)
            end
        end
    end))
    Z.Track(UIS.InputEnded:Connect(function(i)
        if dragging and IsPointer(i) then
            dragging = false
            if not moved and onClick then Safe(onClick) end
        end
    end))
end

local function ClampMain(x, y)
    local vp = Viewport()
    local mx, my = vp.X / 2 - 80, vp.Y / 2 - 40
    return math.clamp(x, -mx, mx), math.clamp(y, -my, my)
end
MakeDraggable(Header, Main, nil, ClampMain)
MakeDraggable(LogoCard, Main, nil, ClampMain)

-- ═══════════════════════════════════════════════════════════════════════
-- BOLHA + MOSTRAR / ESCONDER
-- ═══════════════════════════════════════════════════════════════════════
local Bubble = New("TextButton", {
    Size = UDim2.fromOffset(58, 58), Position = UDim2.new(1, -94, 1, -136), Text = "",
    BackgroundTransparency = 1, AutoButtonColor = false, BorderSizePixel = 0, Visible = false, ZIndex = 50,
}, Hub)
local bubbleCircle = New("Frame", {
    Size = UDim2.fromScale(1, 1), BackgroundColor3 = WHITE, BorderSizePixel = 0,
}, Bubble)
Corner(bubbleCircle, 29)
Gradient(bubbleCircle, Colors.Accent, Colors.Purple, 45)
local bubbleStroke = Stroke(bubbleCircle, Colors.AccentLight, 2.5, 0.25)
New("TextLabel", {
    Name = "Letter", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "C",
    Font = F_BLACK, TextSize = 28, TextColor3 = Colors.Bg, ZIndex = 2,
}, Bubble)
Bubble.MouseEnter:Connect(function() Tween(bubbleStroke, 0.18, { Transparency = 0, Thickness = 4 }) end)
Bubble.MouseLeave:Connect(function() Tween(bubbleStroke, 0.18, { Transparency = 0.25, Thickness = 2.5 }) end)

local animToken = 0
function Z.SetVisible(v)
    if not Z.Alive then return end
    v = not not v
    if v == Z.IsVisible then return end
    Z.IsVisible = v
    animToken += 1
    local my = animToken
    if v then
        Bubble.Visible = false
        WinScale.Scale = 0.6
        Main.Visible = true
        Tween(WinScale, 0.32, { Scale = TargetScale() }, Enum.EasingStyle.Quint)
    else
        Tween(WinScale, 0.22, { Scale = 0.01 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        task.delay(0.23, function()
            if animToken == my and Z.Alive then
                Main.Visible = false
                Bubble.Visible = true
            end
        end)
    end
end
function Z.ToggleVisible() Z.SetVisible(not Z.IsVisible) end
MakeDraggable(Bubble, Bubble, function() Z.SetVisible(true) end)

-- Botões do cabeçalho
local function HeaderBtn(text, xOff, cb)
    local b = New("TextButton", {
        Size = UDim2.fromOffset(34, 34), Position = UDim2.new(1, xOff, 0, 15), BackgroundColor3 = Colors.Card, Text = text,
        Font = F_BOLD, TextSize = 18, TextColor3 = Colors.Text, AutoButtonColor = false, BorderSizePixel = 0,
    }, Header)
    Corner(b, 10)
    Gradient(b, WHITE, SOFT_GRAY, 90)
    local st = Stroke(b, Colors.Border, 1, 0.5)
    b.MouseEnter:Connect(function()
        Tween(b, 0.15, { BackgroundColor3 = Colors.CardHover })
        Tween(st, 0.15, { Color =... (13 KB restante(s))
