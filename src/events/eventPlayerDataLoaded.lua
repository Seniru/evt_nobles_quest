eventPlayerDataLoaded = function(name, data)
	-- reset player data if they are stored according to the old version
	if data:find("^v2") then
		dHandler:newPlayer(name, data:sub(3))
	else
		system.savePlayerData(name, "")
		dHandler:newPlayer(name, "")
	end

	local player = Player.players[name]
	player.learnedRecipes = recipesBitList:decode(dHandler:get(name, "recipes"))

	local questProgress = dHandler:get(name, "questProgress")
	if questProgress == "" then
		player.questProgress =  { wc = { stage = 1, stageProgress = 0, completed = false } }
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
	end
	player.inventory = inventory

	-- stuff
	player:addInventoryItem(Item.items.basic_axe, 1)
	player:displayInventory()
	player:changeInventorySlot(1)

	p(player.learnedRecipes)
	p(player.inventory)
	p(player.questProgress)

	if not player.questProgress.wc.completed then
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
