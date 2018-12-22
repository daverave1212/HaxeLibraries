package scripts;

class Texts
{

	public static function stringContains(s : String, letter : String){
		for(i in 0...s.length){
			if(s.charAt(i) == letter){
				return s.charAt(i);
			}
		}
		return "";
	}
	
	public static function splitString(s : String, delimiters : String){
		var start = 0;
		var end = 0;
		var returnedArray : Array<String> = new Array<String>();
		var lastLetterWasDelimiter = false;
		for(i in 0...s.length){
			var letter = s.charAt(i);
			if(stringContains(delimiters, letter) != ""){
				if(lastLetterWasDelimiter){
					start = i + 1;
				} else {
					returnedArray.push(s.substring(start, end));
					start = i + 1;
					end = start;
				}
                lastLetterWasDelimiter = true;
			} else {
                lastLetterWasDelimiter = false;
				end = i + 1;
			}
		}
		if(!lastLetterWasDelimiter){
            returnedArray.push(s.substring(start));
        }
		return returnedArray;
	}
}
