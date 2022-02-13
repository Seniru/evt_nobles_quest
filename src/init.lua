local IS_TEST = true

-- NOTE: Sometimes the script is loaded twice in the same round (detect it when eventNewGame is called twice). You must use system.exit() is this case, because it doesn't load the player data correctly, and the textareas (are duplicated) doesn't trigger eventTextAreaCallback.
local eventLoaded = false
local mapPlaying = ""

local maps = {
	mine = [[<C><P L="1600" H="800" MEDATA=";;4,1;;-0;0:::1-"/><Z><S><S T="5" X="966" Y="694" L="1690" H="44" P="0,0,0.3,0.2,0,0,0,0"/><S T="8" X="346" Y="643" L="113" H="64" P="0,0,0.3,0.2,0,0,0,0" c="4" lua="2"/><S T="8" X="515" Y="566" L="176" H="204" P="0,0,0.3,0.2,0,0,0,0" c="4" lua="3"/><S T="8" X="142" Y="626" L="216" H="91" P="0,0,0.3,0.2,0,0,0,0" c="2" lua="4"/><S T="8" X="681" Y="603" L="96" H="130" P="0,0,0.3,0.2,0,0,0,0" c="2" lua="5"/><S T="8" X="1108" Y="552" L="532" H="244" P="0,0,0.3,0.2,0,0,0,0" c="2" lua="6"/></S><D><DS X="275" Y="661"/></D><O><O X="462" Y="649" C="22" nosync="" P="0" type="tree"/><O X="326" Y="655" C="22" nosync="" P="0" type="npc" name="nosferatu"/><O X="187" Y="654" C="22" nosync="" P="0" type="craft_table"/><O X="649" Y="650" C="22" nosync="" P="0" type="recipe" name="basic_axe"/><O X="1275" Y="634" C="14" nosync="" P="0" type="monster_spawn"/></O><L/></Z></C>]]
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
	}
}

local dHandler = DataHandler.new("evt_nq", {
	--[[version = {
		index = 8,
		type = "string",
		default = "v0.0.0.0"
	}]]
})
