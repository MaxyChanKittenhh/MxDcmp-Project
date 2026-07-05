-- MxDcmp User Interface Module
-- A comprehensive, responsive, and sleek UI framework for Luau execution.

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local UI = {}
local Elements = {}
local Toggles = {}

-- Theme Configuration
local Theme = {
    Background = Color3.fromRGB(20, 20, 20),
    Panel = Color3.fromRGB(28, 28, 30),
    Sidebar = Color3.fromRGB(24, 24, 26),
    Topbar = Color3.fromRGB(35, 35, 38),
    Accent = Color3.fromRGB(60, 120, 255),
    AccentHover = Color3.fromRGB(80, 140, 255),
    TextMain = Color3.fromRGB(255, 255, 255),
    TextMuted = Color3.fromRGB(150, 150, 150),
    Success = Color3.fromRGB(50, 200, 80),
    Danger = Color3.fromRGB(255, 80, 80),
    CornerRadius = UDim.new(0, 8)
}

-- Tween Info Configuration
local TInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

-- Attempt to use CoreGui for stealth, fallback to PlayerGui
local function getParent()
    local success, result = pcall(function() return CoreGui end)
    if success and result then return result end
    return Players.LocalPlayer:WaitForChild("PlayerGui")
end

-- ScreenGui Setup
local parent = getParent()
if parent:FindFirstChild("MxDcmp_UI") then
    parent.MxDcmp_UI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MxDcmp_UI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = parent

-- Helper: Create Corner
local function MakeCorner(parentInst, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = radius or Theme.CornerRadius
    corner.Parent = parentInst
    return corner
end

-- Helper: Hover Animation
local function ApplyHover(button, originalColor, hoverColor)
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TInfo, {BackgroundColor3 = hoverColor}):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TInfo, {BackgroundColor3 = originalColor}):Play()
    end)
end

-- Main Open Tab (Minimized State)
local OpenTab = Instance.new("TextButton")
OpenTab.Name = "OpenTab"
OpenTab.Parent = ScreenGui
OpenTab.BackgroundColor3 = Theme.Accent
OpenTab.Position = UDim2.new(0, 0, 0.5, -25)
OpenTab.Size = UDim2.new(0, 40, 0, 50)
OpenTab.Text = ">"
OpenTab.TextColor3 = Theme.TextMain
OpenTab.TextSize = 24
OpenTab.Font = Enum.Font.GothamBold
OpenTab.Visible = false
MakeCorner(OpenTab, UDim.new(0, 12))
ApplyHover(OpenTab, Theme.Accent, Theme.AccentHover)

-- Main Background Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.Position = UDim2.new(0.2, 0, 0.2, 0)
MainFrame.Size = UDim2.new(0, 650, 0, 450)
MainFrame.ClipsDescendants = true
MakeCorner(MainFrame, UDim.new(0, 12))

-- Topbar
local Topbar = Instance.new("Frame")
Topbar.Name = "Topbar"
Topbar.Parent = MainFrame
Topbar.BackgroundColor3 = Theme.Topbar
Topbar.Size = UDim2.new(1, 0, 0, 40)
Topbar.BorderSizePixel = 0

local Title = Instance.new("TextLabel")
Title.Parent = Topbar
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Size = UDim2.new(0, 200, 1, 0)
Title.Text = "MxDcmp Framework"
Title.TextColor3 = Theme.TextMain
Title.TextSize = 16
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = Topbar
CloseBtn.BackgroundTransparency = 1
CloseBtn.Position = UDim2.new(1, -40, 0, 0)
CloseBtn.Size = UDim2.new(0, 40, 1, 0)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Theme.Danger
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.GothamBold

local MinBtn = Instance.new("TextButton")
MinBtn.Parent = Topbar
MinBtn.BackgroundTransparency = 1
MinBtn.Position = UDim2.new(1, -80, 0, 0)
MinBtn.Size = UDim2.new(0, 40, 1, 0)
MinBtn.Text = "-"
MinBtn.TextColor3 = Theme.TextMain
MinBtn.TextSize = 24
MinBtn.Font = Enum.Font.Gotham

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Parent = MainFrame
Sidebar.BackgroundColor3 = Theme.Sidebar
Sidebar.Position = UDim2.new(0, 0, 0, 40)
Sidebar.Size = UDim2.new(0, 150, 1, -40)
Sidebar.BorderSizePixel = 0

local SidebarLayout = Instance.new("UIListLayout")
SidebarLayout.Parent = Sidebar
SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
SidebarLayout.Padding = UDim.new(0, 5)

