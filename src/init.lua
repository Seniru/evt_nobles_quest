local IS_TEST = true

math.randomseed(os.time())
-- NOTE: Sometimes the script is loaded twice in the same round (detect it when eventNewGame is called twice). You must use system.exit() is this case, because it doesn't load the player data correctly, and the textareas (are duplicated) doesn't trigger eventTextAreaCallback.
local eventLoaded, mapLoaded, eventEnding = false, false, false
local mapPlaying = ""

local maps = {
	mine = [[<C><P L="1622" H="852" D="17f32282dfc.png,2,5" APS="17f322853ac.png,,820,535,800,317,-1,0" MEDATA=";;;;1,1-0;0:::1-"/><Z><S><S T="1" X="1628" Y="108" L="10" H="2016" P="0,0,0,0.2,2880,0,0,0" m=""/><S T="1" X="-7" Y="196" L="10" H="2016" P="0,0,0,0.2,2880,0,0,0" m=""/><S T="0" X="5" Y="5" L="11" H="10" P="0,0,0.3,0.2,2880,0,0,0" c="4" nosync="" i="0,0,17f32282dfc.png"/><S T="0" X="30" Y="202" L="61" H="10" P="0,0,0.3,0.2,2890,0,0,0" m=""/><S T="0" X="85" Y="221" L="59" H="10" P="0,0,0.3,0.2,2910,0,0,0" m=""/><S T="0" X="149" Y="319" L="139" H="10" P="0,0,0.3,0.2,2950,0,0,0" m=""/><S T="0" X="119" Y="246" L="26" H="10" P="0,0,0.3,0.2,2930,0,0,0" m=""/><S T="0" X="209" Y="399" L="102" H="10" P="0,0,0.3,0.2,2918,0,0,0" m=""/><S T="0" X="264" Y="453" L="57" H="10" P="0,0,0.3,0.2,2950,0,0,0" m=""/><S T="0" X="298" Y="509" L="79" H="10" P="0,0,0.3,0.2,2930,0,0,0" m=""/><S T="0" X="321" Y="562" L="49" H="10" P="0,0,0.3,0.2,2970,0,0,0" m=""/><S T="0" X="524" Y="535" L="230" H="10" P="0,0,0.3,0.2,2860,0,0,0" m=""/><S T="0" X="235" Y="658" L="230" H="10" P="0,0,0.3,0.2,2840,0,0,0" m=""/><S T="0" X="667" Y="474" L="88" H="10" P="0,0,0.3,0.2,2850,0,0,0" m=""/><S T="0" X="778" Y="425" L="163" H="10" P="0,0,0.3,0.2,2860,0,0,0" m=""/><S T="0" X="957" Y="398" L="212" H="10" P="0,0,0.3,0.2,2880,0,0,0" m=""/><S T="0" X="1082" Y="390" L="54" H="10" P="0,0,0.3,0.2,2860,0,0,0" m=""/><S T="0" X="1130" Y="380" L="69" H="10" P="0,0,0.3,0.2,2840,0,0,0" m=""/><S T="0" X="1193" Y="346" L="85" H="12" P="0,0,0.3,0.2,2860,0,0,0" m=""/><S T="0" X="1237" Y="333" L="67" H="10" P="0,0,0.3,0.2,2800,0,0,0" m=""/><S T="0" X="1314" Y="263" L="161" H="10" P="0,0,0.3,0.2,2850,0,0,0" m=""/><S T="0" X="1430" Y="214" L="94" H="10" P="0,0,0.3,0.2,2870,0,0,0" m=""/><S T="0" X="1532" Y="207" L="113" H="10" P="0,0,0.3,0.2,2880,0,0,0" m=""/><S T="0" X="1602" Y="210" L="34" H="10" P="0,0,0.3,0.2,2890,0,0,0" m=""/><S T="4" X="357" Y="673" L="10" H="235" P="0,0,20,0.2,2910,0,0,0" m=""/><S T="0" X="900" Y="844" L="1800" H="22" P="0,0,0.3,0.2,2880,0,0,0" m=""/><S T="0" X="894" Y="862" L="136" H="10" P="0,0,0.3,0.2,2840,0,0,0" m=""/><S T="0" X="1003" Y="811" L="121" H="10" P="0,0,0.3,0.2,2870,0,0,0" m=""/><S T="0" X="1121" Y="795" L="118" H="10" P="0,0,0.3,0.2,2875,0,0,0" m=""/><S T="0" X="1528" Y="850" L="118" H="10" P="0,0,0.3,0.2,2915,0,0,0" m=""/><S T="0" X="1332" Y="804" L="314" H="10" P="0,0,0.3,0.2,2885,0,0,0" m=""/><S T="0" X="245" Y="810" L="200" H="10" P="0,0,0.3,0.2,2900,0,0,0" m=""/><S T="1" X="150" Y="859" L="10" H="268" P="0,0,0,0.2,2880,0,0,0" m=""/><S T="8" X="1261" Y="670" L="718" H="375" P="0,0,0.3,0.2,0,0,0,0" c="4" lua="2"/><S T="8" X="148" Y="253" L="302" H="499" P="0,0,0.3,0.2,0,0,0,0" c="4" lua="3"/><S T="8" X="730" Y="395" L="264" H="151" P="0,0,0.3,0.2,0,0,0,0" c="2" lua="4"/><S T="8" X="3910" Y="576" L="1751" H="454" P="0,0,0.3,0.2,0,0,0,0" c="2" lua="7"/><S T="8" X="1308" Y="275" L="630" H="257" P="0,0,0.3,0.2,0,0,0,0" c="4" lua="5"/><S T="8" X="75" Y="799" L="157" H="107" P="0,0,0.3,0.2,0,0,0,0" c="4" lua="6"/><S T="8" X="563" Y="794" L="157" H="107" P="0,0,0.3,0.2,0,0,0,0" c="4" lua="8"/><S T="12" X="3909" Y="392" L="1786" H="28" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="3035" Y="590" L="30" H="428" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="3911" Y="793" L="1774" H="26" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="4786" Y="589" L="32" H="418" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="3418" Y="770" L="477" H="63" P="0,0,0.3,0.2,0,0,0,0" o="324650"/></S><D><DS X="947" Y="380"/></D><O><O X="31" Y="152" C="22" nosync="" P="0" type="tree"/><O X="212" Y="345" C="22" nosync="" P="0" type="tree"/><O X="259" Y="398" C="22" nosync="" P="0" type="tree"/><O X="1272" Y="702" C="22" nosync="" P="0" type="npc" name="nosferatu"/><O X="732" Y="392" C="22" nosync="" P="0" type="craft_table"/><O X="580" Y="776" C="22" nosync="" P="0" type="recipe" name="basic_shovel"/><O X="1458" Y="185" C="22" nosync="" P="0" type="rock"/><O X="1549" Y="181" C="22" nosync="" P="0" type="rock"/><O X="1259" Y="281" C="22" nosync="" P="0" type="rock"/><O X="3110" Y="752" C="22" nosync="" P="0" type="recipe" name="basic_axe"/><O X="1535" Y="799" C="11" nosync="" P="0" type="teleport" route="mine" id="1"/><O X="3105" Y="459" C="11" nosync="" P="0" type="teleport" route="mine" id="2"/><O X="3367" Y="658" C="22" nosync="" P="0" type="rock"/><O X="3807" Y="758" C="22" nosync="" P="0" type="rock"/><O X="4333" Y="758" C="22" nosync="" P="0" type="rock"/><O X="3965" Y="762" C="22" nosync="" P="0" type="rock"/><O X="3637" Y="702" C="22" nosync="" P="0" type="iron_ore"/><O X="4449" Y="754" C="22" nosync="" P="0" type="rock"/><O X="4561" Y="752" C="22" nosync="" P="0" type="iron_ore"/><O X="4727" Y="558" C="22" nosync="" P="0" type="iron_ore"/><O X="4711" Y="750" C="22" nosync="" P="0" type="rock"/><O X="1029" Y="375" C="22" nosync="" P="0" type="tree"/><O X="56" Y="805" C="22" nosync="" P="0" type="tree"/></O><L/></Z></C>]],
	castle = [[<C><P L="1600" H="800" MEDATA=";;;;-0;0:::1-"/><Z><S><S T="12" X="399" Y="386" L="797" H="26" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="0" Y="198" L="27" H="392" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="800" Y="193" L="34" H="405" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="395" Y="-1" L="834" H="31" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="8" X="399" Y="198" L="792" H="365" P="0,0,0.3,0.2,0,0,0,0" c="4" lua="1"/><S T="8" X="1200" Y="593" L="792" H="365" P="0,0,0.3,0.2,0,0,0,0" c="4" lua="2"/><S T="12" X="1190" Y="389" L="815" H="13" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="1602" Y="574" L="20" H="451" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="793" Y="574" L="20" H="464" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="1180" Y="729" L="848" H="18" P="0,0,0.3,0.2,0,0,0,0" o="324650"/></S><D><DS X="85" Y="355"/></D><O><O X="606" Y="341" C="22" nosync="" P="0" type="npc" name="edric"/><O X="1347" Y="610" C="11" nosync="" P="0" type="teleport" route="arena" id="2"/><O X="300" Y="342" C="11" nosync="" P="0" type="teleport" route="arena" id="1"/><O X="910" Y="693" C="14" nosync="" P="0" type="monster_spawn"/><O X="1543" Y="692" C="14" nosync="" P="0" type="monster_spawn"/></O><L/></Z></C>]]

}

