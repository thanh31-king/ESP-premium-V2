-- language: Lua, file: Main.lua
-- *ESP Hoàn chỉnh + Nút Nổi Bật/Tắt*

local Rayfield = nil
pcall(function()
    Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)
if not Rayfield then return warn("[VANTA] Không thể tải Rayfield UI.") end
getgenv().SecureMode = true

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local Camera = Workspace.CurrentCamera
local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")

-- ============================================================
-- CẤU HÌNH MẶC ĐỊNH
-- ============================================================
local Settings = {
    Enabled = true,
    Box = true,
    Name = true,
    Distance = true,
    Health = true,
    Tracer = true,
    Skeleton = false,
    HeadDot = false,
    Chams = false,
    TeamCheck = false,
    MaxDistance = 9999999,
    TracerStart = "Top",
    
    BoxColor = Color3.fromRGB(255, 0, 0),
    NameColor = Color3.fromRGB(255, 255, 255),
    DistanceColor = Color3.fromRGB(255, 100, 100),
    HealthColor = Color3.fromRGB(0, 255, 100),
    TracerColor = Color3.fromRGB(255, 255, 255),
    SkeletonColor = Color3.fromRGB(255, 255, 255),
    ChamsColor = Color3.fromRGB(255, 0, 0),
}

local ESP_Cache = {}

-- ============================================================
-- KHỞI TẠO DRAWING
-- ============================================================
local function CreateESP(plr)
    if ESP_Cache[plr] then return ESP_Cache[plr] end
    
    local data = {
        Box = Drawing.new("Square"),
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        Health = Drawing.new("Text"),
        Tracer = Drawing.new("Line"),
        HeadDot = Drawing.new("Circle"),
        Chams = nil,
        Skeleton = {
            Head = Drawing.new("Line"), Torso = Drawing.new("Line"),
            LeftArm = Drawing.new("Line"), RightArm = Drawing.new("Line"),
            LeftLeg = Drawing.new("Line"), RightLeg = Drawing.new("Line")
        }
    }
    
    data.Box.Thickness = 1; data.Box.Filled = false; data.Box.Transparency = 1
    data.Name.Size = 14; data.Name.Center = true; data.Name.Outline = true
    data.Distance.Size = 12; data.Distance.Center = true; data.Distance.Outline = true
    data.Health.Size = 12; data.Health.Center = true; data.Health.Outline = true
    data.Tracer.Thickness = 1.5; data.Tracer.Transparency = 1
    data.HeadDot.Radius = 5; data.HeadDot.Filled = true; data.HeadDot.Thickness = 1
    
    for _, line in pairs(data.Skeleton) do line.Thickness = 1.5 end
    
    ESP_Cache[plr] = data
    return data
end

