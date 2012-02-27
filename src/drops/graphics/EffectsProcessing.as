package drops.graphics {
	import drops.data.effects.C_EffectConverter;
	import drops.data.effects.C_EffectResult;
	import drops.data.effects.C_EffectsArray;
	import drops.data.effects.C_EffectType;
	import drops.data.effects.C_GradientData;
	import drops.data.effects.samples.C_EffectSample;
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.Shape;
	import flash.filters.BitmapFilter;
	import flash.filters.BlurFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class EffectsProcessing {
		//------------------------------------------------------------------
		//	P U B L I C
		//------------------------------------------------------------------
		public static function generate(source:BitmapData, effects:C_EffectsArray, fillAlpha:Number = 1.0):C_EffectResult {
			return new C_EffectResult(source, source.rect, false);
		}
		
	}

}