--[[
================================================================================
DragonUI Options Panel - Action Bars Tab
================================================================================
Scales, positions, button appearance, bar size for action bars.
================================================================================
]]

local addon = DragonUI
if not addon then return end

local C = addon.PanelControls
local Panel = addon.OptionsPanel

-- ============================================================================
-- SUB-TAB DEFINITIONS
-- ============================================================================

local activeSubTab = "general"

local subTabs = {
    { key = "general", label = "General" },
    { key = "layout",  label = "Layout" },
    { key = "visibility", label = "Visibility" },
}

-- ============================================================================
-- REFRESH HELPER
-- ============================================================================

local function RefreshBars()
    if addon.RefreshMainbars then addon.RefreshMainbars() end
end

local function RefreshButtons()
    if addon.RefreshButtons then addon.RefreshButtons() end
end

local function RefreshCooldowns()
    if addon.RefreshCooldowns then addon.RefreshCooldowns() end
end

-- ============================================================================
-- GENERAL SUB-TAB (existing action bar settings)
-- ============================================================================

local function BuildGeneralTab(scroll)
    -- ====================================================================
    -- SCALES
    -- ====================================================================
    local scales = C:AddSection(scroll, "Action Bar Scales")

    local barScales = {
        { path = "mainbars.scale_actionbar",    label = "Main Bar Scale" },
        { path = "mainbars.scale_rightbar",     label = "Right Bar Scale" },
        { path = "mainbars.scale_leftbar",      label = "Left Bar Scale" },
        { path = "mainbars.scale_bottomleft",   label = "Bottom Left Bar Scale" },
        { path = "mainbars.scale_bottomright",  label = "Bottom Right Bar Scale" },
    }

    for _, bar in ipairs(barScales) do
        C:AddSlider(scales, {
            dbPath = bar.path,
            label = bar.label,
            min = 0.5, max = 2.0, step = 0.1,
            width = 250,
            callback = RefreshBars,
        })
    end

    C:AddButton(scales, {
        label = "Reset All Scales",
        width = 180,
        callback = function()
            for _, bar in ipairs(barScales) do
                C:SetDBValue(bar.path, 0.9)
            end
            RefreshBars()
            Panel:SelectTab("actionbars")
            print("|cFF00FF00[DragonUI]|r All action bar scales reset to 0.9")
        end,
    })

    -- ====================================================================
    -- POSITIONS
    -- ====================================================================
    local positions = C:AddSection(scroll, "Action Bar Positions")

    C:AddToggle(positions, {
        label = "Left Bar Horizontal",
        desc = "Make the left secondary bar horizontal instead of vertical.",
        dbPath = "mainbars.left.horizontal",
        callback = function()
            if addon.PositionActionBars then addon.PositionActionBars() end
        end,
    })

    C:AddToggle(positions, {
        label = "Right Bar Horizontal",
        desc = "Make the right secondary bar horizontal instead of vertical.",
        dbPath = "mainbars.right.horizontal",
        callback = function()
            if addon.PositionActionBars then addon.PositionActionBars() end
        end,
    })

    -- ====================================================================
    -- BUTTON APPEARANCE
    -- ====================================================================
    local buttons = C:AddSection(scroll, "Button Appearance")

    C:AddToggle(buttons, {
        label = "Main Bar Only Background",
        desc = "Only the main action bar buttons will have a background.",
        dbPath = "buttons.only_actionbackground",
        callback = RefreshButtons,
    })

    C:AddToggle(buttons, {
        label = "Hide Main Bar Background",
        desc = "Hide the background texture of the main action bar.",
        dbPath = "buttons.hide_main_bar_background",
        requiresReload = true,
        callback = RefreshBars,
    })

    -- Text visibility sub-section
    local textVis = C:AddSection(scroll, "Text Visibility")

    C:AddToggle(textVis, {
        label = "Show Count Text",
        dbPath = "buttons.count.show",
        callback = RefreshButtons,
    })

    C:AddToggle(textVis, {
        label = "Show Hotkey Text",
        dbPath = "buttons.hotkey.show",
        callback = RefreshButtons,
    })

    C:AddToggle(textVis, {
        label = "Range Indicator",
        desc = "Show range indicator dot on buttons.",
        dbPath = "buttons.hotkey.range",
        callback = RefreshButtons,
    })

    C:AddToggle(textVis, {
        label = "Show Macro Names",
        dbPath = "buttons.macros.show",
        callback = RefreshButtons,
    })

    C:AddToggle(textVis, {
        label = "Show Page Numbers",
        dbPath = "buttons.pages.show",
        requiresReload = true,
    })

    -- Cooldown text
    local cdSection = C:AddSection(scroll, "Cooldown Text")

    C:AddSlider(cdSection, {
        label = "Min Duration",
        desc = "Minimum duration for cooldown text to appear.",
        dbPath = "buttons.cooldown.min_duration",
        min = 1, max = 10, step = 1,
        width = 200,
        callback = RefreshCooldowns,
    })

    C:AddSlider(cdSection, {
        label = "Font Size",
        desc = "Size of cooldown text.",
        dbPath = "buttons.cooldown.font_size",
        min = 8, max = 24, step = 1,
        width = 200,
        callback = RefreshCooldowns,
    })

    C:AddColorPicker(cdSection, {
        label = "Cooldown Text Color",
        getFunc = function()
            local c = addon.db.profile.buttons.cooldown.color
            if c then return c[1], c[2], c[3], c[4] end
            return 1, 1, 1, 1
        end,
        setFunc = function(r, g, b, a)
            addon.db.profile.buttons.cooldown.color = { r, g, b, a }
            RefreshCooldowns()
        end,
        hasAlpha = true,
    })

    -- Colors
    local colorSection = C:AddSection(scroll, "Colors")

    C:AddColorPicker(colorSection, {
        label = "Macro Text Color",
        getFunc = function()
            local c = addon.db.profile.buttons.macros.color
            if c then return c[1], c[2], c[3], c[4] end
            return 1, 1, 0, 1
        end,
        setFunc = function(r, g, b, a)
            addon.db.profile.buttons.macros.color = { r, g, b, a }
            RefreshButtons()
        end,
        hasAlpha = true,
    })

    C:AddColorPicker(colorSection, {
        label = "Hotkey Shadow Color",
        getFunc = function()
            local c = addon.db.profile.buttons.hotkey.shadow
            if c then return c[1], c[2], c[3], c[4] end
            return 0, 0, 0, 1
        end,
        setFunc = function(r, g, b, a)
            addon.db.profile.buttons.hotkey.shadow = { r, g, b, a }
            RefreshButtons()
        end,
        hasAlpha = true,
    })

    C:AddColorPicker(colorSection, {
        label = "Border Color",
        getFunc = function()
            local c = addon.db.profile.buttons.border_color
            if c then return c[1], c[2], c[3], c[4] end
            return 1, 1, 1, 1
        end,
        setFunc = function(r, g, b, a)
            addon.db.profile.buttons.border_color = { r, g, b, a }
            RefreshButtons()
        end,
        hasAlpha = true,
    })

    -- ====================================================================
    -- GRYPHONS
    -- ====================================================================
    local gryphons = C:AddSection(scroll, "Gryphons")

    C:AddDescription(gryphons, "End-cap ornaments flanking the main action bar.")

    C:AddDropdown(gryphons, {
        label = "Style",
        dbPath = "style.gryphons",
        values = {
            old    = "Classic",
            new    = "Dragonflight",
            flying = "Flying",
            none   = "Hidden",
        },
        width = 200,
        callback = function()
            if addon.RefreshMainbars then addon.RefreshMainbars() end
        end,
    })

    -- Texture previews row
    local previewRow = C:AddRow(gryphons)
    local assets = addon._dir or "Interface\\AddOns\\DragonUI\\assets\\"
    local faction = UnitFactionGroup and UnitFactionGroup("player") or "Alliance"

    -- Classic gryphon preview
    C:AddTexturePreview(previewRow, {
        label = "Classic",
        texture = assets .. "uiactionbar2x_",
        texCoord = { 1/512, 357/512, 209/2048, 543/2048 },
        width = 80,
        height = 80,
    })

    -- Dragonflight gryphon preview (faction-aware: gryphon=Alliance, wyvern=Horde)
    local dfTexCoord
    if faction == "Horde" then
        dfTexCoord = { 1/512, 357/512, 881/2048, 1215/2048 } -- wyvern-thick-left
    else
        dfTexCoord = { 1/512, 357/512, 209/2048, 543/2048 }  -- gryphon-thick-left
    end
    C:AddTexturePreview(previewRow, {
        label = faction == "Horde" and "Dragonflight (Wyvern)" or "Dragonflight (Gryphon)",
        texture = assets .. "uiactionbar2x_new",
        texCoord = dfTexCoord,
        width = 80,
        height = 80,
    })

    -- Flying gryphon preview
    C:AddTexturePreview(previewRow, {
        label = "Flying",
        texture = assets .. "uiactionbar2x_flying",
        texCoord = { 1/256, 158/256, 149/2048, 342/2048 },
        width = 70,
        height = 90,
    })
