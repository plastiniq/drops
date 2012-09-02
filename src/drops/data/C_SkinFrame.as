package drops.data {
	import com.adobe.crypto.MD5;
	import drops.data.effects.C_EffectDescription;
	import drops.data.effects.C_EffectProperty;
	import drops.data.effects.C_EffectsArray;
	import drops.data.effects.samples.C_EffectSample;
	import drops.graphics.EffectsProcessing;
	import flash.display.BitmapData;
	import flash.events.EventDispatcher;
	import flash.geom.Rectangle;
	import flash.text.TextFormat;
	import flash.utils.describeType;
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_SkinFrame extends EventDispatcher {
		private var _background:C_Background;
		private var _effects:C_EffectsArray;
		
		public var textColor:Object;
		public var emboss:C_Emboss;
		
		public var enabled:Boolean = true;
		public var selectedEffect:int = -1;
		
		public function C_SkinFrame(effects:C_EffectsArray = null, background:C_Background = null) {
			_background = background;
			_effects = (effects) ? effects : new C_EffectsArray();
		}
		
		//----------------------------------------------------------------
		//	S E T  /  G E T
		//----------------------------------------------------------------
		public function get effects():C_EffectsArray {
			return _effects;
		}
		
		public function set effects(value:C_EffectsArray):void {
			_effects = value;
		}
		
		public function get background():C_Background {
			return _background;
		}
		
		public function set background(value:C_Background):void {
			_background = value;
		}
		
		//----------------------------------------------------------------
		//	P U B L I C
		//----------------------------------------------------------------
		public function clone():C_SkinFrame {
			var bg:C_Background = (_background === null) ? null : _background.clone();
			var frame:C_SkinFrame = new C_SkinFrame(_effects.clone(), bg);
			
			frame.emboss = (emboss) ? emboss.clone() : emboss;
			frame.textColor = textColor;
			frame.enabled = enabled;
			frame.selectedEffect = selectedEffect;
			
			return frame;
		}

		//---------------------------------------------------------------------
		//	S T A T I C
		//---------------------------------------------------------------------
	}

}