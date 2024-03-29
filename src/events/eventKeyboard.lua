eventKeyboard = function(name, key, down, x, y)
	local player = Player.players[name]

	if key == keys.LEFT then
		player.stance = 1
	elseif key == keys.RIGHT then
		player.stance = -1
	end
	if player.actionCooldown > os.time() then return end

	if player.alive and key >= keys.KEY_0 and keys.KEY_9 >= key then
		local n = tonumber(table.find(keys, key):sub(-1))
		n = n == 0 and 10 or n
		player:changeInventorySlot(n)
	elseif key == keys.KEY_P then
		openCraftingTable(player)
	elseif key == keys.KEY_X then
		player:dropItem()
	elseif key == keys.KEY_U then
		player:toggleDivinePower()
	end

	if (not player.alive) or (not player:setArea(x, y)) then return end

	if down then player:processSequence(key) end

	if key == keys.DUCK then
		local area = Area.areas[player.area]
		local inventoryItem = player.inventory[player.inventorySelection][1]
		local monster = area:getClosestMonsterTo(x, y)
		if inventoryItem and inventoryItem.id:match("shield") then
			player:equipShield(down)
		elseif monster then
			player:attack(monster)
		else
			local entity = area:getClosestEntityTo(x, y)
			if entity then
				entity:receiveAction(player, down)
			end
		end
	end
	player.actionCooldown = os.time() + 400

end
