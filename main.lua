-- 簡易腳本
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- 初始化
local function getCharacter()
    local char = player.Character or player.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")
    local humanoid = char:WaitForChild("Humanoid")
    return char, root, humanoid
end

local character, rootPart, humanoid = getCharacter()

-- 控制變數
local flyEnabled = false
local hoverEnabled = false
local speed = 6
local interval = 0.05
local bodyVel = nil

-- GUI
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "掛貓簡易腳本"
screenGui.ResetOnSpawn = false

-- 主框架
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 160)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Position = UDim2.new(0.5, 0, 0.5, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BackgroundTransparency = 0.15
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

-- 標題列
local titleBar = Instance.new("Frame", frame)
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
titleBar.BorderSizePixel = 0
titleBar.Active = true
titleBar.Draggable = true

local title = Instance.new("TextLabel", titleBar)
title.Size = UDim2.new(1, -60, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.Text = "簡易腳本 v1.0.3"
title.TextSize = 16
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextXAlignment = Enum.TextXAlignment.Left

-- 最小化按鈕
local minimizeBtn = Instance.new("TextButton", titleBar)
minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
minimizeBtn.Position = UDim2.new(1, -60, 0, 0)
minimizeBtn.BackgroundTransparency = 1
minimizeBtn.Text = "─"
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 18
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

-- 關閉按鈕
local closeBtn = Instance.new("TextButton", titleBar)
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -30, 0, 0)
closeBtn.BackgroundTransparency = 1
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18
closeBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
closeBtn.ZIndex = 13

-- 功能容器
local content = Instance.new("Frame", frame)
content.Size = UDim2.new(1, 0, 1, -30)
content.Position = UDim2.new(0, 0, 0, 30)
content.BackgroundTransparency = 1

-- 建立功能行
local function createToggle(parent, name, callback, order)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -20, 0, 40)
    row.Position = UDim2.new(0, 10, 0, 10 + (order-1)*50)
    row.BackgroundTransparency = 1
    row.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.Font = Enum.Font.GothamBold
    label.TextSize = 18
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row

    local toggle = Instance.new("TextButton")
    toggle.Size = UDim2.new(0, 40, 0, 25)
    toggle.Position = UDim2.new(0.75, 0, 0.2, 0)
    toggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50) -- 預設紅
    toggle.Text = ""
    toggle.Parent = row
    Instance.new("UICorner", toggle).CornerRadius = UDim.new(1, 0)

    local state = false
    toggle.MouseButton1Click:Connect(function()
        state = not state
        if state then
            toggle.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        else
            toggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        end
        callback(state)
    end)
end

-- 瞬移飛行
local function flyLoop()
    while flyEnabled do
        if rootPart and humanoid and humanoid.MoveDirection.Magnitude > 0 and not hoverEnabled then
            local dir = camera.CFrame.LookVector
            rootPart.CFrame = rootPart.CFrame + dir.Unit * speed
            rootPart.Velocity = Vector3.new(0,0,0)
        end
        task.wait(interval)
    end
end

-- 朝視角瞬移
createToggle(content, "朝視角瞬移", function(state)
    flyEnabled = state
    if flyEnabled then
        flyLoop()
    end
end, 1)

-- 空中懸停
createToggle(content, "空中懸停", function(state)
    hoverEnabled = state
    if hoverEnabled then
        bodyVel = Instance.new("BodyVelocity")
        bodyVel.Velocity = Vector3.new(0, 0, 0)
        bodyVel.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        bodyVel.Parent = rootPart
    else
        if bodyVel then bodyVel:Destroy() bodyVel = nil end
    end
end, 2)

-- 🔹 最小化時
local miniFrame = Instance.new("TextButton")
miniFrame.Size = UDim2.new(0, 80, 0, 80)
miniFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
miniFrame.Text = "掛貓製作"
miniFrame.TextColor3 = Color3.fromRGB(255, 150, 0)
miniFrame.TextSize = 23
miniFrame.Font = Enum.Font.GothamBold
miniFrame.Visible = false
miniFrame.Active = true
miniFrame.Draggable = true
miniFrame.Parent = screenGui

minimizeBtn.MouseButton1Click:Connect(function()
    frame.Visible = false
    miniFrame.Visible = true
end)

miniFrame.MouseButton1Click:Connect(function()
    frame.Visible = true
    miniFrame.Visible = false
end)

-- 🔹 關閉確認框
local overlay = Instance.new("Frame", screenGui)
overlay.Size = UDim2.new(1,0,1,0)
overlay.BackgroundColor3 = Color3.fromRGB(0,0,0)
overlay.BackgroundTransparency = 0.5
overlay.Visible = false
overlay.Active = true  -- 讓遮罩可以阻擋點擊
overlay.ZIndex = 10    -- 遮罩

local confirmFrame = Instance.new("Frame", screenGui)
confirmFrame.Size = UDim2.new(0, 200, 0, 120)
confirmFrame.Position = UDim2.new(0.5, -100, 0.5, -60)
confirmFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
confirmFrame.Visible = false
Instance.new("UICorner", confirmFrame).CornerRadius = UDim.new(0, 10)
confirmFrame.ZIndex = 11   -- ✅ 確認框在遮罩之上

local confirmLabel = Instance.new("TextLabel", confirmFrame)
confirmLabel.Size = UDim2.new(1, 0, 0.6, 0)
confirmLabel.Text = "你確定要關閉腳本嗎？"
confirmLabel.TextSize = 20
confirmLabel.Font = Enum.Font.GothamBold
confirmLabel.TextColor3 = Color3.fromRGB(255,255,255)
confirmLabel.BackgroundTransparency = 1
confirmLabel.Zindex = 12 --讓你確定要關閉腳本嗎？顯示在遮罩之上

local yesBtn = Instance.new("TextButton", confirmFrame)
yesBtn.Size = UDim2.new(0.5, -5, 0.3, 0)
yesBtn.Position = UDim2.new(0, 0, 0.7, 0)
yesBtn.Text = "是"
yesBtn.Font = Enum.Font.GothamBold
yesBtn.TextSize = 18
yesBtn.TextColor3 = Color3.fromRGB(0,0,0)
yesBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
yesBtn.ZIndex = 12  --讓按鈕顯示在遮罩之上

local noBtn = Instance.new("TextButton", confirmFrame)
noBtn.Size = UDim2.new(0.5, -5, 0.3, 0)
noBtn.Position = UDim2.new(0.5, 5, 0.7, 0)
noBtn.Text = "否"
noBtn.Font = Enum.Font.GothamBold
noBtn.TextSize = 18
noBtn.TextColor3 = Color3.fromRGB(0,0,0)
noBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
noBtn.ZIndex = 12   -- 讓按鈕顯示在遮罩之上

closeBtn.MouseButton1Click:Connect(function()
    confirmFrame.Visible = true
    overlay.Visible = true


end)

yesBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

noBtn.MouseButton1Click:Connect(function()
    confirmFrame.Visible = false
    overlay.Visible = false
end)

-- 重生處理
player.CharacterAdded:Connect(function()
    task.wait(1)
    character, rootPart, humanoid = getCharacter()
end)
