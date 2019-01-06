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
import box2D.collision.shapes.B2Shape;

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

import com.stencyl.graphics.shaders.BasicShader;
import com.stencyl.graphics.shaders.GrayscaleShader;
import com.stencyl.graphics.shaders.SepiaShader;
import com.stencyl.graphics.shaders.InvertShader;
import com.stencyl.graphics.shaders.GrainShader;
import com.stencyl.graphics.shaders.ExternalShader;
import com.stencyl.graphics.shaders.InlineShader;
import com.stencyl.graphics.shaders.BlurShader;
import com.stencyl.graphics.shaders.SharpenShader;
import com.stencyl.graphics.shaders.ScanlineShader;
import com.stencyl.graphics.shaders.CSBShader;
import com.stencyl.graphics.shaders.HueShader;
import com.stencyl.graphics.shaders.TintShader;
import com.stencyl.graphics.shaders.BloomShader;


class UI
{


	/*
	x
	y
	top
	left
	bottom
	right
	width
	height
	
	
	*/
	
	public static inline function style(a : Actor, s : String){
		setStyle(a, s);
	}
	
	public static function setStyle(a : Actor, s : String){
		var style = Texts.splitString(s, " :;\n");
		trace("Got style as: " + style);
		var property : String = "";
		var value : String = "";

		for(i in 0...style.length){
			if(i%2 == 0){
				property = style[i];
				continue;
			} else {
				value = style[i];
				trace("At " + value + ": last char is " + value.charAt(value.length - 1));
				// Style below:
				switch(property){
					case "x": a.setX(Std.parseInt(value));
					case "y": a.setY(Std.parseInt(value));
					case "top":
						if(value.charAt(value.length - 1) == "%")
							setPercentTop(a, Std.parseFloat(value));
						else
							setTop(a, Std.parseFloat(value));
					case "bottom":
						if(value.charAt(value.length - 1) == "%")
							setPercentBottom(a, Std.parseFloat(value));
						else
							setBottom(a, Std.parseFloat(value));
					case "left":
						if(value.charAt(value.length - 1) == "%")
							setPercentLeft(a, Std.parseFloat(value));
						else
							setLeft(a, Std.parseFloat(value));
					case "right":
						if(value.charAt(value.length - 1) == "%")
							setPercentRight(a, Std.parseFloat(value));
						else
							setRight(a, Std.parseFloat(value));
					case "width":
						if(value.charAt(value.length - 1) == "%")
							setWidthPercent(a, Std.parseFloat(value));
						else
							setWidth(a, Std.parseFloat(value));
					case "height":
						if(value.charAt(value.length - 1) == "%")
							setHeightPercent(a, Std.parseFloat(value));
						else
							setHeight(a, Std.parseFloat(value));
					case "mid-top":
						if(value.charAt(value.length - 1) == "%")
							setPercentMidTop(a, Std.parseFloat(value));
						else
							setMidTop(a, Std.parseFloat(value));
					case "mid-bottom":
						if(value.charAt(value.length - 1) == "%")
							setPercentMidBottom(a, Std.parseFloat(value));
						else
							setMidBottom(a, Std.parseFloat(value));
					case "mid-left":
						if(value.charAt(value.length - 1) == "%")
							setPercentMidLeft(a, Std.parseFloat(value));
						else
							setMidLeft(a, Std.parseFloat(value));		
					case "mid-right":
						if(value.charAt(value.length - 1) == "%")
							setPercentMidRight(a, Std.parseFloat(value));
						else
							setMidRight(a, Std.parseFloat(value));		
							
							
				}
			}
		}
	}

	// Pixel single dimensions
	public static function setWidth(a : Actor, w : Float){
		var newPercent = w / a.getWidth();
		trace("Got new percent as " + newPercent);
		a.growTo(newPercent, 1, 0, Linear.easeNone);
	}

	public static function setHeight(a : Actor, h : Float){
		var newPercent = h / a.getHeight();
		trace("Got new percent as " + newPercent);
		a.growTo(1, h, 0, Linear.easeNone);
		
	}
	
	// Percent single dimensions
	public static function setWidthPercent(a : Actor, w : Float){
		a.growTo((w * getScreenWidth() / 100) / a.getWidth(), 1, 0, Linear.easeNone);
	}

	public static function setHeightPercent(a : Actor, h : Float){
		a.growTo(1, (h * getScreenHeight() / 100) / a.getHeight(), 0, Linear.easeNone);
	}


	// Pixel single position
	public static function setTop(a : Actor, top : Float){
		a.setY(getScreenY() + top);
		a.anchorToScreen();
	}
	
	public static function setBottom(a : Actor, bottom : Float){
		a.setY(getScreenY() + getScreenHeight() - a.getHeight() - bottom);
		a.anchorToScreen();
	}
	
