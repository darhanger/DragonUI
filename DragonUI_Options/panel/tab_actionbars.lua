--[[
================================================================================
DragonUI Options Panel - Action Bars Tab
================================================================================
Scales, positions, button appearance for action bars.
================================================================================
]]

local addon = DragonUI
if not addon then return end

local C = addon.PanelControls
local Panel = addon.OptionsPanel

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
-- ACTION BARS TAB BUILDER
-- ============================================================================

local function BuildActionbarsTab(scroll)
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
            -- Refresh the tab to update slider positions
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

-- Register the tab
Panel:RegisterTab("actionbars", "Action Bars", BuildActionbarsTab, 3)

print("|cFF00FF00[DragonUI]|r Panel tab: Action Bars loaded")
