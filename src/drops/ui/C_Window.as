package drops.ui {
	import drops.core.C_Box;
	import drops.core.C_SkinnableBox;
	import drops.data.C_Background;
	import drops.data.C_Mounts;
	import drops.data.C_Skin;
	import drops.data.C_SkinFrame;
	import drops.data.C_SkinState;
	import drops.events.C_Event;
	import drops.graphics.Animations;
	import drops.utils.C_Display;
	import com.greensock.loading.data.core.DisplayObjectLoaderVars;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_Window extends C_Box {
		private var _titleLabel:C_Label;
		private var _titleOffsetX:Number;
		private var _titleOffsetY:Number;
		
		private var _buttonsOffsetX:Number;
		private var _buttonsOffsetY:Number;
		
		private var _box:C_Box;
		private var _header:C_SkinnableBox;
		private var _body:C_SkinnableBox;
		private var _content:C_Box;
		private var _mirror:Bitmap;
		
		private var _titleAlign:String;
		private var _beginAnimation:String;
		private var _expanded:Boolean;
		private var _animation:Boolean;
		
		private var _resizible:Boolean;
		
		private var _buttons:C_ButtonBar;
		private var _closeButton:C_Button;
		private var _restoreButton:C_Button;
		private var _minimizeButton:C_Button;
		
		private var _showCloseButton:Boolean;
		private var _showRestoreButton:Boolean;
		private var _showMinimizeButton:Boolean;
		
		private var _actionHandler:Function;
		
		private var _okButton:C_Button;
		private var _cancelButton:C_Button;
		
		private var _contentPaddingLeft:Number;
		private var _contentPaddingTop:Number;
		private var _contentPaddingRight:Number;
		private var _contentPaddingBottom:Number;
		
		private var _disableStage:Boolean;
		private var _disabledObjects:Dictionary;
		
		private var _inFocus:Boolean;
		public static const W_STACK:Array = [];
		private static const GLOBAL_DISABLED:Dictionary = new Dictionary(true);
		
		private var _offset:Point;
		
		private var _sessionName:String;

		public static const NONE:String = 'none';
		public static const SHOW:String = 'show';
		public static const HIDE:String = 'hide';
		
		public static const LEFT:String = 'left';
		public static const CENTER:String = 'center';
		public static const RIGHT:String = 'right';
		
		public function C_Window(title:String = null, disableStage:Boolean = false) {
			_contentPaddingLeft = 0;
			_contentPaddingTop = 0;
			_contentPaddingRight = 0;
			_contentPaddingBottom = 0;
			
			_sessionName = name;
			
			_disableStage = disableStage;
			_disabledObjects = new Dictionary();
			
			width = 300;
			height = 200;
			
			_titleOffsetX = 0;
			_titleOffsetY = 0;
			
			_buttonsOffsetX = 0; 
			_buttonsOffsetY = 0; 
			
			_resizible = false;
			
			_showCloseButton = true;
			_showRestoreButton = false;
			_showMinimizeButton = false;
			
			_expanded = true;
			_animation = false;
			_beginAnimation = NONE;
			_titleAlign = LEFT;
			//mouseEnabled = false;
			
			_box = new C_Box();
			_box.mouseEnabled = false;
			_box.mounts = new C_Mounts(0, 0, 0, 0);
			addChild(_box);
			
			_header = new C_SkinnableBox();
			_header.mounts = new C_Mounts(0, 0, 0);
			_header.height = 40;
			_box.addChild(_header);
			_header.skin = new C_Skin(null, null, null, 0x706181);
			
			_buttons = new C_ButtonBar();
			_buttons.fit = C_ButtonBar.NONE;
			_buttons.toggle = false;
			_closeButton = new C_Button();
			_restoreButton = new C_Button();
			_minimizeButton = new C_Button();
			_header.addChild(_buttons);
			
			_titleLabel = new C_Label(title);
			_header.addChild(_titleLabel);
			
			_body = new C_SkinnableBox();
			_body.mouseEnabled = false;
			_body.mounts = new C_Mounts(0, 0, _header.height, 0);
			_box.addChild(_body);
			_body.skin.background = new C_Background(null, null, null, null, 0xf3f0f5);
			
			_content = new C_Box();
			_content.mounts = new C_Mounts(0, 0, 0, 0);
			_body.addChild(_content);
			
			_mirror = new Bitmap();
			_mirror.visible = false;
			addChild(_mirror);
			
			refreshButtonBar();
			align();
			
			_buttons.addEventListener(MouseEvent.CLICK, buttonsClickHander);
			_header.addEventListener(C_Event.RESIZE, headerResizeHandler);
			_header.addEventListener(MouseEvent.MOUSE_DOWN, headerDownHandler);
			addEventListener(MouseEvent.MOUSE_DOWN, bodyDownHandler);
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);

		}
		
		//----------------------------------------------------------------
		//	H A N D L E R S
		//----------------------------------------------------------------
		private function screenMouseHandler(e:MouseEvent):void {
			e.stopPropagation();
		}
		
		private function cancelClickHanlder(e:MouseEvent = null):void {
			callActionHandler(C_WindowActionType.CANCEL);
		}
		
		private function okClickHanlder(e:MouseEvent = null):void {
			callActionHandler(C_WindowActionType.APPLY);
		}
		
		private function stageKeyDownHandler(e:KeyboardEvent):void {
			if (_inFocus && W_STACK[0] === this) {
				if (_actionHandler !== null) {
					if (e.keyCode == 13) {
						callActionHandler(C_WindowActionType.APPLY);
					} 
					else if (e.keyCode == 27) {
						callActionHandler(C_WindowActionType.CANCEL);
					}
				}
			}
		}
		
		private function bodyDownHandler(e:MouseEvent):void {
			if (_inFocus) return;
			
			if (W_STACK[0] !== this) {
				parent.addChild(this);
				//parent.swapChildren(parent.getChildAt(parent.numChildren - 1), this);
				addToStack(this);
			}
			_inFocus = true;
		}
		
		private function stageDownHandler(e:MouseEvent):void {
			if (!this.contains(e.target as DisplayObject)) {
				_inFocus = false;
			}
		}
		
		private function buttonsClickHander(e:MouseEvent):void {
			if (e.target === _closeButton) {
				callActionHandler(C_WindowActionType.CLOSE);
				privateClose(true);
				turn();
			}
		}

		private function stageUpHandler(e:MouseEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_UP, stageUpHandler);
			this.stopDrag();
		}
		
		private function headerDownHandler(e:MouseEvent):void {
			if (!_buttons.contains(e.target as DisplayObject)) {
				stage.addEventListener(MouseEvent.MOUSE_UP, stageUpHandler);
				this.startDrag();
			}
		}
		
		private function headerResizeHandler(e:C_Event):void {
			_body.top = _header.height;
			align();
		}
		
		private function removedFromStageHandler(e:Event):void {
			setStageListeners(false);
			if (_disableStage) restoreEnvironment();
		}
		
		private function addedToStageHandler(e:Event):void {
			if (_expanded) {
				setKeysListeners(true);
				setStageListeners(true);
				_inFocus = true;
			}
			if (_disableStage) disableEnvironment();
		}
		
		private function animationCompleteHandler():void {
			_mirror.visible = false;
			
			if (_beginAnimation === SHOW) {
				_box.visible = true;
				setKeysListeners(true);
				setStageListeners(true);
				_inFocus = true;
			}
			else if (_beginAnimation === HIDE) {
				visible = false;
				_mirror.visible = false;
				setKeysListeners(false);
				setStageListeners(false);
				_inFocus = false;
			}
			
			dispatchEvent(new C_Event(C_Event.ANIMATION_COMPLETE, _beginAnimation, true));
			_beginAnimation = NONE;
		}

		//----------------------------------------------------------------
		//	S E T  /  G E T
		//----------------------------------------------------------------
		public function get inFocus():Boolean {
			return _inFocus;
		}
		
		public function get resizible():Boolean {
			return _resizible;
		}
		
		public function set resizible(value:Boolean):void {
			
		}
		
		public function get cancelButton():C_Button {
			return _cancelButton;
		}
		
		public function set cancelButton(value:C_Button):void {
			if (value === _cancelButton) return;
			
			if (_cancelButton) _cancelButton.removeEventListener(MouseEvent.CLICK, cancelClickHanlder);
			value.addEventListener(MouseEvent.CLICK, cancelClickHanlder);
			_cancelButton = value;
		}
		
		public function get okButton():C_Button {
			return _okButton;
		}
		
		public function set okButton(value:C_Button):void {
			if (value === _okButton) return;
			
			if (_okButton) _okButton.removeEventListener(MouseEvent.CLICK, okClickHanlder);
			value.addEventListener(MouseEvent.CLICK, okClickHanlder);
			_okButton = value;
		}

		public function get content():C_Box {
			return _content;
		}
		
		public function get animation():Boolean {
			return _animation;
		}
		
		public function set animation(value:Boolean):void {
			_animation = value;
		}
		
		public function get buttonBar():C_ButtonBar {
			return _buttons;
		}
		
		public function get showMinimizeButton():Boolean {
			return _showMinimizeButton;
		}
		
		public function set showMinimizeButton(value:Boolean):void {
			if (value !== _showMinimizeButton) {
				_showMinimizeButton = value;
				refreshButtonBar();
				align();
			}
		}
		
		public function get showRestoreButton():Boolean {
			return _showRestoreButton;
		}
		
		public function set showRestoreButton(value:Boolean):void {
			if (value !== _showRestoreButton) {
				_showRestoreButton = value;
				refreshButtonBar();
				align();
			}
		}
		
		public function get showCloseButton():Boolean {
			return _showCloseButton;
		}
		
		public function set showCloseButton(value:Boolean):void {
			if (value !== _showCloseButton) {
				_showCloseButton = value;
				refreshButtonBar();
				align();
			}
		}
		
		public function get minimizeButton():C_Button {
			return _minimizeButton;
		}
		
		public function get restoreButton():C_Button {
			return _restoreButton;
		}
		
		public function get closeButton():C_Button {
			return _closeButton;
		}
		
		public function get buttonsOffsetY():Number {
			return _buttonsOffsetY;
		}
		
		public function set buttonsOffsetY(value:Number):void {
			if (value !== _buttonsOffsetY) {
				_buttonsOffsetY = value;
				align();
			}
		}
		
		public function get buttonsOffsetX():Number {
			return _buttonsOffsetX;
		}
		
		public function set buttonsOffsetX(value:Number):void {
			if (value !== _buttonsOffsetX) {
				_buttonsOffsetX = value;
				align();
			}
		}
		
		public function get titleOffsetY():Number {
			return _titleOffsetY;
		}
		
		public function set titleOffsetY(value:Number):void {
			if (value !== _titleOffsetY) {
				_titleOffsetY = value;
				align();
			}
		}

		public function get titleOffsetX():Number {
			return _titleOffsetX;
		}
		
		public function set titleOffsetX(value:Number):void {
			if (value !== _titleOffsetX) {
				_titleOffsetX = value;
				align();
			}
		}
		
		public function get title():String {
			return _titleLabel.text;
		}
		
		public function set title(value:String):void {
			if (value !== _titleLabel.text) {
				_titleLabel.text = value;
				align();
			}
		}
		
		public function get header():C_SkinnableBox {
			return _header;
		}
		
		public function get titleLabel():C_Label {
			return _titleLabel;
		}
		
		public function get body():C_SkinnableBox {
			return _body;
		}
	
		public function get expanded():Boolean {
			return _expanded;
		}
		
		
		public function get contentPaddingLeft():Number {
			return _contentPaddingLeft;
		}
		
		public function set contentPaddingLeft(value:Number):void {
			if (_contentPaddingLeft == value) return;
			_contentPaddingLeft = value;
			_content.left = value;
		}
		
		public function get contentPaddingRight():Number {
			return _contentPaddingRight;
		}
		
		public function set contentPaddingRight(value:Number):void {
			if (_contentPaddingRight == value) return;
			_contentPaddingRight = value;
			_content.right = value;
		}
		
		public function get contentPaddingTop():Number {
			return _contentPaddingTop;
		}
		
		public function set contentPaddingTop(value:Number):void {
			if (_contentPaddingTop == value) return;
			_contentPaddingTop = value;
			_content.top = value;
		}
		
		public function get contentPaddingBottom():Number {
			return _contentPaddingBottom;
		}
		
		public function set contentPaddingBottom(value:Number):void {
			if (_contentPaddingBottom == value) return;
			_contentPaddingBottom = value;
			_content.bottom = value;
		}
		
		public function get actionHandler():Function {
			return _actionHandler;
		}
		
		public function set actionHandler(value:Function):void {
			_actionHandler = value;
		}
		
		//----------------------------------------------------------------
		//	P U B L I C
		//----------------------------------------------------------------
		public function setFocus(value:Boolean):void {
			_inFocus = value;
		}
		
		public function setContentPadding(left:Number, right:Number, top:Number, bottom:Number):void {
			_contentPaddingLeft = left;
			_contentPaddingRight = right;
			_contentPaddingTop = top;
			_contentPaddingBottom = bottom;
			_content.mounts = new C_Mounts(left, right, top, bottom);
		}
		
		public function setContentSize(w:Number, h:Number):void {
			setSize(w + _contentPaddingLeft + _contentPaddingRight, h + _contentPaddingTop + _contentPaddingBottom + _header.height);
		}
		
		public function turn():void {
			if (!_expanded) return;

			if (_animation) {
				_box.visible = false;
				refreshMirror();
				_mirror.visible = true;
				_beginAnimation = HIDE;
				Animations.scaleAroundCenter(_mirror, 0, 0.94, 0.94, 0.1, animationCompleteHandler);
			}
			else {
				_box.visible = false;
				visible = false;
			}
			
			removeFromStack(this);
			//if (W_STACK.length > 0) W_STACK[0].setFocus(true);
			_expanded = false;
			if (_disableStage) restoreEnvironment();
			dispatchEvent(new C_Event(C_Event.TURN));
		}
		
		public function expand(center:Boolean = false):void {
			visible = true;
			if (parent) {
				if (center) {
					var parentW:Number = (parent is Stage) ? stage.stageWidth : parent.width;
					var parentH:Number = (parent is Stage) ? stage.stageHeight : parent.height;
					
					x = int((parentW * 0.5) - (width * 0.5));
					y = int((parentH * 0.5) - (height * 0.5));
				}
				parent.addChild(this);
				//parent.swapChildren(parent.getChildAt(parent.numChildren - 1), this);
			}

			if (!_expanded) {
				if (_animation) {
				refreshMirror();
				_box.visible = false;
				_mirror.visible = true;
				_beginAnimation = SHOW;

				Animations.scaleAroundCenter(_mirror, 0.5, 0.85, 0.85, 0);
				Animations.scaleAroundCenter(_mirror, 1, 1, 1, 0.15, animationCompleteHandler);
				}
				else {
					_mirror.visible = false;
					_box.visible = true;
				}
			}
			
			addToStack(this);
			_expanded = true;
			if (_disableStage) disableEnvironment();
			dispatchEvent(new C_Event(C_Event.EXPAND));
		}
		
		public function refreshMirror():void {
			_mirror.scaleX = 1;
			_mirror.scaleY = 1;
			_mirror.x = 0;
			_mirror.y = 0;
			_mirror.visible = false;
			if (_mirror.bitmapData) _mirror.bitmapData.dispose();
			
			if (_box.width * _box.height > 0) {
				_mirror.bitmapData = new BitmapData(_box.width, _box.height, true, 0xffffff);
				_mirror.bitmapData.draw(_box, null, null);
				_mirror.smoothing = true;
			}
		}
		
		//----------------------------------------------------------------
		//	P R I V A T E
		//----------------------------------------------------------------
		private function callActionHandler(type:String):void {
			if (_actionHandler !== null) _actionHandler.apply(this, [type]);
		}
		
		private function disableEnvironment():void {
			C_Display.disable(_sessionName, stage, this);
		}
		
		private function restoreEnvironment():void {
			C_Display.restore(_sessionName);
		}
		
		private function setStageListeners(enabled:Boolean):void {
			if (!stage) return;
			if (enabled) {
				stage.addEventListener(MouseEvent.MOUSE_DOWN, stageDownHandler);
				stage.addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);
				stage.addEventListener(MouseEvent.MOUSE_UP, stageUpHandler);
			}
			else {
				stage.removeEventListener(MouseEvent.MOUSE_DOWN, stageDownHandler);
				stage.removeEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);
				stage.removeEventListener(MouseEvent.MOUSE_UP, stageUpHandler);
			}
		}
		
		private function setKeysListeners(enabled:Boolean):void {
			if (!stage) return;
			if (enabled) {
				stage.addEventListener(KeyboardEvent.KEY_DOWN, stageKeyDownHandler);
			}
			else {
				stage.removeEventListener(KeyboardEvent.KEY_DOWN, stageKeyDownHandler);
			}
		}
		
		private function privateClose(inside:Boolean):void {
			dispatchEvent(new C_Event(C_Event.CLOSE, null, inside));
		}
		
		private function refreshButtonBar():void {
			_buttons.clear();
			if (_showMinimizeButton) _buttons.addItem(_minimizeButton);
			if (_showRestoreButton) _buttons.addItem(_restoreButton);
			if (_showCloseButton) _buttons.addItem(_closeButton);
		}
		
		private function align():void {
			_buttons.x = _header.width - _buttons.width + _buttonsOffsetX;
			_buttons.y = int((_header.height * 0.5) - (_buttons.height * 0.5)) + _buttonsOffsetY;
			
			var posX:Number = 0;
			
			if (_titleAlign === CENTER) {
				posX = (_header.width * 0.5) - (_titleLabel.width * 0.5);
			}
			if (_titleAlign === RIGHT) {
				posX = _buttons.x - _titleLabel.width;
			}
			
			_titleLabel.x = posX + _titleOffsetX;
			_titleLabel.y = (_header.height * 0.5) - (_titleLabel.textHeight * 0.5) + _titleOffsetY;
		}
		
		//----------------------------------------------------------------
		//	S T A T I C
		//----------------------------------------------------------------
		private static function removeFromStack(window:C_Window):void {
			var i:int = W_STACK.indexOf(window);
			if (i > -1) W_STACK.splice(i, 1);
		}
		
		private static function addToStack(window:C_Window):void {
			removeFromStack(window);
			W_STACK.unshift(window);
		}

	}

}