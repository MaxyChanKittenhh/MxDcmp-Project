--[=[
    @class MX_Framework
    @author MX Hub Development
    @description Enterprise-grade utility framework featuring an Object-Oriented UI library, 
                 state management, configuration serialization, and bypass engines.
]=]

-- ==============================================================================
-- 1. SERVICE ACQUISITION & ENVIRONMENT SETUP
-- ==============================================================================
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Environment Safety
local GET_ASSET = getsynasset or getcustomasset or function() return "" end
local REQUEST = request or http_request or (syn and syn.request) or function() return {} end
local HAS_FILE_SYSTEM = isfile and writefile and readfile and makefolder

-- Clean previous instances securely
local existingUI = CoreGui:FindFirstChild("MX_Enterprise_Engine")
if existingUI then
    existingUI:Destroy()
end

-- ==============================================================================
-- 2. UTILITY & MATH MODULE
-- ==============================================================================
local Utility = {}

function Utility:CreateTween(instance, properties, duration, style, direction)
    local tweenInfo = TweenInfo.new(
        duration or 0.3,
        style or Enum.EasingStyle.Sine,
        direction or Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

function Utility:CalculateSliderMath(input, frame, min, max)
    local absolutePosition = frame.AbsolutePosition.X
    local absoluteSize = frame.AbsoluteSize.X
    local inputPosition = input.Position.X
    
    local percentage = math.clamp((inputPosition - absolutePosition) / absoluteSize, 0, 1)
    local value = min + ((max - min) * percentage)
    
    return percentage, math.floor(value * 10) / 10
end

function Utility:DeepCopy(original)
    local copy = {}
    for k, v in pairs(original) do
        if type(v) == "table" then
            v = Utility:DeepCopy(v)
        end
        copy[k] = v
    end
    return copy
end

-- ==============================================================================
-- 3. STATE & CONFIGURATION MANAGER
-- ==============================================================================
local StateManager = {
    Flags = {},
    Connections = {},
    Theme = {
        Background = Color3.fromRGB(15, 15, 18),
        Surface = Color3.fromRGB(22, 22, 26),
        SurfaceLight = Color3.fromRGB(30, 30, 35),
        Accent = Color3.fromRGB(110, 150, 255),
        AccentHover = Color3.fromRGB(130, 170, 255),
        TextPrimary = Color3.fromRGB(240, 240, 240),
        TextSecondary = Color3.fromRGB(160, 160, 160),
        Border = Color3.fromRGB(40, 40, 45)
    },
    ConfigFolder = "MX_Framework",
    ConfigFile = "profiles.json"
}

function StateManager:SetFlag(flag, value)
    self.Flags[flag] = value
end

function StateManager:GetFlag(flag)
    return self.Flags[flag]
end

function StateManager:BindConnection(name, connection)
    if self.Connections[name] then
        self.Connections[name]:Disconnect()
    end
    self.Connections[name] = connection
end

function StateManager:SaveConfig()
    if not HAS_FILE_SYSTEM then return end
    if not isfolder(self.ConfigFolder) then
        makefolder(self.ConfigFolder)
    end
    local success, encoded = pcall(function()
        return HttpService:JSONEncode(self.Flags)
    end)
    if success then
        writefile(self.ConfigFolder .. "/" .. self.ConfigFile, encoded)
    end
end

-- ==============================================================================
-- 4. OBJECT-ORIENTED UI FRAMEWORK
-- ==============================================================================
local Library = {
    Instances = {},
    ActiveWindow = nil
}

function Library:CreateWindow(config)
    local title = config.Title or "MX Framework"
    local size = config.Size or UDim2.new(0, 750, 0, 500)
    
    local Window = {
        Tabs = {},
        CurrentTab = nil
    }
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MX_Enterprise_Engine"
    ScreenGui.Parent = CoreGui
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.Size = size
    MainFrame.Position = UDim2.new(0.5, -size.X.Offset/2, 0.5, -size.Y.Offset/2)
    MainFrame.BackgroundColor3 = StateManager.Theme.Background
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = MainFrame
    
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = StateManager.Theme.Border
    UIStroke.Thickness = 1
    UIStroke.Parent = MainFrame
    
    -- Title Bar
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Parent = MainFrame
    TopBar.Size = UDim2.new(1, 0, 0, 45)
    TopBar.BackgroundTransparency = 1
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Parent = TopBar
    TitleLabel.Size = UDim2.new(1, -20, 1, 0)
    TitleLabel.Position = UDim2.new(0, 20, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title
    TitleLabel.TextColor3 = StateManager.Theme.TextPrimary
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 14
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local TopDivider = Instance.new("Frame")
    TopDivider.Parent = TopBar
    TopDivider.Size = UDim2.new(1, 0, 0, 1)
    TopDivider.Position = UDim2.new(0, 0, 1, -1)
    TopDivider.BackgroundColor3 = StateManager.Theme.Border
    TopDivider.BorderSizePixel = 0
    
    -- Sidebar (Navigation)
    local Sidebar = Instance.new("Frame")
    Sidebar.Parent = MainFrame
    Sidebar.Size = UDim2.new(0, 180, 1, -45)
    Sidebar.Position = UDim2.new(0, 0, 0, 45)
    Sidebar.BackgroundColor3 = StateManager.Theme.Surface
    Sidebar.BorderSizePixel = 0
    
    local SidebarDivider = Instance.new("Frame")
    SidebarDivider.Parent = Sidebar
    SidebarDivider.Size = UDim2.new(0, 1, 1, 0)
    SidebarDivider.Position = UDim2.new(1, -1, 0, 0)
    SidebarDivider.BackgroundColor3 = StateManager.Theme.Border
    SidebarDivider.BorderSizePixel = 0
    
    local TabList = Instance.new("ScrollingFrame")
    TabList.Parent = Sidebar
    TabList.Size = UDim2.new(1, 0, 1, 0)
    TabList.BackgroundTransparency = 1
    TabList.ScrollBarThickness = 2
    TabList.ScrollBarImageColor3 = StateManager.Theme.Border
    TabList.BorderSizePixel = 0
    
    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Parent = TabList
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Padding = UDim.new(0, 4)
    
    local TabPadding = Instance.new("UIPadding")
    TabPadding.Parent = TabList
    TabPadding.PaddingTop = UDim.new(0, 10)
    TabPadding.PaddingLeft = UDim.new(0, 10)
    TabPadding.PaddingRight = UDim.new(0, 10)
    
    -- Pages Container
    local PageContainer = Instance.new("Frame")
    PageContainer.Parent = MainFrame
    PageContainer.Size = UDim2.new(1, -180, 1, -45)
    PageContainer.Position = UDim2.new(0, 180, 0, 45)
    PageContainer.BackgroundTransparency = 1
    
    -- Dragging Logic
    local dragging, dragInput, dragStart, startPos
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    TopBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    -- Keyboard & Gamepad Toggles
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed then
            if input.KeyCode == Enum.KeyCode.RightShift or input.KeyCode == Enum.KeyCode.ButtonSelect then
                ScreenGui.Enabled = not ScreenGui.Enabled
            end
            
            -- Gamepad Tab Navigation
            if ScreenGui.Enabled and #Window.Tabs > 1 then
                if input.KeyCode == Enum.KeyCode.ButtonL1 or input.KeyCode == Enum.KeyCode.ButtonR1 then
                    local currentIndex = 1
                    for i, tab in ipairs(Window.Tabs) do
                        if tab.Name == Window.CurrentTab.Name then currentIndex = i break end
                    end
                    
                    local newIndex = currentIndex
                    if input.KeyCode == Enum.KeyCode.ButtonR1 then
                        newIndex = (currentIndex % #Window.Tabs) + 1
                    elseif input.KeyCode == Enum.KeyCode.ButtonL1 then
                        newIndex = currentIndex - 1
                        if newIndex < 1 then newIndex = #Window.Tabs end
                    end
                    Window.Tabs[newIndex]:Select()
                end
            end
        end
    end)

    function Window:CreateTab(name)
        local Tab = {Name = name, Elements = {}}
        
        local TabButton = Instance.new("TextButton")
        TabButton.Parent = TabList
        TabButton.Size = UDim2.new(1, 0, 0, 36)
        TabButton.BackgroundColor3 = StateManager.Theme.SurfaceLight
        TabButton.BackgroundTransparency = 1
        TabButton.Text = "   " .. name
        TabButton.TextColor3 = StateManager.Theme.TextSecondary
        TabButton.Font = Enum.Font.GothamMedium
        TabButton.TextSize = 13
        TabButton.TextXAlignment = Enum.TextXAlignment.Left
        TabButton.AutoButtonColor = false
        
        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 6)
        TabCorner.Parent = TabButton
        
        local Page = Instance.new("ScrollingFrame")
        Page.Parent = PageContainer
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 2
        Page.ScrollBarImageColor3 = StateManager.Theme.Border
        Page.Visible = false
        Page.BorderSizePixel = 0
        
        local PageLayout = Instance.new("UIListLayout")
        PageLayout.Parent = Page
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Padding = UDim.new(0, 8)
        
        local PagePadding = Instance.new("UIPadding")
        PagePadding.Parent = Page
        PagePadding.PaddingTop = UDim.new(0, 15)
        PagePadding.PaddingLeft = UDim.new(0, 15)
        PagePadding.PaddingRight = UDim.new(0, 15)
        PagePadding.PaddingBottom = UDim.new(0, 15)
        
        function Tab:Select()
            if Window.CurrentTab then
                Utility:CreateTween(Window.CurrentTab.Button, {BackgroundTransparency = 1, TextColor3 = StateManager.Theme.TextSecondary}, 0.2)
                Window.CurrentTab.Page.Visible = false
            end
            Window.CurrentTab = self
            Utility:CreateTween(TabButton, {BackgroundTransparency = 0, TextColor3 = StateManager.Theme.TextPrimary}, 0.2)
            Page.Visible = true
        end
        
        TabButton.MouseButton1Click:Connect(function() Tab:Select() end)
        
        -- Form Elements
        function Tab:CreateToggle(options)
            local flag = options.Flag or options.Name
            local default = options.Default or false
            local callback = options.Callback or function() end
            
            StateManager:SetFlag(flag, default)
            
            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Parent = Page
            ToggleFrame.Size = UDim2.new(1, 0, 0, 42)
            ToggleFrame.BackgroundColor3 = StateManager.Theme.Surface
            
            local TCorner = Instance.new("UICorner")
            TCorner.CornerRadius = UDim.new(0, 6)
            TCorner.Parent = ToggleFrame
            
            local TStroke = Instance.new("UIStroke")
            TStroke.Color = StateManager.Theme.Border
            TStroke.Parent = ToggleFrame
            
            local Label = Instance.new("TextLabel")
            Label.Parent = ToggleFrame
            Label.Size = UDim2.new(1, -70, 1, 0)
            Label.Position = UDim2.new(0, 15, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = options.Name
            Label.TextColor3 = StateManager.Theme.TextPrimary
            Label.Font = Enum.Font.GothamMedium
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left
            
            local Switch = Instance.new("TextButton")
            Switch.Parent = ToggleFrame
            Switch.Size = UDim2.new(0, 40, 0, 20)
            Switch.Position = UDim2.new(1, -55, 0.5, -10)
            Switch.BackgroundColor3 = default and StateManager.Theme.Accent or StateManager.Theme.SurfaceLight
            Switch.Text = ""
            Switch.AutoButtonColor = false
            
            local SCorner = Instance.new("UICorner")
            SCorner.CornerRadius = UDim.new(1, 0)
            SCorner.Parent = Switch
            
            local Indicator = Instance.new("Frame")
            Indicator.Parent = Switch
            Indicator.Size = UDim2.new(0, 16, 0, 16)
            Indicator.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            Indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            
            local ICorner = Instance.new("UICorner")
            ICorner.CornerRadius = UDim.new(1, 0)
            ICorner.Parent = Indicator
            
            local function Fire()
                local currentState = StateManager:GetFlag(flag)
                local newState = not currentState
                StateManager:SetFlag(flag, newState)
                
                Utility:CreateTween(Switch, {BackgroundColor3 = newState and StateManager.Theme.Accent or StateManager.Theme.SurfaceLight}, 0.2)
                Utility:CreateTween(Indicator, {Position = newState and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}, 0.3, Enum.EasingStyle.Back)
                
                task.spawn(callback, newState)
            end
            
            Switch.MouseButton1Click:Connect(Fire)
            
            -- Gamepad trigger execute
            Switch.InputBegan:Connect(function(input)
                if input.KeyCode == Enum.KeyCode.ButtonR2 then Fire() end
            end)
            
            if default then task.spawn(callback, default) end
        end
        
        function Tab:CreateSlider(options)
            local flag = options.Flag or options.Name
            local min = options.Min or 0
            local max = options.Max or 100
            local default = options.Default or min
            local callback = options.Callback or function() end
            
            StateManager:SetFlag(flag, default)
            
            local SliderFrame = Instance.new("Frame")
            SliderFrame.Parent = Page
            SliderFrame.Size = UDim2.new(1, 0, 0, 55)
            SliderFrame.BackgroundColor3 = StateManager.Theme.Surface
            
            local SCorner = Instance.new("UICorner")
            SCorner.CornerRadius = UDim.new(0, 6)
            SCorner.Parent = SliderFrame
            Instance.new("UIStroke", SliderFrame).Color = StateManager.Theme.Border
            
            local Label = Instance.new("TextLabel")
            Label.Parent = SliderFrame
            Label.Size = UDim2.new(1, -20, 0, 25)
            Label.Position = UDim2.new(0, 15, 0, 5)
            Label.BackgroundTransparency = 1
            Label.Text = options.Name
            Label.TextColor3 = StateManager.Theme.TextPrimary
            Label.Font = Enum.Font.GothamMedium
            Label.TextSize = 13
            Label.TextXAlignment = Enum.TextXAlignment.Left
            
            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.Parent = SliderFrame
            ValueLabel.Size = UDim2.new(0, 50, 0, 25)
            ValueLabel.Position = UDim2.new(1, -65, 0, 5)
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.Text = tostring(default)
            ValueLabel.TextColor3 = StateManager.Theme.TextSecondary
            ValueLabel.Font = Enum.Font.GothamMedium
            ValueLabel.TextSize = 13
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
            
            local Track = Instance.new("TextButton")
            Track.Parent = SliderFrame
            Track.Size = UDim2.new(1, -30, 0, 6)
            Track.Position = UDim2.new(0, 15, 0, 35)
            Track.BackgroundColor3 = StateManager.Theme.SurfaceLight
            Track.Text = ""
            Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)
            
            local Fill = Instance.new("Frame")
            Fill.Parent = Track
            Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            Fill.BackgroundColor3 = StateManager.Theme.Accent
            Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)
            
            local dragging = false
            local function Update(input)
                local pct, val = Utility:CalculateSliderMath(input, Track, min, max)
                Fill.Size = UDim2.new(pct, 0, 1, 0)
                ValueLabel.Text = tostring(val)
                StateManager:SetFlag(flag, val)
                callback(val)
            end
            
            Track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true Update(input)
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    Update(input)
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)
        end
        
        function Tab:CreateButton(options)
            local ButtonFrame = Instance.new("TextButton")
            ButtonFrame.Parent = Page
            ButtonFrame.Size = UDim2.new(1, 0, 0, 42)
            ButtonFrame.BackgroundColor3 = StateManager.Theme.Surface
            ButtonFrame.Text = options.Name
            ButtonFrame.TextColor3 = StateManager.Theme.TextPrimary
            ButtonFrame.Font = Enum.Font.GothamMedium
            ButtonFrame.TextSize = 13
            ButtonFrame.AutoButtonColor = false
            
            Instance.new("UICorner", ButtonFrame).CornerRadius = UDim.new(0, 6)
            local stroke = Instance.new("UIStroke", ButtonFrame)
            stroke.Color = StateManager.Theme.Border
            
            ButtonFrame.MouseEnter:Connect(function()
                Utility:CreateTween(ButtonFrame, {BackgroundColor3 = StateManager.Theme.SurfaceLight}, 0.2)
            end)
            ButtonFrame.MouseLeave:Connect(function()
                Utility:CreateTween(ButtonFrame, {BackgroundColor3 = StateManager.Theme.Surface}, 0.2)
            end)
            
            local function Fire()
                local clickAnim = Instance.new("Frame")
                clickAnim.Parent = ButtonFrame
                clickAnim.BackgroundColor3 = StateManager.Theme.Accent
                clickAnim.Size = UDim2.new(0, 0, 1, 0)
                clickAnim.Position = UDim2.new(0.5, 0, 0, 0)
                clickAnim.AnchorPoint = Vector2.new(0.5, 0)
                clickAnim.BorderSizePixel = 0
                Instance.new("UICorner", clickAnim).CornerRadius = UDim.new(0, 6)
                
                local tween = Utility:CreateTween(clickAnim, {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1}, 0.4)
                tween.Completed:Connect(function() clickAnim:Destroy() end)
                
                task.spawn(options.Callback)
            end
            
            ButtonFrame.MouseButton1Click:Connect(Fire)
            
            ButtonFrame.InputBegan:Connect(function(input)
                if input.KeyCode == Enum.KeyCode.ButtonR2 or input.KeyCode == Enum.KeyCode.ButtonA then Fire() end
            end)
        end

        Tab.Button = TabButton
        Tab.Page = Page
        table.insert(Window.Tabs, Tab)
        
        if #Window.Tabs == 1 then Tab:Select() end
        return Tab
    end
    
    return Window
