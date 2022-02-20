local Entity = {}

Entity.__index = Entity
Entity.__tostring = function(self)
	return table.tostring(self)
end


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
				if self.resourcesLeft <= 0 then
					return tfm.exec.chatMessage("cant use")
				end
				player:addInventoryItem(Item.items.stick, 2)
				self.resourcesLeft = self.resourcesLeft - 2
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
		}
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

	-- npcs

	nosferatu = {
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
			local idx, amount = player:getInventoryItem("wood")
			print({"wood", amount})
			if not qProgress.completed then
				if qProgress.stage == 1 and qProgress.stageProgress == 0 then
					addDialogueSeries(name, 2, {
						{ text = translate("NOSFERATU_DIALOGUES", player.language, 1), icon = "17ebeab46db.png" },
						{ text = translate("NOSFERATU_DIALOGUES", player.language, 2), icon = "17ebeab46db.png" },
						{ text = translate("NOSFERATU_DIALOGUES", player.language, 3), icon = "17ebeab46db.png" },
						{ text = translate("NOSFERATU_DIALOGUES", player.language, 4), icon = "17ebeab46db.png" },
					}, "Nosferatu", function(id, _name, event)
						if player.questProgress.giveWood and player.questProgress.giveWood.stage ~= 1 then return end -- delayed packets can result in giving more than 10 stone
						player:updateQuestProgress("giveWood", 1)
						dialoguePanel:hide(name)
						player:addInventoryItem(Item.items.stone, 10)
						player:displayInventory()

					end)
				elseif qProgress.stage == 2 and amount and amount >= 10 then
					addDialogueSeries(name, 3, {
						{ text = "ok u suck", icon = "17ebeab46db.png" },
					}, "Nosferatu", function(id, _name, event)
						if player.questProgress.giveWood and player.questProgress.giveWood.stage ~= 2 then return end -- delayed packets can result in giving more than 10 stone
						player:updateQuestProgress("giveWood", 1)
						dialoguePanel:hide(name)
						player:displayInventory()
					end)
				end
			else
				addDialogueBox(10, "Do you need anything?", name, "Nosferatu", "17ebeab46db.png", { "How do I get wood?", "Axe?" })
			end
		end
	}

}

function Entity.new(x, y, type, area, name)
	local self = setmetatable({}, Entity)
	self.x = x
	self.y = y
	self.type = type
	self.area = area
	self.name = name
	area.entities[#area.entities + 1] = self
	if type == "npc" then
		local npc = Entity.entities[name]
		local xAdj, yAdj = x + (npc.image.xAdj or 0), y + (npc.image.yAdj or 0)
		local id = tfm.exec.addImage(npc.image.id, "?999", xAdj, yAdj)
		ui.addTextArea(id, Entity.entities[name].displayName, nil, xAdj - 10, yAdj, 0, 0, nil, nil, 0, false)
	else
		local entity = Entity.entities[type]
		self.resourcesLeft = entity.resourceCap
		local id = tfm.exec.addImage(entity.image.id, "?999", x + (entity.image.xAdj or 0), y + (entity.image.yAdj or 0))
		ui.addTextArea(id, type, nil, x, y, 0, 0, nil, nil, 1, false)
	end
	return self
end

function Entity:receiveAction(player)
	local onAction = Entity.entities[self.type == "npc" and self.name or self.type].onAction
	if onAction then
		onAction(self, player)
	end
end
