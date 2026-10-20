-- ═══ CHUPPY HUB — STEAL AN EGG (UI Chuppy + module game) ═══
(function()

-- ═══════════════════════════════════════════════════════════════════════════════
-- [1.0] SERVICES
-- ═══════════════════════════════════════════════════════════════════════════════
local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local UIS          = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui      = game:GetService("CoreGui")
local LP           = Players.LocalPlayer

-- ═══════════════════════════════════════════════════════════════════════════════
-- [1.1] THEME — Bảng màu & config
-- ═══════════════════════════════════════════════════════════════════════════════
local Theme = {
    Background     = Color3.fromRGB(12, 13, 18),
    Surface        = Color3.fromRGB(20, 22, 30),
    Surface2       = Color3.fromRGB(28, 30, 40),
    Surface3       = Color3.fromRGB(36, 38, 50),
    SurfaceDeep    = Color3.fromRGB(8, 9, 13),

    Border         = Color3.fromRGB(40, 42, 55),
    BorderLight    = Color3.fromRGB(55, 58, 75),

    Accent         = Color3.fromRGB(0, 190, 255),
    AccentDim      = Color3.fromRGB(0, 90, 130),
    AccentGlow     = Color3.fromRGB(80, 220, 255),

    Success        = Color3.fromRGB(0, 220, 130),
    SuccessDark    = Color3.fromRGB(0, 60, 35),
    Warning        = Color3.fromRGB(255, 180, 50),
    WarningDark    = Color3.fromRGB(80, 50, 10),
    Danger         = Color3.fromRGB(255, 75, 95),
    DangerDark     = Color3.fromRGB(80, 20, 28),
    Info           = Color3.fromRGB(100, 160, 255),

    Text           = Color3.fromRGB(240, 242, 248),
    TextBright     = Color3.fromRGB(255, 255, 255),
    TextDim        = Color3.fromRGB(150, 158, 175),
    TextMuted      = Color3.fromRGB(90, 96, 115),

    Radius         = UDim.new(0, 8),
    RadiusSmall    = UDim.new(0, 6),
    RadiusTiny     = UDim.new(0, 4),
    RadiusLarge    = UDim.new(0, 12),
    RadiusXL       = UDim.new(0, 16),
    RadiusFull     = UDim.new(1, 0),

    AnimInstant    = TweenInfo.new(0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    AnimFast       = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    AnimNormal     = TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
    AnimSmooth     = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
    AnimSpring     = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),

    FontBlack      = Enum.Font.GothamBlack,
    FontBold       = Enum.Font.GothamBold,
    FontMedium     = Enum.Font.GothamMedium,
    FontRegular    = Enum.Font.Gotham,
    FontMono       = Enum.Font.Code,

    SizeSmall      = 10,
    SizeNormal     = 11,
    SizeMedium     = 12,
    SizeTitle      = 14,
    SizeHeader     = 16,
}
getgenv().ChuppyTheme = Theme

-- ═══════════════════════════════════════════════════════════════════════════════
-- [1.2] HELPERS
-- ═══════════════════════════════════════════════════════════════════════════════
local function New(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then
            pcall(function() obj[k] = v end)
        end
    end
    if parent then obj.Parent = parent end
    return obj
end

local function Corner(radius, parent)
    return New("UICorner", { CornerRadius = radius or Theme.Radius }, parent)
end

local function Stroke(color, thickness, transparency, parent)
    return New("UIStroke", {
        Color = color or Theme.Border,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
    }, parent)
end

local function Padding(t, b, l, r, parent)
    return New("UIPadding", {
        PaddingTop = UDim.new(0, t or 0),
        PaddingBottom = UDim.new(0, b or 0),
        PaddingLeft = UDim.new(0, l or 0),
        PaddingRight = UDim.new(0, r or 0),
    }, parent)
end

local function Tween(obj, info, props)
    if not obj or not obj.Parent then return nil end
    local t = TweenService:Create(obj, info or Theme.AnimNormal, props)
    t:Play()
    return t
end

local function TextBounds(font, size, text)
    local label = Instance.new("TextLabel")
    label.TextSize = size
    label.Font = font
    label.Text = text or ""
    local bounds = label.TextBounds
    label:Destroy()
    return bounds
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- [1.3] ANIMATIONS
-- ═══════════════════════════════════════════════════════════════════════════════
local Anim = {}
local activeGlows = {}

function Anim.Pulse(obj, scale, duration)
    if not obj or not obj.Parent then return end
    scale = scale or 1.05
    duration = duration or 0.3
    local origSize = obj.Size
    local info = TweenInfo.new(duration / 2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local t = TweenService:Create(obj, info, {
        Size = UDim2.new(
            origSize.X.Scale * scale, origSize.X.Offset * scale,
            origSize.Y.Scale * scale, origSize.Y.Offset * scale
        ),
    })
    t:Play()
    t.Completed:Connect(function()
        if obj and obj.Parent then
            TweenService:Create(obj, info, { Size = origSize }):Play()
        end
    end)
end

function Anim.Ripple(parent, x, y, color)
    if not parent or not parent.Parent then return end
    color = color or Theme.Accent
    local ripple = New("Frame", {
        Name = "RippleEffect",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0, x, 0, y),
        Size = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = color,
        BackgroundTransparency = 0.7,
        BorderSizePixel = 0,
        ZIndex = 10,
    }, parent)
    Corner(Theme.RadiusFull, ripple)
    local maxSize = math.max(parent.AbsoluteSize.X, parent.AbsoluteSize.Y) * 2
    Tween(ripple, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, maxSize, 0, maxSize),
        BackgroundTransparency = 1,
    })
    task.delay(0.7, function()
        if ripple and ripple.Parent then ripple:Destroy() end
    end)
end

function Anim.Glow(obj, stroke, baseColor, glowColor)
    if not obj or not obj.Parent or not stroke then return end
    if activeGlows[obj] then
        activeGlows[obj]:Disconnect()
        activeGlows[obj] = nil
    end
    baseColor = baseColor or Theme.Border
    glowColor = glowColor or Theme.AccentGlow
    local startTime = tick()
    local period = 1.5
    activeGlows[obj] = RunService.Heartbeat:Connect(function()
        if not obj or not obj.Parent or not stroke or not stroke.Parent then
            if activeGlows[obj] then
                activeGlows[obj]:Disconnect()
                activeGlows[obj] = nil
            end
            return
        end
        local t = ((tick() - startTime) % period) / period
        local alpha = (math.sin(t * math.pi * 2) + 1) / 2
        alpha = 0.3 + alpha * 0.5
        stroke.Color = baseColor:Lerp(glowColor, alpha)
        stroke.Transparency = 1 - alpha
    end)
end

function Anim.StopGlow(obj)
    if activeGlows[obj] then
        activeGlows[obj]:Disconnect()
        activeGlows[obj] = nil
    end
end

function Anim.RotateChevron(chevron, toAngle, duration)
    if not chevron or not chevron.Parent then return end
    duration = duration or 0.25
    Tween(chevron, TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
        Rotation = toAngle,
    })
end

getgenv().ChuppyAnim = Anim

-- ═══════════════════════════════════════════════════════════════════════════════
-- [1.4] NOTIFICATION SYSTEM
-- ═══════════════════════════════════════════════════════════════════════════════
local Notification = {}
local notiStack = {}
local notiHolder = nil
local NOTI_W, NOTI_H, NOTI_GAP = 300, 68, 8

local NOTI_ICONS = { info = "ℹ", success = "✓", warning = "⚠", danger = "✕" }
local NOTI_COLORS = {
    info    = function() return Theme.Info end,
    success = function() return Theme.Success end,
    warning = function() return Theme.Warning end,
    danger  = function() return Theme.Danger end,
}

local function InitNotiHolder(screenGui)
    if notiHolder and notiHolder.Parent then return end
    notiHolder = New("Frame", {
        Name = "NotificationHolder",
        Size = UDim2.new(0, NOTI_W, 0, 0),
        Position = UDim2.new(0, 12, 0, 60),
        BackgroundTransparency = 1,
        ZIndex = 9999,
    }, screenGui)
end

local function ReorganizeNoti()
    local yPos = 0
    for _, noti in ipairs(notiStack) do
        if noti.frame and noti.frame.Parent then
            Tween(noti.frame, Theme.AnimNormal, { Position = UDim2.new(0, 0, 0, yPos) })
            yPos = yPos + NOTI_H + NOTI_GAP
        end
    end
end

local function DismissNoti(noti)
    if not noti or not noti.frame or not noti.frame.Parent then return end
    for i, n in ipairs(notiStack) do
        if n == noti then
            table.remove(notiStack, i)
            break
        end
    end
    if noti.timerConn then pcall(function() noti.timerConn:Disconnect() end) end
    local frame = noti.frame
    Tween(frame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
        Position = UDim2.new(0, -NOTI_W - 20, 0, frame.Position.Y.Offset),
        BackgroundTransparency = 1,
    })
    for _, desc in ipairs(frame:GetDescendants()) do
        if desc:IsA("TextLabel") then
            Tween(desc, Theme.AnimFast, { TextTransparency = 1 })
        elseif desc:IsA("TextButton") then
            Tween(desc, Theme.AnimFast, { TextTransparency = 1, BackgroundTransparency = 1 })
        elseif desc:IsA("Frame") then
            Tween(desc, Theme.AnimFast, { BackgroundTransparency = 1 })
        elseif desc:IsA("UIStroke") then
            Tween(desc, Theme.AnimFast, { Transparency = 1 })
        end
    end
    task.delay(0.3, function()
        if frame and frame.Parent then frame:Destroy() end
        ReorganizeNoti()
    end)
end

function Notification.Show(config)
    if not notiHolder or not notiHolder.Parent then return nil end
    config = config or {}
    local nType = config.Type or "info"
    local title = config.Title or "Thông báo"
    local desc  = config.Desc or config.Text or ""
    local dur   = config.Duration or 4
    local icon  = config.Icon or NOTI_ICONS[nType] or "ℹ"
    local color = NOTI_COLORS[nType] and NOTI_COLORS[nType]() or Theme.Info

    local frame = New("Frame", {
        Name = "Noti_" .. tostring(math.random(10000, 99999)),
        Size = UDim2.new(0, NOTI_W, 0, NOTI_H),
        Position = UDim2.new(0, -NOTI_W - 20, 0, 0),
        BackgroundColor3 = Theme.Surface,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 9999,
    }, notiHolder)
    Corner(Theme.RadiusLarge, frame)
    local stroke = Stroke(Theme.Border, 1, 1, frame)

    local accent = New("Frame", {
        Name = "AccentBar",
        Size = UDim2.new(0, 3, 1, 0),
        BackgroundColor3 = color,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 10000,
    }, frame)
    Corner(Theme.RadiusTiny, accent)

    local iconF = New("Frame", {
        Name = "IconFrame",
        Size = UDim2.new(0, 36, 0, 36),
        Position = UDim2.new(0, 16, 0.5, -18),
        BackgroundColor3 = color,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 10000,
    }, frame)
    Corner(Theme.RadiusFull, iconF)
    New("TextLabel", {
        Name = "Icon",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = icon,
        Font = Theme.FontBlack,
        TextSize = 16,
        TextColor3 = Theme.Background,
        TextTransparency = 1,
        ZIndex = 10001,
    }, iconF)

    New("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, -80, 0, 18),
        Position = UDim2.new(0, 62, 0, 14),
        BackgroundTransparency = 1,
        Text = title,
        Font = Theme.FontBold,
        TextSize = Theme.SizeMedium,
        TextColor3 = color,
        TextTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 10000,
    }, frame)

    New("TextLabel", {
        Name = "Desc",
        Size = UDim2.new(1, -80, 0, 26),
        Position = UDim2.new(0, 62, 0, 32),
        BackgroundTransparency = 1,
        Text = desc,
        Font = Theme.FontRegular,
        TextSize = Theme.SizeNormal,
        TextColor3 = Theme.TextDim,
        TextTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 10000,
    }, frame)

    local progBar, progFill
    if dur > 0 then
        progBar = New("Frame", {
            Name = "ProgressBar",
            Size = UDim2.new(1, -20, 0, 2),
            Position = UDim2.new(0, 10, 1, -4),
            BackgroundColor3 = Theme.SurfaceDeep,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ZIndex = 10000,
        }, frame)
        Corner(Theme.RadiusTiny, progBar)
        progFill = New("Frame", {
            Name = "Fill",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = color,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ZIndex = 10001,
        }, progBar)
        Corner(Theme.RadiusTiny, progFill)
    end

    local click = New("TextButton", {
        Name = "ClickArea",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 10002,
    }, frame)

    local noti = { frame = frame, type = nType, timerConn = nil }
    table.insert(notiStack, noti)

    Tween(frame, Theme.AnimSmooth, {
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 0,
    })
    task.delay(0.05, function()
        if not frame or not frame.Parent then return end
        Tween(accent, Theme.AnimNormal, { BackgroundTransparency = 0 })
        Tween(iconF, Theme.AnimNormal, { BackgroundTransparency = 0 })
        Tween(iconF.Icon, Theme.AnimNormal, { TextTransparency = 0 })
        Tween(frame.Title, Theme.AnimNormal, { TextTransparency = 0 })
        Tween(frame.Desc, Theme.AnimNormal, { TextTransparency = 0 })
        Tween(stroke, Theme.AnimNormal, { Transparency = 0 })
        if progBar then
            Tween(progBar, Theme.AnimNormal, { BackgroundTransparency = 0.3 })
            Tween(progFill, Theme.AnimNormal, { BackgroundTransparency = 0 })
        end
    end)

    if dur > 0 then
        local startTime = tick()
        local conn
        conn = RunService.Heartbeat:Connect(function()
            if not frame or not frame.Parent then
                if conn then conn:Disconnect() end
                return
            end
            local elapsed = tick() - startTime
            local prog = math.clamp(1 - elapsed / dur, 0, 1)
            if progFill and progFill.Parent then
                progFill.Size = UDim2.new(prog, 0, 1, 0)
                if prog < 0.25 then
                    progFill.BackgroundColor3 = Theme.Danger
                elseif prog < 0.5 then
                    progFill.BackgroundColor3 = Theme.Warning
                else
                    progFill.BackgroundColor3 = color
                end
            end
            if elapsed >= dur then
                if conn then conn:Disconnect() end
                DismissNoti(noti)
            end
        end)
        noti.timerConn = conn
    end

    click.MouseButton1Click:Connect(function() DismissNoti(noti) end)
    ReorganizeNoti()
    return noti
