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