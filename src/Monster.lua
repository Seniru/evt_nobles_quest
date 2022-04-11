local Monster = {}
Monster.monsters = {}

Monster.__index = Monster
Monster.__tostring = function(self)
	return table.tostring(self)
end
Monster.__type = "monster"

setmetatable(Monster, {
	__call = function (cls, ...)
		return cls.new(...)
	end,
})

Monster.all = {
	mutant_rat = {}
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
	monsters.mutant_rat.attacks = {
		primary = function(self, target)
			target.health = target.health - 2.5
		end,
		secondary = function(self, target)

		end
	}

end


function Monster.new(metadata, spawnPoint)
	local self = setmetatable({}, Monster)
	local id = #Monster.monsters + 1
	self.id = id
	self.spawnPoint = spawnPoint
	self.x = spawnPoint.x
	self.y = spawnPoint.y
	self.area = spawnPoint.area
	self.species = metadata.species
	self.health = metadata.health or metadata.species.health
	self.metadata = metadata
	self.stance = -1 -- left
	self.decisionMakeCooldown = os.time()
	self.latestActionCooldown = os.time()
	self.latestActionReceived = os.time()
	self.lastAction = "move"
	self.objId = tfm.exec.addShamanObject(10, self.x, self.y)
	local imageData = self.species.sprites.idle_left
	self.imageId = tfm.exec.addImage(imageData.id, "#" .. self.objId, imageData.xAdj, imageData.yAdj, nil)
	tfm.exec.moveObject(self.objId, 0, 0, true, -20, -20, false, 0, true)
	Monster.monsters[id] = self
	self.area.monsters[id] = self
	return self
end

function Monster:action()
	if self.latestActionCooldown > os.time() then return end
	local obj = tfm.get.room.objectList[self.objId]
	self.x, self.y = obj.x, obj.y
	-- monsters are not fast enough to calculate new actions, in other words dumb
	-- if somebody couldn't get past these monsters, I call them noob
	if self.decisionMakeCooldown > os.time() then
		self:changeStance(self.stance)
		if self.lastAction == "move" then
			-- keep moving to the same direction till the monster realized he did a bad move
			tfm.exec.moveObject(self.objId, 0, 0, true, self.stance * 20, -20, false, 0, true)

		end
	else
		-- calculate the best move
		local lDists, lPlayers, lScore, rDists, rPlayers, rScore = {}, {}, 0, {}, {}, 0
		for name in next, self.area.players do
			local player = tfm.get.room.playerList[name]
			local dist = math.pythag(self.x, self.y, player.x, player.y)
			if dist <= 300 then
				if player.x < self.x  then -- player is to left
					lDists[#lDists + 1] = dist
					lPlayers[dist] = name
					lScore = lScore + 310 - dist
				else
					rDists[#rDists + 1] = dist
					rPlayers[dist] = name
					rScore = rScore + 310 - dist
				end
			end
		end
		table.sort(lDists)
		table.sort(rDists)

		if self.stance == -1 then -- left side
			local normalScore = lScore / math.max(#lDists, 1)
			if lDists[1] and lDists[1] < 60 then
				self:attack(lPlayers[lDists[1]], "primary")
			elseif rDists[1] and rDists[1] < 60 then
				-- if there are players to right, turn right and attack
				self:changeStance(1)
				self:attack(rPlayers[rDists[1]], "primary")
			elseif normalScore > 100 then
				self:move()
			elseif normalScore > 10 then
				self:attack(lPlayers[lDists[math.random(#lDists)]], "secondary")
			elseif lScore > rScore then
				self:move()
			else
				-- turn to right side and move
				self:changeStance(1)
				self:move()
			end
		else --right side
			local normalScore = rScore / math.max(#rDists, 1)
			if rDists[1] and rDists[1] < 60 then
				self:attack(rPlayers[rDists[1]], "primary")
			elseif lDists[1] and lDists[1] < 60 then
				-- if there are players to left, turn left and attack
				self:changeStance(-1)
				self:attack(lPlayers[lDists[1]], "primary")
			elseif normalScore > 100 then
				self:move()
			elseif normalScore > 10 then
				self:attack(rPlayers[rDists[math.random(#rDists)]], "secondary")
			elseif lScore < rScore then
				self:move()
			else
				-- turn left and move
				self:changeStance(-1)
				self:move()
			end
		end
		self.decisionMakeCooldown = os.time() + 1500
	end
	self.latestActionCooldown = os.time() + 1000
end

function Monster:changeStance(stance)
	self.stance = stance
	tfm.exec.removeImage(self.imageId)
	local imageData = self.species.sprites[stance == -1 and "idle_left" or "idle_right"]
	self.imageId = tfm.exec.addImage(imageData.id, "#" .. self.objId, imageData.xAdj, imageData.yAdj, nil)
end

function Monster:attack(player, attackType)
	local playerObj = Player.players[player]
	self.lastAction = "attack"
	self.species.attacks[attackType](self, playerObj)
	tfm.exec.removeImage(self.imageId)
	local imageData = self.species.sprites[attackType .. "_attack_" .. (self.stance == -1 and "left" or "right")]
	self.imageId = tfm.exec.addImage(imageData.id, "#" .. self.objId, imageData.xAdj, imageData.yAdj, nil)
	if playerObj.health < 0 then
		playerObj:destroy()
	end
	displayDamage(playerObj)
end

function Monster:move()
	tfm.exec.moveObject(self.objId, 0, 0, true, self.stance * 20, -20, false, 0, true)
	if self.lastAction ~= "move" then
		tfm.exec.removeImage(self.imageId)
		local imageData = self.species.sprites[self.stance == -1 and "idle_left" or "idle_right"]
		self.imageId = tfm.exec.addImage(imageData.id, "#" .. self.objId, imageData.xAdj, imageData.yAdj, nil)
	end
	self.lastAction = "move"
end

function Monster:regen()
	local healthCurr, healthOriginal = self.health, self.metadata.health
	if healthCurr < healthOriginal then
		local regenAmount = math.floor(os.time() - self.latestActionReceived) / 6000
		self.health = math.min(healthOriginal, healthCurr + regenAmount)
	end
end

function Monster:destroy(destroyedBy)
	if destroyedBy then
		local qProgress = destroyedBy.questProgress
		if destroyedBy.area == 2 and qProgress.strength_test and qProgress.strength_test.stage == 2 then
			destroyedBy:updateQuestProgress("strength_test", 1)
		end
	end
	tfm.exec.removeObject(self.objId)
	Monster.monsters[self.id] = nil
	self.area.monsters[self.id] = nil
	self = nil
end

