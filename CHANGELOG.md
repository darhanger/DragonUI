# 🐉 DragonUI - Experimental Changelog

## 2026-02-05

### Added
- `DragonUI_Options` as separate addon (loads on demand for faster startup)
<img width="236" height="58" alt="image" src="https://github.com/user-attachments/assets/a6b7239b-fd9e-41f2-b8f4-c2ad7c844e78" />
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
