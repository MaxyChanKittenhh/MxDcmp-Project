local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local UI = {}
UI.Elements = {}
UI.ConfigPath = "MxDcmp_Config.json"

-- Default Configuration
UI.Config = {
    mode = "full",
    Decompile = true,
    DecompileTimeout = -1,
    scriptcache = true,
    SafeMode = false,
    FilePath = "MyBackup",
    NilInstances = true
}

-- Safe Executor File System Wrappers
local function SaveConfig()
    if writefile then
        local success, err = pcall(function()
            writefile(UI.ConfigPath, HttpService:JSONEncode(UI.Config))
        end)
        return success
    end
    return false
end

local function LoadConfig()
    if isfile and readfile and isfile(UI.ConfigPath) then
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile(UI.ConfigPath))
        end)
        if success and type(data) == "table" then
            for k, v in pairs(data) do
                if UI.Config[k] ~= nil then
                    UI.Config[k] = v
                end
            end
        end
    end
end

-- Load saved configs before building the UI
LoadConfig()

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
    local ripple = Instance.new("Frame")
    ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ripple.BackgroundTransparency = 0.8
    ripple.BorderSizePixel = 0
    ripple.AnchorPoint = Vector2.new(0.5, 0.5)
    Instance.new("UICorner", ripple).CornerRadius = UDim.new(1, 0)
    
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
-- TOAST NOTIFICATION SYSTEM
-- ==========================================
local NotifContainer = Instance.new("Frame")
NotifContainer.Size = UDim2.new(0, 250, 1, -20)
NotifContainer.Position = UDim2.new(1, -270, 0, 10)
NotifContainer.BackgroundTransparency = 1
NotifContainer.Parent = ScreenGui

local NotifLayout = Instance.new("UIListLayout")
NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotifLayout.Padding = UDim.new(0, 10)
NotifLayout.Parent = NotifContainer

function UI.Notify(title, text, duration)
    duration = duration or 3
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(1, 40, 0, 60) -- Starts offscreen slightly
    notif.BackgroundTransparency = 1
    notif.Parent = NotifContainer
    
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
    bg.Parent = notif
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", bg).Color = Color3.fromRGB(70, 150, 255)
    
    local titleLbl = Instance.new("TextLabel", bg)
    titleLbl.Size = UDim2.new(1, -20, 0, 25)
    titleLbl.Position = UDim2.new(0, 10, 0, 5)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title
    titleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 14
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    
    local textLbl = Instance.new("TextLabel", bg)
    textLbl.Size = UDim2.new(1, -20, 0, 20)
    textLbl.Position = UDim2.new(0, 10, 0, 30)
    textLbl.BackgroundTransparency = 1
    textLbl.Text = text
    textLbl.TextColor3 = Color3.fromRGB(180, 180, 180)
    textLbl.Font = Enum.Font.Gotham
    textLbl.TextSize = 12
    textLbl.TextXAlignment = Enum.TextXAlignment.Left
    
    -- Slide in
    CreateTween(notif, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 60)})
    
    task.delay(duration, function()
        local out = CreateTween(notif, TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.In), {Size = UDim2.new(1, 40, 0, 60), BackgroundTransparency = 1})
        CreateTween(bg, TweenInfo.new(0.3), {BackgroundTransparency = 1})
        CreateTween(titleLbl, TweenInfo.new(0.3), {TextTransparency = 1})
        CreateTween(textLbl, TweenInfo.new(0.3), {TextTransparency = 1})
        out.Completed:Wait()
        notif:Destroy()
    end)
end

-- ==========================================
-- MAIN UI CONSTRUCTION (700x500)
-- ==========================================
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 700, 0, 500)
MainFrame.Position = UDim2.new(0.5, -350, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(50, 50, 55)
MainStroke.Thickness = 1.5

-- Topbar
local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 50)
TopBar.BackgroundTransparency = 1

local TitlePill = Instance.new("Frame", TopBar)
TitlePill.Size = UDim2.new(0, 220, 0, 32)
TitlePill.Position = UDim2.new(0, 15, 0, 9)
TitlePill.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
Instance.new("UICorner", TitlePill).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", TitlePill).Color = Color3.fromRGB(60, 60, 65)

local TitleText = Instance.new("TextLabel", TitlePill)
TitleText.Size = UDim2.new(1, 0, 1, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "Enclave Lock | RightShift to Toggle"
TitleText.TextColor3 = Color3.fromRGB(240, 240, 240)
TitleText.Font = Enum.Font.Bodoni
TitleText.TextSize = 14

local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.Size = UDim2.new(0, 50, 0, 32)
CloseBtn.Position = UDim2.new(1, -65, 0, 9)
CloseBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", CloseBtn).Color = Color3.fromRGB(60, 60, 65)

CloseBtn.MouseButton1Click:Connect(function()
    CreateRipple(CloseBtn)
    local outTween = CreateTween(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0,0,0,0)})
    outTween.Completed:Wait()
    ScreenGui:Destroy()
end)

local Line = Instance.new("Frame", MainFrame)
Line.Size = UDim2.new(1, -30, 0, 1)
Line.Position = UDim2.new(0, 15, 0, 50)
Line.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
Line.BorderSizePixel = 0

-- Settings Container
local SettingsContainer = Instance.new("ScrollingFrame", MainFrame)
SettingsContainer.Size = UDim2.new(1, -30, 1, -130)
SettingsContainer.Position = UDim2.new(0, 15, 0, 65)
SettingsContainer.BackgroundTransparency = 1
SettingsContainer.ScrollBarThickness = 3
SettingsContainer.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 85)

