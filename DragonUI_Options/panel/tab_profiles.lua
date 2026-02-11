--[[
================================================================================
DragonUI Options Panel - Profiles Tab
================================================================================
Profile management using AceDB-3.0 API directly.
Provides: select profile, copy, delete, reset.
================================================================================
]]

local addon = DragonUI
if not addon then return end

local AceGUI = LibStub("AceGUI-3.0")
local C = addon.PanelControls
local Panel = addon.OptionsPanel

-- ============================================================================
-- PROFILES TAB BUILDER
-- ============================================================================

local function BuildProfilesTab(scroll)
    local db = addon.db
    if not db then
        C:AddLabel(scroll, "|cFFFF0000Database not available.|r")
        return
    end

    C:AddLabel(scroll, "|cffFFD700Profiles|r", { color = C.Theme.textGold })
    C:AddDescription(scroll, "Save and switch between different configurations per character.")
    C:AddSpacer(scroll)

    -- ====================================================================
    -- CURRENT PROFILE
    -- ====================================================================
    local current = C:AddSection(scroll, "Current Profile")

    local currentProfile = db:GetCurrentProfile()
    C:AddLabel(current, "Active: |cff1784d1" .. currentProfile .. "|r")

    -- ====================================================================
    -- SELECT / CREATE PROFILE
    -- ====================================================================
    local selectSection = C:AddSection(scroll, "Switch or Create Profile")

    -- Build profile list for dropdown
    local function GetProfileList()
        local profiles = {}
        for _, name in ipairs(db:GetProfiles()) do
            profiles[name] = name
        end
        return profiles
    end

    C:AddDropdown(selectSection, {
        label = "Select Profile",
        getFunc = function() return db:GetCurrentProfile() end,
        setFunc = function(val)
            db:SetProfile(val)
            Panel:SelectTab("profiles")
        end,
        values = GetProfileList(),
    })

    -- New profile input
    local newName = AceGUI:Create("EditBox")
    newName:SetLabel("New Profile Name")
    newName:SetWidth(250)
    newName:SetCallback("OnEnterPressed", function(widget, event, text)
        if text and text ~= "" then
            db:SetProfile(text)
            widget:SetText("")
            Panel:SelectTab("profiles")
        end
    end)
    selectSection:AddChild(newName)

    -- ====================================================================
    -- COPY FROM
    -- ====================================================================
    local copySection = C:AddSection(scroll, "Copy From")

    C:AddDescription(copySection, "Copies all settings from the selected profile into your current one.")

    C:AddDropdown(copySection, {
        label = "Copy From",
        getFunc = function() return nil end,
        setFunc = function(val)
            if val then
                db:CopyProfile(val)
                print("|cFF00FF00[DragonUI]|r Copied profile: " .. val)
                Panel:SelectTab("profiles")
            end
        end,
        values = GetProfileList(),
    })

    -- ====================================================================
    -- DELETE
    -- ====================================================================
    local deleteSection = C:AddSection(scroll, "Delete Profile")

    C:AddDescription(deleteSection, "|cffFF6600Warning:|r Deleting a profile is permanent and cannot be undone.")

    -- Build list excluding current
    local function GetDeletableProfiles()
        local profiles = {}
        local current = db:GetCurrentProfile()
        for _, name in ipairs(db:GetProfiles()) do
            if name ~= current then
                profiles[name] = name
            end
        end
        return profiles
    end

    C:AddDropdown(deleteSection, {
        label = "Delete",
        getFunc = function() return nil end,
        setFunc = function(val)
            if val then
                db:DeleteProfile(val, true)
                print("|cFF00FF00[DragonUI]|r Deleted profile: " .. val)
                Panel:SelectTab("profiles")
            end
        end,
        values = GetDeletableProfiles(),
    })

    -- ====================================================================
    -- RESET
    -- ====================================================================
    local resetSection = C:AddSection(scroll, "Reset Current Profile")

    C:AddDescription(resetSection, "Restores the current profile to its defaults. This cannot be undone.")

    C:AddButton(resetSection, {
        label = "Reset Profile",
        width = 160,
        callback = function()
            -- Show confirmation dialog before resetting
            StaticPopupDialogs["DRAGONUI_RESET_PROFILE"] = StaticPopupDialogs["DRAGONUI_RESET_PROFILE"] or {
                text = "All changes will be lost and the UI will be reloaded.\nAre you sure you want to reset your profile?",
                button1 = "Yes",
                button2 = "No",
                OnAccept = function()
                    if addon.db then
                        addon.db:ResetProfile()
                        print("|cFF00FF00[DragonUI]|r Profile reset to defaults.")
                    end
                    ReloadUI()
                end,
                timeout = 0,
                whileDead = true,
                hideOnEscape = true,
                preferredIndex = 3,
            }
            StaticPopup_Show("DRAGONUI_RESET_PROFILE")
        end,
    })
end

-- Register the tab
Panel:RegisterTab("profiles", "Profiles", BuildProfilesTab, 99)

print("|cFF00FF00[DragonUI]|r Panel tab: Profiles loaded")
