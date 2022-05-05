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

local prettify
-- https://github.com/a801-luadev/useful-stuff/blob/master/prettyprint.lua
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

	prettify = function(obj, depth, opt, checked)
		opt = opt or {}
		opt.maxDepth = opt.maxDepth or 30
		opt.truncateAt = opt.truncateAt or 30

		local prettifyFn = typeLookup[type(obj)]
		if (prettifyFn) then return { res = (prettifyFn(tostring(obj))), count = 1 } end -- not the type of object ({}, [])

		if checked[obj] then
			return {
				res = ("<b><V>circular</V></b>"):format(tostring(obj)),
				count = 1
			}
		end

		if depth >= opt.maxDepth then
			return {
				res = ("<b><V>%s</V></b>"):format(tostring(obj)),
				count = 1
			}
		end

		checked[obj] = true

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
				local prettified = prettify(value, depth + 1, opt, checked)
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

local prettyprint = function(obj, opt) print(prettify(obj, 0, opt or {}, {}).res) end
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
