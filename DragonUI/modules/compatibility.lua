local addon = select(2, ...)
local compatibility = {}
addon.compatibility = compatibility

--[[
* DragonUI Compatibility Manager
* 
* Modular system to detect specific addons and apply custom behaviors.
* Each addon can have its own detection and behavior logic.
]]

-- ============================================================================
-- CONFIGURATION
-- ============================================================================

local CONFIG = {
    warningDelay = 0.5,
    scanDelay = 0.1
}

-- ============================================================================
-- OPTIMIZED SYSTEMS
-- ============================================================================

-- Timer helper: delegates to centralized addon:After() (note: arg order is func, delay)
local function DelayedCall(func, delay)
    addon:After(delay, func)
end

-- Cache system for addon loading checks
local addonLoadCache = {}
local function IsAddonLoadedCached(addonName)
    if addonLoadCache[addonName] == nil then
        addonLoadCache[addonName] = IsAddOnLoaded(addonName)
    end
    return addonLoadCache[addonName]
end

-- ============================================================================
-- BEHAVIOR SYSTEM
-- ============================================================================

local behaviors = {}

-- Behavior: Show conflict warning with disable option
behaviors.ConflictWarning = function(addonName, addonInfo)
    local popupName = "DRAGONUI_CONFLICT_" .. string.upper(addonName)
    
    StaticPopupDialogs[popupName] = {
        text = string.format(
            "|cFFFF0000DragonUI Conflict Warning|r\n\n" ..
            "The addon |cFFFFFF00%s|r conflicts with DragonUI.\n\n" ..
            "|cFFFF9999Reason:|r %s\n\n" ..
            "Disable the conflicting addon now?",
            addonInfo.name, addonInfo.reason
        ),
        button1 = "Disable ",
        button2 = "Keep Both",
        OnAccept = function()
            DisableAddOn(addonName)
            ReloadUI()
        end,
        OnCancel = function() end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = false,
        preferredIndex = 3
    }
    
    StaticPopup_Show(popupName)
end

-- Behavior: CompactRaidFrame taint mitigation
behaviors.CompactRaidFrameFix = function(addonName, addonInfo)
    
    -- Simple state tracking
    local inCombat = false
    local needsRefresh = false
    local lastPartySize = GetNumPartyMembers()
    local partySizeWhenCombatStarted = 0
    
    -- Simple cleanup system for party frames
    local function CleanPartyFrames()
        -- Only cleanup - don't try to recreate
        for i = 1, 4 do
            local frameName = 'PartyMemberFrame' .. i
            local frame = _G[frameName]
            
            if frame then
                -- Hide and clear all events
                frame:Hide()
                frame:UnregisterAllEvents()
                
                -- Clear unit assignment
                frame.unit = nil
                frame.id = nil
                
                -- Reset health bar
                local healthBar = _G[frameName .. 'HealthBar']
                if healthBar then
                    healthBar:UnregisterAllEvents()
                    healthBar:SetMinMaxValues(0, 100)
                    healthBar:SetValue(0)
                end
                
                -- Reset mana bar  
                local manaBar = _G[frameName .. 'ManaBar']
                if manaBar then
                    manaBar:UnregisterAllEvents()
                    manaBar:SetMinMaxValues(0, 100)
                    manaBar:SetValue(0)
                end
                
                -- Clear portrait
                local portrait = _G[frameName .. 'Portrait']
                if portrait then
                    portrait:SetTexture(nil)
                end
                
                -- Reset name text
                local nameText = _G[frameName .. 'Name']
                if nameText then
                    nameText:SetText("")
                end
                
                -- Clear all DragonUI custom elements
                if frame.DragonUI_CustomTexts then
                    frame.DragonUI_CustomTexts = nil
                end
                if frame.DragonUI_HealthText then
                    frame.DragonUI_HealthText:Hide()
                    frame.DragonUI_HealthText = nil
                end
                if frame.DragonUI_ManaText then
                    frame.DragonUI_ManaText:Hide()
                    frame.DragonUI_ManaText = nil
                end
                if frame.DragonUI_TextFrame then
                    frame.DragonUI_TextFrame:Hide()
                    frame.DragonUI_TextFrame = nil
                end
            end
        end
        
        -- Simple refresh of party system
        DelayedCall(function()
            if _G.PartyMemberFrame_UpdateParty then
                _G.PartyMemberFrame_UpdateParty()
            end
            
            -- Apply DragonUI refresh if available
            if addon and addon.RefreshPartyFrames then
                addon.RefreshPartyFrames()
            end
        end, 0.2)
    end
    
    -- Show reload dialog for party frame creation issues
    local function ShowPartyReloadDialog()
        StaticPopupDialogs["DRAGONUI_PARTY_RELOAD"] = {
            text = "|cFFFFFF00DragonUI - Party Frame Issue|r\n\n" ..
                   "You joined a party while in combat. Due to CompactRaidFrame taint issues, " ..
                   "party frames may not display correctly.\n\n" ..
                   "|cFFFF9999Reload the UI to fix party frame display?|r",
            button1 = "Reload UI",
            button2 = "Skip",
            OnAccept = function()
                ReloadUI()
            end,
            OnCancel = function() end,
            timeout = 15, -- Auto-dismiss after 15 seconds
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3
        }
        
        StaticPopup_Show("DRAGONUI_PARTY_RELOAD")
    end
    

    
    -- Polling frame that ONLY runs while in combat (auto-disables otherwise)
    local pollingFrame = CreateFrame("Frame")
    local checkInterval = 0
    
    local function StartPolling()
        checkInterval = 0
        pollingFrame:SetScript("OnUpdate", function(self, elapsed)
            checkInterval = checkInterval + elapsed
            if checkInterval < 0.5 then return end
            checkInterval = 0
            
            local currentPartySize = GetNumPartyMembers()
            if currentPartySize ~= lastPartySize then
                needsRefresh = true
            end
        end)
    end
    
    local function StopPolling()
        pollingFrame:SetScript("OnUpdate", nil)
        
        if needsRefresh then
            local currentPartySize = GetNumPartyMembers()
            if currentPartySize == 0 and partySizeWhenCombatStarted > 0 then
                CleanPartyFrames()
            elseif currentPartySize > 0 and partySizeWhenCombatStarted > 0 then
                CleanPartyFrames()
            elseif currentPartySize > 0 and partySizeWhenCombatStarted == 0 then
                ShowPartyReloadDialog()
            end
            needsRefresh = false
        end
        
        lastPartySize = GetNumPartyMembers()
        partySizeWhenCombatStarted = 0
        inCombat = false
    end
    
    -- Use events to toggle polling on/off (much cheaper than always polling)
    pollingFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
    pollingFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    pollingFrame:SetScript("OnEvent", function(self, event)
        if event == "PLAYER_REGEN_DISABLED" then
            inCombat = true
            partySizeWhenCombatStarted = GetNumPartyMembers()
            lastPartySize = partySizeWhenCombatStarted
            StartPolling()
        elseif event == "PLAYER_REGEN_ENABLED" then
            StopPolling()
        end
    end)
    

