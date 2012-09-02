package drops.ui {
	import drops.core.C_Box;
	import drops.data.C_Child;
	import drops.data.C_Description;
	import drops.data.C_Property;
	import drops.events.C_Event;
	import drops.graphics.TextCursor;
	import drops.utils.C_Text;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.events.TimerEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.fscommand;
	import flash.text.engine.CFFHinting;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.FontDescription;
	import flash.text.engine.FontLookup;
	import flash.text.engine.FontPosture;
	import flash.text.engine.FontWeight;
	import flash.text.engine.RenderingMode;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextElement;
	import flash.text.engine.TextLine;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_TextField extends C_Box {
		private var _content:Sprite;
		private var _textBlock:TextBlock;
		private var _elementFormat:ElementFormat;
		private var _format:TextFormat;
		private var _selBegin:int;
		private var _selEnd:int;
		private var _scrollV:int;
		private var _numVisible:int;
		private var _lines:Array;
		private var _moveCount:int;
		
		private var _colorTransform:ColorTransform;
		
		private var _tf:TextField;
		private var _selectable:Boolean;
		private var _autoHeight:Boolean;
		private var _heightCalculation:String;
		private var _input:Boolean;
		private var _cursor:TextCursor;
		
		private static const EMPTY_COLOR_TRANSFORM:ColorTransform = new ColorTransform();
		
		public static var description:C_Description = new C_Description();
		description.transparent = true;
		description.pushGroup('Position and Size', 2);
		description.lastGroup.pushProperty(C_Property.NUMBER, 'x', 'X');
		description.lastGroup.pushProperty(C_Property.NUMBER, 'y', 'Y');
		description.lastGroup.pushProperty(C_Property.NUMBER, 'width', 'Width');
		description.lastGroup.pushProperty(C_Property.NUMBER, 'height', 'Height');
		description.pushGroup('Mounts');
		description.lastGroup.pushProperty(C_Property.MOUNTS, 'mounts');
		description.pushGroup('Text');
		description.lastGroup.pushProperty(C_Property.TEXT_FORMAT, 'textFormat');
		//description.lastGroup.pushProperty(C_Property.STRING, 'text');
		public function C_TextField() {
			width = 100;
			height = 100;
			
			_heightCalculation = LabelHeightCalculation.TEXT_HEIGHT;
			
			_scrollV = 0;
			_numVisible = 0;
			_selectable = false;
			_autoHeight = false;
			_selBegin = -1;
			_selEnd = 0;
			_moveCount = 0;
			
			_content = new Sprite();
			addChild(_content);
			
			_colorTransform = new ColorTransform();
			
			_lines = [];
			
			_textBlock = new TextBlock();
			_format = C_Text.defineFormat();
			_elementFormat = C_Text.formatToElementFormat(_format);
			
			_cursor = new TextCursor();
			_cursor.hide();
			addChild(_cursor);
			
			text = 'Text Field';
			
			//input = true;
			//selectable = true;

			addEventListener(C_Event.RESIZE, resizeHandler);
			addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);
		}
		
		//-------------------------------------------------------------
		//	H A N D L E R S
		//-------------------------------------------------------------
		private function removedFromStageHandler(e:Event):void {
			stage.removeEventListener(MouseEvent.MOUSE_WHEEL, tfWheelHandler);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, stageMoveHandler);
			stage.removeEventListener(MouseEvent.MOUSE_UP, stageUpHandler);
		}
		
		private function mOutHandler(e:MouseEvent):void {
			Mouse.show();
			Mouse.cursor = MouseCursor.AUTO;
		}
		
		private function mOverHandler(e:MouseEvent):void {
			Mouse.hide();
			Mouse.cursor = MouseCursor.IBEAM;
		}
		
		public function selectAllHandler(e:Event):void {
			selectAll();
		}
		
		private function tfWheelHandler(e:MouseEvent):void {
			scrollV -= e.delta;
		}
		
		private function tfFocusOutHandler(e:FocusEvent):void {
			fscommand("trapallkeys", "false");
			stage.removeEventListener(MouseEvent.MOUSE_WHEEL, tfWheelHandler);
		}
		
		private function tfFocusInHandler(e:FocusEvent):void {
			fscommand("trapallkeys", "true");
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, tfWheelHandler);
		}
		
		private function tfKeyDownHandler(e:KeyboardEvent):void {
			var setCursorSpec:Boolean = true;
			
			if (e.keyCode == 65 && e.ctrlKey) {
				selectAll();
			}
			else if (e.keyCode == 67 && e.ctrlKey) {
				trace('ctrl+c');
			}
			else if (e.keyCode == 8) {
				if (_selBegin == _selEnd) {
					selectionBegin--;
				}
				replaceText(null, 0);
			}
			else if (e.keyCode == 46) {
				if (_selBegin == _selEnd) {
					selectionEnd++;
				}
				replaceText(null, 0);
			}
			else if (e.keyCode == 13) {
				replaceText('\n', 1);
			}
			else if (e.keyCode == 40 || e.keyCode == 38) {
				var propLine:String = (e.keyCode == 40) ? 'nextLine' : 'previousLine';
				var line:TextLine = _textBlock.getTextLineAtCharIndex(_selEnd);
				if (line[propLine]) line = line[propLine];
				_selEnd = charIndex(_cursor.specX, line.y);
				if (!e.shiftKey) selectionBegin = selectionEnd;
				setCursorSpec = false;
			}
			else if (e.keyCode == 37) {
				selectionEnd--;
				if (!e.shiftKey) selectionBegin = selectionEnd;
			}
			else if (e.keyCode == 39) {
				selectionEnd++;
				if (!e.shiftKey) selectionBegin = selectionEnd;
			}

			redrawSelection();
			placeCursor(setCursorSpec);
		}
		
		private function textInputHandler(e:TextEvent):void {
			replaceText(e.text);
			_tf.text = '';
		}
		
		private function stageUpHandler(e:MouseEvent):void {
			if (_selBegin === _selEnd) graphics.clear();
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, stageMoveHandler);
			stage.removeEventListener(MouseEvent.MOUSE_UP, stageUpHandler);
		}
		
		private function stageMoveHandler(e:MouseEvent):void {
			_moveCount++;
			
			if (_moveCount > 5) {
				if (mouseY < _lines[_scrollV].y) {
					scrollV--;
				}
				else if (mouseY > _lines[_scrollV + _numVisible - 1].y) {
					scrollV++;
				}
				_moveCount = 0;
			}
			
			_selEnd = charIndex(mouseX, mouseY);
			placeCursor();
			redrawSelection();
		}
		
		private function mDownHandler(e:MouseEvent):void {
			if (_input && stage) {
				stage.focus = _tf;
			}
			_selBegin = charIndex(mouseX, mouseY);
			_selEnd = _selBegin;
			placeCursor();
			stage.addEventListener(MouseEvent.MOUSE_MOVE, stageMoveHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP, stageUpHandler);
		}
		
		private function resizeHandler(e:C_Event):void {
			if (e.data == BOTH || e.data == WIDTH) {
				refresh();
			}
			else {
				refreshLines();
			}
		}
		
		//-------------------------------------------------------------
		//	S E T  /  G E T
		//-------------------------------------------------------------
		public function get autoHeight():Boolean {
			return _autoHeight;
		}
		
		public function set autoHeight(value:Boolean):void {
			if (_autoHeight != value) {
				_autoHeight = value;
				if (value) refreshLines();
			}
		}
		
		public function get scrollV():int {
			return _scrollV;
		}
		
		public function set scrollV(value:int):void {
			_scrollV = Math.max(0, Math.min(value, (_lines.length - _numVisible - 1)));
			refreshLines();
		}
		
		public function get selectionEnd():int {
			return _selEnd;
		}
		
		public function set selectionEnd(index:int):void {
			_selEnd = Math.max(0, Math.min(TextElement(_textBlock.content).text.length -1, index));
			redrawSelection();
		}
		
		public function get selectionBegin():int {
			return _selBegin;
		}
		
		public function set selectionBegin(index:int):void {
			_selBegin = Math.max(0, Math.min(TextElement(_textBlock.content).text.length -1, index));
			redrawSelection();
		}
		
		public function set input(value:Boolean):void {
			if (value) {
				if (!_tf) {
					_tf = new TextField();
					_tf.type = TextFieldType.DYNAMIC;
				}
				_tf.addEventListener(KeyboardEvent.KEY_DOWN, tfKeyDownHandler);
				_tf.addEventListener(TextEvent.TEXT_INPUT, textInputHandler);
				_tf.addEventListener(Event.SELECT_ALL, selectAllHandler);
				_tf.addEventListener(FocusEvent.FOCUS_IN, tfFocusInHandler);
				_tf.addEventListener(FocusEvent.FOCUS_OUT, tfFocusOutHandler);
				selectable = true;
			}
			else {
				if (_tf) {
					_tf.removeEventListener(KeyboardEvent.KEY_DOWN, tfKeyDownHandler);
					_tf.removeEventListener(TextEvent.TEXT_INPUT, textInputHandler);
					_tf.removeEventListener(Event.SELECT_ALL, selectAllHandler);
					_tf.removeEventListener(FocusEvent.FOCUS_IN, tfFocusInHandler);
					_tf.removeEventListener(FocusEvent.FOCUS_OUT, tfFocusOutHandler);
				}
			}
			_input = value;
		}
		
		public function get selectable():Boolean {
			return _selectable;
		}
		
		public function set selectable(value:Boolean):void {
			if (value == _selectable) return;
			if (value) {
				addEventListener(MouseEvent.MOUSE_DOWN, mDownHandler);
				addEventListener(MouseEvent.MOUSE_OVER, mOverHandler);
				addEventListener(MouseEvent.MOUSE_OUT, mOutHandler);
				_cursor.show();
				addChild(_cursor);
				_selBegin = _selEnd = 0;
			}
			else {
				removeEventListener(MouseEvent.MOUSE_DOWN, mDownHandler);
				removeEventListener(MouseEvent.MOUSE_OVER, mOverHandler);
				removeEventListener(MouseEvent.MOUSE_OUT, mOutHandler);
				if (stage) {
					stage.removeEventListener(MouseEvent.MOUSE_MOVE, stageMoveHandler);
					stage.removeEventListener(MouseEvent.MOUSE_UP, stageUpHandler);
				}
				_cursor.hide();
				removeChild(_cursor);
			}
			_selectable = value;
		}
		
		public function get textFormat():TextFormat {
			return _format;
		}
		
		public function set textFormat(value:TextFormat):void {
			/*var compArr:Array = C_Text.compareFormat(_format, format);
			_format = format;

			if (compArr.length == 1 && compArr.indexOf('color') > -1) {
				textColor(uint(_format.color));
			}
			else if (compArr.length > 0){
				_elementFormat = C_Text.formatToElementFormat(format);
				_textBlock.content.elementFormat = _elementFormat;
				refresh();
			}*/
			
			if (value == null) value = C_Text.defineFormat();
			var compArr:Array = C_Text.compareFormat(_format, value);
			
			if (compArr.length == 1 && compArr.indexOf('color') > -1) {
				_format.color = value.color;
				_elementFormat = C_Text.formatToElementFormat(_format);
				_textBlock.content.elementFormat = _elementFormat;
				textColor(value.color);
			}
			else if (compArr.length > 0) {
				textColor(null);
				var i:int = compArr.length;
				var val:Object;
				
				while (--i > -1) {
					_format[compArr[i]] = value[compArr[i]];
				}
				_elementFormat = C_Text.formatToElementFormat(_format);
				_textBlock.content.elementFormat = _elementFormat;
				refresh();
			}
		}
		
		public function get text():String {
			return (_textBlock.content === null) ? null : _textBlock.content.rawText;
		}
		
		public function set text(value:String):void {
			_textBlock.content = (value === null) ? null : new TextElement(value, _elementFormat);
			refresh();
		}
		
		public function get content():Sprite {
			return _content;
		}
		
		public function get heightCalculation():String {
			return _heightCalculation;
		}
		
		public function set heightCalculation(value:String):void {
			if (_heightCalculation == value) return;
			_heightCalculation = value;
			refresh();
		}
		
		//-------------------------------------------------------------
		//	P U B L I C
		//-------------------------------------------------------------
		public function selectAll():void {
			selectionBegin = 0;
			selectionEnd = 10000000;
			redrawSelection();
		}
		
		//-------------------------------------------------------------
		//	P R I V A T E
		//-------------------------------------------------------------
		private function refreshLines():void {
			_numVisible = 0;
			var i:int = -1;
			var line:TextLine;
			var oY:Number = NaN;
			
			while (++i < _lines.length) {
				line = _lines[i];
				
				if (i < _scrollV) {
					if (line.parent) _content.removeChild(line);
				}
				else {
					if (isNaN(oY)) oY = line.ascent;
					if ((oY + line.descent) < height || _autoHeight) {
						line.y = oY;
						if (!line.parent) _content.addChild(line);
						_numVisible++;
					}
					else {
						if (line.parent) _content.removeChild(line);
					}
					line.x = (_format.align == 'right') ? width - line.width : (_format.align == 'center') ? (width - line.width) * .5 : 0;
					oY += Math.round(line.textHeight * 1.2);
				}
			}
			if (_autoHeight) height = (line === null) ? 0 : Math.ceil(line.y + ((_heightCalculation == LabelHeightCalculation.TEXT_HEIGHT) ? line.descent : 0));
			placeCursor();
		}
		
		private function refresh():void {
			removeLines();
			_lines.length = 0;
			
			if (_textBlock.content) {
				_textBlock.baselineFontSize = Number(_format.size);
				_textBlock.baselineFontDescription = _elementFormat.fontDescription;
				
				var line:TextLine = _textBlock.createTextLine(null, width, 0, true);
				while (line !== null) {
					_lines.push(line);
					line = _textBlock.createTextLine(line, width, 0, true);
				}
				refreshLines();
				
				setChildIndex(_cursor, numChildren - 1);
				placeCursor();
			}
			refreshLines();
		}
		
		private function replaceText(text:String, caretOffset:int = 1):void {
			if (_selBegin > -1 && _selEnd > -1) {
				var begin:int = Math.min(_selBegin, _selEnd) + 1;
				var end:int = Math.max(_selBegin, _selEnd) + 1;
				TextElement(_textBlock.content).replaceText(begin, end, text);
				selectionEnd = selectionBegin = Math.min(_selEnd, _selBegin) + caretOffset;
				refresh();
				redrawSelection();
			}
		}
		
		private function removeLines():void {
			/*if (_textBlock.firstLine) {
				var line:TextLine = _textBlock.firstLine;
			
				while (line !== null) {
					line.flushAtomData();
					if (line.parent === this) removeChild(line);
					line = line.nextLine;
				}
				_textBlock.releaseLines(_textBlock.firstLine, _textBlock.lastLine);
			}*/
			removeChild(_content);
			_content = new Sprite();
			addChild(_content);
		}
		
		private function placeCursor(setSpec:Boolean = true):void {
			var prop:String = (_selBegin > _selEnd) ? 'left' : 'right'
			var line:TextLine = _textBlock.getTextLineAtCharIndex(_selEnd);
			if (!line || !line.parent) {
				_cursor.hide();
			}
			else {
				if (_input) _cursor.show();
				var atomBounds:Rectangle = line.getAtomBounds(line.getAtomIndexAtCharIndex(_selEnd));
				_cursor.x = atomBounds[prop];
				_cursor.y = Math.floor(line.y - line.ascent);
				_cursor.height = line.ascent + line.descent;
			}
			if (setSpec) {
				_cursor.specX = _cursor.x;
				_cursor.specY = _cursor.y;
			}
		}
		
		private function redrawSelection():void {
			graphics.clear();
			
			if (_selBegin > -1 && _selEnd > -1 && _selBegin !== _selEnd) {
				var charBegin:int = Math.min(_selBegin, _selEnd);
				var charEnd:int = Math.max(_selBegin, _selEnd);
				
				var startLine:TextLine = _textBlock.getTextLineAtCharIndex(charBegin);
				var endLine:TextLine = _textBlock.getTextLineAtCharIndex(charEnd);
				var line:TextLine = startLine;
				var rect:Rectangle = new Rectangle();
				
				graphics.beginFill(0xcddcff);
				
				while (line !== null) {
					rect.y = line.y - line.ascent;
					rect.left = Math.floor(line.x);
					rect.right = Math.ceil(line.width);
					rect.height = line.textHeight;
					
					if (line == startLine) {
						rect.left = line.getAtomBounds(line.getAtomIndexAtCharIndex(charBegin)).x;
					}
					if (line == endLine) {
						rect.right = line.getAtomBounds(line.getAtomIndexAtCharIndex(charEnd)).right;
					}
					if (line.parent) graphics.drawRect(rect.x, rect.y, rect.width, rect.height);
					
					if (line == endLine) break;
					line = line.nextLine;
				}
			}
		}
		
		private function charIndex(x:Number, y:Number):int {
			var line:TextLine = lineAtPoint(x, y);
			if (line == null) return -1;
			
			var atomIndex:int = -1;
			
			if (x < line.x) {
				atomIndex = 0;
			}
			else if (x > line.x + line.width) {
				atomIndex = line.atomCount - 1;
			}
			else {
				var pt:Point = localToGlobal(new Point(x, line.y));
				atomIndex = line.getAtomIndexAtPoint(pt.x, pt.y);
			}
			
			return line.getAtomTextBlockBeginIndex(atomIndex);
		}
		
		private function lineAtPoint(x:Number, y:Number):TextLine {
			if (!_textBlock.firstLine) return null;
			
			var line:TextLine = _lines[_scrollV];
			if (y < line.y - line.ascent) return line;
			
			var i:int = _scrollV - 1;
			while (++i < _lines.length) {
				line = _lines[i];
				if ((line.y + line.descent) > y || (line.nextLine && !line.nextLine.parent)) break;
			}
			return line;
		}
		
		private function textColor(value:Object):void {
			if (value === null) {
				_content.transform.colorTransform = EMPTY_COLOR_TRANSFORM;
			}
			else {
				_colorTransform.color = uint(value);
				_content.transform.colorTransform = _colorTransform;
			}
		}
		
		private static function lineText(line:TextLine):String {
			var begin:int = line.getAtomTextBlockBeginIndex(0);
			var end:int = line.getAtomTextBlockBeginIndex(line.atomCount - 1);
			return line.textBlock.content.rawText.slice(begin, end);
		}
	}
	
}