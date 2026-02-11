--[[
================================================================================
DragonUI - API Functions
================================================================================
This file contains utility functions used throughout DragonUI.
These are general-purpose functions that can be used by any module.
================================================================================
]]

local addon = select(2, ...)

-- ============================================================================
-- TABLE UTILITIES
-- ============================================================================

-- Recursively copy tables
function addon.DeepCopy(source, target)
    target = target or {}
    for key, value in pairs(source) do
        if type(value) == "table" then
            if not target[key] then
                target[key] = {}
            end
            addon.DeepCopy(value, target[key])
        else
            target[key] = value
        end
    end
    return target
end

-- Count elements in a table (works with non-sequential tables)
function addon:tcount(tbl)
    local count = 0
    for _ in pairs(tbl) do count = count + 1 end
    return count
end

-- ============================================================================
-- FRAME CREATION AND MANAGEMENT
-- ============================================================================

-- Frames registry for editor mode
addon.frames = addon.frames or {}

-- Editor mode texture base path
local EDITMODE_TEXTURE_BASE = 'Interface\\AddOns\\DragonUI\\Textures\\Editmode\\'

-- Nineslice texture coordinates
local NINESLICE_COORDS = {
    highlight = {
        corner = {0.03125, 0.53125, 0.285156, 0.347656},
        topEdge = {0, 0.5, 0.0742188, 0.136719},
        bottomEdge = {0, 0.5, 0.00390625, 0.0664062},
        leftEdge = {0.0078125, 0.132812, 0, 1},
        rightEdge = {0.148438, 0.273438, 0, 1}
    },
    selected = {
        corner = {0.03125, 0.53125, 0.355469, 0.417969},
        topEdge = {0, 0.5, 0.214844, 0.277344},
        bottomEdge = {0, 0.5, 0.144531, 0.207031},
        leftEdge = {0.289062, 0.414062, 0, 1},
        rightEdge = {0.429688, 0.554688, 0, 1}
    }
}

-- Add nineslice border to a frame
local function AddNineslice(frame)
    frame.NineSlice = {}
    local slice = frame.NineSlice
    
    -- Top left corner (no rotation needed)
    slice.TopLeftCorner = frame:CreateTexture(nil, 'OVERLAY')
    slice.TopLeftCorner:SetSize(16, 16)
    slice.TopLeftCorner:SetPoint('TOPLEFT', -8, 8)
    
    -- Top right corner (will be rotated via SetTexCoord)
    slice.TopRightCorner = frame:CreateTexture(nil, 'OVERLAY')
    slice.TopRightCorner:SetSize(16, 16)
    slice.TopRightCorner:SetPoint('TOPRIGHT', 8, 8)
    
    -- Bottom left corner (will be rotated via SetTexCoord)
    slice.BottomLeftCorner = frame:CreateTexture(nil, 'OVERLAY')
    slice.BottomLeftCorner:SetSize(16, 16)
    slice.BottomLeftCorner:SetPoint('BOTTOMLEFT', -8, -8)
    
    -- Bottom right corner (will be rotated via SetTexCoord)
    slice.BottomRightCorner = frame:CreateTexture(nil, 'OVERLAY')
    slice.BottomRightCorner:SetSize(16, 16)
    slice.BottomRightCorner:SetPoint('BOTTOMRIGHT', 8, -8)
    
    -- Top edge (connects corners)
    slice.TopEdge = frame:CreateTexture(nil, 'OVERLAY')
    slice.TopEdge:SetPoint('TOPLEFT', slice.TopLeftCorner, 'TOPRIGHT')
    slice.TopEdge:SetPoint('BOTTOMRIGHT', slice.TopRightCorner, 'BOTTOMLEFT')
    
    -- Bottom edge
    slice.BottomEdge = frame:CreateTexture(nil, 'OVERLAY')
    slice.BottomEdge:SetPoint('TOPLEFT', slice.BottomLeftCorner, 'TOPRIGHT')
    slice.BottomEdge:SetPoint('BOTTOMRIGHT', slice.BottomRightCorner, 'BOTTOMLEFT')
    
    -- Left edge
    slice.LeftEdge = frame:CreateTexture(nil, 'OVERLAY')
    slice.LeftEdge:SetPoint('TOPLEFT', slice.TopLeftCorner, 'BOTTOMLEFT')
    slice.LeftEdge:SetPoint('BOTTOMRIGHT', slice.BottomLeftCorner, 'TOPRIGHT')
    
    -- Right edge
    slice.RightEdge = frame:CreateTexture(nil, 'OVERLAY')
    slice.RightEdge:SetPoint('TOPLEFT', slice.TopRightCorner, 'BOTTOMLEFT')
    slice.RightEdge:SetPoint('BOTTOMRIGHT', slice.BottomRightCorner, 'TOPRIGHT')
    
    -- Center (background)
    slice.Center = frame:CreateTexture(nil, 'BACKGROUND')
    slice.Center:SetPoint('TOPLEFT', 0, 0)
    slice.Center:SetPoint('BOTTOMRIGHT', 0, 0)
