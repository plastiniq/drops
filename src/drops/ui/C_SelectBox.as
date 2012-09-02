package drops.ui {
	import drops.core.C_Box;
	import drops.data.C_Child;
	import drops.data.C_Description;
	import drops.data.C_Mounts;
	import drops.data.C_Property;
	import drops.events.C_Event;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_SelectBox extends C_Box {
		private var _arrowButton:C_Button;
		private var _contentButton:C_Button;
		private var _list:C_SelectList;
		
		private var _listPaddingTop:Number;
		private var _listPaddingLeft:Number;
		private var _listPaddingRight:Number;
		private var _listAutoWidth:String;
		
		private var _displayText:Boolean;
		private var _displayIcon:Boolean;
		
		public var data:*;
		
		public static const NONE:String = 'none';
		public static const LOCK:String = 'lock';
		public static const AUTO:String = 'auto';
		
		public static var description:C_Description = new C_Description();
		description.pushChild(new C_Child('List', 'list'));
		description.pushChild(new C_Child('Content Button', 'contentButton'));
		description.pushChild(new C_Child('Arrow Button', 'arrowButton'));
		
		description.pushGroup('Position and Size', 2);
		description.lastGroup.pushProperty(C_Property.NUMBER, 'x', 'X');
		description.lastGroup.pushProperty(C_Property.NUMBER, 'y', 'Y');
		description.lastGroup.pushProperty(C_Property.NUMBER, 'width', 'Width');
		description.lastGroup.pushProperty(C_Property.NUMBER, 'height', 'Height');
		description.pushGroup('Options');
		description.lastGroup.pushProperty(C_Property.NUMBER, 'arrowButtonWidth', 'Width Arrow Button');
		description.lastGroup.pushProperty(C_Property.MENU, 'listAutoWidth', 'List Auto Width');
		description.lastProperty.addOption('Auto', AUTO);
		description.lastProperty.addOption('Locked', LOCK);
		description.lastProperty.addOption('None', NONE);

		public function C_SelectBox() {
			width = 100;
			height = 20;
			
			_displayText = true;
			_displayIcon = true;
			
			_listPaddingTop = 0;
			_listPaddingLeft = 0;
			_listPaddingRight = 0;
			
			_listAutoWidth = AUTO;
			
			_arrowButton = new C_Button();
			_arrowButton.enabled = false;
			_arrowButton.mounts = new C_Mounts(null, 0, 0, 0);
			addChild(_arrowButton);
			
			_contentButton = new C_Button();
			_contentButton.stopRender();
			_contentButton.cropContent = true;
			_contentButton.paddingRight = 2;
			_contentButton.paddingTop = 0;
			_contentButton.paddingBottom = 0;
			_contentButton.enabled = false;
			_contentButton.contentAlignX = C_Button.LEFT;
			_contentButton.mounts = new C_Mounts(0, _arrowButton.width, 0, 0);
			_contentButton.beginRender();
			addChild(_contentButton);
			
			_list = new C_SelectList();
			_list.toggle = true;
			_list.multiSelect = false;
			_list.autoWidth = false;
			_list.turn();
			
			_arrowButton.addEventListener(C_Event.RESIZE, arrowResizeHandler);
			_list.addEventListener(C_Event.SELECT, listSelectHandler);
			_list.addEventListener(C_Event.ANIMATION_COMPLETE, listAnimationCompleteHandler);
			_list.addEventListener(C_Event.UPDATE, listUpdateHandler);
			addEventListener(MouseEvent.MOUSE_OVER, mOverHandler);
			addEventListener(MouseEvent.MOUSE_OUT, mOutHandler);
			addEventListener(MouseEvent.MOUSE_DOWN, mDownHandler);
			addEventListener(MouseEvent.MOUSE_UP, mUpHandler);
			addEventListener(C_Event.RESIZE, resizeHandler);
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);
		}
		
		//------------------------------------------------------------
		//	H A N D L E R S
		//------------------------------------------------------------
		private function stageDownHandler(e:MouseEvent):void {
			if (!this.contains(e.target as DisplayObject) && !_list.contains(e.target as DisplayObject)) {
				hideList();
			}
		}
		
		private function removedFromStageHandler(e:Event):void {
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, stageDownHandler);
		}
		
		private function addedToStageHandler(e:Event):void {
			stage.addEventListener(MouseEvent.MOUSE_DOWN, stageDownHandler);
		}
		
		private function listSelectHandler(e:C_Event):void {
			refreshContent();
			_list.turn(true);
			dispatchEvent(new C_Event(C_Event.LIST_SELECT, e.data, e.inside));
		}
		
		private function listUpdateHandler(e:C_Event):void {
			refreshListWidth();
		}
		
		private function resizeHandler(e:C_Event):void {
			if (e.data == C_Box.WIDTH || e.data == C_Box.BOTH) {
				refreshListWidth();
			}
		}
		
		private function mUpHandler(e:MouseEvent):void {
			_contentButton.setOverState();
			_arrowButton.setOverState();
		}
		
		private function mDownHandler(e:MouseEvent):void {
			_contentButton.setDownState();
			_arrowButton.setDownState();
			(_list.expanded) ? hideList() : showList();
		}
		
		private function mOutHandler(e:MouseEvent):void {
			_contentButton.setNormalState();
			_arrowButton.setNormalState();
		}
		
		private function mOverHandler(e:MouseEvent):void {
			_contentButton.setOverState();
			_arrowButton.setOverState();
		}
		
		private function listAnimationCompleteHandler(e:C_Event):void {
			if (e.data === C_SelectList.HIDE) {
				removeList();
			}
		}
		
		private function arrowResizeHandler(e:C_Event):void {
			if (e.data == C_Box.WIDTH || e.data == C_Box.BOTH) {
				_contentButton.right = _arrowButton.width;
			}
		}
		
		//------------------------------------------------------------
		//	S E T  /  G E T 
		//------------------------------------------------------------
		public function set selectedValue(value:*):void {
			var i:int = _list.items.length;
			while (--i > -1) {
				if (_list.items[i].data === value) {
					_list.items[i].selected = true;
					break;
				}
			}
		}
		
		public function get selectedItem():C_Button {
			return _list.lastSelectedItem;
		}
		
		public function get selectedIndex():int {
			return _list.lastSelectedIndex;
		}
		
		public function get selectedValue():* {
			return _list.lastSelectedItem.data;
		}
		
		public function get displayIcon():Boolean {
			return _displayIcon;
		}
		
		public function set displayIcon(value:Boolean):void {
			if (value === _displayIcon) return;
			_displayIcon = value;
			refreshContent();
		}
		
		public function get displayText():Boolean {
			return _displayText;
		}
		
		public function set displayText(value:Boolean):void {
			if (value === _displayText) return;
			_displayText = value;
			refreshContent();
		}
		
		public function get listPaddingTop():Number {
			return _listPaddingTop;
		}
		
		public function set listPaddingTop(value:Number):void {
			if (value === _listPaddingTop) return;
			_listPaddingTop = value;
			refreshListWidth();
		}
		
		public function get listPaddingRight():Number {
			return _listPaddingRight;
		}
		
		public function set listPaddingRight(value:Number):void {
			if (value == _listPaddingRight) return;
			_listPaddingRight = value;
			refreshListWidth();
		}
		
		public function get listPaddingLeft():Number {
			return _listPaddingLeft;
		}
		
		public function set listPaddingLeft(value:Number):void {
			if (value === _listPaddingLeft) return;
			_listPaddingLeft = value;
			refreshListWidth();
		}
		
		public function get listAutoWidth():String {
			return _listAutoWidth;
		}
		
		public function set listAutoWidth(value:String):void {
			if (value === _listAutoWidth) return;
			_listAutoWidth = value;
			refreshListWidth();
		}
		
		public function get arrowButton():C_Button {
			return _arrowButton;
		}
		
		public function get contentButton():C_Button {
			return _contentButton;
		}
		
		public function get arrowButtonWidth():Number {
			return _arrowButton.width;
		}
		
		public function set arrowButtonWidth(value:Number):void {
			_arrowButton.width = value;
		}
		
		public function get list():C_SelectList {
			return _list;
		}
		
		//------------------------------------------------------------
		//	P U B L I C
		//------------------------------------------------------------
		public function setData(data:Array, labelKey:String = null, iconKey:String = null, dataKey:String = null):void {
			_list.setData(data, labelKey, iconKey, dataKey);
		}
		
		//------------------------------------------------------------
		//	P R I V A T E
		//------------------------------------------------------------
		private function refreshContent():void {
			if (_list.lastSelectedItem) {
				_contentButton.icon = (_displayIcon)? _list.lastSelectedItem.icon : null; 
				_contentButton.text = (_displayText)? _list.lastSelectedItem.text : null;
			}
		}
		
		private function refreshListWidth():void {
			if (_listAutoWidth === AUTO) {
				_list.width = Math.max(_list.getAutoWidthValue(), width) - _listPaddingLeft - _listPaddingRight;
			}
			else if (_listAutoWidth === LOCK) {
				_list.width = width - _listPaddingLeft - _listPaddingRight;
			}
		}
		
		private function hideList():void {
			if (!_list.expanded) return;
			_list.turn(true);
		}
		
		private function removeList():void {
			if (_list.parent) _list.parent.removeChild(_list);
		}
		
		private function showList():void {
			if (_list.expanded || !stage) return;
			var point:Point = this.localToGlobal(new Point(_listPaddingLeft, height + _listPaddingTop));
			_list.x = Math.min(stage.stageWidth - _list.width, point.x);
			
			if (point.y + _list.height > stage.stageHeight) {
				if (point.y - height >= _list.height) {
					point.y -= (height + _list.height + _listPaddingTop);
				}
			}
			_list.y = point.y;
			stage.addChild(_list);
			_list.expand(true);
		}
	}

}