local SidebarPadding = Instance.new("UIPadding")
SidebarPadding.Parent = Sidebar
SidebarPadding.PaddingTop = UDim.new(0, 10)
SidebarPadding.PaddingLeft = UDim.new(0, 10)
SidebarPadding.PaddingRight = UDim.new(0, 10)

-- Content Container
local ContentContainer = Instance.new("Frame")
ContentContainer.Name = "ContentContainer"
ContentContainer.Parent = MainFrame
ContentContainer.BackgroundTransparency = 1
ContentContainer.Position = UDim2.new(0, 150, 0, 40)
ContentContainer.Size = UDim2.new(1, -150, 1, -40)

local Pages = {}
local TabButtons = {}

-- Helper: Create Page
local function CreatePage(name)
    local Page = Instance.new("ScrollingFrame")
    Page.Name = name
    Page.Parent = ContentContainer
    Page.BackgroundTransparency = 1
    Page.Size = UDim2.new(1, 0, 1, 0)
    Page.ScrollBarThickness = 2
    Page.ScrollBarImageColor3 = Theme.Accent
    Page.Visible = false
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    
    local PageLayout = Instance.new("UIListLayout")
    PageLayout.Parent = Page
    PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PageLayout.Padding = UDim.new(0, 8)
    
    local PagePadding = Instance.new("UIPadding")
    PagePadding.Parent = Page
    PagePadding.PaddingTop = UDim.new(0, 15)
    PagePadding.PaddingBottom = UDim.new(0, 15)
    PagePadding.PaddingLeft = UDim.new(0, 15)
    PagePadding.PaddingRight = UDim.new(0, 15)
    
    Pages[name] = Page
    return Page
end

-- Helper: Create Sidebar Button
local function CreateTabButton(name, icon, order)
    local Btn = Instance.new("TextButton")
    Btn.Name = name .. "Tab"
    Btn.Parent = Sidebar
    Btn.BackgroundColor3 = Theme.Panel
    Btn.BackgroundTransparency = 1
    Btn.Size = UDim2.new(1, 0, 0, 35)
    Btn.Text = "   " .. name
    Btn.TextColor3 = Theme.TextMuted
    Btn.TextSize = 14
    Btn.Font = Enum.Font.GothamMedium
    Btn.TextXAlignment = Enum.TextXAlignment.Left
    Btn.LayoutOrder = order
    MakeCorner(Btn, UDim.new(0, 6))
    
    TabButtons[name] = Btn
    
    Btn.MouseButton1Click:Connect(function()
        for pageName, pageFrame in pairs(Pages) do
            pageFrame.Visible = (pageName == name)
        end
        for btnName, btnFrame in pairs(TabButtons) do
            if btnName == name then
                TweenService:Create(btnFrame, TInfo, {BackgroundTransparency = 0, TextColor3 = Theme.TextMain}):Play()
            else
                TweenService:Create(btnFrame, TInfo, {BackgroundTransparency = 1, TextColor3 = Theme.TextMuted}):Play()
            end
        end
    end)
    return Btn
end

-- Helper: Create UI Block
local function CreateActionBlock(parentPage, titleText, descText, buttonText, callback)
    local Block = Instance.new("Frame")
    Block.Parent = parentPage
    Block.BackgroundColor3 = Theme.Panel
    Block.Size = UDim2.new(1, 0, 0, 60)
    MakeCorner(Block)
    
    local TitleLbl = Instance.new("TextLabel")
    TitleLbl.Parent = Block
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Position = UDim2.new(0, 15, 0, 10)
    TitleLbl.Size = UDim2.new(0.7, 0, 0, 20)
    TitleLbl.Text = titleText
    TitleLbl.TextColor3 = Theme.TextMain
    TitleLbl.TextSize = 14
    TitleLbl.Font = Enum.Font.GothamBold
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
    
    local DescLbl = Instance.new("TextLabel")
    DescLbl.Parent = Block
    DescLbl.BackgroundTransparency = 1
    DescLbl.Position = UDim2.new(0, 15, 0, 30)
    DescLbl.Size = UDim2.new(0.7, 0, 0, 20)
    DescLbl.Text = descText
    DescLbl.TextColor3 = Theme.TextMuted
    DescLbl.TextSize = 12
    DescLbl.Font = Enum.Font.Gotham
    DescLbl.TextXAlignment = Enum.TextXAlignment.Left
    
    local ActionBtn = Instance.new("TextButton")
    ActionBtn.Parent = Block
    ActionBtn.BackgroundColor3 = Theme.Topbar
    ActionBtn.Position = UDim2.new(1, -110, 0, 15)
    ActionBtn.Size = UDim2.new(0, 95, 0, 30)
    ActionBtn.Text = buttonText
    ActionBtn.TextColor3 = Theme.TextMain
    ActionBtn.TextSize = 12
    ActionBtn.Font = Enum.Font.GothamBold
    MakeCorner(ActionBtn, UDim.new(0, 6))
    ApplyHover(ActionBtn, Theme.Topbar, Theme.Accent)
    
    if callback then
        ActionBtn.MouseButton1Click:Connect(callback)
    end
    
    return ActionBtn
