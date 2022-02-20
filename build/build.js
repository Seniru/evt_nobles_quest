const combine = require("./combine");
const { exec } = require("child_process");
const luamin = require("luamin");
const vkbeauty = require("vkbeautify");

combine({
  	libs: {
    	files: [
      		"libs/utils.lua",
      		"libs/bit.lua",
      		"libs/BitList.lua",
      		"libs/Windows.lua",
      		"libs/timers4tfm.lua",
      		"libs/DataHandler.lua",
      		"libs/xmllib.lua",
			"src/quests.lua",
			"src/Area.lua",
			"src/Monster.lua",
			"src/Trigger.lua",
			"src/Item.lua",
			"src/Player.lua",
			"src/crafting.lua",
			"src/Entity.lua",
    	],
  	},
  	init: { files: ["src/init.lua"] },
  	translations: {
    	header: "local translations = {}\n\n",
    	files: [
    		"src/translations/en.lua",
      		"src/translations/translator.lua",
    	],
  	},
  	//classes: { files: ["libs/Player.lua"] },
  	events: {
    	files: [
      		"src/events/eventLoop.lua",
			"src/events/eventNewPlayer.lua",
			"src/events/eventNewGame.lua",
      		"src/events/eventPlayerDataLoaded.lua",
			"src/events/eventKeyboard.lua",
			"src/events/eventTextAreaCallback.lua"
    	],
  	},
  	main: {
    	files: [
      		"src/main.lua",
    	],
  	},
}).then((res) => {
    console.log("\x1b[1m\x1b[32m%s\x1b[0m", "Build completed!");
});
