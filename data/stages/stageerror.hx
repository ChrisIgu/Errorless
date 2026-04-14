import funkin.backend.system.framerate.Framerate;
import flixel.math.FlxBasePoint;
import flixel.util.FlxGradient;

var uh = new FunkinShader('
// https://www.shadertoy.com/view/3tfcD8

#pragma header

float NoiseSeed;
float randomFloat(){
	NoiseSeed = sin(NoiseSeed) * 84522.13219145687;
	return fract(NoiseSeed);
}

float SCurve (float value, float amount, float correction) {
	float curve = 1.0;

	if (value < 0.5) {
		curve = pow(value, amount) * pow(2.0, amount) * 0.5; 
	}
	else { 	
		curve = 1.0 - pow(1.0 - value, amount) * pow(2.0, amount) * 0.5; 
	}

	return pow(curve, correction);
}




//ACES tonemapping from: https://www.shadertoy.com/view/wl2SDt
vec3 ACESFilm(vec3 x) {
	float a = 2.51;
	float b = 0.03;
	float c = 2.43;
	float d = 0.59;
	float e = 0.14;
	return (x*(a*x+b))/(x*(c*x+d)+e);
}




//Chromatic Abberation from: https://www.shadertoy.com/view/XlKczz
vec3 chromaticAbberation(sampler2D tex, vec2 uv, float amount) {
	float aberrationAmount = amount/10.0;
   	vec2 distFromCenter = uv - 0.5;

	// stronger aberration near the edges by raising to power 3
	vec2 aberrated = aberrationAmount * pow(distFromCenter, vec2(3.0, 3.0));
	
	vec3 color = vec3(0.0);
	
	for (int i = 1; i <= 8; i++) {
		float weight = 1.0 / pow(2.0, float(i));
		color.r += flixel_texture2D(tex, uv - float(i) * aberrated).r * weight;
		color.b += flixel_texture2D(tex, uv + float(i) * aberrated).b * weight;
	}
	
	color.g = flixel_texture2D(tex, uv).g * 0.9961; // 0.9961 = weight(1)+weight(2)+...+weight(8);
	
	return color;
}




//film grain from: https://www.shadertoy.com/view/wl2SDt
vec3 filmGrain() {
	return vec3(0.9 + randomFloat()*0.15);
}




//Sigmoid Contrast from: https://www.shadertoy.com/view/MlXGRf
vec3 contrast(vec3 color)
{
	return vec3(SCurve(color.r, 3.0, 1.0), 
				SCurve(color.g, 4.0, 0.7), 
				SCurve(color.b, 2.6, 0.6)
			   );
}




//anamorphic-ish flares from: https://www.shadertoy.com/view/MlsfRl
vec3 flares(sampler2D tex, vec2 uv, float threshold, float intensity, float stretch, float brightness) {
	threshold = 1.0 - threshold;
	
	vec3 hdr = flixel_texture2D(tex, uv).rgb;
	hdr = vec3(floor(threshold+pow(hdr.r, 1.0)));
	
	float d = intensity; //200.;
	float c = intensity*stretch; //100.;
	
	
	//horizontal
	for (float i=c; i>-1.0; i--)
	{
		float texL = flixel_texture2D(tex, uv+vec2(i/d, 0.0)).r;
		float texR = flixel_texture2D(tex, uv-vec2(i/d, 0.0)).r;
		hdr += floor(threshold+pow(max(texL,texR), 4.0))*(1.0-i/c);
	}
	
	//vertical
	for (float i=c/2.0; i>-1.0; i--)
	{
		float texU = flixel_texture2D(tex, uv+vec2(0.0, i/d)).r;
		float texD = flixel_texture2D(tex, uv-vec2(0.0, i/d)).r;
		hdr += floor(threshold+pow(max(texU,texD), 40.0))*(1.0-i/c) * 0.25;
	}
	
	hdr *= vec3(0.5,0.4,1.0); //tint
	
	return hdr*brightness;
}




//glow from: https://www.shadertoy.com/view/XslGDr (unused but useful)
vec3 samplef(vec2 tc, vec3 color)
{
	return pow(color, vec3(2.2, 2.2, 2.2));
}

vec3 highlights(vec3 pixel, float thres)
{
	float val = (pixel.x + pixel.y + pixel.z) / 3.0;
	return pixel * smoothstep(thres - 0.1, thres + 0.1, val);
}

vec3 hsample(vec3 color, vec2 tc)
{
	return highlights(samplef(tc, color), 0.6);
}

vec3 blur(vec3 col, vec2 tc, float offs)
{
	vec4 xoffs = offs * vec4(-2.0, -1.0, 1.0, 2.0) / openfl_TextureSize.x;
	vec4 yoffs = offs * vec4(-2.0, -1.0, 1.0, 2.0) / openfl_TextureSize.y;
	
	vec3 color = vec3(0.0, 0.0, 0.0);
	color += hsample(col, tc + vec2(xoffs.x, yoffs.x)) * 0.00366;
	color += hsample(col, tc + vec2(xoffs.y, yoffs.x)) * 0.01465;
	color += hsample(col, tc + vec2(	0.0, yoffs.x)) * 0.02564;
	color += hsample(col, tc + vec2(xoffs.z, yoffs.x)) * 0.01465;
	color += hsample(col, tc + vec2(xoffs.w, yoffs.x)) * 0.00366;
	
	color += hsample(col, tc + vec2(xoffs.x, yoffs.y)) * 0.01465;
	color += hsample(col, tc + vec2(xoffs.y, yoffs.y)) * 0.05861;
	color += hsample(col, tc + vec2(	0.0, yoffs.y)) * 0.09524;
	color += hsample(col, tc + vec2(xoffs.z, yoffs.y)) * 0.05861;
	color += hsample(col, tc + vec2(xoffs.w, yoffs.y)) * 0.01465;
	
	color += hsample(col, tc + vec2(xoffs.x, 0.0)) * 0.02564;
	color += hsample(col, tc + vec2(xoffs.y, 0.0)) * 0.09524;
	color += hsample(col, tc + vec2(	0.0, 0.0)) * 0.15018;
	color += hsample(col, tc + vec2(xoffs.z, 0.0)) * 0.09524;
	color += hsample(col, tc + vec2(xoffs.w, 0.0)) * 0.02564;
	
	color += hsample(col, tc + vec2(xoffs.x, yoffs.z)) * 0.01465;
	color += hsample(col, tc + vec2(xoffs.y, yoffs.z)) * 0.05861;
	color += hsample(col, tc + vec2(	0.0, yoffs.z)) * 0.09524;
	color += hsample(col, tc + vec2(xoffs.z, yoffs.z)) * 0.05861;
	color += hsample(col, tc + vec2(xoffs.w, yoffs.z)) * 0.01465;
	
	color += hsample(col, tc + vec2(xoffs.x, yoffs.w)) * 0.00366;
	color += hsample(col, tc + vec2(xoffs.y, yoffs.w)) * 0.01465;
	color += hsample(col, tc + vec2(	0.0, yoffs.w)) * 0.02564;
	color += hsample(col, tc + vec2(xoffs.z, yoffs.w)) * 0.01465;
	color += hsample(col, tc + vec2(xoffs.w, yoffs.w)) * 0.00366;

	return color;
}

vec3 glow(vec3 col, vec2 uv)
{
	vec3 color = blur(col, uv, 2.0);
	color += blur(col, uv, 3.0);
	color += blur(col, uv, 5.0);
	color += blur(col, uv, 7.0);
	color /= 4.0;
	
	color += samplef(uv, col);
	
	return color;
}

void main() {
	vec2 uv = openfl_TextureCoordv.xy;
	vec4 texColor = flixel_texture2D(bitmap, uv);
    vec3 color = texColor.rgb;
	
	
	//chromatic abberation
	color = chromaticAbberation(bitmap, uv, 0.3);
	
	
	//film grain
	color *= filmGrain();
	
	
	//ACES Tonemapping
  	color = ACESFilm(color);
	
	
	//glow
	color = clamp(.1 + glow(color, uv) * .9, .0, 1.);
	
	
	//contrast
	color = contrast(color) * 0.9;
	
	
	//flare
	color += flares(bitmap, uv, 0.9, 200.0, .04, 0.1);
	
	//output
	gl_FragColor = vec4(color, texColor.a); 
}
');

var clon:Character;
var clon2:Character;

var camMove:Bool = true;
var individualzoom:Bool = false;
var grrSteps:Int = 0;
var huddelamierdaaaa:HudCamera;
var degradado:FlxGradient;
var bloqueSolido:FlxSprite;
var contenedor:FlxSpriteGroup = new FlxSpriteGroup();
var particle:FunkinSprite = new FunkinSprite();
var backgrd:FunkinSprite;
var movement = new FlxBasePoint();

var healthArry:Array<FunkinSprite> = [];
var life:Int = 0;
var gameoverCheck:Bool = false;

FlxG.signals.postUpdate.addOnce(() -> {
    for(i in [Framerate.memoryCounter, Framerate.codenameBuildField, Framerate.fpsCounter.fpsNum]) i.visible = false;
    Framerate.fpsCounter.x = -20;
});

function postCreate() {
    clon = new Character(0, 0, boyfriend.curCharacter, boyfriend.isPlayer);
    clon2 = new Character(0, 0, dad.curCharacter, dad.isPlayer);

    FlxG.camera.zoom = defaultCamZoom = 1;

    FlxG.cameras.add(huddelamierdaaaa = new HudCamera(0, 0, 1280, 720, 1), false).bgColor = 0;
    huddelamierdaaaa.zoom = 0.9;
    huddelamierdaaaa.downscroll = Options.downscroll;

    FlxG.cameras.add(jejecam = new FlxCamera(), false).bgColor = 0x0;

	if(Options.gameplayShaders){
        camGame.addShader(uh);
        huddelamierdaaaa.addShader(uh);
	}

	boyfriend.setPosition(boyfriend.x + 200, boyfriend.y + 35);
	dad.setPosition(dad.x - 200, dad.y - 70);

    insert(0, topBar = new FunkinSprite().makeGraphic(FlxG.width, 60, 0xFF000000));
    topBar.camera = camHUD;

    insert(0, bottomBar = new FunkinSprite(0, 660).makeGraphic(FlxG.width, 60, 0xFF000000));
    bottomBar.camera = camHUD;

    for(strum in [player, cpu]){
        for (i in 0...4) {
            strum.members[i].camera = huddelamierdaaaa;
            (strum == player) ? strum.members[i].x += 100 : strum.members[i].x -= 100;
            strum.members[i].alpha = 0;
        }
    }

    comboGroup.setPosition(comboGroup.x + 900, comboGroup.y + 80);

    for(i in 0...10){
		var healthbarmc:FunkinSprite = new FunkinSprite(((FlxG.width / 2) - ((10 * 50 ) / 2)) + (i * 50),0);
        healthbarmc.frames = Paths.getFrames('life');
        healthbarmc.animation.addByPrefix('normal', "normal", 24, false);
        healthbarmc.animation.addByPrefix('half', "half", 24, false);
        healthbarmc.animation.addByPrefix('empty', "empty", 24, false);
        healthbarmc.scale.set(5,5);
        healthbarmc.updateHitbox();
        healthbarmc.y = FlxG.height - healthbarmc.height * 2;
        healthbarmc.camera = huddelamierdaaaa;
   		healthbarmc.animation.play('normal');
        add(healthbarmc);
        healthArry.push(healthbarmc);
    }
    life = healthArry.length * 2;

    for(i in [clon, clon2]){
        i.setPosition((i == clon) ? boyfriend.x + 200 : dad.x + 400, (i == clon) ? boyfriend.y : dad.y);
        i.alpha = 0;
        i.active = false;
        insert(0, i);
    }

	contenedor.camera = jejecam;

    degradado = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height, [FlxColor.BLACK, FlxColor.TRANSPARENT], 1, 90);

    bloqueSolido = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);

    degradado.y = FlxG.height; 
    bloqueSolido.y = 0;

    contenedor.add(degradado);
    contenedor.add(bloqueSolido);

    contenedor.y = -FlxG.height * 2; 
    contenedor.visible = false;
    add(contenedor);

    particle.frames = Paths.getFrames('particle');
    particle.animation.addByPrefix('particle', "particle", 24, false);
    particle.scale.set(0.8,0.8);
	particle.camera = jejecam;
	particle.color = 0xFF000000;
	particle.screenCenter();
    particle.alpha = 0;
	particle.animation.finishCallback = (_) -> remove(particle);
    add(particle);

    insert(0, ground = new FunkinSprite(-50, -100).loadGraphic(Paths.image("stages/errorless/Ground")));
    ground.scrollFactor.set(1, 1);
	ground.scale.set(2.5, 2.5);
	ground.alpha = 0;

    insert(0, skystorm = new FunkinSprite(-50, -100).loadGraphic(Paths.image("stages/errorless/Skystorm")));
    skystorm.scrollFactor.set(0.4, 0.4);
	skystorm.scale.set(2.5, 2.5);
	skystorm.alpha = 0;

    for (obj in [scoreTxt, missesTxt, accuracyTxt, iconP1, iconP2, healthBar, healthBarBG, boyfriend, dad]) obj.alpha = 0;

    for (line in [strumLines.members[0], strumLines.members[1]]){
        for (i in 0...4) FlxTween.tween(line.members[i], {visible: false, alpha: 0}, 0.2);
    }
}

