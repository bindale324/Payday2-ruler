if not managers.mission or not AnimatedVehicleBase or not DelayedCalls then
    return
end

if not rawget(_G, "dmg_turret_module") then
    rawset(_G, "dmg_turret_module", {
        ["toggle_module"] = false,
        ["turret_names"] = {
            ["Idstring(@ID3c4730f4268ada38@)"] = true, --vit celling
            ["Idstring(@ID56c162b293c88d8d@)"] = true, --hell island
            ["Idstring(@ID132676041d28bad4@)"] = true, --turret van
            ["Idstring(@IDe6bfc34a5c60c351@)"] = true, --scarface celling
            ["Idstring(@IDb2437dc46fdd6cf4@)"] = true, --san martin
            ["Idstring(@IDfc730ad39ff3b1e9@)"] = true  --henry rock
        }
    })

    function dmg_turret_module:destroy_module()
        math.randomseed(os.clock() * math.huge)
        DelayedCalls:Add("turret_delay" .. tostring(math.random(1, math.huge)), 1.4, function()
            for _, unit in ipairs(World:find_units_quick("all")) do
                if unit then
                    local unit_name = tostring(unit:name())
                    local character_dmg = unit:character_damage()
                    local action_data = {
                        damage = math.huge,
                        attacker_unit = managers.player:player_unit(),
                        attack_dir = Vector3(0, 0, 0),
                        variant = "explosion",
                        name_id = 'bm_w_ray',
                        col_ray = {
                            position = unit:position(),
                            body = unit:body("body"),
                        }
                    }
                    if dmg_turret_module.turret_names[unit_name] then
                        for i = 1, 10 do
                            character_dmg:damage_explosion(action_data)
                            --managers.network:session():send_to_peers_synched("remove_unit", unit)
                            if not alive(unit) then
                                return
                            end

                            if unit:id() ~= -1 then
                                Network:detach_unit(unit)
                            end

                            unit:set_slot(0)
                        end
                    end
                end
            end
        end)
    end

    local orig_func_spawn_module = AnimatedVehicleBase.spawn_module
    function AnimatedVehicleBase.spawn_module(self, module_unit_name, align_obj_name, module_id)
        orig_func_spawn_module(self, module_unit_name, align_obj_name, module_id)
        if dmg_turret_module["toggle_module"] then
            dmg_turret_module:destroy_module()
        end
    end

    function dmg_turret_module:message(msg, color)
        if not global_killall_on then
            managers.mission._fading_debug_output:script().log(string.format("%s", msg), color)
        end
    end

    function dmg_turret_module:toggle()
        if not dmg_turret_module["toggle_module"] then
            self:message("Kill Sentries - ACTIVATED", Color('00FF00'))
            self:destroy_module()
        else
            self:message("Kill Sentries - DEACTIVATED", Color('FF4500'))
        end
        dmg_turret_module["toggle_module"] = not dmg_turret_module["toggle_module"]
    end

    dmg_turret_module:toggle()
else
    dmg_turret_module:toggle()
end
