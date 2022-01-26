local IS_TEST = true

-- NOTE: Sometimes the script is loaded twice in the same round (detect it when eventNewGame is called twice). You must use system.exit() is this case, because it doesn't load the player data correctly, and the textareas (are duplicated) doesn't trigger eventTextAreaCallback.
local eventLoaded = false 

local maps = {
	mine = [[<C><P L="1600" H="800" MEDATA=";;0,1;;-0;0:::1-"/><Z><S><S T="5" X="966" Y="694" L="1690" H="44" P="0,0,0.3,0.2,0,0,0,0"/><S T="8" X="146" Y="599" L="291" H="192" P="0,0,0.3,0.2,0,0,0,0" c="4" lua="1"/><S T="8" X="431" Y="544" L="283" H="261" P="0,0,0.3,0.2,0,0,0,0" c="4" lua="2"/><S T="8" X="664" Y="562" L="176" H="204" P="0,0,0.3,0.2,0,0,0,0" c="4" lua="3"/><S T="8" X="862" Y="627" L="216" H="91" P="0,0,0.3,0.2,0,0,0,0" c="2" lua="4"/><S T="8" X="1007" Y="677" L="74" H="33" P="0,0,0.3,0.2,0,0,0,0" c="2" lua="5"/></S><D><DS X="146" Y="639"/></D><O><O X="638" Y="654" C="22" nosync="" P="0" type="tree"/></O><L/></Z></C>]]
}

local keys = {
	SPACE = 32
}

local dHandler = DataHandler.new("evt_nq", {
	--[[version = {
		index = 8,
		type = "string",
		default = "v0.0.0.0"
	}]]
})