end

-- Helper function to apply rotated tex coords using 8-value SetTexCoord
-- SetTexCoord(ULx, ULy, LLx, LLy, URx, URy, LRx, LRy)
local function SetTexCoordRotated(texture, coords, rotation)
    local l, r, t, b = coords[1], coords[2], coords[3], coords[4]
    
    if rotation == 0 then
        -- Normal (0°): TopLeft corner
        texture:SetTexCoord(l, t, l, b, r, t, r, b)
    elseif rotation == 90 then
        -- 90° CW: BottomLeft corner
        texture:SetTexCoord(l, b, r, b, l, t, r, t)
    elseif rotation == 180 then
        -- 180°: BottomRight corner
        texture:SetTexCoord(r, b, r, t, l, b, l, t)
    elseif rotation == 270 then
        -- 270° CW (-90°): TopRight corner
        texture:SetTexCoord(r, t, l, t, r, b, l, b)
    end
end

-- Apply highlight or selected state to nineslice
local function SetNinesliceState(frame, selected)
    local slice = frame.NineSlice
    if not slice then return end
    
    local coords = selected and NINESLICE_COORDS.selected or NINESLICE_COORDS.highlight
    
    -- Corners use same texture with different coords and rotations
    local cornerTexture = EDITMODE_TEXTURE_BASE .. 'EditModeUI'
    
    -- TopLeft (0° - normal)
    slice.TopLeftCorner:SetTexture(cornerTexture)
    SetTexCoordRotated(slice.TopLeftCorner, coords.corner, 0)
    
    -- TopRight (90° CW)
    slice.TopRightCorner:SetTexture(cornerTexture)
    SetTexCoordRotated(slice.TopRightCorner, coords.corner, 90)
    
    -- BottomLeft (270° CW / -90°)
    slice.BottomLeftCorner:SetTexture(cornerTexture)
    SetTexCoordRotated(slice.BottomLeftCorner, coords.corner, 270)
    
    -- BottomRight (180°)
    slice.BottomRightCorner:SetTexture(cornerTexture)
    SetTexCoordRotated(slice.BottomRightCorner, coords.corner, 180)
    
    -- Edges
    slice.TopEdge:SetTexture(cornerTexture)
    slice.TopEdge:SetTexCoord(unpack(coords.topEdge))
    slice.BottomEdge:SetTexture(cornerTexture)
    slice.BottomEdge:SetTexCoord(unpack(coords.bottomEdge))
    
    local verticalTexture = EDITMODE_TEXTURE_BASE .. 'EditModeUIVertical'
    slice.LeftEdge:SetTexture(verticalTexture)
    slice.LeftEdge:SetTexCoord(unpack(coords.leftEdge))
    slice.RightEdge:SetTexture(verticalTexture)
    slice.RightEdge:SetTexCoord(unpack(coords.rightEdge))
    
    -- Center background
    local centerTexture = selected and 'EditModeUISelectedBackground' or 'EditModeUIHighlightBackground'
    slice.Center:SetTexture(EDITMODE_TEXTURE_BASE .. centerTexture)
    slice.Center:SetTexCoord(0, 1, 0, 1)
end

-- Show nineslice overlay
local function ShowNineslice(frame)
    local slice = frame.NineSlice
    if not slice then return end
    
    for _, part in pairs(slice) do
        part:Show()
    end
end

