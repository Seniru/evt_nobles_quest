eventPlayerDataLoaded = function(name, data)
	-- reset player data if they are stored according to the old version
	if data:find("^v2") then
		dHandler:newPlayer(name, data:sub(3))
	else
		system.savePlayerData(name, "")
		dHandler:newPlayer(name, "")
	end

	local player = Player.players[name]
	player.spiritOrbs = dHandler:get(name, "spiritOrbs")
	player.learnedRecipes = recipesBitList:decode(dHandler:get(name, "recipes"))

	local questProgress = dHandler:get(name, "questProgress")
	if questProgress == "" then
		--player.questProgress =  { wc = { stage = 1, stageProgress = 0, completed = false } }
		player:addNewQuest("wc")
	else
		player.questProgress = decodeQuestProgress(dHandler:get(name, "questProgress"))
	end

	local inventory = { {}, {}, {}, {}, {}, {}, {}, {}, {}, {} }
	local items = Item.items
	local itemNIds = items._all
	for i, itemData in next, decodeInventory(dHandler:get(name, "inventory")) do
		local item = items[itemNIds[itemData[1]]]:getItem()
		local isSpecialItem = itemData[2]
		local isResource = itemData[3]
		if isSpecialItem then
			inventory[i] = { item, 1 }
		elseif isResource then
			inventory[i] = { item, itemData[4] }
		else -- is a tool
			item.durability = itemData[4]
			inventory[i] = { item, 1 }
		end
		player.carriageWeight = player.carriageWeight + inventory[i][1].weight * inventory[i][2]
		print(player.carriageWeight)
	end
	player.inventory = inventory

	-- stuff
	player:displayInventory()
	player:changeInventorySlot(1)

	p(player.learnedRecipes)
	p(player.inventory)
	p(player.questProgress)

	if not player.questProgress.wc.completed then
		addDialogueSeries(name, 1, {
			{ text = translate("ANNOUNCER_DIALOGUES", player.language, 1), icon = "180c6ce0308.png" },
			{ text = translate("ANNOUNCER_DIALOGUES", player.language, 2), icon = "180c6ce0308.png" },
			{ text = translate("ANNOUNCER_DIALOGUES", player.language, 3), icon = "180c6ce0308.png" },
			{ text = translate("ANNOUNCER_DIALOGUES", player.language, 4), icon = "180c6ce0308.png" },
			{ text = translate("ANNOUNCER_DIALOGUES", player.language, 5), icon = "180c6ce0308.png" },
			{ text = translate("ANNOUNCER_DIALOGUES", player.language, 6), icon = "180c6ce0308.png" },
			{ text = translate("ANNOUNCER_DIALOGUES", player.language, 7), icon = "180c6ce0308.png" },
		}, "Announcer", function(id, _name, event)
			player:updateQuestProgress("wc", 1)
			dialoguePanel:hide(name)
			player:displayInventory()
			player:addNewQuest("nosferatu")
		end)
	end

	if player.questProgress.nosferatu and player.questProgress.nosferatu.completed then
		mineQuestCompletedPlayers = mineQuestCompletedPlayers + 1
	else
		mineQuestIncompletedPlayers = mineQuestIncompletedPlayers + 1
	end

	totalProcessedPlayers =  totalProcessedPlayers + 1

	if totalProcessedPlayers == totalPlayers then
		if (mineQuestCompletedPlayers / tfm.get.room.uniquePlayers) <= 0.6 then
			mapPlaying = "mine"
		elseif math.random(1, 10) <= 4 then
			mapPlaying = "mine"
		else
			mapPlaying = "castle"
		end
		mapPlaying = "castle"
		tfm.exec.newGame(maps[mapPlaying])
		tfm.exec.setGameTime(150)
		mapLoaded = true

	end

end
