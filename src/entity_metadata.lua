Entity.entities = {

	-- resources

	tree = {
		images = {
			{
				id = "180cc69ce37.png",
				xAdj = -20,
				yAdj = -165
			},
			{
				id = "180cc6a2d6e.png",
				xAdj = -20,
				yAdj = -165
			},
			{
				id = "180cc6a7e24.png",
				xAdj = -20,
				yAdj = -165
			}
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
		images = {
			{
				id = "180a4ca7edc.png",
				xAdj = -20,
				yAdj = -10
			},
			{
				id = "180a4cba62e.png",
				xAdj = -20,
				yAdj = -10
			},
			{
				id = "180a4cbf706.png",
				xAdj = -20,
				yAdj = -16
			}
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
			id = "180dfe91752.png",
			xAdj = -110,
			yAdj = -120
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
			if not tpInfo.canEnter(player, tp2) then
				if tpInfo.onFailure then tpInfo.onFailure(player) end
				return
			end
			local terminal, x, y
			if tp1 == self then
				x, y, terminal = tp2.x, tp2.y, 2
			else
				x, y, terminal = tp1.x, tp1.y, 1
			end
			tfm.exec.movePlayer(player.name, x, y)
			Timer.new("tp_anim", tfm.exec.displayParticle, 10, false, 37, x, y)
			if tpInfo.onEnter then tpInfo.onEnter(player, terminal) end
		end
	},

	dropped_item = {
		image = {
			id = "no.png"
		},
		onAction = function(self, player, down)
			if not down then return end
			player:addInventoryItem(self.name, self.id)
			self:destroy()
		end
	},

	spirit_orb  = {
		image = {
			id = "180dbcc0036.png"
		},
		onAction = function(self, player, down)
			if not down then return end
			local qProgress = player.questProgress
			player:addNewQuest("spiritOrbs")
			if bit.band(player.spiritOrbs, bit.lshift(1, self.name)) > 0 then return end
			player.spiritOrbs = bit.bor(player.spiritOrbs, bit.lshift(1, self.name))
			print(player.spiritOrbs)
			tfm.exec.chatMessage(translate("SPIRIT_ORB", player.language), player.name)
			if qProgress.spiritOrbs and qProgress.spiritOrbs.stage == 3 then
				player:updateQuestProgress("spiritOrbs", 1)
			end
			if self.name == 5 then
				player:updateQuestProgress("fiery_dragon", 1)
				player:addNewQuest("final_boss")
			end
			player:savePlayerData()
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
						local w = 560 / 4
						tfm.exec.addPhysicObject(100 + bridgeCount, self.x - 20 + bridgeCount * w, self.y + 35, {
							type = 0,
							width = w,
							height = 10,
							friction = 30
						})
						self.bridges[bridgeCount] = {100 + bridgeCount, self.x - 20 + bridgeCount * w, self.y + 35 }
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

	local garry = {
		sad = "180d2707c36.png"
	}

	local thompson = {
		pointing = "180d28c6772.png",
		thinking = "180d29fd7a6.png",
		happy = "180d2a009e2.png"
	}

	local edric = {
		normal = "180d7901bfb.png",
		surprised = "180d79c0e9c.png",
		happy = "180d79c2837.png",
		exclamation = "180d79cba27.png",
		question = "180d7df87b1.png"
	}

	local saruman = {
		normal = "180dcb867ce.png",
		exclamation = "180dcb7c454.png",
		happy = "180dcb7e119.png",
		question = "180dcb89e56.png"
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
			print("came here ")
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
						xpcall(player.addInventoryItem, function(err, success)
							if success then
								player:updateQuestProgress("nosferatu", 1)
								dialoguePanel:hide(name)
								player:displayInventory()
							elseif err:match("Full inventory") then
								addDialogueBox(2, translate("NOSFERATU_DIALOGUES", player.language, 18), name, "Nosferatu", nosferatu.thinking)
							end
						end, player, Item.items.stone, 10)
					end)
				-- change wood amount later
				elseif qProgress.stage == 2 and woodAmount and woodAmount >= 15 then
					addDialogueSeries(name, 2, {
						{ text = translate("NOSFERATU_DIALOGUES", player.language, 5), icon = nosferatu.normal },
						{ text = translate("NOSFERATU_DIALOGUES", player.language, 6), icon = nosferatu.happy },
						{ text = translate("NOSFERATU_DIALOGUES", player.language, 7), icon = nosferatu.normal },
					}, "Nosferatu", function(id, _name, event)
						if player.questProgress.nosferatu and player.questProgress.nosferatu.stage ~= 2 then return end -- delayed packets can result in giving more than 10 stone
						dialoguePanel:hide(name)
						player:displayInventory()
						xpcall(player.addInventoryItem, function(err, success)
							if success then
								player:addInventoryItem(Item.items.wood, -15)
								player:updateQuestProgress("nosferatu", 1)
								dialoguePanel:hide(name)
								player:displayInventory()
							elseif err:match("Full inventory") then
								addDialogueBox(2, translate("NOSFERATU_DIALOGUES", player.language, 18), name, "Nosferatu", nosferatu.thinking)
							end
						end, player, Item.items.stone, 10)

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
						xpcall(player.addInventoryItem, function(err, success)
							if success then
								player:addInventoryItem(Item.items.iron_ore, -15)
								player:updateQuestProgress("nosferatu", 1)
								dialoguePanel:hide(name)
								player:displayInventory()
							elseif err:match("Full inventory") then
								addDialogueBox(2, translate("NOSFERATU_DIALOGUES", player.language, 18), name, "Nosferatu", nosferatu.thinking)
							end
						end, player, Item.items.stone, 30)

					end)
				else
					addDialogueBox(2, translate("NOSFERATU_DIALOGUES", player.language, 13), name, "Nosferatu", nosferatu.question, {
						{ translate("NOSFERATU_QUESTIONS", player.language, 1), addDialogueBox, { 2, translate("NOSFERATU_DIALOGUES", player.language, 14), name, "Nosferatu", nosferatu.normal } },
						{ translate("NOSFERATU_QUESTIONS", player.language, 2), addDialogueBox, { 2, translate("NOSFERATU_DIALOGUES", player.language, 15), name, "Nosferatu", nosferatu.normal }}
					})
				end
			else
				addDialogueBox(2, translate("NOSFERATU_DIALOGUES", player.language, 16), name, "Nosferatu", nosferatu.normal, {
					{ translate("NOSFERATU_QUESTIONS", player.language, 3), function(player)
						local idx, stickAmount = player:getInventoryItem("stick")
						if stickAmount < 35 then
							addDialogueBox(2, translate("NOSFERATU_DIALOGUES", player.language, 20), name, "Nosferatu", nosferatu.normal)
						else
							xpcall(player.addInventoryItem, function(err, success)
								if success then
									player:addInventoryItem(Item.items.stick, -35)
									addDialogueBox(2, translate("NOSFERATU_DIALOGUES", player.language, 19), name, "Nosferatu", nosferatu.happy)
								elseif err:match("Full inventory") then
									addDialogueBox(2, translate("NOSFERATU_DIALOGUES", player.language, 18), name, "Nosferatu", nosferatu.thinking)
								end
							end, player, Item.items.stone, 10)
						end
					end, { player } },
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
			local name = player.name
			local qProgress = player.questProgress
			if qProgress.strength_test then
				if qProgress.strength_test.completed or qProgress.strength_test.stage > 2 then
					addDialogueBox(3, translate("EDRIC_DIALOGUES", player.language, 9), name, "Lieutenant Edric", edric.exclamation)
					player:updateQuestProgress("strength_test", 1)
					player:addNewQuest("fiery_dragon")
				else
					if qProgress.strength_test.stage == 2 then
						return addDialogueBox(3, translate("EDRIC_DIALOGUES", player.language, 8), name, "Lieutenant Edric", edric.happy)
					end
					addDialogueBox(3, translate("EDRIC_DIALOGUES", player.language, 6), name, "Lieutenant Edric", edric.question, {
						{ translate("EDRIC_QUESTIONS", player.language, 1), addDialogueBox, { 3, translate("EDRIC_DIALOGUES", player.language, 5), name, "Lieutenant Edric", edric.normal} },
						{ translate("EDRIC_QUESTIONS", player.language, 2), addDialogueSeries,
							{ name, 3, {
								{ text = translate("EDRIC_DIALOGUES", player.language, 7), icon = edric.normal },
								{ text = translate("EDRIC_DIALOGUES", player.language, 8), icon = edric.happy }
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
					{ text = translate("EDRIC_DIALOGUES", player.language, 1), icon = edric.exclamation },
					{ text = translate("EDRIC_DIALOGUES", player.language, 2), icon = edric.surprised },
					{ text = translate("EDRIC_DIALOGUES", player.language, 3), icon = edric.normal },
					{ text = translate("EDRIC_DIALOGUES", player.language, 4), icon = edric.normal },
					{ text = translate("EDRIC_DIALOGUES", player.language, 5), icon = edric.happy },
				}, "Lieutenant Edric", function(id, _name, event)
					--if player.questProgress.nosferatu and player.questProgress.nosferatu.stage ~= 1 then return end -- delayed packets can result in giving more than 10 stone
					--player:updateQuestProgress("nosferatu", 1)
					player:addNewQuest("strength_test")
					dialoguePanel:hide(name)
					player:displayInventory()

				end)
			else
				addDialogueBox(3, translate("EDRIC_DIALOGUES", player.language, 1), name, "Lieutenant Edric", edric.exclamation)
			end
		end
	}

	Entity.entities.garry = {
		displayName = "Garry",
		look = "126;110_AE752F,0,55_5F524F+554A47+C5B4AE+C5B4AE+332A28+332A28,36_5F524F+554A47+242120+5F524F,0,75_583131+391E1E+1D121A,37_AE752F+AE752F,21_332A28,0",
		title = 0,
		female = false,
		lookAtPlayer = true,
		interactive = true,
		onAction = function(self, player)
			addDialogueBox(4, translate("GARRY_DIALOGUES", player.language, 1), player.name, "Garry", garry.sad)
		end
	}

	Entity.entities.thompson = {
		displayName = "Thompson",
		look = "15;190_443A40+767576+585155+C48945+C48945+202020+E7E6E5,24,0,54,8,0,36,67,0",
		title = 0,
		female = false,
		lookAtPlayer = true,
		interactive = true,
		onAction = function(self, player)
			local name = player.name
			addDialogueBox(4, translate("THOMPSON_DIALOGUES", player.language, 1), player.name, "Thompson", thompson.thinking, {
				{ translate("THOMPSON_QUESTIONS", player.language, 1), addDialogueBox, { 2, translate("THOMPSON_DIALOGUES", player.language, 2), name, "Thompson", thompson.pointing } },
				{ translate("THOMPSON_QUESTIONS", player.language, 2), addDialogueBox, { 2, translate("THOMPSON_DIALOGUES", player.language, 3), name, "Thompson", thompson.happy }}
			})
		end
	}

	Entity.entities.laura = {
		displayName = "Laura",
		look = "9;2_FFAC38,0,0,0,49_532B21+532B21+532B21+FFAC38+FFAC38,26_291511+FFAC38,0,60_291511,0",
		title = 0,
		female = true,
		lookAtPlayer = true,
		interactive = true,
		onAction = function(self, player)
			system.openEventShop("nobles", player.name)
		end
	}

	Entity.entities.cole = {
		displayName = "Cole",
		look = "1;62_414131+25251E,46_25251E,0,0,60_25251E+414131+25251E+414131+25251E+25251E+25251E+414131+414131+414131,94_482F20+221C16+482F20+221C16,13_414131+54380A+D5B073,76_1F1A16,0;BD9067",
		title = 0,
		female = false,
		lookAtPlayer = true,
		interactive = true,
		onAction = function(self, player)
			addDialogueBox(5, translate("COLE_DIALOGUES", player.language, 2), player.name, "Cole", "180d8434702.png")
		end
	}

	Entity.entities.marc = {
		displayName = "Marc",
		look = "194;0,0,0,0,0,0,0,0,0",
		title = 0,
		female = false,
		lookAtPlayer = true,
		interactive = true,
		onAction = function(self, player)
			addDialogueBox(6, translate("MARC_DIALOGUES", player.language, 1), player.name, "Marc", marc.angry)
		end
	}

	Entity.entities.saruman = {
		displayName = "Saruman",
		look = "158;112,8,0,57_FFFFFF+2E483E,43_2E483E+456458+456458,0,54_74534D+160C2B+0+675548+56413D+D8D5D2+D4BDA5+635043,13,59",
		title = 0,
		female = false,
		lookAtPlayer = true,
		interactive = true,
		onAction = function(self, player)
			local qProgress = player.questProgress
			if qProgress.spiritOrbs.stage == 2 then
				addDialogueSeries(player.name, 7, {
					{ text = translate("SARUMAN_DIALOGUES", player.language, 2), icon = saruman.exclamation },
					{ text = translate("SARUMAN_DIALOGUES", player.language, 3), icon = saruman.normal },
					{ text = translate("SARUMAN_DIALOGUES", player.language, 4), icon = saruman.happy },
					{ text = translate("SARUMAN_DIALOGUES", player.language, 5), icon = saruman.question },
					{ text = translate("SARUMAN_DIALOGUES", player.language, 6), icon = saruman.normal },
					{ text = translate("SARUMAN_DIALOGUES", player.language, 7), icon = saruman.normal },
					{ text = translate("SARUMAN_DIALOGUES", player.language, 8), icon = saruman.normal },
					{ text = translate("SARUMAN_DIALOGUES", player.language, 9), icon = saruman.exclamation },
					{ text = translate("SARUMAN_DIALOGUES", player.language, 10), icon = saruman.normal },
					{ text = translate("SARUMAN_DIALOGUES", player.language, 11), icon = saruman.normal },
					{ text = translate("SARUMAN_DIALOGUES", player.language, 12), icon = saruman.happy },
				}, "Saruman", function(id, name, event)
					-- handle delayed packets/multiple text area callbacks at once
					if qProgress.spiritOrbs.stage == 2 then player:updateQuestProgress("spiritOrbs", 1) end
					local orbs = 0
					for i = 1, 5 do
						if bit.band(player.spiritOrbs, bit.lshift(1, i)) > 0 then
							orbs = orbs + 1
						end
					end
					player:updateQuestProgress("spiritOrbs", orbs)
					dialoguePanel:hide(name)
					player:displayInventory()
				end)
			else
				if player.spiritOrbs == 62 then
					return addDialogueBox(7, translat3e("SARUMAN_DIALOGUES", player.language, 22), player.name, "Saruman", saruman.exclamation)
				end
				addDialogueBox(7, translate("SARUMAN_DIALOGUES", player.language, 13), player.name, "Saruman", saruman.question, {
					{ translate("SARUMAN_QUESTIONS", player.language, 1), addDialogueSeries, { player.name, 7, {
						{ text = translate("SARUMAN_DIALOGUES", player.language, 14), icon = saruman.normal },
						{ text = translate("SARUMAN_DIALOGUES", player.language, 15), icon = saruman.normal },
						{ text = translate("SARUMAN_DIALOGUES", player.language, 16), icon = saruman.happy },
						{ text = translate("SARUMAN_DIALOGUES", player.language, 17), icon = saruman.normal },
						{ text = translate("SARUMAN_DIALOGUES", player.language, 18), icon = saruman.normal },
						{ text = translate("SARUMAN_DIALOGUES", player.language, 19), icon = saruman.normal },
						{ text = translate("SARUMAN_DIALOGUES", player.language, 20), icon = saruman.happy },
					}, "Saruman", function(id, name, event)
						dialoguePanel:hide(name)
						player:displayInventory()
					end}},
					{ translate("SARUMAN_QUESTIONS", player.language, 2), addDialogueBox, { 7, translate("SARUMAN_DIALOGUES", player.language, 21), player.name, "Saruman", saruman.happy } }
				})
			end
		end
	}

end
