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
	self.health = health(50, name)
	self.alive = true
	self.inventory = { {}, {}, {}, {}, {}, {}, {}, {}, {}, {} }
	self.carriageWeight = 0
	self.sequenceIndex = 1
	self.chargedDivinePower = 0
	self.learnedRecipes = {}
	self.spiritOrbs = 0
	self.divinePower = false
	self.isShielded = false
	self.actionCooldown = 0
	self.kills = 0
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
	--if quantity <= 0 then return end
	for i, item in next, self.inventory do
		if #item > 0 and newItem.stackable and newItem.id == item[1].id and quantity + item[2] < 128 then
			self.inventory[i][2] = item[2] + quantity
			return self:displayInventory()
		elseif #item == 0 and quantity > 0 then
			self.inventory[i] = { newItem:getItem(), quantity }
			if i == self.inventorySelection then self:changeInventorySlot(i) end
			return self:displayInventory()
		elseif #item > 0 and item[1].id == newItem.id and (not newItem.stackable) and quantity == -1 then
			self.inventory[i] = {}
			return self:displayInventory()
		end
	end
	tfm.exec.chatMessage(translate("FULL_INVENTORY", self.language), self.name)
	error("Full inventory", 2)
end

-- use some kind of class based thing to add items

function Player:changeInventorySlot(idx)
	if idx < 0 or idx > 10 or self.divinePower then return end
	self.inventorySelection = idx
	self.isShielded = false
	local item = self.inventory[idx][1]
	if item and item.type ~= Item.types.RESOURCE and item.type ~= Item.types.SPECIAL then
		self.equipped = self.inventory[idx][1]
		self:changeHoldingItem()
	else
		self.equipped = nil
	end
	self:displayInventory()
end

function Player:changeHoldingItem()
	--[[local item = self.inventory[self.inventorySelection][1]
	if self.holdingImage then
		tfm.exec.removeImage(self.holdingImage)
	end
	if item and item.type ~= Item.types.RESOURCE and item.type ~= Item.types.SPECIAL then
		print("got in here")
		local isFacingRight = self.stance == -1
		self.holdingImage = tfm.exec.addImage(item.image, "$" .. self.name, isFacingRight and 28 or -25, isFacingRight and -3 or 0, nil, 0.8, 0.8, isFacingRight and 0 or 180, 1, 0.5, 0.5)
	end]]
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
			Panel.panels[120 + i]:update("<font size='10px' color='#aaaaaa'>" .. (item[2] and "×" .. item[2] or "") .. "</font>", self.name)
		end
	end
	Panel.panels[150]:update(translate("INVENTORY_INFO", self.language, nil, {
		color = self.carriageWeight < 14 and "C2C2DA" or (self.carriageWeight < 18 and "de813e" or "d93931"),
		weight = self.carriageWeight
	}), self.name)
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
	self:savePlayerData()
end

function Player:updateQuestProgress(quest, newProgress)
	if newProgress == 0 then return end
	local pProgress = self.questProgress[quest]
	if pProgress.completed then return end
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
			giveReward(self.name, 1)
			if quest == "strength_test" then
				system.giveEventGift(self.name, "evt_nobles_quest_title_542")
				system.giveEventGift(self.name, "evt_nobles_quest_golden_ticket_20")
			elseif quest ~= "wc" and quest ~= "final_boss" then
				system.giveEventGift(self.name, "evt_nobles_quest_golden_ticket_20")
			end
		else
			self.questProgress[quest].stage = self.questProgress[quest].stage + 1
			self.questProgress[quest].stageProgress = 0
			tfm.exec.chatMessage(translate("NEW_STAGE", self.language, nil, {
				questName = q.title_locales[self.language] or q.title_locales["en"],
				desc = q[pProgress.stage].description_locales[self.language] or q[pProgress.stage].description_locales["en"] or "",
			}), self.name)
			giveReward(self.name, 0)
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
	local hasAllRecipes = true
	for k, v in next, recipesBitList.featureKeys do
		if not self.learnedRecipes[k] then
			hasAllRecipes = false
			break
		end
	end
	if self.learnedRecipes[recipe] then return end
	self.learnedRecipes[recipe] = true
	local item = Item.items[recipe]
	tfm.exec.chatMessage(translate("NEW_RECIPE", self.language, nil, { itemName = item.locales[self.language], itemDesc = item.description_locales[self.language] }), self.name)
	if hasAllRecipes then
		system.giveEventGift(self.name, "evt_nobles_quest_title_543")
	end
	dHandler:set(self.name, "recipes", recipesBitList:encode(self.learnedRecipes))
	self:savePlayerData()
end

function Player:canCraft(recipe)
	if not self.learnedRecipes[recipe] then return false end
	for _, neededItem in next, recipes[recipe] do
		local idx, amount = nil, 0
		if not neededItem[1].stackable then
			for i, it in next, self.inventory do
				if it[1] and it[1].id == neededItem[1].id then
					idx = i
					amount = amount + 1
				end
			end
		else
			idx, amount = self:getInventoryItem(neededItem[1].id)
		end
		if (not idx) or (neededItem[2] > amount) then return false end
	end
	return true
