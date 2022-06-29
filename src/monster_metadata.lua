Monster.all = {
	mutant_rat = {},
	the_rock = {},
	snail = {},
	fiery_dragon = {},
	final_boss = {}
}

do
	local monsters = Monster.all

	monsters.mutant_rat.sprites = {
		idle_left = {
			id = "18012c3631a.png",
			xAdj = -30,
			yAdj = -30,
		},
		idle_right = {
			id = "18012d4d75e.png",
			xAdj = -30,
			yAdj = -30,
		},
		primary_attack_left = {
			id = "180192208f0.png",
			xAdj = -30,
			yAdj = -43,
		},
		primary_attack_right = {
			id = "18019222e6a.png",
			xAdj = -45,
			yAdj = -43
		},
		secondary_attack_left = {
			id = "180192b8289.png",
			xAdj = -30,
			yAdj = -35
		},
		secondary_attack_right = {
			id = "180192ba692.png",
			xAdj = -45,
			yAdj = -35
		},
		dead_left = {
			id = "180193395b8.png",
			xAdj = -35,
			yAdj = -18
		},
		dead_right = {
			id = "1801933c6e6.png",
			xAdj = -40,
			yAdj = -18
		}
	}

	monsters.mutant_rat.spawn = function(self)
		self.objId = tfm.exec.addShamanObject(10, self.x, self.y)
		local imageData = self.species.sprites.idle_left
		self.imageId = tfm.exec.addImage(imageData.id, "#" .. self.objId, imageData.xAdj, imageData.yAdj, nil)
		tfm.exec.moveObject(self.objId, 0, 0, true, -20, -20, false, 0, true)
	end
	monsters.mutant_rat.move = function(self)
		tfm.exec.moveObject(self.objId, 0, 0, true, self.stance * 20, -20, false, 0, true)
		if self.lastAction ~= "move" then
			tfm.exec.removeImage(self.imageId)
			local imageData = self.species.sprites[self.stance == -1 and "idle_left" or "idle_right"]
			self.imageId = tfm.exec.addImage(imageData.id, "#" .. self.objId, imageData.xAdj, imageData.yAdj, nil)
		end
	end
	monsters.mutant_rat.attacks = {
		primary = function(self, target)
			target.health = target.health - 3
		end,
		secondary = function(self, target)
			local id = #projectiles + 1
			local projectile = tfm.exec.addPhysicObject(12000 + id, self.x, self.y - 5, {
				type = 2,
				width = 10,
				height = 10,
				friction = 2,
				contactListener = true,
				dynamic = true,
				groundCollision = false
			})
			local player = tfm.get.room.playerList[target.name]
			local vx, vy = getVelocity(player.x, self.x, player.y, self.y - 5, 3)
			tfm.exec.movePhysicObject(12000 + id, 0, 0, false, vx, -vy)
			local imgId = tfm.exec.addImage(assets.stone, "+" .. (12000 + id), -5, -5)
			projectiles[id] = { 1, false }
			Timer.new("projectile_" .. id, tfm.exec.removePhysicObject, 5000, false, 1200 + id)
		end
	}

	monsters.the_rock.sprites = {
		idle_left = {
			id = "180989fbe7d.png",
			xAdj = -27,
			yAdj = -20,
		},
		idle_right = {
			id = "18098a542e3.png",
			xAdj = -27,
			yAdj = -20,
		},
		primary_attack_left = {
			id = "18098ad201c.png",
			xAdj = -36,
			yAdj = -18,
		},
		primary_attack_right = {
			id = "18098ae95b3.png",
			xAdj = -33,
			yAdj = -18
		},
		secondary_attack_left = {
			id = "180989fbe7d.png",
			xAdj = -27,
			yAdj = -20,
		},
		secondary_attack_right = {
			id = "18098a542e3.png",
			xAdj = -27,
			yAdj = -20,
		},
		dead_left = {
			id = "180ec2c3204.png",
			xAdj = -27,
			yAdj = -20,
		},
		dead_right = {
			id = "180ec2d589a.png",
			xAdj = -27,
			yAdj = -20,
		}
	}
	monsters.the_rock.spawn = function(self)
		self.objId = tfm.exec.addShamanObject(10, self.x, self.y)
		local imageData = self.species.sprites.idle_left
		self.imageId = tfm.exec.addImage(imageData.id, "#" .. self.objId, imageData.xAdj, imageData.yAdj, nil)
		tfm.exec.moveObject(self.objId, 0, 0, true, -20, -20, false, 0, true)
	end
	monsters.the_rock.move = function(self)
		tfm.exec.moveObject(self.objId, 0, 0, true, self.stance * 20, -20, false, 0, true)
		if self.lastAction ~= "move" then
			tfm.exec.removeImage(self.imageId)
			local imageData = self.species.sprites[self.stance == -1 and "idle_left" or "idle_right"]
			self.imageId = tfm.exec.addImage(imageData.id, "#" .. self.objId, imageData.xAdj, imageData.yAdj, nil)
		end
	end
	monsters.the_rock.attacks = {
		primary = function(self, target)
			target.health = target.health - 7
		end,
		secondary = function(self, target)
			self:changeStance(self.stance * -1)
			self:move()
		end
	}

	monsters.snail.sprites = {
		idle_left = {
			id = "1809debd5c6.png",
			xAdj = -28,
			yAdj = -20,
		},
		idle_right = {
			id = "1809dee97e2.png",
			xAdj = -30,
			yAdj = -20,
		},
		primary_attack_left = {
			id = "1809df1bc2e.png",
			xAdj = -28,
			yAdj = -20,
		},
		primary_attack_right = {
			id = "1809df30ef7.png",
			xAdj = -28,
			yAdj = -20
		},
		secondary_attack_left = {
			id = "1809df1bc2e.png",
			xAdj = -28,
			yAdj = -20,
		},
		secondary_attack_right = {
			id = "1809df30ef7.png",
			xAdj = -28,
			yAdj = -20
		},
		dead_left = {
			id = "180ec41d099.png",
			xAdj = -35,
			yAdj = -16
		},
		dead_right = {
			id = "180ec41ef3e.png",
			xAdj = -35,
			yAdj = -16
		}
	}
	monsters.snail.spawn = function(self)
		self.objId = tfm.exec.addShamanObject(10, self.x, self.y)
		local imageData = self.species.sprites.idle_left
		self.imageId = tfm.exec.addImage(imageData.id, "#" .. self.objId, imageData.xAdj, imageData.yAdj, nil)
		tfm.exec.moveObject(self.objId, 0, 0, true, -20, -20, false, 0, true)
	end
	monsters.snail.move = function(self)
		tfm.exec.moveObject(self.objId, 0, 0, true, self.stance * 20, -20, false, 0, true)
		if self.lastAction ~= "move" then
			tfm.exec.removeImage(self.imageId)
			local imageData = self.species.sprites[self.stance == -1 and "idle_left" or "idle_right"]
			self.imageId = tfm.exec.addImage(imageData.id, "#" .. self.objId, imageData.xAdj, imageData.yAdj, nil)
		end
	end

	local snailAttack = function(self, target)
		local id = #projectiles + 1
			local projectile = tfm.exec.addPhysicObject(12000 + id, self.x, self.y - 5, {
				type = 2,
				width = 30,
				height = 10,
				friction = 2,
				contactListener = true,
				dynamic = true,
				groundCollision = false,
				mass = 0.0002
			})
			local player = tfm.get.room.playerList[target.name]
			local vx, vy = 120 * self.stance, 20
			tfm.exec.movePhysicObject(12000 + id, 0, 0, false, vx, -vy)
			local imgId = tfm.exec.addImage(assets.spit, "+" .. (12000 + id), -15, -5)
			projectiles[id] = { 0, true, 1000, { assets.goo, "$" .. target.name, -15, -10 } }
			Timer.new("projectile_" .. id, tfm.exec.removePhysicObject, 5000, false, 1200 + id)
	end
	monsters.snail.attacks = {
		primary = snailAttack,
		secondary = snailAttack
	}



	monsters.fiery_dragon.sprites = {
		idle_left = {
			id = "1809dfcd636.png",
			xAdj = -200,
			yAdj = -110,
		},
		idle_right = {
			id = "1809dfcd636.png",
			xAdj = -200,
			yAdj = -110,
		},
		primary_attack_left = {
			id = "180a2a35e91.png",
			xAdj = -235,
			yAdj = -120,
		},
		primary_attack_right = {
			id = "180a2a35e91.png",
			xAdj = -235,
			yAdj = -120,
		},

		secondary_attack_left = {
			id = "180a34985f3.png",
			xAdj = -200,
			yAdj = -130,
		},
		secondary_attack_right = {
			id = "180a34985f3.png",
			xAdj = -200,
			yAdj = -130,
		},
		throw_animation = {
			id = "180a34763fa.png",
			xAdj = -205,
			yAdj = -120
		},
		dead_left = {
			id = "180ea8a13f4.png",
			xAdj = -180,
			yAdj = -120
		},
		dead_right = {
			id = "180ea8a13f4.png",
			xAdj = -180,
			yAdj = -120
		}
	}

	local dragonLocationCheck = function(self)
		self.wait = self.wait - 1
		local dragX = math.min(self.realX, tfm.get.room.objectList[self.objId] and (tfm.get.room.objectList[self.objId].x - self.w) - 30 or self.realX)
		self.realX = dragX
		--ui.addTextArea(34289, "x",nil, self.realX, self.y, 10,10, nil, nil, 1, false)
		if dragX < 700 then
			return self:destroy()
		end
		if self.wait < 0 then
			tfm.exec.removeObject(self.objId)
			self.objId = tfm.exec.addShamanObject(62, self.realX + self.w + 120, self.y, 180, -50, 0, false)
			tfm.exec.addImage("no.png", "#" .. self.objId, 0, 0)
			self.wait = 1
		end
		local entityBridge
		for i, e in next, self.area.entities do
			if e.type == "bridge" then
				entityBridge = e
				break
			end
		end
		local toRemove = {}
		for i, bridge in next, (entityBridge.bridges or {}) do
			if math.abs(bridge[2] - (560 / 8) - dragX) < 60 and not (entityBridge.bridges[i + 1] and #entityBridge.bridges[i + 1] > 0) then
				tfm.exec.removePhysicObject(bridge[1])
				toRemove[#toRemove + 1] = i
				--entityBridge.bridges[i] = nil
			end
		end
		for i, j in next, toRemove do
			tfm.exec.removePhysicObject(entityBridge.bridges[j][1])
			tfm.exec.removeImage(entityBridge.bridges[j][4])
			entityBridge.bridges[j] = nil
		end
	end

	monsters.fiery_dragon.spawn = function(self)
		--TODO: do not spawn if has been spawmed already
		self.wait = 0
		self.visibilityRange = 3400
		self.objId = 999999
		self.bodyId = 200
		self.w = 200
		tfm.exec.addPhysicObject(self.bodyId, self.x, self.y - 80, {
			type = 1,
			width = self.w,
			height = 170,
			dynamic = true,
			friction = 30,
			mass = 9999,
			fixedRotation = true,
			linearDamping = 999
		})
		self.y = self.y + 20
		self.realX = self.x - self.w
		local imageData = self.species.sprites.idle_left
		tfm.exec.addImage(imageData.id, "+" .. self.bodyId, imageData.xAdj, imageData.yAdj, nil)
		self.imageId = imageData
	end
	monsters.fiery_dragon.move = function(self)
		dragonLocationCheck(self)
		tfm.exec.movePhysicObject(200, 0, 0, false, -25, -30)
		local imageData = self.species.sprites.idle_left
		if imageData ~= self.imageId then
			tfm.exec.addImage(imageData.id, "+" .. self.bodyId, imageData.xAdj, imageData.yAdj, nil)
		end
		self.imageId = imageData
	end
	monsters.fiery_dragon.attacks = {
		primary = function(self, target)
			--tfm.exec.removeImage(self.imageId)
			dragonLocationCheck(self)
			local imageData = self.species.sprites.primary_attack_left
			if imageData ~= self.imageId then
				tfm.exec.addImage(imageData.id, "+" .. self.bodyId, imageData.xAdj, imageData.yAdj, nil)
			end
			self.imageId = imageData
			self.latestActionCooldown = os.time() + 3000
			-- attack all the players nearby to the target
			local player = tfm.get.room.playerList[target.name]
			local x1, y1 = player.x, player.y
			for name in next, self.area.players do
				local playerOther = tfm.get.room.playerList[name]
				if math.pythag(x1, y1, playerOther.x, playerOther.y) <= 50 then
					local playerOtherObject = Player.players[name]
					playerOtherObject.health = playerOtherObject.health - 15
					displayDamage(playerOtherObject)
				end
			end
		end,
		secondary = function(self, target)
			dragonLocationCheck(self)
			local imageData = self.species.sprites.secondary_attack_left
			tfm.exec.addImage(imageData.id, "+" .. self.bodyId, imageData.xAdj, imageData.yAdj, nil)
			local id = #projectiles + 1
			local projectile = tfm.exec.addPhysicObject(12000 + id, self.realX - 15, self.y + 15, {
				type = 1,
				width = 30,
				height = 30,
				friction = 2,
				contactListener = true,
				dynamic = true,
				groundCollision = false
			})
			tfm.exec.addImage(assets.rock, "+" .. (12000 + id), -30, -35, nil)
			local player = tfm.get.room.playerList[target.name]
			tfm.exec.movePhysicObject(12000 + id, 0, 0, false, 0, -60)
			--local imgId = tfm.exec.addImage(assets.stone, "+" .. (12000 + id), -5, -5)
			Timer.new("projectile_" .. id, tfm.exec.removePhysicObject, 5000, false, 1200 + id)
			Timer.new("rock_throw", function()
				local imgData = self.species.sprites.throw_animation
				tfm.exec.addImage(imgData.id, "+" .. self.bodyId, imgData.xAdj, imgData.yAdj, nil)
				self.imageId = imgData
				local vx, vy = getVelocity(player.x, self.realX - 15, player.y, self.y - 15, 3)
				tfm.exec.movePhysicObject(12000 + id, 0, 0, false, 0, 0)
				tfm.exec.movePhysicObject(12000 + id, 0, 0, false, vx, -vy)
				projectiles[id] = { 10, true, 2500 }
			end, 1000, false, id)
			self.latestActionCooldown = os.time() + 5000
		end
	}
	monsters.fiery_dragon.death = function(self, killedBy)
		local imageData = self.species.sprites.dead_left
		local image = tfm.exec.addImage(imageData.id, "+" .. self.bodyId, imageData.xAdj, imageData.yAdj, nil)
		Timer.new("clear_body_drag", tfm.exec.removeImage, 2000, false, image, true)
	end

	monsters.final_boss.sprites = {
		idle_left = {
			id = "180c7398a1f.png",
			xAdj = -280,
			yAdj = -150,
		},
		idle_right = {
			id = "180c7398a1f.png",
			xAdj = -280,
			yAdj = -150,
		},
		primary_attack_left = {
			id = "180c7386662.png",
			xAdj = -230,
			yAdj = -150,
		},
		primary_attack_right = {
			id = "180c7386662.png",
			xAdj = -230,
			yAdj = -150,
		},
		secondary_attack_left = {
			id = "180c739b495.png",
			xAdj = -230,
			yAdj = -150,
		},
		secondary_attack_right = {
			id = "180c739b495.png",
			xAdj = -230,
			yAdj = -150,
		},
		dead_left = {
			id = "180ec62d464.png",
			xAdj = -280,
			yAdj = -150,
		},
		dead_right = {
			id = "1809dfcd636.png",
			xAdj = -280,
			yAdj = -150,
		}
	}

	local final_boss_secondaries = function(boss)
		local spawnRarities = {1 ,1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 3, 3, 3 }
		local choice = math.random(1, 10)
		if choice == 1 then
			local imageData = boss.species.sprites.secondary_attack_left
			tfm.exec.addImage(imageData.id, "+" .. boss.objId, imageData.xAdj, imageData.yAdj, nil)
			for name in next, boss.area.players do
				local playerOtherObject = Player.players[name]
				playerOtherObject.health = playerOtherObject.health - (playerOtherObject.divinePower and 3 or 20)
				displayDamage(playerOtherObject)
			end

			local laser = tfm.exec.addImage(assets.laser, "!1", 250, 4695)
			Timer.new("laser_remove" .. laser, tfm.exec.removeImage, 500, false, laser)
		elseif choice > 9 then
			local imageData = boss.species.sprites.secondary_attack_left
			tfm.exec.addImage(imageData.id, "+" .. boss.objId, imageData.xAdj, imageData.yAdj, nil)
			local monster = Monster.new({ health = 20, species = Monster.all[({"mutant_rat", "snail", "the_rock"})[spawnRarities[math.random(#spawnRarities)]]] }, boss.spawnPoint.area.triggers[2])
			monster:changeStance(1)
		end
	end
	monsters.final_boss.spawn = function(self)
		self.objId = 300
		self.visibilityRange = 700
		tfm.exec.addPhysicObject(self.objId, self.x, self.y - 80, {
			type = 1,
			width = 400,
			height = 250,
			dynamic = true,
			friction = 0,
			mass = 9999
		})
		self.x = self.x - 250
		self.y = 4850
		local imageData = self.species.sprites.idle_left
		self.imageId = tfm.exec.addImage(imageData.id, "+" .. self.objId, imageData.xAdj, imageData.yAdj, nil)
	end
	monsters.final_boss.move = final_boss_secondaries
	monsters.final_boss.attacks = {
		primary = function(self, target)
			target.health = target.health - 30
			local imageData = self.species.sprites.primary_attack_left
			tfm.exec.addImage(imageData.id, "+" .. self.objId, imageData.xAdj, imageData.yAdj, nil)
		end,
		secondary = final_boss_secondaries
	}
	monsters.final_boss.death = function(self, killedBy)
		for name in next, boss.area.players do
			local player = Player.players[name]
			player:updateQuestProgress("final_boss", 1)
		end
	end

end