-- ============================================================
-- VÒNG LẶP CẬP NHẬT ESP
-- ============================================================
RunService.RenderStepped:Connect(function()
    pcall(function()
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr == LP then continue end
            
            local data = ESP_Cache[plr]
            local char = plr.Character
            
            if not char or not char:FindFirstChild("Humanoid") or char.Humanoid.Health <= 0 or not Settings.Enabled then
                if data then
                    data.Box.Visible = false; data.Name.Visible = false; data.Distance.Visible = false
                    data.Health.Visible = false; data.Tracer.Visible = false; data.HeadDot.Visible = false
                    for _, line in pairs(data.Skeleton) do line.Visible = false end
                    if data.Chams then data.Chams:Destroy(); data.Chams = nil end
                end
                continue
            end
            
            if not data then data = CreateESP(plr) end
            
            local hum = char.Humanoid
            local head = char:FindFirstChild("Head")
            local root = char:FindFirstChild("HumanoidRootPart")
            if not head or not root then continue end
            
            local isEnemy = not Settings.TeamCheck or (plr.Team ~= LP.Team)
            local dist = (root.Position - Camera.CFrame.Position).Magnitude
            
            if not isEnemy or dist > Settings.MaxDistance then
                data.Box.Visible = false; data.Name.Visible = false; data.Distance.Visible = false
                data.Health.Visible = false; data.Tracer.Visible = false; data.HeadDot.Visible = false
                for _, line in pairs(data.Skeleton) do line.Visible = false end
                if data.Chams then data.Chams:Destroy(); data.Chams = nil end
                continue
            end
            
            local headPos, onScreen = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
            local legPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
            
            if onScreen and headPos.Z > 0 then
                local height = math.abs(headPos.Y - legPos.Y)
                local width = height * 0.6
                local headScreen = Vector2.new(headPos.X, headPos.Y)
                
                data.Box.Size = Vector2.new(width, height)
                data.Box.Position = Vector2.new(headPos.X - width / 2, headPos.Y)
                data.Box.Color = Settings.BoxColor
                data.Box.Visible = Settings.Box
                
                data.Name.Text = plr.Name
                data.Name.Position = Vector2.new(headPos.X, headPos.Y - 18)
                data.Name.Color = Settings.NameColor
                data.Name.Visible = Settings.Name
                
                data.Distance.Text = "[" .. math.floor(dist) .. "m]"
                data.Distance.Position = Vector2.new(headPos.X, headPos.Y + height + 2)
                data.Distance.Color = Settings.DistanceColor
                data.Distance.Visible = Settings.Distance
                
                data.Health.Text = math.floor(hum.Health) .. " HP"
                data.Health.Position = Vector2.new(headPos.X, headPos.Y + height + 16)
                data.Health.Color = Settings.HealthColor
                data.Health.Visible = Settings.Health
                
                local startX = Camera.ViewportSize.X / 2
                local startY = 0
                if Settings.TracerStart == "Bottom" then startY = Camera.ViewportSize.Y
                elseif Settings.TracerStart == "Center" then startY = Camera.ViewportSize.Y / 2 end
                
                data.Tracer.From = Vector2.new(startX, startY)
                data.Tracer.To = headScreen
                data.Tracer.Color = Settings.TracerColor
                data.Tracer.Visible = Settings.Tracer
                
                data.HeadDot.Position = headScreen
                data.HeadDot.Color = Settings.SkeletonColor
                data.HeadDot.Visible = Settings.HeadDot
                
                if Settings.Chams then
                    if not data.Chams then
                        local hl = Instance.new("Highlight")
                        hl.FillColor = Settings.ChamsColor; hl.OutlineColor = Color3.new(0,0,0)
                        hl.FillTransparency = 0.5; hl.Parent = char
                        data.Chams = hl
                    else
                        data.Chams.FillColor = Settings.ChamsColor
                    end
                elseif data.Chams then 
                    data.Chams:Destroy(); data.Chams = nil 
                end

                if Settings.Skeleton then
                    for _, line in pairs(data.Skeleton) do 
                        line.Visible = true; line.Color = Settings.SkeletonColor 
                    end
                    
                    local function getPos(partName)
                        local p = char:FindFirstChild(partName)
                        if p then
                            local sp, onS = Camera:WorldToViewportPoint(p.Position)
                            if onS then return Vector2.new(sp.X, sp.Y) end
                        end
                        return nil
                    end
                    
                    local hP = getPos("Head")
                    local uT = getPos("UpperTorso") or getPos("Torso")
                    local lT = getPos("LowerTorso") or getPos("Torso")
                    local la = getPos("Left Arm") or getPos("LeftUpperArm") or getPos("LeftLowerArm")
                    local ra = getPos("Right Arm") or getPos("RightUpperArm") or getPos("RightLowerArm")
                    local ll = getPos("Left Leg") or getPos("LeftUpperLeg") or getPos("LeftLowerLeg")
                    local rl = getPos("Right Leg") or getPos("RightUpperLeg") or getPos("RightLowerLeg")

                    if hP and uT then data.Skeleton.Head.From = hP; data.Skeleton.Head.To = uT else data.Skeleton.Head.Visible = false end
                    if uT and lT then data.Skeleton.Torso.From = uT; data.Skeleton.Torso.To = lT else data.Skeleton.Torso.Visible = false end
                    if uT and la then data.Skeleton.LeftArm.From = uT; data.Skeleton.LeftArm.To = la else data.Skeleton.LeftArm.Visible = false end
                    if uT and ra then data.Skeleton.RightArm.From = uT; data.Skeleton.RightArm.To = ra else data.Skeleton.RightArm.Visible = false end
                    if lT and ll then data.Skeleton.LeftLeg.From = lT; data.Skeleton.LeftLeg.To = ll else data.Skeleton.LeftLeg.Visible = false end
                    if lT and rl then data.Skeleton.RightLeg.From = lT; data.Skeleton.RightLeg.To = rl else data.Skeleton.RightLeg.Visible = false end
                else
                    for _, line in pairs(data.Skeleton) do line.Visible = false end
                end
            else
                data.Box.Visible = false; data.Name.Visible = false; data.Distance.Visible = false
                data.Health.Visible = false; data.Tracer.Visible = false; data.HeadDot.Visible = false
                for _, line in pairs(data.Skeleton) do line.Visible = false end
            end
        end
    end)
end)

Players.PlayerRemoving:Connect(function(plr)
    if ESP_Cache[plr] then
        for _, d in pairs(ESP_Cache[plr]) do
            if typeof(d) == "Instance" and d.Remove then d:Remove() end
        end
        ESP_Cache[plr] = nil
    end
end)

-- ============================================================
-- GIAO DIỆN RAYFIELD
-- ============================================================
local Window = Rayfield:CreateWindow({
    Name = "VANTA | Universal ESP",
    LoadingTitle = "VANTA ESP",
    LoadingSubtitle = "Premium Edition",
    Theme = "Dark",
    ToggleUIKeybind = "K",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false,
})