end

-- ==============================================================================
-- 5. INITIALIZATION & FEATURE MODULES
-- ==============================================================================

local Window = Library:CreateWindow({
    Title = "MX Enterprise Engine",
    Size = UDim2.new(0, 780, 0, 520)
})

-- ---------------------------------------------------------
-- MODULE: ADVANCED MOVEMENT (CFRAME & VELOCITY ENGINES)
-- ---------------------------------------------------------
local Movement = Window:CreateTab("Movement Systems")

Movement:CreateToggle({
    Name = "Vector Translation (TP Walk)",
    Flag = "Move_TPWalk",
    Callback = function(state)
        if state then
            StateManager:BindConnection("TPWalk", RunService.RenderStepped:Connect(function()
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if root and hum and hum.MoveDirection.Magnitude > 0 then
                    local speed = StateManager:GetFlag("Move_TPWalkSpeed") or 3
                    root.CFrame = root.CFrame + (hum.MoveDirection * (speed / 10))
                end
            end))
        else
            if StateManager.Connections["TPWalk"] then StateManager.Connections["TPWalk"]:Disconnect() end
        end
    end
})

Movement:CreateSlider({
    Name = "Translation Multiplier",
    Flag = "Move_TPWalkSpeed",
    Min = 1, Max = 20, Default = 3
})

