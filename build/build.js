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
			"src/quests.lua"
    	],
  	},
  	init: { files: ["src/init.lua"] },
  	translations: {
    	header: "local translations = {}\n\n",
    	files: [
    		"src/translations/en.lua",
			"src/translations/pl.lua",
			"src/translations/ro.lua",
			"src/translations/ar.lua",
			"src/translations/tr.lua",
			"src/translations/cn.lua",
			"src/translations/zh.lua",
			"src/translations/fr.lua",
			"src/translations/br.lua",
			"src/translations/pt.lua",
			"src/translations/ru.lua",
      		"src/translations/translator.lua",
    	],
  	},
	  
  	classes: { files: [			
	  	"src/Monster.lua",
		"src/monster_metadata.lua",
		"src/Area.lua",
	  	"src/Trigger.lua",
	  	"src/Item.lua",
	  	"src/Player.lua",
	  	"src/crafting.lua",
	  	"src/Entity.lua",
		"src/entity_metadata.lua"
	] },
  	events: {
    	files: [
      		"src/events/eventLoop.lua",
			"src/events/eventNewPlayer.lua",
			"src/events/eventNewGame.lua",
      		"src/events/eventPlayerDataLoaded.lua",
			"src/events/eventKeyboard.lua",
			"src/events/eventTalkToNPC.lua",
			"src/events/eventTextAreaCallback.lua",
			"src/events/eventContactListener.lua",
			"src/events/eventPopupAnswer.lua"
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