end

function Notification.Info(t, d, dur)    return Notification.Show({ Type = "info",    Title = t, Desc = d, Duration = dur }) end
function Notification.Success(t, d, dur) return Notification.Show({ Type = "success", Title = t, Desc = d, Duration = dur }) end
function Notification.Warning(t, d, dur) return Notification.Show({ Type = "warning", Title = t, Desc = d, Duration = dur }) end
function Notification.Danger(t, d, dur)  return Notification.Show({ Type = "danger",  Title = t, Desc = d, Duration = dur }) end

getgenv().ChuppyNotification = Notification

-- ═══════════════════════════════════════════════════════════════════════════════
-- [1.5] TOOLTIP SYSTEM
-- ═══════════════════════════════════════════════════════════════════════════════
local Tooltip = {}
local tFrame, tVisible = nil, false

local function InitTooltip(screenGui)
    if tFrame and tFrame.Parent then return end
    tFrame = New("Frame", {
        Name = "TooltipFrame",
        Size = UDim2.new(0, 0, 0, 26),
        BackgroundColor3 = Theme.Surface3,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 99999,
        Visible = false,
    }, screenGui)
    Corner(Theme.RadiusSmall, tFrame)
    Stroke(Theme.BorderLight, 1, 1, tFrame)
    New("TextLabel", {
        Name = "Label",
        Size = UDim2.new(1, -16, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1,
        Text = "",
        Font = Theme.FontMedium,
        TextSize = Theme.SizeSmall,
        TextColor3 = Theme.Text,
        TextTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
        ZIndex = 100000,
    }, tFrame)
end

function Tooltip.Show(text, x, y)
    if not tFrame or not tFrame.Parent or not text or text == "" then return end
    local label = tFrame:FindFirstChild("Label")
    if not label then return end
    local bounds = TextBounds(Theme.FontMedium, Theme.SizeSmall, text)
    local w = math.max(50, bounds.X + 20)
    label.Text = text
    tFrame.Size = UDim2.new(0, w, 0, 26)
    tFrame.Position = UDim2.new(0, x - w / 2, 0, y)
    if not tVisible then
        tVisible = true
        tFrame.Visible = true
        tFrame.BackgroundTransparency = 0.05
        Tween(label, Theme.AnimFast, { TextTransparency = 0 })
    end
end

function Tooltip.Hide()
    if not tFrame or not tFrame.Parent then return end
    tVisible = false
    local label = tFrame:FindFirstChild("Label")
    if label then Tween(label, Theme.AnimFast, { TextTransparency = 1 }) end
    Tween(tFrame, Theme.AnimFast, { BackgroundTransparency = 1 })
    task.delay(0.2, function()
        if tFrame and tFrame.Parent and not tVisible then
            tFrame.Visible = false
        end
    end)
end

function Tooltip.Attach(element, text)
    if not element or not text then return end
    local hoverTime, isHovering = 0, false
    element.MouseEnter:Connect(function()
        isHovering = true
        hoverTime = tick()
        task.delay(0.4, function()
            if isHovering and (tick() - hoverTime) >= 0.35 then
                local pos, size = element.AbsolutePosition, element.AbsoluteSize
                Tooltip.Show(text, pos.X + size.X / 2, pos.Y - 32)
            end
        end)
    end)
    element.MouseLeave:Connect(function()
        isHovering = false
        Tooltip.Hide()
    end)
end

getgenv().ChuppyTooltip = Tooltip

-- ═══════════════════════════════════════════════════════════════════════════════
-- [1.6] MODAL DIALOG
-- ═══════════════════════════════════════════════════════════════════════════════
local Modal = {}

local function CreateModalBase(screenGui)
    local overlay = New("TextButton", {
        Name = "ModalOverlay",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 99998,
    }, screenGui)
    local modal = New("Frame", {
        Name = "Modal",
        Size = UDim2.new(0, 300, 0, 0),
        Position = UDim2.new(0.5, -150, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Theme.Surface2,
        BorderSizePixel = 0,
        ZIndex = 99999,
        AutomaticSize = Enum.AutomaticSize.Y,
    }, overlay)
    Corner(Theme.RadiusXL, modal)
    Stroke(Theme.BorderLight, 1, 0, modal)
    return overlay, modal
end

function Modal.Confirm(config)
    config = config or {}
    local title    = config.Title or "Xác nhận"
    local message  = config.Message or "Bạn có chắc chắn?"
    local yesText  = config.YesText or "Đồng ý"
    local noText   = config.NoText or "Hủy"
    local onYes    = config.OnYes or function() end
    local onNo     = config.OnNo or function() end
    local yesColor = config.YesColor or Theme.Success
    local noColor  = config.NoColor or Theme.Danger
    local parent   = config.Parent or getgenv().ChuppyScreenGui
    if not parent then return end

    local overlay, modal = CreateModalBase(parent)

    New("TextLabel", {
        Size = UDim2.new(1, -32, 0, 24),
        Position = UDim2.new(0, 16, 0, 18),
        BackgroundTransparency = 1,
        Text = title,
        Font = Theme.FontBold,
        TextSize = Theme.SizeHeader,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 100000,
    }, modal)

    New("TextLabel", {
        Size = UDim2.new(1, -32, 0, 40),
        Position = UDim2.new(0, 16, 0, 48),
        BackgroundTransparency = 1,
        Text = message,
        Font = Theme.FontRegular,
        TextSize = Theme.SizeMedium,
        TextColor3 = Theme.TextDim,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        ZIndex = 100000,
    }, modal)

    local btnRow = New("Frame", {
        Size = UDim2.new(1, -32, 0, 36),
        Position = UDim2.new(0, 16, 0, 96),
        BackgroundTransparency = 1,
        ZIndex = 100000,
    }, modal)
    New("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 10),
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
    }, btnRow)

    local noBtn = New("TextButton", {
        Size = UDim2.new(0, 110, 1, 0),
        BackgroundColor3 = noColor,
        BorderSizePixel = 0,
        Text = noText,
        Font = Theme.FontBold,
        TextSize = Theme.SizeMedium,
        TextColor3 = Theme.TextBright,
        AutoButtonColor = false,
        LayoutOrder = 1,
        ZIndex = 100001,
    }, btnRow)
    Corner(Theme.RadiusSmall, noBtn)

    local yesBtn = New("TextButton", {
        Size = UDim2.new(0, 110, 1, 0),
        BackgroundColor3 = yesColor,
        BorderSizePixel = 0,
        Text = yesText,
        Font = Theme.FontBold,
        TextSize = Theme.SizeMedium,
        TextColor3 = Theme.TextBright,
        AutoButtonColor = false,
        LayoutOrder = 2,
        ZIndex = 100001,
    }, btnRow)
    Corner(Theme.RadiusSmall, yesBtn)

    modal.Size = UDim2.new(0, 300, 0, 150)
    overlay.BackgroundTransparency = 1
    modal.Position = UDim2.new(0.5, -150, 0.5, 20)
    modal.BackgroundTransparency = 1
    Tween(overlay, Theme.AnimNormal, { BackgroundTransparency = 0.5 })
    Tween(modal, Theme.AnimSpring, {
        Position = UDim2.new(0.5, -150, 0.5, 0),
        BackgroundTransparency = 0,
    })

    local function close()
        Tween(overlay, Theme.AnimFast, { BackgroundTransparency = 1 })
        Tween(modal, Theme.AnimFast, {
            Position = UDim2.new(0.5, -150, 0.5, 20),
            BackgroundTransparency = 1,
        })
        task.delay(0.2, function()
            if overlay and overlay.Parent then overlay:Destroy() end
        end)
    end

    yesBtn.MouseButton1Click:Connect(function() close(); pcall(onYes) end)
    noBtn.MouseButton1Click:Connect(function()  close(); pcall(onNo)  end)
    overlay.MouseButton1Click:Connect(function() close(); pcall(onNo) end)
    return overlay
end

function Modal.Prompt(config)
    config = config or {}
    local title       = config.Title or "Nhập liệu"
    local placeholder = config.Placeholder or "Nhập ở đây..."
    local default     = config.Default or ""
    local onSubmit    = config.OnSubmit or function() end
    local onCancel    = config.OnCancel or function() end
    local parent      = config.Parent or getgenv().ChuppyScreenGui
    if not parent then return end

    local overlay, modal = CreateModalBase(parent)

    New("TextLabel", {
        Size = UDim2.new(1, -32, 0, 24),
        Position = UDim2.new(0, 16, 0, 18),
        BackgroundTransparency = 1,
        Text = title,
        Font = Theme.FontBold,
        TextSize = Theme.SizeHeader,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 100000,
    }, modal)

    local input = New("TextBox", {
        Size = UDim2.new(1, -32, 0, 34),
        Position = UDim2.new(0, 16, 0, 52),
        BackgroundColor3 = Theme.SurfaceDeep,
        BorderSizePixel = 0,
        Text = default,
        PlaceholderText = placeholder,
        PlaceholderColor3 = Theme.TextMuted,
        Font = Theme.FontRegular,
        TextSize = Theme.SizeMedium,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        ZIndex = 100000,
    }, modal)
    Corner(Theme.RadiusSmall, input)
    Padding(0, 0, 10, 10, input)

    local inputStroke = Stroke(Theme.Border, 1, 0, input)
    input.Focused:Connect(function()
        Tween(inputStroke, Theme.AnimFast, { Color = Theme.Accent })
    end)
    input.FocusLost:Connect(function()
        Tween(inputStroke, Theme.AnimFast, { Color = Theme.Border })
    end)

    local btnRow = New("Frame", {
        Size = UDim2.new(1, -32, 0, 34),
        Position = UDim2.new(0, 16, 0, 100),
        BackgroundTransparency = 1,
        ZIndex = 100000,
    }, modal)
    New("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 10),
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
    }, btnRow)

    local cancelBtn = New("TextButton", {
        Size = UDim2.new(0, 100, 1, 0),
        BackgroundColor3 = Theme.Surface3,
        BorderSizePixel = 0,
        Text = "Hủy",
        Font = Theme.FontBold,
        TextSize = Theme.SizeMedium,
        TextColor3 = Theme.Text,
        AutoButtonColor = false,
        LayoutOrder = 1,
        ZIndex = 100001,
    }, btnRow)
    Corner(Theme.RadiusSmall, cancelBtn)

    local okBtn = New("TextButton", {
        Size = UDim2.new(0, 100, 1, 0),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Text = "OK",
        Font = Theme.FontBold,
        TextSize = Theme.SizeMedium,
        TextColor3 = Theme.Background,
        AutoButtonColor = false,
        LayoutOrder = 2,
        ZIndex = 100001,
    }, btnRow)
    Corner(Theme.RadiusSmall, okBtn)

    modal.Size = UDim2.new(0, 300, 0, 150)
    overlay.BackgroundTransparency = 1
    modal.Position = UDim2.new(0.5, -150, 0.5, 20)
    Tween(overlay, Theme.AnimNormal, { BackgroundTransparency = 0.5 })
    Tween(modal, Theme.AnimSpring, {
        Position = UDim2.new(0.5, -150, 0.5, 0),
        BackgroundTransparency = 0,
    })

    local function close()
        Tween(overlay, Theme.AnimFast, { BackgroundTransparency = 1 })
        Tween(modal, Theme.AnimFast, {
            Position = UDim2.new(0.5, -150, 0.5, 20),
            BackgroundTransparency = 1,
        })
        task.delay(0.2, function()
            if overlay and overlay.Parent then overlay:Destroy() end
        end)
    end

    okBtn.MouseButton1Click:Connect(function()
        local txt = input.Text
        close()
        pcall(onSubmit, txt)
    end)
    cancelBtn.MouseButton1Click:Connect(function()
        close()
        pcall(onCancel)
    end)
    task.defer(function() pcall(function() input:CaptureFocus() end) end)
    return overlay
end

getgenv().ChuppyModal = Modal

