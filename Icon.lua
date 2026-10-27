-- language: Lua, file: Icon.lua
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LP = Players.LocalPlayer
local PG = LP:WaitForChild("PlayerGui")

local old = PG:FindFirstChild("VANTA_ICON_UI")
if old then old:Destroy() end

local floatGui = Instance.new("ScreenGui")
floatGui.Name = "VANTA_ICON_UI"
floatGui.ResetOnSpawn = false
floatGui.IgnoreGuiInset = true
floatGui.DisplayOrder = 2147483647
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

local dragging = false
local dragInput, dragStart, startPos
local isClick = false

floatBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        isClick = true
        dragStart = input.Position
        startPos = floatBtn.Position
    end
end)

floatBtn.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
        if isClick then
            pcall(function()
                if _G.Rayfield and _G.Rayfield.GUI then
                    _G.Rayfield.GUI.Enabled = not _G.Rayfield.GUI.Enabled
                else
                    local rayGui = PG:FindFirstChild("Rayfield")
                    if rayGui then rayGui.Enabled = not rayGui.Enabled end
                end
            end)
        end
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        if delta.Magnitude > 5 then
            isClick = false
        end
        floatBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
