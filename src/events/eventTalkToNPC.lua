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
		local player = Player.players[name]
		if player.actionCooldown > os.time() then return end
		Entity.entities[npcNames[npc]]:onAction(Player.players[name])
		player.actionCooldown = os.time() + 500
	end
end