-- Hide nineslice overlay
local function HideNineslice(frame)
    local slice = frame.NineSlice
    if not slice then return end
    
    for _, part in pairs(slice) do
        part:Hide()
    end
end

-- Create a UI frame with editor mode support
function addon.CreateUIFrame(width, height, frameName)
    local frame = CreateFrame("Frame", 'DragonUI_' .. frameName, UIParent)
    frame:SetSize(width, height)

    frame:RegisterForDrag("LeftButton")
    frame:EnableMouse(false)
    frame:SetMovable(false)
    
    frame:SetScript("OnDragStart", function(self, button)
        self:StartMoving()
        -- Show selected state while dragging
        if self.NineSlice then
            SetNinesliceState(self, true)
        end
    end)
    
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        
        -- Return to highlight state
        if self.NineSlice then
            SetNinesliceState(self, false)
        end
        
        -- AUTO-SAVE: Find this frame in EditableFrames and save position automatically
        for name, frameData in pairs(addon.EditableFrames) do
            if frameData.frame == self then
                -- Save position automatically
                if #frameData.configPath == 2 then
                    addon.SaveUIFramePosition(frameData.frame, frameData.configPath[1], frameData.configPath[2])
                else
                    addon.SaveUIFramePosition(frameData.frame, frameData.configPath[1])
                end
                break
            end
        end
    end)

    frame:SetFrameLevel(100)
    frame:SetFrameStrata('FULLSCREEN')

    -- Create nineslice overlay (DragonflightUI style)
    AddNineslice(frame)
    SetNinesliceState(frame, false) -- Default to highlight state
    HideNineslice(frame) -- Start hidden
    
    -- Legacy editorTexture reference (for backwards compatibility)
    frame.editorTexture = frame.NineSlice.Center

    -- Text label for editor mode
    do
        local fontString = frame:CreateFontString(nil, "OVERLAY", 'GameFontNormal')
        fontString:SetPoint("CENTER", frame, "CENTER", 0, 0)
        fontString:SetText(frameName)
        fontString:Hide()
        frame.editorText = fontString
    end

    return frame
end

-- Global function alias for backwards compatibility
CreateUIFrame = addon.CreateUIFrame

-- Export nineslice functions for modules with custom behavior
addon.AddNineslice = AddNineslice
addon.SetNinesliceState = SetNinesliceState
addon.ShowNineslice = ShowNineslice
addon.HideNineslice = HideNineslice

-- ============================================================================
-- FRAME VISIBILITY FUNCTIONS (Editor Mode Support)
-- ============================================================================

-- Show a UI frame (disable editor mode for this frame)
function addon.ShowUIFrame(frame)
    frame:SetMovable(false)
    frame:EnableMouse(false)
    
    -- Hide nineslice overlay (new system)
    if frame.NineSlice then
        HideNineslice(frame)
    elseif frame.editorTexture then
        -- Legacy fallback for frames not using CreateUIFrame
        frame.editorTexture:Hide()
    end
    
    if frame.editorText then
        frame.editorText:Hide()
    end

    if addon.frames[frame] then
        for _, target in pairs(addon.frames[frame]) do
            target:SetAlpha(1)
        end
        addon.frames[frame] = nil
    end
end

-- Global function alias for backwards compatibility
ShowUIFrame = addon.ShowUIFrame

-- Hide a UI frame (enable editor mode for this frame)
function addon.HideUIFrame(frame, exclude)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    
    -- Show nineslice overlay (new system)
    if frame.NineSlice then
        SetNinesliceState(frame, false) -- Highlight state
        ShowNineslice(frame)
    elseif frame.editorTexture then
        -- Legacy fallback for frames not using CreateUIFrame
        frame.editorTexture:Show()
    end
    
    if frame.editorText then
        frame.editorText:Show()
    end

    addon.frames[frame] = {}
    exclude = exclude or {}

    for _, target in pairs(exclude) do
        target:SetAlpha(0)
        table.insert(addon.frames[frame], target)
    end
end

-- Global function alias for backwards compatibility
HideUIFrame = addon.HideUIFrame

-- ============================================================================
-- POSITION SAVE/LOAD FUNCTIONS
-- ============================================================================

