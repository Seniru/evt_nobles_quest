eventPlayerDataLoaded = function(name, data)
	-- reset player data if they are stored according to the old version
	local player = Player.players[name]
	xpcall(function()
		if data:find("^v2") then
			dHandler:newPlayer(name, data:sub(3))
		else
			system.savePlayerData(name, "")
			dHandler:newPlayer(name, "")
		end
	end, function(err, success)
		if not success then
			p({name, data, err})
			tfm.exec.chatMessage(translate("PLAYER_DATA_FAIL_SAFEBACK", player.language), name)
		end
	end)


	player.spiritOrbs = dHandler:get(name, "spiritOrbs")
	player.learnedRecipes = recipesBitList:decode(dHandler:get(name, "recipes"))

	local questProgress = dHandler:get(name, "questProgress")
	-- remove
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
		if not itemData[1] then
			inventory[i] = {}
		else
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
		end
	end
	player.inventory = inventory

	-- stuff
	player:displayInventory()
	player:changeInventorySlot(1)


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
			dialoguePanel:hide(name)
			player:displayInventory()
			if not player.questProgress.wc.completed then
				player:updateQuestProgress("wc", 1)
				player:addNewQuest("nosferatu")
			end
		end)
	end


	if true and not dHandler:get(name, "missingRewardsGiven") then
		print("[INFO] Giving missing rewards")
		local missing = 0
		for i, quest in next, ({ "nosferatu", "strength_test", "fiery_dragon" }) do
			if player.questProgress[quest] and player.questProgress[quest].completed then
				missing = missing + 1
			end
		end
		for i = 1, missing - 1 do
			system.giveEventGift(name, "evt_nobles_quest_golden_ticket_20")
			dHandler:set(name, "missingRewardsGiven", true)
		end
		player:savePlayerData()
	end

	if player.questProgress.nosferatu and player.questProgress.nosferatu.completed then
		mineQuestCompletedPlayers = mineQuestCompletedPlayers + 1
	else
		mineQuestIncompletedPlayers = mineQuestIncompletedPlayers + 1
	end

	totalProcessedPlayers =  totalProcessedPlayers + 1

	mapPlaying = "mine"
	if totalProcessedPlayers == totalPlayers then
	--[[	if (mineQuestCompletedPlayers / tfm.get.room.uniquePlayers) <= 0.2 then
			mapPlaying = "mine"
		elseif math.random(1, 10) <= 4 then
			mapPlaying = "mine"
		else
			mapPlaying = "castle"
		end
		--mapPlaying ="castle"
		--tfm.exec.newGame(maps[mapPlaying])
		--tfm.exec.setGameTime(180)
		--mapLoaded = true
	]]
		if mineQuestCompletedPlayers > 0 then
			if math.random(1, 10) <= 5 then
				mapPlaying = "mine"
			else
				mapPlaying = "castle"
			end
		end
	end
	--mapPlaying = "castle"

	Timer.new("startMap", function(mapPlaying)
		tfm.exec.newGame(maps[mapPlaying], false)
		tfm.exec.setGameTime(180)
		mapLoaded = true
		questProgressButton:show()
	end, 3100, false, mapPlaying)

end
