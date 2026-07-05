local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local UI = {}
UI.Elements = {}
UI.Config = {
    mode = "full",
    Decompile = true,
    DecompileTimeout = -1,
    scriptcache = true,
    SafeMode = false,
    FilePath = "MyBackup",
    NilInstances = true
}

-- Cleanup old instances
if CoreGui:FindFirstChild("MxDcmpPremiumUI") then
    CoreGui.MxDcmpPremiumUI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MxDcmpPremiumUI"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- ==========================================
-- UTILITY & ANIMATION FUNCTIONS
-- ==========================================
local function CreateTween(instance, info, goals)
    local tween = TweenService:Create(instance, info, goals)
    tween:Play()
    return tween
end

local function CreateRipple(button)
    local mouseLocation = UserInputService:GetMouseLocation()
    local ripple = Instance.new("Frame")
    ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ripple.BackgroundTransparency = 0.8
    ripple.BorderSizePixel = 0
    ripple.AnchorPoint = Vector2.new(0.5, 0.5)
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = ripple
    
    ripple.Parent = button
    ripple.Position = UDim2.new(0.5, 0, 0.5, 0)
    ripple.Size = UDim2.new(0, 0, 0, 0)
    
    CreateTween(ripple, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = UDim2.new(2, 0, 2, 0),
        BackgroundTransparency = 1
    })
    
    task.delay(0.4, function() ripple:Destroy() end)
end

-- ==========================================
-- MAIN UI CONSTRUCTION
-- ==========================================
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 550, 0, 400)
MainFrame.Position = UDim2.new(0.5, -275, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(50, 50, 55)
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame

-- Topbar (Enclave Lock Style)
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 50)
TopBar.BackgroundTransparency = 1
TopBar.Parent = MainFrame

local TitlePill = Instance.new("Frame")
TitlePill.Size = UDim2.new(0, 220, 0, 32)
TitlePill.Position = UDim2.new(0, 15, 0, 9)
TitlePill.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
TitlePill.Parent = TopBar
Instance.new("UICorner", TitlePill).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", TitlePill).Color = Color3.fromRGB(60, 60, 65)

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, 0, 1, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "Welcome to Enclave Lock"
TitleText.TextColor3 = Color3.fromRGB(240, 240, 240)
TitleText.Font = Enum.Font.Bodoni
TitleText.TextSize = 16
TitleText.Parent = TitlePill

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 50, 0, 32)
CloseBtn.Position = UDim2.new(1, -65, 0, 9)
CloseBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.Parent = TopBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", CloseBtn).Color = Color3.fromRGB(60, 60, 65)

CloseBtn.MouseEnter:Connect(function() CreateTween(CloseBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 20, 24)}) end)
CloseBtn.MouseLeave:Connect(function() CreateTween(CloseBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(20, 20, 24)}) end)
CloseBtn.MouseButton1Click:Connect(function()
    CreateRipple(CloseBtn)
    local outTween = CreateTween(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0,0,0,0)})
    outTween.Completed:Wait()
    ScreenGui:Destroy()
end)

local Line = Instance.new("Frame")
Line.Size = UDim2.new(1, -30, 0, 1)
Line.Position = UDim2.new(0, 15, 0, 50)
Line.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
Line.BorderSizePixel = 0
Line.Parent = MainFrame

-- Settings Container
local SettingsContainer = Instance.new("ScrollingFrame")
SettingsContainer.Size = UDim2.new(1, -30, 1, -110)
SettingsContainer.Position = UDim2.new(0, 15, 0, 60)
SettingsContainer.BackgroundTransparency = 1
SettingsContainer.ScrollBarThickness = 3
SettingsContainer.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 85)
SettingsContainer.Parent = MainFrame

local SettingsLayout = Instance.new("UIListLayout")
SettingsLayout.Padding = UDim.new(0, 12)
SettingsLayout.SortOrder = Enum.SortOrder.LayoutOrder
SettingsLayout.Parent = SettingsContainer

-- ==========================================
-- CUSTOM SETTING CONTROLS
-- ==========================================

-- Animated Toggle Switch
local function CreateToggle(name, defaultVal, layoutOrder)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 40)
    frame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    frame.LayoutOrder = layoutOrder
    frame.Parent = SettingsContainer
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Position = UDim2.new(0, 15, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local toggleBg = Instance.new("TextButton")
    toggleBg.Size = UDim2.new(0, 50, 0, 24)
    toggleBg.Position = UDim2.new(1, -65, 0.5, -12)
    toggleBg.BackgroundColor3 = defaultVal and Color3.fromRGB(70, 200, 100) or Color3.fromRGB(50, 50, 55)
    toggleBg.Text = ""
    toggleBg.Parent = frame
    Instance.new("UICorner", toggleBg).CornerRadius = UDim.new(1, 0)

    local toggleKnob = Instance.new("Frame")
    toggleKnob.Size = UDim2.new(0, 20, 0, 20)
    toggleKnob.Position = defaultVal and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
    toggleKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggleKnob.Parent = toggleBg
    Instance.new("UICorner", toggleKnob).CornerRadius = UDim.new(1, 0)

    toggleBg.MouseButton1Click:Connect(function()
        UI.Config[name] = not UI.Config[name]
        local isEnabled = UI.Config[name]
        
        CreateTween(toggleBg, TweenInfo.new(0.3), {
            BackgroundColor3 = isEnabled and Color3.fromRGB(70, 200, 100) or Color3.fromRGB(50, 50, 55)
        })
        CreateTween(toggleKnob, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = isEnabled and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
        })
    end)
