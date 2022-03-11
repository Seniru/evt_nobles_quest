do

	local npcNames = {
		["Nosferatu"] = "nosferatu",
		["Lieutenant Edric"] = "edric"
	}

	eventTalkToNPC = function(name, npc)
		print(npcNames[npc])
		Entity.entities[npcNames[npc]]:onAction(Player.players[name])
	end
end