local keys = {
	LEFT 	= 0,
	JUMP 	= 1,
	RIGHT 	= 2,
	DUCK 	= 3,
	SPACE 	= 32,
	KEY_0 	= 48,
	KEY_1	= 49,
	KEY_2	= 50,
	KEY_3	= 51,
	KEY_4	= 52,
	KEY_5	= 53,
	KEY_6	= 54,
	KEY_7	= 55,
	KEY_8	= 56,
	KEY_9	= 57,
	KEY_R 	= 82,
	KEY_X	= 88
}

local assets = {
	ui = {
		reply = "171d2f983ba.png",
		btnNext = "17eaa38a3f8.png",
		inventory = "17ff9b6b11f.png"
	},
	damageFg = "17f2a88995c.png",
	damageBg = "17f2a890350.png"
}

local dHandler = DataHandler.new("evt_nq", {
	recipes = {
		index = 1,
		type = "number",
		default = 0
	},
	questProgress = {
		index = 2,
		type = "string",
		default = ""
	},
	inventory = {
		index = 3,
		type = "string",
		default = ""
	}
})

local teleports = {
	mine = {
		canEnter = function(player, terminalId)
			local quest = player.questProgress.nosferatu
			return quest and (quest.completed or quest.stage >= 3)
		end
	},
	arena = {
		canEnter = function(player, terminalId)
			local quest = player.questProgress.strength_test
			return quest and (quest.completed or quest.stage >= 2)
		end
	}
}

local mineQuestCompletedPlayers, mineQuestIncompletedPlayers, totalPlayers, totalProcessedPlayers = 0, 0, 0, 0


