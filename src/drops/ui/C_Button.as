package drops.ui 
{
	import drops.core.C_Box;
	import drops.core.C_SkinnableBox;
	import drops.data.C_Background;
	import drops.data.C_Child;
	import drops.data.C_Description;
	import drops.data.C_Emboss;
	import drops.data.C_Mounts;
	import drops.data.C_Property;
	import drops.data.C_Skin;
	import drops.data.C_SkinFrame;
	import drops.data.C_SkinState;
	import drops.data.C_TaskEntry;
	import drops.events.C_Event;
	import drops.utils.UtilFunctions;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;
	import flash.utils.describeType;
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_Button extends C_SkinnableBox {
		private var _arrow:Bitmap;
		private var _content:C_ButtonContent;
		private var _contentMask:Shape;
		
		private var _paddingTop:Number;
		private var _paddingBottom:Number;
		private var _paddingLeft:Number;
		private var _paddingRight:Number;
		
		private var _contentOffsetX:Number;
		private var _contentOffsetY:Number;
		private var _arrowOffsetX:Number;
		private var _arrowOffsetY:Number;
		
		private var _cropContent:Boolean;
		private var _toggle:Boolean;
		private var _enabled:Boolean;
		private var _selected:Boolean;
		private var _mouseOver:Boolean;
		
		private var _renderEnabled:Boolean;
		private var _renderCalled:Boolean;
		
		private var _color:ColorTransform;
		
		private var _blindChildrens:Vector.<DisplayObject>;
		
		private var _data:Object;
		private var _sample:C_Button;
		private static var SOURSE_INFO:XML;
		
		private var _autoSize:String;
		public static const ALL:String = "all";
		public static const WIDTH:String = "width";
		public static const HEIGHT:String = "height";
		public static const NONE:String = "none";
		
		private var _contentAlignX:String;
		private var _contentAlignY:String;
		
		private var _lockResize:Boolean;
		
		private var _stack:Vector.<Function>;
		
		public static const LEFT:String = "left";
		public static const CENTER:String = "center";
		public static const RIGHT:String = "right";
		public static const TOP:String = "top";
		public static const BOTTOM:String = "bottom";
		
		private static const BRIGHTNESS_UP:Number = 1.03;
		private static const BRIGHTNESS_DOWN:Number = 0.95;
		private static const BRIGHTNESS_NORMAL:Number = 1;
		
		private static const EXCEPTED_PROPS:Array = ['enabled', 'size', 'selected', 'skinState', 'soundTransform', 'tabEnabled', 'sample', 'cacheBackground', 'tabChildren', 'accessibilityProperties', 'blendMode', 'scrollRect', 'opaqueBackground', 'cacheAsBitmap', 'contextMenu', 'accessibilityImplementation', 'doubleClickEnabled', 'mouseEnabled', 'tabIndex', 'focusRect', 'visible', 'x', 'y', 'data', 'z', 'name', 'selectedIcon', 'icon', 'autoSize', 'toggle', 'multiSelect', 'scale9Grid', 'rotationX', 'rotationY', 'rotationZ', 'rotation', 'filters', 'transform', 'width', 'height', 'mounts', 'text', 'left', 'right', 'top', 'bottom', 'scaleX', 'scaleY', 'scaleZ'];

		public static var description:C_Description = new C_Description();
		description.pushChild(new C_Child('Content', 'content'));
		description.pushChild(new C_Child('Skin', 'skinManager'));
		
		description.pushGroup('Position and Size', 2);
		description.lastGroup.pushProperty(C_Property.NUMBER, 'x', 'X');
		description.lastGroup.pushProperty(C_Property.NUMBER, 'y', 'Y');
		description.lastGroup.pushProperty(C_Property.NUMBER, 'width', 'Width');
		description.lastGroup.pushProperty(C_Property.NUMBER, 'height', 'Height');
		description.pushGroup('Mounts', 1, false);
		description.lastGroup.pushProperty(C_Property.MOUNTS, 'mounts');
		description.pushGroup('Options');
		description.lastGroup.pushProperty(C_Property.BOOLEAN, 'selected', 'Selected');
		description.lastGroup.pushProperty(C_Property.BOOLEAN, 'cropContent', 'Crop Content');
		//description.lastGroup.pushProperty(C_Property.EMBOSS, 'emboss', null, null, 'content, label');
		//description.lastGroup.pushProperty(C_Property.STRING, 'text', 'Text');
		
		description.lastGroup.pushProperty(C_Property.BITMAPDATA, 'arrow', 'Selected Arrow');
		description.lastGroup.pushProperty(C_Property.NUMBER, 'contentOffsetX', 'Content Offset X');
		description.lastGroup.pushProperty(C_Property.NUMBER, 'contentOffsetY', 'Content Offset Y');
		description.lastGroup.pushProperty(C_Property.MENU, 'contentAlignX', 'Align X');
		description.lastProperty.addOption('left', LEFT);
		description.lastProperty.addOption('center', CENTER);
		description.lastProperty.addOption('right', RIGHT);
		description.lastGroup.pushProperty(C_Property.MENU, 'contentAlignY', 'Align Y');
		description.lastProperty.addOption('top', TOP);
		description.lastProperty.addOption('center', CENTER);
		description.lastProperty.addOption('bottom', BOTTOM);
		description.pushGroup('Text Format');
		//description.lastGroup.pushProperty(C_Property.TEXT_FORMAT, 'textFormat');
		/*description.pushGroup('Skin');
		description.lastGroup.pushProperty(C_Property.C_SkinState.NORMAL, 'skin');
		description.lastProperty.addOption('Normal Skin', C_SkinState.NORMAL);
		description.lastProperty.addOption('Selected Skin', C_SkinState.SELECTED);
		description.lastProperty.addOption('Mouse Over Skin', C_SkinState.MOUSE_OVER);
		description.lastProperty.addOption('Mouse Down Skin', C_SkinState.MOUSE_DOWN);*/
		
		public function C_Button(label:String = null) {
			_autoSize = ALL;
			_contentAlignX = CENTER;
			_contentAlignY = CENTER;
			
			_renderEnabled = true;
			_renderCalled = false;
			_lockResize = false;
			
			_paddingTop = 10;
			_paddingBottom = 10;
			_paddingLeft = 10;
			_paddingRight = 10;
			
			_contentOffsetX = 0;
			_contentOffsetY = 0;
			_arrowOffsetX = 0;
			_arrowOffsetY = 0;
			
			_cropContent = false;
			_enabled = true;
			_toggle = false;
			
			_mouseOver = false;
			
			mouseChildren = false;
			
			_content = new C_ButtonContent(label);
			addChild(_content);
			_color = new ColorTransform();
			
			skin.background = new C_Background(null, null, null, null, 0x514080);
			skin.background = new C_Background(null, null, null, null, 0xff0000);
			
			enabledMouseHandlers(true);
			
			_stack = new Vector.<Function>();
			
			addEventListener(C_Event.RESIZE, resizeHandler);
			addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);
			skinManager.addEventListener(C_Event.CHANGE, skinChangeHandler);
			_content.addEventListener(C_Event.CHANGE, contentChangeHandler);
			refresh();
		}
		
		//---------------------------------------------------------
		//	H A N D L E R S
		//---------------------------------------------------------
		private function removedFromStageHandler(e:Event):void {
		}
		
		private function moveHandler(e:Event):void {
			if (_mouseOver == false && containsMouse(mouseX, mouseY)) {
				setOverState();
				_mouseOver = true;
			}
			else if (_mouseOver == true && !containsMouse(mouseX, mouseY)) {
				setNormalState();
				_mouseOver = false;
			}
		}
		
		private function sampleChangeHanlder(e:C_Event):void {
			copyFrom(_sample);
		}
		
		private function contentChangeHandler(e:C_Event):void {
			refresh();
		}
		
		private function skinChangeHandler(e:C_Event):void {
			setLabelFormat();
			change();
		}
		
		private function resizeHandler(e:C_Event):void {
			if (!_lockResize) refresh();
		}
		
		private function mouseClickHandler(e:MouseEvent):void {
			if (isBlindTarget(e.stageX, e.stageY)) return;
			if (_toggle) insideSelected((_selected) ? false : true, true);
			if (containsMouse(mouseX, mouseY)) setUpState();
		}
		
		private function mouseDownHandler(e:MouseEvent):void {
			if (isBlindTarget(e.stageX, e.stageY)) return;
			if (containsMouse(mouseX, mouseY)) setDownState();
		}
		
		private function mouseOutHandler(e:MouseEvent):void {
			removeEventListener(MouseEvent.MOUSE_MOVE, moveHandler);
			if (_mouseOver) {
				setNormalState();
				_mouseOver = false;
			}
		}
		
		private function mouseOverHandler(e:MouseEvent):void {
			addEventListener(MouseEvent.MOUSE_MOVE, moveHandler);
			if (containsMouse(mouseX, mouseY)) {
				setOverState();
				_mouseOver = true;
			}
		}

		//---------------------------------------------------------
		//	S E T  /  G E T
		//---------------------------------------------------------
		public function get sample():C_Button {
			return _sample;
		}
		
		public function set sample(value:C_Button):void {
			copyFrom(value);
			_sample = value;
		}
		
		public function get cropContent():Boolean {
			return _cropContent;
		}
		
		public function set cropContent(value:Boolean):void {
			if (value !== _cropContent) {
				_cropContent = value;
				refresh();
			}
		}
		
		public function get paddingRight():Number {
			return _paddingRight;
		}
		
		public function set paddingRight(value:Number):void {
			if (_paddingRight != value) {
				_paddingRight = value;
				refresh();
			}
		}
		
		public function get paddingLeft():Number {
			return _paddingLeft;
		}
		
		public function set paddingLeft(value:Number):void {
			if (_paddingLeft != value) {
				_paddingLeft = value;
				refresh();
			}
		}
		
		public function get paddingBottom():Number {
			return _paddingBottom;
		}
		
		public function set paddingBottom(value:Number):void {
			if (_paddingBottom != value) {
				_paddingBottom = value;
				refresh();
			}
		}
		
		public function get paddingTop():Number {
			return _paddingTop;
		}
		
		public function set paddingTop(value:Number):void {
			if (_paddingTop != value) {
				_paddingTop = value;
				refresh();
			}
		}
		
		public function get content():C_ButtonContent {
			return _content;
		}
		
		public function get iconAlign():String {
			return _content.iconAlign;
		}
		
		public function set iconAlign(value:String):void {
			_content.iconAlign = value;
		}
		
		public function get selectedIcon():BitmapData {
			return _content.selectedIcon;
		}
		
		public function set selectedIcon(bitmapdata:BitmapData):void {
			_content.selectedIcon = bitmapdata;
		}
		
		public function get icon():BitmapData {
			return _content.icon;
		}
		
		public function set icon(bitmapdata:BitmapData):void {
			_content.icon = bitmapdata;
		}
		
		public function get autoSize():String {
			return _autoSize;
		}
		
		public function set autoSize(value:String):void {
			if (_autoSize != value) {
				_autoSize = value;
				refresh();
			}
		}
		
		public function get contentAlignY():String {
			return _contentAlignY;
		}
		
		public function set contentAlignY(value:String):void {
			if (_contentAlignY != value) {
				_contentAlignY = value;
				refresh();
			}
		}
		
		public function get contentAlignX():String {
			return _contentAlignX;
		}
		
		public function set contentAlignX(value:String):void {
			if (_contentAlignX != value) {
				_contentAlignX = value;
				refresh();
			}
		}
		
		public function set data(data:Object):void {
			_data = data;
		}
		
		public function get data():Object {
			return _data;
		}
		
		public function get emboss():C_Emboss {
			return _content.label.emboss;
		}
		
		public function set emboss(value:C_Emboss):void {
			_content.label.emboss = value;
		}
		
		public function get textFormat():TextFormat {
			return _content.label.textFormat;
		}
		
		public function set textFormat(format:TextFormat):void {
			_content.label.textFormat = format;
		}
		
		public function get label():C_Label {
			return _content.label;
		}
		
		public function get text():String {
			return _content.label.text;
		}
		
		public function set text(value:String):void {
			_content.text = value;
		}
		
		public function get arrowOffsetY():Number {
			return _arrowOffsetY;
		}

		public function set arrowOffsetY(value:Number):void {
			if (_arrowOffsetY != value) {
				_arrowOffsetY = value;
				refreshArrow();
			}
		}
		
		public function get arrowOffsetX():Number {
			return _arrowOffsetX;
		}
		
		public function set arrowOffsetX(value:Number):void {
			if (_arrowOffsetX != value) {
				_arrowOffsetX = value;
				refreshArrow();
			}
		}
		
		public function get contentOffsetY():Number {
			return _contentOffsetY;
		}

		public function set contentOffsetY(value:Number):void {
			if (_contentOffsetY != value) {
				_contentOffsetY = value;
				refresh();
			}
		}
		
		public function get contentOffsetX():Number {
			return _contentOffsetX;
		}
		
		public function set contentOffsetX(value:Number):void {
			if (_contentOffsetX != value) {
				_contentOffsetX = value;
				refresh();
			}
		}
		
		public function get arrow():BitmapData {
			return (_arrow) ? _arrow.bitmapData : null;
		}
		
		public function set arrow(bitmapdata:BitmapData):void {
			checkArrow();
			_arrow.bitmapData = bitmapdata;
			_arrow.visible = _selected;
		}
		
		public function get toggle():Boolean{
			return _toggle;
		}
		
		public function set toggle(value:Boolean):void {
			if (_toggle != value) {
				_toggle = value;
				if (_toggle === false && selected === true) selected = false;
			}
		}
		
		public function get selected():Boolean {
			return _selected;
		}
		
		public function set selected(value:Boolean):void {
			insideSelected(value, false);
		}
		
		public function get enabled():Boolean {
			return _enabled;
		}
		
		public function set enabled(value:Boolean):void {
			if (value != _enabled) {
				enabledMouseHandlers(value);
			}
			_enabled = value;
		}
		
		public function get blindChildrens():Vector.<DisplayObject> {
			return _blindChildrens;
		}
		
		public function set blindChildrens(value:Vector.<DisplayObject>):void {
			_blindChildrens = value;
		}

		//------------------------------------------------------------
		//	O V E R R I D E D
		//------------------------------------------------------------
		override public function setSize(width:Number, height:Number):void {
			_autoSize = NONE;
			super.setSize(width, height);
		}

		override public function set mounts(value:C_Mounts):void {
			if (value.blockedX) defineAutoSize(WIDTH);
			if (value.blockedY) defineAutoSize(HEIGHT);
			super.mounts = value;
		}
		
		override public function set top(value:Object):void {
			defineAutoSize(HEIGHT);
			super.top = value;
		}
		
		override public function set bottom(value:Object):void {
			defineAutoSize(HEIGHT);
			super.bottom = value;
		}
		
		override public function set left(value:Object):void {
			defineAutoSize(WIDTH);
			super.left = value;
		}
		
		override public function set right(value:Object):void {
			defineAutoSize(WIDTH);
			super.right = value;
		}

		override public function set height(value:Number):void {
			defineAutoSize(HEIGHT);
			super.height = value;
		}

		override public function set width(value:Number):void {
			defineAutoSize(WIDTH);
			super.width = value;
		}
		
		public function get contentFilters():Array {
			return _content.filters;
		}
		
		public function set contentFilters(value:Array):void {
			_content.filters = value;
		}
	
		//---------------------------------------------------------
		//	P U B L I C
		//---------------------------------------------------------
		public function copyFrom(source:C_Button, exceptions:Array = null, setSample:Boolean = false):void {
			if (!source) return;
			if (setSample) _sample = source;
			stopRender();
			if (!SOURSE_INFO) SOURSE_INFO = describeType(this);
			var mergedExceptions:Array = (exceptions) ? EXCEPTED_PROPS.concat(exceptions) : EXCEPTED_PROPS;
			UtilFunctions.copyData(source, this, mergedExceptions, SOURSE_INFO);
			beginRender();
		}
		
		public function beginRender():void {
			_content.beginRender();
			_renderEnabled = true;
			
			var i:int = -1;
			while (++i < _stack.length) {
				_stack[i].apply(_stack[i]);
			}
			_stack.length = 0;
		}
		
		public function stopRender():void {
			_content.stopRender();
			_renderEnabled = false;
		}

		public function setAllPadding(value:Number):Number {
			if (_paddingTop != value || _paddingBottom != value || _paddingLeft != value || _paddingRight != value) {
				_paddingTop = _paddingBottom = _paddingLeft = _paddingRight = value;
				refresh();
			}
			return value;
		}
		
		public function refresh():void {
			refreshAutoSize();
			refreshContent();
			change();
		}

		//---------------------------------------------------------
		//	P R I V A T E
		//---------------------------------------------------------
		public function setUpState():void {
			skinState = (_selected) ? C_SkinState.SELECTED : (skin.frames[C_SkinState.MOUSE_OVER]) ? C_SkinState.MOUSE_OVER : C_SkinState.NORMAL;
			setBrightness((skinState === C_SkinState.NORMAL) ? BRIGHTNESS_UP : BRIGHTNESS_NORMAL);
			setLabelFormat();
		}
		
		public function insideSelected(value:Boolean, inside:Boolean, dispatch:Boolean = true):void {
			if (_selected != value) {
				_content.selected = value;
				_selected = value;
				if (_arrow) _arrow.visible = value;
				skinState = (value) ? C_SkinState.SELECTED : C_SkinState.NORMAL;
				setLabelFormat();
				if (dispatch) {
					if (value) dispatchEvent(new C_Event(C_Event.SELECT, this, inside));
					dispatchEvent(new C_Event(C_Event.CHANGE_STATE, null, inside));
				}
			}
		}
		
		public function setDownState():void {
			if (_selected || !skin.frames[C_SkinState.MOUSE_DOWN]) {
				setBrightness(BRIGHTNESS_DOWN);
			}
			else {
				skinState = C_SkinState.MOUSE_DOWN;
			}
			setLabelFormat();
		}
		
		public function setOverState():void {
			if (_selected || !skin.frames[C_SkinState.MOUSE_OVER]) {
				setBrightness(BRIGHTNESS_UP);
			}
			else {
				skinState = C_SkinState.MOUSE_OVER;
			}
			setLabelFormat();
		}
		
		public function setNormalState():void {
			skinState = (_selected) ? C_SkinState.SELECTED : C_SkinState.NORMAL;
			setBrightness(BRIGHTNESS_NORMAL);
			setLabelFormat();
		}
		
		private function setLabelFormat():void {
			if (skin.frames[skinState]) {
				_content.label.overlayTextColor = skin.frames[skinState].textColor;
				_content.label.overlayEmboss = skin.frames[skinState].emboss;
			}
			else {
				_content.label.overlayTextColor = null;
				_content.label.overlayEmboss = null;
			}
		}
		
		private function defineAutoSize(dimension:String):void {
			var antiDimension:String = (dimension === WIDTH) ? HEIGHT : WIDTH;
			
			if (_autoSize === ALL) {
				_autoSize = antiDimension;
			}
			else if (_autoSize === dimension){
				_autoSize = NONE;
			}
		}

		private function refreshAutoSize():void {
			if (delayed(refreshAutoSize)) return;
			var w:Number = width;
			var h:Number = height;
			
			_lockResize = true;
			
			if (_autoSize !== NONE) {
				if (_autoSize === ALL || _autoSize === WIDTH) {
					w = _paddingLeft + Math.round(_content.width) + _paddingRight;
					_content.x = _paddingLeft + _contentOffsetX;
				}
				if (_autoSize === ALL || _autoSize === HEIGHT) {
					h = _paddingTop + Math.round(_content.height) + _paddingBottom;
					_content.y = _paddingTop + _contentOffsetY;
				}
			}
			super.setSize(w, h);
			_lockResize = false;
		}
		
		private function refreshContent():void {
			if (delayed(refreshContent)) return;
			
			if (_autoSize !== WIDTH && _autoSize !== ALL) {
				var newX:Number;
				if (_contentAlignX === LEFT) 		{ newX = _paddingLeft }
				else if (_contentAlignX === CENTER)	{ newX = (width * 0.5) - (_content.width * 0.5) }
				else if (_contentAlignX === RIGHT)	{ newX = width - _paddingRight - _content.width }
				_content.x = Math.round(newX + _contentOffsetX);
			}
			if (_autoSize !== HEIGHT && _autoSize !== ALL) {	
				var newY:Number;
				if (_contentAlignY === TOP) 		{ newY = _paddingTop }
				else if (_contentAlignY === CENTER)	{ newY = (height * 0.5) - (_content.height * 0.5) }
				else if (_contentAlignY === BOTTOM)	{ newY = height - _paddingBottom - _content.height }
				_content.y = Math.round(newY + _contentOffsetY);
			}
			
			if (_autoSize === NONE) {
				if (_cropContent) {
					checkMask();
					_contentMask.x = _paddingLeft;
					_contentMask.y = _paddingTop;
					_contentMask.width = width - _paddingLeft - _paddingRight;
					_contentMask.height = height - _paddingTop - _paddingBottom;
					_content.mask = _contentMask;
				}
				else {
					_content.mask = null;
				}
				refreshArrow();
			}
		}
		
		private function refreshArrow():void {
			if (_arrow) {
				_arrow.x = Math.round((width * 0.5) - (_arrow.width * 0.5) + _arrowOffsetX);
				_arrow.y = height + _arrowOffsetY;
			}
		}

		private function checkArrow():void {
			if (!_arrow) {
				_arrow = new Bitmap();
				addChild(_arrow);
			}
		}
		
		private function checkMask():void {
			if (!_contentMask) {
				_contentMask = new Shape();
				_contentMask.visible = false;
				_contentMask.graphics.beginFill(0);
				_contentMask.graphics.drawRect(0, 0, 10, 10);
				addChild(_contentMask);
			}
		}
		
		private function setBrightness(value:Number):void {
			
			value = (255 * value) - 255;
			if (_color.redOffset != value) {
				_color.redOffset = value;
				_color.greenOffset = value;
				_color.blueOffset = value;
				transform.colorTransform = _color;
			}
		}
		
		private function enabledMouseHandlers(value:Boolean):void {
			if (value) {
				addEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
				addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
				addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
				addEventListener(MouseEvent.CLICK, mouseClickHandler);
			}
			else {
				setBrightness(BRIGHTNESS_NORMAL);
				removeEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
				removeEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
				removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
				removeEventListener(MouseEvent.CLICK, mouseClickHandler);
				removeEventListener(MouseEvent.MOUSE_MOVE, moveHandler);
			}
		}
		
		private function delayed(func:Function):Boolean {
			if (_renderEnabled) return false;
			var exist:int = _stack.indexOf(func);
			if (exist > -1) _stack.splice(exist, 1);
			_stack.push(func);
			return true;
		}
		
		private function change():void {
			dispatchEvent(new C_Event(C_Event.CHANGE));
		}
		
		private function containsMouse(mouseX:Number, mouseY:Number):Boolean {
			return (mouseX >= 0 && mouseX <= width && mouseY >= 0 && mouseY <= height);
		}
		
		private function isBlindTarget(stageX:Number, stageY:Number):Boolean {
			if (!_blindChildrens || !_blindChildrens.length) return false;
			
			var i:int = _blindChildrens.length;
			while (--i > -1) {
				if (this.contains(_blindChildrens[i]) && _blindChildrens[i].hitTestPoint(stageX, stageY)) return true;
			}
			return false;
		}
	}

}