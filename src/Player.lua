local Player = {}

Player.players = {}
Player.alive = {}
Player.playerCount = 0
Player.aliveCount = 0

Player.__index = Player
Player.__tostring = function(self)
	return table.tostring(self)
end

setmetatable(Player, {
	__call = function (cls, name)
		return cls.new(name)
	end,
})

function Player.new(name)
	local self = setmetatable({}, Player)

	self.name = name
	self.area = nil

	Player.players[name] = self
	Player.playerCount = Player.playerCount + 1

	return self
end

function Player:setArea(x, y)
	local area = Area.getAreaByCoords(x, y)
	if area then
		if not self.area then
			self.area = area.id
		else
			Area.areas[self.area].players[self.name] = nil
			Area.areas[area.id].players[self.name] = true
			self.area = area.id
		end
	end
end


function Player:savePlayerData()
	local name = self.name
	system.savePlayerData(name, "v2" .. dHandler:dumpPlayer(name))
end