local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer

local UI = {}
UI.ConfigPath = "MxDcmp_Config.json"
UI.CurrentTab = "SaveInstance"

-- State tracking for cheats
local Cheats = {
    Fly = false,
    Noclip = false,
    ESP = false,
    Speed = 16,
    Jump = 50,
    TPWalk = false,
    TPWalkSpeed = 2,
    SilentAim = false
}

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

local function GetResponsiveSize()
    local viewport = Workspace.CurrentCamera and Workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
    local targetWidth = math.min(750, viewport.X * 0.9)
    local targetHeight = math.min(520, viewport.Y * 0.85)
    return UDim2.new(0, targetWidth, 0, targetHeight)
end

local function CreateTween(instance, info, goals)
    local tween = TweenService:Create(instance, info, goals)
    tween:Play()
    return tween
end

-- ==========================================
-- FLOATING MINIMIZE ICON
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
IconShadow.Color = Color3.fromRGB(5, 5, 5)
IconShadow.Thickness = 2.5
IconShadow.Transparency = 0.3

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
-- TOAST NOTIFICATION SYSTEM
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
MainFrame.Visible = false

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
local MainShadow = Instance.new("UIStroke", MainFrame)
MainShadow.Color = Color3.fromRGB(5, 5, 5)
MainShadow.Thickness = 3
MainShadow.Transparency = 0.4

-- Top Bar Elements
local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size = UDim2.new(1, 0, 0, 50)
TopBar.BackgroundTransparency = 1

local TitlePill = Instance.new("Frame", TopBar)
TitlePill.Size = UDim2.new(0, 220, 0, 32)
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

-- ==========================================
-- SIDEBAR NAVIGATION SYSTEM
-- ==========================================
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 160, 1, -65)
Sidebar.Position = UDim2.new(0, 15, 0, 65)
Sidebar.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 8)

local SidebarLayout = Instance.new("UIListLayout", Sidebar)
SidebarLayout.Padding = UDim.new(0, 6)
SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder

local PagesContainer = Instance.new("Frame", MainFrame)
PagesContainer.Size = UDim2.new(1, -200, 1, -65)
PagesContainer.Position = UDim2.new(0, 185, 0, 65)
PagesContainer.BackgroundTransparency = 1

local Pages = {}
local TabButtons = {}

local function CreateTab(name, layoutOrder)
    local btn = Instance.new("TextButton", Sidebar)
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(22, 22, 25)
    btn.BackgroundTransparency = name == UI.CurrentTab and 0 or 1
    btn.Text = "   " .. name
    btn.TextColor3 = name == UI.CurrentTab and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 160, 160)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 13
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.LayoutOrder = layoutOrder
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local page = Instance.new("ScrollingFrame", PagesContainer)
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible = name == UI.CurrentTab and true or false
    page.ScrollBarThickness = 2
    page.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 65)
    page.BorderSizePixel = 0

    local pageLayout = Instance.new("UIListLayout", page)
    pageLayout.Padding = UDim.new(0, 10)
    pageLayout.SortOrder = Enum.SortOrder.LayoutOrder

    Pages[name] = page
    TabButtons[name] = btn

    btn.MouseButton1Click:Connect(function()
        for k, v in pairs(Pages) do v.Visible = (k == name) end
        for k, v in pairs(TabButtons) do 
            CreateTween(v, TweenInfo.new(0.2), {
                BackgroundTransparency = (k == name) and 0 or 1,
                TextColor3 = (k == name) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 160, 160)
            })
        end
        UI.CurrentTab = name
    end)
    return page
end

local SaveInstancePage = CreateTab("SaveInstance", 1)
local UniversalsPage = CreateTab("Universals", 2)
local SimplePage = CreateTab("Simple", 3)

