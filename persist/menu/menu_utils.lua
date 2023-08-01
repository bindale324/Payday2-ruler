DNC.utils = {}

function DNC.menu.utils()
    return {
        custom = true,
        title = DNC.menu_item[DNC.lan]["utility_List"],
        button_list = {
            {
                text = DNC.menu_item[DNC.lan]["convert_all_enemies"],
                callback_func = DNC.utils.convert_all_enemies,
                in_game = true
            },
            {
                text = DNC.menu_item[DNC.lan]["carry_bags"],
                callback_func = DNC.utils.carry_bags,
                in_game = true,
                close_button = true
            },
            {
                no_text = true,
                no_selection = true
            },
            {
                text = DNC.menu_item[DNC.lan]["close"],
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
