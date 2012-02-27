package drops.data.effects {
	import drops.data.effects.samples.C_EffectSample;
	import flash.display.BitmapData;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.sampler.NewObjectSample;
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_ShadowEffect extends C_EffectSample {
		public var angle:Number;
		public var color:uint;
		public var alpha:Number;
		public var distance:Number;
		public var strength:Number;
		public var size:Number;
		public var inner:Boolean;
		public var quality:uint;
		
		public static const description:C_EffectDescription = new C_EffectDescription('Shadow');
		description.push(new C_EffectProperty(C_EffectPropertyType.COLOR, 'color', 'Color'));
		description.push(new C_EffectProperty(C_EffectPropertyType.BOOLEAN, 'inner', 'inner'));
		description.push(new C_EffectProperty(C_EffectPropertyType.NUMERIC, 'alpha', 'Alpha', null, new C_ValueRange(0, 1, 0.01)));
		description.push(new C_EffectProperty(C_EffectPropertyType.NUMERIC, 'strength', 'Strength'));
		description.push(new C_EffectProperty(C_EffectPropertyType.NUMERIC, 'size', 'Size'));
		description.push(new C_EffectProperty(C_EffectPropertyType.ANGLE, 'angle', 'Angle'));
		description.push(new C_EffectProperty(C_EffectPropertyType.NUMERIC, 'distance', 'Distance'));
		
		public function C_ShadowEffect() {
			angle = 90.0;
			color = 0x000000;
			alpha = 0.5;
			distance = 2;
			strength = 1.0;
			size = 6.0;
			inner = false;
			quality = 1;
		}
		
	}

}