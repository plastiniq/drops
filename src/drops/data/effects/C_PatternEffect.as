package drops.data.effects {
	import drops.data.effects.samples.C_EffectSample;
	import drops.graphics.BitmapProcessing;
	import drops.graphics.Pattern;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.Shape;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_PatternEffect extends C_EffectSample {
		public var pattern:BitmapData;
		public var alpha:Number;
		
		public static const description:C_EffectDescription = new C_EffectDescription('Pattern Overlay');
		description.push(new C_EffectProperty(C_EffectPropertyType.BITMAPDATA, 'pattern', 'Pattern'));
		description.push(new C_EffectProperty(C_EffectPropertyType.NUMERIC, 'alpha', 'Alpha', null, new C_ValueRange(0, 1, 0.01)));
		
		public function C_PatternEffect() {
			alpha = 1.0;
		}
		
	
	}

}