--[[
================================================================================
DragonUI Options Panel - General Tab
================================================================================
Editor Mode, KeyBind Mode, and general settings.
================================================================================
]]

local addon = DragonUI
if not addon then return end

local C = addon.PanelControls
local Panel = addon.OptionsPanel

-- ============================================================================
-- GENERAL TAB BUILDER
-- ============================================================================

local function BuildGeneralTab(scroll)
    -- ====================================================================
    -- ABOUT
    -- ====================================================================
    local about = C:AddSection(scroll, "About")

    C:AddLabel(about, "|cff1784d1DragonUI|r")
    C:AddDescription(about, "Dragonflight-inspired UI for WotLK 3.3.5a.")
    C:AddSpacer(about)
    C:AddDescription(about, "|cffff8800Experimental Branch|r — This options panel is in early beta.")
    C:AddDescription(about, "Features may change or be incomplete. Report issues on GitHub.")
    C:AddSpacer(about)
    C:AddDescription(about, "Use |cff1784d1/dragonui|r or |cff1784d1/pi|r to toggle this panel.")
    C:AddDescription(about, "Use |cff1784d1/dragonui legacy|r to open the classic AceConfig options.")

    C:AddSpacer(scroll)

    -- ====================================================================
    -- QUICK ACTIONS
    -- ====================================================================
    local actions = C:AddSection(scroll, "Quick Actions")

    C:AddButton(actions, {
        label = "Editor Mode",
        width = 200,
        callback = function()
            if addon.OptionsPanel then addon.OptionsPanel:Close() end
            if addon.EditorMode then
                addon.EditorMode:Toggle()
            end
        end,
    })

    C:AddButton(actions, {
        label = "KeyBind Mode",
        width = 200,
        callback = function()
            if addon.OptionsPanel then addon.OptionsPanel:Close() end
            if addon.KeyBindingModule and LibStub and LibStub("LibKeyBound-1.0", true) then
                LibStub("LibKeyBound-1.0"):Toggle()
            end
        end,
    })
end

-- Register the tab
Panel:RegisterTab("general", "General", BuildGeneralTab, 1)

print("|cFF00FF00[DragonUI]|r Panel tab: General loaded")
