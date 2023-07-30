if Network:is_server() then
	local peer = managers.network:session():local_peer():id()
	local carry_data = managers.player._global.synced_carry
	if peer then
		managers.loot:secure(carry_data[peer].carry_id, carry_data[peer].multiplier, true, peer)
		managers.mission._fading_debug_output:script().log(string.format("Secured %s", carry_data[peer].carry_id),  Color.green)
	end
	DelayedCalls:Add( "securecarrybags", 1, function()
		if not alive(managers.player:player_unit()) then return end
		managers.player:clear_carry()
	end)
else --only for heists were you spawn same place everytime
	local level_table = {
		["rat"] = {
			position = Vector3(5700, -10625, 100)
		},
		["alex_1"] = {
			position = Vector3(5700, -10625, 100)
		},
		["alex_2"] = {
			position = false
		},
		["alex_3"] = {
			position = false
		},
		["branchbank"] = {
			position = Vector3(-13300, 1000, 200)
		},
		["cane"] = {
			position = Vector3(7837, -991, -475.28)
		},
		["kosugi"] = {
			position = false--Vector3(-2184, -2374, 1180)
		},
		["framing_frame_1"] = {
			position = Vector3(1154, -4298, 222)
		},
		["framing_frame_2"] = {
			position = false
		},
		["framing_frame_3"] = {
			position = Vector3(-1079, 6491, 4833)
		},
		["gallery"] = {
			position = Vector3(1154, -4298, 222)
		},
		["election_day_3_skip1"] = {
			position = Vector3(-1842, -6047, 88.331)
		},
		["crojob2"] = {
			position = Vector3(-3907, 9638, -118)
		},
		["crojob3"] = {
			position = false
		},
		["crojob3_night"] = {
			position = false
		},
		["election_day_1"] = {
			position = false
		},
		["election_day_2"] = {
			position = Vector3(-175, 4125, 125)
		},
		["election_day_3"] = {
			position = false
		},
		["election_day_3_skip1"] = {
			position = Vector3(-1842, -6047, 88.331)
		},
		["election_day_3_skip2"] = {
			position = false
		},
		["mia_1"] = {
			position = false
		},
		["mia_2"] = {
			position = false
		},
		["mia2_new"] = {
			position = false
		},
		["mex_cooking"] = {
			position = false
		},
		-------------------------
		["big"] = {
			position = false
		},
		["mus"] = {
			position = false
		},
		["hox_1"] = {
			position = false
		},
		["hox_2"] = {
			position = false
		},
		["hox_3"] = {
			position = false
		},
		["watchdogs_1"] = {
			position = false
		},
		["watchdogs_1_night"] = {
			position = false
		},
		["watchdogs_2"] = {
			position = false
		},
		["watchdogs_2_day"] = {
			position = false
		},
		["firestarter_1"] = {
			position = false
		},
		["firestarter_2"] = {
			position = false
		},
		["firestarter_3"] = {
			position = false
		},
		["welcome_to_the_jungle_1"] = {
			position = false
		},
		["welcome_to_the_jungle_1_night"] = {
			position = false
		},
		["welcome_to_the_jungle_2"] = {
			position = false
		},
		["four_stores"] = {
			position = false
		},
		["mallcrasher"] = {
			position = false
		},
		["nightclub"] = {
			position = false
		},
		["shoutout_raid"] = {
			position = false
		},
		["pines"] = {
			position = false
		},
		["ukrainian_job"] = {
			position = false
		},
		["escape_cafe"] = {
			position = false
		},
		["escape_cafe_day"] = {
			position = false
		},
		["escape_park"] = {
			position = false
		},
		["escape_park_day"] = {
			position = false
		},
		["escape_overpass"] = {
			position = false
		},
		["escape_overpass_night"] = {
			position = false
		},
		["escape_street"] = {
			position = false
		},
		["escape_garage"] = {
			position = false
		},
		["driving_escapes_industry_day"] = {
			position = false
		},
		["driving_escapes_city_day"] = {
			position = false
		},
		["blueharvest_3"] = {
			position = false
		},
		["escape_hell"] = {
			position = false
		},
		["safehouse"] = {
			position = false
		},
		["jewelry_store"] = {
			position = false
		},
		["family"] = {
			position = false
		},
		["cage"] = {
			position = false
		},
		["arm_cro"] = {
			position = false
		},
		["arm_hcm"] = {
			position = false
		},
		["arm_fac"] = {
			position = false
		},
		["arm_und"] = {
			position = false
		},
		["arm_par"] = {
			position = false
		},
		["arm_for"] = {
			position = false
		},
		["roberts"] = {
			position = Vector3(-8025, -3837, 285.86)
		},
		["arena"] = {
			position = false
		},
		["kenaz"] = {
			position = false
		},
		["jolly"] = {
			position = false
		},
		["red2"] = {
			position = Vector3(math.random(40000, 78000), math.random(-40000, -110000), 0) -- needed to remove bag
		},
		["pex"] = {
			position = Vector3(math.random(40000, 78000), math.random(-40000, -110000), 0) -- needed to remove bag
		},
		["dinner"] = {
			position = false
		},
		["pbr"] = {
			position = false
		},
		["pbr2"] = {
			position = false
		},
		["nail"] = {
			position = Vector3(-10356.9, -322.8, -3020.3)
		},
		["peta"] = {
			position = false
		},
		["peta2"] = {
			position = false
		},
		["pal"] = {
			position = false
		},
		["man"] = {
			position = false
		},
		["dark"] = {
			position = false
		},
		["mad"] = {
			position = false
		},
		["biker_train"] = {
			position = false
		},
		["born"] = {
			position = false
		},
		["chew"] = {
			position = false
		},
		["short1_stage1"] = {
			position = false
		},
		["short1_stage2"] = {
			position = false
		},
		["short2_stage1"] = {
			position = false
		},
		["short2_stage2b"] = {
			position = false
		},
		["chill"] = {
			position = false
		},
		["chill_combat"] = {
			position = false
		},
		["friend"] = {
			position = false
		},
		["flat"] = {
			position = false
		},
		["help"] = {
			position = false
		},
		["moon"] = {
			position = false
		},
		["spa"] = {
			position = false
		},
		["fish"] = {
			position = false
		},
		["haunted"] = {
			position = false
		},
		["run"] = {
			position = false
		},
		["dah"] = {
			position = false
		},
		["rvd1"] = {
			position = false
		},
		["rvd2"] = {
			position = false
		},
		["hvh"] = {
			position = false
		},
		["wwh"] = {
			position = false
		},
		["brb"] = {
			position = false
		},
		["tag"] = {
			position = false
		},
		["des"] = {
			position = false
		},
		["sah"] = {
			position = false
		},
		["skm_mus"] = {
			position = false
		},
		["skm_red2"] = {
			position = false
		},
		["skm_run"] = {
			position = false
		},
		["skm_watchdogs_stage2"] = {
			position = false
		},
		["tag"] = {
			position = false
		}
	}
	
	local level_id = managers.job:current_level_id()
	local carry_data = managers.player:get_my_carry_data()
	local rotation = managers.player:player_unit():camera():rotation()
	local forward = managers.player:player_unit():camera():forward()
	if (level_table[level_id].position == false) then
		managers.loot:secure(carry_data.carry_id, managers.money:get_bag_value(carry_data.carry_id), true)
		managers.network:session():send_to_host("server_drop_carry", carry_data.carry_id, carry_data.multiplier, carry_data.dye_initiated, carry_data.has_dye_pack, carry_data.dye_value_multiplier, Vector3(math.random(20000, 78000), math.random(-20000, -110000), 0), Vector3(math.random(-180, 180), math.random(-180, 180), 0), Vector3(0, 0, 1), 1, nil)
		managers.player:clear_carry()
	else
		local secure_position = level_table[level_id].position
		managers.network:session():send_to_host("server_drop_carry", carry_data.carry_id, carry_data.multiplier, carry_data.dye_initiated, carry_data.has_dye_pack, carry_data.dye_value_multiplier, secure_position, Vector3(math.random(-180, 180), math.random(-180, 180), 0), Vector3(0, 0, 1), 1, nil)
		managers.player:clear_carry()
	end
	managers.mission._fading_debug_output:script().log(string.format("Secured %s", carry_data.carry_id),  Color.green)
end