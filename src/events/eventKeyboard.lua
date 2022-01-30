eventKeyboard = function(name, key, down, x, y)
	local player = Player.players[name]
	player:setArea(x, y)
	if key == keys.SPACE then
		local entity = Area.areas[player.area]:getClosestEntityTo(x, y)
		if entity then
			entity:receiveAction(player)
		end
	end

end