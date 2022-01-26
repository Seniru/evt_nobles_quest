eventKeyboard = function(name, key, down, x, y)
	local player = Player.players[name]
	player:setArea(x, y)
	if key == keys.SPACE then
		local obj = Area.areas[player.area]:getClosestObjTo(x, y)
		p(obj)
	end

end