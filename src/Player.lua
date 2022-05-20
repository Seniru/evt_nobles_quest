Player = {}

Player.players = {}
Player.alive = {}
Player.playerCount = 0
Player.aliveCount = 0

Player.__index = Player
Player.__tostring = function(self)
	return table.tostring(self)
end
Player.__type = "player"

setmetatable(Player, {
	__call = function (cls, name)
		return cls.new(name)
	end,
})

function Player.new(name)
	local self = setmetatable({}, Player)

	self.name = name
	self.language = tfm.get.room.playerList[name].language
	self.area = nil
	self.equipped = nil
	self.inventorySelection = 1
	self.stance = -1 -- right
	self.health = 50
	self.alive = true
	self.inventory = { {}, {}, {}, {}, {}, {}, {}, {}, {}, {} }
	self.carriageWeight = 0
	self.sequenceIndex = 1
	self.chargedDivinePower = 0
	self.learnedRecipes = {}
	self.spiritOrbs = 0
	self.questProgress = {
		-- quest: stage, stageProgress, completed?
	}

	Player.players[name] = self
	Player.playerCount = Player.playerCount + 1

	return self
end

function Player:setArea(x, y)
	local originalArea = Area.areas[self.area]
	local newArea = Area.getAreaByCoords(x, y)
	self.area = newArea and newArea.id or nil
	if originalArea ~= newArea then
		if originalArea then originalArea:onPlayerLeft(self) end
		if newArea then newArea:onNewPlayer(self) end
	end
	return newArea
end

function Player:getInventoryItem(item)
	for i, it in next, self.inventory do
		if it[1] and it[1].id == item then
			return i, it[2]
		end
	end
end

function Player:addInventoryItem(newItem, quantity)
	local newWeight = self.carriageWeight + newItem.weight * quantity
	if newWeight > 20 then error("Full inventory", 1) end
	self.carriageWeight = newWeight
	if newItem.stackable then
		local invPos, itemQuantity = self:getInventoryItem(newItem.id)
		if invPos and itemQuantity + quantity < 128 then
			local newQuantity = itemQuantity + quantity
			if newQuantity < 0 then return end
			if newQuantity == 0 then
				self.inventory[invPos] = {}
			else
				if newQuantity <= 0 then
					self.inventory[invPos] = {}
				else
					self.inventory[invPos][2] = newQuantity
				end
			end
			if invPos == self.inventorySelection then self:changeInventorySlot(invPos) end
			return self:displayInventory()
		end
	end
	if quantity <= 0 then return end
	for i, item in next, self.inventory do
		if #item > 0 and newItem.stackable and newItem.id == item[1].id and quantity + item[2] < 128 then
			self.inventory[i][2] = item[2] + quantity
			return self:displayInventory()
		elseif #item == 0 then
			self.inventory[i] = { newItem:getItem(), quantity }
			if i == self.inventorySelection then self:changeInventorySlot(i) end
			return self:displayInventory()
		end
	end
	error("Full inventory", 2)
end

-- use some kind of class based thing to add items

function Player:changeInventorySlot(idx)
	if idx < 0 or idx > 10 then return end
	self.inventorySelection = idx
	local item = self.inventory[idx][1]
	if item and item.type ~= Item.types.RESOURCE then
		self.equipped = self.inventory[idx][1]
	else
		self.equipped = nil
	end
	self:displayInventory()
end

function Player:displayInventory()
	local invSelection = self.inventorySelection
	inventoryPanel:hide(self.name)
	inventoryPanel:show(self.name)
	for i, item in next, self.inventory do
		if #item > 0 then
			Panel.panels[100 + i]:addImageTemp(Image(item[1].image, "~1", Panel.panels[100 + i].x, 350), self.name)
		end
		if i == invSelection then
			Panel.panels[120 + i]:update("<b><font size='10px'>" .. (item[2] and "×" .. item[2] or "") .. "</font></b>", self.name)
		else
			Panel.panels[120 + i]:update("<font size='10px'>" .. (item[2] and "×" .. item[2] or "") .. "</font>", self.name)
		end
	end
