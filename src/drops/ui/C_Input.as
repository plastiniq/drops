package drops.ui {
	import drops.core.C_SkinnableBox;
	import drops.data.C_Description;
	import drops.data.C_SkinState;
	import drops.events.C_Event;
	import drops.data.C_Property;
	import drops.utils.C_Text;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_Input extends C_SkinnableBox {
		private var _padding:Number;
		private var _autoSizeRect:Rectangle;
		
		private var _autoFontSize:Boolean;
		
		private var _input:TextField;
		
		private var _icon:Bitmap;
		private var _changed:Boolean;
		
		private var _startSelection:int;
		
		private var _fieldOffsetY:Number;
		
		//private var _endSelection:int;

		
		private var _iconAlign:String;
		public static const CENTER:String = 'center';
		public static const TOP:String = 'top';
		public static const BOTTOM:String = 'bottom';
		public static const LEFT:String = 'left';
		public static const RIGHT:String = 'right';
		
		public static var description:C_Description = new C_Description();
		description.pushGroup('Position and Size');
		description.lastGroup.pushProperty(C_Property.NUMBER, 'x', 'X');
		description.lastGroup.pushProperty(C_Property.NUMBER, 'y', 'Y');
		description.lastGroup.pushProperty(C_Property.NUMBER, 'width', 'Width');
		description.lastGroup.pushProperty(C_Property.NUMBER, 'height', 'Height');
		description.pushGroup('Mounts');
		description.lastGroup.pushProperty(C_Property.MOUNTS, 'mounts');
		description.pushGroup('Text');
		description.lastGroup.pushProperty(C_Property.STRING, 'text', null);
		description.lastGroup.pushProperty(C_Property.TEXT_FORMAT, 'textFormat', null);
		description.pushGroup('Skin');
		description.lastGroup.pushProperty(C_Property.SKIN, 'skin');
		description.lastProperty.addOption('Normal Skin', C_SkinState.NORMAL);
		description.lastProperty.addOption('Focus Skin', C_SkinState.SELECTED);

		
		public function C_Input() {
			_fieldOffsetY = 0;
			_padding = 5;
			_autoFontSize = false;
			_iconAlign = CENTER;
			_autoSizeRect = new Rectangle();
			
			_icon = new Bitmap(null);
			addChild(_icon);
			
			_input = C_Text.defineTF(null, null, C_Text.defineFormat(null, null, "left"));
			_input.type = 'input';
			addChild(_input);

			addEventListener(C_Event.CHANGE_SKIN, skinChangeHandler);
			addEventListener(MouseEvent.MOUSE_DOWN, mDownHandler);
			addEventListener(C_Event.CHANGE_TEXT, changedTextHandler);
			_input.addEventListener(KeyboardEvent.KEY_UP, inputKeyUpHandler);
			
			addEventListener(C_Event.RESIZE, resizeHandler);
			_input.addEventListener(FocusEvent.FOCUS_IN, focusInHandler);
			_input.addEventListener(FocusEvent.FOCUS_OUT, focusOutHandler);
			
			width = 100;
			height = 30;
		}
		//------------------------------------------------
		//	H A N D L E R S
		//------------------------------------------------
		private function changedTextHandler(e:C_Event):void {
			if (e.inside) _changed = true;
		}
		
		private function focusOutHandler(e:Event):void {
			skinState = C_SkinState.NORMAL;
			changeComplete();
		}
		
		private function focusInHandler(e:Event):void {
			if (skin.frames[C_SkinState.SELECTED]) skinState = C_SkinState.SELECTED;
		}
		
		private function resizeHandler(e:Event):void {
			refresh();
		}
		
		private function inputKeyUpHandler(e:Event):void {
			_changed = true;
			dispatchEvent(new C_Event(C_Event.CHANGE_TEXT, null, true));
		}
		
		private function stageSelectHandler(e:Event):void {
			_input.setSelection(_startSelection, getCaretIndex(_input.mouseX, _input.height * 0.5));
		}
		
		private function stageUpHandler(e:MouseEvent):void {
			if (stage) {
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, stageSelectHandler);
				stage.removeEventListener(MouseEvent.MOUSE_UP, stageUpHandler);
			}
		}
		
		private function stageDownHandler(e:MouseEvent):void {
			if (!this.contains(e.target as DisplayObject)) {
				skinState = C_SkinState.NORMAL;
				if (stage) stage.removeEventListener(MouseEvent.MOUSE_DOWN, stageDownHandler);
			}
		}
		
		private function mDownHandler(e:Event):void {
			if (skin.frames[C_SkinState.SELECTED]) skinState = C_SkinState.SELECTED;
			stage.addEventListener(MouseEvent.MOUSE_DOWN, stageDownHandler);
			stage.focus = _input;
			
			if (e.target != _input) {
				stage.addEventListener(MouseEvent.MOUSE_UP, stageUpHandler);
				stage.addEventListener(MouseEvent.MOUSE_MOVE, stageSelectHandler);
			
				_startSelection = getCaretIndex(_input.mouseX, _input.height * 0.5);
				_input.setSelection(_startSelection, _startSelection);
			}
		}
		
		private function skinChangeHandler(e:Event):void {
			
		}
		
		//------------------------------------------------
		//	S E T  /  G E T
		//------------------------------------------------
		public function get textFormat():TextFormat {
			return _input.defaultTextFormat;
		}
		
		public function set textFormat(format:TextFormat):void {
			C_Text.defineTF(_input, null, format);
			refresh();
		}
		
		public function get iconAlign():String {
			return _iconAlign;
		}
		
		public function set iconAlign(value:String):void {
			_iconAlign = value;
		}
		
		public function get icon():BitmapData {
			return _icon.bitmapData;
		}
		
		public function set icon(bitmapdata:BitmapData):void {
			_icon.bitmapData = bitmapdata;
			refreshIcon();
		}
		
		public function get textField():TextField {
			return _input;
		}
		
		public function set fontColor(color:uint):void {
			C_Text.defineTF(_input, null, C_Text.defineFormat(_input.defaultTextFormat, null, null, color));
		}
		
		public function get fontSize():Number {
			return Number(_input.defaultTextFormat.size);
		}
		
		public function set fontSize(value:Number):void {
			_autoFontSize = false;
			C_Text.defineTF(_input, null, C_Text.defineFormat(_input.defaultTextFormat, value));
			refresh();
		}
		
		public function get text():String {
			return _input.text;
		}
		
		public function set text(value:String):void {
			if (value == _input.text) return;
			var refreshBefore:Boolean = (_input.text) ? false : true;
			_input.text = (value === null) ? '' : value;
			if (refreshBefore) refresh();
			dispatchEvent(new C_Event(C_Event.CHANGE_TEXT));
		}
		
		public function set autoFontSize(value:Boolean):void {
			_autoFontSize = value;
		}
		
		public function get fieldOffsetY():Number {
			return _fieldOffsetY;
		}
		
		public function set fieldOffsetY(value:Number):void {
			if (value == _fieldOffsetY) return;
			_fieldOffsetY = value;
			refresh();
		}
		
		//------------------------------------------------
		//	O V E R R I D E D
		//------------------------------------------------
		/*override public function set width(value:Number):void {
			if (width != value) {
				super.width = value;
				refresh();
			}
		}
		

		override public function set height(value:Number):void {
			if (height != value) {
				super.height = value;
				refresh();
			}
		}*/
		
		//------------------------------------------------
		//	P U B L I C
		//------------------------------------------------
		public function refresh():void {
			_autoSizeRect.width = width;
			_autoSizeRect.height = height;
			
			if (_autoFontSize) {
				C_Text.autoSize(_input, _autoSizeRect);
				C_Text.autoFontSize(_input);
			}
			else {
				_autoSizeRect.height = -1;
				C_Text.autoSize(_input, _autoSizeRect);
				var format:TextFormat = _input.defaultTextFormat;
				format.leftMargin = (height - _input.height) / 2 - 1;
				C_Text.defineTF(_input, null, format);
				_input.y = Math.round((height * 0.5) - (_input.textHeight * 0.5)) + _fieldOffsetY;
			}
			refreshIcon();
		}
		
		//------------------------------------------------
		//	P R I V A T E
		//------------------------------------------------
		private function changeComplete():void {
			if (_changed) {
				dispatchEvent(new C_Event(C_Event.CHANGE_COMPLETE, null, true));
				_changed = false;
			}
		}
		
		private function refreshIcon():void {
			if (_icon.bitmapData) {
				if (_iconAlign == LEFT || _iconAlign == RIGHT) {
					_icon.x = (_iconAlign == LEFT) ? 0 : width - _icon.width;
					_icon.y = (height * 0.5) - (_icon.height * 0.5);
				}
				else if (_iconAlign == TOP || _iconAlign == BOTTOM) {
					_icon.x = (width * 0.5) - (_icon.width * 0.5);
					_icon.y = (_iconAlign == TOP) ? 0 : height - _icon.height;
				}
				else if (_iconAlign == CENTER) {
					_icon.x = (width * 0.5) - (_icon.width * 0.5);
					_icon.y = (height * 0.5) - (_icon.height * 0.5);
				}
			}
		}
		
		private function getCaretIndex(x:Number, y:Number):int {
			var index:int = _input.getCharIndexAtPoint(x, y);
			
			if (_input.getLineLength(0) < 1) {
				index = 0;
			}
			else if (index < 0) {
				if (x < _input.getCharBoundaries(0).x) {
					index = 0;
				}
				else {
					index =  _input.getLineLength(0);
				}
			}
			
			return index;
		}

	}

}