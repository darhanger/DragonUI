--[[
  DragonUI - Boss Frames (boss.lua)

  Reskins Blizzard's native Boss1-4TargetFrame with Dragonflight visual styling.
  Follows the RetailUI pattern: retexture existing Blizzard frames instead of
  creating new ones from scratch. Blizzard handles all event/unit management.

  Architecture:
  - Config: addon.db.profile.unitframe.boss
  - Atlas: SetAtlasTexture (global from Atlas.lua)
  - Editor: RegisterEditableFrame for drag positioning
  - Visibility: Blizzard's own RegisterUnitWatch on BossXTargetFrame
]]

local _, addon = ...

local UF = addon.UF
if not UF then return end

-- ============================================================================
-- CONFIG ACCESS
-- ============================================================================

local function GetConfig()
    return UF.GetConfig("boss")
end

local function IsEnabled()
    return UF.IsEnabled("boss")
end

-- ============================================================================
-- CONSTANTS
-- ============================================================================

local NUM_BOSS_FRAMES = 4

-- ============================================================================
-- MODULE STATE
-- ============================================================================

local BossModule = UF.CreateModule("boss")
BossModule.wrapperFrames = {} -- editor wrapper frames indexed 1-4
BossModule.configured = false

-- ============================================================================
-- RESKIN BLIZZARD BOSS FRAME
-- ============================================================================

