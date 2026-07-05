local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local UI = {}
UI.ConfigPath = "MxDcmp_Config.json"

-- Default Configuration Parameters
UI.Config = {
    mode = "full",
    Decompile = true,
    DecompileTimeout = -1,
    scriptcache = true,
    SafeMode = false,
    FilePath = "DcmpByMax",
    NilInstances = true
}

-- Safe Executor File System Wrappers
local function SaveConfig()
    if writefile then
        pcall(function()
            writefile(UI.ConfigPath, HttpService:JSONEncode(UI.Config))
        end)
    end
end

local function LoadConfig()
    if isfile and readfile and isfile(UI.ConfigPath) then
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile(UI.ConfigPath))
        end)
        if success and type(data) == "table" then
            for k, v in pairs(data) do
                if UI.Config[k] ~= nil then UI.Config[k] = v end
            end
        end
    end
end

LoadConfig()

-- Cleanup old instances
if CoreGui:FindFirstChild("MxDcmpPremiumUI") then CoreGui.MxDcmpPremiumUI:Destroy() end
if CoreGui:FindFirstChild("MxDcmpMinimizeIcon") then CoreGui.MxDcmpMinimizeIcon:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MxDcmpPremiumUI"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- Dynamic Device Responsive Sizing
local function GetResponsiveSize()
    local viewport = Workspace.CurrentCamera and Workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
    local targetWidth = math.min(700, viewport.X * 0.9)
    local targetHeight = math.min(500, viewport.Y * 0.85)
    return UDim2.new(0, targetWidth, 0, targetHeight)
end

local function CreateTween(instance, info, goals)
    local tween = TweenService:Create(instance, info, goals)
    tween:Play()
    return tween
end

-- ==========================================
-- FLOATING MINIMIZE ICON (Shadowed, No Glow)
-- ==========================================
local IconGui = Instance.new("ScreenGui")
IconGui.Name = "MxDcmpMinimizeIcon"
IconGui.Parent = CoreGui

local FloatingIcon = Instance.new("TextButton")
FloatingIcon.Size = UDim2.new(0, 50, 0, 50)
FloatingIcon.Position = UDim2.new(0.05, 0, 0.2, 0)
FloatingIcon.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
FloatingIcon.Text = "MX"
FloatingIcon.TextColor3 = Color3.fromRGB(240, 240, 240)
FloatingIcon.Font = Enum.Font.Bodoni
FloatingIcon.TextSize = 18
FloatingIcon.Visible = false
FloatingIcon.Parent = IconGui

Instance.new("UICorner", FloatingIcon).CornerRadius = UDim.new(1, 0)
local IconShadow = Instance.new("UIStroke", FloatingIcon)
IconShadow.Color = Color3.fromRGB(5, 5, 5) -- Dark shadow instead of blue glow
IconShadow.Thickness = 2.5
IconShadow.Transparency = 0.3

-- Make Floating Icon Draggable
local iconDragging, iconStart, iconPos
FloatingIcon.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        iconDragging = true
        iconStart = input.Position
        iconPos = FloatingIcon.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if iconDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - iconStart
        FloatingIcon.Position = UDim2.new(iconPos.X.Scale, iconPos.X.Offset + delta.X, iconPos.Y.Scale, iconPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then iconDragging = false end
end)

-- ==========================================
-- TOAST NOTIFICATION SYSTEM (Shadowed)
-- ==========================================
local NotifContainer = Instance.new("Frame", ScreenGui)
NotifContainer.Size = UDim2.new(0, 260, 1, -20)
NotifContainer.Position = UDim2.new(1, -280, 0, 10)
NotifContainer.BackgroundTransparency = 1

local NotifLayout = Instance.new("UIListLayout", NotifContainer)
NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotifLayout.Padding = UDim.new(0, 10)

