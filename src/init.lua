local IS_TEST = true

-- NOTE: Sometimes the script is loaded twice in the same round (detect it when eventNewGame is called twice). You must use system.exit() is this case, because it doesn't load the player data correctly, and the textareas (are duplicated) doesn't trigger eventTextAreaCallback.
local eventLoaded, mapLoaded, eventEnding = false, false, false
local mapPlaying = ""

local maps = {
	mine = [[<C><P L="4800" H="800" MEDATA="3,1;;;;-0;0:::1-"/><Z><S><S T="8" X="1437" Y="712" L="318" H="175" P="0,0,0.3,0.2,0,0,0,0" c="4" lua="2"/><S T="8" X="208" Y="560" L="374" H="204" P="0,0,0.3,0.2,0,0,0,0" c="4" lua="3"/><S T="8" X="1281" Y="193" L="216" H="91" P="0,0,0.3,0.2,0,0,0,0" c="2" lua="4"/><S T="8" X="3910" Y="576" L="1751" H="454" P="0,0,0.3,0.2,0,0,0,0" c="2" lua="7"/><S T="8" X="845" Y="690" L="332" H="182" P="0,0,0.3,0.2,-60,0,0,0" c="4" lua="5"/><S T="8" X="284" Y="93" L="532" H="244" P="0,0,0.3,0.2,0,0,0,0" c="4" lua="6"/><S T="12" X="155" Y="433" L="300" H="37" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="802" Y="771" L="1600" H="18" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="12" Y="402" L="778" H="18" P="0,0,0.3,0.2,90,0,0,0" o="324650"/><S T="12" X="1610" Y="420" L="778" H="18" P="0,0,0.3,0.2,90,0,0,0" o="324650"/><S T="12" X="1404" Y="609" L="399" H="36" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="1615" Y="692" L="44" H="210" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="1216" Y="624" L="25" H="67" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="13" X="1327" Y="784" L="53" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="892" Y="650" L="824" H="27" P="0,0,0.3,0.2,20,0,0,0" o="324650"/><S T="12" X="433" Y="390" L="295" H="32" P="0,0,0.3,0.2,-20,0,0,0" o="324650"/><S T="12" X="459" Y="548" L="295" H="32" P="0,0,0.3,0.2,-40,0,0,0" o="324650"/><S T="12" X="903" Y="276" L="295" H="32" P="0,0,0.3,0.2,-10,0,0,0" o="324650"/><S T="12" X="416" Y="701" L="802" H="184" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="1021" Y="801" L="560" H="184" P="0,0,0.3,0.2,20,0,0,0" o="324650"/><S T="12" X="1382" Y="487" L="450" H="224" P="0,0,0.3,0.2,-30,0,0,0" o="324650"/><S T="12" X="1500" Y="300" L="218" H="594" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="804" Y="-10" L="1622" H="70" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="358" Y="215" L="678" H="28" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="708" Y="218" L="49" H="28" P="0,0,0.3,0.2,10,0,0,0" o="324650"/><S T="12" X="1269" Y="374" L="452" H="266" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="270" Y="189" L="538" H="36" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="1297" Y="239" L="196" H="36" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="456" Y="625" L="220" H="102" P="0,0,0.3,0.2,30,0,0,0" o="324650"/><S T="13" X="835" Y="627" L="59" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="3909" Y="392" L="1786" H="28" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="3035" Y="590" L="30" H="428" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="3911" Y="793" L="1774" H="26" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="4786" Y="589" L="32" H="418" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="3418" Y="770" L="477" H="63" P="0,0,0.3,0.2,0,0,0,0" o="324650"/></S><D><DS X="40" Y="394"/></D><O><O X="364" Y="129" C="22" nosync="" P="0" type="tree"/><O X="88" Y="543" C="22" nosync="" P="0" type="tree"/><O X="936" Y="607" C="22" nosync="" P="0" type="tree"/><O X="308" Y="587" C="22" nosync="" P="0" type="tree"/><O X="214" Y="121" C="22" nosync="" P="0" type="tree"/><O X="442" Y="119" C="22" nosync="" P="0" type="rock"/><O X="300" Y="127" C="22" nosync="" P="0" type="tree"/><O X="1460" Y="718" C="22" nosync="" P="0" type="npc" name="nosferatu"/><O X="1301" Y="204" C="22" nosync="" P="0" type="craft_table"/><O X="131" Y="578" C="22" nosync="" P="0" type="recipe" name="basic_shovel"/><O X="201" Y="570" C="22" nosync="" P="0" type="rock"/><O X="253" Y="562" C="22" nosync="" P="0" type="recipe" name="basic_axe"/><O X="79" Y="143" C="14" nosync="" P="0" type="monster_spawn"/><O X="1562" Y="736" C="11" nosync="" P="0" type="teleport" route="mine" id="1"/><O X="3105" Y="459" C="11" nosync="" P="0" type="teleport" route="mine" id="2"/><O X="3367" Y="658" C="22" nosync="" P="0" type="rock"/><O X="3807" Y="758" C="22" nosync="" P="0" type="rock"/><O X="4333" Y="758" C="22" nosync="" P="0" type="rock"/><O X="3965" Y="762" C="22" nosync="" P="0" type="rock"/><O X="3637" Y="702" C="22" nosync="" P="0" type="iron_ore"/><O X="4449" Y="754" C="22" nosync="" P="0" type="rock"/><O X="4561" Y="752" C="22" nosync="" P="0" type="iron_ore"/><O X="4727" Y="558" C="22" nosync="" P="0" type="iron_ore"/><O X="4711" Y="750" C="22" nosync="" P="0" type="rock"/></O><L/></Z></C>]]
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
}

local assets = {
	ui = {
		reply = "171d2f983ba.png",
		btnNext = "17eaa38a3f8.png"
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
			return player.questProgress.nosferatu and player.questProgress.nosferatu.stage >= 3
		end
	}
}

local mineQuestCompletedPlayers, mineQuestIncompletedPlayers, totalPlayers, totalProcessedPlayers = 0, 0, 0, 0


