local addon = select(2,...);
local L = addon.L

-- =================================================================
-- DRAGONUI GAME MENU BUTTON MODULE (WOW 3.3.5A)
-- =================================================================

-- Local variables for WoW 3.3.5a compatibility
local CreateFrame = CreateFrame
local GameMenuFrame = GameMenuFrame
local HideUIPanel = HideUIPanel

-- Button state
local dragonUIButton = nil
local buttonAdded = false
local buttonPositioned = false -- Prevents multiple repositioning

-- List of all game menu buttons in order of appearance (WoW 3.3.5a)
local GAME_MENU_BUTTONS = {
    "GameMenuButtonHelp",
    "GameMenuButtonWhatsNew", 
    "GameMenuButtonStore",
    "GameMenuButtonOptions",
    "GameMenuButtonUIOptions", 
    "GameMenuButtonKeybindings",
    "GameMenuButtonMacros",
    "GameMenuButtonAddons",
    "GameMenuButtonLogout",
    "GameMenuButtonQuit",
    "GameMenuButtonContinue"
}

-- Function to find the correct position for the DragonUI button
local function FindInsertPosition()
    -- ALWAYS insert after the "Return to Game" (Continue) button at the end of the menu
    local afterButton = _G["GameMenuButtonContinue"]
    
    -- If Continue doesn't exist, insert after Quit
    if not afterButton then
        afterButton = _G["GameMenuButtonQuit"]
    end
    
    -- If Quit doesn't exist either, insert after Logout
    if not afterButton then
        afterButton = _G["GameMenuButtonLogout"]
    end
    
    return afterButton, nil -- No beforeButton since it goes at the end
end

-- Function to position the DragonUI button conservatively
local function PositionDragonUIButton()
    if not dragonUIButton then return end
    
    -- IMPORTANT: Only position once to prevent offset accumulation
    if buttonPositioned then 
        return 
    end
    
    local afterButton, beforeButton = FindInsertPosition()
    
    if not afterButton then
        -- Fallback: position at the end of the menu
        dragonUIButton:ClearAllPoints()
        dragonUIButton:SetPoint("TOP", GameMenuFrame, "TOP", 0, -200)
        buttonPositioned = true
        return
    end
    
    -- Position ONLY the DragonUI button immediately after the reference button
    dragonUIButton:ClearAllPoints()
    dragonUIButton:SetPoint("TOP", afterButton, "BOTTOM", 0, -2)
    
    -- MINIMALLY adjust the GameMenuFrame height ONLY once
    local buttonHeight = dragonUIButton:GetHeight() or 16
    local spacing = 1
    local currentHeight = GameMenuFrame:GetHeight()
    GameMenuFrame:SetHeight(currentHeight + buttonHeight + spacing)
    
    -- Since it's at the end of the menu, we don't need to move other buttons
    
    -- Mark as positioned to prevent future executions
    buttonPositioned = true
end

-- Function to open the DragonUI configuration interface
local function OpenDragonUIConfig()
    -- Close game menu first
    HideUIPanel(GameMenuFrame)
    
    -- Use ToggleOptionsUI which handles LoadOnDemand addon loading
    if addon and addon.ToggleOptionsUI then
        addon:ToggleOptionsUI()
        return
    end
    
    -- Fallback: Try slash command
    if SlashCmdList and SlashCmdList["DRAGONUI"] then
        SlashCmdList["DRAGONUI"]("config")
        return
    end
    
    print("|cFFFF0000[DragonUI]|r " .. L["Unable to open configuration"])
end

