package drops.data.effects {
	import drops.data.effects.samples.C_EffectSample;
	import flash.display.BitmapData;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_GlowEffect extends C_EffectSample {
		public var color:uint;
		public var alpha:Number;
		public var strength:Number;
		public var size:Number;
		public var inner:Boolean;
		
		public static const description:C_EffectDescription = new C_EffectDescription('Glow');
		description.push(new C_EffectProperty(C_EffectPropertyType.COLOR, 'color', 'Color'));
		description.push(new C_EffectProperty(C_EffectPropertyType.BOOLEAN, 'inner', 'Inner'));
		description.push(new C_EffectProperty(C_EffectPropertyType.SLIDER, 'alpha', 'Alpha', null, new C_ValueRange(0, 1, 0.01)));
		description.push(new C_EffectProperty(C_EffectPropertyType.SLIDER, 'strength', 'Strength', null, new C_ValueRange(0, 255)));
		description.push(new C_EffectProperty(C_EffectPropertyType.NUMERIC, 'size', 'Size'));
		
		public function C_GlowEffect() {
			color = 0xffff00;
			alpha = 1.0;
			strength = 2.0;
			size = 10.0;
			inner = true;
		}
		
	}

}