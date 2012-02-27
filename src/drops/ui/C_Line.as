package drops.ui {
	import drops.core.C_Box;
	import drops.events.C_Event;
	import flash.display.CapsStyle;
	import flash.display.LineScaleMode;
	import flash.display.Shape;
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_Line extends C_Box {
		private var _line:Shape;
		
		private var _topColor:uint;
		private var _bottomColor:uint;
		private var _topAlpha:Number;
		private var _bottomAlpha:Number;
		
		public function C_Line(topColor:uint = 0x000000, bottomColor:uint = 0x000000, topAlpha:Number = 1, bottomAlpha:Number = 0) {
			height = 0;
			_line = new Shape();
			addChild(_line);
			addEventListener(C_Event.RESIZE, resizeHandler);
			update(topColor, bottomColor, topAlpha, bottomAlpha);
		}
		
		//--------------------------------------------------------------------------
		//	H A N D L E R S
		//--------------------------------------------------------------------------
		private function resizeHandler(e:C_Event):void {
			align();
		}
		
		//--------------------------------------------------------------------------
		//	S E T  /  G E T
		//--------------------------------------------------------------------------
		
		//--------------------------------------------------------------------------
		//	P U B L I C
		//--------------------------------------------------------------------------
		public function update(topColor:uint, bottomColor:uint, topAlpha:Number, bottomAlpha:Number):void {
			_topColor = topColor;
			_bottomColor = bottomColor;
			_topAlpha = topAlpha;
			_bottomAlpha = bottomAlpha;

			align();
		}
		
		//--------------------------------------------------------------------------
		//	P R I V A T E
		//--------------------------------------------------------------------------
		private function draw():void {
			_line.graphics.clear();
			
			if (_topAlpha > 0) {
				_line.graphics.lineStyle(1, _topColor, _topAlpha, false, 'normal', CapsStyle.NONE);
				_line.graphics.moveTo(0, 0.5);
				_line.graphics.lineTo(width, 0.5);
				_line.graphics.endFill();
			}
			
			if (_bottomAlpha > 0) {
				_line.graphics.lineStyle(1, _bottomColor, _bottomAlpha, false, LineScaleMode.NONE, CapsStyle.NONE);
				_line.graphics.moveTo(0, 1.5);
				_line.graphics.lineTo(width, 1.5);
				_line.graphics.endFill();
			}
		}
		
		private function align():void {
			draw();
			_line.y = Math.round((height - _line.height) * 0.5);
		}
	}

}