eventKeyboard = function(name, key, down, x, y)
	local player = Player.players[name]
	if not player:setArea(x, y) then return end
	if key == keys.DUCK then
		local entity = Area.areas[player.area]:getClosestEntityTo(x, y)
		if entity then
			entity:receiveAction(player)
		end
	end

end