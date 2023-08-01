local content = DNC.readFile("mods/DoNotCheat/mod_config.json")
local config_table = DNC.jsonDecode(content)

if config_table["language"] == "en" then
    DNC.logMessageOutGame("Language: English", DNC.loglevel.INFO)
else
    DNC.logMessageOutGame("Language: Chinese", DNC.loglevel.INFO)
end

-- menu language convert
DNC.lan = config_table["language"]
DNC.menu_item = config_table["menu_convert"]

function DNC.menu.main()
    return {
        custom = true,
        title = "Do Not Cheat v" .. DNC.version,
        text = "by SamuraiBUPT, 虚无",
        button_list = {
            {
                text = DNC.menu_item[DNC.lan]["attack"],
                open_menu = DNC.menu.attack(),
                in_game = true
            },
            {
                text = DNC.menu_item[DNC.lan]["player"],
                open_menu = DNC.menu.player(),
                in_game = true
            },
            {
                text = DNC.menu_item[DNC.lan]["utils"],
                open_menu = DNC.menu.utils()
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

DNCMenuMain = true