-- ═══════════════════════════════════════════════════════════════════════════════
-- [1.7] UI LIBRARY CLASS
-- ═══════════════════════════════════════════════════════════════════════════════
local UILibrary = {}
UILibrary.__index = UILibrary
UILibrary.Theme        = Theme
UILibrary.Notification = Notification
UILibrary.Tooltip      = Tooltip
UILibrary.Modal        = Modal
UILibrary.Anim         = Anim

function UILibrary:CreateWindow(config)
    config = config or {}
    local title    = config.Title or "Chuppy Hub V2"
    local subtitle = config.SubTitle or "Premium Edition"
    local width    = config.Width or 360
    local height   = config.Height or 460
    pcall(function()
        local vp = workspace.CurrentCamera.ViewportSize
        width, height = math.min(width, vp.X * 0.62, 300), math.clamp(vp.Y * 0.72, 220, math.min(height, 320))
    end)

    local self = setmetatable({}, UILibrary)
    self.config, self.title, self.tabs = config, title, {}
    self.currentTab, self.flags = nil, {}
    self.minimized, self._elementCount = false, 0

    local gui = New("ScreenGui", {
        Name = "ChuppyUI_" .. tostring(math.random(10000, 99999)),
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
        DisplayOrder = 999,
    })
    pcall(function() gui.Parent = (gethui and gethui()) or CoreGui end)
    if not gui.Parent then gui.Parent = LP:WaitForChild("PlayerGui") end
    self.screenGui = gui
    getgenv().ChuppyScreenGui = gui

    InitNotiHolder(gui)
    InitTooltip(gui)

    local main = New("Frame", {
        Name = "MainWindow",
        Size = UDim2.new(0, width, 0, height),
        Position = UDim2.new(0.5, -width / 2, 0.5, -height / 2),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Active = true,
        ClipsDescendants = true,
    }, gui)
    Corner(Theme.RadiusXL, main)
    Stroke(Theme.Border, 1, 0, main)
    self.mainFrame = main

    -- Title bar
    local titleBar = New("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 46),
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
    }, main)
    Corner(Theme.RadiusXL, titleBar)
    New("Frame", {
        Size = UDim2.new(1, 0, 0, 14),
        Position = UDim2.new(0, 0, 1, -14),
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        ZIndex = 2,
    }, titleBar)

    local logoDot = New("Frame", {
        Size = UDim2.new(0, 26, 0, 26),
        Position = UDim2.new(0, 12, 0.5, -13),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        ZIndex = 3,
    }, titleBar)
    Corner(Theme.RadiusFull, logoDot)
    New("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "🐾",
        Font = Theme.FontBold,
        TextSize = 14,
        TextColor3 = Theme.Background,
        ZIndex = 4,
    }, logoDot)

    New("TextLabel", {
        Size = UDim2.new(0, width - 140, 0, 16),
        Position = UDim2.new(0, 46, 0, 6),
        BackgroundTransparency = 1,
        Text = title:upper(),
        Font = Theme.FontBlack,
        TextSize = Theme.SizeTitle,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
    }, titleBar)

    New("TextLabel", {
        Size = UDim2.new(0, width - 140, 0, 12),
        Position = UDim2.new(0, 46, 0, 24),
        BackgroundTransparency = 1,
        Text = subtitle,
        Font = Theme.FontRegular,
        TextSize = Theme.SizeSmall,
        TextColor3 = Theme.TextDim,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
    }, titleBar)

    local ctrl = New("Frame", {
        Size = UDim2.new(0, 70, 0, 30),
        Position = UDim2.new(1, -78, 0.5, -15),
        BackgroundTransparency = 1,
        ZIndex = 3,
    }, titleBar)
    New("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 6),
    }, ctrl)

    local minBtn = New("TextButton", {
        Size = UDim2.new(0, 28, 0, 28),
        BackgroundColor3 = Theme.Surface2,
        BorderSizePixel = 0,
        Text = "—",
        Font = Theme.FontBlack,
        TextSize = 14,
        TextColor3 = Theme.Warning,
        AutoButtonColor = false,
        ZIndex = 4,
    }, ctrl)
    Corner(Theme.RadiusSmall, minBtn)

    local closeBtn = New("TextButton", {
        Size = UDim2.new(0, 28, 0, 28),
        BackgroundColor3 = Theme.Surface2,
        BorderSizePixel = 0,
        Text = "✕",
        Font = Theme.FontBlack,
        TextSize = 12,
        TextColor3 = Theme.Danger,
        AutoButtonColor = false,
        ZIndex = 4,
    }, ctrl)
    Corner(Theme.RadiusSmall, closeBtn)

    minBtn.MouseEnter:Connect(function()
        Tween(minBtn, Theme.AnimFast, { BackgroundColor3 = Theme.Surface3 })
    end)
    minBtn.MouseLeave:Connect(function()
        Tween(minBtn, Theme.AnimFast, { BackgroundColor3 = Theme.Surface2 })
    end)
    closeBtn.MouseEnter:Connect(function()
        Tween(closeBtn, Theme.AnimFast, { BackgroundColor3 = Theme.DangerDark })
    end)
    closeBtn.MouseLeave:Connect(function()
        Tween(closeBtn, Theme.AnimFast, { BackgroundColor3 = Theme.Surface2 })
    end)

    -- Drag
    local dragging, dragStart, startPos
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
           or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
        end
    end)
    titleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
           or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
                        or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    -- Sidebar
    local sidebar = New("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 54, 1, -60),
        Position = UDim2.new(0, 8, 0, 52),
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    }, main)
    Corner(Theme.RadiusLarge, sidebar)
    Stroke(Theme.Border, 1, 0.5, sidebar)

    local sidebarScroll = New("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 0,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    }, sidebar)
    Padding(6, 6, 6, 6, sidebarScroll)
    New("UIListLayout", {
        Padding = UDim.new(0, 4),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
    }, sidebarScroll)

    -- Content
    local content = New("Frame", {
        Name = "Content",
        Size = UDim2.new(1, -78, 1, -60),
        Position = UDim2.new(0, 70, 0, 52),
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    }, main)
    Corner(Theme.RadiusLarge, content)
    Stroke(Theme.Border, 1, 0.5, content)

    self.sidebar, self.sidebarScroll = sidebar, sidebarScroll
    self.content, self.titleBar = content, titleBar

    minBtn.MouseButton1Click:Connect(function()
        self.minimized = not self.minimized
        Tween(main, Theme.AnimSmooth, {
            Size = self.minimized
                and UDim2.new(0, width, 0, 46)
                or  UDim2.new(0, width, 0, height),
        })
        sidebar.Visible = not self.minimized
        content.Visible = not self.minimized
    end)

    function self:Toggle(v)
        if v == nil then v = not main.Visible end
        main.Visible = v
    end
    closeBtn.MouseButton1Click:Connect(function() self:Toggle(false) end)

    -- Nút nổi (kéo được, chạm để ẩn/hiện menu)
    local fb = New("TextButton", {
        Name = "FloatButton", Size = UDim2.new(0, 40, 0, 40),
        Position = UDim2.new(0, 10, 0.35, 0), BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0, Text = "🐾", TextSize = 20, Font = Theme.FontBold,
        TextColor3 = Theme.Background, AutoButtonColor = false, ZIndex = 100,
    }, gui)
    Corner(Theme.RadiusFull, fb)
    Stroke(Theme.AccentGlow, 2, 0.3, fb)
    local fdrag, fstart, fpos, fmoved = false, nil, nil, false
    fb.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            fdrag, fmoved, fstart, fpos = true, false, i.Position, fb.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then
                    fdrag = false
                    if not fmoved then self:Toggle() end
                end
            end)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if fdrag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - fstart
            if d.Magnitude > 6 then fmoved = true end
            if fmoved then
                fb.Position = UDim2.new(fpos.X.Scale, fpos.X.Offset + d.X, fpos.Y.Scale, fpos.Y.Offset + d.Y)
            end
        end
    end)
    self.floatButton = fb

    main.Position = UDim2.new(0.5, -width / 2, 0.7, -height / 2)
    main.BackgroundTransparency = 1
    Tween(main, Theme.AnimSpring, {
        Position = UDim2.new(0.5, -width / 2, 0.5, -height / 2),
        BackgroundTransparency = 0,
    })

    return self
end

function UILibrary:MakeTab(config)
    config = config or {}
    local name  = config.Name or config[1] or "Tab"
    local icon  = config.Icon or config[2] or "•"
    local order = config.Order or (#self.tabs + 1)

    local tabBtn = New("TextButton", {
        Name = "TabBtn_" .. name,
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = Theme.Surface,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        LayoutOrder = order,
    }, self.sidebarScroll)
    Corner(Theme.RadiusSmall, tabBtn)

    local iconLabel = New("TextLabel", {
        Name = "Icon",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = icon,
        Font = Theme.FontBold,
        TextSize = 18,
        TextColor3 = Theme.TextDim,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
    }, tabBtn)

    local indicator = New("Frame", {
        Name = "Indicator",
        Size = UDim2.new(0, 3, 0, 0),
        Position = UDim2.new(0, 0, 0.5, 0),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        ZIndex = 2,
    }, tabBtn)
    Corner(UDim.new(1, 0), indicator)

    local page = New("ScrollingFrame", {
        Name = "Page_" .. name,
        Size = UDim2.new(1, -16, 1, -16),
        Position = UDim2.new(0, 8, 0, 8),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.Border,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Visible = false,
    }, self.content)
    New("UIListLayout", { Padding = UDim.new(0, 8) }, page)

    local tab = {
        name = name, icon = icon, _window = self, _btn = tabBtn,
        _icon = iconLabel, _indicator = indicator, _page = page,
        _elementCount = 0,
        flags = self.flags, -- [Chuppy fix] AddToggle/AddKeybind dùng self.flags nhưng chỉ Window có
    }
    setmetatable(tab, UILibrary)
    table.insert(self.tabs, tab)

    tabBtn.MouseButton1Click:Connect(function() self:SelectTab(name) end)
    tabBtn.MouseEnter:Connect(function()
        if self.currentTab ~= name then
            Tween(tabBtn, Theme.AnimFast, { BackgroundTransparency = 0.5, BackgroundColor3 = Theme.Surface2 })
            Tween(iconLabel, Theme.AnimFast, { TextColor3 = Theme.Text })
            Tooltip.Show(name, tabBtn.AbsolutePosition.X + 40, tabBtn.AbsolutePosition.Y + 8)
        end
    end)
    tabBtn.MouseLeave:Connect(function()
        if self.currentTab ~= name then
            Tween(tabBtn, Theme.AnimFast, { BackgroundTransparency = 1, BackgroundColor3 = Theme.Surface })
            Tween(iconLabel, Theme.AnimFast, { TextColor3 = Theme.TextDim })
        end
        Tooltip.Hide()
    end)

    return tab
end

function UILibrary:SelectTab(name)
    for _, t in ipairs(self.tabs) do
        if t.name == name then
            t._page.Visible = true
            t._btn.BackgroundColor3 = Theme.Surface3
            t._btn.BackgroundTransparency = 0
            t._icon.TextColor3 = Theme.Accent
            t._indicator.Size = UDim2.new(0, 3, 0, 18)
            t._indicator.Position = UDim2.new(0, 0, 0.5, -9)
            self.currentTab = name
        else
            t._page.Visible = false
            t._btn.BackgroundColor3 = Theme.Surface
            t._btn.BackgroundTransparency = 1
            t._icon.TextColor3 = Theme.TextDim
            t._indicator.Size = UDim2.new(0, 3, 0, 0)
            t._indicator.Position = UDim2.new(0, 0, 0.5, 0)
        end
    end
end

function UILibrary:CreateSection(config)
    local name      = type(config) == "table" and (config.Name or config[1]) or (config or "Section")
    local collapsed = type(config) == "table" and config.Collapsed or false

    local wrapper = New("Frame", {
        Name = "SectionWrapper",
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = self._elementCount + 1,
    }, self._page)
    self._elementCount = self._elementCount + 1

    local header = New("TextButton", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundColor3 = Theme.Surface2,
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
    }, wrapper)
    Corner(Theme.RadiusSmall, header)

    local chevron = New("TextLabel", {
        Name = "Chevron",
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(0, 8, 0.5, -10),
        BackgroundTransparency = 1,
        Text = "▶",
        Font = Theme.FontBold,
        TextSize = 10,
        TextColor3 = Theme.Accent,
        Rotation = collapsed and 0 or 90,
    }, header)

    New("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, -50, 1, 0),
        Position = UDim2.new(0, 30, 0, 0),
        BackgroundTransparency = 1,
        Text = name:upper(),
        Font = Theme.FontBold,
        TextSize = Theme.SizeSmall,
        TextColor3 = Theme.Accent,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, header)

    local container = New("Frame", {
        Name = "Container",
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 0, 32),
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
        Visible = not collapsed,
    }, wrapper)
    New("UIListLayout", { Padding = UDim.new(0, 5) }, container)

    local section = {
        _wrapper = wrapper, _header = header, _container = container,
        _chevron = chevron, _collapsed = collapsed, _name = name,
        _window = self,
        _elementCount = 0, -- [Chuppy fix] thiếu trường này nên AddToggle/AddButton trong section bị lỗi nil + 1
        flags = self.flags,
    }
    setmetatable(section, UILibrary)

    header.MouseButton1Click:Connect(function()
        section._collapsed = not section._collapsed
        if section._collapsed then
            container.Visible = false
            Anim.RotateChevron(chevron, 0)
        else
            container.Visible = true
            Anim.RotateChevron(chevron, 90)
        end
    end)

    header.MouseEnter:Connect(function()
        Tween(header, Theme.AnimFast, { BackgroundTransparency = 0 })
    end)
    header.MouseLeave:Connect(function()
        Tween(header, Theme.AnimFast, { BackgroundTransparency = 0.4 })
    end)

    return section