function onSongStart(){
    for (line in [strumLines.members[0], strumLines.members[1]]){
        for (i in 0...4) FlxTween.tween(line.members[i], {visible: true, alpha: 0}, 0.2);
    }
}

function update(elapsed:Float) {
    Framerate.fpsCounter.fpsLabel.text =  Framerate.fpsCounter.fpsNum.text + " FPS / " + Framerate.memoryCounter.memoryText.text;
    if (clon != null && boyfriend != null && boyfriend.animation.curAnim != null) {
        if (clon.animation.curAnim == null || clon.animation.curAnim.name != boyfriend.animation.curAnim.name) {
            clon.playAnim(boyfriend.animation.curAnim.name, true);
        }

        clon.animation.curAnim.curFrame = boyfriend.animation.curAnim.curFrame;
        
        clon.offset.set(boyfriend.offset.x, boyfriend.offset.y);
    }

    if (clon2 != null && dad != null && dad.animation.curAnim != null) {
        if (clon2.animation.curAnim == null || clon2.animation.curAnim.name != dad.animation.curAnim.name) {
            clon2.playAnim(dad.animation.curAnim.name, true);
        }

        clon2.animation.curAnim.curFrame = dad.animation.curAnim.curFrame;
        
        clon2.offset.set(dad.offset.x, dad.offset.y);
    }
    if(life <= 0 && !gameoverCheck){
        gameoverCheck = true;
        canPause = false;
        camMove = false;
        individualzoom = false;
        openSubState(new ModSubState("GameOver"));
    }
    if(life > healthArry.length * 2) {
        life = healthArry.length * 2;
    }

    if(boyfriend.color != -1029){
        boyfriend.color = FlxColor.interpolate(boyfriend.color, 0xFFFFFFFF, 0.2);
        trace("color: " + boyfriend.color);
    }
    if(boyfriend.color == -67108865){
        boyfriend.color = 0xFFFF0000;
    }
}

