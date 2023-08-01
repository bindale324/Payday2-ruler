-- This script initializes the DNC(Do Not Cheat) struct as a global variable, and will be used by other scripts.
-- stick to function programming


DNC = {} -- [struct], inside is the whole variables and functions of this mod
DNC.version = "1.0.3"

DNC.menu = {}

function DNC.openMenu(menu)
    managers.system_menu:show_buttons(menu)
end

function DNC.readFile(filePath)
    if not io.file_is_readable(filePath) then
        managers.mission._fading_debug_output:script().log('reading file failure, not the right path', Color.red)
        return false
    end
    local file = io.open(filePath, "r")
    if not file then
        managers.mission._fading_debug_output:script().log('reading file failure, check your file compeletion', Color
            .red)
        return false
    end
    local content = file:read("*all")
    file:close()
    return content
end

function DNC.jsonDecode(content)
    return json.decode(content)
end

DNCStruct = true
