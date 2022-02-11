local Player = {}

Player.players = {}
Player.alive = {}
Player.playerCount = 0
Player.aliveCount = 0

Player.__index = Player
Player.__tostring = function(self)
	return table.tostring(self)
end

setmetatable(Player, {
	__call = function (cls, name)
		return cls.new(name)
	end,
})

function Player.new(name)
	local self = setmetatable({}, Player)

	self.name = name
	self.area = nil
	self.equipped = nil
	self.inventorySelection = 1
	self.inventory = { {}, {}, {}, {}, {}, {}, {}, {}, {}, {} }
	self.learnedRecipes = {}
	self.questProgress = {
		-- quest: stage, stageProgress, completed?
		wc = { stage = 1, stageProgress = 0, completed = false }
	}

	Player.players[name] = self
	Player.playerCount = Player.playerCount + 1

	return self
end

function Player:setArea(x, y)
	local area = Area.getAreaByCoords(x, y)
	if area then
		if not self.area then
			self.area = area.id
		else
			Area.areas[self.area].players[self.name] = nil
			Area.areas[area.id].players[self.name] = true
			self.area = area.id
		end
	end
	return area
end

function Player:getInventoryItem(item)
	for i, it in next, self.inventory do
		if it[1] and it[1].id == item then
			return i, it[2]
		end
	end
end

function Player:addInventoryItem(newItem, quantity)
	if newItem.stackable then
		local invPos, itemQuantity = self:getInventoryItem(newItem.id)
		if invPos then
			self.inventory[invPos][2] = itemQuantity + quantity
			return self:displayInventory()
		end
	end
	for i, item in next, self.inventory do
		if #item == 0 then
			self.inventory[i] = { newItem:getItem(), quantity }
			return self:displayInventory()
		end
	end
end

-- use some kind of class based thing to add items

function Player:changeInventorySlot(idx)
	if idx < 0 or idx > 10 then return end
	self.inventorySelection = idx
	local item = self.inventory[idx][1]
	if item and item.type ~= Item.types.RESOURCE then
		print("item is special")
		self.equipped = self.inventory[idx][1]
	else
		p({"item is not epsicla", item})
		self.equipped = nil
	end
	self:displayInventory()
end

function Player:displayInventory()
	local invSelection = self.inventorySelection
	inventoryPanel:show(self.name)
	for i, item in next, self.inventory do
		if i == invSelection then
			Panel.panels[100 + i]:update("<b>" .. prettify({item[1] and item[1].id, item[2]}, 1, {}).res .. "</b>", self.name)
		else
			Panel.panels[100 + i]:update(prettify({item[1] and item[1].id, item[2]}, 1, {}).res, self.name)
		end
	end
end

function Player:useSelectedItem(isCorrectItem)
	local item = self.equipped
	local itemDamage = isCorrectItem and 1 or math.max(1, 4 - item.tier)
	local originalDurability = item.durability
	originalDurability = originalDurability - itemDamage
	item.durability = originalDurability
	if item.durability <= 0 then
		self.inventory[self.inventorySelection] = {}
	end
	p(self.inventory)
	-- give resources equivelant to the tier level of the item if they are using the correct item for the job
	return isCorrectItem and item.tier or 1
end

function Player:addNewQuest(quest)
	self.questProgress[quest] = { stage = 1, stageProgress = 0, completed = false }
	tfm.exec.chatMessage("New quest")
end

function Player:updateQuestProgress(quest, newProgress)
	local pProgress = self.questProgress[quest]
	local progress = pProgress.stageProgress + newProgress
	local q = quests[quest]
	self.questProgress[quest].stageProgress = progress
	if progress >= quests[quest][pProgress.stage].tasks then
		if pProgress.stage >= #q then
			tfm.exec.chatMessage("Quest completed")
			self.questProgress[quest].completed = true
		else
			tfm.exec.chatMessage("New stage")
			self.questProgress[quest].stage = self.questProgress[quest].stage + 1
			self.questProgress[quest].stageProgress = 0
		end
	end
end

function Player:learnRecipe(recipe)
	if self.learnedRecipes[recipe] then return end
	self.learnedRecipes[recipe] = true
	tfm.exec.chatMessage("Learned a new recipe")
end

function Player:canCraft(recipe)
	if not self.learnedRecipes[recipe] then return false end
	for _, neededItem in next, recipes[recipe] do
		local idx, amount = self:getInventoryItem(neededItem[1].id)
		p({neededItem[1], idx, amount})
		if (not idx) or (neededItem[2] > amount) then return false end
	end
	return true
end

function Player:craftItem(recipe)
	if not self:canCraft(recipe) then return p("cant craft") end
	for _, neededItem in next, recipes[recipe] do
		local idx, amount = self:getInventoryItem(neededItem[1].id)
		self.inventory[idx][2] = amount - neededItem[2]
	end
	self:addInventoryItem(Item.items[recipe], 1)
end

function Player:savePlayerData()
	local name = self.name
	system.savePlayerData(name, "v2" .. dHandler:dumpPlayer(name))
end