end

function Player:useSelectedItem(requiredType, requiredProperty, targetEntity)
	local item = self.equipped
	-- we only need to calculate the regen when it receives another action
	-- so we can save resources used to calculate the regen over each intervals
	targetEntity:regen()
	if (not item[requiredProperty] == 0) or targetEntity.resourcesLeft <= 0 then
		tfm.exec.chatMessage(translate("OUT_OF_RESOURCES", player.language), self.name)
		return 0
	end
	local isCorrectItem = item.type == requiredType
	local itemDamage = isCorrectItem and 1 or math.max(1, 4 - item.tier)
	local originalDurability = item.durability
	originalDurability = originalDurability - itemDamage
	item.durability = originalDurability
	if item.durability <= 0 then
		self.inventory[self.inventorySelection] = {}
		item = nil
		self:changeInventorySlot(self.inventorySelection)
		return 0
	end
	-- give resources equivelant to the tier level of the item if they are using the correct item for the job
	local returnAmount = isCorrectItem and (item.tier + item[requiredProperty] - 1) or 1
	targetEntity.resourcesLeft = math.max(targetEntity.resourcesLeft - returnAmount, 0)
	displayDamage(targetEntity)
	targetEntity.latestActionTimestamp = os.time()
	return returnAmount
end

function Player:addNewQuest(quest)
	if self.questProgress[quest] then return end
	self.questProgress[quest] = { stage = 1, stageProgress = 0, completed = false }
	local qData = quests[quest]
	tfm.exec.chatMessage(translate("NEW_QUEST", self.language, nil, {
		questName = qData.title_locales[self.language] or qData.title_locales["en"],
	}), self.name)
	tfm.exec.chatMessage(translate("NEW_STAGE", self.language, nil, {
		questName = qData.title_locales[self.language] or qData.title_locales["en"],
		desc = qData[1].description_locales[self.language] or qData[1].description_locales["en"] or "",
	}), self.name)
end

function Player:updateQuestProgress(quest, newProgress)
	if newProgress == 0 then return end
	local pProgress = self.questProgress[quest]
	local progress = pProgress.stageProgress + newProgress
	local q = quests[quest]
	local announceStageProgress = true
	self.questProgress[quest].stageProgress = progress
	if progress >= quests[quest][pProgress.stage].tasks then
		if pProgress.stage >= #q then
			tfm.exec.chatMessage(translate("QUEST_OVER", self.language, nil, {
				questName = q.title_locales[self.language] or q.title_locales["en"],
			}), self.name)
			self.questProgress[quest].completed = true
		else
			self.questProgress[quest].stage = self.questProgress[quest].stage + 1
			self.questProgress[quest].stageProgress = 0
			tfm.exec.chatMessage(translate("NEW_STAGE", self.language, nil, {
				questName = q.title_locales[self.language] or q.title_locales["en"],
				desc = q[pProgress.stage].description_locales[self.language] or q[pProgress.stage].description_locales["en"] or "",
			}), self.name)
		end
		announceStageProgress = false
	end
	if announceStageProgress then
		tfm.exec.chatMessage(translate("STAGE_PROGRESS", self.language, nil, {
			questName = q.title_locales[self.language] or q.title_locales["en"],
			progress = progress,
			needed = quests[quest][pProgress.stage].tasks
		}), self.name)
	end
	dHandler:set(self.name, "questProgress", encodeQuestProgress(self.questProgress))
	self:savePlayerData()
end

function Player:learnRecipe(recipe)
	if self.learnedRecipes[recipe] then return end
	self.learnedRecipes[recipe] = true
	local item = Item.items[recipe]
	p({item.locales[self.language], self.language})
	tfm.exec.chatMessage(translate("NEW_RECIPE", self.language, nil, { itemName = item.locales[self.language], itemDesc = item.description_locales[self.language] }), self.name)
	dHandler:set(self.name, "recipes", recipesBitList:encode(self.learnedRecipes))
	self:savePlayerData()
end

