package drops.core {
	import drops.data.C_Description;
	import drops.data.C_Property;
	import drops.events.C_Event;
	import drops.ui.C_ScrollBar;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_ScrollableArea extends C_SkinnableBox {
		private var _xScroll:C_ScrollBar;
		private var _yScroll:C_ScrollBar;
		
		private var _xScrollEnabled:Boolean;
		private var _yScrollEnabled:Boolean;
		
		private var _smoothScroll:Boolean;
		private var _smoothTime:Number;
		
		private var _content:C_Box;
		private var _contentBounds:Rectangle;
		
		private var _mask:Shape;
		
		private var _exceptions:Array;
		
		private var _padding:Number;
		
		private var _overflow:String;
		public static const VISIBLE:String = "visible";
		public static const HIDDEN:String = "hidden";
		public static const SCROLL:String = "scroll";

		public function C_ScrollableArea() {
			_overflow = VISIBLE;
			_smoothScroll = false;
			_smoothTime = 0.12;

			_xScrollEnabled = true;
			_yScrollEnabled = true;
			
			_padding = 0;
			
			_content = new C_Box();
			super.addChild(_content);
			
			_xScroll = new C_ScrollBar();
			_xScroll.step = 10;
			_xScroll.orientation = C_ScrollBar.X;
			super.addChild(_xScroll);
			
			_yScroll = new C_ScrollBar();
			_yScroll.step = 10;
			_yScroll.orientation = C_ScrollBar.Y;
			super.addChild(_yScroll);
			
			_mask = new Shape();
			_mask.visible =  false;
			_mask.graphics.beginFill(0);
			_mask.graphics.drawRect(0, 0, 10, 10);
			super.addChild(_mask);
			
			_contentBounds = new Rectangle();
			
			_xScroll.addEventListener(C_Event.CHANGE, xScrollHandler);
			_yScroll.addEventListener(C_Event.CHANGE, yScrollHandler);
			addEventListener(C_Event.RESIZE, resizeHandler);
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}
		
		//-----------------------------------------------
		//	H A N D L E R S 
		//-----------------------------------------------
		private function addedToStageHandler(e:Event):void {
			refresh();
		}
		
		private function resizeHandler(e:Event):void {
			refresh();
		}
		
		private function yScrollHandler(e:C_Event):void {
			_content.y = -_yScroll.scroll - Math.min(0, _contentBounds.y);
		}
		
		private function xScrollHandler(e:C_Event):void {
			_content.x = -_xScroll.scroll - Math.min(0, _contentBounds.x);
		}
		
		//-----------------------------------------------
		//	O V E R R I D E D
		//-----------------------------------------------
		override public function addChildAt(child:DisplayObject, index:int):DisplayObject {
			_content.addChildAt(child, index);
			
			var bounds:Rectangle = _content.contentBounds;
			content.width = bounds.width;
			content.height = bounds.height;
			
			refresh();
			return child;
		}
		
		override public function addChild(child:DisplayObject):DisplayObject {
			_content.addChild(child);
			
			var bounds:Rectangle = _content.contentBounds;
			content.width = bounds.width;
			content.height = bounds.height;
			
			refresh();
			return child;
		}
		
		//-----------------------------------------------
		//	S E T  /  G E T
		//-----------------------------------------------
		public function get yScrollEnabled():Boolean {
			return _yScrollEnabled;
		}
		
		public function set yScrollEnabled(value:Boolean):void {
			if (_yScrollEnabled != value) {
				_yScrollEnabled = value;
				_yScroll.visible = value;
			}
		}
		
		public function get xScrollEnabled():Boolean {
			return _xScrollEnabled;
		}
		
		public function set xScrollEnabled(value:Boolean):void {
			if (_xScrollEnabled != value) {
				_xScrollEnabled = value;
				_xScroll.visible = value;
			}
		}
		
		public function get smoothScroll():Boolean {
			return _smoothScroll;
		}
		
		public function set smoothScroll(value:Boolean):void {
			_smoothScroll = value;
		}
		
		public function get visibleArea():Rectangle {
			return new Rectangle(0, 0, width - ((_yScroll.visible) ? _yScroll.width : 0), height - ((_xScroll.visible) ? _xScroll.height : 0));
		}
		
		public function get yScrollbar():C_ScrollBar {
			return _yScroll;
		}
		
		public function get xScrollbar():C_ScrollBar {
			return _xScroll;
		}
		
		public function get overflow():String {
			return _overflow;
		}
		
		public function set overflow(value:String):void {
			if (_overflow != value) {
				_overflow = value;
				refresh();
			}
		}
		
		public function get content():C_Box {
			return _content;
		}
		
		public function get exceptions():Array {
			return _exceptions;
		}
		
		public function set exceptions(value:Array):void {
			if (value === _exceptions) return;
			_exceptions = value;
			refresh();
		}
		
		public function get padding():Number {
			return _padding;
		}
		
		public function set padding(value:Number):void {
			if (_padding == value) return;
			_padding = value;
			refresh();
		}
		
		//-----------------------------------------------
		//	P U B L I C
		//-----------------------------------------------
		public function refresh():void {
			_contentBounds = getContentBounds();
			var visibleW:Number = width;
			var visibleH:Number = height;

			if (_overflow == VISIBLE) {
				_content.mask = null;
				removeXScroll();
				removeYScroll();
				_content.x = 0;
				_content.y = 0;
				_content.setSize(width, height);
			}
			else {
				if (!_content.mask) _content.mask = _mask;
				
				visibleW = (_contentBounds.height > height && _yScrollEnabled) ? width - _yScroll.width - _padding : width;
				visibleH = (_contentBounds.width > width && _xScrollEnabled) ? height - _xScroll.height - _padding : height;
				
				_content.width = visibleW;
				_content.height = visibleH;

				if (_overflow == HIDDEN) {
					_mask.width = width;
					_mask.height = height;
					removeXScroll();
					removeYScroll();
				}
				else if (_overflow == SCROLL) {
					_contentBounds = getContentBounds();
					_mask.width = visibleW;
					_mask.height = visibleH;

					var overW:Boolean = Boolean(_contentBounds.width > visibleW);
					var overH:Boolean = Boolean(_contentBounds.height > visibleH);
	
					if (overH && _yScrollEnabled) {
						_yScroll.x = width - _yScroll.width;
						_yScroll.height = (overW && _xScrollEnabled) ? height - _xScroll.height : height;
						_yScroll.all = _contentBounds.bottom - Math.min(0, _contentBounds.y);
						_yScroll.shown = visibleH;
						_yScroll.scroll = Math.min((_yScroll.all - visibleH), -_content.y - Math.min(0, _contentBounds.y));
						addYScroll();
						_yScroll.y = 0;
					}
					else {
						removeYScroll();
						_content.y = 0;
					}
					if (overW && _xScrollEnabled) {
						_xScroll.y = height - _xScroll.height;
						_xScroll.width = (overH && _yScrollEnabled) ? width - _yScroll.width : width;
						_xScroll.all = _contentBounds.right - Math.min(0, _contentBounds.x);
						_xScroll.shown = visibleW;
						_xScroll.scroll = Math.min((_xScroll.all - visibleW), -_content.x - Math.min(0, _contentBounds.x));
						addXScroll();
						_xScroll.x = 0;
					}
					else {
						removeXScroll();
						_content.x = 0;
					}
				}
			}
		}
		
		//-----------------------------------------------
		//	P R I V A T E
		//-----------------------------------------------
		private function removeXScroll():void {
			if (_xScroll.parent) _xScroll.parent.removeChild(_xScroll);
		}
		
		private function removeYScroll():void {
			if (_yScroll.parent) _yScroll.parent.removeChild(_yScroll);
		}
		
		private function addXScroll():void {
			if (_xScroll.parent != this) super.addChild(_xScroll);
		}
		
		private function addYScroll():void {
			if (_yScroll.parent != this) super.addChild(_yScroll);
		}
		
		private function getContentBounds():Rectangle {
			if (!_exceptions || !_exceptions.length) return _content.contentBounds;
			
			var totalBounds:Rectangle;
			var childBounds:Rectangle;
			var child:DisplayObject;
			var i:int = _content.numChildren;
			while (--i > -1) {
				child = _content.getChildAt(i);
				if (_exceptions.indexOf(child) < 0) {
					childBounds = child.getBounds(_content);
					if (!totalBounds) {
						totalBounds = childBounds;
					}
					else {
						totalBounds = totalBounds.union(childBounds);
					}
				}
			}
			return (totalBounds) ? totalBounds : new Rectangle();
		}
	}

}