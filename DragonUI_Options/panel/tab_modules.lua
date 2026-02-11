--[[
================================================================================
DragonUI Options Panel - Modules Tab
================================================================================
Module enable/disable toggles organized by category.
================================================================================
]]

local addon = DragonUI
if not addon then return end

local C = addon.PanelControls
local Panel = addon.OptionsPanel

-- ============================================================================
-- HELPER: Create a module toggle with standard pattern
-- ============================================================================

local function ModuleToggle(parent, opts)
    -- opts: { label, desc, moduleName (single string or table of names), callback }
    local moduleNames = opts.moduleNames or { opts.moduleName }

    C:AddToggle(parent, {
        label = opts.label,
        desc  = opts.desc,
        getFunc = function()
            local modules = addon.db.profile.modules
            if not modules then return false end
            for _, name in ipairs(moduleNames) do
                if not (modules[name] and modules[name].enabled) then
                    return false
                end
            end
            return true
        end,
        setFunc = function(val)
            if not addon.db.profile.modules then
                addon.db.profile.modules = {}
            end
            for _, name in ipairs(moduleNames) do
                if not addon.db.profile.modules[name] then
                    addon.db.profile.modules[name] = {}
                end
                addon.db.profile.modules[name].enabled = val
            end
        end,
        callback = opts.callback,
        requiresReload = (opts.requiresReload ~= false), -- default true
    })
end

-- ============================================================================
-- MODULES TAB BUILDER
-- ============================================================================

local function BuildModulesTab(scroll)
    C:AddLabel(scroll, "|cffFFD700Modules|r", { color = C.Theme.textGold })
    C:AddDescription(scroll, "Toggle individual modules on or off. Disabled modules revert to the default Blizzard UI.")

    C:AddSpacer(scroll)

    -- ====================================================================
    -- CAST BARS
    -- ====================================================================
    local castSection = C:AddSection(scroll, "Cast Bars")

    C:AddToggle(castSection, {
        label = "Player Castbar",
        desc = "Enable DragonUI player castbar styling.",
        dbPath = "castbar.enabled",
        callback = function() if addon.RefreshCastbar then addon.RefreshCastbar() end end,
    })

    C:AddToggle(castSection, {
        label = "Target Castbar",
        desc = "Enable DragonUI target castbar styling.",
        getFunc = function()
            local t = addon.db.profile.castbar and addon.db.profile.castbar.target
            if not t then return true end
            return t.enabled ~= false
        end,
        setFunc = function(val)
            if not addon.db.profile.castbar.target then
                addon.db.profile.castbar.target = {}
            end
            addon.db.profile.castbar.target.enabled = val
        end,
        callback = function() if addon.RefreshTargetCastbar then addon.RefreshTargetCastbar() end end,
    })

    C:AddToggle(castSection, {
        label = "Focus Castbar",
        desc = "Enable DragonUI focus castbar styling.",
        dbPath = "castbar.focus.enabled",
        callback = function() if addon.RefreshFocusCastbar then addon.RefreshFocusCastbar() end end,
    })

    -- ====================================================================
    -- ACTION BARS SYSTEM (unified toggle)
    -- ====================================================================
    local abSection = C:AddSection(scroll, "Action Bars System")

    C:AddDescription(abSection, "Includes main bars, vehicle, stance, pet, totem bars, and button styling.")

    ModuleToggle(abSection, {
        label = "Enable All Action Bar Modules",
        desc = "Master toggle for the complete action bars system.",
        moduleNames = { "mainbars", "vehicle", "stance", "petbar", "multicast", "buttons", "noop" },
    })

    -- ====================================================================
    -- UI SYSTEMS
    -- ====================================================================
    local uiSection = C:AddSection(scroll, "UI Systems")

    ModuleToggle(uiSection, {
        label = "Micro Menu & Bags",
        desc = "Micro menu and bags styling.",
        moduleName = "micromenu",
    })

    ModuleToggle(uiSection, {
        label = "Minimap System",
        desc = "Minimap styling, tracking icons, and calendar.",
        moduleName = "minimap",
    })

    ModuleToggle(uiSection, {
        label = "Buff Frame System",
        desc = "Buff frame styling and toggle button.",
        moduleName = "buffs",
        callback = function(val)
            if addon.BuffFrameModule then
                addon.BuffFrameModule:Toggle(val)
            end
        end,
    })

    ModuleToggle(uiSection, {
        label = "Cooldown Timers",
        desc = "Show cooldown timers on action buttons.",
        moduleName = "cooldowns",
        requiresReload = false,
        callback = function()
            if addon.RefreshCooldownSystem then addon.RefreshCooldownSystem() end
        end,
    })

    ModuleToggle(uiSection, {
        label = "Quest Tracker",
        desc = "DragonUI quest tracker positioning and styling.",
        moduleName = "questtracker",
    })

    ModuleToggle(uiSection, {
        label = "KeyBind Mode",
        desc = "LibKeyBound integration for intuitive hover + key press binding.",
        moduleName = "keybinding",
    })

    -- ====================================================================
    -- ADVANCED: Individual Module Control
    -- ====================================================================
    C:AddSpacer(scroll)
    local advSection = C:AddSection(scroll, "Advanced - Individual Modules")

    C:AddLabel(advSection, "|cffFF6600Warning:|r Individual overrides. The grouped toggles above take priority.", { color = C.Theme.warning })
    C:AddSpacer(advSection)

    -- Generate toggles for all registered modules
    local MR = addon.ModuleRegistry
    if MR and MR.loadOrder then
        for _, moduleName in ipairs(MR.loadOrder) do
            local info = MR:GetInfo(moduleName)
            if info then
                ModuleToggle(advSection, {
                    label = info.displayName or moduleName,
                    desc = (info.description and info.description ~= "") and info.description or ("Enable/disable " .. (info.displayName or moduleName)),
                    moduleName = moduleName,
                })
            end
        end
    else
        -- Fallback: show known modules from database defaults
        local knownModules = {
            { key = "mainbars",    name = "Main Bars" },
            { key = "vehicle",     name = "Vehicle" },
            { key = "stance",      name = "Stance Bar" },
            { key = "petbar",      name = "Pet Bar" },
            { key = "multicast",   name = "Multicast" },
            { key = "buttons",     name = "Buttons" },
            { key = "noop",        name = "Hide Blizzard Elements" },
            { key = "micromenu",   name = "Micro Menu" },
            { key = "cooldowns",   name = "Cooldowns" },
            { key = "minimap",     name = "Minimap" },
            { key = "buffs",       name = "Buffs" },
            { key = "keybinding",  name = "KeyBinding" },
            { key = "questtracker", name = "Quest Tracker" },
        }
        for _, mod in ipairs(knownModules) do
            ModuleToggle(advSection, {
                label = mod.name,
                desc = "Enable/disable " .. mod.name,
                moduleName = mod.key,
            })
        end
    end
end

-- Register the tab
Panel:RegisterTab("modules", "Modules", BuildModulesTab, 2)

print("|cFF00FF00[DragonUI]|r Panel tab: Modules loaded")
