function DNC.menu.attack()
    return {
        custom = true,
        title = "Attack List",
        button_list = {
            {
                text = "kill and tie",
                callback_func = DNC.attack.kill_and_tie
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

function DNC.attack.kill_and_tie()
    dofile("mods/DoNotCheat/menu_impl/attack/kill_and_tie.lua")
end

DNCMenuAttack = true
