package drops.data {
	import flash.geom.Rectangle;
	import flash.text.engine.TextLine;
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_LinePoint {
		private var _lineIndex:int;
		private var _atomIndex:int;
		private var _lines:Array;
		private var _atomBounds:Rectangle;
		
		public function C_LinePoint(lines:Array):void {
			_lines = lines;
		}
		
		//-------------------------------------------------------------------
		//	S E T  /  G E T
		//-------------------------------------------------------------------
		public static function equals(point1:C_LinePoint, point2:C_LinePoint):Boolean {
			return (point1.lineIndex === point2.lineIndex && point1.atomIndex === point2.atomIndex);
		}
		
		public function setPoint(lineIndex:int, atomIndex:int, lines:Array):void {
			_lineIndex = lineIndex;
			_atomIndex = atomIndex;
			_lines = lines;
			refreshBounds();
		}
		
		public function get lines():Array {
			return _lines;
		}
		
		public function set lines(value:Array):void {
			_lines = value;
			refreshBounds();
		}
		
		public function get atomIndex():int {
			return _atomIndex;
		}
		
		public function set atomIndex(value:int):void {
			_atomIndex = value;
			refreshBounds();
		}
		
		public function get lineIndex():int {
			return _lineIndex;
		}
		
		public function set lineIndex(value:int):void {
			_lineIndex = value;
		}

		public function get atomBounds():Rectangle {
			return _atomBounds;
		}
		
		public function get line():TextLine {
			return (_lines && _lines[_lineIndex]) ? _lines[_lineIndex] : null;
		}
		
		private function refreshBounds():void {
			if (_lines && _lines[_lineIndex]) {
				_atomBounds = line.getAtomBounds(atomIndex);
				_atomBounds.y = int(line.y - line.ascent);
				_atomBounds.x = int(_atomBounds.x);
				_atomBounds.width = int(_atomBounds.width);
				_atomBounds.height = int(_atomBounds.height);
			}
		}
	}

}