-- Save frame position to database
function addon.SaveUIFramePosition(frame, configPath1, configPath2)
    if not frame then
        return
    end

    local anchor, _, relativePoint, posX, posY = frame:GetPoint(1)

    -- Handle nested paths (widgets.player)
    if configPath2 then
        -- Case: SaveUIFramePosition(frame, "widgets", "player")
        if not addon.db.profile[configPath1] then
            addon.db.profile[configPath1] = {}
        end

        if not addon.db.profile[configPath1][configPath2] then
            addon.db.profile[configPath1][configPath2] = {}
        end

        addon.db.profile[configPath1][configPath2].anchor = anchor or "CENTER"
        addon.db.profile[configPath1][configPath2].posX = posX or 0
        addon.db.profile[configPath1][configPath2].posY = posY or 0
    else
        -- Case: SaveUIFramePosition(frame, "minimap") - backwards compatibility
        local widgetName = configPath1
        
        if not addon.db.profile.widgets then
            addon.db.profile.widgets = {}
        end

        if not addon.db.profile.widgets[widgetName] then
            addon.db.profile.widgets[widgetName] = {}
        end

        addon.db.profile.widgets[widgetName].anchor = anchor or "CENTER"
        addon.db.profile.widgets[widgetName].posX = posX or 0
        addon.db.profile.widgets[widgetName].posY = posY or 0
    end
end

-- Global function alias for backwards compatibility
SaveUIFramePosition = addon.SaveUIFramePosition

-- Apply frame position from database
function addon.ApplyUIFramePosition(frame, configPath)
    if not frame or not configPath then
        return
    end

    local section, key = configPath:match("([^%.]+)%.([^%.]+)")
    if not section or not key then
        return
    end

    local config = addon.db.profile[section] and addon.db.profile[section][key]
    if not config or not config.override then
        return
    end

    frame:ClearAllPoints()
    frame:SetPoint(config.anchor or "CENTER", UIParent, config.anchorParent or "CENTER", config.x or 0, config.y or 0)
end

-- Global function alias for backwards compatibility
ApplyUIFramePosition = addon.ApplyUIFramePosition

-- ============================================================================
-- SETTINGS VALIDATION
-- ============================================================================

-- Check if settings exist and load defaults if needed
function addon.CheckSettingsExists(moduleTable, configPaths)
    local needsDefaults = false

    for _, configPath in pairs(configPaths) do
        local section, key = configPath:match("([^%.]+)%.([^%.]+)")
        if section and key then
            if not addon.db.profile[section] or not addon.db.profile[section][key] then
                needsDefaults = true
                break
            end
        end
    end

    if needsDefaults and moduleTable.LoadDefaultSettings then
        moduleTable:LoadDefaultSettings()
    end

    if moduleTable.UpdateWidgets then
        moduleTable:UpdateWidgets()
    end
end

-- Global function alias for backwards compatibility
CheckSettingsExists = addon.CheckSettingsExists

-- ============================================================================
-- EDITABLE FRAMES REGISTRY
-- Centralized system for managing moveable UI elements
-- ============================================================================

addon.EditableFrames = addon.EditableFrames or {}

-- Register a frame as editable
function addon:RegisterEditableFrame(frameInfo)
    local frameData = {
        name = frameInfo.name,                    -- "player", "minimap", "target"
        frame = frameInfo.frame,                  -- The auxiliary frame
        blizzardFrame = frameInfo.blizzardFrame,  -- Real Blizzard frame (optional)
        configPath = frameInfo.configPath,        -- {"widgets", "player"} or {"unitframe", "target"}
        onShow = frameInfo.onShow,                -- Optional function when showing editor
        onHide = frameInfo.onHide,                -- Optional function when hiding editor
        showTest = frameInfo.showTest,            -- Function to show with fake data
        hideTest = frameInfo.hideTest,            -- Function to hide fake frame
        hasTarget = frameInfo.hasTarget,          -- Function to check if should be visible
        editorVisible = frameInfo.editorVisible,  -- Function to check if frame should appear in editor mode
        module = frameInfo.module                 -- Reference to the module
    }
    
    self.EditableFrames[frameInfo.name] = frameData
end

