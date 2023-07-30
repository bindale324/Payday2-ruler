if rawget(_G, "CarryScript") then -- 这允许我们重新加载脚本，以防我们在游戏中进行了一些更改。
	rawset(_G, "CarryScript", nil)
end

if not rawget(_G, "CarryScript") then
	rawset(_G, "CarryScript", {
		BagList = {},
		menu_mode = true,
		carrystack_lastpress = 0
	})

	for _, unit in pairs(managers.interaction._interactive_units) do
		if not alive(unit) then
			-- managers.mission._fading_debug_output:script().log(
			--     string.format("Cant open menu because sentry is/was on the map"), Color.green)
			DNC.logMessage("Cant open menu because sentry is/was on the map", DNC.loglevel.WARN)
			dofile("mods/DoNotCheat/implement/utils/carrybags/carrystacker.lua")
			return
		end
		local interaction = unit:interaction()
		local carry = unit:carry_data()
		if unit and interaction and carry then
			table.insert(CarryScript.BagList, carry:carry_id())
		end
	end
	table.sort(CarryScript.BagList)

	function CarryScript:secure_carry_toggle()
		local count_table = managers.player:is_carrying() and 1 or 0
		for i = 1, count_table do
			dofile("mods/DoNotCheat/implement/utils/carrybags/securecarrybags.lua")
		end
		managers.player:clear_carry()
	end

	function CarryScript:DropCarry()
		local carry_data = managers.player:get_my_carry_data()
		local rotation = managers.player:player_unit():camera():rotation()
		local position = managers.player:player_unit():camera():position()
		local forward = managers.player:player_unit():camera():forward()
		local throw_force = managers.player:upgrade_level("carry", "throw_distance_multiplier", 0)
		if carry_data then
			managers.player:clear_carry()
			if Network:is_server() then
				managers.player:server_drop_carry(carry_data.carry_id, carry_data.multiplier, carry_data.dye_initiated,
					carry_data.has_dye_pack, carry_data.dye_value_multiplier, position, rotation, forward, throw_force,
					zipline_unit, managers.network:session():local_peer())
			else
				managers.network:session():send_to_host("server_drop_carry", carry_data.carry_id, carry_data.multiplier,
					carry_data.dye_initiated, carry_data.has_dye_pack, carry_data.dye_value_multiplier, position,
					rotation, forward, throw_force, nil)
			end
		end
	end

	function CarryScript:InteractBySpecificBag(id)
		if not alive(managers.player:player_unit()) then
			return
		end

		if global_secure_carry then
			self:secure_carry()
		end

		self:DropCarry()

		for _, unit in pairs(managers.interaction._interactive_units) do
			if not alive(unit) then return end
			local interaction = unit:interaction()
			local carry = unit:carry_data()
			if unit and interaction and carry then
				if carry:carry_id() == id then
					interaction:interact(managers.player:player_unit())
					break
				end
			end
		end

		if global_secure_carry then
			self:secure_carry()
		end
	end

	function CarryScript:menu(BagList)
		local dialog_data = {
			title = "搬运车菜单",
			text = "选择选项",
			button_list = {}
		}

		table.insert(dialog_data.button_list, {})
		for _, carry_id in pairs(BagList) do
			local carry_data = tweak_data.carry[carry_id]
			local type_text = managers.localization:text(carry_data.name_id)
			table.insert(dialog_data.button_list, {
				text = type_text,
				callback_func = function()
					self:InteractBySpecificBag(carry_id)
				end
			})
		end

		if not dialog_data.button_list.text == type_text then
			table.insert(dialog_data.button_list, { text = "地图上没有包", })
		end

		table.insert(dialog_data.button_list, {})
		table.insert(dialog_data.button_list, {
			text = "全部捡起来",
			callback_func = function()
				for _, carry_id in pairs(BagList) do
					CarryScript:InteractBySpecificBag(carry_id)
				end
				managers.mission._fading_debug_output:script().log(string.format("全部捡起来激活"), Color.green)
			end
		})
		table.insert(dialog_data.button_list, {
			text = "一个接一个地丢弃",
			callback_func = function()
				CarryScript.menu_mode = not CarryScript.menu_mode
				CarryScript:InteractBySpecificBag(CarryScript.BagList[1])
				managers.mission._fading_debug_output:script().log(string.format("一对一"), Color.green)
				managers.chat:feed_system_message(ChatManager.GAME, "搬运车双击快速进入菜单")
			end
		})
		table.insert(dialog_data.button_list, {
			text = "安全携带",
			callback_func = function()
				CarryScript:secure_carry_toggle()
			end
		})
		table.insert(dialog_data.button_list, {})
		table.insert(dialog_data.button_list, {
			text = "搬运车（主机）",
			callback_func = function()
				dofile("mods/DoNotCheat/implement/utils/carrybags/carrystacker.lua")
			end
		})
		table.insert(dialog_data.button_list, {})
		table.insert(dialog_data.button_list, {
			text = managers.localization:text("dialog_cancel"),
			focus_callback_func = function() end,
			cancel_button = true
		})
		managers.system_menu:show_buttons(dialog_data)
	end

	function CarryScript:menu_override(BagList)
		local dialog_data = {
			title = "Bag Carry Manager",
			text = "",
			button_list = {}
		}

		local item_mapper = {}

		for _, carry_id in pairs(BagList) do
			local carry_data = tweak_data.carry[carry_id]
			local type_text = managers.localization:text(carry_data.name_id)
			-- table.insert(dialog_data.button_list, {
			-- 	text = type_text,
			-- 	callback_func = function()
			-- 		self:InteractBySpecificBag(carry_id)
			-- 	end
			-- })

			if not item_mapper[type_text] then
				item_mapper[type_text] = 1
			else
				item_mapper[type_text] = item_mapper[type_text] + 1
			end
		end

		for k, v in pairs(item_mapper) do
			table.insert(dialog_data.button_list, {
				text = k .. " : " .. v,
				callback_func = function()
					self:InteractBySpecificBag(carry_id)
				end
			})
		end

		if dialog_data.button_list.text ~= type_text then
			table.insert(dialog_data.button_list, { text = "No package on the map" })
		else
			table.insert(dialog_data.button_list, {})
			table.insert(dialog_data.button_list, {
				text = "Carry All",
				callback_func = function()
					for _, carry_id in pairs(BagList) do
						CarryScript:InteractBySpecificBag(carry_id)
					end
					managers.mission._fading_debug_output:script().log(string.format("Carry All Activated"),
						Color.green)
				end
			})

			table.insert(dialog_data.button_list, {
				text = "Drop one by one",
				callback_func = function()
					CarryScript.menu_mode = not CarryScript.menu_mode
					CarryScript:InteractBySpecificBag(CarryScript.BagList[1])
					managers.mission._fading_debug_output:script().log(string.format("Dropped"), Color.green)
					-- managers.chat:feed_system_message(ChatManager.GAME, "搬运车双击快速进入菜单")
				end
			})

			table.insert(dialog_data.button_list, {
				text = "Secure Carry",
				callback_func = function()
					CarryScript:secure_carry_toggle()
				end
			})

			table.insert(dialog_data.button_list, {})
			table.insert(dialog_data.button_list, {
				text = "Carrier(host)",
				callback_func = function()
					dofile("mods/DoNotCheat/implement/utils/carrybags/carrystacker.lua")
				end
			})
		end

		table.insert(dialog_data.button_list, {})
		table.insert(dialog_data.button_list, {
			text = managers.localization:text("dialog_cancel"),
			focus_callback_func = function() end,
			cancel_button = true
		})

		managers.system_menu:show_buttons(dialog_data)
	end

	function CarryScript:_toggle()
		local unit = managers.player:player_unit()
		if alive(unit) then
			if CarryScript.menu_mode then
				CarryScript:menu_override(CarryScript.BagList)
			else
				if (Application:time() - self.carrystack_lastpress) < 0.2 then
					CarryScript.menu_mode = not CarryScript.menu_mode
					CarryScript:menu_override(CarryScript.BagList)
					managers.mission._fading_debug_output:script().log(string.format("Drop one by one - DEACTIVATED"),
						Color.red)
				else
					CarryScript:InteractBySpecificBag(CarryScript.BagList[1])
				end
			end
			self.carrystack_lastpress = Application:time()
		end
	end

	CarryScript:_toggle()
else
	CarryScript:_toggle()
end

-- override
local orig = ObjectInteractionManager.update
function ObjectInteractionManager:update(t, dt)
	orig(self, t, dt)
	if #CarryScript.BagList ~= self._interactive_count then
		CarryScript.BagList = {}
		for _, unit in pairs(self._interactive_units) do
			if not alive(unit) then return end
			local interaction = unit:interaction()
			local carry = unit:carry_data()
			if interaction and carry then
				table.insert(CarryScript.BagList, carry:carry_id())
			end
		end

		table.sort(CarryScript.BagList)
	end
end