end

-- Custom Animated Input Box
local function CreateInput(name, defaultVal, isNumber, layoutOrder)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 40)
    frame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    frame.LayoutOrder = layoutOrder
    frame.Parent = SettingsContainer
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.Position = UDim2.new(0, 15, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local input = Instance.new("TextBox")
    input.Size = UDim2.new(0.4, -15, 0, 28)
    input.Position = UDim2.new(0.6, 0, 0.5, -14)
    input.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
    input.TextColor3 = Color3.fromRGB(255, 255, 255)
    input.Text = tostring(defaultVal)
    input.Font = Enum.Font.Gotham
    input.TextSize = 13
    input.Parent = frame
    Instance.new("UICorner", input).CornerRadius = UDim.new(0, 6)
    local stroke = Instance.new("UIStroke", input)
    stroke.Color = Color3.fromRGB(40, 40, 45)

    input.Focused:Connect(function() CreateTween(stroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(100, 150, 255)}) end)
    input.FocusLost:Connect(function()
        CreateTween(stroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(40, 40, 45)})
        if isNumber then
            UI.Config[name] = tonumber(input.Text) or defaultVal
        else
            UI.Config[name] = input.Text
        end
    end)
end

-- Generate Settings
CreateInput("mode", "full", false, 1) -- Standard input for mode
CreateToggle("Decompile", true, 2)
CreateInput("DecompileTimeout", -1, true, 3)
CreateToggle("scriptcache", true, 4)
CreateToggle("SafeMode", false, 5)
CreateInput("FilePath", "MyBackup", false, 6)
CreateToggle("NilInstances", true, 7)

-- ==========================================
-- EXECUTION & CONSOLE AREA
-- ==========================================
local BottomArea = Instance.new("Frame")
BottomArea.Size = UDim2.new(1, 0, 0, 50)
BottomArea.Position = UDim2.new(0, 0, 1, -50)
BottomArea.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
BottomArea.BorderSizePixel = 0
BottomArea.Parent = MainFrame

local ExecBtn = Instance.new("TextButton")
ExecBtn.Size = UDim2.new(1, -30, 0, 36)
ExecBtn.Position = UDim2.new(0, 15, 0, 7)
ExecBtn.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
ExecBtn.Text = "Initialize SaveInstance"
ExecBtn.TextColor3 = Color3.fromRGB(10, 10, 10)
ExecBtn.Font = Enum.Font.GothamBold
ExecBtn.TextSize = 14
ExecBtn.AutoButtonColor = false
ExecBtn.Parent = BottomArea
Instance.new("UICorner", ExecBtn).CornerRadius = UDim.new(0, 8)
UI.Elements.ExecuteBtn = ExecBtn

ExecBtn.MouseEnter:Connect(function() CreateTween(ExecBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(200, 200, 200)}) end)
ExecBtn.MouseLeave:Connect(function() CreateTween(ExecBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(240, 240, 240)}) end)

-- ==========================================
-- CINEMATIC LOADING SCREEN
-- ==========================================
local LoadingGui = Instance.new("ScreenGui")
LoadingGui.Name = "MxDcmpLoading"
LoadingGui.Parent = CoreGui

local LoadFrame = Instance.new("Frame")
LoadFrame.Size = UDim2.new(0, 0, 0, 2)
LoadFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
LoadFrame.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
LoadFrame.AnchorPoint = Vector2.new(0.5, 0.5)
LoadFrame.BorderSizePixel = 0
LoadFrame.Parent = LoadingGui

local LoadText = Instance.new("TextLabel")
LoadText.Size = UDim2.new(0, 200, 0, 30)
LoadText.Position = UDim2.new(0.5, -100, 0.5, -30)
LoadText.BackgroundTransparency = 1
LoadText.Text = "Authenticating Framework..."
LoadText.TextColor3 = Color3.fromRGB(255, 255, 255)
LoadText.Font = Enum.Font.Bodoni
LoadText.TextSize = 18
LoadText.TextTransparency = 1
LoadText.Parent = LoadingGui

task.spawn(function()
    -- Phase 1: Line expanding
    local t1 = CreateTween(LoadFrame, TweenInfo.new(0.6, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, 300, 0, 2)})
    t1.Completed:Wait()
    
    -- Phase 2: Text Fading in
    CreateTween(LoadText, TweenInfo.new(0.5), {TextTransparency = 0})
    task.wait(1.2)
    LoadText.Text = "Linking Engine Hooks..."
    task.wait(0.8)
    
    -- Phase 3: Box expanding
    CreateTween(LoadText, TweenInfo.new(0.3), {TextTransparency = 1})
    local t3 = CreateTween(LoadFrame, TweenInfo.new(0.7, Enum.EasingStyle.Expo, Enum.EasingDirection.Out), {Size = UDim2.new(0, 550, 0, 400), BackgroundTransparency = 1})
    t3.Completed:Wait()
    
    LoadingGui:Destroy()
    
    -- Phase 4: Main UI Pops in
    MainFrame.Visible = true
    MainFrame.Size = UDim2.new(0, 500, 0, 350)
    CreateTween(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 550, 0, 400)
    })
end)

-- ==========================================
-- SMOOTH LERP DRAGGING (Physics Based)
-- ==========================================
local dragging, dragInput, dragStart, startPos
local dragSpeed = 0.15

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        local targetPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        CreateTween(MainFrame, TweenInfo.new(dragSpeed, Enum.EasingStyle.Linear), {Position = targetPos})
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

function UI.GetConfigs()
    return UI.Config
end

return UI
