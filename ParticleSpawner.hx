/* NOTE: Requires:
	Queue.hx
	Texts.hx
*/

/*
	How to use:
	var p = new ParticleSpawner(
		fileNameWithExtension : String,	// Ex: "image.png"
		x : Float,
		y : Float,
		direction : ...		// Use ParticleSpawner.UP, ParticleSpawner.LEFT, ParticleSpawner. STATIC, etc
		?frequency	: Int	// In miliseconds, 200 by default
		?lifespan	: Int	// In miliseconds, 2000 by default
	)
	
	HOWEVER...
	You should use this method instead, which utilizes CSS-like properties:
	var p = ParticleSpawner.create("
			file-name: water.png;
			x: 200;
			y: 200;
			gravity-x: 0;
			gravity-y: 1;
			frequency: 100;
			lifespan: 4000")
	List of properties:
		file-name
		x
		y
		direction
		gravity-x
		gravity-y
		frequency
		lifespan
		rotate
		variation-x
		variation-y
	
	API:
	.stop()
	.start()
	.attachToActor(Actor)
	
	
*/

package scripts;


import com.stencyl.graphics.G;
import com.stencyl.graphics.BitmapWrapper;

import com.stencyl.behavior.Script;
import com.stencyl.behavior.Script.*;
import com.stencyl.behavior.ActorScript;
import com.stencyl.behavior.SceneScript;
import com.stencyl.behavior.TimedTask;

import com.stencyl.models.Actor;
import com.stencyl.models.GameModel;
import com.stencyl.models.actor.Animation;
import com.stencyl.models.actor.ActorType;
import com.stencyl.models.actor.Collision;
import com.stencyl.models.actor.Group;
import com.stencyl.models.Scene;
import com.stencyl.models.Sound;
import com.stencyl.models.Region;
import com.stencyl.models.Font;
import com.stencyl.models.Joystick;

import com.stencyl.Engine;
import com.stencyl.Input;
import com.stencyl.Key;
import com.stencyl.utils.Utils;

import openfl.ui.Mouse;
import openfl.display.Graphics;
import openfl.display.BlendMode;
import openfl.display.BitmapData;
import openfl.display.Bitmap;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.TouchEvent;
import openfl.net.URLLoader;

import box2D.common.math.B2Vec2;
import box2D.dynamics.B2Body;
import box2D.dynamics.B2Fixture;
import box2D.dynamics.joints.B2Joint;

class ImageX{
	
	public var imageBase : BitmapData;
	public var image : BitmapWrapper;
	public var baseAngle : Float = 0;
	public var speedX : Float = 0;
	public var speedY : Float = 0;
	
	public function new(imageBase : BitmapData, x : Float, y : Float, ?layerName : String, _speedX : Float, _speedY : Float){
		image = new BitmapWrapper(new Bitmap(imageBase));
		speedX = _speedX;
		speedY = _speedY;
		//setOriginForImage(image, image.width/Engine.SCALE/2, image.height/Engine.SCALE/2);
		if(layerName == null){	
			attachImageToHUD(image, Std.int(x), Std.int(y));
		} else {
			attachImageToLayer(image, 1, layerName, Std.int(x), Std.int(y), 1);
		}
		setOriginForImage(image, image.width/2/Engine.SCALE, image.height/2/Engine.SCALE);
	}
	
	public inline function kill(){removeImage(image);}
	
	public inline function getX(){ return image.x/Engine.SCALE;}
	public inline function getY(){ return image.y/Engine.SCALE;}
	public inline function getWidth(){ return image.width/Engine.SCALE;}
	public inline function getHeight(){ return image.height/Engine.SCALE;}
	public inline function getRotation(){ return image.rotation;}
	public inline function getOpacity(){ return image.alpha;}
	
	public inline function setX(x : Float){setXForImage(image, x);}
	public inline function addX(x : Float){setXForImage(image, getX() + x);}
	public inline function setY(y : Float){setYForImage(image, y);}
	public inline function addY(y : Float){setYForImage(image, getY() + y);}
	public inline function setRotation(a : Float){image.rotation = a;}
	public inline function addRotation(a : Float){image.rotation += a;}
	public inline function setOpacity(o : Float){image.alpha = o;}
	public inline function addOpacity(o : Float){image.alpha += o;}
	
	public inline function addSize(f : Float){
		image.scaleX += f;
		image.scaleY += f;
	}
	
