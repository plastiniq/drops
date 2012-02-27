package drops.ui {
	import drops.core.C_Box;
	import drops.events.C_Event;
	import drops.graphics.DashedLine;
	import drops.graphics.Emb;
	import drops.utils.C_Mouse;
	import drops.utils.C_Text;
	import flash.display.Bitmap;
	import flash.display.CapsStyle;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class CxNumericInput extends C_Box {
		/*[Embed(source="skins/cursor_rows_h.png")]
		private static const EMB_CURSOR_ROWS_H:Class;
		private static const CURSOR_ROWS_H:BitmapData = (new EMB_CURSOR_ROWS_H() as Bitmap).bitmapData;*/
		
		private var _min:Number;
		private var _max:Number;
		private var _step:Number;
		private var _current:Number;
		private var _previous:Number;
		private var _previousStr:String;
		
		private var _suffix:C_Label;
		private var _suffixSpacing:Number;
		
		private var _input:TextField;
		private var _state:String;
		private var _isSlide:Boolean;
		private var _autoWidth:Boolean;
		private var _maxLabel:Number;
		private var _changed:Boolean;
		
		private var _startPoint:Point;
		private var _destPoint:Point;
		private var _startValue:Number;
		
		private var _textFormat:TextFormat;
	
		private var _mode:String;
		
		private var _holdColor:uint;
		
		private var _lockResize:Boolean;
		private var _lockCursor:Boolean;
		
		public static const INPUT:String = "input";
		public static const SCROLL:String = "scroll";
		
		public static const NUMBER:String = "number";
		public static const INTEGER:String = "rounded";
		public static const HEX_COLOR:String = "hexColor";
		
		private var _handCursor:String;
		
		public var data:*;
		
		public function CxNumericInput(min:Number = 0, max:Number = 100, step:Number = 1) {
			_min = min;
			_max = max;
			_step = step;
			_current = min;
			_previous = _current;
			_previousStr = String(_current);
			_holdColor = 0;
			_state = SCROLL;
			_mode = NUMBER;
			_autoWidth = true;
			_maxLabel = 0;
			_suffixSpacing = 3;
			_lockResize = false;
			
			_handCursor = this.name + '_handCursor';
			C_Mouse.registerCursor(_handCursor, new Bitmap(Emb.CURSOR_SMALL_HAND), new Point(3, 1));
			
			_startPoint = new Point();
			_destPoint = new Point();
			
			_textFormat = C_Text.defineFormat();
			
			_input = C_Text.defineTF(null, String(_current), _textFormat, new Rectangle(0, 0, 30, 0));
			addChild(_input);
			
			setScrollState();
			
			_input.addEventListener(MouseEvent.CLICK, inputClickHandler);
			_input.addEventListener(MouseEvent.MOUSE_DOWN, inputDownHandler);
			_input.addEventListener(FocusEvent.FOCUS_IN, inputFocusInHandler);
			_input.addEventListener(FocusEvent.FOCUS_OUT, inputFocusOutHandler);
			
			_input.addEventListener(MouseEvent.MOUSE_OVER, inputOverHandler);
			_input.addEventListener(MouseEvent.MOUSE_OUT, inputOutHandler);
			
			addEventListener(C_Event.CHANGE, changeHandler);
			addEventListener(C_Event.RESIZE, resizeHandler);
			
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			
			refreshInputWidth();
			refresh();
		}
		
		//---------------------------------------------------
		//	H A N D L E R S
		//---------------------------------------------------
		private function addedToStageHandler(e:Event):void {
			C_Mouse.stage = stage;
			removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}
		
		private function inputOverHandler(e:MouseEvent):void {
			if (_state === SCROLL) C_Mouse.cursor = _handCursor;
		}
		
		private function inputOutHandler(e:MouseEvent):void {
			if (!_lockCursor) C_Mouse.removeCursor(_handCursor);
		}
		
		private function resizeHandler(e:C_Event):void {
			if (!_lockResize) {
				refreshInputWidth();
				refresh();
			}
		}
		
		private function changeHandler(e:C_Event):void {
			if (e.inside) _changed = true;
		}
		
		private function keyUpHandler(e:KeyboardEvent):void {
			var str:String = _input.text.replace(/[\.\,бю]+/g, ".");
			_input.text = str.replace(/(\.[^\.]*)[\.]/g, "$1");

			var value:Number = (mode === HEX_COLOR) ? Number('0x' + _input.text) : Number(_input.text);
			
			if (isNaN(value)) {
				_input.text = _previousStr;
			}
			else {
				insideCurrent(value);
				_previousStr = _input.text;
			}
			
			if (e.charCode == 13) {
				insideCurrent(value, true);
				setScrollState();
			}
		}
		
		private function inputFocusInHandler(e:FocusEvent):void {
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, mWheelHandler);
		}
		
		private function inputFocusOutHandler(e:FocusEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_WHEEL, mWheelHandler);
		}

		private function inputClickHandler(e:MouseEvent):void {
			if (_isSlide == false) setInputState();
		}
		
		private function stageDownHandler(e:MouseEvent):void {
			if (!this.hitTestPoint(stage.mouseX, stage.mouseY)) {
				insideCurrent((mode === HEX_COLOR) ? Number('0x' + _input.text) : Number(_input.text), true);
				setScrollState();
				changeComplete();
			}
		}
		
		private function mWheelHandler(e:MouseEvent):void {
			insideCurrent(current + ((e.delta > 0) ? _step : -_step) * ((e.shiftKey) ? 10 : 1), true);
			_input.setSelection(0, _input.length);
		}
		
		private function stageMoveHandler(e:MouseEvent):void {
			_destPoint.x = mouseX;
			_destPoint.y = mouseY;
			
			if (!_isSlide && Point.distance(_startPoint, _destPoint) > 2) {
				_startPoint.x = mouseX;
				_startPoint.y = mouseY;
				_isSlide = true;
			}

			if (_isSlide) {
				var value:Number = (_destPoint.x - _startPoint.x) - (_destPoint.y - _startPoint.y);
				var step:Number = _step * ((e.shiftKey) ? 10 : 1)
				insideCurrent(_startValue + (value * step), true)
			}
		}
		
		private function stageUpHandler(e:MouseEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, stageMoveHandler);
			stage.removeEventListener(MouseEvent.MOUSE_UP, stageUpHandler);
			if (!_input.hitTestPoint(stage.mouseX, stage.mouseY)) {
				C_Mouse.removeCursor(_handCursor);
			}
			_lockCursor = false;
			changeComplete();
		}
		
		private function inputDownHandler(e:MouseEvent):void {
			if (_state == SCROLL) {
				_startPoint.x = mouseX;
				_startPoint.y = mouseY;
				_startValue = _current;
				stage.addEventListener(MouseEvent.MOUSE_MOVE, stageMoveHandler);
				stage.addEventListener(MouseEvent.MOUSE_UP, stageUpHandler);
				_isSlide = false;
				_lockCursor = true;
			}
		}
		
		//---------------------------------------------------
		//	S E T  /  G E T
		//---------------------------------------------------
		public function get textFormat():TextFormat {
			return _textFormat;
		}
		
		public function set textFormat(value:TextFormat):void {
			_input.setTextFormat(value);
			_input.defaultTextFormat = value;
			if (_suffix) _suffix.textFormat = value;
			_holdColor = (value.color) ? value.color as Number : 0x000000;
			_textFormat = value;
			refreshInputWidth();
			refresh();
		}
		
		public function get suffixLabel():C_Label {
			if (!_suffix) {
				_suffix = new C_Label();
				addChild(_suffix);
			}
			return _suffix;
		}
		
		public function get suffix():String {
			return (_suffix) ? _suffix.text : null;
		}
		
		public function set suffix(value:String):void {
			if (_suffix && _suffix.text == value) return;
			if (!_suffix) {
				_suffix = new C_Label(value);
				_suffix.textFormat = _textFormat;
				addChild(_suffix);
			}
			refreshInputWidth();
			refresh();
		}
		
		public function get step():Number {
			return _step;
		}
		
		public function set step(value:Number):void {
			if (value == _max) return;
			_step = value;
			refreshInputWidth();
			refresh();
			insideCurrent(Math.round(_current / _step) * _step, true, false);
		}
		
		public function get max():Number {
			return _max;
		}
		
		public function set max(value:Number):void {
			if (value == _max) return;
			_max = value;
			insideCurrent(_current, true, false);
			refreshInputWidth();
			refresh();
		}
		
		public function get min():Number {
			return _min;
		}
		
		public function set min(value:Number):void {
			if (value == _min) return;
			_min = value;
			insideCurrent(_current, true, false);
		}
		
		public function set autoWidth(value:Boolean):void {
			_autoWidth = value;
			refreshInputWidth();
			refresh();
		}

		public function get mode():String {
			return _mode;
		}
		
		public function set mode(value:String):void {
			if (_mode == value) return;
			_mode = value;
			refreshText();
			refreshInputWidth();
			refresh();
		}
		
		public function get current():Number {
			return _current;
		}

		public function set current(value:Number):void {
			insideCurrent(value, true, false);
		}
		
		//----------------------------------------------------
		//	O V E R R I D E
		//----------------------------------------------------
		override public function set height(value:Number):void { }
		
		//---------------------------------------------------
		//	P U B L I C
		//---------------------------------------------------
		public function refresh():void {
			_lockResize = true;

			width = _input.x + _input.width + ((_suffix) ? _suffixSpacing + _suffix.width : 0);
			height = _input.textHeight;
		
			alignSuffix();
			
			super.height = _input.height;
			drawUnderline();
			_lockResize = false;
		}
		
		//---------------------------------------------------
		//	P R I V A T E
		//---------------------------------------------------
		private function refreshInputWidth():void {
			var sizeRect:Rectangle = new Rectangle(0, 0, 0, -1);
			
			if (_autoWidth) {
				var maxNumber:Number = (_max === Infinity) ? 1000 : _max;
				var lenStr:String = new String();
				var zeros:int = 0;
				var len:int;
				
				if (_mode == NUMBER) {
					var afterPoint:int = 0;
					
					if (int(step) != step) {
						lenStr += '.';
						afterPoint = String(step - Math.floor(step)).length - 2;
					}
					
					zeros = (afterPoint > 0) ?  String(maxNumber - 1).length + afterPoint : String(maxNumber).length;
				}
				else if (_mode == HEX_COLOR) {
					zeros = toHEX(maxNumber).length
				}
				else {
					zeros = String(int(maxNumber)).length;
				}
				
				while (--zeros > -1) lenStr += '0';
				_input.text = lenStr;
				sizeRect.width = _input.textWidth + 7;
				setText(_current);
			}
			else {
				sizeRect.width = width - ((_suffix) ? _suffix.width + _suffixSpacing : 0);
			}
			C_Text.autoSize(_input, sizeRect);
		}
		
		public function insideCurrent(value:Number, refreshInput:Boolean = false, inside:Boolean = true, dispatch:Boolean = true ):void {
			if (isNaN(value)) {
				_current = _previous;
			}
			else {
				value = Math.max(_min, Math.min(value, _max));
				value = Math.round(value * Math.pow(10, 2)) / Math.pow(10, 2);
				if (value == _current) return;
				_current = value;
				_previous = _current;
				if (dispatch) dispatchEvent(new C_Event(C_Event.CHANGE, null, inside));
			}

			if (refreshInput) refreshText();
		}
		
		private function refreshText():void {
			setText(_current);
			refresh();
		}
		
		private function setText(value:Number):void {
			switch (_mode) {
				case NUMBER:	_input.text = String(value);		break;
				case INTEGER:	_input.text = String(int(value));	break;
				case HEX_COLOR:	_input.text = toHEX(value);			break;
				default:		_input.text = String(value);
			}
		}
		
		private function toHEX(value:Number):String {
			var str:String = int(value).toString(16);
			while (6 > str.length) str = '0' + str;
			return str;
		}
		
		private function alignSuffix():void {
			if (_suffix) {
				_suffix.x = ((_state == INPUT) ? _input.width : _input.textWidth) + _input.x + _suffixSpacing;
				_suffix.y = C_Text.baseLine(_input) - _suffix.baseline;
			}
		}
		
		public function setInputState():void {
			if (_state !== INPUT) {
				C_Text.defineTF(_input, null, C_Text.defineFormat(_input.defaultTextFormat, null, null, 0x000000), null, false, true);
				_input.border = true;
				_input.background = true;
				_input.type = TextFieldType.INPUT;
				
				if (_state == SCROLL) _input.setSelection(0, _input.length);
				
				//_input.addEventListener(MouseEvent.MOUSE_WHEEL, mWheelHandler);
				_input.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
				if (stage) stage.addEventListener(MouseEvent.MOUSE_DOWN, stageDownHandler);
				
				graphics.clear();
				
				_input.scrollH = 0;
				_state = INPUT;
				
				alignSuffix();
				
				C_Mouse.removeCursor(_handCursor);
			}
		}

		public function setScrollState():void {
			C_Text.defineTF(_input, null, C_Text.defineFormat(_input.defaultTextFormat, null, null, _holdColor), null, false, false);
			_input.border = false;
			_input.background = false;
			_input.setSelection(0, 0);
			_input.type = TextFieldType.DYNAMIC;
			
			//_input.removeEventListener(MouseEvent.MOUSE_WHEEL, mWheelHandler);
			_input.removeEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
			if (stage) stage.removeEventListener(MouseEvent.MOUSE_DOWN, stageDownHandler);
			drawUnderline();
			
			_input.scrollH = 0;
			_state = SCROLL;
			
			alignSuffix();
			
			if (stage && _input.hitTestPoint(stage.mouseX, stage.mouseY)) {
				C_Mouse.cursor = _handCursor;
			}
		}
		
		private function changeComplete():void {
			if (_changed) {
				dispatchEvent(new C_Event(C_Event.CHANGE_COMPLETE, null, true));
				_changed = false;
			}
		}
		
		private function drawUnderline(dashLength:int = 1, spaceLength:int = 2):void {
			graphics.clear();
			DashedLine.beginDraw(_holdColor, 1, 1, dashLength, spaceLength);
			DashedLine.moveTo(Math.round(_input.x) + 2, int(C_Text.baseLine(_input)) + 2);
			DashedLine.lineTo(Math.round(_input.x) + _input.textWidth + 2, int(C_Text.baseLine(_input)) + 2, this.graphics);
		}
	}

}