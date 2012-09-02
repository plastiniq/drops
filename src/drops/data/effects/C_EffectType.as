package drops.data.effects {
	import drops.data.effects.advanced.C_DropShadowEffect;
	import drops.data.effects.advanced.C_InnerShadowEffect;
	import drops.data.effects.C_ColorEffect;
	import drops.data.effects.C_GlowEffect;
	import drops.data.effects.C_GradientData;
	import drops.data.effects.C_GradientEffect;
	import drops.data.effects.C_NoiseEffect;
	import drops.data.effects.C_PatternEffect;
	import drops.data.effects.C_ShadowEffect;
	import drops.data.effects.C_StrokeEffect;
	import drops.data.effects.samples.C_EffectSample;
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_EffectType {
		
		public static const GRADIENT:Class = C_GradientEffect;
		public static const GLOW:Class = C_GlowEffect;
		public static const SHADOW:Class = C_ShadowEffect;
		public static const INNER_SHADOW:Class = C_InnerShadowEffect;
		public static const DROP_SHADOW:Class = C_DropShadowEffect;
		public static const NOISE:Class = C_NoiseEffect;
		public static const COLOR:Class = C_ColorEffect;
		public static const STROKE:Class = C_StrokeEffect;
		
		
		public function C_EffectType() {
			
		}
		
	}

}