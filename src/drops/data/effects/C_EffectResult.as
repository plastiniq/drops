package drops.data.effects {
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_EffectResult {
		public var bmd:BitmapData;
		public var rect:Rectangle;
		public var inner:Boolean;
		
		public function C_EffectResult(bmd:BitmapData, rect:Rectangle, inner:Boolean) {
			this.bmd = bmd;
			this.rect = rect;
			this.inner = inner;
		}
		
	}

}