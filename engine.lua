-- MxDcmp Engine Module
-- Handles the execution logic and external library fetching.

local Engine = {}

-- === CORE: SaveInstance Logic ===
function Engine.RunSave(settings)
    print("[MxDcmp Engine] Initializing SaveInstance...")
    
    -- We use a pcall here so if the GitHub URL is down or your executor 
    -- blocks HttpGet, it won't crash your entire game.
    local success, synsaveinstance = pcall(function()
        local url = "https://raw.githubusercontent.com/luau/UniversalSynSaveInstance/main/saveinstance.luau"
        return loadstring(game:HttpGet(url, true))()
    end)
    
    if success and type(synsaveinstance) == "function" then
        print("[MxDcmp Engine] UniversalSynSaveInstance loaded successfully. Starting environment dump...")
        
        -- Execute the dumping process with the settings passed from the UI
        synsaveinstance(settings)
        
        print("[MxDcmp Engine] Dump sequence initiated. Check your executor's workspace folder.")
    else
        warn("[MxDcmp Engine] Failed to fetch or load the SaveInstance library.")
        if type(synsaveinstance) == "string" then
            warn("Error Output: " .. synsaveinstance)
        end
    end
end

-- === UTILITIES: Framework Stubs ===
-- These functions match the buttons on your Utilities UI page. 
-- You can replace the print statements with the actual execution code later.

function Engine.LaunchDex()
    print("[MxDcmp Engine] Launching Dex Explorer...")
    -- Example: loadstring(game:HttpGet("dex_url_here"))()
end

function Engine.ConvertRig()
    print("[MxDcmp Engine] Initiating Rig15 conversion...")
    -- Insert your R15 conversion logic here
end

function Engine.FlingTarget()
    print("[MxDcmp Engine] Fling module activated.")
    -- Insert your fling physics logic here
end

function Engine.TestTitleAction()
    print("[MxDcmp Engine] Hooking into TitleAction remote event for pipeline testing...")
    -- Insert your server-side validation testing script here
end

function Engine.LogCrossPlatformInputs()
    print("[MxDcmp Engine] Input logger active. Listening for L1, L2, R2...")
    -- Insert your Gamepad/Console input monitoring logic here
end

return Engine