-- ==========================================
-- PAGE 1: SAVEINSTANCE BUILDER
-- ==========================================
local function CreateToggle(parent, name, configRef, layoutOrder)
    local frame = Instance.new("Frame", parent)
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
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left

    local toggleBg = Instance.new("TextButton", frame)
    toggleBg.Size = UDim2.new(0, 46, 0, 22)
    toggleBg.Position = UDim2.new(1, -60, 0.5, -11)
    toggleBg.BackgroundColor3 = configRef[name] and Color3.fromRGB(90, 180, 110) or Color3.fromRGB(45, 45, 50)
    toggleBg.Text = ""
    Instance.new("UICorner", toggleBg).CornerRadius = UDim.new(1, 0)

    local toggleKnob = Instance.new("Frame", toggleBg)
    toggleKnob.Size = UDim2.new(0, 18, 0, 18)
    toggleKnob.Position = configRef[name] and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
    toggleKnob.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
    Instance.new("UICorner", toggleKnob).CornerRadius = UDim.new(1, 0)

    toggleBg.MouseButton1Click:Connect(function()
        configRef[name] = not configRef[name]
        local isEnabled = configRef[name]
        CreateTween(toggleBg, TweenInfo.new(0.2), {BackgroundColor3 = isEnabled and Color3.fromRGB(90, 180, 110) or Color3.fromRGB(45, 45, 50)})
        CreateTween(toggleKnob, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = isEnabled and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)})
        SaveConfig()
    end)
end

local function CreateInput(parent, name, isNumber, configRef, layoutOrder)
    local frame = Instance.new("Frame", parent)
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
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left

    local input = Instance.new("TextBox", frame)
    input.Size = UDim2.new(0.4, -10, 0, 28)
    input.Position = UDim2.new(0.6, 0, 0.5, -14)
    input.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
    input.TextColor3 = Color3.fromRGB(240, 240, 240)
    input.Text = tostring(configRef[name])
    input.Font = Enum.Font.Gotham
    input.TextSize = 12
    Instance.new("UICorner", input).CornerRadius = UDim.new(0, 6)
    
    local stroke = Instance.new("UIStroke", input)
    stroke.Color = Color3.fromRGB(35, 35, 40)

    input.Focused:Connect(function() CreateTween(stroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(90, 90, 95)}) end)
    input.FocusLost:Connect(function()
        CreateTween(stroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(35, 35, 40)})
        if isNumber then
            configRef[name] = tonumber(input.Text) or configRef[name]
        else
            configRef[name] = input.Text
        end
        SaveConfig()
    end)
end

CreateInput(SaveInstancePage, "mode", false, UI.Config, 1)
CreateToggle(SaveInstancePage, "Decompile", UI.Config, 2)
CreateInput(SaveInstancePage, "DecompileTimeout", true, UI.Config, 3)
CreateToggle(SaveInstancePage, "scriptcache", UI.Config, 4)
CreateToggle(SaveInstancePage, "SafeMode", UI.Config, 5)
CreateInput(SaveInstancePage, "FilePath", false, UI.Config, 6)
CreateToggle(SaveInstancePage, "NilInstances", UI.Config, 7)

local SaveExecContainer = Instance.new("Frame", SaveInstancePage)
SaveExecContainer.Size = UDim2.new(1, -5, 0, 50)
SaveExecContainer.BackgroundTransparency = 1
SaveExecContainer.LayoutOrder = 8

local SaveExecBtn = Instance.new("TextButton", SaveExecContainer)
SaveExecBtn.Size = UDim2.new(1, 0, 1, 0)
SaveExecBtn.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
SaveExecBtn.Text = "Initialize SaveInstance Pipeline"
SaveExecBtn.TextColor3 = Color3.fromRGB(15, 15, 15)
SaveExecBtn.Font = Enum.Font.GothamBold
SaveExecBtn.TextSize = 13
Instance.new("UICorner", SaveExecBtn).CornerRadius = UDim.new(0, 6)