end

-- Helper: Create Toggle Block
local function CreateToggleBlock(parentPage, id, titleText, descText, defaultState)
    local Block = Instance.new("Frame")
    Block.Parent = parentPage
    Block.BackgroundColor3 = Theme.Panel
    Block.Size = UDim2.new(1, 0, 0, 60)
    MakeCorner(Block)
    
    local TitleLbl = Instance.new("TextLabel")
    TitleLbl.Parent = Block
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Position = UDim2.new(0, 15, 0, 10)
    TitleLbl.Size = UDim2.new(0.7, 0, 0, 20)
    TitleLbl.Text = titleText
    TitleLbl.TextColor3 = Theme.TextMain
    TitleLbl.TextSize = 14
    TitleLbl.Font = Enum.Font.GothamBold
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
    
    local DescLbl = Instance.new("TextLabel")
    DescLbl.Parent = Block
    DescLbl.BackgroundTransparency = 1
    DescLbl.Position = UDim2.new(0, 15, 0, 30)
    DescLbl.Size = UDim2.new(0.7, 0, 0, 20)
    DescLbl.Text = descText
    DescLbl.TextColor3 = Theme.TextMuted
    DescLbl.TextSize = 12
    DescLbl.Font = Enum.Font.Gotham
    DescLbl.TextXAlignment = Enum.TextXAlignment.Left
    
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Parent = Block
    ToggleBtn.BackgroundColor3 = defaultState and Theme.Accent or Theme.Topbar
    ToggleBtn.Position = UDim2.new(1, -55, 0, 15)
    ToggleBtn.Size = UDim2.new(0, 40, 0, 30)
    ToggleBtn.Text = defaultState and "ON" or "OFF"
    ToggleBtn.TextColor3 = Theme.TextMain
    ToggleBtn.TextSize = 12
    ToggleBtn.Font = Enum.Font.GothamBold
    MakeCorner(ToggleBtn, UDim.new(0, 6))
    
    Toggles[id] = defaultState
    
    ToggleBtn.MouseButton1Click:Connect(function()
        Toggles[id] = not Toggles[id]
        if Toggles[id] then
            TweenService:Create(ToggleBtn, TInfo, {BackgroundColor3 = Theme.Accent}):Play()
            ToggleBtn.Text = "ON"
        else
            TweenService:Create(ToggleBtn, TInfo, {BackgroundColor3 = Theme.Topbar}):Play()
            ToggleBtn.Text = "OFF"
        end
    end)
end

-- Initialize Pages and Tabs
local PageHome = CreatePage("Home")
local PageUtils = CreatePage("Utilities")
local PageDecomp = CreatePage("Decompiler")

CreateTabButton("Home", "", 1)
CreateTabButton("Utilities", "", 2)
CreateTabButton("Decompiler", "", 3)

-- === HOME PAGE CONTENT ===
local WelcomeLbl = Instance.new("TextLabel")
WelcomeLbl.Parent = PageHome
WelcomeLbl.BackgroundTransparency = 1
WelcomeLbl.Size = UDim2.new(1, 0, 0, 40)
WelcomeLbl.Text = "Welcome to MxDcmp"
WelcomeLbl.TextColor3 = Theme.TextMain
WelcomeLbl.TextSize = 22
WelcomeLbl.Font = Enum.Font.GothamBold
WelcomeLbl.TextXAlignment = Enum.TextXAlignment.Left

local StatusLbl = Instance.new("TextLabel")
StatusLbl.Parent = PageHome
StatusLbl.BackgroundTransparency = 1
StatusLbl.Size = UDim2.new(1, 0, 0, 20)
StatusLbl.Text = "System Status: Online | Executor Ready"
StatusLbl.TextColor3 = Theme.Success
StatusLbl.TextSize = 14
StatusLbl.Font = Enum.Font.Gotham
StatusLbl.TextXAlignment = Enum.TextXAlignment.Left

