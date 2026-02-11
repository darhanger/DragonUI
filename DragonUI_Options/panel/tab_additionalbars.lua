--[[
================================================================================
DragonUI Options Panel - Additional Bars Tab
================================================================================
Stance Bar, Pet Bar, Vehicle Bar, Totem Bar settings.
================================================================================
]]

local addon = DragonUI
if not addon then return end

local C = addon.PanelControls
local Panel = addon.OptionsPanel

-- ============================================================================
-- ADDITIONAL BARS TAB BUILDER
-- ============================================================================

local function BuildAdditionalBarsTab(scroll)
    C:AddDescription(scroll, "Bars that appear based on your class and situation.")

    -- ====================================================================
    -- STANCE BAR
    -- ====================================================================
    local stance = C:AddSection(scroll, "Stance Bar")

    C:AddSlider(stance, {
        label = "Button Size",
        dbPath = "additional.stance.button_size",
        min = 16, max = 64, step = 1,
        width = 200,
        callback = function()
            if addon.RefreshStance then addon.RefreshStance() end
        end,
    })

    C:AddSlider(stance, {
        label = "Button Spacing",
        dbPath = "additional.stance.button_spacing",
        min = 0, max = 20, step = 1,
        width = 200,
        callback = function()
            if addon.RefreshStance then addon.RefreshStance() end
        end,
    })

    -- ====================================================================
    -- PET BAR
    -- ====================================================================
    local pet = C:AddSection(scroll, "Pet Bar")

    C:AddToggle(pet, {
        label = "Show Empty Slots",
        dbPath = "additional.pet.grid",
        callback = function()
            if addon.RefreshPetbar then addon.RefreshPetbar() end
        end,
    })

    -- ====================================================================
    -- VEHICLE BAR
    -- ====================================================================
    local vehicle = C:AddSection(scroll, "Vehicle Bar")

    C:AddToggle(vehicle, {
        label = "Blizzard Art Style",
        desc = "Use Blizzard vehicle bar art with health/power display. Requires reload.",
        dbPath = "additional.vehicle.artstyle",
        requiresReload = true,
    })

    -- ====================================================================
    -- TOTEM BAR
    -- ====================================================================
    local totem = C:AddSection(scroll, "Totem Bar (Shaman)")

    C:AddSlider(totem, {
        label = "Button Size",
        getFunc = function()
            local cfg = addon.db.profile.additional.totem
            if cfg and cfg.button_size then return cfg.button_size end
            return addon.db.profile.additional.size or 31
        end,
        setFunc = function(val)
            if not addon.db.profile.additional.totem then
                addon.db.profile.additional.totem = {}
            end
            addon.db.profile.additional.totem.button_size = val
            if addon.RefreshMulticast then addon.RefreshMulticast(true) end
        end,
        min = 16, max = 64, step = 1,
        width = 200,
    })

    C:AddSlider(totem, {
        label = "Button Spacing",
        getFunc = function()
            local cfg = addon.db.profile.additional.totem
            if cfg and cfg.button_spacing then return cfg.button_spacing end
            return addon.db.profile.additional.spacing or 6
        end,
        setFunc = function(val)
            if not addon.db.profile.additional.totem then
                addon.db.profile.additional.totem = {}
            end
            addon.db.profile.additional.totem.button_spacing = val
            if addon.RefreshMulticast then addon.RefreshMulticast(true) end
        end,
        min = 0, max = 20, step = 1,
        width = 200,
    })
end

-- Register the tab (order 4 = right after Action Bars)
Panel:RegisterTab("additionalbars", "Additional Bars", BuildAdditionalBarsTab, 4)

print("|cFF00FF00[DragonUI]|r Panel tab: Additional Bars loaded")
