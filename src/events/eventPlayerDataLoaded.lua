eventPlayerDataLoaded = function(name, data)
	-- reset player data if they are stored according to the old version
	if data:find("^v2") then
		dHandler:newPlayer(name, data:sub(3))
	else
		system.savePlayerData(name, "")
		dHandler:newPlayer(name, "")
	end

	local player = Player.players[name]
	-- stuff

	player:displayInventory()

	if not player.questProgress.wc.completed then
		--[[addDialogueBox(1, "Welcome to the town loser", name, "Announcer", "17088637078.png", function(id, name, event)
			addDialogueBox(2, "There's nothign to look at here lmao, just get it over", name, "Announcer", "17088637078.png", function()
				player:updateQuestProgress("wc", 1)
				dialoguePanel:hide(name)
				player:displayInventory(name)
			end)
		end)]]
		addDialogueSeries(name, 1, {
			{ text = "Welcome to the town loser", icon = "17088637078.png" },
			{ text = "yes that works", icon = assets.ui.btnNext },
			{ text = "yes yes now close this", icon = "17088637078.png" },
		}, "Announcer", function(id, _name, event)
			player:updateQuestProgress("wc", 1)
			dialoguePanel:hide(name)
			player:displayInventory(name)
			player:addNewQuest("giveWood")
		end)
	end

end
