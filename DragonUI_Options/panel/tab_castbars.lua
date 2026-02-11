--[[
================================================================================
DragonUI Options Panel - Castbars Tab
================================================================================
Player, target, and focus castbar options with sub-tab navigation.
================================================================================
]]

local addon = DragonUI
if not addon then return end

local C = addon.PanelControls
local Panel = addon.OptionsPanel

-- ============================================================================
-- SHARED VALUES
-- ============================================================================

local textModeValues = {
    simple   = "Simple (Name Only)",
    detailed = "Detailed (Name + Time)",
}

-- ============================================================================
-- ACTIVE SUB-TAB STATE
-- ============================================================================

local activeSubTab = "player"

local subTabs = {
    { key = "player", label = "Player" },
    { key = "target", label = "Target" },
    { key = "focus",  label = "Focus" },
}

-- ============================================================================
-- COMMON CONTROLS BUILDER
-- ============================================================================

local function AddCastbarControls(parent, dbPrefix, refreshFunc, opts)
    opts = opts or {}

    local sizeXMin = opts.sizeXMin or 80
    local sizeXMax = opts.sizeXMax or 512
    local sizeYMin = opts.sizeYMin or 10
    local sizeYMax = opts.sizeYMax or 64

    C:AddSlider(parent, {
        label = "Width",
        dbPath = dbPrefix .. ".sizeX",
        min = sizeXMin, max = sizeXMax, step = 1,
        width = 200,
        callback = refreshFunc,
    })

    C:AddSlider(parent, {
        label = "Height",
        dbPath = dbPrefix .. ".sizeY",
        min = sizeYMin, max = sizeYMax, step = 1,
        width = 200,
        callback = refreshFunc,
    })

    C:AddSlider(parent, {
        label = "Scale",
        dbPath = dbPrefix .. ".scale",
        min = 0.5, max = 2.0, step = 0.1,
        width = 200,
        callback = refreshFunc,
    })

    C:AddToggle(parent, {
        label = "Show Icon",
        dbPath = dbPrefix .. ".showIcon",
        callback = refreshFunc,
    })

    C:AddSlider(parent, {
        label = "Icon Size",
        dbPath = dbPrefix .. ".sizeIcon",
        min = 1, max = 64, step = 1,
        width = 200,
        disabled = function()
            return not C:GetDBValue(dbPrefix .. ".showIcon")
        end,
        callback = refreshFunc,
    })

    C:AddDropdown(parent, {
        label = "Text Mode",
        dbPath = dbPrefix .. ".text_mode",
        values = textModeValues,
        callback = refreshFunc,
    })

    C:AddSlider(parent, {
        label = "Time Precision",
        desc = "Decimal places for remaining time.",
        dbPath = dbPrefix .. ".precision_time",
        min = 0, max = 3, step = 1,
        width = 180,
        disabled = function()
            return C:GetDBValue(dbPrefix .. ".text_mode") == "simple"
        end,
    })

    C:AddSlider(parent, {
        label = "Max Time Precision",
        desc = "Decimal places for total time.",
        dbPath = dbPrefix .. ".precision_max",
        min = 0, max = 3, step = 1,
        width = 180,
        disabled = function()
            return C:GetDBValue(dbPrefix .. ".text_mode") == "simple"
        end,
    })

    C:AddSlider(parent, {
        label = "Hold Time (Success)",
        desc = "How long the bar stays after a successful cast.",
        dbPath = dbPrefix .. ".holdTime",
        min = 0, max = 2, step = 0.1,
        width = 200,
        callback = refreshFunc,
    })

    C:AddSlider(parent, {
        label = "Hold Time (Interrupt)",
        desc = "How long the bar stays after being interrupted.",
        dbPath = dbPrefix .. ".holdTimeInterrupt",
        min = 0, max = 2, step = 0.1,
        width = 200,
        callback = refreshFunc,
    })

    if opts.hasAutoAdjust then
        C:AddToggle(parent, {
            label = "Auto-Adjust for Auras",
            desc = "Shift castbar when buff/debuff rows are showing.",
            dbPath = dbPrefix .. ".autoAdjust",
            callback = refreshFunc,
        })
    end

    if opts.resetFunc then
        C:AddButton(parent, {
            label = "Reset Position",
            width = 160,
            callback = opts.resetFunc,
        })
    end
end

-- ============================================================================
-- SUB-TAB BUILDERS
-- ============================================================================

local function BuildPlayerCastbar(scroll)
    local refresh = function()
        if addon.RefreshCastbar then addon.RefreshCastbar() end
    end

    local s = C:AddSection(scroll, "Player Castbar")
    AddCastbarControls(s, "castbar", refresh, {
        sizeXMin = 80, sizeXMax = 512,
        sizeYMin = 10, sizeYMax = 64,
        resetFunc = function()
            if addon.ResetCastbarPosition then
                addon.ResetCastbarPosition()
            end
            print("|cFF00FF00[DragonUI]|r Player castbar position reset.")
        end,
    })
end

local function BuildTargetCastbar(scroll)
    local refresh = function()
        if addon.RefreshTargetCastbar then addon.RefreshTargetCastbar() end
    end

    local s = C:AddSection(scroll, "Target Castbar")
    AddCastbarControls(s, "castbar.target", refresh, {
        sizeXMin = 50, sizeXMax = 400,
        sizeYMin = 5, sizeYMax = 50,
        hasAutoAdjust = true,
        resetFunc = function()
            if addon.ResetTargetCastbarPosition then
                addon.ResetTargetCastbarPosition()
            end
            print("|cFF00FF00[DragonUI]|r Target castbar position reset.")
        end,
    })
end

local function BuildFocusCastbar(scroll)
    local refresh = function()
        if addon.RefreshFocusCastbar then addon.RefreshFocusCastbar() end
    end

    local s = C:AddSection(scroll, "Focus Castbar")
    AddCastbarControls(s, "castbar.focus", refresh, {
        sizeXMin = 50, sizeXMax = 400,
        sizeYMin = 5, sizeYMax = 50,
        hasAutoAdjust = true,
        resetFunc = function()
            if addon.ResetFocusCastbarPosition then
                addon.ResetFocusCastbarPosition()
            end
            print("|cFF00FF00[DragonUI]|r Focus castbar position reset.")
        end,
    })
end

-- ============================================================================
-- SUB-TAB DISPATCH
-- ============================================================================

local subTabBuilders = {
    player = BuildPlayerCastbar,
    target = BuildTargetCastbar,
    focus  = BuildFocusCastbar,
}

-- ============================================================================
-- MAIN TAB BUILDER
-- ============================================================================

local function BuildCastbarsTab(scroll)
    C:AddSubTabs(scroll, subTabs, activeSubTab, function(key)
        activeSubTab = key
        Panel:SelectTab("castbars")
    end)

    local builder = subTabBuilders[activeSubTab]
    if builder then
        builder(scroll)
    end
end

-- Register the tab
Panel:RegisterTab("castbars", "Cast Bars", BuildCastbarsTab, 7)

print("|cFF00FF00[DragonUI]|r Panel tab: Cast Bars loaded")
