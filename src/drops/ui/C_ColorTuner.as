package drops.ui {
	import drops.data.C_Description;
	import drops.data.C_Property;
	import drops.events.C_Event;
	import drops.utils.C_Color;
	import drops.utils.C_Text;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextFormat;
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_ColorTuner extends C_TileBox {
		private var _color:C_Color;
		private var _channels:Object;
		
		private var _hsl:C_TileBox;
		private var _rgb:C_TileBox;
		private var _hex:C_TileBox;
		
		private var _hslEnabled:Boolean;
		private var _rgbEnabled:Boolean;
		private var _hexEnabled:Boolean;
		
		private var _changed:Boolean;
		
		public static var description:C_Description = new C_Description();
		description.pushGroup('Options');
		description.lastGroup.pushProperty(C_Property.BOOLEAN, 'hslEnabled', 'Hsl Scheme');
		description.lastGroup.pushProperty(C_Property.BOOLEAN, 'rgbEnabled', 'Rgb Scheme');
		description.lastGroup.pushProperty(C_Property.BOOLEAN, 'hexEnabled', 'Hex Scheme');

		public function C_ColorTuner(hsl:Boolean = true, rgb:Boolean = true, hex:Boolean = true) {
			_hslEnabled = hsl;
			_rgbEnabled = rgb;
			_hexEnabled = hex;
			
			_changed = false;
			
			tileWidth = '100%';
			tileAutoHeight = true;
			tileAutoWidth = false;
			hideOverflow = true;
			tilePaddingTop = 10;
			
			_color = new C_Color(0xFFFFFF);
			
			_channels = { };
			
			_hsl = new C_TileBox('100%');
			_hsl.tileAutoHeight = true;
			_hsl.tileAutoWidth = false;
			_hsl.autoHeight = true;
			_hsl.addChild(newChannel('h', 'H:', 0, 359));
			_hsl.addChild(newChannel('s', 'S:', 0, 100));
			_hsl.addChild(newChannel('l', 'L:', 0, 100));

			_rgb = new C_TileBox('100%');
			_rgb.tileAutoHeight = true;
			_rgb.tileAutoWidth = false;
			_rgb.autoHeight = true;
			_rgb.addChild(newChannel('r', 'R:', 0, 255));
			_rgb.addChild(newChannel('g', 'G:', 0, 255));
			_rgb.addChild(newChannel('b', 'B:', 0, 255));
			
			_hex = new C_TileBox('100%');
			_hex.tileAutoWidth = false;
			_hex.tileAutoHeight = true;
			_hex.autoHeight = true;
			_hex.addChild(newChannel('hex', '#:', 0, 0xFFFFFF, CxNumericInput.HEX_COLOR));
			
			if (_hslEnabled) addChild(_hsl);
			if (_rgbEnabled) addChild(_rgb);
			if (_hexEnabled) addChild(_hex);
		}
		
		//--------------------------------------------------------
		//	H A N D L E R S
		//--------------------------------------------------------
		private function channelChangeCompleteHandler(e:C_Event):void {
			if (_changed) {
				change(true, e.inside);
				_changed = false;
			}
		}
		
		private function channelChangeHandler(e:C_Event):void {
			if (e.inside) {
				_color[e.target.data] = e.target.current;
				refreshValues(e.target.data);
			}
			_changed = true;
			change(false, e.inside);
		}
		
		//--------------------------------------------------------
		//	S E T  /  G E T
		//--------------------------------------------------------
		public function get hexEnabled():Boolean {
			return _hexEnabled;
		}
		
		public function set hexEnabled(value:Boolean):void {
			enableScheme(_hex, value);
			_hexEnabled = value;
		}
		
		public function get rgbEnabled():Boolean {
			return _rgbEnabled;
		}
		
		public function set rgbEnabled(value:Boolean):void {
			enableScheme(_rgb, value);
			_rgbEnabled = value;
		}
		
		public function get hslEnabled():Boolean {
			return _hslEnabled;
		}
		
		public function set hslEnabled(value:Boolean):void {
			enableScheme(_hsl, value);
			_hslEnabled = value;
		}
		
		public function get color():C_Color {
			return _color;
		}
		
		public function get hexColor():uint {
			return _color.hex;
		}
		
		public function set hexColor(value:uint):void {
			insideHex(value, true, false, true);
		}
		
		public function get channels():Object {
			return _channels;
		}
		
		//--------------------------------------------------------
		//	P R I V A T E
		//--------------------------------------------------------
		public function insideHex(value:uint, dispatch:Boolean, inside:Boolean = false, complete:Boolean = false):void {
			if (value == _color.hex) {
				if (dispatch && complete) change(true, inside);
				return;
			}
			
			_color.hex = value;
			refreshValues();
			if (dispatch) {
				change(false, inside);
				if (complete) change(true, inside);
			}
		}
		
		private function enableScheme(scheme:DisplayObject, enabled:Boolean):void {
			if ((scheme.parent === this) === enabled) return;
			if (enabled) {
				addChild(scheme);
			}
			else {
				this.removeChild(scheme);
			}
		}
		
		internal function refreshValues(...exceptions):void {
			var k:String;
			var input:CxNumericInput;
			for (k in _channels) {
				if (_color.hasOwnProperty(k) && exceptions.indexOf(k) == -1) {
					input = _channels[k];
					if (contains(input) && input.visible) input.insideCurrent(_color[k], true, false, false);
				}
			}
		}
		
		private function newChannel(channel:String, label:String, min:Number, max:Number, mode:String = null, suffix:String = null):C_LabeledBox {
			var input:CxNumericInput = new CxNumericInput(min, max);
			input.mode = (mode) ? mode : CxNumericInput.INTEGER;
			input.current = _color[channel];
			input.data = channel;
			input.addEventListener(C_Event.CHANGE, channelChangeHandler);
			input.addEventListener(C_Event.CHANGE_COMPLETE, channelChangeCompleteHandler);
			input.suffix = suffix;
			_channels[channel] = input;
			
			var labeledBox:C_LabeledBox = new C_LabeledBox(label);
			labeledBox.labelOffsetY = 1;
			labeledBox.group = name;
			labeledBox.label.textFormat = C_Text.defineFormat(null, 11);
			labeledBox.height = 20;
			labeledBox.content = input;
			return labeledBox;
		}
		
		private function change(complete:Boolean, inside:Boolean):void {
			dispatchEvent(new C_Event((complete) ? C_Event.CHANGE_COMPLETE : C_Event.CHANGE, null, inside));
		}
	}

}