Movement:CreateToggle({
    Name = "Absolute CFrame Flight",
    Flag = "Move_Fly",
    Callback = function(state)
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        
        if state then
            if hum then hum.PlatformStand = true end
            StateManager:BindConnection("CFrameFly", RunService.RenderStepped:Connect(function()
                char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if not root then return end
                
                local moveDir = Vector3.new(0, 0, 0)
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - Camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - Camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Camera.CFrame.RightVector end
                
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0, 1, 0) end
                
                if moveDir.Magnitude > 0 then moveDir = moveDir.Unit end
                
                local speed = StateManager:GetFlag("Move_FlySpeed") or 5
                root.Velocity = Vector3.new(0, 0, 0)
                root.CFrame = root.CFrame + (moveDir * speed)
            end))
        else
            if StateManager.Connections["CFrameFly"] then StateManager.Connections["CFrameFly"]:Disconnect() end
            if hum then hum.PlatformStand = false end
        end
    end
})

Movement:CreateSlider({
    Name = "Flight Velocity Modifier",
    Flag = "Move_FlySpeed",
    Min = 1, Max = 30, Default = 5
})

Movement:CreateToggle({
    Name = "Unrestricted Jump Height (Inf Jump)",
    Flag = "Move_InfJump",
    Callback = function(state)
        if state then
            StateManager:BindConnection("InfJump", UserInputService.JumpRequest:Connect(function()
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end))
        else
            if StateManager.Connections["InfJump"] then StateManager.Connections["InfJump"]:Disconnect() end
        end
    end
})

