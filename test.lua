--[[local map = [[<C><P L="1600" H="800" MEDATA=";;;;-0;0:::1-"/><Z><S><S T="12" X="399" Y="386" L="797" H="26" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="0" Y="198" L="27" H="392" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="800" Y="193" L="34" H="405" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="397" Y="-1" L="834" H="31" P="0,0,0.3,0.2,0,0,100,0" o="324650"/><S T="8" X="399" Y="198" L="792" H="365" P="0,0,0.3,0.2,0,0,0,0" c="4" lua="1"/><S T="8" X="1200" Y="593" L="792" H="365" P="0,0,0.3,0.2,0,0,0,0" c="4" lua="2"/><S T="12" X="1190" Y="389" L="815" H="13" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="1602" Y="574" L="20" H="451" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="793" Y="574" L="20" H="464" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="825" Y="729" L="1538" H="18" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="1207" Y="-1" L="805" H="29" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="1607" Y="207" L="21" H="412" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="8" X="1204" Y="193" L="787" H="391" P="0,0,0.3,0.2,0,0,0,0" c="4" lua="3"/><S T="12" X="888" Y="331" L="158" H="112" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="1428" Y="330" L="339" H="129" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="1255" Y="136" L="58" H="273" P="0,0,0.3,0.2,0,0,0,0" o="324650" m="" lua="4"/><S T="12" X="71" Y="599" L="43" H="348" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="401" Y="416" L="677" H="30" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="760" Y="594" L="46" H="393" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="1" X="417" Y="515" L="647" H="20" P="0,0,0,0.2,0,0,0,0"/></S><D><DS X="85" Y="355"/></D><O><O X="606" Y="341" C="22" nosync="" P="0" type="npc" name="edric"/><O X="1347" Y="610" C="11" nosync="" P="0" type="teleport" route="arena" id="2"/><O X="300" Y="342" C="11" nosync="" P="0" type="teleport" route="arena" id="1"/><O X="693" Y="343" C="11" nosync="" P="0" type="teleport" route="bridge" id="1"/><O X="851" Y="256" C="11" nosync="" P="0" type="teleport" route="bridge" id="2"/><O X="910" Y="693" C="14" nosync="" P="0" type="monster_spawn"/><O X="1543" Y="692" C="14" nosync="" P="0" type="monster_spawn"/><O X="1502" Y="242" C="14" nosync="" P="0" type="fiery_dragon"/><O X="172" Y="346" C="22" nosync="" P="0" type="recipe" name="bridge"/><O X="948" Y="260" C="22" nosync="" P="0" type="bridge"/></O><L/></Z></C>]]

--[[tfm.exec.newGame(map)
start = 0
system.bindMouse("King_seniru#5890", true)
local id = 10000

eventMouse = function(name, x, y)
	start = os.time()
	id = id + 1
	tfm.exec.addPhysicObject(id, 713, 500, {
		type = 1,
		width = 10,
		height = 10,
		friction = 0,
		dynamic = true,
		fixedRotation = true,
		contactListener = true
	})
	tfm.exec.movePhysicObject(id, 0, 0, false, -20, 0)
end

eventContactListener = function(name, id, contactInfo)
	--0print(os.date("*t", os.difftime(time, os.time())))
	print((os.time() - start) / 1000)
	local s1 = math.abs(713 - contactInfo.playerX)
	local s2 = math.abs(713 - contactInfo.contactX)
	local v = contactInfo.speedX
	local u = 20
	--print({s, v, u})

	-- s = t(u + v)/2
	-- 2s/(u+v) = t

	--print(2 * s1 / (u + u))
	print((2 * s2 / (u + u - 0.01))/3)
end
]]

s = 20   u = 20 v = 18
print(2 * s / (u + v))
print((2 * s) / (u + v))