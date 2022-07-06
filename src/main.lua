createPrettyUI = function(id, x, y, w, h, fixed, closeButton)

	local window = Panel(id * 100 + 10, "", x - 4, y - 4, w + 8, h + 8, 0x7f492d, 0x7f492d, 1, fixed)
		:addPanel(
			Panel(id * 100 + 20, "", x, y, w, h, 0x152d30, 0x0f1213, 1, fixed)
		)
		:addImage(Image(assets.widgets.borders.topLeft, "&1", x - 10, y - 10))
		:addImage(Image(assets.widgets.borders.topRight, "&1", x + w - 18, y - 10))
		:addImage(Image(assets.widgets.borders.bottomLeft, "&1", x - 10, y + h - 18))
		:addImage(Image(assets.widgets.borders.bottomRight, "&1", x + w - 18, y + h - 18))

	if closeButton then
		window
			:addPanel(
				Panel(id * 100 + 30, "<a href='event:close'>\n\n\n\n\n\n</a>", x + w + 18, y - 10, 15, 20, nil, nil, 0, fixed)
				:addImage(Image(assets.widgets.closeButton, ":0", x + w + 15, y - 10)
				)
			)
			:setCloseButton(id * 100 + 30)
	end

	return window

end


inventoryPanel = Panel(100, "", 30, 350, 740, 50, nil, nil, 0, true)
	:addImage(Image(assets.ui.inventory, "~1", 20, 320))
	:addPanel(Panel(150, "INFO", 370, 342, 66, 80, nil, nil, 0, true))

do
	for i = 0, 9 do
		local x = 76 + (i >= 5 and 50 or 0) + 62 * i
		inventoryPanel:addPanel(Panel(101 + i, "", x, 350, 40, 40, nil, nil, 0, true))
		inventoryPanel:addPanel(Panel(121 + i, "", x + 25, 340, 0, 0, nil, nil, 0, true))
	end
end

dialoguePanel = Panel(200, "", 0, 0, 0, 0, nil, nil, 0, true)
	:addPanel(Panel(201, "", 0, 0, 0, 0, nil, nil, 0, true))