end

function UILibrary:AddToggle(config, callback)
    config = config or {}
    local name     = config.Name or "Toggle"
    local desc     = config.Desc
    local default  = config.Default or false
    local flag     = config.Flag or name
    local disabled = config.Disabled or false
    local tooltip  = config.Tooltip
    local hasDesc  = desc ~= nil and desc ~= ""
    local height   = hasDesc and 54 or 42

    local frame = New("TextButton", {
        Name = "Toggle_" .. name,
        Size = UDim2.new(1, 0, 0, height),
        BackgroundColor3 = Theme.Surface2,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        LayoutOrder = self._elementCount + 1,
    }, self._container or self._page)
    Corner(Theme.RadiusSmall, frame)
    local frameStroke = Stroke(Theme.Border, 1, 0.7, frame)
    self._elementCount = self._elementCount + 1

    local title = New("TextLabel", {
        Size = UDim2.new(1, -80, 0, 16),
        Position = UDim2.new(0, 12, 0, hasDesc and 8 or 0),
        BackgroundTransparency = 1,
        Text = name,
        Font = Theme.FontMedium,
        TextSize = Theme.SizeMedium,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, frame)

    if hasDesc then
        New("TextLabel", {
            Size = UDim2.new(1, -80, 0, 14),
            Position = UDim2.new(0, 12, 0, 26),
            BackgroundTransparency = 1,
            Text = desc,
            Font = Theme.FontRegular,
            TextSize = Theme.SizeSmall,
            TextColor3 = Theme.TextDim,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
        }, frame)
    end

    local switch = New("Frame", {
        Size = UDim2.new(0, 42, 0, 22),
        Position = UDim2.new(1, -54, 0.5, -11),
        BackgroundColor3 = default and Theme.Success or Theme.Surface3,
        BorderSizePixel = 0,
    }, frame)
    Corner(Theme.RadiusFull, switch)

    local knob = New("Frame", {
        Size = UDim2.new(0, 18, 0, 18),
        Position = default and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9),
        BackgroundColor3 = Theme.TextBright,
        BorderSizePixel = 0,
    }, switch)
    Corner(Theme.RadiusFull, knob)

    local state = default
    local function updateVisual(instant)
        local info       = instant and Theme.AnimInstant or Theme.AnimSmooth
        local springInfo = instant and Theme.AnimInstant or Theme.AnimSpring
        if state then
            Tween(switch, info, { BackgroundColor3 = Theme.Success })
            Tween(knob, springInfo, {
                Position = UDim2.new(1, -20, 0.5, -9),
                BackgroundColor3 = Theme.TextBright,
            })
            Tween(frameStroke, info, { Color = Theme.Success, Transparency = 0.6 })
            Tween(title, info, { TextColor3 = Theme.TextBright })
        else
            Tween(switch, info, { BackgroundColor3 = Theme.Surface3 })
            Tween(knob, springInfo, {
                Position = UDim2.new(0, 2, 0.5, -9),
                BackgroundColor3 = Theme.TextDim,
            })
            Tween(frameStroke, info, { Color = Theme.Border, Transparency = 0.7 })
            Tween(title, info, { TextColor3 = Theme.Text })
        end
    end

    local clickable = New("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 5,
    }, frame)

    clickable.MouseButton1Click:Connect(function()
        if disabled then return end
        state = not state
        updateVisual()
        Anim.Pulse(frame, 1.015, 0.15)
        if callback then pcall(callback, state) end
    end)

    clickable.MouseEnter:Connect(function()
        if disabled then return end
        Tween(frame, Theme.AnimFast, { BackgroundColor3 = Theme.Surface3 })
    end)
    clickable.MouseLeave:Connect(function()
        Tween(frame, Theme.AnimFast, { BackgroundColor3 = Theme.Surface2 })
    end)

    if tooltip then Tooltip.Attach(frame, tooltip) end
    self.flags[flag] = { type = "toggle", value = state }

    return {
        Set = function(v)
            if state ~= v then
                state = v
                updateVisual(true)
                if callback then pcall(callback, state) end
            end
        end,
        Get = function() return state end,
        SetDisabled = function(v)
            disabled = v
            frame.BackgroundTransparency = v and 0.5 or 0
        end,
        Flag = flag,
    }
end

function UILibrary:AddButton(config, callback)
    config = config or {}
    local name    = config.Name or "Button"
    local desc    = config.Desc
    local color   = config.Color or Theme.Accent
    local tooltip = config.Tooltip
    local hasDesc = desc ~= nil and desc ~= ""
    local height  = hasDesc and 50 or 40

    local btn = New("TextButton", {
        Name = "Button_" .. name,
        Size = UDim2.new(1, 0, 0, height),
        BackgroundColor3 = Theme.Surface2,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        ClipsDescendants = true,
        LayoutOrder = self._elementCount + 1,
    }, self._container or self._page)
    Corner(Theme.RadiusSmall, btn)
    local btnStroke = Stroke(color, 1, 0.5, btn)
    self._elementCount = self._elementCount + 1

    New("TextLabel", {
        Size = UDim2.new(1, -40, 0, 16),
        Position = UDim2.new(0, 12, 0, hasDesc and 8 or 0),
        BackgroundTransparency = 1,
        Text = name,
        Font = Theme.FontMedium,
        TextSize = Theme.SizeMedium,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, btn)

    if hasDesc then
        New("TextLabel", {
            Size = UDim2.new(1, -40, 0, 14),
            Position = UDim2.new(0, 12, 0, 26),
            BackgroundTransparency = 1,
            Text = desc,
            Font = Theme.FontRegular,
            TextSize = Theme.SizeSmall,
            TextColor3 = Theme.TextDim,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
        }, btn)
    end

    New("TextLabel", {
        Size = UDim2.new(0, 20, 1, 0),
        Position = UDim2.new(1, -26, 0, 0),
        BackgroundTransparency = 1,
        Text = "›",
        Font = Theme.FontBlack,
        TextSize = 18,
        TextColor3 = color,
    }, btn)

    btn.MouseButton1Click:Connect(function()
        local mouse = UIS:GetMouseLocation()
        Anim.Ripple(btn, mouse.X - btn.AbsolutePosition.X, mouse.Y - btn.AbsolutePosition.Y, color)
        Anim.Pulse(btn, 0.98, 0.1)
        if callback then pcall(callback) end
    end)

    btn.MouseEnter:Connect(function()
        Tween(btn, Theme.AnimFast, { BackgroundColor3 = Theme.Surface3 })
        Tween(btnStroke, Theme.AnimFast, { Transparency = 0.2 })
    end)
    btn.MouseLeave:Connect(function()
        Tween(btn, Theme.AnimFast, { BackgroundColor3 = Theme.Surface2 })
        Tween(btnStroke, Theme.AnimFast, { Transparency = 0.5 })
    end)

    if tooltip then Tooltip.Attach(btn, tooltip) end
    return btn
end

function UILibrary:AddSlider(config, callback)
    config = config or {}
    local name    = config.Name or "Slider"
    local min     = config.Min or 0
    local max     = config.Max or 100
    local default = config.Default or min
    local step    = config.Step or 1
    local suffix  = config.Suffix or ""
    local value   = math.clamp(default, min, max)

    local frame = New("Frame", {
        Name = "Slider_" .. name,
        Size = UDim2.new(1, 0, 0, 52),
        BackgroundColor3 = Theme.Surface2,
        BorderSizePixel = 0,
        LayoutOrder = self._elementCount + 1,
    }, self._container or self._page)
    Corner(Theme.RadiusSmall, frame)
    local frameStroke = Stroke(Theme.Border, 1, 0.7, frame)
    self._elementCount = self._elementCount + 1

    New("TextLabel", {
        Size = UDim2.new(0.6, -12, 0, 18),
        Position = UDim2.new(0, 12, 0, 6),
        BackgroundTransparency = 1,
        Text = name,
        Font = Theme.FontMedium,
        TextSize = Theme.SizeMedium,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, frame)

    local valueLabel = New("TextLabel", {
        Size = UDim2.new(0.4, -12, 0, 18),
        Position = UDim2.new(0.6, 0, 0, 6),
        BackgroundTransparency = 1,
        Text = tostring(value) .. suffix,
        Font = Theme.FontBold,
        TextSize = Theme.SizeMedium,
        TextColor3 = Theme.Accent,
        TextXAlignment = Enum.TextXAlignment.Right,
    }, frame)

    local track = New("Frame", {
        Size = UDim2.new(1, -24, 0, 8),
        Position = UDim2.new(0, 12, 0, 32),
        BackgroundColor3 = Theme.SurfaceDeep,
        BorderSizePixel = 0,
    }, frame)
    Corner(Theme.RadiusFull, track)

    local fill = New("Frame", {
        Size = UDim2.new((value - min) / math.max(max - min, 1), 0, 1, 0),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
    }, track)
    Corner(Theme.RadiusFull, fill)

    local knob = New("Frame", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new((value - min) / math.max(max - min, 1), -8, 0.5, -8),
        BackgroundColor3 = Theme.TextBright,
        BorderSizePixel = 0,
        ZIndex = 3,
    }, track)
    Corner(Theme.RadiusFull, knob)

    local dragging = false
    local trackInput = New("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 5,
    }, track)

    local function updateFromX(relX)
        relX = math.clamp(relX, 0, 1)
        local rawValue = min + (max - min) * relX
        local finalValue = math.clamp(math.floor(rawValue / step + 0.5) * step, min, max)
        value = finalValue
        local rel = (value - min) / math.max(max - min, 1)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        knob.Position = UDim2.new(rel, -8, 0.5, -8)
        valueLabel.Text = tostring(value) .. suffix
        if callback then pcall(callback, value) end
    end

    trackInput.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
           or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateFromX((input.Position.X - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1))
        end
    end)
    trackInput.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
           or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
                        or input.UserInputType == Enum.UserInputType.Touch) then
            updateFromX((input.Position.X - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1))
        end
    end)

    trackInput.MouseEnter:Connect(function()
        Tween(frameStroke, Theme.AnimFast, { Transparency = 0.4 })
    end)
    trackInput.MouseLeave:Connect(function()
        Tween(frameStroke, Theme.AnimFast, { Transparency = 0.7 })
    end)

    return {
        Set = function(v)
            v = math.clamp(v, min, max)
            value = v
            local rel = (value - min) / math.max(max - min, 1)
            fill.Size = UDim2.new(rel, 0, 1, 0)
            knob.Position = UDim2.new(rel, -8, 0.5, -8)
            valueLabel.Text = tostring(value) .. suffix
            if callback then pcall(callback, value) end
        end,
        Get = function() return value end,
    }
end

