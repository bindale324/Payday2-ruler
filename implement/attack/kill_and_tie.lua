local enemies = managers.enemy:all_enemies()
local civilians = managers.enemy:all_civilians()
local id_level = managers.job:current_level_id()
local stealth = managers.groupai:state():whisper_mode()
local player_unit = managers.player:player_unit()

local function is_playing()
    if not BaseNetworkHandler
    then
        return false
    end
    return BaseNetworkHandler._gamestate_filter.any_ingame_playing[game_state_machine:last_queued_state_name()]
end

if not is_playing() then
    return
end

local function can_interact()
    return true
end

local function is_hostage(unit)
    if alive(unit) then
        local brain = unit.brain
        brain = brain and brain(unit)
        if brain then
            local is_hostage = brain.is_hostage
            is_hostage = is_hostage and is_hostage(brain)
            if is_hostage then
                return true
            end
        end
        local anim_data = unit.anim_data
        anim_data = anim_data and anim_data(unit)
        if anim_data then
            local tied = anim_data.tied or anim_data.hands_tied
            if tied then
                return true
            end
        end
    end
    return false
end

-- kill cameras
-- unit: for _, unit in pairs(SecurityCamera.cameras)
local function dmg_cam(unit)
    local position = unit:position()
    local body
    do
        local i = -1
        repeat
            i = i + 1
            body = unit:body(i)
        until (body and body:extension()) or i >= 5
        if not body then
            return
        end
    end
    body:extension().damage:damage_melee(unit, nil, position, nil, 10000)
    managers.network:session():send_to_peers_synched("sync_body_damage_melee", body, unit, nil, position, nil, 10000)
end

local function dmg_melee(unit, player_unit)
    local action_data = {
        damage = unit:character_damage()._HEALTH_INIT,
        raw_damage = 1,
        attacker_unit = player_unit,
        attack_dir = Vector3(0, 0, 0),
        weapon_unit = managers.player:player_unit():inventory():equipped_unit(),
        variant = "fire",
        critical_hit = false,
        stagger = false,
        knock_down = false,
        fire_dot_data = {
            dot_trigger_max_distance = 1300,
            dot_trigger_chance = 1,
            dot_length = 1,
            dot_damage = 10,
            start_dot_dance_antimation = false,
            dot_tick_period = 0.5
        },
        col_ray = {
            position = unit:position(),
            body = unit:body("body"),
            unit = unit,
            normal = Vector3(0, 0, 0)
        }
    }
    unit:character_damage():damage_fire(action_data)
end


local function check_kill(unit, unit_tweak, player_unit)
    if not is_hostage(unit) or (unit_tweak == "bank_manager") then
        if (unit_tweak ~= "mute_security_undominatable") then
            pcall(dmg_melee, unit, player_unit)
        end
    end
end

local function interactbytweak()
    for _, unit in pairs(managers.interaction._interactive_units) do
        if not alive(unit) then
            for _, u_data in pairs(civilians) do
                local unit_tweak = u_data.unit:base()._tweak_table
                check_kill(u_data.unit, unit_tweak, player_unit)
            end
            return
        end
        local interaction = unit:interaction()
        if interaction and (interaction.tweak_data == "intimidate") then
            interaction.can_interact = can_interact
            interaction:interact(managers.player:player_unit())
            interaction.can_interact = nil
        end
    end
end

