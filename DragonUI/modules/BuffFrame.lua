--[[
    Original code by Dmitriy (RetailUI) - Licensed under MIT License
    Adapted for DragonUI with DragonflightUI-inspired positioning control
]]

local addon = select(2, ...);

--  CREATE MODULE USING THE DRAGONUI SYSTEM
local BuffFrameModule = {}
addon.BuffFrameModule = BuffFrameModule

-- Register with ModuleRegistry (if available)
if addon.RegisterModule then
    addon:RegisterModule("buffs", BuffFrameModule, "Buff Frame", "Custom buff frame styling, positioning and toggle button")
end

--  LOCAL VARIABLES
local buffFrame = nil
local toggleButton = nil
local dragonUIBuffFrame = nil  --  OUR CUSTOM FRAME

-- DEFAULT BUFF FRAME POSITION (must match database.lua defaults)
local BUFF_DEFAULT_ANCHOR = "TOPRIGHT"
local BUFF_DEFAULT_POSX = -300
local BUFF_DEFAULT_POSY = -39

-- Y position when a GM ticket or GM chat panel is open
local BUFF_TICKET_POSY = -60

-- Save original BuffFrame methods BEFORE anything modifies them
local original_BuffFrame_SetPoint = BuffFrame.SetPoint
local original_BuffFrame_ClearAllPoints = BuffFrame.ClearAllPoints

-- Flag: when true, our SetPoint/ClearAllPoints overrides are active
local buffFramePositionLocked = false

-- Check if buff frame is at default position (not moved by editor)
-- Uses a saved flag instead of coordinate comparison to avoid stale profile values
local function IsBuffFrameAtDefaultPosition()
    if not addon.db or not addon.db.profile or not addon.db.profile.widgets or not addon.db.profile.widgets.buffs then
        return true
    end
    return not addon.db.profile.widgets.buffs.custom_position
end

--  FUNCTION TO REPLACE BUFFFRAME (TOGGLE BUTTON)
local function ReplaceBlizzardFrame(frame)
    frame.toggleButton = frame.toggleButton or CreateFrame('Button', nil, UIParent)
    toggleButton = frame.toggleButton
    toggleButton.toggle = true
    toggleButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 12, -6)
    toggleButton:SetSize(9, 17)
    toggleButton:SetHitRectInsets(0, 0, 0, 0)

    local normalTexture = toggleButton:GetNormalTexture() or toggleButton:CreateTexture(nil, "BORDER")
    normalTexture:SetAllPoints(toggleButton)
    SetAtlasTexture(normalTexture, 'CollapseButton-Right')
    toggleButton:SetNormalTexture(normalTexture)

    local highlightTexture = toggleButton:GetHighlightTexture() or toggleButton:CreateTexture(nil, "HIGHLIGHT")
    highlightTexture:SetAllPoints(toggleButton)
    SetAtlasTexture(highlightTexture, 'CollapseButton-Right')
    toggleButton:SetHighlightTexture(highlightTexture)

    toggleButton:SetScript("OnClick", function(self)
        if self.toggle then
            local normalTexture = self:GetNormalTexture()
            SetAtlasTexture(normalTexture, 'CollapseButton-Left')
            local highlightTexture = toggleButton:GetHighlightTexture()
            SetAtlasTexture(highlightTexture, 'CollapseButton-Left')

            for index = 1, BUFF_ACTUAL_DISPLAY do
                local button = _G['BuffButton' .. index]
                if button then
                    button:Hide()
                end
            end
        else
            local normalTexture = self:GetNormalTexture()
            SetAtlasTexture(normalTexture, 'CollapseButton-Right')
            local highlightTexture = toggleButton:GetHighlightTexture()
            SetAtlasTexture(highlightTexture, 'CollapseButton-Right')

            for index = 1, BUFF_ACTUAL_DISPLAY do
                local button = _G['BuffButton' .. index]
                if button then
                    button:Show()
                end
            end
        end

        self.toggle = not self.toggle
    end)

    local consolidatedBuffFrame = ConsolidatedBuffs
    consolidatedBuffFrame:SetMovable(true)
    consolidatedBuffFrame:SetUserPlaced(true)
    consolidatedBuffFrame:ClearAllPoints()
    consolidatedBuffFrame:SetPoint("LEFT", toggleButton, "RIGHT", 6, 0)
end

--  FUNCTION TO SHOW/HIDE THE BUTTON BASED ON BUFFS
local function ShowToggleButtonIf(condition)
    if condition then
        dragonUIBuffFrame.toggleButton:Show()
    else
        dragonUIBuffFrame.toggleButton:Hide()
    end
end

--  FUNCTION TO COUNT BUFFS
local function GetUnitBuffCount(unit, range)
    local count = 0
    for index = 1, range do
        local name = UnitBuff(unit, index)
        if name then
            count = count + 1
        end
    end
    return count
