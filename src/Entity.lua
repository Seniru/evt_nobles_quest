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
		onAction = function(self, player)
			if player.equipped == nil then
				player:addInventoryItem(Item.items.stick, 2)
			end
		end
	},

	rock = {
		image = {
			id = "no.png",
			xAdj = 0,
			yAdj = 0
		}
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
			if qProgress.stage == 1 and qProgress.stageProgress == 0 then
				addDialogueSeries(name, 2, {
					{ text = "Ahh you look quite new?", icon = "17ebeab46db.png" },
					{ text = "well anyways some more bs", icon = "17ebeab46db.png" },
					{ text = "Translate this and find me some wood.", icon = "17ebeab46db.png" },
				}, "Nosferatu", function(id, _name, event)
					if player.questProgress.giveWood and player.questProgress.giveWood.stage ~= 1 then return end -- delayed packets can result in giving more than 10 stone
					player:updateQuestProgress("giveWood", 1)
					dialoguePanel:hide(name)
					player:addInventoryItem(Item.items.stone, 10)
				end)
			else
				addDialogueBox(3, "Do you need anything?", name, "Nosferatu", "17ebeab46db.png", { "How do I get wood?", "Axe?" })
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
		tfm.exec.addImage(entity.image.id, "?999", x + (entity.image.xAdj or 0), y + (entity.image.yAdj or 0))
	end
	return self
end

function Entity:receiveAction(player)
	local onAction = Entity.entities[self.type == "npc" and self.name or self.type].onAction
	if onAction then
		onAction(self, player)
	end
end
