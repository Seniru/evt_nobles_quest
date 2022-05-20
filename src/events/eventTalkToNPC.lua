do

	local npcNames = {
		["Nosferatu"] = "nosferatu",
		["Lieutenant Edric"] = "edric",
		["Garry"] = "garry",
		["Thompson"] = "thompson",
		["Laura"] = "laura",
		["Cole"] = "cole",
		["Marc"] = "marc",
		["Saruman"] = "saruman"
	}

	eventTalkToNPC = function(name, npc)
		print(npcNames[npc])
		Entity.entities[npcNames[npc]]:onAction(Player.players[name])
	end
end
