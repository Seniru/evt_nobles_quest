local quests = {
	--[[
		struture:

		name:
			stage: tasksAmount
		..
	]]
	wc = {
		id = 1,
		title_locales = {
			en = "New person in the town"
		},
		{
			description_locales = {
				en = "Start your journey in this town and please edit this ugly desc later"
			},
			tasks = 1
		}
	},

	giveWood = {
		id = 2,
		title_locales = {
			en = "Some nice title"
		},
		{
			description_locales = {
				en = "Meet Nosferatu at the mine"
			},
			tasks = 1
		},
		{
			description_locales = {
				en = "Gather wood"
			},
			tasks = 1
		}
	},

	_all = { "wc", "giveWood" }

}