var black:FlxSprite;
var topBar:FlxSprite;
var bottomBar:FlxSprite;
function create(){
    transitionTween.cancel();
	remove(blackSpr);
	remove(transitionSprite);

    var fuera = newState != null;
    done();
    transitionCamera.scroll.y = 0;

}

function done()
{
	if (newState != null)
		FlxG.switchState(newState);

	new FlxTimer().start(2, ()-> {
			close();
	});
}