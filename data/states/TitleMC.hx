import funkin.backend.MusicBeatState;

var booleed:Bool = false;
var intro:FlxSprite;
var bar:FlxSprite;
var bar2:FlxSprite;
var bar3:FlxSprite;
var num:Int = 0;

function create(){
    FlxG.sound.playMusic(Paths.music('MainMenu'), 0, true);

    insert(0, screenshot = new FlxSprite(0, 0).loadGraphic(Paths.image('screenshot')));
    screenshot.setGraphicSize(FlxG.width, FlxG.height);
    screenshot.screenCenter(FlxAxes.XY);

    insert(1, intro = new FlxSprite(0, 0).loadGraphic(Paths.image('intro')));
    intro.scale.set(0.95,0.95);
    intro.screenCenter(FlxAxes.XY);

    add(bar = new FlxSprite(0, FlxG.height / 1.2).makeGraphic(FlxG.width / 1.8, 20, 0xFFef323d));
    bar.screenCenter(FlxAxes.X);

    insert(2, bar2 = new FlxSprite(bar.x -2, bar.y - 2).makeGraphic(bar.width + 4, bar.height + 4, 0xFFFFFFFF));

    add(bar3 = new FlxSprite(bar.x + 2, bar.y + 2).makeGraphic(1, bar.height - 4, 0xffffffff));
    bar3.origin.set(0, 0);
}

function update(elapsed:Float) {
    trace(num);
	if (FlxG.sound.music != null)
		Conductor.songPosition = FlxG.sound.music.time;

	var pressedEnter:Bool = FlxG.keys.justPressed.ENTER;

	if (pressedEnter){
        for(i in [bar, bar2, bar3])FlxTween.tween(i, {alpha: 0}, 1, {ease: FlxEase.quintOut, onComplete: pressEnter()});
    }
}

function beatHit(){
    if(curBeat % 1 == 0){
        var limiteMaximo:Float = bar.width - 4;
        
        num = FlxG.random.int(20, 100);
        bar3.scale.x = Math.min(bar3.scale.x + num, limiteMaximo);
        
        if(bar3.width >= limiteMaximo){
            bar3.scale.x = limiteMaximo;
            for(i in [bar, bar2, bar3]) {
                FlxTween.tween(i, {alpha: 0}, 1, {
                    ease: FlxEase.quintOut, 
                    onComplete: function(twn:FlxTween) { pressEnter(); }
                });
            }
        }
        
        bar3.updateHitbox();
    }
}

function pressEnter(){
    FlxTween.tween(intro, {alpha: 0}, 1.5, {ease: FlxEase.quintOut, onComplete: function(){
	    MusicBeatState.skipTransOut = true;
	    FlxG.switchState(new MainMenuState());
    }});
}