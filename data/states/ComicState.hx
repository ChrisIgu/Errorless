import flixel.math.FlxRect;
var comic:FlxSprite;
var black:FlxSprite;
var clip = new FlxRect(0, 0, 4500, 1700);
var camrrr:FlxCamera = new FlxCamera();
var scene:Float = -1;
function create(){
    camrrr.bgColor = 0xFFFFFFFF;
    FlxG.cameras.add(camrrr, false);
    camrrr.zoom = 1;

    add(comic = new FlxSprite(-1600, -1400).loadGraphic(Paths.image('comicationbysquarexml')));
    comic.camera = camrrr;
    comic.scale.set(0.7, 0.7);
    comic.clipRect = clip;
    scene = 1;

    add(black = new FlxSprite(0, 0).makeGraphic(5000, 7800, 0xFF000000));
    black.screenCenter();
    black.camera = camrrr;

    FlxG.sound.playMusic(Paths.music("comic"), 1, true);
}

function update() {
    if(controls.BACK){
        FlxG.switchState(new FreeplayState());
    }

    if(controls.ACCEPT){
        scene = 5;
    }

    if(scene == 1){
        scene = 1.5;
        FlxTween.tween(black, { alpha: 0 }, 2);
        FlxTween.num(1, 0.45, 2, { ease: FlxEase.quadInOut, onComplete: function(twn:FlxTween) {
            new FlxTimer().start(1, _ -> scene = 2);
        }}, function(v) {
            camrrr.zoom = v;
        });
    }

    if(scene == 2){
        scene = 2.5;
        FlxTween.num(camrrr.scroll.y, 900, 2, { ease: FlxEase.quadInOut, onComplete: function(twn:FlxTween) {
            camrrr.scroll.y = 900;
            new FlxTimer().start(2, _ -> scene = 3);
        }}, function(v) {
            camrrr.scroll.y = v;
        });
        FlxTween.num(clip.height, 3100, 1, { ease: FlxEase.quadInOut }, function(v:Float) {
            clip.height = v;
            comic.clipRect = clip;
            trace(clip.height);
        });
    }

    if(scene == 3){
        scene = 3.5;
        FlxTween.num(camrrr.scroll.y, 1800, 2, { ease: FlxEase.quadInOut, onComplete: function(twn:FlxTween) {
            camrrr.scroll.y = 1800;
            new FlxTimer().start(4, _ -> scene = 4);
        }}, function(v) {
            camrrr.scroll.y = v;
        });

        FlxTween.num(clip.height, 4350, 1, { ease: FlxEase.quadInOut }, function(v:Float) {
            clip.height = v;
            comic.clipRect = clip;
            trace(clip.height);
        });
    }

    if(scene == 4){
        scene = 4.5;
        FlxTween.num(camrrr.scroll.y, 3050, 2, { ease: FlxEase.quadInOut, onComplete: function(twn:FlxTween) {
            camrrr.scroll.y = 3050;
            new FlxTimer().start(2, _ -> scene = 5);
        }}, function(v) {
            camrrr.scroll.y = v;
        });

        FlxTween.num(clip.height, 6500, 1, { ease: FlxEase.quadInOut }, function(v:Float) {
            clip.height = v;
            comic.clipRect = clip;
            trace(clip.height);
        });
    }

    if(scene == 5){
        scene = 5.5;
        FlxTween.tween(black, { alpha: 1 }, 3);
        FlxTween.num(FlxG.sound.volume, 0, 3, {
            ease: FlxEase.sineInOut,
            onComplete: function(twn:FlxTween) {
                FlxG.sound.music.pause();
                FlxG.sound.music.stop();
                FlxG.sound.volume = 1;
                PlayState.loadSong(Options.freeplayLastSong, Options.freeplayLastDifficulty, Options.freeplayLastVariation);
                var nextState = new PlayState();
                FlxG.switchState(nextState);
            }
        }, function(valor:Float) {
            FlxG.sound.volume = valor;
        });
    }
}