-- Show all frames in editor mode
function addon:ShowAllEditableFrames()
    for name, frameData in pairs(self.EditableFrames) do
        if frameData.frame then
            -- Skip frames that explicitly declare they shouldn't appear in editor
            if frameData.editorVisible and not frameData.editorVisible() then
                frameData.frame:Hide()
            else
                addon.HideUIFrame(frameData.frame) -- Show green overlay

                -- Show frame with fake data if needed
                if frameData.showTest then
                    frameData.showTest()
                end

                if frameData.onShow then
                    frameData.onShow()
                end
            end
        end
    end
    print("|cFF00FF00[DragonUI]|r All editable frames shown for editing")
end

-- Hide all frames and save positions
function addon:HideAllEditableFrames(refresh)
    for name, frameData in pairs(self.EditableFrames) do
        if frameData.frame then
            addon.ShowUIFrame(frameData.frame) -- Hide green overlay
            
            -- Hide fake frame if it shouldn't be visible
            if frameData.hideTest then
                frameData.hideTest()
            end
            
            if refresh then
                -- Save position automatically (skip if configPath is nil - custom save logic)
                if frameData.configPath then
                    if #frameData.configPath == 2 then
                        addon.SaveUIFramePosition(frameData.frame, frameData.configPath[1], frameData.configPath[2])
                    else
                        addon.SaveUIFramePosition(frameData.frame, frameData.configPath[1])
                    end
                end
                
                if frameData.onHide then
                    frameData.onHide()
                end
            end
        end
    end
    print("|cFF00FF00[DragonUI]|r All editable frames hidden, positions saved")
end

-- Check if a frame should be visible
function addon:ShouldFrameBeVisible(frameName)
    local frameData = self.EditableFrames[frameName]
    if not frameData then return false end
    
    if frameData.hasTarget then
        return frameData.hasTarget()
    end
    
    -- By default, frames are always visible (player, minimap)
    return true
end

-- Get information about a registered frame
function addon:GetEditableFrameInfo(frameName)
    return self.EditableFrames[frameName]
end

-- ============================================================================
-- MODULE REGISTRY SYSTEM
-- ============================================================================
-- Central registry for all DragonUI modules.
-- Provides: auto-discovery, status reporting, batch enable/disable operations.
-- Modules self-register during load, making the system extensible.

addon.ModuleRegistry = addon.ModuleRegistry or {
    -- Registered modules: { [name] = { module, displayName, description, order } }
    modules = {},
    -- Load order for enable/disable operations
    loadOrder = {},
    -- Counter for auto-ordering
    orderCounter = 0,
}

local MR = addon.ModuleRegistry

-- Register a module with the registry
-- @param name: Unique module identifier (matches database key in profile.modules)
-- @param moduleTable: The module state table (e.g., StanceModule)
-- @param displayName: Human-readable name for UI display
-- @param description: Description for tooltips (optional)
-- @param order: Load order number (optional, auto-assigned if nil)
function MR:Register(name, moduleTable, displayName, description, order)
    if not name or not moduleTable then
        addon:Error("ModuleRegistry:Register requires name and moduleTable")
        return false
    end
    
    -- Prevent duplicate registration
    if self.modules[name] then
        addon:Debug("ModuleRegistry: Module already registered -", name)
        return false
    end
    
    -- Auto-assign order if not provided
    self.orderCounter = self.orderCounter + 1
    local assignedOrder = order or self.orderCounter
    
    -- Store module info
    self.modules[name] = {
        module = moduleTable,
        displayName = displayName or name,
        description = description or "",
        order = assignedOrder,
    }
    
    -- Add to load order
    table.insert(self.loadOrder, name)
    
    addon:Debug("ModuleRegistry: Registered module -", name, "order:", assignedOrder)
    return true
end

-- Get a registered module by name
-- @param name: Module identifier
-- @return moduleTable or nil
function MR:Get(name)
    local info = self.modules[name]
    return info and info.module or nil
end

-- Get module info (name, description, order)
-- @param name: Module identifier
-- @return table { module, displayName, description, order } or nil
function MR:GetInfo(name)
    return self.modules[name]
end

-- Get all registered module names
-- @return table (array) of module names in load order
function MR:GetAll()
    return self.loadOrder
end

-- Get count of registered modules
-- @return number
function MR:Count()
    return #self.loadOrder
end

