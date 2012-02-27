package drops.ui {
	import drops.core.C_Box;
	import drops.core.C_SkinnableBox;
	import drops.data.C_Background;
	import drops.data.C_Mounts;
	import drops.data.C_SkinFrame;
	import drops.data.C_SkinState;
	import drops.events.C_Event;
	import drops.ui.C_Button;
	import drops.ui.C_ColorPicker;
	import drops.ui.C_Window;
	import drops.ui.CxNumericInput;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_PopUpColorPicker extends C_Box {
		private var _sample:C_Box;
		private var _sampleBg:C_SkinnableBox;
		private var _sampleButton:C_Button;
		
		private var _hexInput:CxNumericInput;
		private var _inputOffsetY:Number;
		private var _inputOffsetX:Number;
		
		private var _static:Boolean;
		private var _showInput:Boolean;
		
		private var _cancelColor:uint;
		private var _hexColor:uint;
		
		private var _alphaValue:Number;
		
		private static const _staticPicker:C_ColorPicker = new C_ColorPicker();
		private static const _staticWindow:C_Window = createPickerWindow(_staticPicker, 80, 3);
		
		private var _currentWindow:C_Window;
		private var _currentPicker:C_ColorPicker;
		
		public static var activePicker:C_PopUpColorPicker;
		
		public function C_PopUpColorPicker() {
			_currentWindow = _staticWindow;
			_currentPicker = _staticPicker;
			
			_alphaValue = 1.0;
			_hexColor = _currentPicker.hexColor;
			
			_inputOffsetY = 0;
			_inputOffsetX = 5;
			
			_static = true;
			_showInput = true;
			
			_sample = new C_Box();
			addChild(_sample);
			
			_sampleBg = new C_SkinnableBox();
			_sampleBg.skin.background = new C_Background(null, null, null, null, 0x808080, 1);
			_sampleBg.mounts = new C_Mounts(0, 0, 0, 0);
			_sample.addChild(_sampleBg);
			
			_sampleButton = new C_Button();
			_sampleButton.skin.setFrame(C_SkinState.NORMAL, new C_SkinFrame(null, new C_Background()));
			_sampleButton.mounts = new C_Mounts(0, 0, 0, 0);
			_sample.addChild(_sampleButton);
			
			_hexInput = new CxNumericInput(0x000000, 0xffffff);
			_hexInput.mode = CxNumericInput.HEX_COLOR;
			addChild(_hexInput);
			
			
			_hexInput.addEventListener(C_Event.CHANGE, inputChangeHandler);
			_hexInput.addEventListener(C_Event.CHANGE_COMPLETE, inputCompleteHandler);
			
			_hexInput.addEventListener(C_Event.RESIZE, elementsResizeHandler);
			_sample.addEventListener(C_Event.RESIZE, elementsResizeHandler);
			_sample.addEventListener(MouseEvent.CLICK, sampleClickHandler);

			align();
		}
		
		//---------------------------------------------------------------
		//	H A N D L E R S
		//---------------------------------------------------------------
		private function sampleClickHandler(e:MouseEvent):void {
			expand();
		}
		
		private function pickerChangeHandler(inside:Boolean, complete:Boolean):void {
			_hexColor = _currentPicker.hexColor;
			_hexInput.insideCurrent(_hexColor, true, inside, false);
			
			change(false, inside);
			if (complete) change(true, inside);
		}
		
		private function inputCompleteHandler(e:C_Event):void {
			change(true, e.inside);
		}
		
		private function inputChangeHandler(e:C_Event):void {
			_hexColor = _hexInput.current;
			_currentPicker.insideHex(_hexInput.current, false);
			change(false, e.inside);
		}
		
		private function elementsResizeHandler(e:C_Event):void {
			align();
		}
		
		//---------------------------------------------------------------
		//	S E T  /  G E T
		//---------------------------------------------------------------
		public function get staticPicker():C_ColorPicker {
			return _staticPicker;
		}
		
		public function get alphaValue():Number {
			return _alphaValue;
		}
		
		public function set alphaValue(value:Number):void {
			_alphaValue = value;
		}
		
		public function get sample():C_Box {
			return _sample;
		}
		
		public function get input():CxNumericInput {
			return _hexInput;
		}
		
		public function get window():C_Window {
			return _currentWindow;
		}
		
		public function set showInput(value:Boolean):void {
			if (value === _showInput) return;
			
			_showInput = value;
			_hexInput.visible = value;
			align();
		}
		
		public function get inputOffsetY():Number {
			return _inputOffsetY;
		}
		
		public function set inputOffsetY(value:Number):void {
			if (value === _inputOffsetY) return;
			_inputOffsetY = value;
			align();
		}
		
		public function get inputOffsetX():Number {
			return _inputOffsetX;
		}
		
		public function set inputOffsetX(value:Number):void {
			if (value === _inputOffsetX) return;
			_inputOffsetX = value;
			align();
		}
		
		public function get sampleButton():C_Button {
			return _sampleButton;
		}
		
		public function get hexColor():uint {
			return _hexColor;
		}
		
		public function set hexColor(value:uint):void {
			insideHex(value, true, false, true);
		}
		
		//---------------------------------------------------------------
		//	P U B L I C
		//---------------------------------------------------------------
		public function insideHex(value:uint, dispatch:Boolean, inside:Boolean = false, complete:Boolean = false):void {
			if (value == _hexColor) {
				if (dispatch && complete) change(complete, inside);
				return;
			}
			
			if (_currentWindow.expanded && activePicker == this) _currentPicker.insideHex(value, false);
			_hexInput.insideCurrent(value, true, false, false);
			_hexColor = value;
			
			if (dispatch) {
				change(false, inside);
				if (complete) change(true, inside);
			}
			else {
				refreshSample();
			}
		}
		
		public function turn():void {
			_currentWindow.turn();
		}
		
		public function expand():void {
			if (stage) {
				if (_currentWindow.parent !== stage) {
					stage.addChild(_currentWindow);
					_currentWindow.x = Math.min(stage.stageWidth -_currentWindow.width, stage.mouseX);
					_currentWindow.y = Math.min(stage.stageHeight -_currentWindow.height, stage.mouseY);
				}
				
				_cancelColor = hexColor;
				_currentPicker.insideHex(_hexColor, false);
				_currentPicker.changeFunction = pickerChangeHandler;
				
				_currentWindow.enterHandler = applyWindow;
				_currentWindow.escapeHandler = cancelWindow;
				_currentWindow.expand(false);
				
				activePicker = this;
			}
		}
		
		//---------------------------------------------------------------
		//	P R I V A T E
		//---------------------------------------------------------------
		private function align():void {
			var oX:Number = _sample.width;
			var oY:Number = _sample.height;
			
			if (_showInput) {
				_hexInput.y = Math.round((_sample.height - _hexInput.height) * 0.5) + _inputOffsetY;
				_hexInput.x = oX + _inputOffsetX;
				oX = _hexInput.x + _hexInput.width;
			}

			width = oX;
			height = oY;
		}

		private function applyWindow():void {
			_currentWindow.turn();
		}
		
		private function cancelWindow():void {
			if (hexColor !== _cancelColor) {
				hexColor = _cancelColor;
				change(false, true);
				change(true, true);
			}
			_currentWindow.turn();
		}
		
		private function refreshSample():void {
			var ct:ColorTransform = _sampleBg.transform.colorTransform;
			ct.color = _hexColor;
			_sampleBg.transform.colorTransform = ct;
		}

		private function change(complete:Boolean, inside:Boolean):void {
			refreshSample();
			dispatchEvent(new C_Event((complete) ? C_Event.CHANGE_COMPLETE : C_Event.CHANGE, null, inside));
		}
		
		//---------------------------------------------------------------
		//	S T A T I C
		//---------------------------------------------------------------
		private static function createPickerWindow(picker:C_ColorPicker, buttonsWidth:Number, buttonsSpacing:Number):C_Window {
			var window:C_Window = new C_Window('Color Picker', true);
			window.width = 250;
			window.height = 250;
			window.x = 400;
			window.y = 200;
			window.turn();
			window.animation = true;
			picker.mounts = new C_Mounts(0, buttonsWidth + 10, 0, 0);
			window.content.addChild(picker);
			
			var tBox:C_TileBox = new C_TileBox('100%');
			tBox.autoHeight = true;
			tBox.tileAutoHeight = true;
			tBox.tilePaddingBottom = buttonsSpacing;
			tBox.width = buttonsWidth;
			tBox.right = 0;
			window.content.addChild(tBox);
			
			var okButton:C_Button = new C_Button('Ok');
			okButton.mounts = new C_Mounts(0, 0);
			tBox.addChild(okButton);
			
			var cancelButton:C_Button = new C_Button('Cancel');
			cancelButton.mounts = new C_Mounts(0, 0);
			tBox.addChild(cancelButton);
			
			window.okButton = okButton;
			window.cancelButton = cancelButton;
			
			return window;
		}
	}

}