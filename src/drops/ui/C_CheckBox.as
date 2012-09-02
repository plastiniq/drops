package drops.ui {
	import drops.core.C_Box;
	import drops.core.C_SkinnableBox;
	import drops.data.C_Description;
	import drops.data.C_Property;
	import drops.data.C_SkinFrame;
	import drops.data.C_SkinState;
	import drops.events.C_Event;
	import flash.display.BitmapData;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_CheckBox extends C_SkinnableBox {
		private var _button:C_Button;
		private var _label:C_Label;
		private var _labelOffsetY:Number;
		
		private var _spacing:Number;
		
		private var _lockResize:Boolean;
		
		private var _fit:String;
		public static const NONE:String = 'none';
		public static const SPACING:String = 'spacing';
		
		private var _buttonAlign:String;
		public static const LEFT:String = 'left';
		public static const RIGHT:String = 'right';
		
		public static var description:C_Description = new C_Description();
		description.pushGroup('Position and Size', 2);
		description.lastGroup.pushProperty(C_Property.NUMBER, 'x', 'X');
		description.lastGroup.pushProperty(C_Property.NUMBER, 'y', 'Y');
		description.lastGroup.pushProperty(C_Property.NUMBER, 'width', 'Width');
		description.lastGroup.pushProperty(C_Property.NUMBER, 'height', 'Height');
		description.pushGroup('Mounts');
		description.lastGroup.pushProperty(C_Property.MOUNTS, 'mounts');
		description.pushGroup('Text');
		description.lastGroup.pushProperty(C_Property.STRING, 'text');
		description.lastGroup.pushProperty(C_Property.TEXT_FORMAT, 'textFormat');
		description.pushGroup('Button Properties');
		description.lastGroup.pushProperty(C_Property.NUMBER, 'width', 'Button Width', null, 'button');
		description.lastGroup.pushProperty(C_Property.NUMBER, 'height', 'Button Height', null, 'button');
		description.lastGroup.pushProperty(C_Property.BOOLEAN, 'selected', 'Selected');
		description.pushGroup('Label Properties');
		description.lastGroup.pushProperty(C_Property.NUMBER, 'labelOffsetY', 'Label Vertical Offset');
		description.lastGroup.pushProperty(C_Property.NUMBER, 'spacing', 'Spacing');
		description.pushGroup('Button Skin');
		description.lastGroup.pushProperty(C_Property.BITMAPDATA, 'selectedIcon', 'Icon', null, 'button');
		description.lastGroup.pushProperty(C_Property.NUMBER, 'contentOffsetX', 'Icon Offset X', null, 'button');
		description.lastGroup.pushProperty(C_Property.NUMBER, 'contentOffsetY', 'Icon Offset Y', null, 'button');
		
		description.lastGroup.pushProperty(C_Property.SKIN, 'skin', null, null, 'button');
		description.lastProperty.addOption('Normal Skin', C_SkinState.NORMAL);
		description.lastProperty.addOption('Selected Skin', C_SkinState.SELECTED);
		description.lastProperty.addOption('Mouse Over Skin', C_SkinState.MOUSE_OVER);
		description.lastProperty.addOption('Mouse Down Skin', C_SkinState.MOUSE_DOWN);
		
		public function C_CheckBox(text:String = null) {
			_fit = NONE;
			_buttonAlign = LEFT;
			_spacing = 5;
			_labelOffsetY = 0;
			width = 100;
			height = 20;
			
			_label = new C_Label(text);
			addChild(_label);
			
			_button = new C_Button();
			_button.cropContent = false;
			_button.setAllPadding(0);
			_button.width = 20;
			_button.height = 20;
			_button.toggle = true;
			_button.hitArea = this;
			addChild(_button);
			
			skin.setFrame(C_SkinState.NORMAL, new C_SkinFrame());
	
			refresh();
			
			//_label.addEventListener(MouseEvent.MOUSE_UP, labelUpHandler);
			_button.addEventListener(C_Event.SELECT, selectHandler);
			_button.addEventListener(C_Event.CHANGE_STATE, changeHandler);
			_button.addEventListener(C_Event.RESIZE, buttonResizeHandler);
			addEventListener(C_Event.RESIZE, resizeHandler);
		}
		
		//--------------------------------------------------
		//	H A N D L E R S
		//--------------------------------------------------
		private function selectHandler(e:C_Event):void {
			dispatchEvent(new C_Event(C_Event.SELECT, e.data, e.inside));
		}
		
		private function buttonResizeHandler(e:C_Event):void {
			if (!e.inside) refresh();
		}
		
		private function resizeHandler(e:C_Event):void {
			if (!_lockResize) refresh();
		}
		
		/*private function labelUpHandler(e:MouseEvent):void {
			_button.insideSelected((_button.selected) ? false : true, true);
		}*/
		
		private function changeHandler(e:C_Event):void {
			dispatchEvent(new C_Event(e.type, null, e.inside));
		}
		
		//--------------------------------------------------
		//	S E T  / G E T
		//--------------------------------------------------
		public function get selectedIcon():BitmapData {
			return _button.selectedIcon;
		}
		
		public function set selectedIcon(value:BitmapData):void {
			_button.selectedIcon = value;
		}
		
		public function get buttonHeight():Number {
			return _button.height;
		}
		
		public function set buttonHeight(value:Number):void {
			_button.height = value;
		}
		
		public function get buttonWidth():Number {
			return _button.width;
		}
		
		public function set buttonWidth(value:Number):void {
			_button.width = value;
		}
		
		public function get selected():Boolean {
			return _button.selected;
		}
		
		public function set selected(value:Boolean):void {
			_button.selected = value;
		}
		
		public function get labelOffsetY():Number {
			return _labelOffsetY;
		}
		
		public function set labelOffsetY(value:Number):void {
			if (_labelOffsetY != value) {
				_labelOffsetY = value;
				refresh();
			}
		}
		
		public function get spacing():Number {
			return _spacing;
		}
		
		public function set spacing(value:Number):void {
			if (_spacing != value) {
				_spacing = value;
				refresh();
			}
		}
		
		public function get label():C_Label {
			return _label;
		}
		
		public function get button():C_Button {
			return _button;
		}
		
		public function get fit():String {
			return _fit;
		}
		
		public function set fit(value:String):void {
			if (_fit != value) {
				_fit = value;
				refresh();
			}
		}
		
		public function get buttonAlign():String {
			return _buttonAlign;
		}
		
		public function set buttonAlign(value:String):void {
			if (_buttonAlign !== value) {
				_buttonAlign = value;
				refresh();
			}
		}
		
		public function get textFormat():TextFormat {
			return _label.textFormat;
		}
		
		public function set textFormat(format:TextFormat):void {
			_label.textFormat = format;
		}
		
		public function get text():String {
			return _label.text;
		}
		
		public function set text(value:String):void {
			if (_label.text != value) {
				_label.text = value;
				refresh();
			}
		}
		//--------------------------------------------------
		//	O V E R R I D E D
		//--------------------------------------------------
		
		//--------------------------------------------------
		//	P U B L I C
		//--------------------------------------------------
		public function refresh():void {
			alignLabel();
		}
		
		//--------------------------------------------------
		//	P R I V A T E
		//--------------------------------------------------
		public function alignLabel():void {
			_lockResize = true;
		
			if (_fit == SPACING) {
				_label.x = (_buttonAlign == LEFT) ? width - _label.width : 0;
			}
			else {
				_label.x = (_buttonAlign == LEFT) ? _button.width + _spacing : width - _button.width - _spacing - _label.width;
				width = (_label.width > 0) ? Math.round(_label.x + _label.width) : _button.width;
			}
			
			height = Math.max(_button.height, _label.baseline);
			_label.y = ((height - _label.textHeight) * 0.5) + _labelOffsetY;
			_button.y = Math.round((height - _button.height) * 0.5);
			
			_lockResize = false;
		}
	}

}