local Trigger = {}

Trigger.__index = Trigger
Trigger.__tostring = function(self)
	return table.tostring(self)
end


setmetatable(Trigger, {
	__call = function (cls, ...)
		return cls.new(...)
	end,
})

Trigger.triggers = {

	monster_spawn = {
		onactivate = function(self)
			Monster.new({ health = 20, species = Monster.all.mutant_rat }, self)
		end,
		ontick = function(self)
			for _, monster in next, self.monsters do
				if monster then monster:action() end
			end
			if (math.random(1, 1000) > (#self.monsters == 0 and 200 or 990)) then
				--Monster.new({ health = 20, species = Monster.all.mutant_rat }, self)
			end
		end,
		ondeactivate = function(self)
			-- to prevent invalid keys to "next"
			local previousMonster
			for i, monster in next, self.monsters do
				if previousMonster then previousMonster:destroy() end
				previousMonster = monster
			end
			if previousMonster then previousMonster:destroy() end
		end
	},

	fiery_dragon = {
		onactivate = function(self)
			Monster.new({ health = 9999, species = Monster.all.fiery_dragon }, self)
		end,
		ontick = function(self)
			print(next(self.monsters))
			for _, monster in next, self.monsters do
				if monster then monster:action() end
			end
		end,
		ondeactivate = function(self)
			next(self.monsters):destroy()
		end
	}

}

function Trigger.new(x, y, type, area, name)
	local self = setmetatable({}, Trigger)
	self.x = x
	self.y = y
	self.type = type
	self.area = area
	self.name = name
	self.id = #area.triggers + 1
	self.monsters = {}
	area.triggers[self.id] = self
	return self
end

function Trigger:activate()
	Trigger.triggers[self.type].onactivate(self)
	local ontick = Trigger.triggers[self.type].ontick
	Timer("trigger_" .. self.id, ontick, 500, true, self)
end

function Trigger:deactivate()
	Trigger.triggers[self.type].ondeactivate(self)
	Timer._timers["trigger_" .. self.id]:kill()
end
