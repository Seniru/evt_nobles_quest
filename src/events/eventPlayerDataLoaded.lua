local eventPlayerDataLoaded = function(name, data)
	-- reset player data if they are stored according to the old version
	if data:find("^v2") then
		dHandler:newPlayer(name, data:sub(3))
	else
		system.savePlayerData(name, "")
		dHandler:newPlayer(name, "")
	end

end
