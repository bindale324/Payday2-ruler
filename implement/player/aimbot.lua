local target_closest = true                -- 如果你想瞄准离你的十字准线最近的敌人而不是任何敌人，则设置为 true
local shoot_through_wall = false           -- 如果您想通过墙壁瞄准敌人，请设置为 true 注意：这不会让您能够穿过墙壁射击！
local shoot_through_wall_thickness = false -- 设置可以射多少东西的数值，40是正常的墙
local fov_only = 100                       -- 如果您只想在一定度数内拍摄，请设置为 0-360 之间的值，如果到处拍摄则为 false

-----------------------------------------------------------------------------------------------------------------------------------------------

-- 激活
active = not active
managers.hud:show_hint({ text = active and "Aimbot Activated" or "Aimbot Deactivated" })

function calculate_angle(unit)
	-- 初始化变量
	local player = Vector3()
	local enemy = Vector3()
	local dir = Vector3()

	--设置初始向量
	mvector3.set(player, managers.player:player_unit():camera():position())
	mvector3.set(enemy, unit:movement():m_head_pos())

	-- 计算差异向量
	mvector3.set(dir, player)
	mvector3.subtract(dir, enemy)
	mvector3.normalize(dir)

	-- 计算方向
	local newx, newy, newz = dir.x, dir.y, dir.z
	if player.x > enemy.x or (player.x < enemy.x and newx < 0) then newx = newx * -1 end
	if player.y > enemy.y or (player.y < enemy.y and newy < 0) then newy = newy * -1 end
	if player.z > enemy.z or (player.z < enemy.z and newz < 0) then newz = newz * -1 end
	mvector3.set(dir, Vector3(newx, newy, newz))

	return dir
end

function get_target(pthis)
	-- 初始化变量
	local from = managers.player:player_unit():camera():position()
	local current = managers.player:player_unit():camera():forward()
	local best = nil
	local closest = 100000

	for _, ene in pairs(managers.enemy:all_enemies()) do
		local team = ene.unit:movement():team()
		local team_id = team.id
		local in_slot = ene.unit:in_slot(managers.slot:get_mask("enemies"))

		if (team_id == "mobster1" or team_id == "law1") and in_slot and not ene.unit:brain():surrendered() then
			local to = ene.unit:movement():m_head_pos()
			local ray = nil
			local ray_hits = nil

			-- 确定此武器是否可以射穿盾牌（爆炸子弹等）
			old_can_shoot = pthis._can_shoot_through_shield
			for _, cat in pairs(tweak_data.weapon[pthis._name_id].categories) do
				if cat == "grenade_launcher" then pthis._can_shoot_through_shield = true end
			end
			if pthis._bullet_class.id == "explosive" or pthis._bullet_class.id == "dragons_breath" then pthis._can_shoot_through_shield = true end

			-- 将射线击中头部
			if shoot_through_wall or pthis._can_shoot_through_wall then
				ray_hits = World:raycast_wall("ray", from, to, "slot_mask", pthis._bullet_slotmask, "ignore_unit",
					pthis._setup.ignore_units,
					"thickness", (shoot_through_wall and shoot_through_wall_thickness or 1), "thickness_mask",
					managers.slot:get_mask("world_geometry", "vehicles"))
			else
				ray_hits = World:raycast_all("ray", from, to, "slot_mask", pthis._bullet_slotmask, "ignore_unit",
					pthis._setup.ignore_units)
			end

			-- 决定我们能否击中这个敌人
			for _, hit in ipairs(ray_hits) do
				if hit.unit:key() == ene.unit:key() then
					ray = hit; break
				end
				if not shoot_through_wall then
					if not pthis._can_shoot_through_wall and hit.unit:in_slot(managers.slot:get_mask("world_geometry", "vehicles")) then
						break
					elseif not pthis._can_shoot_through_shield and hit.unit:in_slot(managers.slot:get_mask("enemy_shield_check")) then
						break
					end
				end
			end

			-- 重置更改的穿透值
			pthis._can_shoot_through_shield = old_can_shoot

			if ray and ray.unit and ray.unit:key() == ene.unit:key() then
				-- 计算所需的角度并在需要时比较最短的
				local dir = calculate_angle(ene.unit)
				if not target_closest then return dir end

				local distance = mvector3.distance(current, dir)
				if distance < closest and (fov_only and (distance / 2 * 360) <= fov_only or not fov_only) then
					closest = distance
					best = dir
				end
			end
		end
	end

	return best
end

old_fire = old_fire or NewRaycastWeaponBase.fire
function NewRaycastWeaponBase:fire(from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul,
								   target_unit)
	local dir = nil
	if active and self._setup.user_unit == managers.player:player_unit() then dir = get_target(self) end
	if dir then return old_fire(self, from_pos, dir, dmg_mul, shoot_player, 0, autohit_mul, suppr_mul, target_unit) end
	return old_fire(self, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, target_unit)
end
