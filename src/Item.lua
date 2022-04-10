local Item = {}
Item.items = { _all = {} }

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
	SHOVEL		= 3,
	SPECIAL 	= 100
}


function Item.new(id, type, stackable, image, locales, description_locales, attrs)
	local self = setmetatable({}, Item)
	self.id = id
	self.nid = #Item.items._all + 1
	self.type = type
	self.stackable = stackable
	self.image = image or "17ff9c560ce.png"
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
	Item.items._all[self.nid] = id
	return self
end

function Item:getItem()
	if self.type == Item.types.RESOURCE then return self end
	return table.copy(self)
end

-- Setting up the items
Item("stick", Item.types.RESOURCE, true, "17ff9c560ce.png", {
	en = "Stick"
})

Item("stone", Item.types.RESOURCE, true, nil, {
	en = "Stone"
})

Item("iron_ore", Item.types.RESOURCE, true, nil, {
	en = "Iron ore"
})

Item("wood", Item.types.RESOURCE, true, nil, {
	en = "Wood"
})

-- Special items
Item("basic_axe", Item.types.AXE, false, nil, {
	en = "Basic axe"
}, {
	en = "Just a basic axe"
}, {
	durability = 10,
	chopping = 1
})

Item("basic_shovel", Item.types.SHOVEL, nil, false, {
	en = "Basic shovel"
}, {
	en = "Evolution started here"
}, {
	durability = 10,
	mining = 3
})