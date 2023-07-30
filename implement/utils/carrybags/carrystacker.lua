function is_playing()
	if not BaseNetworkHandler then 
		return false 
	end
	return BaseNetworkHandler._gamestate_filter.any_ingame_playing[ game_state_machine:last_queued_state_name() ]
end

if not is_playing() then 
	return
end

PlayerManager.carry_stack = {}
--[[local count_table = #PlayerManager.carry_stack + (managers.player:is_carrying() and 1 or 0)
for i = 1, count_table do
	dofile("mods/hook/content/scripts/securecarrybags.lua")
end--]]
--managers.hud:remove_special_equipment("carrystacker")
--managers.player:clear_carry()

global_carry_stacker = global_carry_stacker or false
if not global_carry_stacker then
	if not global_toggle_bag_cooldown then global_toggle_bag_cooldown = PlayerManager.carry_blocked_by_cooldown end
	if not global_toggle_set_carry_off then global_toggle_set_carry_off = PlayerManager.set_carry end
	if not global_toggle_drop_carry_off then global_toggle_drop_carry_off = PlayerManager.drop_carry end
	if not global_toggle_interact_blocked_off then global_toggle_interact_blocked_off = IntimitateInteractionExt._interact_blocked end
	if not global_toggle_interact_blocked_off2 then global_toggle_interact_blocked_off2 = CarryInteractionExt._interact_blocked end
	
	--反作弊
	function PlayerManager.verify_carry() return true end
	function NetworkPeer.verify_bag() return true end
	
	--背包冷却
	function PlayerManager:carry_blocked_by_cooldown() return false end

	function PlayerManager:refresh_stack_counter()
		local count_table = #self.carry_stack + (self:is_carrying() and 1 or 0)
		managers.hud:remove_special_equipment("carrystacker")
		if count_table > 0 then
			managers.hud:add_special_equipment({id = "carrystacker", icon = "pd2_loot", amount = count_table})
		end
	end
	
	--当玩家放下携带的物品时，从堆栈中弹出一个物品
	function PlayerManager:drop_carry( ... ) 
		global_toggle_drop_carry_off(self, ... )
		if #self.carry_stack > 0 then
			local cdata = table.remove(self.carry_stack)
			if cdata then
				self:set_carry(cdata.carry_id, cdata.value or 100, cdata.dye_initiated, cdata.has_dye_pack, cdata.dye_value_multiplier)
			end
		end
		self:refresh_stack_counter()
	end

	-- 如果我们已经携带了一些东西，则将当前项目保存到堆栈中
	function PlayerManager:set_carry( ... )
		if self:is_carrying() and self:get_my_carry_data() then
			table.insert(self.carry_stack, self:get_my_carry_data())
		end
		global_toggle_set_carry_off(self, ...)
		self:refresh_stack_counter()
	end

	--防止阻止我们捡起尸体
	function IntimitateInteractionExt:_interact_blocked( player )
		if self.tweak_data == "corpse_dispose" then
			if not managers.player:has_category_upgrade( "player", "corpse_dispose" ) then
				return true
			end
			return not managers.player:can_carry( "person" )
		end
		return global_toggle_interact_blocked_off(self, player)
	end

	-- 覆盖以始终允许我们拿起随身物品
	function CarryInteractionExt:_interact_blocked( player )
		return not managers.player:can_carry( self._unit:carry_data():carry_id() )
	end

	-- 覆盖以始终允许我们选择携带物品
	function CarryInteractionExt:can_select( player )
		return CarryInteractionExt.super.can_select( self, player )
	end

	managers.mission._fading_debug_output:script().log('Carrystacker (Host) - ACTIVATED',  Color.green)
else
	if global_toggle_bag_cooldown then PlayerManager.carry_blocked_by_cooldown = global_toggle_bag_cooldown end
	if global_toggle_drop_carry_off then PlayerManager.drop_carry = global_toggle_drop_carry_off end
	if global_toggle_set_carry_off then PlayerManager.set_carry = global_toggle_set_carry_off end
	if global_toggle_interact_blocked_off then IntimitateInteractionExt._interact_blocked = global_toggle_interact_blocked_off end
	if global_toggle_interact_blocked_off2 then CarryInteractionExt._interact_blocked = global_toggle_interact_blocked_off2 end
	managers.hud:remove_special_equipment("carrystacker")
	managers.player:clear_carry()
	managers.mission._fading_debug_output:script().log('Carrystacker (Host) - DEACTIVATED',  Color.red)
end
global_carry_stacker = not global_carry_stacker