--[[
 DragonUI_Options - Simplified Chinese Locale (zhCN)
 Community translation — Edit this file to contribute!

 Guidelines:
 - Use `true` for strings you haven't translated yet (falls back to English)
 - Keep format specifiers like %s, %d, %.1f intact
 - Keep "DragonUI" as addon name untranslated
 - Keep color codes |cff...|r outside of L[] strings
]]

local L = LibStub("AceLocale-3.0"):NewLocale("DragonUI_Options", "zhCN")
if not L then return end

-- Example:
-- L["General"] = "常规"

L["Button Spacing"] = "按钮间距"
L["Scale"] = "缩放"
L["Class Portrait"] = "职业肖像"

-- LAYOUT PRESETS
L["Layout Presets"] = "布局预设"
L["Save and restore complete UI layouts. Each preset captures all positions, scales, and settings."] = "保存和恢复完整的界面布局。每个预设包含所有位置、缩放和设置。"
L["No presets saved yet."] = "尚未保存任何预设。"
L["Save New Preset"] = "保存新预设"
L["Save your current UI layout as a new preset."] = "将当前界面布局保存为新预设。"
L["Preset"] = "预设"
L["Enter a name for this preset:"] = "输入此预设的名称："
L["Save"] = "保存"
L["Load"] = "加载"
L["Load preset '%s'? This will overwrite your current layout settings."] = "加载预设 '%s'？这将覆盖您当前的布局设置。"
L["Load Preset"] = "加载预设"
L["Delete preset '%s'? This cannot be undone."] = "删除预设 '%s'？此操作无法撤销。"
L["Delete Preset"] = "删除预设"
L["Duplicate Preset"] = "复制预设"
L["Preset saved: "] = "预设已保存: "
L["Preset loaded: "] = "预设已加载: "
L["Preset deleted: "] = "预设已删除: "
L["Preset duplicated: "] = "预设已复制: "
L["Also delete all saved layout presets?"] = "是否同时删除所有已保存的布局预设？"
L["Presets kept."] = "预设已保留。"

-- PRESET IMPORT / EXPORT
L["Export Preset"] = "导出预设"
L["Import Preset"] = "导入预设"
L["Import a preset from a text string shared by another player."] = "从其他玩家分享的文本中导入预设。"
L["Import"] = "导入"
L["Select All"] = "全选"
L["Close"] = "关闭"
L["Enter a name for the imported preset:"] = "为导入的预设输入名称："
L["Imported Preset"] = "导入的预设"
L["Preset imported: "] = "预设已导入: "
L["Invalid preset string."] = "无效的预设字符串。"
L["Not a valid DragonUI preset string."] = "不是有效的 DragonUI 预设字符串。"
L["Failed to export preset."] = "导出预设失败。"
