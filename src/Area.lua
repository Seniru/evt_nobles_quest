local Area = {}
Area.areas = {}

Area.__index = Area
Area.__tostring = function(self)
	return table.tostring(self)
end

setmetatable(Area, {
	__call = function (cls, ...)
		return cls.new(...)
	end,
})

function Area.new(x, y, w, h)
	local self = setmetatable({}, Area)
	self.id = #Area.areas + 1
	self.x = tonumber(x)
	self.y = tonumber(y)
	self.w = tonumber(w)
	self.h = tonumber(h)
	self.x = self.x - self.w / 2
	self.y = self.y - self.h / 2
	self.isTriggered = false
	self.playerCount = 0
	self.players = {}
	self.triggers = {}
	self.entities = {}
	self.monsters = {}
	Area.areas[#Area.areas + 1] = self
	return self
end

function Area.getAreaByCoords(x, y)
	for id, area in next, Area.areas do
		if x >= area.x and x <= area.x + area.w and y >= area.y and y <= area.y + area.h then
			return area
		end
	end
end

function Area:getClosestEntityTo(x, y)
	local min, closest = 1/0, nil
	for id, obj in next, self.entities do
		local dist = math.pythag(x, y, obj.x, obj.y)
		if dist <= 40 and dist < min then
			min = dist
			closest = obj
		end
	end
	return closest
end

function Area:getClosestMonsterTo(x, y)
	local min, closest = 1/0, nil
	local objList = tfm.get.room.objectList
	for id, monster in next, self.monsters do
		local obj =  (monster.species == Monster.all.fiery_dragon or monster.species == Monster.all.final_boss) and { x = monster.realX or monster.x, y = monster.y } or tfm.get.room.objectList[monster.objId]
		local dist = math.pythag(x, y, obj.x, obj.y)
		if dist <= 60 and dist < min then
			min = dist
			closest = monster
		end
	end
	return closest
end


function Area:onNewPlayer(player)
	self.players[player.name] = true
	self.playerCount = self.playerCount + 1
	if not self.isTriggered then
		self.isTriggered = true
		for _, trigger in next, self.triggers do
			trigger:activate()
		end
	end

end

function Area:onPlayerLeft(player)
	self.players[player.name] = nil
	self.playerCount = self.playerCount - 1
	if self.playerCount == 0 then
		for _, trigger in next, self.triggers do
			trigger:deactivate()
		end
		self.isTriggered = false
	end
end
