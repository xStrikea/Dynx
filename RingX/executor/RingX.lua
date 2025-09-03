local sourceUrl = "https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua"
local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet(sourceUrl))()
end)

if not success or not Rayfield then
    warn("Failed to load Rayfield from: " .. tostring(sourceUrl))
    return
end

local function EnableAntiKick()
    if getgenv().ED_AntiKickLoaded then return end
    getgenv().ED_AntiKickLoaded = true

    local cloneref = cloneref or function(...) return ... end
    local Players, LocalPlayer = cloneref(game:GetService("Players")), cloneref(game:GetService("Players").LocalPlayer)

    getgenv().ED_AntiKick = {
        Enabled = true,
        CheckCaller = true
    }

    getgenv().ED_AntiKick.OriginalNamecall = getrawmetatable(game).__namecall
    getgenv().ED_AntiKick.OriginalKick = LocalPlayer.Kick

    getgenv().ED_AntiKick.OldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(...)
        local self = ...
        local method = getnamecallmethod()
        if (getgenv().ED_AntiKick.CheckCaller and not checkcaller()) 
        and self == LocalPlayer and string.lower(method) == "kick" 
        and getgenv().ED_AntiKick.Enabled then
            return
        end
        return getgenv().ED_AntiKick.OldNamecall(...)
    end))

    getgenv().ED_AntiKick.OldKick = hookfunction(LocalPlayer.Kick, function(...)
        local self = ...
        if self == LocalPlayer and getgenv().ED_AntiKick.Enabled then
            return
        end
        return getgenv().ED_AntiKick.OldKick(...)
    end)
end

local function DisableAntiKick()
    if not getgenv().ED_AntiKickLoaded then return end

    local mt = getrawmetatable(game)
    setreadonly(mt, false)
    mt.__namecall = getgenv().ED_AntiKick.OriginalNamecall
    setreadonly(mt, true)

    local Players = game:GetService("Players")
    Players.LocalPlayer.Kick = getgenv().ED_AntiKick.OriginalKick

    getgenv().ED_AntiKick = nil
    getgenv().ED_AntiKickLoaded = false
end

local Window = Rayfield:CreateWindow({
    Name = "RingX Executor",
    LoadingTitle = "RingX Executor",
    LoadingSubtitle = "by xSpecter",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false
})

local loadedVersions = {}

local function createVersionTab(versionCode, description)
    local Tab = Window:CreateTab(versionCode, 4483362458)
    Tab:CreateParagraph({
        Title = "RingX "..versionCode,
        Content = description or "No description"
    })

    Tab:CreateButton({
        Name = "Execute "..versionCode,
        Callback = function()
            local url = string.format("https://raw.githubusercontent.com/xStrikea/Dynx/refs/heads/main/RingX/%s/RingX.lua", versionCode)
            local ok, err = pcall(function()
                loadstring(game:HttpGet(url, true))()
            end)
            if not ok then
                warn("Failed to execute "..versionCode..": "..tostring(err))
            end
        end
    })

    Tab:CreateToggle({
        Name = "Anti-Kick",
        CurrentValue = false,
        Callback = function(state)
            if state then
                EnableAntiKick()
            else
                DisableAntiKick()
            end
        end
    })
end

local HomeTab = Window:CreateTab("Home", 4483362458)
HomeTab:CreateLabel("Welcome to RingX Executor！")
HomeTab:CreateParagraph({
    Title = "Introduction",
    Content = "This script collects nearby or distant loose parts and forms a spinning ring. You can use it to attack players. It functions like Fling. Have fun."
})

spawn(function()
    local vListUrl = "https://raw.githubusercontent.com/xStrikea/Dynx/refs/heads/main/RingX/executor/v.txt"
    local successList, listData = pcall(function()
        return game:HttpGet(vListUrl, true)
    end)

    if not successList or not listData or #listData == 0 then
        warn("Failed to load version list.")
        return
    end

    for line in string.gmatch(listData, "[^\r\n]+") do
        local versionCode = line:gsub("%s+", "")
        if versionCode ~= "" then
            local scriptUrl = string.format("https://raw.githubusercontent.com/xStrikea/Dynx/refs/heads/main/RingX/%s/RingX.lua", versionCode)
            local infoUrl = string.format("https://raw.githubusercontent.com/xStrikea/Dynx/refs/heads/main/RingX/%s/info.txt", versionCode)

            local successScript, code = pcall(function()
                return game:HttpGet(scriptUrl, true)
            end)

            if successScript and code and #code > 10 then
                local successInfo, infoText = pcall(function()
                    return game:HttpGet(infoUrl, true)
                end)
                if not (successInfo and infoText and #infoText > 0) then
                    infoText = "No description"
                end

                loadedVersions[versionCode] = infoText
            end
        end
    end

    for v, desc in pairs(loadedVersions) do
        createVersionTab(v, desc)
    end
end)