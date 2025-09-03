-- ModernNotifier.lua
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local module = {}
module.__index = module

-- 預設設定
local DEFAULT_DURATION = 4
local WIDTH, HEIGHT = 450, 100
local SPACING = 16
local MAX_QUEUE = 5

-- 狀態存儲
local queues = {}

-- 建立 ScreenGui 與 Container
local function createGui(parent)
    local gui = Instance.new("ScreenGui")
    gui.Name = "ModernNotifierGui"
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 9999
    gui.ResetOnSpawn = false
    gui.Parent = parent

    local container = Instance.new("Frame")
    container.Name = "Container"
    container.AnchorPoint = Vector2.new(0.5, 0.8)
    container.Position = UDim2.new(0.5, 0, 0.8, 0)
    container.Size = UDim2.new(0, WIDTH, 0, 0)
    container.BackgroundTransparency = 1
    container.Parent = gui

    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, SPACING)
    layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    layout.Parent = container

    return gui, container
end

-- 建立通知框 UI
local function createNotifUI(opts)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, WIDTH, 0, HEIGHT)
    frame.BackgroundColor3 = opts.BackgroundColor or Color3.fromRGB(30, 30, 30)
    frame.BorderSizePixel = 0
    frame.BackgroundTransparency = 0.2
    frame.ClipsDescendants = true

    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 14)
    Instance.new("UIStroke", frame).Thickness = 2
    frame.UIStroke.Color = opts.StrokeColor or Color3.fromRGB(50, 50, 50)
    frame.UIStroke.Transparency = 0.3

    local gradient = Instance.new("UIGradient", frame)
    gradient.Color = ColorSequence.new(opts.GradientStart or Color3.fromRGB(60, 60, 60), opts.GradientEnd or Color3.fromRGB(30, 30, 30))
    gradient.Rotation = 90

    if opts.Icon then
        local icon = Instance.new("ImageLabel", frame)
        icon.Size = UDim2.new(0, 36, 0, 36)
        icon.Position = UDim2.new(0, 12, 0.5, -18)
        icon.Image = opts.Icon
        icon.BackgroundTransparency = 1
    end

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, -60, 0, 24)
    title.Position = UDim2.new(0, opts.Icon and 60 or 14, 0, 12)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Text = opts.Title or "Title"
    title.TextXAlignment = Enum.TextXAlignment.Left

    local body = Instance.new("TextLabel", frame)
    body.Size = UDim2.new(1, -60, 0, 40)
    body.Position = UDim2.new(0, opts.Icon and 60 or 14, 0, 40)
    body.BackgroundTransparency = 1
    body.Font = Enum.Font.Gotham
    body.TextSize = 14
    body.TextColor3 = Color3.fromRGB(200, 200, 200)
    body.Text = opts.Message or ""
    body.TextXAlignment = Enum.TextXAlignment.Left
    body.TextYAlignment = Enum.TextYAlignment.Top
    body.TextWrapped = true

    -- 可關閉按鈕
    local closeBtn = Instance.new("ImageButton", frame)
    closeBtn.Size = UDim2.new(0, 24, 0, 24)
    closeBtn.Position = UDim2.new(1, -34, 0, 10)
    closeBtn.Image = "rbxassetid://7087858712" -- 假設為 "X" 圖標
    closeBtn.BackgroundTransparency = 1

    closeBtn.MouseButton1Click:Connect(function()
        if opts.OnClose then opts.OnClose() end
        -- 可加動畫再銷毀
        TweenService:Create(frame, TweenInfo.new(0.3), {BackgroundTransparency = 1, Size = UDim2.new(0, WIDTH, 0, 0)}):Play()
        task.delay(0.35, function() frame:Destroy() end)
    end)

    -- 時間條
    local bar = Instance.new("Frame", frame)
    bar.Size = UDim2.new(1, 0, 0, 4)
    bar.Position = UDim2.new(0, 0, 1, -4)
    bar.BackgroundColor3 = opts.BarColor or Color3.fromRGB(100, 200, 100)
    bar.BorderSizePixel = 0

    TweenService:Create(bar, TweenInfo.new(opts.Duration or DEFAULT_DURATION, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 0, 4)}):Play()

    return frame
end

-- 顯示通知
function module:Notify(opts)
    local player = Players.LocalPlayer
    if not player then return warn("僅能在 LocalScript 使用") end
    queues[player] = queues[player] or {Gui=nil, Container=nil, Items={}}
    local state = queues[player]

    if not state.Gui then
        local gui, container = createGui(Players.LocalPlayer:WaitForChild("PlayerGui"))
        state.Gui, state.Container = gui, container
    end

    local notif = createNotifUI(opts)
    notif.Parent = state.Container

    table.insert(state.Items, notif)
    if #state.Items > MAX_QUEUE then
        local old = table.remove(state.Items, 1)
        if old then old:Destroy() end
    end

    -- 顯示動畫
    notif.Size = UDim2.new(0, WIDTH, 0, 0)
    notif.BackgroundTransparency = 1
    TweenService:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, WIDTH, 0, HEIGHT)}):Play()
    TweenService:Create(notif, TweenInfo.new(0.2), {BackgroundTransparency = 0}):Play()

    -- 自動消失
    task.delay(opts.Duration or DEFAULT_DURATION, function()
        if notif and notif.Parent then
            TweenService:Create(notif, TweenInfo.new(0.3), {BackgroundTransparency = 1, Size = UDim2.new(0, WIDTH, 0, 0)}):Play()
            task.delay(0.35, function() if notif then notif:Destroy() end end)
        end
    end)
end

function module.Simple(msg, duration)
    module:Notify({Title="", Message=msg, Duration=duration})
end

return module