package drops.ui.advanced {
	import drops.core.C_Box;
	import drops.core.C_SkinnableBox;
	import drops.data.C_Skin;
	import drops.data.C_SkinFrame;
	import drops.data.C_SkinState;
	import drops.events.C_Event;
	import drops.ui.C_Button;
	import drops.utils.C_Accessor;
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_StopperTrack extends C_SkinnableBox {
		private const _stoppers:Array = [];
		
		private var _selectedStopper:C_Stopper;
		private var _waitingStopper:C_Stopper;
		
		private var _stopperWidth:Number;
		private var _stopperHeight:Number;
		private var _stopperArrow:BitmapData;
		private var _stopperSkin:C_Skin;
		private var _sample:C_Button;
		private var _align:String;
		
		private var _colors:Array;
		private var _alphas:Array;
		private var _ratios:Array;
		
		private var _changed:Boolean;
		
		private var _gradientShape:Shape;
		private var _gradientBitmapData:BitmapData;
		private var _gradientMatrix:Matrix;
		
		private var _lastColor:uint;
		private var _lastAlpha:Number;
		
		public function C_StopperTrack() {
			_stopperWidth = 11;
			_stopperHeight = 12;
			_lastColor = 0x000000;
			_lastAlpha = 1;
			
			width = 300;
			
			_colors = [];
			_alphas = [];
			_ratios = [];
			 
			_gradientShape = new Shape();
			_gradientBitmapData = new BitmapData(width, 1, true, 0xFF000000);
			_gradientMatrix = new Matrix();
			 
			skin = new C_Skin(null, null, null, 0);
			skin.background.fillAlpha = 0.2;
			addEventListener(C_Event.RESIZE, resizeHandler);
			addEventListener(MouseEvent.MOUSE_DOWN, mDownHandler);

			refreshHeight();
		}
		
		//---------------------------------------------------------
		//	H A N D L E R
		//---------------------------------------------------------
		private function stageUpHandler(e:MouseEvent):void {
			_waitingStopper = null;
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, stageMoveHandler);
			stage.removeEventListener(MouseEvent.MOUSE_UP, stageUpHandler);
		}
		
		private function stageMoveHandler(e:MouseEvent):void {
			if ((Math.abs(mouseY - height * 0.5) > height) && _selectedStopper) {
				_waitingStopper = _selectedStopper;
				removeStopper(_selectedStopper);
			}
			else if (mouseX < width && mouseX > 0 && mouseY < height && mouseY > 0 && _waitingStopper) {
				insertStopper(_waitingStopper, mouseX / width);
				_waitingStopper.insideSelected(true, true, true);
				_waitingStopper.startDrag();
				_selectedStopper = _waitingStopper;
				_waitingStopper = null;
			}
		}
		
		private function selectHandler(e:C_Event):void {
			if (_selectedStopper) _selectedStopper.insideSelected(false, false);
			_selectedStopper = e.target as C_Stopper;
			_lastColor = _selectedStopper.picker.hexColor;
			_lastAlpha = _selectedStopper.alphaValue;
			dispatchEvent(new C_Event(C_Event.CHANGE_STATE));
		}
		
		private function completeHandler(e:C_Event):void {
			change(true, e.inside);
		}
		
		private function changeHandler(e:C_Event):void {
			change(false, e.inside);
		}
		
		private function mDownHandler(e:MouseEvent):void {
			if (!(e.target is C_Stopper)) {
				
				var pixelAlpha:Number = (e.shiftKey) ? (_gradientBitmapData.getPixel32(mouseX, 0) >> 24 & 0xFF) / 255: 1;
				var pixelRGB:uint = (e.shiftKey) ? _gradientBitmapData.getPixel(mouseX, 0) : _lastColor;
				
				var stopper:C_Stopper = newStopper(pixelRGB, pixelAlpha, mouseX / width);
				stopper.insideSelected(true, true);
				stopper.startDrag();
			}
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, stageMoveHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP, stageUpHandler);
		}
		
		private function resizeHandler(e:C_Event):void {
			if (e.data !== C_Box.HEIGHT) {
				setStoppersValue('refreshLocation', []);
				_changed = true;
			}
		}
		
		//---------------------------------------------------------
		//	S E T  /  G E T
		//---------------------------------------------------------
		
		
		public function get stopperSkin():C_Skin {
			return _stopperSkin;
		}
		
		public function set stopperSkin(value:C_Skin):void {
			_stopperSkin = value;
			setStoppersValue('sampleSkin', value);
		}
		
		public function get stopperArrow():BitmapData {
			return _stopperArrow;
		}
		
		public function set stopperArrow(value:BitmapData):void {
			_stopperArrow = value;
			setStoppersValue('stopperArrow', value);
			refreshHeight();
		}
		
		public function get gradientBitmapData():BitmapData {
			refreshData();
			return _gradientBitmapData;
		}
		
		public function get ratios():Array {
			refreshData();
			return _ratios;
		}
		
		public function get alphas():Array {
			refreshData();
			return _alphas;
		}
		
		public function get colors():Array {
			refreshData();
			return _colors;
		}
		
		public function get selectedStopper():C_Stopper {
			return _selectedStopper;
		}
		
		public function set selectedStopper(value:C_Stopper):void {
			if (_selectedStopper == value) return;
			value.insideSelected(true, false);
		}
		
		//---------------------------------------------------------
		//	P U B L I C
		//---------------------------------------------------------
		public function markChanged():void {
			_lastColor = _selectedStopper.picker.hexColor;
			_lastAlpha = _selectedStopper.alphaValue;
			_changed = true;
		}
		
		public function load(colors:Array, alphas:Array, ratios:Array):void {
			if (!colors || !alphas || !ratios || !((colors.length == alphas.length) && (colors.length == ratios.length))) return;

			var i:int = -1;
			var stopper:C_Stopper;
			
			while (++i < colors.length) {
				if (i < _stoppers.length) {
					stopper = _stoppers[i];
				}
				else {
					stopper = new C_Stopper();
					stopper.sampleWidth = _stopperWidth;
					stopper.sampleHeight = _stopperHeight;
					stopper.stopperArrow = _stopperArrow;
					stopper.sampleSkin = _stopperSkin;
					stopper.align = _align;
				}
				
				stopper.insideHex(colors[i], false, false, false);
				stopper.insideAlpha(alphas[i], false, false, false);
				insertStopper(stopper, ratios[i] / 255, false);
			}
			
			if (_stoppers.length > colors.length) {
				i = _stoppers.length;
				while (--i > colors.length - 1) {
					removeStopper(_stoppers[i], false);
				}
			}
			
			change(false, false);
			change(true, false);
			dispatchEvent(new C_Event(C_Event.CHANGE_STATE, null, false));
		}
		
		public function removeStopper(stopper:C_Stopper, dispatch:Boolean = true):void {
			if (!stopper) return;
			
			var index:int = _stoppers.indexOf(stopper);
			
			if (index > -1) {
				setStopperListeners(stopper, false);
				_stoppers.splice(index, 1);
				stopper.stopDrag();
				stopper.insideSelected(false, false, false);
				if (stopper.parent) stopper.parent.removeChild(stopper);
				if (_selectedStopper == stopper) _selectedStopper = null;
				
				if (dispatch) {
					change(false, true);
					change(true, true);
					dispatchEvent(new C_Event(C_Event.CHANGE_STATE));
				}
			}
		}
		
		public function insertStopper(stopper:C_Stopper, location:Number, dispatch:Boolean = true):void {
			if (_stoppers.indexOf(stopper) == -1) _stoppers.push(stopper);
			stopper.insideLocation(location, false, false);
			setStopperListeners(stopper, true);
			addChild(stopper);
			if (dispatch) {
				change(false, true);
				change(true, true);
			}
		}
		
		public function newStopper(color:uint, alpha:Number, location:Number, dispatch:Boolean = true):C_Stopper {
			var stopper:C_Stopper = new C_Stopper();
			stopper.insideHex(color, true, false);
			stopper.insideAlpha(alpha, true, false);
			stopper.sampleWidth = _stopperWidth;
			stopper.sampleHeight = _stopperHeight;
			stopper.stopperArrow = _stopperArrow;
			stopper.sampleSkin = _stopperSkin;
			stopper.align = _align;
			
			insertStopper(stopper, location, dispatch);
			
			return stopper;
		}
		
		//---------------------------------------------------------
		//	P R I V A T E
		//---------------------------------------------------------
		private function refreshData():void {
			if (!_changed) return;
			_changed = false;
			
			_stoppers.sortOn('location', Array.NUMERIC)

			var i:int = -1;
			var len:int = _stoppers.length;
		
			_colors.length = 0;
			_alphas.length = 0;
			_ratios.length = 0;
			
			while (++i < len) {
				_colors.push(_stoppers[i].picker.hexColor);
				_alphas.push(_stoppers[i].alphaValue);
				_ratios.push(_stoppers[i].location * 255);
			}
			
			refreshGradient();
		}
		
		private function refreshGradient():void {
			_gradientMatrix.createGradientBox(width, 1, 0, 0, 0);
			_gradientShape.graphics.clear();
			_gradientShape.graphics.beginGradientFill(GradientType.LINEAR, colors, alphas, ratios, _gradientMatrix);
			_gradientShape.graphics.drawRect(0, 0, width, 1);
			
			_gradientBitmapData.dispose();
			_gradientBitmapData = new BitmapData(Math.max(1, width), 1, true, 0);
			_gradientBitmapData.draw(_gradientShape);
		}
		
		private function setStopperListeners(target:C_Stopper, enabled:Boolean):void {
			if 	(enabled) {
				target.addEventListener(C_Event.CHANGE, changeHandler);
				target.addEventListener(C_Event.CHANGE_COMPLETE, completeHandler);
				target.addEventListener(C_Event.SELECT, selectHandler);
			}
			else {
				target.removeEventListener(C_Event.CHANGE, changeHandler);
				target.removeEventListener(C_Event.CHANGE_COMPLETE, completeHandler);
				target.removeEventListener(C_Event.SELECT, selectHandler);
			}
		}
		
		private function refreshHeight():void {
			height = _stopperHeight + ((_stopperArrow) ? _stopperArrow.height : 0);
		}
		
		private function setStoppersValue(method:String, value:*):void {
			var i:int = _stoppers.length;
			while (--i > -1) C_Accessor.setValue(_stoppers[i], method, value);
		}
		
		private function change(complete:Boolean, inside:Boolean):void {
			if (!complete) {
				_changed = true;
				if (_selectedStopper) {
					_lastColor = _selectedStopper.picker.hexColor;
					_lastAlpha = _selectedStopper.alphaValue;
				}
			}
			dispatchEvent(new C_Event((complete) ? C_Event.CHANGE_COMPLETE : C_Event.CHANGE, null, inside));
		}
	}

}