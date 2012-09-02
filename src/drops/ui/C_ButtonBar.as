package drops.ui {
	import drops.core.C_Box;
	import drops.core.C_SkinnableBox;
	import drops.data.C_Child;
	import drops.data.C_Description;
	import drops.data.C_Mounts;
	import drops.data.C_Property;
	import drops.data.C_Skin;
	import drops.data.C_SkinFrame;
	import drops.data.C_SkinManager;
	import drops.data.C_SkinState;
	import drops.events.C_Event;
	import com.greensock.TweenMax;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_ButtonBar extends C_SkinnableBox {
		private var _items:Vector.<C_Button>;
		private var _axis:String;
		private var _fit:String;
		private var _spacing:Number;
		
		private var _toggle:Boolean;
		private var _multiSelect:Boolean;
		private var _draggable:Boolean;
		
		private var _draggableItem:C_Button;
		private var _dragRect:Rectangle;
		private var _snapshot:Vector.<itemPosition>;
		private var _swapSpeed:Number;
		private var _swapped:Boolean;
		private var _dragged:Boolean;
		private var _downPoint:Point;
		private var _movedPoint:Point;
		
		private var _firstItemSample:C_Button;
		private var _itemSample:C_Button;
		private var _lastItemSample:C_Button;
		private var _singleItemSample:C_Button;
		
		private var _existSample:Boolean;
		private var _existFirst:Boolean;
		private var _existLast:Boolean;
		private var _existSingle:Boolean;

		private var _lastSelectedIndex:int;
		private var _lockResize:Boolean;
		
		private var _bannedSampleProps:Array;
		
		public static const X:String = 'x';
		public static const Y:String = 'y';
		
		public static const NONE:String = 'none';
		public static const SPACING:String = 'spacing';
		public static const ITEMS:String = 'items';
		
		public static var description:C_Description = new C_Description(); 
		
		description.setContainer('addItem', [C_Button]);
		description.transparent = true;
		description.lockChildrensSkin = true;
		
		description.pushChild(new C_Child('Item Sample', 'itemSample'));
		description.pushChild(new C_Child('First Item Sample', 'firstItemSample'));
		description.pushChild(new C_Child('Last Item Sample', 'lastItemSample'));
		description.pushChild(new C_Child('Single Item Sample', 'singleItemSample'));
		
		description.pushGroup('Position and Size', 2);
		description.lastGroup.pushProperty(C_Property.NUMBER, 'x', 'X');
		description.lastGroup.pushProperty(C_Property.NUMBER, 'y', 'Y');
		description.lastGroup.pushProperty(C_Property.NUMBER, 'width', 'Width');
		description.lastGroup.pushProperty(C_Property.NUMBER, 'height', 'Height');
		
		description.pushGroup('Mounts', 1, false);
		description.lastGroup.pushProperty(C_Property.MOUNTS, 'mounts');
		
		description.pushGroup('Properties');
		description.lastGroup.pushProperty(C_Property.BOOLEAN, 'toggle', 'Toggle');
		description.lastGroup.pushProperty(C_Property.BOOLEAN, 'multiSelect', 'Multi Select');
		description.lastGroup.pushProperty(C_Property.MENU, 'fit', 'Fit');
		description.lastProperty.addOption('None', NONE);
		description.lastProperty.addOption('Spacing', SPACING);
		description.lastProperty.addOption('Items', ITEMS);
		
		description.lastGroup.pushProperty(C_Property.MENU, 'axis', 'Orientation');
		description.lastProperty.addOption('Horizontal', X);
		description.lastProperty.addOption('Vertical', Y);
		
		description.lastGroup.pushProperty(C_Property.NUMBER, 'spacing', 'Spacing');
		
		public function C_ButtonBar(...args) {
			width = 150;
			height = 20;
			
			_swapSpeed = 0.2;
			
			var emptySkin:C_Skin = new C_Skin();
			skin = emptySkin;
			
			_toggle = false;
			_draggable = false;
			_multiSelect = false;
			_lockResize = false;
			_swapped = false;
			_dragged = false;
			
			_bannedSampleProps = [];
			
			_spacing = 0;
			_axis = X;
			_lastSelectedIndex = -1;
			_items = new Vector.<C_Button>();

			_firstItemSample = new C_Button();
			_itemSample = new C_Button();
			_lastItemSample = new C_Button();
			_singleItemSample = new C_Button();
			
			_movedPoint = new Point();
			_downPoint = new Point();
			_dragRect = new Rectangle();
			_snapshot = new Vector.<itemPosition>();
			
			fit = ITEMS;
			
			_firstItemSample.addEventListener(C_Event.CHANGE, firstSampleChangeHandler);
			_itemSample.addEventListener(C_Event.CHANGE, itemSampleChangeHandler);
			_lastItemSample.addEventListener(C_Event.CHANGE, lastSampleChangeHandler);
			_singleItemSample.addEventListener(C_Event.CHANGE, singleSampleChangeHandler);
			
			addEventListener(Event.REMOVED, removedHandler);
			addEventListener(C_Event.RESIZE, resizeHandler);
			
			var i:int = -1
			while (++i < args.length) newItem(args[i]);
		}
		
		//-----------------------------------------------------------------
		//	H A N D L E R S
		//-----------------------------------------------------------------
		private function stageUpHandler(e:MouseEvent):void {
			stage.removeEventListener(MouseEvent.MOUSE_UP, stageUpHandler);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, stageMoveHandler);
			if (_draggableItem) {
				_draggableItem.stopDrag();
				_draggableItem = null;
				align(true, 0.4);
				
				if (_swapped) {
					dispatchEvent(new C_Event(C_Event.SWAP_COMPLETE, null, true));
					_swapped = false;
				}
			}
		}
		
		private function stageMoveHandler(e:MouseEvent):void {
			if (!_draggableItem) return;
			
			_movedPoint.x = mouseX;
			_movedPoint.y = mouseY;
			
			if (Point.distance(_downPoint, _movedPoint) < 10) return;
			
			if (!_dragged) {
				_dragged = true;
				_draggableItem.x += _movedPoint.x - _downPoint.x;
				_draggableItem.y += _movedPoint.y - _downPoint.y;
				_draggableItem.startDrag(false, _dragRect);
			}
			
			var i:int = -1;
			var index:int = _items.indexOf(_draggableItem);
			
			while (++i < _snapshot.length) {
				if (index > i && _draggableItem[_axis] < _snapshot[i].position + (_snapshot[i].length * 0.5)) {
					swapItems(index, i);
					index = _items.indexOf(_draggableItem);
					align(true, _swapSpeed, _draggableItem, false);
				}
				else if (index < i && _draggableItem[_axis] + _draggableItem[lengthProp] > _snapshot[i].position + (_snapshot[i].length * 0.5)) {
					swapItems(index, i);
					index = _items.indexOf(_draggableItem);
					align(true, _swapSpeed, _draggableItem, false);
				}
			}
		}
		
		private function mDownHandler(e:MouseEvent):void {
			if (_items.indexOf(e.target) > -1) {
				_dragged = false;
				stage.addEventListener(MouseEvent.MOUSE_UP, stageUpHandler);
				stage.addEventListener(MouseEvent.MOUSE_MOVE, stageMoveHandler);
				_dragRect[lengthProp] = this[lengthProp] - e.target[lengthProp];
				_dragRect[thickProp] = 0;
				_draggableItem = e.target as C_Button;
				setChildIndex(_draggableItem, numChildren - 1);
				_downPoint.x = mouseX;
				_downPoint.y = mouseY;
			}
		}
		
		
		private function firstSampleChangeHandler(e:C_Event):void {
			_existFirst = true;
			if (_items.length > 1) _items[0].sample = firstItemSample;
		}
		
		private function itemSampleChangeHandler(e:C_Event):void {
			_existSample = true;
			refreshSkins();
		}
		
		private function lastSampleChangeHandler(e:C_Event):void {
			_existLast = true;
			if (_items.length > 1) _items[_items.length - 1].sample = lastItemSample;
		}
		
		private function singleSampleChangeHandler(e:C_Event):void {
			_existSingle = true;
			if (_items.length == 1) _items[0].sample = singleItemSample;
		}
		
		private function removedHandler(e:Event):void {
			if (e.target !== this && e.target.parent === this) {
				removeItem(e.target as C_Button);
			}
		}
		
		private function resizeHandler(e:C_Event):void {
			if (!_lockResize) align();
		}
		
		private function itemResizeHandler(e:C_Event):void {
			if (!_lockResize) align();
		}
		
		private function itemChangeHandler(e:C_Event):void {
			dispatchEvent(new C_Event(C_Event.CHANGE_STATE, e.target, e.inside));
		}
		
		private function itemSelectHandler(e:C_Event):void {
			if (!_multiSelect) {
				if (lastSelectedItem !== null) {
					lastSelectedItem.selected = false;
					lastSelectedItem.enabled = true;
				}
				e.target.enabled = false;
			}
			_lastSelectedIndex = _items.indexOf(e.target);
			dispatchEvent(new C_Event(C_Event.SELECT, e.target, e.inside));
		}
		
		//-----------------------------------------------------------------
		//	S E T  /  G E T
		//-----------------------------------------------------------------
		public function set bannedSampleProps(value:Array):void {
			_bannedSampleProps = value ? value : [];
		}
		
		public function get bannedSampleProps():Array {
			return _bannedSampleProps;
		}
		
		public function set draggable(value:Boolean):void {
			if (_draggable == value) return;

			if (value) {
				addEventListener(MouseEvent.MOUSE_DOWN, mDownHandler);
			}
			else {
				removeEventListener(MouseEvent.MOUSE_DOWN, mDownHandler);
			}
			_draggable = value;
		}
		
		public function get items():Vector.<C_Button> {
			return _items;
		}
		
		public function get axis():String {
			return _axis;
		}
		
		public function set axis(value:String):void {
			if (_axis !== value) {
				_axis = value;
				align();
			}
		}
		
		public function get lastSelectedIndex():int {
			return _lastSelectedIndex;
		}
		
		public function get lastSelectedItem():C_Button {
			return (_lastSelectedIndex > -1 && _lastSelectedIndex < _items.length) ? _items[_lastSelectedIndex] :null;
		}
		
		public function get spacing():Number {
			return _spacing;
		}
		
		public function set spacing(value:Number):void {
			if (_spacing !== value) {
				_spacing = value;
				align();
			}
		}
		
		public function get fit():String {
			return _fit;
		}
		
		public function set fit(value:String):void {
			if (_fit !== value) {
				_fit = value;
				align();
			}
		}
		
		public function get multiSelect():Boolean {
			return _multiSelect;
		}
		
		public function set multiSelect(value:Boolean):void {
			_multiSelect = value;
		}
		
		public function get toggle():Boolean {
			return _toggle;
		}
		
		public function set toggle(value:Boolean):void {
			if (value !== _toggle) {
				var i:int = _items.length;
				while (--i > -1) {
					_items[i].toggle = value;
					setListeners(_items[i], value);
				}
				_toggle = value;
			}
		}
		
		public function get firstItemSample():C_Button {
			return _firstItemSample;
		}
		
		public function set firstItemSample(value:C_Button):void {
			if (_firstItemSample) _firstItemSample.removeEventListener(C_Event.CHANGE, firstSampleChangeHandler);
			if (value) {
				value.addEventListener(C_Event.CHANGE, firstSampleChangeHandler);
				if (_items.length > 1) _items[0].sample = value;
				_existFirst = true;
			}
			else {
				_existFirst = false;
			}

			_firstItemSample = value;
		}
		
		public function get itemSample():C_Button {
			return _itemSample;
		}
		
		public function set itemSample(value:C_Button):void {
			if (_itemSample) _itemSample.removeEventListener(C_Event.CHANGE, itemSampleChangeHandler);
			if (value) {
				value.addEventListener(C_Event.CHANGE, itemSampleChangeHandler);
				_existSample = true;
			}
			else {
				_existSample = false;
			}
			
			_itemSample = value;
			refreshSkins();
		}
		
		public function get lastItemSample():C_Button {
			return _lastItemSample;
		}
		
		public function set lastItemSample(value:C_Button):void {
			if (_lastItemSample) _lastItemSample.removeEventListener(C_Event.CHANGE, lastSampleChangeHandler);
			if (value) {
				value.addEventListener(C_Event.CHANGE, lastSampleChangeHandler);
				if (_items.length > 1) _items[_items.length - 1].sample = value;
				_existLast = true;
			}
			else {
				_existLast = false;
			}
			_lastItemSample = value;
		}
		
		public function get singleItemSample():C_Button {
			return _singleItemSample;
		}
		
		public function set singleItemSample(value:C_Button):void {
			if (_singleItemSample) _singleItemSample.removeEventListener(C_Event.CHANGE, singleSampleChangeHandler);
			if (value) {
				value.addEventListener(C_Event.CHANGE, singleSampleChangeHandler);
				if (_items.length == 1) _items[0].sample = value;
				_existSingle = true;
			}
			else {
				_existSingle = false;
			}
			
			_singleItemSample = value;
		}
		
		//-----------------------------------------------------------------
		//	P U B L I C
		//-----------------------------------------------------------------
		public function deselectAll():void {
			var i:int = -1;
			while (++i < _items.length) {
				_items[i].selected = false;
				_items[i].enabled = true;
			}
			_lastSelectedIndex = -1;
		}
		
		public function getItemByLabel(text:String):C_Button {
			var index:int = getIndexByLabel(text);
			return (index > -1) ? _items[index] : null;
		}
		
		public function getIndexByLabel(text:String):int {
			var i:int = _items.length;
			var index:int = -1;
			
			while (--i > -1) {
				if (_items[i].text === text) {
					index = i;
					break;
				}
			}
			return index;
		}
		
		public function removeItemAt(index:int):void {
			if (index > -1 && index < _items.length) {
				setListeners(_items[index], false);
				_items.splice(index, 1);
				refreshSkins();
				align();
				
				dispatchEvent(new C_Event(C_Event.REMOVE, null, true));
			}
		}
		
		public function removeItem(item:C_Button):void {
			removeItemAt(_items.indexOf(item));
		}
		
		public function newItem(label:String, icon:BitmapData = null):C_Button {
			var button:C_Button = new C_Button(label);
			button.icon = icon;
			addItemAt(button, -1);
			return button;
		}
		
		public function insideAddItemAt(item:C_Button, index:int, dispatch:Boolean = true):C_Button {
			item.toggle = _toggle;
			if (!_toggle || (!_multiSelect && lastSelectedItem)) item.selected = false;
			
			setListeners(item, true);
			var tmpSelected:C_Button = lastSelectedItem;

			if (index < 0 || index > _items.length || _items.length == 0) {
				_items.push(item);
			}
			else if (_items.indexOf(item) !== index) {
				_items.splice(index, 0, item);
			}
			
			_lastSelectedIndex = _items.indexOf(tmpSelected);
			
			addChild(item);
			align();
			refreshSkins();
			
			if (dispatch) dispatchEvent(new C_Event(C_Event.ADD, null, true));
			
			return item;
		}
		
		public function addItemAt(item:C_Button, index:int):C_Button {
			return insideAddItemAt(item, index);
		}
		
		public function addItem(item:C_Button):C_Button {
			return insideAddItemAt(item, -1);
		}
		
		public function clear():void {
			if (_items.length == 0) return;
			
			var i:int = _items.length;
			while (--i > -1) {
				setListeners(_items[i], false);
				if (_items[i].parent === this) removeChild(_items[i]);
			}
			_items.length = 0;
			align();
		}

		//-----------------------------------------------------------------
		//	P R I V A T E
		//-----------------------------------------------------------------
		private function swapItems(from:int, to:int):void {
			if (from == to) return;
			
			_swapped = true;
			
			var sel:C_Button = lastSelectedItem;
			var item:C_Button = _items[from];
			
			_items.splice(from, 1);
			_items.splice(to, 0, item);
			
			_lastSelectedIndex = _items.indexOf(sel);
			refreshSkins();
			
			dispatchEvent(new C_Event(C_Event.SWAP, null, true));
		}
		
		private function setListeners(target:C_Button, enabled:Boolean):void {
			if (enabled) {
				target.addEventListener(C_Event.CHANGE_STATE, itemChangeHandler);
				target.addEventListener(C_Event.SELECT, itemSelectHandler);
				target.addEventListener(C_Event.RESIZE, itemResizeHandler);
			}
			else {
				target.removeEventListener(C_Event.CHANGE_STATE, itemChangeHandler);
				target.removeEventListener(C_Event.SELECT, itemSelectHandler);
				target.removeEventListener(C_Event.RESIZE, itemResizeHandler);
			}
		}
		
		protected function refreshSkins():void {
			var i:int = -1;
			var sample:C_Button;
			
			while (++i < _items.length) {
				if 		(_items.length == 1 && _existSingle)						{ sample = _singleItemSample}
				else if (i == 0 && _items.length > 1 && _existFirst)				{ sample = _firstItemSample }
				else if (i == _items.length - 1 && _items.length > 1 && _existLast)	{ sample = _lastItemSample }
				else if (_existSample)												{ sample = _itemSample }
				
				if (sample && _items[i].sample !== sample) {
					_items[i].copyFrom(sample, _bannedSampleProps, true);
				}
			}
		}
		
		private function align(animate:Boolean = false, animateTime:Number = 0.2, exception:C_Button = null, order:Boolean = true):void {
			var item:C_Button;
			var newSize:Object = { pos:0, width:0, height:0 };
			var spacing:Number = (_fit === SPACING) ? (this[lengthProp] - getItemsLength()) / (_items.length - 1) : _spacing;
			var itemLength:Number = (this[lengthProp] - (_items.length - 1) * _spacing) / _items.length;
			var prevOffset:Number = 0;
			var maxThick:Number = 0;
			var time:Number;
			var vars:Object;
			var i:int = -1;

			_snapshot.length = 0;
			_lockResize = true;
			
			while (++i < _items.length) {
				item = _items[i];
				item[antiAxis] = 0;
				
				newSize[lengthProp] = item[lengthProp];
				newSize[thickProp] = this[thickProp];

				if (_fit !== NONE) {
					if (_fit === ITEMS) {
						newSize[lengthProp] = Math.round((i * (itemLength + spacing)) + itemLength) - prevOffset;
					}
				}

				item.setSize(newSize.width, newSize.height);
				newSize.pos = Math.round(prevOffset);
				
				if (_items[i] !== exception) {
					if (animate) {
						time = Math.min(animateTime, (Math.abs(newSize.pos - item[_axis]) / 100) * animateTime);
						vars = { };
						vars[_axis] = newSize.pos;
						TweenMax.to(item, time, vars);
					}
					else {
						item[_axis] = newSize.pos;
					}
				}
				
				if (order) {
					setChildIndex(item, Math.max(numChildren-1, i));
				}
				
				prevOffset = newSize.pos + item[lengthProp] + spacing;
				maxThick = Math.max(_items[i][thickProp], maxThick);
				_snapshot.push(new itemPosition(item, newSize.pos, newSize[lengthProp]))
			}
			
			if (_fit === NONE && _items.length > 0) {
				
				item = _items[_items.length - 1];
				newSize[lengthProp] = item[_axis] + item[lengthProp];
				setSize(newSize.width, newSize.height);
			}
			
			_lockResize = false;
		}
		
		private function getItemsLength():Number {
			var length:Number = 0;
			var i:int = _items.length;
			
			while (--i > -1) length += _items[i][lengthProp];
			return length;
		}
		
		private function get antiAxis():String {
			return (_axis === X) ? Y : X;
		}
		
		private function get thickProp():String {
			return (_axis === X) ? 'height' : 'width';
		}
		
		private function get lengthProp():String {
			return (_axis === X) ? 'width' : 'height';
		}
		
	}

}

class itemPosition {
	import drops.ui.C_Button;
	
	public var position:Number;
	public var length:Number;
	public var item:C_Button;
	
	public function itemPosition(item:C_Button, position:Number, length:Number) {
		this.position = position;
		this.length = length;
		this.item = item;
	}
}