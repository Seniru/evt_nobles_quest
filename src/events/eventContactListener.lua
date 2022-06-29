eventContactListener = function(name, id, contactInfo)
	local player = Player.players[name]
	local bulletData = projectiles[id - 12000]
	local stun = bulletData[2]
	local imageData = bulletData[4]
	player.health = player.health - bulletData[1]
	displayDamage(player)
	if stun then
		tfm.exec.freezePlayer(name, true, false)
		local imageId
		if imageData then
			imageId = tfm.exec.addImage(imageData[1], imageData[2], imageData[3], imageData[4])
		end
		Timer.new("stun" .. name, function(name, imageId)
			tfm.exec.freezePlayer(name, false, false)
			if imageId then tfm.exec.removeImage(imageId) end
		end, bulletData[3], false, name, imageId)

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