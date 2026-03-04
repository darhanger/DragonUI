--[[
================================================================================
DragonUI Options - Core
================================================================================
This file provides the options registration system and initialization.
Based on ElvUI_OptionsUI pattern - accesses DragonUI addon via global.
================================================================================
]]

-- Access the main DragonUI addon (exposed globally in DragonUI/core.lua)
local addon = DragonUI
if not addon then
    print("|cFFFF0000[DragonUI_Options]|r Error: DragonUI addon not found!")
    return
end

-- Initialize Options localization
-- Core L comes from main addon, Options L is for option-specific strings
local L = LibStub("AceLocale-3.0"):GetLocale("DragonUI")
local LO = LibStub("AceLocale-3.0"):GetLocale("DragonUI_Options")
addon.LO = LO  -- Expose for other option files

-- ============================================================================
-- STATIC POPUP FOR RELOAD
-- ============================================================================

StaticPopupDialogs["DRAGONUI_RELOAD_UI"] = {
    text = LO["Changing this setting requires a UI reload to apply correctly."],
    button1 = LO["Reload UI"],
    button2 = LO["Not Now"],
    OnAccept = function()
        ReloadUI()
    end,
    timeout = 0,
    whileDead = 1,
    hideOnEscape = 1,
    preferredIndex = 3
}

-- ============================================================================
-- REGISTRATION FUNCTION (for backwards compatibility with option files)
-- ============================================================================

-- Register an options group directly to addon.Options.args
function addon:RegisterOptionsGroup(name, optionsTable, order)
    if not addon.Options then
        addon.Options = { type = "group", name = "DragonUI", args = {} }
    end
    
    addon.Options.args[name] = optionsTable
    if order then
        addon.Options.args[name].order = order
    end

    -- Process any options groups that were queued before Options loaded
    if addon._pendingOptionsGroups then
        for _, pending in ipairs(addon._pendingOptionsGroups) do
            addon.Options.args[pending.name] = pending.table
        end
        addon._pendingOptionsGroups = nil
    end
end

-- ============================================================================
-- WINDOW SIZE SETUP
-- ============================================================================

local function SetupWindowSize()
    local AceConfigDialog = LibStub("AceConfigDialog-3.0")
    if not AceConfigDialog then return end
    
    local userHasResized = false
    local defaultWidth, defaultHeight = 900, 600

    local function setupDragonUIWindowSize()
        local configFrame = AceConfigDialog.OpenFrames["DragonUI"]
        if configFrame and configFrame.frame then
            local statusWidth = configFrame.status.width
            local statusHeight = configFrame.status.height

            if statusWidth and statusHeight then
                if statusWidth ~= defaultWidth or statusHeight ~= defaultHeight then
                    userHasResized = true
                end
            end

            if not userHasResized then
                configFrame.frame:SetWidth(defaultWidth)
                configFrame.frame:SetHeight(defaultHeight)
                configFrame.frame:ClearAllPoints()
                configFrame.frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
                configFrame.status.width = defaultWidth
                configFrame.status.height = defaultHeight
            else
                configFrame.frame:ClearAllPoints()
                configFrame.frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
            end
        end
    end

    -- Hook the status table application
    local originalSetStatusTable = AceConfigDialog.SetStatusTable
    AceConfigDialog.SetStatusTable = function(self, appName, statusTable)
        local result = originalSetStatusTable(self, appName, statusTable)
        if appName == "DragonUI" then
            setupDragonUIWindowSize()
        end
        return result
    end

    -- Hook Open to set size immediately
    local originalOpen = AceConfigDialog.Open
    AceConfigDialog.Open = function(self, appName, ...)
        local result = originalOpen(self, appName, ...)
        if appName == "DragonUI" then
            userHasResized = false
            setupDragonUIWindowSize()
        end
        return result
    end
end

-- ============================================================================
-- INITIALIZE OPTIONS (called after all option files are loaded)
-- ============================================================================

function addon:InitializeOptions()
    -- Add profiles options
    local profilesOptions = LibStub("AceDBOptions-3.0"):GetOptionsTable(addon.db)
    addon.Options.args.profiles = profilesOptions
    addon.Options.args.profiles.order = 100
    
    -- Register with AceConfig
    LibStub("AceConfig-3.0"):RegisterOptionsTable("DragonUI", addon.Options)
    LibStub("AceConfigDialog-3.0"):AddToBlizOptions("DragonUI", "DragonUI")
    
    -- Setup window size hooks
    SetupWindowSize()
    
    addon.OptionsLoaded = true
end

-- Initialize when this addon finishes loading
local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("ADDON_LOADED")
initFrame:SetScript("OnEvent", function(self, event, loadedAddon)
    if loadedAddon == "DragonUI_Options" then
        addon:InitializeOptions()
        self:UnregisterAllEvents()
    end
end)