	public function setSizePercent(f : Float){
		image.scaleX = f;
		image.scaleY = f;
	}
	
}

class ParticleSpawner{

	public static inline var FadeIn = 1;
	public static inline var FadeOut = 2;
	public static inline var FadeNone = 0;
	public static inline var FadeOutIn = 3;

	var imageBase : BitmapData;
	var x : Float;
	var y : Float;
	var direction : Float = 0;	// Direction or angle of the spawner
	var actorAttachedTo : Actor = null;
	
	var particleLifespan : Int = 2000;
	var particleFrequency : Int = 400;
	var particleSpeed : Float = 3;
	
	var xVariation : Int = 10;
	var yVariation : Int = 10;
	var directionVariation : Int = 10;
	
	var opacitySpeed : Float = 0;
	var fadeType : Int = FadeNone;
	
	var defaultRotation : Float = 0;
	var rotationVariation : Float = 10;
	var rotationSpeed : Float = 0;
	
	var defaultSize : Float = 1;
	var sizeVariation : Float = 0.2;
	var growSpeed : Float = 0;
	
	var gravityX : Float = 0;
	var gravityY : Float = 0;
	
	
	var particles : Queue<ImageX>;
	
	private var canKillParticles = false;
	private var isActive = true;
	
	public static function create(fileName : String, x : Float, y : Float, type : String){
		var p : ParticleSpawner = null;
		switch(type){
			case "smoke":
				var p = new ParticleSpawner("particle.png", x, y, -90, ParticleSpawner.FadeOut, 2, 0, 1, 0.015, 0, 0, 200, 2500);
				p.directionVariation = 6;
			case "smokesmall":
				var p = new ParticleSpawner("particle.png", x, y, -90, ParticleSpawner.FadeOut, 2, 0, 1, 0.015, 0, 0, 200, 2500);
				p.directionVariation = 6;
				p.particleSpeed = 1.85;
			case "smokenorotate":
				var p = new ParticleSpawner("particle.png", x, y, -90, ParticleSpawner.FadeOut, 0, 0, 1, 0.015, 0, 0, 200, 2500);
				p.directionVariation = 6;
		}
		return p;
		
	}

	public function new(fileName : String,
						_x : Float,
						_y : Float,
						_direction : Float,
						_fadeType : Int,
						_rotationSpeed : Float,
						_defaultRotation : Float,
						_defaultSize : Float,
						_growSpeed : Float,
						_gravityX : Float,
						_gravityY : Float,
						_particleFrequency : Int,
						_particleLifespan : Int
						){
		particles = new Queue<ImageX>();
		imageBase = getExternalImage(fileName);
		x = _x;
		y = _y;
		direction = _direction;
		fadeType = _fadeType;
		defaultSize = _defaultSize;
		growSpeed = _growSpeed;
		gravityX = _gravityX;
		gravityY = _gravityY;
		particleFrequency = _particleFrequency;
		particleLifespan = _particleLifespan;
		switch(fadeType){
			case 1: opacitySpeed = 20 / particleLifespan;		// Fade Out
			case 2: opacitySpeed = -20 / particleLifespan;		// Fade In
			case 3: opacitySpeed = 20 / particleLifespan;		// Fade Out In
		}
		rotationSpeed = _rotationSpeed;
		defaultRotation = _defaultRotation;
		runPeriodically(20 , function(timeTask:TimedTask):Void{
			updateParticles();
		}, null);
		runPeriodically(particleFrequency, function(timeTask:TimedTask):Void{
			if(isActive){
				spawnNewParticle();
			}
			if(canKillParticles){
				killFirstParticle();
			}
		}, null);
		startKillingParticlesAfter(particleLifespan);
	}
	
	public function start(){
		if(!isActive){
			canKillParticles = false;
			isActive = true;
			startKillingParticlesAfter(particleLifespan);
		}
	}
	public function stop(){isActive = false;}
	
	
	public function attachToActor(a : Actor){
		actorAttachedTo = a;
	}
	
	
	private function updateParticles(){
		var iter = particles.first;
		while(iter != null){
			updateParticle(iter.data);
			iter = iter.next;
		}
	}
	
