--[[
 DragonUI_Options - Traditional Chinese Locale (zhTW)
 Community translation — Edit this file to contribute!

 Guidelines:
 - Use `true` for strings you haven't translated yet (falls back to English)
 - Keep format specifiers like %s, %d, %.1f intact
 - Keep "DragonUI" as addon name untranslated
 - Keep color codes |cff...|r outside of L[] strings
]]

local L = LibStub("AceLocale-3.0"):NewLocale("DragonUI_Options", "zhTW")
if not L then return end

-- Example:
-- L["General"] = "一般"

L["Button Spacing"] = "按鈕間距"
L["Scale"] = "縮放"
L["Class Portrait"] = "職業肖像"

-- LAYOUT PRESETS
L["Layout Presets"] = "介面預設"
L["Save and restore complete UI layouts. Each preset captures all positions, scales, and settings."] = "儲存和恢復完整的介面佈局。每個預設包含所有位置、縮放和設定。"
L["No presets saved yet."] = "尚未儲存任何預設。"
L["Save New Preset"] = "儲存新預設"
L["Save your current UI layout as a new preset."] = "將目前介面佈局儲存為新預設。"
L["Preset"] = "預設"
L["Enter a name for this preset:"] = "輸入此預設的名稱："
L["Save"] = "儲存"
L["Load"] = "載入"
L["Load preset '%s'? This will overwrite your current layout settings."] = "載入預設 '%s'？這將覆蓋您目前的佈局設定。"
L["Load Preset"] = "載入預設"
L["Delete preset '%s'? This cannot be undone."] = "刪除預設 '%s'？此操作無法復原。"
L["Delete Preset"] = "刪除預設"
L["Duplicate Preset"] = "複製預設"
L["Preset saved: "] = "預設已儲存: "
L["Preset loaded: "] = "預設已載入: "
L["Preset deleted: "] = "預設已刪除: "
L["Preset duplicated: "] = "預設已複製: "
L["Also delete all saved layout presets?"] = "是否同時刪除所有已儲存的介面預設？"
L["Presets kept."] = "預設已保留。"

-- PRESET IMPORT / EXPORT
L["Export Preset"] = "匯出預設"
L["Import Preset"] = "匯入預設"
L["Import a preset from a text string shared by another player."] = "從其他玩家分享的文字匯入預設。"
L["Import"] = "匯入"
L["Select All"] = "全選"
L["Close"] = "關閉"
L["Enter a name for the imported preset:"] = "為匯入的預設輸入名稱："
L["Imported Preset"] = "匯入的預設"
L["Preset imported: "] = "預設已匯入: "
L["Invalid preset string."] = "無效的預設字串。"
L["Not a valid DragonUI preset string."] = "不是有效的 DragonUI 預設字串。"
L["Failed to export preset."] = "匯出預設失敗。"
