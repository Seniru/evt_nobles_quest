eventTextAreaCallback = function(id, name, event)
	if player.actionCooldown > os.time() then return end
	Panel.handleActions(id, name, event)
	player.actionCooldown = os.time() + 500
end