--==[[ libs ]]==--

local stringutils = {}
stringutils.format = function(s, tab) return (s:gsub('($%b{})', function(w) return tab[w:sub(3, -2)] or w end)) end

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

	function Image.new(imageId, target, x, y, parent)

		local self = setmetatable({
			id = #Image.images + 1,
			imageId = imageId,
			target = target,
			x = x,
			y = y,
			instances = {},
		}, Image)

		Image.images[self.id] = self

		return self

	end

	function Image:show(target)
		if target == nil then error("Target cannot be nil") end
		if self.instances[target] then return self end
		self.instances[target] = tfm.exec.addImage(self.imageId, self.target, self.x, self.y, target)
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
			temporary = {}
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
		title_locales = {
			en = "New person in the town"
		},
		{
			description_locales = {
				en = "Start your journey in this town and please edit this ugly desc later"
			},
			tasks = 1
		}
	},

	giveWood = {
		title_locales = {
			en = "Some nice title"
		},
		{
			description_locales = {
				en = "Meet Nosferatu at the mine"
			},
			tasks = 1
		},
		{
			description_locales = {
				en = "Gather wood"
			},
			tasks = 1
		}
	}

}

--==[[ init ]]==--

local IS_TEST = true

-- NOTE: Sometimes the script is loaded twice in the same round (detect it when eventNewGame is called twice). You must use system.exit() is this case, because it doesn't load the player data correctly, and the textareas (are duplicated) doesn't trigger eventTextAreaCallback.
local eventLoaded = false
local mapPlaying = ""

local maps = {
	mine = [[<C><P L="4800" H="800" defilante="0,0,0,1" MEDATA=";;11,1;;-0;0:::1-"/><Z><S><S T="8" X="1437" Y="712" L="318" H="175" P="0,0,0.3,0.2,0,0,0,0" c="4" lua="2"/><S T="8" X="208" Y="560" L="374" H="204" P="0,0,0.3,0.2,0,0,0,0" c="4" lua="3"/><S T="8" X="1281" Y="193" L="216" H="91" P="0,0,0.3,0.2,0,0,0,0" c="2" lua="4"/><S T="8" X="3575" Y="624" L="1066" H="454" P="0,0,0.3,0.2,0,0,0,0" c="2" lua="7"/><S T="8" X="845" Y="690" L="332" H="182" P="0,0,0.3,0.2,-60,0,0,0" c="4" lua="5"/><S T="8" X="284" Y="93" L="532" H="244" P="0,0,0.3,0.2,0,0,0,0" c="4" lua="6"/><S T="12" X="155" Y="433" L="300" H="37" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="802" Y="771" L="1600" H="18" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="12" Y="402" L="778" H="18" P="0,0,0.3,0.2,90,0,0,0" o="324650"/><S T="12" X="1610" Y="420" L="778" H="18" P="0,0,0.3,0.2,90,0,0,0" o="324650"/><S T="12" X="1404" Y="609" L="399" H="36" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="1615" Y="692" L="44" H="210" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="1216" Y="624" L="25" H="67" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="13" X="1327" Y="784" L="53" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="892" Y="650" L="824" H="27" P="0,0,0.3,0.2,20,0,0,0" o="324650"/><S T="12" X="433" Y="390" L="295" H="32" P="0,0,0.3,0.2,-20,0,0,0" o="324650"/><S T="12" X="459" Y="548" L="295" H="32" P="0,0,0.3,0.2,-40,0,0,0" o="324650"/><S T="12" X="903" Y="276" L="295" H="32" P="0,0,0.3,0.2,-10,0,0,0" o="324650"/><S T="12" X="416" Y="701" L="802" H="184" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="1021" Y="801" L="560" H="184" P="0,0,0.3,0.2,20,0,0,0" o="324650"/><S T="12" X="1382" Y="487" L="450" H="224" P="0,0,0.3,0.2,-30,0,0,0" o="324650"/><S T="12" X="1500" Y="300" L="218" H="594" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="804" Y="-10" L="1622" H="70" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="358" Y="215" L="678" H="28" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="708" Y="218" L="49" H="28" P="0,0,0.3,0.2,10,0,0,0" o="324650"/><S T="12" X="1269" Y="374" L="452" H="266" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="270" Y="189" L="538" H="36" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="1297" Y="239" L="196" H="36" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="456" Y="625" L="220" H="102" P="0,0,0.3,0.2,30,0,0,0" o="324650"/><S T="13" X="835" Y="627" L="59" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="3909" Y="392" L="1786" H="28" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="3035" Y="590" L="30" H="428" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="3911" Y="793" L="1774" H="26" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="4786" Y="589" L="32" H="418" P="0,0,0.3,0.2,0,0,0,0" o="324650"/><S T="12" X="3418" Y="770" L="477" H="63" P="0,0,0.3,0.2,0,0,0,0" o="324650"/></S><D><DS X="40" Y="394"/></D><O><O X="364" Y="129" C="22" nosync="" P="0" type="tree"/><O X="88" Y="543" C="22" nosync="" P="0" type="tree"/><O X="936" Y="607" C="22" nosync="" P="0" type="tree"/><O X="308" Y="587" C="22" nosync="" P="0" type="tree"/><O X="214" Y="121" C="22" nosync="" P="0" type="tree"/><O X="442" Y="119" C="22" nosync="" P="0" type="rock"/><O X="300" Y="127" C="22" nosync="" P="0" type="tree"/><O X="1460" Y="718" C="22" nosync="" P="0" type="npc" name="nosferatu"/><O X="1301" Y="204" C="22" nosync="" P="0" type="craft_table"/><O X="131" Y="578" C="22" nosync="" P="0" type="recipe" name="basic_shovel"/><O X="201" Y="570" C="22" nosync="" P="0" type="rock"/><O X="253" Y="562" C="22" nosync="" P="0" type="recipe" name="basic_axe"/><O X="79" Y="143" C="14" nosync="" P="0" type="monster_spawn"/><O X="1562" Y="736" C="11" nosync="" P="0" route="mine" id="1"/><O X="3105" Y="459" C="11" nosync="" P="0" route="mine" id="2"/></O><L/></Z></C>]]
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
	--[[version = {
		index = 8,
		type = "string",
		default = "v0.0.0.0"
	}]]
})


