-- language: Lua, file: Loader.lua
local BASE_URL = "https://raw.githubusercontent.com/thanh31-king/ESP-premium-V2/refs/heads/main/"

_G.VantaAuth = false
_G.VantaWindow = nil
_G.VantaMenuGui = nil

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
        warn("[VANTA] Không tải được " .. fileName)
    end
end

-- 1. Chạy UI Nhập Key
RunFile("Key.lua")

-- 2. Chờ xác thực
task.spawn(function()
    while not _G.VantaAuth do
        task.wait(0.2)
    end
    task.wait(0.2)
    
    -- 3. Chạy lần lượt các file
    RunFile("Main.lua")
    task.wait(1) -- Chờ 1 giây để Main tạo xong Menu
    RunFile("Optimizer.lua")
    RunFile("Icon.lua")
end)
