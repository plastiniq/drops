package drops.ui.advanced {
	import drops.core.C_Box;
	import drops.core.C_SkinnableBox;
	import drops.events.C_Event;
	import drops.ui.C_ColorPicker;
	import drops.ui.C_Label;
	import drops.ui.C_LabeledBox;
	import drops.ui.C_PopUpColorPicker;
	import drops.ui.C_Slider;
	import drops.ui.CxNumericInput;
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_ContextGE extends C_Box {
		private var _locationBox:C_LabeledBox;
		private var _locationInput:CxNumericInput;
		
		private var _locationBoxOffsetY:Number;
		private var _alphaPickerOffsetY:Number;
		
		private var _alphaPicker:C_AlphaPopUpColorPicker;
		
		private var _slider:C_Slider;
		
		private var _enabled:Boolean;
		private var _item:C_Stopper;
		
		public function C_ContextGE() {
			height = 26;
			
			_locationBox = new C_LabeledBox('Location:');
			_locationInput = new CxNumericInput(0, 100);
			_locationInput.suffix = '%';
			_locationInput.step = 1;
			_locationBox.content = _locationInput;
			addChild(_locationBox);
			
			_locationBoxOffsetY = 0;
			_alphaPickerOffsetY = 0;
		
			_alphaPicker = new C_AlphaPopUpColorPicker();
			_alphaPicker.right = 0;
			
			addChild(_alphaPicker);
			
			
			enabled = false;
			align();
			
			_locationInput.addEventListener(C_Event.CHANGE, locationChangeHandler);
			_locationInput.addEventListener(C_Event.CHANGE_COMPLETE, locationChangeHandler);
			
			_alphaPicker.addEventListener(C_Event.CHANGE, pickerChangeHandler);
			_alphaPicker.addEventListener(C_Event.CHANGE_COMPLETE, pickerChangeHandler);
			
			_locationBox.addEventListener(C_Event.RESIZE, childResizeHandler);
			_alphaPicker.addEventListener(C_Event.RESIZE, childResizeHandler);
			addEventListener(C_Event.RESIZE, resizeHandler);
		}
		
		//---------------------------------------------------------
		//	H A N D L E R S
		//---------------------------------------------------------
		private function locationChangeHandler(e:C_Event):void {
			if (_item) {
				_item.insideLocation(_locationInput.current / 100, e.inside, false);
				change((e.type === C_Event.CHANGE_COMPLETE), e.inside);
			}
		}
		
		private function pickerChangeHandler(e:C_Event):void {
			if (e.inside && _item) {
				_item.insideAlpha(_alphaPicker.alphaValue / 100, e.inside, false);
				_item.insideHex(_alphaPicker.hexColor, e.inside, false);
			}
			change((e.type === C_Event.CHANGE_COMPLETE), e.inside);
		}
		
		private function childResizeHandler(e:C_Event):void {
			align();
		}
		
		private function resizeHandler(e:C_Event):void {
			if (e.data !== WIDTH) align();
		}
		
		//---------------------------------------------------------
		//	S E T / G E T 
		//---------------------------------------------------------
		public function get alphaPickerOffsetY():Number {
			return _alphaPickerOffsetY;
		}
		
		public function set alphaPickerOffsetY(value:Number):void {
			if (_alphaPickerOffsetY == value) return;
			_alphaPickerOffsetY = value;
			align();
		}
		
		public function get locationBoxOffsetY():Number {
			return _locationBoxOffsetY;
		}
		
		public function set locationBoxOffsetY(value:Number):void {
			if (_locationBoxOffsetY == value) return;
			_locationBoxOffsetY = value;
			align();
		}
		
		public function get locationBox():C_LabeledBox {
			return _locationBox;
		}
		
		public function get locationInput():CxNumericInput {
			return _locationInput;
		}
		
		public function get alphaPicker():C_AlphaPopUpColorPicker {
			return _alphaPicker;
		}
		
		public function get locationLabel():C_Label {
			return _locationBox.label;
		}
		
		public function get stopper():C_Stopper {
			return _item;
		}
		
		public function set stopper(value:C_Stopper):void {
			_item = value;
			refresh();
		}
		
		public function get enabled():Boolean {
			return _enabled;
		}
		
		public function set enabled(value:Boolean):void {
			if (value) {
				alpha = 1;
				mouseEnabled = true;
				mouseChildren = true;
			}
			else {
				alpha = 0.4;
				mouseEnabled = false;
				mouseChildren = false;
			}
			_enabled = value;
		}
		
		//---------------------------------------------------------
		//	P U B L I C
		//---------------------------------------------------------
		public function refresh():void {
			enabled = Boolean(_item);
			if (_item) {
				_alphaPicker.alphaValue = _item.alphaValue * 100;
				_locationInput.current = _item.location * 100;
				_alphaPicker.hexColor = _item.picker.hexColor;
			}
		}
		
		public function refreshLocation():void {
			enabled = Boolean(_item);
			if (_item) {
				_locationInput.current = _item.location * 100;
			}
		}
		
		//---------------------------------------------------------
		//	P R I V A T E
		//---------------------------------------------------------
		private function align():void {
			_locationBox.y = Math.round((height - _locationBox.height) * 0.5) + _locationBoxOffsetY;
			_alphaPicker.y = Math.round((height - _alphaPicker.height) * 0.5) + _alphaPickerOffsetY;
		}
		
		private function change(complete:Boolean, inside:Boolean):void {
			dispatchEvent(new C_Event((complete) ? C_Event.CHANGE_COMPLETE : C_Event.CHANGE, null, inside));
		}
	}

}