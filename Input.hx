// BACKUP


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

import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.TouchEvent;

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
		var t = new TextInput(font, ?actor, x, y, w, h);
		Should work!
	However...
	You can style it with CSS!
		var t = TextInput.create(font, "x: 200; height: ...")
	
	List of properties:
	  x
	  y
	  width
	  height
	  border: none
	  border-color	(#FFFFAA)
	  border-width
	  cursor-color
	  cursor-width
	  background-color: none (or color)
	  max-length
	  padding
	
*/

class TextInput extends SceneScript
{
	var text : String = "";
	var font : Font = null;
	var x : Float;
	var y : Float;
	var width : Float = 200;
	var height: Float = 50;
	var actorAttachedTo : Actor = null;
	var maxLength : Int = 10;
	var isFocused : Bool = false;
	var isDrawingCursor : Bool = false;
	var padding : Int = 8;
	
	var cursorWidth : Int = 3;
	var cursorColor : Int = Utils.getColorRGB(0,0,0);
	
	var hasBorder	: Bool = false;
	var borderWidth : Int = 3;
	var borderColor	: Int = Utils.getColorRGB(0,0,0);
	
	var backgroundColor : Int = Utils.getColorRGB(240,240,240);
	var isTransparent : Bool = true;
	
	public static function create(f : Font, ?a : Actor, s : String){
		var style = Texts.splitString(s, " ,=:;\n");
		var property : String = "";
		var value : String = "";
		
		var ret = new TextInput(f);
		
		for(i in 0...style.length){
			if(i%2 == 0){
				property = style[i];
				continue;
			} else {
				value = style[i];
				trace(property + ":" + value + ";");
				//trace("At " + value + ": last char is " + value.charAt(value.length - 1));
				switch(property){
					case "x": ret.x = Std.parseFloat(value);
					case "y": ret.y = Std.parseFloat(value);
					case "width": ret.width = Std.parseFloat(value);
					case "height": ret.height = Std.parseFloat(value);
					case "border": if(value == "none") ret.hasBorder = false;
					case "border-width": ret.borderWidth = Std.parseInt(value); ret.hasBorder = true;
					case "background-color":
						if(value == "none" || value == "transparent"){
							ret.isTransparent = true;
						} else {
							if(value.length > 0){
								if(value.charAt(0) == "#"){
									ret.backgroundColor = Std.parseInt("0X" + value.substring(1, value.length));
								}
							}
						}
					case "border-color":
						if(value == "none" || value == "transparent"){
							ret.hasBorder = false;
						} else {
							if(value.length > 0){
								if(value.charAt(0) == "#"){
									ret.borderColor = Std.parseInt("0X" + value.substring(1, value.length));
								}
							}
						}
					case "cursor-color":
						if(value.length > 0){
							if(value.charAt(0) == "#"){
								ret.cursorColor = Std.parseInt("0X" + value.substring(1, value.length));
							}
						}
					case "cursorWidth": ret.cursorWidth = Std.parseInt(value);
					case "padding": ret.padding = Std.parseInt(value);
					case "max-length": ret.maxLength = Std.parseInt(value);
					case "text": ret.text = value;
					case "default-text": ret.text = value;
					
				}
				
				// Style below:
			}
		}
		return ret;
	}
	

	public function new(f : Font, ?a : Actor, ?_x : Float, ?_y : Float, ?w : Float, ?h : Float){
		super();
		font = f;
		if(a == null){
			x = _x;
			y = _y;
			width = w;
			height = h;
		} else {
			x = a.getX();
			y = a.getY();
			width = a.getWidth();
			height = a.getHeight();
			actorAttachedTo = a;
		}
		addWhenDrawingListener(null, function(g:G, x:Float, y:Float, list:Array<Dynamic>):Void{
			draw(g);
		});
		addAnyKeyPressedListener(function(event:KeyboardEvent, list:Array<Dynamic>):Void{
			if(isFocused){
				var key : String = charFromCharCode(event.charCode);
				switch(event.charCode){
					case 8: // Backspace
						if(text.length > 0){
							text = text.substring(0, text.length - 1);
						}
					case 13: // Enter
						isFocused = false;
				}
				if(text.length < maxLength){
					text += key;
				}
			}
		});
		addMousePressedListener(function(list:Array<Dynamic>):Void{
			if(isMouseOverIt()){
				isFocused = !isFocused;
				if(isFocused){
					isDrawingCursor = true;
				}
			} else if(isFocused){
				isFocused = false;
			}
		});
		runPeriodically(600, function(timeTask:TimedTask):Void{
			isDrawingCursor = !isDrawingCursor;
		}, null);
		
	}
	
	private function isMouseOverIt(){
		var mx = getMouseX();
		var my = getMouseY();
		if(mx > x && mx < x + width && my > y && my < y + height){
			return true;
		} else return false;
	}
	
	private function draw(g : G){
		if(actorAttachedTo != null){
			x = actorAttachedTo.getX();
			y = actorAttachedTo.getY();
		}
		if(hasBorder){
			g.strokeColor = borderColor;
			g.strokeSize = borderWidth;
			g.drawRect(x, y, width, height);
		}
		if(!isTransparent){
			g.fillColor = backgroundColor;
			g.fillRect(x, y, width, height);
		}
		g.setFont(font);
		g.drawString(text, x + padding, y + padding);	
		if(isFocused && isDrawingCursor){
			drawCursor(g);
		}
	}
	
	private function drawCursor(g : G){
			g.strokeColor = cursorColor;
			g.strokeSize = cursorWidth;
			var textWidth = font.font.getTextWidth(text)/Engine.SCALE + 2;
			var textHeight = font.getHeight()/Engine.SCALE;
			g.drawLine(x + padding + textWidth, y + padding, x+padding+textWidth, y + padding + textHeight);
	}
}
