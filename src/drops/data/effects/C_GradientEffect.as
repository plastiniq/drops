package drops.data.effects {
	import drops.data.effects.samples.C_EffectSample;
	import drops.graphics.BitmapProcessing;
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_GradientEffect extends C_EffectSample {
		public var gradientData:C_GradientData;
		public var alpha:Number;
		public var type:String;
		public var angle:Number;
		
		private static const _shape:Shape = new Shape();
		private static const _matrix:Matrix = new Matrix();
		
		public static const description:C_EffectDescription = new C_EffectDescription('Gradient Overlay');
		description.push(new C_EffectProperty(C_EffectPropertyType.GRADIENT, 'gradientData', 'Gradient'));
		description.lastProperty.cloneFunc = 'clone';
		description.push(new C_EffectProperty(C_EffectPropertyType.MENU, 'type', 'Type', [new C_EffectOption(GradientType.LINEAR, GradientType.RADIAL), new C_EffectOption('radial', 'radial')]));
		description.push(new C_EffectProperty(C_EffectPropertyType.ANGLE, 'angle', 'Angle'));
		description.push(new C_EffectProperty(C_EffectPropertyType.NUMERIC, 'alpha', 'Alpha', null, new C_ValueRange(0, 1, 0.01)));
		
		public function C_GradientEffect() {
			alpha = 1.0;
			type = GradientType.LINEAR;
			angle = 90;
			gradientData = new C_GradientData();
		}
		
		public function clone():C_GradientEffect {
			var filter:C_GradientEffect = new C_GradientEffect();
			filter.alpha = alpha;
			filter.gradientData = gradientData.clone();
			return filter;
		}
	}

}