	private function updateParticle(img : ImageX){
		img.addX(img.speedX);
		img.addY(img.speedY);
		updateParticleOpacity(img);
		if(rotationSpeed != 0)
			img.addRotation(rotationSpeed);
		if(growSpeed != 0)
			img.addSize(growSpeed);
		img.speedX += gravityX;
		img.speedY += gravityY;
		
	}
	
	private function updateParticleOpacity(img : ImageX){
		if(fadeType == FadeIn || fadeType == FadeOut){
			img.addOpacity(opacitySpeed);
		} else if(fadeType == FadeOutIn){
			if(img.getOpacity() >= 1){
				img.addOpacity(-opacitySpeed);
			} else {
				img.addOpacity(opacitySpeed);
			}
		}
	}
	
	private function startKillingParticlesAfter(time : Int){
		runLater(time, function(timeTask:TimedTask):Void{
			canKillParticles = true;
		}, null);
	}
	
	private function spawnNewParticle(){
		var xVar = randomInt(-xVariation, xVariation);
		var yVar = randomInt(-yVariation, yVariation);
		var dVar = randomInt(-directionVariation, directionVariation);
		var rVar = randomInt(-rotationVariation, rotationVariation);
		var sVar = randomInt(-sizeVariation, sizeVariation);
		spawnParticle(x + xVar, y + yVar, direction + dVar, defaultRotation + rVar, defaultSize + sVar);
	}
	
	private function spawnParticle(x : Float, y : Float, direction : Float, rot : Float, size : Float){
		//trace("Got direction: " + direction);
		var speedX = Math.cos(direction * Utils.RAD) * particleSpeed;
		var speedY = Math.sin(direction * Utils.RAD) * particleSpeed;
		//trace("Spawned with " + speedX + ", " + speedY);
		var img = new ImageX(imageBase, x, y, speedX, speedY);
		if(opacitySpeed > 0){
			img.setOpacity(0);
		}
		img.setRotation(rot);
		img.setSizePercent(size);
		particles.push(img);
	}
	
	private function killFirstParticle(){
		if(particles.peek() == null) return;
		particles.peek().kill();
		particles.pop();
	}
	
	
	
	

}

/*

class ParticleSpawner
{

	public static inline var LEFT = 0;
	public static inline var RIGHT = 1;
	public static inline var UP = 2;
	public static inline var DOWN = 3;
	public static inline var STATIC = 4;
	
	public static inline var FADENONE = 0;
	public static inline var FADEIN = 1;
	public static inline var FADEOUT = 2;
	
	public var image : BitmapData;
	public var x : Float = 0;
	public var y : Float = 0;
	public var gravityX : Float = 0;
	public var gravityY : Float = 0;
	public var variationX : Int = 10;
	public var variationY : Int = 10;
	public var type : Int = UP;
	public var particleLifespan : Int = 2000;
	public var particleFrequency : Int = 200;
	public var isActive = true;
	public var ownerActor : Actor = null;
	public var rotationSpeed : Float = 0;
	public var fadeType : Int = FADENONE;
	public var fadePerTick : Float = 0;
	
	private static var defaultGravity : Float = 3;
	
	private var canKillParticles : Bool = false;
	
	private var particles : Queue<ImageX> = null;
	
	public function new(fileName : String,
						_x 		 : Float,
						_y 		 : Float,
						_type 	 : Int,
						?rs 	 : Float,
						?fr 	 : Int,
						?ls 	 : Int,
						?fade 	 : Int,
						?enable  : Bool){
		if(enable == false){
			isActive = false;}
		if(fr != null){
			particleFrequency = fr;
		}
		if(ls != null){
			particleLifespan = ls;
		}
		if(rs != null){
			rotationSpeed = rs;
		}
		if(fade != null){
			fadeType = fade;
			if(fade == FADEIN){
				fadePerTick = 20 / particleLifespan;
			}
			if(fade == FADEOUT){
				fadePerTick = -20 / particleLifespan;
			}
		}
		image = getExternalImage(fileName);
		x = _x;
		y = _y;
		particles = new Queue<ImageX>();
		setDirection(_type);
		runPeriodically(20 , function(timeTask:TimedTask):Void{
			updateParticles();
		}, null);
		runPeriodically(particleFrequency, function(timeTask:TimedTask):Void{
			if(isActive){
				spawnNewParticle();
			}
			if(canKillParticles){
				killFirstParticle();
			}
		}, null);
		runLater(particleLifespan, function(timeTask:TimedTask):Void{
			canKillParticles = true;
		}, null);
		trace("Spawner successfully created");
	}
	
	private function setDirection(dir : Int){
		type = dir;
		switch(dir){
			case LEFT:
				gravityX = -defaultGravity;
			case RIGHT:
				gravityX = defaultGravity;
			case UP:
				gravityY = -defaultGravity;
			case DOWN:
				gravityY = defaultGravity;
			default:
				gravityY = -defaultGravity;
		}
	}
	
	public function attachToActor(a : Actor){
		ownerActor = a;
	}
	
	public function detach(){
		ownerActor = null;
	}
	
	public function stop(){
		isActive = false;
	}
	
	public function start(){
		canKillParticles = false;
		isActive = true;
		runLater(particleLifespan, function(timeTask:TimedTask):Void{
			canKillParticles = true;
		}, null);
	}
	
	private function spawnParticle(_x : Float, _y : Float){
		var p : ImageX = new ImageX(image, _x, _y);
		particles.push(p);
	}
	
	private function updateParticles(){
		var iter = particles.first;
		while(iter != null){
			updateParticle(iter.data);
			iter = iter.next;
		}
	}
	
	private function updateParticle(im : ImageX){
		im.setX(im.getX() + gravityX);
		im.setY(im.getY() + gravityY);
		if(rotationSpeed != 0){
			im.setAngle(im.getAngle() + rotationSpeed);
		}
		if(fadeType != FADENONE){
			im.setOpacity(im.getOpacity() + fadePerTick);
		}
	}
	
	private function spawnNewParticle(){
		if(ownerActor == null){
			spawnParticle(x + randomInt(-variationX, variationX), y + randomInt(-variationY, variationY));
		} else {
			spawnParticle(ownerActor.x + randomInt(-variationX, variationX), ownerActor.y + randomInt(-variationY, variationY));
		}
	}
	
	private function killFirstParticle(){
		if(particles.peek() == null) return;
		particles.peek().kill();
		particles.pop();
	}
	

	
}


*/





















