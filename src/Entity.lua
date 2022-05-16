Entity = {}

Entity.__index = Entity
Entity.__tostring = function(self)
	return table.tostring(self)
end
Entity.__type = "entity"


setmetatable(Entity, {
	__call = function (cls, ...)
		return cls.new(...)
	end,
})

Entity.entities = {}

function Entity.new(x, y, type, area, name, id)
	local self = setmetatable({}, Entity)
	self.x = x
	self.y = y
	self.type = type
	self.area = area
	self.name = name
	self.id = id
	self.isDestroyed = false
	p({type, name, id})
	area.entities[#area.entities + 1] = self
	if type == "npc" then
		local npc = Entity.entities[name]
		tfm.exec.addNPC(npc.displayName, {
			title = npc.title,
			look = npc.look,
			x = x,
			y = y,
			female = npc.female,
			lookLeft = npc.lookLeft,
			lookAtPlayer = npc.lookAtPlayer,
			interactive = npc.interactive
		})
	else
		local entity = Entity.entities[type]
		self.resourceCap = entity.resourceCap
		self.resourcesLeft = entity.resourceCap
		self.latestActionTimestamp = -1/0
		local imageData = entity.images and entity.images[math.random(#entity.images)] or entity.image
		self.imageId = tfm.exec.addImage(imageData.id, "_999", x + (imageData.xAdj or 0), y + (imageData.yAdj or 0))
		ui.addTextArea(self.imageId, type, nil, x, y, 0, 0, nil, nil, 0, false)
	end
	return self
end

function Entity:receiveAction(player, keydown)
	if self.isDestroyed then return end
	local onAction = Entity.entities[self.type == "npc" and self.name or self.type].onAction
	if onAction then
		local success, error = pcall(onAction, self, player, keydown)
		p({success, error})
	end
end

function Entity:regen()
	if self.resourcesLeft < self.resourceCap then
		local regenAmount = math.floor(os.time() - self.latestActionTimestamp) / 2000
		self.resourcesLeft = math.min(self.resourceCap, self.resourcesLeft + regenAmount)
	end
end

function Entity:destroy()
	-- removing visual hints and marking state as destroyed should be enough
	-- we can't really remove the object because it is cached inside the Area
	-- keeping track of the index isn't going to be an easier task within our implementation
	self.isDestroyed = true
	ui.removeTextArea(self.imageId)
end