local VisualTab = Window:CreateTab("Visuals", 4483362458)
VisualTab:CreateSection("Thành Phần Cơ Bản")
VisualTab:CreateToggle({ Name = "Bật ESP (Master)", CurrentValue = true, Flag = "ESPEnabled", Callback = function(v) Settings.Enabled = v end })
VisualTab:CreateToggle({ Name = "Box (Khung)", CurrentValue = true, Flag = "BoxESP", Callback = function(v) Settings.Box = v end })
VisualTab:CreateToggle({ Name = "Name (Tên)", CurrentValue = true, Flag = "NameESP", Callback = function(v) Settings.Name = v end })
VisualTab:CreateToggle({ Name = "Distance (Khoảng cách)", CurrentValue = true, Flag = "DistESP", Callback = function(v) Settings.Distance = v end })
VisualTab:CreateToggle({ Name = "Health (Máu)", CurrentValue = true, Flag = "HealthESP", Callback = function(v) Settings.Health = v end })

VisualTab:CreateSection("Nâng Cao")
VisualTab:CreateToggle({ Name = "Skeleton (Xương)", CurrentValue = false, Flag = "SkeletonESP", Callback = function(v) Settings.Skeleton = v end })
VisualTab:CreateToggle({ Name = "Head Dot (Chấm đầu)", CurrentValue = false, Flag = "HeadDotESP", Callback = function(v) Settings.HeadDot = v end })
VisualTab:CreateToggle({ Name = "Chams (Highlight)", CurrentValue = false, Flag = "ChamsESP", Callback = function(v) Settings.Chams = v end })

local EffectTab = Window:CreateTab("Effects", 4483362458)
EffectTab:CreateSection("Tracer (Tia laze)")
EffectTab:CreateToggle({ Name = "Bật Tracer", CurrentValue = true, Flag = "TracerESP", Callback = function(v) Settings.Tracer = v end })
EffectTab:CreateDropdown({
    Name = "Vị trí bắt đầu",
    Options = {"Top", "Bottom", "Center"},
    CurrentOption = {"Top"},
    Flag = "TracerStart",
    Callback = function(option) Settings.TracerStart = option[1] end,
})

local SettingsTab = Window:CreateTab("Settings", 4483362458)
SettingsTab:CreateSection("Cấu Hình")
SettingsTab:CreateToggle({ Name = "Team Check", CurrentValue = false, Flag = "TeamCheck", Callback = function(v) Settings.TeamCheck = v end })
SettingsTab:CreateSlider({ Name = "Max Distance", Range = {100, 9999999}, Increment = 1000, Suffix = "m", CurrentValue = 9999999, Flag = "MaxDistance", Callback = function(v) Settings.MaxDistance = v end })

SettingsTab:CreateSection("Màu Sắc")
SettingsTab:CreateColorPicker({ Name = "Màu Box", Color = Settings.BoxColor, Flag = "BoxColor", Callback = function(v) Settings.BoxColor = v end })
SettingsTab:CreateColorPicker({ Name = "Màu Name", Color = Settings.NameColor, Flag = "NameColor", Callback = function(v) Settings.NameColor = v end })
SettingsTab:CreateColorPicker({ Name = "Màu Tracer", Color = Settings.TracerColor, Flag = "TracerColor", Callback = function(v) Settings.TracerColor = v end })
SettingsTab:CreateColorPicker({ Name = "Màu Skeleton", Color = Settings.SkeletonColor, Flag = "SkeletonColor", Callback = function(v) Settings.SkeletonColor = v end })

-- ============================================================
-- NÚT NỔI (FLOATING BUTTON)
-- ============================================================
local floatGui = Instance.new("ScreenGui")
floatGui.Name = "VANTA_FLOAT_ICON"
floatGui.ResetOnSpawn = false
floatGui.IgnoreGuiInset = true
floatGui.DisplayOrder = 999
floatGui.Parent = PG

local floatBtn = Instance.new("TextButton")
floatBtn.Size = UDim2.new(0, 50, 0, 50)
floatBtn.Position = UDim2.new(0, 16, 0.5, -25)
floatBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
floatBtn.Text = "👁️"
floatBtn.TextSize = 24
floatBtn.Font = Enum.Font.GothamBold
floatBtn.AutoButtonColor = false
floatBtn.Parent = floatGui
Instance.new("UICorner", floatBtn).CornerRadius = UDim.new(1, 0)
local fStroke = Instance.new("UIStroke", floatBtn)
fStroke.Color = Color3.fromRGB(0, 255, 255)
fStroke.Thickness = 1.5

local dragging, dragInput, dragStart, startPos
floatBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = floatBtn.Position
    end
end)
floatBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        floatBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

floatBtn.MouseButton1Click:Connect(function()
    pcall(function()
        if Rayfield.GUI then Rayfield.GUI.Enabled = not Rayfield.GUI.Enabled end
    end)
end)

pcall(function()
    Rayfield:Notify({ Title = "VANTA Premium", Content = "Đã tải! Bấm icon 👁️ để bật/tắt Menu.", Duration = 5 })
end)
