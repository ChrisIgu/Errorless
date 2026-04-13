import funkin.backend.scripting.events.menu.freeplay.FreeplaySongSelectEvent;
import funkin.menus.FreeplayState.FreeplaySonglist;
import flixel.FlxG;

function onSelect(event:FreeplaySongSelectEvent) {
    var song = FreeplaySonglist.get().songs[0];

    Options.freeplayLastSong = song.name;
    Options.freeplayLastDifficulty = song.difficulties[0];
    Options.freeplayLastVariation = song.variants;
	PlayState.loadSong(Options.freeplayLastSong, Options.freeplayLastDifficulty, Options.freeplayLastVariation);

    event.cancel();
    
    if (FlxG.sound.music != null) {
        FlxG.sound.music.stop();
    }

    FlxG.switchState(new ModState('ComicState'));

}