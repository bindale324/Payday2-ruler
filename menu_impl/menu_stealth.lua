function DNC.menu.stealth()
    return {
        custom = true,
        title = "stealth List",
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

DNCMenuStealth = true
