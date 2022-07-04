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
