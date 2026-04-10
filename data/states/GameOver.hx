var txts:Array<String> = ["Respawn", "Volver al titulo"];
var backgrd:FlxSprite = new FlxSprite();
var itemsitos:Array<FlxText> = [];
var cosos:Array<FlxSprite> = [];
var texto:FlxText = new FlxText(0, 100, 400, "You died!");
var texto1:FlxText = new FlxText(0, 200, 400, "Score:");
var texto2:FlxText;
var gameever:Bool = true;
var curSelected:Int = 0;
var val:Int = 0;

function create(){
	sexocam = new FlxCamera();
    sexocam.bgColor = 0x00000000;
	FlxG.cameras.add(sexocam, false);
    FlxG.mouse.visible = true;

	backgrd.makeGraphic(FlxG.width,FlxG.height,0xFFFF0000);
    backgrd.camera = sexocam;
    backgrd.alpha = 0.25;
	backgrd.scrollFactor.set(0,0);
    insert(0, backgrd);

    texto.setFormat(Paths.font("Minecraftia-Regular.ttf"), 40, FlxColor.WHITE, "center");
    texto.screenCenter(FlxAxes.X);
    texto.camera = sexocam;
    add(texto);

    texto1.setFormat(Paths.font("Minecraftia-Regular.ttf"), 20, FlxColor.WHITE, "center");
    texto1.screenCenter(FlxAxes.X);
    texto1.camera = sexocam;
    add(texto1);

    texto2 = new FlxText(texto1.x + 245, texto1.y, 400, "");
    texto2.setFormat(Paths.font("Minecraftia-Regular.ttf"), 20, FlxColor.YELLOW, "left");
    texto2.camera = sexocam;
    add(texto2);

    for(i in 0...txts.length) {
        var grrraaa:FlxSprite = new FlxSprite(50, 350 + (i * 50)); 
    
        grrraaa.frames = Paths.getFrames('button');
        grrraaa.animation.addByPrefix('idle', "botonxd2 basic", 1);
        grrraaa.animation.addByPrefix('idlegrr', "botonxd2 white", 1);
        grrraaa.animation.play('idle');
    
        grrraaa.scrollFactor.set();
        grrraaa.camera = sexocam;
        grrraaa.scale.set(2.5, 2);
        grrraaa.updateHitbox();
        grrraaa.screenCenter(FlxAxes.X);
        add(grrraaa);
        cosos.push(grrraaa);
    }

    for(i => textaco in txts){
        var texto:FlxText = new FlxText(540, cosos[i].y + 6, 200, "" + textaco, 40, false);
        texto.setFormat(Paths.font("Minecraftia-Regular.ttf"), 15, FlxColor.WHITE, "center");
        texto.scale.set(1, 1);
        texto.camera = sexocam;
        add(texto);
        itemsitos.push(texto);
    }
    texto2.text = PlayState.instance.songScore;

    if (PlayState.instance != null) {
        FlxTween.globalManager.cancelTweensOf(PlayState.instance);
        FlxTween.globalManager.cancelTweensOf(PlayState.instance.camGame);
        PlayState.instance.camZooming = false;

        FlxTween.num(PlayState.instance.defaultCamZoom, PlayState.instance.defaultCamZoom + 0.2, 2, { ease: FlxEase.smootherStepInOut}, function(v) {
            PlayState.instance.defaultCamZoom = v;
            PlayState.instance.camGame.zoom = v;
        });

        FlxTween.num(PlayState.instance.camGame.angle, PlayState.instance.camGame.angle + 5, 2, { ease: FlxEase.smootherStepInOut}, function(v) {
            PlayState.instance.camGame.angle = v;
        });

        PlayState.instance.camHUD.alpha = 0;
    }
}

function update(){
    for (i in 0...itemsitos.length)
    {
        if(FlxG.mouse.overlaps(cosos[i])){
                curSelected = i;
                if(FlxG.mouse.justPressed) confirmSelection(i);
        }else{
            curSelected = 2;
        }
		cosos[i].animation.play((i == curSelected) ? 'idlegrr' : 'idle');
    }

    if (FlxG.sound.music != null) FlxG.sound.music.stop();

    if (PlayState.instance != null) {
        if (PlayState.instance.vocals != null) 
            PlayState.instance.vocals.stop();

        for (strumLine in PlayState.instance.strumLines.members) {
            if (strumLine.vocals != null) strumLine.vocals.stop();
        }
    }

    if (FlxG.keys.justPressed.SPACE){
        FlxG.mouse.visible = false;
        FlxG.resetState();
    }
}

function confirmSelection(sel:Int)
{
    if(val != 0) return;
    val++;

    switch(sel){
        case 0: FlxG.resetState();
        case 1: FlxG.switchState(new MainMenuState());
        }
}

