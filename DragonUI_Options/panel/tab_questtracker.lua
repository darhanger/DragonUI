--[[
================================================================================
DragonUI Options Panel - Quest Tracker Tab
================================================================================
Quest tracker position and behavior.
================================================================================
]]

local addon = DragonUI
if not addon then return end

local C = addon.PanelControls
local Panel = addon.OptionsPanel

-- ============================================================================
-- QUEST TRACKER TAB BUILDER
-- ============================================================================

local anchorValues = {
    TOPRIGHT    = "Top Right",
    TOPLEFT     = "Top Left",
    BOTTOMRIGHT = "Bottom Right",
    BOTTOMLEFT  = "Bottom Left",
    CENTER      = "Center",
}

local function RefreshQT()
    if addon.RefreshQuestTracker then addon.RefreshQuestTracker() end
end

local function BuildQuesttrackerTab(scroll)
    local section = C:AddSection(scroll, "Quest Tracker")

    C:AddDescription(section, "Position and display settings for the objective tracker.")

    C:AddToggle(section, {
        label = "Show Header Background",
        desc = "Show/hide the decorative header background texture.",
        getFunc = function()
            return C:GetDBValue("questtracker.show_header") ~= false
        end,
        setFunc = function(val)
            C:SetDBValue("questtracker.show_header", val)
            RefreshQT()
        end,
    })

    C:AddDropdown(section, {
        label = "Anchor Point",
        desc = "Screen anchor point for the quest tracker.",
        dbPath = "questtracker.anchor",
        values = anchorValues,
        callback = RefreshQT,
    })

    C:AddSlider(section, {
        label = "X Position",
        dbPath = "questtracker.x",
        min = -500, max = 500, step = 1,
        width = 200,
        callback = RefreshQT,
    })

    C:AddSlider(section, {
        label = "Y Position",
        dbPath = "questtracker.y",
        min = -500, max = 500, step = 1,
        width = 200,
        callback = RefreshQT,
    })

    C:AddButton(section, {
        label = "Reset Position",
        width = 160,
        callback = function()
            C:SetDBValue("questtracker.anchor", "TOPRIGHT")
            C:SetDBValue("questtracker.x", -140)
            C:SetDBValue("questtracker.y", -255)
            RefreshQT()
            -- Refresh tab to update controls
            Panel:SelectTab("questtracker")
        end,
    })
end

-- Register the tab
Panel:RegisterTab("questtracker", "Quest Tracker", BuildQuesttrackerTab, 10)

print("|cFF00FF00[DragonUI]|r Panel tab: Quest Tracker loaded")