giveReward = function(name, level)
	local rewards
	if level == 0 then
		rewards = { 1, 11, 24, 23, 23, 23, 23, 2514, 4, 4, 4, 4, 4, 21, -1, -1, -1, -1, -1, -1 , 2240, 2240, 2240,}
	else
		rewards = { 2257, 2497, 2497, 2497, 2497, 2497 }
	end
	local reward = rewards[math.random(#rewards)]
	if reward == -1 then return end
	tfm.exec.giveConsumables(name, reward)
end

craftingPanel = createPrettyUI(3, 360, 40, 380, 340, true, true)-- main shop window
	:addPanel(
		Panel(351, "〈", 620, 350, 40, 20, nil, 0x324650, 1, true)
		:setActionListener(function(id, name, event)
			openCraftingTable(Player.players[name], tonumber(event), true)
		end)
	):addPanel(
		Panel(352, "〉", 680, 350, 40, 20, nil, 0x324650, 1, true)
		:setActionListener(function(id, name, event)
			openCraftingTable(Player.players[name], tonumber(event), true)
		end)
	)
	:addPanel(-- preview window
		createPrettyUI(4, 70, 40, 260, 340, true, false)
		:addPanel(Panel(451, "", 160, 60, 150, 90, nil, nil, 0, true)) -- recipe descriptions
		:addPanel(Panel(452, "", 80, 160, 100, 100, nil, nil, 0, true)) -- recipe info
		:addPanel(Panel(450, "", 80, 355, 240, 20, nil, 0x324650, 1, true)
			:setActionListener(function(id, name, event)
				if not recipes[event] then return end
				local player = Player.players[name]
				if not player:canCraft(event) then return end
				local success, err = pcall(player.craftItem, player, event)
				if not success then
					for _, neededItem in next, recipes[event] do
						if not neededItem[1].stackable then
							for i = 1, neededItem[2] do
								player:addInventoryItem(neededItem[1], 1)
							end
						else
							player:addInventoryItem(neededItem[1], neededItem[2])
						end
						--self.inventory[idx][2] = amount - neededItem[2]
					end
					tfm.exec.chatMessage(translate("FULL_INVENTORY", player.language), name)
				end
				player:displayInventory()
				player:changeInventorySlot(player.inventorySelection)
				displayRecipeInfo(name, event, true)
				player:savePlayerData()
			end)
		)
	):setCloseButton(330, function(name)
		local player = Player.players[name]
		if not player then return end
		player:displayInventory()
	end)

divineChargePanel = Panel(400, "", 30, 110, 600, 50, nil, nil, 0, true)
	:addImage(Image(assets.ui.marker, "&1", 158, 15))
	:addImage(Image(assets.ui.divine_panel, "&1", 170, 215))

questProgressPanel = createPrettyUI(7, 270, 50, 260, 330, true, true)

questProgressButton = Panel(600, "<a href='event:quests'>\n\n\n</a>", 0, 30, 50, 36, nil, nil, 0, true)
	:setActionListener(function(id, name, event)
		local player = Player.players[name]
		questProgressPanel:show(name)
		local ongoing = ""
		local completed = "\n\n"
		for n, quest in next, player.questProgress do
			local q = quests[n]
			local questName = q.title_locales[player.language] or q.title_locales["en"]
			if quest.completed then
				completed = completed .. translate("QUEST_OVER", player.language, nil, { questName = questName }) .. "\n"
			else
				ongoing = ongoing ..
					("<font color='#506d3d'>[</font> <font color='#c6b392'>•</font> <font color='#506d3d'>]</font> <font color='#ab5e42' face='Lucida Console'><b>%s</b></font>\n- %s <font color='#bd9d60' size='11' face='Lucida Console'>( %s / %s )</font>\n")
						:format(
							questName,
							q[quest.stage].description_locales[player.language] or q[quest.stage].description_locales["en"],
							quest.stageProgress,
							q[quest.stage].tasks
						)
			end
		end
		Panel.panels[720]:update(translate("QUESTS", player.language) .. ongoing .. completed, name)
	end)
	:addImage(Image(assets.ui.questProgress, "~1", 0, 30))

addDialogueBox = function(id, text, name, speakerName, speakerIcon, replies)
	local x, y, w, h = 30, 350, type(replies) == "table" and 600 or 740, 50
	-- to erase stuff that has been displayed previously, if this dialoguebox was a part of a conversation
	dialoguePanel:hide(name)
	inventoryPanel:hide(name)
	dialoguePanel:show(name)
	print(name)
	local isReplyBox = type(replies) == "table"
	dialoguePanel:addPanelTemp(Panel(id * 1000, text, x + (isReplyBox and 25 or 20), y, w, h, 0, 0, 0, true)
		:addImageTemp(Image(assets.ui[isReplyBox and "dialogue_replies" or "dialogue_proceed"], "~1", 20, 280), name),
		name)
	Panel.panels[id * 1000]:update(text, name)
	dialoguePanel:addPanelTemp(Panel(id * 1000 + 1, "<b><font size='10'>" .. (speakerName or "???") .. "</font></b>", x + w - 180, y - 25, 0, 0, nil, nil, 0, true), name)
	--dialoguePanel:addImageTemp(Image("171843a9f21.png", "&1", 730, 350), name)
	Panel.panels[201]:addImageTemp(Image(speakerIcon, "&1", x + w - 100, y - 55), name)
	--dialoguePanel:update(text, name)
	if isReplyBox then
		local minusY = -10
		for i, reply in next, replies do
			dialoguePanel:addImageTemp(Image(assets.ui.reply, "~1", x + w - 10, y - 10 + 26 * (i - 1) + minusY, 1.1, 0.9), name)
			local p = Panel.panels[id * 1000 + 10 + i] or Panel(id * 1000 + 10 + i, "", x + w - 6, y - 6 + 24 * (i - 1) + minusY, 130, 25, nil, nil, 0, true)
			dialoguePanel:addPanelTemp(p
			:setActionListenerTemp(function(id, name, event)
				reply[2](table.unpack(reply[3]))
			end, name),
			name)
			p:update(("<a href='event:reply'>%s</a>"):format(reply[1]), name)
		end
	else
		dialoguePanel:addImageTemp(Image(assets.ui.btnNext, "~1", x + w - 25, y + h - 30), name)
		local p = Panel.panels[id * 1000 + 10] or Panel(id * 1000 + 10, "<a href='event:2'>\n\n\n</a>", x + w - 25, y + h - 30, 30, 30, nil, nil, 0, true)

		dialoguePanel:addPanelTemp(p
			:setActionListenerTemp(replies or function(id, name, event)
				dialoguePanel:hide(name)
				Player.players[name]:displayInventory()
			end, name)
			, name)
	end
end

addDialogueSeries = function(name, id, dialogues, speakerName, conclude)
	local x, y, w, h = 30, 350, 740, 50
	addDialogueBox(id, dialogues[1].text, name, speakerName, dialogues[1].icon, function(id2, name, event)
		local page = tonumber(event)
		if not page or page < 0 then return conclude(id2, name, event) end -- events from arbitary packets
		if page > #dialogues then return conclude(id2, name, event) end
		Panel.panels[id * 1000]:update(dialogues[page].text, name)
		Panel.panels[201]:hide(name)
		Panel.panels[201]:show(name)
		Panel.panels[201]:addImageTemp(Image(dialogues[page].icon, "&1", x + w - 100, y - 55), name)
		Panel.panels[id * 1000 + 10]:update(("<a href='event:%d'>\n\n\n</a>"):format(page + 1), name)
	end)
end


displayDamage = function(target)
	local bg, fg
	if target.type == "bridge" then
		bg = tfm.exec.addImage(assets.damageBg, "!1", target.x, target.y)
		fg = tfm.exec.addImage(assets.damageFg, "!2", target.x + 1, target.y + 1, nil, target.buildProgress / 20)
	elseif target.__type == "entity" then
		bg = tfm.exec.addImage(assets.damageBg, "!1", target.x, target.y)
		fg = tfm.exec.addImage(assets.damageFg, "!2", target.x + 1, target.y + 1, nil, target.resourcesLeft / target.resourceCap)
	elseif target.__type == "monster" then
		local isBoss = 	target.species == Monster.all.fiery_dragon or target.species == Monster.all.final_boss
		if isBoss then
			bg = tfm.exec.addImage(assets.damageBg, "!1", target.realX or target.x, target.y, nil, 4, 2)
			fg = tfm.exec.addImage(assets.damageFg, "!2", (target.realX or target.x) + 2, target.y + 2, nil, (target.health / target.metadata.health) * 4, 2)
		else
			local obj = tfm.get.room.objectList[target.objId]
			bg = tfm.exec.addImage(assets.damageBg, "=" .. target.objId, 0, -30)
			fg = tfm.exec.addImage(assets.damageFg, "=" .. target.objId, 1, 1 - 30, nil, target.health / target.metadata.health)
		end
	elseif target.__type == "player" then
		bg = tfm.exec.addImage(assets.damageBg, "$" .. target.name, 0, -30)
		fg = tfm.exec.addImage(assets.damageFg, "$" .. target.name, 1, -30 + 1, nil, target.health / 50)
	end
	Timer.new("damage" .. bg, tfm.exec.removeImage, 1500, false, bg)
	Timer.new("damage" .. fg, tfm.exec.removeImage, 1500, false, fg)
end

encodeInventory = function(inventory)
	local res = ""
	for i, data in next, inventory do
		if #data == 0 then
			res = res .. string.char(0)
		else
			local c = bit.lshift(data[1], 2)
			c = bit.bor(c, data[2] and 2 or 0)
			c = bit.bor(c, data[3] and 1 or 0)
			res = res .. string.char(c)
			if not data[2] then
				res = res .. string.char(data[4])
			end
		end
	end
	return base64Encode(res)
end

decodeInventory = function(data)
	data = base64Decode(data)
	local res = {}
	local i = 1
	while i <= #data do
		local c = string.byte(data, i)
		if c == 0 then
			res[#res + 1] = {}
			i = i + 1
		else
			local id = bit.rshift(bit.band(c, 252), 2)
			local isSpecialItem = bit.band(c, 2) > 0
			local isResource = bit.band(c, 1) == 1
			if isSpecialItem then
				res[#res + 1] = { id, isSpecialItem, isResource }
				i = i + 1
			else
				res[#res + 1] = { id, isSpecialItem, isResource, string.byte(data, i + 1) }
				i = i + 2
			end
		end
	end
	return res
end

encodeQuestProgress = function(pQuests)
	local res = ""
	local questIds = quests._all
	for quest, progress in next, pQuests do
		local c = bit.lshift(quests[quest].id, 1)
		c = bit.bor(c, progress.completed and 1 or 0)
		res = res .. string.char(c)
		if not progress.completed then
			res = res .. string.char(progress.stage, progress.stageProgress)
		end
	end
	return base64Encode(res)
end

decodeQuestProgress = function(data)
	data = base64Decode(data)
	local res = {}
	local questIds = quests._all
	local i = 1
	while i <= #data do
		local c = string.byte(data, i)
		local questId = questIds[bit.rshift(c, 1)]
		local completed = bit.band(c, 1) == 1
		i = i + 1
		local stage, stageProgress
		if not completed then
			stage = string.byte(data, i)
			i = i + 1
			stageProgress = string.byte(data, i)
			i = i + 1
		end
		res[questId] = { stage = stage, stageProgress = stageProgress, completed = completed }
	end
	return res
end

getVelocity = function(x_to, x_from, y_to, y_from, t)
	local vcostheta = (x_to - x_from) / t
	local vsintheta = (y_to - y_from + 10 * t ^ 2) / t
	return vcostheta * 1.2, vsintheta * 1.2
end

fadeInSlowly = function(time, imageId, target, xPosition, yPosition, targetPlayer, scaleX, scaleY, angle, alpha, anchorX, anchorY)
	local iterations = time / 500
	local images = {}
	local co
	co = coroutine.create(function()
		for i = 1, math.ceil(iterations) do
			Timer.new(string.format("fadeIn_%s_%s", imageId, i), function()
				images[#images + 1] = tfm.exec.addImage(imageId, target, xPosition, yPosition, targetPlayer, scaleX, scaleY, angle, (i / iterations) * alpha, anchorX, anchorY, true)
				if i >= iterations then
					coroutine.resume(co)
				end
			end, 500 * i, false)
		end
		coroutine.yield()
		-- I'm not really sure how to return values from coroutines so we have this for now
		Timer.new("removeFinal", function()
			for i = 1, #images do
				tfm.exec.removeImage(images[i], true)
			end
		end, 3000, false)
	end)

	coroutine.resume(co)

end

teleports = {
	mine = {
		canEnter = function(player, terminalId)
			local quest = player.questProgress.nosferatu
			return quest and (quest.completed or quest.stage >= 3)
		end,
		onEnter = function(player, terminalId)
			tfm.exec.setPlayerNightMode(terminalId == 2, player.name)
		end,
		onFailure = function(player)
			tfm.exec.chatMessage(translate("PORTAL_ENTER_FAIL", player.language), player.name)
		end
	},
	castle = {
		canEnter = function() return true end,
		onEnter = function(player, terminalId)
			if terminalId == 2 then
				addDialogueBox(5, translate("COLE_DIALOGUES", player.language, 1), player.name, "Cole", "180d8434702.png")
			end
		end
	},
	arena = {
		canEnter = function(player, terminalId)
			local quest = player.questProgress.strength_test
			return quest and (quest.completed or quest.stage >= 2)
		end,
		onFailure = function(player)
			tfm.exec.chatMessage(translate("PORTAL_ENTER_FAIL", player.language), player.name)
		end
	},
	bridge = {
		canEnter = function(player, terminalId)
			local quest = player.questProgress.strength_test
			return quest and quest.completed
		end,
		onFailure = function(player)
			addDialogueBox(5, translate("COLE_DIALOGUES", player.language, 3), player.name, "Cole", "180d8434702.png")
		end
	},
	shrines = {
		canEnter = function() return true end,
		onEnter = function(player, terminalId)
			if (not player.questProgress.spiritOrbs) or player.questProgress.spiritOrbs.stage == 1 then
				player:addNewQuest("spiritOrbs")
				player:updateQuestProgress("spiritOrbs", 1)
				print("came here and should update smh")
				addDialogueBox(7, translate("SARUMAN_DIALOGUES", player.language, 1), player.name, "???", "180dbd361b5.png", function()
					dialoguePanel:hide(player.name)
					player:displayInventory()
				end)
			end
			tfm.exec.setPlayerNightMode(terminalId == 2, player.name)
		end
	},
	final_boss = {
		canEnter = function(player)
			return (player.questProgress.final_boss) and not bossBattleTriggered
		end,
		onEnter = function(player, terminalId)
			if player.spiritOrbs == 62 then
				tfm.exec.chatMessage(translate("DIVINE_POWER_TOGGLE_REMINDER", player.language), player.name)
			end
		end,
		onFailure = function(player, terminalId)
			tfm.exec.chatMessage(translate("PORTAL_ENTER_FAIL", player.language), player.name)
		end
	},
	enigma = {
		canEnter = function(player, terminalId) return terminalId == 1 end,
		onFailure = function(player)
			local tfmPlayer = tfm.get.room.playerList[player.name]
			ui.addPopup(69, 2, translate("PASSCODE", player.language), player.name, tfmPlayer.x - 10, tfmPlayer.y - 10, nil, false)
		end
	}
}

do
	eventNewGame()
	for name, player in next, tfm.get.room.playerList do
		eventNewPlayer(name)
	end
end
