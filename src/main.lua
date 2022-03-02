tfm.exec.newGame(maps["mine"])
mapPlaying = "mine"

tfm.exec.setGameTime(150)

inventoryPanel = Panel(100, "", 30, 350, 740, 50, nil, nil, 1, true)
do
	for i = 0, 9 do
		inventoryPanel:addPanel(Panel(101 + i, "", 30 + 74 * i, 350, 50, 50, nil, nil, 1, true))
	end
end

dialoguePanel = Panel(200, "", 0, 0, 0, 0, nil, nil, 0, true)
	:addPanel(Panel(201, "", 0, 0, 0, 0, nil, nil, 0, true))

craftingPanel = Panel(300, "", 20, 30, 760, 300, nil, nil, 1, true)

addDialogueBox = function(id, text, name, speakerName, speakerIcon, replies)
	local x, y, w, h = 30, 350, type(replies) == "table" and 600 or 740, 50
	-- to erase stuff that has been displayed previously, if this dialoguebox was a part of a conversation
	dialoguePanel:hide(name)
	inventoryPanel:hide(name)
	dialoguePanel:show(name)

	dialoguePanel:addPanelTemp(Panel(id * 1000, text, x, y, w, h, 0x472315, 0xd1b130, 1, true), name)
	dialoguePanel:addPanelTemp(Panel(id * 1000 + 1, speakerName or "???", x + w - 150, y, 0, 0, nil, nil, 1, true), name)
	--dialoguePanel:addImageTemp(Image("171843a9f21.png", "&1", 730, 350), name)
	Panel.panels[201]:addImageTemp(Image(speakerIcon, "&1", x + w - 80, y - 20), name)
	dialoguePanel:update(text, name)
	if type(replies) == "table" then
		for i, reply in next, replies do
			dialoguePanel:addPanelTemp(Panel(id * 1000 + 10 + i, ("<a href='event:reply'>%s</a>"):format(reply[1]), x + w + 30, y - 10 + 20 * (i - 1), 130, 25, nil, nil, 0, true)
				:setActionListener(function(id, name, event)
					reply[2](table.unpack(reply[3]))
				end),
			name)
			dialoguePanel:addImageTemp(Image(assets.ui.reply, ":1", x + w, y - 10 + 20 * (i - 1)), name)
		end
	else
		dialoguePanel:addImageTemp(Image(assets.ui.btnNext, "&1", x + w - 20, y + h - 20), name)
		dialoguePanel:addPanelTemp(
			Panel(id * 1000 + 10, "<a href='event:2'>\n\n\n</a>", x + w + 20, y + h - 20, 30, 30, nil, nil, 1, true)
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
		Panel.panels[201]:addImageTemp(Image(dialogues[page].icon, "&1", x + w - 80, y - 20), name)
		Panel.panels[id * 1000 + 10]:update(("<a href='event:%d'>\n\n\n</a>"):format(page + 1), name)
	end)
end


displayDamage = function(target)
	local bg, fg
	if target.__type == "entity" then
		bg = tfm.exec.addImage(assets.damageBg, "?999", target.x, target.y)
		fg = tfm.exec.addImage(assets.damageFg, "?999", target.x + 1, target.y + 1, nil, target.resourcesLeft / target.resourceCap)
	elseif target.__type == "monster" then
		local obj = tfm.get.room.objectList[target.objId]
		bg = tfm.exec.addImage(assets.damageBg, "?999", obj.x, obj.y - 30)
		fg = tfm.exec.addImage(assets.damageFg, "?999" .. target.objId, obj.x + 1, obj.y + 1 - 30, nil, target.health / target.metadata.health)
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