-- ---------------------------------------------------------
-- MODULE: VISUAL EXTRAPOLATION (ESP)
-- ---------------------------------------------------------
local Visuals = Window:CreateTab("Visual Intelligence")
local ESP_Container = Instance.new("Folder", CoreGui)
ESP_Container.Name = "MX_RenderData"

Visuals:CreateToggle({
    Name = "Render Player Bounding Boxes (ESP)",
    Flag = "Vis_ESP",
    Callback = function(state)
        if state then
            StateManager:BindConnection("RenderESP", RunService.RenderStepped:Connect(function()
                for _, player in ipairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                        local char = player.Character
                        local root = char.HumanoidRootPart
                        local highlight = ESP_Container:FindFirstChild(player.Name)
                        
                        if not highlight then
                            highlight = Instance.new("Highlight")
                            highlight.Name = player.Name
                            highlight.Parent = ESP_Container
                            highlight.FillColor = Color3.fromRGB(255, 60, 60)
                            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                            highlight.FillTransparency = 0.5
                            highlight.OutlineTransparency = 0
                            
                            local bgui = Instance.new("BillboardGui", highlight)
                            bgui.Name = "Data"
                            bgui.Size = UDim2.new(0, 200, 0, 50)
                            bgui.StudsOffset = Vector3.new(0, 4, 0)
                            bgui.AlwaysOnTop = true
                            
                            local text = Instance.new("TextLabel", bgui)
                            text.Size = UDim2.new(1, 0, 1, 0)
                            text.BackgroundTransparency = 1
                            text.TextColor3 = Color3.fromRGB(255, 255, 255)
                            text.TextStrokeTransparency = 0
                            text.Font = Enum.Font.GothamBold
                            text.TextSize = 13
                        end
                        
                        highlight.Adornee = char
                        local dist = math.floor((Camera.CFrame.Position - root.Position).Magnitude)
                        highlight.Data.TextLabel.Text = string.format("%s\n[%d Studs]", player.DisplayName, dist)
                    end
                end
            end))
        else
            if StateManager.Connections["RenderESP"] then StateManager.Connections["RenderESP"]:Disconnect() end
            ESP_Container:ClearAllChildren()
        end
    end
})