-- === UTILITIES PAGE CONTENT ===
CreateActionBlock(PageUtils, "Dex Explorer", "Manage and inspect instances locally.", "Launch", function()
    print("Launching Dex...")
end)

CreateActionBlock(PageUtils, "Rig15 Conversion", "Set the desired player's rig type to R15.", "Convert", function()
    print("Converting Rig...")
end)

CreateActionBlock(PageUtils, "Fling Target", "Send targets out of bounds.", "Execute", function()
    print("Flinging...")
end)

CreateActionBlock(PageUtils, "TitleAction Event Hook", "Verify Server-Side security pipelines via TitleAction.", "Test Event", function()
    print("Hooking TitleAction remote...")
end)

CreateActionBlock(PageUtils, "Input Debugger", "Log L1, L2, R2 trigger data for cross-platform support.", "Enable", function()
    print("Logging cross-platform inputs...")
end)


-- === DECOMPILER PAGE CONTENT ===
local DecompHeader = Instance.new("TextLabel")
DecompHeader.Parent = PageDecomp
DecompHeader.BackgroundTransparency = 1
DecompHeader.Size = UDim2.new(1, 0, 0, 30)
DecompHeader.Text = "SaveInstance Configuration"
DecompHeader.TextColor3 = Theme.TextMain
DecompHeader.TextSize = 18
DecompHeader.Font = Enum.Font.GothamBold
DecompHeader.TextXAlignment = Enum.TextXAlignment.Left

CreateToggleBlock(PageDecomp, "Decompile", "Decompile Scripts", "Enables the internal luau decompiler.", true)
CreateToggleBlock(PageDecomp, "NilInstances", "Nil Instances", "Scans memory for hidden unparented objects.", true)
CreateToggleBlock(PageDecomp, "SaveBytecode", "Save Bytecode", "Captures raw Luau VM instructions.", true)
CreateToggleBlock(PageDecomp, "IsolatePlayer", "Isolate Player", "Removes local runtime clutter.", true)
CreateToggleBlock(PageDecomp, "DisableStarterPlayerScripts", "Disable LocalScripts", "Prevents crashes when testing in Studio.", true)
CreateToggleBlock(PageDecomp, "DisableLightInfluence", "Disable Lighting", "Removes atmosphere and blur for map clarity.", true)

local ExecuteBtn = Instance.new("TextButton")
ExecuteBtn.Parent = PageDecomp
ExecuteBtn.BackgroundColor3 = Theme.Accent
ExecuteBtn.Size = UDim2.new(1, 0, 0, 45)
ExecuteBtn.Text = "Run SaveInstance"
ExecuteBtn.TextColor3 = Theme.TextMain
ExecuteBtn.TextSize = 16
ExecuteBtn.Font = Enum.Font.GothamBold
MakeCorner(ExecuteBtn, UDim.new(0, 8))
ApplyHover(ExecuteBtn, Theme.Accent, Theme.AccentHover)

Elements.ExecuteBtn = ExecuteBtn

-- Logic: Window Dragging
local dragging, dragInput, dragStart, startPos

Topbar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Topbar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Logic: Minimize and Close
CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

MinBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    OpenTab.Visible = true
end)

OpenTab.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    OpenTab.Visible = false
end)

-- Initialize Default Tab
TabButtons["Home"]:Fire()

-- Engine Link Methods
function UI.GetConfigs()
    return {
        mode = "full",
        SafeMode = true,
        ShowStatus = true,
        SaveCacheInterval = 3000,
        FilePath = "MxDcmp_Dump",
        Decompile = Toggles["Decompile"],
        DecompileTimeout = 15,
        SaveBytecode = Toggles["SaveBytecode"],
        scriptcache = true,
        NilInstances = Toggles["NilInstances"],
        SaveNotCreatable = true,
        SavePlayers = false,
        SavePlayerCharacters = false,
        IsolatePlayer = Toggles["IsolatePlayer"],
        DisableStarterPlayerScripts = Toggles["DisableStarterPlayerScripts"],
        DisableLightInfluence = Toggles["DisableLightInfluence"],
        Ignore = {
            "Players",
            "PlayerGui",
            "CoreGui",
            "CorePackages",
            "Chat",
            "SoundService",
            "Teams"
        }
    }
end

UI.Elements = Elements
return UI
