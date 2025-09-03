-- Fynx.lua (Modern Notifier)
-- Load: local Notifier = loadstring(game:HttpGet("https://raw.githubusercontent.com/xStrikea/Dynx/refs/heads/main/Fynx/Fynx.lua"))()

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local module = {}
local WIDTH, HEIGHT = 460, 90
local DEFAULT_DURATION = 3.5
local SPACING = 12

local queues = {}

-- 建立 GUI 容器
local function createGui(parent)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FynxNotifier"
    screenGui.IgnoreGuiInset = true
    screenGui.DisplayOrder = 9999
    screenGui.ResetOnSpawn = false
    screenGui.Parent = parent

    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.new(1, 0, 1, 0)
    container.AnchorPoint = Vector2.new(0.5, 1)
    container.Position = UDim2.new(0.5, 0, 0.92, 0)
    container.BackgroundTransparency = 1
    container.Parent = screenGui

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, SPACING)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    layout.Parent = container

    return screenGui, container
end

-- 建立通知框
local function makeNotification(title, msg, accent)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, WIDTH, 0, HEIGHT)
    frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
    frame.BackgroundTransparency = 0.15
    frame.BorderSizePixel = 0

    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, 16)

    -- 陰影
    local shadow = Instance.new("ImageLabel")
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
    shadow.AnchorPoint = Vector2.new(0.5,0.5)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316045217"
    shadow.ImageTransparency = 0.5
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10,10,118,118)
    shadow.ZIndex = 0
    shadow.Parent = frame

    -- 彩色強調條
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0,6,1,0)
    bar.Position = UDim2.new(0,0,0,0)
    bar.BackgroundColor3 = accent or Color3.fromRGB(255,75,75)
    bar.BorderSizePixel = 0
    bar.Parent = frame
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0,6)

    local titleLbl = Instance.new("TextLabel")
    titleLbl.BackgroundTransparency = 1
    titleLbl.Position = UDim2.new(0,14,0,10)
    titleLbl.Size = UDim2.new(1,-28,0,22)
    titleLbl.Font = Enum.Font.GothamSemibold
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.TextColor3 = Color3.fromRGB(240,240,240)
    titleLbl.TextSize = 18
    titleLbl.Text = title
    titleLbl.Parent = frame

    local msgLbl = Instance.new("TextLabel")
    msgLbl.BackgroundTransparency = 1
    msgLbl.Position = UDim2.new(0,14,0,36)
    msgLbl.Size = UDim2.new(1,-28,1,-36)
    msgLbl.Font = Enum.Font.Gotham
    msgLbl.TextXAlignment = Enum.TextXAlignment.Left
    msgLbl.TextYAlignment = Enum.TextYAlignment.Top
    msgLbl.TextColor3 = Color3.fromRGB(200,200,200)
    msgLbl.TextWrapped = true
    msgLbl.TextSize = 15
    msgLbl.Text = msg
    msgLbl.Parent = frame

    return frame
end

-- 動畫：顯示
local function animateIn(frame)
    frame.Size = UDim2.new(0, WIDTH, 0, 0)
    frame.BackgroundTransparency = 1
    frame.Visible = true
    frame.ClipsDescendants = true

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

-- 主函式
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

    local notif = makeNotification(
        tostring(opts.Title or "訊息"),
        tostring(opts.Message or ""),
        opts.AccentColor
    )
    notif.Parent = state.Container

    table.insert(state.Items, notif)
    animateIn(notif)

    task.delay(tonumber(opts.Duration) or DEFAULT_DURATION, function()
        if notif and notif.Parent then
            animateOut(notif)
        end
    end)
end

function module.Simple(msg, duration)
    module:Notify({Title="提示", Message=msg, Duration=duration})
end

return module