-- ---------------------------------------------------------
-- MODULE: LOCAL ANIMATION PIPELINE
-- ---------------------------------------------------------
local Emotes = Window:CreateTab("Animation Engine")
local AnimController = { Track = nil, Assets = {
    {"Distraction Dance", "rbxassetid://6284699564"},
    {"Floss", "rbxassetid://5917459365"},
    {"Groove", "rbxassetid://5915712534"},
    {"Headless", "rbxassetid://3370603842"},
    {"Zombie", "rbxassetid://6161680369"}
}}

local function CleanAnimation()
    if AnimController.Track then
        AnimController.Track:Stop()
        AnimController.Track:Destroy()
        AnimController.Track = nil
    end
end

Emotes:CreateButton({
    Name = "[!] Terminate Running Animation",
    Callback = CleanAnimation
})

for _, emote in ipairs(AnimController.Assets) do
    Emotes:CreateButton({
        Name = "Play Asset: " .. emote[1],
        Callback = function()
            CleanAnimation()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                local animator = hum:FindFirstChildOfClass("Animator") or Instance.new("Animator", hum)
                local anim = Instance.new("Animation")
                anim.AnimationId = emote[2]
                local success, track = pcall(function() return animator:LoadAnimation(anim) end)
                if success then
                    AnimController.Track = track
                    AnimController.Track.Priority = Enum.AnimationPriority.Action4
                    AnimController.Track:Play()
                end
            end
        end
    })
