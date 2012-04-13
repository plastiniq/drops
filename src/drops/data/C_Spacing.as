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
		
		public function get width():Number {
			return Number(left) + Number(right);
		}
		
		public function get height():Number {
			return Number(top) + Number(bottom);
		}
		
	}

}