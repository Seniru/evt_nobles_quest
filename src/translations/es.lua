-- theme color pallete: https://www.colourpod.com/post/173929539115/a-medieval-recipe-for-murder-submitted-by

translations["es"] = {
	OUT_OF_RESOURCES = "<font color='#ab5e42'>[</font> <font color='#c6b392'>•</font> <font color='#ab5e42'>]</font> <font color='#c6b392' face='Lucida Console'>¡No tienes recursos suficientes!</font>",
	NEW_RECIPE = "<font color='#506d3d' size='8'><b>[NUEVA RECETA]</b></font> <font color='#ab5e42' face='Lucida Console'><b>${itemName}</b></font>\n<font color='#bd9d60' size='11' face='Lucida Console'>(${itemDesc})</font>",
	NEW_QUEST = "<font color='#506d3d' size='8'><b>[NUEVA MISIÓN]</b></font> <font color='#ab5e42' face='Lucida Console'><b>${questName}</b></font>",
	NEW_STAGE = "<font color='#506d3d' size='8'><b>[ACTUALIZACIÓN]</b></font> <font color='#ab5e42' face='Lucida Console'><b>${questName}</b></font>\n<font color='#bd9d60' size='11' face='Lucida Console'>(${desc})</font>",
	STAGE_PROGRESS = "<font color='#506d3d' size='8'><b>[ACTUALIZACIÓN]</b></font> <font color='#ab5e42' face='Lucida Console'><b>${questName}</b></font> <font color='#bd9d60' size='11' face='Lucida Console'>( ${progress} / ${needed} )</font>",
	QUEST_OVER = "<font color='#506d3d' size='8'><b>[COMPLETADO]</b></font> <font color='#ab5e42' face='Lucida Console'><b>${questName}</b></font>",
	SPIRIT_ORB = "<b><font color='#ab5e42' face='Lucida Console'>¡Has recibido una <font color='#bd9d60' face='Lucida Console'>orbe espiritual!</font></font></b>",
	PASSCODE = "Inserta la clave de acceso.",
	WRONG_GUESS = "<R>Clave de acceso incorrecta.</R>",
	INVENTORY_INFO = "<font face='Lucida Console'><p align='center'><font color='#${color}' size='9'>Weight: ${weight}</font>\n\n\n\n<font size='9'><N2><b>[X] Throw</b></N2></font></p></font>",
	FULL_INVENTORY = "<font color='#ab5e42'>[</font> <font color='#c6b392'>•</font> <font color='#ab5e42'>]</font> <font color='#c6b392' face='Lucida Console'>¡Tu inventario está lleno!</font>",
	FINAL_BOSS_ENTER_FAIL = "<font color='#ab5e42'>[</font> <font color='#c6b392'>•</font> <font color='#ab5e42'>]</font> <font color='#c6b392' face='Lucida Console'>¡Necesitas conseguir la orbe espiritual del dragón para entrar en este portal!</font>",
	CRAFT = "Crea",
	CANT_CRAFT = "No puedes crear",
	RECIPE_DESC = "\n\n<font face='Lucida console' size='12' color='#999999'><i>“ ${desc} ”</i></font>",
	FINAL_BATTLE_PING = "<font color='#ab5e42'>[</font> <font color='#c6b392'>•</font> <font color='#ab5e42'>]</font> <font color='#c6b392' face='Lucida Console'>¡La batalla final está ocurriendo!</font>",
	ACTIVATE_POWER = "<font color='#ab5e42'>[</font> <font color='#c6b392'>•</font> <font color='#ab5e42'>]</font> <font color='#c6b392' face='Lucida Console'>Presiona <font color='#ab5e42'><b>U</b></font> para alternar <font color='#ab5e42'><b>el poder divino!</b></font></font>",
	ANNOUNCER_DIALOGUES = {
		"¡¡ATENCIÓN TODOS!! ¡¡¡ATENCIÓN!!!",
		"Este mensaje es de nuestra majestad, el glorioso rey de estas tierras...",
		"Nuestras tierras están bajo ataque de los despiadados monstruos que derrotamos una vez hace mucho tiempo..",
		"Todo esto seguido del desafortunado evento que ahora vamos a anunciar. <b><VP>Nuestra princesa ha sido secuestrada.</VP></b>",
		"Los despiadados monstruos también han logrado irse con la mayoría de nuestros tesoros.",
		"El Rey está buscando SOLDADOS VALIENTES que ayuden al ejército a derrotar todos estos monstruos para salvar a la princesa.\ncon nuestro tesoro",
		"El Rey estará esperando la presencia de aquellos cuyos corazones sean valientes...\n"
	},
	NOSFERATU_DIALOGUES = {
		"Ahh puedo notar que eres nuevo por aquí... De todas formas, me pareces útil.",
		"Así que por lo que me estás diciendo, viniste aquí desde otra dimensión y desconoces donde te encuentras y que estás haciendo aquí.\n<i>*Hmmm, quizá pueda ser realmente útil para mí.</i>",
		"Bueno... Jóven amigo, supongo que necesitas un trabajo para poder vivir. No te preocupes por eso. Te daré un trabajo. Sí... Sí....",
		"Pero... Antes de eso, necesitamos comprobar si estás en buenas condiciones físicas.\nRecolecta <VP><b>15 de madera</b></VP> en el bosque para mí.\nToma esta <VP><b>10 piedra</b></VP> como adelanto. ¡Buena suerte!",
		"Bastante impresionante, de hecho. Pero <i>en nuestros tiempos</i> lo hacíamos más rápido...\nTampoco importa mucho ya. Como te prometí, <VP><b>el trabajo</b></VP> es tuyo.",
		"Dicho esto, ahora tienes acceso a la <b><VP>mina</VP></b>\n¡Ve hacia la<b><VP>puerta</VP></b> dirigiéndote a la izquierda desde aquí para <b><VP>↓</VP></b> acceder!",
		"Como primera tarea, necesito que recolectes<b><VP> 15 lingotes de hierro</VP></b>. ¡Buena suerte de nuevo!",
		"¡Wow! Parece que te subestimé, impresionante!",
		"Escuché que el <b><VP>castillo</VP></b> necesita algunos jóvenes como tú para salvar su tesoro y rescatar a la princesa de esos malvados...",
		"¡Se te daría muy bien!",
		"Te daré una <b><VP>carta de recomendación de Nosferatu</VP></b>, presenta esto al <b><VP>Teniente</VP></b> y con suerte te reclutará en el ejercito.\n<i>Y... Eso sería bastante dinero para tí</i>",
		"Ah, y no te olvides tu regalo de <b><VP>30 de piedra</VP></b> por todo el trabajo duro!",
		"¿Necesitas algo más?",
		"Eso es cultura general... Necesitas <b><VP>talar un árbol con un hacha</VP></b>",
		"¿Así que necesitas un <b><VP>pico</VP></b>? Debería haber uno tirado en algún lugar del <b><VP>bosque</VP></b>. <b><VP>↓</VP></b> para estudiarlo y fabricar la receta estudiada en una <b><VP>mesa de fabricación</VP></b>.\nHay una mesa justo encima de esta mina.",
		"Vendo <b><VP>10 de piedra</VP></b> por <b><VP>35 palos de madera</VP></b>",
		"Ah ok, hasta la vista entonces",
		"Tu inventario parece estar lleno. ¿Qué te parece si lo vacías un poco para volver aquí y recoger tu recompensa?",
		"¡Un placer hacer negocios contigo!",
		"Parece que no tienes objetos suficientes para este intercambio."
	},
	NOSFERATU_QUESTIONS = {
		"¿Cómo consigo madera?",
		"¿Pico?",
		"Intercambia",
		"Déjalo estar.",
		"It's something else."

	},
	EDRIC_DIALOGUES = {
		"Nuestra princesa... Y el tesoro, está en manos de malvados. Debemos apresurarnos.",
		"Espera. ¿¿¿Así que dices que <b><VP>Nosferatu</VP></b> te envió hasta aquí para que ayudes en las misiones de nuestras tropas???",
		"Eso es genial. Pero trabajar parar un ejército no es tan simple como crees.\nNecesitarás un poco de <b><VP>entrenamiento intensivo</VP></b> considerando que tu cuerpo no está en perfecto estado.\nAcércate a la <b><VP>área de entrenamiento, a mi izquierda</VP></b> para empezar con tu entrenamiento.",
		"Pero antes de eso, aségurate de que estás completamente preparado. Hay algunas <b><VP>recetas</VP></b> dispersas alrededor de los<b><VP>bastidores de armas</VP></b> y los <b><VP>bosques sombríos bajo la colina.</VP></b>\nEspero que hagas un bue uso de ellas.",
		"¡Habla conmigo de nuevo cuando te consideres preparado!",
		"¿Estás preparado para tomar el desafío?",
		"¡Genial! Ve a empezar tu entrenamiento en el área de entrenamiento. Necesitas <b><VP>derrotar 25 monstruos</VP></b> para completar este desafío.",
		"Puedes tomarte todo el tiempo que quieras\n¡¡¡Buena suerte!!!",
		"¡Demostraste ser válido! ¡¡¡Date prisa!!! ¡Únete al resto de nuestros soldados y lucha contra los monstruos!"
	},
	EDRIC_QUESTIONS = {
		"Necesito más tiempo...",
		"¡Estoy preparado!"
	},
	GARRY_DIALOGUES = {
		"Este es el peor lugar en el que nunca he estado. <b><VP>Nosferatu</VP></b> ni siquiera paga suficiente. <i>*uf...*</i>"
	},
	THOMPSON_DIALOGUES = {
		"¡Hola! ¿Necesitas algo de mí?",
		"Si estás buscando una <b><VP>pala</VP></b>, debería haber una en <b><VP>la parte más hacia la derecha de la mina</VP></b>.\n¡Buena suerte!",
		"¡Ten un buen día!"
	},
	THOMPSON_QUESTIONS = {
		"¿Alguna receta?",
		"Solo vengo a decir hola."
	},
	COLE_DIALOGUES = {
		"Hay muchos <b><VP>monstruos</VP></b> allí fuera. Por favor, ten cuidado!",
		"Todo mi ejercito está luchando contra los monstruos. Necesitamos mucha ayuda.",
		"¡AGHHHH! NO PUEDO DEJAR A UN DEBILUCHO COMO TÚ IR POR AHÍ. ¡VUELVE AQUÍ!"
	},
	MARC_DIALOGUES = {
		"¡MALO! ¡NO toques mi mesa"
	},
	SARUMAN_DIALOGUES = {
		"¡¡¡¡HEYYYYY!!!! ¡¡¡¡HEYYYYYYYYY!!!!\n¿¿¿HAY ALGUIEN AHÍ???",
		"¡¡HEYY!! ¡AYÚDAME POR AQUÍ!\nDIOS MÍO, GRACIAS!!!",
		"Soy <b><VP>Saruman</VP></b> por cierto. He estado atrapado aquí por unos...\n15 años?",
		"Mi compañero <b><VP>Hootie</VP></b> es la razón por la que aun estoy vivo.\nHubiera fallecido de hambre si no fuése por él",
		"Así que... Quieres saber como y por qué he estado atrapado aquí?",
		"Es una larga historia, tiempo atrás, cuando aun era <b>joven</b> y fuerte como tú,\nEscuché sobre estos tesoros llamados <b><VP>orbes espirituales</VP></b>",
		"Además, yo era profesor así que estaba bastante interesado en informarme más sobre este tema.\nHe recolectado muchísima información sobre ellas",
		"Estas orbes están ligadas a un alma. Una vez están ligadas con todas las <b><VP>5 orbes</VP></b> serán recompensados con el <b><VP>poder divino</VP></b>",
		"No estoy seguro que tipo de poder conseguiría de las orbes o que podría hacerme...\nPero estoy bastante seguro que los <b><VP>monjes</VP></b> saben más sobre como usarlo!",
		"Pero nadie sabía donde están así que vine aquí para encontrar todas por mí mismo.",
		"Creo que hice un buen trabajo encontrando una <VP><b>orbe</b></VP>.\nPero... Elegí el camino equivocado y me quedé atrapado aquí desde entonces.",
		"¡Estoy muy agradecido de que me hayas ayudado! Puedes preguntarme todo lo que necesites saber sobre estas orbes.\nEl conocimiento existe para ser compartido, y... Me salvaste!",
		"Ok, compañero! ¿Qué quieres saber sobre mí?",
		"Como dije, hay <b><VP>5 orbes espirituales</VP></b>\n<b><VP>3</VP></b> de ellas podrían ser encontradas</b> en este bosque.\nAunque estoy algo inseguro sobre las otras 2...",
		"Con la información que he recolectado, deberás encarar varios retos para llegar a las orbes.",
		"Creo que ya sabes una a no ser que tengas ciertos poderes mágicos para teletransportarte aquí",
		"El segundo orbe está protegido por muchos <b><VP>monstruos</VP></b> en el camino.\n¡Así que equípate bien para explorar allí!",
		"Y para el último orbe, encontré esta <b><VP>pista</VP></b> en unos libros muy antiguos",
		"<b><VP>\"Rompecabezas, acertijos y viejas tradiciones.\nPuntuación matemática, pero no suma\nUn recurso que tan fructíferamente dio\nCllega a término con la verdadera tradición\nToma el rango que se muestra a todos\nAl mundo debes llamar\"</VP></b>",
		"¡Eso es todo!That's all! Espero que hagas buen uso de esta información.",
		"¡Gracias por fíjarte en mí, amigo!",
		"OH, PARECE QUE HAS RECOLECTADO TODAS LAS ORBES ESPIRITUALES!!!\nEstamos parejos ahora... agradéceme luego!\nPero asegúrate de que encuentras más información sobre estas orbes consultando a un <b><VP>monje</VP></b>"
	},
	SARUMAN_QUESTIONS = {
		"¿Dónde están las orbes?",
		"¡Comprobando ahora mismo!"
	},
	MONK_DIALOGUES = {
		"He estado conteniendo este malvado poder por un largo tiempo...\nEstoy contento de escuchar que viniste a ayudarnos",
		"Así que me estás diciendo que posees los <b><VP>5 orbes espirituales</VP></b>",
		"Menudo buen trabajo. Esto hará más fácil el hecho de derrotar ese malvado poder para siempre",
		"Estos orbes espirituales están ligados al espíritu de alguien.\nSolo algunos afortunados pueden poseer los 5.",
		"Estos orbes te ayudarán con el <b><VP>poder divino</VP></b>lo cual es la única maneera de destruir la maldad\npor lo que sé",
		"Una vez hayas activado el poder divino y confrontado la maldad...\nDeberás viajar un largo camino dentro de tu mente para lograr el <b><VP>estado divino</VP></b>",
		"Los orbes espirituales te ayudarán a encontrar el camino adecuado para conseguirlo.\nYou only have to travel to the way it show you at the right time!",
		"Estoy bastante seguro de que no lo lograrás.\nPero incluso si te acercas...",
		"Creará una gran energía divina la cual invocará a la <b><VP>Diosa</VP></b>",
		"Los libros ancestrales dicen que la bestia es demasiado poderosa pero estoy bastante seguro de que la\n<b><VP>bendición de la diosa</VP></b> lo hará estar en un estado más débil",
		"Ese será nuestro momento, para destruir el malvado poder para siempre!!!",
		"La diosa... está aquí\n¡¡¡ESTÁ OCURRIENDO!!!"
	},
	NIELS_DIALOGUES = {
		"Todo el mundo, preparado en sus posiciones!",
		"El <b><VP>dragón</VP></b> al otro lado del rio es demasiado peligroso.\nUtilizará sus <b><VP>ataques de fuego</VP></b> y <b><VP>lanzará rocas</VP></b> sobre tí",
		"Por favor, cuidado...",
		"No podemos atacar al dragón directamente, ya que el puente parece estar roto",
		"El dragón lo destruyó con su fuego cuando estaba intentando cruzarlo.",
		"Así que... Deberemos repararlo para poder alcanzarle. ¡¡¡Rápido!!!"
	},
	PROPS = {
		attack = "Ataque",
		defense = "Defensa",
		durability = "Durabilidad",
		chopping = "Talar",
		mining = "Minar"
	}
}
