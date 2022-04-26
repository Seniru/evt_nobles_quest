Entity = {}

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
		onAction = function(self, player, down)
			if not down then return end
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
		onAction = function(self, player, down)
			if not down then return end
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
		onAction = function(self, player, down)
			if not down then return end
			if player.equipped == nil or player.equipped.type == Item.types.SPECIAL then return end
			player:addInventoryItem(Item.items.iron_ore,
				player:useSelectedItem(Item.types.SHOVEL, "mining", self)
			)
		end
	},

	copper_ore = {
		image = {
			id = "no.png",
			xAdj = 0,
			yAdj = 0
		},
		resourceCap = 60,
		onAction = function(self, player, down)
			if not down then return end
			if player.equipped == nil or player.equipped.type == Item.types.SPECIAL then return end
			player:addInventoryItem(Item.items.iron_ore,
				player:useSelectedItem(Item.types.SHOVEL, "mining", self)
			)
		end
	},

	gold_ore = {
		image = {
			id = "no.png",
			xAdj = 0,
			yAdj = 0
		},
		resourceCap = 60,
		onAction = function(self, player, down)
			if not down then return end
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
		onAction = function(self, player, down)
			if down then openCraftingTable(player) end
		end
	},

	recipe = {
		image = {
			id = "no.png"
		},
		onAction = function(self, player, down)
			if down then player:learnRecipe(self.name) end
		end
	},

	teleport = {
		image = {
			id = "no.png"
		},
		onAction = function(self, player, down)
			if not down then return end
			local tpInfo = teleports[self.name]
			local tp1, tp2 = tpInfo[1], tpInfo[2]
			if not tpInfo.canEnter(player, tp2) then return end
			if tp1 == self then
				tfm.exec.movePlayer(player.name, tp2.x, tp2.y)
				tpInfo.onEnter(player, 2)
			else
				tfm.exec.movePlayer(player.name, tp1.x, tp1.y)
				tpInfo.onEnter(player, 1)
			end
		end
	},

	dropped_item = {
		image = {
			id = "no.png"
		},
		onAction = function(self, player, down)
			if not down then return end
			p(self.name)
			p(self.id)
			player:addInventoryItem(self.name, self.id)
			self:destroy()
		end
	},

	bridge = {
		image = {
			id = "no.png"
		},
		onAction = function(self, player, down)
			self.building = self.building or false
			self.buildProgress = self.buildProgress or 0
			self.bridges = self.bridges or {}
			-- TODO: block building if someone is building already
			--if player.equipped.id ~= "bridge" then return end
			if down then
				self.building = true
				Timer.new("bridge_" .. player.name, function()
					self.buildProgress = self.buildProgress + 1
					displayDamage(self) -- it's progress here
					-- TODO: Change to 20
					if self.buildProgress > 2 then -- 0 then
						Timer._timers["bridge_" .. player.name]:kill()
						self.building = false
						local bridgeCount = #self.bridges + 1
						self.buildProgress = 0
						tfm.exec.addPhysicObject(100 + bridgeCount, self.x + 20 + bridgeCount * 50, self.y + 20, {
							type = 0,
							width = 50,
							height = 10,
							friction = 30
						})
						self.bridges[bridgeCount] = {100 + bridgeCount, self.x + 20 + bridgeCount * 50, self.y + 20 }
						if bridgeCount == 4 then
							tfm.exec.removePhysicObject(4)
						end
					end
				end, 500, true)
			else
				self.building = false
				self.buildProgress = 0
				Timer._timers["bridge_" .. player.name]:kill()
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
		look = "22;0,4_201412,0,1_301C18,39_FFB753,87_201412+201412+201412+301C18+41201A+201412,36_301C18+301C18+201412+201412+201412+FFBB27+FFECA5+41201A+FFB753,21_41201A,0",
		title = 0,
		female = false,
		lookLeft = true,
		lookAtPlayer = false,
		interactive = true,
		onAction = function(self, player)
			if not down then return end
			local name = player.name
			local qProgress = player.questProgress.nosferatu
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
						if player.questProgress.nosferatu and player.questProgress.nosferatu.stage ~= 1 then return end -- delayed packets can result in giving more than 10 stone
						player:updateQuestProgress("nosferatu", 1)
						dialoguePanel:hide(name)
						player:addInventoryItem(Item.items.stone, 10)
						player:displayInventory()

					end)
				-- change wood amount later
				elseif qProgress.stage == 2 and woodAmount and woodAmount >= 10 then
					addDialogueSeries(name, 2, {
						{ text = translate("NOSFERATU_DIALOGUES", player.language, 5), icon = nosferatu.normal },
						{ text = translate("NOSFERATU_DIALOGUES", player.language, 6), icon = nosferatu.happy },
						{ text = translate("NOSFERATU_DIALOGUES", player.language, 7), icon = nosferatu.normal },
					}, "Nosferatu", function(id, _name, event)
						if player.questProgress.nosferatu and player.questProgress.nosferatu.stage ~= 2 then return end -- delayed packets can result in giving more than 10 stone
						player:updateQuestProgress("nosferatu", 1)
						player:addInventoryItem(Item.items.wood, -10)
						player:addInventoryItem(Item.items.stone, 10)
						dialoguePanel:hide(name)
						player:displayInventory()
					end)
				elseif qProgress.stage == 3 and oreAmount and oreAmount >= 15 then
					addDialogueSeries(name, 2, {
						{ text = translate("NOSFERATU_DIALOGUES", player.language, 8), icon = nosferatu.shocked },
						{ text = translate("NOSFERATU_DIALOGUES", player.language, 9), icon = nosferatu.thinking },
						{ text = translate("NOSFERATU_DIALOGUES", player.language, 10), icon = nosferatu.shocked },
						{ text = translate("NOSFERATU_DIALOGUES", player.language, 11), icon = nosferatu.normal },
						{ text = translate("NOSFERATU_DIALOGUES", player.language, 10), icon = nosferatu.happy },

					}, "Nosferatu", function(id, _name, event)
						if player.questProgress.nosferatu and player.questProgress.nosferatu.stage ~= 3 then return end -- delayed packets can result in giving more than 10 stone
						player:updateQuestProgress("nosferatu", 1)
						player:addInventoryItem(Item.items.iron_ore, -15)
						player:addInventoryItem(Item.items.stone, 30)
						dialoguePanel:hide(name)
						player:displayInventory()
					end)
				else
					addDialogueBox(2, translate("NOSFERATU_DIALOGUES", player.language, 11), name, "Nosferatu", nosferatu.question, {
						{ translate("NOSFERATU_QUESTIONS", player.language, 1), addDialogueBox, { 2, translate("NOSFERATU_DIALOGUES", player.language, 11), name, "Nosferatu", nosferatu.normal } },
						{ translate("NOSFERATU_QUESTIONS", player.language, 2), addDialogueBox, { 2, translate("NOSFERATU_DIALOGUES", player.language, 12), name, "Nosferatu", nosferatu.normal }}
					})
				end
			else
				addDialogueBox(2, translate("NOSFERATU_DIALOGUES", player.language, 16), name, "Nosferatu", nosferatu.normal, {
					{ translate("NOSFERATU_QUESTIONS", player.language, 3), print, {} },
					{ translate("NOSFERATU_QUESTIONS", player.language, 4), addDialogueBox, { 2, translate("NOSFERATU_DIALOGUES", player.language, 17), name, "Nosferatu", nosferatu.normal }}
				})
			end
		end
	}

	Entity.entities.edric = {
		displayName = "Lieutenant Edric",
		look = "120;135_49382E+A27D35+49382E+53191E,9_53191E,0,0,19_DCA22E+53191E,53_CBBEB1+53191E,0,25,16_231810+A27D35+8D1C23+49382E",
		title = 0,
		female = false,
		lookLeft = true,
		lookAtPlayer = true,
		interactive = true,
		onAction = function(self, player)
			if not down then return end
			local name = player.name
			local qProgress = player.questProgress
			if qProgress.strength_test then
				if qProgress.strength_test.completed then

				else
					addDialogueBox(3, translate("EDRIC_DIALOGUES", player.language, 6), name, "Lieutenant Edric", nosferatu.normal, {
						{ translate("EDRIC_QUESTIONS", player.language, 1), addDialogueBox, { 3, translate("EDRIC_DIALOGUES", player.language, 5), name, "Lieutenant Edric", nosferatu.normal} },
						{ translate("EDRIC_QUESTIONS", player.language, 2), addDialogueSeries,
							{ name, 3, {
								{ text = translate("EDRIC_DIALOGUES", player.language, 7), icon = nosferatu.normal },
								{ text = translate("EDRIC_DIALOGUES", player.language, 8), icon = nosferatu.normal }
							}, "Lieutenant Edric", function(id, name, event)
								dialoguePanel:hide(name)
								player:displayInventory()
								if player.questProgress.strength_test and player.questProgress.strength_test.stage ~= 1 then return end -- delayed packets can result in giving more than 10 stone
								player:updateQuestProgress("strength_test", 1)
							end }
						}
					})
				end
			elseif qProgress.nosferatu and qProgress.nosferatu.completed then
				addDialogueSeries(name, 3, {
					{ text = translate("EDRIC_DIALOGUES", player.language, 1), icon = nosferatu.shocked },
					{ text = translate("EDRIC_DIALOGUES", player.language, 2), icon = nosferatu.thinking },
					{ text = translate("EDRIC_DIALOGUES", player.language, 3), icon = nosferatu.happy },
					{ text = translate("EDRIC_DIALOGUES", player.language, 4), icon = nosferatu.normal },
					{ text = translate("EDRIC_DIALOGUES", player.language, 5), icon = nosferatu.normal },
				}, "Lieutenant Edric", function(id, _name, event)
					--if player.questProgress.nosferatu and player.questProgress.nosferatu.stage ~= 1 then return end -- delayed packets can result in giving more than 10 stone
					--player:updateQuestProgress("nosferatu", 1)
					player:addNewQuest("strength_test")
					dialoguePanel:hide(name)
					player:displayInventory()

				end)
			else
				addDialogueBox(3, translate("EDRIC_DIALOGUES", player.language, 1), name, "Lieutenant Edric", nosferatu.normal)
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
	self.isDestroyed = false
	area.entities[#area.entities + 1] = self
	if type == "npc" then
		local npc = Entity.entities[name]
		tfm.exec.addNPC(npc.displayName, {
			title = npc.title,
			look = npc.look,
			x = x,
			y = y,
			female = npc.female,
			lookLeft = npc.lookLeft,
			lookAtPlayer = npc.lookAtPlayer,
			interactive = npc.interactive
		})
	else
		local entity = Entity.entities[type]
		self.resourceCap = entity.resourceCap
		self.resourcesLeft = entity.resourceCap
		self.latestActionTimestamp = -1/0
		self.imageId = tfm.exec.addImage(entity.image.id, "?999", x + (entity.image.xAdj or 0), y + (entity.image.yAdj or 0))
		ui.addTextArea(self.imageId, type, nil, x, y, 0, 0, nil, nil, 0, false)
	end
	return self
end

function Entity:receiveAction(player, keydown)
	if self.isDestroyed then return end
	local onAction = Entity.entities[self.type == "npc" and self.name or self.type].onAction
	if onAction then
		local success, error = pcall(onAction, self, player, keydown)
		p({success, error})
	end
end

function Entity:regen()
	if self.resourcesLeft < self.resourceCap then
		local regenAmount = math.floor(os.time() - self.latestActionTimestamp) / 2000
		self.resourcesLeft = math.min(self.resourceCap, self.resourcesLeft + regenAmount)
	end
end

function Entity:destroy()
	-- removing visual hints and marking state as destroyed should be enough
	-- we can't really remove the object because it is cached inside the Area
	-- keeping track of the index isn't going to be an easier task within our implementation
	self.isDestroyed = true
	ui.removeTextArea(self.imageId)
end
