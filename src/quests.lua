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
				en = "Travel back from time to a town in the medieval era"
			},
			tasks = 1
		}
	},

	nosferatu = {
		id = 2,
		title_locales = {
			en = "The loyal servant"
		},
		{
			description_locales = {
				en = "Meet Nosferatu at the mine"
			},
			tasks = 1
		},
		{
			description_locales = {
				en = "Gather 15 wood"
			},
			tasks = 1
		},
		{
			description_locales = {
				en = "Gather 15 iron ore"
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
				en = "Defeat 25 monsters"
			},
			tasks = 25
		},
		{
			description_locales = {
				en = "Meet Lieutenant Edric back"
			},
			tasks = 1
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

	fiery_dragon = {
		id = 5,
		title_locales = {
			en = "Resisting the fire"
		},
		{
			description_locales = {
				en = "Destroy the fiery dragon and collect it's spirit orb"
			},
			tasks = 1
		}
	},

	final_boss = {
		id = 6,
		title_locales = {
			en = "Medieval hero"
		},
		{
			description_locales = {
				en = "Destroy the evil spirit"
			}
		}
	},

	_all = { "wc", "nosferatu", "strength_test", "spiritOrbs", "fiery_dragon", "final_boss" }

}