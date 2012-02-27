package drops.data.effects {
	import drops.data.effects.samples.C_EffectSample;
	import flash.filters.BitmapFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_EffectConverter {
		
		
		public static function convertToNative(source:C_EffectSample, hideObj:Boolean):BitmapFilter {
			var sClass:Class = Object(source).constructor;
			var s:Object = source;
			
			if (sClass == C_EffectType.SHADOW || sClass == C_EffectType.INNER_SHADOW || sClass == C_EffectType.DROP_SHADOW) {
				return new DropShadowFilter(s.distance, -s.angle + 180, s.color, s.alpha, s.size, s.size, s.strength, 2, s.inner, true, hideObj);
			}
			else if (sClass == C_EffectType.GLOW) {
				return new DropShadowFilter(0, 0, s.color, s.alpha, s.size, s.size, s.strength, 2, s.inner, true, hideObj);
			}
			else if (sClass == C_EffectType.STROKE) {
				var strokeBlur:Number = s.size * 2;
				var strokeStrength:Number = Math.min(80, (s.size * 10) - 5.8);
				return new DropShadowFilter(0, 45, s.color, s.alpha, strokeBlur, strokeBlur, strokeStrength, s.quality, s.inner, true, hideObj);
			}
			
			return null;
		}
	}

}