function UILibrary:AddDropdown(config, callback)
    config = config or {}
    local name    = config.Name or "Dropdown"
    local options = config.Options or config.List or {}
    local default = config.Default or options[1]
    local search  = config.Search or false

    local frame = New("Frame", {
        Name = "Dropdown_" .. name,
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = Theme.Surface2,
        BorderSizePixel = 0,
        LayoutOrder = self._elementCount + 1,
        ZIndex = 3,
    }, self._container or self._page)
    Corner(Theme.RadiusSmall, frame)
    local frameStroke = Stroke(Theme.Border, 1, 0.7, frame)
    self._elementCount = self._elementCount + 1

    local valueLabel = New("TextLabel", {
        Size = UDim2.new(1, -40, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = name .. ": " .. tostring(default or "None"),
        Font = Theme.FontMedium,
        TextSize = Theme.SizeMedium,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
    }, frame)

    local arrow = New("TextLabel", {
        Size = UDim2.new(0, 20, 1, 0),
        Position = UDim2.new(1, -26, 0, 0),
        BackgroundTransparency = 1,
        Text = "▾",
        Font = Theme.FontBlack,
        TextSize = 14,
        TextColor3 = Theme.Accent,
    }, frame)

    local clickBtn = New("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 4,
    }, frame)

    local menu = New("ScrollingFrame", {
        Name = "Menu",
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 1, 4),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.Accent,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Visible = false,
        ZIndex = 100,
    }, frame)
    Corner(Theme.RadiusSmall, menu)
    Stroke(Theme.BorderLight, 1, 0, menu)
    New("UIListLayout", { Padding = UDim.new(0, 2) }, menu)
    Padding(4, 4, 4, 4, menu)

    local selected = { [default] = true }
    local currentValue = default
    local optBtns = {}

    local searchBox
    if search then
        searchBox = New("TextBox", {
            Size = UDim2.new(1, 0, 0, 26),
            BackgroundColor3 = Theme.Surface2,
            BorderSizePixel = 0,
            Text = "",
            PlaceholderText = "🔍 Tìm kiếm...",
            PlaceholderColor3 = Theme.TextMuted,
            Font = Theme.FontRegular,
            TextSize = Theme.SizeSmall,
            TextColor3 = Theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            ClearTextOnFocus = false,
            LayoutOrder = 0,
        }, menu)
        Corner(Theme.RadiusSmall, searchBox)
        Padding(0, 0, 8, 8, searchBox)
    end

    for i, opt in ipairs(options) do
        local optBtn = New("TextButton", {
            Name = "Opt_" .. tostring(opt),
            Size = UDim2.new(1, 0, 0, 26),
            BackgroundColor3 = Theme.Surface2,
            BorderSizePixel = 0,
            Text = "  " .. tostring(opt),
            Font = Theme.FontRegular,
            TextSize = Theme.SizeSmall,
            TextColor3 = selected[opt] and Theme.Accent or Theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            AutoButtonColor = false,
            LayoutOrder = i + (search and 1 or 0),
        }, menu)
        Corner(Theme.RadiusSmall, optBtn)
        table.insert(optBtns, { btn = optBtn, name = tostring(opt) })

        optBtn.MouseEnter:Connect(function()
            Tween(optBtn, Theme.AnimFast, { BackgroundColor3 = Theme.Surface3 })
        end)
        optBtn.MouseLeave:Connect(function()
            Tween(optBtn, Theme.AnimFast, { BackgroundColor3 = Theme.Surface2 })
        end)
        optBtn.MouseButton1Click:Connect(function()
            for _, data in ipairs(optBtns) do
                data.btn.TextColor3 = Theme.Text
            end
            optBtn.TextColor3 = Theme.Accent
            currentValue = opt
            valueLabel.Text = name .. ": " .. tostring(opt)
            menu.Visible = false
            menu.Size = UDim2.new(1, 0, 0, 0)
            arrow.Rotation = 0
            if callback then pcall(callback, opt) end
        end)
    end

    if searchBox then
        searchBox:GetPropertyChangedSignal("Text"):Connect(function()
            local txt = searchBox.Text:lower()
            for _, data in ipairs(optBtns) do
                data.btn.Visible = txt == "" or data.name:lower():find(txt, 1, true) ~= nil
            end
        end)
    end

    local isOpen = false
    clickBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then
            local layout = menu:FindFirstChildOfClass("UIListLayout")
            local h = math.min((layout and layout.AbsoluteContentSize.Y or 30) + 10, 180)
            menu.Visible = true
            Tween(menu, Theme.AnimSpring, { Size = UDim2.new(1, 0, 0, h) })
            Tween(arrow, Theme.AnimSpring, { Rotation = 180 })
            Tween(frameStroke, Theme.AnimFast, { Color = Theme.Accent, Transparency = 0.3 })
        else
            Tween(menu, Theme.AnimFast, { Size = UDim2.new(1, 0, 0, 0) })
            Tween(arrow, Theme.AnimFast, { Rotation = 0 })
            Tween(frameStroke, Theme.AnimFast, { Color = Theme.Border, Transparency = 0.7 })
            task.delay(0.15, function()
                if not isOpen then menu.Visible = false end
            end)
        end
    end)

    clickBtn.MouseEnter:Connect(function()
        Tween(frame, Theme.AnimFast, { BackgroundColor3 = Theme.Surface3 })
    end)
    clickBtn.MouseLeave:Connect(function()
        Tween(frame, Theme.AnimFast, { BackgroundColor3 = Theme.Surface2 })
    end)

    return {
        Set = function(v)
            currentValue = v
            selected = { [v] = true }
            for _, data in ipairs(optBtns) do
                data.btn.TextColor3 = (data.name == tostring(v)) and Theme.Accent or Theme.Text
            end
            valueLabel.Text = name .. ": " .. tostring(v)
            if callback then pcall(callback, v) end
        end,
        Get = function() return currentValue end,
    }
end

function UILibrary:AddLabel(config)
    if type(config) == "string" then config = { Text = config } end
    config = config or {}
    local text   = config.Text or config.Title or "Label"
    local color  = config.Color or Theme.TextDim
    local size   = config.Size or Theme.SizeSmall
    local bold   = config.Bold or false
    local center = config.Center or false

    local lbl = New("TextLabel", {
        Name = "Label",
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = text,
        Font = bold and Theme.FontBold or Theme.FontRegular,
        TextSize = size,
        TextColor3 = color,
        TextXAlignment = center and Enum.TextXAlignment.Center or Enum.TextXAlignment.Left,
        TextWrapped = true,
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = self._elementCount + 1,
    }, self._container or self._page)
    Padding(2, 2, 4, 4, lbl)
    self._elementCount = self._elementCount + 1

    return {
        SetText = function(t) lbl.Text = tostring(t) end,
        GetText = function() return lbl.Text end,
        Instance = lbl,
    }
end

function UILibrary:AddDivider(config)
    config = config or {}
    local div = New("Frame", {
        Name = "Divider",
        Size = UDim2.new(1, -20, 0, 1),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundColor3 = config.Color or Theme.Border,
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        LayoutOrder = self._elementCount + 1,
    }, self._container or self._page)
    self._elementCount = self._elementCount + 1
    return div
end

