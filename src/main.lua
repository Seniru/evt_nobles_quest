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
			dialoguePanel:addPanelTemp(Panel(id * 1000 + 10 + i, reply, x + w + 30, y - 10 + 20 * (i - 1), 130, 25, nil, nil, 0, true), name)
			dialoguePanel:addImageTemp(Image(assets.ui.reply, ":1", x + w, y - 10 + 20 * (i - 1)), name)
		end
	else
		dialoguePanel:addImageTemp(Image(assets.ui.btnNext, "&1", x + w - 20, y + h - 20), name)
		dialoguePanel:addPanelTemp(
			Panel(id * 1000 + 10, ("<a href='event:%d'>\n\n\n</a>"):format(id + 1), x + w + 20, y + h - 20, 30, 30, nil, nil, 1, true)
				:setActionListener(replies)
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
