package scripts;

class Node<T>{
	public var data : T;
	public var next : Node<T> = null;
	
	public function new(d : T){
		data = d;
	}
	
}

class Queue<T>
{
	public var first : Node<T> = null;		// Left most, earliest, these are removed first
	public var last : Node<T> = null;
	public var length : Int = 0;
	
	public function new(){
	
	}
	
	public function push(t : T){
		if(length == 0){
			first = new Node<T>(t);
			last = first;
		} else {
			var node = new Node<T>(t);
			last.next = node;
			last = node;
		}
		length++;
	}
	
	public function pop(){
		if(length == 0){
			// Do nothing
		} else if(length == 1){
			first = null;
			last = null;
			length--;
		} else{
			first = first.next;
			length--;
		}
	}
	
	public function peek(){
		if(length == 0) return null;
		return first.data;
	}
	
	
}
