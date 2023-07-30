function DNC.menu.main()
    return {
        custom = true,
        title = "Do Not Cheat v" .. DNC.version,
        text = "by samuraibupt, 虚无",
        button_list = {
            {
                text = "attack",
                open_menu = DNC.menu.attack(),
                in_game = true
            },
            {
                text = "player",
                open_menu = DNC.menu.player(),
                in_game = true
            },
            {
                text = "utils",
                open_menu = DNC.menu.utils()
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

DNCMenuMain = true