function onPlayerMiss(e) {
  if (!e.note.isSustainNote) {
    if (life > 0) {
        life -= 1;
            
        var index:Int = Math.floor(life / 2);
        var isHalf:Bool = (life % 2 == 1);

        if (isHalf) {
            healthArry[index].animation.play('half');
        } else {
            healthArry[index].animation.play('empty');
        }
    }
    trace(life);
    FlxG.sound.play(Paths.sound("hit1"), 1);
    boyfriend.color = 0xFFFF0000;
    }
}

function onPlayerHit(event:NoteHitEvent) {
    if (!event.note.isSustainNote) {
        if (life < healthArry.length * 2) {
            var index:Int = Math.floor(life / 2);
            var isCurrentlyEmpty:Bool = (life % 2 == 0);
    
        if (isCurrentlyEmpty) {
                healthArry[index].animation.play('half');
            } else {
                healthArry[index].animation.play('normal');
            }
            
            life += 1;
        }
        trace(life);
    }
}

function onDadHit(){
	if(!individualzoom) return;
    camGame.shake(0.006,0.2, null, true, null);
    huddelamierdaaaa.shake(0.006,0.2, null, true, null);
}

function onGameOver(_) _.cancel();

function onCameraMove(e:CamMoveEvent){
    if(camMove){
        switch (strumLines.members[curCameraTarget].characters[0].getAnimName()) {
            case "singLEFT": movement.set(-90, 0);
                FlxG.camera.angle = lerp(FlxG.camera.angle, -1.5, 0.055);
            case "singDOWN": movement.set(0, 90);
                FlxG.camera.angle = lerp(FlxG.camera.angle, 0, 0.055);
            case "singUP": movement.set(0, -90);
                FlxG.camera.angle = lerp(FlxG.camera.angle, 0, 0.055);
            case "singRIGHT": movement.set(90, 0);
                FlxG.camera.angle = lerp(FlxG.camera.angle, 1.5, 0.055);
            default: movement.set(0, 0);
                FlxG.camera.angle = lerp(FlxG.camera.angle, 0, 0.01);
        }
        e.position.x += movement.x;
        e.position.y += movement.y;
    }else{
        e.cancel();
	}

	if(!individualzoom) return;
	FlxTween.num(defaultCamZoom, (e.strumLine == strumLines.members[0]) ? 0.5 : 0.7, 0.2, { ease: FlxEase.smoothStepInOut }, function(v){ defaultCamZoom = v;});
}

