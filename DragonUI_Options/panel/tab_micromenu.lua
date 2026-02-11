--[[
================================================================================
DragonUI Options Panel - Micro Menu Tab
================================================================================
Micro menu, bags, XP/rep bars, additional bars.
================================================================================
]]

local addon = DragonUI
if not addon then return end

local C = addon.PanelControls
local Panel = addon.OptionsPanel

-- ============================================================================
-- MICRO MENU TAB BUILDER
-- ============================================================================

local function BuildMicromenuTab(scroll)
    -- ====================================================================
    -- MICRO MENU
    -- ====================================================================
    local menu = C:AddSection(scroll, "Micro Menu")

    C:AddToggle(menu, {
        label = "Grayscale Icons",
        desc = "Use grayscale icons instead of colored icons.",
        dbPath = "micromenu.grayscale_icons",
        requiresReload = true,
    })

    -- Mode-aware scale
    local modeKey = function()
        return (C:GetDBValue("micromenu.grayscale_icons") and "grayscale" or "normal")
    end

    C:AddSlider(menu, {
        label = "Menu Scale",
        getFunc = function()
            return C:GetDBValue("micromenu." .. modeKey() .. ".scale_menu")
        end,
        setFunc = function(val)
            C:SetDBValue("micromenu." .. modeKey() .. ".scale_menu", val)
            if addon.RefreshMicromenu then addon.RefreshMicromenu() end
        end,
        min = 0.5, max = 3.0, step = 0.1,
        width = 200,
    })

    C:AddSlider(menu, {
        label = "Icon Spacing",
        getFunc = function()
            return C:GetDBValue("micromenu." .. modeKey() .. ".icon_spacing")
        end,
        setFunc = function(val)
            C:SetDBValue("micromenu." .. modeKey() .. ".icon_spacing", val)
            if addon.RefreshMicromenu then addon.RefreshMicromenu() end
        end,
        min = 5, max = 40, step = 1,
        width = 200,
    })

    C:AddToggle(menu, {
        label = "Hide on Vehicle",
        desc = "Hide micromenu and bags while in a vehicle.",
        dbPath = "micromenu.hide_on_vehicle",
        callback = function()
            if addon.RefreshMicromenuVehicle then addon.RefreshMicromenuVehicle() end
            if addon.RefreshBagsVehicle then addon.RefreshBagsVehicle() end
        end,
    })

    -- ====================================================================
    -- BAGS
    -- ====================================================================
    local bags = C:AddSection(scroll, "Bags")

    C:AddSlider(bags, {
        label = "Bag Bar Scale",
        dbPath = "bags.scale",
        min = 0.5, max = 2.0, step = 0.1,
        width = 200,
        callback = function()
            if addon.RefreshBagsPosition then addon.RefreshBagsPosition() end
        end,
    })
end

-- Register the tab
Panel:RegisterTab("micromenu", "Micro Menu", BuildMicromenuTab, 9)

print("|cFF00FF00[DragonUI]|r Panel tab: Micro Menu loaded")
