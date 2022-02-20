recipes = {
	basic_axe = {
		{ Item.items.stick, 5 },
		{ Item.items.stone, 3 }
	},
	basic_shovel = {
		{ Item.items.wood, 5 },
	}
}

openCraftingTable = function(player)
	local name = player.name
	--craftingPanel:show(name)
	--craftingPanel:update(prettify(player.learnedRecipes, 1, {}).res, player)
	-- craft all the craftable recipes for now
	for recipeName in next, player.learnedRecipes do
		player:craftItem(recipeName)
	end
end