end

-- ============================================================================
-- LAYOUT SUB-TAB (grid layout: rows/columns/buttons per bar)
-- ============================================================================

local function BuildLayoutTab(scroll)
    -- ---- Main Bar ----
    local mainSection = C:AddSection(scroll, "Main Bar Layout")

    C:AddDescription(mainSection,
        "Configure the main action bar grid layout. " ..
        "Rows are determined automatically from columns and buttons shown.")

    C:AddSlider(mainSection, {
        dbPath = "mainbars.player.columns",
        label = "Columns",
        min = 1, max = 12, step = 1,
        width = 200,
        callback = RefreshBars,
    })

    C:AddSlider(mainSection, {
        dbPath = "mainbars.player.buttons_shown",
        label = "Buttons Shown",
        min = 1, max = 12, step = 1,
        width = 200,
        callback = RefreshBars,
    })

    local mainPresetRow = C:AddRow(mainSection)

    C:AddButton(mainPresetRow, {
        label = "1x12",
        width = 60,
        callback = function()
            C:SetDBValue("mainbars.player.columns", 12)
            C:SetDBValue("mainbars.player.buttons_shown", 12)
            RefreshBars()
            Panel:SelectTab("actionbars")
        end,
    })

    C:AddButton(mainPresetRow, {
        label = "2x6",
        width = 60,
        callback = function()
            C:SetDBValue("mainbars.player.columns", 6)
            C:SetDBValue("mainbars.player.buttons_shown", 12)
            RefreshBars()
            Panel:SelectTab("actionbars")
        end,
    })

    C:AddButton(mainPresetRow, {
        label = "3x4",
        width = 60,
        callback = function()
            C:SetDBValue("mainbars.player.columns", 4)
            C:SetDBValue("mainbars.player.buttons_shown", 12)
            RefreshBars()
            Panel:SelectTab("actionbars")
        end,
    })

    C:AddButton(mainPresetRow, {
        label = "4x3",
        width = 60,
        callback = function()
            C:SetDBValue("mainbars.player.columns", 3)
            C:SetDBValue("mainbars.player.buttons_shown", 12)
            RefreshBars()
            Panel:SelectTab("actionbars")
        end,
    })

    -- ---- Bottom Left Bar ----
    local blSection = C:AddSection(scroll, "Bottom Left Bar Layout")

    C:AddSlider(blSection, {
        dbPath = "mainbars.bottom_left.columns",
        label = "Columns",
        min = 1, max = 12, step = 1,
        width = 200,
        callback = RefreshBars,
    })

    C:AddSlider(blSection, {
        dbPath = "mainbars.bottom_left.buttons_shown",
        label = "Buttons Shown",
        min = 1, max = 12, step = 1,
        width = 200,
        callback = RefreshBars,
    })

    -- ---- Bottom Right Bar ----
    local brSection = C:AddSection(scroll, "Bottom Right Bar Layout")

    C:AddSlider(brSection, {
        dbPath = "mainbars.bottom_right.columns",
        label = "Columns",
        min = 1, max = 12, step = 1,
        width = 200,
        callback = RefreshBars,
    })

    C:AddSlider(brSection, {
        dbPath = "mainbars.bottom_right.buttons_shown",
        label = "Buttons Shown",
        min = 1, max = 12, step = 1,
        width = 200,
        callback = RefreshBars,
    })

    -- ---- Right Bar ----
    local rightSection = C:AddSection(scroll, "Right Bar Layout")

    C:AddSlider(rightSection, {
        dbPath = "mainbars.right.columns",
        label = "Columns",
        min = 1, max = 12, step = 1,
        width = 200,
        callback = RefreshBars,
    })

    C:AddSlider(rightSection, {
        dbPath = "mainbars.right.buttons_shown",
        label = "Buttons Shown",
        min = 1, max = 12, step = 1,
        width = 200,
        callback = RefreshBars,
    })

    -- ---- Left Bar (Blizzard: MultiBarLeft = "Right 2") ----
    local leftSection = C:AddSection(scroll, "Left Bar Layout")

    C:AddSlider(leftSection, {
        dbPath = "mainbars.left.columns",
        label = "Columns",
        min = 1, max = 12, step = 1,
        width = 200,
        callback = RefreshBars,
    })

    C:AddSlider(leftSection, {
        dbPath = "mainbars.left.buttons_shown",
        label = "Buttons Shown",
        min = 1, max = 12, step = 1,
        width = 200,
        callback = RefreshBars,
    })

    -- ---- Quick Presets ----
    local presetSection = C:AddSection(scroll, "Quick Presets")

    C:AddDescription(presetSection, "Apply layout presets to multiple bars at once.")

    local presetRow = C:AddRow(presetSection)

    C:AddButton(presetRow, {
        label = "Both 1x12",
        width = 90,
        callback = function()
            for _, key in ipairs({"bottom_left", "bottom_right"}) do
                C:SetDBValue("mainbars." .. key .. ".columns", 12)
                C:SetDBValue("mainbars." .. key .. ".buttons_shown", 12)
            end
            RefreshBars()
            Panel:SelectTab("actionbars")
        end,
    })

    C:AddButton(presetRow, {
        label = "Both 2x6",
        width = 90,
        callback = function()
            for _, key in ipairs({"bottom_left", "bottom_right"}) do
                C:SetDBValue("mainbars." .. key .. ".columns", 6)
                C:SetDBValue("mainbars." .. key .. ".buttons_shown", 12)
            end
            RefreshBars()
            Panel:SelectTab("actionbars")
        end,
    })

    C:AddButton(presetRow, {
        label = "Reset All",
        width = 90,
        callback = function()
            C:SetDBValue("mainbars.player.columns", 12)
            C:SetDBValue("mainbars.player.buttons_shown", 12)
            for _, key in ipairs({"bottom_left", "bottom_right"}) do
                C:SetDBValue("mainbars." .. key .. ".columns", 12)
                C:SetDBValue("mainbars." .. key .. ".buttons_shown", 12)
            end
            C:SetDBValue("mainbars.right.columns", 1)
            C:SetDBValue("mainbars.right.buttons_shown", 12)
            C:SetDBValue("mainbars.left.columns", 1)
            C:SetDBValue("mainbars.left.buttons_shown", 12)
            RefreshBars()
            Panel:SelectTab("actionbars")
            print("|cFF00FF00[DragonUI]|r All bar layouts reset to defaults.")
        end,
    })
