package scripts;

import com.stencyl.graphics.G;

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
import com.stencyl.utils.Utils;

import nme.ui.Mouse;
import nme.display.Graphics;

import motion.Actuate;
import motion.easing.Back;
import motion.easing.Cubic;
import motion.easing.Elastic;
import motion.easing.Expo;
import motion.easing.Linear;
import motion.easing.Quad;
import motion.easing.Quart;
import motion.easing.Quint;
import motion.easing.Sine;

/*
	How to use:
	1. Create a FloatingTextManager object (var f = nwe FloatingTextManager(theFont, ?extraBounciness : Float)
			extraBounciness is a number between 0 and 1, 1 meaning 100% bonus and 0 0% bonus bounciness
	2. Use the .pump("text", x, y, ?right : Bool) function!
			if right is true, the text will jump right, else, left
	
	TODO: Customize it so it is customizable on X and Y axis both!
*/


/* private */ class Text_{
	public var x : Float;
	public var y : Float;
	public var text : String = "";
	public var gravityY : Float = 0;
	public var gravityX : Float = 0;
	public var isAlive : Bool = true;
	
	public function new(t : String, _x : Float, _y : Float, gy : Float, gx : Float, ?alive : Bool){
		text = t;
		x = _x;
		y = _y;
		gravityX = gx;
		gravityY = gy;
		if(alive != null){
			isAlive = alive;
		}
	}
	
	public inline function draw(g : G){
		g.drawString(text, x, y);
	}
	
	public inline function updatePositionsAndGravity(gravityIncrementY : Float, ?gravityIncrementX : Float){
		x += gravityX;
		y += gravityY;
		gravityY += gravityIncrementY;
		if(gravityIncrementX != null){
			gravityX += gravityIncrementX;
		}
	}
}

class FloatingTextManager extends SceneScript
{
	
	public var texts : Array<Text_>;
	
	var screenHeight : Float;
	var gravityIncrementY : Float = 0.2;
	var gravityDefaultY : Float = -3;
	var gravityDefaultX : Float = -3;
	private var font : Font = null;
	
	public function new(f : Font, ?bouncinessIncrement : Float){
		super();
		font = f;
		texts = new Array<Text_>();
		if(bouncinessIncrement != null){
			gravityIncrementY = gravityIncrementY * (bouncinessIncrement + 1);
			gravityDefaultY = gravityDefaultY * (bouncinessIncrement + 1);
			gravityDefaultX = gravityDefaultX * (bouncinessIncrement/2 + 1);
		}
		screenHeight = getScreenHeight();
		runPeriodically(20, function(timeTask:TimedTask):Void{
			updateGravities();
		}, null);
		addWhenDrawingListener(null, function(g:G, x:Float, y:Float, list:Array<Dynamic>):Void{
			drawTexts(g);
		});
	}
	
	public function pump(?nr: Float, ?s : String, x : Float, y : Float, ?right : Bool){
		var txt : String = "";
		if(nr != null){
			if(nr - Math.floor(nr) == 0){
				txt = "" + Std.int(nr);
			} else {
				txt = "" + nr;
			}
		} else {
			if(s != null){
				txt = s;
			}
		}
		var t : Text_ = null;
		if(right != null){
			if(right == true){
				t = new Text_(txt, x, y, gravityDefaultY, (-1) * gravityDefaultX);
			}
		} else {
			t = new Text_(txt, x, y, gravityDefaultY, gravityDefaultX);
		}
		addText(t);
	}
	
	private function addText(t : Text_){
		for(i in 0...texts.length){
			if(texts[i] != null){
				if(texts[i].isAlive == false){
					texts[i] = t;
					return;
				}
			}
		}
		texts.push(t);
	}
	
	private function updateGravities(){
		for(i in 0...texts.length){
			texts[i].updatePositionsAndGravity(gravityIncrementY);
			if(texts[i].y > screenHeight){
				texts[i].isAlive = false;
			}
		}
	}
	
	private function drawTexts(g : G){
		g.setFont(font);
		for(i in 0...texts.length){
			texts[i].draw(g);
		}
	}
	
}
