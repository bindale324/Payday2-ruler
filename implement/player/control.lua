dofile(ModPath .. "persist/core/dnclogtool.lua")

function in_game()
	if not game_state_machine then return false end
	return string.find(game_state_machine:current_state_name(), "game")
end

if not in_game() then
	DNC.logMessageOutGame("You are not in game!", DNC.loglevel.ERROR)
	return
end

function get_peers(code, unitcheck)
	local peerid = tonumber(code)
	local me = managers.network:session():local_peer():id()
	if not peerid or peerid and (peerid < 1 or peerid > 4) then
		local tab = {}
		for x = 1, 4 do
			if managers.network:session():peer(x) then
				if not (unitcheck or unitcheck and managers.network:session():peer(x):unit()) then
					table.insert(tab, x)
				end
			end
		end
		if code == "*" then -- everyone
			return tab
		elseif code == "?" then -- random
			peerid = tab[math.random(1, #tab)]
		elseif code == "!" then
			table.remove(tab, me)
			return tab
		else
			peerid = me
		end

		tab = nil
	end
	if peerid and managers.network:session():peer(peerid) then
		if not unitcheck or (unitcheck and managers.network:session():peer(peerid):unit()) then
			return { peerid }
		end
	end
	return
end

function verify_player_id(id)
	if not managers.network:session() then return false end
	return managers.network:session():peer(id) and managers.criminals:character_name_by_peer_id(id)
end

--single states
local normal_state_player = function(id, state)
	local ids = get_peers(id)
	if ids then
		for _, id in pairs(ids) do
			local peer = managers.network:session():peer(id)
			local network, send
			if alive(peer:unit()) then
				network = peer:unit():network()
				send = network.send
			end

			local unit = peer:unit()
			if peer then
				if network and send then
					if state == "dead" then
						send(network, "sync_player_movement_state", "dead", 0, peer:id())
						send(network, "set_health", 0)
						network:send_to_unit({ "spawn_dropin_penalty", true, nil, 0, nil, nil })
						managers.groupai:state():on_player_criminal_death(peer:id())
					elseif state == "tased" then
						send(network, "sync_player_movement_state", "tased", 0, peer:id())
					elseif state == "incapacitated" then
						send(network, "sync_player_movement_state", "incapacitated", 0, peer:id())
					elseif state == "arrested" then
						send(network, "sync_player_movement_state", "arrested", 0, peer:id())
					elseif state == "standard" then
						send(network, "sync_player_movement_state", "standard", 0, peer:id())
					elseif state == "teleport" then
						managers.player:warp_to(unit:position(), unit:rotation())
					elseif state == "teleporttoyou" then
						send(network, "sync_player_movement_state", "dead", 0, peer:id())
						send(network, "set_health", 0)
						network:send_to_unit({ "spawn_dropin_penalty", true, nil, 0, nil, nil })
						managers.groupai:state():on_player_criminal_death(peer:id())
						DelayedCalls:Add("teleport_all", 2, function()
							IngameWaitingForRespawnState.request_player_spawn(peer:id())
						end)
					elseif state == "cheated" then
						local tag = "Ate Ass"
						local r, g, b = 185 / 255, 80 / 255, 199 / 255
						_color = Color(r, g, b)
						--_color = tweak_data.screen_colors.pro_color
						local name_label = managers.hud:_name_label_by_peer_id(peer:id())
						if name_label then
							name_label.panel:child("cheater"):set_visible(true)
							name_label.panel:child("cheater"):set_text(tag:upper())
							name_label.panel:child("cheater"):set_color(_color)
						end
					end
					managers.mission._fading_debug_output:script().log(string.format("%s - %s", peer:name(), state),
						Color.green)
				else
					if state == "release" then
						if verify_player_id(id) then
							IngameWaitingForRespawnState.request_player_spawn(peer:id())
						end
					end
					managers.mission._fading_debug_output:script().log(string.format("%s - %s", peer:name(), state),
						Color.green)
				end
			end
		end
	end
end

--team states
local team_state_player = function(state)
	if state == "dead" then
		for id, data in pairs(managers.criminals._characters) do
			local unit = data.unit
			local bot = data.data.ai
			local name = data.name
			if bot and alive(unit) then
				local crim_data = managers.criminals:character_data_by_name(name)
				if crim_data then
					managers.hud:set_mugshot_custody(crim_data.mugshot_id)
				end
				unit:set_slot(name, 0)
			end
		end
	elseif state == "release" then
		for id, data in pairs(managers.criminals._characters) do
			local spawn_on_unit = (managers.player._players[1]):camera():position()
			local unit = data.unit
			local bot = data.data.ai
			local name = data.name
			if unit ~= null and bot and not alive(unit) then
				managers.trade:remove_from_trade(name)
				managers.groupai:state():spawn_one_teamAI(false, name, spawn_on_unit)
			end
		end
	elseif state == "teleport" then
		for id, data in pairs(managers.criminals._characters) do
			local unit = data.unit
			local bot = data.data.ai
			local name = data.name
			if bot and alive(unit) then
				local crim_data = managers.criminals:character_data_by_name(name)
				if crim_data then
					managers.hud:set_mugshot_custody(crim_data.mugshot_id)
				end
				unit:set_slot(name, 0)
			end
		end
		DelayedCalls:Add("teleport_all_ai", 1.5, function()
			for id, data in pairs(managers.criminals._characters) do
				local spawn_on_unit = (managers.player._players[1]):camera():position()
				local unit = data.unit
				local bot = data.data.ai
				local name = data.name
				if unit ~= null and bot and not alive(unit) then
					managers.trade:remove_from_trade(name)
					managers.groupai:state():spawn_one_teamAI(false, name, spawn_on_unit)
				end
			end
		end)
	end
	local ids = get_peers('!')
	if ids then
		for _, id in pairs(ids) do
			local peer = managers.network:session():peer(id)
			local network, send
			if alive(peer:unit()) then
				network = peer:unit():network()
				send = network.send
			end

			local unit = peer:unit()
			if peer then
				if network and send then
					if state == "dead" then
						send(network, "sync_player_movement_state", "dead", 0, peer:id())
						send(network, "set_health", 0)
						network:send_to_unit({ "spawn_dropin_penalty", true, nil, 0, nil, nil })
						managers.groupai:state():on_player_criminal_death(peer:id())
					elseif state == "tased" then
						send(network, "sync_player_movement_state", "tased", 0, peer:id())
					elseif state == "incapacitated" then
						send(network, "sync_player_movement_state", "incapacitated", 0, peer:id())
						for _, data in pairs(managers.criminals:characters()) do
							if data.data.ai and alive(data.unit) then
								data.unit:character_damage():clbk_exit_to_dead()
							end
						end
					elseif state == "arrested" then
						send(network, "sync_player_movement_state", "arrested", 0, peer:id())
					elseif state == "standard" then
						send(network, "sync_player_movement_state", "standard", 0, peer:id())
					elseif state == "teleport" then
						send(network, "sync_player_movement_state", "dead", 0, peer:id())
						send(network, "set_health", 0)
						network:send_to_unit({ "spawn_dropin_penalty", true, nil, 0, nil, nil })
						managers.groupai:state():on_player_criminal_death(peer:id())
						DelayedCalls:Add("teleport_all", 1.5, function()
							IngameWaitingForRespawnState.request_player_spawn(peer:id())
						end)
					elseif state == "cheated" then
						local tag = "Ate Ass"
						_color = tweak_data.screen_colors.pro_color
						local name_label = managers.hud:_name_label_by_peer_id(peer:id())
						if name_label then
							name_label.panel:child("cheater"):set_visible(true)
							name_label.panel:child("cheater"):set_text(tag:upper())
							name_label.panel:child("cheater"):set_color(_color)
						end
					end
					managers.mission._fading_debug_output:script().log(string.format("%s - %s", peer:name(), state),
						Color.green)
				else
					if state == "release" then
						if verify_player_id(id) then
							IngameWaitingForRespawnState.request_player_spawn(peer:id())
						end
					end
					managers.mission._fading_debug_output:script().log(string.format("%s - %s", peer:name(), state),
						Color.green)
				end
			end
		end
	end
end

--own states
local change_own_state = function(state)
	if alive(managers.player:player_unit()) then
		if state == "jail" then
			local player = managers.player:local_player()
			managers.player:force_drop_carry()
			managers.statistics:downed({ death = true })
			IngameFatalState.on_local_player_dead()
			game_state_machine:change_state_by_name("ingame_waiting_for_respawn")
			player:character_damage():set_invulnerable(true)
			player:character_damage():set_health(0)
			player:base():_unregister()
			player:base():set_slot(player, 0)
		else
			managers.player:set_player_state(state)
		end
	else
		if state == "release" then
			IngameWaitingForRespawnState.request_player_spawn(id)
		end
	end
	managers.mission._fading_debug_output:script().log(string.format("%s", state), Color.green)
end

local EAP = function()
	function LevelsTweakData:get_default_team_ID(type)
		local lvl_tweak = self[Global.level_data.level_id]
		if lvl_tweak and lvl_tweak.default_teams and lvl_tweak.default_teams[type] then
			if lvl_tweak.teams[lvl_tweak.default_teams[type]] then
				return lvl_tweak.default_teams[type]
			else
				debug_pause("[LevelsTweakData:get_default_player_team_ID] Team not defined ",
					lvl_tweak.default_teams[type], "in", Global.level_data.level_id)
			end
		end
		if type == "player" then
			return "criminal1"
		elseif type == "combatant" then
			return "criminal1"
		elseif type == "non_combatant" then
			return "neutral1"
		else
			return "mobster1"
		end
	end

	managers.mission._fading_debug_output:script().log('团队切换已激活', Color.green)
end
local GAP = function()
	function LevelsTweakData:get_default_team_ID(type)
		local lvl_tweak = self[Global.level_data.level_id]
		if lvl_tweak and lvl_tweak.default_teams and lvl_tweak.default_teams[type] then
			if lvl_tweak.teams[lvl_tweak.default_teams[type]] then
				return lvl_tweak.default_teams[type]
			else
				debug_pause("[LevelsTweakData:get_default_player_team_ID] Team not defined ",
					lvl_tweak.default_teams[type], "in", Global.level_data.level_id)
			end
		end
		if type == "player" then
			return "criminal1"
		elseif type == "combatant" then
			return "law1"
		elseif type == "non_combatant" then
			return "neutral1"
		else
			return "criminal1"
		end
	end

	managers.mission._fading_debug_output:script().log('团队切换已激活', Color.green)
end
local GAE = function()
	function LevelsTweakData:get_default_team_ID(type)
		local lvl_tweak = self[Global.level_data.level_id]
		if lvl_tweak and lvl_tweak.default_teams and lvl_tweak.default_teams[type] then
			if lvl_tweak.teams[lvl_tweak.default_teams[type]] then
				return lvl_tweak.default_teams[type]
			else
				debug_pause("[LevelsTweakData:get_default_player_team_ID] Team not defined ",
					lvl_tweak.default_teams[type], "in", Global.level_data.level_id)
			end
		end
		if type == "player" then
			return "criminal1"
		elseif type == "combatant" then
			return "mobster1"
		elseif type == "non_combatant" then
			return "neutral1"
		else
			return "mobster1"
		end
	end

	managers.mission._fading_debug_output:script().log('团队切换已激活', Color.green)
end
local resetally = function()
	function LevelsTweakData:get_default_team_ID(type)
		local lvl_tweak = self[Global.level_data.level_id]
		if lvl_tweak and lvl_tweak.default_teams and lvl_tweak.default_teams[type] then
			if lvl_tweak.teams[lvl_tweak.default_teams[type]] then
				return lvl_tweak.default_teams[type]
			else
				debug_pause("[LevelsTweakData:get_default_player_team_ID] Team not defined ",
					lvl_tweak.default_teams[type], "in", Global.level_data.level_id)
			end
		end
		if type == "player" then
			return "criminal1"
		elseif type == "combatant" then
			return "law1"
		elseif type == "non_combatant" then
			return "neutral1"
		else
			return "mobster1"
		end
	end

	managers.mission._fading_debug_output:script().log('团队切换已激活', Color.green)
end

menu6 = function(peer_id, peer_name)
	local dialog_data = {
		title = "玩家菜单",
		text = "选择选项",
		button_list = {}
	}

	local single_unit_menu_table = {
		["input"] = {
			{ text = "选择玩家:" .. peer_name },
			{},
			{ text = "监狱玩家", callback_func = function() normal_state_player(peer_id, "dead") end },
			{ text = "释放玩家", callback_func = function() normal_state_player(peer_id, "release") end },
			{ text = "田濑玩家", callback_func = function() normal_state_player(peer_id, "tased") end },
			{ text = "杀死玩家", callback_func = function() normal_state_player(peer_id, "incapacitated") end },
			{ text = "袖口玩家", callback_func = function() normal_state_player(peer_id, "arrested") end },
			{ text = "复活玩家", callback_func = function() normal_state_player(peer_id, "standard") end },
			{ text = "传送到玩家", callback_func = function() normal_state_player(peer_id, "teleport") end },
			{ text = "传送玩家给你", callback_func = function() normal_state_player(peer_id, "teleporttoyou") end },
			{ text = "作弊标签玩家", callback_func = function() normal_state_player(peer_id, "cheated") end },
			{},
			{ text = "返回", callback_func = function() menu4() end },
		}
	}

	local single_unit_menu_array = "input"
	if single_unit_menu_table[single_unit_menu_array] then
		for _, dostuff in pairs(single_unit_menu_table[single_unit_menu_array]) do
			if single_unit_menu_table[single_unit_menu_array] then
				table.insert(dialog_data.button_list, dostuff)
			end
		end
	end

	local no_button = { text = managers.localization:text("dialog_cancel"), cancel_button = true }
	table.insert(dialog_data.button_list, no_button)
	managers.system_menu:show_buttons(dialog_data)
end

menu5 = function()
	local dialog_data = {
		title = "敌人菜单",
		text = "选择选项",
		button_list = {}
	}

	table.insert(dialog_data.button_list, { text = "敌人支援玩家", callback_func = function() EAP() end, })
	table.insert(dialog_data.button_list, { text = "黑帮支援玩家", callback_func = function() GAP() end, })
	table.insert(dialog_data.button_list, { text = "黑帮支援敌人", callback_func = function() GAE() end, })
	table.insert(dialog_data.button_list, { text = "重置", callback_func = function() resetally() end, })

	table.insert(dialog_data.button_list, {})
	table.insert(dialog_data.button_list, { text = "返回", callback_func = function() main_team_menu() end, })
	local no_button = { text = managers.localization:text("dialog_cancel"), cancel_button = true }
	table.insert(dialog_data.button_list, no_button)
	managers.system_menu:show_buttons(dialog_data)
end

menu4 = function()
	local dialog_data = {
		title = "玩家菜单",
		text = "选择选项",
		button_list = {}
	}
	local count_data = #dialog_data.button_list
	local lpeer_id = managers.network._session._local_peer._id

	for _, peer in pairs(managers.network._session._peers) do
		local peer_id = peer._id
		if peer_id ~= lpeer_id then
			local peer_name = peer._name
			table.insert(dialog_data.button_list, {
				text = peer_name,
				callback_func = function() menu6(peer_id, peer_name) end,
			})
		end
	end

	if #dialog_data.button_list == count_data then
		table.insert(dialog_data.button_list, {
			text = "没有玩家",
			callback_func = function() end,
		})
	end

	table.insert(dialog_data.button_list, {})
	table.insert(dialog_data.button_list, { text = "返回", callback_func = function() main_team_menu() end, })
	local no_button = { text = managers.localization:text("dialog_cancel"), cancel_button = true }
	table.insert(dialog_data.button_list, no_button)
	managers.system_menu:show_buttons(dialog_data)
end

menu3 = function()
	local dialog_data = {
		title = "自己菜单",
		text = "选择选项",
		button_list = {}
	}
	local cstate = managers.player._current_state
	table.insert(dialog_data.button_list, { text = "当前状态：" .. cstate, })
	table.insert(dialog_data.button_list, {})
	for _, state in pairs(managers.player:player_states()) do
		if state ~= "jerry2" and state ~= "fatal" and state ~= "bleed_out" and state ~= "bipod" and state ~= "driving" then
			table.insert(dialog_data.button_list, {
				text = state,
				callback_func = function() change_own_state(state) end,
			})
		end
	end
	table.insert(dialog_data.button_list, { text = "监狱", callback_func = function() change_own_state("jail") end, })
	table.insert(dialog_data.button_list, { text = "释放", callback_func = function() change_own_state("release") end, })

	table.insert(dialog_data.button_list, {})
	table.insert(dialog_data.button_list, { text = "返回", callback_func = function() main_team_menu() end, })
	local no_button = { text = managers.localization:text("dialog_cancel"), cancel_button = true }
	table.insert(dialog_data.button_list, no_button)
	managers.system_menu:show_buttons(dialog_data)
end

menu2 = function()
	local dialog_data = {
		title = "团队菜单",
		text = "选择选项",
		button_list = {}
	}

	local team_unit_menu_table = {
		["input"] = {
			{ text = "prison whole team",  callback_func = function() team_state_player("dead") end },
			{ text = "release whole team", callback_func = function() team_state_player("release") end },
			{ text = "tased",              callback_func = function() team_state_player("tased") end },
			{ text = "kill whole team",    callback_func = function() team_state_player("incapacitated") end },
			{ text = "arrest whole team",  callback_func = function() team_state_player("arrested") end },
			{ text = "reborn",             callback_func = function() team_state_player("standard") end },
			{ text = "teleport",           callback_func = function() team_state_player("teleport") end },
			{ text = "label cheat",        callback_func = function() team_state_player("cheated") end },
			{},
			{ text = "back",               callback_func = function() main_team_menu() end },
		}
	}

	local team_unit_menu_array = "input"
	if team_unit_menu_table[team_unit_menu_array] then
		for _, dostuff in pairs(team_unit_menu_table[team_unit_menu_array]) do
			if team_unit_menu_table[team_unit_menu_array] then
				table.insert(dialog_data.button_list, dostuff)
			end
		end
	end

	local no_button = { text = managers.localization:text("dialog_cancel"), cancel_button = true }
	table.insert(dialog_data.button_list, no_button)
	managers.system_menu:show_buttons(dialog_data)
end

main_team_menu = function()
	local dialog_data = {
		title = "团队菜单",
		text = "选择选项",
		button_list = {}
	}

	local main_menu_table = {
		["input"] = {
			{ text = "团队状态", callback_func = function() menu2() end },
			{ text = "玩家状态", callback_func = function() menu4() end },
			{ text = "自己状态", callback_func = function() menu3() end },
			{},
			{ text = "敌方状态", callback_func = function() menu5() end },
		}
	}

	local main_menu_array = "input"
	if main_menu_table[main_menu_array] then
		for _, dostuff in pairs(main_menu_table[main_menu_array]) do
			if main_menu_table[main_menu_array] then
				table.insert(dialog_data.button_list, dostuff)
			end
		end
	end

	table.insert(dialog_data.button_list, {})
	local no_button = { text = managers.localization:text("dialog_cancel"), cancel_button = true }
	table.insert(dialog_data.button_list, no_button)
	managers.system_menu:show_buttons(dialog_data)
end
main_team_menu()
