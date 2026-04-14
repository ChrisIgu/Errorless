import funkin.menus.FreeplayState.FreeplaySonglist;
import flx3d.Flx3DView;
import flx3d.Flx3DUtil;
import openfl.display.BitmapData;
import openfl.utils.Assets;
import away3d.textures.BitmapCubeTexture;
import away3d.primitives.SkyBox;
import funkin.options.OptionsMenu;
import funkin.backend.MusicBeatState;
import Sys;
import flixel.text.FlxTextBorderStyle;

var cam:FlxCamera;
var scene3D:Flx3DView;

var cubeTexture:BitmapCubeTexture;
var skybox:SkyBox;
var buttons:Array<FlxSprite> = [];
var curSelected:Int = 0;
var val:Int = 0;
var vram:Bool;
var framesActive:Int = 0;
var screenshot:FlxSprite; 
var click:FlxSound = FlxG.sound.load(Paths.sound("click"));

function create(){
    vram = Options.gpuOnlyBitmaps;
    Options.gpuOnlyBitmaps = false;
    cam = new FlxCamera();
    cam.bgColor = 0x0;
	FlxG.cameras.add(cam, false);

	scene3D = new Flx3DView(0, 0, FlxG.width, FlxG.height);
    scene3D.screenCenter();
	scene3D.antialiasing = false;
	scene3D.camera = cam;
    Flx3DUtil.is3DAvailable();

    scene3D.view.camera.rotationY = 180;

    scene3D.view.camera.lens.far = 100; 

    add(scene3D);

	cubeTexture = new BitmapCubeTexture(
    	Assets.getBitmapData("assets/images/menuCube_right.png"),
    	Assets.getBitmapData("assets/images/menuCube_left.png"),
    	Assets.getBitmapData("assets/images/menuCube_top.png"),
    	Assets.getBitmapData("assets/images/menuCube_bottom.png"),
    	Assets.getBitmapData("assets/images/menuCube_front.png"),
    	Assets.getBitmapData("assets/images/menuCube_back.png")
	);

	skybox = new SkyBox(cubeTexture);
	scene3D.addChild(skybox);

    add(screenshot = new FlxSprite(0, 0).loadGraphic(Paths.image('screenshot')));
    screenshot.camera = cam;
    screenshot.setGraphicSize(FlxG.width, FlxG.height);
    screenshot.screenCenter(FlxAxes.XY);

	var coords:Array<Int> = [642, 505, 780];

    for(i in 0...3) {
        var grrraaa:FlxSprite = new FlxSprite(0, 0); 
    
        grrraaa.frames = Paths.getFrames('mainmenu/button' + i);
        grrraaa.animation.addByPrefix('idle', "basic", 1);
        grrraaa.animation.addByPrefix('selected', "white", 1);
        grrraaa.animation.play('idle');
        grrraaa.camera = cam;
        grrraaa.scale.set(1.35, 1.35);
        grrraaa.updateHitbox();
        grrraaa.alpha = 0;
        add(grrraaa);
		grrraaa.setPosition(coords[i] - grrraaa.width / 2, 320 + (((i == 0) ? 0 : 1) * 65));
        buttons.push(grrraaa);
    }

	add(title = new FlxSprite(0, -100).loadGraphic(Paths.image('mainmenu/errorless_title')));
	title.camera = cam;
	title.scale.set(0.4,0.4);
	title.screenCenter(FlxAxes.X);

    add(texto = new FlxText(10, FlxG.height - 35, 0, "Minecraft 1.21.11").setFormat(Paths.font("Minecraftia-Regular.ttf"), 20, FlxColor.WHITE, "center"));
	texto.setBorderStyle(FlxTextBorderStyle.SHADOW, 0xFF3F3F3F, 3);
    texto.camera = cam;

    add(texto1 = new FlxText(800, FlxG.height - 35, 475, "Copyright Mojang AB. ¡Do not distribute!").setFormat(Paths.font("Minecraftia-Regular.ttf"), 20, FlxColor.WHITE, "center"));
	texto1.setBorderStyle(FlxTextBorderStyle.SHADOW, 0xFF3F3F3F, 3);
    texto1.camera = cam;

    add(underline = new FlxSprite(texto1.x, texto1.y + texto1.height - 15).makeGraphic(Std.int(texto1.width), 2, 0xFFFFFFFF));
	underline.camera = cam;

    for(i in [title, texto, texto1, underline])i.alpha = 0;

	FlxG.mouse.visible = true;
}

var time:Float = 0;
var corriendo:Bool = false;
function update(elapsed:Float){
    time += elapsed;
    if (scene3D != null && scene3D.view != null) {
        scene3D.view.camera.rotationY = 200 + time * 2;
        
        if (screenshot != null && screenshot.visible) {
            framesActive++;
            if (framesActive > 5) {
                if(title.alpha == 0){
                    for(i in [title, texto, texto1, underline])FlxTween.tween(i, {alpha: 1}, 2, {ease: FlxEase.quintOut});
                    for(i in 0...buttons.length)FlxTween.tween(buttons[i], {alpha: 1}, 2, {ease: FlxEase.quintOut});
                }
                corriendo = true;
                screenshot.visible = false;
                screenshot.destroy();
            }
        }
    }


    if(corriendo){
        for (i in 0...3){
            if(FlxG.mouse.overlaps(buttons[i])){
                    curSelected = i;
                    if(FlxG.mouse.justPressed) selected(i);
            }else{
                curSelected = 3;
            }
	    	buttons[i].animation.play((i == curSelected) ? 'selected' : 'idle');
        }
    }
    trace(title.alpha);
}

function selected(sel:Int){
    if(val != 0) return;
    val++;

    FlxG.sound.play(Paths.sound('click'), 1);
    for(i in [title, texto, texto1, underline])FlxTween.tween(i, {alpha: 0}, 2, {ease: FlxEase.quintOut});
    for(i in 0...buttons.length)FlxTween.tween(buttons[i], {alpha: 0}, 2, {ease: FlxEase.quintOut, onComplete: function(){
        switch(sel){
            case 0:
                var song = FreeplaySonglist.get().songs[0];

            Options.freeplayLastSong = song.name;
            Options.freeplayLastDifficulty = song.difficulties[0];
            PlayState.loadSong(Options.freeplayLastSong, Options.freeplayLastDifficulty);
    
            if (FlxG.sound.music != null) {
                FlxG.sound.music.stop();
            }

            FlxG.switchState(new ModState('ComicState'));
		
        case 1: FlxG.switchState(new OptionsMenu());
		case 2: Sys.exit(0);
        }
    }});
}

function destroy(){
    scene3D.destroy();
    scene3D = null;

    Options.gpuOnlyBitmaps = vram;
}