package drops.ui.advanced {
	import drops.core.C_Box;
	import drops.events.C_Event;
	import drops.ui.C_PopUpColorPicker;
	import drops.ui.C_Slider;
	import flash.display.GradientType;
	import flash.geom.Matrix;
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_AlphaPopUpColorPicker extends C_Box {
		private var _slider:C_Slider;
		private var _picker:C_PopUpColorPicker;
		
		private var _sliderOffsetX:Number;
		private var _sliderOffsetY:Number;
		
		private var _gradientMatrix:Matrix;
		
		private var _lockRefresh:Boolean;
		
		public function C_AlphaPopUpColorPicker() {
			_sliderOffsetX = 4;
			_sliderOffsetY = 0;
			
			_lockRefresh = false;
			
			_gradientMatrix = new Matrix();
			
			_picker = new C_PopUpColorPicker;
			_picker.showInput = false;
			addChild(_picker);
			
			_slider = new C_Slider();
			_slider.setSize(50, 10);
			_slider.progressTrackVisible = false;
			_slider.pointer.setSize(10, 10);
			addChild(_slider);
			
			_slider.addEventListener(C_Event.CHANGE, sliderChangeHandler);
			_slider.addEventListener(C_Event.CHANGE_COMPLETE, sliderCompleteHandler);
			_slider.addEventListener(C_Event.RESIZE, sliderResizeHandler);
			
			_picker.addEventListener(C_Event.CHANGE, pickerChangeHandler);
			_picker.addEventListener(C_Event.CHANGE_COMPLETE, pickerCompleteHandler);
			_picker.addEventListener(C_Event.RESIZE, pickerResizeHandler);
			
			addEventListener(C_Event.RESIZE, resizeHandler);
			
			align();
			refreshSlider();
		}
		
		//----------------------------------------------------------------
		//	H A N D L E R S
		//----------------------------------------------------------------
		private function resizeHandler(e:C_Event):void {
			if (!_lockRefresh) {
				_slider.width = width - _picker.width - _sliderOffsetX;
			}
		}
		
		private function sliderResizeHandler(e:C_Event):void {
			align();
			refreshSlider();
		}
		
		private function pickerResizeHandler(e:C_Event):void {
			align();
		}
		
		private function pickerChangeHandler(e:C_Event):void {
			change(false, e.inside);
			refreshSlider();
		}
		
		private function sliderChangeHandler(e:C_Event):void {
			change(false, e.inside);
		}
		
		private function pickerCompleteHandler(e:C_Event):void {
			change(true, e.inside);
		}
		
		private function sliderCompleteHandler(e:C_Event):void {
			change(true, e.inside);
		}
		//----------------------------------------------------------------
		//	S E T  /  G E T
		//----------------------------------------------------------------
		public function get hexColor():uint {
			return _picker.hexColor;
		}
		
		public function set hexColor(value:uint):void {
			_picker.hexColor = value;
		}
		
		public function get alphaValue():Number {
			return _slider.current;
		}
		
		public function set alphaValue(value:Number):void {
			_slider.current = value;
		}
		
		public function get sliderOffsetY():Number {
			return _sliderOffsetY;
		}
		
		public function set sliderOffsetY(value:Number):void {
			if (_sliderOffsetY == value) return;
			align();
		}
		
		public function get sliderOffsetX():Number {
			return _sliderOffsetX;
		}
		
		public function set sliderOffsetX(value:Number):void {
			if (_sliderOffsetX == value) return;
			align();
		}
		
		public function get alphaSlider():C_Slider {
			return _slider;
		}
		
		public function get picker():C_PopUpColorPicker {
			return _picker;
		}
		
		//----------------------------------------------------------------
		//	P U B L I C
		//----------------------------------------------------------------
		public function insideApha(value:uint, dispatch:Boolean, inside:Boolean = false, complete:Boolean = false):void {
			_slider.insideCurrent(value, dispatch, inside, complete);
		}
		
		public function insideHex(value:uint, dispatch:Boolean, inside:Boolean = false, complete:Boolean = false):void {
			_picker.insideHex(value, dispatch, inside, complete);
			if (!dispatch) refreshSlider();
		}
		
		//----------------------------------------------------------------
		//	P R I V A T E
		//----------------------------------------------------------------
		private function align():void {
			_picker.x = 0;
			_picker.y = Math.round((height - _picker.height) * 0.5);
			
			_slider.x = _picker.width + _sliderOffsetX;
			_slider.y = Math.round((height - _slider.height) * 0.5) + _sliderOffsetY;
			
			_lockRefresh = true;
			width = _slider.x + _slider.width;
			_lockRefresh = false;
		}
		
		private function refreshSlider():void {
			_gradientMatrix.createGradientBox(_slider.width, _slider.height, 0, 0, 0);
			_slider.graphics.clear();
			_slider.graphics.beginGradientFill(GradientType.LINEAR, [_picker.hexColor, _picker.hexColor], [0, 1], [0, 255], _gradientMatrix);
			_slider.graphics.drawRect(0, 0, _slider.width, _slider.height);
		}
		
		private function change(complete:Boolean, inside:Boolean):void {
			dispatchEvent(new C_Event((complete) ? C_Event.CHANGE_COMPLETE : C_Event.CHANGE, null, inside));
		}
		
	}

}