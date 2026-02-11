--[[
================================================================================
DragonUI Options Panel - Minimap Tab
================================================================================
Minimap scale, tracking, clock, display settings.
================================================================================
]]

local addon = DragonUI
if not addon then return end

local C = addon.PanelControls
local Panel = addon.OptionsPanel

-- ============================================================================
-- MINIMAP TAB BUILDER
-- ============================================================================

local function RefreshMinimap()
    if addon.MinimapModule then
        addon.MinimapModule:UpdateSettings()
    end
end

local function BuildMinimapTab(scroll)
    -- ====================================================================
    -- BASIC SETTINGS
    -- ====================================================================
    local basic = C:AddSection(scroll, "Basic Settings")

    C:AddSlider(basic, {
        label = "Scale",
        dbPath = "minimap.scale",
        min = 0.5, max = 2.0, step = 0.1,
        width = 200,
        callback = RefreshMinimap,
    })

    C:AddSlider(basic, {
        label = "Border Alpha",
        desc = "Top border alpha (0 to hide).",
        dbPath = "minimap.border_alpha",
        min = 0, max = 1, step = 0.1,
        width = 200,
        callback = function()
            local val = C:GetDBValue("minimap.border_alpha") or 1
            if MinimapBorderTop then MinimapBorderTop:SetAlpha(val) end
        end,
    })

    C:AddToggle(basic, {
        label = "Addon Button Skin",
        desc = "Apply DragonUI border styling to addon icons.",
        dbPath = "minimap.addon_button_skin",
        callback = function()
            if addon.RefreshMinimap then addon:RefreshMinimap() end
        end,
    })

    C:AddToggle(basic, {
        label = "Addon Button Fade",
        desc = "Addon icons fade out when not hovered (requires Addon Button Skin).",
        dbPath = "minimap.addon_button_fade",
        disabled = function()
            return not C:GetDBValue("minimap.addon_button_skin")
        end,
        callback = function()
            if addon.RefreshMinimap then addon:RefreshMinimap() end
        end,
    })

    C:AddToggle(basic, {
        label = "New Blip Style",
        desc = "Use newer-style minimap blip icons.",
        dbPath = "minimap.blip_skin",
        callback = RefreshMinimap,
    })

    C:AddSlider(basic, {
        label = "Player Arrow Size",
        dbPath = "minimap.player_arrow_size",
        min = 8, max = 50, step = 1,
        width = 200,
        callback = RefreshMinimap,
    })

    -- ====================================================================
    -- TIME & CALENDAR
    -- ====================================================================
    local time = C:AddSection(scroll, "Time & Calendar")

    C:AddToggle(time, {
        label = "Show Clock",
        dbPath = "minimap.clock",
        callback = RefreshMinimap,
    })

    C:AddToggle(time, {
        label = "Show Calendar",
        dbPath = "minimap.calendar",
        callback = function()
            local val = C:GetDBValue("minimap.calendar")
            if GameTimeFrame then
                if val then GameTimeFrame:Show() else GameTimeFrame:Hide() end
            end
        end,
    })

    C:AddSlider(time, {
        label = "Clock Font Size",
        dbPath = "minimap.clock_font_size",
        min = 8, max = 20, step = 1,
        width = 200,
        callback = RefreshMinimap,
    })

    -- ====================================================================
    -- DISPLAY SETTINGS
    -- ====================================================================
    local display = C:AddSection(scroll, "Display Settings")

    C:AddToggle(display, {
        label = "Tracking Icons",
        desc = "Show current tracking icons (old style).",
        dbPath = "minimap.tracking_icons",
        callback = function()
            if addon.MinimapModule then addon.MinimapModule:UpdateTrackingIcon() end
        end,
    })

    C:AddToggle(display, {
        label = "Zoom Buttons",
        desc = "Show zoom buttons (+/-).",
        dbPath = "minimap.zoom_buttons",
        callback = RefreshMinimap,
    })

    C:AddSlider(display, {
        label = "Zone Text Font Size",
        desc = "Font size of the zone text above the minimap.",
        dbPath = "minimap.zonetext_font_size",
        min = 8, max = 20, step = 1,
        width = 200,
        callback = RefreshMinimap,
    })

    C:AddButton(display, {
        label = "Reset Minimap Position",
        width = 200,
        callback = function()
            if addon.ResetMinimapPosition then
                addon.ResetMinimapPosition()
            end
            print("|cFF00FF00[DragonUI]|r Minimap position reset.")
        end,
    })
end

-- Register the tab
Panel:RegisterTab("minimap", "Minimap", BuildMinimapTab, 8)

print("|cFF00FF00[DragonUI]|r Panel tab: Minimap loaded")
