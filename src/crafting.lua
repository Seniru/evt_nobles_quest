recipes = {
	basic_axe = {
		{ Item.items.stick, 5 },
		{ Item.items.stone, 3 }
	},
	iron_axe = {
		{ Item.items.stick, 5 },
		{ Item.items.iron_ore, 4 }
	},
	copper_axe = {
		{ Item.items.stick, 5},
		{ Item.items.iron_ore, 2} ,
		{ Item.items.copper_ore, 3 }
	},
	gold_axe = {
		{ Item.items.stick, 5 },
		{ Item.items.iron_ore, 1 },
		{ Item.items.copper_ore, 2 },
		{ Item.items.gold_ore, 5 }
	},
	basic_shovel = {
		{ Item.items.wood, 5 },
	},
	iron_shovel = {
		{ Item.items.wood, 3 },
		{ Item.items.iron_ore, 4 }
	},
	copper_shovel = {
		{ Item.items.wood, 3 },
		{ Item.items.iron_ore, 2} ,
		{ Item.items.copper_ore, 3 }
	},
	gold_shovel = {
		{ Item.items.wood, 3 },
		{ Item.items.iron_ore, 1 },
		{ Item.items.copper_ore, 2 },
		{ Item.items.gold_ore, 5 }
	},
	iron_sword = {
		{ Item.items.wood, 5},
		{ Item.items.iron_ore, 5}
	},
	copper_sword = {
		{ Item.items.wood, 3 },
		{ Item.items.iron_ore, 2} ,
		{ Item.items.copper_ore, 3 }
	},
	gold_sword = {
		{ Item.items.wood, 3 },
		{ Item.items.iron_ore, 1 },
		{ Item.items.copper_ore, 2 },
		{ Item.items.gold_ore, 5 }
	},
	iron_shield = {
		{ Item.items.stick, 6 },
		{ Item.items.wood, 2},
		{ Item.items.iron_ore, 4}
	},
	copper_shield = {
		{ Item.items.stick, 6 },
		{ Item.items.wood, 2 },
		{ Item.items.iron_ore, 2 },
		{ Item.items.copper_ore, 3 }
	},
	gold_shield = {
		{ Item.items.stick, 6 },
		{ Item.items.wood, 2 },
		{ Item.items.iron_ore, 1},
		{ Item.items.copper_ore, 2 },
		{ Item.items.gold_ore, 5 }
	},
	log_stakes = {
		{ Item.items.wood, 3 },
	},
	bridge = {
		{ Item.items.log_stakes, 3 },
		{ Item.items.clay, 20 },
		{ Item.items.stone, 8 }
	}
}

recipesBitList = BitList {
	"basic_axe", "iron_axe", "copper_axe", "gold_axe",
	"basic_shovel", "iron_shovel", "copper_shovel", "gold_shovel",
	"iron_sword", "copper_sword", "gold_sword",
	"iron_shield", "copper_shield", "gold_shield",
	"log_stakes", "bridge"
}

local totalRecipes = 0
for recipe in next, recipes do totalRecipes = totalRecipes + 1 end

local totalPages = math.ceil((totalRecipes) / 6)


openCraftingTable = function(player, page, inCraftingTable)
	page = page or 1
	if page < 1 or page > totalPages then return end

	local target = player.name
	local items = Item.items
	craftingPanel:hide(target):show(target)
	Panel.panels[410]:hide()

	Panel.panels[351]:update(("<a href='event:%s'><p align='center'><b>%s〈%s</b></p></a>")
		:format(
			page - 1,
			page - 1 < 1 and "<N2>" or "",
			page - 1 < 1 and "</N2>" or ""
		)
	, target)
	Panel.panels[352]:update(("<a href='event:%s'><p align='center'><b>%s〉%s</b></p></a>")
		:format(
			page + 1,
			page + 1 > totalPages and "<N2>" or "</N2>",
			page + 1 > totalPages and "</N2>" or "</N2>"
		)
	, target)


	local col, row, count = 0, 0, 0
	for i = (page - 1) * 6 + 1, page * 6 do
		local name = recipesBitList:get(i)
		if not name then return end
		-- todo: c hange
		if true then--player.learnedRecipes[name] then
			local item = Item.items[name]
			local recipePanel = Panel(460 + count, "", 380 + col * 120, 100 + row * 120, 100, 100, 0x1A3846, 0x1A3846, 1, true)
			local p = Panel.panels[460 + count + 1] or Panel(460 + count + 1, "", 385 + col * 120, 170 + row * 120, 90, 20, nil, 0x324650, 1, true)
			recipePanel:addImageTemp(Image(item.image, "&1", 410 + col * 120, 110 + row * 120), target)
				:addPanel(p
					:setActionListenerTemp(function(id, name, event)
						displayRecipeInfo(name, event, inCraftingTable)
					end, target)
				)

			if not player.learnedRecipes[name] then recipePanel:addImageTemp(Image(assets.ui.lock, "&1", 380 + col * 120, 80 + row * 120), target) end
			craftingPanel:addPanelTemp(recipePanel, target)
			p:update(("<p align='center'><a href='event:%s'>%s</a></p>"):format(name, item.locales[player.language], target), target)
				--p:show(name)


			col = col + 1
			count = count + 2
			if col >= 3 then
				row = row + 1
				col = 0
			end
		end
	end

end

displayRecipeInfo = function(name, recipeName, inCraftingTable)
	print("came here")
	local player = Player.players[name]
	local recipe = recipes[recipeName]
	local item = Item.items[recipeName]
	if not recipe then return end
	local target = name
	Panel.panels[410]:hide(target):show(target)

	Panel.panels[420]:addImageTemp(Image(item.image, "&1", 80, 80), name)
	Panel.panels[420]:update(" <font size='15' face='Lucida console'><b><BV>" .. item.locales[player.language] .. "</BV></b></font>", name)
	if inCraftingTable then
		Panel.panels[450]:update(("<p align='center'><b><a href='event:%s'>%s</a></b></p>")
			:format(
				recipeName,
				(player:canCraft(recipeName) and (translate("CRAFT", player.language))
					or ("<N2>" .. translate("CANT_CRAFT", player.language) .. "</N2>")
				)
			), name)
	else
		Panel.panels[450]:hide(target)
	end

	Panel.panels[451]:update(translate("RECIPE_DESC", player.language, nil, {
		desc = item.description_locales[player.language]
	}), target)

	for i, items in next, recipe do
		local reqItemObj = items[1]
		Panel.panels[452]
			:addPanelTemp(Panel(452 + i,
				(" x %s <i>( %s )</i>"):format(items[2], reqItemObj.locales[player.language]),
			100, 190 + i * 30, 180, 30, nil, nil, 0, true), name)
			:addImageTemp(Image(reqItemObj.image, "&1", 80, 190 + i * 30, 0.6, 0.6), name)
	end

	local col, row = 0, 0
	for i, prop in next, ({ "attack", "defense", "durability", "chopping", "mining" }) do
		if item[prop] and item[prop] ~= 0 then
			Panel.panels[410]:addPanelTemp(
				Panel(480 + i, (" x %s <b>[</b>%s<b>]</b>"):format(item[prop], translate("PROPS", player.language, prop)), 105 + 125 * col, 150 + row * 30, 240, 20, nil, nil, 0, true)
					:addImageTemp(Image(assets.ui[prop], "&1", 75 + 125 * col, 140 + row * 30), name)
			, name)
			col = col + 1
			if col >= 2 then
				row = row + 1
				col = 0
			end
		end


	end

end
