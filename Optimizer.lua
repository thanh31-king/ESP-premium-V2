-- language: Lua, file: Optimizer.lua
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

-- Đợi cho đến khi file Main.lua tạo Menu xong
repeat task.wait(0.1) until _G.VantaWindow ~= nil

local OptState = { Master = false }

local function ApplyMaster(on)
    pcall(function()
        if on then
            Lighting.GlobalShadows = false
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("BasePart") then
                    obj.CastShadow = false
                    if obj.Material == Enum.Material.Neon or obj.Material == Enum.Material.Glass or obj.Material == Enum.Material.ForceField then
                        obj.Material = Enum.Material.SmoothPlastic
                    end
                elseif obj:IsA("ParticleEmitter") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Trail") then
                    obj.Enabled = false
                end
            end
            for _, obj in ipairs(Lighting:GetChildren()) do
                if obj:IsA("PostEffect") then obj.Enabled = false end
            end
            local terrain = Workspace:FindFirstChildOfClass("Terrain")
            if terrain then
                terrain.Decoration = false; terrain.WaterWaveSize = 0; terrain.WaterWaveSpeed = 0
            end
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        else
            Lighting.GlobalShadows = true
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level21
        end
    end)
end

Workspace.DescendantAdded:Connect(function(obj)
    if not OptState.Master then return end
    task.wait(0.1)
    pcall(function()
        if obj:IsA("ParticleEmitter") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Trail") then obj.Enabled = false
        elseif obj:IsA("BasePart") then
            obj.CastShadow = false
            if obj.Material == Enum.Material.Neon or obj.Material == Enum.Material.Glass then obj.Material = Enum.Material.SmoothPlastic end
        end
    end)
end)

local OptTab = _G.VantaWindow:CreateTab("Performance", 4483362458)
OptTab:CreateSection("Tối Ưu Hóa")
OptTab:CreateToggle({
    Name = "⚡ Bật Fix Lag",
    CurrentValue = false,
    Callback = function(v) 
        OptState.Master = v
        ApplyMaster(v) 
    end,
})
