import funkin.game.Character;

var preloadedCharacters:Map<String, Character> = [];

function postCreate() {
    // Escaneamos los eventos para precargar personajes y evitar tirones (lag)
    for (event in PlayState.SONG.events) {
        if (event.name == "Change Character" || (event.name == "Psych_Events" && event.params[0] == "Change Character")) {
            var charName:String = (event.name == "Change Character") ? event.params[1] : event.params[2];
            var slot:Int = getSlotID( (event.name == "Change Character") ? event.params[0] : event.params[1] );

            if (!preloadedCharacters.exists(charName)) {
                var c = new Character(0, 0, charName, slot == 1); // slot 1 suele ser BF
                c.active = c.visible = false;
                add(c); // Se añade al estado pero oculto
                preloadedCharacters.set(charName, c);
            }
        }
    }
}

function onEvent(e) {
    var name:String = "";
    var targetChar:String = "";
    var slot:Int = 0;

    // Soporte para ambos tipos de evento (Codename y Psych)
    if (e.event.name == "Change Character") {
        slot = getSlotID(e.event.params[0]);
        targetChar = e.event.params[1];
    } else if (e.event.name == "Psych Events" && e.event.params[0] == "Change Character") {
        slot = getSlotID(e.event.params[1]);
        targetChar = e.event.params[2];
    } else {
        return; 
    }

    var strum = strumLines.members[slot];
    if (strum == null) return;

    // Cambiamos el personaje en la línea de notas
    strum.characters[0].visible = false; // Ocultamos el actual
    
    // Si no se precargó, lo creamos ahora
    if (!preloadedCharacters.exists(targetChar)) {
        var newChar = new Character(0, 0, targetChar, slot == 1);
        add(newChar);
        preloadedCharacters.set(targetChar, newChar);
    }

    var newChar = preloadedCharacters.get(targetChar);
    strum.characters[0] = newChar; // Asignamos el nuevo a la StrumLine
    
    // Ajustar posición y visibilidad
    newChar.setPosition(strum.characters[0].x, strum.characters[0].y);
    newChar.visible = true;
    newChar.active = true;

    // Actualizar Iconos y Colores
    if (slot == 1) iconP1.changeIcon(newChar.healthIcon);
    else iconP2.changeIcon(newChar.healthIcon);
    
    reloadHealthBarColors();
}

function getSlotID(val:Dynamic):Int {
    var str = Std.string(val).toLowerCase();
    if (str == "bf" || str == "boyfriend" || str == "1") return 1;
    if (str == "gf" || str == "girlfriend" || str == "2") return 2;
    return 0; // Dad / Opponent
}