package drops.data {
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_Margin {
		public var left:Number;
		public var right:Number;
		public var top:Number;
		public var bottom:Number;
		
		public function C_Margin(left:Number = 0, right:Number = 0, top:Number = 0, bottom:Number = 0) {
			this.left = left;
			this.right = right;
			this.top = top;
			this.bottom = bottom;
		}
		
		public function get width():Number {
			return left + right;
		}
		
		public function get height():Number {
			return top + bottom;
		}
		
	}

}