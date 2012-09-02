package drops.data {
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_Mounts {
		public var left:Object;
		public var right:Object;
		public var top:Object;
		public var bottom:Object;
		
		public var leftOffset:Object;
		public var rightOffset:Object;
		public var topOffset:Object;
		public var bottomOffset:Object;
		
		public static const PROPS:Array = ['left', 'right', 'top', 'bottom', 'leftOffset', 'rightOffset', 'topOffset', 'bottomOffset'];
		
		public function C_Mounts(left:Object = null, right:Object = null, top:Object = null, bottom:Object = null, leftOffset:Object = null, rightOffset:Object = null, topOffset:Object = null, bottomOffset:Object = null) {
			setMounts(left, right, top, bottom, leftOffset, rightOffset, topOffset, bottomOffset);
		}
		
		public function setMounts(left:Object = null, right:Object = null, top:Object = null, bottom:Object = null, leftOffset:Object = null, rightOffset:Object = null, topOffset:Object = null, bottomOffset:Object = null):void {
			this.left = left;
			this.right = right;
			this.top = top;
			this.bottom = bottom;
			this.leftOffset = leftOffset;
			this.rightOffset = rightOffset;
			this.topOffset = topOffset;
			this.bottomOffset = bottomOffset;
		}
		
		public function get isEmpty():Boolean {
			return (left === null && right === null && top === null && bottom === null);
		}
		
		public function get blockedX():Boolean {
			return ((left !== null || right !== null));
		}
		
		public function get blockedY():Boolean {
			return ((top !== null || bottom !== null));
		}
	}

}