function stepHit(){
    if(curStep >= 50 && grrSteps == 0){
		grrSteps = 1;
        camMove = false;
        FlxTween.tween(clon2, {x: clon2.x + 850, alpha: 1}, 4, {ease: FlxEase.smoothStepInOut});
        for (line in [strumLines.members[0]]){
            for (i in 0...4) FlxTween.tween(line.members[i], {alpha: 1}, 6, {ease: FlxEase.smoothStepInOut});
        }
    }
    if(curStep >= 120 && grrSteps == 1){
		grrSteps = 2;
        FlxTween.tween(clon, {x: clon.x - 600, alpha: 1}, 4, {ease: FlxEase.smoothStepInOut});
        for (line in [strumLines.members[1]]){
            for (i in 0...4) FlxTween.tween(line.members[i], {alpha: 1}, 6, {ease: FlxEase.smoothStepInOut});
        }
    }
    if(curStep >= 186 && grrSteps == 2){
		grrSteps = 3;
        FlxTween.tween(clon2, {x: clon2.x + 1250, alpha: 1}, 1, {ease: FlxEase.smoothStepInOut});
        FlxTween.tween(clon, {x: clon.x - 1100, alpha: 1}, 1, {ease: FlxEase.smoothStepInOut});
    }
    if(curStep >= 192 && grrSteps == 3){
		grrSteps = 4;
        for(i in [clon, clon2]) i.kill();
        FlxG.camera.flash(0xFFFFFFFF, 2);
        camMove = true;
        contenedor.visible = true;

        FlxTween.num(defaultCamZoom, 0.5, 1, { ease: FlxEase.quadInOut, onComplete: function(_) {
            FlxTween.num(0.5, 1, 10, { ease: FlxEase.cubeIn, onComplete: function(_) {
                FlxTween.num(camGame.scroll.y, -1300, 1.4, { ease: FlxEase.cubeIn }, function(v) {
                    camMove = false;
                    camGame.scroll.y = v;
                });
				FlxTween.num(-FlxG.height * 2, 0, 1.5, {ease: FlxEase.cubeIn}, function(v) {
 	                contenedor.y = v;
	            });
                FlxTween.num(1, 1.5, 1, { ease: FlxEase.cubeIn }, function(v) {
                    defaultCamZoom = v;
                });
            }}, function(v) {
                defaultCamZoom = v;
            });
        }}, function(v) {
            defaultCamZoom = v;
        });

        for(sprite in [boyfriend, dad]) {
            sprite.alpha = 1;
            sprite.cameraOffset.set(0, sprite.cameraOffset.y + (sprite == boyfriend ? 50 : 150));
        }
    }
	if(curStep >= 352 && grrSteps == 4){
		grrSteps = 5;
        for(sprite in [boyfriend, dad]) {
			sprite.scale.set(0.8, 0.8);
            sprite.setPosition(sprite.x + (sprite == boyfriend ? -200 : -100), sprite.y + (sprite == boyfriend ? 0 : 50));
            sprite.cameraOffset.set(sprite.cameraOffset.x + (sprite == boyfriend ? -150 : 150), sprite.cameraOffset.y + (sprite == boyfriend ? -80 : 0));
		}
		ground.alpha = skystorm.alpha = particle.alpha = 1;
        camMove = true;
        camGame.scroll.y = 0;
        defaultCamZoom = 0.5;
		//camGame.setFilters([]);
		contenedor.clear();
        contenedor.destroy();
        remove(contenedor);
		particle.animation.play('particle');
		individualzoom = true;
	}

	if(curStep >= 606 && grrSteps == 5){
		grrSteps = 6;
        individualzoom = false;
        dad.cameraOffset.set(dad.cameraOffset.x - 200, dad.cameraOffset.y);
	}

	if(curStep >= 671 && grrSteps == 6){
		grrSteps = 7;
        individualzoom = true;
	}

    if(curStep >= 732 && grrSteps == 7){
    	grrSteps = 8;
        FlxG.camera.flash(0xFFFFFFFF, 2);
        for(i in [dad, boyfriend]) i.setColorTransform(1,1,1,1,255,255,255,0);
        ground.alpha = skystorm.alpha = 0;

        if (clon.curCharacter != boyfriend.curCharacter) {
            remove(clon);
            clon = new Character(boyfriend.x + 200, boyfriend.y - 650, boyfriend.curCharacter, boyfriend.isPlayer);
            insert(0, clon);
        }
        
        if (clon2.curCharacter != dad.curCharacter) {
            remove(clon2);
            clon2 = new Character(dad.x - 200, dad.y - 700, dad.curCharacter, dad.isPlayer);
            insert(0, clon2);
        }

        for(i in [clon, clon2]){
            i.active = false;
            i.camera = camHUD;
            i.setColorTransform(1,1,1,1,255,255,255,0);
            i.alpha = 0;
        }

        individualzoom = false;
        camMove = false;
        FlxTween.num(defaultCamZoom, 4, 2, { ease: FlxEase.cubeIn }, function(v) {
                defaultCamZoom = v;
        });
        FlxTween.num(camGame.scroll.x, camGame.scroll.x - 170, 2, { ease: FlxEase.cubeIn }, function(v) {
                camGame.scroll.x = v;
                camGame.followLerp = 0;
        });
    }

    if(curStep >= 792 && grrSteps == 8){
        grrSteps = 9;
        FlxTween.tween(clon, {alpha: 1, x: clon.x - 400}, 2.5, {ease: FlxEase.smoothStepInOut});
    }

    if(curStep >= 824 && grrSteps == 9){
        grrSteps = 10;
        FlxTween.tween(clon2, {alpha: 1, x: clon2.x + 400}, 2.5, {ease: FlxEase.smoothStepInOut});
    }
    
    if(curStep >= 864 && grrSteps == 10){
        grrSteps = 11;
        FlxG.camera.flash(0xFFFFFFFF, 2);
        boyfriend.setColorTransform(1,1,1,1,0,0,0,0);
        dad.setColorTransform(1,1,1,1,0,0,0,0);
        FlxTween.num(camGame.scroll.x, camGame.scroll.x + 170, 2, { ease: FlxEase.cubeIn }, function(v) {
                camGame.scroll.x = v;   
        });
        for(sprite in [boyfriend, dad]) {
            sprite.cameraOffset.set(sprite.cameraOffset.x + (sprite == boyfriend ? 0 : 300), sprite.cameraOffset.y + (sprite == boyfriend ? 450 : 300));
            sprite.setPosition(sprite.x + (sprite == boyfriend ? 0 : 200), sprite.y + (sprite == boyfriend ? 0 : 250));
        }
        camGame.followLerp = 0.03;
        individualzoom = true;
        camMove = true;
        ground.alpha = skystorm.alpha = 1;
        for(i in [clon, clon2]) i.kill();
    }
}
