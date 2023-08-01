local modPath = ModPath

local function stringReplace(string, search, replace)
    return string:gsub(search, replace)
end

modPath = stringReplace(modPath, "\\", "/")

if modPath:sub(-1, -1) == "/" then
    modPath = modPath:sub(1, -2)
end

-- register core
dofile(modPath .. "/persist/core/donotcheat.lua")
dofile(modPath .. "/persist/core/dnclogtool.lua")

-- register menu
dofile(modPath .. "/persist/menu/menu_main.lua")
dofile(modPath .. "/persist/menu/menu_attack.lua")
dofile(modPath .. "/persist/menu/menu_player.lua")
dofile(modPath .. "/persist/menu/menu_utils.lua")