local function ReskinBossFrame(wrapperFrame, bossFrame)
    -- Anchor the Blizzard boss frame to our wrapper
    bossFrame:ClearAllPoints()
    bossFrame:SetPoint("LEFT", wrapperFrame, "LEFT", 0, 0)
    bossFrame:SetSize(wrapperFrame:GetWidth(), wrapperFrame:GetHeight())
    bossFrame:SetHitRectInsets(0, 0, 0, 0)

    local frameName = bossFrame:GetName()

    -- Border texture — use RareElite style for bosses
    local borderTexture = _G[frameName .. "TextureFrameTexture"]
    if borderTexture then
        borderTexture:ClearAllPoints()
        borderTexture:SetPoint("BOTTOMLEFT", 0, 0)
        SetAtlasTexture(borderTexture, "TargetFrame-TextureFrame-RareElite")
        borderTexture:SetDrawLayer("BORDER")
    end

    -- Portrait
    local portraitTexture = _G[frameName .. "Portrait"]
    if portraitTexture then
        portraitTexture:ClearAllPoints()
        portraitTexture:SetPoint("RIGHT", -5, 8)
        portraitTexture:SetSize(56, 56)
        portraitTexture:SetDrawLayer("BACKGROUND")
    end

    -- Name background
    local nameBG = _G[frameName .. "NameBackground"]
    if nameBG then
        nameBG:ClearAllPoints()
        nameBG:SetPoint("TOPLEFT", 4, -2)
        nameBG:SetPoint("BOTTOMRIGHT", -56, 44)
        nameBG:SetDrawLayer("BORDER")
        nameBG:SetBlendMode("ADD")
    end

    -- Health bar
    local healthBar = _G[frameName .. "HealthBar"]
    if healthBar then
        healthBar:SetFrameLevel(bossFrame:GetFrameLevel() + 1)
        healthBar:ClearAllPoints()
        healthBar:SetPoint("TOPLEFT", 5, -15)
        healthBar:SetSize(124, 20)

        local statusBarTex = healthBar:GetStatusBarTexture()
        if statusBarTex then
            statusBarTex:SetAllPoints(healthBar)
            SetAtlasTexture(statusBarTex, "TargetFrame-StatusBar-Health")
        end
    end

    -- Mana bar
    local manaBar = _G[frameName .. "ManaBar"]
    if manaBar then
        manaBar:SetFrameLevel(bossFrame:GetFrameLevel() + 1)
        manaBar:ClearAllPoints()
        manaBar:SetPoint("TOPLEFT", 4, -37)
        manaBar:SetSize(132, 10)

        local statusBarTex = manaBar:GetStatusBarTexture()
        if statusBarTex then
            statusBarTex:SetAllPoints(manaBar)
            SetAtlasTexture(statusBarTex, "TargetFrame-StatusBar-Mana")
        end
    end

    -- Name text
    local nameText = _G[frameName .. "TextureFrameName"]
    if nameText then
        nameText:ClearAllPoints()
        nameText:SetPoint("CENTER", -20, 27)
        nameText:SetDrawLayer("OVERLAY")
        nameText:SetJustifyH("LEFT")
        nameText:SetWidth(80)
    end

    -- Level text
    local levelText = _G[frameName .. "TextureFrameLevelText"]
    if levelText then
        levelText:ClearAllPoints()
        levelText:SetPoint("CENTER", -80, 27)
        levelText:SetJustifyH("LEFT")
        levelText:SetDrawLayer("OVERLAY")
    end

    -- High level icon (skull)
    local highLevelTex = _G[frameName .. "TextureFrameHighLevelTexture"]
    if highLevelTex and levelText then
        highLevelTex:ClearAllPoints()
        highLevelTex:SetPoint("CENTER", levelText, "CENTER", 0, 0)
        SetAtlasTexture(highLevelTex, "TargetFrame-HighLevelIcon")
    end

    -- Health text
    local healthText = _G[frameName .. "TextureFrameHealthBarText"]
    if healthText then
        healthText:ClearAllPoints()
        healthText:SetPoint("CENTER", -25, 8)
        healthText:SetDrawLayer("OVERLAY")
    end

    -- Dead text
    local deadText = _G[frameName .. "TextureFrameDeadText"]
    if deadText then
        deadText:ClearAllPoints()
        deadText:SetPoint("CENTER", -25, 8)
        deadText:SetDrawLayer("OVERLAY")
    end

    -- Mana text
    local manaText = _G[frameName .. "TextureFrameManaBarText"]
    if manaText then
        manaText:ClearAllPoints()
        manaText:SetPoint("CENTER", -25, -8)
        manaText:SetDrawLayer("OVERLAY")
    end

    -- PVP icon
    local pvpIcon = _G[frameName .. "TextureFramePVPIcon"]
    if pvpIcon then
        pvpIcon:ClearAllPoints()
        pvpIcon:SetPoint("CENTER", bossFrame, "BOTTOMRIGHT", 6, 14)
    end

    -- Leader icon
    local leaderIcon = _G[frameName .. "TextureFrameLeaderIcon"]
    if leaderIcon then
        leaderIcon:ClearAllPoints()
        leaderIcon:SetPoint("BOTTOM", bossFrame, "TOP", 26, -3)
    end

    -- Flash texture (threat)
    local flashTex = _G[frameName .. "Flash"]
    if flashTex then
        flashTex:SetDrawLayer("OVERLAY")
    end

    -- Threat indicator
    if bossFrame.threatIndicator then
        bossFrame.threatIndicator:ClearAllPoints()
        bossFrame.threatIndicator:SetPoint("BOTTOMLEFT", 0, 0)
        SetAtlasTexture(bossFrame.threatIndicator, "TargetFrame-Status")
    end

    -- ShowTest function for editor mode / testboss command
    bossFrame.ShowTest = function(self)
        local portrait = _G[self:GetName() .. "Portrait"]
        if portrait then
            SetPortraitTexture(portrait, "player")
        end

        local bg = _G[self:GetName() .. "NameBackground"]
        if bg then
            bg:SetVertexColor(UnitSelectionColor("player"))
        end

        local dead = _G[self:GetName() .. "TextureFrameDeadText"]
        if dead then dead:Hide() end

        local highLevel = _G[self:GetName() .. "TextureFrameHighLevelTexture"]
        if highLevel then highLevel:Hide() end

        local name = _G[self:GetName() .. "TextureFrameName"]
        if name then name:SetText(UnitName("player")) end

        local level = _G[self:GetName() .. "TextureFrameLevelText"]
        if level then
            level:SetText(UnitLevel("player"))
            level:Show()
        end

        local hpText = _G[self:GetName() .. "TextureFrameHealthBarText"]
        local curHP = UnitHealth("player")
        if hpText then hpText:SetText(curHP .. "/" .. curHP) end

        local mpText = _G[self:GetName() .. "TextureFrameManaBarText"]
        local curMP = UnitPower("player", 0) -- Mana
        if mpText then mpText:SetText(curMP .. "/" .. curMP) end

        local hp = _G[self:GetName() .. "HealthBar"]
        if hp then
            hp:SetMinMaxValues(0, curHP)
            hp:SetStatusBarColor(0.29, 0.69, 0.07)
            hp:SetValue(curHP)
            hp:Show()
        end

        local mp = _G[self:GetName() .. "ManaBar"]
        if mp then
            mp:SetMinMaxValues(0, curMP)
            mp:SetValue(curMP)
            mp:SetStatusBarColor(0.02, 0.32, 0.71)
            mp:Show()
        end

        self:Show()
    end

    bossFrame.HideTest = function(self)
        self:Hide()
    end
