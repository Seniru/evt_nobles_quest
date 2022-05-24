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
	SWORD		= 4,
	SPECIAL 	= 100
}

do

	locale_mt = { __index = function(tbl, k)
		p({tbl, rawget(tbl, k), rawget(tbl, "en")})
		return rawget(tbl, k) or rawget(tbl, "en") or ""
	end }

	desc_locale_mt = { __index = function(tbl, k)
		return rawget(tbl, k) or rawget(tbl, "en") or ""
	end }

	function Item.new(id, type, stackable, image, weight, locales, description_locales, attrs)
		local self = setmetatable({}, Item)
		self.id = id
		self.nid = #Item.items._all + 1
		self.type = type
		self.stackable = stackable
		self.image = image or "17ff9c560ce.png"
		self.weight = weight
		self.locales = setmetatable(locales, locale_mt)
		self.description_locales = setmetatable(description_locales or {}, desc_locale_mt)

		if type ~= Item.types.RESOURCE and type ~= Item.types.SPECIAL then
			-- basic settings for most of the basic tools
			self.durability = 15
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
end

function Item:getItem()
	if self.type == Item.types.RESOURCE then return self end
	return table.copy(self)
end

-- Setting up the items
Item("stick", Item.types.RESOURCE, true, "17ff9c560ce.png", 0.005, {
	en = "Stick"
})

Item("stone", Item.types.RESOURCE, true, "180a896fdf8.png", 0.05, {
	en = "Stone"
}, {
	en = ""
})

Item("clay", Item.types.RESOURCE, true, "180db604121.png", 0.05, {
	en = "Clay"
})

Item("iron_ore", Item.types.RESOURCE, true, nil, 0.08, {
	en = "Iron ore"
})

Item("copper_ore", Item.types.RESOURCE, true, nil, 0.09, {
	en = "Copper ore"
})

Item("gold_ore", Item.types.RESOURCE, true, nil, 0.3, {
	en = "Gold ore"
})

Item("wood", Item.types.RESOURCE, true, "18099c310cd.png", 1, {
	en = "Wood"
})

-- Special items
Item("log_stakes", Item.types.SPECIAL, false, nil, 3.8, {
	en = "Log stakes"
}, {
	en = "One of the most important building blocks in constructions!\nIt can also use as a decoration or just for fire if you have no use of it."
})

Item("bridge", Item.types.SPECIAL, false, nil, 19.5, {
	en = "Bridge"
}, {
	en = "Bridges! Most basic use is accessing the land on the other side of a river, but also is also a great component in city architecuring.\nBut... how are you going to fit a bridge inside your pocket???"
})

Item("basic_axe", Item.types.AXE, false, "180dfe8e723.png", 1, {
	en = "Basic axe"
}, {
	en = "Just a basic axe"
}, {
	durability = 10,
	chopping = 1
})

Item("iron_axe", Item.types.AXE, false, "1801248fac2.png", 1.3, {
	en = "Iron axe"
}, {
	en = "The reinforcement added with iron makes it last twice more than a basic axe!"
}, {
	durability = 20,
	chopping = 1
})

Item("copper_axe", Item.types.AXE, false, "180dfe88be8.png", 1.4, {
	en = "Copper axe"
}, {
	en = "Designed by notable blacksmiths. The edge design makes it much easier to use and sharper!"
}, {
	durability = 20,
	chopping = 2
})

Item("gold_axe", Item.types.AXE, false, "180dfe8aab9.png", 1.5, {
	en = "Golden axe"
}, {
	en = "An axe designed after combining gold and other alloys to make it stronger and more durable.\nI'm not sure if any regular jacksmith uses such an expensive tool though."
}, {
	durability = 30,
	chopping = 3
})


Item("basic_shovel", Item.types.SHOVEL, false, nil, 1, {
	en = "Basic shovel"
}, {
	en = "Dig dig dig"
}, {
	durability = 10,
	mining = 2
})

Item("iron_shovel", Item.types.SHOVEL, false, nil, 1.4, {
	en = "Iron shovel"
}, {
	en = "Evolution started here"
}, {
	durability = 15,
	mining = 3
})

Item("copper_shovel", Item.types.SHOVEL, false, nil, 1, {
	en = "Copper shovel"
}, {
	en = "Evolution started here"
}, {
	durability = 10,
	mining = 3
})

Item("gold_shovel", Item.types.SHOVEL, false, nil, 1, {
	en = "Gold shovel"
}, {
	en = "Evolution started here"
}, {
	durability = 20,
	mining = 4
})

Item("basic_sword", Item.types.SWORD, false, nil, 1, {
	en = "Basic sword",
}, {}, {
		attack = 3
	}
)

Item("iron_sword", Item.types.SWORD, false, nil, 1.4, {
	en = "Iron sword",
}, {}, {
	attack = 5,
	durability = 20
	}
)

Item("copper_sword", Item.types.SWORD, false, nil, 1.4, {
	en = "Copper sword",
}, {}, {
		attack = 7,
		durability = 25
	}
)

Item("gold_sword", Item.types.SWORD, false, nil, 1.4, {
	en = "Gold sword",
}, {}, {
		attack = 10,
		durability = 30
	}
)


Item("basic_shield", Item.types.SPECIAL, false, nil, 0.7, {
	en = "Basic shield",
}, {}, {
		defense = 1
	}
)

Item("iron_shield", Item.types.SPECIAL, false, nil, 1, {
	en = "Iron shield",
}, {}, {
		defense = 3
	}
)

Item("copper_shield", Item.types.SPECIAL, false, nil, 1.4, {
	en = "Copper shield",
}, {}, {
	defense = 4
	}
)

Item("gold_shield", Item.types.SPECIAL, false, nil, 2, {
	en = "Gold sword",
}, {}, {
	defense = 6
	}
)