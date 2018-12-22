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
	API:
	- You need to make a fader object in a Scene:
	var f = new Fader(255, 255, 0);		// Takes optional arguments red,green,blue (Int)
	f.fadeIn(1.5) // in seconds
	f.fadeOut(...)
	f.fadeInAndOut(1.5, 2.2)
	
*/

class Fader extends SceneScript
{
	var fadeAmount : Float = 0;
	var fadeIncrement : Float = 0;
	var isFadingIn = false;
	var isFadingOut = false;
	var screenHeight : Int;
	var screenWidth	 : Int;
	
	var red		: Int = 0;
	var green	: Int = 0;
	var blue	: Int = 0;
	
	private var ticksPerSecond : Float = 50;

	public function new(?r : Int, ?g : Int, ?b : Int)
	{
		super();
		if(b != null){
			red = r;
			blue = b;
			green = g;
		}
		screenHeight = getScreenHeight();
		screenWidth = getScreenWidth();
		addWhenDrawingListener(null, function(g:G, x:Float, y:Float, list:Array<Dynamic>):Void{
			draw(g);
			});
		runPeriodically(1000 / ticksPerSecond, function(timeTask:TimedTask):Void{
			updateFadeAmount();
			}, null);
	}
	
	public function fadeIn(overSeconds : Float){
		isFadingOut = false;
		isFadingIn = true;
		fadeAmount = 0;
		var miliseconds = overSeconds * 1000;
		fadeIncrement = 1 / (ticksPerSecond * miliseconds / 1000);					// 50 ... 1000, x ... miliseconds?
		trace(fadeIncrement);
		runLater(miliseconds, function(timeTask:TimedTask):Void{
			isFadingIn = false;
		}, null);
	}
	
	public function fadeOut(overSeconds : Float){
		isFadingIn = false;
		isFadingOut = true;
		fadeAmount = 1;
		var miliseconds = overSeconds * 1000;
		fadeIncrement = 1 / (ticksPerSecond * miliseconds / 1000);					// 50 ... 1000, x ... miliseconds?
		trace(fadeIncrement);
		runLater(miliseconds, function(timeTask:TimedTask):Void{
			isFadingOut = false;
		}, null);
	}
	
	public function fadeInAndOut(inSeconds : Float, outSeconds : Float){
		fadeIn(inSeconds);
		var miliseconds = inSeconds * 1000;
		runLater(miliseconds + 0.01, function(timeTask:TimedTask):Void{
			fadeOut(outSeconds);
		}, null);
	}
	
	
	
	
	// Private functions
	public function updateFadeAmount (){
		if(isFadingIn){
			fadeAmount += fadeIncrement;
			if(fadeAmount >= 100){
				isFadingIn = false;
			}
		} else if (isFadingOut){
			fadeAmount -= fadeIncrement;
			if(fadeAmount <= 0){
				isFadingOut = false;
			}
		}
	}
	
	public function draw (g : G){
		if(isFadingIn || isFadingOut){
			var oldAlpha = g.alpha;
			var oldColor = g.fillColor;
			g.fillColor = Utils.getColorRGB(red,green,blue);
			g.alpha = fadeAmount;
			g.fillRect(getScreenX(), getScreenY(), screenWidth, screenHeight);
			g.alpha = oldAlpha;
			g.fillColor = oldColor;
		}
	}
	
	
}
