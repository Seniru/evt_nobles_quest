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
}, {
   defense = 20,
   durability = 35
   }
)