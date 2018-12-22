/*
    Use Scripts.get(actor, behaviorName) to get the behavior
    IMPORTANT: You must cast it!
    Ex: var b : MyBehavior = cast Scripts.get(actor, behaviorName);
*/

package scripts;

import com.stencyl.Engine;
import com.stencyl.models.Actor;

class Scripts
{
	public static function get(a : Actor, behaviorName : String){
		if(a != null){
			var b =  a.behaviors.cache.get(behaviorName);
			if(b != null){
				return b.script;
			} else {
				return null;
			}
		} else {
			return null;
		}
	}
}
