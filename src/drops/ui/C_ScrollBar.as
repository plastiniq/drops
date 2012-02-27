package drops.ui {
	import drops.core.C_Box;
	import drops.data.C_Background;
	import drops.data.C_Description;
	import drops.data.C_Property;
	import drops.data.C_Shape;
	import drops.data.C_SkinFrame;
	import drops.data.C_SkinState;
	import drops.events.C_Event;
	import drops.graphics.Emb;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_ScrollBar extends C_Box {
		private var _thickness:Number;
		private var _length:Number;
		private var _buttonsLength:Number;
		private var _minPointerLength:Number;
		
		private var _all:int;
		private var _shown:int;
		
		private var _scroll:int;
		private var _overScroll:int;
		
		private var _firstBtn:C_Button;
		private var _lastBtn:C_Button;
		
		private var _track:Sprite;
		private var _bg:C_Button;
		private var _pointer:C_Button;

		private var _startScroll:Number;
		private var _startMouse:Number;
		
		private var _timer:Timer;
		private var _downButton:String;
		
		private var _step:Number;
		
		private var _axis:String;
		public static const X:String = "x";
		public static const Y:String = "y";
		
		public static const FIRST:String = "first";
		public static const LAST:String = "last";
		public static const TRACK_UP:String = "trackUp";
		public static const TRACK_DOWN:String = "trackDown";

		public function C_ScrollBar(all:int = 100, shown:int = 20) {
			_all = all;
			_shown = shown;
			
			_axis = X;
			
			_thickness = this[thickProp] = 9;
			_length = this[lengthProp] = 100;
			_buttonsLength = 0;
			_minPointerLength = 20;
			
			_step = 1;

			_firstBtn = new C_Button();
			//_firstBtn.skin.background = new C_Background(Emb.SCROLLBAR_TOP, null, new Rectangle(2, 3, 14, 16));
			//_firstBtn.icon = Emb.SCROLLBAR_ICON_TOP;
			addChild(_firstBtn);
			
			_lastBtn = new C_Button();
			//_lastBtn.skin.background = new C_Background(Emb.SCROLLBAR_BOTTOM, null, new Rectangle(2, 3, 14, 16));
			//_lastBtn.icon = Emb.SCROLLBAR_ICON_BOTTOM;
			addChild(_lastBtn);
		
			_bg = new C_Button();
			_bg.skin.background = new C_Background();
			//_bg.skin.background = new C_Background(Emb.SCROLLBAR_TRACK, null, new Rectangle(4, 6, 13, 7));
			
			_pointer = new C_Button();
			_pointer.skin.background = new C_Background(null, null, null, C_Shape.RECTANGLE, 0x4f3c66, 0.79);
			//_pointer.skin.background.setRoundness(5, 5, 5, 5);
			//_pointer.skin.background = new C_Background(Emb.SCROLLBAR_POINTER, null, new Rectangle(2, 3, 14, 16));
			//_pointer.icon = Emb.SCROLLBAR_ICON_POINTER;
			
			_track = new Sprite();
			addChild(_track)
			_track.addChild(_bg);
			_track.addChild(_pointer);
			
			_timer = new Timer(700, 0);
			_timer.addEventListener(TimerEvent.TIMER, timerHandler);
			
			_firstBtn.addEventListener(MouseEvent.MOUSE_DOWN, firstDownHandler);
			_lastBtn.addEventListener(MouseEvent.MOUSE_DOWN, lastDownHandler);
			
			_bg.addEventListener(MouseEvent.MOUSE_DOWN, bgDownHandler);
			_pointer.addEventListener(MouseEvent.MOUSE_DOWN, pointerDownHandler);
			addEventListener(MouseEvent.MOUSE_WHEEL, wheelHandler);
			addEventListener(C_Event.RESIZE, resizeHandler);
			
			refresh();
		}
		
		//----------------------------------------------------
		//	H A N D L E R S
		//----------------------------------------------------
		private function resizeHandler(e:C_Event):void {
			_thickness = this[thickProp];
			_length = this[lengthProp];
			refresh();
		}
		
		private function wheelHandler(e:MouseEvent):void {
			insideScroll((e.delta > 0) ? _scroll - _step : _scroll + _step);
		}
		
		private function timerHandler(e:TimerEvent):void {
			_timer.delay = Math.min(100, Math.max(1, _timer.delay - 5));
			
			switch (_downButton) { 
				case FIRST:			insideScroll(_scroll - _step);		break; 
				case LAST:			insideScroll(_scroll + _step);		break; 
				case TRACK_UP:		insideScroll(_scroll - _shown);	break; 
				case TRACK_DOWN:	insideScroll(_scroll + _shown);	break; 
				default:			break; 
			}
		}
		
		private function lastDownHandler(e:MouseEvent):void {
			insideScroll(_scroll + _step);
			_downButton = LAST;
			stage.addEventListener(MouseEvent.MOUSE_UP, stageUpHandler);
			_timer.start();
		}
		
		private function firstDownHandler(e:MouseEvent):void {
			insideScroll(_scroll - _step);
			_downButton = FIRST;
			stage.addEventListener(MouseEvent.MOUSE_UP, stageUpHandler);
			_timer.start();
		}
		
		private function stageMoveHandler(e:MouseEvent):void {
			insideScroll((_startScroll + (((stage[mouseProp] - _startMouse) / bgLength) * _all)));
		}
		
		private function stageUpHandler(e:MouseEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_UP, stageUpHandler);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, stageMoveHandler);
			_downButton = null;
			_timer.stop();
			_timer.delay = 700;
		}
		
		private function pointerDownHandler(e:MouseEvent):void {
			stage.addEventListener(MouseEvent.MOUSE_UP, stageUpHandler);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, stageMoveHandler);
			_startScroll = _scroll;
			_startMouse = stage[mouseProp];
		}
		
		private function bgDownHandler(e:MouseEvent):void {
			stage.addEventListener(MouseEvent.MOUSE_UP, stageUpHandler);
			if (_bg[mouseProp] > _pointer[_axis]) {
				insideScroll(_scroll + _shown);
				_downButton = TRACK_DOWN;
			}
			else {
				insideScroll(_scroll - _shown);
				_downButton = TRACK_UP;
			}
			_timer.start();
		}
		
		//----------------------------------------------------
		//	S E T  /  G E T
		//----------------------------------------------------
		public function get step():Number {
			return _step;
		}
		
		public function set step(value:Number):void {
			if (value > 0) _step = value;
		}
		
		public function get pointer():C_Button {
			return _pointer;
		}
		
		public function get track():C_Button {
			return _bg;
		}
		
		public function get lastButton():C_Button {
			return _lastBtn;
		}
		
		public function get firstButton():C_Button {
			return _firstBtn;
		}

		public function get shown():int {
			return _shown;
		}
		
		public function set shown(value:int):void {
			_shown = value;
			refresh();
		}
		
		public function get all():int {
			return _all;
		}
		
		public function set all(value:int):void {
			_all = value;
			refresh();
		}
		
		public function get thickness():Number {
			return _thickness;
		}
		
		public function set thickness(value:Number):void {
			_thickness = value;
			refresh();
		}
		
		public function get length():Number {
			return _length;
		}
		
		public function set length(value:Number):void {
			_length = value;
			refresh();
		}
		
		public function get buttonsLength():Number {
			return _buttonsLength;
		}
		
		public function set buttonsLength(value:Number):void {
			_buttonsLength = value;
			refresh();
		}
		
		public function set orientation(value:String):void {
			if (value == X || value == Y) {
				_axis = value;
				var rect:Rectangle = new Rectangle();
				rect[thickProp] = _thickness;
				rect[lengthProp] = _length;
				setSize(rect.width, rect.height);
			}
		}
		
		public function get overScroll():int {
			return _overScroll;
		}
		
		public function get scroll():int {
			return _scroll;
		}
		
		public function set scroll(value:int):void {
			insideScroll(value, false);
		}
		
		//--------------------------------------------
		//	O V E R R I D E D
		//--------------------------------------------
		/*override public function get width():Number {
			return this[widthProp];
		}
		
		override public function set width(value:Number):void {
			if (this[widthProp] != value) {
				this[widthProp] = value;
				refresh();
			}
		}
		
		override public function get height():Number {
			return this[heightProp];
		}
		
		override public function set height(value:Number):void {
			if (this[heightProp] != value) {
				this[heightProp] = value;
				refresh();
			}
		}*/
		
		//----------------------------------------------------
		//	P U B L I C
		//----------------------------------------------------
		public function refresh():void {
			_firstBtn[lengthProp] = _buttonsLength;
			_firstBtn[thickProp] = _thickness;
			
			_bg[lengthProp] = _length - (_buttonsLength * 2);
			_bg[thickProp] = _thickness;
			_track[_axis] = _buttonsLength;
			_track[antiAxis] = 0;
			
			_pointer[thickProp] = _thickness;
			_pointer[lengthProp] = Math.round(Math.max(_minPointerLength, (_shown / _all) * _bg[lengthProp]));
			_pointer[antiAxis] = 0;
			
			_lastBtn[lengthProp] = _buttonsLength;
			_lastBtn[thickProp] = _thickness;
			_lastBtn[_axis] = _length - _buttonsLength;
			_lastBtn[antiAxis] = 0;
			
			updatePointer();
		}
		
		//----------------------------------------------------
		//	P R I V A T E
		//----------------------------------------------------
		private function updatePointer():void {
			_pointer[_axis] = Math.round(bgLength * (_scroll / _all));
		}
		
		private function insideScroll(value:int, inside:Boolean = true, updatePointer:Boolean = true):void {
			if (value == _scroll) return;
			
			_overScroll = value;
			_scroll = Math.max(0, Math.min(_all - _shown, value));
			if (updatePointer) this.updatePointer();
			dispatchEvent(new C_Event(C_Event.CHANGE, null, inside));
		
		}
		
		private function get bgLength():Number {
			return _bg[lengthProp] - Math.max(0, _minPointerLength - ((_shown / _all) * _bg[lengthProp]));
		}
		
		private function get antiAxis():String {
			return (_axis == X) ? 'y' : 'x';
		}
		
		private function get thickProp():String {
			return (_axis == X) ? 'height' : 'width';
		}
		
		private function get mouseProp():String {
			return (_axis == X) ? 'mouseX' : 'mouseY';
		}
		
		private function get widthProp():String {
			return (_axis == X) ? 'length' : 'thickness';
		}
		
		private function get heightProp():String {
			return (_axis == X) ? 'thickness' : 'length';
		}
		
		private function get lengthProp():String {
			return (_axis == X) ? 'width' : 'height';
		}
	}

}