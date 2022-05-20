function eventPopupAnswer(id, name, answer)
	local player = Player.players[name]
	if id == 69 and player.questProgress.spiritOrbs then
		if answer == "69" then
			x, y = 351, 773
			tfm.exec.movePlayer(name, x, y)
			Timer.new("tp_anim", tfm.exec.displayParticle, 10, false, 37, x, y)
		else
			tfm.exec.chatMessage(translate("WRONG_GUESS", player.language))
		end
	end
end