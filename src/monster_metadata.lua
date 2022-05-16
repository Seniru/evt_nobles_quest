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
			yAdj = -35,
		},
		primary_attack_right = {
			id = "18019222e6a.png",
			xAdj = -45,
			yAdj = -35
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
			yAdj = -30
		},
		dead_right = {
			id = "1801933c6e6.png",
			xAdj = -40,
			yAdj = -30
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
			yAdj = -25,
		},
		idle_right = {
			id = "18098a542e3.png",
			xAdj = -27,
			yAdj = -25,
		},
		primary_attack_left = {
			id = "18098ad201c.png",
			xAdj = -33,
			yAdj = -20,
		},
		primary_attack_right = {
			id = "18098ae95b3.png",
			xAdj = -33,
			yAdj = -20
		},
		secondary_attack_left = {
			id = "180989fbe7d.png",
			xAdj = -27,
			yAdj = -25,
		},
		secondary_attack_right = {
			id = "18098a542e3.png",
			xAdj = -27,
			yAdj = -25,
		},
		dead_left = {
			id = "180193395b8.png",
			xAdj = -35,
			yAdj = -30
		},
		dead_right = {
			id = "1801933c6e6.png",
			xAdj = -40,
			yAdj = -30
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
			yAdj = -22,
		},
		idle_right = {
			id = "1809dee97e2.png",
			xAdj = -30,
			yAdj = -22,
		},
		primary_attack_left = {
			id = "1809df1bc2e.png",
			xAdj = -28,
			yAdj = -23,
		},
		primary_attack_right = {
			id = "1809df30ef7.png",
			xAdj = -28,
			yAdj = -23
		},
		secondary_attack_left = {
			id = "1809df1bc2e.png",
			xAdj = -28,
			yAdj = -23,
		},
		secondary_attack_right = {
			id = "1809df30ef7.png",
			xAdj = -28,
			yAdj = -23
		},
		dead_left = {
			id = "180193395b8.png",
			xAdj = -35,
			yAdj = -30
		},
		dead_right = {
			id = "1801933c6e6.png",
			xAdj = -40,
			yAdj = -30
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
				groundCollision = false
			})
			local player = tfm.get.room.playerList[target.name]
			local vx, vy = getVelocity(player.x, self.x, player.y, self.y - 5, 3)
			tfm.exec.movePhysicObject(12000 + id, 0, 0, false, vx, -vy)
			local imgId = tfm.exec.addImage(assets.spit, "+" .. (12000 + id), -15, -5)
			projectiles[id] = { 0, true, 1000 }
			Timer.new("projectile_" .. id, tfm.exec.removePhysicObject, 5000, false, 1200 + id)
	end
	monsters.snail.attacks = {
		primary = snailAttack,
		secondary = snailAttack
	}



	monsters.fiery_dragon.sprites = {
		-- copy left-side content to right side content instead of relying on wrong images
		idle_left = {
			id = "1809dfcd636.png",
			xAdj = -200,
			yAdj = -100,
		},
		idle_right = {
			id = "1809dfcd636.png",
			xAdj = -30,
			yAdj = -30,
		},
		primary_attack_left = {
			id = "180a2a35e91.png",
			xAdj = -235,
			yAdj = -110,
		},
		primary_attack_right = {
			id = "1809dfcd636.png",
			xAdj = -45,
			yAdj = -35
		},
		secondary_attack_left = {
			id = "180a34985f3.png",
			xAdj = -180,
			yAdj = -100,
		},
		secondary_attack_right = {
			id = "1809dfcd636.png",
			xAdj = -135,
			yAdj = -120
		},
		throw_animation = {
			id = "180a34763fa.png",
			xAdj = -135,
			yAdj = -120
		},
		dead_left = {
			id = "1809dfcd636.png",
			xAdj = -35,
			yAdj = -30
		},
		dead_right = {
			id = "1809dfcd636.png",
			xAdj = -40,
			yAdj = -30
		}
	}
	monsters.fiery_dragon.spawn = function(self)
		self.wait = 0
		self.visibilityRange = 2000
		self.objId = 999999
		self.bodyId = 200
		tfm.exec.addPhysicObject(self.bodyId, self.x, self.y - 80, {
			type = 1,
			width = 345,
			height = 185,
			dynamic = true,
			friction = 30,
			mass = 9999,
			fixedRotation = true,
			linearDamping = 999
		})
		self.realX = self.x
		local imageData = self.species.sprites.idle_left
		tfm.exec.addImage(imageData.id, "+" .. self.bodyId, imageData.xAdj, imageData.yAdj, nil)
		self.imageId = imageData
	end
	monsters.fiery_dragon.move = function(self)
		self.wait = self.wait - 1
		local dragX = math.min(self.realX, tfm.get.room.objectList[self.objId] and (tfm.get.room.objectList[self.objId].x - 345) + 10 or self.realX)
		self.realX = dragX
		if self.wait < 0 then
			tfm.exec.removeObject(self.objId)
			self.objId = tfm.exec.addShamanObject(62, self.x + 50, self.y - 50, 180, -100, 0, false)
			tfm.exec.movePhysicObject(200, 0, 0, false, -25, -30)
			self.wait = 3
		end
		local entityBridge
		for i, e in next, self.area.entities do
			if e.type == "bridge" then
				entityBridge = e
				break
			end
		end
		p(entityBridge.bridges)
		for i, bridge in next, (entityBridge.bridges or {}) do
			if math.abs(bridge[2] - dragX) < 50 and not (entityBridge.bridges[i + 1] and #entityBridge.bridges[i + 1] > 0) then
				tfm.exec.removePhysicObject(bridge[1])
				entityBridge.bridges[i] = nil
			end
		end
		local imageData = self.species.sprites.idle_left
		if imageData ~= self.imageId then
			tfm.exec.addImage(imageData.id, "+" .. self.bodyId, imageData.xAdj, imageData.yAdj, nil)
		end
		self.imageId = imageData
	end
	monsters.fiery_dragon.attacks = {
		primary = function(self, target)
			--tfm.exec.removeImage(self.imageId)
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
					playerOtherObject.health = playerOtherObject.health - 1
					displayDamage(playerOtherObject)
				end
			end
		end,
		secondary = function(self, target)
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
			local player = tfm.get.room.playerList[target.name]
			tfm.exec.movePhysicObject(12000 + id, 0, 0, false, 0, -60)
			--local imgId = tfm.exec.addImage(assets.stone, "+" .. (12000 + id), -5, -5)
			Timer.new("projectile_" .. id, tfm.exec.removePhysicObject, 5000, false, 1200 + id)
			Timer.new("rock_throw", function()
				local imgData = self.species.sprites.throw_animation
				tfm.exec.addImage(imgData.id, "+" .. self.bodyId, imgData.xAdj, imgData.yAdj, nil)
				self.imageId = imgData
				ui.addTextArea(3495, "x", nil, self.realX, self.y - 15, 10, 10, nil, nil, 1, false)
				local vx, vy = getVelocity(player.x, self.realX - 15, player.y, self.y - 15, 3)
				tfm.exec.movePhysicObject(12000 + id, 0, 0, false, 0, 0)
				tfm.exec.movePhysicObject(12000 + id, 0, 0, false, vx, -vy)
				projectiles[id] = { 10, true, 2500 }
			end, 1000, false, id)
			self.latestActionCooldown = os.time() + 5000
		end
	}

	monsters.final_boss.sprites = {
		idle_left = {
			id = "180c7398a1f.png",
			xAdj = -230,
			yAdj = -150,
		},
		idle_right = {
			id = "180c7398a1f.png",
			xAdj = -230,
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
			id = "1809dfcd636.png",
			xAdj = -230,
			yAdj = -150,
		},
		dead_right = {
			id = "1809dfcd636.png",
			xAdj = -230,
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
				playerOtherObject.health = playerOtherObject.health - 10
				displayDamage(playerOtherObject)
			end

			local laser = tfm.exec.addImage(assets.laser, "!1", 200, 4646)
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
			friction = 0
		})
		self.x = self.x - 350
		local imageData = self.species.sprites.idle_left
		self.imageId = tfm.exec.addImage(imageData.id, "+" .. self.objId, imageData.xAdj, imageData.yAdj, nil)
	end
	monsters.final_boss.move = final_boss_secondaries
	monsters.final_boss.attacks = {
		primary = function(self, target)
			target.health = target.health - 2.5
			local imageData = self.species.sprites.primary_attack_left
			tfm.exec.addImage(imageData.id, "+" .. self.objId, imageData.xAdj, imageData.yAdj, nil)
		end,
		secondary = final_boss_secondaries
	}
	monsters.final_boss.death = function(self, killedBy)
		print("YOu win")
	end

end