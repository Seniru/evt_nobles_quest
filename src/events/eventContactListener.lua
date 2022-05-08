eventContactListener = function(name, id, contactInfo)
	local player = Player.players[name]
	local bulletData = projectiles[id - 12000]
	local stun = bulletData[2]
	player.health = player.health - bulletData[1]
	displayDamage(player)
	if stun then
		tfm.exec.freezePlayer(name, true, true)
		Timer.new("stun" .. name, tfm.exec.freezePlayer, bulletData[3], false, name, false)
	end
end