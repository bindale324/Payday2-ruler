DNC.attack = {}

function DNC.menu.attack()
    return {
        custom = true,
        title = "Attack List",
        button_list = {
            {
                text = "kill and tie", -- this can kill all enemies in the map, and tie civilians and also answer the pager.
                callback_func = DNC.attack.kill_and_tie,
                close_button = true
            },
            {
                text = "victory immediately", -- this can make the game victory immediately.
                callback_func = DNC.attack.victory_immediately,
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

function DNC.attack.kill_and_tie()
    dofile("mods/DoNotCheat/implement/attack/kill_and_tie.lua")
end

function DNC.attack.victory_immediately()
    if managers.platform:presence() == "Playing" then
        local num_winners = managers.network:session():amount_of_alive_players()
        managers.network:session():send_to_peers("mission_ended", true, num_winners)
        game_state_machine:change_state_by_name(
            "victoryscreen",
            {
                num_winners = num_winners,
                personal_win = true,
            })
    end
    DNC.logMessage("You have won the game!", DNC.loglevel.INFO)
end

DNCMenuAttack = true
