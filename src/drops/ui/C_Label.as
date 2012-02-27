package drops.ui {
	import drops.core.C_Box;
	import drops.data.C_Description;
	import drops.data.C_Emboss;
	import drops.data.C_Property;
	import drops.events.C_Event;
	import drops.utils.C_Text;
	import com.greensock.data.DropShadowFilterVars;
	import flash.display.Sprite;
	import flash.filters.DropShadowFilter;
	import flash.geom.ColorTransform;
	import flash.text.CSMSettings;
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
	import flash.text.TextColorType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextRenderer;
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_Label extends C_Box {
		private var _format:TextFormat;
		private var _emboss:C_Emboss;

		private var _elementFormat:ElementFormat;
		private var _textBlock:TextBlock;
		
		private var _colorTransform:ColorTransform;
		private var _textColor:Object;
		
		private var _renderingMode:String;
		
		private var _heightCalculation:String;
		
		public var ascent:Number = 0;
		public var descent:Number = 0;
		
		public static var description:C_Description = new C_Description();
		description.pushGroup('Position and Size', 2);
		description.transparent = true;
		description.lastGroup.pushProperty(C_Property.NUMBER, 'x', 'X');
		description.lastGroup.pushProperty(C_Property.NUMBER, 'y', 'Y');
		description.lastGroup.pushProperty(C_Property.NUMBER, 'width', 'Width');
		description.lastGroup.pushProperty(C_Property.NUMBER, 'height', 'Height');
		description.pushGroup('Text');
		description.lastGroup.pushProperty(C_Property.TEXT_FORMAT, 'textFormat');
		//description.lastGroup.pushProperty(C_Property.EMBOSS, 'emboss');
		//description.lastGroup.pushProperty(C_Property.STRING, 'text');
		
		private static const EMPTY_COLOR_TRANSFORM:ColorTransform = new ColorTransform();
		
		public function C_Label(text:String = null, format:TextFormat = null) {
			_renderingMode = RenderingMode.CFF;
			_heightCalculation = LabelHeightCalculation.TEXT_HEIGHT;
			width = 0;
			height = 0;
			_textBlock = new TextBlock();
			_format = (format === null) ? C_Text.defineFormat() : format;
			_elementFormat = C_Text.formatToElementFormat(_format, _renderingMode);
			_colorTransform = new ColorTransform();
			
			this.text = text;
		}
		//-------------------------------------------------------------
		//	S E T  /  G E T
		//-------------------------------------------------------------
		public function get emboss():C_Emboss {
			return _emboss;
		}
		
		public function set emboss(value:C_Emboss):void {
			if (_emboss === value) return;
			_emboss = value;
			C_Text.embossField(this, value);
			dispatchEvent(new C_Event(C_Event.CHANGE));
		}
		
		public function get textHeight():Number {
			return (_textBlock.firstLine) ? _textBlock.firstLine.textHeight : 0;
		}
		
		public function get bold():Boolean {
			return _format.bold;
		}
		
		public function set bold(value:Boolean):void {
			if (_format.bold !== value) return;
			
			_format.bold = value;
			textFormat = _format;
		}
		
		public function getTextFormat():TextFormat {
			return _format;
		}
		
		public function get textFormat():TextFormat {
			return _format;
		}
		
		public function set textFormat(value:TextFormat):void {
			
			if (value == null) value = C_Text.defineFormat();
			var compArr:Array = C_Text.compareFormat(_format, value);
			if (compArr.length == 1 && compArr.indexOf('color') > -1) {
				textColor = value.color;
			}
			else if (compArr.length > 0) {
				textColor = null;
				var i:int = compArr.length;
				
				while (--i > -1) {
					_format[compArr[i]] = value[compArr[i]];
				}
				_elementFormat = C_Text.formatToElementFormat(_format, _renderingMode);
				_textBlock.content.elementFormat = _elementFormat;
				refresh();
			}
		}

		
		public function get text():String {
			return (_textBlock.content) ?  _textBlock.content.rawText : '';
		}
		
		public function set text(value:String):void {
			if (value != text) {
				var prevEmpty:Boolean = Boolean(_textBlock.content);
				_textBlock.content = new TextElement(value, _elementFormat);
				if (prevEmpty) _textBlock.content.elementFormat = _elementFormat;
				refresh();
			}
		}
		
		public function get baseline():Number {
			return (_textBlock.firstLine) ? _textBlock.firstLine.ascent : 0;
		}
		
		public function get textColor():Object {
			return _textColor;
		}
		
		public function set textColor(value:Object):void {
			if (_textColor === value) return;
			
			if (_textBlock.firstLine) {
				if (value === null) {
					_textBlock.firstLine.transform.colorTransform = EMPTY_COLOR_TRANSFORM;
				}
				else {
					_colorTransform.color = uint(value);
					_textBlock.firstLine.transform.colorTransform = _colorTransform;
				}
			}

			_textColor = value;
			_format.color = value;
			_elementFormat = C_Text.formatToElementFormat(_format);
			if (_textBlock.content) _textBlock.content.elementFormat = _elementFormat;
			dispatchEvent(new C_Event(C_Event.CHANGE));
		}
		
		public function get fontSize():Number {
			return Number(_format.size);
		}
		
		public function set fontSize(value:Number):void {
			if (value == _format.size) return;
			_format.size = value;
			_elementFormat = C_Text.formatToElementFormat(_format, _renderingMode);
			_textBlock.content.elementFormat = _elementFormat;
			refresh();
		}
		
		public function get renderingMode():String {
			return _renderingMode;
		}
		
		public function set renderingMode(value:String):void {
			_renderingMode = value;
			_elementFormat = C_Text.formatToElementFormat(_format, _renderingMode);
			_textBlock.content.elementFormat = _elementFormat;
			refresh();
		}
		
		public function get heightCalculation():String {
			return _heightCalculation;
		}
		
		public function set heightCalculation(value:String):void {
			_heightCalculation = value;
			sizeFromLine(_textBlock.firstLine);
		}
		
		//-------------------------------------------------------------
		//	P U B L I C
		//-------------------------------------------------------------
		public function copyFrom(source:C_Label):void {
			textColor = source.textColor;
			emboss = source.emboss;
			textFormat = source.textFormat;
		}
		
		public function refresh():void {
			removeLines();
			var line:TextLine = _textBlock.createTextLine();
			if (line) {
				line.y = line.ascent;
				addChild(line);
				ascent = line.ascent;
				descent = line.descent;
				sizeFromLine(line);
			}
			else {
				setSize(0, 0);
			}
			dispatchEvent(new C_Event(C_Event.CHANGE));
		}
		
		//-------------------------------------------------------------
		//	P R I V A T E
		//-------------------------------------------------------------
		private function sizeFromLine(line:TextLine):void {
			if (!line) {
				setSize(0, 0);
			}
			else {
				switch (_heightCalculation) {
					case LabelHeightCalculation.TEXT_HEIGHT: 
						setSize(line.width, line.textHeight);
						break;
					case LabelHeightCalculation.BASELINE:
						setSize(Math.round(line.width), Math.round(line.ascent));
						break;
					default:
						setSize(Math.round(line.width), Math.round(line.textHeight));
						break;
				}
			}
		}
		
		private function removeLines():void {
			if (_textBlock.firstLine) {
				var line:TextLine = _textBlock.firstLine;
				//line.flushAtomData();
				if (line.parent === this) removeChild(line);
				_textBlock.releaseLines(_textBlock.firstLine, _textBlock.lastLine);
			}
		}
		
	}

}