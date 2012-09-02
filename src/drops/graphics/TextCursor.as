package drops.graphics {
	import flash.display.CapsStyle;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class TextCursor extends Shape {
		private var _timer:Timer;
		private var _height:Number;
		private var _hidden:Boolean;
		
		public var specX:Number;
		public var specY:Number;
		
		public function TextCursor(height:Number = 20) {
			_height = height;
			_hidden = false;
			
			redraw(this.graphics, _height);
			
			_timer = new Timer(400, 0);
			_timer.start();
			_timer.addEventListener(TimerEvent.TIMER, timerHandler);
		}
		
		private function timerHandler(e:TimerEvent):void {
			this.visible = !visible;
		}
		
		override public function get height():Number {
			return _height;
		}
		
		override public function set height(value:Number):void {
			if (value != _height) {
				_height = value;
				redraw(this.graphics, value);
			}
		}
		
		public function show():void {
			if (_hidden) {
				_timer.start();
				this.visible = true;
				_hidden = false;
			}
		}
		
		public function hide():void {
			if (!_hidden) {
				_timer.stop();
				this.visible = false;
				_hidden = true;
			}
		}
		
		public static function redraw(graphics:Graphics, height:Number):void {
			graphics.clear();
			graphics.lineStyle(2, 0, 1, true, "normal", CapsStyle.NONE);
			graphics.moveTo( -1, 0);
			graphics.lineTo( -1, height);
		}
	}
}