end

-- ============================================================================
-- POSITIONING SYSTEM
-- We permanently override BuffFrame.SetPoint and ClearAllPoints so that
-- NO Blizzard code (BuffFrame_Update, UIParent_ManageFramePositions, etc.)
-- can move BuffFrame. Every SetPoint call on BuffFrame gets redirected to
-- anchor it to our dragonUIBuffFrame. We only touch dragonUIBuffFrame position.
-- ============================================================================

--  FUNCTION TO POSITION OUR FRAME (dragonUIBuffFrame moves, BuffFrame follows)
function BuffFrameModule:UpdatePosition()
    if not dragonUIBuffFrame then return end
    if not addon.db or not addon.db.profile or not addon.db.profile.widgets or not addon.db.profile.widgets.buffs then
        return
    end
    
    local widgetOptions = addon.db.profile.widgets.buffs
    
    if IsBuffFrameAtDefaultPosition() then
        -- DEFAULT POSITION: shift down when ticket/GM panel is open
        local ticketOpen = (TicketStatusFrame and TicketStatusFrame:IsShown())
                        or (GMChatStatusFrame and GMChatStatusFrame:IsShown())
        local posY = ticketOpen and BUFF_TICKET_POSY or BUFF_DEFAULT_POSY
        dragonUIBuffFrame:ClearAllPoints()
        dragonUIBuffFrame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", BUFF_DEFAULT_POSX, posY)
    else
        -- CUSTOM POSITION (editor): use saved coordinates, ignore tickets
        dragonUIBuffFrame:ClearAllPoints()
        dragonUIBuffFrame:SetPoint(widgetOptions.anchor, widgetOptions.posX, widgetOptions.posY)
    end
end

--  FUNCTION TO ENABLE/DISABLE THE MODULE
function BuffFrameModule:Toggle(enabled)
    if not addon.db or not addon.db.profile then return end
    
    addon.db.profile.buffs.enabled = enabled
    
    if enabled then
        self:Enable()
    else
        self:Disable()
    end
end

