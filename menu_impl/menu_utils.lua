DNC.utils = {}

function DNC.menu.utils()
    return {
        custom = true,
        title = "utility List",
        button_list = {
            {
                text = "convert all enemies",
                callback_func = DNC.utils.convert_all_enemies
            },
            {
                no_text = true,
                no_selection = true
            },
            {
                text = "close",
                cancel_button = true
            }
        }
    }
end

function DNC.utils.convert_all_enemies()
    dofile("mods/DoNotCheat/menu_impl/utils/convert_all_enemies.lua")
end

DNCMenuUtils = true