-- Check if a module is enabled in database
-- @param name: Module identifier
-- @return boolean
function MR:IsEnabled(name)
    if not addon.db or not addon.db.profile or not addon.db.profile.modules then
        return false
    end
    local cfg = addon.db.profile.modules[name]
    return cfg and cfg.enabled
end

-- Enable a specific module
-- @param name: Module identifier
-- @return boolean success
function MR:Enable(name)
    local info = self.modules[name]
    if not info then
        addon:Error("ModuleRegistry: Unknown module -", name)
        return false
    end
    
    -- Update database
    if addon.db and addon.db.profile and addon.db.profile.modules then
        if not addon.db.profile.modules[name] then
            addon.db.profile.modules[name] = {}
        end
        addon.db.profile.modules[name].enabled = true
    end
    
    -- Call module's Apply function if it has one
    local mod = info.module
    if mod then
        if mod.ApplySystem then
            mod:ApplySystem()
        elseif mod.Apply then
            mod:Apply()
        elseif mod.Enable then
            mod:Enable()
        end
    end
    
    addon:Debug("ModuleRegistry: Enabled -", name)
    return true
end

-- Disable a specific module
-- @param name: Module identifier
-- @return boolean success
function MR:Disable(name)
    local info = self.modules[name]
    if not info then
        addon:Error("ModuleRegistry: Unknown module -", name)
        return false
    end
    
    -- Update database
    if addon.db and addon.db.profile and addon.db.profile.modules then
        if not addon.db.profile.modules[name] then
            addon.db.profile.modules[name] = {}
        end
        addon.db.profile.modules[name].enabled = false
    end
    
    -- Call module's Restore function if it has one
    local mod = info.module
    if mod then
        if mod.RestoreSystem then
            mod:RestoreSystem()
        elseif mod.Restore then
            mod:Restore()
        elseif mod.Disable then
            mod:Disable()
        end
    end
    
    addon:Debug("ModuleRegistry: Disabled -", name)
    return true
end

-- Enable all registered modules (in load order)
function MR:EnableAll()
    for _, name in ipairs(self.loadOrder) do
        self:Enable(name)
    end
end

-- Disable all registered modules (in reverse load order for proper cleanup)
function MR:DisableAll()
    for i = #self.loadOrder, 1, -1 do
        self:Disable(self.loadOrder[i])
    end
end

-- Print status of all registered modules (for /dragonui status)
function MR:PrintStatus()
    if #self.loadOrder == 0 then
        print("  No modules registered in ModuleRegistry")
        return
    end
    
    print("  |cFF00FF00Registered Modules:|r")
    for _, name in ipairs(self.loadOrder) do
        local info = self.modules[name]
        local enabled = self:IsEnabled(name)
        local status = enabled and "|cFF00FF00Enabled|r" or "|cFFFF0000Disabled|r"
        local loaded = info.module and (info.module.initialized or info.module.applied) and "|cFF00FF00Loaded|r" or "|cFFAAAAAA-|r"
        
        print(string.format("    %s: %s (%s)", info.displayName, status, loaded))
    end
end

-- Convenience function for modules to register themselves
-- @param name: Module identifier
-- @param moduleTable: Module state table
-- @param displayName: Display name (optional)
-- @param description: Description (optional)
function addon:RegisterModule(name, moduleTable, displayName, description)
    return MR:Register(name, moduleTable, displayName, description)
end

-- ============================================================================
-- COMBAT QUEUE SYSTEM (ElvUI Pattern)
-- ============================================================================
-- Central system for deferring operations that cannot run during combat lockdown.
-- Pattern: Check InCombatLockdown() -> if true, queue operation -> execute after combat
-- Reference: ElvUI ActionBars.lua PLAYER_REGEN_ENABLED handler

addon.CombatQueue = addon.CombatQueue or {
    -- Pending operations table: { [id] = { func, args } }
    pending = {},
    -- Is the event frame registered?
    isRegistered = false,
    -- Event frame for PLAYER_REGEN_ENABLED
    eventFrame = nil,
}

local CQ = addon.CombatQueue

