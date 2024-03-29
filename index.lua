--==[[ libs ]]==--

local stringutils = {}
stringutils.format = function(s, tab)
	return (s:gsub('($%b{})',
		function(w) return tab[w:sub(3, -2)] or w end))
	end

stringutils.split = function(s, delimiter)
	result = {}
	for match in (s .. delimiter):gmatch("(.-)" .. delimiter) do
		table.insert(result, match)
	end
	return result
end

table.tostring = function(tbl, depth)
	local res = "{"
	local prev = 0
	for k, v in next, tbl do
		if type(v) == "table" then
			if depth == nil or depth > 0 then
				res =
					res ..
					((type(k) == "number" and prev and prev + 1 == k) and "" or k .. ": ") ..
					table.tostring(v, depth and depth - 1 or nil) .. ", "
			else
				res = res .. k .. ":  {...}, "
			end
		else
			res = res .. ((type(k) == "number" and prev and prev + 1 == k) and "" or k .. ": ") .. tostring(v) .. ", "
		end
		prev = type(k) == "number" and k or nil
	end
	return res:sub(1, res:len() - 2) .. "}"
end

table.map = function(tbl, fn)
	local res = {}
	for k, v in next, tbl do
		res[k] = fn(v)
	end
	return res
end

table.find = function(tbl, val)
	for k, v in next, tbl do
		if v == val then return k end
	end
end

table.copy = function(obj, seen)
	if type(obj) ~= 'table' then return obj end
	if seen and seen[obj] then return seen[obj] end
	local s = seen or {}
	local res = setmetatable({}, getmetatable(obj))
	s[obj] = res
	for k, v in pairs(obj) do res[table.copy(k, s)] = table.copy(v, s) end
	return res
  end

math.pythag = function(x1, y1, x2, y2)
	return ((x1 - x2) ^ 2 + (y1 - y2) ^ 2) ^ (1/2)
end

local _xpcall = xpcall

xpcall = function(f, msgh, arg1, arg2, arg3, arg4, arg5)
	local fWrapper = function()
		return f(arg1, arg2, arg3, arg4, arg5)
	end
	local success = _xpcall(fWrapper, msgh)
	if success then msgh(nil, true) end
end

local prettyify

do

    local typeLookup = {
	    ["string"] = function(obj) return ("<VP>\"%s\"</VP>"):format(obj) end,
	    ["number"] = function(obj) return ("<J>%s</J>"):format(obj) end,
	    ["boolean"] = function(obj) return ("<J>%s</J>"):format(obj) end,
	    ["function"] = function(obj) return ("<b><V>%s</V></b>"):format(obj) end,
	    ["nil"] = function() return ("<G>nil</G>") end
    }

	local string_repeat = function(str, times)
		local res = ""
		while times > 0 do
			res = res .. str
			times = times - 1
		end
		return res
	end

	prettify = function(obj, depth, opt)
	
		opt = opt or {}
		opt.maxDepth = opt.maxDepth or 30
		opt.truncateAt = opt.truncateAt or 30

		local prettifyFn = typeLookup[type(obj)]
		if (prettifyFn) then return { res = (prettifyFn(tostring(obj))), count = 1 } end -- not the type of object ({}, [])

		if depth >= opt.maxDepth then
			return { 
				res = ("<b><V>%s</V></b>"):format(tostring(obj)),
				count = 1
			}
		end

		local kvPairs = {}
		local totalObjects = 0
		local length = 0
		local shouldTruncate = false

		local previousKey = 0

		for key, value in next, obj do

			if not shouldTruncate then
				
				local tn = tonumber(key)
				key = tn and (((previousKey and tn - previousKey == 1) and "" or "[" .. key .. "]:")) or (key .. ":")
				-- we only need to check if the previous key is a number, so a nil key doesn't matter
				previousKey = tn
				local prettified = prettify(value, depth + 1, opt)
				kvPairs[#kvPairs + 1] = key .. " " .. prettified.res

				totalObjects = totalObjects + prettified.count
				if length >= opt.truncateAt then shouldTruncate = true end
			end

			length = length + 1

		end

		if shouldTruncate then kvPairs[#kvPairs] = (" <G><i>... %s more values</i></G>"):format(length - opt.truncateAt) end

		if totalObjects < 6 then
			return { res = "<N>{ " .. table.concat(kvPairs, ", ") .. " }</N>", count = totalObjects }
		else 
			return { res = "<N>{ " .. table.concat(kvPairs, ",\n  " .. string_repeat("  ", depth)) .. " }</N>", count = totalObjects }
		end

	end

end

local prettyprint = function(obj, opt) print(prettify(obj, 0, opt or {}).res) end
local p = prettyprint

-- Credits: lua users wiki
local base64Encode, base64Decode
do
	local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
	-- encoding
	base64Encode = function(data)
		return ((data:gsub('.', function(x) 
			local r,b='',x:byte()
			for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
			return r;
		end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
			if (#x < 6) then return '' end
			local c=0
			for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
			return b:sub(c+1,c+1)
		end)..({ '', '==', '=' })[#data%3+1])
	end
	-- decoding
	base64Decode = function(data)
		data = string.gsub(data, '[^'..b..'=]', '')
		return (data:gsub('.', function(x)
			if (x == '=') then return '' end
			local r,f='',(b:find(x)-1)
			for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
			return r;
		end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
			if (#x ~= 8) then return '' end
			local c=0
			for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
			return string.char(c)
		end))
	end
end


local healthMt = {
	__sub = function(self, amount)
		local player = Player.players[self.playerName]
		if player.isShielded then
			local shield = player.inventory[player.inventorySelection][1]
			amount = amount - shield.defense
			if amount > 0 then
				shield.durability = shield.durability - shield.defense
				self.health = self.health - amount
			else
				shield.durability = shield.durability - 1
			end
			if shield.durability <= 0 then
				player.inventory[player.inventorySelection] = {}
				player:changeInventorySlot(player.inventorySelection)
				player:displayInventory()
			end
		else
			self.health = self.health - amount
		end
		return self
	end,

	__div = function (self, amount)
		return self.health / amount
	end,

	__lt = function(self, amount)
		amount = amount.health
		return self.health < amount
	end,

	__le = function(self, amount)
		amount = amount.health
		return self.health <= amount
	end,

	__gt = function(self, amount)
		amount = amount.health
		return self.health > amount
	end,

	__ge = function(self, amount)
		amount = amount.health
		return self.health >= amount.health
	end
}

local health = function(health, player)
	return setmetatable({ health = health, playerName = player}, healthMt)
end
-- Thanks to Turkitutu
-- https://pastebin.com/raw/Nw3y1A42

bit = {}

bit.lshift = function(x, by) -- Left-shift of x by n bits
	return x * 2 ^ by
end

bit.rshift = function(x, by) -- Logical right-shift of x by n bits
	return math.floor(x / 2 ^ by)
end

bit.band = function(a, b) -- bitwise and of x1, x2
	local p, c = 1, 0
	while a > 0 and b > 0 do
		local ra, rb = a % 2, b % 2
		if ra + rb > 1 then
			c = c + p
		end
		a, b, p = (a - ra) / 2, (b - rb) / 2, p * 2
	end
	return c
end

bit.bxor = function(a,b) -- Bitwise xor of x1, x2
	local r = 0
	for i = 0, 31 do
		local x = a / 2 + b / 2
		if x ~= math.floor(x) then
			r = r + 2^i
		end
		a = math.floor(a / 2)
		b = math.floor(b / 2)
	end
	return r
end

bit.bor = function(a,b) -- Bitwise or of x1, x2
	local p, c= 1, 0
	while a+b > 0 do
		local ra, rb = a % 2, b % 2
		if ra + rb > 0 then
			c = c + p
		end
		a, b, p = (a - ra) / 2, (b - rb) / 2, p * 2
	end
	return c
end

bit.bnot = function(n) -- Bitwise not of x
	local p, c = 1, 0
	while n > 0 do
		local r = n % 2
		if r < 0 then
			c = c + p
		end
		n, p = (n - r) / 2, p * 2
	end
	return c
end

local BitList = {}

BitList.__index = BitList
setmetatable(BitList, {
	__call = function(cls, ...)
		return cls.new(...)
	end
})

do

	function BitList.new(features)
		local self = setmetatable({}, BitList)
		self.featureArray = features

		self.featureKeys = {}

		for k, v in next, features do
			self.featureKeys[v] = k
		end

		self.features = #self.featureArray

		return self
	end

	function BitList:encode(featTbl)
		local res = 0
		for k, v in next, featTbl do
			if v and self.featureKeys[k] then
				res = bit.bor(res, bit.lshift(1, self.featureKeys[k] - 1))
			end
		end
		return res
	end

	function BitList:decode(featInt)
		local features, index = {}, 1
		while (featInt > 0) do
			feat = bit.band(featInt, 1) == 1
			corrFeat = self.featureArray[index]
			features[corrFeat] = feat
			featInt = bit.rshift(featInt, 1)
			index = index + 1
		end
		return features
	end

	function BitList:get(index)
		return self.featureArray[index]
	end

	function BitList:find(feature)
		return self.featureKeys[feature]
	end

end

local Panel = {}
local Image = {}

do


	local string_split = function(s, delimiter)
		result = {}
		for match in (s .. delimiter):gmatch("(.-)" .. delimiter) do
			table.insert(result, match)
		end
		return result
	end

	local table_tostring

	table_tostring = function(tbl, depth)
		local res = "{"
		local prev = 0
		for k, v in next, tbl do
			if type(v) == "table" then
				if depth == nil or depth > 0 then
					res =
						res ..
						((type(k) == "number" and prev and prev + 1 == k) and "" or k .. ": ") ..
						table_tostring(v, depth and depth - 1 or nil) .. ", "
				else
					res = res .. k .. ":  {...}, "
				end
			else
				res = res .. ((type(k) == "number" and prev and prev + 1 == k) and "" or k .. ": ") .. tostring(v) .. ", "
			end
			prev = type(k) == "number" and k or nil
		end
		return res:sub(1, res:len() - 2) .. "}"
	end

	local table_copy = function(tbl)
		local res = {}
		for k, v in next, tbl do res[k] = v end
		return res
	end



	-- [[ class Image ]] --

	Image.__index = Image
	Image.__tostring = function(self) return table_tostring(self) end

	Image.images = {}

	setmetatable(Image, {
		__call = function(cls, ...)
			return cls.new(...)
		end
	})

	function Image.new(imageId, target, x, y, scaleX, scaleY, angle, alpha, anchorX, anchorY)

		local self = setmetatable({
			id = #Image.images + 1,
			imageId = imageId,
			target = target,
			x = x,
			y = y,
			scaleX = scaleX,
			scaleY = scaleY,
			angle = angle,
			alpha = alpha,
			anchorX = anchorX,
			anchorY = anchorY,
			instances = {},
		}, Image)

		Image.images[self.id] = self

		return self

	end

	function Image:show(target)
		if target == nil then error("Target cannot be nil") end
		if self.instances[target] then return self end
		self.instances[target] = tfm.exec.addImage(self.imageId, self.target, self.x, self.y, target, self.scaleX, self.scaleY, self.angle, self.alpha, self.anchorX, self.anchorY)
		return self
	end

	function Image:hide(target)
		if target == nil then error("Target cannot be nil") end
		if not self.instances[target] then return end
		tfm.exec.removeImage(self.instances[target])
		self.instances[target] = nil
		return self
	end

	-- [[ class Panel ]] --

	Panel.__index = Panel
	Panel.__tostring = function(self) return table_tostring(self) end

	Panel.panels = {}

	setmetatable(Panel, {
		__call = function (cls, ...)
			return cls.new(...)
		end,
	})

	function Panel.new(id, text, x, y, w, h, background, border, opacity, fixed, hidden)

		local self = setmetatable({
			id = id,
			text = text,
			x = x,
			y = y,
			w = w,
			h = h,
			background = background,
			border = border,
			opacity = opacity,
			fixed = fixed,
			hidden = hidden,
			isCloseButton = false,
			closeTarget = nil,
			parent = nil,
			onhide = nil,
			onclick = nil,
			children = {},
			temporary = {},
			temporaryListeners = {}
		}, Panel)

		Panel.panels[id] = self

		return self

	end

	function Panel.handleActions(id, name, event)
		local panelId = id - 10000
		local panel = Panel.panels[panelId]
		if not panel then return end
		if panel.isCloseButton then
			if not panel.closeTarget then return end
			panel.closeTarget:hide(name)
			if panel.onhide then panel.onhide(panelId, name, event) end
		else
			if panel.onclick then panel.onclick(panelId, name, event) end
			if panel.temporaryListeners[name] then panel.temporaryListeners[name](panelId, name, event) end
		end
	end

	function Panel:show(target)
		ui.addTextArea(10000 + self.id, self.text, target, self.x, self.y, self.w, self.h, self.background, self.border, self.opacity, self.opacity)
		self.visible = true

		for name in next, (target and { [target] = true } or tfm.get.room.playerList) do
			for id, child in next, self.children do
				child:show(name)
			end
		end

		return self

	end

	function Panel:update(text, target)
		ui.updateTextArea(10000 + self.id, text, target)
		return self
	end

	function Panel:hide(target)

		ui.removeTextArea(10000 + self.id, target)

		for name in next, (target and { [target] = true } or tfm.get.room.playerList) do

			for id, child in next, self.children do
				child:hide(name)
			end

			if self.temporary[name] then
				for id, child in next, self.temporary[name] do
					child:hide(name)
				end
				self.temporary[name] = {}
			end
			--self.temporaryListeners[name] = nil

		end


		if self.onclose then self.onclose(target) end
		return self

	end

	function Panel:addPanel(panel)
		self.children[panel.id] = panel
		panel.parent = self.id
		return self
	end

	function Panel:addImage(image)
		self.children["i_" .. image.id] = image
		return self
	end

	function Panel:addPanelTemp(panel, target)
		if not self.temporary[target] then self.temporary[target] = {} end
		panel:show(target)
		self.temporary[target][panel.id] = panel
		return self
	end

	function Panel:addImageTemp(image, target)
		if not self.temporary[target] then self.temporary[target] = {} end
		image:show(target)
		self.temporary[target]["i_" .. image.id] = image
		return self
	end

	function Panel:setActionListener(fn)
		self.onclick = fn
		return self
	end

	function Panel:setActionListenerTemp(fn, target)
		self.temporaryListeners[target] = fn
		return self
	end

	function Panel:setCloseButton(id, callback)
		local button = Panel.panels[id]
		if not button then return self end
		self.closeTarget = button
		self.onclose = callback
		button.isCloseButton = true
		button.closeTarget = self
		return self
	end

end

-- [[Timers4TFM]] --
local a={}a.__index=a;a._timers={}setmetatable(a,{__call=function(b,...)return b.new(...)end})function a.process()local c=os.time()local d={}for e,f in next,a._timers do if f.isAlive and f.mature<=c then f:call()if f.loop then f:reset()else f:kill()d[#d+1]=e end end end;for e,f in next,d do a._timers[f]=nil end end;function a.new(g,h,i,j,...)local self=setmetatable({},a)self.id=g;self.callback=h;self.timeout=i;self.isAlive=true;self.mature=os.time()+i;self.loop=j;self.args={...}a._timers[g]=self;return self end;function a:setCallback(k)self.callback=k end;function a:addTime(c)self.mature=self.mature+c end;function a:setLoop(j)self.loop=j end;function a:setArgs(...)self.args={...}end;function a:call()self.callback(table.unpack(self.args))end;function a:kill()self.isAlive=false end;function a:reset()self.mature=os.time()+self.timeout end;Timer=a

--[[DataHandler v22]]
local a={}a.VERSION='1.5'a.__index=a;function a.new(b,c,d)local self=setmetatable({},a)assert(b,'Invalid module ID (nil)')assert(b~='','Invalid module ID (empty text)')assert(c,'Invalid skeleton (nil)')for e,f in next,c do f.type=f.type or type(f.default)end;self.players={}self.moduleID=b;self.moduleSkeleton=c;self.moduleIndexes={}self.otherOptions=d;self.otherData={}self.originalStuff={}for e,f in pairs(c)do self.moduleIndexes[f.index]=e end;if self.otherOptions then self.otherModuleIndexes={}for e,f in pairs(self.otherOptions)do self.otherModuleIndexes[e]={}for g,h in pairs(f)do h.type=h.type or type(h.default)self.otherModuleIndexes[e][h.index]=g end end end;return self end;function a.newPlayer(self,i,j)assert(i,'Invalid player name (nil)')assert(i~='','Invalid player name (empty text)')self.players[i]={}self.otherData[i]={}j=j or''local function k(l)local m={}for n in string.gsub(l,'%b{}',function(o)return o:gsub(',','\0')end):gmatch('[^,]+')do n=n:gsub('%z',',')if string.match(n,'^{.-}$')then table.insert(m,k(string.match(n,'^{(.-)}$')))else table.insert(m,tonumber(n)or n)end end;return m end;local function p(c,q)for e,f in pairs(c)do if f.index==q then return e end end;return 0 end;local function r(c)local s=0;for e,f in pairs(c)do if f.index>s then s=f.index end end;return s end;local function t(b,c,u,v)local w=1;local x=r(c)b="__"..b;if v then self.players[i][b]={}end;local function y(n,z,A,B)local C;if z=="number"then C=tonumber(n)or B elseif z=="string"then C=string.match(n and n:gsub('\\"','"')or'',"^\"(.-)\"$")or B elseif z=="table"then C=string.match(n or'',"^{(.-)}$")C=C and k(C)or B elseif z=="boolean"then if n then C=n=='1'else C=B end end;if v then self.players[i][b][A]=C else self.players[i][A]=C end end;if#u>0 then for n in string.gsub(u,'%b{}',function(o)return o:gsub(',','\0')end):gmatch('[^,]+')do n=n:gsub('%z',','):gsub('\9',',')local A=p(c,w)local z=c[A].type;local B=c[A].default;y(n,z,A,B)w=w+1 end end;if w<=x then for D=w,x do local A=p(c,D)local z=c[A].type;local B=c[A].default;y(nil,z,A,B)end end end;local E,F=self:getModuleData(j)self.originalStuff[i]=F;if not E[self.moduleID]then E[self.moduleID]='{}'end;t(self.moduleID,self.moduleSkeleton,E[self.moduleID]:sub(2,-2),false)if self.otherOptions then for b,c in pairs(self.otherOptions)do if not E[b]then local G={}for e,f in pairs(c)do local z=f.type or type(f.default)if z=='string'then G[f.index]='"'..tostring(f.default:gsub('"','\\"'))..'"'elseif z=='table'then G[f.index]='{}'elseif z=='number'then G[f.index]=f.default elseif z=='boolean'then G[f.index]=f.default and'1'or'0'end end;E[b]='{'..table.concat(G,',')..'}'end end end;for b,u in pairs(E)do if b~=self.moduleID then if self.otherOptions and self.otherOptions[b]then t(b,self.otherOptions[b],u:sub(2,-2),true)else self.otherData[i][b]=u end end end end;function a.dumpPlayer(self,i)local m={}local function H(I)local m={}for e,f in pairs(I)do local J=type(f)if J=='table'then m[#m+1]='{'m[#m+1]=H(f)if m[#m]:sub(-1)==','then m[#m]=m[#m]:sub(1,-2)end;m[#m+1]='}'m[#m+1]=','else if J=='string'then m[#m+1]='"'m[#m+1]=f:gsub('"','\\"')m[#m+1]='"'elseif J=='boolean'then m[#m+1]=f and'1'or'0'else m[#m+1]=f end;m[#m+1]=','end end;if m[#m]==','then m[#m]=''end;return table.concat(m)end;local function K(i,b)local m={b,'=','{'}local L=self.players[i]local M=self.moduleIndexes;local N=self.moduleSkeleton;if self.moduleID~=b then M=self.otherModuleIndexes[b]N=self.otherOptions[b]b='__'..b;L=self.players[i][b]end;if not L then return''end;for D=1,#M do local A=M[D]local z=N[A].type;if z=='string'then m[#m+1]='"'m[#m+1]=L[A]:gsub('"','\\"')m[#m+1]='"'elseif z=='number'then m[#m+1]=L[A]elseif z=='boolean'then m[#m+1]=L[A]and'1'or'0'elseif z=='table'then m[#m+1]='{'m[#m+1]=H(L[A])m[#m+1]='}'end;m[#m+1]=','end;if m[#m]==','then m[#m]='}'else m[#m+1]='}'end;return table.concat(m)end;m[#m+1]=K(i,self.moduleID)if self.otherOptions then for e,f in pairs(self.otherOptions)do local u=K(i,e)if u~=''then m[#m+1]=','m[#m+1]=u end end end;for e,f in pairs(self.otherData[i])do m[#m+1]=','m[#m+1]=e;m[#m+1]='='m[#m+1]=f end;return table.concat(m)..self.originalStuff[i]end;function a.get(self,i,A,O)if not O then return self.players[i][A]else assert(self.players[i]['__'..O],'Module data not available ('..O..')')return self.players[i]['__'..O][A]end end;function a.set(self,i,A,C,O)if O then self.players[i]['__'..O][A]=C else self.players[i][A]=C end;return self end;function a.save(self,i)system.savePlayerData(i,self:dumpPlayer(i))end;function a.removeModuleData(self,i,O)assert(O,"Invalid module name (nil)")assert(O~='',"Invalid module name (empty text)")assert(O~=self.moduleID,"Invalid module name (current module data structure)")if self.otherData[i][O]then self.otherData[i][O]=nil;return true else if self.otherOptions and self.otherOptions[O]then self.players[i]['__'..O]=nil;return true end end;return false end;function a.getModuleData(self,l)local m={}for b,u in string.gmatch(l,'([0-9A-Za-z_]+)=(%b{})')do local P=self:getTextBetweenQuotes(u:sub(2,-2))for D=1,#P do P[D]=P[D]:gsub("[%(%)%.%%%+%-%*%?%[%]%^%$]","%%%0")u=u:gsub(P[D],P[D]:gsub(',','\9'))end;m[b]=u end;for e,f in pairs(m)do l=l:gsub(e..'='..f:gsub('\9',','):gsub("[%(%)%.%%%+%-%*%?%[%]%^%$]","%%%0")..',?','')end;return m,l end;function a.convertFromOld(self,Q,R)assert(Q,'Old data is nil')assert(R,'Old skeleton is nil')local function S(l,T)local m={}for U in string.gmatch(l,'[^'..T..']+')do m[#m+1]=U end;return m end;local E=S(Q,'?')local m={}for D=1,#E do local O=E[D]:match('([0-9a-zA-Z]+)=')local u=S(E[D]:gsub(O..'=',''):gsub(',,',',\8,'),',')local G={}for V=1,#u do if R[O][V]then if R[O][V]=='table'then G[#G+1]='{'if u[V]~='\8'then local I=S(u[V],'#')for W=1,#I do G[#G+1]=I[W]G[#G+1]=','end;if G[#G]==','then table.remove(G)end end;G[#G+1]='},'elseif R[O][V]=='string'then G[#G+1]='"'if u[V]~='\8'then G[#G+1]=u[V]end;G[#G+1]='"'G[#G+1]=','else if u[V]~='\8'then G[#G+1]=u[V]else G[#G+1]=0 end;G[#G+1]=','end end end;if G[#G]==','then table.remove(G)end;m[#m+1]=O;m[#m+1]='='m[#m+1]='{'m[#m+1]=table.concat(G)m[#m+1]='}'m[#m+1]=','end;if m[#m]==','then table.remove(m)end;return table.concat(m)end;function a.convertFromDataManager(self,Q,R)assert(Q,'Old data is nil')assert(R,'Old skeleton is nil')local function S(l,T)local m={}for U in string.gmatch(l,'[^'..T..']+')do m[#m+1]=U end;return m end;local E=S(Q,'§')local m={}for D=1,#E do local O=E[D]:match('%[(.-)%]')local u=S(E[D]:gsub('%['..O..'%]%((.-)%)','%1'),'#')local G={}for V=1,#u do if R[V]=='table'then local I=S(u[V],'&')G[#G+1]='{'for W=1,#I do if tonumber(I[W])then G[#G+1]=I[W]G[#G+1]=','else G[#G+1]='"'G[#G+1]=I[W]G[#G+1]='"'G[#G+1]=','end end;if G[#G]==','then table.remove(G)end;G[#G+1]='}'G[#G+1]=','else if R[V]=='string'then G[#G+1]='"'G[#G+1]=u[V]G[#G+1]='"'else G[#G+1]=u[V]end;G[#G+1]=','end end;if G[#G]==','then table.remove(G)end;m[#m+1]=O;m[#m+1]='='m[#m+1]='{'m[#m+1]=table.concat(G)m[#m+1]='}'end;return table.concat(m)end;function a.getTextBetweenQuotes(self,l)local m={}local X=1;local Y=0;local Z=false;for D=1,#l do local _=l:sub(D,D)if _=='"'then if l:sub(D-1,D-1)~='\\'then if Y==0 then X=D;Y=Y+1 else Y=Y-1;if Y==0 then m[#m+1]=l:sub(X,D)end end end end end;return m end;DataHandler=a

--[[ Makinit's XML library ]]--
local a="Makinit's XML library"local b="[%a_:][%w%.%-_:]*"function parseXml(c,d)if not d then c=string.gsub(c,"<!%[CDATA%[(.-)%]%]>",xmlEscape)c=string.gsub(c,"<%?.-%?>","")c=string.gsub(c,"<!%-%-.-%-%->","")c=string.gsub(c,"<!.->","")end;local e={}local f={}local g=e;for h,i,j,k,l in string.gmatch(c,"<(/?)("..b..")(.-)(/?)>%s*([^<]*)%s*")do if h=="/"then local m=f[g]if m and i==g.name then g=m end else local n={name=i,attribute={}}table.insert(g,n)f[n]=g;if k~="/"then g=n end;for i,o in string.gmatch(j,"("..b..")%s*=%s*\"(.-)\"")do n.attribute[i]=d and o or xmlUnescape(o)end end;if l~=""then local n={text=d and l or xmlUnescape(l)}table.insert(g,n)f[n]=g end end;return e[1]end;function generateXml(g,d)if g.name then local c="<"..g.name;for i,o in pairs(g.attribute)do c=c.." "..i.."=\""..(d and tostring(o)or xmlEscape(tostring(o))).."\""end;if#g==0 then c=c.." />"else c=c..">"for p,n in ipairs(g)do c=c..generateXml(n,d)end;c=c.."</"..g.name..">"end;return c elseif g.text then return d and tostring(g.text)or xmlEscape(tostring(g.text))end end;function path(q,...)q={q}for p,i in ipairs(arg)do local r={}for p,s in ipairs(q)do for p,n in ipairs(s)do if n.name==i then table.insert(r,n)end end end;q=r end;return q end;local t={}function xmlEscape(u)local v=t[u]if not v then local w=string.gsub;v=w(u,"&","&amp;")v=w(v,"\"","&quot;")v=w(v,"'","&apos;")v=w(v,"<","&lt;")v=w(v,">","&gt;")t[u]=v end;return v end;local x={}function xmlUnescape(u)local v=x[u]if not v then local w=string.gsub;v=w(u,"&quot;","\"")v=w(v,"&apos;","'")v=w(v,"&lt;","<")v=w(v,"&gt;",">")v=w(v,"&#(%d%d?%d?%d?);",dec2char)v=w(v,"&#x(%x%x?%x?%x?);",hex2char)v=w(v,"&amp;","&")x[u]=v end;return v end;function dec2char(y)y=tonumber(y)return string.char(y>255 and 0 or y)end;function hex2char(y)y=tonumber(y,16)return string.char(y>255 and 0 or y)end

local quests = {
	--[[
		struture:

		name:
			stage: tasksAmount
		..
	]]
	wc = {
		id = 1,
		title_locales = {
			ar = "شخص جديد في البلدة",
			en = "New person in the town",
			pl = "Nowa osoba w mieście",
			ro = "Un nou vizitator în oraș",
			tr = "Şehirdeki yeni kişi",
			es = "Alguien nuevo en el poblado",
			cn = "城市中的新脸孔",
			zh = "城市中的新臉孔",
			ru = "Новый человек в городе",
			br = "Nova pessoa na cidade",
			pt = "Nova pessoa na cidade",
			hu = "Új egér a városban",
		},
		{
			description_locales = {
				ar = "سافر من وقت لآخر إلى بلدة في العصور الوسطى",
				en = "Travel back from time to a town in the medieval era",
				pl = "Cofnij się w czasie do średniowiecznego miasta",
				ro = "Călătorește înapoi în timp într-un orășel din evul mediu",
				tr = "Ortaçağ döneminde bulunan bir şehire zamanda geri git",
				es = "Viaja atrás en el tiempo hacia un poblado en la época medieval",
				cn = "时光倒流回到中世纪的城市",
				zh = "時光倒流回到中世紀的城市",
				ru = "Путешествуй во времени в средневековье",
				br = "Viaje de volta no tempo para uma pequena cidade medieval",
				pt = "Viaje de volta no tempo para uma pequena cidade medieval",
				hu = "Utazz vissza az időben egy középkori városba",
			},

			tasks = 1
		}
	},

	nosferatu = {
		id = 2,
		title_locales = {
			ar = "الخادم المخلص",
			en = "The loyal servant",
			pl = "Lojalny sługa",
			ro = "Servitorul regal",
			tr = "Sadık hizmetçi",
			es = "El sirviente leal",
			cn = "忠心的仆人",
			zh = "忠心的僕人",
			ru = "Верный слуга",
			br = "O servo leal",
			pt = "O servo leal",
			hu = "A hűséges szolga",
		},
		{
			description_locales = {
			ar = "قابل نوسفيراتو في المنجم",
			en = "Meet Nosferatu at the mine",
			pl = "potkaj się z Nosferatu w kopalni",
			ro = "Întâlnește-l pe Nosferatu lângă mină",
			tr = "Madende Nosferatu ile buluş",
			es = "Ve con Nosferatu a la mina",
			cn = "在洞穴中跟 Nosferatu 见面",
			zh = "在洞穴中跟 Nosferatu 見面",
			ru = "Встреться с Носферату у шахты",
			br = "Conheça Nosferatu na mina",
			pt = "Conheça Nosferatu na mina",
			hu = "Találkozz Nosferatu-val a bányában",
			},
			tasks = 1
		},
		{
			description_locales = {
				ar = "اجمع 15 قطعة خشب",
				en = "Gather 15 wood",
				pl = "Zbierz 15 drewien",
				ro = "Adună 15 lemne",
				tr = "15 odun topla",
				es = "Recolecta 15 de madera",
				cn = "收集 15 个木头",
				zh = "收集 15 個木頭",
				ru = "Раздобудь 15 древесины",
				br = "Recolha 15 madeiras",
				pt = "Recolha 15 madeiras",
				hu = "Gyűjts 15 fát",
			},
			tasks = 1
		},
		{
			description_locales = {
				ar = "اجمع 15 خام حديد",
				en = "Gather 15 iron ore",
				pl = "Zbierz 15 rud żelaza",
				ro = "Adună 15 minereuri de fier",
				tr = "15 demir cevheri topla",
				es = "Recolecta 15 lingotes de hierro",
				cn = "收集 15 个铁矿石",
				zh = "收集 15 個鐵礦石",
				ru = "Раздобудь 15 железа",
				br = "Recolha 15 minério de ferro",
				pt = "Recolha 15 minério de ferro",
				hu = "Gyűjts 15 vasércet",
			},
			tasks = 1
		}
	},

	strength_test = {
		id = 3,
		title_locales = {
			ar = "إختبار القوة",
			en = "Strength test",
			pl = "Test siły",
			ro = "Testul forței",
			tr = "Sağlamlık testi",
			es = "Test de fuerza",
			cn = "力量测试",
			zh = "力量測試",
			ru = "Испытание силы",
			br = "Teste de resistência",
			pt = "Teste de resistência",
			hu = "Az erőmérő próba",
		},
		{
			description_locales = {
				ar = "اجمع الوصفات وتحدث إلى الملازم إدريك",
				en = "Gather recipes and talk to Lieutenant Edric",
				pl = "Zbierz przepisy i porozmawiaj z porucznikiem Edriciem",
				ro = "Adună rețete pentru a vorbi cu Locotenentul Edric",
				tr = "Tarifleri elde et ve Lieutenant Edric ile konuş",
				es = "Recolecta recetas y habla con el Teniente Edric",
				cn = "收集物品制作方法然后跟 Lieutenant Edric 说话",
				zh = "收集物品製作方法然後跟 Lieutenant Edric 說話",
				ru = "Найди рецепты и поговори с Лейтенантом Эдриком",
				br = "Junte as receitas e fale com o Tenente Edric",
				pt = "Junte as receitas e fale com o Tenente Edric",
				hu = "Gyűjts recepteket, és beszélj Edric Hadnaggyal",
			},
			tasks = 1
		},
		{
			description_locales = {
				ar = "اهزم 25 وحشًا",
				en = "Defeat 25 monsters",
				pl = "Pokonaj 25 potworów",
				ro = "Înfrânge 25 monștri",
				tr = "25 canavar yen",
				es = "Derrota 25 monstruos",
				cn = "打败 25 个怪物",
				zh = "打敗 25 個怪物",
				ru = "Одолей 25 монстров",
				br = "Destrua 25 monstros",
				pt = "Destrua 25 monstros",
				hu = "Ölj meg 25 szörnyet",
			},
			tasks = 25
		},
		{
			description_locales = {
				ar = "قابل الملازم إدريك مرة أخرى",
				en = "Meet Lieutenant Edric back",
				pl = "Spotkaj się z powrotem z porucznikiem Edriciem",
				ro = "Întâlnește Locotenentul Edric din nou",
				tr = "Tekrar Lieutenant Edric ile buluş",
				es = "Ve con el Teniente Edric de vuelta",
				cn = "回去跟 Lieutenant Edric 见面",
				zh = "回去跟 Lieutenant Edric 見面",
				ru = "Встреться с Лейтенантом Эдриком снова",
				br = "Conheça o Tenente Edric.",
				pt = "Conheça o Tenente Edric.",
				hu = "Találkozz Edric Hadnaggyal",
			},
			tasks = 1
		}
	},

	spiritOrbs = {
		id = 4,
		title_locales = {
			ar = "الطريق الروحي",
			en = "The spiritual way",
			pl = "Droga duchowa",
			ro = "Calea spirituală",
			tr = "Ruhani yol",
			es = "El camino espiritual",
			cn = "灵性旅途",
			zh = "靈性旅途",
			ru = "Духовный путь",
			br = "O caminho espiritual",
			pt = "O caminho espiritual",
			hu = "A szellemi út",
		},
		{
			description_locales = {
				ar = "اذهب إلى الغابة القاتمة",
				en = "Go to the gloomy forest",
				pl = "Udaj się do ponurego lasu",
				ro = "Intră în pădurea mohorâtă",
				tr = "Kasvetli ormana git",
				es = "Ve al bosque sombrío",
				cn = "前往阴沉森林",
				zh = "前往陰沉森林",
				ru = "Иди в мрачный лес",
				br = "Dirigira-se à floresta sombria",
				pt = "Dirigira-se à floresta sombria",
				hu = "Menj a sötét erdőbe",
			},
			tasks = 1
		},
		{
			description_locales = {
				ar = "ابحث عن الصوت الغامض",
				en = "Find the mysterious voice",
				pl = "Znajdź tajemniczy głos",
				ro = "Găsește vocea misterioasă",
				tr = "Gizemli sesi bul",
				es = "Encuentra la voz misteriosa",
				cn = "找出谜之声音",
				zh = "找出謎之聲音",
				ru = "Найди загадочный голос",
				br = "Encontre a voz misteriosa",
				pt = "Encontre a voz misteriosa",
				hu = "Találd meg a rejtélyes hangot",
			},
			tasks = 1
		},
		{
			description_locales = {
				ar = "اجمع كل الأجرام السماوية الخمسة",
				en = "Gather all 5 spirit orbs",
				pl = "Zbierz wszystkie 5 duchowych kul",
				ro = "Adună toate 5 globuri",
				tr = "Tüm 5 ruh küresini topla",
				es = "Recolecta las 5 orbes espirituales",
				cn = "收集全部 5 个灵体球",
				zh = "收集全部 5 個靈體球",
				ru = "Найди все 5 сфер душ",
				br = "Junte as 5 orbes espirituosas",
				pt = "Junte as 5 orbes espirituosas",
				hu = "Gyűjts össze mind az 5 lélekgömböt",
			},
			tasks = 5
		}
	},

	fiery_dragon = {
		id = 5,
		title_locales = {
			ar = "مقاومة النار",
			en = "Resisting the fire",
			pl = "Odporność na ogień",
			ro = "Rezistând focului",
			tr = "Ateşe direnmek",
			es = "Resistiendo al fuego",
			cn = "抵抗火炎",
			zh = "抵抗火炎",
			ru = "Устаивая огню",
			br = "Resista ao fogo",
			pt = "Resista ao fogo",
			hu = "A tűz ellenállása",
		},
		{
			description_locales = {
				ar = "تدمير التنين الناري وجمع الجرم السماوي الروحي",
				en = "Destroy the fiery dragon and collect its spirit orb",
				pl = "Zniszcz ognistego smoka i zbierz jego duchową kulę",
				ro = "Distruge Dragonul de foc și pune mâna pe globul său de spirit",
				tr = "Alevli ejderhayı yok et ve ruh küresini elde et",
				es = "Destruye al dragón de fuego y recolecta su orbe espiritual",
				cn = "打败喷火龙然后收集它的灵体球",
				zh = "打敗噴火龍然後收集它的靈體球",
				ru = "Уничтожь дракона и добудь его сферу души",
				br = "Destrua o dragão de fogo e recolha a sua orbe espiritual",
				pt = "Destrua o dragão de fogo e recolha a sua orbe espiritual",
				hu = "Küzdj meg a tüzes sárkánnyal, és gyűjtsd be a lélekgömbjét",
			},
			tasks = 1
		}
	},

	final_boss = {
		id = 6,
		title_locales = {
			ar = "بطل العصور الوسطى",
			en = "Medieval hero",
			pl = "Średniowieczny bohater",
			ro = "Erou medieval",
			tr = "Ortaçağın kahramanı",
			es = "Héroe medieval",
			cn = "中世纪英雄",
			zh = "中世紀英雄",
			ru = "Герой средневековья",
			br = "Herói medieval",
			pt = "Herói medieval",
			hu = "Középkori hős",
		},
		{
			description_locales = {
				ar = "اهلك الروح الشريرة",
				en = "Destroy the evil spirit",
				pl = "Zniszcz złego ducha",
				ro = "Distruge spiritul răului",
				tr = "Kötü ruhu yok et",
				es = "Destruye el espíritu malvado",
				cn = "毁灭邪恶力量",
				zh = "毀滅邪惡力量",
				ru = "Уничтожь злой дух",
				br = "Destrua o espírito maligno",
				pt = "Destrua o espírito maligno",
				hu = "Győzdd le a gonosz szellemet",
			},
			tasks = 1
		}
	},

	_all = { "wc", "nosferatu", "strength_test", "spiritOrbs", "fiery_dragon", "final_boss" }

}

--==[[ init ]]==--

local IS_TEST = true

tfm.exec.disableAfkDeath()
tfm.exec.disableAutoShaman()
tfm.exec.disablePhysicalConsumables()
tfm.exec.disableWatchCommand()

system.luaEventLaunchInterval(40)
system.setLuaEventBanner(28)

math.randomseed(os.time())
-- NOTE: Sometimes the script is loaded twice in the same round (detect it when eventNewGame is called twice). You must use system.exit() is this case, because it doesn't load the player data correctly, and the textareas (are duplicated) doesn't trigger eventTextAreaCallback.
local eventLoaded, mapLoaded, eventEnding = false, false, false
local mapPlaying = ""

-- final boss battle
local bossBattleTriggered, divineChargeTimeOver, divinePowerCasted = false, false, false
local divinePowerCharge = 0
local FINAL_BOSS_ATK_MAX_CHARGE = 2000

local maps = {
	mine = [[<C><P L="1622" H="1720" APS="17f322853ac.png,,820,1329,800,317,0,800" Ca="" MEDATA="67,1;;;;0,6-0;0:::1-"/><Z><S><S T="1" X="1628" Y="1208" L="10" H="2016" P="0,0,0,0.2,2880,0,0,0" m=""/><S T="1" X="-7" Y="1296" L="10" H="2016" P="0,0,0,0.2,2880,0,0,0" m=""/><S T="0" X="5" Y="805" L="11" H="10" P="0,0,0.3,0.2,2880,0,0,0" c="4" nosync="" i="0,0,17f32282dfc.png"/><S T="0" X="30" Y="1002" L="61" H="10" P="0,0,0.3,0.2,2890,0,0,0" m=""/><S T="0" X="85" Y="1021" L="59" H="10" P="0,0,0.3,0.2,2910,0,0,0" m=""/><S T="0" X="149" Y="1119" L="139" H="10" P="0,0,6,0.2,2950,0,0,0" m=""/><S T="0" X="119" Y="1046" L="26" H="10" P="0,0,0.3,0.2,2930,0,0,0" m=""/><S T="0" X="209" Y="1199" L="102" H="10" P="0,0,0.3,0.2,2918,0,0,0" m=""/><S T="0" X="264" Y="1253" L="57" H="10" P="0,0,0.3,0.2,2950,0,0,0" m=""/><S T="0" X="298" Y="1309" L="79" H="10" P="0,0,0.3,0.2,2930,0,0,0" m=""/><S T="12" X="801" Y="315" L="723" H="542" P="0,0,0.3,0.2,0,0,0,0" o="322226" c="2"/><S T="0" X="321" Y="1362" L="49" H="10" P="0,0,0.3,0.2,2970,0,0,0" m=""/><S T="0" X="524" Y="1335" L="230" H="10" P="0,0,0.3,0.2,2860,0,0,0" m=""/><S T="0" X="1237" Y="1257" L="80" H="10" P="0,0,0.3,0.2,2860,0,0,0" m=""/><S T="0" X="1305" Y="1256" L="80" H="10" P="0,0,0.3,0.2,2890,0,0,0" m=""/><S T="0" X="1382" Y="1277" L="80" H="10" P="0,0,0.3,0.2,2900,0,0,0" m=""/><S T="0" X="1457" Y="1280" L="80" H="10" P="0,0,0.3,0.2,2860,0,0,0" m=""/><S T="0" X="1541" Y="1269" L="80" H="10" P="0,0,0.3,0.2,2880,0,0,0" m=""/><S T="0" X="1588" Y="1258" L="80" H="10" P="0,0,0.3,0.2,2870,0,0,0" m=""/><S T="0" X="723" Y="1508" L="82" H="10" P="0,0,0.3,0.2,2860,0,0,0" m=""/><S T="0" X="644" Y="1512" L="58" H="10" P="0,0,0.3,0.2,2870,0,0,0" m=""/><S T="0" X="792" Y="1468" L="82" H="10" P="0,0,0.3,0.2,2840,0,0,0" m=""/><S T="0" X="614" Y="1563" L="82" H="10" P="0,0,0.3,0.2,2840,0,0,0" m=""/><S T="0" X="827" Y="1417" L="82" H="10" P="0,0,0.3,0.2,2820,0,0,0" m=""/><S T="0" X="883" Y="1364" L="82" H="10" P="0,0,0.3,0.2,2850,0,0,0" m=""/><S T="0" X="909" Y="1344" L="63" H="10" P="0,0,0.3,0.2,2850,0,0,0" m=""/><S T="0" X="972" Y="1334" L="63" H="10" P="0,0,0.3,0.2,2890,0,0,0" m=""/><S T="0" X="1024" Y="1344" L="63" H="10" P="0,0,0.3,0.2,2880,0,0,0" m=""/><S T="0" X="1072" Y="1334" L="65" H="10" P="0,0,0.3,0.2,2857,0,0,0" m=""/><S T="0" X="1108" Y="1318" L="65" H="10" P="0,0,0.3,0.2,2837,0,0,0" m=""/><S T="0" X="1162" Y="1294" L="65" H="10" P="0,0,0.3,0.2,2877,0,0,0" m=""/><S T="0" X="1174" Y="1286" L="65" H="10" P="0,0,0.3,0.2,2847,0,0,0" m=""/><S T="0" X="915" Y="1354" L="82" H="28" P="0,0,0.3,0.2,2880,0,0,0" m=""/><S T="0" X="235" Y="1458" L="230" H="10" P="0,0,0.3,0.2,2840,0,0,0" m=""/><S T="0" X="667" Y="1274" L="88" H="10" P="0,0,0.3,0.2,2850,0,0,0" m=""/><S T="0" X="778" Y="1225" L="163" H="10" P="0,0,1.2,0.2,2860,0,0,0" m=""/><S T="0" X="957" Y="1198" L="212" H="10" P="0,0,0.3,0.2,2880,0,0,0" m=""/><S T="0" X="1082" Y="1190" L="54" H="10" P="0,0,0.3,0.2,2860,0,0,0" m=""/><S T="0" X="1130" Y="1180" L="69" H="10" P="0,0,0.3,0.2,2840,0,0,0" m=""/><S T="0" X="1193" Y="1146" L="85" H="12" P="0,0,0.3,0.2,2860,0,0,0" m=""/><S T="0" X="1237" Y="1133" L="67" H="10" P="0,0,0.3,0.2,2800,0,0,0" m=""/><S T="0" X="1314" Y="1063" L="161" H="10" P="0,0,0.3,0.2,2850,0,0,0" m=""/><S T="0" X="1430" Y="1014" L="94" H="10" P="0,0,0.3,0.2,2870,0,0,0" m=""/><S T="0" X="1532" Y="1007" L="113" H="10" P="0,0,0.3,0.2,2880,0,0,0" m=""/><S T="0" X="1602" Y="1010" L="34" H="10" P="0,0,0.3,0.2,2890,0,0,0" m=""/><S T="4" X="356" Y="1476" L="10" H="235" P="0,0,20,0.2,2910,0,0,0" m=""/><S T="0" X="900" Y="1644" L="1800" H="22" P="0,0,0.3,0.2,2880,0,0,0" m=""/><S T="0" X="894" Y="1662" L="136" H="10" P="0,0,0.3,0.2,2840,0,0,0" m=""/><S T="0" X="1003" Y="1611" L="121" H="10" P="0,0,0.3,0.2,2870,0,0,0" m=""/><S T="0" X="1121" Y="1595" L="118" H="10" P="0,0,0.3,0.2,2875,0,0,0" m=""/><S T="0" X="1528" Y="1650" L="118" H="10" P="0,0,0.3,0.2,2915,0,0,0" m=""/><S T="0" X="1332" Y="1604" L="314" H="10" P="0,0,0.3,0.2,2885,0,0,0" m=""/><S T="0" X="267" Y="1625" L="200" H="10" P="0,0,0.3,0.2,2900,0,0,0" m=""/><S T="0" X="86" Y="1625" L="200" H="10" P="0,0,0.3,0.2,2860,0,0,0" m=""/><S T="8" X="1263" Y="1444" L="718" H="449" P="0,0,0.3,0.2,0,0,0,0" c="4" m="" lua="2"/><S T="8" X="154" Y="1049" L="302" H="499" P="0,0,0.3,0.2,0,0,0,0" c="4" m="" lua="3"/><S T="8" X="730" Y="1195" L="264" H="151" P="0,0,0.3,0.2,0,0,0,0" c="2" m="" lua="4"/><S T="8" X="804" Y="313" L="670" H="520" P="0,0,0.3,0.2,5400,0,0,0" c="2" m="" lua="7"/><S T="5" X="470" Y="123" L="154" H="42" P="0,0,0.3,0.2,90,0,0,0"/><S T="5" X="1140" Y="123" L="154" H="42" P="0,0,0.3,0.2,-90,0,0,0"/><S T="5" X="491" Y="90" L="91" H="31" P="0,0,0.3,0.2,110,0,0,0"/><S T="5" X="471" Y="337" L="91" H="31" P="0,0,0.3,0.2,110,0,0,0"/><S T="5" X="490" Y="333" L="91" H="31" P="0,0,0.3,0.2,130,0,0,0"/><S T="5" X="1124" Y="346" L="91" H="31" P="0,0,0.3,0.2,90,0,0,0"/><S T="5" X="1119" Y="90" L="91" H="31" P="0,0,0.3,0.2,-110,0,0,0"/><S T="5" X="512" Y="82" L="78" H="42" P="0,0,0.3,0.2,150,0,0,0"/><S T="5" X="1098" Y="82" L="78" H="42" P="0,0,0.3,0.2,-150,0,0,0"/><S T="8" X="1239" Y="1062" L="765" H="299" P="0,0,0.3,0.2,0,0,0,0" c="4" m="" lua="5"/><S T="8" X="75" Y="1599" L="157" H="107" P="0,0,0.3,0.2,0,0,0,0" c="4" m="" lua="6"/><S T="8" X="563" Y="1594" L="157" H="107" P="0,0,0.3,0.2,0,0,0,0" c="4" m="" lua="8"/><S T="5" X="922" Y="214" L="110" H="23" P="0,0,0.3,0.2,140,0,0,0"/><S T="5" X="569" Y="257" L="58" H="23" P="0,0,0.3,0.2,90,0,0,0"/><S T="5" X="858" Y="256" L="58" H="23" P="0,0,0.3,0.2,160,0,0,0"/><S T="5" X="1045" Y="227" L="49" H="23" P="0,0,0.3,0.2,180,0,0,0"/><S T="5" X="999" Y="206" L="74" H="23" P="0,0,0.3,0.2,220,0,0,0"/><S T="5" X="902" Y="408" L="58" H="23" P="0,0,0.3,0.2,90,0,0,0"/><S T="5" X="563" Y="294" L="196" H="23" P="0,0,0.3,0.2,0,0,0,0"/><S T="5" X="728" Y="338" L="101" H="23" P="0,0,0.3,0.2,-50,0,0,0"/><S T="5" X="653" Y="372" L="101" H="23" P="0,0,0.3,0.2,0,0,0,0"/><S T="5" X="874" Y="370" L="80" H="23" P="0,0,0.3,0.2,0,0,0,0"/><S T="5" X="1098" Y="336" L="101" H="23" P="0,0,0.3,0.2,-50,0,0,0"/><S T="5" X="1110" Y="348" L="47" H="23" P="0,0,0.3,0.2,-50,0,0,0"/><S T="5" X="1101" Y="450" L="156" H="23" P="0,0,0.3,0.2,280,0,0,0"/><S T="5" X="823" Y="196" L="101" H="23" P="0,0,0.3,0.2,-20,0,0,0"/><S T="5" X="644" Y="194" L="45" H="23" P="0,0,0.3,0.2,150,0,0,0"/><S T="5" X="733" Y="143" L="33" H="23" P="0,0,0.3,0.2,150,0,0,0"/><S T="5" X="835" Y="103" L="195" H="23" P="0,0,0.3,0.2,160,0,0,0"/><S T="5" X="637" Y="120" L="157" H="23" P="0,0,0.3,0.2,240,0,0,0"/><S T="5" X="918" Y="179" L="101" H="23" P="0,0,0.3,0.2,0,0,0,0"/><S T="5" X="1064" Y="370" L="161" H="23" P="0,0,0.3,0.2,0,0,0,0"/><S T="5" X="978" Y="127" L="129" H="23" P="0,0,0.3,0.2,-90,0,0,0"/><S T="5" X="938" Y="511" L="129" H="23" P="0,0,0.3,0.2,-90,0,0,0"/><S T="5" X="799" Y="339" L="111" H="23" P="0,0,0.3,0.2,-140,0,0,0"/><S T="5" X="746" Y="270" L="81" H="23" P="0,0,0.3,0.2,70,0,0,0"/><S T="5" X="611" Y="463" L="101" H="23" P="0,0,0.3,0.2,0,0,0,0"/><S T="5" X="763" Y="499" L="101" H="23" P="0,0,0.3,0.2,-90,0,0,0"/><S T="5" X="941" Y="448" L="101" H="23" P="0,0,0.3,0.2,-180,0,0,0"/><S T="5" X="816" Y="526" L="101" H="23" P="0,0,0.3,0.2,20,0,0,0"/><S T="5" X="497" Y="351" L="138" H="23" P="0,0,0.3,0.2,130,0,0,0"/><S T="5" X="508" Y="431" L="138" H="23" P="0,0,0.3,0.2,210,0,0,0"/><S T="5" X="469" Y="494" L="156" H="23" P="0,0,0.3,0.2,270,0,0,0"/><S T="5" X="544" Y="548" L="156" H="23" P="0,0,0.3,0.2,350,0,0,0"/><S T="5" X="592" Y="557" L="156" H="23" P="0,0,0.3,0.2,360,0,0,0"/><S T="5" X="883" Y="546" L="528" H="44" P="0,0,0.3,0.2,360,0,0,0"/><S T="5" X="1047" Y="294" L="196" H="23" P="0,0,0.3,0.2,0,0,0,0"/><S T="5" X="451" Y="313" L="30" H="550" P="0,0,0.3,0.2,0,0,0,0"/><S T="5" X="478" Y="240" L="94" H="26" P="0,0,0.3,0.2,90,0,0,0"/><S T="5" X="1123" Y="457" L="163" H="26" P="0,0,0.3,0.2,90,0,0,0"/><S T="5" X="1112" Y="492" L="163" H="26" P="0,0,0.3,0.2,110,0,0,0"/><S T="5" X="1132" Y="240" L="94" H="26" P="0,0,0.3,0.2,-90,0,0,0"/><S T="5" X="1124" Y="175" L="130" H="23" P="0,0,0.3,0.2,-110,0,0,0"/><S T="5" X="808" Y="575" L="700" H="26" P="0,0,0.3,0.2,0,0,0,0"/><S T="5" X="804" Y="76" L="526" H="23" P="0,0,0.3,0.2,0,0,0,0"/><S T="5" X="492" Y="158" L="94" H="23" P="0,0,0.3,0.2,110,0,0,0"/><S T="5" X="540" Y="88" L="94" H="23" P="0,0,0.3,0.2,140,0,0,0"/><S T="5" X="1150" Y="313" L="32" H="550" P="0,0,0.3,0.2,0,0,0,0"/><S T="5" X="1070" Y="88" L="94" H="23" P="0,0,0.3,0.2,-140,0,0,0"/><S T="5" X="815" Y="52" L="700" H="28" P="0,0,0.3,0.2,0,0,0,0"/><S T="12" X="812" Y="1751" L="1640" H="207" P="0,0,0.3,0.2,0,0,0,0" o="533d2e"/><S T="1" X="612" Y="1543" L="14" H="58" P="0,0,0,0.2,16,0,0,0" m=""/><S T="12" X="813" Y="737" L="1643" H="125" P="0,0,0.3,0.2,0,0,0,0" o="BAD9E8"/></S><D><DS X="903" Y="1168"/></D><O><O X="19" Y="1008" C="22" nosync="" P="0" type="tree"/><O X="93" Y="1033" C="22" nosync="" P="0" type="tree"/><O X="189" Y="1186" C="22" nosync="" P="0" type="tree"/><O X="1340" Y="1580" C="22" nosync="" P="0" type="npc" name="nosferatu"/><O X="954" Y="1180" C="22" nosync="" P="0" type="npc" name="laura"/><O X="708" Y="505" C="22" nosync="" P="0" type="npc" name="garry"/><O X="856" Y="506" C="22" nosync="" P="0" type="npc" name="thompson"/><O X="763" Y="1206" C="22" nosync="" P="0" type="craft_table"/><O X="499" Y="1601" C="22" nosync="" P="0" type="recipe" name="basic_axe"/><O X="1596" Y="1241" C="22" nosync="" P="0" type="recipe" name="copper_shovel"/><O X="1569" Y="1247" C="22" nosync="" P="0" type="recipe" name="copper_axe"/><O X="950" Y="114" C="22" nosync="" P="0" type="recipe" name="iron_shovel"/><O X="1434" Y="1594" C="22" nosync="" P="0" type="recipe" name="log_stakes"/><O X="956" Y="154" C="22" nosync="" P="0" type="spirit_orb" name="1"/><O X="1057" Y="332" C="22" nosync="" P="0" type="recipe" name="basic_shovel"/><O X="15" Y="960" C="22" nosync="" P="0" type="recipe" name="iron_axe"/><O X="1449" Y="996" C="22" nosync="" P="0" type="rock"/><O X="1554" Y="981" C="22" nosync="" P="0" type="rock"/><O X="1296" Y="1067" C="22" nosync="" P="0" type="rock"/><O X="1535" Y="1599" C="11" nosync="" P="0" type="teleport" route="mine" id="1"/><O X="510" Y="519" C="11" nosync="" P="0" type="teleport" route="mine" id="2"/><O X="1027" Y="1188" C="22" nosync="" P="0" type="tree"/><O X="56" Y="1605" C="22" nosync="" P="0" type="tree"/><O X="584" Y="431" C="22" nosync="" P="0" type="rock"/><O X="521" Y="264" C="22" nosync="" P="0" type="rock"/><O X="629" Y="169" C="22" nosync="" P="0" type="copper_ore"/><O X="782" Y="100" C="22" nosync="" P="0" type="gold_ore"/><O X="888" Y="208" C="22" nosync="" P="0" type="copper_ore"/><O X="1031" Y="189" C="22" nosync="" P="0" type="iron_ore"/><O X="856" Y="342" C="22" nosync="" P="0" type="rock"/><O X="1053" Y="507" C="22" nosync="" P="0" type="rock"/><O X="1004" Y="504" C="22" nosync="" P="0" type="rock"/><O X="933" Y="417" C="22" nosync="" P="0" type="iron_ore"/></O><L/></Z></C>]],
	castle = [[<C><P L="2000" H="6000" d="x_deadmeat/x_pictos/d_2297.png,1465,471;x_deadmeat/x_pictos/d_2297.png,1167,742;x_deadmeat/x_pictos/d_2297.png,346,441;x_deadmeat/x_pictos/d_2297.png,-22,760;x_deadmeat/x_pictos/d_2297.png,360,1055;x_deadmeat/x_pictos/d_2297.png,786,803;x_deadmeat/x_pictos/d_2297.png,1371,1025;x_deadmeat/x_pictos/d_2297.png,462,1247;x_deadmeat/x_pictos/d_2297.png,1171,1659;x_deadmeat/x_pictos/d_2297.png,1349,1606;x_deadmeat/x_pictos/d_2297.png,259,1767;x_deadmeat/x_pictos/d_2297.png,-11,1270;tfmadv/meli/fougere4.png,1924,1248;tfmadv/picto/marais/roseau3.png,687,453;tfmadv/picto/marais/herbe5.png,1462,909;tfmadv/picto/marais/herbe5.png,1094,1721;tfmadv/picto/marais/herbe5.png,530,868;tfmadv/picto/marais/herbe5.png,63,690;tfmadv/picto/foret/pomme-pin.png,887,750;tfmadv/picto/foret/herbe2.png,1060,1064;tfmadv/picto/foret/herbe2.png,567,765;tfmadv/picto/souris/tasbois_horizontal.png,197,744;tfmadv/picto/souris/tasbois_horizontal.png,406,1783;tfmadv/picto/souris/tasbois_horizontal.png,1451,1049;tfmadv/picto/marais/herbe2.png,1168,758;tfmadv/picto/marais/herbe2.png,597,1379;tfmadv/picto/marais/herbe2.png,378,1061;tfmadv/picto/marais/trefles2.png,1432,510;tfmadv/picto/marais/trefles.png,-97,864;tfmadv/picto/marais/test/plante3_moyenne.png,824,1107;tfmadv/picto/marais/test/plantecarnivore1_feuilles1.png,950,1667;tfmadv/picto/marais/test/plantecarnivore1_feuilles1.png,444,1326;tfmadv/picto/foret/treflemoyen.png,173,1554;tfmadv/picto/foret/treflemoyen.png,698,1157;tfmadv/picto/village/petitminerai.png,416,458;tfmadv/picto/village/petitminerai.png,1466,758;tfmadv/picto/village/petitminerai.png,1076,898;tfmadv/picto/village/petitminerai.png,221,1059;tfmadv/picto/village/petitminerai.png,771,1379;tfmadv/picto/village/petitminerai.png,531,1459;tfmadv/picto/village/petitminerai.png,241,1779" D="180c7386662.png,383,4486;180c7386662.png,403,4496" Ca="" MEDATA=";;;0,4:1,4:2,4:3,4:4,4:5,4:6,4:7,4:8,4:9,4:10,4:11,4:12,4:13,4:14,4:15,4:16,4:17,4:18,4:19,4:20,4:21,4:22,4:23,4:24,4:25,4:26,4:27,4:28,4:29,4:30,4:31,4:32,4:33,4;0,4:1,4:2,4:3,4:4,4:5,4:6,4:7,4:8,4:9,4:10,4:11,4:12,4:13,4:14,4:15,4:16,4:17,4:18,4:19,4:20,4:21,4:22,4:23,4:24,4:25,4:26,4:27,4:28,4:29,4:30,4:31,4:32,4:33,4:34,4:35,4:36,4:37,4:38,4:39,4:40,4:41,4:42,4-0;0::0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33:1-"/><Z><S><S T="0" X="7" Y="2745" L="10" H="10" P="0,0,0.3,0.2,0,0,0,0" i="0,0,17f9dab706f.jpg"/><S T="0" X="89" Y="3226" L="197" H="10" P="0,0,0.3,0.2,30,0,0,0" m=""/><S T="0" X="54" Y="3174" L="197" H="10" P="0,0,0.3,0.2,50,0,0,0" m=""/><S T="0" X="274" Y="3193" L="69" H="10" P="0,0,0.3,0.2,40,0,0,0" m=""/><S T="0" X="214" Y="3178" L="84" H="10" P="0,0,0.3,0.2,0,0,0,0" m=""/><S T="0" X="156" Y="3144" L="84" H="10" P="0,0,0.3,0.2,60,0,0,0" m=""/><S T="0" X="269" Y="3258" L="197" H="10" P="0,0,0.3,0.2,-10,0,0,0" m=""/><S T="0" X="530" Y="3241" L="330" H="10" P="0,0,0.3,0.2,0,0,0,0" m=""/><S T="0" X="654" Y="3241" L="197" H="10" P="0,0,0.3,0.2,-10,0,0,0" m=""/><S T="0" X="849" Y="3224" L="197" H="10" P="0,0,0.3,0.2,0,0,0,0" m=""/><S T="0" X="1027" Y="3224" L="158" H="10" P="0,0,0.3,0.2,0,0,0,0" m=""/><S T="0" X="1194" Y="3240" L="197" H="10" P="0,0,0.3,0.2,10,0,0,0" m=""/><S T="0" X="1700" Y="3217" L="197" H="10" P="0,0,0.3,0.2,20,0,0,0" m=""/><S T="0" X="1514" Y="3184" L="197" H="10" P="0,0,0.3,0.2,0,0,0,0" m=""/><S T="0" X="1713" Y="3237" L="197" H="10" P="0,0,0.3,0.2,0,0,0,0" m=""/><S T="12" X="446" Y="4969" L="896" H="295" P="0,0,0.3,0.2,0,0,0,0" o="c53c45" m=""/><S T="0" X="1687" Y="3021" L="51" H="10" P="0,0,0.3,0.2,230,0,0,0" m=""/><S T="0" X="1641" Y="2987" L="51" H="10" P="0,0,0.3,0.2,200,0,0,0" m=""/><S T="0" X="1600" Y="2983" L="51" H="10" P="0,0,0.3,0.2,170,0,0,0" m=""/><S T="0" X="1566" Y="2996" L="51" H="10" P="0,0,0.3,0.2,160,0,0,0" m=""/><S T="0" X="1854" Y="3263" L="103" H="10" P="0,0,0.3,0.2,30,0,0,0" m=""/><S T="0" X="1994" Y="3512" L="103" H="10" P="0,0,5,0.2,-80,0,0,0" m=""/><S T="0" X="1959" Y="3606" L="103" H="10" P="0,0,5,0.2,-60,0,0,0" m=""/><S T="0" X="1903" Y="3687" L="103" H="10" P="0,0,1,0.2,-50,0,0,0" m=""/><S T="0" X="1820" Y="3743" L="103" H="10" P="0,0,0.3,0.2,-20,0,0,0" m=""/><S T="0" X="1726" Y="3767" L="103" H="10" P="0,0,0.3,0.2,-10,0,0,0" m=""/><S T="0" X="1587" Y="3726" L="118" H="10" P="0,0,0.3,0.2,10,0,0,0" m=""/><S T="0" X="1421" Y="3716" L="220" H="10" P="0,0,0.3,0.2,0,0,0,0" m=""/><S T="0" X="1146" Y="3745" L="349" H="10" P="0,0,0.3,0.2,-10,0,0,0" m=""/><S T="0" X="838" Y="3826" L="310" H="10" P="0,0,0.3,0.2,-20,0,0,0" m=""/><S T="1" X="-13" Y="2265" L="10" H="3651" P="0,0,0,0.2,0,0,0,0" m=""/><S T="1" X="133" Y="3092" L="10" H="62" P="0,0,0,0.2,0,0,0,0" m=""/><S T="1" X="2009" Y="3168" L="10" H="2154" P="0,0,0,0.2,0,0,0,0" m=""/><S T="1" X="1168" Y="3019" L="10" H="482" P="0,0,0,0.2,0,0,0,0" m=""/><S T="1" X="1092" Y="3184" L="10" H="76" P="0,0,0,0.2,0,0,0,0" m=""/><S T="1" X="1121" Y="3135" L="10" H="76" P="0,0,0,0.2,50,0,0,0" m=""/><S T="0" X="1910" Y="3309" L="53" H="10" P="0,0,0.3,0.2,60,0,0,0" m=""/><S T="4" X="2003" Y="3381" L="10" H="190" P="0,0,20,0.2,0,0,0,0" m=""/><S T="1" X="1535" Y="2948" L="10" H="453" P="0,0,0,0.2,0,0,0,0" m=""/><S T="0" X="151" Y="4046" L="442" H="10" P="0,0,0.3,0.2,-10,0,0,0" m=""/><S T="0" X="291" Y="3848" L="675" H="10" P="0,0,0.3,0.2,3,0,0,0" m=""/><S T="0" X="586" Y="3977" L="442" H="10" P="0,0,0.3,0.2,-8,0,0,0" m=""/><S T="0" X="1024" Y="3955" L="442" H="10" P="0,0,0.3,0.2,2,0,0,0" m=""/><S T="0" X="1064" Y="3955" L="442" H="10" P="0,0,0.3,0.2,2,0,0,0" m=""/><S T="0" X="1472" Y="4040" L="411" H="10" P="0,0,0.3,0.2,22,0,0,0" m=""/><S T="0" X="1654" Y="4046" L="474" H="10" P="0,0,0.3,0.2,22,0,0,0" m=""/><S T="0" X="1678" Y="4119" L="43" H="10" P="0,0,0.3,0.2,2,0,0,0" m=""/><S T="0" X="1509" Y="3949" L="209" H="10" P="0,0,0.3,0.2,-4,0,0,0" m=""/><S T="0" X="1799" Y="3942" L="411" H="10" P="0,0,0.3,0.2,0,0,0,0" m=""/><S T="0" X="1851" Y="4090" L="310" H="61" P="0,0,0.3,0.2,0,0,0,0" m=""/><S T="0" X="1618" Y="3834" L="175" H="10" P="0,0,5,0.2,-44,0,0,0" m=""/><S T="4" X="1706" Y="3098" L="10" H="114" P="0,0,20,0.2,0,0,0,0" m=""/><S T="1" X="1700" Y="3089" L="10" H="121" P="0,0,0,0.2,0,0,0,0" m=""/><S T="8" X="1008" Y="3014" L="2013" H="535" P="0,0,0.3,0.2,0,0,0,0" c="4" m="" lua="1"/><S T="8" X="1402" Y="2332" L="900" H="405" P="0,0,0.3,0.2,0,0,0,0" c="4" lua="2" i="0,0,180938afb04.png"/><S T="8" X="427" Y="4768" L="1098" H="410" P="0,0,0.3,0.2,0,0,0,0" c="4" lua="5" i="116,-248,180e68a59d6.png"/><S T="12" X="1355" Y="5515" L="58" H="273" P="0,0,0,0.2,0,0,0,0" o="324650" m="" lua="4" ignore="true"/><S T="1" X="852" Y="4643" L="83" H="450" P="0,0,0,0.2,0,0,0,0" m=""/><S T="1" X="4" Y="4429" L="1990" H="57" P="0,0,0,0.2,0,0,0,0" m=""/><S T="12" X="995" Y="5316" L="1990" H="135" P="0,0,0,0.2,0,0,0,0" o="ABABAB"/><S T="1" X="-31" Y="4636" L="63" H="461" P="0,0,0,0.2,0,0,0,0" m=""/><S T="1" X="-33" Y="5562" L="63" H="440" P="0,0,0,0.2,0,0,0,0" m=""/><S T="1" X="2031" Y="5586" L="80" H="500" P="0,0,0,0.2,0,0,0,0" m=""/><S T="0" X="1403" Y="2518" L="905" H="67" P="0,0,0.3,0.2,0,0,0,0" m=""/><S T="8" X="995" Y="5579" L="1987" H="391" P="0,0,0.3,0.2,0,0,0,0" c="4" lua="3" i="0,0,1817ac76a6a.png"/><S T="8" X="996" Y="3878" L="2009" H="470" P="0,0,0.3,0.2,180,0,0,0" c="4" m="" lua="6"/><S T="8" X="983" Y="1329" L="1985" H="381" P="0,0,0.3,0.2,0,0,0,0" c="4" m="" lua="7"/><S T="8" X="983" Y="632" L="1985" H="381" P="0,0,0.3,0.2,0,0,0,0" c="4" m="" lua="9"/><S T="8" X="985" Y="961" L="2005" H="318" P="0,0,0.3,0.2,0,0,0,0" c="4" m="" lua="8"/><S T="12" X="1657" Y="5708" L="777" H="147" P="0,0,0.3,0.2,0,0,0,0" o="324650" m=""/><S T="12" X="399" Y="5709" L="872" H="147" P="0,0,0.3,0.2,0,0,0,0" o="324650" m=""/><S T="10" X="400" Y="1860" L="800" H="80" P="0,0,0.3,0,0,0,0,0" c="3"/><S T="10" X="1359" Y="1860" L="1120" H="80" P="0,0,0.3,0,0,0,0,0" c="3"/><S T="10" X="600" Y="1780" L="80" H="80" P="0,0,0.3,0,0,0,0,0"/><S T="10" X="400" Y="1490" L="80" H="10" P="1,-1,0.3,0,0,1,0,0" m=""/><S T="10" X="760" Y="1700" L="80" H="80" P="0,0,0.3,0,0,0,0,0"/><S T="10" X="440" Y="1700" L="80" H="80" P="0,0,0.3,0,0,0,0,0"/><S T="10" X="320" Y="1600" L="80" H="40" P="0,0,0.3,0,0,0,0,0"/><S T="10" X="600" Y="1640" L="80" H="40" P="0,0,0.3,0,0,0,0,0"/><S T="10" X="360" Y="1720" L="80" H="40" P="0,0,0.3,0,0,0,0,0"/><S T="10" X="600" Y="1520" L="400" H="40" P="0,0,0.3,0,0,0,0,0"/><S T="10" X="420" Y="1440" L="120" H="120" P="0,0,0.3,0,0,0,0,0"/><S T="10" X="200" Y="1520" L="80" H="40" P="0,0,0.3,0,0,0,0,0"/><S T="10" X="300" Y="1440" L="120" H="40" P="0,0,0.3,0,0,0,0,0"/><S T="10" X="1120" Y="1000" L="120" H="40" P="0,0,0.3,0,0,0,0,0"/><S T="10" X="1721" Y="1766" L="120" H="40" P="0,0,0.3,0,0,0,0,0"/><S T="10" X="1080" Y="960" L="120" H="40" P="0,0,0.3,0,0,0,0,0"/><S T="10" X="1770" Y="1724" L="120" H="40" P="0,0,0.3,0,0,0,0,0"/><S T="10" X="1320" Y="920" L="120" H="40" P="0,0,0.3,0,0,0,0,0"/><S T="10" X="1520" Y="1040" L="80" H="40" P="0,0,0.3,0,0,0,0,0"/><S T="10" X="780" Y="920" L="80" H="40" P="0,0,0.3,0,0,0,0,0"/><S T="10" X="780" Y="660" L="80" H="40" P="0,0,0.3,0,0,0,0,0"/><S T="10" X="700" Y="740" L="80" H="40" P="0,0,0.3,0,0,0,0,0"/><S T="10" X="1500" Y="660" L="80" H="40" P="0,0,0.3,0,0,0,0,0"/><S T="10" X="1220" Y="780" L="80" H="40" P="0,0,0.3,0,0,0,0,0"/><S T="10" X="900" Y="760" L="80" H="80" P="0,0,0.3,0,0,0,0,0"/><S T="10" X="40" Y="720" L="80" H="160" P="0,0,0.3,0,0,0,0,0"/><S T="10" X="700" Y="1040" L="80" H="40" P="0,0,0.3,0,0,0,0,0"/><S T="10" X="580" Y="1000" L="80" H="40" P="0,0,0.3,0,0,0,0,0"/><S T="10" X="80" Y="1440" L="80" H="40" P="0,-1,0.3,0,0,0,0,0"/><S T="10" X="20" Y="1420" L="40" H="80" P="0,-1,0.3,0,0,0,0,0" c="3"/><S T="10" X="51" Y="1300" L="40" H="80" P="0,-1,0.3,0,0,0,0,0" c="3"/><S T="10" X="400" Y="1200" L="80" H="120" P="0,-1,0.3,0,0,0,0,0" c="3"/><S T="10" X="1926" Y="1678" L="80" H="463" P="0,-1,0.3,0,0,0,0,0" c="3"/><S T="10" X="120" Y="1700" L="240" H="240" P="0,0,0.3,0,360,0,0,0"/><S T="10" X="1220" Y="1280" L="40" H="280" P="0,0,0.3,0,-360,0,0,0"/><S T="10" X="1979" Y="1172" L="40" H="1460" P="0,0,0.3,0,-360,0,0,0"/><S T="10" X="921" Y="1460" L="640" H="80" P="0,0,0.3,0,-360,0,0,0"/><S T="10" X="947" Y="1120" L="1896" H="40" P="0,0,0.3,0,-360,0,0,0"/><S T="10" X="931" Y="820" L="1863" H="40" P="0,0,0.3,0,-360,0,0,0"/><S T="10" X="1000" Y="460" L="2000" H="40" P="0,0,0.3,0,-360,0,0,0"/><S T="10" X="240" Y="1280" L="400" H="40" P="0,0,0.3,0,-360,0,0,0"/><S T="12" X="760" Y="1820" L="20" H="40" P="1,20,0.3,0.2,0,1,2000,0" o="6D4E94" c="3"/><S T="12" X="30" Y="1580" L="20" H="40" P="1,20,0.3,0.2,0,1,2000,0" o="000000" c="2" m=""/><S T="12" X="810" Y="1660" L="20" H="40" P="1,20,0.3,0.2,0,1,2000,0" o="000000" c="2" m=""/><S T="12" X="360" Y="1390" L="38" H="20" P="1,20,0.3,0.2,0,1,2000,0" o="000000" c="2" m=""/><S T="12" X="30" Y="1420" L="20" H="40" P="1,20,0.3,0.2,0,1,2000,0" o="000000" c="2" m=""/><S T="12" X="80" Y="1520" L="80" H="120" P="1,20,0,0,0,1,0,0" o="6D4E94"/><S T="12" X="760" Y="1600" L="80" H="120" P="1,20,0,0,0,1,0,0" o="68A2C4"/><S T="12" X="80" Y="1360" L="80" H="120" P="1,20,0,0,0,1,0,0" o="007D42"/><S T="12" X="400" Y="1340" L="80" H="80" P="1,20,0,0,0,1,0,0" o="C6C96D"/><S T="12" X="80" Y="1580" L="20" H="40" P="1,20,0.3,0.2,0,1,2000,0" o="68A2C4" c="3"/><S T="12" X="760" Y="1660" L="20" H="40" P="1,20,0.3,0.2,0,1,2000,0" o="007D42" c="3"/><S T="12" X="40" Y="1410" L="40" H="20" P="1,20,0.3,0.2,0,1,2000,0" o="C6C96D" c="3"/><S T="1" X="1660" Y="1020" L="40" H="160" P="0,0,0,0.2,0,0,0,0"/><S T="1" X="300" Y="1020" L="40" H="160" P="0,0,0,0.2,0,0,0,0"/><S T="1" X="1160" Y="720" L="40" H="160" P="0,0,0,0.2,0,0,0,0"/><S T="1" X="840" Y="720" L="40" H="160" P="0,0,0,0.2,0,0,0,0"/><S T="1" X="400" Y="640" L="40" H="320" P="0,0,0,0.2,0,0,0,0"/><S T="1" X="840" Y="520" L="40" H="80" P="0,0,0,0.2,180,0,0,0"/><S T="1" X="1160" Y="520" L="40" H="80" P="0,0,0,0.2,180,0,0,0"/><S T="1" X="1280" Y="1040" L="40" H="120" P="0,0,0,0.2,0,0,0,0"/><S T="1" X="840" Y="1000" L="40" H="200" P="0,0,0,0.2,0,0,0,0"/><S T="10" X="1360" Y="720" L="280" H="20" P="1,0,0.3,0,0,0,0,0" c="3"/><S T="10" X="1000" Y="630" L="240" H="20" P="1,0,0.3,0,0,0,0,0" c="3"/><S T="10" X="240" Y="630" L="240" H="20" P="1,0,0.3,0,0,0,0,0" c="3"/><S T="10" X="1616" Y="740" L="160" H="120" P="0,0,0.3,0,0,0,0,0"/><S T="12" X="1091" Y="2567" L="1851" H="75" P="0,0,0.3,0.2,0,0,0,0" o="533d2e"/><S T="12" X="487" Y="4649" L="13" H="404" P="0,0,0.3,0.2,0,0,0,0" o="324650" c="2" m=""/><S T="12" X="559" Y="2298" L="463" H="787" P="0,0,0,0.2,90,0,0,0" o="b17a6d"/><S T="12" X="1946" Y="2300" L="463" H="187" P="0,0,0,0.2,90,0,0,0" o="b17a6d"/><S T="12" X="1101" Y="2036" L="1880" H="187" P="0,0,0,0.2,180,0,0,0" o="b17a6d"/><S T="0" X="1075" Y="5831" L="647" H="36" P="0,0,0.3,0.2,0,0,0,0" c="2" m=""/><S T="12" X="1292" Y="2411" L="66" H="17" P="0,0,0.3,0.2,-30,0,0,0" o="915E52"/><S T="12" X="1601" Y="2349" L="191" H="17" P="0,0,0.3,0.2,-30,0,0,0" o="915E52"/><S T="12" X="1420" Y="2396" L="207" H="17" P="0,0,0.3,0.2,0,0,0,0" o="915E52"/><S T="12" X="1441" Y="2300" L="251" H="17" P="0,0,0.3,0.2,0,0,0,0" o="915E52"/><S T="12" X="1712" Y="2302" L="68" H="17" P="0,0,0.3,0.2,0,0,0,0" o="915E52"/><S T="12" X="1738" Y="2337" L="90" H="17" P="0,0,0.3,0.2,90,0,0,0" o="915E52"/><S T="12" X="1755" Y="2436" L="134" H="17" P="0,0,0.3,0.2,0,0,0,0" o="915E52"/><S T="12" X="1255" Y="2263" L="149" H="17" P="0,0,0.3,0.2,30,0,0,0" o="915E52"/><S T="12" X="1072" Y="2226" L="242" H="17" P="0,0,0.3,0.2,0,0,0,0" o="915E52"/><S T="1" X="1742" Y="4935" L="400" H="250" P="1,9999,0,0.2,0,1,0,0" lua="300"/><S T="0" X="1460" Y="4996" L="150" H="170" P="1,9999,30,0.2,0,1,0,0" lua="200" contactlistener="true"/><S T="1" X="1497" Y="4880" L="30" H="30" P="1,9999,2,0.2,0,1,0,0" lua="12000" contactListener="true"/><S T="1" X="1427" Y="4884" L="30" H="30" P="1,9999,2,0.2,0,1,0,0" lua="12001" contactListener="true"/><S T="12" X="1966" Y="4832" L="30" H="553" P="0,0,0.3,0.2,0,0,0,0" o="324650" m=""/><S T="12" X="1623" Y="5104" L="757" H="50" P="0,0,0.3,0.2,0,0,0,0" o="324650" m=""/><S T="12" X="1262" Y="4822" L="137" H="587" P="0,0,0.3,0.2,0,0,0,0" o="324650" m=""/><S T="12" X="1630" Y="4529" L="827" H="100" P="0,0,0.3,0.2,0,0,0,0" o="324650" m=""/><S T="0" X="12" Y="4838" L="36" H="29" P="0,0,0.3,0.2,0,0,0,0" c="4" i="0,0,181b8d28825.png"/></S><D><P X="1160" Y="1400" T="11" P="0,0"/><P X="120" Y="1090" T="11" P="0,0"/><P X="40" Y="650" T="11" P="0,0"/><P X="637" Y="1541" T="109" P="1,0"/><P X="306" Y="1458" T="109" P="1,0"/><P X="1125" Y="1020" T="109" P="1,0"/><DS X="855" Y="3195"/></D><O><O X="322" Y="3221" C="22" nosync="" P="0" type="npc" name="edric"/><O X="593" Y="3222" C="22" nosync="" P="0" type="npc" name="laura"/><O X="769" Y="3189" C="22" nosync="" P="0" type="npc" name="marc"/><O X="286" Y="1190" C="22" nosync="" P="0" type="npc" name="saruman"/><O X="48" Y="610" C="22" nosync="" P="0" type="spirit_orb" name="2"/><O X="1890" Y="5596" C="22" nosync="" P="0" type="spirit_orb" name="5"/><O X="75" Y="1058" C="22" nosync="" P="0" type="spirit_orb" name="3"/><O X="1104" Y="1330" C="22" nosync="" P="0" type="spirit_orb" name="4"/><O X="1768" Y="3214" C="22" nosync="" P="0" type="npc" name="cole"/><O X="206" Y="5604" C="22" nosync="" P="0" type="npc" name="niels"/><O X="137" Y="4792" C="22" nosync="" P="0" type="npc" name="monk"/><O X="1075" Y="2197" C="11" nosync="" P="0" type="teleport" route="arena" id="2"/><O X="273" Y="3156" C="11" nosync="" P="0" type="teleport" route="arena" id="1"/><O X="1326" Y="888" C="14" nosync="" P="0" type="monster_spawn"/><O X="1150" Y="3728" C="14" nosync="" P="0" type="monster_spawn"/><O X="494" Y="3963" C="14" nosync="" P="0" type="monster_spawn"/><O X="944" Y="3914" C="14" nosync="" P="0" type="monster_spawn"/><O X="358" Y="5613" C="14" nosync="" P="0" type="monster_spawn"/><O X="1069" Y="1083" C="14" nosync="" P="0" type="monster_spawn"/><O X="620" Y="1064" C="14" nosync="" P="0" type="monster_spawn"/><O X="1379" Y="2282" C="14" nosync="" P="0" type="monster_spawn"/><O X="1380" Y="2370" C="14" nosync="" P="0" type="monster_spawn"/><O X="718" Y="4681" C="14" nosync="" P="0" type="final_boss"/><O X="486" Y="4710" C="14" nosync="" P="0" type="monster_spawn_passive"/><O X="1952" Y="3906" C="11" nosync="" P="0" type="teleport" route="bridge" id="1"/><O X="126" Y="5609" C="11" nosync="" P="0" type="teleport" route="final_boss" id="1"/><O X="1063" Y="3197" C="11" nosync="" P="0" type="teleport" route="castle" id="1"/><O X="1669" Y="3172" C="11" nosync="" P="0" type="teleport" route="castle" id="2"/><O X="23" Y="4793" C="11" nosync="" P="0" type="teleport" route="final_boss" id="2"/><O X="57" Y="4024" C="11" nosync="" P="0" type="teleport" route="shrines" id="1"/><O X="1911" Y="1420" C="11" nosync="" P="0" type="teleport" route="shrines" id="2"/><O X="358" Y="784" C="11" nosync="" P="0" type="teleport" route="enigma" id="2"/><O X="35" Y="5609" C="11" nosync="" P="0" type="teleport" route="bridge" id="2"/><O X="86" Y="3806" C="22" nosync="" P="0" type="recipe" name="bridge"/><O X="164" Y="3118" C="22" nosync="" P="0" type="recipe" name="iron_sword"/><O X="524" Y="1476" C="22" nosync="" P="0" type="recipe" name="copper_sword"/><O X="1684" Y="4085" C="22" nosync="" P="0" type="recipe" name="copper_shield"/><O X="156" Y="1245" C="22" nosync="" P="0" type="recipe" name="gold_shovel"/><O X="257" Y="1080" C="22" nosync="" P="0" type="recipe" name="gold_axe"/><O X="1769" Y="5596" C="22" nosync="" P="0" type="recipe" name="gold_sword"/><O X="1809" Y="5596" C="22" nosync="" P="0" type="recipe" name="gold_shield"/><O X="183" Y="3118" C="22" nosync="" P="0" type="recipe" name="iron_shield"/><O X="1619" Y="2960" C="22" nosync="" P="0" type="recipe" name="gold_axe"/><O X="721" Y="5607" C="22" nosync="" P="0" type="bridge"/><O X="1494" Y="3699" C="22" nosync="" P="0" type="tree"/><O X="1408" Y="3691" C="22" nosync="" P="0" type="tree"/><O X="1307" Y="3659" C="22" nosync="" P="0" type="tree"/><O X="1232" Y="3698" C="22" nosync="" P="0" type="tree"/><O X="1079" Y="3689" C="22" nosync="" P="0" type="tree"/><O X="985" Y="3730" C="22" nosync="" P="0" type="tree"/><O X="786" Y="3181" C="22" nosync="" P="0" type="craft_table"/><O X="1816" Y="5565" C="14" nosync="" P="0" type="fiery_dragon"/><O X="1740" Y="1090" C="7" P="0"/><O X="1360" Y="1090" C="7" P="0"/><O X="920" Y="1090" C="7" P="0"/><O X="380" Y="1090" C="7" P="0"/><O X="1740" Y="1090" C="11" P="0"/><O X="1360" Y="1090" C="11" P="0"/><O X="920" Y="1090" C="11" P="0"/><O X="380" Y="1090" C="11" P="0"/><O X="1846" Y="710" C="423" P="-60,0"/><O X="1696" Y="590" C="423" P="-60,0"/><O X="1894" Y="628" C="11" P="0"/><O X="1744" Y="508" C="11" P="0"/><O X="431" Y="770" C="11" nosync="" P="0" type="teleport" route="enigma" id="1"/><O X="431" Y="770" C="11" nosync="" P="0" type="teleport" route="enigma" id="1"/><O X="431" Y="770" C="11" nosync="" P="0" type="teleport" route="enigma" id="1"/></O><L><JP M1="112" M2="71" AXIS="0,1"/><JP M1="117" M2="71" AXIS="1,0" LIM1="0" LIM2="Infinity" MV="1,6.666666666666667"/><JP M1="113" M2="71" AXIS="0,1"/><JD M1="113" M2="112"/><JP M1="121" M2="71" AXIS="0,1"/><JP M1="114" M2="71" AXIS="0,1"/><JP M1="118" M2="71" AXIS="1,0" LIM1="-Infinity" LIM2="0" MV="1,-6.666666666666667"/><JD M1="121" M2="114"/><JP M1="122" M2="71" AXIS="0,1"/><JP M1="116" M2="71" AXIS="0,1"/><JD M1="116" M2="122"/><JP M1="119" M2="71" AXIS="1,0" LIM1="0" LIM2="Infinity" MV="1,6.666666666666667"/><JP M1="123" M2="71" AXIS="1,0"/><JP M1="120" M2="71" AXIS="0,1" LIM1="-Infinity" LIM2="0" MV="1,6.666666666666667"/><JD M1="123" M2="115"/><JP M1="115" M2="71" AXIS="1,0"/><JD c="C55924,4,1,0" P1="640,1720" P2="650,1725"/><JD c="C55924,4,1,0" P1="500,1370" P2="510,1375"/><JD c="C55924,4,1,0" P1="640,1730" P2="650,1725"/><JD c="C55924,4,1,0" P1="500,1380" P2="510,1375"/><JR M1="134" M2="109" P1="1000,630" MV="Infinity,1.4"/><JR M1="133" M2="109" P1="1360,720" MV="Infinity,1.4"/><JR M1="135" M2="109" P1="240,630" MV="Infinity,1.4"/><JD c="272416,200,1,0" P1="100,0" P2="100,1600"/><JD c="272416,200,1,0" P1="280,0" P2="280,1800"/><JD c="272416,200,1,0" P1="460,0" P2="460,1800"/><JD c="272416,200,1,0" P1="640,0" P2="640,1800"/><JD c="272416,200,1,0" P1="820,0" P2="820,1800"/><JD c="272416,200,1,0" P1="1000,0" P2="1000,1800"/><JD c="272416,200,1,0" P1="1180,0" P2="1180,1800"/><JD c="272416,200,1,0" P1="1360,0" P2="1360,1800"/><JD c="272416,200,1,0" P1="1540,0" P2="1540,1800"/><JD c="272416,200,1,0" P1="1720,0" P2="1720,1800"/><JD c="272416,200,1,0" P1="1900,0" P2="1900,1800"/></L></Z></C>]]
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
	KEY_P 	= 80,
	KEY_X	= 88,
	KEY_U	= 85
}

local assets = {
	ui = {
		reply = "171d2f983ba.png",
		btnNext = "17eaa38a3f8.png",
		inventory = "17ff9b6b11f.png",
		dialogue_proceed = "180c6623296.png",
		dialogue_replies = "180c6a27f57.png",
		divine_panel = "180e6a4cc73.png",
		marker = "180e698ed6b.png",
		attack = "180f665dad5.png",
		defense = "180f6724a3b.png",
		durability = "180f66d1355.png",
		chopping = "180f697bff3.png",
		mining = "180f675527f.png",
		questProgress = "181b07c5bcb.png",
		lock = "1660271f4c6.png",
		cogwheel = "181bd5c03f5.png"
	},
	widgets = {
		borders = {
			topLeft = "155cbe99c72.png",
			topRight = "155cbea943a.png",
			bottomLeft = "155cbe97a3f.png",
			bottomRight = "155cbe9bc9b.png"
		},
		closeButton = "171e178660d.png",
		scrollbarBg = "1719e0e550a.png",
		scrollbarFg = "1719e173ac6.png"
	},
	damageFg = "17f2a88995c.png",
	damageBg = "17f2a890350.png",
	stone = "18093cce38d.png",
	bridge = "1816b166e3e.png",
	spit = "180a896aac3.png",
	laser = "180c7384245.png",
	rock = "180eaca954d.png",
	goo = "18105dfd36a.png",
	divine_light = "1817af8c258.png"
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
	},
	spiritOrbs = {
		index = 4,
		type = "number",
		default = 0
	},
	missingRewardsGiven = {
		index = 5,
		type = "boolean",
		default = false
	}
})

local teleports = {}

local directionSequence = {}
local projectiles = {}

local mineQuestCompletedPlayers, mineQuestIncompletedPlayers, totalPlayers, totalProcessedPlayers = 0, 0, 0, 0
local _tc, _tr = 0, 0



--==[[ translations ]]==--

local translations = {}

-- theme color pallete: https://www.colourpod.com/post/173929539115/a-medieval-recipe-for-murder-submitted-by

translations["en"] = {
	OUT_OF_RESOURCES = "<font color='#ab5e42'>[</font> <font color='#c6b392'>•</font> <font color='#ab5e42'>]</font> <font color='#c6b392' face='Lucida Console'>Out of resources!</font>",
	NEW_RECIPE = "<font color='#506d3d' size='8'><b>[NEW RECIPE]</b></font> <font color='#ab5e42' face='Lucida Console'><b>${itemName}</b></font>\n<font color='#bd9d60' size='11' face='Lucida Console'>(${itemDesc})</font>",
	NEW_QUEST = "<font color='#506d3d' size='8'><b>[NEW QUEST]</b></font> <font color='#ab5e42' face='Lucida Console'><b>${questName}</b></font>",
	NEW_STAGE = "<font color='#506d3d' size='8'><b>[UPDATE]</b></font> <font color='#ab5e42' face='Lucida Console'><b>${questName}</b></font>\n<font color='#bd9d60' size='11' face='Lucida Console'>(${desc})</font>",
	STAGE_PROGRESS = "<font color='#506d3d' size='8'><b>[UPDATE]</b></font> <font color='#ab5e42' face='Lucida Console'><b>${questName}</b></font> <font color='#bd9d60' size='11' face='Lucida Console'>( ${progress} / ${needed} )</font>",
	QUEST_OVER = "<font color='#506d3d' size='8'><b>[COMPLETED]</b></font> <font color='#ab5e42' face='Lucida Console'><b>${questName}</b></font>",
	SPIRIT_ORB = "<b><font color='#ab5e42' face='Lucida Console'>You received a <font color='#bd9d60' face='Lucida Console'>spirit orb!</font></font></b>",
	PASSCODE = "Please enter the access key.",
	WRONG_GUESS = "<R>Incorrect access key.</R>",
	INVENTORY_INFO = "<font face='Lucida Console'><p align='center'><font color='#${color}' size='9'>Weight: ${weight}</font>\n\n\n\n<font size='9'><N2><b>[X] Throw</b></N2></font></p></font>",
	FULL_INVENTORY = "<font color='#ab5e42'>[</font> <font color='#c6b392'>•</font> <font color='#ab5e42'>]</font> <font color='#c6b392' face='Lucida Console'>Your inventory is full!</font>",
	PORTAL_ENTER_FAIL = "<font color='#ab5e42'>[</font> <font color='#c6b392'>•</font> <font color='#ab5e42'>]</font> <font color='#c6b392' face='Lucida Console'>Can't access the portal right now.</font>",
	CRAFT = "Craft!",
	CANT_CRAFT = "Can't craft",
	QUESTS = "<font size='15' face='Lucida console'><b><BV>Quests</BV></b></font>\n\n",
	RECIPE_DESC = "\n\n<font face='Lucida console' size='12' color='#999999'><i>“ ${desc} ”</i></font>",
	FINAL_BATTLE_PING = "<font color='#ab5e42'>[</font> <font color='#c6b392'>•</font> <font color='#ab5e42'>]</font> <font color='#c6b392' face='Lucida Console'>Final battle is happening!</font>",
	ACTIVATE_POWER = "<font color='#ab5e42'>[</font> <font color='#c6b392'>•</font> <font color='#ab5e42'>]</font> <font color='#c6b392' face='Lucida Console'>Press <font color='#ab5e42'><b>U</b></font> to toggle <font color='#ab5e42'><b>divine power!</b></font></font>",
	ENDING_MESSAGE = "<font color='#cccccc'><font color='#bd9d60'><b>Congratulations</b></font> for completing the event!<br><br>Thanks <font color='#bd9d60'>King_seniru</font><font size='8' color='#ab5e42'>#5890</font>, <font color='#bd9d60'>Hattington</font><font size='8' color='#ab5e42'>#2583</font>, <font color='#bd9d60'>Vividia</font><font size='8' color='#ab5e42'>#0095</font>, <font color='#bd9d60'>Chibi</font><font size='8' color='#ab5e42'>#0095</font>, <font color='#bd9d60'>Karasu</font><font size='8' color='#ab5e42'>#0010</font>, <font color='#bd9d60'>Zetdey</font><font size='8' color='#ab5e42'>#3845</font>, <font color='#bd9d60'>Eremia</font><font size='8' color='#ab5e42'>#0020</font>, <font color='#bd9d60'>Event squad</font> and <font color='#bd9d60'>you</font> for making this event possible!\n\n</font><i><font color='#548336'>Don't stop there... there's still a lot more to explore! Happy exploring!!!</font></i>",
	PLAYER_DATA_FAIL_SAFEBACK = "<font color='#ab5e42'>[</font> <font color='#c6b392'>•</font> <font color='#ab5e42'>]</font> <font color='#c6b392' face='Lucida Console'>It appears your data didn't load correctly. Therefore we disabled saving stats for you. Try changing rooms or relogging and contact King_seniru#5890 if this problem persists</font>",
	ANNOUNCER_DIALOGUES = {
		"ATTENTION EVERYONE! ATTENTION!!!",
		"This message is from our majesty, the glorious King of this land...",
		"Our land is under attack, by the ruthless monsters that have been once defeated a while ago.",
		"This follows up with the unfortunate event yet to be announced. <b><VP>Our princess has been kidnapped.</VP></b>",
		"The ruthless monsters also managed to get away with almost all the treasury we had.",
		"The King is looking for BRAVE SOLDIERS that will help the army to defeat all these monsters, and save the princess\nwith our treasury",
		"The King will be hoping the presence of all the brave hearts...\n"
	},
	NOSFERATU_DIALOGUES = {
		"Ahh you look quite new here... anyways you look like useful",
		"So you are telling, you came to here from another dimension, and have no idea where you are or what to do at all\n<i>*Hmmm maybe he is actually useful for me</i>",
		"Well young fella, I guess you need a job to live. Don't worry about that, I'll give you a job yes yes.",
		"But... before that, we need to check if you are in a good physical state.\nGather <VP><b>15 wood</b></VP> for me from the woods.\nHave these <VP><b>20 stone</b></VP> as an advance. Good luck!",
		"Quite impressive indeed. But <i>back in our days</i> we did it much faster...\nNot like it matters now. As I promised <VP><b>job</b></VP> is yours.",
		"That said, you now have access to the <b><VP>mine</VP></b>\nHead to the <b><VP>door</VP></b> to the leftside from here and <b><VP>↓</VP></b> to access it!",
		"As your first job, I need you to gather<b><VP> 15 iron ore</VP></b>. Good luck again!",
		"Woah! Looks like I underestimated you, such an impressive job!",
		"I heard the <b><VP>castle</VP></b> needs some young fellas like you to save it's treasury and the princess from the bad guys...",
		"You could be a good fit for that!",
		"I'll give you <b><VP>Nosferatu's recommendation letter</VP></b>, present this to <b><VP>Lieutenant</VP></b> and hopefully he'll recruit you into the army.\n<i>aaand that's some good money too</i>",
		"Oh and don't forget your reward of <b><VP>30 stone</VP></b> for all the hard work!",
		"Do you need anything?",
		"That's quite general knowledge... You need to <b><VP>chop a tree with an axe</VP></b>",
		"So you need a <b><VP>pickaxe</VP></b>? There should be one lying around in <b><VP>woods</VP></b>.\n<b><VP>↓</VP></b> to study it and craft the studied recipe in a <b><VP>crafting station</VP></b>.\nA station is located right above this mine.",
		"I sell <b><VP>10 stone</VP></b> for <b><VP>35 sticks</VP></b>",
		"Ah ok farewell then",
		"Your inventory seems to be full. How about you empty it come back for your reward.",
		"Pleasure doing business with ya!",
		"Looks like you have no enough items to do this trade kiddo."
	},
	NOSFERATU_QUESTIONS = {
		"How do I get wood?",
		"Pickaxe?",
		"Exchange",
		"Nevermind.",
		"It's something else."
	},
	EDRIC_DIALOGUES = {
		"Our princess... and the treasury, is in the hands of evil. We gotta hurry",
		"Hold on. So you say <b><VP>Nosferatu</VP></b> sent you here and you can help our troops with the missions???",
		"That's great. But working for an army is not simple as you think.\nYou will need to do some <b><VP>intense training</VP></b> considering your body is not in the right shape either.\nHead to the <b><VP>training area to the leftside of me</VP></b> to start your training.",
		"But before that, make sure you are fully prepared. There are few <b><VP>recipes</VP></b> scattered around the <b><VP>weapon racks</VP></b> and the <b><VP>gloomy forests down the hill</VP></b>\nHope you will make a good use of them!",
		"Talk to me again when you think you ready!",
		"Are you ready to take the challenge?",
		"Great! Go start your training in the training area. You need to <b><VP>defeat 25 monsters</VP></b> to pass this challenge.",
		"You can take as much as time you want\nGood luck to you!!!",
		"You proved that you are worthy! Hurry!!! Join the rest of our soldiers and fight the monsters!"
	},
	EDRIC_QUESTIONS = {
		"I need more time...",
		"I am ready!"
	},
	GARRY_DIALOGUES = {
		"This is the worst place I've ever been. <b><VP>Nosferatu</VP></b> doesn't even pay enough. <i>*sigh...*</i>"
	},
	THOMPSON_DIALOGUES = {
		"Hello! Do you want anything from me?",
		"If you are looking for a <b><VP>shovel</VP></b>, there should be one to the <b><VP>rightmost part of the mine</VP></b>.\nGood luck!",
		"Have a nice day!"
	},
	THOMPSON_QUESTIONS = {
		"Any recipes?",
		"Just saying hi."
	},
	COLE_DIALOGUES = {
		"There's a lot of <b><VP>monsters</VP></b> out there. Please be careful!",
		"All of our army is fighting against the monsters. We need a lot of help.",
		"OIIIIII! I CANT LET A WEAKLING LIKE YOU GO THAT WAY. COME BACK UP HERE!"
	},
	MARC_DIALOGUES = {
		"BAD YOU! Touch my bench work NOT!"
	},
	SARUMAN_DIALOGUES = {
		"EYYYYY!!!! EYYYYYYYYY!!!!\nIS SOMEBODY THERE???",
		"HEYY!! HELP ME OUT THERE!\nTHANKS GOD FOR SAVING ME OUT HERE!!!",
		"I am <b><VP>Saruman</VP></b> by the way. I've been stucked here for like...\n15 years?",
		"My buddy <b><VP>Hootie</VP></b> is the reason I'm still alive.\nI'd die out of starvation if it wasn't him",
		"So you want to know how and why I'm stuck here?",
		"Well long story short, back when I was still <b>young</b> and strong as you,\nI heard about these treasures called <b><VP>spirit orbs</VP></b>",
		"I was a professor too so I was quite interested in researching about this topic.\nI've gathered like a lots of information about them",
		"These orbs are binded to one's soul. Once they are binded with all <b><VP>5 orbs</VP></b> they will be granted the <b><VP>divine power</VP></b>",
		"I'm not sure what kind of power I'd get from those or what would they do to me...\nBut I'm pretty sure the <b><VP>monks</VP></b> know more about how to use it!",
		"But nobody knew where they are exactly located so I came here to find them all by myself.",
		"I think I did a pretty good job finding one <VP><b>shrine orb</b></VP>.\nBut... I choosed the wrong path and was stucked here forever since then.",
		"I'm glad you helped me out! Feel free to talk to me to know anything about these orbs.\nKnowledge is there to share, and you saved me!",
		"Yeah buddy! What do you want to know from me?",
		"Like I said there are <b><VP>5 spirit orbs</VP></b>\n<b><VP>3</VP></b> of them could be found in the <b><VP>shrines</VP></b> in this gloomy forest.\nI'm quite unsure about the rest 2 though...",
		"From the information I have collected, you'll have to face various challenges to get into shrines.",
		"I think you know one already unless you had some magic power to teleport here",
		"Second shrine is guarded by a lot of <b><VP>monsters</VP></b> on it's way.\nSo equip well before exploring there!",
		"And for the last shrine I've found this <b><VP>hint</VP></b> from ancient books",
		"<b><VP>\"Puzzles, and riddles, and old tradition\nMathematical score, but not addition",
		"That's all! Hope you make a good use of these information",
		"Thanks for checking on me bud!",
		"OH LOOKS LIKE YOU'VE COLLECTED ALL THE SPIRIT ORBS!!!\nWe're even now... thank me later!\nBut make sure you find more information about these orbs from a <b><VP>monk</VP></b>",
		"<b><VP>\"A resource that so fruitfully bore\nComes to term with ones true lore\"</VP></b>",
		"<b><VP>\"Take the rank shown to all\nTo the world you must call\"</VP></b>"
	},
	SARUMAN_QUESTIONS = {
		"Where are orbs?",
		"Just checking!"
	},
	MONK_DIALOGUES = {
		"I've been holding this evil power for a long time...\nGlad to hear you came to help us",
		"So you're telling you possess all <b><VP>5 spirit orbs</VP></b>",
		"Quite a good job indeed. Now this will make it easier to defeat the evil power forever",
		"These spirit orbs are indeed binded to one's spirit\nOnly couragous individuals can possess all 5",
		"These orbs will help you to <b><VP>divine power</VP></b> which is the only way to destroy the evil\nas far as I know",
		"Once you have activated the divine power and confronted the evil...\nYou will have to travel a long path inside your mind to achieve the <b><VP>divine status</VP></b>",
		"The spirit orbs will help you to find the right path to achieve that.\nYou only have to travel to the way it show you at the right time!",
		"I'm pretty sure you won't succeed it to the most powerful divine energy.\nBut even if you get closer...",
		"It will create a large divine energy which will then summon the <b><VP>goddess</VP></b>",
		"Ancient books say that the beast is too powerful but I'm pretty sure the\n<b><VP>goddessess' blessing</VP></b> would put it in a weaker state",
		"Which then is our time, to destroy the evil power forever!!!",
		"The goddess... she's here\nIT IS HAPPENING!!!"
	},
	NIELS_DIALOGUES = {
		"Everyone hold onto their positions!",
		"The <b><VP>dragon</VP></b> on the other side of the river is too dangerous.\nHe will use his <b><VP>fire attacks</VP></b> and will <b><VP>throw rocks</VP></b> on you",
		"Please be careful...",
		"However we can't directly attack the dragon, as the bridge appears to be broken",
		"The dragon once destroyed it with his fire, when he was trying to cross it.",
		"So... we will have to repair it to reach him as well. Hurry!!!"
	},
	PROPS = {
		attack = "Attack",
		defense = "Defense",
		durability = "Durability",
		chopping = "Chopping",
		mining = "Mining"
	}
}

translations["pl"] = {
	OUT_OF_RESOURCES = "<font color='#ab5e42'>[</font> <font color='#c6b392'>•</font> <font color='#ab5e42'>]</font> <font color='#c6b392' face='Lucida Console'>Brak zasobów!</font>",
	NEW_RECIPE = "<font color='#506d3d' size='8'><b>[NOWY PRZEPIS]</b></font> <font color='#ab5e42' face='Lucida Console'><b>${itemName}</b></font>\n<font color='#bd9d60' size='11' face='Lucida Console'>(${itemDesc})</font>",
	NEW_QUEST = "<font color='#506d3d' size='8'><b>[NOWA MISJA]</b></font> <font color='#ab5e42' face='Lucida Console'><b>${questName}</b></font>",
	NEW_STAGE = "<font color='#506d3d' size='8'><b>[AKTUALIZACJA]</b></font> <font color='#ab5e42' face='Lucida Console'><b>${questName}</b></font>\n<font color='#bd9d60' size='11' face='Lucida Console'>(${desc})</font>",
	STAGE_PROGRESS = "<font color='#506d3d' size='8'><b>[AKTUALIZACJA]</b></font> <font color='#ab5e42' face='Lucida Console'><b>${questName}</b></font> <font color='#bd9d60' size='11' face='Lucida Console'>( ${progress} / ${needed} )</font>",
	QUEST_OVER = "<font color='#506d3d' size='8'><b>[ZAKOŃCZONA]</b></font> <font color='#ab5e42' face='Lucida Console'><b>${questName}</b></font>",
	SPIRIT_ORB = "<b><font color='#ab5e42' face='Lucida Console'>Otrzymujesz <font color='#bd9d60' face='Lucida Console'>duchową kulę!</font></font></b>",
	PASSCODE = "Wprowadź klucz dostępu.",
	WRONG_GUESS = "<R>Nieprawidłowy klucz dostępu.</R>",
	INVENTORY_INFO = "<font face='Lucida Console'><p align='center'><font color='#${color}' size='9'>Obciążenie: ${weight}</font>\n\n\n\n<font size='9'><N2><b>[X] Rzuć</b></N2></font></p></font>",
	FULL_INVENTORY = "<font color='#ab5e42'>[</font> <font color='#c6b392'>•</font> <font color='#ab5e42'>]</font> <font color='#c6b392' face='Lucida Console'>Twój ekwipunek jest pełny!</font>",
	FINAL_BOSS_ENTER_FAIL = "<font color='#ab5e42'>[</font> <font color='#c6b392'>•</font> <font color='#ab5e42'>]</font> <font color='#c6b392' face='Lucida Console'> Musisz zdobyć duchową kulę smoka, aby wejść do tego portalu!</font>",
	CRAFT = "Twórz!",
	CANT_CRAFT = "Nie można tworzyć",
	RECIPE_DESC = "\n\n<font face='Lucida console' size='12' color='#999999'><i>“ ${desc} ”</i></font>",
	FINAL_BATTLE_PING = "<font color='#ab5e42'>[</font> <font color='#c6b392'>•</font> <font color='#ab5e42'>]</font> <font color='#c6b392' face='Lucida Console'>Trwa ostateczna bitwa!</font>",
	ACTIVATE_POWER = "<font color='#ab5e42'>[</font> <font color='#c6b392'>•</font> <font color='#ab5e42'>]</font> <font color='#c6b392' face='Lucida Console'>Wciśnij <font color='#ab5e42'><b>U</b></font> aby aktywować <font color='#ab5e42'><b>boską moc!</b></font></font>",
	ANNOUNCER_DIALOGUES = {
		"UWAGA WSZYSCY! UWAGA!!!",
		"Ta wiadomość jest od naszego majestatu, chwalebnego króla tej ziemi...",
		"Nasz kraj jest atakowany przez bezwzględne potwory, które zostały pokonane jakiś czas temu.",
		"Jest to następstwo niefortunnego wydarzenia, które nie zostało jeszcze ogłoszone. <b><VP>Nasza księżniczka została porwana.</VP></b>",
		"Bezwzględne potwory zdołały też uciec z prawie całym skarbem, jakiego mieliśmy.",
		"Król szuka ODWAŻNYCH ŻOŁNIERZY, którzy pomogą armii pokonać wszystkie potwory i ocalić księżniczkę.\nwraz z naszym skarbem",
		"Król będzie miał nadzieję na obecność wszystkich odważnych serc...\n"
	},
	NOSFERATU_DIALOGUES = {
		"Wyglądasz na całkiem nowego... w każdym razie wyglądasz na użytecznego",
		"Mówisz więc, że przybyłeś tu z innego wymiaru i nie masz pojęcia, gdzie jesteś ani co masz robić\n<i>*Hmmm może faktycznie jest dla mnie przydatny</i>",
		"No cóż, młody człowieku, chyba potrzebujesz pracy, żeby żyć. Nie martw się o to, dam ci pracę.",
		"Ale... przedtem musimy sprawdzić, czy jesteś w dobrym stanie fizycznym.\nZbierz <VP><b>15 drewna</b></VP> dla mnie z lasu.\nMiej te <VP><b>10 kamieni</b></VP> jako zaliczkę. Powodzenia!",
		"Rzeczywiście, robi wrażenie. Ale <i>za naszych czasów</i> robiliśmy to znacznie szybciej...\nTeraz to już nie ma znaczenia. Tak jak obiecałem <VP><b>praca</b></VP> jest twoja.",
		"Dzięki temu masz teraz dostęp do <b><VP>kopalni</VP></b>\nSkieruj się do <b><VP>drzwi</VP></b> na lewą stronę od tego miejsca <b><VP>↓</VP></b> żeby mieć dostęp!",
		"Twoją pierwszą pracą będzie przyniesienie<b><VP> 15 rud żelaza</VP></b>. Powodzenia ponownie!",
		"Wow! Wygląda na to, że cię nie doceniłem, tak imponująca robota!",
		" Słyszałem, że <b><VP>zamek</VP></b> potrzebuje takich młodych ludzi jak ty, żeby ocalić swój skarb i księżniczkę przed złymi ludźmi...",
		"Możesz się do tego nadawać!",
		"Dam ci <b><VP>list polecający Nosferatusa</VP></b>, przedstaw to <b><VP>porucznikowi</VP></b> i miej nadzieję, że zwerbuje cię do armii.\n<i>iii są też z tego niezłe pieniądze</i>",
		"Och i nie zapomnij o swojej nagrodzie <b><VP>30 kamieni</VP></b> za całą ciężką pracę!",
		"Czy potrzebujesz czegoś?",
		"To dość ogólna wiedza... Musisz <b><VP>porąbać drzewo siekierą</VP></b>",
		"Zatem potrzebujesz <b><VP>siekiery</VP></b>? Powinna leżeć jedna w <b><VP>lesie</VP></b>. <b><VP>↓</VP></b> aby przestudiować i wykonać przepis w <b><VP>stacji rzemieślniczej</VP></b>.\nStacja znajduje się tuż nad kopalnią.",
		"Sprzedam <b><VP>10 kamieni</VP></b> za <b><VP>35 patyków</VP></b>",
		"W takim razie żegnam",
		" Twój ekwipunek wydaje się być pełny. Może opróżnij go i wróć po nagrodę.",
		"Interesy z tobą to przyjemność!",
		"Wygląda na to, że nie masz wystarczającej ilości przedmiotów, aby przeprowadzić tę transakcję, dzieciaku."
	},
	NOSFERATU_QUESTIONS = {
		"Jak zdobyć drewno?",
		"Siekiera?",
		"Wymiana",
		"Nieważne.",
		"It's something else."
	},
	EDRIC_DIALOGUES = {
		"Nasza księżniczka... i skarb są w rękach zła. Musimy się pośpieszyć",
		"Wstrzymaj się. Zatem mówisz, że <b><VP>Nosferatu</VP></b> przysłał cię tutaj, abyś pomógł naszym wojskom z misjami???",
		"To wspaniale. Ale praca dla armii nie jest taka prosta, jak ci się zdaje.\nBędziesz musiał wykonać <b><VP>intensywny trening</VP></b> zwłaszcza, że twoje ciało nie jest teraz w dobrej formie.\nUdaj się na <b><VP>plac treningowy po mojej lewej,</VP></b> aby rozpocząć swój trening.",
		"Ale wcześniej, upewnij się, że jesteś dobrze przygotowany. Jest tam kilka <b><VP>przepisów</VP></b> porozrzucanych wokół <b><VP>stojaków na broń</VP></b> i <b><VP>ponurych lasów na wzgórzu</VP></b>\nMam nadzieję, że zrobisz z nich dobry użytek!",
		"Odezwij się do mnie ponownie, kiedy będziesz wiedział, że jesteś gotowy!",
		"Czy jesteś gotów podjąć wyzwanie?",
		"To świetnie! Rozpocznij swój trening na placu treningowym. Aby zaliczyć to wyzwanie, musisz <b><VP>pokonać 25 potworów.</VP></b>",
		"Możesz, poświęcić tyle czasu ile tylko chcesz.\nŻyczę ci powodzenia!!!",
		"Udowodniłeś, że jesteś godzien! Pośpiesz się!!! Dołącz do reszty naszych żołnierzy i walcz z potworami!"
	},
	EDRIC_QUESTIONS = {
		"Potrzebuje więcej czasu...",
		"Jestem gotów!"
	},
	GARRY_DIALOGUES = {
		"To najgorsze miejsce, w jakim kiedykolwiek byłem. <b><VP>Nosferatu</VP></b> nawet nie płaci wystarczająco dużo. <i>*eh...*</i>"
	},
	THOMPSON_DIALOGUES = {
		"Cześć! Czy potrzebujesz czegoś ode mnie?",
		"Jeśli szukasz <b><VP>łopaty</VP></b>, powinna znajdować się ona <b><VP>po prawej stronie kopalni</VP></b>.\nPowodzenia!",
		"Miłego dnia!"
	},
	THOMPSON_QUESTIONS = {
		"Czy masz jakieś przepisy?",
		"Chciałem się tylko przywitać."
	},
	COLE_DIALOGUES = {
		"Jest tam wiele <b><VP>potworów</VP></b>. Bądź ostrożny!",
		"Cała nasza armia walczy przeciwko z potworami. Potrzebujemy dużo pomocy.",
		"OJJJJJ! NIE MOGĘ POZWOLIĆ, BY TAKI SŁABEUSZ JAK TY POSZEDŁ TĄ DROGĄ. WRACAJ TU!"
	},
	MARC_DIALOGUES = {
		"ZŁY TY! NIE dotykaj mojej pracy na ławce!"
	},
	SARUMAN_DIALOGUES = {
		"EJJJJJ!!!! EJJJJJJJJJ!!!!\nCZY JEST TAM KTOŚ???",
		"HEJJ!! POMÓŻ MI TAM!\nDZIĘKI BOGU, ZA URATOWANIE MNIE TUTAJ!!!",
		"Jestem <b><VP>Saruman</VP></b> swoją drogą. Utknąłem tu od jakichś...\n15 lat?",
		"Mój kumpel <b><VP>Hootie</VP></b> jest powodem, dla którego jeszcze żyje.\nGdyby nie on, umarłbym z głodu",
		"Więc chcesz wiedzieć, jak i dlaczego tu utknąłem?",
		"Cóż, w skrócie, kiedy byłem jeszcze <b>młody</b> i silny jak ty,\nsłyszałem o tych skarbach zwanych <b><VP>duchowymi kulami</VP></b>",
		"Ja też byłem profesorem, więc byłem bardzo zainteresowany badaniami na ten temat.\nZebrałem o nich mnóstwo informacji",
		"Te kule są związane z duszą. Gdy zostaną połączone ze wszystkimi <b><VP>5 kulami</VP></b> otrzymają <b><VP>boską moc</VP></b>",
		"Nie jestem pewien, jaką moc bym od nich otrzymał, ani co by mi zrobiły...\nAle jestem pewny, że <b><VP>mnisi</VP></b> wiedzą lepiej jak z tego korzystać!",
		"Ale nikt nie miał pojęcia, gdzie one dokładnie się znajdują, więc przyjechałem tutaj, aby znaleźć je wszystkie samemu.",
		"Myślę, że wykonałem całkiem niezłą robotę, znajdując jedną <VP><b>świątynie kul</b></VP>.\nAle... wybrałem złą ścieżkę i od tego czasu utknąłem tu na zawsze.",
		"Cieszę się, że mi pomogłeś! Porozmawiaj ze mną, aby dowiedzieć się coś o tych kulach.\nWiedza jest po to, aby się nią dzielić, a ty mnie uratowałeś!",
		"Tak kolego! Co chcesz ode mnie wiedzieć?",
		"Tak jak powiedziałem, jest <b><VP>5 duchowych kul</VP></b>\n<b><VP>3</VP></b> z nich można znaleźć w <b><VP>świątyniach</VP></b> w ponurym lesie.\nNie jestem pewien co do pozostałych 2, chociaż...",
		"Z informacji, które zebrałem, będziesz musiał stawić czoła różnym wyzwaniom, aby dostać się do świątyń.",
		"Myślę, że jedno już znasz, chyba że miałeś jakąś magiczną moc, aby się tu teleportować",
		"Druga świątynie jest strzeżona przez wiele <b><VP>potworów</VP></b> po drodze.\nWięc lepiej wyposaż się dobrze przed zwiedzaniem!",
		"A dla ostatniej świątyni znalazłem tą <b><VP>wskazówkę</VP></b> ze starożytnych ksiąg",
		"b><VP>\"Puzzles, and riddles, and old tradition\nMathematical score, but not addition",
		"To już wszystko! Mam nadzieję, że dobrze wykorzystasz te informacje",
		"Dzięki, że zainteresowałeś się co u mnie, kolego!",
		"OCH WYGLĄDA NA TO, ŻE ZEBRAŁEŚ WSZYSTKIE DUCHOWE KULE!!!\nJesteśmy teraz... podziękujesz mi później!\nAle upewnij się, że znajdziesz więcej informacji na temat tych kul od <b><VP>mnicha</VP></b>",
		"<b><VP>\"A resource that so fruitfully bore\nComes to term with ones true lore\"</VP></b>",
		"<b><VP>\"Take the rank shown to all\nTo the world you must call\"</VP></b>"
	},
	SARUMAN_QUESTIONS = {
		"Gdzię są kule?",
		"Tylko sprawdzam!"
	},
	MONK_DIALOGUES = {
		"Przez długi czas trzymałem tą złą siłę...\nCieszę się, że przyszedłeś nam z pomocą",
		"Więc powiadasz, że posiadasz wszystkie <b><VP>5 duchowych kul</VP></b>",
		"Całkiem dobra robota. Teraz ułatwi to pokonanie złej mocy na zawsze",
		"Te duchowe kule, rzeczywiście są związane z jakimś duchem\nTylko odważne osoby, mogą posiadać wszystkie 5",
		"Te duchowe kule pomogą Ci w <b><VP>boskiej mocy</VP></b>, która jest jedynym sposobem, aby zniszczyć zło\nZ tego co mi wiadomo",
		"Kiedy już aktywujesz boską moc i stawisz czoła złu...\nBędziesz musiał przebyć długą ścieżkę w swoim umyśle, aby osiągnać <b><VP>boski status</VP></b>",
		"Kulę duchów pomogą Ci znaleźć właściwą ścieżkę, aby to osiągnąć.\nMusisz tylko podróżować do sposobu, w jaki pokazuje Ci to we właściwym czasie!",
		"Jestem pewien, że nie uda Ci się to najpoteżniejszej boskiej energii.\nAle jeśli nawet podejdziesz bliżej...",
		"Stworzy ona wielką boską energię, która następnie przywoła <b><VP>boginię</VP></b>",
		"Starożytne księgi mówią, że bestia jest zbyt potężna, ale jestem całkiem pewien, że\n<b><VP>błogosławieństwo bogini</VP></b> postawiłoby ją w słabszym stanie",
		"To jest nasz czas, by na zawsze zniszczyć złą moc!!!",
		"Bogini... ona tu jest\nTO SIĘ DZIEJE!!!"
	},
	NIELS_DIALOGUES = {
		"Zostańcie na swoich pozycjach!",
		"<b><VP>Smok</VP></b> po drugiej stronie rzeki jest zbyt niebezpieczny.\nUżyje on swoich <b><VP>ognistych ataków</VP></b> i rzuci <b><VP>kamieniami</VP></b> na Ciebie",
		"Proszę bądź ostrożny...",
		"Nie możemy jednak bezpośrednio zaatakować smoka, ponieważ most wydaje się zepsuty",
		"Smok raz zniszczył go swoim ogniem, kiedy próbował go przekroczyć.",
		"Więc... będziemy musieli go naprawić, by do niego dotrzeć. Szybko!!!"
	},
	PROPS = {
		attack = "Atak",
		defense = "Obrona",
		durability = "Wytrzymałość",
		chopping = "Rąbanie",
		mining = "Wydobywanie"
	}
}



translations["ro"] = {
	OUT_OF_RESOURCES = "<font color='#ab5e42'>[</font> <font color='#c6b392'>•</font> <font color='#ab5e42'>]</font> <font color='#c6b392' face='Lucida Console'>S-au terminat resursele!</font>",
	NEW_RECIPE = "<font color='#506d3d' size='8'><b>[REȚETĂ NOUĂ]</b></font> <font color='#ab5e42' face='Lucida Console'><b>${itemName}</b></font>\n<font color='#bd9d60' size='11' face='Lucida Console'>(${itemDesc})</font>",
	NEW_QUEST = "<font color='#506d3d' size='8'><b>[QUEST NOU]</b></font> <font color='#ab5e42' face='Lucida Console'><b>${questName}</b></font>",
	NEW_STAGE = "<font color='#506d3d' size='8'><b>[UPDATE]</b></font> <font color='#ab5e42' face='Lucida Console'><b>${questName}</b></font>\n<font color='#bd9d60' size='11' face='Lucida Console'>(${desc})</font>",
	STAGE_PROGRESS = "<font color='#506d3d' size='8'><b>[UPDATE]</b></font> <font color='#ab5e42' face='Lucida Console'><b>${questName}</b></font> <font color='#bd9d60' size='11' face='Lucida Console'>( ${progress} / ${needed} )</font>",
	QUEST_OVER = "<font color='#506d3d' size='8'><b>[COMPLETAT]</b></font> <font color='#ab5e42' face='Lucida Console'><b>${questName}</b></font>",
	SPIRIT_ORB = "<b><font color='#ab5e42' face='Lucida Console'>You received a <font color='#bd9d60' face='Lucida Console'>glob al spiritelor!</font></font></b>",
	PASSCODE = "Vă rog, introduceți cuvântul cheie.",
	WRONG_GUESS = "<R>Cheie de access invalidă.</R>",
	INVENTORY_INFO = "<font face='Lucida Console'><p align='center'><font color='#${color}' size='9'>Greutate: ${weight}</font>\n\n\n\n<font size='9'><N2><b>[X] Aruncă</b></N2></font></p></font>",
	FULL_INVENTORY = "<font color='#ab5e42'>[</font> <font color='#c6b392'>•</font> <font color='#ab5e42'>]</font> <font color='#c6b392' face='Lucida Console'>Inventar plin!</font>",
	FINAL_BOSS_ENTER_FAIL = "<font color='#ab5e42'>[</font> <font color='#c6b392'>•</font> <font color='#ab5e42'>]</font> <font color='#c6b392' face='Lucida Console'>Trebuie să găsești globul spiritelor de Dragon pentru a intra!</font>",
	CRAFT = "Creează!",
	CANT_CRAFT = "Nu poate fi meșteșugărit",
	RECIPE_DESC = "\n\n<font face='Lucida console' size='12' color='#999999'><i>“ ${desc} ”</i></font>",
	FINAL_BATTLE_PING = "<font color='#ab5e42'>[</font> <font color='#c6b392'>•</font> <font color='#ab5e42'>]</font> <font color='#c6b392' face='Lucida Console'>Lupta finală începe!</font>",
	ACTIVATE_POWER = "<font color='#ab5e42'>[</font> <font color='#c6b392'>•</font> <font color='#ab5e42'>]</font> <font color='#c6b392' face='Lucida Console'>Tastează <font color='#ab5e42'><b>U</b></font> pentru a folosi <font color='#ab5e42'><b>puterea divină!</b></font></font>",
	ANNOUNCER_DIALOGUES = {
		"ATENȚIE, FIECARE! ATENȚIE!!!",
		"Acest mesaj e de la maiestatea sa, regele glorios al acestui meleag...",
		"Patria noastră este atacată de către monțtrii nemiloși cândva înfrânși.",
		"A continuat o întâmplare groaznică care urmează să fie anunțată. <b><VP>Prințesa noastră a fost răpită.</VP></b>",
		"Monștrii nemiloși au reușit și să fugă cu întregul tezaur al regatului nostru.",
		"Regele caută SOLDAȚI CURAJOȘI care vor ajuta armata să lupte contra monștri și să salveze prințesa\nși bogățiile noastre",
		"Regele speră să fie prezente toate inimile curajoase...\n"
	},
	NOSFERATU_DIALOGUES = {
		"Ahh, se pare că ești nou aici... oricum, se vede că ești de folos",
		"Deci, spui că ai venit dintr-o altă dimensiune și că n-ai habar unde ești și ce trebuie să faci\n<i>*Poate că chiar îmi va fi de folos</i>",
		"Ei bine tinere, cred că îți va trebui o meserie ca să trăiești. Nu-ți fă griji, îți găsesc eu de lucru, da da.",
		"Dar... înainte de toate, trebuie să verificăm dacă ești într-o stare fizică cum se cuvine.\nStrânge-mi <VP><b>15 lemn</b></VP> din pădure.\nIa aceste <VP><b>10 pietre</b></VP> în avans. Baftă!",
		"Impresionant. Dar <i>pe vremurile noastre</i> o făceam mult mai repede...\nNu că ar conta acum. Cum am promis <VP><b>slujba</b></VP> e a ta.",
		"Acum ai acces la <b><VP>mină</VP></b>\nIa-o spre<b><VP>ușa</VP></b> la stânga de aici și fă <b><VP>↓</VP></b> pentru a o accesa!",
		"Ca primă sarcină, vreau să strângi<b><VP> 15 minereuri de fier</VP></b>. Mult noroc din nou!",
		"Uau! Se pare că te-am subestimat, treabă minunată!",
		"Am auzit că <b><VP>palatul</VP></b> are nevoie de niște indivizi ca tine să-i salveze comorile și prințesa de cei malefici...",
		"Ai putea fi un bun candidat pentru asta!",
		"Îți voi da <b><VP>scrisoarea de recomandare a lui Nosferatu</VP></b>, prezint-o <b><VP>Locotenentului</VP></b> și să sperăm că te va lua la armată.\n<i>șiii aia-s niște bani buni</i>",
		"O, nu uita de recompensa de <b><VP>30 pietre</VP></b> pentru tot lucrul tău!",
		"Pot să te ajut cu ceva?",
		"Asta-i ceva bine știut... Trebuie să <b><VP>tai un copac cu un topor</VP></b>",
		"Deci, cauți un <b><VP>topor</VP></b>? Ar trebui să fie unul undeva prin <b><VP>pădure</VP></b>. <b><VP>↓</VP></b> pentru a-l studia și a înregistra rețeta în<b><VP>punctul de meșteșuguri</VP></b>.\nO locație poate fi găsită chiar deasupra acestei mine.",
		"Eu vând <b><VP>10 pietre</VP></b> pentru <b><VP>35 bețe</VP></b>",
		"Ah, pe curând atunci",
		"Inventarul tău pare a fi plin. Ce zici să-l golești și să revii după recompensă.",
		"Îmi face plăcere să fac afeceri cu tine!",
		"Se pare că nu ai destule resurse pentru asta, copile."
	},
	NOSFERATU_QUESTIONS = {
		"Cum fac rost de lemn?",
		"Topor?",
		"Schimb",
		"Las-o baltă.",
		"It's something else."
	},
	EDRIC_DIALOGUES = {
		"Prințesa noastră... și comoara sunt în mâinile răului. Trbuie să ne grăbim",
		"Stai puțin. Deci tu spui că <b><VP>Nosferatu</VP></b> te-a trimis aici și ne poți ajuta cu misiunea???",
		"Superb. Însă, să lucrezi într-o armată nu e așa simplu cum crezi.\nVa fi nevoie să treci prin niște <b><VP>antrenamente intensive</VP></b> considerând că nu ești în formă.\nIa-o spre <b><VP>punctul de antrenamente la stânga mea</VP></b> pentru a-ți începe antrenamentul.",
		"Înainte de asta, asigură-te că ești pregătit. Sunt câteva <b><VP>rețete</VP></b> împrăștiate printre <b><VP>rafturile cu arme</VP></b> și <b><VP>pădurile mohorâte</VP></b>\nSper că le vei folosi cu putință!",
		"Vino la mine din nou când crezi că ești pregătit!",
		"Ești gata să accepți provocarea?",
		"Bine! Începe antrenamentul în zona de antrenamente Trebuie să <b><VP>înfrângi 25 de monștri</VP></b> pentru a trece încercarea.",
		"Poți lua cât timp ai nevoie\nMultă baftă!!!",
		"Ai demonstrat că ești de valoare! Repede!!! Alătură-te celorlalți soldați și luptă cu monștrii!"
	},
	EDRIC_QUESTIONS = {
		"Îmi trebuie mai mult timp...",
		"Sung gata!"
	},
	GARRY_DIALOGUES = {
		"Acesta e cel mai rău loc în care am fost. <b><VP>Nosferatu</VP></b> nici măcar nu plătește destul. <i>*sigh...*</i>"
	},
	THOMPSON_DIALOGUES = {
		"Bună! Pot să-ți ofer ceva?",
		"Dacă cauți o <b><VP>lopată</VP></b>, ar trebui să fie una <b><VP>în capăt, la dreapta mea</VP></b>.\nBaftă!",
		"Să ai o zi bună!"
	},
	THOMPSON_QUESTIONS = {
		"Vreo rețetă?",
		"Doar îți spun salut."
	},
	COLE_DIALOGUES = {
		"Sunt o mulțime <b><VP>de monștri</VP></b> acolo. Fii atent!",
		"Toată armata noastră confruntă monștrii. Avem nevoie de mult ajutor.",
		"Stai! NU POT LĂSA UN LAȘ CA TINE SĂ MEARGĂ ACOLO. VINO ÎNAPOI AICI!"
	},
	MARC_DIALOGUES = {
		"RĂUTATE! NU-mi atinge lucrul pe bancă!"
	},
	SARUMAN_DIALOGUES = {
		"EI!!!! EIIIIII!!!!\nE CINEVA AICI???",
		"HEII!! AJUTOR!\nSLAVĂ CERULUI CĂ AJUTĂ CINEVA!!!",
		"Eu sunt<b><VP>Saruman</VP></b>. Am rămas blocat aici pe viață...\n15 ani?",
		"Prietenul meu <b><VP>Hootie</VP></b> este motivul din care trăiesc.\nFără el aș fi murit de foame",
		"Deci, vrei să știi cum am ajuns blocat aici?",
		"E o istorie lungă, când încă eram <b>tânăr</b> și puternic ca tine.\nAm auzit despre niște comori numite <b><VP>globuri ale spiritelor</VP></b>",
		"Eram și profesor și eram curios să cercetez această temă.\nAm strâns multă informație despre ele",
		"Aceste globuri sunt legate de sufletul cuiva. Odată ce sufletul e legat de toate <b><VP>5 globuri</VP></b>, va obține <b><VP>puterea divină</VP></b>",
		"Nu știu ce fel de putere aș primit sau ce mi-ar face globurile...\nDar sunt sigur că <b><VP>călugării</VP></b> știu cum să le folosească!",
		"Nimeni nu știa unde se află concret, așa că am venit aici să le găsesc de unul singur.",
		"Cred că m-am descurcat de minune să găsesc un <VP><b>glob din altar</b></VP>.\nDar... Am ales drumul greșit și am rămas blocat aici pentru totdeauna.",
		"Sunt fericit că m-ai ajutat! Întreabă-mă oricând despre aceste globuri.\nCunoștințele sunt făcute pentru a fi împărtășite, iar tu m-ai salvat!",
		"Da, amice! Ce ai vrea să afli?",
		"Cum am mai spus, există <b><VP>5 globuri ale spiritelor</VP></b>\n<b><VP>3</VP></b> din ele pot fi găsite în <b><VP>altare</VP></b> în pădurea asta mohorâtă.\nNu sunt sigur cum rămâne cu celelalte 2...",
		"Din informația pe care am strâns-o, vei fi pus la încercare când vei decide să intri în altare.",
		"Cred că știi unul deja, doar dacă nu cumva ai vreo putere magică care te-a adus aici",
		"Al doilea altar e păzit de o mulțime de <b><VP>monștri</VP></b> de jur împrejur.\nPregătește-te bine înainte să pui piciorul acolo!",
		"Și pentru ultimul altar, am găsit acest <b><VP>indiciu</VP></b> din cărți antice",
		"<b><VP>\"Enigme, și ghicitori, și vechia tradiție a \nscorului Matematic, dar nu și adunarea\nUn resurs care a ținut atât de rodnic\nSe împacă cu adevărata lor moștenire\nIa rangul arătat tuturor\nCătre lume trebuie chemat\"</VP></b>",
		"Asta-i tot! Sper să folosești această informașie cum trbuie",
		"Mulțumesc că m-ai vizitat!",
		"O, SE PARE CĂ AI FĂCUT ROST DE TOATE GLOBURILE!!!\nAm reușit acum... mă vei mulțumi mai târziu!\nNu uita să dobândești mai multă informație de la un <b><VP>călugăr</VP></b>"
	},
	SARUMAN_QUESTIONS = {
		"Unde sunt globurile?",
		"Doar verificam!"
	},
	MONK_DIALOGUES = {
		"Am ținut această forță malefică sub control pentru mult timp...\nBucuros să văd că ne sari în ajutor",
		"Spui că ai dobâdit toate cele <b><VP>5 globuri ale spiritelor</VP></b>",
		"Bună treabă. Asta ne va ajuta să înfrângem răul odată pentru totdeauna",
		"Aceste globuri de spirite sunt întradevăr legate de sufletul cuiva\nDoar cei curajoși pot poseda toate 5 globuri",
		"Aceste globuri te vor ajuta să obții<b><VP>puterea divină</VP></b>, ceea ce e unica metodă de a distruge răul\ndin câte știu",
		"Odată ce ai activat puterea divină și ai confruntat răul...\nVei fi nevoit(ă) să parcurgi un drum lung prin mintea tea pentru a obține <b><VP>statutul divin</VP></b>",
		"Globurile spiritelor de vor ajuta să găsești drumul corect.\nTrebuie doar să urmezi direcția care ți-o arată la timpul potrivit!",
		"Sunt sigur că nu vei reuși să obții cea mai superioară putere.\nDar chiar și dacă de apropii...",
		"Va crea un val imens de energie care va convoca <b><VP>zeița</VP></b>",
		"Cărțile vechi spun că bestia e prea puternică, dar eu sunt sigur că\n<b><VP>binecuvântarea zeiței</VP></b> o va slăbi",
		"Acum e timpul să distrugem răul pentru totdeauna!!!",
		"Zeița... e aici\nSE ÎNTÂMPLĂ!!!"
	},
	NIELS_DIALOGUES = {
		"Toată lumea, pe poziție!",
		"<b><VP>Dragonul/VP></b> de peste râu e prea periculos.\nÎși va folosi <b><VP>atacurile de foc</VP></b> și va <b><VP>arunca pietre</VP></b> peste tine",
		"Te rog, fii atent(ă)...",
		"Nu putem ataca dragonul direct, pentru că podul e stricat",
		"Dragonul l-a distrus cu respirația sa de foc când a încercat să-l treacă.",
		"Deci... va fi nevoie să-l reparăm ca să-l ajungem. Grăbiți-vă!!!"
	},
	PROPS = {
		attack = "Atac",
		defense = "Apărare",
		durability = "Durabilitate",
		chopping = "Tăiere",
		mining = "Săpare"
	}
}

-- theme color pallete: https://www.colourpod.com/post/173929539115/a-medieval-recipe-for-murder-submitted-by

translations["ar"] = {
	OUT_OF_RESOURCES = "<font color='#ab5e42'>[</font> <font color='#c6b392'>•</font> <font color='#ab5e42'>]</font> <font color='#c6b392' face='Lucida Console'>نفذت الموارد</font>",
	NEW_RECIPE = "<font color='#506d3d' size='8'><b>[وصفة جديدة]</b></font> <font color='#ab5e42' face='Lucida Console'><b>${itemName}</b></font>\n<font color='#bd9d60' size='11' face='Lucida Console'>(${itemDesc})</font>",
	NEW_QUEST = "<font color='#506d3d' size='8'><b>[مهمة جديدة]</b></font> <font color='#ab5e42' face='Lucida Console'><b>${questName}</b></font>",
	NEW_STAGE = "<font color='#506d3d' size='8'><b>[تحديث]</b></font> <font color='#ab5e42' face='Lucida Console'><b>${questName}</b></font>\n<font color='#bd9d60' size='11' face='Lucida Console'>(${desc})</font>",
	STAGE_PROGRESS = "<font color='#506d3d' size='8'><b>[تحديث]</b></font> <font color='#ab5e42' face='Lucida Console'><b>${questName}</b></font> <font color='#bd9d60' size='11' face='Lucida Console'>( ${progress} / ${needed} )</font>",
	QUEST_OVER = "<font color='#506d3d' size='8'><b>[اكتملت المهمة]</b></font> <font color='#ab5e42' face='Lucida Console'><b>${questName}</b></font>",
	SPIRIT_ORB = "<b><font color='#ab5e42' face='Lucida Console'>لقد تلقيت <font color='#bd9d60' face='Lucida Console'>!روح الجرم السماوي</font></font></b>",
	PASSCODE = ".الرجاء إدخال مفتاح الوصول",
	WRONG_GUESS = "<R>.مفتاح الوصول غير صحيح</R>",
	INVENTORY_INFO = "<font face='Lucida Console'><p align='center'><font color='#${color}' size='9'>:وزن ${weight}</font>\n\n\n\n<font size='9'><N2><b>[X] ارمي</b></N2></font></p></font>",
	FULL_INVENTORY = "<font color='#ab5e42'>[</font> <font color='#c6b392'>•</font> <font color='#ab5e42'>]</font> <font color='#c6b392' face='Lucida Console'>المخزون الخاص بك هو الكامل</font>",
	FINAL_BOSS_ENTER_FAIL = "<font color='#ab5e42'>[</font> <font color='#c6b392'>•</font> <font color='#ab5e42'>]</font> <font color='#c6b392' face='Lucida Console'>تحتاج إلى الحصول على الجرم السماوي التنين للدخول إلى هذه البوابة/font>",
	CRAFT = "اصنع",
	CANT_CRAFT = "لاتستطيع الصنع",
	RECIPE_DESC = "\n\n<font face='Lucida console' size='12' color='#999999'><i>“ ${desc} ”</i></font>",
	FINAL_BATTLE_PING = "<font color='#ab5e42'>[</font> <font color='#c6b392'>•</font> <font color='#ab5e42'>]</font> <font color='#c6b392' face='Lucida Console'>!المعركة النهائية تحدث</font>",
	ACTIVATE_POWER = "<font color='#ab5e42'>[</font> <font color='#c6b392'>•</font> <font color='#ab5e42'>]</font> <font color='#c6b392' face='Lucida Console'>اضغط <font color='#ab5e42'><b>U</b></font> للتبديل <font color='#ab5e42'><b>القوة العظمى</b></font></font>",
	ANNOUNCER_DIALOGUES = {
		"انتبهوا الجميع! الانتباه!!!",
		"...هذه الرسالة من صاحب الجلالة ملك هذه الأرض",
		".تتعرض أرضنا للهجوم من قبل الوحوش التي لا تعرف الرحمة التي هُزمت منذ فترة",
		".يأتي هذا في أعقاب الحدث المؤسف الذي لم يتم الإعلان عنه بعد \n<b><VP>.تم اختطاف أميرتنا</VP></b>",
		".تمكنت الوحوش التي لا تعرف الرحمة أيضًا من الإفلات تقريبًا من الخزانة التي كانت لدينا",
		"يبحث الملك عن جنود شجعان يساعدون الجيش على هزيمة كل هذه الوحوش وإنقاذ الأميرة\n مع خزانتنا",
		"...الملك يأمل في حضور كل القلوب الشجاعة\n"
	},
	NOSFERATU_DIALOGUES = {
		"آه تبدو جديدًا تمامًا هنا على أي حال تبدو مفيدًا",
		"إذن أنت تقول ، لقد أتيت إلى هنا من بُعد آخر وليس لديك أي فكرة عن مكانك أو ما يجب القيام به على الإطلاق\n<i>*حسنًا ، ربما يكون مفيدًا لي حقًا</i>",
		"حسنًا أيها الشاب ، أعتقد أنك بحاجة إلى عمل لتعيش فيه. لا تقلق بشأن ذلك ، سأعطيك وظيفة نعم نعم",
		".لكن ... قبل ذلك ، نحتاج إلى التحقق مما إذا كنت في حالة بدنية جيدة\n <VP><b> 15 خشب </b></VP> اجمع.\nبالنسبة لي من الغابة\nاحصل على هؤلاء \n<VP><b>10 حجر</b></VP>\n!كمقدم. حظا طيبا وبالتوفيق",
		"مثير للإعجاب حقا. ولكن \n<i>في ايامنا</i> ...لقد فعلناها بشكل أسرع \nليس مثل ما يهم الآن. كما وعدت \n .انها لك <VP><b>الوظيفة</b></VP> ",
		"ومع ذلك ، يمكنك الآن الوصول إلى \n<b><VP>منجم</VP></b>\nتوجه الى\n<b><VP>الباب</VP></b>\n على الجانب الأيسر من هنا و \n<b><VP>↓</VP></b>!للوصول إليه",
		"باعتبارها وظيفتك الأولى ، أحتاج منك أن تجمع\n<b><VP> 15 قطعة حديد</VP></b>\n !حظا سعيدا مرة أخرى",
		"!واو! يبدو أنني قللت من تقديرك ، يا له من عمل مثير للإعجاب",
		"لقد سمعت ان \n<b><VP>القلعة</VP></b> \n...تحتاج إلى بعض الشباب مثلك لإنقاذ خزنتها والأميرة من الأشرار",
		" من الممكن ان تكون مناسبا لذلك",
		"سوف اعطيك \n<b><VP>رسالة توصية نوسفيراتو\n</VP></b>, قدم هذا لـ \n<b><VP>الملازم</VP></b>\n .ونأمل أن يجندك في الجيش\n<i>وهذا بعض المال الجيد أيضًا</i>",
		"أوه ولا تنسى مكافأتك \n<b><VP>30 حجر</VP></b>\n!لكل العمل الشاق",
		"هل تحتاج لأي شيء؟",
		"هذه معرفة عامة تمامًا ... أنت بحاجة إلى\n <b><VP>قطع الشجرة بالفأس</VP></b>",
		"لذلك أنت بحاجة إلى  \n<b><VP>فأس</VP></b> \nيجب أن يكون هناك واحد في جوار \n<b><VP>الغابة</VP></b>. <b><VP>↓</VP></b>\n لدراستها وصياغة الوصفة المدروسة في\n <b><VP>محطة صياغة</VP></b>\n.تقع المحطة فوق هذا المنجم مباشرةً",
		"انا ابيع \n<b><VP>10 حجر</VP></b>\n مقابل \n<b><VP>35 عصا</VP></b>",
		"آه طيب وداعا بعد ذلك",
		".يبدو أن مخزونك ممتلئ. ماذا عن تفريغها بالاول بعد ذالك يمكنك ان تعود لمكافأتك",
		"!سعيد بالتعامل معك",
		".يبدو أنه ليس لديك عناصر كافية للقيام بهذه التجارة"
	},
	NOSFERATU_QUESTIONS = {
		"كيف أحصل على الخشب؟",
		"فأس؟",
		"تبادل",
		".لا تهتم",
		"It's something else."
	},
	EDRIC_DIALOGUES = {
		"أميرتنا ... والخزانة في أيدي الشر. علينا أن نسرع",
		"توقف. انت تقول ان \n<b><VP>نوسفيراتو</VP></b>\n أرسلتك إلى هنا ويمكنك مساعدة قواتنا في المهمات ؟؟؟",
		".ذلك رائع. لكن العمل في جيش ليس بالأمر السهل كما تعتقد\nسوف تحتاج إلى القيام ببعض \n<b><VP>تدريب مكثف</VP></b> \n.مع الأخذ في الاعتبار أن جسمك ليس بالقوة المطلوبة أيضًا\nاتجه الى \n<b><VP>منطقة التدريب على الجانب الأيسر مني</VP></b>\n. لبدء تدريبك",
		"لكن قبل ذلك ، تأكد من أنك على استعداد تام. هناك القليل \n<b><VP>وصفات</VP></b> \nمنتشرة حول \n<b><VP>رفوف السلاح</VP></b> و <b><VP>الغابات القاتمة أسفل التل</VP></b>\n!آمل أن تستفيد منهم بشكل جيد",
		"!تحدث معي مرة أخرى عندما تعتقد أنك مستعد",
		"هل انت مستعد لقبول التحدي؟",
		"رائعة! اذهب وابدأ تدريبك في منطقة التدريب. أنت بحاجه إلى \n<b><VP>هزيمة 25 وحشًا</VP></b>\n .لاجتياز هذا التحدي",
		"!!!يمكنك أن تأخذ الكثير من الوقت الذي تريده لك حظًا سعيدًا ",
		"لقد أثبتت أنك مستحق! عجل!!! انضم إلى بقية جنودنا وحارب الوحوش!"
	},
	EDRIC_QUESTIONS = {
		"...أنا بحاجة لمزيد من الوقت",
		"!أنا مستعد"
	},
	GARRY_DIALOGUES = {
		".هذا هو أسوأ مكان ذهبت إليه على الإطلاق \n<b><VP>نوسفيراتو</VP></b>\n... لا يدفع ما يكفي حتى \n<i>*...تنهد*</i>"
	},
	THOMPSON_DIALOGUES = {
		"مرحبًا! هل تريد شيئا مني؟",
		"إذا كنت تبحث عن \n<b><VP>مجرفة</VP></b>\n يجب أن يكون هناك واحد في \n<b><VP>الجزء الأيمن من المنجم</VP></b>\n!حظا سعيدا",
		"!أتمنى لك يوم سعيد"
	},
	THOMPSON_QUESTIONS = {
		"أي وصفات؟",
		".فقط ألقي التحية"
	},
	COLE_DIALOGUES = {
		"هناك الكثير من \n<b><VP>الوحوش</VP></b>\n !في الخارج. رجاءا كن حذرا",
		".كل جيشنا يقاتل ضد الوحوش. نحن بحاجة إلى الكثير من المساعدة",
		".هييييي, انا لا استطيع ان ادعك تذهب هذا الطريق. ارجع في الحال"
	},
	MARC_DIALOGUES = {
		"انت سيء, لاتلمس طاولة العمل"
	},
	SARUMAN_DIALOGUES = {
		"!!!!هيييييييييييي!!!!هيييييي\nهل يوجد أحد ؟؟؟",
		"مهلا !! ساعدني في الخروج من هناك!\n!!!شكراً لله على أنقذك لي هنا",
		"انا \n<b><VP>سلمان</VP></b>\n ...على فكرة. لقد علقت هنا منذ ما يقرب\n15 سنة",
		"صديقي \n<b><VP>هادي</VP></b> \n.هو السبب في أنني ما زلت على قيد الحياة\nكنت سأموت من الجوع من دونه",
		"هل تريد أن تعرف كيف ولماذا أنا عالق هنا؟",
		"حسنًا ، قصة طويلة قصيرة ، عندما كنت لا أزال \nوقوي مثلك <b>يافع</b>\nسمعت عن هذه الكنوز تسمى \n<b><VP>روح الأجرام السماوية</VP></b>",
		".كنت أستاذًا أيضًا ، لذلك كنت مهتمًا جدًا بالبحث عن هذا الموضوع\nلقد جمعت الكثير من المعلومات عنهم",
		"هذه الأجرام السماوية مرتبطة بالروح. بمجرد أن يتم ربطهم مع الجميع \n<b><VP>الخمس الأجرام السماوية</VP></b>\n سيتم منحهم \n<b><VP> القوة الإلهية</VP></b>",
		"...لست متأكدًا من نوع القوة التي سأحصل عليها منهم أو ماذا سيفعلون بي \nلكنني متأكد من أن \n<b><VP>الشيوخ</VP></b>\n !يعرفون المزيد عن كيفية استخدامها",
		".لكن لم يعرف أحد مكانهم بالضبط ، لذلك جئت إلى هنا للعثور عليهم جميعًا بنفسي",
		"أعتقد أنني قمت بعمل جيد في العثور على واحد \n<VP><b>ضريح الجرم السماوي</b></VP>.\n.لكن ... اخترت الطريق الخطأ وظللت هنا إلى الأبد منذ ذلك الحين",
		".أنا سعيد لأنك ساعدتني! لا تتردد في التحدث معي لمعرفة أي شيء عن هذه الأجرام السماوية\nالمعرفة موجودة للمشاركة ، ولانك أنقذتني!",
		"نعم يا صاحبي! ماذا تريد ان تعرف مني؟",
		"كما قلت هناك \n<b><VP>خمس ارواح اجرام سماوية</VP></b>\n<b><VP>3</VP></b> يوجد \n يمكن العثور على منهم في \n<b><VP>الأضرحة</VP></b>\n .في هذه الغابة القاتمة\nأنا غير متأكد تمامًا من الباقي 2 على الرغم من ",
		".من المعلومات التي جمعتها ، سيتعين عليك مواجهة تحديات مختلفة للوصول إلى الأضرحة",
		"أعتقد أنك تعرف واحدًا بالفعل ما لم يكن لديك بعض القوة السحرية للانتقال الفوري هنا",
		"الضريح الثاني يحرسه الكثير من \n<b><VP>الوحوش</VP></b>\n في هذا الطريق \n!لذا جهز نفسك جيدًا قبل الاستكشاف هناك",
		"ووجدت هذا في الضريح الأخير \n<b><VP>دليل</VP></b>\n من الكتب القديمة",
		"<b><VP>\"الألغاز والأحاجي والتقاليد القديمة\nالنتيجة الرياضية ، ولكن ليس الجمع\nمورد مثمر للغاية\nيأتي مع تلك التقاليد الحقيقية\nخذ المرتبة المعروضة للجميع\nإلى العالم يجب عليك الاتصال\"</VP></b>",
		"هذا كل شئ! آمل أن تستفيد من هذه المعلومات بشكل جيد",
		"!شكرا لتفقدك لي يا صديقي",
		"!!!تبدو أوه وكأنك جمعت كل ارواح الاجرام السماوية \n نحن متعادلان الان ... اشكرني لاحقا\nولكن تأكد من العثور على مزيد من المعلومات حول هذه الأجرام السماوية من \n<b><VP>الشيخ</VP></b>"
	},
	SARUMAN_QUESTIONS = {
		"أين الأجرام السماوية؟",
		"!أتحقق وحسب"
	},
	MONK_DIALOGUES = {
		"...لقد كنت أمسك بهذه القوة الشريرة لفترة طويلة \nسعيد لسماع أنك أتيت لمساعدتنا",
		"لذا فأنت تخبرني أنك تمتلك كل  \n<b><VP> خمس ارواح الأجرام السماوية</VP></b>",
		"إنه عمل جيد بالفعل. الآن هذا سيجعل من السهل هزيمة قوة الشر إلى الأبد",
		"هذه الأجرام السماوية الروحية مرتبطة بالفعل بروح المرء\nيمكن للأفراد الشجعان فقط امتلاك كل الخمسة",
		"هذه الأجرام السماوية سوف تساعدك على الحصول على \n<b><VP>القوة الإلهية</VP></b>\n وهي الطريقة الوحيدة لتدمير الشر\nبقدر ما أعرف",
		"بمجرد تفعيل القدرة الإلهية ومواجهة الشر\nسيتعين عليك السير في طريق طويل داخل عقلك لتحقيق \n<b><VP>الوضع الإلهي</VP></b>",
		"ستساعدك الأجرام السماوية الروحية على إيجاد الطريق الصحيح لتحقيق ذلك\nما عليك سوى السفر بالطريقة التي تظهر بها لك في الوقت المناسب",
		"أنا متأكد من أنك لن تنجح في الحصول على أقوى طاقة إلهية\nلكن حتى لو اقتربت",
		"سيخلق طاقة إلهية كبيرة تستدعي بعد ذلك \n<b><VP>هيرا</VP></b>",
		"تقول الكتب القديمة أن الوحش قوي للغاية لكنني متأكد من أن\n<b><VP>مباركة هيرا</VP></b> \nسيضعها في حالة أضعف",
		"!!!وهو وقتنا إذًا أن نقضي على قوة الشر إلى الأبد",
		"!!!هيرا انها هنا\n!!!إنه يحدث"
	},
	NIELS_DIALOGUES = {
		"!الجميع يحتفظون بمواقعهم",
		"<b><VP>التنين</VP></b> \nعلى الجانب الآخر من النهر خطير جدًا\nسوف يستخدم\n<b><VP>الهجمات النارية</VP></b> \nوسوف \n<b><VP>يرمي الحجارة</VP></b> \nعليك",
		"...رجاءا كن حذرا",
		"ومع ذلك ، لا يمكننا مهاجمة التنين مباشرة ، حيث يبدو أن الجسر مكسور",
		"لقد دمره التنين مرة بناره عندما كان يحاول عبوره",
		"!!!لذلك علينا إصلاحه حتى نصل إليه أيضا"
	},
	PROPS = {
		attack = "هجوم",
		defense = "دفاع",
		durability = "قوة التحمل",
		chopping = "قطع",
		mining = "التعدين"
	}
}

-- theme color pallete: https://www.colourpod.com/post/173929539115/a-medieval-recipe-for-murder-submitted-by

translations["tr"] = {
	OUT_OF_RESOURCES = "<font color='#ab5e42'>[</font> <font color='#c6b392'>•</font> <font color='#ab5e42'>]</font> <font color='#c6b392' face='Lucida Console'>Yetersiz kaynak!</font>",
	NEW_RECIPE = "<font color='#506d3d' size='8'><b>[YENİ TARİF]</b></font> <font color='#ab5e42' face='Lucida Console'><b>${itemName}</b></font>\n<font color='#bd9d60' size='11' face='Lucida Console'>(${itemDesc})</font>",
	NEW_QUEST = "<font color='#506d3d' size='8'><b>[YENİ GÖREV]</b></font> <font color='#ab5e42' face='Lucida Console'><b>${questName}</b></font>",
	NEW_STAGE = "<font color='#506d3d' size='8'><b>[İLERLEME]</b></font> <font color='#ab5e42' face='Lucida Console'><b>${questName}</b></font>\n<font color='#bd9d60' size='11' face='Lucida Console'>(${desc})</font>",
	STAGE_PROGRESS = "<font color='#506d3d' size='8'><b>[İLERLEME]</b></font> <font color='#ab5e42' face='Lucida Console'><b>${questName}</b></font> <font color='#bd9d60' size='11' face='Lucida Console'>( ${progress} / ${needed} )</font>",
	QUEST_OVER = "<font color='#506d3d' size='8'><b>[TAMAMLANDI]</b></font> <font color='#ab5e42' face='Lucida Console'><b>${questName}</b></font>",
	SPIRIT_ORB = "<b><font color='#ab5e42' face='Lucida Console'>Bir <font color='#bd9d60' face='Lucida Console'>ruh küresi</font> elde ettin!</font></b>",
	PASSCODE = "Lütfen erişmek için şifreyi girin.",
	WRONG_GUESS = "<R>Yanlış erişim şifresi.</R>",
	INVENTORY_INFO = "<font face='Lucida Console'><p align='center'><font color='#${color}' size='9'>Ağırlık: ${weight}</font>\n\n\n\n<font size='9'><N2><b>[X] At</b></N2></font></p></font>",
	FULL_INVENTORY = "<font color='#ab5e42'>[</font> <font color='#c6b392'>•</font> <font color='#ab5e42'>]</font> <font color='#c6b392' face='Lucida Console'>Envanterin dolu!</font>",
	FINAL_BOSS_ENTER_FAIL = "<font color='#ab5e42'>[</font> <font color='#c6b392'>•</font> <font color='#ab5e42'>]</font> <font color='#c6b392' face='Lucida Console'>Portaldan geçebilmek için Ejderha'nın ruh küresini elde etmen gerekiyor!</font>",
	CRAFT = "Üret!",
	CANT_CRAFT = "Üretilemiyor",
	QUESTS = "<font size='15' face='Lucida console'><b><BV>Görevler</BV></b></font>\n\n",
	RECIPE_DESC = "\n\n<font face='Lucida console' size='12' color='#999999'><i>“ ${desc} ”</i></font>",
	FINAL_BATTLE_PING = "<font color='#ab5e42'>[</font> <font color='#c6b392'>•</font> <font color='#ab5e42'>]</font> <font color='#c6b392' face='Lucida Console'>Final savaşı gerçekleşiyor!</font>",
	ACTIVATE_POWER = "<font color='#ab5e42'>[</font> <font color='#c6b392'>•</font> <font color='#ab5e42'>]</font> <font color='#c6b392' face='Lucida Console'><font color='#ab5e42'><b>Kutsal güce</b></font> geçiş yapmak için <font color='#ab5e42'><b>U tuşuna</b></font> basın. </font>",
	ANNOUNCER_DIALOGUES = {
		"HERKESE DİKKAT! DİKKAT DİKKAT!!!",
		"Bu mesaj majestelerimizdendir, bu toprakların ihtişamlı kralı...",
		"Topraklarımız, bir süre önce de yendiğimiz acımasız canavarlar tarafından saldırı altındadır.",
		"Bu henüz açıklamadığımız talihsiz bir olayı beraberinde getirdi. <b><VP>Prensesimiz kaçırıldı.</VP></b>",
		"Acımasız canavarlar ayrıca topladığımız tüm hazineleri de alıp kaçmayıp başardı.",
		"Kral tüm bu canavarları yenmek ve prensesi kurtarmak için orduya yardım edecek CESUR ASKERLER arıyor\nve hazinemizi kurtaracak",
		"Kral tüm cesur yüreklilerin varlığına inanıyor olacak...\n"
	},
	NOSFERATU_DIALOGUES = {
		"Ahh burada çok yeniymiş gibi duruyorsun... neyse aynı zamanda işe yarar gibisin",
		"Öyleyse buraya başka bir boyuttan geldiğini ve nerede olduğunu, ne yapacağını bilmediğini söylüyorsun\n<i>*Hmmm belki de geçekten benim için faydalı biridir</i>",
		"Peki genç dostum, hayatına devam edebilmek için yeni bir işe ihtiyacın olduğunu varsayıyorum. Bu konuda endişelenme, sana bir iş vereceğim, evet evet vereceğim.",
		"Ama... ondan önce, fiziksel olarak iyi bir durumda olup olmadığını kontrol etmemiz gerekiyor.\nBenim için ağaçlıktan <VP><b>15 odun</b></VP> topla.\nŞu <VP><b>10 taş</b></VP>ı gelişmek için al. Bol şans!",
		"Cidden çok etkileyici. Ama <i>bizim zamanlarımızda</i> daha hızlı yapardık...\nŞu an olduğu gibi değil. Söz verdiğim gibi <VP><b>bu iş</b></VP> senindir.",
		"Derler ki, şimdi <b><VP>madene</VP></b> erişmen gerekiyor\n<b><VP>Kapıya</VP></b> ulaşmak için bu taraftan sol tarafa doğru git ve erişmek için <b><VP>↓</VP></b>'a bas!",
		"İlk işin olarak<b><VP> 15 demir cevheri</VP></b> toplamanı istiyorum. Tekrardan bol şans!",
		"Vay! Görünüşe göre seni hafife almışım, oldukça etkileyici bir iş!",
		"Duydum ki <b><VP>kale</VP></b>, hazineyi ve prensesi kötü kişilerden kurtarmak için senin gibi genç yoldaşlar arıyor...",
		"Buna çok uygun olabilirsin!",
		"Sana <b><VP>Nosferatu'nun tavsiye mektubunu</VP></b> vereceğim, bunu <b><VP>Lieutenant</VP></b>'a sunarsan seni orduya alacağını umuyorum.\n<i>Veeee bu işin biraz da iyi parası olacaktır</i>.",
		"Oh, yoğun çalışmanın sonucun ödülü olan <b><VP>30 taşı</VP></b> unutma!",
		"Herhangi bir şeye ihtiyacın var mı?",
		"Bu çok genel bir bilgi... <b><VP>Bir balta ile ağaç kesmen</VP></b> gerekiyor.",
		"Yani bir <b><VP>baltaya</VP></b> mı ihtiyacın var? <b><VP>Kütüklerin</VP></b> arasında dayalı bir tane olması gerek. Bir <b><VP>üretim merkezinde</VP></b>, <b><VP>↓</VP></b>'a basarak onun üzerine çalışabilir ve çalıştığın tarifi üretebilirsin.\nBu merkez madenin hemen sağ üstünde bulunuyor.",
		"<b><VP>35 çubuk</VP></b> karşılığında <b><VP>10 taş</VP></b> satıyorum.",
		"Ah peki öyleyse elveda",
		"Envanterin dolu gibi görünüyor. Boşalttıktan sonra ödülünü almak için geri gelmeye ne dersin?",
		"Seninle iş yapmak bir zevkti!",
		"Görünüşe göre bu takası yapmak için gerekli eşyalara sahip değilsin ufaklık."
	},
	NOSFERATU_QUESTIONS = {
		"Odunu nasıl elde edebilirim?",
		"Balta?",
		"Takas",
		"Boş ver.",
		"It's something else."
	},
	EDRIC_DIALOGUES = {
		"Prensesimiz... ve hazinemiz, kötü ellerin elinde. Acele etmeliyiz.",
		"Bekle. Yani <b><VP>Nosferatu</VP></b> seni buraya gönderdi ve görevlerde birliklerimize yardımcı mı olacaksın???",
		"Bu mükemmel. Ama bir orduda çalışmak sandığın kadar basit değil.\nVücudunun doğru durumda olmadığını varsayarsak <b><VP>yoğun bir</VP></b> eğitimden geçmen gerekiyor.\nEğitime başlamak için <b><VP>benim sol tarafımda bulunan eğitim alanına</VP></b> doğru git.",
		"Ama ondan önce, tamamen hazır olduğundan emin ol. <b><VPSilah sergisinde</VP></b> ve <b><VPtepenin aşağısındaki kasvetli ormanda</VP></b> dağınık halde bulunan birkaç tane <b><VP>tarif</VP></b> var.\nUmarım ki onları kullanmak için iyi bir amacın olacaktır!",
		"Hazır olduğunu düşündüğün zaman bana haber ver!",
		"Meydan okum için hazır mısın?",
		"Harika! Eğitimine başlamak için eğitim alanına git. Meydan okumayı geçmek için <b><VP>25 canavarı</VP></b> yenmen gerekiyor.",
		"Ne kadar zaman istersen o kadar alabilirsin\nSana bol şans!!!", 
		"Buna değer olduğunu kanıtladın! Acele et!!! Geri kalan askerlerimize katıl ve canavarlarla savaş!"
	},
	EDRIC_QUESTIONS = {
		"Daha fazla zamana ihtiyacım var...",
		"Hazırım!"
	},
	GARRY_DIALOGUES = {
		"Bu hayatımda gördüğüm en kötü yer. <b><VP>Nosferatu</VP></b> yeteri kadar ödeme yapmıyor bile. <i>*iç çeker...*</i>"
	},
	THOMPSON_DIALOGUES = {
		"Merhaba! Benden herhangi bir şey istiyor musun?",
		"Eğer bir <b><VP>kürek</VP></b> arıyorsan, <b><VP>madenin en sağ kısmında</VP></b> bir tane olması gerekiyor.\nBol şans!",
		"İyi günler!"
	},
	THOMPSON_QUESTIONS = {
		"Herhangi bir tarif?",
		"Sadece selam vermek istedim."
	},
	COLE_DIALOGUES = {
		"Bu taraflarda çok fazla <b><VP>canavar</VP></b> var. Lütfen dikkatli ol!",
		"Tüm ordumuz canavarlarla savaşıyor. Yardıma çok ihtiyacımız var.",
		"HEY HEY HEY! SENİN GİBİ ÇELİMSİZ BİRİNİN GİTMESİNE İZİN VEREMEM. BURAYA GERİ GEL!"
	},
	MARC_DIALOGUES = {
		"KÖTÜ ÇOCUK! İş tezgahıma DOKUNMA!"
	},
	SARUMAN_DIALOGUES = {
		"HEYYYYY!!!! HEYYYYYYYYY!!!!\nORADA BİRİ VAR MI???",
		"HEYY!! BANA YARDIM EDİN!\nTANRI BENİ BURADAN KURTARAN KİŞİDEN RAZI OLSUN!!!",
		"Bu arada ben <b><VP>Saruman</VP></b>. Bir süredir burada kapana kısıldım...\n15 yıl kadar?",
		"Hayatta olmamın sebebi, dostum <b><VP>Hootie</VP></b>.\nEğer o olmasaydı açlıktan ölmüştüm.",
		"Yani buraya nasıl ve neden sıkıştığımı öğrenmek istiyorsun?",
		"Peki uzun lafın kısası, <b>genç</b> ve senin kadar güçlü olduğum zamanlarda,\n<b><VP>Ruh küreleri</VP></b> denen bu hazineler hakkında bir şeyler duymuştum.",
		"Ben de bir profesördüm, bu yüzden bu konuda hakkındaki araştırmalara oldukça ilgiliyim.\nBirçok bilgi de edindim bu konuda.",
		"Bu küreler birinin ruhuna bağlı olur. <b><VP>5 küre</VP></b> birden bağlandıkları taktirde <b><VP>kutsal gücü</VP></b> vereceklerdir.",
		"Bu tür bir gücü aldığım taktirde bana ne yapacağı konusunda emin değilim...\nAma oldukça eminim ki <b><VP>keşişler</VP></b> bunun nasıl kullanıldığı hakkında daha çok bilgiye sahiptir!",
		"Ama hiç kimse tam olarak nerede olduklarını bilmiyor, ben de onları tek başıma bulmak için buraya geldim.",
		"Bence bir tane <VP><b>tapınak küresi</b></VP> bularak çok tatlı bir iş başardım.\nAncak... Seçtiğim yanlış yol o zamandan beri buraya sıkışmama sebep oldu.",
		"Bana yardım ettiğin için mutluyum! Bana bu küreler hakkında bir şeyler sormak istersen hiç çekinme.\nBilgi paylaşmak için vardır ve sen beni kurtardın!",
		"Evet dostum! Benden ne öğrenmek istersin?",
		"<b><VP>5 ruh küresi</VP></b> olduğunu söylemiştim\n<b><VP>3</VP></b> tanesi kasvetli ormanda bulunan <b><VP>tapınaklarda</VP></b> bulunuyor.\nGeriye kalan 2 tanesinin nerede olduğu konusunda emin değilim...",
		"Topladığım bilgiler sayesinde, tapınaklara girebilmek için çeşitli mücadelelerde bulunmak gerekeceğini söyleyebilirim.",
		"Buraya kadar ışınlanacak kadar sihirli güce sahipsen bir tanesini zaten nerede bulacağını bildiğini düşünüyorum.",
		"İkinci tapınak yolu üzerindeki birçok <b><VP>canavar</VP></b> korunuyor.\nBu yüzden keşfe çıkmadan önce iyice hazırlandığından emin ol!",
		"Son tapınak için, antik kitaplardan bu <b><VP>ipucunu</VP></b> bulmuştum.",
		"<b><VP>\"Bulmacalar, bilmeceler, ve eski gelenekler\nMatematiksel sayı, ama bir toplama değil\nVerimli şekile oyulmuş bir kaynak\nDoğru bilgi ifadesiyle birlikte gelir\nHerkese gösterilen sırayı edin\nAraman gereken dünya için\"</VP></b>",
		"Hepsi bu kadar! Umarım ki bu bilgileri kullanmak için iyi bir amaç bulursun.",
		"Beni kontrol ettiğin için sağ ol ahbap!",
		"GÖRÜŞÜNE GÖRE TÜM RUH KÜRELERİNİ TOPLAMIŞSIN!!!\nBitirdik bile... bana sonra teşekkür edersin!\n<b><VP>Bir keşişten</VP></b> bu küreler hakkıda daha fazla bilgi edindiğinden emin ol."
	},
	SARUMAN_QUESTIONS = {
		"Küreler nerede?",
		"Sadece kontrol ediyorum!"
	},
	MONK_DIALOGUES = {
		"Bu şeytani gücü bir süredir elimde tutuyordum...\nBana yardım etmek için geldiğin için çok memnun oldum",
		"Yani <b><VP>5 ruh küresinin</VP></b> hepsine sahip olduğunu söylüyorsun.",
		"Gerçekten çok iyi bir iş. Şimdi bu şeytani gücü sonsuza kadar yenmeyi kolaylaştırıcak.",
		"Aslında bu ruh küreleri birinin ruhuna bağlı olur\nSadece cesur bireyler tüm 5'ine birden hakim olabilir",
		"Bu küreler şeytani gücü yok etmen için tek yol olan <b><VP>kutsal güce</VP></b> ulaşmana yardımcı olacak \nYani benim bildiğin kadarıyla öyle",
		"Kutsak gücü bir kez aktive ettiğinde ve şeytani güce karşı koyduğunda...\n<b><VP>Kutsal duruma</VP></b> erişmek için zihninin içinde uzun bir yolculuğa çıkman gerekecek.",
		"Ruh küreleri doğru yolu bulmayı başarman için yardımcı olacak.\nSadece sana doğru zamanda söylediği yolu kullanarak yolculuk etmelisin!",
		"I'm pretty sure you won't succeed it to the most powerful divine energy.\nBut even if you get closer...",
		"Bu <b><VP>tanrıçayı</VP></b> ortaya çıkaracak büyük miktarda kutsal enerjiyi yaratacak.",
		"Antik kitaplar yaratığın çok güçlü olduğunu söylüyor ama ben olduça eminim ki \n<b><VP>tanrıçanın kutsaması</VP></b> onu daha zayıf bir hale sokacak.",
		"Bu bizim zamanımız öyleyse, şeytani gücü sonsuza kadar yenmek için!!!",
		"Tanrıça... O burada\nİŞTE GERÇEKLEŞİYOR!!!"
	},
	NIELS_DIALOGUES = {
		"Herkes yerlerine geçsin!",
		"The <b><VP>dragon</VP></b> on the other side of the river is too dangerous.\nHe will use his <b><VP>fire attacks</VP></b> and will <b><VP>throw rocks</VP></b> on you",
		"Lütfen dikkatli ol...",
		"Ancak direkt olarak ejderhaya saldıramıyoruz, köprü kırılmış olarak ortaya çıkabilir.",
		"Ona çarpmaya çalışırken, ejderha onu ateşiyle yok etmiş olacak.",
		"Bu yüzden... Ona ulaşana kadar biz de onu tamir etmek zorunda olacağız. Acele edin!!!"
	},
	PROPS = {
		attack = "Saldırı",
		defense = "Savunma",
		durability = "Dayanıklılık",
		chopping = "Kesme",
		mining = "Kazma"
	}
}

translations["cn"] = {
	OUT_OF_RESOURCES = "<font color='#ab5e42'>[</font> <font color='#c6b392'>•</font> <font color='#ab5e42'>]</font> <font color='#c6b392' face='Lucida Console'>没有资源了!</font>",
	NEW_RECIPE = "<font color='#506d3d' size='8'><b>[新制作方法]</b></font> <font color='#ab5e42' face='Lucida Console'><b>${itemName}</b></font>\n<font color='#bd9d60' size='11' face='Lucida Console'>(${itemDesc})</font>",
	NEW_QUEST = "<font color='#506d3d' size='8'><b>[新任务]</b></font> <font color='#ab5e42' face='Lucida Console'><b>${questName}</b></font>",
	NEW_STAGE = "<font color='#506d3d' size='8'><b>[更新]</b></font> <font color='#ab5e42' face='Lucida Console'><b>${questName}</b></font>\n<font color='#bd9d60' size='11' face='Lucida Console'>(${desc})</font>",
	STAGE_PROGRESS = "<font color='#506d3d' size='8'><b>[更新]</b></font> <font color='#ab5e42' face='Lucida Console'><b>${questName}</b></font> <font color='#bd9d60' size='11' face='Lucida Console'>( ${progress} / ${needed} )</font>",
	QUEST_OVER = "<font color='#506d3d' size='8'><b>[已完成]</b></font> <font color='#ab5e42' face='Lucida Console'><b>${questName}</b></font>",
	SPIRIT_ORB = "<b><font color='#ab5e42' face='Lucida Console'>你得到一个 <font color='#bd9d60' face='Lucida Console'>灵体球!</font></font></b>",
	PASSCODE = "请输入通行码。",
	WRONG_GUESS = "<R>通行码错误。</R>",
	INVENTORY_INFO = "<font face='Lucida Console'><p align='center'><font color='#${color}' size='9'>Weight: ${weight}</font>\n\n\n\n<font size='9'><N2><b>[X] 键丢弃</b></N2></font></p></font>",
	FULL_INVENTORY = "<font color='#ab5e42'>[</font> <font color='#c6b392'>•</font> <font color='#ab5e42'>]</font> <font color='#c6b392' face='Lucida Console'>你的物品栏已满!</font>",
	PORTAL_ENTER_FAIL = "<font color='#ab5e42'>[</font> <font color='#c6b392'>•</font> <font color='#ab5e42'>]</font> <font color='#c6b392' face='Lucida Console'>现在不能使用传送门。</font>",
	CRAFT = "制作!",
	CANT_CRAFT = "不能制作",
	QUESTS = "<font size='15' face='Lucida console'><b><BV>任务</BV></b></font>\n\n",
	RECIPE_DESC = "\n\n<font face='Lucida console' size='12' color='#999999'><i>“ ${desc} ”</i></font>",
	FINAL_BATTLE_PING = "<font color='#ab5e42'>[</font> <font color='#c6b392'>•</font> <font color='#ab5e42'>]</font> <font color='#c6b392' face='Lucida Console'>Final battle is happening!</font>",
	ACTIVATE_POWER = "<font color='#ab5e42'>[</font> <font color='#c6b392'>•</font> <font color='#ab5e42'>]</font> <font color='#c6b392' face='Lucida Console'>按 <font color='#ab5e42'><b>U 键</b></font> 使用 <font color='#ab5e42'><b>神圣力量!</b></font></font>",
	ENDING_MESSAGE = "<font color='#cccccc'><font color='#bd9d60'><b>恭喜</b></font> 完成了活动!<br><br>感谢 <font color='#bd9d60'>King_seniru</font><font size='8' color='#ab5e42'>#5890</font>, <font color='#bd9d60'>Hattington</font><font size='8' color='#ab5e42'>#2583</font>, <font color='#bd9d60'>Vividia</font><font size='8' color='#ab5e42'>#0095</font>, <font color='#bd9d60'>Chibi</font><font size='8' color='#ab5e42'>#0095</font>, <font color='#bd9d60'>Karasu</font><font size='8' color='#ab5e42'>#0010</font>, <font color='#bd9d60'>Zetdey</font><font size='8' color='#ab5e42'>#3845</font>, <font color='#bd9d60'>Eremia</font><font size='8' color='#ab5e42'>#0020</font>, <font color='#bd9d60'>活动团队</font> 以及 <font color='#bd9d60'>你</font> 使活动成真!\n\n</font><i><font color='#548336'>别停下来... 前面有更多东西等着被发掘! 祝你发掘开心!!!</font></i>",
	PLAYER_DATA_FAIL_SAFEBACK = "<font color='#ab5e42'>[</font> <font color='#c6b392'>•</font> <font color='#ab5e42'>]</font> <font color='#c6b392' face='Lucida Console'>看来的的进度没有好好加载。所以我们取消了替你储存本次资料。如果问题持续, 试试换房间或重登然后联络 King_seniru#5890</font>",
	ANNOUNCER_DIALOGUES = {
		"各位注意! 注意!!!",
		"这则讯息是从管治我们这片土地尊贵的, 辉煌无比的国王颁布下来...",
		"我们这片土地正受到攻击, 是那些曾被我们打败的无情的怪物。",
		"接着也有不幸的事要宣布。<b><VP>我们的公主被绑架了。</VP></b>",
		"这些无情的怪物也几乎把我们的所有宝物财富都抢走。",
		"国王现在正找寻勇敢的士兵T来协助军队打败这些怪物, 然后救回公主\n以及宝物",
		"国王希望怀着义勇之心的鼠存在并到来...\n"
	},
	NOSFERATU_DIALOGUES = {
		"啊你看来是新来的... 算了你好像也很可靠",
		"所以你是说, 你从别的时空过来, 然后也不知道你在哪或是不知道要干嘛\n<i>*呃也许他对我很有用</i>",
		"好的年轻人, 我猜你需要一份工作来过活。是是别担心, 我会给你一份工作的。",
		"但... 在那之前, 我们需要你有没有好的身体状态。\n在森林中为我收集 <VP><b>15 个木头</b></VP>。\n先拿着这 <VP><b>20 个石头</b></VP> 吧。祝你好运!",
		"挺不错的嘛。但是 <i>在以前的时候</i> 我们做的更快...\n不像现在了。就如我所答应的, 你得到 <VP><b>工作</b></VP> 了。",
		"这代表, 你现在可以进去 <b><VP>矿洞</VP></b> 了\n前往这里右边的那扇 <b><VP>门</VP></b> 然后按 <b><VP>↓</VP></b> 来通过它!",
		"作为第一份工作, 我需要你收集 <b><VP> 15 个铁矿石</VP></b>。再次祝你好运!",
		"哇! 看来你我低估了你, 真是出色的工作!",
		"我听说 <b><VP>城堡</VP></b> 需要一些像你的年轻人来在坏蛋手上保护国库及公主...",
		"你可以好好胜任的!",
		"我会给你 <b><VP>Nosferatu 的推荐信</VP></b>, 把这个交给 <b><VP>Lieutenant</VP></b> 然后希望他会把你招揽到军中。\n<i>而且那也可以得到好一些金钱</i>",
		"噢也别忘了你的奖励 <b><VP>30 个石头</VP></b> 是你的辛劳成果!",
		"你需要什么吗?",
		"那是挺普通的知识... 你需要 <b><VP>使用斧头来砍树</VP></b>",
		"所以你需要一个 <b><VP>斧头</VP></b>? 那里 <b><VP>森林中</VP></b> 应该有一个。\n按<b><VP>↓</VP></b> 来研究制作方法然后在 <b><VP>工作桌</VP></b> 制造出来。\n工作桌就在这洞穴上方。",
		"我售卖 <b><VP>10 个石头</VP></b> 价格是 <b><VP>35 根树枝</VP></b>",
		"呃好吧再见",
		"你的物品栏好像满了。你要不先把它清空再来领取你的奖励。",
            "跟你一起工作是荣幸!",
		"看来你没有足够的物品来交易啊小孩。"
	},
	NOSFERATU_QUESTIONS = {
		"我要如何得到木头?",
		"斧头?",
		"交易",
		"算了。",
		"It's something else."
	},
	EDRIC_DIALOGUES = {
		"我们的公主... 以及国库, 都在恶魔手上。我们要快一点了",
		"暂着。所以你说 <b><VP>Nosferatu</VP></b> 把你带来这里然后你可以帮助我们的士兵完成任务???",
		"那太好了。但是替军方打工不是你想像的那么简单。\n你需要进行一些 <b><VP>密集式训练</VP></b> 想像你的身体不再像正常的形状那样。\n前往 <b><VP>我左边的训练场</VP></b> 来开始你的训练吧。",
		"但是在那之前, 先确定你预备好了。那里有几个 <b><VP>物品制作方法</VP></b> 在 <b><VP>武器架上</VP></b> 散落着而 <b><VP>阴沉森林在山下</VP></b>\n希望你可以好好运用它们!",
		"当你觉得准备好了就再次来跟我说话!",
		"你准备好接受挑战了吗?",
		"好极了! 去训练区开始你的训练吧。你需要 <b><VP>打败 25 只怪物</VP></b> 来通过挑战。",
		"你想用上多少时间都可以\n祝你好运!!!",
		"你证明了你是值得的! 好耶!!! 加入其他士兵来打败怪物吧!"
	},
	EDRIC_QUESTIONS = {
		"我需要更多时间...",
		"我预备好了!"
	},
	GARRY_DIALOGUES = {
		"这是我去过最坏的地方。 <b><VP>Nosferatu</VP></b> 没有支付足够。 <i>*哭...*</i>"
	},
	THOMPSON_DIALOGUES = {
		"嗨喽! 你想要得到什么吗?",
		"如果你在找寻 <b><VP>铲子</VP></b>, <b><VP>矿洞中最右侧</VP></b> 应该有一个。\n祝你好运!",
		"祝你有好的一天!"
	},
	THOMPSON_QUESTIONS = {
		"任何制作方法?",
		"只是打个招呼。"
	},
	COLE_DIALOGUES = {
		"外面有很多 <b><VP>怪物</VP></b>。请小心!",
		"我们所有的军队都在对抗怪物。我们需要更多帮助。",
		"喂喂喂! 我不可以让像你一样弱小的人走到那边。回到上面吧!"
	},
	MARC_DIALOGUES = {
		"坏欸你! 不要碰我的工作桌!"
	},
	SARUMAN_DIALOGUES = {
		"欸!!!! 欸!!!!\n有人吗???",
		"喂!! 帮忙把我弄出来!\n太感谢上天让我出来了!!!",
		"喔对了我是 <b><VP>Saruman</VP></b>。我在这里被困了好像...\n15 年?",
		"我的朋友 <b><VP>Hootie</VP></b> 是使我活着的原因。\n要不是他我早就死于饥饿了",
            "所以你想知道为什么我被困在这?",
		"长话短说, 在我还 <b>年轻</b> 而且好像你这么强壮的时候,\n我听说有宝物叫 <b><VP>灵体球</VP></b>",
		"我以前是一个教授所以我对这方面很有兴趣。\n我收集了不少关于它们的资讯",
		"这些球是连接着某人的灵魂。一旦它们跟所有 <b><VP>5 个球</VP></b> 连接就会得到 <b><VP>神圣力量</VP></b>",
		"我不太确定会从中得到什么样的力量或是它们会怎么对我...\n但是我挺确定 <b><VP>僧侣们</VP></b> 会知道怎么使用它们!",
		"但是没人知道他们到底在哪里所以我才一直自己找到来这里。",
		"我觉得我已经做得不错找到了一个 <VP><b>神社球</b></VP>。\n但是... 我走错路然后就一直被困在此。",
		"我很高兴你帮我脱困! 可以随便问我关于这些球的资讯。\n知识是用来分享的, 更何况你救了我!",
		"好的朋友! 你想知道什么?",
            "就像我说的那里一共有 <b><VP>5 个灵体球</VP></b>\n<b><VP>3</VP></b> 个可以在阴沉森林中的 <b><VP>神社</VP></b> 里找到。\n而我不怎么清楚剩下的 2 个...",
		"从我收集到的资讯, 你需要面对几个挑战才可以进到神社。",
		"我觉得你已经找到一个不然你怎么有神奇的力量可以来到这里",
		"通住第二个神社的路上有很多 <b><VP>怪物</VP></b> 防护着。\n所以要装备好才探索那里!",
		"而关于最后一个神社我从书本中发现了这个 <b><VP>提示</VP></b>",
		"<b><VP>\"拼图, 以及谜语, 还有古老的传统\n数学符号, 但不是加号",
		"那就是全部了! 希望你可以好好运用这些资讯",
		"谢谢你来找我问问看!",
		"噢看来你已经收集完了全部的灵体球!!!\n我们现在各没拖欠了... 稍后再谢我!\n但是你一定要找 <b><VP>僧侣</VP></b> 问个清楚",
		"<b><VP>\"丰硕富足的资源\n始自与传说结缘\"</VP></b>",
		"<b><VP>\"接下职责来向人展示\n呈现出你的凶凶气势\"</VP></b>"
	},
	SARUMAN_QUESTIONS = {
		"球在哪里?",
		"正在找寻!"
	},
	MONK_DIALOGUES = {
		"我已经压制着这般邪恶力量很久了...\n很高兴你来帮我们",
		"所以你说已经集好全部 <b><VP>5 个灵体球</VP></b>",
		"确实做的不错。现在可以更容易地永远打倒邪恶力量",
		"这些灵体球其实是连接着某人的灵魂\n只有具有勇气的人才可以使用全部 5 个",
		"这些灵体球可以帮你使用 <b><VP>神圣力量</VP></b> 而这也是唯一的方法来打败邪魔\n据我所知道",
		"当你启用了神圣力量来对抗邪魔...\n你就会需要在思维中经历长长旅途以达至 <b><VP>神圣状态</VP></b>",
		"灵体球会协助你找到正确的路以达至那状态。\n你只需要在正确时机跟着它带领的路走!",
		"我挺肯定你不会达到最强大的神圣力量境界。\n但即使是更接近一点点...",
		"它会创造出巨大的神圣力量而召唤出 <b><VP>神</VP></b>",
		"古书籍说猛兽太强大了但我认为\n<b><VP>神的祝福</VP></b> 会削弱它",
		"那就是我们的时机, 永远地打败邪恶力量!!!",
		"神... 衪就在这里\n正在发生了!!!"
	},
	NIELS_DIALOGUES = {
		"所有人各就各位!",
		"在河的对岸那尾 <b><VP>龙</VP></b> 太危险了。\n它会用它的 <b><VP>火炎攻击</VP></b> 而且会向你 <b><VP>丢石头</VP></b>",
		"请小心...",
		"但是我们不能直接攻击那尾龙, 因为桥看起来要断裂了",
		"那尾龙曾经在尝试过桥时用火炎破坏它。",
		"所以... 我们需要先维修它以靠近龙。快点!!!"
	},
	PROPS = {
		attack = "攻击",
		defense = "防御",
		durability = "耐用性",
		chopping = "斩击",
		mining = "挖矿"
	}
}
translations["zh"] = {
	OUT_OF_RESOURCES = "<font color='#ab5e42'>[</font> <font color='#c6b392'>•</font> <font color='#ab5e42'>]</font> <font color='#c6b392' face='Lucida Console'>沒有資源了!</font>",
	NEW_RECIPE = "<font color='#506d3d' size='8'><b>[新製作方法]</b></font> <font color='#ab5e42' face='Lucida Console'><b>${itemName}</b></font>\n<font color='#bd9d60' size='11' face='Lucida Console'>(${itemDesc})</font>",
	NEW_QUEST = "<font color='#506d3d' size='8'><b>[新任務]</b></font> <font color='#ab5e42' face='Lucida Console'><b>${questName}</b></font>",
	NEW_STAGE = "<font color='#506d3d' size='8'><b>[更新]</b></font> <font color='#ab5e42' face='Lucida Console'><b>${questName}</b></font>\n<font color='#bd9d60' size='11' face='Lucida Console'>(${desc})</font>",
	STAGE_PROGRESS = "<font color='#506d3d' size='8'><b>[更新]</b></font> <font color='#ab5e42' face='Lucida Console'><b>${questName}</b></font> <font color='#bd9d60' size='11' face='Lucida Console'>( ${progress} / ${needed} )</font>",
	QUEST_OVER = "<font color='#506d3d' size='8'><b>[已完成]</b></font> <font color='#ab5e42' face='Lucida Console'><b>${questName}</b></font>",
	SPIRIT_ORB = "<b><font color='#ab5e42' face='Lucida Console'>你得到一個 <font color='#bd9d60' face='Lucida Console'>靈體球!</font></font></b>",
	PASSCODE = "請輸入通行碼。",
	WRONG_GUESS = "<R>通行碼錯誤。</R>",
	INVENTORY_INFO = "<font face='Lucida Console'><p align='center'><font color='#${color}' size='9'>Weight: ${weight}</font>\n\n\n\n<font size='9'><N2><b>[X] 鍵丟棄</b></N2></font></p></font>",
	FULL_INVENTORY = "<font color='#ab5e42'>[</font> <font color='#c6b392'>•</font> <font color='#ab5e42'>]</font> <font color='#c6b392' face='Lucida Console'>你的物品欄已滿!</font>",
	PORTAL_ENTER_FAIL = "<font color='#ab5e42'>[</font> <font color='#c6b392'>•</font> <font color='#ab5e42'>]</font> <font color='#c6b392' face='Lucida Console'>現在不能使用傳送門。</font>",
	CRAFT = "製作!",
	CANT_CRAFT = "不能製作",
	QUESTS = "<font size='15' face='Lucida console'><b><BV>任務</BV></b></font>\n\n",
	RECIPE_DESC = "\n\n<font face='Lucida console' size='12' color='#999999'><i>“ ${desc} ”</i></font>",
	FINAL_BATTLE_PING = "<font color='#ab5e42'>[</font> <font color='#c6b392'>•</font> <font color='#ab5e42'>]</font> <font color='#c6b392' face='Lucida Console'>Final battle is happening!</font>",
	ACTIVATE_POWER = "<font color='#ab5e42'>[</font> <font color='#c6b392'>•</font> <font color='#ab5e42'>]</font> <font color='#c6b392' face='Lucida Console'>按 <font color='#ab5e42'><b>U 鍵</b></font> 使用 <font color='#ab5e42'><b>神聖力量!</b></font></font>",
	ENDING_MESSAGE = "<font color='#cccccc'><font color='#bd9d60'><b>恭喜</b></font> 完成了活動!<br><br>感謝 <font color='#bd9d60'>King_seniru</font><font size='8' color='#ab5e42'>#5890</font>, <font color='#bd9d60'>Hattington</font><font size='8' color='#ab5e42'>#2583</font>, <font color='#bd9d60'>Vividia</font><font size='8' color='#ab5e42'>#0095</font>, <font color='#bd9d60'>Chibi</font><font size='8' color='#ab5e42'>#0095</font>, <font color='#bd9d60'>Karasu</font><font size='8' color='#ab5e42'>#0010</font>, <font color='#bd9d60'>Zetdey</font><font size='8' color='#ab5e42'>#3845</font>, <font color='#bd9d60'>Eremia</font><font size='8' color='#ab5e42'>#0020</font>, <font color='#bd9d60'>活動團隊</font> 以及 <font color='#bd9d60'>你</font> 使活動成真!\n\n</font><i><font color='#548336'>別停下來... 前面有更多東西等著被發掘! 祝你發掘開心!!!</font></i>",
	PLAYER_DATA_FAIL_SAFEBACK = "<font color='#ab5e42'>[</font> <font color='#c6b392'>•</font> <font color='#ab5e42'>]</font> <font color='#c6b392' face='Lucida Console'>看來的的進度沒有好好加載。所以我們取消了替你儲存本次資料。如果問題持續, 試試換房間或重登然後聯絡 King_seniru#5890</font>",
	ANNOUNCER_DIALOGUES = {
		"各位注意! 注意!!!",
		"這則訊息是從管治我們這片土地尊貴的, 輝煌無比的國王頒布下來...",
		"我們這片土地正受到攻擊, 是那些曾被我們打敗的無情的怪物。",
		"接著也有不幸的事要宣佈。<b><VP>我們的公主被綁架了。</VP></b>",
		"這些無情的怪物也幾乎把我們的所有寶物財富都搶走。",
		"國王現在正找尋勇敢的士兵T來協助軍隊打敗這些怪物, 然後救回公主\n以及寶物",
		"國王希望懷著義勇之心的鼠存在並到來...\n"
	},
	NOSFERATU_DIALOGUES = {
		"啊你看來是新來的... 算了你好像也很可靠",
		"所以你是說, 你從別的時空過來, 然後也不知道你在哪或是不知道要幹嘛\n<i>*呃也許他對我很有用</i>",
		"好的年輕人, 我猜你需要一份工作來過活。是是別擔心, 我會給你一份工作的。",
		"但... 在那之前, 我們需要你有沒有好的身體狀態。\n在森林中為我收集 <VP><b>15 個木頭</b></VP>。\n先拿著這 <VP><b>20 個石頭</b></VP> 吧。祝你好運!",
		"挺不錯的嘛。但是 <i>在以前的時候</i> 我們做的更快...\n不像現在了。就如我所答應的, 你得到 <VP><b>工作</b></VP> 了。",
		"這代表, 你現在可以進去 <b><VP>礦洞</VP></b> 了\n前往這裡右邊的那扇 <b><VP>門</VP></b> 然後按 <b><VP>↓</VP></b> 來通過它!",
		"作為第一份工作, 我需要你收集 <b><VP> 15 個鐵礦石</VP></b>。再次祝你好運!",
		"哇! 看來你我低估了你, 真是出色的工作!",
		"我聽說 <b><VP>城堡</VP></b> 需要一些像你的年輕人來在壞蛋手上保護國庫及公主...",
		"你可以好好勝任的!",
		"我會給你 <b><VP>Nosferatu 的推薦信</VP></b>, 把這個交給 <b><VP>Lieutenant</VP></b> 然後希望他會把你招攬到軍中。\n<i>而且那也可以得到好一些金錢</i>",
		"噢也別忘了你的獎勵 <b><VP>30 個石頭</VP></b> 是你的辛勞成果!",
		"你需要什麼嗎?",
		"那是挺普通的知識... 你需要 <b><VP>使用斧頭來砍樹</VP></b>",
		"所以你需要一個 <b><VP>斧頭</VP></b>? 那裡 <b><VP>森林中</VP></b> 應該有一個。\n按<b><VP>↓</VP></b> 來研究製作方法然後在 <b><VP>工作桌</VP></b> 製造出來。\n工作桌就在這洞穴上方。",
		"我售賣 <b><VP>10 個石頭</VP></b> 價格是 <b><VP>35 根樹枝</VP></b>",
		"呃好吧再見",
		"你的物品欄好像滿了。你要不先把它清空再來領你的獎勵。",
		"跟你一起工作是榮幸!",
		"看來你沒有足夠的物品來交易啊小孩。"
	},
	NOSFERATU_QUESTIONS = {
		"我要如何得到木頭?",
		"斧頭?",
		"交易",
		"算了。",
		"It's something else."
	},
	EDRIC_DIALOGUES = {
		"我們的公主... 以及國庫, 都在惡魔手上。我們要快一點了",
		"暫著。所以你說 <b><VP>Nosferatu</VP></b> 把你帶來這裡然後你可以幫助我們的士兵完成任務???",
		"那太好了。但是替軍方打工不是你想像的那麼簡單。\n你需要進行一些 <b><VP>密集式訓練</VP></b> 想像你的身體不再像正常的形狀那樣。\n前往 <b><VP>我左邊的訓練場</VP></b> 來開始你的訓練吧。",
		"但是在那之前, 先確定你預備好了。那裡有幾個 <b><VP>物品製作方法</VP></b> 在 <b><VP>武器架上</VP></b> 散落著而 <b><VP>陰沉森林在山下</VP></b>\n希望你可以好好運用它們!",
		"當你覺得準備好了就再次來跟我說話!",
		"你準備好接受挑戰了嗎?",
		"好極了! 去訓練區開始你的訓練吧。你需要 <b><VP>打敗 25 隻怪物</VP></b> 來通過挑戰。",
		"你想用上多少時間都可以\n祝你好運!!!",
		"你證明了你是值得的! 好耶!!! 加入其他士兵來打敗怪物吧!"
	},
	EDRIC_QUESTIONS = {
		"我需要更多時間...",
		"我預備好了!"
	},
	GARRY_DIALOGUES = {
		"這是我去過最壞的地方。 <b><VP>Nosferatu</VP></b> 沒有支付足夠。 <i>*哭...*</i>"
	},
	THOMPSON_DIALOGUES = {
		"嗨嘍! 你想要得到什麼嗎?",
		"如果你在找尋 <b><VP>鏟子</VP></b>, <b><VP>礦洞中最右側</VP></b> 應該有一個。\n祝你好運!",
		"祝你有好的一天!"
	},
	THOMPSON_QUESTIONS = {
		"任何製作方法?",
		"只是打個招呼。"
	},
	COLE_DIALOGUES = {
		"外面有很多 <b><VP>怪物</VP></b>。請小心!",
		"我們所有的軍隊都在對抗怪物。我們需要更多幫助。",
		"喂喂喂! 我不可以讓像你一樣弱小的人走到那邊。回到上面吧!"
	},
	MARC_DIALOGUES = {
		"壞欸你! 不要碰我的工作桌!"
	},
	SARUMAN_DIALOGUES = {
		"欸!!!! 欸!!!!\n有人嗎???",
		"喂!! 幫忙把我弄出來!\n太感謝上天讓我出來了!!!",
		"喔對了我是 <b><VP>Saruman</VP></b>。我在這裡被困了好像...\n15 年?",
		"我的朋友 <b><VP>Hootie</VP></b> 是使我活著的原因。\n要不是他我早就死於饑餓了",
            "所以你想知道為什麼我被困在這?",
		"長話短說, 在我還 <b>年輕</b> 而且好像你這麼強壯的時候,\n我聽說有寶物叫 <b><VP>靈體球</VP></b>",
		"我以前是一個教授所以我對這方面很有興趣。\n我收集了不少關於它們的資訊",
		"這些球是連接著某人的靈魂。一旦它們跟所有 <b><VP>5 個球</VP></b> 連接就會得到 <b><VP>神聖力量</VP></b>",
		"我不太確定會從中得到什麼樣的力量或是它們會怎麼對我...\n但是我挺確定 <b><VP>僧侶們</VP></b> 會知道怎麼使用它們!",
		"但是沒人知道他們到底在哪裡所以我才一直自己找到來這裡。",
		"我覺得我已經做得不錯找到了一個 <VP><b>神社球</b></VP>。\n但是... 我走錯路然後就一直被困在此。",
		"我很高興你幫我脫困! 可以隨便問我關於這些球的資訊。\n知識是用來分享的, 更何況你救了我!",
		"好的朋友! 你想知道什麼?",
		"就像我說的那裡一共有 <b><VP>5 個靈體球</VP></b>\n<b><VP>3</VP></b> 個可以在陰沉森林中的 <b><VP>神社</VP></b> 裡找到。\n而我不怎麼清楚剩下的 2 個...",
		"從我收集到的資訊, 你需要面對幾個挑戰才可以進到神社。",
		"我覺得你已經找到一個不然你怎麼有神奇的力量可以來到這裡",
		"通住第二個神社的路上有很多 <b><VP>怪物</VP></b> 防護著。\n所以要裝備好才探索那裡!",
		"而關於最後一個神社我從書本中發現了這個 <b><VP>提示</VP></b>",
		"<b><VP>\"拼圖, 以及謎語, 還有古老的傳統\n數學符號, 但不是加號",
		"那就是全部了! 希望你可以好好運用這些資訊",
		"謝謝你來找我問問看!",
		"噢看來你已經收集完了全部的靈體球!!!\n我們現在各沒拖欠了... 稍後再謝我!\n但是你一定要找 <b><VP>僧侶</VP></b> 問個清楚",
		"<b><VP>\"豐碩富足的資源\n始自與傳說結緣\"</VP></b>",
		"<b><VP>\"接下職責來向人展示\n呈現出你的兇兇氣勢\"</VP></b>"
	},
	SARUMAN_QUESTIONS = {
		"球在哪裡?",
		"正在找尋!"
	},
	MONK_DIALOGUES = {
		"我已經壓制著這般邪惡力量很久了...\n很高興你來幫我們",
		"所以你說已經集好全部 <b><VP>5 個靈體球</VP></b>",
		"確實做的不錯。現在可以更容易地永遠打倒邪惡力量",
		"這些靈體球其實是連接著某人的靈魂\n只有具有勇氣的人才可以使用全部 5 個",
		"這些靈體球可以幫你使用 <b><VP>神聖力量</VP></b> 而這也是唯一的方法來打敗邪魔\n據我所知道",
		"當你啟用了神聖力量來對抗邪魔...\n你就會需要在思維中經歷長長旅途以達至 <b><VP>神聖狀態</VP></b>",
		"靈體球會協助你找到正確的路以達至那狀態。\n你只需要在正確時機跟著它帶領的路走!",
		"我挺肯定你不會達到最強大的神聖力量境界。\n但即使是更接近一點點...",
		"它會創造出巨大的神聖力量而召喚出 <b><VP>神</VP></b>",
		"古書籍說猛獸太強大了但我認為\n<b><VP>神的祝福</VP></b> 會削弱它",
		"那就是我們的時機, 永遠地打敗邪惡力量!!!",
		"神... 衪就在這裡\n正在發生了!!!"
	},
	NIELS_DIALOGUES = {
		"所有人各就各位!",
		"在河的對岸那尾 <b><VP>龍</VP></b> 太危險了。\n它會用它的 <b><VP>火炎攻擊</VP></b> 而且會向你 <b><VP>丟石頭</VP></b>",
		"請小心...",
		"但是我們不能直接攻擊那尾龍, 因為橋看起來要斷裂了",
		"那尾龍曾經在嘗試過橋時用火炎破壞它。",
		"所以... 我們需要先維修它以靠近龍。快點!!!"
	},
	PROPS = {
		attack = "攻擊",
		defense = "防禦",
		durability = "耐用性",
		chopping = "斬擊",
		mining = "挖礦"
	}
}
-- theme color pallete: https://www.colourpod.com/post/173929539115/a-medieval-recipe-for-murder-submitted-by

translations["fr"] = {
	OUT_OF_RESOURCES = "<font color='#ab5e42'>[</font> <font color='#c6b392'>•</font> <font color='#ab5e42'>]</font> <font color='#c6b392' face='Lucida Console'>Plus de ressources !</font>",
	NEW_RECIPE = "<font color='#506d3d' size='8'><b>[NOUVELLE RECETTE]</b></font> <font color='#ab5e42' face='Lucida Console'><b>${itemName}</b></font>\n<font color='#bd9d60' size='11' face='Lucida Console'>(${itemDesc})</font>",
	NEW_QUEST = "<font color='#506d3d' size='8'><b>[NOUVELLE QUÊTE]</b></font> <font color='#ab5e42' face='Lucida Console'><b>${questName}</b></font>",
	NEW_STAGE = "<font color='#506d3d' size='8'><b>[MISE À JOUR]</b></font> <font color='#ab5e42' face='Lucida Console'><b>${questName}</b></font>\n<font color='#bd9d60' size='11' face='Lucida Console'>(${desc})</font>",
	STAGE_PROGRESS = "<font color='#506d3d' size='8'><b>[MISE À JOUR]</b></font> <font color='#ab5e42' face='Lucida Console'><b>${questName}</b></font> <font color='#bd9d60' size='11' face='Lucida Console'>( ${progress} / ${needed} )</font>",
	QUEST_OVER = "<font color='#506d3d' size='8'><b>[COMPLÉTÉ]</b></font> <font color='#ab5e42' face='Lucida Console'><b>${questName}</b></font>",
	SPIRIT_ORB = "<b><font color='#ab5e42' face='Lucida Console'>Vous avez reçu une <font color='#bd9d60' face='Lucida Console'>orbe d'esprit !</font></font></b>",
	PASSCODE = "Utilisez la clé d'accès.",
	WRONG_GUESS = "<R>Clé d'accès incorrecte.</R>",
	INVENTORY_INFO = "<font face='Lucida Console'><p align='center'><font color='#${color}' size='9'>Poids : ${weight}</font>\n\n\n\n<font size='9'><N2><b>[X] Lancer</b></N2></font></p></font>",
	FULL_INVENTORY = "<font color='#ab5e42'>[</font> <font color='#c6b392'>•</font> <font color='#ab5e42'>]</font> <font color='#c6b392' face='Lucida Console'>Votre inventaire est plein !</font>",
	FINAL_BOSS_ENTER_FAIL = "<font color='#ab5e42'>[</font> <font color='#c6b392'>•</font> <font color='#ab5e42'>]</font> <font color='#c6b392' face='Lucida Console'>Vous devez obtenir l'orbe d'esprit du Dragon pour entrer dans ce portail !</font>",
	CRAFT = "Créer !",
	CANT_CRAFT = "Impossible de créer",
	RECIPE_DESC = "\n\n<font face='Lucida console' size='12' color='#999999'><i>“ ${desc} ”</i></font>",
	FINAL_BATTLE_PING = "<font color='#ab5e42'>[</font> <font color='#c6b392'>•</font> <font color='#ab5e42'>]</font> <font color='#c6b392' face='Lucida Console'>La bataille finale arrive !</font>",
	ACTIVATE_POWER = "<font color='#ab5e42'>[</font> <font color='#c6b392'>•</font> <font color='#ab5e42'>]</font> <font color='#c6b392' face='Lucida Console'>Appuyez sur <font color='#ab5e42'><b>U</b></font> pour utiliser vos <font color='#ab5e42'><b>pouvoirs divins !</b></font></font>",
	ANNOUNCER_DIALOGUES = {
		"OYEZ OYEZ TOUT LE MONDE ! VOTRE ATTENTION !!!",
		"Voici un message de votre masjesté, le glorieux Roi de cette contrée...",
		"Notre terre est attaquée par les viles monstres qui ont été anéantis il y a fort longtemps.",
		"Un malheureux événement s'est produit en conséquences. <b><VP>Notre princesse a été kidnappée.</VP></b>",
		"Ces impitoyables monstres ont aussi réussi à s'échapper avec presque tout les trésors que nous avions.",
		"Le Roi est à la recherche de BRAVES SOLDATS qui aideront notre armée à battre tous ces monstres, et à sauver la princesse\nainsi que notre trésor.",
		"Le Roi requiert la présence de tous les coeurs braves...\n"
	},
	NOSFERATU_DIALOGUES = {
		"Ah vous êtes nouveau ici... bref vous allez m'être utile",
		"Donc ce que vous dites, c'est que vous venez d'une autre dimension, et vous n'avez aucune idée de où vous vous trouvez\n<i>*Hummm peut-être qu'il peut vraiment m'être utile</i>",
		"Bon petit gars, je suppose que tu as besoin d'une mission dans la vie. Ne t'inquiète pas pour ça, je vais te donner du travail.",
		"Mais... avant ça, nous devons vérifier si tu es en forme physiquement.\nRécupère <VP><b>15 morceaux de bois</b></VP> pour moi dans la forêt.\nTiens, voici <VP><b>10 pierres</b></VP> comme avance. Bonne chance !",
		"Pas mal du tout. Mais <i>de notre temps</i> on fait ça plus bien vite...\nMais ça n'a plus d'importance maintenant. Comme promis, le <VP><b>job</b></VP> est à toi.",
		"Ceci dit, tu as maintenant accès aux <b><VP>mines</VP></b>\nRends-toi à la <b><VP>porte</VP></b> à gauche d'ici puis baisse-toi <b><VP>↓</VP></b> pour l'ouvrir !",
		"En tout que premier job, vous devez récupérer<b><VP> 15 minerais de fer</VP></b>. Bonne courage à nouveau !",
		"Woah ! On dirait que je t'ai sous-estimé, bon travail !",
		"J'ai entendu que le <b><VP>château</VP></b> avait besoin de petits gars comme toi pour récupérer son trésor et sa princesse des mains des méchants...",
		"Tu pourrais tout à fait convenir !",
		"Je vais te donner une <b><VP>lettre de recommendation de Nosferatu</VP></b>, présente-là au <b><VP>Lieutenant</VP></b> quand tu arrives et avec un peu de chance, il te recrutera dans son armée.\n<i>eeet aussi voici un peu d'argent</i>",
		"Oh et n'oublie pas ta récompense de <b><VP>30 pierres</VP></b> pour ton dur labeur !",
		"Vous avez besoin de quelque chose ?",
		"C'est une connaissance de base... Vous devez <b><VP>couper un arbre avec une Pioche</VP></b>",
		"Donc vous devez utiliser une <b><VP>pioche</VP></b> ? Il doit y en avoir une qui traîne par là dans les <b><VP>bois</VP></b>. Baissez-vous <b><VP>↓</VP></b> pour évaluer et fabriquer la recette trouvée dans la <b><VP>station de construction</VP></b>.\nUne station se trouve à droite, au dessus de la mine.",
		"Je vends <b><VP>10 pierres</VP></b> pour <b><VP>35 bâtons</VP></b>",
		"Ah ok bon vent alors",
		"Votre inventaire a l'air d'être plein. Pourquoi vous ne le videriez pas avant de revenir vers moi pour récupérer votre récompense.",
		"C'est un plaisir de faire affaire avec toi !",
		"Il semblerait que tu n'aies pas assez d'items pour faire un échange petit."
	},
	NOSFERATU_QUESTIONS = {
		"Comment je me rends dans les bois ?",
		"Une pioche ?",
		"Échanger",
		"Non rien.",
		"It's something else."
	},
	EDRIC_DIALOGUES = {
		"Notre princesse... et le trésor, il est entre les mainis du démon. On doit se dépêcher.",
		"Attends. Tu dis que <b><VP>Nosferatu</VP></b> t'a envoyé ici et que tu peux aider nos troupes dans leurs missions ???",
		"C'est super. Mais travailler dans une armée n'est pas aussi simple que ce que tu crois.\nTu vas devoir faire quelques sessions d'<b><VP>entrainement intense</VP></b> pour renforcer ce petit corps de ton corps.\nRends-toi dans la <b><VP>zone d'entraîmenent à ma gauche</VP></b> pour commencer ton entrainement.",
		"Mais avant ça, assure-toi d'être fin prêt. Il y a quelques <b><VP>recettes</VP></b> dispercées autour des <b><VP>zones d'arme</VP></b> et des <b><VP>sombres forêts en bas de la colline</VP></b>\nJ'espère que vous en ferez bon usage !",
		"Reviens vers moi quand tu seras prêt !",
		"Es-tu prêt à relever le défi ?",
		"Super ! Va commencer votre formation dans la zone d'entraînement. Vous devez <b><VP>battre 25 monstres</VP></b> pour valider ce défi.",
		"Vous pouvez prendre autant de temps que vous le voulez\nBonne chance à toi !!!",
		"Vous avez prouvé que vous êtes digne ! On se dépêche !!! Rejoingnez le reste de nos soldats et allez combattre les monstres !"
	},
	EDRIC_QUESTIONS = {
		"J'ai besoin de plus de temps...",
		"Je suis prêt !"
	},
	GARRY_DIALOGUES = {
		"C'est le pire endroit que j'ai jamais vu. <b><VP>Nosferatu</VP></b> ne paie même pas assez. <i>*soupire...*</i>"
	},
	THOMPSON_DIALOGUES = {
		"Salut ! Tu cherches quelque chose ?",
		"Si vous recherchez une <b><VP>pelle</VP></b>, il doit y en avoir une <b><VP>tout à droite des mines</VP></b>.\nBon courage !",
		"Passe une bonne journée !"
	},
	THOMPSON_QUESTIONS = {
		"Aucune recette ?",
		"Je voulais juste dire bonjour."
	},
	COLE_DIALOGUES = {
		"Il y a beaucoup de <b><VP>monstres</VP></b> par ici. Fais attention !",
		"Toute notre armée se bat contre les monstres. Nous avons besoin de beaucoup d'aide.",
		"OIIIIII ! JE NE PEUX PAS LAISSER UN FAIBLE COMME TOI PRENDRE CETTE VOIE. REVIENS PAR ICI !"
	},
	MARC_DIALOGUES = {
		"BATS LES PATTES ! Ne touchez PAS à mon banc de travail !"
	},
	SARUMAN_DIALOGUES = {
		"EYYYYY !!!! EYYYYYYYYY !!!!\nIL Y A QUELQU'UN ICI ???",
		"HEYY!! AIDE-MOI À SORTIR DE LÀ !\nMERCI MON DIEU DE M'AVOIR SAUVÉ DE LÀ !!!",
		"Je suis <b><VP>Saruman</VP></b> au passage. J'étais bloqué ici depuis à peu près...\n15 ans ?",
		"Mon pote <b><VP>Hootie</VP></b> est la raison pour laquelle je suis encore en vie.\nJe serais mort de mort si il n'avait pas été là",
		"Oh vous voulez savoir comment et pourquoi je suis coincé ici ?",
		"Pour faire court, à l'époque où j'étais encore <b>jeune</b> et fort comme toi,\nj'ai entendu parler de ces trésors appelés <b><VP>orbes d'esprit</VP></b>",
		"J'étais professeur aussi, donc j'étais très intéressé par les recherches sur ce sujet.\nJ'ai rassemblé beaucoup d'informations sur elles.",
		"Ces orbes sont liées à l'âme d'une personne. Une fois qu'elles sont reliés aux <b><VP>5 orbes</VP></b> elles vont obtenir leur <b><VP>pouvoir divin</VP></b>",
		"Je ne suis pas sûr de quel type de pouvoir je vais obtenir ou de l'effet que ça aura sur moi...\nMais je suis certain que les <b><VP>moines</VP></b> vont savoir comment utiliser tout ça !",
		"Mais personne ne savait où ils se trouvaient exactement, alors je suis venu ici pour les trouver par moi-même.",
		"Je pense que j'ai fait un bon travail en en trouvant une de ces <VP><b>orbes du sanctuaire</b></VP>.\nMais... j'ai choisi le mauvais chemin et je suis resté coincé ici pour toujours depuis lors.",
		"Je suis heureux que vous m'ayez aidé à sortir ! N'hésitez pas à venir me voir pour savoir quoi que ce soit sur ces orbes.\nLa connaissance est là pour être partagée, et vous m'avez sauvé !",
		"Ouais, mon pote ! Que veux-tu savoir de moi ?",
		"Comme je l'ai dit, il y a <b><VP>5 orbes d'esprit</VP></b>\n<b><VP>3</VP></b> d'entre elles pourraient être trouvée dans les <b><VP>sanctuaires</VP></b> dans la sombre forêt.\nJe ne suis pas sûr des 2 autres...",
		"D'après les informations que j'ai recueillies, vous devrez relever divers défis pour accéder aux sanctuaires.",
		"Je pense que tu en connais déjà un, à moins que tu aies eu un pouvoir magique pour te téléporter ici",
		"Le deuxième sanctuaire est gardé par un grand nombre de <b><VP>monstres</VP></b> sur son chemin.\nIl faut donc bien s'équiper avant de s'y rendre !",
		"Et pour le dernier sanctuaire, j'ai trouvé cet <b><VP>indice</VP></b> dans des livres anciens",
		"<b><VP>\"Puzzles, énigmes et vieilles traditions\nScore mathématique, mais pas d'addition\nUne ressource qui a tant porté ses fruits\nApprendre à connaître sa vraie nature\nPrenez la mesure de votre rank à tous\nAu monde, vous devez appeler\"</VP></b>",
		"C'est tout! J'espère que vous ferez bon usage de cette information",
		"Merci d'être venu me voir, mon pote !",
		"OH ON DIRAIT QUE TU AS COLLECTÉ TOUS LES ORBES D'ESPRIT !!!\nNous sommes pareil maintenant... remerciez-moi plus tard !\nMais assurez-vous de trouver plus d'information sur ces orbes auprès d'un <b><VP>moine</VP></b>"
	},
	SARUMAN_QUESTIONS = {
		"Où sont les orbes ?",
		"Juste pour vérifier !"
	},
	MONK_DIALOGUES = {
		"Je détiens ce pouvoir maléfique depuis fort longtemps...\nContent d'apprendre que vous êtes venu nous aider",
		"Donc vous dites que vous possédez la totalité des <b><VP>5 orbes d'esprit</VP></b>",
		"Un très bon travail en effet. Maintenant, il sera plus facile de vaincre le pouvoir maléfique pour toujours.",
		"Ces orbes spirituelles sont en effet liées à l'esprit d'une personne.\nSeuls des individus courageux peuvent posséder les 5",
		"Ces orbes vous aideront à obtenir le <b><VP>pouvoir divin</VP></b> qui est le seul moyen de détruire le mal\npour autant que je sache",
		"Une fois que vous avez activé le pouvoir divin et affronté le mal...\nVous devrez parcourir un long chemin dans votre esprit pour atteindre la <b><VP>statut divine</VP></b>",
		"Les orbes spirituelles vous aideront à trouver le bon chemin pour y parvenir.\nVous n'avez qu'à voyager jusqu'au chemin qu'il vous montrera au bon moment !",
		"Je suis presque sûr que vous ne réussirez pas à atteindre la plus puissante énergie divine.\nMais même si vous vous en rapprochez...",
		"Cela va créer une grande énergie divine qui va ensuite invoquer le <b><VP>déesse</VP></b>",
		"Les livres anciens disent que la bête est trop puissante mais je suis presque sûr que la\n<b><VP>bénédiction de la déesse</VP></b> l'affablirait",
		"C'est donc à nous de détruire le pouvoir maléfique pour toujours !!!",
		"La déesse... elle est là\nCA SE PRODUIT !!!"
	},
	NIELS_DIALOGUES = {
		"Tout le monde se tient sur ses positions !",
		"Le <b><VP>dragon</VP></b> de l'autre côté de la rivière est trop dangereux.\nIl va utiliser ses <b><VP>attaques de feu</VP></b> et nous <b><VP>envoyer des rochers</VP></b> à la figure",
		"S'il vous plaît, soyez prudent...",
		"Cependant on ne peut pas attaquer le dragon directement, vu que le pont à l'air d'avoir sauté",
		"Le dragon l'a détruit une fois avec son feu, quand il a essayé de le traverser.",
		"Donc... nous devrons le réparer pour le traverser également. On se dépêche !!!"
	},
	PROPS = {
		attack = "Attaque",
		defense = "Défense",
		durability = "Endurance",
		chopping = "Coupe",
		mining = "Minage"
	}
}

-- theme color pallete: https://www.colourpod.com/post/173929539115/a-medieval-recipe-for-murder-submitted-by

translations["br"] = {
	OUT_OF_RESOURCES = "<font color='#ab5e42'>[</font> <font color='#c6b392'>•</font> <font color='#ab5e42'>]</font> <font color='#c6b392' face='Lucida Console'>Sem recursos!</font>",
	NEW_RECIPE = "<font color='#506d3d' size='8'><b>[NOVA RECEITA]</b></font> <font color='#ab5e42' face='Lucida Console'><b>${itemName}</b></font>\n<font color='#bd9d60' size='11' face='Lucida Console'>(${itemDesc})</font>",
	NEW_QUEST = "<font color='#506d3d' size='8'><b>[NOVA MISSÃO]</b></font> <font color='#ab5e42' face='Lucida Console'><b>${questName}</b></font>",
	NEW_STAGE = "<font color='#506d3d' size='8'><b>[ATUALIZAÇÃO]</b></font> <font color='#ab5e42' face='Lucida Console'><b>${questName}</b></font>\n<font color='#bd9d60' size='11' face='Lucida Console'>(${desc})</font>",
	STAGE_PROGRESS = "<font color='#506d3d' size='8'><b>[ATUALIZAÇÃO]</b></font> <font color='#ab5e42' face='Lucida Console'><b>${questName}</b></font> <font color='#bd9d60' size='11' face='Lucida Console'>( ${progress} / ${needed} )</font>",
	QUEST_OVER = "<font color='#506d3d' size='8'><b>[COMPLETO]</b></font> <font color='#ab5e42' face='Lucida Console'><b>${questName}</b></font>",
	SPIRIT_ORB = "<b><font color='#ab5e42' face='Lucida Console'>Você recebeu uma <font color='#bd9d60' face='Lucida Console'>Orbe espiritual!</font></font></b>",
	PASSCODE = "Por favor, insira a senha.",
	WRONG_GUESS = "<R>Senha incorreta.</R>",
	INVENTORY_INFO = "<font face='Lucida Console'><p align='center'><font color='#${color}' size='9'>Weight: ${weight}</font>\n\n\n\n<font size='9'><N2><b>[X] Soltar</b></N2></font></p></font>",
	FULL_INVENTORY = "<font color='#ab5e42'>[</font> <font color='#c6b392'>•</font> <font color='#ab5e42'>]</font> <font color='#c6b392' face='Lucida Console'>Seu inventário está cheio!</font>",
	CRAFT = "Construir!",
	CANT_CRAFT = "Não dá pra construir.",
	RECIPE_DESC = "\n\n<font face='Lucida console' size='12' color='#cccccc'><i>“ ${desc} ”</i></font>",
	FINAL_BATTLE_PING = "<font color='#ab5e42'>[</font> <font color='#c6b392'>•</font> <font color='#ab5e42'>]</font> <font color='#c6b392' face='Lucida Console'>A batalha final está acontecendo!</font>",
	ACTIVATE_POWER = "<font color='#ab5e42'>[</font> <font color='#c6b392'>•</font> <font color='#ab5e42'>]</font> <font color='#c6b392' face='Lucida Console'>Press <font color='#ab5e42'><b>U</b></font> to toggle <font color='#ab5e42'><b>poder divino!</b></font></font>",
	ANNOUNCER_DIALOGUES = {
		"ATENÇÃO TODO MUNDO, ATENÇÃO!!!",
		"Essa mensagem é de vossa majestade, o glorioso Rei dessa terra…",
		"Nossa terra está sendo atacada por monstros implacáveis que nós já tínhamos derrotado há algum tempo.",
		"Dito isso, temos uma notícia infeliz a ser anunciada. <b><VP>Nossa princesa foi sequestrada.</VP></b>",
		"Os monstros impiedosos também conseguiram se safar com quase todo o tesouro do reino.",
		"O Rei está procurando por BRAVOS SOLDADOS que ajudarão o exército a derrotar todos esses monstros e salvar a princesa\ncom o nosso tesouro",
		"O Rei estará esperando a presença de todos os corações valentes...\n"
	},
	NOSFERATU_DIALOGUES = {
		"Ah você parece novo por aqui… De qualquer forma você parece útil",
		"Então você está me dizendo que você veio aqui de outra dimensão, e não tem ideia de onde você está ou o que deve fazer?\n<i>*Hmmm talvez você seja realmente útil pra mim</i>",
		"Bem, jovem, acho que você precisa de um emprego para viver. Não se preocupe com isso, eu te darei um emprego sim sim.",
		"Mas antes disso… Preciso verificar se você está em um bom estado físico.\nPegue <VP><b>15 madeira</b></VP> para mim da floresta.\nTome essas<VP><b>10 pedra</b></VP> como adiantamento, boa sorte!",
		"Bem impressionante mesmo. Mas <i>na minha época</i> a gente fazia bem mais rápido...\nNão que importe agora. Como eu prometi o<VP><b>trabalho</b></VP> é seu.",
		"Dito isso, agora você tem acesso à <b><VP>mina</VP></b>\nVá para a  <b><VP>porta</VP></b> à esquerda daqui e <b><VP>↓</VP></b> para entrar!",
		"Como seu primeiro trabalho, preciso que você pegue<b><VP> 15 minério de ferro</VP></b>. Boa sorte de novo!",
		"Uau! Parece que eu te subestimei, que trabalho impressionante!",
		"Ouvi dizer que o <b><VP>castelo</VP></b> precisa de alguns jovens como você para salvar a princesa e o tesouro dos bandidos…",
		"Você poderia ser ótimo para isso!",
		"Eu vou te dar <b><VP>Carta de recomendação do Nosferatu</VP></b>, mostre isso para o <b><VP>Tenente</VP></b> e torcemos para que ele te recrute para o exército.\n<i>eeee isso pode te dar uma boa grana também.</i>",
		"Ah e não se esqueça da sua recompensa de  <b><VP>30 pedra</VP></b> por todo seu trabalho duro!",
		"Você precisa de algo?",
		"Isso é bem simples... Você precisa <b><VP>cortar uma árvore com uma picareta</VP></b>",
		"Então você precisa de uma <b><VP>picareta</VP></b>? Deve ter uma por aí na <b><VP>floresta</VP></b>. <b><VP>↓</VP></b> Para estudar e construir a receita aprendida em uma <b><VP>estação de construção</VP></b>.\nA estação está localizada logo acima dessa mina.",
		"Eu vendo <b><VP>10 pedra</VP></b> por <b><VP>35 gravetos</VP></b>",
		"Ah ok. Tchauzinho.",
		"Seu inventário parece cheio. Que tal você esvaziá-lo e depois voltar aqui pra sua recompensa?",
		"Foi um prazer fazer negócios com você!",
		"Parece que você não tem itens suficientes para fazer essa troca amigo."
	},
	NOSFERATU_QUESTIONS = {
		"Como conseguir madeira?",
		"Picareta?",
		"Trocar",
		"Nada não.",
		"It's something else."
	},
	EDRIC_DIALOGUES = {
		"Nossa princesa... e o tesouro, estão nas mãos do mal. Temos que correr",
		"Peraí. Então você diz que <b><VP>Nosferatu</VP></b> mandou você aqui para nos ajudar com as nossas tropas e suas missões???",
		"Isso é ótimo. Porém trabalhar para um exército não é tão simples quanto parece.\nVocê vai precisar fazer um pouco de <b><VP>treinamento intenso</VP></b>considerando que seu corpo não está em forma.\nVá para a <b><VP>área de treinamento à minha esquerda</VP></b> para começar seu treinamento.",
		"Mas antes disso, tenha certeza que você está totalmente preparado. Há algumas <b><VP>receitas</VP></b> espalhadas pelos <b><VP>armamentos</VP></b> e as <b><VP>florestas sombrias descendo a colina.</VP></b>\nEspero que você faça um bom uso delas!",
		"Fale comigo de novo quando estiver pronto!",
		"Está pronto para o desafio?",
		"Ótimo! Vá começar seu treinamento na área de treinamento. Você precisa <b><VP>derrotar 25 monstros</VP></b> para passar esse desafio.",
		"Você pode levar o tempo que quiser.\nBoa sorte!!!",
		"Você se provou digno! Depressa!! Junte-se ao resto dos nossos soldados e lute contra os monstros!"
	},
	EDRIC_QUESTIONS = {
		"Preciso de mais tempo...",
		"Estou pronto"
	},
	GARRY_DIALOGUES = {
		"Esse é o pior lugar que já estive. <b><VP>Nosferatu</VP></b> nem me paga tão bem assim. <i>*suspiro...*</i>"
	},
	THOMPSON_DIALOGUES = {
		"Olá! Você precisa de algo de mim?",
		"Se você está procurando por uma <b><VP>pá</VP></b>, deve ter uma na <b><VP>parte mais a direita da mina</VP></b>.\nBoa sorte!",
		"Tenha um ótimo dia!"
	},
	THOMPSON_QUESTIONS = {
		"Alguma receita?",
		"Só dando um oi."
	},
	COLE_DIALOGUES = {
		"Há muitos <b><VP>monstros</VP></b> por aí. Tenha cuidado!",
		"Todo o nosso exército está lutando contra os monstros, precisamos de muita ajuda.",
		"EEEEEI! NÃO POSSO DEIXAR UM FRACO COMO VOCÊ IR POR AÍ. VOLTE!"
	},
	MARC_DIALOGUES = {
		"CAI FORA! Não toque na minha mesa de trabalho!"
	},
	SARUMAN_DIALOGUES = {
		"EIIIIIII!!!! EIIIIIIIII!!!!\nTEM ALGUÉM AQUI???",
		"OWWW!! ME AJUDE AQUI!\nGRAÇAS A DEUS ALGUÉM ME AJUDOU!!!",
		"Inclusive, meu nome é <b><VP>Saruman</VP></b>. Eu estive preso por aqui há...\nuns 15 anos?",
		"Meu amigo <b><VP>Hootie</VP></b> É a razão de eu ainda estar vivo.\nEu morreria de fome se não fosse ele",
		"Então você quer saber como e por que eu fiquei preso aqui?",
		"Dando uma resumida, quando eu ainda era <b>jovem</b> e forte como você,\nEu ouvi falar desses tesouros chamados <b><VP>Orbes Espirituais</VP></b>",
		"Eu também era professor, então fiquei bastante interessado em pesquisar sobre esse assunto.\nJá juntei muitas informações sobre eles.",
		"Esses Orbes estão ligados à alma dae uma pessoa. Uma vez que a pessoa esteja ligada com todas as  <b><VP>5 Orbes</VP></b> ela conseguirá o <b><VP>poder divino</VP></b>",
		"Eu não tenho certeza que tipo de poder eu conseguiria ou o que ele faria comigo...\nMas tenho certeza de que os <b><VP>monges</VP></b> sabem mais sobre como usá-lo!",
		"Mas ninguém sabe exatamente onde eles estão, então eu vim aqui para encontrá-los sozinho.",
		"Creio que fiz um bom trabalho encontrando um <VP><b>Orbe santuário</b></VP>.\nMas... Eu escolhi o caminho errado e fiquei preso desde então.",
		"Fico grato que você me ajudou! Sinta-se à vontade para falar comigo sobre esses Orbes\nConhecimento é pra compartilhar e você me salvou!",
		"Sim amigo! O que você quer saber?",
		"Como eu disse, há <b><VP>5 Orbes espirituais</VP></b>\n<b><VP>3</VP></b> delas podem ser encontradas nos <b><VP>santuários</VP></b> nessa floresta sombria.\nEu não tenho certeza sobre as últimas 2...",
		"A partir das informações que coletei, você terá que enfrentar vários desafios para entrar nos santuários.",
		"Acho que você já sabe de uma, a não ser que você tenha teleportado para cá",
		"O segundo santuário é guardado por muitos <b><VP>monstros</VP></b> no caminho.\nEntão se equipe bem antes de explorar!",
		"E para o último santuário eu encontrei essa <b><VP>pista</VP></b> dentro de livros antigos",
		"<b><VP>\"quebra-cabeças, charadas e antigas tradições\nPontuação matemática, mas não adição\nUm recurso que rendeu muito\nChega a termo com a verdadeira sabedoria\nPegue o rank mostrado para todos\nPara o mundo você precisa chamar\"</VP></b>",
		"Isso é tudo! Espero que você faça bom uso dessa informação",
		"Obrigada por vir me ver amigo!",
		"PARECE QUE VOCÊ PEGOU TODAS AS ORBES!!!\nEstamos os quites agora... me agradeça depois!\nMas tenha certeza de conseguir mais informações sobre as Orbes com um <b><VP>monge</VP></b>"
	},
	SARUMAN_QUESTIONS = {
		"Onde estão as Orbes?",
		"Só checando!"
	},
	MONK_DIALOGUES = {
		"Eu venho segurando esse poder maligno há muito tempo...\nFico feliz em saber que você veio nos ajudar",
		"Então você está me dizendo que possui todas as <b><VP>5 Orbes espirituais?</VP></b>",
		"Muito bom trabalho, de fato. Agora isso tornará mais fácil derrotar o poder do mal para sempre.",
		"Essas Orbes espirituais estão realmente ligados ao espírito de uma pessoa.\nSomente os mais corajosos podem possuir todos os 5",
		"Essas Orbes vão te ajudar a ter o <b><VP>poder divino</VP></b> que é o único jeito de destruir o mal\naté onde eu sei.",
		"Depois de ativar o poder divino e confrontar o mal...\nVocê terá que percorrer um longo caminho dentro de sua mente para alcançar o <b><VP>status divino</VP></b>",
		"As Orbes divinas vão te ajudar a achar o caminho certo para isso.\nVocê só precisa seguir o caminho e ela te mostrará na hora certa!",
		"Tenho quase certeza de que você não conseguirá chegar até a energia mais poderosa\nPorém mesmo que você chegue perto...",
		"Isso criará uma energia grande o bastante para convocar a  <b><VP>deusa</VP></b>",
		"Livros antigos dizem que a fera é muito poderosa, mas acredito que a \n<b><VP>benção da deusa</VP></b> a deixaria mais fraca",
		"E quando estiver, destruiremos o poder do mal para sempre!!!",
		"A deusa... ela está aqui\nESTÁ ACONTECENDO!!!"
	},
	NIELS_DIALOGUES = {
		"Todo mundo mantenha suas posições!",
		"O <b><VP>dragão</VP></b> do outro lado do rio é muito perigoso.\nEle usará seus <b><VP>ataques de fogo</VP></b> e irá <b><VP>jogar pedras</VP></b> em você.",
		"Por favor, tenha cuidado...",
		"De qualquer forma, não podemos atacar diretamente o dragão, pois a ponte está quebrada",
		"O dragão a destruiu a ponte quando tentamos atravessar.",
		"Então… Nós teremos que consertá-la também! Depressa!!!"
	},
	PROPS = {
		attack = "Ataque",
		defense = "Defesa",
		durability = "Durabilidade",
		chopping = "Corte",
		mining = "Mineração"
	}
}



-- theme color pallete: https://www.colourpod.com/post/173929539115/a-medieval-recipe-for-murder-submitted-by

translations["pt"] = {
	OUT_OF_RESOURCES = "<font color='#ab5e42'>[</font> <font color='#c6b392'>•</font> <font color='#ab5e42'>]</font> <font color='#c6b392' face='Lucida Console'>Sem recursos!</font>",
	NEW_RECIPE = "<font color='#506d3d' size='8'><b>[NOVA RECEITA]</b></font> <font color='#ab5e42' face='Lucida Console'><b>${itemName}</b></font>\n<font color='#bd9d60' size='11' face='Lucida Console'>(${itemDesc})</font>",
	NEW_QUEST = "<font color='#506d3d' size='8'><b>[NOVA MISSÃO]</b></font> <font color='#ab5e42' face='Lucida Console'><b>${questName}</b></font>",
	NEW_STAGE = "<font color='#506d3d' size='8'><b>[ATUALIZAÇÃO]</b></font> <font color='#ab5e42' face='Lucida Console'><b>${questName}</b></font>\n<font color='#bd9d60' size='11' face='Lucida Console'>(${desc})</font>",
	STAGE_PROGRESS = "<font color='#506d3d' size='8'><b>[ATUALIZAÇÃO]</b></font> <font color='#ab5e42' face='Lucida Console'><b>${questName}</b></font> <font color='#bd9d60' size='11' face='Lucida Console'>( ${progress} / ${needed} )</font>",
	QUEST_OVER = "<font color='#506d3d' size='8'><b>[COMPLETO]</b></font> <font color='#ab5e42' face='Lucida Console'><b>${questName}</b></font>",
	SPIRIT_ORB = "<b><font color='#ab5e42' face='Lucida Console'>Você recebeu uma <font color='#bd9d60' face='Lucida Console'>Orbe espiritual!</font></font></b>",
	PASSCODE = "Por favor, insira a senha.",
	WRONG_GUESS = "<R>Senha incorreta.</R>",
	INVENTORY_INFO = "<font face='Lucida Console'><p align='center'><font color='#${color}' size='9'>Weight: ${weight}</font>\n\n\n\n<font size='9'><N2><b>[X] Soltar</b></N2></font></p></font>",
	FULL_INVENTORY = "<font color='#ab5e42'>[</font> <font color='#c6b392'>•</font> <font color='#ab5e42'>]</font> <font color='#c6b392' face='Lucida Console'>Seu inventário está cheio!</font>",
	CRAFT = "Construir!",
	CANT_CRAFT = "Não dá pra construir.",
	RECIPE_DESC = "\n\n<font face='Lucida console' size='12' color='#cccccc'><i>“ ${desc} ”</i></font>",
	FINAL_BATTLE_PING = "<font color='#ab5e42'>[</font> <font color='#c6b392'>•</font> <font color='#ab5e42'>]</font> <font color='#c6b392' face='Lucida Console'>A batalha final está acontecendo!</font>",
	ACTIVATE_POWER = "<font color='#ab5e42'>[</font> <font color='#c6b392'>•</font> <font color='#ab5e42'>]</font> <font color='#c6b392' face='Lucida Console'>Press <font color='#ab5e42'><b>U</b></font> to toggle <font color='#ab5e42'><b>poder divino!</b></font></font>",
	ANNOUNCER_DIALOGUES = {
		"ATENÇÃO TODO MUNDO, ATENÇÃO!!!",
		"Essa mensagem é de vossa majestade, o glorioso Rei dessa terra…",
		"Nossa terra está sendo atacada por monstros implacáveis que nós já tínhamos derrotado há algum tempo.",
		"Dito isso, temos uma notícia infeliz a ser anunciada. <b><VP>Nossa princesa foi sequestrada.</VP></b>",
		"Os monstros impiedosos também conseguiram se safar com quase todo o tesouro do reino.",
		"O Rei está procurando por BRAVOS SOLDADOS que ajudarão o exército a derrotar todos esses monstros e salvar a princesa\ncom o nosso tesouro",
		"O Rei estará esperando a presença de todos os corações valentes...\n"
	},
	NOSFERATU_DIALOGUES = {
		"Ah você parece novo por aqui… De qualquer forma você parece útil",
		"Então você está me dizendo que você veio aqui de outra dimensão, e não tem ideia de onde você está ou o que deve fazer?\n<i>*Hmmm talvez você seja realmente útil pra mim</i>",
		"Bem, jovem, acho que você precisa de um emprego para viver. Não se preocupe com isso, eu te darei um emprego sim sim.",
		"Mas antes disso… Preciso verificar se você está em um bom estado físico.\nPegue <VP><b>15 madeira</b></VP> para mim da floresta.\nTome essas<VP><b>10 pedra</b></VP> como adiantamento, boa sorte!",
		"Bem impressionante mesmo. Mas <i>na minha época</i> a gente fazia bem mais rápido...\nNão que importe agora. Como eu prometi o<VP><b>trabalho</b></VP> é seu.",
		"Dito isso, agora você tem acesso à <b><VP>mina</VP></b>\nVá para a  <b><VP>porta</VP></b> à esquerda daqui e <b><VP>↓</VP></b> para entrar!",
		"Como seu primeiro trabalho, preciso que você pegue<b><VP> 15 minério de ferro</VP></b>. Boa sorte de novo!",
		"Uau! Parece que eu te subestimei, que trabalho impressionante!",
		"Ouvi dizer que o <b><VP>castelo</VP></b> precisa de alguns jovens como você para salvar a princesa e o tesouro dos bandidos…",
		"Você poderia ser ótimo para isso!",
		"Eu vou te dar <b><VP>Carta de recomendação do Nosferatu</VP></b>, mostre isso para o <b><VP>Tenente</VP></b> e torcemos para que ele te recrute para o exército.\n<i>eeee isso pode te dar uma boa grana também.</i>",
		"Ah e não se esqueça da sua recompensa de  <b><VP>30 pedra</VP></b> por todo seu trabalho duro!",
		"Você precisa de algo?",
		"Isso é bem simples... Você precisa <b><VP>cortar uma árvore com uma picareta</VP></b>",
		"Então você precisa de uma <b><VP>picareta</VP></b>? Deve ter uma por aí na <b><VP>floresta</VP></b>. <b><VP>↓</VP></b> Para estudar e construir a receita aprendida em uma <b><VP>estação de construção</VP></b>.\nA estação está localizada logo acima dessa mina.",
		"Eu vendo <b><VP>10 pedra</VP></b> por <b><VP>35 gravetos</VP></b>",
		"Ah ok. Tchauzinho.",
		"Seu inventário parece cheio. Que tal você esvaziá-lo e depois voltar aqui pra sua recompensa?",
		"Foi um prazer fazer negócios com você!",
		"Parece que você não tem itens suficientes para fazer essa troca amigo."
	},
	NOSFERATU_QUESTIONS = {
		"Como conseguir madeira?",
		"Picareta?",
		"Trocar",
		"Nada não.",
		"It's something else."
	},
	EDRIC_DIALOGUES = {
		"Nossa princesa... e o tesouro, estão nas mãos do mal. Temos que correr",
		"Peraí. Então você diz que <b><VP>Nosferatu</VP></b> mandou você aqui para nos ajudar com as nossas tropas e suas missões???",
		"Isso é ótimo. Porém trabalhar para um exército não é tão simples quanto parece.\nVocê vai precisar fazer um pouco de <b><VP>treinamento intenso</VP></b>considerando que seu corpo não está em forma.\nVá para a <b><VP>área de treinamento à minha esquerda</VP></b> para começar seu treinamento.",
		"Mas antes disso, tenha certeza que você está totalmente preparado. Há algumas <b><VP>receitas</VP></b> espalhadas pelos <b><VP>armamentos</VP></b> e as <b><VP>florestas sombrias descendo a colina.</VP></b>\nEspero que você faça um bom uso delas!",
		"Fale comigo de novo quando estiver pronto!",
		"Está pronto para o desafio?",
		"Ótimo! Vá começar seu treinamento na área de treinamento. Você precisa <b><VP>derrotar 25 monstros</VP></b> para passar esse desafio.",
		"Você pode levar o tempo que quiser.\nBoa sorte!!!",
		"Você se provou digno! Depressa!! Junte-se ao resto dos nossos soldados e lute contra os monstros!"
	},
	EDRIC_QUESTIONS = {
		"Preciso de mais tempo...",
		"Estou pronto"
	},
	GARRY_DIALOGUES = {
		"Esse é o pior lugar que já estive. <b><VP>Nosferatu</VP></b> nem me paga tão bem assim. <i>*suspiro...*</i>"
	},
	THOMPSON_DIALOGUES = {
		"Olá! Você precisa de algo de mim?",
		"Se você está procurando por uma <b><VP>pá</VP></b>, deve ter uma na <b><VP>parte mais a direita da mina</VP></b>.\nBoa sorte!",
		"Tenha um ótimo dia!"
	},
	THOMPSON_QUESTIONS = {
		"Alguma receita?",
		"Só dando um oi."
	},
	COLE_DIALOGUES = {
		"Há muitos <b><VP>monstros</VP></b> por aí. Tenha cuidado!",
		"Todo o nosso exército está lutando contra os monstros, precisamos de muita ajuda.",
		"EEEEEI! NÃO POSSO DEIXAR UM FRACO COMO VOCÊ IR POR AÍ. VOLTE!"
	},
	MARC_DIALOGUES = {
		"CAI FORA! Não toque na minha mesa de trabalho!"
	},
	SARUMAN_DIALOGUES = {
		"EIIIIIII!!!! EIIIIIIIII!!!!\nTEM ALGUÉM AQUI???",
		"OWWW!! ME AJUDE AQUI!\nGRAÇAS A DEUS ALGUÉM ME AJUDOU!!!",
		"Inclusive, meu nome é <b><VP>Saruman</VP></b>. Eu estive preso por aqui há...\nuns 15 anos?",
		"Meu amigo <b><VP>Hootie</VP></b> É a razão de eu ainda estar vivo.\nEu morreria de fome se não fosse ele",
		"Então você quer saber como e por que eu fiquei preso aqui?",
		"Dando uma resumida, quando eu ainda era <b>jovem</b> e forte como você,\nEu ouvi falar desses tesouros chamados <b><VP>Orbes Espirituais</VP></b>",
		"Eu também era professor, então fiquei bastante interessado em pesquisar sobre esse assunto.\nJá juntei muitas informações sobre eles.",
		"Esses Orbes estão ligados à alma dae uma pessoa. Uma vez que a pessoa esteja ligada com todas as  <b><VP>5 Orbes</VP></b> ela conseguirá o <b><VP>poder divino</VP></b>",
		"Eu não tenho certeza que tipo de poder eu conseguiria ou o que ele faria comigo...\nMas tenho certeza de que os <b><VP>monges</VP></b> sabem mais sobre como usá-lo!",
		"Mas ninguém sabe exatamente onde eles estão, então eu vim aqui para encontrá-los sozinho.",
		"Creio que fiz um bom trabalho encontrando um <VP><b>Orbe santuário</b></VP>.\nMas... Eu escolhi o caminho errado e fiquei preso desde então.",
		"Fico grato que você me ajudou! Sinta-se à vontade para falar comigo sobre esses Orbes\nConhecimento é pra compartilhar e você me salvou!",
		"Sim amigo! O que você quer saber?",
		"Como eu disse, há <b><VP>5 Orbes espirituais</VP></b>\n<b><VP>3</VP></b> delas podem ser encontradas nos <b><VP>santuários</VP></b> nessa floresta sombria.\nEu não tenho certeza sobre as últimas 2...",
		"A partir das informações que coletei, você terá que enfrentar vários desafios para entrar nos santuários.",
		"Acho que você já sabe de uma, a não ser que você tenha teleportado para cá",
		"O segundo santuário é guardado por muitos <b><VP>monstros</VP></b> no caminho.\nEntão se equipe bem antes de explorar!",
		"E para o último santuário eu encontrei essa <b><VP>pista</VP></b> dentro de livros antigos",
		"<b><VP>\"quebra-cabeças, charadas e antigas tradições\nPontuação matemática, mas não adição\nUm recurso que rendeu muito\nChega a termo com a verdadeira sabedoria\nPegue o rank mostrado para todos\nPara o mundo você precisa chamar\"</VP></b>",
		"Isso é tudo! Espero que você faça bom uso dessa informação",
		"Obrigada por vir me ver amigo!",
		"PARECE QUE VOCÊ PEGOU TODAS AS ORBES!!!\nEstamos os quites agora... me agradeça depois!\nMas tenha certeza de conseguir mais informações sobre as Orbes com um <b><VP>monge</VP></b>"
	},
	SARUMAN_QUESTIONS = {
		"Onde estão as Orbes?",
		"Só checando!"
	},
	MONK_DIALOGUES = {
		"Eu venho segurando esse poder maligno há muito tempo...\nFico feliz em saber que você veio nos ajudar",
		"Então você está me dizendo que possui todas as <b><VP>5 Orbes espirituais?</VP></b>",
		"Muito bom trabalho, de fato. Agora isso tornará mais fácil derrotar o poder do mal para sempre.",
		"Essas Orbes espirituais estão realmente ligados ao espírito de uma pessoa.\nSomente os mais corajosos podem possuir todos os 5",
		"Essas Orbes vão te ajudar a ter o <b><VP>poder divino</VP></b> que é o único jeito de destruir o mal\naté onde eu sei.",
		"Depois de ativar o poder divino e confrontar o mal...\nVocê terá que percorrer um longo caminho dentro de sua mente para alcançar o <b><VP>status divino</VP></b>",
		"As Orbes divinas vão te ajudar a achar o caminho certo para isso.\nVocê só precisa seguir o caminho e ela te mostrará na hora certa!",
		"Tenho quase certeza de que você não conseguirá chegar até a energia mais poderosa\nPorém mesmo que você chegue perto...",
		"Isso criará uma energia grande o bastante para convocar a  <b><VP>deusa</VP></b>",
		"Livros antigos dizem que a fera é muito poderosa, mas acredito que a \n<b><VP>benção da deusa</VP></b> a deixaria mais fraca",
		"E quando estiver, destruiremos o poder do mal para sempre!!!",
		"A deusa... ela está aqui\nESTÁ ACONTECENDO!!!"
	},
	NIELS_DIALOGUES = {
		"Todo mundo mantenha suas posições!",
		"O <b><VP>dragão</VP></b> do outro lado do rio é muito perigoso.\nEle usará seus <b><VP>ataques de fogo</VP></b> e irá <b><VP>jogar pedras</VP></b> em você.",
		"Por favor, tenha cuidado...",
		"De qualquer forma, não podemos atacar diretamente o dragão, pois a ponte está quebrada",
		"O dragão a destruiu a ponte quando tentamos atravessar.",
		"Então… Nós teremos que consertá-la também! Depressa!!!"
	},
	PROPS = {
		attack = "Ataque",
		defense = "Defesa",
		durability = "Durabilidade",
		chopping = "Corte",
		mining = "Mineração"
	}
}



translations["ru"] = {

	OUT_OF_RESOURCES = "<font color='#ab5e42'>[</font> <font color='#c6b392'>•</font> <font color='#ab5e42'>]</font> <font color='#c6b392' face='Lucida Console'>Кончились ресурсы!</font>",
	NEW_RECIPE = "<font color='#506d3d' size='8'><b>[НОВЫЙ РЕЦЕПТ]</b></font> <font color='#ab5e42' face='Lucida Console'><b>${itemName}</b></font>\n<font color='#bd9d60' size='11' face='Lucida Console'>(${itemDesc})</font>",
	NEW_QUEST = "<font color='#506d3d' size='8'><b>[НОВЫЙ КВЕСТ]</b></font> <font color='#ab5e42' face='Lucida Console'><b>${questName}</b></font>",
	NEW_STAGE = "<font color='#506d3d' size='8'><b>[ОБНОВЛЕНИЕ]</b></font> <font color='#ab5e42' face='Lucida Console'><b>${questName}</b></font>\n<font color='#bd9d60' size='11' face='Lucida Console'>(${desc})</font>",
	STAGE_PROGRESS = "<font color='#506d3d' size='8'><b>[ОБНОВЛЕНИЕ]</b></font> <font color='#ab5e42' face='Lucida Console'><b>${questName}</b></font> <font color='#bd9d60' size='11' face='Lucida Console'>( ${progress} / ${needed} )</font>",
	QUEST_OVER = "<font color='#506d3d' size='8'><b>[ПРОЙДЕНО]</b></font> <font color='#ab5e42' face='Lucida Console'><b>${questName}</b></font>",
	SPIRIT_ORB = "<b><font color='#ab5e42' face='Lucida Console'>You received a <font color='#bd9d60' face='Lucida Console'>шар душ!</font></font></b>",
	PASSCODE = "Пожалуйста, введите пароль.",
	WRONG_GUESS = "<R>Неправильный пароль.</R>",
	INVENTORY_INFO = "<font face='Lucida Console'><p align='center'><font color='#${color}' size='9'>Weight: ${weight}</font>\n\n\n\n<font size='9'><N2><b>[X] Кинуть</b></N2></font></p></font>",
	FULL_INVENTORY = "<font color='#ab5e42'>[</font> <font color='#c6b392'>•</font> <font color='#ab5e42'>]</font> <font color='#c6b392' face='Lucida Console'>Ваш инвентарь полон!</font>",
	FINAL_BOSS_ENTER_FAIL = "<font color='#ab5e42'>[</font> <font color='#c6b392'>•</font> <font color='#ab5e42'>]</font> <font color='#c6b392' face='Lucida Console'>Тебе нужна сфера души гдракона чтобы зайти в портал!</font>",
	CRAFT = "Смастерить!",
	CANT_CRAFT = "Нельзя смастерить",
	RECIPE_DESC = "\n\n<font face='Lucida console' size='12' color='#999999'><i>“ ${desc} ”</i></font>",
	FINAL_BATTLE_PING = "<font color='#ab5e42'>[</font> <font color='#c6b392'>•</font> <font color='#ab5e42'>]</font> <font color='#c6b392' face='Lucida Console'>Финальный бой!</font>",
	ACTIVATE_POWER = "<font color='#ab5e42'>[</font> <font color='#c6b392'>•</font> <font color='#ab5e42'>]</font> <font color='#c6b392' face='Lucida Console'>Жми <font color='#ab5e42'><b>U</b></font> чтобы запустить <font color='#ab5e42'><b>божественную силу!</b></font></font>",
	ANNOUNCER_DIALOGUES = {
		"ВНИМАНИЕ ВСЕ! ВНИМАНИЕ!!!",
		"Это послание от его высочества, славного короля этих земель...",
		"Наши земли под атакой беспощадных монстров которые были когда-то свергнуты.",
		"Дальше произошло ужасное. <b><VP>Нашу принцессу похитили.</VP></b>",
		"Эти беспощадные монстры смогли так же унести всю нашу казну.",
		"Король ищет ХРАБРЫХ СОЛДАТОВ которые отправятся в миссию и спасут нашу принцессу\nи богатства",
		"Король ждёт присутствия всех, кто храбрые сердцем...\n"
	},
	NOSFERATU_DIALOGUES = {
		"Так-так, ты кажется новичок... В любом случае, ты явно полезный(ая)",
		"Так ты говоришь, что пришёл(ла) из другого мира, и не понимаешь, где ты и что делать\n<i>*Хммм, может он(а) действительно может мне пригодиться</i>",
		"Итак, юноша (юная леди), тебе нужна работа чтобы выжить. Не волнуйся, я дам тебе работу. Да да.",
		"Но... сначала, нам нужно проверить в хорошей ли ты форме.\nСобери <VP><b>15 древесины</b></VP> для меня в лесу.\nВот тебе <VP><b>10 камней</b></VP> заранее. Удачи!",
		"Впечатляет. Но <i>в наши дни</i> мы делали это быстрее...\nНе имеет значения. Как я обещал, <VP><b>работа</b></VP> твоя.",
		"Теперь у тебя есть доступ к <b><VP>шахте</VP></b>\nИди к <b><VP>двери</VP></b> справа от меня и жми <b><VP>↓</VP></b> чтобы открыть её!",
		"В первую очередь, мне нужно чтобы ты достал(а) <b><VP> 15 железа</VP></b>. Опять же, удачи!",
		"Вау! Кажется я тебя недооценил, потрясающая работа!",
		"Я слышал что <b><VP>замок</VP></b> нуждается в нескольких юных солдат, чтобы спасти казну и принцессу...",
		"Ты бы подошёл(ла)!",
		"Я дам тебе <b><VP>письмо рекомендации от Носферату</VP></b>, вручи его <b><VP>Лейтенанту</VP></b> и надеюсь тебя примут в армию.\n<i>И тут ещё хорошие деньги</i>",
		"Ах да, не забудь свою награду в <b><VP>30 камня</VP></b> за твой труд!",
		"Могу ли я чем-то помочь?",
		"Это все знают... Тебе надо <b><VP>срубить дерево топором</VP></b>",
		"Так тебе нужен <b><VP>топор</VP></b>? Один должен валяться в <b><VP>лесу</VP></b>. <b><VP>↓</VP></b> чтобы изучить рецепт и сделать его в <b><VP>мастерской</VP></b>.\nОдна мастерская находится прямо над этой шахтой.",
		"Я продаю <b><VP>10 камня</VP></b> за <b><VP>35 веток</VP></b>",
		"Тогда до встречи",
		"Твой инвентарь кажется полный. Сделай немного места и вернись за наградой.",
		"Хорошо иметь с тобой дело!",
		"Кажется тебе не хватает ресурсов для такого обмена, дитя."
	},
	NOSFERATU_QUESTIONS = {
		"Как мне достать дерево?",
		"Топор?",
		"Обмен",
		"Не важно.",
		"It's something else."
	},
	EDRIC_DIALOGUES = {
		"Наша принцесса... и богатства в руках чудищ. Нужно торопиться",
		"Погоди. Значит, <b><VP>Носферату</VP></b> послал тебя чтобы ты смог(ла) помочь солдатам в миссии???",
		"Прелестно. Но быть в армии труднее чем ты думаешь.\nТебе придётся пройти <b><VP>интенсивную подготовку</VP></b>, так как ты не в форме.\nИди к <b><VP>зоне тренировок слева от меня</VP></b> чтобы приступить.",
		"Для начала, убедись что ты полностью подготовлен(а). Там есть несколько <b><VP>рецептов</VP></b>, разброссаные по <b><VP>полкам с оружием</VP></b> и в <b><VP>мрачных лесах вниз по холму</VP></b>\nНадеюсь, ты хорошо их используешь!",
		"Вернись ко мне когда будешь готов(а)!",
		"Ты готов(а) принять вызов?",
		"Прекрасно! Начни тренировку в зоне тренировок. Тебе надо <b><VP>победить 25 монстров</VP></b> чтобы пройти испытание.",
		"Можешь брать сколько времени хочешь\nУдачи тебе!!!",
		"Ты доказал(а) что стоишь чего-то! Быстро!!! Присоединяйся к солдатам и иди сражаться с монстрами!"
	},
	EDRIC_QUESTIONS = {
		"Мне нужно больше времени...",
		"Я готов(а)!"
	},
	GARRY_DIALOGUES = {
		"Это худшее где я когда-либо находился. <b><VP>Носферату</VP></b> даже не платит достаточно. <i>*вздох...*</i>"
	},
	THOMPSON_DIALOGUES = {
		"Привет! Тебе что-то от меня нужно?",
		"Если ты ищешь <b><VP>лопату</VP></b>, одна должна быть в <b><VP>правом конце от меня</VP></b>.\nУдачи!",
		"Хорошого дня!"
	},
	THOMPSON_QUESTIONS = {
		"Какие-то рецепты?",
		"Просто поздоровался(ась).",
	},
	COLE_DIALOGUES = {
		"Тут куча <b><VP>монстров</VP></b> вокруг. Будь осторожен(на)!",
		"Вся наша армия дерётся с монстрами. Нам нужно много помощи.",
		"ААААА! Я не могу дать такому слабаку пройти туда. ВЕРНИСЬ СЮДА!"
	},
	MARC_DIALOGUES = {
		"ПЛОХОЙ(АЯ)! Не трогай мою рабочую скамью!"
	},
	SARUMAN_DIALOGUES = {
		"АУУУ!!!! АААУУУУУУ!!!!\nЗДЕСЬ КТО-НИБУДЬ ЕСТЬ???",
		"ЭЙЙ!! ПОМОГИТЕ МНЕ!\nХОРОШО ЧТО КТО-ТО ЗДЕСЬ ПРИШЁЛ СПАСАТЬ!!!",
		"Я <b><VP>Саруман</VP></b>, кстати. Я застрял здесь уже...\n15 лет?",
		"Мой дружок <b><VP>Хути</VP></b> - причина по которой я ещё дышу.\nБез него, я бы умер от голода",
		"Так ты хочешь знать как я попал тут?",
		"Ну, коротко, когда я был ещё <b>молодым</b> и сильным как ты,\nя слышал об этих сокровищах под названием <b><VP>сферы  душ</VP></b>",
		"Я был профессором и интересовался этой темой.\nЯ собрал кучу знаний о них",
		"Эти сферы привязаны к душе какого-то человека. Когда человек связан со всеми <b><VP>5 сферами</VP></b>, он(а) обретает <b><VP>божественную силу</VP></b>",
		"Я не уверен, какую силу смог бы получить от них или что бы они мне дали...\nНо я уверен, <b><VP>монахи</VP></b> знают больше о том, как их использовать!",
		"Никто не знал где они находятся, так что я пришёл найти их сам.",
		"Я справился в поисках одного из <VP><b>сфер алтаря</b></VP>.\nНо... я выбрал неправильный путь и остался в заточении здесь, навсегда.",
		"Я рад что ты меня нашёл(ла)! Можешь спрашивать что хочешь про сферы.\nЗнаниями нужно делиться, а ты ещё спас(ла) меня!",
		"Да, дружок! Что тебе нужно от меня?",
		"Как я говорил, есть <b><VP>5 сфер душ</VP></b>\n<b><VP>3</VP></b> из них можно найти в <b><VP>алтарях</VP></b> в этом мрачном лесу.\nЯ не уверен насчёт других 2...",
		"По моим расчётам, ты столкнёшься с многочисленными преградами по пути в алтари.",
		"Я думаю ты знаешь один уже, только если ты не очутился(лась) здесь магическим образом",
		"Второй алтарь защищён <b><VP>многими монстрами</VP></b> по пути.\nПодготовься перед тем как идти туда!",
		"А для последнего алтаря, я нашёл эту <b><VP>зацепку</VP></b> из древних книг",
		"<b><VP>\"Головоломки, и загадки, и старое умение\nМатематический скор, но не сложение\nРесурс что так жизненно нёс\nМирится с чьим-то знанием \nБери всем показанный ранк\nИ к миру ты должен призвать\"</VP></b>",
		"Это всё! Надеюсь ты используешь эти знания с умом",
		"Спасибо что навестил(а) меня!",
		"ПОХОЖЕ, ТЫ ДОСТАЛ(А) ВСЕ СФЕРЫ ДУШ!!!\nТеперь мы в расчёте... потом поблагодаришь!\nУзнай больше информации об этих сферах у <b><VP>монаха</VP></b>"
	},
	SARUMAN_QUESTIONS = {
		"Где шары?",
		"Просто проверял(а)!"
	},
	MONK_DIALOGUES = {
		"Я держал эту злую силу в узде долгое время...\nРад что ты примкнул(а) нам на помощь",
		"Так у тебя есть все <b><VP>5 сфер душ</VP></b>",
		"Хорошо сделано. Это поможет тебе свергнуть злую силу навеки",
		"Эти сферы действительно привязаны к душе\nТолько храбрые люди могут обуздать все 5",
		"Эти сферы помогут тебе получить <b><VP>божественную силу</VP></b> - единственный способ одолеть зло\n, насколько мне известно",
		"Когда ты активируешь божественную силу и одолеешь зло...\nтебе придётся пройти долгий путь в разуме чтобы достичь <b><VP>божественного статуса</VP></b>",
		"Шары душ помогут тебе найти путь.\nТебе лишь придётся пройти правильный путь, когда наступит время!",
		"Я почти уверен, что тебе не удастся достичь высшей силы.\nНо если ты хотя бы приблизишься...",
		"Оно создаст волну энергии, которая призовёт <b><VP>богиню</VP></b>",
		"Древние книги говорят что бестия слишком сильна, но я уверен что \n<b><VP>благословение богини</VP></b> ослабит её",
		"И тогда, мы сможем свергнуть зло навсегда!!!",
		"Богиня... она пришла\nЭТО ПРОИСХОДИТ!!!"
	},
	NIELS_DIALOGUES = {
		"Вы все, будьте на чеку!",
		"<b><VP>Дракон</VP></b>, что на другом берегу, слишком опасный.\nОн использует свой <b><VP>огненный удар</VP></b> и <b><VP>кинет камни</VP></b> в тебя",
		"Будь осторожен...",
		"Мы не можем атаковать дракона прямо, так как мост сломан",
		"Дракон разрушил его своим пламенем, когда пытался пересечь его.",
		"Так что... нам придётся его починить чтобы достать дракона. Торопись!!!"
	},
	PROPS = {
		attack = "Атака",
		defense = "Оборона",
		durability = "Длительность",
		chopping = "Рубление",
		mining = "Раскопки"
	}
}
-- theme color pallete: https://www.colourpod.com/post/173929539115/a-medieval-recipe-for-murder-submitted-by

translations["hu"] = {
	OUT_OF_RESOURCES = "<font color='#ab5e42'>[</font> <font color='#c6b392'>•</font> <font color='#ab5e42'>]</font> <font color='#c6b392' face='Lucida Console'>Kifogyott a nyersanyag!</font>",
	NEW_RECIPE = "<font color='#506d3d' size='8'><b>[ÚJ RECEPT]</b></font> <font color='#ab5e42' face='Lucida Console'><b>${itemName}</b></font>\n<font color='#bd9d60' size='11' face='Lucida Console'>(${itemDesc})</font>",
	NEW_QUEST = "<font color='#506d3d' size='8'><b>[ÚJ KÜLDETÉS]</b></font> <font color='#ab5e42' face='Lucida Console'><b>${questName}</b></font>",
	NEW_STAGE = "<font color='#506d3d' size='8'><b>[HALADÁS]</b></font> <font color='#ab5e42' face='Lucida Console'><b>${questName}</b></font>\n<font color='#bd9d60' size='11' face='Lucida Console'>(${desc})</font>",
	STAGE_PROGRESS = "<font color='#506d3d' size='8'><b>[HALADÁS]</b></font> <font color='#ab5e42' face='Lucida Console'><b>${questName}</b></font> <font color='#bd9d60' size='11' face='Lucida Console'>( ${progress} / ${needed} )</font>",
	QUEST_OVER = "<font color='#506d3d' size='8'><b>[TELJESÍTVE]</b></font> <font color='#ab5e42' face='Lucida Console'><b>${questName}</b></font>",
	SPIRIT_ORB = "<b><font color='#ab5e42' face='Lucida Console'>Szereztél egy <font color='#bd9d60' face='Lucida Console'>lélekgömböt!</font></font></b>",
	PASSCODE = "Írd be a bejutáshoz szükséges kulcsot.",
	WRONG_GUESS = "<R>Helytelen kulcs.</R>",
	INVENTORY_INFO = "<font face='Lucida Console'><p align='center'><font color='#${color}' size='9'>Súly: ${weight}</font>\n\n\n\n<font size='9'><N2><b>[X] Eldobás</b></N2></font></p></font>",
	FULL_INVENTORY = "<font color='#ab5e42'>[</font> <font color='#c6b392'>•</font> <font color='#ab5e42'>]</font> <font color='#c6b392' face='Lucida Console'>A raktárad megtelt!</font>",
	PORTAL_ENTER_FAIL = "<font color='#ab5e42'>[</font> <font color='#c6b392'>•</font> <font color='#ab5e42'>]</font> <font color='#c6b392' face='Lucida Console'>Ez az átjáró most nem elérhető számodra.</font>",
	CRAFT = "Barkácsolás!",
	CANT_CRAFT = "Nem barkácsolható",
	QUESTS = "<font size='15' face='Lucida console'><b><BV>Küldetések</BV></b></font>\n\n",
	RECIPE_DESC = "\n\n<font face='Lucida console' size='12' color='#999999'><i>“ ${desc} ”</i></font>",
	FINAL_BATTLE_PING = "<font color='#ab5e42'>[</font> <font color='#c6b392'>•</font> <font color='#ab5e42'>]</font> <font color='#c6b392' face='Lucida Console'>Kezdődik a végső csata!</font>",
	ACTIVATE_POWER = "<font color='#ab5e42'>[</font> <font color='#c6b392'>•</font> <font color='#ab5e42'>]</font> <font color='#c6b392' face='Lucida Console'>Nyomd meg az <font color='#ab5e42'><b>U</b></font> billentyűt, hogy aktiváld az <font color='#ab5e42'><b>Isteni erőt!</b></font></font>",
	ENDING_MESSAGE = "<font color='#cccccc'><font color='#bd9d60'><b>Gratulálok</b></font>, teljesítetted a kalandot!<br><br>Köszönet a következőknek: <font color='#bd9d60'>King_seniru</font><font size='8' color='#ab5e42'>#5890</font>, <font color='#bd9d60'>Hattington</font><font size='8' color='#ab5e42'>#2583</font>, <font color='#bd9d60'>Vividia</font><font size='8' color='#ab5e42'>#0095</font>, <font color='#bd9d60'>Chibi</font><font size='8' color='#ab5e42'>#0095</font>, <font color='#bd9d60'>Karasu</font><font size='8' color='#ab5e42'>#0010</font>, <font color='#bd9d60'>Zetdey</font><font size='8' color='#ab5e42'>#3845</font>, <font color='#bd9d60'>Eremia</font><font size='8' color='#ab5e42'>#0020</font>, <font color='#bd9d60'>Kaland csapat</font> és <font color='#bd9d60'>neked</font>, hogy létrehoztátok ezt az eventet!\n\n</font><i><font color='#548336'>De ne hagyd abba... még sok mindent felfedezhetsz! Jó felfedezést!!!</font></i>",
	PLAYER_DATA_FAIL_SAFEBACK = "<font color='#ab5e42'>[</font> <font color='#c6b392'>•</font> <font color='#ab5e42'>]</font> <font color='#c6b392' face='Lucida Console'>Az adataid nem megfelelően töltöttek be. Ezért az adataidat nem fogjuk elmenteni. Válts szobát, vagy lépj ki és be, vagy írj King_seniru#5890-nak, ha a probléma továbbra is fennáll.</font>",
	ANNOUNCER_DIALOGUES = {
		"FIGYELEM MINDENKI! FIGYELEM!!!",
		"Ez az üzenet a felségtől jött, eme föld nagyszerű Királyától...",
		"A földünket megtámadták a kegyetlen szörnyetegek, akiket már egyszer legyőztünk.",
		"Ezt követően pedig egy hatalmas baj történt. <b><VP>A hercegnőnket elrabolták.</VP></b>",
		"A kegyetlen szörnyek az összes kincseinket is ellopták, amink csak volt.",
		"A Király BÁTOR KALANDOROKAT keres, akik legyőzik az összes szörnyet, és megmentik a hercegnőt\na kincseinkkel együtt",
		"A Király számít minden bátor szívre...\n"
	},
	NOSFERATU_DIALOGUES = {
		"Ahh biztos új vagy itt... de hasznosnak tűnsz.",
		"Szóval, azt mondod, hogy egy másik dimenzióból jöttél, nem tudod hol vagy és mihez kezdj?\n<i>*Hmmm talán tényleg hasznos lesz számomra.</i>",
		"Nos fiatal barátom, úgy tűnik kellene neked egy munka. Ne aggódj, adok neked munkát persze, persze.",
		"De... előtte meg kell néznem, hogy mennyire vagy jó fizikai állapotban.\nGyűjts <VP><b>15 fát</b></VP> az erdőből.\nAdok <VP><b>20 követ</b></VP> előleg gyanánt. Sok sikert!",
		"Lenyűgöző. De <i>régebben</i> mi azért gyorsabbak voltunk...\nBár már nem számít. Ahogy ígértem, adok neked <VP><b>munkát</b></VP>.",
		"Most már bemehetsz a <b><VP>bányába</VP></b>.\nMenj át az <b><VP>átjárón</VP></b>, amit jobbra találsz, és nyomj <b><VP>↓</VP></b> nyilat, hogy belépj!",
		"Első feladatként pedig, gyűjts <b><VP> 15 vasércet</VP></b>. Sok sikert ismét!",
		"Woah! Alulbecsültelek téged, nagyon szép munka!",
		"Úgy hallottam, hogy a <b><VP>kastélynak</VP></b> szüksége van hozzád hasonló egerekre, hogy megmentsék a kincseket és a hercegnőt...",
		"Biztos menne neked!",
		"Adok egy <b><VP>levelet ajánlásként</VP></b>, mutasd meg a <b><VP>Hadnagynak</VP></b>, és remélhetőleg felvesz a seregbe.\n<i>ééééés ez jól fizet is.</i>",
		"Oh és ne felejtsd itt a <b><VP>30 követ</VP></b> díjként a nehéz munkáért!",
		"Szükséged van valamire?",
		"Ez elég egyértelmű dolog... A <b><VP>fákat baltával kell kivágni</VP></b>",
		"Szóval <b><VP>csákány</VP></b> kell neked? Kell lennie egynek az <b><VP>erdőben</VP></b>.\n<b><VP>↓</VP></b>, hogy tanulmányozd a receptet, és barkácsold össze a <b><VP>barkácsasztalnál</VP></b>.\nVan egy asztal épp a bánya felett.",
		"<b><VP>10 követ</VP></b> árulok <b><VP>35 botért</VP></b>",
		"Ah rendben, viszlát akkor",
		"Tele van a raktárad. Ürítsd ki, és gyere vissza a nyereményért.",
		"Örültem az üzletnek!",
		"Nincs elég anyagod, hogy cseréljek veled ifjú barátom."
	},
	NOSFERATU_QUESTIONS = {
		"Hogy szerzek fát?",
		"Csákány?",
		"Csere",
		"Mindegy.",
		"Valami más."
	},
	EDRIC_DIALOGUES = {
		"A hercegnő... és a kincsek, mind a gonosz kezében. Sietnünk kell.",
		"Várj csak. Szóval <b><VP>Nosferatu</VP></b> küldött, hogy segíts a seregnek és a küldetésben???",
		"Nagyszerű. De a seregnél dolgozni nem olyan egyszerű, mint hinnéd.\nMuszáj lesz egy nagyon <b><VP>intenzív edzésen</VP></b> részt venned, mivel a tested nem elég jó fizikumú.\nMenj a <b><VP>bal oldalon található gyakorló szobába</VP></b>, hogy elkezdd az edzést.",
		"De előtte, szerelkezz fel jól. Van néhány <b><VP>recept</VP></b> eldobálva a <b><VP>fegyverraktárnál</VP></b> és a <b><VP>sötét erdőben is a domb aljában.</VP></b>\nRemélem jól fognak jönni!",
		"Beszélj velem újra, ha úgy gondolod, hogy készenállsz!",
		"Készen állsz a kihívásra?",
		"Remek! Menj és kezdd el az edzést a gyakorló szobában. Ölj meg <b><VP>25 szörnyet</VP></b>, hogy teljesítsd a kihívást.",
		"Annyi időt szánhatsz rá, amennyit csak akarsz\nSok sikert neked!!!",
		"Tehát még is elég jó vagy! Siess!!! Csatlakozz a többiekhez, és küzdj meg a szörnyekkel!"
	},
	EDRIC_QUESTIONS = {
		"Több idő kell...",
		"Készen állok!"
	},
	GARRY_DIALOGUES = {
		"Ez a legrosszabb hely, ahol valaha dolgoztam. <b><VP>Nosferatu</VP></b> nem is fizet eleget. <i>*sóhaj...*</i>"
	},
	THOMPSON_DIALOGUES = {
		"Helló! Segíthetek valamiben?",
		"Ha <b><VP>ásót</VP></b> keresnél, kell lennie egynek a <b><VP>bánya jobb szélén</VP></b>.\nSok sikert!",
		"Szép napot!"
	},
	THOMPSON_QUESTIONS = {
		"Van nálad recept?",
		"Csak köszönni jöttem."
	},
	COLE_DIALOGUES = {
		"Sok <b><VP>szörny</VP></b> leselkedik odakint. Vigyázz magadra!",
		"A sereg összes katonája a szörnyek ellen harcol. Szükségünk van rád.",
		"OIIIIII! NEM ENGEDHETEM MEG EGY ILYEN GYENGE LÉLEKNEK, HOGY ELVÁNDOROLJON. GYERE VISSZA!"
	},
	MARC_DIALOGUES = {
		"ROSSZ TE! Megérinteni a barkácsasztalom NEM szabad!"
	},
	SARUMAN_DIALOGUES = {
		"EYYYYY!!!! EYYYYYYYYY!!!!\nVAN OTT VALAKI???",
		"HÉ!!! SEGÍTS NEKEM!\nHÁLA ISTENNEK VALAKI MEGMENT VÉGRE!!!",
		"<b><VP>Saruman</VP></b> vagyok. Itt ragadtam, és itt vagyok már körülbelül...\n15 éve?",
		"<b><VP>Hootie</VP></b>, a barátom tehet róla, hogy még élek.\nÉhen halnék, ha ő nem lenne.",
		"Akarod tudni, hogy miért vagyok ide bezárva?",
		"Röviden annyi, hogy amikor még <b>fiatal</b> és erős voltam, mint te,\nhallottam kincsekről, amiknek a nevük <b><VP>lélekgömbök</VP></b>.",
		"Egy professzor voltam, így természetesen nagyon érdekeltek ezek a dolgok.\nSok információt is találtam róluk.",
		"A gömbök egy személy lelkéhez kötődnek. Ha mind az <b><VP>5 gömböt</VP></b> összekötjük, akkor elszabadulhat egy <b><VP>Isteni erő</VP></b>.",
		"Nem tudom, hogy rám milyen hatásuk lenne, vagy milyen erős lennék utána...\nDe biztos, hogy a <b><VP>szerzetesek</VP></b> többet tudnának mondani róla!",
		"Senki sem tudja, hol lehet őket megtalálni, így eljöttem egyedül megkeresni őket.",
		"Egész jó munkát végeztem, mert találtam egy <VP><b>fénylő gömböt</b></VP>.\nDe... rossz utat választottam, és azóta itt vagyok.",
		"Örülök, hogy segítettél! Nyugodtan beszélj velem, ha kell valami információ a gömbökről.\nA tudást meg kell osztani, és te megmentettél!",
		"Igen, barátom. Mit szeretnél tudni?",
		"Ahogy mondtam, <b><VP>5 lélekgömb</VP></b> létezik.\n<b><VP>3</VP></b>-at könnyedén a <b><VP>szentélyeknél</VP></b> lehet megtalálni, a sötét erdőben.\nA másik kettő hollétéről nem tudok...",
		"Az összegyűjtött információim alapján sok kihívást kell teljesítened, hogy eljuss a szentélyekhez.",
		"Szerintem már tudhatsz is egyről, hacsak nem volt valami varázserőd, hogy odateleportálj.",
		"A második szentélyt <b><VP>szörnyek</VP></b> óvják.\nSzerelkezz fel, mielőtt odamennél!",
		"És az utolsó szentélyhez ezt a <b><VP>segítséget</VP></b> találtam régi könyvekből.",
		"<b><VP>\"Rejtvények, kirakók, ősi hagyomány\nMatematikai művelet, de nem összeadás",
		"Ennyi! Remélem jól fog jönni az információ!",
		"Köszi, hogy benéztél, barátom!",
		"OH SZÓVAL MEGVAN AZ ÖSSZES LÉLEKGÖMB!!!\nKvittek vagyunk... megköszönheted később!\nDe a használat előtt informálódj róluk egy <b><VP>szerzetesnél</VP></b>.",
		"<b><VP>\"Egy erőforrás, amely gyümölcsözni vélik\nEgyetlen személy történetét meséli\"</VP></b>",
		"<b><VP>\"Fogd a rangot, mutasd mindenkinek\nAdd a szóhoz, amit írnod kell\"</VP></b>"
	},
	SARUMAN_QUESTIONS = {
		"Hol vannak a gömbök?",
		"Csak megnéztem, hogy vagy!"
	},
	MONK_DIALOGUES = {
		"Már egy ideje én tartom vissza ezt a gonosz erőt...\nÖrülök, hogy jöttél segíteni",
		"Szóval, megvan neked az összes <b><VP>lélekgömb</VP></b>?",
		"Szép munka, valóban. Így könnyebb lesz legyőzni ezt a gonosz erőt örökké!",
		"Ezek a lélekgömbök egyetlen egy személy lelkéhez kötődnek\nCsak bátor egereké lehet mind az 5 egyszerre.",
		"Ezek a gömbök segítenek előhívni az <b><VP>Isteni erőt</VP></b>, amely elpusztítja a gonosz erőt,\n ezt tudom róla.",
		"Ha aktiváltad az Isteni erőt, és csatára hívtad a gonoszt...\nAz elmédben elég sokat kell utaznod, hogy elérd az <b><VP>Isteni státuszt</VP></b>.",
		"A lélekgömbök segítenek, hogy elérd ezt.\nCsak jó időben kell utaznod, és tiéd lehet a hatalom!",
		"Biztos vagyok benne, hogy nem fog sikerülni elérni ezt.\nDe ha csak a közelébe érsz..",
		"Egy hatalmas fennséges energiát fog felszabadítani, amely megidézi az <b><VP>Istennőt</VP></b>.",
		"Ősi könyvek szerint a szörny annyira erős, hogy csak az \n<b><VP>Istennő áldása</VP></b> tudja helyre tenni őt.",
		"És most itt a mi időnk, hogy elpusztítsuk végleg!!!",
		"Az Istennő... itt van!\nMEGTÖRTÉNIK!!!"
	},
	NIELS_DIALOGUES = {
		"Mindenki tartsa be a pozíciót!",
		"A <b><VP>sárkány</VP></b> a tó túloldalán túl veszélyes.\nHasználni fogja a <b><VP>tűzlehelletét</VP></b> és <b><VP>köveket dobál</VP></b> rád.",
		"Kérlek légy óvatos...",
		"De közvetlenül nem sebesíthetjük meg a sárkányt, mert túl gyenge a híd.",
		"A sárkány tönkretette újra, amikor át akart kelni.",
		"Szóval... meg kell újra javítanunk. Siess!!!"
	},
	PROPS = {
		attack = "Támadás",
		defense = "Védelem",
		durability = "Tartósság",
		chopping = "Vágás",
		mining = "Bányászás"
	}
}

translate = function(term, lang, page, kwargs)
	local translation
	if translations[lang] then
		translation = translations[lang][term] or translations.en[term]
	else
		translation = translations.en[term]
	end
	translation = page and translation[page] or translation
	if not translation then return end
	return stringutils.format(translation, kwargs)
end


--==[[ classes ]]==--

local Monster = {}
Monster.monsters = {}

Monster.__index = Monster
Monster.__tostring = function(self)
	return table.tostring(self)
end
Monster.__type = "monster"

setmetatable(Monster, {
	__call = function (cls, ...)
		return cls.new(...)
	end,
})

function Monster.new(metadata, spawnPoint)
	local self = setmetatable({}, Monster)
	local id = #Monster.monsters + 1
	self.id = id
	self.spawnPoint = spawnPoint
	self.x = spawnPoint.x
	self.y = spawnPoint.y
	self.area = spawnPoint.area
	self.species = metadata.species
	self.health = metadata.health or metadata.species.health
	self.metadata = metadata
	self.stance = -1 -- left
	self.isAlive = true
	self.decisionMakeCooldown = os.time()
	self.latestActionCooldown = os.time()
	self.latestActionReceived = os.time()
	self.lastAction = "move"
	self.species.spawn(self)
	Monster.monsters[id] = self
	spawnPoint.monsters[id] = self
	spawnPoint.monsterCount = spawnPoint.monsterCount + 1
	self.area.monsters[id] = self
	return self
end

function Monster:action()
	if not self.isAlive then return end
	if self.latestActionCooldown > os.time() then return end
	local obj = (self.species == Monster.all.fiery_dragon or self.species == Monster.all.final_boss) and { x = self.x, y = self.y } or  tfm.get.room.objectList[self.objId]
	if not obj then return end
	self.x, self.y = obj.x, obj.y
	-- monsters are not fast enough to calculate new actions, in other words dumb
	-- if somebody couldn't get past these monsters, I call them noob
	if self.decisionMakeCooldown > os.time() then
		self:changeStance(self.stance)
		if self.lastAction == "move" then
			-- keep moving to the same direction till the monster realized he did a bad move
			--tfm.exec.moveObject(self.objId, 0, 0, true, self.stance * 20, -20, false, 0, true)
			self:move()

		end
	else
		-- calculate the best move
		local lDists, lPlayers, lScore, rDists, rPlayers, rScore = {}, {}, 0, {}, {}, 0
		for name in next, self.area.players do
			local player = tfm.get.room.playerList[name]
			local dist = math.pythag(self.realX or self.x, self.y, player.x, player.y)
			if dist <= (self.visibilityRange or 300) then
				if player.x < self.x  then -- player is to left
					lDists[#lDists + 1] = dist
					lPlayers[dist] = name
					lScore = lScore + (self.visibilityRange or 300) + 10 - dist
				else
					rDists[#rDists + 1] = dist
					rPlayers[dist] = name
					rScore = rScore + (self.visibilityRange or 300) + 10 - dist
				end
			end
		end
		table.sort(lDists)
		table.sort(rDists)
		if self.stance == -1 then -- left side
			local normalScore = lScore / math.max(#lDists, 1)
			if lDists[1] and lDists[1] < 60 then
				self:attack(lPlayers[lDists[1]], "primary")
			elseif rDists[1] and rDists[1] < 60 then
				-- if there are players to right, turn right and attack
				self:changeStance(1)
				self:attack(rPlayers[rDists[1]], "primary")
			elseif normalScore > (self.visibilityRange or 300) - 200 then
				self:move()
			elseif normalScore > 10 then
				self:attack(lPlayers[lDists[math.random(#lDists)]], "secondary")
			elseif lScore > rScore then
				self:move()
			else
				-- turn to right side and move
				self:changeStance(1)
				self:move()
			end
		else --right side
			local normalScore = rScore / math.max(#rDists, 1)
			if rDists[1] and rDists[1] < 60 then
				self:attack(rPlayers[rDists[1]], "primary")
			elseif lDists[1] and lDists[1] < 60 then
				-- if there are players to left, turn left and attack
				self:changeStance(-1)
				self:attack(lPlayers[lDists[1]], "primary")
			elseif normalScore > (self.visibilityRange or 300) - 200 then
				self:move()
			elseif normalScore > 10 then
				self:attack(rPlayers[rDists[math.random(#rDists)]], "secondary")
			elseif lScore < rScore then
				self:move()
			else
				-- turn left and move
				self:changeStance(-1)
				self:move()
			end
		end
		self.decisionMakeCooldown = os.time() + 1500
	end
	self.latestActionCooldown = os.time() + 1000
end

function Monster:changeStance(stance)
	local isBoss = self.species == Monster.all.fiery_dragon or self.species == Monster.all.final_boss
	self.stance = stance
	tfm.exec.removeImage(self.imageId)
	if not isBoss then
		local imageData = self.species.sprites[stance == -1 and "idle_left" or "idle_right"]
		self.imageId = tfm.exec.addImage(imageData.id, "#" .. self.objId, imageData.xAdj, imageData.yAdj, nil)
	elseif self.species == Monster.all.final_boss then
		local imageData = self.species.sprites[stance == -1 and "idle_left" or "idle_right"]
		self.imageId = tfm.exec.addImage(imageData.id, "+" .. self.objId, imageData.xAdj, imageData.yAdj, nil)
	end
end

function Monster:attack(player, attackType)
	if not self.isAlive then return end
	local isBoss = self.species == Monster.all.fiery_dragon or self.species == Monster.all.final_boss
	local playerObj = Player.players[player]
	self.lastAction = "attack"
	self.species.attacks[attackType](self, playerObj)
	if not isBoss then
		tfm.exec.removeImage(self.imageId)
		local imageData = self.species.sprites[attackType .. "_attack_" .. (self.stance == -1 and "left" or "right")]
		self.imageId = tfm.exec.addImage(imageData.id, "#" .. self.objId, imageData.xAdj, imageData.yAdj, nil)
	end
	if attackType == "primary" then displayDamage(playerObj) end
	if playerObj.health < health(0) then
		playerObj:destroy()
	end
end

function Monster:move()
	self.species.move(self)
	self.lastAction = "move"
end

function Monster:regen()
	local healthCurr, healthOriginal = self.health, self.metadata.health
	if healthCurr < healthOriginal then
		local regenAmount = math.floor(os.time() - self.latestActionReceived) / 6000
		self.health = math.min(healthOriginal, healthCurr + regenAmount)
	end
end

function Monster:destroy(destroyedBy)
	if destroyedBy then
		local qProgress = destroyedBy.questProgress
		if destroyedBy.area == 2 and qProgress.strength_test and qProgress.strength_test.stage == 2 then
			destroyedBy:updateQuestProgress("strength_test", 1)
		end
		destroyedBy.kills = destroyedBy.kills + 1
		if destroyedBy.kills % 5 == 0 then
			giveReward(destroyedBy.name, 1)
		else
			giveReward(destroyedBy.name, 0)
		end
	end
	if self.species.death then self.species.death(self, destroyedBy) end
	self.isAlive = false
	local isBoss = self.species == Monster.all.fiery_dragon or self.species == Monster.all.final_boss
	if not isBoss then
		tfm.exec.removeImage(self.imageId)
		local imageData = self.species.sprites["dead_" .. (self.stance == -1 and "left" or "right")]
		self.imageId = tfm.exec.addImage(imageData.id, "#" .. self.objId, imageData.xAdj, imageData.yAdj, nil)
	end

	Timer.new("clear_body_" .. self.id, function(image, objId)
		tfm.exec.removeImage(image, true)
		Timer.new("removeObject" .. objId, tfm.exec.removeObject, 500, false, objId)
	end, 2000, false, self.imageId, self.objId)

	Monster.monsters[self.id] = nil
	self.area.monsters[self.id] = nil
	-- 	TODO: remove the dead monsters in the coming iteration
	--self.spawnPoint.monsters[self.id] = nil
	self.spawnPoint.monsterCount = self.spawnPoint.monsterCount - 1
	self = nil
end


Monster.all = {
	mutant_rat = {},
	the_rock = {},
	snail = {},
	fiery_dragon = {},
	final_boss = {}
}

do
	local monsters = Monster.all

	monsters.mutant_rat.sprites = {
		idle_left = {
			id = "18012c3631a.png",
			xAdj = -30,
			yAdj = -30,
		},
		idle_right = {
			id = "18012d4d75e.png",
			xAdj = -30,
			yAdj = -30,
		},
		primary_attack_left = {
			id = "180192208f0.png",
			xAdj = -30,
			yAdj = -43,
		},
		primary_attack_right = {
			id = "18019222e6a.png",
			xAdj = -45,
			yAdj = -43
		},
		secondary_attack_left = {
			id = "180192b8289.png",
			xAdj = -30,
			yAdj = -35
		},
		secondary_attack_right = {
			id = "180192ba692.png",
			xAdj = -45,
			yAdj = -35
		},
		dead_left = {
			id = "180193395b8.png",
			xAdj = -35,
			yAdj = -18
		},
		dead_right = {
			id = "1801933c6e6.png",
			xAdj = -40,
			yAdj = -18
		}
	}

	monsters.mutant_rat.spawn = function(self)
		self.objId = tfm.exec.addShamanObject(10, self.x, self.y)
		local imageData = self.species.sprites.idle_left
		self.imageId = tfm.exec.addImage(imageData.id, "#" .. self.objId, imageData.xAdj, imageData.yAdj, nil)
		tfm.exec.moveObject(self.objId, 0, 0, true, -20, -20, false, 0, true)
	end
	monsters.mutant_rat.move = function(self)
		tfm.exec.moveObject(self.objId, 0, 0, true, self.stance * 20, -20, false, 0, true)
		if self.lastAction ~= "move" then
			tfm.exec.removeImage(self.imageId)
			local imageData = self.species.sprites[self.stance == -1 and "idle_left" or "idle_right"]
			self.imageId = tfm.exec.addImage(imageData.id, "#" .. self.objId, imageData.xAdj, imageData.yAdj, nil)
		end
	end
	monsters.mutant_rat.attacks = {
		primary = function(self, target)
			target.health = target.health - 3
		end,
		secondary = function(self, target)
			local id = #projectiles + 1
			local projectile = tfm.exec.addPhysicObject(12000 + id, self.x, self.y - 5, {
				type = 2,
				width = 10,
				height = 10,
				friction = 2,
				contactListener = true,
				dynamic = true,
				groundCollision = false
			})
			local player = tfm.get.room.playerList[target.name]
			local vx, vy = getVelocity(player.x, self.x, player.y, self.y - 5, 3)
			tfm.exec.movePhysicObject(12000 + id, 0, 0, false, vx, -vy)
			local imgId = tfm.exec.addImage(assets.stone, "+" .. (12000 + id), -5, -5)
			projectiles[id] = { 1, false }
			Timer.new("projectile_" .. id, tfm.exec.removePhysicObject, 3000, false, 1200 + id)
		end
	}

	monsters.the_rock.sprites = {
		idle_left = {
			id = "180989fbe7d.png",
			xAdj = -27,
			yAdj = -20,
		},
		idle_right = {
			id = "18098a542e3.png",
			xAdj = -27,
			yAdj = -20,
		},
		primary_attack_left = {
			id = "18098ad201c.png",
			xAdj = -36,
			yAdj = -18,
		},
		primary_attack_right = {
			id = "18098ae95b3.png",
			xAdj = -33,
			yAdj = -18
		},
		secondary_attack_left = {
			id = "180989fbe7d.png",
			xAdj = -27,
			yAdj = -20,
		},
		secondary_attack_right = {
			id = "18098a542e3.png",
			xAdj = -27,
			yAdj = -20,
		},
		dead_left = {
			id = "180ec2c3204.png",
			xAdj = -27,
			yAdj = -20,
		},
		dead_right = {
			id = "180ec2d589a.png",
			xAdj = -27,
			yAdj = -20,
		}
	}
	monsters.the_rock.spawn = function(self)
		self.objId = tfm.exec.addShamanObject(10, self.x, self.y)
		local imageData = self.species.sprites.idle_left
		self.imageId = tfm.exec.addImage(imageData.id, "#" .. self.objId, imageData.xAdj, imageData.yAdj, nil)
		tfm.exec.moveObject(self.objId, 0, 0, true, -20, -20, false, 0, true)
	end
	monsters.the_rock.move = function(self)
		tfm.exec.moveObject(self.objId, 0, 0, true, self.stance * 20, -20, false, 0, true)
		if self.lastAction ~= "move" then
			tfm.exec.removeImage(self.imageId)
			local imageData = self.species.sprites[self.stance == -1 and "idle_left" or "idle_right"]
			self.imageId = tfm.exec.addImage(imageData.id, "#" .. self.objId, imageData.xAdj, imageData.yAdj, nil)
		end
	end
	monsters.the_rock.attacks = {
		primary = function(self, target)
			target.health = target.health - 7
		end,
		secondary = function(self, target)
			self:changeStance(self.stance * -1)
			self:move()
		end
	}

	monsters.snail.sprites = {
		idle_left = {
			id = "1809debd5c6.png",
			xAdj = -28,
			yAdj = -20,
		},
		idle_right = {
			id = "1809dee97e2.png",
			xAdj = -30,
			yAdj = -20,
		},
		primary_attack_left = {
			id = "1809df1bc2e.png",
			xAdj = -28,
			yAdj = -20,
		},
		primary_attack_right = {
			id = "1809df30ef7.png",
			xAdj = -28,
			yAdj = -20
		},
		secondary_attack_left = {
			id = "1809df1bc2e.png",
			xAdj = -28,
			yAdj = -20,
		},
		secondary_attack_right = {
			id = "1809df30ef7.png",
			xAdj = -28,
			yAdj = -20
		},
		dead_left = {
			id = "180ec41d099.png",
			xAdj = -35,
			yAdj = -16
		},
		dead_right = {
			id = "180ec41ef3e.png",
			xAdj = -35,
			yAdj = -16
		}
	}
	monsters.snail.spawn = function(self)
		self.objId = tfm.exec.addShamanObject(10, self.x, self.y)
		local imageData = self.species.sprites.idle_left
		self.imageId = tfm.exec.addImage(imageData.id, "#" .. self.objId, imageData.xAdj, imageData.yAdj, nil)
		tfm.exec.moveObject(self.objId, 0, 0, true, -20, -20, false, 0, true)
	end
	monsters.snail.move = function(self)
		tfm.exec.moveObject(self.objId, 0, 0, true, self.stance * 20, -20, false, 0, true)
		if self.lastAction ~= "move" then
			tfm.exec.removeImage(self.imageId)
			local imageData = self.species.sprites[self.stance == -1 and "idle_left" or "idle_right"]
			self.imageId = tfm.exec.addImage(imageData.id, "#" .. self.objId, imageData.xAdj, imageData.yAdj, nil)
		end
	end

	local snailAttack = function(self, target)
		local id = #projectiles + 1
			local projectile = tfm.exec.addPhysicObject(12000 + id, self.x, self.y - 5, {
				type = 2,
				width = 30,
				height = 10,
				friction = 2,
				contactListener = true,
				dynamic = true,
				groundCollision = false,
				mass = 0.0002
			})
			local player = tfm.get.room.playerList[target.name]
			local vx, vy = 120 * self.stance, 20
			tfm.exec.movePhysicObject(12000 + id, 0, 0, false, vx, -vy)
			local imgId = tfm.exec.addImage(assets.spit, "+" .. (12000 + id), -15, -5)
			projectiles[id] = { 0, true, 1000, { assets.goo, "$" .. target.name, -15, -10 } }
			Timer.new("projectile_" .. id, tfm.exec.removePhysicObject, 1500, false, 1200 + id)
	end
	monsters.snail.attacks = {
		primary = snailAttack,
		secondary = snailAttack
	}



	monsters.fiery_dragon.sprites = {
		idle_left = {
			id = "1809dfcd636.png",
			xAdj = -200,
			yAdj = -110,
		},
		idle_right = {
			id = "1809dfcd636.png",
			xAdj = -200,
			yAdj = -110,
		},
		primary_attack_left = {
			id = "180a2a35e91.png",
			xAdj = -235,
			yAdj = -120,
		},
		primary_attack_right = {
			id = "180a2a35e91.png",
			xAdj = -235,
			yAdj = -120,
		},

		secondary_attack_left = {
			id = "180a34985f3.png",
			xAdj = -200,
			yAdj = -130,
		},
		secondary_attack_right = {
			id = "180a34985f3.png",
			xAdj = -200,
			yAdj = -130,
		},
		throw_animation = {
			id = "180a34763fa.png",
			xAdj = -205,
			yAdj = -120
		},
		dead_left = {
			id = "180ea8a13f4.png",
			xAdj = -180,
			yAdj = -120
		},
		dead_right = {
			id = "180ea8a13f4.png",
			xAdj = -180,
			yAdj = -120
		}
	}

	dragonLocationCheck = function(self)
		self.wait = self.wait - 1
		local dragX = self.realX
		if self.wait < 0 then
			dragX = math.min(self.realX, tfm.get.room.objectList[self.objId] and (tfm.get.room.objectList[self.objId].x - self.w) - 30 or self.realX)
			self.realX = dragX
			if dragX < 700 then
				return self:destroy()
			end
			tfm.exec.removeObject(self.objId)
			self.objId = tfm.exec.addShamanObject(62, self.realX + self.w + 120, self.y, 180, -50, 0, false)
			tfm.exec.addImage("no.png", "#" .. self.objId, 0, 0)
			self.wait = 8
		end
		local entityBridge
		for i, e in next, self.area.entities do
			if e.type == "bridge" then
				entityBridge = e
				break
			end
		end
		local toRemove = {}
		for i, bridge in next, (entityBridge.bridges or {}) do
			if math.abs(bridge[2] - (560 / 8) - dragX) - 80 < 85 and i > 2 then
				--tfm.exec.removePhysicObject(bridge[1])
				for _ = i, 4 do
					toRemove[#toRemove + 1] = i
				end
				--entityBridge.bridges[i] = nil
			end
		end
		for i, j in next, toRemove do
			if entityBridge.bridges[j] then
				tfm.exec.removePhysicObject(entityBridge.bridges[j][1])
				tfm.exec.removeImage(entityBridge.bridges[j][4])
				entityBridge.bridges[j] = nil
			end
		end
	end

	monsters.fiery_dragon.spawn = function(self)
		--TODO: do not spawn if has been spawmed already
		self.wait = 0
		self.visibilityRange = 3400
		self.objId = 999999
		self.bodyId = 200
		self.w = 150
		self.rockThrowId = 0
		--[[tfm.exec.addPhysicObject(self.bodyId, self.x, self.y - 80, {
			type = 1,
			width = self.w,
			height = 170,
			dynamic = true,
			friction = 30,
			mass = 9999,
			fixedRotation = true,
			linearDamping = 999
		})]]
		tfm.exec.movePhysicObject(self.bodyId, self.x, self.y - 80)
		self.y = self.y + 20
		self.realX = self.x - self.w
		local imageData = self.species.sprites.idle_left
		tfm.exec.addImage(imageData.id, "+" .. self.bodyId, imageData.xAdj, imageData.yAdj, nil)
		self.imageId = imageData
		dragon = self
	end
	monsters.fiery_dragon.move = function(self)
		dragonLocationCheck(self)
		tfm.exec.movePhysicObject(200, 0, 0, false, -25, -30)
		local imageData = self.species.sprites.idle_left
		if imageData ~= self.imageId then
			tfm.exec.addImage(imageData.id, "+" .. self.bodyId, imageData.xAdj, imageData.yAdj, nil)
		end
		self.imageId = imageData
	end
	monsters.fiery_dragon.attacks = {
		primary = function(self, target)
			--tfm.exec.removeImage(self.imageId)
			dragonLocationCheck(self)
			local imageData = self.species.sprites.primary_attack_left
			if imageData ~= self.imageId then
				tfm.exec.addImage(imageData.id, "+" .. self.bodyId, imageData.xAdj, imageData.yAdj, nil)
			end
			self.imageId = imageData
			self.latestActionCooldown = os.time() + 3000
			-- attack all the players nearby to the target
			local player = tfm.get.room.playerList[target.name]
			local x1, y1 = player.x, player.y
			for name in next, self.area.players do
				local playerOther = tfm.get.room.playerList[name]
				if math.pythag(x1, y1, playerOther.x, playerOther.y) <= 50 then
					local playerOtherObject = Player.players[name]
					playerOtherObject.health = playerOtherObject.health - 15
					displayDamage(playerOtherObject)
				end
			end
		end,
		secondary = function(self, target)
			dragonLocationCheck(self)
			local imageData = self.species.sprites.secondary_attack_left
			tfm.exec.addImage(imageData.id, "+" .. self.bodyId, imageData.xAdj, imageData.yAdj, nil)
			self.rockThrowId = self.rockThrowId + 1
			local id = #projectiles + 1--self.rockThrowId % 2
			local projectile = tfm.exec.addPhysicObject(12000 + id, self.realX - 15, self.y + 15, {
				type = 1,
				width = 30,
				height = 30,
				friction = 2,
				contactListener = true,
				dynamic = true,
				groundCollision = false
			})
			tfm.exec.addImage(assets.rock, "+" .. (12000 + id), -30, -35, nil)
			local player = tfm.get.room.playerList[target.name]
			tfm.exec.movePhysicObject(12000 + id, self.realX - 15, self.y + 15, false, 0, 0)
			tfm.exec.movePhysicObject(12000 + id, 0, 0, false, 0, -60)
			--local imgId = tfm.exec.addImage(assets.stone, "+" .. (12000 + id), -5, -5)
			Timer.new("projectile_" .. id, tfm.exec.removePhysicObject, 5000, false, 1200 + id)
			Timer.new("rock_throw", function()
				local imgData = self.species.sprites.throw_animation
				tfm.exec.addImage(imgData.id, "+" .. self.bodyId, imgData.xAdj, imgData.yAdj, nil)
				self.imageId = imgData
				local vx, vy = getVelocity(player.x, self.realX - 15, player.y, self.y - 15, 3)
				tfm.exec.movePhysicObject(12000 + id, 0, 0, false, 0, 0)
				tfm.exec.movePhysicObject(12000 + id, 0, 0, false, vx, -vy)
				projectiles[id] = { 10, true, 2500 }
			end, 1000, false, id)
			self.latestActionCooldown = os.time() + 5000
		end
	}
	monsters.fiery_dragon.death = function(self, killedBy)
		local imageData = self.species.sprites.dead_left
		local image = tfm.exec.addImage(imageData.id, "+" .. self.bodyId, imageData.xAdj, imageData.yAdj, nil)
		Timer.new("clear_body_drag", function(image, ground)
			tfm.exec.removeImage(image, true)
			--tfm.exec.removePhysicObject(ground)
			tfm.exec.movePhysicObject(ground, 1460, 4996)
		end, 2000, false, image, self.bodyId)
	end

	monsters.final_boss.sprites = {
		idle_left = {
			id = "180c7398a1f.png",
			xAdj = -280,
			yAdj = -150,
		},
		idle_right = {
			id = "180c7398a1f.png",
			xAdj = -280,
			yAdj = -150,
		},
		primary_attack_left = {
			id = "180c7386662.png",
			xAdj = -230,
			yAdj = -150,
		},
		primary_attack_right = {
			id = "180c7386662.png",
			xAdj = -230,
			yAdj = -150,
		},
		secondary_attack_left = {
			id = "180c739b495.png",
			xAdj = -230,
			yAdj = -150,
		},
		secondary_attack_right = {
			id = "180c739b495.png",
			xAdj = -230,
			yAdj = -150,
		},
		dead_left = {
			id = "180ec62d464.png",
			xAdj = -280,
			yAdj = -150,
		},
		dead_right = {
			id = "1809dfcd636.png",
			xAdj = -280,
			yAdj = -150,
		}
	}

	local final_boss_secondaries = function(boss)
		local spawnRarities = {1 ,1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 3, 3, 3 }
		local choice = math.random(1, 10)
		if choice == 1 then
			local imageData = boss.species.sprites.secondary_attack_left
			tfm.exec.addImage(imageData.id, "+" .. boss.objId, imageData.xAdj, imageData.yAdj, nil)
			for name in next, boss.area.players do
				local playerOtherObject = Player.players[name]
				playerOtherObject.health = playerOtherObject.health - (playerOtherObject.divinePower and 3 or 20)
				displayDamage(playerOtherObject)
			end

			local laser = tfm.exec.addImage(assets.laser, "!1", 250, 4695)
			Timer.new("laser_remove" .. laser, tfm.exec.removeImage, 500, false, laser)
		elseif choice > 9 then
			local imageData = boss.species.sprites.secondary_attack_left
			tfm.exec.addImage(imageData.id, "+" .. boss.objId, imageData.xAdj, imageData.yAdj, nil)
			local monster = Monster.new({ health = 20, species = Monster.all[({"mutant_rat", "snail", "the_rock"})[spawnRarities[math.random(#spawnRarities)]]] }, boss.spawnPoint.area.triggers[2])
			monster:changeStance(1)
		end
	end
	monsters.final_boss.spawn = function(self)
		self.objId = 300
		self.visibilityRange = 700
		--[[tfm.exec.addPhysicObject(self.objId, self.x, self.y - 80, {
			type = 1,
			width = 400,
			height = 250,
			dynamic = true,
			friction = 0,
			mass = 9999
		})]]
		tfm.exec.movePhysicObject(self.objId, self.x, self.y - 80)
		self.x = self.x - 250
		self.y = 4850
		local imageData = self.species.sprites.idle_left
		self.imageId = tfm.exec.addImage(imageData.id, "+" .. self.objId, imageData.xAdj, imageData.yAdj, nil)
	end
	monsters.final_boss.move = final_boss_secondaries
	monsters.final_boss.attacks = {
		primary = function(self, target)
			target.health = target.health - 30
			local imageData = self.species.sprites.primary_attack_left
			tfm.exec.addImage(imageData.id, "+" .. self.objId, imageData.xAdj, imageData.yAdj, nil)
		end,
		secondary = final_boss_secondaries
	}
	monsters.final_boss.death = function(self, killedBy)
		local imageData = self.species.sprites.dead_left
		local image = tfm.exec.addImage(imageData.id, "+" .. self.objId, imageData.xAdj, imageData.yAdj, nil)
		Timer.new("clear_body_final", tfm.exec.removeImage, 2000, false, image, true)
		for name in next, self.area.players do
			local player = Player.players[name]
			if not player.questProgress.final_boss.completed then system.giveEventGift(name, "evt_nobles_quest_golden_ticket_50") end
			player:updateQuestProgress("final_boss", 1)
			system.giveEventGift(name, "evt_nobles_quest_badge")
			tfm.exec.chatMessage(translate("ENDING_MESSAGE", player.language), name)
		end
	end

end
local Area = {}
Area.areas = {}

Area.__index = Area
Area.__tostring = function(self)
	return table.tostring(self)
end

setmetatable(Area, {
	__call = function (cls, ...)
		return cls.new(...)
	end,
})

function Area.new(x, y, w, h)
	local self = setmetatable({}, Area)
	self.id = #Area.areas + 1
	self.x = tonumber(x)
	self.y = tonumber(y)
	self.w = tonumber(w)
	self.h = tonumber(h)
	self.x = self.x - self.w / 2
	self.y = self.y - self.h / 2
	self.isTriggered = false
	self.playerCount = 0
	self.players = {}
	self.triggers = {}
	self.entities = {}
	self.monsters = {}
	Area.areas[#Area.areas + 1] = self
	return self
end

function Area.getAreaByCoords(x, y)
	for id, area in next, Area.areas do
		if x >= area.x and x <= area.x + area.w and y >= area.y and y <= area.y + area.h then
			return area
		end
	end
end

function Area:getClosestEntityTo(x, y)
	local min, closest = 1/0, nil
	for id, obj in next, self.entities do
		local dist = math.pythag(x, y, obj.x, obj.y)
		if dist <= 40 and dist < min then
			min = dist
			closest = obj
		end
	end
	return closest
end

function Area:getClosestMonsterTo(x, y)
	local min, closest = 1/0, nil
	local objList = tfm.get.room.objectList
	for id, monster in next, self.monsters do
		local obj =  (monster.species == Monster.all.fiery_dragon or monster.species == Monster.all.final_boss) and { x = monster.realX or monster.x, y = monster.y } or tfm.get.room.objectList[monster.objId]
		local dist = math.pythag(x, y, obj.x, obj.y)
		if dist <= 60 and dist < min then
			min = dist
			closest = monster
		end
	end
	return closest
end


function Area:onNewPlayer(player)
	self.players[player.name] = true
	self.playerCount = self.playerCount + 1
	if not self.isTriggered then
		self.isTriggered = true
		for _, trigger in next, self.triggers do
			trigger:activate()
		end
	end

end

function Area:onPlayerLeft(player)
	self.players[player.name] = nil
	self.playerCount = self.playerCount - 1
	if self.playerCount == 0 then
		for _, trigger in next, self.triggers do
			trigger:deactivate()
		end
		self.isTriggered = false
	end
end

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
			local lowerLimit = 500
			if self.monsterCount > 1 then
				lowerLimit = 1100 - self.area.playerCount * 45
			end
			lowerLimit = math.max(lowerLimit + self.monsterCount * 60, 500)
			if math.random(1, 1000) > lowerLimit then
				Monster.new({ health = math.random(15, 25), species = Monster.all[({"mutant_rat", "snail", "the_rock"})[spawnRarities[math.random(#spawnRarities)]]] }, self)
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
			Monster.new({ health = 15000, species = Monster.all.fiery_dragon }, self)
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
					tfm.exec.movePlayer(name, 63, 4793)
					if player.divinePower then
						inventoryPanel:hide(name)
						dialoguePanel:hide(name)
						divineChargePanel:show(name)
						divineChargePanel:addPanelTemp(Panel(401, "", 290, 380, (1 / FINAL_BOSS_ATK_MAX_CHARGE) * 270, 20, 0x91cfde, 0x91cfde, 1, true), name)
					end
				end
				-- chnge health 2500
				local boss = Monster.new({ health = 2500, species = Monster.all.final_boss }, self)
				Timer.new("bossDivineCharger", function()
					fadeInSlowly(5000, assets.divine_light, "!1", 0, 4570, nil, 1, 1, 0, 1, 0, 0)
					divineChargePanel:hide()
					for name in next, self.area.players do
						local player = Player.players[name]
						addDialogueBox(8, translate("MONK_DIALOGUES", player.language, 12), name, "Monk", "1817cca1b68.png")
					end
					Timer.new("divineAttack", function()
						divineChargeTimeOver = true
						local monster = self.monsters[next(self.monsters)]
						monster.health = monster.health - divinePowerCharge
						displayDamage(monster)
						dialoguePanel:hide()
						for name in next, self.area.players do
							local player = Player.players[name]
							if player.divinePower then
								divineChargePanel:show(name)
							else
								player:displayInventory()
							end
						end
					end, 8000, false)
				end, 1000 * 80, false)
			end, 1000 * 55 -_tc, false) -- change thi sto 40
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

			if #directionSequence > 0 and directionSequence[#directionSequence][3] > os.time() then return end
			--if #directionSequence > 0 then directionSequence[#directionSequence][3] = os.time() print("set") end
			local id = tfm.exec.addShamanObject(1, 816, 4395, 0, -2, 0)
			directionSequence[#directionSequence + 1] = { id, math.random(0, 3), os.time() + 3000, os.time() }
			--[[tfm.exec.addPhysicObject(id, 816, 4395, {
				type = 1,
				width = 10,
				height = 10,
				friction = 0,
				dynamic = true,
				fixedRotation = true
			})]]
			--tfm.exec.movePhysicObject(id, 0, 0, false, -20, 0)
			local imageId = tfm.exec.addImage("180e7b47ef5.png", "#" .. id, 0, 230, nil, 1, 1, math.rad(90 * (directionSequence[#directionSequence] and directionSequence[#directionSequence][2] or 1)), 1, 0.5, 0.5)
			if directionSequence[#directionSequence] then directionSequence[#directionSequence][5] = imageId end
			local s, v = 816 - 170, 20
			-- s = t(u + v)/2
			-- division by 3 is because the given vx is in a different unit than px/s
			local t = (2 * s / (v + v - 0.01)) / 3
			Timer.new("bossMinigame" .. tostring(#directionSequence), function()
				directionSequence.lastPassed = id - 8000
				local lastItemData = directionSequence[directionSequence.lastPassed]
				for name in next, self.area.players do
					local player = Player.players[name]
					if not player.divinePower then return end
					divineChargePanel:addPanelTemp(Panel(401, "", 290, 380, (divinePowerCharge / FINAL_BOSS_ATK_MAX_CHARGE) * 270, 20, 0x91cfde, 0x91cfde, 1, true), name)
					if player.sequenceIndex > directionSequence.lastPassed then return end
					player.sequenceIndex = directionSequence.lastPassed + 1
					tfm.exec.addImage("1810e90e75d.png", "#" .. lastItemData[1], 0, 230, name, 1, 1, math.rad(90 * lastItemData[2]), 1, 0.5, 0.5)
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

local Item = {}
Item.items = { _all = {} }

Item.__index = Item
Item.__tostring = function(self)
	return table.tostring(self)
end

setmetatable(Item, {
	__call = function (cls, ...)
		return cls.new(...)
	end,
})

Item.types = {
	RESOURCE	= 1,
	AXE			= 2,
	SHOVEL		= 3,
	SWORD		= 4,
	SPECIAL 	= 100
}

Item.shields = 15000

do

	locale_mt = { __index = function(tbl, k)
		return rawget(tbl, k) or rawget(tbl, "en") or ""
	end }

	desc_locale_mt = { __index = function(tbl, k)
		return rawget(tbl, k) or rawget(tbl, "en") or ""
	end }

	function Item.new(id, type, stackable, image, weight, locales, description_locales, attrs)
		local self = setmetatable({}, Item)
		self.id = id
		self.nid = #Item.items._all + 1
		self.type = type
		self.stackable = stackable
		self.image = image or "17ff9c560ce.png"
		self.weight = weight
		self.locales = setmetatable(locales, locale_mt)
		self.description_locales = setmetatable(description_locales or {}, desc_locale_mt)

		if type ~= Item.types.RESOURCE and type ~= Item.types.SPECIAL then
			-- basic settings for most of the basic tools
			self.durability = 15
			self.attack = 1
			self.chopping = 1
			self.mining = 0
			self.tier = 1
		end

		attrs = attrs or {}
		for k, v in next, attrs do
			self[k] = v
		end

		Item.items[id] = self
		Item.items._all[self.nid] = id
		return self
	end
end

function Item:getItem()
	if self.type == Item.types.RESOURCE then return self end
	return table.copy(self)
end

-- Setting up the items
Item("stick", Item.types.RESOURCE, true, "17ff9c560ce.png", 0.005, {
	ar = "عصا",
	en = "Stick",
	br = "Galho",
	pt = "Galho",
	pl = "Patyk",
	ro = "Băț",
	es = "Palo",
	tr = "Çubuk",
	cn = "树枝",
	zh = "樹枝",
	fr = "Bout de bois",
	ru = "Ветка",
	hu = "Bot",
})

Item("stone", Item.types.RESOURCE, true, "180a896fdf8.png", 0.05, {
	ar = "حجر",
	en = "Stone",
	br = "Pedra",
	pt = "Pedra",
	pl = "Kamien",
	ro = "Piatră",
	es = "Piedra",
	tr = "Taş",
	cn = "石头",
	zh = "石頭",
	fr = "Pierre",
	ru = "Камень",
	hu = "Kő",
}, {
	ar = ""
})

Item("clay", Item.types.RESOURCE, true, "180db604121.png", 0.05, {
	ar = "طين",
	en = "Clay",
	br = "Argila",
	pt = "Argila",
	pl = "Glina",
	ro = "Lut",
	es = "Arcilla",
	tr = "Kil",
	cn = "黏土",
	zh = "黏土",
	fr = "Argile",
	ru = "Глина",
	hu = "Agyag",
})

Item("iron_ore", Item.types.RESOURCE, true, "181aaa2468d.png", 0.08, {
	ar = "خام الحديد",
	en = "Iron ore",
	br = "Minério de ferro",
	pt = "Minério de ferro",
	pl = "Ruda żelaza",
	ro = "Minereu de fier",
	es = "Lingote de hierro",
	tr = "Demir cevheri",
	cn = "铁矿石",
	zh = "鐵礦石",
	fr = "Minerai de fer",
	ru = "Железная руда",
	hu = "Vasérc",
})

Item("copper_ore", Item.types.RESOURCE, true, "181aa9f511c.png", 0.09, {
	ar = "خام النحاس",
	en = "Copper ore",
	br = "Minério de cobre",
	pt = "Minério de cobre",
	pl = "Ruda miedzi",
	ro = "Minereu de cupru",
	es = "Lingote de cobre",
	tr = "Bakır cevheri",
	cn = "铜矿石",
	zh = "銅礦石",
	fr = "Minerai de cuivre",
	ru = "Медная руда",
	hu = "Rézérc",
})

Item("gold_ore", Item.types.RESOURCE, true, "181aaa10ab5.png", 0.3, {
	ar = "خام الذهب",
	en = "Gold ore",
	br = "Minério de ouro",
	pt = "Minério de ouro",
	pl = "Ruda złota",
	ro = "Minereu de aur",
	es = "Lingote de oro",
	tr = "Altın cevheri",
	cn = "金矿石",
	zh = "金礦石",
	fr = "Minerai d'or",
	ru = "Золотая руда",
	hu = "Aranyérc",
})

Item("wood", Item.types.RESOURCE, true, "18099c310cd.png", 0.35, {
	ar = "خشب",
	en = "Wood",
	br = "Madeira",
	pt = "Madeira",
	pl = "Drewno",
	ro = "Lemn",
	es = "Madera",
	tr = "Odun",
	cn = "木头",
	zh = "木頭",
	fr = "Bois",
	ru = "Древесина",
	hu = "Fa",
})

-- Special items
Item("log_stakes", Item.types.SPECIAL, false, "181aaa3a784.png", 3.5, {
	ar = "أوتاد الخشب",
	en = "Log stakes",
	br = "Estacas de madeira",
	pt = "Estacas de madeira",
	pl = "Stos kołków",
	ro = "Bușteni",
	es = "Lote de estacas",
	tr = "Odun destesi",
	cn = "一捆木",
	zh = "一綑木",
	fr = "Poteau en bois",
	ru = "Связка брёвен",
	hu = "Fakerítés",
}, {
	ar = "!من أهم اللبنات في البناء\n.يمكن استخدامه أيضًا كزخرفة أو للنار فقط إذا لم يكن لديك أي استخدام له",
	en = "One of the most important building blocks in constructions!\nIt can also use as a decoration or just for fire if you have no use of it.",
	br = "Pontes! Servem para atravessar um rio, mas também são um verdadeiro elemento de arquitetura urbana \nMas... como pretendes guarda-la no teu bolso???",
	pt = "Pontes! Servem para atravessar um rio, mas também são um verdadeiro elemento de arquitetura urbana \nMas... como pretendes guarda-la no teu bolso???",
	pl = "Jeden z najważniejszych budulców w konstrukcjach!\nMożna je również użyć jako dekorację lub żeby rozpalić ogień, jeśli nie ma z nich innego pożytku.",
	ro = "Unul dintre cele mai importante materiale de construcție!\nPoate fi folosit drept decorațiune sau pentru foc dacă nu ai unde să-l utilizezi.",
	es = "Uno de los bloques de construcción más importantes!\nTambién puede usarse como decoración o simplemente para hacer fuego",
	tr = "Yapılarda kullanılan en önemli inşaat bloklarından biri!\nAynı zamanda başka kullanım amacınız yoksa dekorasyon için ya da sadece ateş yakmak için kullanabilirsiniz.",
	cn = "在建筑中其中一个最重要的建筑原料!\n如果没其他用途也可以用作装饰或是生火用",
	zh = "在建築中其中一個最重要的建築原料!\n如果沒其他用途也可以用作裝飾或是生火用。",
	fr = "Un des plus importants blocs de construction !\nIl peut aussi être utilisé comme décoration ou juste pour faire du feu si vous n'en avez pas d'autres utilités.",
	ru = "Один из главных материалов в строительствe!\nОни ещё могут послужить декорацией или топливом, если не находится применение.",
	hu = "Az építkezések egyik legfontosabb összetevője!\nDe dekorációként, vagy tüzifaként is használhatod, ha nem tudod már másra.",
})

Item("bridge", Item.types.SPECIAL, false, "181aa89d9ca.png", 18, {
	ar = "الجسر",
	en = "Bridge",
	br = "Ponte",
	pt = "Ponte",
	pl = "Most",
	ro = "Pod",
	es = "Puente",
	tr = "Köprü",
	cn = "桥",
	zh = "橋",
	fr = "Pont",
	ru = "Мост",
	hu = "Híd",
}, {
	ar = "الجسور! الاستخدام الأساسي هو الوصول إلى الأرض على الجانب الآخر من النهر ، ولكنه أيضًا عنصر رائع في هندسة المدن\nلكن ... كيف ستضع الجسر داخل جيبك ؟؟؟",
	en = "Bridges! Most basic use is accessing the land on the other side of a river, but also is also a great component in city architecuring.\nBut... how are you going to fit a bridge inside your pocket???",
	br = "Pontes! Servem para atravessar um rio, mas também são um verdadeiro elemento de arquitetura urbana \nMas... como pretendes guarda-la no teu bolso???",
	pt = "Pontes! Servem para atravessar um rio, mas também são um verdadeiro elemento de arquitetura urbana \nMas... como pretendes guarda-la no teu bolso???",
	pl = "Mosty! Najbardziej podstawowym zastosowaniem jest dostęp do lądu po drugiej stronie rzeki, ale jest także doskonałym elementem architektury miejskiej.\nAle...jak zmieścisz most w kieszeni???",
	ro = "Poduri! Cea mai simplă întrebuințare e pentru a traversa un râu, dar totodată este un component formidabil în arhitectura urbană.\nDar... cum vei face loc pentru un pod în buzunar???",
	es = "¡Puentes! El uso más basico es para acceder a las tierras al otro lado de un río, pero también es un gran componente en la arquitectura de ciudades.\nPero... Cómo vas a guardar un puente en tu bolsillo???",
	tr = "Köprüler! En temel kullanım amacı bir nehrin karşısında bulunan diğer topraklara erişmek, ayrıca şehir mimarisi için en muazzam elemanlardan biri\nAma... bir köprüyü nasıl cebine sığdırabilrsin ki???",
	cn = "桥! 最基本的用法是用来到达河的对岸, 但也是城市建筑最好的组成部分。\n但是... 你要如何把桥收进你的袋子里???",
	zh = "橋! 最基本的用法是用來到達河的對岸, 但也是城市建築最好的組成部分。\n但是... 你要如何把橋收進你的袋子裡???",
	fr = "Des ponts ! La plus basique des utilisations consiste à accéder à la terre de l'autre côté de la rivière, mais c'est aussi un super élément dans les architectures en ville.\nMais... comment allez-vous faire rentrer un pont dans votre poche ???",
	ru = "Мосты! Самое простое применение - это переход с одной стороны реки на другую, а ещё это важный элемент городской архитектуры.\nНо... как ты поместишь мост у себя в кармане???",
	hu = "Hidak! A legegyszerűbb használata az, hogy az egyik földről a másik földre átmehessünk egy tó felett, de a városépítésben is nagyon hasznos tud lenni.\nDe... hogy fogsz egy hidat a zsebedben tárolni???",
})

Item("basic_axe", Item.types.AXE, false, "180dfe8e723.png", 1, {
	ar = "فأس أساسي",
	en = "Basic axe",
	br = "Machado básico",
	pt = "Machado básico",
	pl = "Zwykła siekiera",
	ro = "Topor simplu",
	es = "Hacha básica",
	tr = "Normal balta",
	cn = "基本斧头",
	zh = "基本斧頭",
	fr = "Hache commune",
	ru = "Обычный топор",
	hu = "Alap balta",
}, {
	ar = "مجرد فأس أساسي",
	en = "Just a basic axe",
	br = "Apenas um machado básico",
	pt = "Apenas um machado básico",
	pl = "Po prostu zwykła siekiera",
	ro = "Doar un topor obișnuit",
	es = "Simplemente una hacha básica",
	tr = "Sadece basit bir balta",
	cn = "只是一把基本斧头",
	zh = "只是一把基本斧頭",
	fr = "Juste une hache commune",
	ru = "Железный топор",
	hu = "Csak egy sima balta",
}, {
   durability = 10,
   chopping = 1
})

Item("iron_axe", Item.types.AXE, false, "1801248fac2.png", 1.3, {
	ar = "فأس حديد",
	en = "Iron axe",
	br = "Machado de ferro",
	pt = "Machado de ferro",
	pl = "Żelazna siekiera",
	ro = "Topor de fier",
	es = "Hacha de hierro",
	tr = "Demir balta",
	cn = "铁斧头",
	zh = "鐵斧頭",
	fr = "Hache renforcée",
	ru = "Железный топор",
	hu = "Vasbalta",
}, {
	ar = "!التدعيم المضاف بالحديد يجعله يدوم مرتين أكثر من الفأس الأساسي",
	en = "The reinforcement added with iron makes it last twice more than a basic axe!",
	br = "Reforçando com ferro faz durar duas vezes mais do que um machado básico!!",
	pt = "Reforçando com ferro faz durar duas vezes mais do que um machado básico!!",
	pl = "Wzmocniona żelazem, dzięki czemu wytrzymuje dwa razy więcej niż zwykła siekiera!",
	ro = "Întărit cu fier pentru a rezista de două ori mai mult timp decât un topor simplu!",
	es = "Reforzada con hierro para hacerla durar el doble de lo que dura una hacha básica!",
	tr = "Normal bir baltadan iki kat uzun süre dayanması için demir ile güçlendirilmiş!",
	cn = "用铁来强化使它比基本斧头两倍耐用!",
	zh = "用鐵來強化使它比基本斧頭兩倍耐用!",
	fr = "Renforcée avec le fer pour la faire durer deux fois plus longtemps qu'une hache commune !",
	ru = "Укреплён железом, чтобы рубил вдвое дольше, чем обычный топор!",
	hu = "Vassal átalakítva, hogy kétszer tovább tartson, mint egy sima balta!",
}, {
   durability = 20,
   chopping = 1
})

Item("copper_axe", Item.types.AXE, false, "180dfe88be8.png", 1.4, {
	ar = "فأس نحاسي",
	en = "Copper axe",
	br = "Machado de cobre",
	pt = "Machado de cobre",
	pl = "Miedziana siekiera",
	ro = "Topor de cupru",
	es = "Hacha de cobre",
	tr = "Bakır balta",
	cn = "铜斧头",
	zh = "銅斧頭",
	fr = "Hache en cuivre",
	ru = "Медный топор",
	hu = "Rézbalta",
}, {
	ar = "!صممه حدادون بارزون. تصميم الحافة يجعله أسهل في الاستخدام وأكثر حدة",
	en = "Designed by notable blacksmiths. The edge design makes it much easier to use and sharper!",
	br = "Criado por incríveis ferreiros. O estilo da lâmina torna-a muito mais afiada e fácil de usar!!",
	pt = "Criado por incríveis ferreiros. O estilo da lâmina torna-a muito mais afiada e fácil de usar!!",
	pl = "Zaprojektowana przez wybitnych kowali. Konstrukcja krawędzi sprawia, że jest znacznie łatwiejsza w użyciu i o wiele ostrzejsza!",
	ro = "Meșteșugărit de fierari cu renume. Stilul lamei îl face mult mai ascuțit și ușor de folosit!",
	es = "Diseñada por herreros notables. ¡El diseño del filo la hace más fácil de utilizar y más afilada!",
	tr = "Şöhretli bir demirci tarafından tasarlandı. Kenarlarının tasarımı kullanımını kolaylaştırıyor ve daha keskin olmasını sağlıyor!",
	cn = "由知名铁匠设计。边缘的设计使它更容易使用及更锋利!",
	zh = "由知名鐵匠設計。邊緣的設計使它更容易使用及更鋒利!",
	fr = "Forgée par de grands forgerons. Le trachant de la lame la rend plus facile à utiliser et coupant !",
	ru = "Сделан опытными кузнецами. Дизайн лезвия делает его более острым и лёгким в использовании!",
	hu = "Neves kovácsok készítették először. A kialakítása miatt egyszerűbb használni, és tovább tart!",
}, {
   durability = 20,
   chopping = 2
})

Item("gold_axe", Item.types.AXE, false, "180dfe8aab9.png", 1.5, {
	ar = "الفأس الذهبي",
	en = "Golden axe",
	br = "Machado de ouro",
	pt = "Machado de ouro",
	pl = "Złota siekiera",
	ro = "Topor de aur",
	es = "Hacha de oro",
	tr = "Altın balta",
	cn = "金斧头",
	zh = "金斧頭",
	fr = "Hache en or",
	ru = "Золотой топор",
	hu = "Aranybalta",
}, {
	ar = ".فأس مصمم بعد الجمع بين الذهب والسبائك الأخرى لجعله أقوى وأكثر متانة\nلست متأكدًا مما إذا كان أي حطاب عادي يستخدم مثل هذه الأداة باهظة الثمن",
	en = "An axe designed after combining gold and other alloys to make it stronger and more durable.\nI'm not sure if any regular lumberjack uses such an expensive tool though.",
	br = "Criado pela combinação de ouro e outros materiais para o tornar mais durável.\nMas não tenho a certeza se algum artesão comum vai utilizar uma ferramenta tão cara.",
	pt = "Criado pela combinação de ouro e outros materiais para o tornar mais durável.\nMas não tenho a certeza se algum artesão comum vai utilizar uma ferramenta tão cara.",
	pl = "Siekiera zaprojektowana po połączeniu złota i innych stopów, aby uczynić ją mocniejszą i bardziej wytrzymałą.\nNie jestem pewien, czy jakikolwiek kowal używa tak drogiego narzędzia.",
	ro = "Un topor creat prin combinarea aurului cu numeroase alte aliaje pentru a-l face mai trainic.\nÎnsă nu sunt sigur dacă vreun meșteșugar ordinar folosește o unealtă atât de scumpă.",
	es = "Una hacha hecha de oro y otras aleaciones para hacerla más resistente y duradera.\nNo estoy seguro de si algún leñador usa una herramienta tan cara como esta.",
	tr = "Altın ve diğer alaşımların bir araya getirilmesiyle daha sağlam ve dayanıklı olması için tasarlanmış bir balta.\nSıradan oduncuların bu kadar pahalı bir alet kullanıp kullanmadığı konusunda emin değilim doğrusu.",
	cn = "一把以金及其他合金造成的斧头使它更强更耐用。\n我不确定正常的伐木工会使用这么昂贵的工具就是了。",
	zh = "一把以金及其他合金造成的斧頭使它更強更耐用。\n我不確定正常的伐木工會使用這麼昂貴的工具就是了。",
	fr = "Une hache conçue par combinaison d'or et d'autres alliages pour la rendre plus dure et plus durable.\nJe ne suis pas certain que les petits forgerons puisse créer un tel outil.",
	ru = "Топор сделанный путём перемешивания золота с другими металлами.\nНе уверен, если обычные кузнецы владеют таким инструментом.",
	hu = "Egy balta, ami arany és egyéb nyersanyagokból lett összerakva, így erősebb és tartósabb.\nNem hinném, hogy egy igazi favágó használna ilyen értékes eszközt.",
}, {
   durability = 30,
   chopping = 3
})


Item("basic_shovel", Item.types.SHOVEL, false, "181968e3a21.png", 1, {
	ar = "مجرفة أساسية",
	en = "Basic shovel",
	br = "Pá básica",
	pt = "Pá básica",
	pl = "Zwykła łopata",
	ro = "Lopată simplă",
	es = "Pala básica",
	tr = "Normal kürek",
	cn = "基本铲子",
	zh = "基本鏟子",
	fr = "Pelle commune",
	ru = "Обычная лопата",
	hu = "Alap ásó",
}, {
	ar = "احفر احفر احفر",
	en = "Dig dig dig",
	br = "Cavar Cavar Cavar! mas atenção que esta pá tem pouca resistência",
	pt = "Cavar Cavar Cavar! mas atenção que esta pá tem pouca resistência",
	pl = "Kop kop kop",
	ro = "Sapă sapă sapă",
	es = "Excava, excava, excava",
	tr = "Kaz kaz kaz",
	cn = "挖挖挖",
	zh = "挖挖挖",
	fr = "Creuse creuse creuse",
	ru = "Коп, коп, коп",
	hu = "Áss, áss, áss!",
}, {
   durability = 10,
   mining = 2
})

Item("iron_shovel", Item.types.SHOVEL, false, "181968e1951.png", 1.4, {
	ar = "مجرفة حديدية",
	en = "Iron shovel",
	br = "Pá de ferro",
	pt = "Pá de ferro",
	pl = "Żelazna łopata",
	ro = "Lopată de fier",
	es = "Pala de hierro",
	tr = "Demir kürek",
	cn = "铁铲子",
	zh = "鐵鏟子",
	fr = "Pelle en fer",
	ru = "Железная лопата",
	hu = "Vasásó",
}, {
	ar = "هنا بدأ التطور",
	en = "Evolution started here",
	br = "A evolução começa aqui",
	pt = "A evolução começa aqui",
	pl = "Tutaj zaczęła się ewolucja",
	ro = "Evoluția începe aici",
	es = "La evolución empezó aquí",
	tr = "Gelişim buradan başladı",
	cn = "革命始于这里",
	zh = "革命始於這裡",
	fr = "La civilisation est partie de là",
	ru = "Эволюция началась здесь",
	hu = "Az evolúció itt kezdődött",
}, {
   durability = 15,
   mining = 3
})

Item("copper_shovel", Item.types.SHOVEL, false, "181968d1682.png", 1, {
	ar = "مجرفة نحاسية",
	en = "Copper shovel",
	br = "Pá de cobre",
	pt = "Pá de cobre",
	pl = "Miedziana łopata",
	ro = "Lopată de cupru",
	es = "Pala de cobre",
	tr = "Bakır kürek",
	cn = "铜铲子",
	zh = "銅鏟子",
	fr = "Pelle en cuivre",
	ru = "Медная лопата",
	hu = "Rézásó",
}, {
	ar = "!مع تصميمه القوي يمكنه حفر معظم المواد",
	en = "The material and strong design make it possible to dig the most of it !",
	br = "O estilo e o material robusto ajudam-no a utilizá-lo ao máximo!",
	pt = "O estilo e o material robusto ajudam-no a utilizá-lo ao máximo!",
	pl = "Materiał i mocna konstrukcja umożliwiają wykopanie nim jak najwięcej!",
	ro = "Stilul și materialul trainic te ajută s-o folosești la maxim!",
	es = "El material y el diseño de esta pala hace posible que puedas excavar casi todo",
	tr = "Dayanıklı malzeme tasarımı çoğu şeyi kazmasını mümkün kılıyor!",
	cn = "物质以及强大的设计使它可以挖出最多东西!",
	zh = "物質以及強大的設計使它可以挖出最多東西!",
	fr = "Ses matériaux et sa conception en font une très bon outil pour mieux creuser !",
	ru = "Материал и устойчивый дизайн позволят использовать её по максимуму!",
	hu = "Az anyag és a kivitelezés lehetővé teszi, hogy még többet áss!",
}, {
   durability = 10,
   mining = 3
})

Item("gold_shovel", Item.types.SHOVEL, false, "181968d4e85.png", 1, {
	ar = "مجرفة ذهبية",
	en = "Gold shovel",
	br = "Pá de ouro",
	pt = "Pá de ouro",
	pl = "Złota łopata",
	ro = "Lopată de aur",
	es = "Pala de oro",
	tr = "Altın kürek",
	cn = "金铲子",
	zh = "金鏟子",
	fr = "Pelle en or",
	ru = "Золотая лопата",
	hu = "Aranyásó",
}, {
	ar = "!ندرة المواد المستخدمة في التصميم تجعل من السهل جدًا حفر المزيد من المعادن النادرة",
	en = "The rarirty of the material used to design makes it much easier to dig more rare metals!",
	br = "A raridade do material utilizado na concepção torna-o muito mais fácil escavar metais mais raros!",
	pt = "A raridade do material utilizado na concepção torna-o muito mais fácil escavar metais mais raros!",
	pl = "Rzadkość materiału użytego do konstrukcji ułatwia wydobycie rzadszych metali!",
	ro = "Raritatea metalului folosit pentru a o crea te ajută să găsești mai ușor resure rare!",
	es = "¡La rareza del material usado para diseñarla, la hace mejor para excavar mejores metales!",
	tr = "Tasarımındaki malzemelerin nadirliği, daha ender bulunan metalleri kazmasını kolaylaştırıyor!",
	cn = "设计用上这种稀有物质使它更容易挖出更稀有的金属!",
	zh = "設計用上這種稀有物質使它更容易挖出更稀有的金屬!",
	fr = "La rareté des matériaux utilisés lui permettent de creuser plus et de trouver des métaux plus rares !",
	ru = "Редкость материала помогает раскапывать более редкие металлы!",
	hu = "Az anyagok ritkasága miatt még több ritka fémeket lehet bányászni!",
}, {
   durability = 20,
   mining = 4
})

Item("iron_sword", Item.types.SWORD, false, "1819f06ecfc.png", 1.4, {
	ar = "سيف حديدي",
	en = "Iron sword",
	br = "Espada de ferro",
	pt = "Espada de ferro",
	pl = "Żelazny miecz",
	ro = "Sabie de fier",
	es = "Espada de hierro",
	tr = "Demir kılıç",
	cn = "铁剑",
	zh = "鐵劍",
	fr = "Épée en fer",
	ru = "Железный меч",
	hu = "Vaskard",
}, {
	ar = "!!!إنه سريع وحاد",
	en = "It's fast and sharp!!!",
	br = "É rápido e afiado!!! Mas não é resistente!",
	pt = "É rápido e afiado!!! Mas não é resistente!",
	pl = "Jest szybki i ostry!!!",
	ro = "E iute și ascuțită!!!",
	es = "Es rápida y afilada!",
	tr = "Hızlı ve keskin!!!",
	cn = "快又锋利!!!",
	zh = "快又鋒利!!!",
	fr = "Elle est très rapide et aiguisée !!!",
	ru = "Быстрый и острый!!!",
	hu = "Gyors és éles!!!",
}, {
   attack = 5,
   durability = 25
   }
)

Item("copper_sword", Item.types.SWORD, false, "1819f0717ee.png", 1.4, {
	ar = "سيف نحاسي",
	en = "Copper sword",
	br = "Espada de cobre",
	pt = "Espada de cobre",
	pl = "Miedziany miecz",
	ro = "Sabie de cupru",
	es = "Espada de cobre",
	tr = "Bakır kılıç",
	cn = "铜剑",
	zh = "銅劍",
	fr = "Épée en cuivre",
	ru = "Медный меч",
	hu = "Rézkard",
}, {
	ar = "!يبدو أقوى بكثير من السيف الحديدي",
	en = "Looking a lot more sturdy than the iron sword!",
	br = "Mata os teus inimigos!",
	pt = "Mata os teus inimigos!",
	pl = "Wygląda o wiele solidniej niż żelazny miecz!",
	ro = "Un instrument neostenit",
	es = "Es rápida y afilada!",
	tr = "Buna lütfen bir tabir bulun.",
	cn = "看来比铁剑更结实!",
	zh = "看來比鐵劍更結實!",
	fr = "Une arme assez lourde mais qui saura tenir tête aux plus coriaces.",
	ru = "Выглядит намного солиднее чем железный меч",
	hu = "Sokkal erősebb, mint a vaskard!",
}, {
	   attack = 7,
	   durability = 30
   }
)

Item("gold_sword", Item.types.SWORD, false, "1819f077e01.png", 1.4, {
	ar = "سيف ذهبي",
	en = "Gold sword",
	br = "Espada de ouro",
	pt = "Espada de ouro",
	pl = "Złoty miecz",
	ro = "Sabie de aur",
	es = "Espada de oro",
	tr = "Altın kılıç",
	cn = "金剑",
	zh = "金劍",
	fr = "Épée en or",
	ru = "Золотой меч",
	hu = "Aranykard",
}, {
	ar = "بعد الكثير من الأبحاث ، أقوى سيف مصنوع من السبائك التي تجعله يدوم لفترة أطول من أي شيء آخر",
	en = "After lots of researches, the sharpest sword made with alloys that make it last longer than anything",
	br = "A espada mais resistente, extraída de ouro e dos melhores materiais!",
	pt = "A espada mais resistente, extraída de ouro e dos melhores materiais!",
	pl = "Po wielu poszukiwaniach powstał najostrzejszy miecz wykonany ze stopów, które sprawiają, że ten miecz jest trwalszy niż cokolwiek innego",
	ro = "După multe cercetări, iată sabia cea mai trainică făcută din cele mai scumpe aliaje",
	es = "Despues de mucha búsqueda, esta es la espada más afilada hecha con aleaciones que la hace durar más que ninguna otra",
	tr = "Yoğun araştırmalar sonucu, her şeyden daha uzun süre dayanması için alaşımlarla yapılan en keskin kılıç.",
	cn = "在不少研究之后, 使用合金造出这最锋利的剑比任何东西都耐久",
	zh = "在不少研究之後, 使用合金造出這最鋒利的劍比任何東西都耐久",
	fr = "De nombreuses recherches ont mené à la plus tranchante des épées, forgées avec des alliages qui durent plus que jamais dans le temps",
	ru = "После долгого изучения - меч, сделанный из самых прочных металлов, чтобы служил дольше всех",
	hu = "Sok kutatás után, a legerősebb kardot úgy ötvözték, hogy tovább tartson, mint bármi más.",
}, {
	   attack = 10,
	   durability = 38
   }
)


Item("iron_shield", Item.types.SPECIAL, false, "180fa02a686.png", 1, {
	ar = "درع حديدي",
	en = "Iron shield",
	br = "Escudo de ferro",
	pt = "Escudo de ferro",
	pl = "Żelazna tarcza",
	ro = "Scut de fier",
	es = "Escudo de hierro",
	tr = "Demir kalkan",
	cn = "铁盾牌",
	zh = "鐵盾牌",
	fr = "Bouclier en fer",
	ru = "Железный щит",
	hu = "Vaspajzs",
}, {
	ar = "!احم نفسك من الأعداء",
	en = "Protect yourself from enemies!",
	br = "Defende-te dos teus inimigos!",
	pt = "Defende-te dos teus inimigos!",
	pl = "Broń się przed wrogami!",
	ro = "Apără-te de dușmani",
	es = "¡Protégete de los enemigos!",
	tr = "Kendinizi düşmanlardan koruyun!",
	cn = "在敌人面前保护自己!",
	zh = "在敵人面前保護自己!",
	fr = "Une protection des plus basiques mais tout aussi essentielle",
	ru = "Защищайся им от врагов",
	hu = "Védd meg magad az ellenségektől!",
}, {
	   defense = 10,
	   durability = 20,
   }
)

Item("copper_shield", Item.types.SPECIAL, false, "18105db53fe.png", 1.4, {
	ar = "درع نحاسي",
	en = "Copper shield",
	br = "Escudo de cobre",
	pt = "Escudo de cobre",
	pl = "Miedziana tarcza",
	ro = "Scut de cupru",
	es = "Escudo de cobre",
	tr = "Bakır kalkan",
	cn = "铜盾牌",
	zh = "銅盾牌",
	fr = "Bouclier en cuivre",
	ru = "Медный щит",
	hu = "Rézpajzs",
}, {
	ar = "درع قوي قادر على عكس العديد من الهجمات",
	en = "A sturdy shield capable of reflecting many attacks",
	br = "Um escudo resistente capaz de resistir a muitos ataques",
	pt = "Um escudo resistente capaz de resistir a muitos ataques",
	pl = "Solidna tarcza zdolna do odbijania wielu ataków",
	ro = "Un scut voinic capabil să reziste o mulțime de atacuri",
	es = "Un escudo que puede reflejar varios ataques",
	tr = "Birçok saldırıyı geriye yansıtabilecek kapasiteye sahip dayanıklı bir kalkan",
	cn = "经过研究之后的盾牌能够反弹不少攻击",
	zh = "經過研究之後的盾牌能夠反彈不少攻擊",
	fr = "Un bouclier plus résistant qui saura encaisser les coups durs",
	ru = "Прочный щит, который отразит много атак",
	hu = "Egy erős pajzs, ami több ellenség ütését kivédi.",
}, {
	   defense = 15,
	   durability = 28
   }
)

Item("gold_shield", Item.types.SPECIAL, false, "18105dac98a.png", 2, {
	ar = "درع الذهب",
	en = "Gold shield",
	br = "Escudo de ouro",
	pt = "Escudo de ouro",
	pl = "Złota tarcza",
	ro = "Scut de aur",
	es = "Escudo dorado",
	tr = "Altın kalkan",
	cn = "金盾牌",
	zh = "金盾牌",
	fr = "Bouclier en or",
	ru = "Золотой щит",
	hu = "Aranypajzs",
}, {
	ar = "!أفضل درع يمكن شراؤه بالمال",
	en = "The best shield money... er... gold can buy!",
	br = "O melhor escudo que o dinheiro pode comprar.... arr... de ouro",
	pt = "O melhor escudo que o dinheiro pode comprar.... arr... de ouro",
	pl = "Najlepsza tarcza, jaką można kupić za pieniądze... arr... złoto!",
	ro = "Cea mai bună apărare pe care o poți cumpăra cu bani... ăă... aur",
	es = "El mejor escudo que el dinero... eh... oro puede comprar!",
	tr = "Paranın... ehmm... altının satın alabileceği en iyi kalkan!",
	cn = "最好的盾牌用钱... 呃... 黄金可以买到!",
	zh = "最好的盾牌用錢... 呃... 黃金可以買到!",
	fr = "De par ses matériaux, cela en fait un bouclier d'une extrême résistance en plus de réfléchir la lumière",
	ru = "Лучший щит, который только можно купить за день... ээ... золото!",
	hu = "A legjobb pajzs, amit a pénz... azaz... arany megvehet!",
}, {
   defense = 20,
   durability = 35
   }
)
Player = {}

Player.players = {}
Player.alive = {}
Player.playerCount = 0
Player.aliveCount = 0

Player.__index = Player
Player.__tostring = function(self)
	return table.tostring(self)
end
Player.__type = "player"

setmetatable(Player, {
	__call = function (cls, name)
		return cls.new(name)
	end,
})


function Player.new(name)
	local self = setmetatable({}, Player)

	self.name = name
	self.language = tfm.get.room.playerList[name].language
	self.area = nil
	self.equipped = nil
	self.inventorySelection = 1
	self.stance = -1 -- right
	self.health = health(50, name)
	self.alive = true
	self.inventory = { {}, {}, {}, {}, {}, {}, {}, {}, {}, {} }
	self.carriageWeight = 0
	self.sequenceIndex = 1
	self.chargedDivinePower = 0
	self.learnedRecipes = {}
	self.spiritOrbs = 0
	self.divinePower = false
	self.isShielded = false
	self.actionCooldown = 0
	self.kills = 0
	self.questProgress = {
		-- quest: stage, stageProgress, completed?
	}

	Player.players[name] = self
	Player.playerCount = Player.playerCount + 1

	return self
end

function Player:setArea(x, y)
	local originalArea = Area.areas[self.area]
	local newArea = Area.getAreaByCoords(x, y)
	self.area = newArea and newArea.id or nil
	if originalArea ~= newArea then
		if originalArea then originalArea:onPlayerLeft(self) end
		if newArea then newArea:onNewPlayer(self) end
	end
	return newArea
end

function Player:getInventoryItem(item)
	for i, it in next, self.inventory do
		if it[1] and it[1].id == item then
			return i, it[2]
		end
	end
end

function Player:addInventoryItem(newItem, quantity)
	local newWeight = self.carriageWeight + newItem.weight * quantity
	if newWeight > 20 then error("Full inventory", 1) end
	self.carriageWeight = newWeight
	if newItem.stackable then
		local invPos, itemQuantity = self:getInventoryItem(newItem.id)
		if invPos and itemQuantity + quantity < 128 then
			local newQuantity = itemQuantity + quantity
			if newQuantity < 0 then return end
			if newQuantity == 0 then
				self.inventory[invPos] = {}
			else
				if newQuantity <= 0 then
					self.inventory[invPos] = {}
				else
					self.inventory[invPos][2] = newQuantity
				end
			end
			if invPos == self.inventorySelection then self:changeInventorySlot(invPos) end
			return self:displayInventory()
		end
	end
	--if quantity <= 0 then return end
	for i, item in next, self.inventory do
		if #item > 0 and newItem.stackable and newItem.id == item[1].id and quantity + item[2] < 128 then
			self.inventory[i][2] = item[2] + quantity
			return self:displayInventory()
		elseif #item == 0 and quantity > 0 then
			self.inventory[i] = { newItem:getItem(), quantity }
			if i == self.inventorySelection then self:changeInventorySlot(i) end
			return self:displayInventory()
		elseif #item > 0 and item[1].id == newItem.id and (not newItem.stackable) and quantity == -1 then
			self.inventory[i] = {}
			return self:displayInventory()
		end
	end
	tfm.exec.chatMessage(translate("FULL_INVENTORY", self.language), self.name)
	error("Full inventory", 2)
end

-- use some kind of class based thing to add items

function Player:changeInventorySlot(idx)
	if idx < 0 or idx > 10 or self.divinePower then return end
	self.inventorySelection = idx
	self.isShielded = false
	local item = self.inventory[idx][1]
	if item and item.type ~= Item.types.RESOURCE and item.type ~= Item.types.SPECIAL then
		self.equipped = self.inventory[idx][1]
		self:changeHoldingItem()
	else
		self.equipped = nil
	end
	self:displayInventory()
end

function Player:changeHoldingItem()
	--[[local item = self.inventory[self.inventorySelection][1]
	if self.holdingImage then
		tfm.exec.removeImage(self.holdingImage)
	end
	if item and item.type ~= Item.types.RESOURCE and item.type ~= Item.types.SPECIAL then
		print("got in here")
		local isFacingRight = self.stance == -1
		self.holdingImage = tfm.exec.addImage(item.image, "$" .. self.name, isFacingRight and 28 or -25, isFacingRight and -3 or 0, nil, 0.8, 0.8, isFacingRight and 0 or 180, 1, 0.5, 0.5)
	end]]
end

function Player:displayInventory()
	local invSelection = self.inventorySelection
	inventoryPanel:hide(self.name)
	inventoryPanel:show(self.name)
	for i, item in next, self.inventory do
		if #item > 0 then
			Panel.panels[100 + i]:addImageTemp(Image(item[1].image, "~1", Panel.panels[100 + i].x, 350), self.name)
		end
		if i == invSelection then
			Panel.panels[120 + i]:update("<b><font size='10px'>" .. (item[2] and "×" .. item[2] or "") .. "</font></b>", self.name)
		else
			Panel.panels[120 + i]:update("<font size='10px' color='#aaaaaa'>" .. (item[2] and "×" .. item[2] or "") .. "</font>", self.name)
		end
	end
	Panel.panels[150]:update(translate("INVENTORY_INFO", self.language, nil, {
		color = self.carriageWeight < 14 and "C2C2DA" or (self.carriageWeight < 18 and "de813e" or "d93931"),
		weight = self.carriageWeight
	}), self.name)
end

function Player:useSelectedItem(requiredType, requiredProperty, targetEntity)
	local item = self.equipped
	-- we only need to calculate the regen when it receives another action
	-- so we can save resources used to calculate the regen over each intervals
	targetEntity:regen()
	if (not item[requiredProperty] == 0) or targetEntity.resourcesLeft <= 0 then
		tfm.exec.chatMessage(translate("OUT_OF_RESOURCES", player.language), self.name)
		return 0
	end
	local isCorrectItem = item.type == requiredType
	local itemDamage = isCorrectItem and 1 or math.max(1, 4 - item.tier)
	local originalDurability = item.durability
	originalDurability = originalDurability - itemDamage
	item.durability = originalDurability
	if item.durability <= 0 then
		self.inventory[self.inventorySelection] = {}
		item = nil
		self:changeInventorySlot(self.inventorySelection)
		return 0
	end
	-- give resources equivelant to the tier level of the item if they are using the correct item for the job
	local returnAmount = isCorrectItem and (item.tier + item[requiredProperty] - 1) or 1
	targetEntity.resourcesLeft = math.max(targetEntity.resourcesLeft - returnAmount, 0)
	displayDamage(targetEntity)
	targetEntity.latestActionTimestamp = os.time()
	return returnAmount
end

function Player:addNewQuest(quest)
	if self.questProgress[quest] then return end
	self.questProgress[quest] = { stage = 1, stageProgress = 0, completed = false }
	local qData = quests[quest]
	tfm.exec.chatMessage(translate("NEW_QUEST", self.language, nil, {
		questName = qData.title_locales[self.language] or qData.title_locales["en"],
	}), self.name)
	tfm.exec.chatMessage(translate("NEW_STAGE", self.language, nil, {
		questName = qData.title_locales[self.language] or qData.title_locales["en"],
		desc = qData[1].description_locales[self.language] or qData[1].description_locales["en"] or "",
	}), self.name)
	self:savePlayerData()
end

function Player:updateQuestProgress(quest, newProgress)
	if newProgress == 0 then return end
	local pProgress = self.questProgress[quest]
	if pProgress.completed then return end
	local progress = pProgress.stageProgress + newProgress
	local q = quests[quest]
	local announceStageProgress = true
	self.questProgress[quest].stageProgress = progress
	if progress >= quests[quest][pProgress.stage].tasks then
		if pProgress.stage >= #q then
			tfm.exec.chatMessage(translate("QUEST_OVER", self.language, nil, {
				questName = q.title_locales[self.language] or q.title_locales["en"],
			}), self.name)
			self.questProgress[quest].completed = true
			giveReward(self.name, 1)
			if quest == "strength_test" then
				system.giveEventGift(self.name, "evt_nobles_quest_title_542")
				system.giveEventGift(self.name, "evt_nobles_quest_golden_ticket_20")
			elseif quest ~= "wc" and quest ~= "final_boss" then
				system.giveEventGift(self.name, "evt_nobles_quest_golden_ticket_20")
			end
		else
			self.questProgress[quest].stage = self.questProgress[quest].stage + 1
			self.questProgress[quest].stageProgress = 0
			tfm.exec.chatMessage(translate("NEW_STAGE", self.language, nil, {
				questName = q.title_locales[self.language] or q.title_locales["en"],
				desc = q[pProgress.stage].description_locales[self.language] or q[pProgress.stage].description_locales["en"] or "",
			}), self.name)
			giveReward(self.name, 0)
		end
		announceStageProgress = false
	end
	if announceStageProgress then
		tfm.exec.chatMessage(translate("STAGE_PROGRESS", self.language, nil, {
			questName = q.title_locales[self.language] or q.title_locales["en"],
			progress = progress,
			needed = quests[quest][pProgress.stage].tasks
		}), self.name)
	end
	dHandler:set(self.name, "questProgress", encodeQuestProgress(self.questProgress))
	self:savePlayerData()
end

function Player:learnRecipe(recipe)
	-- for bugged players
	local hasAllRecipes = true
	for k, v in next, recipesBitList.featureKeys do
		if not self.learnedRecipes[k] then
			hasAllRecipes = false
			break
		end
	end
	if hasAllRecipes then
		system.giveEventGift(self.name, "evt_nobles_quest_title_543")
	end
	if self.learnedRecipes[recipe] then return end
	self.learnedRecipes[recipe] = true
	local item = Item.items[recipe]
	tfm.exec.chatMessage(translate("NEW_RECIPE", self.language, nil, { itemName = item.locales[self.language], itemDesc = item.description_locales[self.language] }), self.name)
	local hasAllRecipes = true
	for k, v in next, recipesBitList.featureKeys do
		if not self.learnedRecipes[k] then
			hasAllRecipes = false
			break
		end
	end
	if hasAllRecipes then
		system.giveEventGift(self.name, "evt_nobles_quest_title_543")
	end
	dHandler:set(self.name, "recipes", recipesBitList:encode(self.learnedRecipes))
	self:savePlayerData()
end

function Player:canCraft(recipe)
	if not self.learnedRecipes[recipe] then return false end
	for _, neededItem in next, recipes[recipe] do
		local idx, amount = nil, 0
		if not neededItem[1].stackable then
			for i, it in next, self.inventory do
				if it[1] and it[1].id == neededItem[1].id then
					idx = i
					amount = amount + 1
				end
			end
		else
			idx, amount = self:getInventoryItem(neededItem[1].id)
		end
		if (not idx) or (neededItem[2] > amount) then return false end
	end
	return true
end

function Player:craftItem(recipe)
	if not self:canCraft(recipe) then return end
	for _, neededItem in next, recipes[recipe] do
		if not neededItem[1].stackable then
			for i = 1, neededItem[2] do
				self:addInventoryItem(neededItem[1], -1)
			end
		else
			self:addInventoryItem(neededItem[1], -neededItem[2])
		end
		--self.inventory[idx][2] = amount - neededItem[2]
	end
	self:addInventoryItem(Item.items[recipe], 1)
end

function Player:dropItem()
	local invSelection = self.inventorySelection
	if #self.inventory[invSelection] == 0 then return end
	local droppedItem = self.inventory[invSelection]
	self.inventory[invSelection] = {}
	self.carriageWeight = self.carriageWeight - droppedItem[1].weight * droppedItem[2]
	self:changeHoldingItem()
	self:changeInventorySlot(invSelection)
	self:displayInventory()
	local pData = tfm.get.room.playerList[self.name]
	local dropId = tfm.exec.addShamanObject(tfm.enum.shamanObject.littleBox, pData.x, pData.y, 45, -2 * self.stance, -2, true)
	Timer.new("drop_item" .. dropId, function()
		local obj = tfm.get.room.objectList[dropId]
		local x, y = obj.x, obj.y
		tfm.exec.removeObject(dropId)
		local area = Area.getAreaByCoords(x, y)
		if not area then return end
		Entity.new(x, y, "dropped_item", area, droppedItem[1], droppedItem[2])
	end, 1000, false)
end

function Player:attack(monster)
	monster:regen()
	if (not self.equipped) or (self.equipped and self.equipped.type == Item.types.SPECIAL) then return end
	local playerObj = tfm.get.room.playerList[self.name]
	tfm.exec.displayParticle(3, playerObj.x - self.stance * 10, playerObj.y, 1)
	local item = self.equipped
	monster.health = monster.health - item.attack
	displayDamage(monster)
	local itemDamage = item.type == Item.types.SWORD and 1 or math.max(1, 4 - item.tier)
	self.equipped.durability = self.equipped.durability - itemDamage
	if item.durability <= 0 then
		self.inventory[self.inventorySelection] = {}
		self:changeInventorySlot(self.inventorySelection)
	end
	monster.latestActionReceived = os.time()
	if monster.health <= 0 then
		monster:destroy(self)
	end
end

function Player:equipShield(equip)
	if equip then
		self.isShielded = true
	else
		self.isShielded = false
	end
end

function Player:processSequence(dir)
	dir = ({3, 0, 1, 2})[dir + 1]
	--[[
		0 - Transformice Left
1 - Transformice Jump
2 - Transformice Right
3 - Transformice Duck
	]]
	if not self.divinePower or not (bossBattleTriggered and self.area) then return end
	local s, v = 816 - 170, 20
	-- s = t(u + v)/2
	-- division by 3 is because the given vx is in a different unit than px/s
	local t = ((2 * s / (v + v - 0.01)) / 3) * 1000
	local currDir = directionSequence[self.sequenceIndex]
	if not currDir then return end
	t = t + currDir[4]
	local diff = math.abs(t - os.time()) / 1000
	if diff <= 1 and dir == currDir[2] then -- it passed the line
		self.sequenceIndex = self.sequenceIndex + 1
		divinePowerCharge = math.min(FINAL_BOSS_ATK_MAX_CHARGE,  divinePowerCharge + (20 - diff * 20))
		self.chargedDivinePower = math.min(FINAL_BOSS_ATK_MAX_CHARGE, self.chargedDivinePower + (20 - diff * 20))
		tfm.exec.addImage("1810e9320a6.png", "#" .. currDir[1], 0, 230, self.name, 1, 1, math.rad(90 * currDir[2]), 1, 0.5, 0.5)
	else -- too late/early
		tfm.exec.addImage("1810e90e75d.png", "#" .. currDir[1], 0, 230, self.name, 1, 1, math.rad(90 * currDir[2]), 1, 0.5, 0.5)
		Timer.new("resetCannon" .. self.name, function()
			tfm.exec.addImage("180e7b47ef5.png", "#" .. currDir[1], 0, 230, self.name, 1, 1, math.rad(90 * currDir[2]), 1, 0.5, 0.5)
		end, 1000, false)
		divinePowerCharge = math.max(0,  divinePowerCharge - 3)
		self.chargedDivinePower = math.max(0, self.chargedDivinePower - 3)
	end
end

function Player:toggleDivinePower()
	if self.area == 3 and self.spiritOrbs == 62 and not bossBattleTriggered then
		self.divinePower = not self.divinePower
		self.isShielded = false
		tfm.exec.freezePlayer(self.name, self.divinePower, false)
		if self.divinePower then
			self.divineImage = tfm.exec.addImage("18105fc6781.png", "$" .. self.name, -22, -20)
		else
			tfm.exec.removeImage(self.divineImage)
		end
	end
end

function Player:destroy()
	local name = self.name
	tfm.exec.killPlayer(name)
	for key, code in next, keys do system.bindKeyboard(name, code, true, false) end
	self.alive = false
	divinePowerCharge = divinePowerCharge - self.chargedDivinePower
	self:setArea(-1, -1) -- area is heaven :)
end

function Player:savePlayerData()
	if not self.dataLoaded then return end
	local name = self.name
	local inventory = {}
	local typeSpecial, typeResource = Item.types.SPECIAL, Item.types.RESOURCE
	for i, itemData in next, self.inventory do
		if #itemData > 0 then
			local item, etc = itemData[1], itemData[2]
			inventory[i] = { item.nid, item.type == typeSpecial, item.type == typeResource, item.durability or etc }
		else
			inventory[i] = {}
		end
	end
	dHandler:set(name, "inventory", encodeInventory(inventory))
	dHandler:set(name, "spiritOrbs", self.spiritOrbs)
	dHandler:set(name, "questProgress", encodeQuestProgress(self.questProgress))
	system.savePlayerData(name, "v2" .. dHandler:dumpPlayer(name))
end

recipes = {
	basic_axe = {
		{ Item.items.stick, 5 },
		{ Item.items.stone, 3 }
	},
	iron_axe = {
		{ Item.items.stick, 5 },
		{ Item.items.iron_ore, 4 }
	},
	copper_axe = {
		{ Item.items.stick, 5},
		{ Item.items.iron_ore, 2} ,
		{ Item.items.copper_ore, 3 }
	},
	gold_axe = {
		{ Item.items.stick, 5 },
		{ Item.items.iron_ore, 1 },
		{ Item.items.copper_ore, 2 },
		{ Item.items.gold_ore, 5 }
	},
	basic_shovel = {
		{ Item.items.wood, 5 },
	},
	iron_shovel = {
		{ Item.items.wood, 3 },
		{ Item.items.iron_ore, 4 }
	},
	copper_shovel = {
		{ Item.items.wood, 3 },
		{ Item.items.iron_ore, 2} ,
		{ Item.items.copper_ore, 3 }
	},
	gold_shovel = {
		{ Item.items.wood, 3 },
		{ Item.items.iron_ore, 1 },
		{ Item.items.copper_ore, 2 },
		{ Item.items.gold_ore, 5 }
	},
	iron_sword = {
		{ Item.items.wood, 5},
		{ Item.items.iron_ore, 5}
	},
	copper_sword = {
		{ Item.items.wood, 3 },
		{ Item.items.iron_ore, 2} ,
		{ Item.items.copper_ore, 3 }
	},
	gold_sword = {
		{ Item.items.wood, 3 },
		{ Item.items.iron_ore, 1 },
		{ Item.items.copper_ore, 2 },
		{ Item.items.gold_ore, 5 }
	},
	iron_shield = {
		{ Item.items.stick, 6 },
		{ Item.items.wood, 2},
		{ Item.items.iron_ore, 4}
	},
	copper_shield = {
		{ Item.items.stick, 6 },
		{ Item.items.wood, 2 },
		{ Item.items.iron_ore, 2 },
		{ Item.items.copper_ore, 3 }
	},
	gold_shield = {
		{ Item.items.stick, 6 },
		{ Item.items.wood, 2 },
		{ Item.items.iron_ore, 1},
		{ Item.items.copper_ore, 2 },
		{ Item.items.gold_ore, 5 }
	},
	log_stakes = {
		{ Item.items.wood, 3 },
	},
	bridge = {
		{ Item.items.log_stakes, 3 },
		{ Item.items.clay, 20 },
		{ Item.items.stone, 8 }
	}
}

recipesBitList = BitList {
	"basic_axe", "iron_axe", "copper_axe", "gold_axe",
	"basic_shovel", "iron_shovel", "copper_shovel", "gold_shovel",
	"iron_sword", "copper_sword", "gold_sword",
	"iron_shield", "copper_shield", "gold_shield",
	"log_stakes", "bridge"
}

local totalRecipes = 0
for recipe in next, recipes do totalRecipes = totalRecipes + 1 end

local totalPages = math.ceil((totalRecipes) / 6)


openCraftingTable = function(player, page, inCraftingTable)
	page = page or 1
	if page < 1 or page > totalPages then return end

	local target = player.name
	local items = Item.items
	craftingPanel:hide(target):show(target)
	Panel.panels[410]:hide(target)

	Panel.panels[351]:update(("<a href='event:%s:%s'><p align='center'><b>%s〈%s</b></p></a>")
		:format(
			page - 1,
			inCraftingTable and 1 or 0,
			page - 1 < 1 and "<N2>" or "",
			page - 1 < 1 and "</N2>" or ""
		)
	, target)
	Panel.panels[352]:update(("<a href='event:%s:%s'><p align='center'><b>%s〉%s</b></p></a>")
		:format(
			page + 1,
			inCraftingTable and 1 or 0,
			page + 1 > totalPages and "<N2>" or "</N2>",
			page + 1 > totalPages and "</N2>" or "</N2>"
		)
	, target)


	local col, row, count = 0, 0, 0
	for i = (page - 1) * 6 + 1, page * 6 do
		local name = recipesBitList:get(i)
		if not name then return end
		-- todo: c hange
		if true then--player.learnedRecipes[name] then
			local item = Item.items[name]
			local recipePanel = Panel(460 + count, "", 380 + col * 120, 100 + row * 120, 100, 100, 0x1A3846, 0x1A3846, 1, true)
			local p = Panel.panels[460 + count + 1] or Panel(460 + count + 1, "", 385 + col * 120, 170 + row * 120, 90, 20, nil, 0x324650, 1, true)
			recipePanel:addImageTemp(Image(item.image, "&1", 410 + col * 120, 110 + row * 120), target)
				:addPanel(p
					:setActionListenerTemp(function(id, name, event)
						displayRecipeInfo(name, event, inCraftingTable)
					end, target)
				)

			if not player.learnedRecipes[name] then recipePanel:addImageTemp(Image(assets.ui.lock, "&1", 380 + col * 120, 80 + row * 120), target) end
			craftingPanel:addPanelTemp(recipePanel, target)
			p:update(("<p align='center'><a href='event:%s'>%s</a></p>"):format(name, item.locales[player.language], target), target)
				--p:show(name)


			col = col + 1
			count = count + 2
			if col >= 3 then
				row = row + 1
				col = 0
			end
		end
	end

end

displayRecipeInfo = function(name, recipeName, inCraftingTable)
	local player = Player.players[name]
	local recipe = recipes[recipeName]
	local item = Item.items[recipeName]
	if not recipe then return end
	local target = name
	Panel.panels[410]:hide(target):show(target)

	Panel.panels[420]:addImageTemp(Image(item.image, "&1", 80, 80), name)
	Panel.panels[420]:update(" <font size='15' face='Lucida console'><b><BV>" .. item.locales[player.language] .. "</BV></b></font>", name)
	if inCraftingTable then
		Panel.panels[450]:update(("<p align='center'><b><a href='event:%s'>%s</a></b></p>")
			:format(
				recipeName,
				(player:canCraft(recipeName) and (translate("CRAFT", player.language))
					or ("<N2>" .. translate("CANT_CRAFT", player.language) .. "</N2>")
				)
			), name)
	else
		Panel.panels[450]:hide(target)
	end

	Panel.panels[451]:update(translate("RECIPE_DESC", player.language, nil, {
		desc = item.description_locales[player.language]
	}), target)

	for i, items in next, recipe do
		local reqItemObj = items[1]
		Panel.panels[452]
			:addPanelTemp(Panel(452 + i,
				(" x %s <i>( %s )</i>"):format(items[2], reqItemObj.locales[player.language]),
			100, 190 + i * 25, 180, 25, nil, nil, 0, true), name)
			:addImageTemp(Image(reqItemObj.image, "&1", 80, 190 + i * 25, 0.6, 0.6), name)
	end

	local col, row = 0, 0
	for i, prop in next, ({ "attack", "defense", "durability", "chopping", "mining" }) do
		if item[prop] and item[prop] ~= 0 then
			Panel.panels[410]:addPanelTemp(
				Panel(480 + i, (" x %s <b>[</b>%s<b>]</b>"):format(item[prop], translate("PROPS", player.language, prop)), 105 + 125 * col, 150 + row * 30, 240, 20, nil, nil, 0, true)
					:addImageTemp(Image(assets.ui[prop], "&1", 75 + 125 * col, 140 + row * 30), name)
			, name)
			col = col + 1
			if col >= 2 then
				row = row + 1
				col = 0
			end
		end


	end

end

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
		--ui.addTextArea(self.imageId, type, nil, x, y, 0, 0, nil, nil, 0, false)
	end
	return self
end

function Entity:receiveAction(player, keydown)
	if self.isDestroyed then return end
	local onAction = Entity.entities[self.type == "npc" and self.name or self.type].onAction
	if onAction then
		local success, error = pcall(onAction, self, player, keydown)
		if error then p({success, error}) end
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
	tfm.exec.removeImage(self.imageId)
end

local getOreFromTier = function(item, rockType)
	local orePool = {}
	local rockTypes = { ["rock"] = 2, ["iron_ore"] = 3, ["copper_ore"] = 4, ["gold_ore"] = 5 }
	local itemTypes = { ["regular_shovel"] = 2, ["iron_shovel"] = 3, ["copper_shovel"] = 4, ["gold_shovel"] = 5 }

	local ores = { Item.items.clay, Item.items.stone, Item.items.iron_ore, Item.items.copper_ore, Item.items.gold_ore }
	rockType = rockTypes[rockType]
	if item.type ~= Item.types.SHOVEL then
		orePool = { 1, 1, 1, 1, 1, 2 }
	else
		item = itemTypes[item]
		for i = 1, rockType do
			-- add ores to the ore pool from lowest to highest tier ore
			for j = 1, math.random((6 - i) * 2) + (rockType == item and 4 or 1) do -- make the chances of ore in the highest tier appear low
				orePool[#orePool + 1] = i
			end
		end
		-- adjust the outcomes to the ore type
		for i = 1, math.random(2, 5) do
			orePool[#orePool + 1] = rockType
		end
		for i = 1, math.random(2, 10) do
			orePool[#orePool + 1] = 1 -- clay
		end
		return ores[orePool[math.random(#orePool)]]
	end
end

local nosferatuTrade = function(player, name, nosferatu)
	addDialogueBox(2, translate("NOSFERATU_DIALOGUES", player.language, 16), name, "Nosferatu", nosferatu.normal, {
		{ translate("NOSFERATU_QUESTIONS", player.language, 3), function(player)
			local idx, stickAmount = player:getInventoryItem("stick")
			if (not stickAmount) or stickAmount < 35 then
				addDialogueBox(2, translate("NOSFERATU_DIALOGUES", player.language, 20), name, "Nosferatu", nosferatu.normal)
			else
				xpcall(player.addInventoryItem, function(err, success)
					if success then
						player:addInventoryItem(Item.items.stick, -35)
						addDialogueBox(2, translate("NOSFERATU_DIALOGUES", player.language, 19), name, "Nosferatu", nosferatu.happy)
					elseif err:match("Full inventory") then
						addDialogueBox(2, translate("NOSFERATU_DIALOGUES", player.language, 18), name, "Nosferatu", nosferatu.thinking)
					end
				end, player, Item.items.stone, 10)
			end
		end, { player } },
		{ translate("NOSFERATU_QUESTIONS", player.language, 4), addDialogueBox, { 2, translate("NOSFERATU_DIALOGUES", player.language, 17), name, "Nosferatu", nosferatu.normal }}
	})
end

Entity.entities = {

	-- resources

	tree = {
		images = {
			{
				id = "180cc69ce37.png",
				xAdj = -20,
				yAdj = -165
			},
			{
				id = "180cc6a2d6e.png",
				xAdj = -20,
				yAdj = -165
			},
			{
				id = "180cc6a7e24.png",
				xAdj = -20,
				yAdj = -165
			}
		},
		resourceCap = 100,
		onAction = function(self, player, down)
			if not down then return end
			if player.equipped == nil then
				self:regen()
				if self.resourcesLeft <= 0 then
					return tfm.exec.chatMessage(translate("OUT_OF_RESOURCES", player.language), player.name)
				end
				player:addInventoryItem(Item.items.stick, 2)
				self.resourcesLeft = self.resourcesLeft - 2
				self.latestActionTimestamp = os.time()
				displayDamage(self)
			elseif player.equipped.type ~= Item.types.SPECIAL then
				player:addInventoryItem(Item.items.wood,
					player:useSelectedItem(Item.types.AXE, "chopping", self)
				)
			end
		end
	},

	rock = {
		images = {
			{
				id = "180a4ca7edc.png",
				xAdj = -20,
				yAdj = -10
			},
			{
				id = "180a4cba62e.png",
				xAdj = -20,
				yAdj = -10
			},
			{
				id = "180a4cbf706.png",
				xAdj = -20,
				yAdj = -16
			}
		},
		resourceCap = 100,
		onAction = function(self, player, down)
			if not down then return end
			if player.equipped == nil or player.equipped.type == Item.types.SPECIAL then return end
			player:addInventoryItem(getOreFromTier(player.equipped, "rock"),
				player:useSelectedItem(Item.types.SHOVEL, "mining", self)
			)
		end
	},

	iron_ore = {
		images = {
			{
				id = "181aaa281d4.png",
				xAdj = -20,
				yAdj = -10
			},
			{
				id = "181aaa2b699.png",
				xAdj = -20,
				yAdj = -10
			},
			{
				id = "181aaa2e7d2.png",
				xAdj = -20,
				yAdj = -16
			}
		},
		resourceCap = 60,
		onAction = function(self, player, down)
			if not down then return end
			if player.equipped == nil or player.equipped.type == Item.types.SPECIAL then return end
			player:addInventoryItem(getOreFromTier(player.equipped, "iron_ore"),
				player:useSelectedItem(Item.types.SHOVEL, "mining", self)
			)
		end
	},

	copper_ore = {
		images = {
			{
				id = "181aa9f7962.png",
				xAdj = -20,
				yAdj = -10
			},
			{
				id = "181aaa07218.png",
				xAdj = -20,
				yAdj = -10
			},
			{
				id = "181aaa05d8c.png",
				xAdj = -20,
				yAdj = -16
			}
		},
		resourceCap = 40,
		onAction = function(self, player, down)
			if not down then return end
			if player.equipped == nil or player.equipped.type == Item.types.SPECIAL then return end
			player:addInventoryItem(getOreFromTier(player.equipped, "copper_ore"),
				player:useSelectedItem(Item.types.SHOVEL, "mining", self)
			)
		end
	},

	gold_ore = {
		images = {
			{
				id = "181aaa1345f.png",
				xAdj = -20,
				yAdj = -10
			},
			{
				id = "181aaa16014.png",
				xAdj = -20,
				yAdj = -10
			},
			{
				id = "181aaa18f1d.png",
				xAdj = -20,
				yAdj = -16
			}
		},
		resourceCap = 20,
		onAction = function(self, player, down)
			if not down then return end
			if player.equipped == nil or player.equipped.type == Item.types.SPECIAL then return end
			player:addInventoryItem(getOreFromTier(player.equipped, "gold_ore"),
				player:useSelectedItem(Item.types.SHOVEL, "mining", self)
			)
		end
	},

	-- triggers

	craft_table = {
		image = {
			id = "180dfe91752.png",
			xAdj = -110,
			yAdj = -120
		},
		onAction = function(self, player, down)
			if down then openCraftingTable(player, 1, true) end
		end
	},

	recipe = {
		image = {
			id = "181aa8a80c6.png",
			yAdj = -10
		},
		onAction = function(self, player, down)
			if down then player:learnRecipe(self.name) end
		end
	},

	teleport = {
		image = {
			id = "181aa8a670a.png"
		},
		onAction = function(self, player, down)
			if not down then return end
			local tpInfo = teleports[self.name]
			local tp1, tp2 = tpInfo[1], tpInfo[2]
			if not tpInfo.canEnter(player, tp2) then
				if tpInfo.onFailure then tpInfo.onFailure(player) end
				return
			end
			local terminal, x, y
			if tp1 == self then
				x, y, terminal = tp2.x, tp2.y, 2
			else
				x, y, terminal = tp1.x, tp1.y, 1
			end
			tfm.exec.movePlayer(player.name, x, y)
			Timer.new("tp_anim", tfm.exec.displayParticle, 10, false, 37, x, y)
			if tpInfo.onEnter then tpInfo.onEnter(player, terminal) end
		end
	},

	dropped_item = {
		image = {
			id = "181aa8a2276.png",
			xAdj = -10,
			yAdj = -10
		},
		onAction = function(self, player, down)
			if not down then return end
			player:addInventoryItem(self.name, self.id)
			self:destroy()
		end
	},

	spirit_orb  = {
		image = {
			id = "180dbcc0036.png"
		},
		onAction = function(self, player, down)
			if not down then return end
			local qProgress = player.questProgress
			if self.name == "5" then
				player:updateQuestProgress("fiery_dragon", 1)
				player:addNewQuest("final_boss")
			end
			player:addNewQuest("spiritOrbs")
			if bit.band(player.spiritOrbs, bit.lshift(1, self.name)) > 0 then return end
			player.spiritOrbs = bit.bor(player.spiritOrbs, bit.lshift(1, self.name))
			tfm.exec.chatMessage(translate("SPIRIT_ORB", player.language), player.name)
			if qProgress.spiritOrbs and qProgress.spiritOrbs.stage == 3 then
				player:updateQuestProgress("spiritOrbs", 1)
			end
			if player.spiritOrbs == 62 then
				system.giveEventGift(player.name, "evt_nobles_quest_title_544")
			end
			player:savePlayerData()
		end
	},

	bridge = {
		image = {
			id = "no.png"
		},
		onAction = function(self, player, down)
			self.building = self.building or false
			self.buildProgress = self.buildProgress or 0
			self.bridges = self.bridges or {}
			if self.building or #self.bridges > 4 then return end
			local inventoryItem = player.inventory[player.inventorySelection][1]
			if (not inventoryItem) or inventoryItem.id ~= "bridge" then return end
			if down then
				self.building = true
				Timer.new("bridge_" .. player.name, function()
					self.buildProgress = self.buildProgress + 1
					displayDamage(self) -- it's progress here
					-- TODO: Change to 20
					if self.buildProgress > 20 then -- 0 then
						Timer._timers["bridge_" .. player.name]:kill()
						self.building = false
						local bridgeCount = #self.bridges + 1
						self.buildProgress = 0
						local w = 120
						tfm.exec.addPhysicObject(100 + bridgeCount, self.x - 20 + bridgeCount * w, self.y + 35, {
							type = 0,
							width = w,
							height = 10,
							friction = 30
						})
						player.inventory[player.inventorySelection] = {}
						player:displayInventory()
						local imgId = tfm.exec.addImage(assets.bridge, "+" .. 100 + bridgeCount, -5, -5)
						self.bridges[bridgeCount] = {100 + bridgeCount, self.x - 20 + bridgeCount * w, self.y + 35, imgId }
						if bridgeCount == 4 then
							tfm.exec.removePhysicObject(4)
						end
					end
				end, 500, true)
			else
				self.building = false
				self.buildProgress = 0
				Timer._timers["bridge_" .. player.name]:kill()
			end
		end
	}

}

-- npcs

do

	-- npc icons
	local nosferatu = {
		normal = "17f171134b8.png",
		shocked = "17f17003375.png",
		thinking = "17f170dc941.png",
		happy = "17f170fda30.png",
		question = "17f17132155.png"
	}

	local garry = {
		sad = "180d2707c36.png"
	}

	local thompson = {
		pointing = "180d28c6772.png",
		thinking = "180d29fd7a6.png",
		happy = "180d2a009e2.png"
	}

	local edric = {
		normal = "180d7901bfb.png",
		surprised = "180d79c0e9c.png",
		happy = "180d79c2837.png",
		exclamation = "180d79cba27.png",
		question = "180d7df87b1.png"
	}

	local saruman = {
		normal = "180dcb867ce.png",
		exclamation = "180dcb7c454.png",
		happy = "180dcb7e119.png",
		question = "180dcb89e56.png"
	}

	local niels = {
		normal = "1817cce7595.png",
		exclamation = "1817ccc59f5.png",
		thinking = "1817ccd79f1.png"
	}

	local monk = {
		normal = "1817ccb3999.png",
		exclamation = "1817cca1b68.png",
		happy = "1817cca6901.png",
		thinking = "1817ccdb8d6.png"
	}

	-- npc metadata

	Entity.entities.nosferatu = {
		displayName = "Nosferatu",
		look = "22;0,4_201412,0,1_301C18,39_FFB753,87_201412+201412+201412+301C18+41201A+201412,36_301C18+301C18+201412+201412+201412+FFBB27+FFECA5+41201A+FFB753,21_41201A,0",
		title = 509,
		female = false,
		lookLeft = true,
		lookAtPlayer = false,
		interactive = true,
		onAction = function(self, player)
			local name = player.name
			player:updateQuestProgress("wc", 1)
			player:addNewQuest("nosferatu")
			dialoguePanel:hide(name)
			local qProgress = player.questProgress.nosferatu
			if not qProgress then return end
			local idx, woodAmount = player:getInventoryItem("wood")
			local idx, oreAmount = player:getInventoryItem("iron_ore")
			if not qProgress.completed then
				if qProgress.stage == 1 and qProgress.stageProgress == 0 then
					addDialogueSeries(name, 2, {
						{ text = translate("NOSFERATU_DIALOGUES", player.language, 1), icon = nosferatu.shocked },
						{ text = translate("NOSFERATU_DIALOGUES", player.language, 2), icon = nosferatu.thinking },
						{ text = translate("NOSFERATU_DIALOGUES", player.language, 3), icon = nosferatu.happy },
						{ text = translate("NOSFERATU_DIALOGUES", player.language, 4), icon = nosferatu.normal },
					}, "Nosferatu", function(id, _name, event)
						if player.questProgress.nosferatu and player.questProgress.nosferatu.stage == 1 then
							xpcall(player.addInventoryItem, function(err, success)
								if success then
									player:updateQuestProgress("nosferatu", 1)
									dialoguePanel:hide(name)
									player:displayInventory()
								elseif err:match("Full inventory") then
									addDialogueBox(2, translate("NOSFERATU_DIALOGUES", player.language, 18), name, "Nosferatu", nosferatu.thinking)
								end
							end, player, Item.items.stone, 20)
						end
					end)
				-- change wood amount later
				elseif qProgress.stage == 2 and woodAmount and woodAmount >= 15 then
					addDialogueSeries(name, 2, {
						{ text = translate("NOSFERATU_DIALOGUES", player.language, 5), icon = nosferatu.normal },
						{ text = translate("NOSFERATU_DIALOGUES", player.language, 6), icon = nosferatu.happy },
						{ text = translate("NOSFERATU_DIALOGUES", player.language, 7), icon = nosferatu.normal },
					}, "Nosferatu", function(id, _name, event)
						if player.questProgress.nosferatu and player.questProgress.nosferatu.stage == 2 then
							dialoguePanel:hide(name)
							player:displayInventory()
							xpcall(player.addInventoryItem, function(err, success)
								if success then
									player:addInventoryItem(Item.items.wood, -15)
									player:updateQuestProgress("nosferatu", 1)
									dialoguePanel:hide(name)
									player:displayInventory()
								elseif err:match("Full inventory") then
									addDialogueBox(2, translate("NOSFERATU_DIALOGUES", player.language, 18), name, "Nosferatu", nosferatu.thinking)
								end
							end, player, Item.items.stone, 10)
						end
					end)
				elseif qProgress.stage == 3 and oreAmount and oreAmount >= 15 then
					addDialogueSeries(name, 2, {
						{ text = translate("NOSFERATU_DIALOGUES", player.language, 8), icon = nosferatu.shocked },
						{ text = translate("NOSFERATU_DIALOGUES", player.language, 9), icon = nosferatu.thinking },
						{ text = translate("NOSFERATU_DIALOGUES", player.language, 10), icon = nosferatu.shocked },
						{ text = translate("NOSFERATU_DIALOGUES", player.language, 11), icon = nosferatu.normal },
						{ text = translate("NOSFERATU_DIALOGUES", player.language, 12), icon = nosferatu.happy },

					}, "Nosferatu", function(id, _name, event)
						if player.questProgress.nosferatu and player.questProgress.nosferatu.stage == 3 then
							xpcall(player.addInventoryItem, function(err, success)
								if success then
									player:addInventoryItem(Item.items.iron_ore, -15)
									player:updateQuestProgress("nosferatu", 1)
									dialoguePanel:hide(name)
									player:displayInventory()
								elseif err:match("Full inventory") then
									addDialogueBox(2, translate("NOSFERATU_DIALOGUES", player.language, 18), name, "Nosferatu", nosferatu.thinking)
								end
							end, player, Item.items.stone, 30)
						end

					end)
				else
					addDialogueBox(2, translate("NOSFERATU_DIALOGUES", player.language, 13), name, "Nosferatu", nosferatu.question, {
						{ translate("NOSFERATU_QUESTIONS", player.language, 1), addDialogueBox, { 2, translate("NOSFERATU_DIALOGUES", player.language, 14), name, "Nosferatu", nosferatu.normal } },
						{ translate("NOSFERATU_QUESTIONS", player.language, 2), addDialogueBox, { 2, translate("NOSFERATU_DIALOGUES", player.language, 15), name, "Nosferatu", nosferatu.normal }},
						{ translate("NOSFERATU_QUESTIONS", player.language, 5), nosferatuTrade, { player, name, nosferatu }}

					})
				end
			else
				addDialogueBox(2, translate("NOSFERATU_DIALOGUES", player.language, 16), name, "Nosferatu", nosferatu.normal, {
					{ translate("NOSFERATU_QUESTIONS", player.language, 3), function(player)
						local idx, stickAmount = player:getInventoryItem("stick")
						if (not stickAmount) or stickAmount < 35 then
							addDialogueBox(2, translate("NOSFERATU_DIALOGUES", player.language, 20), name, "Nosferatu", nosferatu.normal)
						else
							xpcall(player.addInventoryItem, function(err, success)
								if success then
									player:addInventoryItem(Item.items.stick, -35)
									addDialogueBox(2, translate("NOSFERATU_DIALOGUES", player.language, 19), name, "Nosferatu", nosferatu.happy)
								elseif err:match("Full inventory") then
									addDialogueBox(2, translate("NOSFERATU_DIALOGUES", player.language, 18), name, "Nosferatu", nosferatu.thinking)
								end
							end, player, Item.items.stone, 10)
						end
					end, { player } },
					{ translate("NOSFERATU_QUESTIONS", player.language, 4), addDialogueBox, { 2, translate("NOSFERATU_DIALOGUES", player.language, 17), name, "Nosferatu", nosferatu.normal }}
				})
			end
		end
	}

	Entity.entities.edric = {
		displayName = "Lieutenant Edric",
		look = "120;135_49382E+A27D35+49382E+53191E,9_53191E,0,0,19_DCA22E+53191E,53_CBBEB1+53191E,0,25,16_231810+A27D35+8D1C23+49382E",
		title = 267,
		female = false,
		lookLeft = true,
		lookAtPlayer = true,
		interactive = true,
		onAction = function(self, player)
			local name = player.name
			local qProgress = player.questProgress
			if qProgress.strength_test then
				if qProgress.strength_test.completed or qProgress.strength_test.stage > 2 then
					addDialogueBox(3, translate("EDRIC_DIALOGUES", player.language, 9), name, "Lieutenant Edric", edric.exclamation)
					if not qProgress.strength_test.completed then player:updateQuestProgress("strength_test", 1) end
					player:addNewQuest("fiery_dragon")
				else
					if qProgress.strength_test.stage == 2 then
						return addDialogueBox(3, translate("EDRIC_DIALOGUES", player.language, 8), name, "Lieutenant Edric", edric.happy)
					end
					addDialogueBox(3, translate("EDRIC_DIALOGUES", player.language, 6), name, "Lieutenant Edric", edric.question, {
						{ translate("EDRIC_QUESTIONS", player.language, 1), addDialogueBox, { 3, translate("EDRIC_DIALOGUES", player.language, 5), name, "Lieutenant Edric", edric.normal} },
						{ translate("EDRIC_QUESTIONS", player.language, 2), addDialogueSeries,
							{ name, 3, {
								{ text = translate("EDRIC_DIALOGUES", player.language, 7), icon = edric.normal },
								{ text = translate("EDRIC_DIALOGUES", player.language, 8), icon = edric.happy }
							}, "Lieutenant Edric", function(id, name, event)
								dialoguePanel:hide(name)
								player:displayInventory()
								if player.questProgress.strength_test and player.questProgress.strength_test.stage ~= 1 then return end -- delayed packets can result in giving more than 10 stone
								player:updateQuestProgress("strength_test", 1)
							end }
						}
					})
				end
			elseif qProgress.nosferatu and qProgress.nosferatu.completed then
				addDialogueSeries(name, 3, {
					{ text = translate("EDRIC_DIALOGUES", player.language, 1), icon = edric.exclamation },
					{ text = translate("EDRIC_DIALOGUES", player.language, 2), icon = edric.surprised },
					{ text = translate("EDRIC_DIALOGUES", player.language, 3), icon = edric.normal },
					{ text = translate("EDRIC_DIALOGUES", player.language, 4), icon = edric.normal },
					{ text = translate("EDRIC_DIALOGUES", player.language, 5), icon = edric.happy },
				}, "Lieutenant Edric", function(id, _name, event)
					--if player.questProgress.nosferatu and player.questProgress.nosferatu.stage ~= 1 then return end -- delayed packets can result in giving more than 10 stone
					--player:updateQuestProgress("nosferatu", 1)
					player:addNewQuest("strength_test")
					dialoguePanel:hide(name)
					player:displayInventory()

				end)
			else
				addDialogueBox(3, translate("EDRIC_DIALOGUES", player.language, 1), name, "Lieutenant Edric", edric.exclamation)
			end
		end
	}

	Entity.entities.garry = {
		displayName = "Garry",
		look = "126;110_AE752F,0,55_5F524F+554A47+C5B4AE+C5B4AE+332A28+332A28,36_5F524F+554A47+242120+5F524F,0,75_583131+391E1E+1D121A,37_AE752F+AE752F,21_332A28,0",
		title = 439,
		female = false,
		lookAtPlayer = true,
		interactive = true,
		onAction = function(self, player)
			addDialogueBox(4, translate("GARRY_DIALOGUES", player.language, 1), player.name, "Garry", garry.sad)
		end
	}

	Entity.entities.thompson = {
		displayName = "Thompson",
		look = "15;190_443A40+767576+585155+C48945+C48945+202020+E7E6E5,24,0,54,8,0,36,67,0",
		title = 439,
		female = false,
		lookAtPlayer = true,
		interactive = true,
		onAction = function(self, player)
			local name = player.name
			addDialogueBox(4, translate("THOMPSON_DIALOGUES", player.language, 1), player.name, "Thompson", thompson.thinking, {
				{ translate("THOMPSON_QUESTIONS", player.language, 1), addDialogueBox, { 2, translate("THOMPSON_DIALOGUES", player.language, 2), name, "Thompson", thompson.pointing } },
				{ translate("THOMPSON_QUESTIONS", player.language, 2), addDialogueBox, { 2, translate("THOMPSON_DIALOGUES", player.language, 3), name, "Thompson", thompson.happy }}
			})
		end
	}

	Entity.entities.laura = {
		displayName = "Laura",
		look = "9;2_FFAC38,0,0,0,49_532B21+532B21+532B21+FFAC38+FFAC38,26_291511+FFAC38,0,60_291511,0",
		title = 514,
		female = true,
		lookAtPlayer = true,
		interactive = true,
		onAction = function(self, player)
			system.openEventShop("Nobles Quest", player.name)
		end
	}

	Entity.entities.cole = {
		displayName = "Cole",
		look = "1;62_414131+25251E,46_25251E,0,0,60_25251E+414131+25251E+414131+25251E+25251E+25251E+414131+414131+414131,94_482F20+221C16+482F20+221C16,13_414131+54380A+D5B073,76_1F1A16,0;BD9067",
		title = 387,
		female = false,
		lookAtPlayer = true,
		interactive = true,
		onAction = function(self, player)
			addDialogueBox(5, translate("COLE_DIALOGUES", player.language, 2), player.name, "Cole", "180d8434702.png")
		end
	}

	Entity.entities.marc = {
		displayName = "Marc",
		look = "194;0,0,0,0,0,0,0,0,0",
		title = 538,
		female = false,
		lookAtPlayer = true,
		interactive = true,
		onAction = function(self, player)
			addDialogueBox(6, translate("MARC_DIALOGUES", player.language, 1), player.name, "Marc", "181ae1bcb23.png")
		end
	}

	Entity.entities.saruman = {
		displayName = "Saruman",
		look = "158;112,8,0,57_FFFFFF+2E483E,43_2E483E+456458+456458,0,54_74534D+160C2B+0+675548+56413D+D8D5D2+D4BDA5+635043,13,59",
		title = 327,
		female = false,
		lookAtPlayer = true,
		interactive = true,
		onAction = function(self, player)
			local qProgress = player.questProgress
			if qProgress.spiritOrbs.stage == 2 then
				addDialogueSeries(player.name, 7, {
					{ text = translate("SARUMAN_DIALOGUES", player.language, 2), icon = saruman.exclamation },
					{ text = translate("SARUMAN_DIALOGUES", player.language, 3), icon = saruman.normal },
					{ text = translate("SARUMAN_DIALOGUES", player.language, 4), icon = saruman.happy },
					{ text = translate("SARUMAN_DIALOGUES", player.language, 5), icon = saruman.question },
					{ text = translate("SARUMAN_DIALOGUES", player.language, 6), icon = saruman.normal },
					{ text = translate("SARUMAN_DIALOGUES", player.language, 7), icon = saruman.normal },
					{ text = translate("SARUMAN_DIALOGUES", player.language, 8), icon = saruman.normal },
					{ text = translate("SARUMAN_DIALOGUES", player.language, 9), icon = saruman.exclamation },
					{ text = translate("SARUMAN_DIALOGUES", player.language, 10), icon = saruman.normal },
					{ text = translate("SARUMAN_DIALOGUES", player.language, 11), icon = saruman.normal },
					{ text = translate("SARUMAN_DIALOGUES", player.language, 12), icon = saruman.happy },
				}, "Saruman", function(id, name, event)
					-- handle delayed packets/multiple text area callbacks at once
					if qProgress.spiritOrbs.stage == 2 then
						player:updateQuestProgress("spiritOrbs", 1)
						local orbs = 0
						for i = 1, 5 do
							if bit.band(player.spiritOrbs, bit.lshift(1, i)) > 0 then
								orbs = orbs + 1
							end
						end
						player:updateQuestProgress("spiritOrbs", orbs)
					end
					dialoguePanel:hide(name)
					player:displayInventory()
				end)
			else
				if player.spiritOrbs == 62 then
					return addDialogueBox(7, translatee("SARUMAN_DIALOGUES", player.language, 22), player.name, "Saruman", saruman.exclamation)
				end
				addDialogueBox(7, translate("SARUMAN_DIALOGUES", player.language, 13), player.name, "Saruman", saruman.question, {
					{ translate("SARUMAN_QUESTIONS", player.language, 1), addDialogueSeries, { player.name, 7, {
						{ text = translate("SARUMAN_DIALOGUES", player.language, 14), icon = saruman.normal },
						{ text = translate("SARUMAN_DIALOGUES", player.language, 15), icon = saruman.normal },
						{ text = translate("SARUMAN_DIALOGUES", player.language, 16), icon = saruman.happy },
						{ text = translate("SARUMAN_DIALOGUES", player.language, 17), icon = saruman.normal },
						{ text = translate("SARUMAN_DIALOGUES", player.language, 18), icon = saruman.normal },
						{ text = translate("SARUMAN_DIALOGUES", player.language, 19), icon = saruman.normal },
						{ text = translate("SARUMAN_DIALOGUES", player.language, 23), icon = saruman.normal },
						{ text = translate("SARUMAN_DIALOGUES", player.language, 24), icon = saruman.normal },
						{ text = translate("SARUMAN_DIALOGUES", player.language, 20), icon = saruman.happy },
					}, "Saruman", function(id, name, event)
						dialoguePanel:hide(name)
						player:displayInventory()
					end}},
					{ translate("SARUMAN_QUESTIONS", player.language, 2), addDialogueBox, { 7, translate("SARUMAN_DIALOGUES", player.language, 21), player.name, "Saruman", saruman.happy } }
				})
			end
		end
	}

	Entity.entities.monk = {
		displayName = "Monk",
		look = "1;123_403F28,0,30_DFB958+468573+745E43,33_D4C9AF+2F2F25,62_2A2A21+403F28+2F2F25+403F28+27271F+403F28,0,36_2F2823+282220+1A1616+211C18+402E2A+FFEE4A+D0D0D0+2E2019+FFE843,0,47;8C887F",
		title = 544,
		female = false,
		lookAtPlayer = true,
		interactive = true,
		onAction = function(self, player)
			addDialogueSeries(player.name, 8, {{ text = translate("MONK_DIALOGUES", player.language, 1), icon = monk.normal }}, "Monk", function(id, name, event)
				if player.spiritOrbs == 62 then
					addDialogueSeries(player.name, 8, {
						{ text = translate("MONK_DIALOGUES", player.language, 2), icon = monk.exclamation },
						{ text = translate("MONK_DIALOGUES", player.language, 3), icon = monk.happy },
						{ text = translate("MONK_DIALOGUES", player.language, 4), icon = monk.normal },
						{ text = translate("MONK_DIALOGUES", player.language, 5), icon = monk.normal },
						{ text = translate("MONK_DIALOGUES", player.language, 6), icon = monk.normal },
						{ text = translate("MONK_DIALOGUES", player.language, 7), icon = monk.normal },
						{ text = translate("MONK_DIALOGUES", player.language, 8), icon = monk.thinking },
						{ text = translate("MONK_DIALOGUES", player.language, 9), icon = monk.exclamation },
						{ text = translate("MONK_DIALOGUES", player.language, 10), icon = monk.happy },
						{ text = translate("MONK_DIALOGUES", player.language, 11), icon = monk.exclamation },
					}, "Monk", function(id, name, event)
						tfm.exec.chatMessage(translate("ACTIVATE_POWER", player.language), name)
						dialoguePanel:hide(name)
						player:displayInventory()
					end)
				else
					dialoguePanel:hide(name)
					player:displayInventory()
				end
			end)
		end
	}

	Entity.entities.niels = {
		displayName = "Niels",
		look = "4;0,5_2A2B2B,46_55595A+55595A+55595A+6A7071+524945,0,0,4_2E2B29,0,0,16_6F4614+636A6D+8E6A3F+464A63",
		title = 542,
		female = false,
		lookAtPlayer = true,
		interactive = true,
		onAction = function(self, player)
			addDialogueSeries(player.name, 9, {
				{ text = translate("NIELS_DIALOGUES", player.language, 1), icon = niels.exclamation },
				{ text = translate("NIELS_DIALOGUES", player.language, 2), icon = niels.exclamation },
				{ text = translate("NIELS_DIALOGUES", player.language, 3), icon = niels.normal },
				{ text = translate("NIELS_DIALOGUES", player.language, 4), icon = niels.thinking },
				{ text = translate("NIELS_DIALOGUES", player.language, 5), icon = niels.normal },
				{ text = translate("NIELS_DIALOGUES", player.language, 6), icon = niels.exclamation },
			}, "Niels", function(id, name, event)
				dialoguePanel:hide(name)
				player:displayInventory()
			end)

		end

	}

end


--==[[ events ]]==--

eventLoop = function(tc, tr)
	_tc, _tr = tc, tr
	if tr < 5000 and (eventLoaded and not eventEnding) then
		eventEnding = true
		local players = Player.players
		for name in next, tfm.get.room.playerList do
			tfm.exec.freezePlayer(name)
			if players[name] then players[name]:savePlayerData() end
		end
	else
		Timer.process()
		if dragon then dragonLocationCheck(dragon) end
	end
end

eventNewPlayer = function(name)
	if eventLoaded then return end
	local player = Player.new(name)
	player.dataLoaded = system.loadPlayerData(name)
	if not player.dataLoaded then
		tfm.exec.chatMessage(translate("PLAYER_DATA_FAIL_SAFEBACK", player.language), name)
	end
	for key, code in next, keys do system.bindKeyboard(name, code, true, true) end
	system.bindKeyboard(name, keys.DUCK, false, true)
	totalPlayers = totalPlayers + 1
end

eventNewGame = function()

	-- NOTE: Sometimes the script is loaded twice in the same round (detect it when eventNewGame is called twice). You must use system.exit() is this case, because it doesn't load the player data correctly, and the textareas (are duplicated) doesn't trigger eventTextAreaCallback.
	if eventLoaded then
        return system.exit()
    end
	-- NOTE: The event runs in rooms with 1 mouse, should be 4 or 5.
	if not IS_TEST and tfm.get.room.uniquePlayers < 4 then
		return system.exit()
	end

	if mapLoaded then
		-- parsing information from xml
		local xml = tfm.get.room.xmlMapInfo.xml
		local dom = parseXml(xml)

		for z, ground in ipairs(path(dom, "Z", "S", "S")) do
			local areaId = tonumber(ground.attribute.lua)
			if areaId and ground.attribute.ignore ~= "true" then
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
end

eventPlayerDataLoaded = function(name, data)
	-- reset player data if they are stored according to the old version
	local player = Player.players[name]
	xpcall(function()
		if data:find("^v2") then
			dHandler:newPlayer(name, data:sub(3))
		else
			system.savePlayerData(name, "")
			dHandler:newPlayer(name, "")
		end
	end, function(err, success)
		if not success then
			p({name, data, err})
			tfm.exec.chatMessage(translate("PLAYER_DATA_FAIL_SAFEBACK", player.language), name)
		end
	end)


	player.spiritOrbs = dHandler:get(name, "spiritOrbs")
	player.learnedRecipes = recipesBitList:decode(dHandler:get(name, "recipes"))

	local questProgress = dHandler:get(name, "questProgress")
	-- remove
	if questProgress == "" then
		--player.questProgress =  { wc = { stage = 1, stageProgress = 0, completed = false } }
		player:addNewQuest("wc")
	else
		player.questProgress = decodeQuestProgress(dHandler:get(name, "questProgress"))
	end

	local inventory = { {}, {}, {}, {}, {}, {}, {}, {}, {}, {} }
	local items = Item.items
	local itemNIds = items._all
	for i, itemData in next, decodeInventory(dHandler:get(name, "inventory")) do
		if not itemData[1] then
			inventory[i] = {}
		else
			local item = items[itemNIds[itemData[1]]]:getItem()
			local isSpecialItem = itemData[2]
			local isResource = itemData[3]
			if isSpecialItem then
				inventory[i] = { item, 1 }
			elseif isResource then
				inventory[i] = { item, itemData[4] }
			else -- is a tool
				item.durability = itemData[4]
				inventory[i] = { item, 1 }
			end
			player.carriageWeight = player.carriageWeight + inventory[i][1].weight * inventory[i][2]
		end
	end
	player.inventory = inventory

	-- stuff
	player:displayInventory()
	player:changeInventorySlot(1)


	if not player.questProgress.wc.completed then
		addDialogueSeries(name, 1, {
			{ text = translate("ANNOUNCER_DIALOGUES", player.language, 1), icon = "180c6ce0308.png" },
			{ text = translate("ANNOUNCER_DIALOGUES", player.language, 2), icon = "180c6ce0308.png" },
			{ text = translate("ANNOUNCER_DIALOGUES", player.language, 3), icon = "180c6ce0308.png" },
			{ text = translate("ANNOUNCER_DIALOGUES", player.language, 4), icon = "180c6ce0308.png" },
			{ text = translate("ANNOUNCER_DIALOGUES", player.language, 5), icon = "180c6ce0308.png" },
			{ text = translate("ANNOUNCER_DIALOGUES", player.language, 6), icon = "180c6ce0308.png" },
			{ text = translate("ANNOUNCER_DIALOGUES", player.language, 7), icon = "180c6ce0308.png" },
		}, "Announcer", function(id, _name, event)
			dialoguePanel:hide(name)
			player:displayInventory()
			if not player.questProgress.wc.completed then
				player:updateQuestProgress("wc", 1)
				player:addNewQuest("nosferatu")
			end
		end)
	end


	if true and not dHandler:get(name, "missingRewardsGiven") then
		print("[INFO] Giving missing rewards")
		local missing = 0
		for i, quest in next, ({ "nosferatu", "strength_test", "fiery_dragon" }) do
			if player.questProgress[quest] and player.questProgress[quest].completed then
				missing = missing + 1
			end
		end
		for i = 1, missing - 1 do
			system.giveEventGift(name, "evt_nobles_quest_golden_ticket_20")
			dHandler:set(name, "missingRewardsGiven", true)
		end
		player:savePlayerData()
	end

	if player.questProgress.nosferatu and player.questProgress.nosferatu.completed then
		mineQuestCompletedPlayers = mineQuestCompletedPlayers + 1
	else
		mineQuestIncompletedPlayers = mineQuestIncompletedPlayers + 1
	end

	totalProcessedPlayers =  totalProcessedPlayers + 1

	mapPlaying = "mine"
	if totalProcessedPlayers == totalPlayers then
	--[[	if (mineQuestCompletedPlayers / tfm.get.room.uniquePlayers) <= 0.2 then
			mapPlaying = "mine"
		elseif math.random(1, 10) <= 4 then
			mapPlaying = "mine"
		else
			mapPlaying = "castle"
		end
		--mapPlaying ="castle"
		--tfm.exec.newGame(maps[mapPlaying])
		--tfm.exec.setGameTime(180)
		--mapLoaded = true
	]]
		if mineQuestCompletedPlayers > 0 then
			if math.random(1, 10) <= 5 then
				mapPlaying = "mine"
			else
				mapPlaying = "castle"
			end
		end
	end
	--mapPlaying = "castle"

	Timer.new("startMap", function(mapPlaying)
		tfm.exec.newGame(maps[mapPlaying], false)
		tfm.exec.setGameTime(180)
		mapLoaded = true
		questProgressButton:show()
	end, 3100, false, mapPlaying)

end

eventKeyboard = function(name, key, down, x, y)
	local player = Player.players[name]

	if key == keys.LEFT then
		player.stance = 1
	elseif key == keys.RIGHT then
		player.stance = -1
	end
	if player.actionCooldown > os.time() then return end

	if player.alive and key >= keys.KEY_0 and keys.KEY_9 >= key then
		local n = tonumber(table.find(keys, key):sub(-1))
		n = n == 0 and 10 or n
		player:changeInventorySlot(n)
	elseif key == keys.KEY_P then
		openCraftingTable(player)
	elseif key == keys.KEY_X then
		player:dropItem()
	elseif key == keys.KEY_U then
		player:toggleDivinePower()
	end

	if (not player.alive) or (not player:setArea(x, y)) then return end

	if down then player:processSequence(key) end

	if key == keys.DUCK then
		local area = Area.areas[player.area]
		local inventoryItem = player.inventory[player.inventorySelection][1]
		local monster = area:getClosestMonsterTo(x, y)
		if inventoryItem and inventoryItem.id:match("shield") then
			player:equipShield(down)
		elseif monster then
			player:attack(monster)
		else
			local entity = area:getClosestEntityTo(x, y)
			if entity then
				entity:receiveAction(player, down)
			end
		end
	end
	player.actionCooldown = os.time() + 400

end

do

	local npcNames = {
		["Nosferatu"] = "nosferatu",
		["Lieutenant Edric"] = "edric",
		["Garry"] = "garry",
		["Thompson"] = "thompson",
		["Laura"] = "laura",
		["Cole"] = "cole",
		["Marc"] = "marc",
		["Saruman"] = "saruman",
		["Niels"] = "niels",
		["Monk"] = "monk"
	}

	eventTalkToNPC = function(name, npc)
		local player = Player.players[name]
		if player.actionCooldown > os.time() then return end
		Entity.entities[npcNames[npc]]:onAction(Player.players[name])
		player.actionCooldown = os.time() + 500
	end
end

eventTextAreaCallback = function(id, name, event)
	local player = Player.players[name]
	if player.actionCooldown > os.time() then return end
	Panel.handleActions(id, name, event)
	player.actionCooldown = os.time() + 500
end
eventContactListener = function(name, id, contactInfo)
	local player = Player.players[name]
	local bulletData = projectiles[id - 12000]
	local stun = bulletData[2]
	local imageData = bulletData[4]
	player.health = player.health - bulletData[1]
	displayDamage(player)
	if stun then
		tfm.exec.freezePlayer(name, true, false)
		local imageId
		if imageData then
			imageId = tfm.exec.addImage(imageData[1], imageData[2], imageData[3], imageData[4])
		end
		Timer.new("stun" .. name, function(name, imageId)
			tfm.exec.freezePlayer(name, false, false)
			if imageId then tfm.exec.removeImage(imageId) end
		end, bulletData[3], false, name, imageId)

		if bulletData[1] > 0 then
			local x, y = tfm.get.room.playerList[name].x, tfm.get.room.playerList[name].y
			Timer.new("getDizzy" .. name, function(x, y)
				tfm.exec.displayParticle(29, x - 20, y - 35, 1)
				tfm.exec.displayParticle(29, x + 10, y - 35, -1)
				Timer.new("dizzy" .. name, function(x, y)
					tfm.exec.displayParticle(29, x - 20, y - 35, 1)
					tfm.exec.displayParticle(29, x + 10, y - 35, -1)
				end, 500, false, x, y)
			end, 500, false, x, y)
		end
	end
end
function eventPopupAnswer(id, name, answer)
	local player = Player.players[name]
	if id == 69 and player.questProgress.spiritOrbs then
		local tfmPlayer = tfm.get.room.playerList[name]
		if answer == "11" .. tfmPlayer.id .. "" .. tfmPlayer.title then
			x, y = 351, 773
			tfm.exec.movePlayer(name, x, y)
			Timer.new("tp_anim", tfm.exec.displayParticle, 10, false, 37, x, y)
		else
			tfm.exec.chatMessage(translate("WRONG_GUESS", player.language), name)
		end
	end
end

--==[[ main ]]==--

createPrettyUI = function(id, x, y, w, h, fixed, closeButton)

	local window = Panel(id * 100 + 10, "", x - 4, y - 4, w + 8, h + 8, 0x7f492d, 0x7f492d, 1, fixed)
		:addPanel(
			Panel(id * 100 + 20, "", x, y, w, h, 0x152d30, 0x0f1213, 1, fixed)
		)
		:addImage(Image(assets.widgets.borders.topLeft, "&1", x - 10, y - 10))
		:addImage(Image(assets.widgets.borders.topRight, "&1", x + w - 18, y - 10))
		:addImage(Image(assets.widgets.borders.bottomLeft, "&1", x - 10, y + h - 18))
		:addImage(Image(assets.widgets.borders.bottomRight, "&1", x + w - 18, y + h - 18))

	if closeButton then
		window
			:addPanel(
				Panel(id * 100 + 30, "<a href='event:close'>\n\n\n\n\n\n</a>", x + w + 18, y - 10, 15, 20, nil, nil, 0, fixed)
				:addImage(Image(assets.widgets.closeButton, ":0", x + w + 15, y - 10)
				)
			)
			:setCloseButton(id * 100 + 30)
	end

	return window

end


inventoryPanel = Panel(100, "", 30, 350, 740, 50, nil, nil, 0, true)
	:addImage(Image(assets.ui.inventory, "~1", 20, 320))
	:addPanel(Panel(150, "INFO", 370, 342, 66, 80, nil, nil, 0, true))

do
	for i = 0, 9 do
		local x = 76 + (i >= 5 and 50 or 0) + 62 * i
		inventoryPanel:addPanel(Panel(101 + i, "", x, 350, 40, 40, nil, nil, 0, true))
		inventoryPanel:addPanel(Panel(121 + i, "", x + 25, 340, 0, 0, nil, nil, 0, true))
	end
end

dialoguePanel = Panel(200, "", 0, 0, 0, 0, nil, nil, 0, true)
	:addPanel(Panel(201, "", 0, 0, 0, 0, nil, nil, 0, true))

giveReward = function(name, level)
	local rewards
	if level == 0 then
		rewards = { 1, 11, 24, 23, 23, 23, 23, 2514, 4, 4, 4, 4, 4, 21, -1, -1, -1, -1, -1, -1 , 2240, 2240, 2240,}
	else
		rewards = { 2257, 2497, 2257, 2497, 2257, 2497 }
	end
	local reward = rewards[math.random(#rewards)]
	if reward == -1 then return end
	tfm.exec.giveConsumables(name, reward)
end

craftingPanel = createPrettyUI(3, 360, 40, 380, 340, true, true)-- main shop window
	:addPanel(
		Panel(351, "〈", 620, 350, 40, 20, nil, 0x324650, 1, true)
		:setActionListener(function(id, name, event)
			local args = stringutils.split(event, ":")
			openCraftingTable(Player.players[name], tonumber(args[1]), args[2] == "1")
		end)
	):addPanel(
		Panel(352, "〉", 680, 350, 40, 20, nil, 0x324650, 1, true)
		:setActionListener(function(id, name, event)
			local args = stringutils.split(event, ":")
			openCraftingTable(Player.players[name], tonumber(args[1]), args[2] == "1")
		end)
	)
	:addPanel(-- preview window
		createPrettyUI(4, 70, 40, 260, 340, true, false)
		:addPanel(Panel(451, "", 160, 60, 150, 90, nil, nil, 0, true)) -- recipe descriptions
		:addPanel(Panel(452, "", 80, 160, 100, 100, nil, nil, 0, true)) -- recipe info
		:addPanel(Panel(450, "", 80, 355, 240, 20, nil, 0x324650, 1, true)
			:setActionListener(function(id, name, event)
				if not recipes[event] then return end
				local player = Player.players[name]
				if not player:canCraft(event) then return end
				local success, err = pcall(player.craftItem, player, event)
				if not success then
					for _, neededItem in next, recipes[event] do
						if not neededItem[1].stackable then
							for i = 1, neededItem[2] do
								player:addInventoryItem(neededItem[1], 1)
							end
						else
							player:addInventoryItem(neededItem[1], neededItem[2])
						end
						--self.inventory[idx][2] = amount - neededItem[2]
					end
					tfm.exec.chatMessage(translate("FULL_INVENTORY", player.language), name)
				end
				player:displayInventory()
				player:changeInventorySlot(player.inventorySelection)
				displayRecipeInfo(name, event, true)
				player:savePlayerData()
			end)
		)
	):setCloseButton(330, function(name)
		local player = Player.players[name]
		if not player then return end
		player:displayInventory()
	end)

divineChargePanel = Panel(400, "", 30, 110, 600, 50, nil, nil, 0, true)
	:addImage(Image(assets.ui.marker, "&1", 158, 15))
	:addImage(Image(assets.ui.divine_panel, "&1", 170, 215))

questProgressPanel = createPrettyUI(7, 270, 50, 260, 330, true, true)

questProgressButton = Panel(600, "<a href='event:quests'>\n\n\n</a>", 0, 30, 50, 36, nil, nil, 0, true)
	:setActionListener(function(id, name, event)
		local player = Player.players[name]
		questProgressPanel:show(name)
		local ongoing = ""
		local completed = "\n\n"
		for n, quest in next, player.questProgress do
			local q = quests[n]
			local questName = q.title_locales[player.language] or q.title_locales["en"]
			if quest.completed then
				completed = completed .. translate("QUEST_OVER", player.language, nil, { questName = questName }) .. "\n"
			else
				ongoing = ongoing ..
					("<font color='#506d3d'>[</font> <font color='#c6b392'>•</font> <font color='#506d3d'>]</font> <font color='#ab5e42' face='Lucida Console'><b>%s</b></font>\n- %s <font color='#bd9d60' size='11' face='Lucida Console'>( %s / %s )</font>\n")
						:format(
							questName,
							q[quest.stage].description_locales[player.language] or q[quest.stage].description_locales["en"],
							quest.stageProgress,
							q[quest.stage].tasks
						)
			end
		end
		Panel.panels[720]:update(translate("QUESTS", player.language) .. ongoing .. completed, name)
	end)
	:addImage(Image(assets.ui.questProgress, "~1", 0, 30))

addDialogueBox = function(id, text, name, speakerName, speakerIcon, replies)
	local x, y, w, h = 30, 350, type(replies) == "table" and 600 or 740, 50
	-- to erase stuff that has been displayed previously, if this dialoguebox was a part of a conversation
	dialoguePanel:hide(name)
	inventoryPanel:hide(name)
	dialoguePanel:show(name)
	print(name)
	local isReplyBox = type(replies) == "table"
	dialoguePanel:addPanelTemp(Panel(id * 1000, text, x + (isReplyBox and 25 or 20), y, w, h, 0, 0, 0, true)
		:addImageTemp(Image(assets.ui[isReplyBox and "dialogue_replies" or "dialogue_proceed"], "~1", 20, 280), name),
		name)
	Panel.panels[id * 1000]:update(text, name)
	dialoguePanel:addPanelTemp(Panel(id * 1000 + 1, "<b><font size='10'>" .. (speakerName or "???") .. "</font></b>", x + w - 180, y - 25, 0, 0, nil, nil, 0, true), name)
	--dialoguePanel:addImageTemp(Image("171843a9f21.png", "&1", 730, 350), name)
	Panel.panels[201]:addImageTemp(Image(speakerIcon, "&1", x + w - 100, y - 55), name)
	--dialoguePanel:update(text, name)
	if isReplyBox then
		local minusY = -10
		for i, reply in next, replies do
			dialoguePanel:addImageTemp(Image(assets.ui.reply, "~1", x + w - 10, y - 10 + 26 * (i - 1) + minusY, 1.1, 0.9), name)
			local p = Panel.panels[id * 1000 + 10 + i] or Panel(id * 1000 + 10 + i, "", x + w - 6, y - 6 + 24 * (i - 1) + minusY, 130, 25, nil, nil, 0, true)
			dialoguePanel:addPanelTemp(p
			:setActionListenerTemp(function(id, name, event)
				reply[2](table.unpack(reply[3]))
			end, name),
			name)
			p:update(("<a href='event:reply'>%s</a>"):format(reply[1]), name)
		end
	else
		dialoguePanel:addImageTemp(Image(assets.ui.btnNext, "~1", x + w - 25, y + h - 30), name)
		local p = Panel.panels[id * 1000 + 10] or Panel(id * 1000 + 10, "<a href='event:2'>\n\n\n</a>", x + w - 25, y + h - 30, 30, 30, nil, nil, 0, true)

		dialoguePanel:addPanelTemp(p
			:setActionListenerTemp(replies or function(id, name, event)
				dialoguePanel:hide(name)
				Player.players[name]:displayInventory()
			end, name)
			, name)
	end
end

addDialogueSeries = function(name, id, dialogues, speakerName, conclude)
	local x, y, w, h = 30, 350, 740, 50
	addDialogueBox(id, dialogues[1].text, name, speakerName, dialogues[1].icon, function(id2, name, event)
		local page = tonumber(event)
		if not page or page < 0 then return conclude(id2, name, event) end -- events from arbitary packets
		if page > #dialogues then return conclude(id2, name, event) end
		Panel.panels[id * 1000]:update(dialogues[page].text, name)
		Panel.panels[201]:hide(name)
		Panel.panels[201]:show(name)
		Panel.panels[201]:addImageTemp(Image(dialogues[page].icon, "&1", x + w - 100, y - 55), name)
		Panel.panels[id * 1000 + 10]:update(("<a href='event:%d'>\n\n\n</a>"):format(page + 1), name)
	end)
end


displayDamage = function(target)
	local bg, fg
	if target.type == "bridge" then
		bg = tfm.exec.addImage(assets.damageBg, "!1", target.x, target.y)
		fg = tfm.exec.addImage(assets.damageFg, "!2", target.x + 1, target.y + 1, nil, target.buildProgress / 20)
	elseif target.__type == "entity" then
		bg = tfm.exec.addImage(assets.damageBg, "!1", target.x, target.y)
		fg = tfm.exec.addImage(assets.damageFg, "!2", target.x + 1, target.y + 1, nil, target.resourcesLeft / target.resourceCap)
	elseif target.__type == "monster" then
		local isBoss = 	target.species == Monster.all.fiery_dragon or target.species == Monster.all.final_boss
		if isBoss then
			bg = tfm.exec.addImage(assets.damageBg, "!1", target.realX or target.x, target.y, nil, 4, 2)
			fg = tfm.exec.addImage(assets.damageFg, "!2", (target.realX or target.x) + 2, target.y + 2, nil, (target.health / target.metadata.health) * 4, 2)
		else
			local obj = tfm.get.room.objectList[target.objId]
			bg = tfm.exec.addImage(assets.damageBg, "=" .. target.objId, 0, -30)
			fg = tfm.exec.addImage(assets.damageFg, "=" .. target.objId, 1, 1 - 30, nil, target.health / target.metadata.health)
		end
	elseif target.__type == "player" then
		bg = tfm.exec.addImage(assets.damageBg, "$" .. target.name, 0, -30)
		fg = tfm.exec.addImage(assets.damageFg, "$" .. target.name, 1, -30 + 1, nil, target.health / 50)
	end
	Timer.new("damage" .. bg, tfm.exec.removeImage, 1500, false, bg)
	Timer.new("damage" .. fg, tfm.exec.removeImage, 1500, false, fg)
end

encodeInventory = function(inventory)
	local res = ""
	for i, data in next, inventory do
		if #data == 0 then
			res = res .. string.char(0)
		else
			local c = bit.lshift(data[1], 2)
			c = bit.bor(c, data[2] and 2 or 0)
			c = bit.bor(c, data[3] and 1 or 0)
			res = res .. string.char(c)
			if not data[2] then
				res = res .. string.char(data[4])
			end
		end
	end
	return base64Encode(res)
end

decodeInventory = function(data)
	data = base64Decode(data)
	local res = {}
	local i = 1
	while i <= #data do
		local c = string.byte(data, i)
		if c == 0 then
			res[#res + 1] = {}
			i = i + 1
		else
			local id = bit.rshift(bit.band(c, 252), 2)
			local isSpecialItem = bit.band(c, 2) > 0
			local isResource = bit.band(c, 1) == 1
			if isSpecialItem then
				res[#res + 1] = { id, isSpecialItem, isResource }
				i = i + 1
			else
				res[#res + 1] = { id, isSpecialItem, isResource, string.byte(data, i + 1) }
				i = i + 2
			end
		end
	end
	return res
end

encodeQuestProgress = function(pQuests)
	local res = ""
	local questIds = quests._all
	for quest, progress in next, pQuests do
		local c = bit.lshift(quests[quest].id, 1)
		c = bit.bor(c, progress.completed and 1 or 0)
		res = res .. string.char(c)
		if not progress.completed then
			res = res .. string.char(progress.stage, progress.stageProgress)
		end
	end
	return base64Encode(res)
end

decodeQuestProgress = function(data)
	data = base64Decode(data)
	local res = {}
	local questIds = quests._all
	local i = 1
	while i <= #data do
		local c = string.byte(data, i)
		local questId = questIds[bit.rshift(c, 1)]
		local completed = bit.band(c, 1) == 1
		i = i + 1
		local stage, stageProgress
		if not completed then
			stage = string.byte(data, i)
			i = i + 1
			stageProgress = string.byte(data, i)
			i = i + 1
		end
		res[questId] = { stage = stage, stageProgress = stageProgress, completed = completed }
	end
	return res
end

getVelocity = function(x_to, x_from, y_to, y_from, t)
	local vcostheta = (x_to - x_from) / t
	local vsintheta = (y_to - y_from + 10 * t ^ 2) / t
	return vcostheta * 1.2, vsintheta * 1.2
end

fadeInSlowly = function(time, imageId, target, xPosition, yPosition, targetPlayer, scaleX, scaleY, angle, alpha, anchorX, anchorY)
	local iterations = time / 500
	local images = {}
	local co
	co = coroutine.create(function()
		for i = 1, math.ceil(iterations) do
			Timer.new(string.format("fadeIn_%s_%s", imageId, i), function()
				images[#images + 1] = tfm.exec.addImage(imageId, target, xPosition, yPosition, targetPlayer, scaleX, scaleY, angle, (i / iterations) * alpha, anchorX, anchorY, true)
				if i >= iterations then
					coroutine.resume(co)
				end
			end, 500 * i, false)
		end
		coroutine.yield()
		-- I'm not really sure how to return values from coroutines so we have this for now
		Timer.new("removeFinal", function()
			for i = 1, #images do
				tfm.exec.removeImage(images[i], true)
			end
		end, 3000, false)
	end)

	coroutine.resume(co)

end

teleports = {
	mine = {
		canEnter = function(player, terminalId)
			local quest = player.questProgress.nosferatu
			return quest and (quest.completed or quest.stage >= 3)
		end,
		onEnter = function(player, terminalId)
			tfm.exec.setPlayerNightMode(terminalId == 2, player.name)
		end,
		onFailure = function(player)
			tfm.exec.chatMessage(translate("PORTAL_ENTER_FAIL", player.language), player.name)
		end
	},
	castle = {
		canEnter = function() return true end,
		onEnter = function(player, terminalId)
			if terminalId == 2 then
				addDialogueBox(5, translate("COLE_DIALOGUES", player.language, 1), player.name, "Cole", "180d8434702.png")
			end
		end
	},
	arena = {
		canEnter = function(player, terminalId)
			local quest = player.questProgress.strength_test
			return quest and (quest.completed or quest.stage >= 2)
		end,
		onFailure = function(player)
			tfm.exec.chatMessage(translate("PORTAL_ENTER_FAIL", player.language), player.name)
		end
	},
	bridge = {
		canEnter = function(player, terminalId)
			local quest = player.questProgress.strength_test
			return quest and quest.completed
		end,
		onFailure = function(player)
			addDialogueBox(5, translate("COLE_DIALOGUES", player.language, 3), player.name, "Cole", "180d8434702.png")
		end
	},
	shrines = {
		canEnter = function() return true end,
		onEnter = function(player, terminalId)
			if (not player.questProgress.spiritOrbs) or player.questProgress.spiritOrbs.stage == 1 then
				player:addNewQuest("spiritOrbs")
				player:updateQuestProgress("spiritOrbs", 1)
				print("came here and should update smh")
				addDialogueBox(7, translate("SARUMAN_DIALOGUES", player.language, 1), player.name, "???", "180dbd361b5.png", function()
					dialoguePanel:hide(player.name)
					player:displayInventory()
				end)
			end
			tfm.exec.setPlayerNightMode(terminalId == 2, player.name)
		end
	},
	final_boss = {
		canEnter = function(player)
			return (player.questProgress.final_boss) and not bossBattleTriggered
		end,
		onEnter = function(player, terminalId)
			if player.spiritOrbs == 62 then
				tfm.exec.chatMessage(translate("DIVINE_POWER_TOGGLE_REMINDER", player.language), player.name)
			end
		end,
		onFailure = function(player, terminalId)
			tfm.exec.chatMessage(translate("PORTAL_ENTER_FAIL", player.language), player.name)
		end
	},
	enigma = {
		canEnter = function(player, terminalId) return terminalId == 1 end,
		onFailure = function(player)
			local tfmPlayer = tfm.get.room.playerList[player.name]
			ui.addPopup(69, 2, translate("PASSCODE", player.language), player.name, tfmPlayer.x - 10, tfmPlayer.y - 10, nil, false)
		end
	}
}

do
	eventNewGame()
	for name, player in next, tfm.get.room.playerList do
		eventNewPlayer(name)
	end
end


