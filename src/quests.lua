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

	nosferatu = {
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
		},
		{
			description_locales = {
				en = "Gather iron ore"
			},
			tasks = 1
		}
	},

	strength_test = {
		id = 3,
		title_locales = {
			en = "Strength test"
		},
		{
			description_locales = {
				en = "Gather recipes and talk to Lieutenant Edric"
			},
			tasks = 1
		},
		{
			description_locales = {
				en = "Defeat 50 monsters"
			},
			tasks = 50
		}
	},

	spiritOrbs = {
		id = 4,
		title_locales = {
			en = "The spiritual way"
		},
		{
			description_locales = {
				en = "Go to the gloomy forest"
			},
			tasks = 1
		},
		{
			description_locales = {
				en = "Find the mysterious voice"
			},
			tasks = 1
		},
		{
			description_locales = {
				en = "Gather all 5 spirit orbs"
			},
			tasks = 5
		}
	},

	_all = { "wc", "nosferatu", "strength_test", "spiritOrbs" }

}