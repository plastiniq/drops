package drops.ui {
	import drops.utils.C_Text;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.text.TextField;
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_SliceContent extends  Sprite {
		private var _titleF:TextField;
		private var _icon:Sprite;
		private var _iconBtm:Bitmap;
		
		private var _inner:Number;
		private var _outer:Number;
		private var _angle:Number;
		private var _padding:Number;
		
		private const PI180:Number = Math.PI / 180;
		
		public function C_SliceContent(title:String, inner:Number, outer:Number, padding:Number) {
			_inner = inner;
			_outer = outer;
			_padding = padding;
			
			_angle = 0;
			
			_titleF = C_Text.defineTF(null, title);
			addChild(_titleF);
			
			_icon = new Sprite();
			addChild(_icon);
			
			refresh();
		}
		
		//------------------------------------------------
		//	S E T  /  G E T
		//------------------------------------------------
		public function get titleField():TextField {
			return _titleF;
		}
		
		public function set icon(bitmapdata:BitmapData):void {
			if (!_iconBtm) _iconBtm = _icon.addChild(new Bitmap()) as Bitmap;
			_iconBtm.bitmapData = bitmapdata;
			refresh();
		}
		
		
		public function set angle(value:Number):void {
			if (value != _angle) {
				_angle = value;
				refresh();
			}
		}
		
		//--------------------------------------
		//  P U B L I C
		//--------------------------------------
		public function refresh():void {
			_titleF.x = _inner + _padding;
			_titleF.width = _outer - _inner - _padding * 2 - _icon.width;
			_titleF.y = 0;
			setAngle(_titleF, _angle);
			
			_icon.y = 0;
			_icon.x = _outer - _icon.width - _padding;
			setAngle(_icon, _angle, false);
		}
		
		//--------------------------------------
		//  P R I V A T E
		//--------------------------------------
		private static function setAngle(obj:DisplayObject, angle:Number, rotate:Boolean = true, x:Number = 0, y:Number = 0):void {
			obj.rotation = 0;
			
			const PI180:Number = Math.PI / 180;
			angle -= 90;
			if (angle > 90) {
				obj.x = -(obj.x + obj.width);
				angle = -180 + angle;
			}
			
			var sin:Number = Math.sin(angle * PI180);
			var cos:Number = Math.cos(angle * PI180);
			var newX:Number, newY:Number;

			if (rotate) {
				newX = ((obj.x - x) * cos - ((obj.y - obj.height * 0.5) - y) * sin) + x;
				newY = ((obj.x - x) * sin + ((obj.y - obj.height * 0.5) - y) * cos) + y;
				obj.rotation = angle;
				obj.x = newX;
				obj.y = newY;
			}
			else {
				newX = ((obj.x - x + obj.width * 0.5) * cos) + x;
				newY = ((obj.x - x + obj.height * 0.5) * sin) + y;
				obj.x = newX - obj.width * 0.5;
				obj.y = newY - obj.height * 0.5;
			}
		}
	}

}