SaveExecBtn.MouseButton1Click:Connect(function()
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
-- PAGE 2: UNIVERSALS UTILITIES PRESETS
-- ==========================================
local function CreateUtilButton(name, loadstringSrc, layoutOrder)
    local btn = Instance.new("TextButton", UniversalsPage)
    btn.Size = UDim2.new(1, -5, 0, 45)
    btn.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
    btn.Text = "Launch " .. name
    btn.TextColor3 = Color3.fromRGB(210, 210, 210)
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 13
    btn.LayoutOrder = layoutOrder
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    btn.MouseButton1Click:Connect(function()
        UI.Notify("Fetching Target", "Injecting environment payload for " .. name, 3)
        task.spawn(function()
            local success, err = pcall(function()
                loadstring(game:HttpGet(loadstringSrc))()
            end)
            if success then
                UI.Notify("Loaded", name .. " execution successful.", 3)
            else
                UI.Notify("Error", "Execution blocked or failed.", 4)
            end
        end)
    end)
end

CreateUtilButton("Dex V3 Explorer", "https://raw.githubusercontent.com/infyiff/backup/main/dex.lua", 1)
CreateUtilButton("Dex++ Optimized", "https://raw.githubusercontent.com/infyiff/backup/main/dex.lua", 2) -- Standard universal mirror
CreateUtilButton("SimpleSpy V2", "https://raw.githubusercontent.com/exxtremestuffs/SimpleSpySource/master/SimpleSpy.lua", 3)
CreateUtilButton("Infinite Yield", "https://raw.githubusercontent.com/EdgeYStandard/InfiniteYield/master/source", 4)
CreateUtilButton("Nameless Admin FE", "https://raw.githubusercontent.com/FilteringEnabled/NamelessAdmin/main/Source", 5)

-- ==========================================
-- PAGE 3: SIMPLE UTILITY CHEATS
-- ==========================================
-- WalkSpeed Logic
local speedFrame = Instance.new("Frame", SimplePage)
speedFrame.Size = UDim2.new(1, -5, 0, 45)
speedFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
speedFrame.LayoutOrder = 1
Instance.new("UICorner", speedFrame).CornerRadius = UDim.new(0, 8)

local speedLabel = Instance.new("TextLabel", speedFrame)
speedLabel.Size = UDim2.new(0.5, 0, 1, 0) speedLabel.Position = UDim2.new(0, 15, 0, 0) speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Custom Speed (Undetected)" speedLabel.TextColor3 = Color3.fromRGB(200, 200, 200) speedLabel.Font = Enum.Font.GothamMedium speedLabel.TextSize = 13 speedLabel.TextXAlignment = Enum.TextXAlignment.Left

local speedInput = Instance.new("TextBox", speedFrame)
speedInput.Size = UDim2.new(0.4, -10, 0, 28) speedInput.Position = UDim2.new(0.6, 0, 0.5, -14) speedInput.BackgroundColor3 = Color3.fromRGB(12, 12, 14) speedInput.TextColor3 = Color3.fromRGB(240, 240, 240) speedInput.Text = "16" speedInput.Font = Enum.Font.Gotham speedInput.TextSize = 12 Instance.new("UICorner", speedInput).CornerRadius = UDim.new(0, 6)

speedInput.FocusLost:Connect(function()
    Cheats.Speed = tonumber(speedInput.Text) or 16
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = Cheats.Speed
    end
end)

-- JumpPower Logic
local jumpFrame = Instance.new("Frame", SimplePage)
jumpFrame.Size = UDim2.new(1, -5, 0, 45)
jumpFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
jumpFrame.LayoutOrder = 2
Instance.new("UICorner", jumpFrame).CornerRadius = UDim.new(0, 8)

local jumpLabel = Instance.new("TextLabel", jumpFrame)
jumpLabel.Size = UDim2.new(0.5, 0, 1, 0) jumpLabel.Position = UDim2.new(0, 15, 0, 0) jumpLabel.BackgroundTransparency = 1
jumpLabel.Text = "Jump Power" jumpLabel.TextColor3 = Color3.fromRGB(200, 200, 200) jumpLabel.Font = Enum.Font.GothamMedium jumpLabel.TextSize = 13 jumpLabel.TextXAlignment = Enum.TextXAlignment.Left

local jumpInput = Instance.new("TextBox", jumpFrame)
jumpInput.Size = UDim2.new(0.4, -10, 0, 28) jumpInput.Position = UDim2.new(0.6, 0, 0.5, -14) jumpInput.BackgroundColor3 = Color3.fromRGB(12, 12, 14) jumpInput.TextColor3 = Color3.fromRGB(240, 240, 240) jumpInput.Text = "50" jumpInput.Font = Enum.Font.Gotham jumpInput.TextSize = 12 Instance.new("UICorner", jumpInput).CornerRadius = UDim.new(0, 6)

jumpInput.FocusLost:Connect(function()
    Cheats.Jump = tonumber(jumpInput.Text) or 50
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        hum.JumpPower = Cheats.Jump
        hum.UseJumpPower = true
    end
end)

-- Loop to re-apply human modifications constantly safely
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum.WalkSpeed ~= Cheats.Speed and Cheats.Speed ~= 16 then hum.WalkSpeed = Cheats.Speed end
            end
        end)
    end