--==[[ translations ]]==--

local translations = {}

translations["en"] = {
	ANNOUNCER_DIALOGUES = {
		"Princess die yes yes"
	},
	NOSFERATU_DIALOGUES = {
		"Ahh you look quite new here... anyways you look like useful",
		"So you are telling, you came to here from another dimension, and have no idea where you are or what to do at all\n<i>*Hmmm maybe he is actually useful for me</i>",
		"Well young fella, I guess you need a job to live. Don't worry about that, I'll give you a job yes yes.",
		"But... before that, we need to check if you are in a good physical state.\nGather <VP>10 wood</VP> for me from the woods.\nHave these <VP>10 stone</VP> as an advance. Good luck!",
		"Do you need anything?"
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
		if dist <= 30 and dist < min then
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
		local obj = objList[monster.objId]
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
	self.health = metadata.health
	self.metadata = metadata
	self.stance = -1 -- right
	self.decisionMakeCooldown = os.time()
	self.latestActionCooldown = os.time()
	self.latestActionReceived = os.time()
	self.lastAction = "move"
	self.objId = tfm.exec.addShamanObject(10, self.x, self.y)
	tfm.exec.moveObject(self.objId, 0, 0, true, -20, -20, false, 0, true)
	Monster.monsters[id] = self
	self.area.monsters[id] = self
	return self
end

function Monster:action()
	if self.latestActionCooldown > os.time() then return end
	local obj = tfm.get.room.objectList[self.objId]
	self.x, self.y = obj.x, obj.y
	-- monsters are not fast enough to calculate new actions, in other words dumb
	-- if somebody couldn't get past these monsters, I call them noob
	if self.decisionMakeCooldown > os.time() then
		if self.lastAction == "move" then
			-- keep moving to the same direction till the monster realized he did a bad move
			tfm.exec.moveObject(self.objId, 0, 0, true, self.stance * 20, -20, false, 0, true)

		end
	else
		-- calculate the best move
		local lDists, lPlayers, lScore, rDists, rPlayers, rScore = {}, {}, 0, {}, {}, 0
		for name in next, self.area.players do
			local player = tfm.get.room.playerList[name]
			local dist = math.pythag(self.x, self.y, player.x, player.y)
			if dist <= 300 then
				if player.x < self.x  then -- player is to left
					lDists[#lDists + 1] = dist
					lPlayers[dist] = name
					lScore = lScore + 310 - dist
				else
					rDists[#rDists + 1] = dist
					rPlayers[dist] = name
					rScore = rScore + 310 - dist
				end
			end
		end
		table.sort(lDists)
		table.sort(rDists)

		if self.stance == -1 then
			local normalScore = lScore / math.max(#lDists, 1)
			if lDists[1] and lDists[1] < 60 then
				self:attack(lPlayers[lDists[1]], "slash")
			elseif rDists[1] and rDists[1] < 60 then
				self:changeStance(1)
				self:attack(rPlayers[rDists[1]], "slash")
			elseif normalScore > 100 then
				self:move()
			elseif normalScore > 10 then
				self:attack(lPlayers[lDists[math.random(#lDists)]], "bullet")
			elseif lScore > rScore then
				self:move()
			else
				self:changeStance(1)
				self:move()
			end
		else
			local normalScore = rScore / math.max(#rDists, 1)
			if rDists[1] and rDists[1] < 60 then
				self:attack(rPlayers[rDists[1]], "slash")
			elseif lDists[1] and lDists[1] < 60 then
				self:changeStance(1)
				self:attack(lPlayers[lDists[1]], "slash")
			elseif normalScore > 100 then
				self:move()
			elseif normalScore > 10 then
				self:attack(rPlayers[rDists[math.random(#rDists)]], "bullet")
			elseif lScore < rScore then
				self:move()
			else
				self:changeStance(-1)
				self:move()
			end
		end
		self.decisionMakeCooldown = os.time() + 1500
	end
	self.latestActionCooldown = os.time() + 1000
end

function Monster:changeStance(stance)
	self.stance = stance
end

function Monster:attack(player, attackType)
	p({player, attackType})
	local playerObj = Player.players[player]
	self.lastAction = "attack"
	if attackType == "slash" then
		playerObj.health = playerObj.health - 2.5
	end
	if playerObj.health < 0 then
		playerObj:destroy()
	end
	displayDamage(playerObj)
end

function Monster:move()
	tfm.exec.moveObject(self.objId, 0, 0, true, self.stance * 20, -20, false, 0, true)
	self.lastAction = "move"
end

function Monster:regen()
	local healthCurr, healthOriginal = self.health, self.metadata.health
	if healthCurr < healthOriginal then
		local regenAmount = math.floor(os.time() - self.latestActionReceived) / 6000
		self.health = math.min(healthOriginal, healthCurr + regenAmount)
	end
end

function Monster:destroy()
	tfm.exec.removeObject(self.objId)
	Monster.monsters[self.id] = nil
	self.area.monsters[self.id] = nil
	self = nil
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

Trigger.triggers = {

	monster_spawn = {
		onactivate = function(self)
			Monster.new({ health = 20 }, self)
		end,
		ontick = function(self)
			for _, monster in next, self.area.monsters do
				if monster then monster:action() end
			end
		end,
		ondeactivate = function(self)
			-- to prevent invalid keys to "next"
			local previousMonster
			for i, monster in next, self.area.monsters do
				if previousMonster then previousMonster:destroy() end
				previousMonster = monster
			end
			if previousMonster then previousMonster:destroy() end
		end
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
Item.items = {}

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
	SPECIAL 	= 100
}


function Item.new(id, type, stackable, locales, description_locales, attrs)
	local self = setmetatable({}, Item)
	self.id = id
	self.type = type
	self.stackable = stackable
	self.locales = locales
	self.description_locales = description_locales or {}

	if type ~= Item.types.RESOURCE and type ~= Item.types.SPECIAL then
		-- basic settings for most of the basic tools
		self.durability = 10
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
	return self
end

function Item:getItem()
	if self.type == Item.types.RESOURCE then return self end
	return table.copy(self)
end

-- Setting up the items
Item("stick", Item.types.RESOURCE, true, {
	en = "Stick"
})

Item("stone", Item.types.RESOURCE, true, {
	en = "Stone"
})

Item("wood", Item.types.RESOURCE, true, {
	en = "Wood"
})

-- Special items
Item("basic_axe", Item.types.AXE, false, {
	en = "Basic axe"
}, {
	en = "Just a basic axe"
}, {
	durability = 10,
	chopping = 1
})

Item("basic_shovel", Item.types.SHOVEL, false, {
	en = "Basic shovel"
}, {
	en = "Evolution started here"
}, {
	durability = 10,
	mining = 3
})
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
	self.health = 50
	self.alive = true
	self.inventory = { {}, {}, {}, {}, {}, {}, {}, {}, {}, {} }
	self.learnedRecipes = {}
	self.questProgress = {
		-- quest: stage, stageProgress, completed?
		wc = { stage = 1, stageProgress = 0, completed = false }
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
	if quantity <= 0 then return end
	if newItem.stackable then
		local invPos, itemQuantity = self:getInventoryItem(newItem.id)
		if invPos then
			self.inventory[invPos][2] = itemQuantity + quantity
			if invPos == self.inventorySelection then self:changeInventorySlot(invPos) end
			return self:displayInventory()
		end
	end
	for i, item in next, self.inventory do
		if #item == 0 then
			self.inventory[i] = { newItem:getItem(), quantity }
			if i == self.inventorySelection then self:changeInventorySlot(i) end
			return self:displayInventory()
		end
	end
end

-- use some kind of class based thing to add items

function Player:changeInventorySlot(idx)
	if idx < 0 or idx > 10 then return end
	self.inventorySelection = idx
	local item = self.inventory[idx][1]
	if item and item.type ~= Item.types.RESOURCE then
		print("item is special")
		self.equipped = self.inventory[idx][1]
	else
		p({"item is not epsicla", item})
		self.equipped = nil
	end
	self:displayInventory()
end

function Player:displayInventory()
	local invSelection = self.inventorySelection
	inventoryPanel:show(self.name)
	for i, item in next, self.inventory do
		if i == invSelection then
			Panel.panels[100 + i]:update("<b>" .. prettify({item[1] and item[1].id, item[2]}, 1, {}).res .. "</b>", self.name)
		else
			Panel.panels[100 + i]:update(prettify({item[1] and item[1].id, item[2]}, 1, {}).res, self.name)
		end
	end
end

function Player:useSelectedItem(requiredType, requiredProperty, targetEntity)
	targetEntity:regen()
	if (not item[requiredProperty] == 0) or targetEntity.resourcesLeft <= 0 then
		tfm.exec.chatMessage("cant use")
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
	p(self.inventory)
	-- give resources equivelant to the tier level of the item if they are using the correct item for the job
	local returnAmount = isCorrectItem and (item.tier + item[requiredProperty] - 1) or 1
	targetEntity.resourcesLeft = math.max(targetEntity.resourcesLeft - returnAmount, 0)
	displayDamage(targetEntity)
	targetEntity.latestActionTimestamp = os.time()
	return returnAmount
end

function Player:addNewQuest(quest)
	self.questProgress[quest] = { stage = 1, stageProgress = 0, completed = false }
	tfm.exec.chatMessage("New quest")
end

function Player:updateQuestProgress(quest, newProgress)
	local pProgress = self.questProgress[quest]
	local progress = pProgress.stageProgress + newProgress
	local q = quests[quest]
	self.questProgress[quest].stageProgress = progress
	if progress >= quests[quest][pProgress.stage].tasks then
		if pProgress.stage >= #q then
			tfm.exec.chatMessage("Quest completed")
			self.questProgress[quest].completed = true
		else
			tfm.exec.chatMessage("New stage")
			self.questProgress[quest].stage = self.questProgress[quest].stage + 1
			self.questProgress[quest].stageProgress = 0
		end
	end
end

function Player:learnRecipe(recipe)
	if self.learnedRecipes[recipe] then return end
	self.learnedRecipes[recipe] = true
	tfm.exec.chatMessage("Learned a new recipe")
end

function Player:canCraft(recipe)
	if not self.learnedRecipes[recipe] then return false end
	for _, neededItem in next, recipes[recipe] do
		local idx, amount = self:getInventoryItem(neededItem[1].id)
		p({neededItem[1], idx, amount})
		if (not idx) or (neededItem[2] > amount) then return false end
	end
	return true
end

function Player:craftItem(recipe)
	if not self:canCraft(recipe) then return p("cant craft") end
	for _, neededItem in next, recipes[recipe] do
		local idx, amount = self:getInventoryItem(neededItem[1].id)
		self.inventory[idx][2] = amount - neededItem[2]
	end
	self:addInventoryItem(Item.items[recipe], 1)
end

function Player:attack(monster)
	if self.equipped == nil then
		monster:regen()
		monster.health = monster.health - 2
		displayDamage(monster)
	elseif player.equipped.type ~= Item.types.SPECIAL then

	end
	monster.latestActionReceived = os.time()
	if monster.health <= 0 then
		monster:destroy()
	end
end

function Player:destroy()
	local name = name
	tfm.exec.killPlayer(name)
	for key, code in next, keys do system.bindKeyboard(self.name, code, true, false) end
	self.alive = false
	self:setArea(-1, -1) -- area is heaven :)
end

function Player:savePlayerData()
	local name = self.name
	system.savePlayerData(name, "v2" .. dHandler:dumpPlayer(name))
end

recipes = {
	basic_axe = {
		{ Item.items.stick, 5 },
		{ Item.items.stone, 3 }
	},
	basic_shovel = {
		{ Item.items.wood, 5 },
	}
}

openCraftingTable = function(player)
	local name = player.name
	--craftingPanel:show(name)
	--craftingPanel:update(prettify(player.learnedRecipes, 1, {}).res, player)
	-- craft all the craftable recipes for now
	for recipeName in next, player.learnedRecipes do
		player:craftItem(recipeName)
	end
end

local Entity = {}

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

Entity.entities = {

	-- resources

	tree = {
		image = {
			id = "no.png",
			xAdj = 0,
			yAdj = 0
		},
		resourceCap = 100,
		onAction = function(self, player)
			if player.equipped == nil then
				self:regen()
				if self.resourcesLeft <= 0 then
					return tfm.exec.chatMessage("cant use")
				end
				player:addInventoryItem(Item.items.stick, 2)
				self.resourcesLeft = self.resourcesLeft - 2
				self.latestActionTimestamp = os.time()
				displayDamage(self)
			elseif player.equipped.type ~= Item.types.SPECIAL then
				player:addInventoryItem(Item.items.wood,
					player:useSelectedItem(Item.types.AXE, "chopping", self)
				)
			else
				p(player.equipped)
			end
		end
	},

	rock = {
		image = {
			id = "no.png",
			xAdj = 0,
			yAdj = 0
		},
		resourceCap = 100,
		onAction = function(self, player)
			if player.equipped == nil or player.equipped.type == Item.types.SPECIAL then return end
			player:addInventoryItem(Item.items.stone,
				player:useSelectedItem(Item.types.SHOVEL, "mining", self)
			)
		end
	},

	iron_ore = {
		image = {
			id = "no.png",
			xAdj = 0,
			yAdj = 0
		}
	},

	-- triggers

	craft_table = {
		image = {
			id = "no.png"
		},
		onAction = function(self, player)
			openCraftingTable(player)
		end
	},

	recipe = {
		image = {
			id = "no.png"
		},
		onAction = function(self, player)
			player:learnRecipe(self.name)
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

	-- npc metadata

	Entity.entities.nosferatu = {
		displayName = "Nosferatu",
		image = {
			id = "17ebeab46db.png",
			xAdj = 0,
			yAdj = -35
		},
		onAction = function(self, player)
			local name = player.name
			local qProgress = player.questProgress["giveWood"]
			if not qProgress then return end
			local idx, amount = player:getInventoryItem("wood")
			print({"wood", amount})
			if not qProgress.completed then
				if qProgress.stage == 1 and qProgress.stageProgress == 0 then
					addDialogueSeries(name, 2, {
						{ text = translate("NOSFERATU_DIALOGUES", player.language, 1), icon = nosferatu.shocked },
						{ text = translate("NOSFERATU_DIALOGUES", player.language, 2), icon = nosferatu.thinking },
						{ text = translate("NOSFERATU_DIALOGUES", player.language, 3), icon = nosferatu.happy },
						{ text = translate("NOSFERATU_DIALOGUES", player.language, 4), icon = nosferatu.normal },
					}, "Nosferatu", function(id, _name, event)
						if player.questProgress.giveWood and player.questProgress.giveWood.stage ~= 1 then return end -- delayed packets can result in giving more than 10 stone
						player:updateQuestProgress("giveWood", 1)
						dialoguePanel:hide(name)
						player:addInventoryItem(Item.items.stone, 10)
						player:displayInventory()

					end)
				elseif qProgress.stage == 2 and amount and amount >= 10 then
					addDialogueSeries(name, 3, {
						{ text = "ok u suck", icon = "17ebeab46db.png" },
					}, "Nosferatu", function(id, _name, event)
						if player.questProgress.giveWood and player.questProgress.giveWood.stage ~= 2 then return end -- delayed packets can result in giving more than 10 stone
						player:updateQuestProgress("giveWood", 1)
						dialoguePanel:hide(name)
						player:displayInventory()
					end)
				end
			else
				addDialogueBox(10, "Do you need anything?", name, "Nosferatu", nosferatu.question, { "How do I get wood?", "Axe?" })
			end
		end
	}

end

function Entity.new(x, y, type, area, name)
	local self = setmetatable({}, Entity)
	self.x = x
	self.y = y
	self.type = type
	self.area = area
	self.name = name
	area.entities[#area.entities + 1] = self
	if type == "npc" then
		local npc = Entity.entities[name]
		local xAdj, yAdj = x + (npc.image.xAdj or 0), y + (npc.image.yAdj or 0)
		local id = tfm.exec.addImage(npc.image.id, "?999", xAdj, yAdj)
		ui.addTextArea(id, Entity.entities[name].displayName, nil, xAdj - 10, yAdj, 0, 0, nil, nil, 0, false)
	else
		local entity = Entity.entities[type]
		self.resourceCap = entity.resourceCap
		self.resourcesLeft = entity.resourceCap
		self.latestActionTimestamp = -1/0
		local id = tfm.exec.addImage(entity.image.id, "?999", x + (entity.image.xAdj or 0), y + (entity.image.yAdj or 0))
		ui.addTextArea(id, type, nil, x, y, 0, 0, nil, nil, 0, false)
	end
	return self
end

function Entity:receiveAction(player)
	local onAction = Entity.entities[self.type == "npc" and self.name or self.type].onAction
	if onAction then
		onAction(self, player)
	end
end

function Entity:regen()
	if self.resourcesLeft < self.resourceCap then
		local regenAmount = math.floor(os.time() - self.latestActionTimestamp) / 2000
		self.resourcesLeft = math.min(self.resourceCap, self.resourcesLeft + regenAmount)
	end
end


--==[[ events ]]==--

eventLoop = function(tc, tr)
	Timer.process()
end

eventNewPlayer = function(name)
	Player.new(name)
	system.loadPlayerData(name)
	for key, code in next, keys do system.bindKeyboard(name, code, true, true) end
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

	for name, player in next, tfm.get.room.playerList do
		eventNewPlayer(name)
	end

	-- parsing information from xml
	local xml = tfm.get.room.xmlMapInfo.xml
	local dom = parseXml(xml)

	for z, ground in ipairs(path(dom, "Z", "S", "S")) do
		local areaId = tonumber(ground.attribute.lua)
		if areaId then
			Area.new(ground.attribute.X, ground.attribute.Y, ground.attribute.L, ground.attribute.H)
		end
	end

	for z, obj in ipairs(path(dom, "Z", "O", "O")) do
		if obj.attribute.type then
			local x, y = tonumber(obj.attribute.X), tonumber(obj.attribute.Y)
			local area, attrC, attrType = Area.getAreaByCoords(x, y), obj.attribute.C, obj.attribute.type
			if attrC == "22" then	-- entities
				Entity.new(x, y, attrType, area, obj.attribute.name)
			elseif attrC == "14" then
				Trigger.new(x, y, attrType, area)
			end
		end
	end

	eventLoaded = true
end

eventPlayerDataLoaded = function(name, data)
	-- reset player data if they are stored according to the old version
	if data:find("^v2") then
		dHandler:newPlayer(name, data:sub(3))
	else
		system.savePlayerData(name, "")
		dHandler:newPlayer(name, "")
	end

	local player = Player.players[name]
	-- stuff

	player:displayInventory()

	if not player.questProgress.wc.completed then
		--[[addDialogueBox(1, "Welcome to the town loser", name, "Announcer", "17088637078.png", function(id, name, event)
			addDialogueBox(2, "There's nothign to look at here lmao, just get it over", name, "Announcer", "17088637078.png", function()
				player:updateQuestProgress("wc", 1)
				dialoguePanel:hide(name)
				player:displayInventory(name)
			end)
		end)]]
		addDialogueSeries(name, 1, {
			{ text = "Welcome to the town loser", icon = "17088637078.png" },
			{ text = "yes that works", icon = assets.ui.btnNext },
			{ text = "yes yes now close this", icon = "17088637078.png" },
		}, "Announcer", function(id, _name, event)
			player:updateQuestProgress("wc", 1)
			dialoguePanel:hide(name)
			player:displayInventory(name)
			player:addNewQuest("giveWood")
		end)
	end

end

eventKeyboard = function(name, key, down, x, y)
	local player = Player.players[name]
	if (not player.alive) or (not player:setArea(x, y)) then return end
	if key == keys.DUCK then
		local area = Area.areas[player.area]
		local monster = area:getClosestMonsterTo(x, y)
		if monster then
			player:attack(monster)
		else
			local entity = area:getClosestEntityTo(x, y)
			if entity then
				entity:receiveAction(player)
			end
		end
	elseif key >= keys.KEY_0 and keys.KEY_9 >= key then
		player:changeInventorySlot(tonumber(table.find(keys, key):sub(-1)))
	end

end
eventTextAreaCallback = function(id, name, event)
	Panel.handleActions(id, name, event)
end

--==[[ main ]]==--

tfm.exec.newGame(maps["mine"])
mapPlaying = "mine"

tfm.exec.setGameTime(150)

inventoryPanel = Panel(100, "", 30, 350, 740, 50, nil, nil, 1, true)
do
	for i = 0, 9 do
		inventoryPanel:addPanel(Panel(101 + i, "", 30 + 74 * i, 350, 50, 50, nil, nil, 1, true))
	end
end

dialoguePanel = Panel(200, "", 0, 0, 0, 0, nil, nil, 0, true)
	:addPanel(Panel(201, "", 0, 0, 0, 0, nil, nil, 0, true))

craftingPanel = Panel(300, "", 20, 30, 760, 300, nil, nil, 1, true)

addDialogueBox = function(id, text, name, speakerName, speakerIcon, replies)
	local x, y, w, h = 30, 350, type(replies) == "table" and 600 or 740, 50
	-- to erase stuff that has been displayed previously, if this dialoguebox was a part of a conversation
	dialoguePanel:hide(name)
	inventoryPanel:hide(name)
	dialoguePanel:show(name)

	dialoguePanel:addPanelTemp(Panel(id * 1000, text, x, y, w, h, 0x472315, 0xd1b130, 1, true), name)
	dialoguePanel:addPanelTemp(Panel(id * 1000 + 1, speakerName or "???", x + w - 150, y, 0, 0, nil, nil, 1, true), name)
	--dialoguePanel:addImageTemp(Image("171843a9f21.png", "&1", 730, 350), name)
	Panel.panels[201]:addImageTemp(Image(speakerIcon, "&1", x + w - 80, y - 20), name)
	dialoguePanel:update(text, name)
	if type(replies) == "table" then
		for i, reply in next, replies do
			dialoguePanel:addPanelTemp(Panel(id * 1000 + 10 + i, reply, x + w + 30, y - 10 + 20 * (i - 1), 130, 25, nil, nil, 0, true), name)
			dialoguePanel:addImageTemp(Image(assets.ui.reply, ":1", x + w, y - 10 + 20 * (i - 1)), name)
		end
	else
		dialoguePanel:addImageTemp(Image(assets.ui.btnNext, "&1", x + w - 20, y + h - 20), name)
		dialoguePanel:addPanelTemp(
			Panel(id * 1000 + 10, "<a href='event:2'>\n\n\n</a>", x + w + 20, y + h - 20, 30, 30, nil, nil, 1, true)
				:setActionListener(replies)
		, name)
	end
end

addDialogueSeries = function(name, id, dialogues, speakerName, conclude)
	local x, y, w, h = 30, 350, 740, 50
	addDialogueBox(id, dialogues[1].text, name, speakerName, dialogues[1].icon, function(id2, name, event)
		local page = tonumber(event)
		if not page or page < 0 then return end -- events from arbitary packets
		if page > #dialogues then return conclude(id2, name, event) end
		Panel.panels[id * 1000]:update(dialogues[page].text, name)
		Panel.panels[201]:hide(name)
		Panel.panels[201]:show(name)
		Panel.panels[201]:addImageTemp(Image(dialogues[page].icon, "&1", x + w - 80, y - 20), name)
		Panel.panels[id * 1000 + 10]:update(("<a href='event:%d'>\n\n\n</a>"):format(page + 1), name)
	end)
end


displayDamage = function(target)
	local bg, fg
	if target.__type == "entity" then
		bg = tfm.exec.addImage(assets.damageBg, "?999", target.x, target.y)
		fg = tfm.exec.addImage(assets.damageFg, "?999", target.x + 1, target.y + 1, nil, target.resourcesLeft / target.resourceCap)
	elseif target.__type == "monster" then
		local obj = tfm.get.room.objectList[target.objId]
		bg = tfm.exec.addImage(assets.damageBg, "?999", obj.x, obj.y - 30)
		fg = tfm.exec.addImage(assets.damageFg, "?999" .. target.objId, obj.x + 1, obj.y + 1 - 30, nil, target.health / target.metadata.health)
	elseif target.__type == "player" then
		bg = tfm.exec.addImage(assets.damageBg, "$" .. target.name, 0, -30)
		fg = tfm.exec.addImage(assets.damageFg, "$" .. target.name, 1, -30 + 1, nil, target.health / 50)
	end
	Timer.new("damage" .. bg, tfm.exec.removeImage, 1500, false, bg)
	Timer.new("damage" .. fg, tfm.exec.removeImage, 1500, false, fg)
end