-- Main function to create the DragonUI button
local function CreateDragonUIButton()
    if dragonUIButton or buttonAdded then return true end
    if not GameMenuFrame then return false end

    -- ============================================================
    -- CUSTOM BUTTON TEXTURES
    -- Drop the files in DragonUI/assets/ and set the paths below.
    -- The texture should be ~128x32 px (same proportions as the
    -- standard game-menu button). One file per state is supported.
    -- Set TEX_CUSTOM_NORMAL = nil to fall back to the red template.
    -- ============================================================
    local TEX_CUSTOM_NORMAL  = addon._dir .. "gamemenu_btn.blp"
    local TEX_CUSTOM_HOVER   = nil  -- misma textura, se aclara con vertex color en hover
    local TEX_CUSTOM_PUSHED  = nil  -- misma textura, se oscurece al pulsar

    local FONT      = (addon.UF and addon.UF.DEFAULT_FONT) or "Fonts\\FRIZQT__.TTF"
    local FONT_SIZE = 12

    -- ── Button (template keeps correct hit-rect and sizing) ──────────────────
    dragonUIButton = CreateFrame("Button", "DragonUIGameMenuButton", GameMenuFrame, "GameMenuButtonTemplate")
    dragonUIButton:SetWidth(144)

    local useCustom = TEX_CUSTOM_NORMAL ~= nil

    -- ── Ocultar texturas del template para que no interfieran ────────────────
    local function hideTemplateTexture(tex)
        if tex then tex:SetAlpha(0) end
    end
    hideTemplateTexture(dragonUIButton:GetNormalTexture())
    hideTemplateTexture(dragonUIButton:GetHighlightTexture())
    hideTemplateTexture(dragonUIButton:GetPushedTexture())

    -- ── Capa de fondo: textura custom, 3px más alta que el frame ───────────
    local bgTex = dragonUIButton:CreateTexture(nil, "BACKGROUND")
    bgTex:SetPoint("TOPLEFT",     dragonUIButton, "TOPLEFT",     0,  1.5)
    bgTex:SetPoint("BOTTOMRIGHT", dragonUIButton, "BOTTOMRIGHT", 0, -1.5)

    if useCustom then
        bgTex:SetTexture(TEX_CUSTOM_NORMAL)
        bgTex:SetTexCoord(0, 1, 0, 1)
        bgTex:SetVertexColor(0.40, 0.65, 1.00)
    else
        local WHITE = "Interface\\Buttons\\WHITE8X8"
        bgTex:SetTexture(WHITE)
        bgTex:SetBlendMode("ADD")
        bgTex:SetVertexColor(0.05, 0.22, 0.60, 1.0)
    end
    dragonUIButton._bgTex = bgTex

    -- ── Capa de hover: overlay aditivo (mismo tamaño, empieza invisible) ─────
    local hovTex = dragonUIButton:CreateTexture(nil, "ARTWORK")
    hovTex:SetPoint("TOPLEFT",     dragonUIButton, "TOPLEFT",     0,  1.5)
    hovTex:SetPoint("BOTTOMRIGHT", dragonUIButton, "BOTTOMRIGHT", 0, -1.5)
    if useCustom then
        hovTex:SetTexture(TEX_CUSTOM_NORMAL)
        hovTex:SetTexCoord(0, 1, 0, 1)
        hovTex:SetBlendMode("ADD")
    else
        hovTex:SetTexture("Interface\\Buttons\\WHITE8X8")
        hovTex:SetBlendMode("ADD")
    end
    hovTex:SetVertexColor(0.30, 0.50, 1.00, 0.0)   -- empieza transparente
    dragonUIButton._hovTex = hovTex

    -- ── Label ────────────────────────────────────────────────────────────────
    local label = dragonUIButton:GetFontString()
    if label then
        label:SetFont(FONT, FONT_SIZE, "OUTLINE")
        label:SetTextColor(1.0, 1.0, 1.0, 1.0)
        label:SetShadowColor(0.0, 0.10, 0.45, 1.0)
        label:SetShadowOffset(1, -1)
        label:ClearAllPoints()
        label:SetPoint("CENTER", dragonUIButton, "CENTER", 0, 1)
        label:SetText(L["DragonUI"])
    end

    -- ── Smooth hover animation ────────────────────────────────────────────────
    local NRM   = {0.40, 0.65, 1.00}   -- bgTex normal  (custom mode)
    local HOV   = {0.70, 0.90, 1.00}   -- bgTex hover   (custom mode)
    local OVR   = {0.05, 0.22, 0.60}   -- bgTex normal  (fallback mode)
    local OVR_H = {0.12, 0.40, 0.95}   -- bgTex hover   (fallback mode)
    local TXT   = {1.00, 1.00, 1.00}
    local TXT_H = {1.00, 1.00, 1.00}

    local hoverProgress = 0
    local hoverTarget   = 0
    local ANIM_SPEED    = 5

    dragonUIButton:SetScript("OnUpdate", function(self, elapsed)
        if hoverProgress == hoverTarget then return end
        local step = ANIM_SPEED * elapsed
        if hoverTarget > hoverProgress then
            hoverProgress = math.min(hoverProgress + step, 1)
        else
            hoverProgress = math.max(hoverProgress - step, 0)
        end
        local p = hoverProgress
        -- Animar textura de fondo
        if useCustom then
            self._bgTex:SetVertexColor(
                NRM[1] + (HOV[1] - NRM[1]) * p,
                NRM[2] + (HOV[2] - NRM[2]) * p,
                NRM[3] + (HOV[3] - NRM[3]) * p)
        else
            self._bgTex:SetVertexColor(
                OVR[1] + (OVR_H[1] - OVR[1]) * p,
                OVR[2] + (OVR_H[2] - OVR[2]) * p,
                OVR[3] + (OVR_H[3] - OVR[3]) * p,
                1.0)
        end
        -- Animar overlay de brillo hover
        self._hovTex:SetVertexColor(0.30, 0.50, 1.00, 0.25 * p)
        -- Animar texto
        if label then
            label:SetTextColor(
                TXT[1] + (TXT_H[1] - TXT[1]) * p,
                TXT[2] + (TXT_H[2] - TXT[2]) * p,
                TXT[3] + (TXT_H[3] - TXT[3]) * p,
                1.0)
        end
    end)

    dragonUIButton:SetScript("OnEnter", function(self) hoverTarget = 1 end)
    dragonUIButton:SetScript("OnLeave", function(self) hoverTarget = 0 end)

    dragonUIButton:SetScript("OnClick", function(self, button)
        if button == "LeftButton" then OpenDragonUIConfig() end
    end)

    PositionDragonUIButton()
    buttonAdded = true
    return true
end

-- Function to attempt creating the button with retries
local function TryCreateButton()
    local attempts = 0
    local maxAttempts = 5
    
    local function attempt()
        attempts = attempts + 1
        
        if CreateDragonUIButton() then
            return -- Success
        end
        
        if attempts < maxAttempts then
            -- Retry after delay
            addon:After(0.5, attempt)
        else
           
        end
    end
    
    attempt()
end

-- Event frame to handle initialization
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")

eventFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "DragonUI" then
        -- Try to add the button after DragonUI loads
        TryCreateButton()
        
    elseif event == "PLAYER_LOGIN" then
        -- Second attempt after login
        addon:After(1.0, function()
            if not buttonAdded then
                TryCreateButton()
            end
        end)
        
        self:UnregisterEvent("PLAYER_LOGIN")
    end
end)

-- Phase 2: hooksecurefunc instead of direct .Show override to avoid taint
hooksecurefunc(GameMenuFrame, "Show", function(self)
    -- Try to create the button if it doesn't exist
    if not buttonAdded then
        CreateDragonUIButton()
    elseif dragonUIButton then
        -- If it already exists, ensure it's visible but DO NOT reposition
        dragonUIButton:Show()
        -- Commented out to prevent accumulation bug: PositionDragonUIButton()
    end
end)

