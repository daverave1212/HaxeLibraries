
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

class ImageX
{
	
	var image : BitmapWrapper;
	var layerName : String;
	
	public function new(?path : String, ?bitmapData : BitmapData, layerName : String){
		if(path != null){
			image = new BitmapWrapper(new Bitmap(getExternalImage(path)));
		} else if(bitmapData != null){
			image = new BitmapWrapper(new Bitmap(bitmapData));
		}
		this.layerName = layerName;
		attachImageToLayer(image, 1, layerName, Std.int(3), Std.int(4), 1);
		image.scaleX = image.scaleX * Engine.SCALE;
		image.scaleY = image.scaleY * Engine.SCALE;
	}
	
	public function changeImage(path : String){
		var oldX = getX();
		var oldY = getY();
		removeImage(image);
		image = new BitmapWrapper(new Bitmap(getExternalImage(path)));
		attachImageToLayer(image, 1, layerName, Std.int(3), Std.int(4), 1);
		image.scaleX = image.scaleX * Engine.SCALE;
		image.scaleY = image.scaleY * Engine.SCALE;
		setX(oldX);
		setY(oldY);
	}
	
	public inline function getX(){
		return image.x / Engine.SCALE;
	}
	
	public inline function getY(){
		return image.y / Engine.SCALE;
	}
	
	public inline function setX(x : Float){
		image.x = x * Engine.SCALE;
	}
	
	public inline function setY(y : Float){
		image.y = y * Engine.SCALE;
	}
	
	public inline function setXY(x : Float, y : Float){
		setX(x);
		setY(y);
	}
	
	public inline function getWidth(){
		return image.width / Engine.SCALE;
	}
	
	public inline function getHeight(){
		return image.height / Engine.SCALE;
	}
	
	public inline function kill(){
		removeImage(image);
	}
	
}

