end

-- ============================================================================
-- HIDE BLIZZARD BACKGROUNDS
-- ============================================================================

local function HideBlizzardBossBackgrounds()
    local backgrounds = {
        _G.Boss1TargetFrameBackground,
        _G.Boss2TargetFrameBackground,
        _G.Boss3TargetFrameBackground,
        _G.Boss4TargetFrameBackground,
    }
    for _, bg in ipairs(backgrounds) do
        if bg then bg:SetAlpha(0) end
    end
end

-- ============================================================================
-- CLASSIFICATION HOOK (re-apply styling after Blizzard resets it)
-- ============================================================================

local function HookClassification()
    if BossModule.classificationHooked then return end

    hooksecurefunc("TargetFrame_CheckClassification", function(self, forceNormalTexture)
        -- Only process boss frames
        local frameName = self:GetName()
        if not frameName or not frameName:match("^Boss%dTargetFrame$") then return end

        -- Re-apply bar sizing and positioning
        local healthBar = _G[frameName .. "HealthBar"]
        if healthBar then healthBar:SetSize(124, 20) end

        local manaBar = _G[frameName .. "ManaBar"]
        if manaBar then manaBar:SetSize(132, 10) end

        local nameText = _G[frameName .. "TextureFrameName"]
        if nameText then
            nameText:ClearAllPoints()
            nameText:SetPoint("CENTER", -20, 27)
        end

        local levelText = _G[frameName .. "TextureFrameLevelText"]
        if levelText then
            levelText:ClearAllPoints()
            levelText:SetPoint("CENTER", -80, 27)
        end

        local pvpIcon = _G[frameName .. "TextureFramePVPIcon"]
        if pvpIcon then
            pvpIcon:ClearAllPoints()
            pvpIcon:SetPoint("CENTER", self, "BOTTOMRIGHT", 6, 14)
        end

        -- Re-apply atlas border based on classification
        if self.borderTexture then
            local classification = UnitClassification(self.unit)
            if classification == "worldboss" or classification == "elite" then
                SetAtlasTexture(self.borderTexture, "TargetFrame-TextureFrame-Elite")
            elseif classification == "rareelite" then
                SetAtlasTexture(self.borderTexture, "TargetFrame-TextureFrame-RareElite")
            elseif classification == "rare" then
                SetAtlasTexture(self.borderTexture, "TargetFrame-TextureFrame-Rare")
            else
                SetAtlasTexture(self.borderTexture, "TargetFrame-TextureFrame-RareElite")
            end
        end

        -- Re-apply threat indicator
        if self.threatIndicator then
            self.threatIndicator:ClearAllPoints()
            self.threatIndicator:SetPoint("BOTTOMLEFT", 0, 0)
            SetAtlasTexture(self.threatIndicator, "TargetFrame-Status")
        end
    end)

    BossModule.classificationHooked = true
end

-- ============================================================================
-- HEALTH BAR COLOR HOOK
-- ============================================================================

