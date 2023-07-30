DNC.utils = {}

function DNC.menu.utils()
    return {
        custom = true,
        title = "utility List",
        button_list = {
            {
                text = "convert all enemies",
                callback_func = DNC.utils.convert_all_enemies,
                in_game = true
            },
            {
                text = "carry bags",
                callback_func = DNC.utils.carry_bags,
                in_game = true,
                close_button = true
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
    dofile("mods/DoNotCheat/implement/utils/convert_all_enemies.lua")
end

function DNC.utils.carry_bags()
    dofile("mods/DoNotCheat/implement/utils/carrybags/carrystacker_client.lua")
end

DNCMenuUtils = true