	public static function setLeft(a : Actor, left : Float){
		a.setX(getScreenX() + left);
		a.anchorToScreen();
	}
	
	public static function setRight(a : Actor, right : Float){
		a.setX(getScreenX() + getScreenWidth() - a.getWidth() - right);
		a.anchorToScreen();
	}
	
	public static function setMidTop(a : Actor, top : Float){
		a.setY(getScreenY() + getScreenHeight()/2 - a.getHeight()/2 - top);
		a.anchorToScreen();
	}
	
	public static function setMidBottom(a : Actor, bottom : Float){
		a.setY(getScreenY() + getScreenHeight()/2 - a.getHeight()/2 + bottom);
		a.anchorToScreen();
	}
	
	public static function setMidLeft(a : Actor, left : Float){
		a.setX(getScreenX() + getScreenWidth()/2 - a.getWidth()/2 - left);
		a.anchorToScreen();
	}
	
	public static function setMidRight(a : Actor, right : Float){
		a.setX(getScreenX() + getScreenWidth()/2 - a.getWidth()/2 + right);
		a.anchorToScreen();
	}
	
	
	// Percent single position
	public static function setPercentMidTop(a : Actor, top : Float){
		var perc = getScreenHeight() * (top / 100);
		a.setY(getScreenY() + getScreenHeight()/2 - a.getHeight()/2 - perc);
		a.anchorToScreen();
	}
	
	public static function setPercentMidLeft(a : Actor, left : Float){
		var perc = getScreenWidth() * (left / 100);
		a.setX(getScreenX() + getScreenWidth()/2 - a.getWidth()/2 - perc);
		a.anchorToScreen();
	}
	
	public static function setPercentMidBottom(a : Actor, top : Float){
		var perc = getScreenHeight() * (top / 100);
		a.setY(getScreenY() + getScreenHeight()/2 - a.getHeight()/2 + perc);
		a.anchorToScreen();
	}
	
	public static function setPercentMidRight(a : Actor, left : Float){
		var perc = getScreenWidth() * (left / 100);
		a.setX(getScreenX() + getScreenWidth()/2 - a.getWidth()/2 + perc);
		a.anchorToScreen();
	}
	
	public static function setPercentTop(a : Actor, top : Float){
		var perc = getScreenHeight() * (top / 100);
		a.setY(getScreenY() + perc);
		a.anchorToScreen();
	}
	
	public static function setPercentBottom(a : Actor, bottom : Float){
		var perc = getScreenHeight() * (bottom / 100);
		a.setY(getScreenY() + getScreenHeight() - a.getHeight() - perc);
		a.anchorToScreen();
	}
	
	public static function setPercentLeft(a : Actor, left : Float){
		var perc = getScreenWidth() * (left / 100);
		a.setX(getScreenX() + perc);
		a.anchorToScreen();
	}
	
	public static function setPercentRight(a : Actor, right : Float){
		var perc = getScreenWidth() * (right / 100);
		a.setX(getScreenX() + getScreenWidth() - a.getWidth() - perc);
		a.anchorToScreen();
	}
	
	
	// Pixel double position
	public static function setTopLeft(a : Actor, top : Float, left : Float){
		a.setY(getScreenY() + top);
		a.setX(getScreenX() + left);
		a.anchorToScreen();
	}
	
	public static function setTopRight(a : Actor, top : Float, right : Float){
		a.setY(getScreenY() + top);
		a.setX(getScreenX() + getScreenWidth() - a.getWidth() - right);
		a.anchorToScreen();
	}
	
	public static function setBottomLeft(a : Actor, bottom : Float, left : Float){
		a.setY(getScreenY() + getScreenHeight() - a.getHeight() - bottom);
		a.setX(getScreenX() + left);
		a.anchorToScreen();
	}

	public static function setBottomRight(a : Actor, bottom : Float, right : Float){
		a.setY(getScreenY() + getScreenHeight() - a.getHeight() - bottom);
		a.setX(getScreenX() + getScreenWidth() - a.getWidth() - right);
		a.anchorToScreen();
	}
	
	// Percent double position
	
	public static function setPercentTopLeft(a : Actor, top : Float, left : Float){
		setPercentTop(a, top);
		setPercentLeft(a, left);
	}
	
	public static function setPercentTopRight(a : Actor, top : Float, right : Float){
		setPercentTop(a, top);
		setPercentRight(a, right);
	}
	
	public static function setPercentBottomRight(a : Actor, bottom : Float, right : Float){
		setPercentBottom(a, bottom);
		setPercentRight(a, right);
	}
	
	public static function setPercentBottomLeft(a : Actor, bottom : Float, left : Float){
		setPercentBottom(a, bottom);
		setPercentLeft(a, left);
	}
	
	
	// Other Functions
	
	public static function sendOnTop(a : Actor){
		a.anchorToScreen();
	}

	public function new(){
		
	}

}
