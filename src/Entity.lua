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

}

function Entity.new(x, y, type, area)
	local self = setmetatable({}, Entity)
	self.x = x
	self.y = y
	self.type = type
	self.area = area
	area.entities[#area.entities + 1] = self
	return self
end

function Entity:receiveAction(player)
	Entity.entities[self.type].onAction(self, player)
end