function UI.Notify(title, text, duration)
    duration = duration or 3
    local notif = Instance.new("Frame", NotifContainer)
    notif.Size = UDim2.new(1, 40, 0, 60)
    notif.BackgroundTransparency = 1
    
    local bg = Instance.new("Frame", notif)
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 8)
    
    local notifShadow = Instance.new("UIStroke", bg)
    notifShadow.Color = Color3.fromRGB(0, 0, 0)
    notifShadow.Thickness = 2
    notifShadow.Transparency = 0.5
    
    local tl = Instance.new("TextLabel", bg)
    tl.Size = UDim2.new(1, -20, 0, 25)
    tl.Position = UDim2.new(0, 10, 0, 5)
    tl.BackgroundTransparency = 1
    tl.Text = title
    tl.TextColor3 = Color3.fromRGB(240, 240, 240)
    tl.Font = Enum.Font.GothamBold
    tl.TextSize = 13
    tl.TextXAlignment = Enum.TextXAlignment.Left
    
    local tx = Instance.new("TextLabel", bg)
    tx.Size = UDim2.new(1, -20, 0, 20)
    tx.Position = UDim2.new(0, 10, 0, 30)
    tx.BackgroundTransparency = 1
    tx.Text = text
    tx.TextColor3 = Color3.fromRGB(160, 160, 160)
    tx.Font = Enum.Font.Gotham
    tx.TextSize = 11
    tx.TextXAlignment = Enum.TextXAlignment.Left
    
    CreateTween(notif, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 60)})
    
    task.delay(duration, function()
        pcall(function()
            local out = CreateTween(notif, TweenInfo.new(0.3), {Size = UDim2.new(1, 40, 0, 60)})
            CreateTween(bg, TweenInfo.new(0.3), {BackgroundTransparency = 1})
            CreateTween(tl, TweenInfo.new(0.3), {TextTransparency = 1})
            CreateTween(tx, TweenInfo.new(0.3), {TextTransparency = 1})
            out.Completed:Wait()
            notif:Destroy()
        end)
    end)
end

-- ==========================================
-- MAIN PANEL INTERFACE
-- ==========================================
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = GetResponsiveSize()
MainFrame.Position = UDim2.new(0.5, -MainFrame.Size.X.Offset/2, 0.5, -MainFrame.Size.Y.Offset/2)
MainFrame.BackgroundColor3 = Color3.fromRGB(14, 14, 16)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Visible = false -- Hidden initially for loader

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- Dark UI Shadow instead of bright borders
local MainShadow = Instance.new("UIStroke", MainFrame)
MainShadow.Color = Color3.fromRGB(5, 5, 5)
MainShadow.Thickness = 3
MainShadow.Transparency = 0.4

-- Top Bar Elements
local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 50)
TopBar.BackgroundTransparency = 1

local TitlePill = Instance.new("Frame", TopBar)
TitlePill.Size = UDim2.new(0, 200, 0, 32)
TitlePill.Position = UDim2.new(0, 15, 0, 9)
TitlePill.BackgroundColor3 = Color3.fromRGB(20, 20, 22)
Instance.new("UICorner", TitlePill).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", TitlePill).Color = Color3.fromRGB(35, 35, 40)

local TitleText = Instance.new("TextLabel", TitlePill)
TitleText.Size = UDim2.new(1, 0, 1, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "Universal Project Hook"
TitleText.TextColor3 = Color3.fromRGB(220, 220, 220)
TitleText.Font = Enum.Font.Bodoni
TitleText.TextSize = 14

-- Minimize Action
local MinimizeBtn = Instance.new("TextButton", TopBar)
MinimizeBtn.Size = UDim2.new(0, 35, 0, 32)
MinimizeBtn.Position = UDim2.new(1, -105, 0, 9)
MinimizeBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 22)
MinimizeBtn.Text = "—"
MinimizeBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 12
Instance.new("UICorner", MinimizeBtn).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", MinimizeBtn).Color = Color3.fromRGB(35, 35, 40)

-- Close Action
local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.Size = UDim2.new(0, 35, 0, 32)
CloseBtn.Position = UDim2.new(1, -55, 0, 9)
CloseBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 22)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(200, 70, 70)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 12
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", CloseBtn).Color = Color3.fromRGB(35, 35, 40)

local Line = Instance.new("Frame", MainFrame)
Line.Size = UDim2.new(1, -30, 0, 1)
Line.Position = UDim2.new(0, 15, 0, 50)
Line.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
Line.BorderSizePixel = 0

-- Scrolling Layout Setup
local SettingsContainer = Instance.new("ScrollingFrame", MainFrame)
SettingsContainer.Size = UDim2.new(1, -30, 1, -130)
SettingsContainer.Position = UDim2.new(0, 15, 0, 65)
SettingsContainer.BackgroundTransparency = 1
SettingsContainer.ScrollBarThickness = 2
SettingsContainer.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 65)
SettingsContainer.BorderSizePixel = 0

