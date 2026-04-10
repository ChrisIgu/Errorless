import funkin.backend.system.framerate.Framerate;

FlxG.signals.postUpdate.addOnce(() -> {
    for(i in [Framerate.memoryCounter, Framerate.codenameBuildField, Framerate.fpsCounter.fpsNum]) i.visible = false;
    Framerate.fpsCounter.x -= 20;
});

function update(elapsed:Float) {
    if (FlxG.keys.justPressed.THREE) FlxG.resetState();
    Framerate.fpsCounter.fpsLabel.text =  Framerate.fpsCounter.fpsNum.text + " FPS / " + Framerate.memoryCounter.memoryText.text;
}