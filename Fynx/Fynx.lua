-- Fynx.lua (Modern Flat Notifier with Rounded Progress Bar)
-- Load: local Notifier = loadstring(game:HttpGet("https://raw.githubusercontent.com/xStrikea/Dynx/refs/heads/main/Fynx/Fynx.lua"))()

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local module = {}
local WIDTH, HEIGHT = 440, 80
local SPACING = 12
local DEFAULT_DURATION = 4
local MAX_QUEUE = 5

local queues = {}

local THEMES = {
    Success = {Accent = Color3.fromRGB(80,200,120)},
    Warning = {Accent = Color3.fromRGB(255,180,0)},
    Error   = {Accent = Color3.fromRGB(255,70,70)},
    Info    = {Accent = Color3.fromRGB(80,180,255)}
}

-- 建立 ScreenGui 與容器
local function createGui(parent)
    local gui = Instance.new("ScreenGui")
    gui.Name = "FynxNotifier"
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 9999
    gui.ResetOnSpawn = false
    gui.Parent = parent

    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.new(1,0,1,0)
    container.AnchorPoint = Vector2.new(0.5,1)
    container.Position = UDim2.new(0.5,0,0.9,0)
    container.BackgroundTransparency = 1
    container.Parent = gui

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, SPACING)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    layout.Parent = container

    return gui, container
end

-- 建立通知框
local function makeNotification(title, msg, theme)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, WIDTH, 0, HEIGHT)
    frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
    frame.BackgroundTransparency = 0.15
    frame.BorderSizePixel = 0
    frame.ClipsDescendants = true

    local frameCorner = Instance.new("UICorner", frame)
    frameCorner.CornerRadius = UDim.new(0,12)

    -- 彩色進度條（貼合圓角）
    local barContainer = Instance.new("Frame")
    barContainer.Size = UDim2.new(1,0,0,6)
    barContainer.Position = UDim2.new(0,0,1,-6)
    barContainer.BackgroundTransparency = 1
    barContainer.Parent = frame

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1,0,1,0)
    bar.Position = UDim2.new(0,0,0,0)
    bar.BackgroundColor3 = theme.Accent
    bar.BorderSizePixel = 0
    bar.ClipsDescendants = true
    bar.Parent = barContainer

    local barCorner = Instance.new("UICorner", bar)
    barCorner.CornerRadius = UDim.new(0,3)

    -- 標題
    local titleLbl = Instance.new("TextLabel")
    titleLbl.BackgroundTransparency = 1
    titleLbl.Position = UDim2.new(0,14,0,10)
    titleLbl.Size = UDim2.new(1,-28,0,22)
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 17
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.TextColor3 = Color3.fromRGB(240,240,240)
    titleLbl.Text = title
    titleLbl.Parent = frame

    -- 內容
    local msgLbl = Instance.new("TextLabel")
    msgLbl.BackgroundTransparency = 1
    msgLbl.Position = UDim2.new(0,14,0,36)
    msgLbl.Size = UDim2.new(1,-28,1,-36)
    msgLbl.Font = Enum.Font.Gotham
    msgLbl.TextSize = 14
    msgLbl.TextXAlignment = Enum.TextXAlignment.Left
    msgLbl.TextYAlignment = Enum.TextYAlignment.Top
    msgLbl.TextColor3 = Color3.fromRGB(200,200,200)
    msgLbl.TextWrapped = true
    msgLbl.Text = msg
    msgLbl.Parent = frame

    return frame, bar
end

-- 動畫：顯示
local function animateIn(frame)
    frame.Size = UDim2.new(0, WIDTH, 0, 0)
    frame.BackgroundTransparency = 1
    TweenService:Create(frame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Size = UDim2.new(0, WIDTH, 0, HEIGHT)}):Play()
    TweenService:Create(frame, TweenInfo.new(0.25), {BackgroundTransparency = 0.15}):Play()
end

-- 動畫：消失
local function animateOut(frame)
    TweenService:Create(frame, TweenInfo.new(0.25), {BackgroundTransparency = 1}):Play()
    TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In),
        {Size = UDim2.new(0, WIDTH, 0, 0)}):Play()
    task.delay(0.3, function() if frame then frame:Destroy() end end)
end

-- 顯示通知
function module:Notify(opts)
    local player = Players.LocalPlayer
    if not player then return end

    queues[player] = queues[player] or {Gui=nil, Container=nil, Items={}}
    local state = queues[player]

    if not state.Gui then
        local gui, container = createGui(player:WaitForChild("PlayerGui"))
        state.Gui = gui
        state.Container = container
    end

    local theme = (opts.Type and THEMES[opts.Type]) or THEMES.Info
    local notif, bar = makeNotification(opts.Title or "訊息", opts.Message or "", theme)
    notif.Parent = state.Container

    table.insert(state.Items, notif)
    animateIn(notif)

    -- 時間條動畫（寬度縮短）
    TweenService:Create(bar, TweenInfo.new(opts.Duration or DEFAULT_DURATION, Enum.EasingStyle.Linear), {Size=UDim2.new(0,0,1,0)}):Play()

    -- 自動消失
    task.delay(opts.Duration or DEFAULT_DURATION, function()
        if notif and notif.Parent then
            animateOut(notif)
        end
    end)
end

function module.Simple(msg, duration)
    module:Notify({Title="提示", Message=msg, Duration=duration})
end

return module