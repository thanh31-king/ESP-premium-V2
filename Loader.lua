-- language: Lua, file: Loader.lua
-- *Loader luôn yêu cầu nhập Key mỗi lần Execute*

local REPO_URL = "https://raw.githubusercontent.com/thanh31-king/ESP-premium-V2/refs/heads/main/Main.lua"
local VALID_KEY = "PREMIUM_ESP"

local function LoadMainScript()
    local success, response = pcall(function()
        return game:HttpGet(REPO_URL, true)
    end)
    if success and not response:find("404: Not Found") then
        local load_success, err = pcall(function()
            loadstring(response)()
        end)
        if not load_success then
            warn("[VANTA] Lỗi khi chạy Main Script: " .. tostring(err))
        end
    else
        warn("[VANTA] Không thể tải file Main từ GitHub. Hãy kiểm tra lại link!")
    end
end

-- LUÔN HIỂN THỊ BẢNG NHẬP KEY
local PG = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
local old = PG:FindFirstChild("VANTA_LOADER_UI")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "VANTA_LOADER_UI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999
gui.Parent = PG

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 280, 0, 180)
main.Position = UDim2.new(0.5, -140, 0.5, -90)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
main.Active = true
main.Draggable = true
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", main).Color = Color3.fromRGB(0, 255, 255)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Text = "VANTA KEY SYSTEM"
title.TextColor3 = Color3.fromRGB(0, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.Parent = main

local input = Instance.new("TextBox")
input.Size = UDim2.new(1, -30, 0, 40)
input.Position = UDim2.new(0, 15, 0, 50)
input.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
input.PlaceholderText = "Nhập key..."
input.Text = ""
input.TextColor3 = Color3.fromRGB(255, 255, 255)
input.Font = Enum.Font.Gotham
input.TextSize = 14
input.ClearTextOnFocus = false
input.Parent = main
Instance.new("UICorner", input).CornerRadius = UDim.new(0, 6)

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(1, -30, 0, 35)
btn.Position = UDim2.new(0, 15, 0, 100)
btn.BackgroundColor3 = Color3.fromRGB(0, 150, 150)
btn.Text = "XÁC NHẬN"
btn.TextColor3 = Color3.new(1,1,1)
btn.Font = Enum.Font.GothamBold
btn.Parent = main
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, 0, 0, 20)
status.Position = UDim2.new(0, 0, 0, 145)
status.BackgroundTransparency = 1
status.Text = ""
status.TextColor3 = Color3.fromRGB(255, 50, 50)
status.Font = Enum.Font.GothamBold
status.TextSize = 12
status.Parent = main

local function CheckKey()
    local clean = string.upper(string.gsub(input.Text, "%s+", ""))
    if clean == VALID_KEY then
        status.TextColor3 = Color3.fromRGB(0, 255, 100)
        status.Text = "Thành công! Đang tải Script..."
        btn.Text = "ĐANG TẢI..."
        
        task.wait(0.8)
        gui:Destroy()
        LoadMainScript()
    else
        status.TextColor3 = Color3.fromRGB(255, 50, 50)
        status.Text = "Key sai hoặc không đúng định dạng!"
        input.Text = ""
        input:CaptureFocus()
    end
end

btn.MouseButton1Click:Connect(CheckKey)
input.FocusLost:Connect(function(enter) if enter then CheckKey() end end)
