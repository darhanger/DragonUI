# 🐉 DragonUI - Experimental Changelog

## 2026-02-06

### Added
- **Class Portrait** - New option to show class icons instead of 3D portraits (Player, Target, Focus)
- **Totem Bar Options** - Size and spacing sliders, auto-anchoring based on visible action bars

### Fixed
- **Stance & Totem Bars** - No longer disappear after `/reload` or break when changing settings
- **Stance Bar Options** - Size and spacing sliders now work correctly  
- **Party Frames** - Horizontal orientation now works properly
- **Sidebar Action Bars** - Editor overlay now follows when switching vertical/horizontal
- **Castbar Advanced Mode** - Time numbers now display correctly

### Improved
- **Editor Mode Rework** - Complete visual overhaul with Dragonflight-style overlays
  - All modules (except ToT/ToF) now use the new editor system
  - New textures and highlight/selected states
  - Stance and Totem bars now draggable in Editor Mode

## 2026-02-05

### Added
- `DragonUI_Options` as separate addon (loads on demand for faster startup)
- Advanced individual module control panel 
- `core/api.lua` with centralized utility functions
- `core/movers.lua` with unified frame movement system
- `core/commands.lua` with slash command handling
- `core/module_base.lua` with standardized module template
- CombatQueue system for safe combat-deferred operations
- Module Registry system for tracking and managing modules
- Quest tracker now works in Editor Mode

### Changed
- Core utilities reorganized into `core/` folder
- Action bar modules consolidated in `modules/actionbars/`
- Options divided into modular files (general, actionbars, unitframes, etc.)
- Standardized module initialization patterns across all modules

### Fixed
- Target of Target not working on Bronzebeard private server (thanks xius)
- Bag icons displaying incorrectly (thanks @mikki33)
- Quest tracker visual fixes (thanks @mikki33)
- Combat lockdown handling improved across modules
- `mainbars.lua` module scope issue (MainbarsModule now at file level)
