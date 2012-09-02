package drops.data {
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_Spacing {
		public var left:Object;
		public var right:Object;
		public var top:Object;
		public var bottom:Object;
		
		public function C_Spacing(left:Object = null, right:Object = null, top:Object = null, bottom:Object = null) {
			this.left = left;
			this.right = right;
			this.top = top;
			this.bottom = bottom;
		}
		
		public function equal(target:C_Spacing):Boolean {
			if (target == null) return false;
			return (left == target.left && right == target.right && top == target.top && bottom == target.bottom);
		}
		
		public function get width():Number {
			return numLeft + numRight;
		}
		
		public function get height():Number {
			return numTop + numBottom;
		}
		
		public function get numLeft():Number {
			return (left is Number) ? left as Number : 0;
		}
		
		public function get numRight():Number {
			return (right is Number) ? right as Number : 0;
		}
		
		public function get numTop():Number {
			return (top is Number) ? top as Number : 0;
		}
		
		public function get numBottom():Number {
			return (bottom is Number) ? bottom as Number : 0;
		}
	}

}