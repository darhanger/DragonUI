-- ============================================================================
-- DragonUI Options - XP & Rep Bars Tab
-- ============================================================================
local addon = DragonUI
if not addon then return end

local Panel = addon.OptionsPanel
local C = addon.PanelControls

-- Shared callback: refresh the entire XP/Rep bar system
local function RefreshBars()
    if addon.RefreshXpRepBars then addon.RefreshXpRepBars() end
end

local function BuildXpRepTab(scroll)
    local isDFUI = (C:GetDBValue("xprepbar.style") or "dragonflightui") == "dragonflightui"
    local isRetail = not isDFUI

    -- ====================================================================
    -- STYLE SELECTOR
    -- ====================================================================
    local styleSection = C:AddSection(scroll, "Bar Style")

    C:AddDropdown(styleSection, {
        label = "XP / Rep Bar Style",
        desc = "DragonflightUI: fully custom bars with rested XP background.\nRetailUI: atlas-based reskin of Blizzard bars.\n\nChanging style requires a UI reload.",
        dbPath = "xprepbar.style",
        values = {
            dragonflightui = "DragonflightUI",
            retailui = "RetailUI",
        },
        width = 200,
        callback = function()
            -- Sync style.xpbar for legacy compat
            local newStyle = C:GetDBValue("xprepbar.style")
            C:SetDBValue("style.xpbar", newStyle)
            -- Prompt reload — style is saved to DB but NOT applied live.
            -- On reload, the new style initializes cleanly from scratch.
            StaticPopupDialogs["DRAGONUI_RELOAD_XPSTYLE"] = {
                text = "XP bar style changed to " .. (newStyle == "retailui" and "RetailUI" or "DragonflightUI") .. ".\nA UI reload is required to apply this change.",
                button1 = "Reload Now",
                button2 = "Cancel",
                OnAccept = function() ReloadUI() end,
                OnCancel = function()
                    -- Revert the DB value if user cancels
                    local oldStyle = (newStyle == "retailui") and "dragonflightui" or "retailui"
                    C:SetDBValue("xprepbar.style", oldStyle)
                    C:SetDBValue("style.xpbar", oldStyle)
                    Panel:SelectTab("xprepbars")
                end,
                timeout = 0,
                whileDead = true,
                hideOnEscape = false,
                preferredIndex = 3,
            }
            StaticPopup_Show("DRAGONUI_RELOAD_XPSTYLE")
        end,
    })

    -- ====================================================================
    -- BAR DIMENSIONS & SCALE
    -- ====================================================================
    local sizeSection = C:AddSection(scroll, "Size & Scale")

    C:AddSlider(sizeSection, {
        label = "Bar Height",
        desc = "Height of the XP and Reputation bars (in pixels).",
        dbPath = isDFUI and "xprepbar.bar_height_dfui" or "xprepbar.bar_height_retailui",
        min = 6, max = 30, step = 1,
        width = 200,
        callback = RefreshBars,
    })

    C:AddSlider(sizeSection, {
        label = "Experience Bar Scale",
        desc = "Scale of the experience bar.",
        dbPath = "xprepbar.expbar_scale",
        min = 0.5, max = 1.5, step = 0.05,
        width = 200,
        callback = RefreshBars,
    })

    C:AddSlider(sizeSection, {
        label = "Reputation Bar Scale",
        desc = "Scale of the reputation bar.",
        dbPath = "xprepbar.repbar_scale",
        min = 0.5, max = 1.5, step = 0.05,
        width = 200,
        callback = RefreshBars,
    })

    -- ====================================================================
    -- RESTED XP INDICATORS
    -- ====================================================================
    local restedSection = C:AddSection(scroll, "Rested XP")

    C:AddToggle(restedSection, {
        label = "Show Rested XP Background",
        desc = "Display a translucent bar showing the total available rested XP range.\n(DragonflightUI style only)",
        dbPath = "xprepbar.show_rested_bar",
        disabled = isRetail,
        callback = RefreshBars,
    })

    C:AddToggle(restedSection, {
        label = "Show Exhaustion Tick",
        desc = "Show the exhaustion tick indicator on the XP bar, marking where rested XP ends.",
        dbPath = "style.exhaustion_tick",
        callback = function()
            if addon.UpdateExhaustionTick then addon.UpdateExhaustionTick() end
        end,
    })

    -- ====================================================================
    -- TEXT DISPLAY
    -- ====================================================================
    local textSection = C:AddSection(scroll, "Text Display")

    C:AddToggle(textSection, {
        label = "Always Show Text",
        desc = "Always display XP/Rep text instead of only on hover.",
        dbPath = "xprepbar.always_show_text",
        callback = RefreshBars,
    })

    C:AddToggle(textSection, {
        label = "Show XP Percentage",
        desc = "Display XP percentage alongside the value text.",
        dbPath = "xprepbar.show_xp_percent",
        callback = RefreshBars,
    })
end

-- Register the tab (order 5 = after Additional Bars)
Panel:RegisterTab("xprepbars", "XP & Rep Bars", BuildXpRepTab, 5)
