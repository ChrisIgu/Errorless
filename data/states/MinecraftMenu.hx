import funkin.menus.FreeplayState.FreeplaySonglist;
import flx3d.Flx3DView;
import flx3d.Flx3DUtil;
import openfl.display.BitmapData;
import openfl.utils.Assets;
import away3d.textures.BitmapCubeTexture;
import away3d.primitives.SkyBox;
import funkin.options.OptionsMenu;
import Sys;
import flixel.text.FlxTextBorderStyle;

var cam:FlxCamera;
var scene3D:Flx3DView;

var cubeTexture:BitmapCubeTexture;
var skybox:SkyBox;
var buttons:Array<FlxSprite> = [];
var curSelected:Int = 0;
var val:Int = 0;

function create(){
    cam = new FlxCamera();
    cam.bgColor = 0x0;
	FlxG.cameras.add(cam, false);

	scene3D = new Flx3DView(0, 0, FlxG.width, FlxG.height);
    scene3D.screenCenter();
	scene3D.antialiasing = true;
	scene3D.camera = cam;
    Flx3DUtil.is3DAvailable();

    scene3D.view.camera.rotationY = 180;

    scene3D.view.camera.lens.far = 2000; 

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


	FlxG.mouse.visible = true;
}

var time:Float = 0;
function update(elapsed:Float){
    time += elapsed;
    scene3D.view.camera.rotationY = 200 + time * 2;

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

function selected(sel:Int){
    if(val != 0) return;
    val++;

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
}

function destroy(){
	scene3D.destroy();
}