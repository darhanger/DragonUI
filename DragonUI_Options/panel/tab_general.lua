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
local L = addon.L
local LO = addon.LO

-- ============================================================================
-- GENERAL TAB BUILDER
-- ============================================================================

local function BuildGeneralTab(scroll)
    -- ====================================================================
    -- ABOUT
    -- ====================================================================
    local about = C:AddSection(scroll, LO["About"])

    C:AddLabel(about, "|cff1784d1" .. LO["DragonUI"] .. "|r")
    C:AddDescription(about, LO["Dragonflight-inspired UI for WotLK 3.3.5a."])
    C:AddSpacer(about)
    C:AddDescription(about, LO["Experimental Branch — This options panel is in early beta."])
    C:AddDescription(about, LO["Features may change or be incomplete. Report issues on GitHub."])
    C:AddSpacer(about)
    C:AddDescription(about, LO["Use /dragonui or /pi to toggle this panel."])

    C:AddSpacer(scroll)

    -- ====================================================================
    -- QUICK ACTIONS
    -- ====================================================================
    local actions = C:AddSection(scroll, LO["Quick Actions"])

    C:AddButton(actions, {
        label = LO["Editor Mode"],
        width = 200,
        callback = function()
            if addon.OptionsPanel then addon.OptionsPanel:Close() end
            if addon.EditorMode then
                addon.EditorMode:Toggle()
            end
        end,
    })

    C:AddButton(actions, {
        label = LO["KeyBind Mode"],
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
Panel:RegisterTab("general", LO["General"], BuildGeneralTab, 1)
