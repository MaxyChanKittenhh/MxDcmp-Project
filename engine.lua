local Engine = {}

function Engine.RunSave(Settings)
    print("[MxDcmp] Engine starting SaveInstance...")

    -- Your exact requested parameters
    local Params = {
        RepoURL = "https://raw.githubusercontent.com/luau/UniversalSynSaveInstance/main/",
        SSI = "saveinstance",
    }

    -- Loading UniversalSynSaveInstance exactly as requested
    local synsaveinstance = loadstring(game:HttpGet(Params.RepoURL .. Params.SSI .. ".luau", true), Params.SSI)()

    -- Executing with the settings pulled directly from your UI
    synsaveinstance({
        mode = Settings.mode,          
        Decompile = Settings.Decompile,         
        DecompileTimeout = Settings.DecompileTimeout,      
        scriptcache = Settings.scriptcache,
        SafeMode = Settings.SafeMode,          
        FilePath = Settings.FilePath,    
        NilInstances = Settings.NilInstances,   
    })
    
    print("[MxDcmp] SaveInstance executed successfully. Check your workspace folder.")
end

return Engine

return Engine
