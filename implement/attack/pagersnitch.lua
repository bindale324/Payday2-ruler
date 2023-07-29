if not CopBrain or not CopDamage or not PlayerManager or not managers.chat then
    return
end

if not rawget(_G, "pager_snitcher") then
    rawset(_G, "pager_snitcher", {
        ["toggle_alert"] = false,   --choose pager when alert or not
        ["toggle_for_team"] = true, --toggle for other players
        ["boost_upgrade_value"] = {
            player = {
                melee_kill_snatch_pager_chance = 1 --100%
            }
        }
    })

    function pager_snitcher:melee_on_proj(unit, attack_data)
        local dmg = (attack_data.damage) * (CopDamage._marked_dmg_mul or 1)
        if alive(unit) and (dmg > 0) then
            unit:character_damage():damage_melee({
                damage = unit:character_damage()._HEALTH_INIT,
                attacker_unit = managers.player._players[1],
                attack_dir = Vector3(0, 0, 0),
                variant = "melee",
                name_id = 'cqc',
                col_ray = { position = unit:position(), body = unit:body("body") }
            })
        end
    end

    function pager_snitcher:check(unit, attack_data)
        local alerted = global_killall_on or alive(unit) and unit:movement() and unit:movement():cool()
        local stealth = global_killall_on or alerted and managers.groupai:state():whisper_mode()
        if (global_pager_snitch_toggle and stealth and (unit:unit_data().has_alarm_pager) and (not self["toggle_alert"] or alerted)) then
            unit:unit_data().has_alarm_pager = false
            self:melee_on_proj(unit, attack_data)
        end
    end

    local orig_pm_ug = PlayerManager.upgrade_value
    function PlayerManager.upgrade_value(self, category, upgrade, default, ...)
        local original_value = orig_pm_ug(self, category, upgrade, default, ...)
        if global_pager_snitch_toggle then
            local boost = pager_snitcher["boost_upgrade_value"]
            if ((boost[category]) and (boost[category][upgrade])) then
                original_value = (original_value + boost[category][upgrade])
            end
        end
        return original_value
    end

    local _CopDamage_damage_bullet = CopDamage.damage_bullet
    function CopDamage.damage_bullet(self, attack_data, ...)
        pager_snitcher:check(self._unit, attack_data)
        return _CopDamage_damage_bullet(self, attack_data, ...)
    end

    local _CopDamage_damage_fire = CopDamage.damage_fire
    function CopDamage.damage_fire(self, attack_data, ...)
        pager_snitcher:check(self._unit, attack_data)
        return _CopDamage_damage_fire(self, attack_data, ...)
    end

    local _CopDamage_damage_explosion = CopDamage.damage_explosion
    function CopDamage.damage_explosion(self, attack_data, ...)
        pager_snitcher:check(self._unit, attack_data)
        return _CopDamage_damage_explosion(self, attack_data, ...)
    end

    local _CopDamage_damage_melee = CopDamage.damage_melee
    function CopDamage.damage_melee(self, attack_data, ...)
        if global_pager_snitch_toggle then attack_data.damage = attack_data.damage * math.huge end
        return _CopDamage_damage_melee(self, attack_data, ...)
    end

    local orig_func_cop_brain = CopBrain.clbk_death
    function CopBrain.clbk_death(self, my_unit, damage_info, ...)
        if global_pager_snitch_toggle and pager_snitcher["toggle_for_team"] then
            pager_snitcher:check(self._unit, { damage = 1 })
        end
        orig_func_cop_brain(self, my_unit, damage_info, ...)
    end

    function pager_snitcher:toggle()
        global_pager_snitch_toggle = global_pager_snitch_toggle or false
        if not global_pager_snitch_toggle then
            if not global_killall_on then --for not spam msg when kill loop is used
                managers.chat:_receive_message(1, "Snatcher", string.format("Player (client/host): true"),
                    tweak_data.system_chat_color)
                managers.chat:_receive_message(1, "Snatcher", string.format("Team (host): true"),
                    tweak_data.system_chat_color)
            end
        else
            if not global_killall_on then
                managers.chat:_receive_message(1, "Snatcher", string.format("Player (client/host): false"),
                    tweak_data.system_chat_color)
                managers.chat:_receive_message(1, "Snatcher", string.format("Team (host): false"),
                    tweak_data.system_chat_color)
            end
        end
        global_pager_snitch_toggle = not global_pager_snitch_toggle
    end

    pager_snitcher:toggle()
else
    pager_snitcher:toggle()
end