local SettingsLayout = Instance.new("UIListLayout", SettingsContainer)
SettingsLayout.Padding = UDim.new(0, 10)
SettingsLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Toggle Switch Builder
local function CreateToggle(name, layoutOrder)
    local frame = Instance.new("Frame", SettingsContainer)
    frame.Size = UDim2.new(1, -5, 0, 45)
    frame.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
    frame.LayoutOrder = layoutOrder
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Position = UDim2.new(0, 15, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left

    local toggleBg = Instance.new("TextButton", frame)
    toggleBg.Size = UDim2.new(0, 50, 0, 24)
    toggleBg.Position = UDim2.new(1, -65, 0.5, -12)
    toggleBg.BackgroundColor3 = UI.Config[name] and Color3.fromRGB(90, 180, 110) or Color3.fromRGB(45, 45, 50)
    toggleBg.Text = ""
    Instance.new("UICorner", toggleBg).CornerRadius = UDim.new(1, 0)

    local toggleKnob = Instance.new("Frame", toggleBg)
    toggleKnob.Size = UDim2.new(0, 20, 0, 20)
    toggleKnob.Position = UI.Config[name] and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
    toggleKnob.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
    Instance.new("UICorner", toggleKnob).CornerRadius = UDim.new(1, 0)

    toggleBg.MouseButton1Click:Connect(function()
        UI.Config[name] = not UI.Config[name]
        local isEnabled = UI.Config[name]
        CreateTween(toggleBg, TweenInfo.new(0.25), {BackgroundColor3 = isEnabled and Color3.fromRGB(90, 180, 110) or Color3.fromRGB(45, 45, 50)})
        CreateTween(toggleKnob, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = isEnabled and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)})
        SaveConfig()
    end)
end

-- TextBox Builder (Removed Blue Glow)
local function CreateInput(name, isNumber, layoutOrder)
    local frame = Instance.new("Frame", SettingsContainer)
    frame.Size = UDim2.new(1, -5, 0, 45)
    frame.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
    frame.LayoutOrder = layoutOrder
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.Position = UDim2.new(0, 15, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left

    local input = Instance.new("TextBox", frame)
    input.Size = UDim2.new(0.4, -10, 0, 30)
    input.Position = UDim2.new(0.6, 0, 0.5, -15)
    input.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
    input.TextColor3 = Color3.fromRGB(240, 240, 240)
    input.Text = tostring(UI.Config[name])
    input.Font = Enum.Font.Gotham
    input.TextSize = 13
    Instance.new("UICorner", input).CornerRadius = UDim.new(0, 6)
    
    local stroke = Instance.new("UIStroke", input)
    stroke.Color = Color3.fromRGB(35, 35, 40)

    -- Subtle grey highlight instead of neon blue
    input.Focused:Connect(function() CreateTween(stroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(90, 90, 95)}) end)
    input.FocusLost:Connect(function()
        CreateTween(stroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(35, 35, 40)})
        if isNumber then
            UI.Config[name] = tonumber(input.Text) or UI.Config[name]
        else
            UI.Config[name] = input.Text
        end
        SaveConfig()
    end)
end

-- Generate Menu Configuration Controls
CreateInput("mode", false, 1)
CreateToggle("Decompile", 2)
CreateInput("DecompileTimeout", true, 3)
CreateToggle("scriptcache", 4)
CreateToggle("SafeMode", 5)
CreateInput("FilePath", false, 6)
CreateToggle("NilInstances", 7)

-- Bottom Execution Deck
local BottomArea = Instance.new("Frame", MainFrame)
BottomArea.Size = UDim2.new(1, 0, 0, 60)
BottomArea.Position = UDim2.new(0, 0, 1, -60)
BottomArea.BackgroundColor3 = Color3.fromRGB(16, 16, 18)
BottomArea.BorderSizePixel = 0

local ExecBtn = Instance.new("TextButton", BottomArea)
ExecBtn.Size = UDim2.new(1, -30, 0, 40)
ExecBtn.Position = UDim2.new(0, 15, 0, 10)
ExecBtn.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
ExecBtn.Text = "Initialize SaveInstance Pipeline"
ExecBtn.TextColor3 = Color3.fromRGB(15, 15, 15)
ExecBtn.Font = Enum.Font.GothamBold
ExecBtn.TextSize = 13
Instance.new("UICorner", ExecBtn).CornerRadius = UDim.new(0, 6)

ExecBtn.MouseEnter:Connect(function() CreateTween(ExecBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(200, 200, 200)}) end)
ExecBtn.MouseLeave:Connect(function() CreateTween(ExecBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(230, 230, 230)}) end)

