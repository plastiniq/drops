package drops.ui {
	import drops.core.C_Box;
	import drops.data.C_Child;
	import drops.data.C_Description;
	import drops.data.C_Emboss;
	import drops.data.C_Property;
	import drops.events.C_Event;
	import drops.utils.C_Text;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_ButtonContent extends C_Box {
		private var _iconBitmap:Bitmap;
		private var _label:C_ButtonLabel;
		private var _labelMargin:Number;
		
		private var _iconOffsetY:Number;
		
		private var _icon:BitmapData;
		private var _selectedIcon:BitmapData;
		
		private var _selected:Boolean;
		
		private var _relatively:Rectangle;
		
		private var _renderEnabled:Boolean;
		private var _renderCalled:Boolean;
		
		private var _align:String;
		public static const LEFT:String = "left";
		public static const RIGHT:String = "right";
		public static const TOP:String = "top";
		public static const BOTTOM:String = "bottom";
		
		public static var description:C_Description = new C_Description();
		description.pushGroup('Options');
		description.lastGroup.pushProperty(C_Property.BITMAPDATA, 'icon', 'Icon');
		description.lastGroup.pushProperty(C_Property.NUMBER, 'labelMargin', 'Label Margin');
		description.lastGroup.pushProperty(C_Property.MENU, 'iconAlign', 'Icon Align');
		description.lastProperty.addOption(LEFT);
		description.lastProperty.addOption(RIGHT);
		description.lastProperty.addOption(TOP);
		description.lastProperty.addOption(BOTTOM);
		description.pushGroup('Text');
		description.lastGroup.pushProperty(C_Property.STRING, 'text', 'Text', null, 'label');
		description.lastGroup.pushProperty(C_Property.EMBOSS, 'emboss', 'Emboss', null, 'label');
		description.lastGroup.pushProperty(C_Property.TEXT_FORMAT, 'textFormat', null, null, 'label');

		public function C_ButtonContent(text:String = "Button", format:TextFormat = null, emboss:C_Emboss = null) {
			_selected = false;
			
			if (!format) format = C_Text.defineFormat();
			
			_iconOffsetY = 0;
			
			_relatively = new Rectangle();
			_renderEnabled = true;
			
			_iconBitmap = new Bitmap();
			addChild(_iconBitmap);
		
			_label = new C_ButtonLabel(text, format);
			_label.emboss = emboss;
			addChild(_label);
			
			_labelMargin = 5;
			_align = LEFT;
			
			setSize(_label.width, _label.textHeight);
			
			_label.addEventListener(C_Event.CHANGE, labelChangeHandler);
		}
		
		//--------------------------------------------
		//	P U B L I C
		//--------------------------------------------
		public function labelChangeHandler(e:C_Event):void {
			align();
		}
		
		public function beginRender():void {
			_renderEnabled = true;
			if (_renderCalled) {
				align();
				_renderCalled = false;
			}
		}
		
		public function stopRender():void {
			_renderEnabled = false;
		}
		
		public function refresh():void {
			align();
		}
		
		//--------------------------------------------
		//	O V E R R I D E
		//--------------------------------------------
		/*override public function set x(value:Number):void{
			super.x = value;
		}
		
    	override public function set y(value:Number):void{
			super.y = value;
		}*/
		
		//--------------------------------------------
		//	S E T  /  G E T
		//--------------------------------------------
		public function get labelMargin():Number {
			return _labelMargin;
		}
		
		public function set labelMargin(value:Number):void {
			if (_labelMargin === value) return;
			_labelMargin = value;
			align();
		}
		
		public function get labelField():C_Label {
			return _label;
		}
		
		public function get iconAlign():String {
			return _align;
		}
		
		public function set iconAlign(value:String):void {
			if (_align === value) return;
			_align = value;
			align();
		}
		
		public function get label():C_ButtonLabel {
			return _label;
		}
		
		public function get text():String {
			return _label.text;
		}
		
		public function set text(value:String):void {
			if (value === _label.text) return;
			
			var prevEmpty:Boolean = (_label.text === null);
			if (_label.text != value) {
				_label.text = value;
				if (prevEmpty) align();
			}
		}
		
		public function get selected():Boolean {
			return _selected;
		}
		
		public function set selected(value:Boolean):void {
			if (value === _selected) return;
			
			if (value) {
				if (_selectedIcon) _iconBitmap.bitmapData = _selectedIcon;
			}
			else {
				_iconBitmap.bitmapData = _icon;
			}
			_selected = value;
			align();
		}
		
		public function get icon():BitmapData {
			return _iconBitmap.bitmapData;
		}
		
		public function set icon(value:BitmapData):void {
			if (_icon === value) return;
			if (!_selected) _iconBitmap.bitmapData = value;
			_icon = value;
			align();
		}
		
		public function get selectedIcon():BitmapData {
			return _selectedIcon;
		}
		
		public function set selectedIcon(value:BitmapData):void {
			if (_selectedIcon === value) return;
			if (_selected) _iconBitmap.bitmapData = value;
			_selectedIcon = value;
			align();
		}
		
		public function get iconOffsetY():Number {
			return _iconOffsetY;
		}
		
		public function set iconOffsetY(value:Number):void {
			if (value == _iconOffsetY) return;
			_iconOffsetY = value;
			align();
		}
		
		//--------------------------------------------
		//	P U B L I C
		//--------------------------------------------
		public function copyFrom(source:C_ButtonContent):void {
			stopRender();
			_label.copyFrom(source.label);
			icon = source.icon;
			iconAlign = source.iconAlign;
			labelMargin = source.labelMargin;
			beginRender();
		}
		
		//--------------------------------------------
		//	P R I V A T E
		//--------------------------------------------
		private function align():void {
			//if (!_iconBitmap || !_iconBitmap.bitmapData) return;
			if (!_renderEnabled) {
				_renderCalled = true;
				return;
			}
			_relatively.width = Math.max(_iconBitmap.width, _label.width);
			_relatively.height = Math.max(_iconBitmap.height, _label.height);
			
			var a:DisplayObject;
			var b:DisplayObject;
			var prop1:String;
			var prop2:String;
			
			var _margin:Number = (_iconBitmap.bitmapData != null && _label.text != '') ? _labelMargin : 0;
			
			if (_align == TOP || _align == BOTTOM) {
				prop1 = 'x';
				prop2 = 'width';
				a = (_align == TOP) ? _iconBitmap : _label;
				b = (_align == TOP) ? _label : _iconBitmap;
				a.y = 0;
				b.y = a.height + _margin;
			}
			else if (_align == LEFT || _align == RIGHT) {
				prop1 = 'y';
				prop2 = 'height';
				a = (_align == LEFT) ? _iconBitmap : _label;
				b = (_align == LEFT) ? _label : _iconBitmap;
				a.x = 0;
				b.x = a.width + _margin;
			}
			_iconBitmap[prop1] = Math.round((_relatively[prop2] * 0.5) - _iconBitmap[prop2] * 0.5);
			_label[prop1] = Math.round((_relatively[prop2] * 0.5) - _label[prop2] * 0.5);
			
			_iconBitmap.y += _iconOffsetY;	
			
			setSize(Math.max(_iconBitmap.x + _iconBitmap.width, text ? (_label.x + _label.width) : 0), 
					Math.max(_iconBitmap.y + _iconBitmap.height, text ? (_label.y + _label.height) : 0));

			dispatchEvent(new C_Event(C_Event.CHANGE));
		}
		
	}

}