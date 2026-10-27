-- language: Lua, file: Loader.lua
local BASE_URL = "https://raw.githubusercontent.com/thanh31-king/ESP-premium-V2/main/"

_G.VantaAuth = false

local function RunFile(fileName)
    local url = BASE_URL .. fileName
    local success, response = pcall(function()
        return game:HttpGet(url, true)
    end)
    
    if success and not response:find("404: Not Found") then
        local run_success, err = pcall(function()
            loadstring(response)()
        end)
        if not run_success then
            warn("[VANTA] Lỗi chạy " .. fileName .. ": " .. tostring(err))
        end
    else
        warn("[VANTA] Không tải được " .. fileName .. ". Link có thể sai!")
    end
end

-- 1. Chạy UI Nhập Key
RunFile("Key.lua")

-- 2. Chờ xác thực
task.spawn(function()
    while not _G.VantaAuth do
        task.wait(0.5)
    end
    task.wait(0.2)
    -- 3. Nếu Key đúng, tải ESP và Icon
    RunFile("Main.lua")
    RunFile("Icon.lua")
end)
