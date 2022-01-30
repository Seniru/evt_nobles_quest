tfm.exec.newGame(maps["mine"])
mapPlaying = "mine"

inventoryPanel = Panel(100, "", 30, 350, 740, 50, nil, nil, 1, true)

do
	for i = 0, 9 do
		inventoryPanel:addPanel(Panel(101 + i, "", 30 + 74 * i, 350, 50, 50, nil, nil, 1, true))
	end
end