-- ==========================================
-- RAW SYN-SAVEINSTANCE EXECUTION
-- ==========================================
ExecBtn.MouseButton1Click:Connect(function()
    UI.Notify("Executing Hooks", "Running your USSI snippet directly...", 4)
    
    local Params = {
        RepoURL = "https://raw.githubusercontent.com/luau/UniversalSynSaveInstance/main/",
        SSI = "saveinstance",
    }

    local synsaveinstance = loadstring(game:HttpGet(Params.RepoURL .. Params.SSI .. ".luau", true), Params.SSI)()

    synsaveinstance({
        mode = UI.Config.mode,          
        Decompile = UI.Config.Decompile,         
        DecompileTimeout = UI.Config.DecompileTimeout,      
        scriptcache = UI.Config.scriptcache,
        SafeMode = UI.Config.SafeMode,          
        FilePath = UI.Config.FilePath,    
        NilInstances = UI.Config.NilInstances,   
    })
    
    UI.Notify("Success", "Snippet executed successfully.", 5)
end)

-- ==========================================
-- TOGGLES, WINDOW WINDOW CONTROL, DRAG LOGIC
-- ==========================================
local function ToggleUI(state)
    if state then
        MainFrame.Visible = true
        FloatingIcon.Visible = false
        MainFrame.Size = UDim2.new(0, 0, 0, 0)
        CreateTween(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = GetResponsiveSize()})
    else
        local shrink = CreateTween(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)})
        shrink.Completed:Wait()
        MainFrame.Visible = false
        FloatingIcon.Visible = true
    end
end

MinimizeBtn.MouseButton1Click:Connect(function() ToggleUI(false) end)
FloatingIcon.MouseButton1Click:Connect(function() ToggleUI(true) end)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy(); IconGui:Destroy() end)

if Workspace.CurrentCamera then
    Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        if MainFrame.Visible then
            MainFrame.Size = GetResponsiveSize()
        end
    end)
end

local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)
MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        CreateTween(MainFrame, TweenInfo.new(0.12, Enum.EasingStyle.Linear), {
            Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        })
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.RightShift then
        ToggleUI(not MainFrame.Visible)
    end
end)

-- ==========================================
-- MINI LOADING SCREEN ANIMATION
-- ==========================================
local LoadFrame = Instance.new("Frame", ScreenGui)
LoadFrame.Size = UDim2.new(0, 80, 0, 80)
LoadFrame.Position = UDim2.new(0.5, -40, 0.5, -40)
LoadFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
LoadFrame.BackgroundTransparency = 1
Instance.new("UICorner", LoadFrame).CornerRadius = UDim.new(0, 12)

local LoadShadow = Instance.new("UIStroke", LoadFrame)
LoadShadow.Color = Color3.fromRGB(5, 5, 5)
LoadShadow.Thickness = 2
LoadShadow.Transparency = 1

local LoadText = Instance.new("TextLabel", LoadFrame)
LoadText.Size = UDim2.new(1, 0, 1, 0)
LoadText.BackgroundTransparency = 1
LoadText.Text = "MX"
LoadText.TextColor3 = Color3.fromRGB(255, 255, 255)
LoadText.Font = Enum.Font.Bodoni
LoadText.TextSize = 28
LoadText.TextTransparency = 1

task.spawn(function()
    -- Fade In Loader
    CreateTween(LoadFrame, TweenInfo.new(0.4), {BackgroundTransparency = 0})
    CreateTween(LoadShadow, TweenInfo.new(0.4), {Transparency = 0.4})
    CreateTween(LoadText, TweenInfo.new(0.4), {TextTransparency = 0})
    
    task.wait(1.5) -- Authentic wait time for visual flair
    
    -- Fade Out Loader
    CreateTween(LoadFrame, TweenInfo.new(0.3), {BackgroundTransparency = 1})
    CreateTween(LoadShadow, TweenInfo.new(0.3), {Transparency = 1})
    local textFadeOut = CreateTween(LoadText, TweenInfo.new(0.3), {TextTransparency = 1})
    
    textFadeOut.Completed:Wait()
    LoadFrame:Destroy()
    
    -- Pop In Main UI
    MainFrame.Visible = true
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    CreateTween(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = GetResponsiveSize()})
    UI.Notify("System Online", "Settings loaded. Ready to dump.", 3)
end)

return UI
