-- This script initializes the DNC(Do Not Cheat) struct as a global variable, and will be used by other scripts.
-- stick to function programming

-- In order to facilitate management, we put all persistent scripts to the `persistent` folder.

DNC = {} -- [struct], inside is the whole variables and functions of this mod
DNC.version = "1.0.0"

DNC.menu = {}



function DNC.openMenu(menu)
    managers.system_menu:show_buttons(menu)
end

DNCStruct = true
