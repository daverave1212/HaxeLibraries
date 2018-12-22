
package scripts;

class Matrix<T>
{
	public var matrix : Array<Array<T>>;
	public var nRows : Int = 0;
	public var nCols : Int = 0;
	
	public function new(_nRows : Int, _nCols : Int){
		nRows = _nRows;
		nCols = _nCols;
		matrix = [for (x in 0...nRows) [for (y in 0...nCols) null]];
	}
	
	public function get(i : Int, j : Int){
		return matrix[i][j];
	}
	
	public function set(i : Int, j : Int, t : T){
		matrix[i][j] = t;
	}
	
	
}