end

function Player:craftItem(recipe)
	if not self:canCraft(recipe) then return end
	for _, neededItem in next, recipes[recipe] do
		if not neededItem[1].stackable then
			for i = 1, neededItem[2] do
				self:addInventoryItem(neededItem[1], -1)
			end
		else
			self:addInventoryItem(neededItem[1], -neededItem[2])
		end
		--self.inventory[idx][2] = amount - neededItem[2]
	end
	self:addInventoryItem(Item.items[recipe], 1)
end

function Player:dropItem()
	local invSelection = self.inventorySelection
	if #self.inventory[invSelection] == 0 then return end
	local droppedItem = self.inventory[invSelection]
	self.inventory[invSelection] = {}
	self.carriageWeight = self.carriageWeight - droppedItem[1].weight * droppedItem[2]
	self:changeHoldingItem()
	self:changeInventorySlot(invSelection)
	self:displayInventory()
	local pData = tfm.get.room.playerList[self.name]
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
	if (not self.equipped) or (self.equipped and self.equipped.type == Item.types.SPECIAL) then return end
	local playerObj = tfm.get.room.playerList[self.name]
	tfm.exec.displayParticle(3, playerObj.x - self.stance * 10, playerObj.y, 1)
	local item = self.equipped
	monster.health = monster.health - item.attack
	displayDamage(monster)
	local itemDamage = item.type == Item.types.SWORD and 1 or math.max(1, 4 - item.tier)
	self.equipped.durability = self.equipped.durability - itemDamage
	if item.durability <= 0 then
		self.inventory[self.inventorySelection] = {}
		self:changeInventorySlot(self.inventorySelection)
	end
	monster.latestActionReceived = os.time()
	if monster.health <= 0 then
		monster:destroy(self)
	end
end

function Player:equipShield(equip)
	if equip then
		self.isShielded = true
	else
		self.isShielded = false
	end
end

function Player:processSequence(dir)
	dir = ({3, 0, 1, 2})[dir + 1]
	--[[
		0 - Transformice Left
1 - Transformice Jump
2 - Transformice Right
3 - Transformice Duck
	]]
	if not self.divinePower or not (bossBattleTriggered and self.area) then return end
	local s, v = 816 - 170, 20
	-- s = t(u + v)/2
	-- division by 3 is because the given vx is in a different unit than px/s
	local t = ((2 * s / (v + v - 0.01)) / 3) * 1000
	local currDir = directionSequence[self.sequenceIndex]
	if not currDir then return end
	t = t + currDir[4]
	local diff = math.abs(t - os.time()) / 1000
	if diff <= 1 and dir == currDir[2] then -- it passed the line
		self.sequenceIndex = self.sequenceIndex + 1
		divinePowerCharge = math.min(FINAL_BOSS_ATK_MAX_CHARGE,  divinePowerCharge + (20 - diff * 20))
		self.chargedDivinePower = math.min(FINAL_BOSS_ATK_MAX_CHARGE, self.chargedDivinePower + (20 - diff * 20))
		tfm.exec.addImage("1810e9320a6.png", "#" .. currDir[1], 0, 230, self.name, 1, 1, math.rad(90 * currDir[2]), 1, 0.5, 0.5)
	else -- too late/early
		tfm.exec.addImage("1810e90e75d.png", "#" .. currDir[1], 0, 230, self.name, 1, 1, math.rad(90 * currDir[2]), 1, 0.5, 0.5)
		Timer.new("resetCannon" .. self.name, function()
			tfm.exec.addImage("180e7b47ef5.png", "#" .. currDir[1], 0, 230, self.name, 1, 1, math.rad(90 * currDir[2]), 1, 0.5, 0.5)
		end, 1000, false)
		divinePowerCharge = math.max(0,  divinePowerCharge - 3)
		self.chargedDivinePower = math.max(0, self.chargedDivinePower - 3)
	end
end

function Player:toggleDivinePower()
	if self.area == 3 and self.spiritOrbs == 62 and not bossBattleTriggered then
		self.divinePower = not self.divinePower
		self.isShielded = false
		tfm.exec.freezePlayer(self.name, self.divinePower, false)
		if self.divinePower then
			self.divineImage = tfm.exec.addImage("18105fc6781.png", "$" .. self.name, -22, -20)
		else
			tfm.exec.removeImage(self.divineImage)
		end
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
	if not self.dataLoaded then return end
	local name = self.name
	local inventory = {}
	local typeSpecial, typeResource = Item.types.SPECIAL, Item.types.RESOURCE
	for i, itemData in next, self.inventory do
		if #itemData > 0 then
			local item, etc = itemData[1], itemData[2]
			inventory[i] = { item.nid, item.type == typeSpecial, item.type == typeResource, item.durability or etc }
		else
			inventory[i] = {}
		end
	end
	dHandler:set(name, "inventory", encodeInventory(inventory))
	dHandler:set(name, "spiritOrbs", self.spiritOrbs)
	dHandler:set(name, "questProgress", encodeQuestProgress(self.questProgress))
	system.savePlayerData(name, "v2" .. dHandler:dumpPlayer(name))
end
