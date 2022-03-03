eventNewGame = function()

	-- NOTE: Sometimes the script is loaded twice in the same round (detect it when eventNewGame is called twice). You must use system.exit() is this case, because it doesn't load the player data correctly, and the textareas (are duplicated) doesn't trigger eventTextAreaCallback.
	if eventLoaded then
        return system.exit()
    end
	-- NOTE: The event runs in rooms with 1 mouse, should be 4 or 5.
	if not IS_TEST and tfm.get.room.uniquePlayers < 4 then
		return system.exit()
	end

	for name, player in next, tfm.get.room.playerList do
		eventNewPlayer(name)
	end

	-- parsing information from xml
	local xml = tfm.get.room.xmlMapInfo.xml
	local dom = parseXml(xml)

	for z, ground in ipairs(path(dom, "Z", "S", "S")) do
		local areaId = tonumber(ground.attribute.lua)
		if areaId then
			Area.new(ground.attribute.X, ground.attribute.Y, ground.attribute.L, ground.attribute.H)
		end
	end

	for z, obj in ipairs(path(dom, "Z", "O", "O")) do
		if obj.attribute.type then
			local x, y = tonumber(obj.attribute.X), tonumber(obj.attribute.Y)
			local area, attrC, attrType = Area.getAreaByCoords(x, y), obj.attribute.C, obj.attribute.type
			if attrC == "22" then	-- entities
				Entity.new(x, y, attrType, area, obj.attribute.name)
			elseif attrC == "14" then -- triggers
				Trigger.new(x, y, attrType, area)
			elseif attrC == "11" then
				local route = obj.attribute.route
				local id = Entity.new(x, y, "teleport", area, route, obj.attribute.id)
				if not teleports[route] then teleports[route] = {} end
				table.insert(teleports[route], id)
			end
		end
	end

	eventLoaded = true
end