end


-- ============================================================================
-- ADDON REGISTRY
-- ============================================================================

-- Behavior: Carbonite minimap texture re-application
-- Carbonite resets minimap mask via SetMaskTexture during its ADDON_LOADED init,
-- and starts a repeating timer that calls SetBlipTexture every ~0.2s (node glow).
-- The SetBlipTexture override in minimap.lua blocks the timer calls, but we still
-- need to re-apply mask and POI textures after Carbonite's one-time init.
behaviors.CarboniteMinimapFix = function(addonName, addonInfo)
    -- Re-apply minimap textures after Carbonite finishes its init
    local elapsed = 0
    local reapplyFrame = CreateFrame("Frame")
    reapplyFrame:SetScript("OnUpdate", function(self, dt)
        elapsed = elapsed + dt
        if elapsed > 1.5 then
            if addon.MinimapModule and addon.MinimapModule.applied
                and addon:IsModuleEnabled("minimap") then
                addon.MinimapModule.ReapplyMinimapTextures()
            end
            self:SetScript("OnUpdate", nil)
        end
    end)
end

local ADDON_REGISTRY = {
    ["unitframelayers"] = {
        name = "UnitFrameLayers",
        reason = "Conflicts with DragonUI's custom unit frame textures and power bar system.",
        behavior = behaviors.ConflictWarning,
        checkOnce = true
    },
    ["compactraidframe"] = {
        name = "CompactRaidFrame",
        reason = "Known taint issues when manipulating party frames during combat. DragonUI provides automatic fixes.",
        behavior = behaviors.CompactRaidFrameFix,
        checkOnce = true,
        listenToRaidEvents = true -- Enable raid event monitoring
    },
    ["carbonite"] = {
        name = "Carbonite",
        reason = "Resets minimap mask and blip textures. DragonUI re-applies its custom textures automatically.",
        behavior = behaviors.CarboniteMinimapFix,
        checkOnce = true
    },
}

-- ============================================================================
-- STATE TRACKING
-- ============================================================================

local state = {
    processedAddons = {},
    activeAddons = {},
    initialized = false
}

-- ============================================================================
-- EVENT SYSTEM (ADDON SPECIFIC)
-- ============================================================================

local activeEventFrames = {}

local function RegisterEventsForAddon(addonName, addonInfo)
    if not addonInfo.listenToRaidEvents then
        return
    end
    
    local eventFrame = CreateFrame("Frame", "DragonUI_Events_" .. addonName)
    eventFrame:RegisterEvent("RAID_ROSTER_UPDATE")
    eventFrame:RegisterEvent("PARTY_CONVERTED_TO_RAID")
    eventFrame:RegisterEvent("PARTY_MEMBERS_CHANGED")
    eventFrame:RegisterEvent("PARTY_LEADER_CHANGED")
    eventFrame:RegisterEvent("GROUP_FORMED")
    eventFrame:RegisterEvent("GROUP_JOINED")
    eventFrame:RegisterEvent("GROUP_LEFT")
    
    eventFrame:SetScript("OnEvent", function(self, event)
        if compatibility.raidUpdateHandlers and compatibility.raidUpdateHandlers[addonName] then
            compatibility.raidUpdateHandlers[addonName]()
        end
    end)
    
    activeEventFrames[addonName] = eventFrame