end

-- ---------------------------------------------------------
-- MODULE: SERVER DEV & NETWORK EXPLOITATION
-- ---------------------------------------------------------
local Network = Window:CreateTab("Network Utilities")

Network:CreateButton({
    Name = "Server Hop (Bypass Server Locking)",
    Callback = function()
        local url = string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100", game.PlaceId)
        local success, result = pcall(function() return HttpService:JSONDecode(game:HttpGet(url)) end)
        if success and result and result.data then
            for _, server in ipairs(result.data) do
                if server.playing < server.maxPlayers and server.id ~= game.JobId then
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                    return
                end
            end
        end
    end
})

Network:CreateButton({
    Name = "Initialize Infinite Yield Command Line",
    Callback = function()
        task.spawn(function()
            loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
        end)
    end
})

Network:CreateButton({
    Name = "Verify Remote Validation (Anti-Cheat Ping)",
    Callback = function()
        -- Specifically looking for common remotes to test server side sanity checks
        local targets = {"TitleAction", "UpdateData", "AntiCheat", "Ban"}
        for _, name in ipairs(targets) do
            local remote = ReplicatedStorage:FindFirstChild(name, true)
            if remote and remote:IsA("RemoteEvent") then
                print("[MX Framework] Pinging server remote:", name)
                remote:FireServer("MX_PROBE")
            end
        end
    end
})

-- Handle GC
LocalPlayer.CharacterAdded:Connect(CleanAnimation)
