package drops.graphics {
	import flash.display.BitmapData;
	import flash.display.Shape;
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class Pattern {
		private static const _shape:Shape = new Shape();
		
		public function Pattern() {
			
		}
		
		public static function getBitmapData(pattern:BitmapData, w:Number, h:Number):BitmapData {
			if (!pattern) return null;
			_shape.graphics.clear();
			_shape.graphics.beginBitmapFill(pattern, null, true, false);
			_shape.graphics.drawRect(0, 0, w, h);
			var bmd:BitmapData = new BitmapData(w, h, true, 0x000000);
			bmd.draw(_shape, null, null);
			return bmd;
		}
	}
}