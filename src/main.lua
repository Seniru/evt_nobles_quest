inventoryPanel = Panel(100, "", 30, 350, 740, 50, nil, nil, 0, true)
	:addImage(Image(assets.ui.inventory, "~1", 20, 320))

do
	for i = 0, 9 do
		local x = 76 + (i >= 5 and 50 or 0) + 62 * i
		inventoryPanel:addPanel(Panel(101 + i, "", x, 350, 40, 40, nil, nil, 0, true))
		inventoryPanel:addPanel(Panel(121 + i, "", x + 25, 340, 0, 0, nil, nil, 0, true))
	end
end

dialoguePanel = Panel(200, "", 0, 0, 0, 0, nil, nil, 0, true)
	:addPanel(Panel(201, "", 0, 0, 0, 0, nil, nil, 0, true))

craftingPanel = Panel(300, "<a href='event:close'>\n\n\n\n</a>", 780, 30, 30, 30, nil, nil, 1, true)
	:setCloseButton(300)
	:addPanel(Panel(301, "", 20, 30, 500, 300, nil, nil, 1, true))
	:addPanel(
		Panel(302, "", 530, 30, 200, 300, nil, nil, 1, true)
			:setActionListener(function(id, name, event)
				print("came here")
				p({event, recipes[event]})
				if not recipes[event] then return print("not a recipe") end
				local player = Player.players[name]
				if not player:canCraft(event) then return print("cant craft") end
				local success, err = pcall(player.craftItem, player, event)
				p({success, err})
			end)
	)

divineChargePanel = Panel(400, "", 30, 110, 600, 50, nil, nil, 1, true)

addDialogueBox = function(id, text, name, speakerName, speakerIcon, replies)
	local x, y, w, h = 30, 350, type(replies) == "table" and 600 or 740, 50
	-- to erase stuff that has been displayed previously, if this dialoguebox was a part of a conversation
	dialoguePanel:hide(name)
	inventoryPanel:hide(name)
	dialoguePanel:show(name)
	local isReplyBox = type(replies) == "table"
	dialoguePanel:addPanelTemp(Panel(id * 1000, text, x + (isReplyBox and 25 or 20), y, w, h, 0, 0, 0, true)
		:addImageTemp(Image(assets.ui[isReplyBox and "dialogue_replies" or "dialogue_proceed"], "~1", 20, 280), name),
	name)
	Panel.panels[id * 1000]:update(text, name)
	dialoguePanel:addPanelTemp(Panel(id * 1000 + 1, "<b><font size='10'>" .. (speakerName or "???") .. "</font></b>", x + w - 180, y - 25, 0, 0, nil, nil, 0, true), name)
	--dialoguePanel:addImageTemp(Image("171843a9f21.png", "&1", 730, 350), name)
	Panel.panels[201]:addImageTemp(Image(speakerIcon, "&1", x + w - 100, y - 55), name)
	dialoguePanel:update(text, name)
	if isReplyBox then
		for i, reply in next, replies do
			dialoguePanel:addPanelTemp(Panel(id * 1000 + 10 + i, ("<a href='event:reply'>%s</a>"):format(reply[1]), x + w - 6, y - 6 + 24 * (i - 1), 130, 25, nil, nil, 0, true)
				:setActionListener(function(id, name, event)
					reply[2](table.unpack(reply[3]))
				end),
			name)
			dialoguePanel:addImageTemp(Image(assets.ui.reply, ":1", x + w - 10, y - 10 + 26 * (i - 1), 1.1, 0.9), name)
		end
	else
		dialoguePanel:addImageTemp(Image(assets.ui.btnNext, "~1", x + w - 25, y + h - 30), name)
		dialoguePanel:addPanelTemp(
			Panel(id * 1000 + 10, "<a href='event:2'>\n\n\n</a>", x + w - 25, y + h - 30, 30, 30, nil, nil, 0, true)
				:setActionListener(replies or function(id, name, event)
					dialoguePanel:hide(name)
					Player.players[name]:displayInventory()
				end)
		, name)
	end
end

addDialogueSeries = function(name, id, dialogues, speakerName, conclude)
	local x, y, w, h = 30, 350, 740, 50
	addDialogueBox(id, dialogues[1].text, name, speakerName, dialogues[1].icon, function(id2, name, event)
		local page = tonumber(event)
		if not page or page < 0 then return end -- events from arbitary packets
		if page > #dialogues then return conclude(id2, name, event) end
		Panel.panels[id * 1000]:update(dialogues[page].text, name)
		Panel.panels[201]:hide(name)
		Panel.panels[201]:show(name)
		Panel.panels[201]:addImageTemp(Image(dialogues[page].icon, "&1",  x + w - 100, y - 55), name)
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
		local obj = tfm.get.room.objectList[target.objId]
		bg = tfm.exec.addImage(assets.damageBg, "=" .. target.objId, 0, -30)
		fg = tfm.exec.addImage(assets.damageFg, "=" .. target.objId, 1, 1 - 30, nil, target.health / target.metadata.health)
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

teleports = {
	mine = {
		canEnter = function(player, terminalId)
			local quest = player.questProgress.nosferatu
			return quest and (quest.completed or quest.stage >= 3)
		end,
		onEnter = function(player, terminalId)
			tfm.exec.setPlayerNightMode(terminalId == 2, player.name)
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
			tfm.exec.setPlayerNightMode(terminalId == 2, player.name)
			if terminalId == 2 and (not player.questProgress["spiritOrbs"] or player.questProgress.stage == 1) then
				addDialogueBox(7, translate("SARUMAN_DIALOGUES", player.language, 1), player.name, "???", "180dbd361b5.png", function()
					player:addNewQuest("spiritOrbs")
					player:updateQuestProgress("spiritOrbs", 1)
					dialoguePanel:hide(player.name)
					player:displayInventory()
				end)
			end
		end
	},
	final_boss = {
		canEnter = function() return true end
	},
	enigma = {
		canEnter = function(player, terminalId) return terminalId == 1 end,
		onFailure = function(player)
			print("failure")
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