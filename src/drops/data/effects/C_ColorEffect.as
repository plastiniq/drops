package drops.data.effects {
	import com.adobe.fileformats.vcard.Phone;
	import drops.data.effects.samples.C_EffectSample;
	import drops.graphics.BitmapProcessing;
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_ColorEffect extends C_EffectSample {
		public var color:uint;
		public var alpha:Number;
		
		public static const description:C_EffectDescription = new C_EffectDescription('Color Overlay');
		description.push(new C_EffectProperty(C_EffectPropertyType.COLOR, 'color', 'Color'));
		description.push(new C_EffectProperty(C_EffectPropertyType.SLIDER, 'alpha', 'Alpha', null, new C_ValueRange(0, 1, 0.01)));
		
		public function C_ColorEffect() {
			color = 0xff0000;
			alpha = 1.0;
		}

	}

}