end

local function UnregisterEventsForAddon(addonName)
    if activeEventFrames[addonName] then
        activeEventFrames[addonName]:UnregisterAllEvents()
        activeEventFrames[addonName] = nil
    end
end

-- ============================================================================
-- CORE DETECTION & EXECUTION
-- ============================================================================

local function ValidateRegistryEntry(addonName, addonInfo)
    if not addonInfo.name or not addonInfo.reason or not addonInfo.behavior then
        return false
    end
    return true
end

local function ProcessAddon(addonName, addonInfo)
    if not ValidateRegistryEntry(addonName, addonInfo) then
        return
    end

    if addonInfo.checkOnce and state.processedAddons[addonName] then
        return
    end

    if addonInfo.checkOnce then
        state.processedAddons[addonName] = true
    end

    state.activeAddons[addonName] = addonInfo

    if addonInfo.behavior then
        addonInfo.behavior(addonName, addonInfo)
    end
    
    if addonInfo.listenToRaidEvents then
        RegisterEventsForAddon(addonName, addonInfo)
    end
end

local function ScanForRegisteredAddons()
    local foundAddons = {}
    
    for addonName, addonInfo in pairs(ADDON_REGISTRY) do
        if IsAddonLoadedCached(addonName) then
            foundAddons[addonName] = addonInfo
        end
    end
    
    return foundAddons
end

-- ============================================================================
-- MAIN EVENT SYSTEM
-- ============================================================================

local function InitializeEvents()
    local eventFrame = CreateFrame("Frame")
    eventFrame:RegisterEvent("ADDON_LOADED")
    eventFrame:RegisterEvent("PLAYER_LOGIN")

    eventFrame:SetScript("OnEvent", function(self, event, loadedAddonName)
        if event == "ADDON_LOADED" then
            if loadedAddonName then
                addonLoadCache[loadedAddonName] = true
            end

            if loadedAddonName == "DragonUI" then
                DelayedCall(function()
                    local foundAddons = ScanForRegisteredAddons()
                    for addonName, addonInfo in pairs(foundAddons) do
                        ProcessAddon(addonName, addonInfo)
                    end
                end, CONFIG.scanDelay)

            elseif ADDON_REGISTRY[loadedAddonName] then
                DelayedCall(function()
                    ProcessAddon(loadedAddonName, ADDON_REGISTRY[loadedAddonName])
                end, CONFIG.warningDelay)
            end

        elseif event == "PLAYER_LOGIN" then
            state.initialized = true
        end
    end)
end

-- ============================================================================
-- SLASH COMMANDS
-- ============================================================================

local function InitializeCommands()
    SLASH_DRAGONUI_COMPAT1 = "/duicomp"
    
    SlashCmdList["DRAGONUI_COMPAT"] = function(msg)
        
        for i = 1, GetNumAddOns() do
            local name = select(1, GetAddOnInfo(i))
            local title = GetAddOnMetadata(i, "Title") or "Unknown"
            local loaded = IsAddOnLoaded(i)
            if loaded then
                print("  - " .. title .. " |cFFFFFF00(" .. name .. ")|r")
            end
        end
    end
end

-- ============================================================================
-- PUBLIC API
-- ============================================================================

function compatibility:RegisterAddon(addonName, addonInfo)
    if not ValidateRegistryEntry(addonName, addonInfo) then
        return false
    end
    
    ADDON_REGISTRY[addonName] = addonInfo
    
    if IsAddonLoadedCached(addonName) then
        ProcessAddon(addonName, addonInfo)
    end
    
    return true
end

function compatibility:UnregisterAddon(addonName)
    if ADDON_REGISTRY[addonName] then
        UnregisterEventsForAddon(addonName)
        state.activeAddons[addonName] = nil
        if compatibility.raidUpdateHandlers then
            compatibility.raidUpdateHandlers[addonName] = nil
        end
        
        ADDON_REGISTRY[addonName] = nil
        
        return true
    end
    return false
end

function compatibility:IsRegistered(addonName)
    return ADDON_REGISTRY[addonName] ~= nil
end

function compatibility:GetActiveAddons()
    return state.activeAddons
end

-- ============================================================================
-- CLEANUP FUNCTIONS
-- ============================================================================

local function Cleanup()
    for addonName, _ in pairs(activeEventFrames) do
        UnregisterEventsForAddon(addonName)
    end
    activeEventFrames = {}
end

-- ============================================================================
-- INITIALIZATION
-- ============================================================================

InitializeEvents()
InitializeCommands()