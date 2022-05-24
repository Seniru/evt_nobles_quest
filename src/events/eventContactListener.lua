eventContactListener = function(name, id, contactInfo)
	local player = Player.players[name]
	local bulletData = projectiles[id - 12000]
	local stun = bulletData[2]
	player.health = player.health - bulletData[1]
	displayDamage(player)
	if stun then
		tfm.exec.freezePlayer(name, true, true)
		Timer.new("stun" .. name, tfm.exec.freezePlayer, bulletData[3], false, name, true)
		if bulletData[1] > 0 then
			local x, y = tfm.get.room.playerList[name].x, tfm.get.room.playerList[name].y
			Timer.new("getDizzy" .. name, function(x, y)
				tfm.exec.displayParticle(29, x - 20, y - 35, 1)
				tfm.exec.displayParticle(29, x + 10, y - 35, -1)
				Timer.new("dizzy" .. name, function(x, y)
					tfm.exec.displayParticle(29, x - 20, y - 35, 1)
					tfm.exec.displayParticle(29, x + 10, y - 35, -1)
				end, 500, false, x, y)
			end, 500, false, x, y)
		end
	end
end