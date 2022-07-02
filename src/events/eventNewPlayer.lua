eventNewPlayer = function(name)
	if eventLoaded then return end
	local player = Player.new(name)
	player.dataLoaded = system.loadPlayerData(name)
	if not player.dataLoaded then
		tfm.exec.chatMessage(translate("PLAYER_DATA_FAIL_SAFEBACK", player.language), name)
	end
	for key, code in next, keys do system.bindKeyboard(name, code, true, true) end
	system.bindKeyboard(name, keys.DUCK, false, true)
	totalPlayers = totalPlayers + 1
end