end)

-- Clean Noclip Implementation
CreateToggle(SimplePage, "Noclip Run", Cheats, 3)
RunService.Stepped:Connect(function()
    if Cheats["Noclip Run"] and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

-- Fly / VFly Logic Core Framework
CreateToggle(SimplePage, "Fly Engine", Cheats, 4)
local flightCore;
task.spawn(function()
    while task.wait(0.1) do
        if Cheats["Fly Engine"] then
            pcall(function()
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if root then
                    local bv = root:FindFirstChild("MX_FlightVector") or Instance.new("BodyVelocity", root)
                    bv.Name = "MX_FlightVector"
                    bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                    local camCFrame = Workspace.CurrentCamera.CFrame
                    local dir = Vector3.new(0,0,0)
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + camCFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - camCFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - camCFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + camCFrame.RightVector end
                    bv.Velocity = dir * 50
                end
            end)
        else
            pcall(function()
                local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if root and root:FindFirstChild("MX_FlightVector") then root.MX_FlightVector:Destroy() end
            end)
        end
    end
end)

-- TPWalk Loop Engine
CreateToggle(SimplePage, "TPWalk", Cheats, 5)
task.spawn(function()
    while task.wait() do
        if Cheats.TPWalk and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            local root = LocalPlayer.Character.HumanoidRootPart
            if hum.MoveDirection.Magnitude > 0 then
                root.CFrame = root.CFrame + (hum.MoveDirection * (Cheats.TPWalkSpeed / 10))
            end
        end
    end
end)

-- Teleport to Player Logic Deck
local tpFrame = Instance.new("Frame", SimplePage)
tpFrame.Size = UDim2.new(1, -5, 0, 45)
tpFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
tpFrame.LayoutOrder = 6
Instance.new("UICorner", tpFrame).CornerRadius = UDim.new(0, 8)

local tpInput = Instance.new("TextBox", tpFrame)
tpInput.Size = UDim2.new(0.6, -15, 0, 28) tpInput.Position = UDim2.new(0, 15, 0.5, -14) tpInput.BackgroundColor3 = Color3.fromRGB(12, 12, 14) tpInput.TextColor3 = Color3.fromRGB(240, 240, 240) tpInput.Text = "Target Username" tpInput.Font = Enum.Font.Gotham tpInput.TextSize = 12 Instance.new("UICorner", tpInput).CornerRadius = UDim.new(0, 6)

local tpBtn = Instance.new("TextButton", tpFrame)
tpBtn.Size = UDim2.new(0.4, -15, 0, 28) tpBtn.Position = UDim2.new(0.6, 5, 0.5, -14) tpBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50) tpBtn.Text = "Teleport" tpBtn.TextColor3 = Color3.fromRGB(230, 230, 230) tpBtn.Font = Enum.Font.GothamBold tpBtn.TextSize = 12 Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0, 6)