function UILibrary:AddKeybind(config, callback)
    config = config or {}
    local name    = config.Name or "Keybind"
    local default = config.Default or Enum.KeyCode.RightShift
    local flag    = config.Flag or name
    local current = default
    local listening = false

    local frame = New("Frame", {
        Name = "Keybind_" .. name,
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = Theme.Surface2,
        BorderSizePixel = 0,
        LayoutOrder = self._elementCount + 1,
    }, self._container or self._page)
    Corner(Theme.RadiusSmall, frame)
    self._elementCount = self._elementCount + 1

    New("TextLabel", {
        Size = UDim2.new(0.5, 0, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = name,
        Font = Theme.FontMedium,
        TextSize = Theme.SizeMedium,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, frame)

    local keyBtn = New("TextButton", {
        Size = UDim2.new(0, 80, 0, 26),
        Position = UDim2.new(1, -92, 0.5, -13),
        BackgroundColor3 = Theme.SurfaceDeep,
        BorderSizePixel = 0,
        Text = current.Name,
        Font = Theme.FontBold,
        TextSize = Theme.SizeSmall,
        TextColor3 = Theme.Accent,
        AutoButtonColor = false,
    }, frame)
    Corner(Theme.RadiusSmall, keyBtn)

    keyBtn.MouseButton1Click:Connect(function()
        listening = true
        keyBtn.Text = "..."
        keyBtn.TextColor3 = Theme.Warning
    end)

    UIS.InputBegan:Connect(function(input, gp)
        if listening and not gp and input.UserInputType == Enum.UserInputType.Keyboard then
            current = input.KeyCode
            keyBtn.Text = current.Name
            keyBtn.TextColor3 = Theme.Accent
            listening = false
            if callback then pcall(callback, current) end
        elseif not listening and input.KeyCode == current and not gp then
            if callback then pcall(callback, current) end
        end
    end)

    self.flags[flag] = { type = "keybind", value = current }
    return {
        Get = function() return current end,
        Set = function(k)
            current = k
            keyBtn.Text = k.Name
            if callback then pcall(callback, k) end
        end,
    }
end

function UILibrary:AddInput(config, callback)
    config = config or {}
    local name        = config.Name or "Input"
    local placeholder = config.Placeholder or "Nhập..."
    local default     = config.Default or ""

    local frame = New("Frame", {
        Name = "Input_" .. name,
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Theme.Surface2,
        BorderSizePixel = 0,
        LayoutOrder = self._elementCount + 1,
    }, self._container or self._page)
    Corner(Theme.RadiusSmall, frame)
    local inputStroke = Stroke(Theme.Border, 1, 0.7, frame)
    self._elementCount = self._elementCount + 1

    New("TextLabel", {
        Size = UDim2.new(0.4, 0, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = name,
        Font = Theme.FontMedium,
        TextSize = Theme.SizeSmall,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
    }, frame)

    local box = New("TextBox", {
        Size = UDim2.new(0.55, -12, 0, 26),
        Position = UDim2.new(0.45, 0, 0.5, -13),
        BackgroundColor3 = Theme.SurfaceDeep,
        BorderSizePixel = 0,
        Text = default,
        PlaceholderText = placeholder,
        PlaceholderColor3 = Theme.TextMuted,
        Font = Theme.FontRegular,
        TextSize = Theme.SizeSmall,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
    }, frame)
    Corner(Theme.RadiusSmall, box)
    Padding(0, 0, 8, 8, box)

    box.Focused:Connect(function()
        Tween(inputStroke, Theme.AnimFast, { Color = Theme.Accent })
    end)
    box.FocusLost:Connect(function()
        Tween(inputStroke, Theme.AnimFast, { Color = Theme.Border })
        if callback then pcall(callback, box.Text) end
    end)

    return {
        Set = function(v) box.Text = tostring(v) end,
        Get = function() return box.Text end,
        Instance = box,
    }
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- [1.8] EXPORT
-- ═══════════════════════════════════════════════════════════════════════════════
getgenv().ChuppyUI = UILibrary

print("═══════════════════════════════════════════════════════════════════════════════")
print("  ✅ PART 1/10 — UI LIBRARY LOADED")
print("  📦 ChuppyTheme · ChuppyUI · ChuppyNotification · ChuppyModal · ChuppyTooltip · ChuppyAnim")
print("═══════════════════════════════════════════════════════════════════════════════")

end)() -- End IIFE

-- ═══════════════════════════════════════════════════════════════════════════════
-- 🥚 CHUPPY HUB — STEAL AN EGG
-- Auto Steal · Auto Place · Auto Hatch · Equip Best · Claim · Upgrade · ESP · Misc
-- ═══════════════════════════════════════════════════════════════════════════════
;(function()

local Players         = game:GetService("Players")
local RS              = game:GetService("ReplicatedStorage")
local RunService      = game:GetService("RunService")
local UIS             = game:GetService("UserInputService")
local Lighting        = game:GetService("Lighting")
local VirtualUser     = game:GetService("VirtualUser")
local TeleportService = game:GetService("TeleportService")
local HttpService     = game:GetService("HttpService")
local LP              = Players.LocalPlayer

local UI, Theme, Notif = getgenv().ChuppyUI, getgenv().ChuppyTheme, getgenv().ChuppyNotification
if not UI or not Theme then warn("[ChuppyEgg] Thiếu UI library"); return end
if getgenv().ChuppyEggUnload then pcall(getgenv().ChuppyEggUnload) end

-- ═══ [1] STATE ═══
local S = {
    Running = true, Status = "Đang chờ", Stolen = 0, Placed = 0, Hatched = 0, StartTime = os.clock(),
    AutoSteal = false, AutoPlace = false, AutoHatch = false, AutoEquip = false, AutoClaim = false,
    UpBase = false, UpTread = false,
    Speed = 300, FlightY = 78, Timeout = 3.5, MaxPlaced = 30,
    Priority = "Hiếm nhất", MinRarity = 1, NameFilter = "", PlaceRule = "Sau mỗi lần steal",
    ESPEggs = false, ESPRare = false, ESPGuards = false, GuardWarn = false, AutoDrop = false,
    AntiKB = true, NoClip = false, InfJump = false, AntiAFK = true, Lag = false, White = false,
    WalkSpeed = 24, SpeedHack = false,
}
getgenv().ChuppyEgg = S
local conns = {}
local function Track(c) conns[#conns + 1] = c; return c end
local function N(kind, title, desc) pcall(function() Notif[kind](title, desc, 3) end) end

-- ═══ [2] MODULE GAME ═══
local function Find(root, ...)
    for _, n in ipairs({ ... }) do root = root and root:FindFirstChild(n) end
    return root
end
local function Req(inst)
    if not inst then return nil end
    local ok, r = pcall(require, inst)
    return ok and r or nil
end
pcall(function() RS:WaitForChild("Shared", 20); RS:WaitForChild("Client", 20) end)

local Remotes    = Req(Find(RS, "Shared", "Remotes"))
local EggState   = Req(Find(RS, "Client", "EggState"))
local PlotState  = Req(Find(RS, "Client", "PlotState"))
local Save       = Req(Find(RS, "Shared", "Save"))
local Assets     = Req(Find(RS, "Data", "Assets"))
local Bases      = Req(Find(RS, "Data", "Bases"))
local Treadmills = Req(Find(RS, "Data", "Treadmills"))
local SlotId     = Req(Find(RS, "Shared", "Util", "AreaEggSlotIdentity"))
local Cycle      = Req(Find(RS, "Shared", "Util", "AreaEggCycle"))
local Wall       = Req(Find(RS, "Client", "AreaEggResetWall"))

local function RF(group, name)
    local ok, r = pcall(function() return Remotes[group][name] end)
    return ok and r or nil
end
local function Invoke(group, name, ...)
    local rf = RF(group, name)
    if not rf then return nil end
    local args = { ... }
    local ok, r = pcall(function() return rf:InvokeServer(table.unpack(args)) end)
    return ok and r or nil
end

-- ═══ [3] TIỆN ÍCH NHÂN VẬT / DI CHUYỂN ═══
local function HRP() local c = LP.Character; return c and c:FindFirstChild("HumanoidRootPart") end
local function Hum() local c = LP.Character; return c and c:FindFirstChildOfClass("Humanoid") end

local function AntiTP()
    pcall(function() workspace:SetAttribute("ClientObbyAntiTp", false) end)
    pcall(function()
        local ps = LP:FindFirstChild("PlayerScripts")
        if not ps then return end
        for _, n in ipairs({ "ObbyAntiTPClient", "AntiTP", "AntiTeleport" }) do
            local s = ps:FindFirstChild(n)
            if s and s:IsA("LocalScript") and not s.Disabled then s.Disabled = true end
        end
    end)
end

local function Fix()
    local h, r = Hum(), HRP()
    if h then pcall(function()
        h.PlatformStand = false; h.Sit = false
        local st = h:GetState()
        if st == Enum.HumanoidStateType.Ragdoll or st == Enum.HumanoidStateType.FallingDown or st == Enum.HumanoidStateType.Physics then
            h:ChangeState(Enum.HumanoidStateType.GettingUp)
            h:ChangeState(Enum.HumanoidStateType.Running)
        end
    end) end
    if r then r.AssemblyLinearVelocity = Vector3.zero; r.AssemblyAngularVelocity = Vector3.zero end
end

local moving = false
Track(RunService.Stepped:Connect(function()
    if not (moving or S.NoClip) then return end
    local c = LP.Character
    if not c then return end
    for _, p in ipairs(c:GetChildren()) do
        if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
    end
end))

-- Bay thẳng tới pos (chặn tới khi tới nơi). abort() được kiểm tra mỗi 0.25s
local function Go(pos, speed, abort)
    local r = HRP()
    if not r then return false end
    AntiTP(); Fix()
    speed = math.max(speed or S.Speed, 20)
    moving = true
    local t0, lastAbort = os.clock(), 0
    local result = false
    while S.Running do
        r = HRP()
        if not r then break end
        local d = pos - r.Position
        local m = d.Magnitude
        if m <= 1.5 then
            r.CFrame = CFrame.new(pos) * (r.CFrame - r.CFrame.Position)
            r.AssemblyLinearVelocity = Vector3.zero
            result = true
            break
        end
        if abort and os.clock() - lastAbort > 0.25 then
            lastAbort = os.clock()
            if abort() then break end
        end
        local dt = RunService.Heartbeat:Wait()
        local step = math.min(m, speed * dt)
        r.CFrame = CFrame.new(r.Position + d.Unit * step) * (r.CFrame - r.CFrame.Position)
        r.AssemblyLinearVelocity = Vector3.zero
        if os.clock() - t0 > m / speed + 6 then
            r.CFrame = CFrame.new(pos) * (r.CFrame - r.CFrame.Position)
            result = true
            break
        end
    end
    moving = false
    return result
end

-- Bay cao rồi mới hạ xuống (tránh tường/vật cản)
local function GoFar(pos, speed, abort)
    local r = HRP()
    if not r then return false end
    if (r.Position - pos).Magnitude <= 100 then return Go(pos, speed, abort) end
    local fy = math.max(S.FlightY, r.Position.Y)
    if not Go(Vector3.new(r.Position.X, fy, r.Position.Z), speed, abort) then return false end
    if not Go(Vector3.new(pos.X, fy, pos.Z), speed, abort) then return false end
    return Go(pos, speed, abort)
end

-- ═══ [4] SAFE ZONE / ĐÊM ═══
local function SafeZone()
    local world = workspace:FindFirstChild("World")
    local sp = Find(world, "Build", "MainMap", "SpawnTarget")
    if sp then
        local p
        if sp:IsA("BasePart") then p = sp.Position
        elseif sp:IsA("Attachment") then p = sp.WorldPosition
        elseif sp:IsA("Model") and sp.PrimaryPart then p = sp.PrimaryPart.Position end
        if p then return p + Vector3.new(0, -5, 0) end
    end
    local sa = Find(world, "Areas", "StartArea")
    if sa and sa:IsA("BasePart") then return sa.Position + Vector3.new(0, 2.5, 0) end
    if sa and sa:IsA("Model") and sa.PrimaryPart then return sa.PrimaryPart.Position + Vector3.new(0, 2.5, 0) end
    return Vector3.new(515, 74.4, -362.8)
end

local function InSafe()
    local r = HRP()
    local areas = Find(workspace, "World", "Areas")
    local line, start = areas and areas:FindFirstChild("SeparationLine"), areas and areas:FindFirstChild("StartArea")
    if not r or not line or not start or not line:IsA("BasePart") or not start:IsA("BasePart") then return false end
    local me = line.CFrame:PointToObjectSpace(r.Position).Z >= 0
    local sz = line.CFrame:PointToObjectSpace(start.Position).Z >= 0
    return me == sz
end

local function Night()
    local ok, r = pcall(function()
        if Cycle then
            local t = workspace:GetServerTimeNow()
            if Cycle.IsNightPhase then return Cycle.IsNightPhase(t) == true end
            if Cycle.IsNight then return Cycle.IsNight(t) == true end
        end
        return false
    end)
    if ok and r then return true end
    ok, r = pcall(function()
        if Wall then
            if Wall.IsSealed then return Wall.IsSealed() == true end
            if Wall.IsClosed then return Wall.IsClosed() == true end
        end
        return false
    end)
    return ok and r or false
end

-- ═══ [5] DỮ LIỆU EGG ═══
local fieldCache, fieldAt = {}, 0
local function Fields()
    if os.clock() - fieldAt < 0.2 then return fieldCache end
    local list
    if EggState and EggState.ReadFieldEggs then
        local ok, r = pcall(EggState.ReadFieldEggs)
        if ok and type(r) == "table" then list = r.Records or r end
    end
    if not list or #list == 0 then
        local r = Invoke("EggWorld", "AskFieldEggSnapshot")
        if type(r) == "table" then list = r.Records or list end
    end
    fieldCache, fieldAt = list or {}, os.clock()
    return fieldCache
end

local ownCache, ownAt = {}, 0
local function Own(force)
    if not force and os.clock() - ownAt < 1.5 then return ownCache end
    local snap = Invoke("EggWorld", "AskLiveSnapshot")
    if type(snap) ~= "table" and EggState and EggState.ReadOwnedEggs then
        local ok, r = pcall(EggState.ReadOwnedEggs)
        if ok then snap = r end
    end
    local recs = {}
    if type(snap) == "table" then
        if snap.Records then snap = { snap } end
        for _, v in ipairs(snap) do
            if v.OwnerUserId == LP.UserId then recs = v.Records or {}; break end
        end
    end
    ownCache, ownAt = recs, os.clock()
    return recs
end

local RARN = { common = 1, uncommon = 2, rare = 3, epic = 4, legendary = 5, mythic = 6, secret = 7 }
local function Info(cat)
    if not Assets or not cat then return nil end
    local t = Assets[cat]
    if type(t) ~= "table" and type(Assets.ASSETS) == "table" then t = Assets.ASSETS[cat] end
    if type(t) ~= "table" and type(Assets.Assets) == "table" then t = Assets.Assets[cat] end
    return type(t) == "table" and t or nil
end
local function RarityNum(rec)
    if type(rec.RarityNumber) == "number" then return rec.RarityNumber end
    local a = Info(rec.AssetCategory)
    if not a then return 1 end
    local r = a.Rarity
    if type(r) == "table" then
        return r.Rank or r.RarityNumber or RARN[string.lower(tostring(r.DisplayName or r.Name or r._id or ""))] or 1
    elseif type(r) == "string" then return RARN[string.lower(r)] or 1
    elseif type(r) == "number" then return r end
    return a.Rank or a.RarityNumber or 1
end
local function Scale(rec) return tonumber(rec.AssetScale) or tonumber(rec.Scale) or 1 end
local function Income(rec)
    local a = Info(rec.AssetCategory)
    local rate = a and tonumber(a.EarningRate) or 0
    if rate <= 0 then return 0 end
    local sc = Scale(rec)
    return rate * (sc <= 5 and sc ^ 1.85 or (sc / 5) ^ 1.2 * 19.637875755794113)
end
local function DisplayName(rec)
    local a = Info(rec.AssetCategory)
    return (a and (a.DisplayName or a.Name)) or tostring(rec.AssetCategory or "Egg")
end

local function EggPos(rec)
    local slot = Find(workspace, "AreaEggSlotsClient", tostring(rec.Uid), "Hitbox")
    if slot and slot:IsA("BasePart") then return slot.Position end
    local cf = rec.BottomCFrame or rec.BoundsCFrame
    if cf then return cf.Position + Vector3.new(0, 1.8, 0) end
    if rec.Position then return rec.Position end
    return nil
end

local function SlotKey(rec)
    if rec.State == "Dropped" then return nil end
    local uid = tostring(rec.Uid or "")
    local nest = rec.NestId or string.match(uid, "(Slot_%d+)")
    local area = rec.AreaId or "Forest"
    if nest and SlotId and SlotId.LooksLikeFirstAreaUid and SlotId.LooksLikeFirstAreaUid(uid) then
        local ok, r = pcall(SlotId.SlotKey, area, nest)
        if ok and r then return r end
    end
    if nest then return tostring(area) .. ":" .. tostring(nest) end
    return nil
end

local function IsCarrying(uid)
    if uid and EggState and EggState.ReadFieldEgg then
        local ok, r = pcall(EggState.ReadFieldEgg, tostring(uid))
        if ok and r and r.CarrierUserId == LP.UserId then return true end
    end
    fieldAt = 0
    for _, r in ipairs(Fields()) do
        if r.CarrierUserId == LP.UserId and (not uid or r.Uid == uid) then return true end
    end
    return false
end

local function Carry(rec)
    local key = SlotKey(rec)
    if EggState and EggState.CarryFieldEgg then
        local ok, r = pcall(EggState.CarryFieldEgg, rec.Uid, key)
        if ok and r == true then return true end
    end
    local ok, r = pcall(function()
        local rf = RF("EggWorld", "AskFieldEggCarry")
        return rf and rf:InvokeServer({ Uid = rec.Uid, FirstAreaSlotKey = key })
    end)
    if ok and (r == true or (type(r) == "table" and r.Outcome == true)) then return true end
    pcall(function()
        if not fireproximityprompt then return end
        local m = Find(workspace, "AreaEggSlotsClient", tostring(rec.Uid))
        if m then for _, d in ipairs(m:GetDescendants()) do
            if d:IsA("ProximityPrompt") and d.Enabled then fireproximityprompt(d, 0) end
        end end
    end)
    return IsCarrying(rec.Uid)
end

local function Unequip()
    pcall(function()
        local c = LP.Character
        if c then for _, t in ipairs(c:GetChildren()) do
            if t:IsA("Tool") and (t:GetAttribute("ItemType") == "AssetEgg" or string.find(t.Name:lower(), "egg")) then
                t.Parent = LP:FindFirstChildOfClass("Backpack")
            end
        end end
    end)
    pcall(function() if EggState and EggState.DoffEggTool then EggState.DoffEggTool() end end)
end

local function DropEgg()
    pcall(function()
        if EggState and EggState.DropFieldEgg then EggState.DropFieldEgg("Manual")
        else Invoke("EggWorld", "AskFieldEggDrop", { Reason = "Manual" }) end
    end)
end

-- Hook sự kiện claim
local claimedAt = 0
pcall(function()
    if EggState and EggState.FieldClaimed then
        Track(EggState.FieldClaimed:Connect(function() claimedAt = os.clock() end))
    end
end)
pcall(function()
    local ev = RF("RigSync", "Refresh")
    if ev then Track(ev.OnClientEvent:Connect(function(arg)
        if not S.AntiKB or typeof(arg) ~= "string" then return end
        if arg:find("BeginRagdoll") or arg:find("BeginImpulse") then task.defer(Fix); task.delay(0.1, Fix) end
    end)) end
end)

-- ═══ [6] AUTO STEAL ═══
local blocked = {}
local function Pick()
    local r = HRP()
    if not r then return nil end
    local best, bs
    local filt = string.lower(S.NameFilter or "")
    for _, rec in ipairs(Fields()) do
        local uid = rec.Uid
        if uid and (rec.State == "Slot" or rec.State == "Dropped") and rec.CarrierUserId == nil
            and not (blocked[uid] and blocked[uid] > os.clock()) then
            local rar = RarityNum(rec)
            local okName = filt == "" or string.find(string.lower(DisplayName(rec)), filt, 1, true)
                or string.find(string.lower(tostring(rec.AssetCategory or "")), filt, 1, true)
            local pos = EggPos(rec)
            if rar >= S.MinRarity and okName and pos then
                local dist = (pos - r.Position).Magnitude
                local score
                local p = S.Priority
                if p == "Gần nhất" then score = -dist
                elseif p == "Nặng nhất" then score = Scale(rec) * 1000 - dist * 0.1
                elseif p == "Money/Sec cao" then score = Income(rec) * 1000 - dist * 0.1
                else score = rar * 1e6 + Income(rec) * 100 - dist * 0.1 end
                if rec.BaseMutation and rec.BaseMutation ~= "" then score = score + 5e5 end
                if rec.State == "Dropped" then score = score + 1e8 end
                if not bs or score > bs then best, bs = rec, score end
            end
        end
    end
    return best
end

local function GoSafe()
    local sz = SafeZone()
    local r = HRP()
    if r and (r.Position - sz).Magnitude > 15 then GoFar(sz, S.Speed, function() return not S.Running end) end
end

local function StealOnce()
    if Night() then S.Status = "Đêm / tường đóng - chờ ở safe zone"; GoSafe(); task.wait(1); return "night" end
    local rec = Pick()
    if not rec then
        S.Status = "Không có egg phù hợp"
        if not InSafe() then GoSafe() end
        return "none"
    end
    local uid = rec.Uid
    local pos = EggPos(rec)
    S.Status = "Đi tới " .. DisplayName(rec) .. " (R" .. RarityNum(rec) .. ")"
    Unequip()
    local off = function() return not S.AutoSteal end
    GoFar(pos, S.Speed, off)
    if not S.AutoSteal then return false end

    -- spam grab
    local got, t0 = false, os.clock()
    while S.Running and S.AutoSteal and os.clock() - t0 < S.Timeout do
        local r = HRP()
        if r and (r.Position - pos).Magnitude > 6 then r.CFrame = CFrame.new(pos); r.AssemblyLinearVelocity = Vector3.zero end
        if Carry(rec) or IsCarrying(uid) then got = true; break end
        task.wait(0.05)
    end
    if not got then
        blocked[uid] = os.clock() + 6
        S.Status = "Grab thất bại: " .. DisplayName(rec)
        return false
    end

    -- chở về safe zone
    S.Status = "Đang chở " .. DisplayName(rec) .. " về safe zone"
    local before, safe, retries = claimedAt, SafeZone(), 0
    local lost = function() return not S.AutoSteal or not IsCarrying(uid) end
    while S.Running and S.AutoSteal do
        if claimedAt > before then break end
        if IsCarrying(uid) then
            local r = HRP()
            if r then
                local up = Vector3.new(r.Position.X, math.max(S.FlightY, r.Position.Y), r.Position.Z)
                if r.Position.Y < S.FlightY - 2 then Go(up, S.Speed, lost) end
                Go(Vector3.new(safe.X, S.FlightY, safe.Z), S.Speed, lost)
                if IsCarrying(uid) then Go(safe, S.Speed, lost) end
            end
            if IsCarrying(uid) and InSafe() then
                local w = os.clock()
                while os.clock() - w < 2.5 and claimedAt <= before and IsCarrying(uid) do task.wait(0.05) end
            end
        else
            if claimedAt > before then break end
            if InSafe() and not IsCarrying() then break end
            retries = retries + 1
            if retries > 5 then break end
            -- egg rơi: tìm lại
            fieldAt = 0
            local dropped
            for _, f in ipairs(Fields()) do if f.Uid == uid and (f.CarrierUserId == nil) then dropped = f end end
            if dropped then
                local dp = EggPos(dropped)
                if dp then GoFar(dp, S.Speed, function() return not S.AutoSteal end) end
                local t1 = os.clock()
                while os.clock() - t1 < 2 and not IsCarrying(uid) do Carry(dropped); task.wait(0.05) end
            else
                break
            end
        end
        task.wait()
    end
    local ok = claimedAt > before or (InSafe() and not IsCarrying())
    blocked[uid] = os.clock() + 30
    Unequip()
    if ok then
        S.Stolen = S.Stolen + 1
        S.Status = "Đã steal " .. DisplayName(rec)
        ownAt = 0
    else
        S.Status = "Chở egg thất bại"
        if not InSafe() then GoSafe() end
    end
    return ok
end

-- ═══ [7] AUTO PLACE ═══
local failCnt = {}
local function GetPlot()
    if not PlotState or not PlotState.ResolvePlot then return nil end
    local ok, p = pcall(PlotState.ResolvePlot, LP)
    if not ok or not p or not p.CenterPoint or not p.PetArea then return nil end
    local area = Find(p.PlotFolder, "ToUpdate", "PetArea") or Find(p.PlotFolder, "PetArea") or p.PetArea
    return { Center = p.CenterPoint, Area = area }
end

local function PlacedPositions(recs, center)
    local out = {}
    for _, rec in pairs(recs) do
        if rec.Placement ~= nil then
            local lc = rec.Placement.LocalCFrame or rec.Placement
            if typeof(lc) == "string" then
                local nums = {}
                for m in string.gmatch(lc, "[-0-9%.e]+") do nums[#nums + 1] = tonumber(m) end
                if #nums >= 3 then out[#out + 1] = center.CFrame:ToWorldSpace(CFrame.new(table.unpack(nums))).Position end
            elseif typeof(lc) == "CFrame" then
                out[#out + 1] = center.CFrame:ToWorldSpace(lc).Position
            end
        end
    end
    return out
end

local function NextSlot(plot, used)
    local area = plot.Area
    local hx, hz = area.Size.X * 0.5 - 3.5, area.Size.Z * 0.5 - 3.5
    local z = -hz
    while z <= hz do
        local x = -hx
        while x <= hx do
            local w = area.CFrame:PointToWorldSpace(Vector3.new(x, 0, z))
            local clash = false
            for _, u in ipairs(used) do
                if math.sqrt((w.X - u.X) ^ 2 + (w.Z - u.Z) ^ 2) < 4.8 then clash = true; break end
            end
            if not clash then return w, plot.Center.CFrame:ToObjectSpace(CFrame.new(w)) end
            x = x + 5.5
        end
        z = z + 5.5
    end
    return nil
end

local function Plant(uid, cf)
    if EggState and EggState.PlantEgg then
        local ok, r = pcall(EggState.PlantEgg, uid, cf)
        if ok and r == true then return true end
    end
    local net = Find(RS, "Packages", "Networking", "RF/EggWorld/AskPlaceEgg")
    if net then
        local ok, r = pcall(function() return net:InvokeServer({ Uid = uid, LocalCFrame = cf }) end)
        if ok and (r == true or (type(r) == "table" and (r.Outcome == true or r.Success == true))) then return true end
    end
    local r = Invoke("EggWorld", "AskPlaceEgg", { Uid = uid, LocalCFrame = cf })
    return r == true or (type(r) == "table" and r.Outcome == true)
end

local function Unplaced(recs)
    local list, placed = {}, 0
    for uid, rec in pairs(recs) do
        if rec.Placement == nil then
            if (failCnt[uid] or 0) < 3 then list[#list + 1] = uid end
        else placed = placed + 1 end
    end
    return list, placed
end

local function PlaceAll()
    local recs = Own(true)
    local list, placed = Unplaced(recs)
    if #list == 0 or placed >= S.MaxPlaced then return false end
    local plot = GetPlot()
    if not plot then S.Status = "Không tìm thấy plot của bạn"; return false end
    S.Status = "Đặt egg vào pen (" .. #list .. " egg)"
    GoFar(plot.Area.Position + Vector3.new(0, 2.8, 0), S.Speed, function() return not S.AutoPlace end)
    local used = PlacedPositions(recs, plot.Center)
    for _, uid in ipairs(list) do
        if not (S.Running and S.AutoPlace) or placed >= S.MaxPlaced then break end
        local world, localCF = NextSlot(plot, used)
        if not world then break end
        local r = HRP()
        if r and (r.Position - plot.Area.Position).Magnitude > 18 then
            GoFar(plot.Area.Position + Vector3.new(0, 2.8, 0), S.Speed)
        end
        pcall(function()
            if EggState and EggState.WearEggTool then EggState.WearEggTool(uid)
            else Invoke("EggWorld", "AskWearTool", uid) end
        end)
        task.wait(0.2)
        if Plant(uid, localCF) then
            placed = placed + 1; used[#used + 1] = world; failCnt[uid] = nil; S.Placed = S.Placed + 1
        else
            failCnt[uid] = (failCnt[uid] or 0) + 1
        end
        pcall(function()
            if EggState and EggState.DoffEggTool then EggState.DoffEggTool(uid)
            else Invoke("EggWorld", "AskDoffTool", uid) end
        end)
        task.wait(0.15)
    end
    Unequip()
    ownAt = 0
    return true
end

-- ═══ [8] ORCHESTRATOR (steal + place chạy tuần tự, không giẫm chân nhau) ═══
task.spawn(function()
    while S.Running do
        task.wait(0.15)
        if (S.AutoSteal or S.AutoPlace) and HRP() then
            local res
            if S.AutoSteal then
                local ok, r = pcall(StealOnce)
                if not ok then warn("[ChuppyEgg] Steal lỗi:", r); task.wait(1) end
                res = ok and r or false
            end
            if S.AutoPlace and (not S.AutoSteal or res == true or res == "none" or res == "night") then
                local do_ = S.PlaceRule ~= "Khi rảnh" or res == "none" or not S.AutoSteal
                if res == "night" then do_ = true end
                if do_ then local ok, e = pcall(PlaceAll); if not ok then warn("[ChuppyEgg] Place lỗi:", e) end end
            end
            if res == "none" or res == "night" then task.wait(0.5) end
        else
            if not (S.AutoSteal or S.AutoPlace) then S.Status = "Đang chờ" end
            task.wait(0.3)
        end
    end
end)

-- ═══ [9] AUTO HATCH / EQUIP / CLAIM / UPGRADE ═══
local hatched = {}
task.spawn(function()
    while S.Running do
        task.wait(2)
        if S.AutoHatch and EggState then pcall(function()
            local recs = Own(true)
            for uid, rec in pairs(recs) do
                if rec.Placement and not hatched[uid] then
                    local ready = EggState.IsReadyToHatch and EggState.IsReadyToHatch(uid)
                    if ready then
                        local okB = (EggState.BeginHatch and EggState.BeginHatch(uid)) or Invoke("EggWorld", "AskHatch", uid)
                        if okB == true then
                            local okF = (EggState.FinishHatch and EggState.FinishHatch(uid)) or Invoke("EggWorld", "AskFinishHatch", uid)
                            if okF == true then hatched[uid] = true; S.Hatched = S.Hatched + 1 end
                        end
                    end
                end
            end
            for uid in pairs(hatched) do if not recs[uid] then hatched[uid] = nil end end
        end) end
    end
end)

task.spawn(function()
    while S.Running do
        task.wait(6)
        if S.AutoEquip then pcall(function()
            local r = Invoke("Haul", "WearBest")
            if r == nil then
                local nw = Find(RS, "Network", "Backpack: EquipBest")
                if nw then nw:InvokeServer() end
            end
        end) end
    end
end)

task.spawn(function()
    while S.Running do
        task.wait(20)
        if S.AutoClaim and not moving then pcall(function()
            Invoke("AwayEarnings", "AskCollect")
            Invoke("Codex", "AskRedeemAll")
        end) end
    end
end)

local function GetSave()
    if not Save then return nil end
    local ok, r = pcall(function() return Save.Get and Save.Get() or (Save.Peek and Save.Peek()) end)
    return ok and type(r) == "table" and r or nil
end

task.spawn(function()
    while S.Running do
        task.wait(4)
        local sv = (S.UpBase or S.UpTread) and GetSave()
        if sv then
            if S.UpBase and Bases and Bases.BASES then pcall(function()
                local nx = Bases.BASES[(sv.BaseUpgradeLevel or 0) + 1]
                if nx and nx.Cost and (sv.Money or 0) >= nx.Cost then
                    local ev = RF("Homestead", "AskBaseTierRaise")
                    if ev then ev:FireServer() end
                end
            end) end
            if S.UpTread and Treadmills and Treadmills.GetByUpgradeLevel then pcall(function()
                local nx = Treadmills.GetByUpgradeLevel((sv.TreadmillUpgradeLevel or 0) + 1)
                if nx and (sv.Money or 0) >= (nx.Price or math.huge) then Invoke("Treadmill", "AskTierRaise", nx._id) end
            end) end
        end
    end
end)

-- ═══ [10] ESP + GUARD ═══
local espObjs, guardHL = {}, {}
local RCOL = { Color3.fromRGB(200, 200, 200), Color3.fromRGB(120, 220, 120), Color3.fromRGB(80, 160, 255),
    Color3.fromRGB(180, 100, 255), Color3.fromRGB(255, 190, 40), Color3.fromRGB(255, 80, 80), Color3.fromRGB(255, 60, 200) }
local function ClearEggESP() for _, o in pairs(espObjs) do pcall(function() o:Destroy() end) end; espObjs = {} end
local function ClearGuardESP() for _, o in pairs(guardHL) do pcall(function() o:Destroy() end) end; guardHL = {} end
local lastWarn = 0

task.spawn(function()
    while S.Running do
        task.wait(1)
        pcall(function()
            if S.ESPEggs or S.ESPRare then
                local seen = {}
                for _, rec in ipairs(Fields()) do
                    local uid = rec.Uid
                    local rar = RarityNum(rec)
                    local part = uid and Find(workspace, "AreaEggSlotsClient", tostring(uid), "Hitbox")
                    if part and (S.ESPEggs or rar >= 6) and rec.CarrierUserId == nil then
                        seen[uid] = true
                        local b = espObjs[uid]
                        if not b or not b.Parent then
                            b = Instance.new("BillboardGui")
                            b.Name = "ChuppyEggESP"; b.AlwaysOnTop = true; b.Size = UDim2.new(0, 130, 0, 28)
                            b.StudsOffset = Vector3.new(0, 3, 0); b.Adornee = part; b.Parent = part
                            local t = Instance.new("TextLabel")
                            t.Name = "T"; t.Size = UDim2.new(1, 0, 1, 0); t.BackgroundTransparency = 1
                            t.Font = Enum.Font.GothamBold; t.TextSize = 13; t.TextStrokeTransparency = 0.4
                            t.Parent = b
                            espObjs[uid] = b
                        end
                        local lbl = b:FindFirstChild("T")
                        if lbl then
                            lbl.Text = string.format("%s R%d", DisplayName(rec), rar)
                            lbl.TextColor3 = RCOL[math.clamp(rar, 1, #RCOL)]
                        end
                    end
                end
                for uid, b in pairs(espObjs) do if not seen[uid] then pcall(function() b:Destroy() end); espObjs[uid] = nil end end
            elseif next(espObjs) then ClearEggESP() end

            local ga = Find(workspace, "World", "Areas", "GuardAreas")
            if ga and (S.ESPGuards or S.GuardWarn) then
                for _, area in ipairs(ga:GetChildren()) do
                    local g = area:IsA("Model") and area:FindFirstChild("Guard")
                    if g and g:IsA("Model") then
                        local st = g:GetAttribute("GuardState") or "Sleeping"
                        local tg = tostring(g:GetAttribute("TargetPlayer") or "")
                        if S.ESPGuards then
                            local h = guardHL[area.Name]
                            if not h or not h.Parent then
                                h = Instance.new("Highlight"); h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                                h.FillTransparency = 0.7; h.Parent = g; guardHL[area.Name] = h
                            end
                            h.Adornee = g
                            local col = st == "Chasing" and Color3.fromRGB(255, 50, 50)
                                or ((st == "Waking" or st == "ReturningHome") and Color3.fromRGB(255, 200, 30) or Color3.fromRGB(50, 255, 80))
                            h.FillColor, h.OutlineColor = col, col
                        end
                        if tg == tostring(LP.UserId) then
                            if S.GuardWarn and os.clock() - lastWarn > 2 then lastWarn = os.clock(); N("Warning", "Guard", "Guard đang đuổi bạn! CHẠY!") end
                            if S.AutoDrop and IsCarrying() then DropEgg() end
                        end
                    end
                end
            end
            if not S.ESPGuards and next(guardHL) then ClearGuardESP() end
        end)
    end
end)

-- ═══ [11] MISC ═══
Track(UIS.JumpRequest:Connect(function()
    if S.InfJump then local h = Hum(); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end
end))
Track(LP.Idled:Connect(function()
    if S.AntiAFK then pcall(function() VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new()) end) end
end))
Track(RunService.Heartbeat:Connect(function()
    if S.SpeedHack then local h = Hum(); if h and h.WalkSpeed ~= S.WalkSpeed then h.WalkSpeed = S.WalkSpeed end end
end))

local lagBackup = {}
local function SetLag(on)
    if on then
        pcall(function() lagBackup.Shadows = Lighting.GlobalShadows; Lighting.GlobalShadows = false; Lighting.FogEnd = 9e9 end)
        for _, d in ipairs(workspace:GetDescendants()) do
            pcall(function()
                if d:IsA("BasePart") then d.Material = Enum.Material.SmoothPlastic; d.CastShadow = false
                elseif d:IsA("ParticleEmitter") or d:IsA("Trail") or d:IsA("Smoke") or d:IsA("Fire") then d.Enabled = false end
            end)
        end
    else
        pcall(function() Lighting.GlobalShadows = lagBackup.Shadows ~= false end)
    end
end

local function Rejoin() pcall(function() TeleportService:Teleport(game.PlaceId, LP) end) end
local function Hop()
    pcall(function()
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        local data = HttpService:JSONDecode(game:HttpGet(url))
        for _, sv in ipairs(data.data or {}) do
            if sv.playing and sv.maxPlayers and sv.playing < sv.maxPlayers - 1 and sv.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, sv.id, LP); return
            end
        end
        Rejoin()
    end)
end

-- ═══ [12] UI ═══
local Window = UI:CreateWindow({ Title = "CHUPPY HUB", SubTitle = "Steal An Egg", Width = 320, Height = 360 })
local function Sec(tab, name, col) return tab:CreateSection({ Name = name, Collapsed = col or false }) end

local TabFarm = Window:MakeTab({ Name = "Farm", Icon = "🥚" })
local F1 = Sec(TabFarm, "Auto Steal")
F1:AddToggle({ Name = "Auto Steal", Desc = "Tự bay tới egg, nhặt và chở về safe zone", Default = false, Flag = "AutoSteal" },
    function(v) S.AutoSteal = v; if not v then moving = false end; N(v and "Success" or "Warning", "Auto Steal", v and "BẬT" or "TẮT") end)
F1:AddDropdown({ Name = "Ưu tiên", Options = { "Hiếm nhất", "Gần nhất", "Nặng nhất", "Money/Sec cao" }, Default = "Hiếm nhất", Flag = "Priority" },
    function(v) S.Priority = v end)
F1:AddDropdown({ Name = "Độ hiếm tối thiểu", Options = { "1 - Common", "2 - Uncommon", "3 - Rare", "4 - Epic", "5 - Legendary", "6 - Mythic", "7 - Secret" }, Default = "1 - Common", Flag = "MinRarity" },
    function(v) S.MinRarity = tonumber(string.match(v, "^(%d+)")) or 1 end)
F1:AddInput({ Name = "Lọc tên egg", Placeholder = "để trống = tất cả", Default = "", Flag = "NameFilter" }, function(v) S.NameFilter = v or "" end)
F1:AddSlider({ Name = "Tốc độ bay (càng thấp càng an toàn)", Min = 100, Max = 400, Default = S.Speed, Suffix = " st/s", Flag = "Speed" }, function(v) S.Speed = v end)
F1:AddSlider({ Name = "Độ cao bay", Min = 60, Max = 120, Default = S.FlightY, Suffix = " st", Flag = "FlightY" }, function(v) S.FlightY = v end)
F1:AddSlider({ Name = "Timeout grab", Min = 2, Max = 8, Default = S.Timeout, Suffix = " s", Flag = "Timeout" }, function(v) S.Timeout = v end)

local F2 = Sec(TabFarm, "Auto Place Egg")
F2:AddToggle({ Name = "Auto Place Egg", Desc = "Đặt egg trong túi vào pen", Default = false, Flag = "AutoPlace" }, function(v) S.AutoPlace = v end)
F2:AddDropdown({ Name = "Khi nào đặt", Options = { "Sau mỗi lần steal", "Khi rảnh" }, Default = "Sau mỗi lần steal", Flag = "PlaceRule" }, function(v) S.PlaceRule = v end)
F2:AddSlider({ Name = "Số egg tối đa trong pen", Min = 5, Max = 60, Default = S.MaxPlaced, Flag = "MaxPlaced" }, function(v) S.MaxPlaced = v end)

local F3 = Sec(TabFarm, "Hatch & Pet")
F3:AddToggle({ Name = "Auto Hatch", Desc = "Tự ấp nở egg đã sẵn sàng", Default = false, Flag = "AutoHatch" }, function(v) S.AutoHatch = v end)
F3:AddToggle({ Name = "Auto Equip Best", Desc = "Tự mặc pet tốt nhất", Default = false, Flag = "AutoEquip" }, function(v) S.AutoEquip = v end)

local TabProg = Window:MakeTab({ Name = "Progress", Icon = "📈" })
local P1 = Sec(TabProg, "Tự động nâng cấp")
P1:AddToggle({ Name = "Auto Upgrade Base", Default = false, Flag = "UpBase" }, function(v) S.UpBase = v end)
P1:AddToggle({ Name = "Auto Upgrade Treadmill", Default = false, Flag = "UpTread" }, function(v) S.UpTread = v end)
P1:AddToggle({ Name = "Auto Claim", Desc = "Nhận tiền offline + Index", Default = false, Flag = "AutoClaim" }, function(v) S.AutoClaim = v end)
local P2 = Sec(TabProg, "Treadmill")
P2:AddButton({ Name = "Thoát khỏi Treadmill", Color = Theme.Warning }, function()
    pcall(function() Invoke("Treadmill", "AskDoff") end)
    pcall(function() local n = Find(RS, "Network", "Treadmills: RequestUnequip"); if n then n:InvokeServer() end end)
end)

local TabESP = Window:MakeTab({ Name = "ESP", Icon = "👁" })
local E1 = Sec(TabESP, "ESP")
E1:AddToggle({ Name = "ESP Eggs", Desc = "Hiện tên + độ hiếm mọi egg", Default = false, Flag = "ESPEggs" }, function(v) S.ESPEggs = v end)
E1:AddToggle({ Name = "ESP Egg hiếm (>= Mythic)", Default = false, Flag = "ESPRare" }, function(v) S.ESPRare = v end)
E1:AddToggle({ Name = "ESP Guards", Desc = "Xanh=ngủ, vàng=đang dậy, đỏ=đang đuổi", Default = false, Flag = "ESPGuards" }, function(v) S.ESPGuards = v end)
local E2 = Sec(TabESP, "An toàn")
E2:AddToggle({ Name = "Cảnh báo Guard đuổi", Default = false, Flag = "GuardWarn" }, function(v) S.GuardWarn = v end)
E2:AddToggle({ Name = "Tự thả egg khi bị đuổi", Default = false, Flag = "AutoDrop" }, function(v) S.AutoDrop = v end)
E2:AddToggle({ Name = "Anti Knockback / Ragdoll", Default = true, Flag = "AntiKB" }, function(v) S.AntiKB = v end)

local TabMisc = Window:MakeTab({ Name = "Misc", Icon = "🧰" })
local M1 = Sec(TabMisc, "Nhân vật")
M1:AddToggle({ Name = "No Clip", Default = false, Flag = "NoClip" }, function(v) S.NoClip = v end)
M1:AddToggle({ Name = "Infinite Jump", Default = false, Flag = "InfJump" }, function(v) S.InfJump = v end)
M1:AddToggle({ Name = "Speed Hack", Default = false, Flag = "SpeedHack" }, function(v) S.SpeedHack = v; if not v then local h = Hum(); if h then h.WalkSpeed = 16 end end end)
M1:AddSlider({ Name = "WalkSpeed", Min = 16, Max = 32, Default = 24, Flag = "WalkSpeed" }, function(v) S.WalkSpeed = v end)
M1:AddToggle({ Name = "Anti-AFK", Default = true, Flag = "AntiAFK" }, function(v) S.AntiAFK = v end)
local M2 = Sec(TabMisc, "Hiệu năng")
M2:AddToggle({ Name = "Reduce Lag", Default = false, Flag = "Lag" }, function(v) S.Lag = v; SetLag(v) end)
M2:AddToggle({ Name = "White Screen", Desc = "Tắt render 3D khi treo máy", Default = false, Flag = "White" },
    function(v) S.White = v; pcall(function() RunService:Set3dRenderingEnabled(not v) end) end)
local M3 = Sec(TabMisc, "Server")
M3:AddButton({ Name = "Rejoin", Color = Theme.Accent }, Rejoin)
M3:AddButton({ Name = "Hop Server", Color = Theme.Accent }, Hop)
M3:AddButton({ Name = "Unload Hub", Color = Theme.Danger }, function() if getgenv().ChuppyEggUnload then getgenv().ChuppyEggUnload() end end)

local TabInfo = Window:MakeTab({ Name = "Info", Icon = "ℹ" })
local I1 = Sec(TabInfo, "Trạng thái")
local lblStatus = I1:AddLabel({ Text = "Đang chờ", Color = Theme.Accent, Bold = true })
local lblStats = I1:AddLabel({ Text = "", Color = Theme.Text })
local lblMoney = I1:AddLabel({ Text = "", Color = Theme.Text })
local I2 = Sec(TabInfo, "Chuppy Hub")
I2:AddLabel({ Text = "Steal An Egg | No Key", Color = Theme.Success })
I2:AddLabel({ Text = "RightShift: Ẩn/Hiện menu", Color = Theme.Warning })

local function Fmt(sec) sec = math.floor(sec); return string.format("%02d:%02d:%02d", sec // 3600, (sec // 60) % 60, sec % 60) end
task.spawn(function()
    while S.Running do
        task.wait(0.5)
        pcall(function()
            lblStatus.SetText("▶ " .. tostring(S.Status))
            lblStats.SetText(string.format("🥚 Steal: %d | Đặt: %d | Nở: %d | %s", S.Stolen, S.Placed, S.Hatched, Fmt(os.clock() - S.StartTime)))
            local sv = GetSave()
            if sv then lblMoney.SetText("💰 Money: " .. tostring(math.floor(tonumber(sv.Money) or 0))) end
        end)
    end
end)

Window:SelectTab("Farm")

-- Ẩn/hiện menu
Track(UIS.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.RightShift then
        local g = getgenv().ChuppyScreenGui
        if g then g.Enabled = not g.Enabled end
    end
end))

-- Unload
getgenv().ChuppyEggUnload = function()
    S.Running = false
    moving = false
    for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
    ClearEggESP(); ClearGuardESP()
    pcall(function() RunService:Set3dRenderingEnabled(true) end)
    pcall(function() local g = getgenv().ChuppyScreenGui; if g then g:Destroy() end end)
    getgenv().ChuppyEgg = nil
    getgenv().ChuppyEggUnload = nil
end

task.delay(0.5, function() N("Success", "Chuppy Hub", "Steal An Egg đã load! RightShift để ẩn/hiện") end)
print("🥚 CHUPPY HUB — STEAL AN EGG LOADED")

end)()
