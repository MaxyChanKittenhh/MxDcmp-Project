-- MxDcmp Master Loader
local GitHubUser = "MaxyChanKittenhh" 
local RepoName = "MxDcmp-Project"
local Branch = "main"

local BaseURL = string.format("https://raw.githubusercontent.com/%s/%s/%s/", GitHubUser, RepoName, Branch)

-- Cache-Buster: Forces the executor to download the newest version of your files
local CacheBust = "?t=" .. tostring(os.time())

print("[MxDcmp] Fetching modules from GitHub...")

-- Fetch the UI and Engine files safely
local ui_success, ui_code = pcall(game.HttpGet, game, BaseURL .. "ui.lua" .. CacheBust)
local engine_success, engine_code = pcall(game.HttpGet, game, BaseURL .. "engine.lua" .. CacheBust)

if ui_success and engine_success then
    print("[MxDcmp] Modules downloaded. Compiling framework...")
    
    -- Load the raw strings into executable functions and run them
    local UI = loadstring(ui_code)()
    local Engine = loadstring(engine_code)()
    
    if UI and Engine then
        -- Link the UI Execute Button to the Engine Save Logic
        UI.Elements.ExecuteBtn.MouseButton1Click:Connect(function()
            -- Visual feedback on the button
            UI.Elements.ExecuteBtn.Text = "Saving... Check Console"
            
            -- Fetch settings from the toggles in your UI
            local currentSettings = UI.GetConfigs()
            
            -- Send those settings into the engine to begin the map dump
            Engine.RunSave(currentSettings)
            
            -- Reset the button text after 2 seconds
            task.wait(2)
            UI.Elements.ExecuteBtn.Text = "Run SaveInstance"
        end)
        
        print("[MxDcmp] UI and Engine successfully linked. Ready to use.")
    else
        warn("[MxDcmp] Modules loaded, but failed to return their tables. Check your ui.lua and engine.lua syntax.")
    end
else
    warn("[MxDcmp] CRITICAL ERROR: Failed to fetch files from GitHub.")
    warn("Make sure your repository is Public.")
    if not ui_success then warn("UI Fetch Error: " .. tostring(ui_code)) end
    if not engine_success then warn("Engine Fetch Error: " .. tostring(engine_code)) end
end