tpBtn.MouseButton1Click:Connect(function()
    local targetName = tpInput.Text:lower()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and (p.Name:lower():sub(1, #targetName) == targetName or p.DisplayName:lower():sub(1, #targetName) == targetName) then
            if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                LocalPlayer.Character.HumanoidRootPart.CFrame = p.Character.HumanoidRootPart.CFrame
                UI.Notify("Teleported", "Moved to " .. p.Name, 3)
                break
            end
        end
    end
end)

-- Client Side Audio ID System
local audioFrame = Instance.new("Frame", SimplePage)
audioFrame.Size = UDim2.new(1, -5, 0, 45)
audioFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
audioFrame.LayoutOrder = 7
Instance.new("UICorner", audioFrame).CornerRadius = UDim.new(0, 8)

local audioInput = Instance.new("TextBox", audioFrame)
audioInput.Size = UDim2.new(0.6, -15, 0, 28) audioInput.Position = UDim2.new(0, 15, 0.5, -14) audioInput.BackgroundColor3 = Color3.fromRGB(12, 12, 14) audioInput.TextColor3 = Color3.fromRGB(240, 240, 240) audioInput.Text = "Audio Asset ID" audioInput.Font = Enum.Font.Gotham audioInput.TextSize = 12 Instance.new("UICorner", audioInput).CornerRadius = UDim.new(0, 6)

local audioBtn = Instance.new("TextButton", audioFrame)
audioBtn.Size = UDim2.new(0.4, -15, 0, 28) audioBtn.Position = UDim2.new(0.6, 5, 0.5, -14) audioBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50) audioBtn.Text = "Play Local" audioBtn.TextColor3 = Color3.fromRGB(230, 230, 230) audioBtn.Font = Enum.Font.GothamBold audioBtn.TextSize = 12 Instance.new("UICorner", audioBtn).CornerRadius = UDim.new(0, 6)

local currentLocalSound;
audioBtn.MouseButton1Click:Connect(function()
    local id = tonumber(audioInput.Text)
    if id then
        if currentLocalSound then currentLocalSound:Destroy() end
        currentLocalSound = Instance.new("Sound", SoundService)
        currentLocalSound.SoundId = "rbxassetid://" .. id
        currentLocalSound.Volume = 1
        currentLocalSound:Play()
        UI.Notify("Playing Local", "Asset ID fired on client layer.", 3)
    end
end)

-- Safe Highlight Framework Player ESP
CreateToggle(SimplePage, "Visual Highlight ESP", Cheats, 8)
task.spawn(function()
    while task.wait(1) do
        if Cheats["Visual Highlight ESP"] then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    if not p.Character:FindFirstChild("MX_Highlight") then
                        local h = Instance.new("Highlight", p.Character)
                        h.Name = "MX_Highlight"
                        h.FillColor = Color3.fromRGB(140, 80, 255)
                        h.OutlineColor = Color3.fromRGB(255, 255, 255)
                        h.FillTransparency = 0.6
                    end
                end
            end
        else
            for _, p in pairs(Players:GetPlayers()) do
                if p.Character and p.Character:FindFirstChild("MX_Highlight") then
                    p.Character.MX_Highlight:Destroy()
                end
            end
        end
    end
end)

-- Silent Aim Flag Framework Target Placeholder
CreateToggle(SimplePage, "Silent Aim Link", Cheats, 9)

-- ==========================================
-- LAYER MANAGEMENT & DRAG LOGIC
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
        if MainFrame.Visible then MainFrame.Size = GetResponsiveSize() end
    end)
end

local dragging, dragInput, dragStart, startPos
MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true dragStart = input.Position startPos = MainFrame.Position
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
    if not processed and input.KeyCode == Enum.KeyCode.RightShift then ToggleUI(not MainFrame.Visible) end
end)

-- ==========================================
-- MINI LOADING SCREEN ANIMATION (MX LOGO)
-- ==========================================
local LoadFrame = Instance.new("Frame", ScreenGui)
LoadFrame.Size = UDim2.new(0, 85, 0, 85)
LoadFrame.Position = UDim2.new(0.5, -42, 0.5, -42)
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
LoadText.TextSize = 30
LoadText.TextTransparency = 1

task.spawn(function()
    CreateTween(LoadFrame, TweenInfo.new(0.4), {BackgroundTransparency = 0})
    CreateTween(LoadShadow, TweenInfo.new(0.4), {Transparency = 0.4})
    CreateTween(LoadText, TweenInfo.new(0.4), {TextTransparency = 0})
    
    task.wait(1.4)
    
    CreateTween(LoadFrame, TweenInfo.new(0.3), {BackgroundTransparency = 1})
    CreateTween(LoadShadow, TweenInfo.new(0.3), {Transparency = 1})
    local textFadeOut = CreateTween(LoadText, TweenInfo.new(0.3), {TextTransparency = 1})
    
    textFadeOut.Completed:Wait()
    LoadFrame:Destroy()
    
    MainFrame.Visible = true
    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    CreateTween(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = GetResponsiveSize()})
    UI.Notify("System Online", "All custom multi-tabs loaded without memory locks.", 3)
end)

return UI
