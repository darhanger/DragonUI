--[[
================================================================================
DragonUI - Spanish Locale (esES)
================================================================================
]]

local L = LibStub("AceLocale-3.0"):NewLocale("DragonUI", "esES")
if not L then return end

-- ============================================================================
-- CORE / GENERAL
-- ============================================================================

L["Cannot toggle editor mode during combat!"] = "¡No se puede cambiar el modo editor durante combate!"
L["Cannot reset positions during combat!"] = "¡No se pueden restablecer las posiciones durante combate!"
L["Cannot toggle keybind mode during combat!"] = "¡No se puede cambiar el modo de atajos durante combate!"
L["Cannot move frames during combat!"] = "¡No se pueden mover marcos durante combate!"
L["Cannot open options in combat."] = "No se pueden abrir las opciones en combate."

L["Editor mode not available."] = "Modo editor no disponible."
L["Keybind mode not available."] = "Modo de atajos no disponible."
L["Vehicle debug not available"] = "Depuración de vehículo no disponible"
L["KeyBinding module not available"] = "Módulo de atajos de teclado no disponible"
L["Unable to open configuration"] = "No se pudo abrir la configuración"

L["Error executing pending operation:"] = "Error al ejecutar operación pendiente:"
L["Error -- Addon 'DragonUI_Options' not found or is disabled."] = "Error -- El addon 'DragonUI_Options' no se encontró o está desactivado."

-- ============================================================================
-- SLASH COMMANDS / HELP
-- ============================================================================

L["Unknown command: "] = "Comando desconocido: "
L["=== DragonUI Commands ==="] = "=== Comandos de DragonUI ==="
L["/dragonui or /dui - Open configuration"] = "/dragonui o /dui - Abrir configuración"
L["/dragonui config - Open configuration"] = "/dragonui config - Abrir configuración"
L["/dragonui legacy - Open legacy AceConfig options"] = "/dragonui legacy - Abrir opciones clásicas de AceConfig"
L["/dragonui edit - Toggle editor mode (move UI elements)"] = "/dragonui edit - Cambiar modo editor (mover elementos de UI)"
L["/dragonui reset - Reset all positions to defaults"] = "/dragonui reset - Restablecer todas las posiciones"
L["/dragonui reset <name> - Reset specific mover"] = "/dragonui reset <nombre> - Restablecer posición específica"
L["/dragonui status - Show module status"] = "/dragonui status - Mostrar estado de módulos"
L["/dragonui kb - Toggle keybind mode"] = "/dragonui kb - Cambiar modo de atajos"
L["/dragonui version - Show version info"] = "/dragonui version - Mostrar versión"
L["/dragonui help - Show this help"] = "/dragonui help - Mostrar esta ayuda"
L["/rl - Reload UI"] = "/rl - Recargar interfaz"

-- ============================================================================
-- STATUS DISPLAY
-- ============================================================================

L["=== DragonUI Status ==="] = "=== Estado de DragonUI ==="
L["Detected Modules:"] = "Módulos detectados:"
L["Loaded"] = "Cargado"
L["Not Loaded"] = "No cargado"
L["Registered Movers: "] = "Movedores registrados: "
L["Editable Frames: "] = "Marcos editables: "
L["DragonUI Version: "] = "Versión de DragonUI: "
L["Use /dragonui edit to enter edit mode, then right-click frames to reset."] = "Usa /dragonui edit para entrar en modo edición, luego haz clic derecho en marcos para restablecer."

-- ============================================================================
-- EDITOR MODE
-- ============================================================================

L["Exit Edit Mode"] = "Salir Editor"
L["Reset All Positions"] = "Restablecer Posiciones"
L["Are you sure you want to reset all interface elements to their default positions?"] = "¿Restablecer todos los elementos a su posición predeterminada?"
L["Yes"] = "Sí"
L["No"] = "No"
L["UI elements have been repositioned. Reload UI to ensure all graphics display correctly?"] = "Los elementos de la interfaz han sido reposicionados. ¿Recargar la interfaz para que se muestren correctamente?"
L["Reload Now"] = "Recargar Ahora"
L["Later"] = "Más Tarde"

-- ============================================================================
-- KEYBINDING MODULE
-- ============================================================================

L["LibKeyBound-1.0 not found or failed to load:"] = "LibKeyBound-1.0 no encontrado o error al cargar:"
L["Commands:"] = "Comandos:"
L["/dukb - Toggle keybinding mode"] = "/dukb - Cambiar modo de atajos"
L["/dukb help - Show this help"] = "/dukb help - Mostrar esta ayuda"
L["Module disabled."] = "Módulo desactivado."
L["Keybinding mode activated. Hover over buttons and press keys to bind them."] = "Modo de atajos activado. Pasa el ratón sobre los botones y pulsa teclas para asignarlas."
L["Keybinding mode deactivated."] = "Modo de atajos desactivado."

-- ============================================================================
-- GAME MENU
-- ============================================================================

L["DragonUI"] = "DragonUI"

-- ============================================================================
-- MINIMAP MODULE
-- ============================================================================

L["DragonUI: Minimap module restored to Blizzard defaults"] = "DragonUI: Módulo de minimapa restaurado a los valores de Blizzard"

-- ============================================================================
-- EDITOR MODE LABELS (displayed on mover overlays - keep SHORT)
-- ============================================================================

L["MainBar"] = "Barra Princ."
L["RightBar"] = "Barra Der."
L["LeftBar"] = "Barra Izq."
L["BottomBarLeft"] = "Barra Inf. Izq."
L["BottomBarRight"] = "Barra Inf. Der."
L["XPBar"] = "Barra XP"
L["RepBar"] = "Barra Rep."
L["MinimapFrame"] = "Minimapa"
L["PlayerFrame"] = "Jugador"
L["ManaBar"] = "Barra Maná"
L["PetFrame"] = "Mascota"
L["ToT"] = "OdO"
L["ToF"] = "OdF"
L["tot"] = "OdO"
L["fot"] = "OdF"
L["PartyFrames"] = "Grupo"
L["TargetFrame"] = "Objetivo"
L["FocusFrame"] = "Foco"
L["BagsBar"] = "Bolsas"
L["MicroMenu"] = "Micromenú"
L["VehicleExitOverlay"] = "Salir Vehículo"
L["StanceOverlay"] = "Posturas"
L["petbar"] = "Barra Mascota"
L["TotemBarOverlay"] = "Tótems"
L["PlayerCastbar"] = "Barra Hechizos"
L["Auras"] = "Auras"
L["Loot Roll"] = "Botín"
L["Quest Tracker"] = "Misiones"

-- Mover tooltip strings
L["Drag to move"] = "Arrastra para mover"
L["Right-click to reset"] = "Clic der. para reiniciar"

-- Editor mode system messages
L["All editable frames shown for editing"] = "Marcos editables mostrados"
L["All editable frames hidden, positions saved"] = "Marcos ocultados, posiciones guardadas"

-- ============================================================================
-- STATIC POPUPS
-- ============================================================================

L["Changing this setting requires a UI reload to apply correctly."] = "Cambiar esta opción requiere recargar la interfaz para aplicarse correctamente."
L["Reload UI"] = "Recargar Interfaz"
L["Not Now"] = "Ahora No"
