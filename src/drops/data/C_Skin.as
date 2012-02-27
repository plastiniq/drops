package drops.data {
	import drops.data.effects.C_EffectDescription;
	import drops.data.effects.C_EffectResult;
	import drops.data.effects.C_EffectsArray;
	import drops.data.effects.samples.C_EffectSample;
	import drops.events.C_Event;
	import drops.utils.C_Text;
	import flash.display.BitmapData;
	import flash.display.GraphicsPath;
	import flash.events.EventDispatcher;
	import flash.geom.Rectangle;
	import flash.text.TextFormat;
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_Skin extends EventDispatcher {
		private var _frames:Object;
		public var numFrames:int;
		
		public var textFormat:TextFormat;
		public var emboss:C_Emboss;
		
		private var _background:C_Background;
		private var _effects:C_EffectsArray;
		
		public var _addOverlay:C_EffectResult;
		public var _substractOverlay:C_EffectResult;

		public function C_Skin(bmd:BitmapData = null, shape:String = null, rect:Rectangle = null, color:Object = null) {
			_background = new C_Background(bmd, null, rect, shape, color);
			numFrames = 1;
			_frames = {};
			_frames[C_SkinState.NORMAL] = new C_SkinFrame();
			_effects = new C_EffectsArray();;
			
			_background.addEventListener(C_Event.CHANGE, bgChangeHandler);
		}
		
		//---------------------------------------------------------------------
		//	H A N D L E R S
		//---------------------------------------------------------------------
		private function bgChangeHandler(e:C_Event):void {
			change();
		}
		
		//---------------------------------------------------------------------
		//	S E T  /  G E T
		//---------------------------------------------------------------------
		public function get effects():C_EffectsArray {
			return _effects;
		}
		
		public function set effects(value:C_EffectsArray):void {
			_effects = (value) ? value : new C_EffectsArray();
			change();
		}
		
		public function get background():C_Background {
			return _background;
		}

		public function set background(value:C_Background):void {
			if (value == _background) return;
			if (_background) _background.removeEventListener(C_Event.CHANGE, bgChangeHandler)
			_background = value;
			_background.addEventListener(C_Event.CHANGE, bgChangeHandler);
			change();
		}
		
		public function get frames():Object {
			return _frames;
		}
		
		//---------------------------------------------------------------------
		//	P U B L I C
		//---------------------------------------------------------------------
		public function clone():C_Skin {
			var skin:C_Skin = new C_Skin();
			
			skin.textFormat = C_Text.cloneFormat(textFormat);
			skin.emboss = (emboss) ? emboss.clone() : null;
			skin.background = _background.clone();
			
			var state:String;
			for (state in _frames) {
				skin.setFrame(state, _frames[state].clone());
			}
			return skin;
		}
		
		public function setFrame(state:String, frame:C_SkinFrame):void {
			if (!_frames[state]) numFrames++;
			_frames[state] = frame;
			change(state);
		}
		
		//---------------------------------------------------------------------
		//	S T A T I C
		//---------------------------------------------------------------------
		
		
		//---------------------------------------------------------------------
		//	P R I V A T E
		//---------------------------------------------------------------------
		private function change(state:String = null):void {
			dispatchEvent(new C_Event(C_Event.CHANGE));
		}

	}

}