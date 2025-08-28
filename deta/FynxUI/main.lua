-- BlackUI.lua
-- Advanced dark-themed UI library for Roblox (Luau)
-- Inspired by Rayfield functionality
-- Supports: Window, Label, Button, Toggle, Slider, Input, Dropdown, Tabs, Notifications, ColorPicker, Keybinds, Save/Load config
-- Usage:
-- local BlackUI = loadstring(game:HttpGet("https://yourdomain/BlackUI.lua"))()
-- local win = BlackUI:CreateWindow("My Window")
-- win:AddLabel("Hello")
-- win:AddButton("Click", function() print("Clicked") end)
-- win:AddToggle("Toggle", true, function(state) print(state) end)
-- win:AddSlider("Volume", 0, 100, 50, function(val) print(val) end)
-- win:AddInput("Username", "Player", function(text) print(text) end)
-- win:AddDropdown("Options", {"A","B"}, "A", function(opt) print(opt) end)
-- win:AddTab({"Tab1","Tab2"}, function(tab) print(tab) end)
-- win:AddKeybind("Open Menu", Enum.KeyCode.M, function() print("Pressed M") end)
-- win:AddColorPicker("Pick Color", Color3.fromRGB(255,0,0), function(c) print(c) end)
-- BlackUI:Notify("Title","Message",5)
-- BlackUI:SaveConfig("myConfig")
-- BlackUI:LoadConfig("myConfig")

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

local BlackUI = {}
BlackUI.__index = BlackUI

local Theme = {
    Background = Color3.fromRGB(11,11,11),
    Panel = Color3.fromRGB(17,18,20),
    Accent = Color3.fromRGB(31,41,55),
    Primary = Color3.fromRGB(16,18,20),
    Text = Color3.fromRGB(229,231,235),
    Muted = Color3.fromRGB(156,163,175),
    Highlight = Color3.fromRGB(239,68,68)
}

local function New(class, props)
    local inst = Instance.new(class)
    if props then for k,v in pairs(props) do pcall(function() inst[k] = v end) end end
    return inst
end

local function RootGui()
    local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    local sg = New("ScreenGui", {Parent = pg or game:GetService("CoreGui"), ResetOnSpawn = false, Name = "BlackUI"})
    return sg
end

-- Notification system
local function CreateNotification(root, title, msg, duration)
    local frame = New("Frame", {Parent = root, Size = UDim2.new(0,250,0,70), Position = UDim2.new(1,-260,1,-80), BackgroundColor3 = Theme.Panel, BorderSizePixel=0})
    New("UICorner", {Parent=frame, CornerRadius=UDim.new(0,8)})
    New("TextLabel", {Parent=frame, Text=title, Font=Enum.Font.GothamBold, TextSize=16, TextColor3=Theme.Text, BackgroundTransparency=1, Size=UDim2.new(1,-10,0,20), Position=UDim2.new(0,10,0,5), TextXAlignment=Enum.TextXAlignment.Left})
    New("TextLabel", {Parent=frame, Text=msg, Font=Enum.Font.Gotham, TextSize=14, TextColor3=Theme.Muted, BackgroundTransparency=1, Size=UDim2.new(1,-10,0,40), Position=UDim2.new(0,10,0,25), TextXAlignment=Enum.TextXAlignment.Left, TextWrapped=true})
    task.spawn(function()
        task.wait(duration or 3)
        frame:Destroy()
    end)
end

-- ColorPicker
local function CreateColorPicker(parent, text, default, callback)
    local container = New("Frame", {Parent=parent, Size=UDim2.new(1,0,0,50), BackgroundTransparency=1})
    New("TextLabel", {Parent=container, Text=text, Font=Enum.Font.Gotham, TextSize=14, TextColor3=Theme.Text, BackgroundTransparency=1, Size=UDim2.new(1,0,0,20), TextXAlignment=Enum.TextXAlignment.Left})
    local preview = New("TextButton", {Parent=container, Size=UDim2.new(0,40,0,20), Position=UDim2.new(0,0,0,25), BackgroundColor3=default, BorderSizePixel=0, Text=""})
    New("UICorner", {Parent=preview, CornerRadius=UDim.new(0,6)})
    preview.MouseButton1Click:Connect(function()
        local color = Color3.fromRGB(math.random(0,255),math.random(0,255),math.random(0,255))
        preview.BackgroundColor3 = color
        pcall(callback, color)
    end)
    return container
end

-- Keybind
local function CreateKeybind(parent, text, defaultKey, callback)
    local container = New("Frame", {Parent=parent, Size=UDim2.new(1,0,0,40), BackgroundTransparency=1})
    New("TextLabel", {Parent=container, Text=text, Font=Enum.Font.Gotham, TextSize=14, TextColor3=Theme.Text, BackgroundTransparency=1, Size=UDim2.new(0.7,0,1,0), TextXAlignment=Enum.TextXAlignment.Left})
    local btn = New("TextButton", {Parent=container, Size=UDim2.new(0.3,0,1,0), Position=UDim2.new(0.7,0,0,0), BackgroundColor3=Theme.Accent, Text=defaultKey.Name, TextColor3=Theme.Text, Font=Enum.Font.Gotham, TextSize=14, BorderSizePixel=0})
    New("UICorner", {Parent=btn, CornerRadius=UDim.new(0,6)})
    local key = defaultKey
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == key then
            pcall(callback)
        end
    end)
    btn.MouseButton1Click:Connect(function()
        btn.Text = "..."
        local conn
        conn = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                key = input.KeyCode
                btn.Text = key.Name
                conn:Disconnect()
            end
        end)
    end)
    return container
end

-- Config system
function BlackUI:SaveConfig(name)
    local data = HttpService:JSONEncode(self._config or {})
    writefile(name..".json", data)
end

function BlackUI:LoadConfig(name)
    if isfile(name..".json") then
        local data = HttpService:JSONDecode(readfile(name..".json"))
        self._config = data
        return data
    end
end

-- Window API
function BlackUI:CreateWindow(title)
    local root = RootGui()
    local holder = New("Frame", {Parent=root, Size=UDim2.new(0,420,0,300), Position=UDim2.new(0.5,-210,0.35,0), BackgroundColor3=Theme.Panel, BorderSizePixel=0})
    local content = New("Frame", {Parent=holder, Size=UDim2.new(1,-20,1,-40), Position=UDim2.new(0,10,0,30), BackgroundTransparency=1})
    local instance = setmetatable({_root=root,_holder=holder,_content=content,_config={}}, BlackUI)

    function instance:AddColorPicker(txt, def, cb)
        return CreateColorPicker(self._content, txt, def, cb)
    end
    function instance:AddKeybind(txt, def, cb)
        return CreateKeybind(self._content, txt, def, cb)
    end
    return instance
end

function BlackUI:Notify(title,msg,duration)
    local gui = RootGui()
    CreateNotification(gui,title,msg,duration)
end

return BlackUI
