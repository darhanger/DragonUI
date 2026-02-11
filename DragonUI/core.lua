local addon = select(2, ...);

--[[
================================================================================
DragonUI - Core Initialization
================================================================================
This file handles the main addon initialization using AceAddon-3.0.
Utility functions have been moved to core/api.lua

Options are loaded on demand from DragonUI_Options addon (ElvUI pattern).
================================================================================
]]

-- Expose addon globally for DragonUI_Options to access
_G.DragonUI = addon

-- Create addon object using AceAddon
addon.core = LibStub("AceAddon-3.0"):NewAddon("DragonUI", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0");

-- Pre-define Options table (will be filled by DragonUI_Options)
addon.Options = { type = "group", name = "DragonUI", args = {} }

-- Track if options addon is loaded
addon.OptionsLoaded = false

function addon.core:OnInitialize()
    -- Replace the temporary addon.db with the real AceDB
    addon.db = LibStub("AceDB-3.0"):New("DragonUIDB", addon.defaults);

    -- Force defaults to be written to profile (check for specific key that should always exist)
    if not addon.db.profile.mainbars or not addon.db.profile.mainbars.scale_actionbar then
        -- Copy all defaults to profile to ensure they exist in SavedVariables
        addon.DeepCopy(addon.defaults.profile, addon.db.profile);
    end

    -- Register callbacks for configuration changes
    addon.db.RegisterCallback(addon, "OnProfileChanged", "RefreshConfig");
    addon.db.RegisterCallback(addon, "OnProfileCopied", "RefreshConfig");
    addon.db.RegisterCallback(addon, "OnProfileReset", "RefreshConfig");

    -- Apply current profile configuration immediately
    -- This ensures the profile is loaded when the addon starts
    addon:RefreshConfig();
end

function addon.core:OnEnable()
    -- Register slash commands (using new commands.lua system)
    if addon.LoadCommands then
        addon.LoadCommands()
    else
        -- Fallback to legacy registration
        self:RegisterChatCommand("dragonui", "SlashCommand")
        self:RegisterChatCommand("pi", "SlashCommand")
    end

    -- Fire custom event to signal that DragonUI is fully initialized
    -- This ensures modules get the correct config values
    self:SendMessage("DRAGONUI_READY");
end

-- ============================================================================
-- OPTIONS UI LOADING (ElvUI Pattern)
-- ============================================================================

function addon:ToggleOptionsUI(msg)
    if InCombatLockdown() then
        print("|cFFFF0000[DragonUI]|r Cannot open options in combat.")
        return
    end

    if not IsAddOnLoaded("DragonUI_Options") then
        local noConfig
        local _, _, _, _, reason = GetAddOnInfo("DragonUI_Options")
        
        if reason ~= "MISSING" and reason ~= "DISABLED" then
            LoadAddOn("DragonUI_Options")
            
            -- Check if it actually loaded
            if not IsAddOnLoaded("DragonUI_Options") then 
                noConfig = true 
            else
                addon.OptionsLoaded = true
            end
        else
            noConfig = true
        end

        if noConfig then
            print("|cFFFF0000[DragonUI]|r Error -- Addon 'DragonUI_Options' not found or is disabled.")
            return
        end
    end

    -- Check for "legacy" argument to open old AceConfigDialog
    if msg and (msg == "legacy" or msg == "config" or msg == "old") then
        local AceConfigDialog = LibStub("AceConfigDialog-3.0")
        if AceConfigDialog then
            local ConfigOpen = AceConfigDialog.OpenFrames and AceConfigDialog.OpenFrames["DragonUI"]
            if ConfigOpen then
                AceConfigDialog:Close("DragonUI")
            else
                AceConfigDialog:Open("DragonUI")
            end
        end
        return
    end

    -- Use the new custom panel
    if addon.OptionsPanel then
        addon.OptionsPanel:Toggle(msg)
    else
        -- Fallback to AceConfigDialog if panel not available
        local AceConfigDialog = LibStub("AceConfigDialog-3.0")
        if AceConfigDialog then
            local ConfigOpen = AceConfigDialog.OpenFrames and AceConfigDialog.OpenFrames["DragonUI"]
            if ConfigOpen then
                AceConfigDialog:Close("DragonUI")
            else
                AceConfigDialog:Open("DragonUI")
            end
        end
    end
end

-- Callback function that refreshes all modules when configuration changes
function addon:RefreshConfig()
    -- Initialize cooldown system if it hasn't been already
    if addon.InitializeCooldowns then
        addon.InitializeCooldowns()
    end

    local failed = {};

    -- List of refresh functions to call
    local refreshFunctions = {
        "RefreshMainbars",
        "RefreshButtons",
        "RefreshMicromenu",
        "RefreshMinimap",
        "RefreshTargetFrame",
        "RefreshFocusFrame",
        "RefreshPartyFrames",
        "RefreshStance",
        "RefreshPetbar",
        "RefreshVehicle",
        "RefreshMulticast",
        "RefreshCooldowns",
        "RefreshXpBarPosition",
        "RefreshRepBarPosition",
        "RefreshMinimapTime",
        "RefreshBuffFrame"
    }

    -- Try to apply each configuration and track failures
    for _, funcName in ipairs(refreshFunctions) do
        if addon[funcName] then
            local success, err = pcall(addon[funcName])
            if not success then
                table.insert(failed, funcName)
            end
        end
    end

    -- If some configurations failed, retry them after 2 seconds
    if #failed > 0 then
        addon.core:ScheduleTimer(function()
            for _, funcName in ipairs(failed) do
                if addon[funcName] then
                    pcall(addon[funcName]);
                end
            end
        end, 2);
    end
end

-- Legacy SlashCommand handler (fallback if commands.lua not loaded)
function addon.core:SlashCommand(input)
    -- Delegate to new command system if available
    if addon.CommandHandlers then
        if not input or input:trim() == "" then
            addon:ToggleOptionsUI()
        elseif input:lower() == "config" then
            addon:ToggleOptionsUI()
        elseif input:lower() == "legacy" or input:lower() == "old" then
            addon:ToggleOptionsUI("legacy")
        elseif input:lower() == "edit" or input:lower() == "editor" then
            addon.CommandHandlers.ToggleEditorMode()
        elseif input:lower() == "help" then
            addon.CommandHandlers.ShowHelp()
        else
            addon.CommandHandlers.ShowHelp()
        end
    else
        -- Original fallback
        if not input or input:trim() == "" then
            addon:ToggleOptionsUI()
        elseif input:lower() == "config" then
            addon:ToggleOptionsUI()
        elseif input:lower() == "edit" or input:lower() == "editor" then
            if addon.EditorMode then
                addon.EditorMode:Toggle()
            else
                print("|cFFFF0000[DragonUI]|r Editor mode not available.")
            end
        else
            print("|cFF00FF00[DragonUI]|r Commands: /dragonui config, /dragonui edit")
        end
    end
end

print("|cFF00FF00[DragonUI]|r Core loaded")
