package drops.utils {
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_Easing {
	
		public static function easeInQuad(x:Number, t:Number, b:Number, c:Number, d:Number):Number {
			return c * (t /= d) * t + b;
		}
		
		public static function easeOutQuad(x:Number, t:Number, b:Number, c:Number, d:Number):Number {
			return -c * (t /= d) * (t - 2) + b;
		}
		
		public static function easeInOutQuad(x:Number, t:Number, b:Number, c:Number, d:Number):Number {
			if ((t /= d / 2) < 1) return c / 2 * t * t + b;
			return -c / 2 * ((--t) * (t - 2) - 1) + b;
		}
		
		public static function easeInCubic(x:Number, t:Number, b:Number, c:Number, d:Number):Number {
			return c * (t /= d) * t * t + b;
		}
		
		public static function easeOutCubic(x:Number, t:Number, b:Number, c:Number, d:Number):Number {
			return c * ((t = t / d - 1) * t * t + 1) + b;
		}
		
		public static function easeInOutCubic(x:Number, t:Number, b:Number, c:Number, d:Number):Number {
			if ((t /= d / 2) < 1) return c / 2 * t * t * t + b;
			return c / 2 * ((t -= 2) * t * t + 2) + b;
		}
		
		public static function easeInQuart(x:Number, t:Number, b:Number, c:Number, d:Number):Number {
			return c * (t /= d) * t * t * t + b;
		}
		
		public static function easeOutQuart(x:Number, t:Number, b:Number, c:Number, d:Number):Number {
			return -c * ((t = t / d - 1) * t * t * t - 1) + b;
		}
		
		public static function easeInOutQuart(x:Number, t:Number, b:Number, c:Number, d:Number):Number {
			if ((t /= d / 2) < 1) return c / 2 * t * t * t * t + b;
			return -c / 2 * ((t -= 2) * t * t * t - 2) + b;
		}
		
		public static function easeInQuint(x:Number, t:Number, b:Number, c:Number, d:Number):Number {
			return c * (t /= d) * t * t * t * t + b;
		}
		
		public static function easeOutQuint(x:Number, t:Number, b:Number, c:Number, d:Number):Number {
			return c * ((t = t / d - 1) * t * t * t * t + 1) + b;
		}
		
		public static function easeInOutQuint(x:Number, t:Number, b:Number, c:Number, d:Number):Number {
			if ((t /= d / 2) < 1) return c / 2 * t * t * t * t * t + b;
			return c / 2 * ((t -= 2) * t * t * t * t + 2) + b;
		}
		
		public static function easeInSine(x:Number, t:Number, b:Number, c:Number, d:Number):Number {
			return -c * Math.cos(t / d * (Math.PI / 2)) + c + b;
		}
		
		public static function easeOutSine(x:Number, t:Number, b:Number, c:Number, d:Number):Number {
			return c * Math.sin(t / d * (Math.PI / 2)) + b;
		}
		
		public static function easeInOutSine(x:Number, t:Number, b:Number, c:Number, d:Number):Number {
			return -c / 2 * (Math.cos(Math.PI * t / d) - 1) + b;
		}
		
		public static function easeInExpo(x:Number, t:Number, b:Number, c:Number, d:Number):Number {
			return (t == 0) ? b : c * Math.pow(2, 10 * (t / d - 1)) + b;
		}
		
		public static function easeOutExpo(x:Number, t:Number, b:Number, c:Number, d:Number):Number {
			return (t == d) ? b + c : c * ( -Math.pow(2, -10 * t / d) + 1) + b;
		}
		
		public static function easeInOutExpo(x:Number, t:Number, b:Number, c:Number, d:Number):Number {
			if (t == 0) return b;
			if (t == d) return b + c;
			if ((t /= d / 2) < 1) return c / 2 * Math.pow(2, 10 * (t - 1)) + b;
			return c / 2 * ( -Math.pow(2, -10 * --t) + 2) + b;
		}
		
		public static function easeInCirc(x:Number, t:Number, b:Number, c:Number, d:Number):Number {
			return -c * (Math.sqrt(1 - (t /= d) * t) - 1) + b;
		}
		
		public static function easeOutCirc(x:Number, t:Number, b:Number, c:Number, d:Number):Number {
			return c * Math.sqrt(1 - (t = t / d - 1) * t) + b;
		}
		
		public static function easeInOutCirc(x:Number, t:Number, b:Number, c:Number, d:Number):Number {
			if ((t /= d / 2) < 1) return -c / 2 * (Math.sqrt(1 - t * t) - 1) + b;
			return c / 2 * (Math.sqrt(1 - (t -= 2) * t) + 1) + b;
		}
		
		public static function easeInElastic(x:Number, t:Number, b:Number, c:Number, d:Number):Number {
			var s:Number = 1.70158; var p:Number = 0; var a:Number = c;
			if (t == 0) return b;  if ((t /= d) == 1) return b + c;  if (!p) p = d * .3;
			if (a < Math.abs(c)) { a = c; s = p / 4 }
			else s = p / (2 * Math.PI) * Math.asin (c / a);
			return -(a * Math.pow(2, 10 * (t -= 1)) * Math.sin( (t * d - s) * (2 * Math.PI) / p )) + b;
		}
		
		public static function easeOutElastic(x:Number, t:Number, b:Number, c:Number, d:Number):Number {
			var s:Number = 1.70158; var p:Number = 0; var a:Number = c;
			if (t == 0) return b;  if ((t /= d) == 1) return b + c;  if (!p) p = d * .3;
			if (a < Math.abs(c)) { a = c; s = p / 4 }
			else s = p / (2 * Math.PI) * Math.asin (c / a);
			return a * Math.pow(2, -10 * t) * Math.sin( (t * d - s) * (2 * Math.PI) / p ) + c + b;
		}
		
		public static function easeInOutElastic(x:Number, t:Number, b:Number, c:Number, d:Number):Number {
			var s:Number = 1.70158; var p:Number = 0; var a:Number = c;
			if (t == 0) return b;  if ((t /= d / 2) == 2) return b + c;  if (!p) p = d * (.3 * 1.5);
			if (a < Math.abs(c)) { a = c; s = p / 4 }
			else s = p / (2 * Math.PI) * Math.asin (c / a);
			if (t < 1) return -.5 * (a * Math.pow(2, 10 * (t -= 1)) * Math.sin( (t * d - s) * (2 * Math.PI) / p )) + b;
			return a * Math.pow(2, -10 * (t -= 1)) * Math.sin( (t * d - s) * (2 * Math.PI) / p ) * .5 + c + b;
		}
		
		public static function easeInBack(x:Number, t:Number, b:Number, c:Number, d:Number, s:Number):Number {
			if (isNaN(s)) s = 1.70158;
			return c * (t /= d) * t * ((s + 1) * t - s) + b;
		}
		
		public static function easeOutBack(x:Number, t:Number, b:Number, c:Number, d:Number, s:Number):Number {
			if (isNaN(s)) s = 1.70158;
			return c * ((t = t / d - 1) * t * ((s + 1) * t + s) + 1) + b;
		}
		
		public static function easeInOutBack(x:Number, t:Number, b:Number, c:Number, d:Number, s:Number):Number {
			if (isNaN(s)) s = 1.70158;
			if ((t /= d / 2) < 1) return c / 2 * (t * t * (((s *= (1.525)) + 1) * t - s)) + b;
			return c / 2 * ((t -= 2) * t * (((s *= (1.525)) + 1) * t + s) + 2) + b;
		}
		
		public static function easeInBounce(x:Number, t:Number, b:Number, c:Number, d:Number):Number {
			return c - C_Easing.easeOutBounce(x, d - t, 0, c, d) + b;
		}
		
		public static function easeOutBounce(x:Number, t:Number, b:Number, c:Number, d:Number):Number {
			if ((t /= d) < (1 / 2.75)) {
				return c * (7.5625 * t * t) + b;
			} else if (t < (2 / 2.75)) {
				return c * (7.5625 * (t -= (1.5 / 2.75)) * t + .75) + b;
			} else if (t < (2.5 / 2.75)) {
				return c * (7.5625 * (t -= (2.25 / 2.75)) * t + .9375) + b;
			} else {
				return c * (7.5625 * (t -= (2.625 / 2.75)) * t + .984375) + b;
			}
		}
		
		public static function easeInOutBounce(x:Number, t:Number, b:Number, c:Number, d:Number):Number {
			if (t < d / 2) return C_Easing.easeInBounce (x, t * 2, 0, c, d) * .5 + b;
			return C_Easing.easeOutBounce (x, t * 2 - d, 0, c, d) * .5 + c * .5 + b;
		}
	
	}

}