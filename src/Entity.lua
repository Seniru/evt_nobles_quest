local Entity = {}

Entity.__index = Entity
Entity.__tostring = function(self)
	return table.tostring(self)
end
Entity.__type = "entity"


setmetatable(Entity, {
	__call = function (cls, ...)
		return cls.new(...)
	end,
})

Entity.entities = {

	-- resources

	tree = {
		image = {
			id = "no.png",
			xAdj = 0,
			yAdj = 0
		},
		resourceCap = 100,
		onAction = function(self, player)
			if player.equipped == nil then
				self:regen()
				if self.resourcesLeft <= 0 then
					return tfm.exec.chatMessage("cant use")
				end
				player:addInventoryItem(Item.items.stick, 2)
				self.resourcesLeft = self.resourcesLeft - 2
				self.latestActionTimestamp = os.time()
				displayDamage(self)
			elseif player.equipped.type ~= Item.types.SPECIAL then
				player:addInventoryItem(Item.items.wood,
					player:useSelectedItem(Item.types.AXE, "chopping", self)
				)
			else
				p(player.equipped)
			end
		end
	},

	rock = {
		image = {
			id = "no.png",
			xAdj = 0,
			yAdj = 0
		},
		resourceCap = 100,
		onAction = function(self, player)
			if player.equipped == nil or player.equipped.type == Item.types.SPECIAL then return end
			player:addInventoryItem(Item.items.stone,
				player:useSelectedItem(Item.types.SHOVEL, "mining", self)
			)
		end
	},

	iron_ore = {
		image = {
			id = "no.png",
			xAdj = 0,
			yAdj = 0
		},
		resourceCap = 60,
		onAction = function(self, player)
			if player.equipped == nil or player.equipped.type == Item.types.SPECIAL then return end
			player:addInventoryItem(Item.items.iron_ore,
				player:useSelectedItem(Item.types.SHOVEL, "mining", self)
			)
		end
	},

	-- triggers

	craft_table = {
		image = {
			id = "no.png"
		},
		onAction = function(self, player)
			openCraftingTable(player)
		end
	},

	recipe = {
		image = {
			id = "no.png"
		},
		onAction = function(self, player)
			player:learnRecipe(self.name)
		end
	},

	teleport = {
		image = {
			id = "no.png"
		},
		onAction = function(self, player)
			local tpInfo = teleports[self.name]
			local tp1, tp2 = tpInfo[1], tpInfo[2]
			if tp1 == self then
				tfm.exec.movePlayer(player.name, tp2.x, tp2.y )
			else
				tfm.exec.movePlayer(player.name, tp1.x, tp1.y)
			end
		end
	}
}

-- npcs

