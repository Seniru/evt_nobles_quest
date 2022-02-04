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
	RESOURCE = 1,
	SPECIAL = 100
}


function Item.new(id, type, stackable, locales, description_locales, attrs)
	local self = setmetatable({}, Item)
	self.id = id
	self.type = type
	self.stackable = stackable
	self.locales = locales
	self.description_locales = description_locales or {}

	attrs = attrs or {}
	for k, v in next, attrs do
		self[k] = v
	end

	Item.items[id] = self
	return self
end

-- Setting up the items
Item("stick", Item.types.RESOURCE, true, {
	en = "Stick"
})

Item("stone", Item.types.RESOURCE, true, {
	en = "Stone"
})


-- Special items
Item("basic_axe", Item.types.SPECIAL, false, {
	en = "Basic axe"
})