local SettingsLayout = Instance.new("UIListLayout", SettingsContainer)
SettingsLayout.Padding = UDim.new(0, 12)
SettingsLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- ==========================================
-- CUSTOM SETTING CONTROLS
-- ==========================================
local function CreateToggle(name, layoutOrder)
    local frame = Instance.new("Frame", SettingsContainer)
    frame.Size = UDim2.new(1, -10, 0, 45)
    frame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    frame.LayoutOrder = layoutOrder
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Position = UDim2.new(0, 20, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 15
    label.TextXAlignment = Enum.TextXAlignment.Left

    local toggleBg = Instance.new("TextButton", frame)
    toggleBg.Size = UDim2.new(0, 54, 0, 26)
    toggleBg.Position = UDim2.new(1, -75, 0.5, -13)
    toggleBg.BackgroundColor3 = UI.Config[name] and Color3.fromRGB(70, 200, 100) or Color3.fromRGB(50, 50, 55)
    toggleBg.Text = ""
    Instance.new("UICorner", toggleBg).CornerRadius = UDim.new(1, 0)

    local toggleKnob = Instance.new("Frame", toggleBg)
    toggleKnob.Size = UDim2.new(0, 22, 0, 22)
    toggleKnob.Position = UI.Config[name] and UDim2.new(1, -24, 0.5, -11) or UDim2.new(0, 2, 0.5, -11)
    toggleKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", toggleKnob).CornerRadius = UDim.new(1, 0)

    toggleBg.MouseButton1Click:Connect(function()
        UI.Config[name] = not UI.Config[name]
        local isEnabled = UI.Config[name]
        
        CreateTween(toggleBg, TweenInfo.new(0.3), {BackgroundColor3 = isEnabled and Color3.fromRGB(70, 200, 100) or Color3.fromRGB(50, 50, 55)})
        CreateTween(toggleKnob, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = isEnabled and UDim2.new(1, -24, 0.5, -11) or UDim2.new(0, 2, 0.5, -11)})
        
        SaveConfig()
    end)
end

local function CreateInput(name, isNumber, layoutOrder)
    local frame = Instance.new("Frame", SettingsContainer)
    frame.Size = UDim2.new(1, -10, 0, 45)
    frame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    frame.LayoutOrder = layoutOrder
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.Position = UDim2.new(0, 20, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(220, 220, 220)
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 15
    label.TextXAlignment = Enum.TextXAlignment.Left

    local input = Instance.new("TextBox", frame)
    input.Size = UDim2.new(0.4, -20, 0, 32)
    input.Position = UDim2.new(0.6, 0, 0.5, -16)
    input.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
    input.TextColor3 = Color3.fromRGB(255, 255, 255)
    input.Text = tostring(UI.Config[name])
    input.Font = Enum.Font.Gotham
    input.TextSize = 14
    Instance.new("UICorner", input).CornerRadius = UDim.new(0, 6)
    local stroke = Instance.new("UIStroke", input)
    stroke.Color = Color3.fromRGB(40, 40, 45)

    input.Focused:Connect(function() CreateTween(stroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(100, 150, 255)}) end)
    input.FocusLost:Connect(function()
        CreateTween(stroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(40, 40, 45)})
        if isNumber then
            UI.Config[name] = tonumber(input.Text) or UI.Config[name]
        else
            UI.Config[name] = input.Text
        end
        SaveConfig()
    end)
end

-- Generate Settings
CreateInput("mode", false, 1)
CreateToggle("Decompile", 2)
CreateInput("DecompileTimeout", true, 3)
CreateToggle("scriptcache", 4)
CreateToggle("SafeMode", 5)
CreateInput("FilePath", false, 6)
CreateToggle("NilInstances", 7)

-- ==========================================
-- EXECUTION AREA
-- ==========================================
local BottomArea = Instance.new("Frame", MainFrame)
BottomArea.Size = UDim2.new(1, 0, 0, 60)
BottomArea.Position = UDim2.new(0, 0, 1, -60)
BottomArea.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
BottomArea.BorderSizePixel = 0

local ExecBtn = Instance.new("TextButton", BottomArea)
ExecBtn.Size = UDim2.new(1, -40, 0, 42)
ExecBtn.Position = UDim2.new(0, 20, 0, 9)
ExecBtn.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
ExecBtn.Text = "Initialize SaveInstance"
ExecBtn.TextColor3 = Color3.fromRGB(10, 10, 10)
ExecBtn.Font = Enum.Font.GothamBold
ExecBtn.TextSize = 15
ExecBtn.AutoButtonColor = false
Instance.new("UICorner", ExecBtn).CornerRadius = UDim.new(0, 8)
UI.Elements.ExecuteBtn = ExecBtn

ExecBtn.MouseEnter:Connect(function() CreateTween(ExecBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(200, 200, 200)}) end)
ExecBtn.MouseLeave:Connect(function() CreateTween(ExecBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(240, 240, 240)}) end)
ExecBtn.MouseButton1Click:Connect(function()
    CreateRipple(ExecBtn)
    UI.Notify("Engine Running", "SaveInstance initialized. Check workspace folder soon.", 5)
end)

-- ==========================================
-- LOADING SEQUENCE & KEYBINDS
-- ==========================================
MainFrame.Visible = true
MainFrame.Size = UDim2.new(0, 600, 0, 400)
CreateTween(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 700, 0, 500)})
UI.Notify("Loaded", "Settings loaded from workspace.", 3)

local uiVisible = true
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
        uiVisible = not uiVisible
        if uiVisible then
            MainFrame.Visible = true
            CreateTween(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 700, 0, 500)})
        else
            local out = CreateTween(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)})
            out.Completed:Wait()
            MainFrame.Visible = false
        end
    end
end)

-- Smooth Dragging
local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)
MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        CreateTween(MainFrame, TweenInfo.new(0.15, Enum.EasingStyle.Linear), {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)})
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

function UI.GetConfigs() return UI.Config end

return UI
