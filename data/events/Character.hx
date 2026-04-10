import funkin.backend.utils.MemoryUtil;
import openfl.system.System;
import haxe.ds.StringMap;

var charMap:Array<Array<StringMap<Character>>> = [];

// partially stole from gorefield lol
function postCreate() {
    var charactersToPreload:Array<String> = [];
    for (event in events) {
        if (event.name == 'Character') {
            var charName:String = event.params[1];
            if (!charactersToPreload.contains(charName)) {
                charactersToPreload.push(charName);
            }
        }
    }

    for (strumIndex in 0...strumLines.members.length) {
        var strumLane = strumLines.members[strumIndex];
        if (charMap[strumIndex] == null) charMap[strumIndex] = [];

        for (charIndex in 0...strumLane.characters.length) {
            var char = strumLane.characters[charIndex];
            if (charMap[strumIndex][charIndex] == null) charMap[strumIndex][charIndex] = new StringMap();

            charMap[strumIndex][charIndex].set(char.curCharacter, char);

            for (charName in charactersToPreload) {
                if (!charMap[strumIndex][charIndex].exists(charName)) {
                    var newChar:Character = new Character(char.x, char.y, charName, char.isPlayer);
                    trace('Preloading Character: ' + charName + ' for Strum ' + strumIndex);
                    
                    charMap[strumIndex][charIndex].set(charName, newChar);
                    newChar.active = newChar.visible = false;
                }
            }
        }
    }
}

function onEvent(event) {
	if (event.event.name == 'Character') {
		trace('Change Character Event Called');
		var params = {
			strumIndex: event.event.params[0],
			charName: event.event.params[1],
			charIndex: event.event.params[2]
		};
		trace(params);
		var oldChar:Character = strumLines.members[params.strumIndex].characters[params.charIndex];
		var newChar:Character = charMap[params.strumIndex][params.charIndex].get(params.charName);
		if (oldChar.curCharacter == newChar.curCharacter) return;

		if (params.charIndex == 0) {
			if (params.strumIndex == 0) iconP2.setIcon(newChar.getIcon());
			else if (params.strumIndex == 1) iconP1.setIcon(newChar.getIcon());
		}
		insert(members.indexOf(oldChar), newChar);
		newChar.active = newChar.visible = true;
		remove(oldChar);
		
		newChar.setPosition(oldChar.x, oldChar.y);
		newChar.playAnim(oldChar.animation.name);
		newChar.animation?.curAnim?.curFrame = oldChar.animation?.curAnim?.curFrame;
		strumLines.members[params.strumIndex].characters[params.charIndex] = newChar;

        charMap[params.strumIndex][params.charIndex].remove(oldChar.curCharacter);
        oldChar.destroy();
        if(!Options.gpuOnlyBitmaps) {
            var graphicRef = oldChar.graphic;
            FlxG.bitmap.remove(graphicRef);
            MemoryUtil.clearMinor();
        }
        
        strumLines.members[params.strumIndex].characters[params.charIndex] = newChar;
        trace('Character ' + oldChar.curCharacter + ' ha sido borrado de la memoria.');
	}
}