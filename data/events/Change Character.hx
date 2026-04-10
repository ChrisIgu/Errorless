var preloadedCharacters:Map<String, Character> = [];
var preloadedIcons:Map<String, FlxSprite> = [];
function postCreate() {
    for (icon in [iconP1, iconP2]) {
        if (icon == null) continue;
        if (icon.animation == null || icon.animation.name == null) continue;
        var key = icon.animation.name + (icon == iconP1 ? "-player" : "");
        preloadedIcons.set(key, icon);
    }

    for (event in PlayState.SONG.events) {
        if (event.name != "Change Character") continue;

        var targetName:String = event.params[1];
        var slot:Int = event.params[0];

        var preExistingCharacter:Bool = false;
        for (strum in strumLines)
            for (ch in strum.characters)
                if (ch.curCharacter == targetName) {
                    preloadedCharacters.set(targetName, ch);
                    preExistingCharacter = true;
                    break;
                }

        var oldCharacter = strumLines.members[slot].characters[0];

        if (!preExistingCharacter) {
            var newCharacter = new Character(oldCharacter.x, oldCharacter.y, targetName, oldCharacter.isPlayer);

            if (newCharacter == null) {
                continue;
            }

            newCharacter.active = newCharacter.visible = false;
            try {
                newCharacter.drawComplex(FlxG.camera);
            } catch(e:Dynamic) {
            }

            preloadedCharacters.set(targetName, newCharacter);

            if (newCharacter.isGF) {
                newCharacter.cameraOffset.x += stage.characterPoses["gf"].camxoffset;
                newCharacter.cameraOffset.y += stage.characterPoses["gf"].camyoffset;
            } else if (newCharacter.playerOffsets) {
                newCharacter.cameraOffset.x += stage.characterPoses["boyfriend"].camxoffset;
                newCharacter.cameraOffset.y += stage.characterPoses["boyfriend"].camyoffset;
            } else {
                newCharacter.cameraOffset.x += stage.characterPoses["dad"].camxoffset;
                newCharacter.cameraOffset.y += stage.characterPoses["dad"].camyoffset;
            }
        }

        var charForIcon:Character = preloadedCharacters.get(targetName) ?? oldCharacter;
        var iconId:String = charForIcon.getIcon();
        var iconKey:String = iconId + (charForIcon.isPlayer ? "-player" : "");
        if (!preloadedIcons.exists(iconKey)) {
            var createdIcon:HealthIcon = new HealthIcon(iconId, charForIcon.isPlayer);
            createdIcon.y = healthBar.y - (createdIcon.height / 2);
            createdIcon.active = createdIcon.visible = false;
            try {
                createdIcon.drawComplex(FlxG.camera);
            } catch(e:Dynamic) {
            }
            createdIcon.cameras = [camHUD];
            preloadedIcons.set(iconKey, createdIcon);
        }
    }
}

function onEvent(_) {
    var params:Array = _.event.params;
    if (_.event.name != "Change Character") return;

    var slot:Int = params[0];
    var targetName:String = params[1];


    if (slot < 0 || slot >= strumLines.members.length) {
        return;
    }

    var oldCharacter:Character = strumLines.members[slot].characters[0];
    if (oldCharacter == null) {
        return;
    }

    var newCharacter:Character = preloadedCharacters.get(targetName);
    if (newCharacter == null) {
        newCharacter = new Character(oldCharacter.x, oldCharacter.y, targetName, oldCharacter.isPlayer);
        if (newCharacter == null) {
            return;
        }
        newCharacter.active = newCharacter.visible = false;
        try { newCharacter.drawComplex(FlxG.camera); } catch(e:Dynamic) {}
        preloadedCharacters.set(targetName, newCharacter);

        if (newCharacter.isGF) {
            newCharacter.cameraOffset.x += stage.characterPoses["gf"].camxoffset;
            newCharacter.cameraOffset.y += stage.characterPoses["gf"].camyoffset;
        } else if (newCharacter.playerOffsets) {
            newCharacter.cameraOffset.x += stage.characterPoses["boyfriend"].camxoffset;
            newCharacter.cameraOffset.y += stage.characterPoses["boyfriend"].camyoffset;
        } else {
            newCharacter.cameraOffset.x += stage.characterPoses["dad"].camxoffset;
            newCharacter.cameraOffset.y += stage.characterPoses["dad"].camyoffset;
        }
    }

    if (oldCharacter.curCharacter == newCharacter.curCharacter) {
        return;
    }

    insert(members.indexOf(oldCharacter), newCharacter);
    newCharacter.active = newCharacter.visible = true;
    remove(oldCharacter);

    newCharacter.setPosition(oldCharacter.x, oldCharacter.y);
    var animName:String = oldCharacter.animation != null ? oldCharacter.animation.name : null;
    if (animName != null) {
        try {
            newCharacter.playAnim(animName);
            newCharacter.animation?.curAnim?.curFrame = oldCharacter.animation?.curAnim?.curFrame;
        } catch(e:Dynamic) {
        }
    }
    strumLines.members[slot].characters[0] = newCharacter;

    var oldIcon:FlxSprite = oldCharacter.isPlayer ? iconP1 : iconP2;
    var expectedIconKey:String = newCharacter.getIcon() + (newCharacter.isPlayer ? "-player" : "");
    var newIcon:FlxSprite = preloadedIcons.get(expectedIconKey);

    if (newIcon == null) {
        var iconIdNow:String = newCharacter.getIcon();
        var createdIconNow:HealthIcon = new HealthIcon(iconIdNow, newCharacter.isPlayer);
        createdIconNow.y = healthBar.y - (createdIconNow.height / 2);
        createdIconNow.active = createdIconNow.visible = false;
        try { createdIconNow.drawComplex(FlxG.camera); } catch(e:Dynamic) {}
        createdIconNow.cameras = [camHUD];
        preloadedIcons.set(iconIdNow + (createdIconNow.isPlayer ? "-player" : ""), createdIconNow);
        newIcon = createdIconNow;
    }

    if (oldIcon != null && newIcon != null && oldIcon.animation?.name != newIcon.animation?.name) {
        insert(members.indexOf(oldIcon), newIcon);
        newIcon.active = newIcon.visible = true;
        remove(oldIcon);
        if (oldCharacter.isPlayer) iconP1 = newIcon;
        else iconP2 = newIcon;
    }

    var leftColor:Int = dad != null && dad.visible && dad.iconColor != null && Options.colorHealthBar ? dad.iconColor : 0xFF000000;
    var rightColor:Int = boyfriend != null && boyfriend.visible && boyfriend.iconColor != null && Options.colorHealthBar ? boyfriend.iconColor : 0xFF000000;
    healthBar.createFilledBar(leftColor, rightColor);
    healthBar.updateBar();
}