do

	-- npc icons
	local nosferatu = {
		normal = "17f171134b8.png",
		shocked = "17f17003375.png",
		thinking = "17f170dc941.png",
		happy = "17f170fda30.png",
		question = "17f17132155.png"

	}

	-- npc metadata

	Entity.entities.nosferatu = {
		displayName = "Nosferatu",
		image = {
			id = "17ebeab46db.png",
			xAdj = 0,
			yAdj = -35
		},
		onAction = function(self, player)
			local name = player.name
			local qProgress = player.questProgress["giveWood"]
			if not qProgress then return end
			local idx, woodAmount = player:getInventoryItem("wood")
			local idx, oreAmount = player:getInventoryItem("iron_ore")
			print({"wood", woodAmount})
			if not qProgress.completed then
				if qProgress.stage == 1 and qProgress.stageProgress == 0 then
					addDialogueSeries(name, 2, {
						{ text = translate("NOSFERATU_DIALOGUES", player.language, 1), icon = nosferatu.shocked },
						{ text = translate("NOSFERATU_DIALOGUES", player.language, 2), icon = nosferatu.thinking },
						{ text = translate("NOSFERATU_DIALOGUES", player.language, 3), icon = nosferatu.happy },
						{ text = translate("NOSFERATU_DIALOGUES", player.language, 4), icon = nosferatu.normal },
					}, "Nosferatu", function(id, _name, event)
						if player.questProgress.giveWood and player.questProgress.giveWood.stage ~= 1 then return end -- delayed packets can result in giving more than 10 stone
						player:updateQuestProgress("giveWood", 1)
						dialoguePanel:hide(name)
						player:addInventoryItem(Item.items.stone, 10)
						player:displayInventory()

					end)
				-- change wood amount later
				elseif qProgress.stage == 2 and woodAmount and woodAmount >= 10 then
					addDialogueSeries(name, 2, {
						{ text = "ok u suck", icon = "17ebeab46db.png" },
					}, "Nosferatu", function(id, _name, event)
						if player.questProgress.giveWood and player.questProgress.giveWood.stage ~= 2 then return end -- delayed packets can result in giving more than 10 stone
						player:updateQuestProgress("giveWood", 1)
						player:addInventoryItem(Item.items.wood, -10)
						player:addInventoryItem(Item.items.stone, 10)
						dialoguePanel:hide(name)
						player:displayInventory()
					end)
				elseif qProgress.stage == 3 and oreAmount and oreAmount >= 15 then
					addDialogueSeries(name, 2, {
						{ text = "good good", icon = nosferatu.happy }
					}, "Nosferatu", function(id, _name, event)
						if player.questProgress.giveWood and player.questProgress.giveWood.stage ~= 3 then return end -- delayed packets can result in giving more than 10 stone
						player:updateQuestProgress("giveWood", 1)
						player:addInventoryItem(Item.items.iron_ore, -15)
						player:addInventoryItem(Item.items.stone, 30)
						dialoguePanel:hide(name)
						player:displayInventory()
					end)
				else
					addDialogueBox(2, "Do you need anything?", name, "Nosferatu", nosferatu.question, { 
						{ "How do I get wood?", addDialogueBox, { 4, "Chop with axe", name, "Nosferatu", nosferatu.question } },
						{ "Axe?", addDialogueBox, { 5, "Find recipe", name, "Nosferatu", nosferatu.question }}
					})
				end
			else
				addDialogueBox(10, "I sell yes", name, "Nosferatu", nosferatu.question)
			end
		end
	}

end

function Entity.new(x, y, type, area, name, id)
	local self = setmetatable({}, Entity)
	self.x = x
	self.y = y
	self.type = type
	self.area = area
	self.name = name
	self.id = id
	area.entities[#area.entities + 1] = self
	if type == "npc" then
		local npc = Entity.entities[name]
		local xAdj, yAdj = x + (npc.image.xAdj or 0), y + (npc.image.yAdj or 0)
		local id = tfm.exec.addImage(npc.image.id, "?999", xAdj, yAdj)
		ui.addTextArea(id, Entity.entities[name].displayName, nil, xAdj - 10, yAdj, 0, 0, nil, nil, 0, false)
	else
		local entity = Entity.entities[type]
		self.resourceCap = entity.resourceCap
		self.resourcesLeft = entity.resourceCap
		self.latestActionTimestamp = -1/0
		local id = tfm.exec.addImage(entity.image.id, "?999", x + (entity.image.xAdj or 0), y + (entity.image.yAdj or 0))
		ui.addTextArea(id, type, nil, x, y, 0, 0, nil, nil, 0, false)
	end
	return self
end

function Entity:receiveAction(player)
	local onAction = Entity.entities[self.type == "npc" and self.name or self.type].onAction
	if onAction then
		onAction(self, player)
	end
end

function Entity:regen()
	if self.resourcesLeft < self.resourceCap then
		local regenAmount = math.floor(os.time() - self.latestActionTimestamp) / 2000
		self.resourcesLeft = math.min(self.resourceCap, self.resourcesLeft + regenAmount)
	end
end
