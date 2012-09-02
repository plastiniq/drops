package drops.data.effects {
	import drops.data.effects.samples.C_EffectSample;
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.Shape;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_StrokeEffect extends C_EffectSample {
		public var size:Number;
		public var strength:Number;
		public var fillType:String;
		public var inner:Boolean;
		public var quality:int;
		
		public var color:Object;
		public var alpha:Object;
		public var gradientData:C_GradientData;
		
		private static const _shape:Shape = new Shape();
		private static const _matrix:Matrix = new Matrix();
		
		public static const description:C_EffectDescription = new C_EffectDescription('Stroke');
		description.push(new C_EffectProperty(C_EffectPropertyType.COLOR, 'color', 'Color'));
		description.push(new C_EffectProperty(C_EffectPropertyType.SLIDER, 'size', 'Size', null, new C_ValueRange(0, 100, 1)));
		description.push(new C_EffectProperty(C_EffectPropertyType.SLIDER, 'alpha', 'Opacity', null, new C_ValueRange(0, 1, 0.01)));
		//description.push(new C_EffectProperty(C_EffectPropertyType.SLIDER, 'strength', 'Strength', null, new C_ValueRange(0, 1000)));
		//description.push(new C_EffectProperty(C_EffectPropertyType.NUMERIC, 'quality', 'Quality'));
		description.push(new C_EffectProperty(C_EffectPropertyType.BOOLEAN, 'inner', 'Inner'));
		

		
		public function C_StrokeEffect() {
			inner = false;
			fillType = C_FillType.COLOR;
			color = 0x000000;
			alpha = 1.0;
			size = 1;
			quality = 1;
			gradientData = new C_GradientData();
		}
	}
}