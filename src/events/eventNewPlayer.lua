eventNewPlayer = function(name)
	Player.new(name)
	system.loadPlayerData(name)
	for key, code in next, keys do system.bindKeyboard(name, code, true, true) end
end
