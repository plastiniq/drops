package drops.data {
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_Emboss {
		public var innerStrength:Number;
		public var dropStrength:Number;
		public var invert:Boolean;
		public var blurX:Number;
		public var blurY:Number;
		
		public static const PROPS:Array = ['innerStrength', 'dropStrength', 'invert', 'blurX', 'blurY'];
		
		public function C_Emboss(innerStrength:Number = 0.5, dropStrength:Number = 0.2, invert:Boolean = false, blurX:Number = 1, blurY:Number = 1) {
			this.innerStrength = innerStrength;
			this.dropStrength = dropStrength;
			this.invert = invert;
			this.blurX = blurX;
			this.blurY = blurY;
		}
		
		public function clone():C_Emboss {
			return new C_Emboss(innerStrength, dropStrength, invert, blurX, blurY);
		}
	}

}