local function killall()
    global_killall_on = true

    if not global_pager_snitch_toggle then
        dofile("mods/DoNotCheat/implement/attack/pagersnitch.lua")
    end

    -- --kill sentries
    -- if not stealth then
    --     dofile("mods/DoNotCheat/menu_impl/attack/kill_sentries.lua")
    --     dofile("mods/DoNotCheat/menu_impl/attack/kill_sentries.lua")
    -- end

    --kills cams
    if (id_level ~= 'tag') then
        for _, unit in pairs(SecurityCamera.cameras) do
            pcall(dmg_cam, unit)
        end
    end

    --tie/kill civs
    if (id_level ~= 'cane') then
        for i = 0, 4 do
            DelayedCalls:Add("killall_tie_civ_delay_" .. tostring(i), i, function()
                for _, u_data in pairs(civilians) do
                    if not is_hostage(u_data.unit) then
                        if stealth then
                            if (id_level ~= 'tag' and id_level ~= 'pex' and id_level ~= 'nmh') then
                                local alert = {
                                    "explosion",
                                    u_data.unit:movement():m_head_pos(),
                                    10000,
                                    u_data.SO_access,
                                    u_data.unit
                                }
                                managers.groupai:state():propagate_alert(alert)

                                u_data.unit:play_redirect(Idstring("idle"))
                                managers.network:session():send_to_peers("play_distance_interact_redirect", u_data.unit,
                                    "idle")

                                if Network:is_server() then
                                    u_data.unit:brain():set_objective({
                                        is_default = true,
                                        type = "free"
                                    })

                                    action_data = {
                                        variant = "stand",
                                        body_part = 1,
                                        type = "act"
                                    }
                                    u_data.unit:brain():action_request(action_data)
                                end
                            end
                        end
                        u_data.unit:brain():on_intimidated(100, player_unit)
                        u_data.unit:brain():on_tied(player_unit)
                        interactbytweak()
                    end
                end
            end)
        end

        DelayedCalls:Add("killall_tie_civ_delay_4", 5, function()
            for _, u_data in pairs(civilians) do
                interactbytweak()
                local unit_tweak = u_data.unit:base()._tweak_table
                check_kill(u_data.unit, unit_tweak, player_unit)
            end
        end)
    end


    --Kills enemies
    for i = 0, 2 do
        DelayedCalls:Add("killall_tie_ene_delay_" .. tostring(i), i, function()
            local minion_table = {}
            for _, u_data in pairs(enemies) do
                local unit = u_data.unit
                local unit_tweak = unit:base()._tweak_table
                if (Network:is_server() and unit:brain() and unit:brain()._logic_data and unit:brain()._logic_data.is_converted and unit.is_converted) or (Network:is_client() and unit.is_converted) then
                    table.insert(minion_table, unit)
                    if stealth or (#minion_table >= 3) then
                        check_kill(unit, unit_tweak, player_unit)
                    end
                else
                    if (id_level == 'nmh' and stealth) then
                    else
                        check_kill(unit, unit_tweak, player_unit)
                    end
                end
            end
        end)
    end

    DelayedCalls:Add("toggle_steal", 2.1, function()
        if global_pager_snitch_toggle then
            dofile("mods/DoNotCheat/implement/attack/pagersnitch.lua")
        end
        global_killall_on = false
    end)

    -- if managers.mission then
    --     managers.mission._fading_debug_output:script().log('Kill all ACTIVATED', Color.green)
    -- end
end

local function ans_pager(unit)
    local player = managers.player:player_unit()
    if not player then
        return
    end

    unit:interaction().can_interact = can_interact
    if Network:is_server() then
        unit:interaction():interact(player)
    else
        local interactions = {}
        local interaction = unit:interaction()
        local vec3 = unit:position()
        interactions[vec3] = interaction
        for _, interaction in pairs(interactions) do
            local u_id = managers.enemy:get_corpse_unit_data_from_key(interaction._unit:key()).u_id

            -- 1=start
            -- 2=interrupted
            -- 3=complete
            managers.network:session():send_to_host("alarm_pager_interaction", u_id, interaction.tweak_data, 1)
            unit:interaction():interact(player)
        end
    end
    unit:interaction().can_interact = nil
end

killall()

DNC.logMessage("Police killed and civilians tied", DNC.loglevel.INFO)

local function ans_pager_activated()
    for _, unit in pairs(managers.interaction._interactive_units) do
        if not alive(unit) then
            break
        end
        local interaction = unit:interaction()
        if interaction and interaction.tweak_data == 'corpse_alarm_pager' then
            ans_pager(unit)
        end
    end
end

DelayedCalls:Add("ans_pager_activated", 2.5, ans_pager_activated)

DNC.logMessage("Pager answered", DNC.loglevel.INFO)
