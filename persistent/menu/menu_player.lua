DNC.player = {}

function DNC.menu.player()
    return {
        custom = true,
        title = "Player Board",
        button_list = {
            {
                text = "Aimbot", -- aimbot by Mayzone
                callback_func = DNC.player.aimbot
            },
            {
                text = "Player Control", -- aimbot by Mayzone
                callback_func = DNC.player.player_control,
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

function DNC.player.aimbot()
    dofile("mods/DoNotCheat/implement/player/aimbot.lua")
end

function DNC.player.player_control()
    dofile("mods/DoNotCheat/implement/player/control.lua")
end

DNCMenuPlayer = true
