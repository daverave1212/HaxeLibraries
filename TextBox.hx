//package scripts;

/*
import com.stencyl.Engine;
import com.stencyl.models.Font;
import com.stencyl.graphics.G;
import com.stencyl.behavior.SceneScript;
*/

/*
 * TextBox:
 * the constructor takes width, height, xposition and yposition
 * Use .setText(String) to set it's text
 * Then simply call startDrawing()
 * Use stopDrawing() to stop drawing
 *
 * NOTE: Don't forget to uncomment the package at the top of the code!
 */
 
 /* API:
 
	new(width, height, x, y)
	.startDrawing()
	.stopDrawing()
	
 	.setText(String)
	.getText()	//returns a String
	.setPosition(x : Float, y : Float)
	.setSize(width : Int, height : Int)
	.reset()
	.x
	.y
	.w
	.h
	.nLines
	.lineSpacing	//default is 20
	.font
 
 */

class TextBox extends SceneScript{
	
	var lines 		:Array<Dynamic>;
	var w			:Int = 400;
	var h			:Int = 400;
	var x			:Float = 50;
	var y			:Float = 50;
	var nLines		:Int = 0;
	var lineSpacing	:Float = 20;
	var font		:Font;
	var isDrawing	:Bool = false;
	
	private var text		:String;
	
	public function new(width : Int, height : Int, _x : Float, _y : Float, f : Font){
		super();
		font = f;
		create(width, height, _x, _y, "");
		addWhenDrawingListener(null, function(g:G, x:Float, y:Float, list:Array<Dynamic>):Void{
			draw(g);
			});}
	
	public function reset(){
		isDrawing = false;
		lines = new Array<Dynamic>();
		text = "";
		nLines = 0;}

	public function create(width : Int, height : Int, X : Float, Y: Float, t : String){
		lines = new Array<Dynamic>();
		x = X;
		y = Y;
		h = height;
		w = width;
		setText(t);}

	public function setSize(width : Int, height : Int){
		w = width;
		h = height;}
	
	public function setPosition(_x : Float, _y : Float){
		x = _x;
		y = _y;}

	public function setText(t : String){
		reset();
		text = t;
		var wordList	: Array<Dynamic> = text.split(" ");
		var currentLine	: Int = 0;
		var currentWord : Int = 0;
		nLines = 0;
		while(currentWord < wordList.length -1){ //while currentLine width < w
			nLines++;
			lines[currentLine] = "";
			while(font.font.getTextWidth(lines[currentLine] + " " + wordList[currentWord]) / Engine.SCALE < w && wordList[currentWord] != "\n" && currentWord < wordList.length){
				lines[currentLine] += " " + wordList[currentWord];
				currentWord++;}
			currentLine++;
			if(wordList[currentWord] == "\n"){
				currentWord++;}}}
				
	public function getText(){
		return text;}
		
	private function draw(g : G){
		if(isDrawing){
			g.setFont(font);
			for(currentLine in 0...nLines){
				g.drawString(lines[currentLine], x, y + lineSpacing * currentLine);}}}
	
	public function startDrawing(){
		isDrawing = true;}
		
	public function stopDrawing(){
		isDrawing = false;}

}
