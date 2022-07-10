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
		},
		{
			description_locales = {
				ar = "سافر من وقت لآخر إلى بلدة في العصور الوسطى",
				en = "Travel back from time to a town in the medieval era",
				pl = "Cofnij się w czasie do średniowiecznego miasta",
				ro = "Călătorește înapoi în timp într-un orășel din evul mediu",
				tr = "Ortaçağ döneminde bulunan bir şehire zamanda geri git",
				es = "Viaja atrás en el tiempo hacia un poblado en la época medieval",
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
		},
		{
			description_locales = {
			ar = "قابل نوسفيراتو في المنجم",
			en = "Meet Nosferatu at the mine",
			pl = "potkaj się z Nosferatu w kopalni",
			ro = "Întâlnește-l pe Nosferatu lângă mină",
			tr = "Madende Nosferatu ile buluş",
			es = "Ve con Nosferatu a la mina",
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
		},
		{
			description_locales = {
				ar = "اجمع الوصفات وتحدث إلى الملازم إدريك",
				en = "Gather recipes and talk to Lieutenant Edric",
				pl = "Zbierz przepisy i porozmawiaj z porucznikiem Edriciem",
				ro = "Adună rețete pentru a vorbi cu Locotenentul Edric",
				tr = "Tarifleri elde et ve Lieutenant Edric ile konuş",
				es = "Recolecta recetas y habla con el Teniente Edric",
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
		},
		{
			description_locales = {
				ar = "اذهب إلى الغابة القاتمة",
				en = "Go to the gloomy forest",
				pl = "Udaj się do ponurego lasu",
				ro = "Intră în pădurea mohorâtă",
				tr = "Kasvetli ormana git",
				es = "Ve al bosque sombrío",
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
		},
		{
			description_locales = {
				ar = "تدمير التنين الناري وجمع الجرم السماوي الروحي",
				en = "Destroy the fiery dragon and collect its spirit orb",
				pl = "Zniszcz ognistego smoka i zbierz jego duchową kulę",
				ro = "Distruge Dragonul de foc și pune mâna pe globul său de spirit",
				tr = "Alevli ejderhayı yok et ve ruh küresini elde et",
				es = "Destruye al dragón de fuego y recolecta su orbe espiritual",
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
		},
		{
			description_locales = {
				ar = "اهلك الروح الشريرة",
				en = "Destroy the evil spirit",
				pl = "Zniszcz złego ducha",
				ro = "Distruge spiritul răului",
				tr = "Kötü ruhu yok et",
				es = "Destruye el espíritu malvado",
			},
			tasks = 1
		}
	},

	_all = { "wc", "nosferatu", "strength_test", "spiritOrbs", "fiery_dragon", "final_boss" }

}


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



t = [[BwoBAAgBAAMF]]
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

t = { final_boss = { completed = true }, fiery_dragon = { completed = true }, wc = { completed = true }, strength_test = { completed = true }, nosferatu = { completed = true },     
spiritOrbs = { completed = false, stage = 3, stageProgress = 4 } }
p(encodeQuestProgress(t))

self = {
	monsterCount = 4,
	area = {
		playerCount = 10
	}
}

print(lowerLimit)
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
recipesBitList = BitList {
	"basic_axe", "iron_axe", "copper_axe", "gold_axe",
	"basic_shovel", "iron_shovel", "copper_shovel", "gold_shovel",
	"iron_sword", "copper_sword", "gold_sword",
	"iron_shield", "copper_shield", "gold_shield",
	"log_stakes", "bridge"
}

v2evt_nq={65535,"Bw0LCAMDAwU=","AAAAAAAAAAAAAA==",42,1}
p(recipesBitList:decode(65535))