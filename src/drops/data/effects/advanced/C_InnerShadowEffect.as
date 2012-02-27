package drops.data.effects.advanced {
	import drops.data.effects.C_EffectDescription;
	import drops.data.effects.C_EffectProperty;
	import drops.data.effects.C_EffectPropertyType;
	import drops.data.effects.C_ShadowEffect;
	import drops.data.effects.C_ValueRange;
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_InnerShadowEffect extends C_ShadowEffect {
		
		public static const description:C_EffectDescription = new C_EffectDescription('Inner Shadow');
		description.push(new C_EffectProperty(C_EffectPropertyType.COLOR, 'color', 'Color'));
		description.push(new C_EffectProperty(C_EffectPropertyType.SLIDER, 'alpha', 'Alpha', null, new C_ValueRange(0, 1, 0.01)));
		description.push(new C_EffectProperty(C_EffectPropertyType.ANGLE, 'angle', 'Angle'));
		description.push(new C_EffectProperty(C_EffectPropertyType.SLIDER, 'distance', 'Distance', null, new C_ValueRange(0, 100, 1)));
		description.push(new C_EffectProperty(C_EffectPropertyType.SLIDER, 'size', 'Size', null, new C_ValueRange(0, 100, 1)));
		description.push(new C_EffectProperty(C_EffectPropertyType.SLIDER, 'strength', 'Strength', null, new C_ValueRange(1, 999, 1)));

		public function C_InnerShadowEffect() {
			inner = true;
		}
		
	}

}