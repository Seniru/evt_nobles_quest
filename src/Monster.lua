local Monster = {}
Monster.monsters = {}

Monster.__index = Monster
Monster.__tostring = function(self)
	return table.tostring(self)
end

setmetatable(Monster, {
	__call = function (cls, ...)
		return cls.new(...)
	end,
})

function Monster.new(metadata, spawnPoint)
	local self = setmetatable({}, Monster)
	local id = #Monster.monsters + 1
	self.id = id
	self.spawnPoint = spawnPoint
	self.x = spawnPoint.x
	self.y = spawnPoint.y
	p({self.x, self.y})
	self.area = spawnPoint.area
	self.health = metadata.health
	self.metadata = metadata
	self.stance = -1 -- right
	self.decisionMakeCooldown = os.time()
	self.lastAction = "move"
	self.objId = tfm.exec.addShamanObject(10, self.x, self.y)
	tfm.exec.moveObject(self.objId, 0, 0, true, -20, -20, false, 0, true)
	Monster.monsters[id] = self
	self.area.monsters[id] = self
	return self
end

function Monster:action()
	local obj = tfm.get.room.objectList[self.objId]
	self.x, self.y = obj.x, obj.y
	-- monsters are not fast enough to calculate new actions, in other words dumb
	-- if somebody couldn't get past these monsters, I call them noob
	if self.decisionMakeCooldown > os.time() then
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
					lScore = lScore + 300 - dist
				else
					rDists[#rDists + 1] = dist
					rDists[dist] = name
					rScore = rScore + 300 - dist
				end
			end
		end
		table.sort(lDists)
		table.sort(rDists)

		if self.stance == -1 then
			local normalScore = lScore / math.max(#lDists, 1)
			p({"normal score", normalScore})
			if lDists[1] and lDists[1] < 30 then
				self:attack(lPlayers[lDists[1]], "slash")
			elseif rDists[1] and rDists[1] < 30 then
				self:changeStance(1)
				self:attack(rPlayers[rDists[1]], "slash")
			elseif normalScore > 100 then
				self:move()
			elseif normalScore > 10 then
				self:attack(lPlayers[lDists[math.random(#lDists)]], "bullet")
			elseif lScore > rScore then
				self:move()
			else
				self:changeStance(1)
				self:move()
			end
		else
			local normalScore = rScore / math.max(#rDists, 1)
			p({"normal score", normalScore})
			if rDists[1] and rDists[1] < 30 then
				self:attack(rPlayers[rDists[1]], "slash")
			elseif lDists[1] and lDists[1] < 30 then
				self:changeStance(1)
				self:attack(lPlayers[lDists[1]], "slash")
			elseif normalScore > 100 then
				self:move()
			elseif normalScore > 10 then
				self:attack(rPlayers[rDists[math.random(#rDists)]], "bullet")
			elseif lScore < rScore then
				self:move()
			else
				self:changeStance(-1)
				self:move()
			end
		end
		
	end
end

function Monster:changeStance(stance)
	self.stance = stance
end

function Monster:attack(player, attackType)
	p({player, attackType})
	self.lastAction = "attack"
end

function Monster:move()
	tfm.exec.moveObject(self.objId, 0, 0, true, self.stance * 20, -20, false, 0, true)
	self.lastAction = "move"
end

function Monster:destroy()
	tfm.exec.removeObject(self.objId)
	Monster.monsters[self.id] = nil
	self.area.monsters[self.id] = nil
	self = nil
end