--  FUNCTION TO ENABLE THE MODULE
function BuffFrameModule:Enable()
    if not addon.db.profile.buffs.enabled then return end
    
    --  CREATE BUFFFRAME USING CreateUIFrame
    dragonUIBuffFrame = addon.CreateUIFrame(BuffFrame:GetWidth(), BuffFrame:GetHeight(), "Auras")
    
    --  REGISTER IN CENTRALIZED SYSTEM
    addon:RegisterEditableFrame({
        name = "buffs",
        frame = dragonUIBuffFrame,
        blizzardFrame = BuffFrame,
        configPath = {"widgets", "buffs"},
        onHide = function()
            -- After editor saves position, check if it matches the default
            local w = addon.db.profile.widgets.buffs
            local isDefault = w.anchor == BUFF_DEFAULT_ANCHOR
                and math.abs(w.posX - BUFF_DEFAULT_POSX) <= 5
                and math.abs(w.posY - BUFF_DEFAULT_POSY) <= 5
            w.custom_position = not isDefault
            self:UpdatePosition()
        end,
        module = self
    })
    
    -- PERMANENTLY OVERRIDE BuffFrame positioning methods.
    -- Every call to BuffFrame:SetPoint() from ANY code path (BuffFrame_Update,
    -- UIParent_ManageFramePositions, etc.) gets redirected to anchor BuffFrame
    -- to our dragonUIBuffFrame. This is the ONLY reliable way to prevent
    -- Blizzard from moving the buff icons.
    buffFramePositionLocked = true
    
    BuffFrame.ClearAllPoints = function(self)
        -- Noop: don't let anyone clear BuffFrame's anchor.
        -- Our SetPoint override handles re-anchoring when needed.
    end
    
    BuffFrame.SetPoint = function(self, ...)
        -- ALWAYS redirect: anchor BuffFrame to our controlled frame
        if not buffFramePositionLocked or not dragonUIBuffFrame then
            -- Module disabled or not ready: use original
            return original_BuffFrame_SetPoint(self, ...)
        end
        -- Redirect to our frame
        original_BuffFrame_ClearAllPoints(self)
        original_BuffFrame_SetPoint(self, "TOPRIGHT", dragonUIBuffFrame, "TOPRIGHT", 0, 0)
        -- DON'T call UpdatePosition() here - it would reset dragonUIBuffFrame
        -- position during editor drag. UpdatePosition is called on events instead.
    end
    
    -- Set initial position: anchor BuffFrame to our frame
    original_BuffFrame_ClearAllPoints(BuffFrame)
    original_BuffFrame_SetPoint(BuffFrame, "TOPRIGHT", dragonUIBuffFrame, "TOPRIGHT", 0, 0)
    BuffFrameModule:UpdatePosition()
    
    -- Hook UIParent_ManageFramePositions: this fires when ticket opens/closes.
    -- We update our frame position so it shifts down for tickets at default pos.
    if not BuffFrameModule._hookedManagePositions then
        BuffFrameModule._hookedManagePositions = true
        hooksecurefunc("UIParent_ManageFramePositions", function()
            if not dragonUIBuffFrame then return end
            if not addon.db or not addon.db.profile or not addon.db.profile.buffs
               or not addon.db.profile.buffs.enabled then return end
            BuffFrameModule:UpdatePosition()
        end)
    end
    
    -- Also hook TicketStatusFrame Show/Hide directly for reliable detection
    if not BuffFrameModule._hookedTicketFrame then
        BuffFrameModule._hookedTicketFrame = true
        if TicketStatusFrame then
            hooksecurefunc(TicketStatusFrame, "Show", function()
                if dragonUIBuffFrame and IsBuffFrameAtDefaultPosition() then
                    BuffFrameModule:UpdatePosition()
                end
            end)
            hooksecurefunc(TicketStatusFrame, "Hide", function()
                if dragonUIBuffFrame and IsBuffFrameAtDefaultPosition() then
                    BuffFrameModule:UpdatePosition()
                end
            end)
        end
        if GMChatStatusFrame then
            hooksecurefunc(GMChatStatusFrame, "Show", function()
                if dragonUIBuffFrame and IsBuffFrameAtDefaultPosition() then
                    BuffFrameModule:UpdatePosition()
                end
            end)
            hooksecurefunc(GMChatStatusFrame, "Hide", function()
                if dragonUIBuffFrame and IsBuffFrameAtDefaultPosition() then
                    BuffFrameModule:UpdatePosition()
                end
            end)
        end
    end
    
    --  CONFIGURE EVENTS
    if not buffFrame then
        buffFrame = CreateFrame("Frame")
        buffFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
        buffFrame:RegisterEvent("UNIT_AURA")
        buffFrame:RegisterEvent("UNIT_ENTERED_VEHICLE")
        buffFrame:RegisterEvent("UNIT_EXITED_VEHICLE")
        
        buffFrame:SetScript("OnEvent", function(self, event, unit)
            if event == "PLAYER_ENTERING_WORLD" then
                ReplaceBlizzardFrame(dragonUIBuffFrame)
                ShowToggleButtonIf(GetUnitBuffCount("player", 16) > 0)
                BuffFrameModule:UpdatePosition()
                
                -- Reposition the GM ticket frame so it doesn't overlap the minimap
                if TicketStatusFrame then
                    TicketStatusFrame:ClearAllPoints()
                    TicketStatusFrame:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -300, -5)
                end
            elseif event == "UNIT_AURA" then
                if unit == 'vehicle' then
                    ShowToggleButtonIf(GetUnitBuffCount("vehicle", 16) > 0)
                elseif unit == 'player' then
                    ShowToggleButtonIf(GetUnitBuffCount("player", 16) > 0)
                end
            elseif event == "UNIT_ENTERED_VEHICLE" then
                if unit == 'player' then
                    ShowToggleButtonIf(GetUnitBuffCount("vehicle", 16) > 0)
                end
            elseif event == "UNIT_EXITED_VEHICLE" then
                if unit == 'player' then
                    ShowToggleButtonIf(GetUnitBuffCount("player", 16) > 0)
                end
            end
        end)
    end
end

--  FUNCTION TO DISABLE THE MODULE
function BuffFrameModule:Disable()
    -- Restore original BuffFrame positioning methods
    buffFramePositionLocked = false
    BuffFrame.SetPoint = original_BuffFrame_SetPoint
    BuffFrame.ClearAllPoints = original_BuffFrame_ClearAllPoints
    
    if buffFrame then
        buffFrame:UnregisterAllEvents()
        buffFrame:SetScript("OnEvent", nil)
        buffFrame = nil
    end
    
    if toggleButton then
        toggleButton:Hide()
        toggleButton = nil
    end
    
    if dragonUIBuffFrame then
        dragonUIBuffFrame:Hide()
        dragonUIBuffFrame = nil
    end
end

--  AUTOMATIC INITIALIZATION
local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("ADDON_LOADED")
initFrame:SetScript("OnEvent", function(self, event, addonName)
    if addonName == "DragonUI" then
        if addon.db and addon.db.profile and addon.db.profile.buffs and addon.db.profile.buffs.enabled then
            BuffFrameModule:Enable()
        end
        self:UnregisterEvent("ADDON_LOADED")
    end
end)

--  FUNCTION TO BE CALLED FROM OPTIONS.LUA
function addon:RefreshBuffFrame()
    if BuffFrameModule and addon.db.profile.buffs.enabled then
        BuffFrameModule:UpdatePosition()
    end
end