function Player:canCraft(recipe)
	if not self.learnedRecipes[recipe] then return false end
	for _, neededItem in next, recipes[recipe] do
		local idx, amount = self:getInventoryItem(neededItem[1].id)
		if (not idx) or (neededItem[2] > amount) then return false end
	end
	return true
end

function Player:craftItem(recipe)
	if not self:canCraft(recipe) then return end
	for _, neededItem in next, recipes[recipe] do
		self:addInventoryItem(neededItem[1], -neededItem[2])
		--self.inventory[idx][2] = amount - neededItem[2]
	end
	self:addInventoryItem(Item.items[recipe], 1)
end

function Player:dropItem()
	local invSelection = self.inventorySelection
	if #self.inventory[invSelection] == 0 then return end
	local droppedItem = self.inventory[invSelection]
	self.inventory[invSelection] = {}
	self:changeInventorySlot(invSelection)
	self:displayInventory()
	local pData = tfm.get.room.playerList[self.name]
	p(self.stance * 2)
	local dropId = tfm.exec.addShamanObject(tfm.enum.shamanObject.littleBox, pData.x, pData.y, 45, -2 * self.stance, -2, true)
	Timer.new("drop_item" .. dropId, function()
		local obj = tfm.get.room.objectList[dropId]
		local x, y = obj.x, obj.y
		tfm.exec.removeObject(dropId)
		local area = Area.getAreaByCoords(x, y)
		if not area then return end
		Entity.new(x, y, "dropped_item", area, droppedItem[1], droppedItem[2])
	end, 1000, false)
end

function Player:attack(monster)
	monster:regen()
	if self.equipped.type ~= Item.types.SPECIAL then
		monster.health = monster.health - self.equipped.attack
		local itemDamage = self.equipped.type == Item.types.SWORD and 1 or math.max(1, 4 - item.tier)
		self.equipped.durability = self.equipped.durability - itemDamage
	end
	monster.latestActionReceived = os.time()
	if monster.health <= 0 then
		monster:destroy(self)
	end
end

function Player:processSequence(dir)
	if not (bossBattleTriggered and self.area) then return end
	local s, v = 528, 20
	-- s = t(u + v)/2
	-- division by 3 is because the given vx is in a different unit than px/s
	local t = ((2 * s / (v + v - 0.01)) / 3) * 1000
	local currDir = directionSequence[self.sequenceIndex]
	if not currDir then return end
	t = t + currDir[4]
	local diff = math.abs(t - os.time()) / 1000
	if diff <= 1 then -- it passed the line
		self.sequenceIndex = self.sequenceIndex + 1
		divinePowerCharge = math.min(FINAL_BOSS_ATK_MAX_CHARGE,  divinePowerCharge + (20 - diff * 20))
		self.chargedDivinePower = math.min(FINAL_BOSS_ATK_MAX_CHARGE, self.chargedDivinePower + (20 - diff * 20))
	else -- too late/early
		print("too early!")
		divinePowerCharge = math.max(0,  divinePowerCharge - 3)
		self.chargedDivinePower = math.max(0, self.chargedDivinePower - 3)
	end
end

function Player:destroy()
	local name = self.name
	tfm.exec.killPlayer(name)
	for key, code in next, keys do system.bindKeyboard(name, code, true, false) end
	self.alive = false
	divinePowerCharge = divinePowerCharge - self.chargedDivinePower
	self:setArea(-1, -1) -- area is heaven :)
end

function Player:savePlayerData()
	local name = self.name
	local inventory = {}
	local typeSpecial, typeResource = Item.types.SPECIAL, Item.types.RESOURCE
	for i, itemData in next, self.inventory do
		if #itemData > 0 then
			local item, etc = itemData[1], itemData[2]
			inventory[i] = { item.nid, item.type == typeSpecial, item.type == typeResource, item.durability or etc }
		end
	end
	p(inventory)
	dHandler:set(name, "inventory", encodeInventory(inventory))
	dHandler:set(name, "spiritOrbs", self.spiritOrbs)
	system.savePlayerData(name, "v2" .. dHandler:dumpPlayer(name))
	print("v2" .. dHandler:dumpPlayer(name))
end