local function HookHealthBarColor()
    if BossModule.healthHooked then return end

    hooksecurefunc("UnitFrameHealthBar_Update", function(statusbar, unit)
        if not statusbar or statusbar.lockValues then return end
        if not unit or not unit:match("^boss%d$") then return end
        if unit ~= statusbar.unit then return end

        if not UnitIsConnected(unit) then
            if not statusbar.lockColor then
                statusbar:SetStatusBarColor(0.5, 0.5, 0.5)
            end
        else
            local config = GetConfig()
            if config and config.classcolor and UnitIsPlayer(unit) then
                local _, class = UnitClass(unit)
                if class then
                    local color = RAID_CLASS_COLORS[class]
                    if color and not statusbar.lockColor then
                        statusbar:SetStatusBarColor(color.r, color.g, color.b)
                        return
                    end
                end
            end
            if not statusbar.lockColor then
                statusbar:SetStatusBarColor(0.48, 0.86, 0.15)
            end
        end
    end)

    BossModule.healthHooked = true
end

-- ============================================================================
-- POSITIONING
-- ============================================================================

local function PositionBossFrames()
    if InCombatLockdown() then return end

    local config = GetConfig()
    local scale = config.scale or 1.0

    for i = 1, NUM_BOSS_FRAMES do
        local wrapper = BossModule.wrapperFrames[i]
        if wrapper then
            wrapper:SetScale(scale)

            if i == 1 then
                -- Always anchor to overlay so editor drag moves everything
                if BossModule.overlay then
                    wrapper:ClearAllPoints()
                    wrapper:SetPoint("TOP", BossModule.overlay, "TOP", 0, 0)
                else
                    wrapper:ClearAllPoints()
                    wrapper:SetPoint(
                        config.anchor or "TOPRIGHT",
                        UIParent,
                        config.anchorParent or "TOPRIGHT",
                        config.x or -100,
                        config.y or -270
                    )
                end
            else
                -- Stack below previous
                wrapper:ClearAllPoints()
                wrapper:SetPoint("TOP", BossModule.wrapperFrames[i - 1], "BOTTOM", 0, -2)
            end
        end
    end
end

-- ============================================================================
-- INITIALIZATION
-- ============================================================================

local function InitializeBossFrames()
    if BossModule.configured then return end
    if InCombatLockdown() then return end
    if not IsEnabled() then return end

    HideBlizzardBossBackgrounds()

    for i = 1, NUM_BOSS_FRAMES do
        local bossFrame = _G["Boss" .. i .. "TargetFrame"]
        if bossFrame then
            -- Create wrapper frame for positioning
            local wrapper = addon.CreateUIFrame(192, 68, "Boss" .. i .. "Frame")
            BossModule.wrapperFrames[i] = wrapper

            -- Reskin the Blizzard boss frame
            ReskinBossFrame(wrapper, bossFrame)
        end
    end

    HookClassification()
    HookHealthBarColor()
    PositionBossFrames()

    BossModule.configured = true
end

-- ============================================================================
-- EDITOR MODE
-- ============================================================================

local function SetupEditorMode()
    local totalHeight = (NUM_BOSS_FRAMES * 70) + ((NUM_BOSS_FRAMES - 1) * 2)
    BossModule.overlay = addon.CreateUIFrame(192, math.min(totalHeight, 300), "boss")

    if BossModule.overlay.editorText then
        local L = addon.L
        BossModule.overlay.editorText:SetText((L and L["Boss Frames"]) or "Boss Frames")
    end

    -- Initial position will be set by ApplyBossFramePosition()
    BossModule.overlay:ClearAllPoints()
    BossModule.overlay:SetPoint(
        "TOPRIGHT", UIParent, "TOPRIGHT", -100, -270
    )

    BossModule.overlay:HookScript("OnDragStop", function(self)
        self.DragonUI_WasDragged = true
    end)

    addon:RegisterEditableFrame({
        name = "boss",
        frame = BossModule.overlay,
        configPath = {"widgets", "boss"},
        hasTarget = function()
            return true
        end,
        showTest = function()
            if BossModule.overlay then
                BossModule.overlay:Show()
            end
            -- Show boss frames in test mode
            for i = 1, NUM_BOSS_FRAMES do
                local bossFrame = _G["Boss" .. i .. "TargetFrame"]
                if bossFrame and bossFrame.ShowTest and not InCombatLockdown() then
                    bossFrame:ShowTest()
                end
            end
        end,
        hideTest = function()
            for i = 1, NUM_BOSS_FRAMES do
                local bossFrame = _G["Boss" .. i .. "TargetFrame"]
                if bossFrame and bossFrame.HideTest and not InCombatLockdown() then
                    if not UnitExists("boss" .. i) then
                        bossFrame:HideTest()
                    end
                end
            end
        end,
        onHide = function()
            if BossModule.overlay and BossModule.overlay.DragonUI_WasDragged then
                local config = GetConfig()
                if config then
                    config.override = true
                end
                PositionBossFrames()
                BossModule.overlay.DragonUI_WasDragged = nil
            end
        end,
        module = BossModule
    })
