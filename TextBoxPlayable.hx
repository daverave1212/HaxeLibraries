//package scripts;

/*
import com.stencyl.behavior.Script;
import com.stencyl.behavior.Script.*;
import com.stencyl.Engine;
import com.stencyl.models.Font;
import com.stencyl.graphics.G;
import com.stencyl.behavior.SceneScript;
import com.stencyl.behavior.TimedTask;
import com.stencyl.utils.Utils;
		Extra API
	.play()				starts playing the text from the beginning
	.stop()				stops playing the text
	.resume()			continues to play the text
	.interval			0.05 by default
	.isTextPlaying()	returns true if it's playing, false if it's not
	NOTE: Requires TextBox.hx
*/

class TextBoxPlayable extends TextBox{

	
	public var interval		: Float = 0.05;
	
	private var currentLine	 	: Int = 0;
	private var currentLetter	: Int = 0;
	private var isPlaying		: Bool = false;
	private var playingText		: Array<String>;

	public function play(){
		currentLine = 0;
		currentLetter = 0;
		isPlaying = true;
	}
	
	public function stop(){
		isPlaying = false;
	}
	
	public function resume(){
		isPlaying = true;
	}
	
	public function isTextPlaying(){
		return isPlaying;
	}
	
	public function new(width : Int, height : Int, _x : Float, _y : Float, f : Font){
		super(width, height, _x, _y, f);
		playingText = new Array<String>();
		playingText[0] = "";
		runPeriodically(1000 * interval, function(timeTask:TimedTask):Void{
			if(isPlaying){
				if(currentLetter < lines[currentLine].length){
					playingText[currentLine] += lines[currentLine].charAt(currentLetter);
					currentLetter++;}
				else{
					currentLetter = 0;
					if(currentLine < lines.length - 1){
						currentLine++;
						playingText[currentLine] = "";}
					else{
						isPlaying = false;
					}
				}
			}
		},null);
	}
	
	public override function reset(){
		isPlaying = false;
		isDrawing = false;
		playingText = new Array<String>();
		playingText[0] = "";
		lines = new Array<Dynamic>();
		text = "";
		nLines = 0;}

	private override function draw(g : G){
		if(isDrawing){
			g.setFont(font);
			for(currentLine in 0...currentLine + 1){
				g.drawString(playingText[currentLine], x, y + lineSpacing * currentLine);}}}

}
