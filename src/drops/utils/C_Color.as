package drops.utils {
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_Color {
		private var _r:int;
		private var _g:int;
		private var _b:int;
		
		private var _h:Number;
		private var _s:Number;
		private var _l:Number;
		
		private var _hex:uint;
		
		public function C_Color(hexColor:uint = 0x000000) {
			hex = hexColor;
		}
		
		//------------------------------------------------
		//	S E T  /  G E T
		//------------------------------------------------
		public function get r():int { return _r }
		public function set r(value:int):void {
			_r = Math.max(0, Math.min(value, 255));
			RGB_2_HSL(_r, _g, _b);
			RGB_2_HEX(_r, _g, _b);
		}
		
		public function get g():int { return _g }
		public function set g(value:int):void {
			_g = Math.max(0, Math.min(value, 255));
			RGB_2_HSL(_r, _g, _b);
			RGB_2_HEX(_r, _g, _b);
		}
		
		public function get b():int { return _b }
		public function set b(value:int):void {
			_b = Math.max(0, Math.min(value, 255));
			RGB_2_HSL(_r, _g, _b);
			RGB_2_HEX(_r, _g, _b);
		}
		
		
		public function get h():Number { return _h }
		public function set h(value:Number):void {
			_h = Math.max(0, Math.min(value, 359));
			HSL_2_RGB(_h, _s, _l);
			RGB_2_HEX(_r, _g, _b);
		}
		
		public function get s():Number { return _s }
		public function set s(value:Number):void {
			_s = Math.max(0, Math.min(value, 100));
			HSL_2_RGB(_h, _s, _l);
			RGB_2_HEX(_r, _g, _b);
		}
		
		public function get l():Number { return _l }
		public function set l(value:Number):void {
			_l = Math.max(0, Math.min(value, 100));
			HSL_2_RGB(_h, _s, _l);
			RGB_2_HEX(_r, _g, _b);
		}
		
		public function get hex():uint { return _hex }
		public function set hex(value:uint):void {
			_hex = value;
			HEX_2_RGB(_hex);
			RGB_2_HSL(_r, _g, _b)
		}
		//-------------------------------------------------
		//	P R I V A T E
		//-------------------------------------------------
		private function RGB_2_HEX(r:int, g:int, b:int):void {
			_hex = (r << 16 | g << 8 | b);
		}
		
		private function HEX_2_RGB(value:uint):void {
			_r = (0xFF0000 & value) >> 16;
			_g = (0x00FF00 & value) >> 8;
			_b = (0x0000FF & value);
		}
		
		private function RGB_2_HSL(r:int, g:int, b:int):void {
			var max:uint = Math.max(r, g, b);
			var min:uint = Math.min(r, g, b);

			var hue:Number = 0;
			var saturation:Number = 0;
			var value:Number = 0;

			var hsv:Array = [];

			if (max == min) 	{ hue = 0; }
			else if (max == r) 	{ hue = (60 * (g - b) / (max - min) + 360) % 360; }
			else if (max == g) 	{ hue = (60 * (b - r) / (max - min) + 120); }
			else if (max == b) 	{ hue = (60 * (r-g) / (max-min) + 240);}

			value = max;

			if (max == 0) { saturation = 0; }
			else { saturation = (max - min) / max; }
			
			_h = Math.round(hue)
			_s = Math.round(saturation * 100)
			_l = Math.round(value / 255 * 100)
		}
		
		private function HSL_2_RGB(h:Number, s:Number, v:Number):Boolean {
			s /= 100;
			v /= 100;
			
			var r:Number, g:Number, b:Number;
			var i:int;
			var f:Number, p:Number, q:Number, t:Number;
			 
			if (s == 0){
				r = g = b = v;
				_r = Math.round(r * 255);
				_g = Math.round(g * 255);
				_b = Math.round(b * 255);
				return false;
			}
			
			h /= 60;
			i  = Math.floor(h);
			f = h - i;
			p = v *  (1 - s);
			q = v * (1 - s * f);
			t = v * (1 - s * (1 - f));
			
			switch( i ) {
				case 0:
					r = v;
					g = t;
					b = p;
					break;
				case 1:
					r = q;
					g = v;
					b = p;
					break;
				case 2:
					r = p;
					g = v;
					b = t;
					break;
				case 3:
					r = p;
					g = q;
					b = v;
					break;
				case 4:
					r = t;
					g = p;
					b = v;
					break;
				default:        // case 5:
					r = v;
					g = p;
					b = q;
					break;
			}
			_r = Math.round(r * 255);
			_g = Math.round(g * 255);
			_b = Math.round(b * 255);
			
			return true;
		}
		
	}
}