end

-- ============================================================================
-- APPLY / RESTORE
-- ============================================================================

local function ApplyBossFramePosition()
    if not BossModule.overlay then return end
    local config = GetConfig()
    if config and config.override then
        if addon.db and addon.db.profile and addon.db.profile.widgets then
            local widgetConfig = addon.db.profile.widgets.boss
            if widgetConfig and widgetConfig.posX and widgetConfig.posY then
                local anchor = widgetConfig.anchor or "CENTER"
                BossModule.overlay:ClearAllPoints()
                BossModule.overlay:SetPoint(anchor, UIParent, anchor, widgetConfig.posX, widgetConfig.posY)
                return
            end
        end
    end
    -- Default: use config position
    if config then
        BossModule.overlay:ClearAllPoints()
        BossModule.overlay:SetPoint(
            config.anchor or "TOPRIGHT",
            UIParent,
            config.anchorParent or "TOPRIGHT",
            config.x or -100,
            config.y or -270
        )
    else
        BossModule.overlay:ClearAllPoints()
        BossModule.overlay:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -100, -270)
    end
end

-- ============================================================================
-- EVENT HANDLING
-- ============================================================================

local eventsFrame = CreateFrame("Frame")
BossModule.eventsFrame = eventsFrame

eventsFrame:SetScript("OnEvent", function(self, event, ...)
    if not IsEnabled() then return end

    if event == "ADDON_LOADED" then
        local name = ...
        if name == "DragonUI" then
            SetupEditorMode()
            ApplyBossFramePosition()
        end

    elseif event == "PLAYER_ENTERING_WORLD" then
        InitializeBossFrames()
        PositionBossFrames()
        HideBlizzardBossBackgrounds()

    elseif event == "PLAYER_REGEN_ENABLED" then
        PositionBossFrames()
    end
end)

eventsFrame:RegisterEvent("ADDON_LOADED")
eventsFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventsFrame:RegisterEvent("PLAYER_REGEN_ENABLED")

-- ============================================================================
-- PUBLIC API
-- ============================================================================

function addon.RefreshBossFrames()
    if not BossModule.configured then return end
    if InCombatLockdown() then return end
    if not IsEnabled() then return end

    HideBlizzardBossBackgrounds()

    for i = 1, NUM_BOSS_FRAMES do
        local bossFrame = _G["Boss" .. i .. "TargetFrame"]
        local wrapper = BossModule.wrapperFrames[i]
        if bossFrame and wrapper then
            ReskinBossFrame(wrapper, bossFrame)
        end
    end

    PositionBossFrames()
end

-- Store reference on addon for profile callbacks
addon.BossModule = BossModule

-- Profile change callbacks
local function OnProfileChanged()
    if addon.RefreshBossFrames then
        addon.RefreshBossFrames()
    end
end

local profileFrame = CreateFrame("Frame")
profileFrame:RegisterEvent("PLAYER_LOGIN")
profileFrame:SetScript("OnEvent", function(self, event)
    if addon.db and addon.db.RegisterCallback then
        addon.db.RegisterCallback(BossModule, "OnProfileChanged", OnProfileChanged)
        addon.db.RegisterCallback(BossModule, "OnProfileCopied", OnProfileChanged)
        addon.db.RegisterCallback(BossModule, "OnProfileReset", OnProfileChanged)
    end
    self:UnregisterAllEvents()
end)
