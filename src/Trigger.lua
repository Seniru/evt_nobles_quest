local Trigger = {}

Trigger.__index = Trigger
Trigger.__tostring = function(self)
	return table.tostring(self)
end


setmetatable(Trigger, {
	__call = function (cls, ...)
		return cls.new(...)
	end,
})


local spawnRarities = {1 ,1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 3, 3, 3 }
Trigger.triggers = {

	monster_spawn = {
		onactivate = function(self)
			Monster.new({ health = 20, species = Monster.all.mutant_rat }, self)
		end,
		ontick = function(self)
			for _, monster in next, self.monsters do
				if monster then monster:action() end
			end
			if (math.random(1, 1000) > (self.monsterCount < 1 and 500 or 900 + self.monsterCount * 30 )) then
				Monster.new({ health = 20, species = Monster.all[({"mutant_rat", "snail", "the_rock"})[spawnRarities[math.random(#spawnRarities)]]] }, self)
			end
		end,
		ondeactivate = function(self)
			-- to prevent invalid keys to "next"
			local previousMonster
			for i, monster in next, self.monsters do
				if previousMonster then previousMonster:destroy() end
				previousMonster = monster
			end
			if previousMonster then previousMonster:destroy() end
		end
	},

	monster_spawn_passive = {
		onactivate = function() end,
		ontick = function(self)
			for _, monster in next, self.monsters do
				if monster then monster:action() end
			end
		end,
		ondeactivate = function(self)
			-- to prevent invalid keys to "next"
			local previousMonster
			for i, monster in next, self.monsters do
				if previousMonster then previousMonster:destroy() end
				previousMonster = monster
			end
			if previousMonster then previousMonster:destroy() end
		end
	},

	fiery_dragon = {
		onactivate = function(self)
			Monster.new({ health = 9999, species = Monster.all.fiery_dragon }, self)
		end,
		ontick = function(self)
			for _, monster in next, (self.monsters or {}) do
				if monster then monster:action() end
			end
		end,
		ondeactivate = function(self)
			self.monsters[next(self.monsters)]:destroy()
		end
	},

	final_boss = {
		onactivate = function(self)
			for name, player in next, Player.players do
				if player.questProgress.final_boss then
					tfm.exec.chatMessage(translate("FINAL_BATTLE_PING", player.language), name)
				end
			end
			Timer.new("start_boss", function()
				bossBattleTriggered = true
				for name in next, self.area.players do
					local player = Player.players[name]
					if player.divinePower then
						inventoryPanel:hide()
						dialoguePanel:hide()
						divineChargePanel:show(name)
						divineChargePanel:addPanelTemp(Panel(401, "", 290, 380, (1 / FINAL_BOSS_ATK_MAX_CHARGE) * 270, 20, 0x91cfde, 0x91cfde, 1, true), name)
					end
				end
				local boss = Monster.new({ health = 1500, species = Monster.all.final_boss }, self)
				Timer.new("bossDivineCharger", function()
					divineChargeTimeOver = true
					local monster = self.monsters[next(self.monsters)]
					print(monster.health)
					monster.health = monster.health - divinePowerCharge
					print(monster.health)
					displayDamage(monster)
				end, 1000 * 80, false)
			end, 1000 * 30 -_tc, false)
		end,
		ontick = function(self)
			if not bossBattleTriggered then return end
			for _, monster in next, self.monsters do
				if monster and monster.isAlive then monster:action() end
			end
			if divineChargeTimeOver or divinePowerCharge >= FINAL_BOSS_ATK_MAX_CHARGE then
				return
			end

			directionSequence.lastPassed = nil
			local id = 8000 + #directionSequence + 1

			if #directionSequence > 0 and directionSequence[#directionSequence][3] > os.time() then return end
			--if #directionSequence > 0 then directionSequence[#directionSequence][3] = os.time() print("set") end
			tfm.exec.addPhysicObject(id, 816, 4395, {
				type = 1,
				width = 10,
				height = 10,
				friction = 0,
				dynamic = true,
				fixedRotation = true
			})
			tfm.exec.movePhysicObject(id, 0, 0, false, -20, 0)
			tfm.exec.addImage("180e7b47ef5.png", "+" .. id, 0, 200)
			directionSequence[#directionSequence + 1] = { id, math.random(0, 3), os.time() + math.max(1000, 5000 - (id - 8000) * 200), os.time() }
			local s, v = 816 - 170, 20
			-- s = t(u + v)/2
			-- division by 3 is because the given vx is in a different unit than px/s
			local t = (2 * s / (v + v - 0.01)) / 3
			Timer.new("bossMinigame" .. tostring(#directionSequence), function()
				print("should trigger")
				for name in next, self.area.players do
					local player = Player.players[name]
					if not player.divinePower then return end
					divineChargePanel:addPanelTemp(Panel(401, "", 290, 380, (divinePowerCharge / FINAL_BOSS_ATK_MAX_CHARGE) * 270, 20, 0x91cfde, 0x91cfde, 1, true), name)
					directionSequence.lastPassed = id - 8000
					if player.sequenceIndex > directionSequence.lastPassed then return end
					player.sequenceIndex = directionSequence.lastPassed + 1
					p({name, "Too late!"})
					divinePowerCharge = math.max(0, divinePowerCharge - 3)
					player.chargedDivinePower = math.max(0, player.chargedDivinePower - 3)
				end
			end, t * 1000 + 400, false)
		end,
		ondeactivate = function() end
	}

}

function Trigger.new(x, y, type, area, name)
	local self = setmetatable({}, Trigger)
	self.x = x
	self.y = y
	self.type = type
	self.area = area
	self.name = name
	self.id = #area.triggers + 1
	self.monsters = {}
	self.monsterCount = 0
	area.triggers[self.id] = self
	return self
end

function Trigger:activate()
	Trigger.triggers[self.type].onactivate(self)
	local ontick = Trigger.triggers[self.type].ontick
	Timer("trigger_" .. self.id, ontick, 500, true, self)
end

function Trigger:deactivate()
	Trigger.triggers[self.type].ondeactivate(self)
	Timer._timers["trigger_" .. self.id]:kill()
end