-- Initialize the combat queue event frame
local function InitializeCombatQueueFrame()
    if CQ.eventFrame then return end
    
    CQ.eventFrame = CreateFrame("Frame", "DragonUI_CombatQueueFrame", UIParent)
    CQ.eventFrame:Hide()
    CQ.eventFrame:SetScript("OnEvent", function(self, event)
        if event == "PLAYER_REGEN_ENABLED" then
            addon.CombatQueue:ProcessQueue()
        end
    end)
end

-- Add an operation to the combat queue
-- @param id: Unique identifier for this operation (prevents duplicates)
-- @param func: Function to call when combat ends
-- @param ...: Arguments to pass to the function
function CQ:Add(id, func, ...)
    if not id or not func then
        addon:Error("CombatQueue:Add requires id and func")
        return false
    end
    
    -- Initialize frame if needed
    InitializeCombatQueueFrame()
    
    -- Store the operation with its arguments
    self.pending[id] = { func = func, args = {...} }
    
    -- Register for PLAYER_REGEN_ENABLED if not already
    if not self.isRegistered then
        self.eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
        self.isRegistered = true
        addon:Debug("CombatQueue: Registered PLAYER_REGEN_ENABLED")
    end
    
    addon:Debug("CombatQueue: Queued operation -", id)
    return true
end

-- Remove an operation from the queue (if no longer needed)
-- @param id: Identifier of the operation to remove
function CQ:Remove(id)
    if self.pending[id] then
        self.pending[id] = nil
        addon:Debug("CombatQueue: Removed operation -", id)
    end
    
    -- If queue is empty, unregister the event
    if not next(self.pending) and self.isRegistered then
        self.eventFrame:UnregisterEvent("PLAYER_REGEN_ENABLED")
        self.isRegistered = false
    end
end

-- Check if an operation is in the queue
-- @param id: Identifier to check
function CQ:HasPending(id)
    return self.pending[id] ~= nil
end

-- Process all queued operations (called on PLAYER_REGEN_ENABLED)
function CQ:ProcessQueue()
    addon:Debug("CombatQueue: Processing", addon:tcount(self.pending), "queued operations")
    
    -- Process all pending operations
    for id, operation in pairs(self.pending) do
        local success, err = pcall(function()
            operation.func(unpack(operation.args))
        end)
        
        if not success then
            addon:Error("CombatQueue: Failed to execute", id, "-", err)
        else
            addon:Debug("CombatQueue: Executed -", id)
        end
    end
    
    -- Clear all pending operations
    self.pending = {}
    
    -- Unregister the event
    if self.isRegistered then
        self.eventFrame:UnregisterEvent("PLAYER_REGEN_ENABLED")
        self.isRegistered = false
        addon:Debug("CombatQueue: Unregistered PLAYER_REGEN_ENABLED")
    end
end

-- Execute immediately if out of combat, queue if in combat
-- @param id: Unique identifier for this operation
-- @param func: Function to call
-- @param ...: Arguments to pass to the function
-- @return true if executed immediately, false if queued
function CQ:ExecuteOrQueue(id, func, ...)
    if InCombatLockdown() then
        self:Add(id, func, ...)
        return false
    else
        -- Execute immediately
        local args = {...}
        local success, err = pcall(function()
            func(unpack(args))
        end)
        
        if not success then
            addon:Error("CombatQueue: Immediate execution failed -", id, "-", err)
        end
        return true
    end
end

-- Convenience function for modules to check and queue
-- Returns true if operation can proceed (not in combat)
-- @param moduleId: Module name for the queue ID
-- @param operationName: Name of the operation (combined with moduleId)
-- @param func: Function to call when combat ends
-- @param ...: Arguments
function addon:SafeExecute(moduleId, operationName, func, ...)
    local queueId = moduleId .. "_" .. operationName
    return CQ:ExecuteOrQueue(queueId, func, ...)
end

-- ============================================================================
-- PRINT / DEBUG UTILITIES
-- ============================================================================

-- Print a formatted message
function addon:Print(...)
    print("|cFF00FF00[DragonUI]|r", ...)
end

-- Print a debug message (only in debug mode)
function addon:Debug(...)
    if addon.debugMode then
        print("|cFFFFFF00[DragonUI Debug]|r", ...)
    end
end

-- Print an error message
function addon:Error(...)
    print("|cFFFF0000[DragonUI Error]|r", ...)
end

print("|cFF00FF00[DragonUI]|r API loaded")
