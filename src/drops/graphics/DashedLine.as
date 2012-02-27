package drops.graphics {
	import flash.display.CapsStyle;
	import flash.display.Graphics;
	import flash.geom.Point;
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class DashedLine {
		public static var graphics:Graphics;
		public static var color:uint = 0;
		public static var alpha:Number = 1;
		public static var thickness:Number = 1;
		public static var dashLength:Number = 1;
		public static var spaceLength:Number = 1;
		public static var lining:Boolean;

		private static var fromX:Number = 0;
		private static var fromY:Number = 0;
		
		public static function moveTo(x:Number, y:Number):void {
			fromX = x;
			fromY = y;
		}
		
		public static function lineTo(x:Number, y:Number, graphics:Graphics):void {
			var fX:Number = fromX;
			var fY:Number = fromY;
			
			var tX:Number = x;
			var tY:Number = y;
			
			if (fromX == tX) {
				if (lining && Math.floor(fY) % 2) fY += 1;
				tX = fX = Math.floor(fX) + 0.5;
			}
			
			if (fromY == tY) {
				if (lining && (Math.floor(fY) % 2)) fY += 1;
				if (lining && !(Math.floor(fX) % 2)) fX += 1;
				tY = fY = Math.floor(fY) + 0.5;
			}
			
			fromX = x;
			fromY = y;
			
			var lineLength:Number = Math.sqrt(Math.pow(tX - fX, 2) + Math.pow(tY - fY, 2));
			
			var dashLen:Number = (dashLength / lineLength);
			var dashX:Number = (tX - fX) * dashLen;
			var dashY:Number = (tY - fY) * (dashLength / lineLength);
			
			var spaceLen:Number = (spaceLength / lineLength);
			var spaceX:Number = (tX - fX) * spaceLen;
			var spaceY:Number = (tY - fY) * spaceLen;
			
			var progress:Number = 0;
			var currX:Number = fX;
			var currY:Number = fY;
			graphics.lineStyle(thickness, color, alpha, false, 'normal', CapsStyle.NONE);
			
			while (progress < lineLength) {
				graphics.moveTo(currX, currY);
				currX += dashX;
				currY += dashY;
				graphics.lineTo(currX, currY);
				currX += spaceX;
				currY += spaceY;
				progress += spaceLength + dashLength;
			}
			
		}
		
		public static function beginDraw(color:uint = 0x000000, alpha:Number = 1, thickness:Number = 1, dashLength:Number = 1, spaceLength:Number = 1, lining:Boolean = false):void {
			DashedLine.color = color;
			DashedLine.alpha = alpha;
			DashedLine.thickness = thickness;
			DashedLine.dashLength = dashLength;
			DashedLine.spaceLength = spaceLength;
			DashedLine.fromX = 0;
			DashedLine.fromY = 0;
			DashedLine.lining = lining;
		}
	}
}