end

-- ============================================================================
-- VISIBILITY SUB-TAB (hover/combat show/hide per bar)
-- ============================================================================

local function RefreshVisibility()
    if addon.RefreshActionBarVisibility then addon.RefreshActionBarVisibility() end
end

local function BuildVisibilityTab(scroll)
    local desc = C:AddSection(scroll, "Bar Visibility")
    C:AddDescription(desc,
        "Control when action bars are visible. " ..
        "Bars can show only on hover, only in combat, or both. " ..
        "When no option is checked the bar is always visible.")

    -- Enable/disable secondary bars
    local enableSection = C:AddSection(scroll, "Enable / Disable Bars")

    C:AddToggle(enableSection, {
        label = "Bottom Left Bar",
        dbPath = "actionbars.bottom_left_enabled",
        callback = RefreshVisibility,
    })

    C:AddToggle(enableSection, {
        label = "Bottom Right Bar",
        dbPath = "actionbars.bottom_right_enabled",
        callback = RefreshVisibility,
    })

    C:AddToggle(enableSection, {
        label = "Right Bar",
        dbPath = "actionbars.right_enabled",
        callback = RefreshVisibility,
    })

    C:AddToggle(enableSection, {
        label = "Left Bar",
        dbPath = "actionbars.left_enabled",
        callback = RefreshVisibility,
    })

    -- Main bar hover/combat
    local mainVis = C:AddSection(scroll, "Main Bar")

    C:AddToggle(mainVis, {
        label = "Show on Hover Only",
        desc = "Hide the main bar until you hover over it.",
        dbPath = "actionbars.main_show_on_hover",
        callback = RefreshVisibility,
    })

    C:AddToggle(mainVis, {
        label = "Show in Combat Only",
        desc = "Hide the main bar until you enter combat.",
        dbPath = "actionbars.main_show_in_combat",
        callback = RefreshVisibility,
    })

    -- Bottom left hover/combat
    local blVis = C:AddSection(scroll, "Bottom Left Bar")

    C:AddToggle(blVis, {
        label = "Show on Hover Only",
        dbPath = "actionbars.bottom_left_show_on_hover",
        callback = RefreshVisibility,
    })

    C:AddToggle(blVis, {
        label = "Show in Combat Only",
        dbPath = "actionbars.bottom_left_show_in_combat",
        callback = RefreshVisibility,
    })

    -- Bottom right hover/combat
    local brVis = C:AddSection(scroll, "Bottom Right Bar")

    C:AddToggle(brVis, {
        label = "Show on Hover Only",
        dbPath = "actionbars.bottom_right_show_on_hover",
        callback = RefreshVisibility,
    })

    C:AddToggle(brVis, {
        label = "Show in Combat Only",
        dbPath = "actionbars.bottom_right_show_in_combat",
        callback = RefreshVisibility,
    })

    -- Right bar hover/combat
    local rightVis = C:AddSection(scroll, "Right Bar")

    C:AddToggle(rightVis, {
        label = "Show on Hover Only",
        dbPath = "actionbars.right_show_on_hover",
        callback = RefreshVisibility,
    })

    C:AddToggle(rightVis, {
        label = "Show in Combat Only",
        dbPath = "actionbars.right_show_in_combat",
        callback = RefreshVisibility,
    })

    -- Left bar hover/combat
    local leftVis = C:AddSection(scroll, "Left Bar")

    C:AddToggle(leftVis, {
        label = "Show on Hover Only",
        dbPath = "actionbars.left_show_on_hover",
        callback = RefreshVisibility,
    })

    C:AddToggle(leftVis, {
        label = "Show in Combat Only",
        dbPath = "actionbars.left_show_in_combat",
        callback = RefreshVisibility,
    })
end

-- ============================================================================
-- SUB-TAB DISPATCH
-- ============================================================================

local subTabBuilders = {
    general    = BuildGeneralTab,
    layout     = BuildLayoutTab,
    visibility = BuildVisibilityTab,
}

-- ============================================================================
-- MAIN TAB BUILDER
-- ============================================================================

local function BuildActionbarsTab(scroll)
    C:AddSubTabs(scroll, subTabs, activeSubTab, function(key)
        activeSubTab = key
        Panel:SelectTab("actionbars")
    end)

    local builder = subTabBuilders[activeSubTab]
    if builder then
        builder(scroll)
    end
end

-- Register the tab
Panel:RegisterTab("actionbars", "Action Bars", BuildActionbarsTab, 3)
