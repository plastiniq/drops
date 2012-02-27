package drops.data.effects {
	import drops.data.effects.samples.C_EffectSample;
	import drops.graphics.BitmapProcessing;
	import drops.graphics.Pattern;
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
	
	 
	public class C_NoiseEffect extends C_EffectSample {
		public var dencity:Number;
		public var color:uint;
		public var randomSeed:int;
		public var blurX:Number;
		public var blurY:Number;
		
		public static const description:C_EffectDescription = new C_EffectDescription('Noise Overlay');
		description.push(new C_EffectProperty(C_EffectPropertyType.COLOR, 'color', 'Color'));
		description.push(new C_EffectProperty(C_EffectPropertyType.SLIDER, 'dencity', 'Dencity'));
		description.push(new C_EffectProperty(C_EffectPropertyType.SLIDER, 'blurX', 'Blur X', null, new C_ValueRange(0, 100, 1)));
		description.push(new C_EffectProperty(C_EffectPropertyType.SLIDER, 'blurY', 'Blur Y', null, new C_ValueRange(0, 100, 1)));
		
		public function C_NoiseEffect() {
			color = 0;
			dencity = 50.0;
			randomSeed = dencity;
			blurX = 0;
			blurY = 0;
		}
		
		public function clone():C_NoiseEffect {
			var filter:C_NoiseEffect = new C_NoiseEffect();
			filter.dencity = dencity;
			filter.randomSeed = randomSeed;
			filter.color = color;
			return filter;
		}
		
		//-----------------------------------------------------------------------
		//	S T A T I C
		//-----------------------------------------------------------------------
	}

}