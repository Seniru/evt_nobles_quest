eventLoop = function(tc, tr)
	_tc, _tr = tc, tr
	if tr < 5000 and (eventLoaded and not eventEnding) then
		eventEnding = true
		local players = Player.players
		for name in next, tfm.get.room.playerList do
			tfm.exec.freezePlayer(name)
			if players[name] then players[name]:savePlayerData() end
		end
	else
		Timer.process()
		if dragon then dragonLocationCheck(dragon) end
	end
end
