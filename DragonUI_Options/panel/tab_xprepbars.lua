-- ============================================================================
-- DragonUI Options - XP & Rep Bars Tab
-- ============================================================================
local addon = DragonUI
if not addon then return end

local Panel = addon.OptionsPanel
local C = addon.PanelControls

local function BuildXpRepTab(scroll)
    -- ====================================================================
    -- XP BAR POSITIONING
    -- ====================================================================
    local xpSection = C:AddSection(scroll, "XP Bar Positioning")

    C:AddSlider(xpSection, {
        label = "Both Bars Y Offset",
        desc = "Vertical offset when both XP and Reputation bars are visible.",
        dbPath = "xprepbar.bothbar_offset",
        min = 0, max = 100, step = 1,
        width = 200,
        callback = function()
            if addon.RefreshXpRepBarPosition then addon.RefreshXpRepBarPosition() end
        end,
    })

    C:AddSlider(xpSection, {
        label = "Single Bar Y Offset",
        desc = "Vertical offset when only one bar is visible.",
        dbPath = "xprepbar.singlebar_offset",
        min = 0, max = 100, step = 1,
        width = 200,
        callback = function()
            if addon.RefreshXpRepBarPosition then addon.RefreshXpRepBarPosition() end
        end,
    })

    C:AddSlider(xpSection, {
        label = "No Bar Y Offset",
        desc = "Vertical offset when no bars are visible.",
        dbPath = "xprepbar.nobar_offset",
        min = 0, max = 100, step = 1,
        width = 200,
        callback = function()
            if addon.RefreshXpRepBarPosition then addon.RefreshXpRepBarPosition() end
        end,
    })

    C:AddSlider(xpSection, {
        label = "Experience Bar Scale",
        desc = "Scale of the experience bar.",
        dbPath = "xprepbar.expbar_scale",
        min = 0.5, max = 1.5, step = 0.05,
        width = 200,
        callback = function()
            if addon.RefreshXpBarPosition then addon.RefreshXpBarPosition() end
        end,
    })

    -- ====================================================================
    -- REPUTATION BAR POSITIONING
    -- ====================================================================
    local repSection = C:AddSection(scroll, "Reputation Bar Positioning")

    C:AddSlider(repSection, {
        label = "Rep Bar Above XP Offset",
        desc = "Offset when reputation bar is displayed above the XP bar.",
        dbPath = "xprepbar.repbar_abovexp_offset",
        min = 0, max = 50, step = 1,
        width = 200,
        callback = function()
            if addon.RefreshRepBarPosition then addon.RefreshRepBarPosition() end
        end,
    })

    C:AddSlider(repSection, {
        label = "Rep Bar Offset",
        desc = "General reputation bar vertical offset.",
        dbPath = "xprepbar.repbar_offset",
        min = 0, max = 50, step = 1,
        width = 200,
        callback = function()
            if addon.RefreshRepBarPosition then addon.RefreshRepBarPosition() end
        end,
    })

    C:AddSlider(repSection, {
        label = "Reputation Bar Scale",
        desc = "Scale of the reputation bar.",
        dbPath = "xprepbar.repbar_scale",
        min = 0.5, max = 1.5, step = 0.05,
        width = 200,
        callback = function()
            if addon.RefreshRepBarPosition then addon.RefreshRepBarPosition() end
        end,
    })

    -- ====================================================================
    -- DISPLAY OPTIONS
    -- ====================================================================
    local displaySection = C:AddSection(scroll, "Display Options")

    C:AddToggle(displaySection, {
        label = "Show Exhaustion Tick",
        desc = "Show the rested XP tick indicator on the experience bar.",
        dbPath = "style.exhaustion_tick",
        callback = function()
            if addon.UpdateExhaustionTick then addon.UpdateExhaustionTick() end
        end,
    })
end

-- Register the tab (order 5 = after Additional Bars)
Panel:RegisterTab("xprepbars", "XP & Rep Bars", BuildXpRepTab, 5)

print("|cFF00FF00[DragonUI]|r Panel tab: XP & Rep Bars loaded")
