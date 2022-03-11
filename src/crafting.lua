recipes = {
	basic_axe = {
		{ Item.items.stick, 5 },
		{ Item.items.stone, 3 }
	},
	basic_shovel = {
		{ Item.items.wood, 5 },
	},
	test = {
		{ Item.items.wood, 5 },

	},
	test2 = {
		{ Item.items.wood, 5 },

	},
	test3 = {
		{ Item.items.wood, 5 },

	},
	test4 = {
		{ Item.items.wood, 5 },

	},
	test5 = {		{ Item.items.wood, 5 },
}
}

recipesBitList = BitList {
	"basic_axe", "basic_shovel"
}

openCraftingTable = function(player)
	local name = player.name
	local items = Item.items
	craftingPanel:show(name)
	--craftingPanel:update(prettify(player.learnedRecipes, 1, {}).res, player)
	-- craft all the craftable recipes for now
	p(player.learnedRecipes)
	local cols, rows, i = 0, 0, 1
	for recipeName in next, recipes do
		--player:craftItem(recipeName)
		cols = cols + 1
		i = i + 1
		craftingPanel:addPanelTemp(
			Panel(320 + i, ("<a href='event:%s'>%s</a>"):format(recipeName, recipeName), 20 + cols * 50, 30 + rows * 50, 50, 70, nil, nil, 1, true)
				:setActionListener(displayRecipeInfo)
		, name)
		if cols == 3 then
			cols = 0
			rows = rows + 1
		end
	end
end

displayRecipeInfo = function(_id, name, recipeName)
	local player = Player.players[name]
	p({_id, name, recipeName})
	local recipe = recipes[recipeName]
	Panel.panels[302]:update(
		("<b>%s</b><br>%s<br>%s")
			:format(recipeName, prettify(recipe, 1, {}).res, player:canCraft(recipeName) and ("<a href='event:%s'>Craft</a>"):format(recipeName) or "Can't craft")
	, name)
end
