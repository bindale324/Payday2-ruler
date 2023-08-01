DNC.player = {}

function DNC.menu.player()
    return {
        custom = true,
        title = DNC.menu_item[DNC.lan]["Player_Board"],
        button_list = {
            {
                text = DNC.menu_item[DNC.lan]["Aimbot"], -- aimbot by Mayzone
                callback_func = DNC.player.aimbot
            },
            {
                text = DNC.menu_item[DNC.lan]["Player_Control"], -- aimbot by Mayzone
                callback_func = DNC.player.player_control,
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

function DNC.player.aimbot()
    dofile("mods/DoNotCheat/implement/player/aimbot.lua")
end

function DNC.player.player_control()
    dofile("mods/DoNotCheat/implement/player/control.lua")
end

DNCMenuPlayer = true