/*
	public static function create(?a : Actor, s : String){
		var style = Texts.splitString(s, " :;\n");
		trace("Got style as: " + style);
		var property : String = "";
		var value : String = "";
		
		var _fileName : String = "";
		var _x : Float = 0;
		var _y : Float = 0;
		var _gravityX : Float = -13.37;
		var _gravityY : Float = -13.37;
		var _variationX : Int = 20;
		var _variationY : Int = 20;
		var _direction : Int = UP;
		var _particleLifespan : Int = 2000;
		var _particleFrequency : Int = 200;
		var _rotationSpeed : Float = 0;
		var _fade : Int = FADENONE;

		for(i in 0...style.length){
			if(i%2 == 0){
				property = style[i];
				continue;
			} else {
				value = style[i];
				// Style below:
				trace(property + ":" + value);
				switch(property){
					case "file-name": _fileName = value;
					case "x": _x = Std.parseFloat(value);
					case "y": _y = Std.parseFloat(value);
					case "direction":
						if(value == "up")     _direction = UP;
						if(value == "down")   _direction = DOWN;
						if(value == "left")   _direction = LEFT;
						if(value == "right")  _direction = RIGHT;
						if(value == "static") _direction = STATIC;
					case "gravity-x": _gravityX = Std.parseFloat(value);
					case "gravity-y": _gravityY = Std.parseFloat(value);
					case "frequency": _particleFrequency = Std.parseInt(value);
					case "lifespan": _particleLifespan = Std.parseInt(value);
					case "variation-x": _variationX = Std.parseInt(value);
					case "variation-y": _variationY = Std.parseInt(value);
					case "rotation-speed": _rotationSpeed = Std.parseFloat(value);
					case "fade":
						if(value == "none"){_fade = FADENONE;}
						else if(value == "in"){
							_fade = FADEIN;
						} else if(value == "out"){
							_fade = FADEOUT;
							trace("Fade indeed out");
						}
				}
			}
		}
		var self : ParticleSpawner = new ParticleSpawner(_fileName, _x, _y, _direction, _rotationSpeed, _particleFrequency, _particleLifespan, _fade);
		if(_gravityX != 13.37){
			self.gravityX = _gravityX;
		}
		if(_gravityY != 13.37){
			self.gravityY = _gravityY;
		}
		if(a != null){
			self.attachToActor(a);
		}
		return self;

	}

*/

