package drops.ui {
	import drops.core.C_Box;
	import drops.core.C_SkinnableBox;
	import drops.data.C_Description;
	import drops.data.C_Property;
	import drops.data.C_Skin;
	import drops.data.C_SkinFrame;
	import drops.data.C_SkinState;
	import drops.events.C_Event;
	import drops.utils.C_Display;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_Slider extends C_Box {
		private var _min:Number;
		private var _max:Number;
		private var _step:Number;
		private var _current:Number;
		private var _startGab:Number;
		private var _endGab:Number;
			
		private var _track:C_SkinnableBox;
		private var _progressTrack:C_SkinnableBox;
		private var _pointer:C_Button;
		
		private var _bg:Shape;
		
		private var _spacing:Number;
		private var _input:CxNumericInput;
		private var _inputOffsetY:Number;
		
		private var _changed:Boolean;
		private var _mouseOffset:Number;
		
		private var _progressMask:Shape;
		
		private var _mode:String;
		public static const SCALED:String = "scaled";
		public static const MASK:String = "mask";
		
		public static var description:C_Description = new C_Description();
		description.pushGroup('Position and Size', 2);
		description.lastGroup.pushProperty(C_Property.NUMBER, 'x', 'X');
		description.lastGroup.pushProperty(C_Property.NUMBER, 'y', 'Y');
		description.lastGroup.pushProperty(C_Property.NUMBER, 'width', 'Width');
		description.lastGroup.pushProperty(C_Property.NUMBER, 'height', 'Height');
		description.pushGroup('Mounts');
		description.lastGroup.pushProperty(C_Property.MOUNTS, 'mounts');
		description.pushGroup('Values');
		description.lastGroup.pushProperty(C_Property.NUMBER, 'current', 'Progress');
		description.lastGroup.pushProperty(C_Property.NUMBER, 'startGab', 'Left Gab');
		description.lastGroup.pushProperty(C_Property.NUMBER, 'endGab', 'Right Gab');
		description.pushGroup('Pointer');
		description.lastGroup.pushProperty(C_Property.NUMBER, 'pointerOffsetY', 'Offset Y', null);
		description.lastGroup.pushProperty(C_Property.NUMBER, 'pointerWidth', 'Width', null);
		description.lastGroup.pushProperty(C_Property.NUMBER, 'pointerHeight', 'Height', null);

		description.pushGroup('Track Skin');
		description.lastGroup.pushProperty(C_Property.SKIN, 'skin', null, null, 'track');
		description.lastProperty.addOption('Normal Skin', C_SkinState.NORMAL);
		description.pushGroup('Progress Skin');
		description.lastGroup.pushProperty(C_Property.SKIN, 'skin', null, null, 'progressTrack');
		description.lastProperty.addOption('Normal Skin', C_SkinState.NORMAL);
		description.pushGroup('Pointer Skin');
		description.lastGroup.pushProperty(C_Property.SKIN, 'skin', null, null, 'pointer');
		description.lastProperty.addOption('Normal Skin', C_SkinState.NORMAL);
		description.lastProperty.addOption('Mouse Over Skin', C_SkinState.MOUSE_OVER);
		description.lastProperty.addOption('Mouse Down Skin', C_SkinState.MOUSE_DOWN);
		
		public function C_Slider() {
			_min = 0;
			_max = 100;
			_step = 1;
			_current = _min;
			_startGab = 0;
			_endGab = 0;
			_spacing = 2;
			_inputOffsetY = 0;
			_mode = SCALED;
			
			width = 100;
			
			_bg = new Shape();
			_bg.graphics.beginFill(0, 0);
			_bg.graphics.drawRect(0, 0, 100, 100);
			addChild(_bg);
			
			_track = new C_SkinnableBox();
			_track.top = 0;
			_track.bottom = 0;
			_track.left = 0;
			_track.right = 0;
			addChild(_track);
			
			_progressTrack = new C_SkinnableBox();
			_progressTrack.skin = new C_Skin(null, null, null, 0xFF0000);
			_progressTrack.skin.background.fillAlpha = 0.5;
			_progressTrack.top = 0;
			_progressTrack.bottom = 0;
			_progressTrack.left = 0;
			_track.addChild(_progressTrack);
			
			_pointer = new C_Button();
			addChild(_pointer);
			
			_input = new CxNumericInput(_min, _max);
			_input.visible = false;
			_input.right = 0;
			addChild(_input);
		
			addEventListener(MouseEvent.MOUSE_DOWN, mDownHandler);
			addEventListener(C_Event.RESIZE, resizeHandler);
			_pointer.addEventListener(C_Event.RESIZE, pointerResizeHandler);
			_input.addEventListener(C_Event.CHANGE, inputChangeHandler);
			_input.addEventListener(C_Event.CHANGE_COMPLETE, inputCompleteHandler);
			_input.addEventListener(C_Event.RESIZE, inputResizeHandler);

			refresh();
		}
		
		//--------------------------------------------------------
		//	H A N D L E R S
		//--------------------------------------------------------
		private function inputResizeHandler(e:C_Event):void {
			if (e.data !== C_Box.HEIGHT) {
				refresh();
			}
		}
		
		private function inputCompleteHandler(e:C_Event):void {
			if (e.inside) change(true, e.inside);
		}
		
		private function inputChangeHandler(e:C_Event):void {
			if (e.inside) {
				insideCurrent(_input.current, true, e.inside, false);
			}
		}
		
		private function pointerResizeHandler(e:C_Event):void {
			refresh();
		}
		
		private function resizeHandler(e:Event):void {
			refresh();
		}
		
		private function mUpHandler(e:MouseEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, stageMoveHandler);
			stage.removeEventListener(MouseEvent.MOUSE_UP, mUpHandler);
			if (_changed) {
				change(true, true);
				_changed = false;
			}
		}
		
		private function mDownHandler(e:MouseEvent):void {
			if (_input.contains(e.target as DisplayObject)) return;
			
			if (e.target == _pointer) {
				_mouseOffset = _pointer.mouseX - (_pointer.width * 0.5);
			}
			else {
				_mouseOffset = 0;
				mouseToCurrent(_track.mouseX - _mouseOffset, _track.mouseY);
			}
			stage.addEventListener(MouseEvent.MOUSE_MOVE, stageMoveHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP, mUpHandler);
		}
		
		private function stageMoveHandler(e:MouseEvent):void {
			mouseToCurrent(_track.mouseX - _mouseOffset, _track.mouseY);
		}
		
		//--------------------------------------------------------
		//	S E T  /  G E T
		//--------------------------------------------------------
		public function get mode():String {
			return _mode;
		}
		
		public function set mode(value:String):void {
			if (value == _mode) return;
			
			if (value == MASK && !_progressMask) {
				_progressMask = new Shape();
				_progressMask.graphics.beginFill(0, 1);
				_progressMask.graphics.drawRect(0, 0, 10, 10);
				_progressMask.visible = false;
				addChild(_progressMask);
			}
			
			_mode = value;
			refresh();
		}
		
		public function get trackWidth():Number {
			return _track.width;
		}
		
		public function set trackWidth(value:Number):void {
			if (value == _track.width) return;
			width = value + _spacing + ((_input.visible) ? _input.width : 0);
		}
		
		public function get inputWidth():Number {
			return _input.width;
		}
		
		public function set inputWidth(value:Number):void {
			_input.width = value;
		}
		
		public function get inputOffsetY():Number {
			return _inputOffsetY;
		}
		
		public function set inputOffsetY(value:Number):void {
			if (_inputOffsetY == value) return;
			_inputOffsetY = value;
			refresh();
		}
		
		public function get spacing():Number {
			return _spacing;
		}
		
		public function set spacing(value:Number):void {
			if (_spacing == value) return;
			_spacing = value;
			refresh();
		}
		
		public function get input():CxNumericInput {
			return _input;
		}
		
		public function get inputEnabled():Boolean {
			return _input.visible;
		}
		
		public function set inputEnabled(value:Boolean):void {
			if (value == _input.visible) return;
			_input.visible = value;
			_input.current = _current;
			_input.mode = (Math.round(_step) == _step) ? CxNumericInput.INPUT : CxNumericInput.NUMBER;
			refresh();
		}
		
		public function get pointerHeight():Number {
			return _pointer.height;
		}
		
		public function set pointerHeight(value:Number):void {
			_pointer.height = value;
		}
		
		public function get pointerWidth():Number {
			return _pointer.width;
		}
		
		public function set pointerWidth(value:Number):void {
			_pointer.width = value;
		}
		
		public function get pointerOffsetY():Number {
			return _pointer.y;
		}
		
		public function set pointerOffsetY(value:Number):void {
			_pointer.y = value;
			refresh();
		}
		
		public function get step():Number {
			return _step;
		}
		
		public function set step(value:Number):void {
			if (_step != value) {
				_step = value;
				_input.mode = (Math.round(_step) == _step) ? CxNumericInput.INTEGER : CxNumericInput.NUMBER;
				_input.step = value;
				refresh();
			}
		}
		
		public function get max():Number {
			return _max;
		}
		
		public function set max(value:Number):void {
			if (_max != value && value > _min) {
				_max = value;
				_input.max = value;
				_current = Math.min(value, _current);
				refresh();
			}
		}
		
		public function get min():Number {
			return _min;
		}
		
		public function set min(value:Number):void {
			if (_min != value && value < _max) {
				_min = value;
				_input.min = value;
				_current = Math.max(value, _current);
				refresh();
			}
		}
		
		public function set progressTrackVisible(value:Boolean):void {
			if (value != _progressTrack.visible) {
				_progressTrack.visible = value;
				if (value) refresh();
			}
		}
		
		public function get progressTrack():C_SkinnableBox {
			return _progressTrack;
		}
		
		public function get pointer():C_SkinnableBox {
			return _pointer;
		}
		
		public function get track():C_SkinnableBox {
			return _track;
		}
		
		public function get endGab():Number {
			return _endGab;
		}
		
		public function set endGab(value:Number):void {
			_endGab = value;
			refresh();
		}
		
		public function get startGab():Number {
			return _startGab;
		}
		
		public function set startGab(value:Number):void {
			_startGab = value;
			refresh();
		}
		
		public function get current():Number {
			return _current;
		}
		
		public function set current(value:Number):void {
			insideCurrent(value, true, false, true);
		}
		
		//--------------------------------------------------------
		//	O V E R R I D E
		//--------------------------------------------------------
		override public function getBounds(targetCoordinateSpace:DisplayObject):Rectangle {
			var rect:Rectangle = new Rectangle(0, Math.min(_track.y, _pointer.y), width, 0);
			rect.height = Math.max(_track.y + _track.height, _pointer.y + _pointer.height) - rect.y;
			return C_Display.rectToSpace(this, targetCoordinateSpace, rect);
		}
		
		//--------------------------------------------------------
		//	P U B L I C
		//--------------------------------------------------------
		public function refresh():void {
			_track.right = (_input.visible) ? _input.width + _spacing : 0;
			_input.y = Math.round((track.height - _input.height) * 0.5) + inputOffsetY;
			//_pointer.x = Math.round(( -_startGab) + ((_current / (_max - _min)) * (_track.width + _startGab + _endGab - _pointer.width)));
			_pointer.x = Math.round(( -_startGab) + (((_current - _min) / (_max - _min)) * (_track.width + _startGab + _endGab - _pointer.width)));
			
			if (_progressTrack.visible) {
				if (_mode == SCALED) {
					_progressTrack.width = _pointer.x + (_pointer.width * 0.5);
					_progressTrack.mask = null;
				}
				else {
					_progressTrack.width = width;
					_progressMask.width = _pointer.x + (_pointer.width * 0.5);
					_progressMask.height = height;
					_progressTrack.mask = _progressMask;
				}
			}
			
			var rect:Rectangle = getBounds(this);
			_bg.x = rect.x;
			_bg.y = rect.y;
			_bg.width = rect.width;
			_bg.height = rect.height;
		}
		
		public function insideCurrent(value:Number, dispatch:Boolean, inside:Boolean = false, complete:Boolean = false):void {
			value = Math.max(_min, Math.min(_max, Math.round(value / _step) * _step));
			if (value == _current) {
				if (dispatch && complete) change(true, inside);
				return;
			}
			
			_current = value;
			_changed = true;
			if (_input.visible) _input.current = _current;
			refresh();
			
			if (dispatch) {
				change(false, inside);
				if (complete) change(true, inside);
			}
		}
		
		//--------------------------------------------------------
		//	P R I V A T E
		//--------------------------------------------------------
		private function mouseToCurrent(x:Number, y:Number):void {
			x += _startGab - (_pointer.width * 0.5);
			insideCurrent(((x / (_track.width - _pointer.width + _startGab + _endGab)) * (_max - _min)) + _min, true, true, false);
			refresh();
		}
		
		private function change(complete:Boolean, inside:Boolean):void {
			dispatchEvent(new C_Event((complete) ? C_Event.CHANGE_COMPLETE : C_Event.CHANGE, null, inside));
		}

	}

}