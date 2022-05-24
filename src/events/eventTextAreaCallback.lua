eventTextAreaCallback = function(id, name, event)
	local player = Player.players[name]
	if player.actionCooldown > os.time() then return end
	Panel.handleActions(id, name, event)
	player.actionCooldown = os.time() + 500
end