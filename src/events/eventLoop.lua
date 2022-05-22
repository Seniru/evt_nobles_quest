eventLoop = function(tc, tr)
	_tc, _tr = tc, tr
	if tr < 5000 and not eventEnding then
		eventEnding = true
		local players = Player.players
		for name in next, tfm.get.room.playerList do
			tfm.exec.freezePlayer(name)
			players[name]:savePlayerData()
		end
	else
		Timer.process()
	end
end
