package drops.ui {
	import drops.core.C_SkinnableBox;
	import drops.data.C_Child;
	import drops.data.C_Description;
	import drops.data.C_Property;
	import drops.events.C_Event;
	import drops.utils.C_Text;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_TextArea extends C_SkinnableBox {

		private var _textField:TextField;
		private var _scrollBar:C_ScrollBar;
		
		public function C_TextArea() {
			width = 250;
			height = 100;
			
			_textField = C_Text.defineTF(null, null, C_Text.defineFormat(null, null, 'left'), null, true, true);
			_textField.wordWrap = true;
			addChild(_textField);
			
			_scrollBar = new C_ScrollBar();
			_scrollBar.orientation = 'y';
			addChild(_scrollBar);
			
			_scrollBar.addEventListener(C_Event.CHANGE, scrollChangeHandler);
			_textField.addEventListener(MouseEvent.MOUSE_WHEEL, mWheelHandler);
			
			addEventListener(C_Event.RESIZE, resizeHandler);
			
			refresh();
		}
		
		//------------------------------------------------------
		//	H A N D L E R S
		//------------------------------------------------------
		private function resizeHandler(e:Event):void {
			refresh();
		}
		
		private function mWheelHandler(e:MouseEvent):void {
			_scrollBar.scroll -= e.delta;
		}
		
		public function scrollChangeHandler(e:C_Event):void {
			if (e.inside) _textField.scrollV = _scrollBar.scroll + 1;
		}
		
		//------------------------------------------------------
		//	S E T  /  G E T
		//------------------------------------------------------
		public function get textField():TextField {
			return _textField;
		}
		
		public function get textFormat():TextFormat {
			return _textField.defaultTextFormat;
		}
		
		public function set textFormat(f:TextFormat):void {
			C_Text.defineTF(_textField, null, f);
			_scrollBar.all = _textField.numLines - 1;
			_scrollBar.shown = _textField.bottomScrollV - _textField.scrollV;
		}
		
		public function get scrollBar():C_ScrollBar {
			return _scrollBar;
		}
		
		public function set color(value:uint):void {
			
		}
		
		public function get text():String {
			return _textField.text;
		}
		
		public function set text(value:String):void {
			_textField.text = value;
			_scrollBar.all = _textField.numLines - 1;
			_scrollBar.shown = _textField.bottomScrollV - _textField.scrollV;
			refresh();
		}
		
		//------------------------------------------------------
		//	P U B L I C
		//------------------------------------------------------
		public function refresh():void {
			if (_textField.bottomScrollV == _textField.numLines) {
				_scrollBar.visible = false;
				_textField.width = width;
			}
			else {
				_scrollBar.x = int(width - _scrollBar.width);
				_scrollBar.height = height;
				_scrollBar.all = _textField.numLines - 1;
				_scrollBar.shown = _textField.bottomScrollV - _textField.scrollV;
				_scrollBar.visible = true;
				_textField.width = width - _scrollBar.width;
			}
			_textField.height = height;
		}
		
		
	}

}