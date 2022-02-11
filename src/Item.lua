local Item = {}
Item.items = {}

Item.__index = Item
Item.__tostring = function(self)
	return table.tostring(self)
end

setmetatable(Item, {
	__call = function (cls, ...)
		return cls.new(...)
	end,
})

Item.types = {
	RESOURCE	= 1,
	AXE			= 2,
	SPECIAL 	= 100
}


function Item.new(id, type, stackable, locales, description_locales, attrs)
	local self = setmetatable({}, Item)
	self.id = id
	self.type = type
	self.stackable = stackable
	self.locales = locales
	self.description_locales = description_locales or {}

	if type ~= Item.types.RESOURCE and type ~= Item.types.SPECIAL then
		-- basic settings for most of the basic tools
		self.durability = 10
		self.attack = 1
		self.chopping = 1
		self.mining = 0
		self.tier = 1
	end

	attrs = attrs or {}
	for k, v in next, attrs do
		self[k] = v
	end

	Item.items[id] = self
	return self
end

function Item:getItem()
	if self.type == Item.types.RESOURCE then return self end
	return table.copy(self)
end

-- Setting up the items
Item("stick", Item.types.RESOURCE, true, {
	en = "Stick"
})

Item("stone", Item.types.RESOURCE, true, {
	en = "Stone"
})

Item("wood", Item.types.RESOURCE, true, {
	en = "Wood"
})

-- Special items
Item("basic_axe", Item.types.AXE, false, {
	en = "Basic axe"
}, {
	en = "Just a basic axe"
}, {
	durability = 10,
	chopping = 1
})