package drops.ui 
{
	import drops.core.C_Box;
	import drops.data.C_Child;
	import drops.data.C_Description;
	import drops.data.C_Mounts;
	import drops.data.C_Property;
	import drops.data.C_Skin;
	import drops.data.C_SkinFrame;
	import drops.data.C_SkinManager;
	import drops.events.C_Event;
	import drops.utils.C_Display;
	import drops.utils.C_Easing;
	import com.greensock.TweenMax;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	
	 
	public class C_SelectList extends C_Box {
		private var _items:Vector.<C_Button>;
		private var _itemsData:Array;
		private var _itemHeight:Number;
		private var _numLines:int;
		private var _scroll:int;
		
		private var _toggle:Boolean;
		private var _multiSelect:Boolean;
		private var _autoWidth:Boolean;
		private var _expanded:Boolean;
		
		private var _renderEnabled:Boolean;
		private var _renderCalled:Boolean;
		
		private var _lastSelectedIndex:int;
		
		private var _paddingLeft:Number;
		private var _paddingRight:Number;
		private var _paddingTop:Number;
		private var _paddingBottom:Number;

		private var _scrollBar:C_ScrollBar;
		
		private var _itemSample:C_Button;
		private var _singleItemSample:C_Button;
		private var _firstItemSample:C_Button;
		private var _lastItemSample:C_Button;
		
		private var _removeHandlerEnabled:Boolean;
		
		private var _disableStage:Boolean;
		private var _sessionName:String;
		
		private var _beginAnimation:String;
		public static const NONE:String = 'none';
		public static const SHOW:String = 'show';
		public static const HIDE:String = 'hide';
		
		private static const EXCEPTED_PROPS:Array = ['contentOffsetX', 'contentOffsetY', 'paddingTop', 'paddingBottom', 'paddingLeft', 'paddingRight', 'textFormat'];
		
		public static var description:C_Description = new C_Description(); 
		description.setContainer('addItem', [C_Button]);
		description.transparent = true;
		description.lockChildrensSkin = true;
		
		description.pushChild(new C_Child('Scroll Bar', 'scrollBar'));
		description.pushChild(new C_Child('Item Sample', 'itemSample'));
		description.pushChild(new C_Child('First Item Sample', 'firstItemSample'));
		description.pushChild(new C_Child('Last Item Sample', 'lastItemSample'));
		description.pushChild(new C_Child('Single Item Sample', 'singleItemSample'));
		
		description.pushGroup('Mounts');
		description.lastGroup.pushProperty(C_Property.MOUNTS, 'mounts');
		description.pushGroup('Properties');
		description.lastGroup.pushProperty(C_Property.NUMBER, 'paddingLeft', 'Padding Left');
		description.lastGroup.pushProperty(C_Property.NUMBER, 'paddingTop', 'Padding Top');
		description.lastGroup.pushProperty(C_Property.NUMBER, 'paddingRight', 'Padding Right');
		description.lastGroup.pushProperty(C_Property.NUMBER, 'paddingBottom', 'Padding Bottom');
		description.lastGroup.pushProperty(C_Property.NUMBER, 'itemHeight', 'Item Height');
		
		description.lastGroup.pushProperty(C_Property.NUMBER, 'numLines', 'Lines');
		description.lastGroup.pushProperty(C_Property.BOOLEAN, 'autoWidth', 'Auto Width');
		
		public function C_SelectList(disableStage:Boolean = false) {
			setSize(100, 50);
			
			_sessionName = name;
			_disableStage = disableStage;
			
			_toggle = true;
			_multiSelect = false;
			_lastSelectedIndex = -1;
			_autoWidth = true;
			_expanded = true;
			_numLines = 12;
			_scroll = 0;
			_itemHeight = 20;
			_paddingLeft = 5;
			_paddingRight = 5;
			_paddingTop = 3;
			_paddingBottom = 3;

			_renderEnabled = true;
			_renderCalled = false;
			
			_removeHandlerEnabled = true;
			
			_itemsData = [];
			_items = new Vector.<C_Button>();
			
			_itemSample = new C_Button();
			_firstItemSample = new C_Button();
			_lastItemSample = new C_Button();
			_singleItemSample = new C_Button();
			
			_scrollBar = new C_ScrollBar();
			_scrollBar.orientation = C_ScrollBar.Y;
			_scrollBar.visible = false;
			placeScroll();
			addChild(_scrollBar);
			
			_itemSample.addEventListener(C_Event.CHANGE, sampleChangeHandler);
			_firstItemSample.addEventListener(C_Event.CHANGE, sampleChangeHandler);
			_lastItemSample.addEventListener(C_Event.CHANGE, sampleChangeHandler);
			_singleItemSample.addEventListener(C_Event.CHANGE, sampleChangeHandler);
			
			_scrollBar.addEventListener(C_Event.CHANGE, scrollChangeHandler);
			addEventListener(Event.REMOVED, removedHandler);
			addEventListener(C_Event.RESIZE, resizeHandler);
		}
		
		//------------------------------------------------------------
		//	H A N D L E R S
		//------------------------------------------------------------
		private function animationComplete(target:*, visible:Object = null, allComplete:Boolean = false):void {
			if (_beginAnimation == HIDE) {
				target.visible = false;
			}
			else if (target == _scrollBar) {
				placeScroll();
			}
			
			if (visible !== null) this.visible = visible;
			
			if (allComplete) dispatchEvent(new C_Event(C_Event.ANIMATION_COMPLETE, _beginAnimation));
			_beginAnimation = NONE;
		}
		
		private function sampleChangeHandler(e:C_Event):void {
			refreshSamples();
		}
		
		private function scrollChangeHandler(e:C_Event):void {
			_scroll = _scrollBar.scroll;
			refresh();
		}
		
		private function resizeHandler(e:C_Event):void {
			if (e.data == C_Box.WIDTH || e.data == C_Box.BOTH) {
				refresh();
			}
		}
		
		private function removedHandler(e:Event):void {
			if (e.target !== this && _items.indexOf(e.target) > -1 && _removeHandlerEnabled) {
				setListeners(e.target as C_Button, false);
				_items.splice(_items.indexOf(e.target), 1);
				refreshScroll();
				refresh();
			}
		}
		
		private function itemSelectHandler(e:C_Event):void {
			if (_toggle && !_multiSelect) {
				C_Button(e.target).enabled = false;
				if (lastSelectedItem) {
					lastSelectedItem.selected = false;
					lastSelectedItem.enabled = true;
				}
			}
			_lastSelectedIndex = _items.indexOf(e.target);
			dispatchEvent(new C_Event(C_Event.SELECT, e.target, e.inside));
		}
		
		//------------------------------------------------------------
		//	S E T  /  G E T
		//------------------------------------------------------------
		public function get paddingBottom():Number {
			return _paddingBottom;
		}
		
		public function set paddingBottom(value:Number):void {
			if (value == _paddingBottom) return;
			_paddingBottom = value;
			refresh();
		}
		
		public function get paddingRight():Number {
			return _paddingRight;
		}
		
		public function set paddingRight(value:Number):void {
			if (value == _paddingRight) return;
			_paddingRight = value;
			refresh();
		}
		
		public function get paddingTop():Number {
			return _paddingTop;
		}
		
		public function set paddingTop(value:Number):void {
			if (value == _paddingTop) return;
			_paddingTop = value;
			refresh();
		}
		
		public function get paddingLeft():Number {
			return _paddingLeft;
		}
		
		public function set paddingLeft(value:Number):void {
			if (value == _paddingLeft) return;
			_paddingLeft = value;
			refresh();
		}
		
		public function get lastItemSample():C_Button {
			return _lastItemSample;
		}
		
		public function set lastItemSample(value:C_Button):void {
			if (_lastItemSample === value) return;
			if (_lastItemSample) _lastItemSample.removeEventListener(C_Event.CHANGE, sampleChangeHandler);
			if (value) value.addEventListener(C_Event.CHANGE, sampleChangeHandler);
			_lastItemSample = value;
			refresh();
		}
		
		public function get singleItemSample():C_Button {
			return _singleItemSample;
		}
		
		public function set singleItemSample(value:C_Button):void {
			if (_singleItemSample === value) return;
			if (_singleItemSample) _singleItemSample.removeEventListener(C_Event.CHANGE, sampleChangeHandler);
			if (value) value.addEventListener(C_Event.CHANGE, sampleChangeHandler);
			_singleItemSample = value;
			refresh();
		}
		
		public function get itemSample():C_Button {
			return _itemSample;
		}
		
		public function set itemSample(value:C_Button):void {
			if (_itemSample === value) return;
			if (_itemSample) _itemSample.removeEventListener(C_Event.CHANGE, sampleChangeHandler);
			if (value) value.addEventListener(C_Event.CHANGE, sampleChangeHandler);
			_itemSample = value;
			refresh();
		}
		
		public function get firstItemSample():C_Button {
			return _firstItemSample;
		}
		
		public function set firstItemSample(value:C_Button):void {
			if (_firstItemSample === value) return;
			if (_firstItemSample) _firstItemSample.removeEventListener(C_Event.CHANGE, sampleChangeHandler);
			if (value) value.addEventListener(C_Event.CHANGE, sampleChangeHandler);
			_firstItemSample = value;
			refresh();
		}
		
		public function get scrollBar():C_ScrollBar {
			return _scrollBar;
		}
		
		public function get items():Vector.<C_Button>{
			return _items;
		}
		
		public function get lastSelectedIndex():int {
			return _lastSelectedIndex;
		}
		
		public function get lastSelectedItem():C_Button {
			return (_lastSelectedIndex > -1 && _lastSelectedIndex < _items.length) ? _items[_lastSelectedIndex] : null;
		}
		
		public function get expanded():Boolean {
			return _expanded;
		}
		
		public function get autoWidth():Boolean {
			return _autoWidth;
		}
		
		public function set autoWidth(value:Boolean):void {
			if (_autoWidth != value) {
				_autoWidth = value;
				refreshAutoWidth();
			}
		}
		
		public function get toggle():Boolean {
			return _toggle;
		}
		
		public function set toggle(value:Boolean):void {
			if (!value) {
				if (lastSelectedItem) lastSelectedItem.selected = false;
				_lastSelectedIndex = -1;
			}
			_toggle = value;
		}
		
		public function get multiSelect():Boolean {
			return _multiSelect;
		}
		
		public function set multiSelect(value:Boolean):void {
			if (value != _multiSelect) {
				_multiSelect = value;
				if (!value) {
					var i:int = _items.length;
					while (--i > -1) _items[i].selected = (i == _lastSelectedIndex);
				}
			}
		}
		
		public function get numLines():int {
			return _numLines;
		}
		
		public function set numLines(value:int):void {
			if (value === _numLines) return;
			_scroll = 0;
			_numLines = value;
			refreshScroll();
			refresh();
		}
		
		public function get itemHeight():Number {
			return _itemHeight;
		}
		
		public function set itemHeight(value:Number):void {
			if (_itemHeight != value) {
				_itemHeight = value;
				refresh();
			}
		}
		
		//------------------------------------------------------------
		//	O V E R R I D E D
		//------------------------------------------------------------
		override public function set width(value:Number):void {
			_autoWidth = false;
			super.width = value;
		}
		
		override public function set height(value:Number):void {
			numLines = (value - _paddingTop - _paddingBottom) / _itemHeight;
			super.height = value;
		}
		
		//------------------------------------------------------------
		//	P U B L I C
		//------------------------------------------------------------
		public function addItem(item:C_Button):void {
			item.x = 0;
			privateAddItem(item, true);
		}
		
		public function getButtonByLabel(label:String):C_Button {
			var result:C_Button;
			var i:int = _items.length;
			
			while (--i > -1) {
				if (_items[i].text === label) {
					result = _items[i];
					break;
				}
			}
			return result;
		}
		
		public function getAutoWidthValue():Number {
			var i:int = _items.length;
			var value:Number = 0;
			while (--i > -1) {
				value = Math.max(value, _items[i].content.width);
			}
			return value + _paddingLeft + _paddingRight;
		}
		
		public function setData(data:Array, labelKey:String = null, iconKey:String = null, dataKey:String = null, selectedIndex:int = 0):void {
			clear();
			_scroll = 0;
			_lastSelectedIndex = -1;
			var item:C_Button;
			var i:int = -1;
			
			while (++i < data.length) {
				item = new C_Button((labelKey) ? data[i][labelKey] : data[i]);
				item.stopRender();
				item.copyFrom(_itemSample);
				if (iconKey && data[i][iconKey]) item.icon = data[i][iconKey];
				if (dataKey && data[i][dataKey]) item.data = data[i][dataKey];
				privateAddItem(item, false);
				item.beginRender();
			}
			
			if (_items.length && selectedIndex > -1 && selectedIndex < _items.length && _toggle) _items[selectedIndex].selected = true;
			refreshScroll();
			
			if (_autoWidth) {
				refreshAutoWidth();
			}
			else {
				refresh();
			}

			dispatchEvent(new C_Event(C_Event.UPDATE));
		}
		
		public function deselectAll():void {
			if (_items.length == 0) return;
			
			var i:int = _items.length;
			while (--i > -1) {
				_items[i].selected = false;
				_items[i].enabled = true;
			}
			_lastSelectedIndex = -1;
		}
		
		public function clear():void {
			_removeHandlerEnabled = false;
			var i:int = -1;
			while (++i < _items.length) {
				if (_items[i].parent) _items[i].parent.removeChild(_items[i]);
				setListeners(_items[i], false);
			}
			_items.length = 0;
			_removeHandlerEnabled = true;
		}
		
		public function beginRender():void {
			_renderEnabled = true;
			if (_renderCalled) {
				refresh();
			}
		}
		
		public function stopRender():void {
			_renderEnabled = false;
		}
		
		public function expand(animate:Boolean = false):void {
			applyState(true, animate);
			if (_disableStage) disableEnvironment();
		}
		
		public function turn(animate:Boolean = false):void {
			applyState(false, animate);
			if (_disableStage) restoreEnvironment();
		}
		
		//------------------------------------------------------------
		//	P R I V A T E
		//------------------------------------------------------------
		private function disableEnvironment():void {
			C_Display.disable(_sessionName, stage, this);
		}
		
		private function restoreEnvironment():void {
			C_Display.restore(_sessionName);
		}
		
		private function privateAddItem(item:C_Button, refreshAfter:Boolean):void {
			item.stopRender();
			item.toggle = _toggle;
			item.paddingTop = 0;
			item.paddingBottom = 0;
			item.cropContent = true;
			item.height = _itemHeight;
			item.contentAlignX = C_Button.LEFT;
			setListeners(item, true);
			item.beginRender();
			_items.push(item);
			addChild(item);

			if (refreshAfter) {
				refreshScroll();
				refresh();
				dispatchEvent(new C_Event(C_Event.UPDATE));
			}
		}
		
		private function applyState(expand:Boolean, animate:Boolean):void {
			if (expand == _expanded) return;
			if (!animate) {
				visible = expand;
				_expanded = expand;
				return;
			}
			
			visible = true;
			
			var i:int = _scroll - 1;
			var endItem:int = Math.min(_items.length, _scroll + _numLines);
			var delay:Number = 0;
			var fromX:Number;
			var scrollFromX:Number;
			var toX:Number;
			var scrollToX:Number;
			var fromAlpha:Number;
			var toAlpha:Number;

			if (expand) {
				fromX = -width * 0.2;
				toX = 0;
				scrollFromX = _scrollBar.x - width * 0.2 - _scrollBar.width;
				scrollToX = width - _paddingRight - _scrollBar.width;
				fromAlpha = 0;
				toAlpha = 1;
			}
			
			else {
				fromX = 0;
				toX = width * 0.1;
				scrollFromX = _scrollBar.x;
				scrollToX = _scrollBar.x + width * 0.15;
				fromAlpha = 1;
				toAlpha = 0;
			}
			
			while (++i < endItem) {
				_items[i].visible = true;
				_items[i].x = fromX;
				_items[i].alpha = fromAlpha;
				_beginAnimation = (expand) ? SHOW : HIDE;
				delay = C_Easing.easeInSine(0, i - _scroll, 0, (endItem - _scroll) / 60, endItem - _scroll);
				TweenMax.to(_items[i], 0.1, { x:toX, alpha:toAlpha, delay:delay, onComplete:animationComplete, onCompleteParams:[_items[i], null, (i == endItem - 1)] } );
			}

			_scrollBar.mounts = null;
			_scrollBar.visible = (_items.length > _numLines);
			_scrollBar.x = scrollFromX;
			_scrollBar.alpha = fromAlpha;
			TweenMax.to(_scrollBar, 0.1, { x:scrollToX, alpha:toAlpha, delay:delay * 0.3, onComplete:animationComplete, onCompleteParams:[_scrollBar, expand] } );

			_expanded = expand;
		}
		
		private function refreshScroll():void {
			if (_items.length > _numLines) {
				_scrollBar.scroll = _scroll;
				_scrollBar.all = _items.length;
				_scrollBar.shown = _numLines;
				_scrollBar.visible = true;
				setChildIndex(_scrollBar, numChildren - 1);
			}
			else {
				_scrollBar.visible = false;
			}
		}
		
		private function placeScroll(itemsHeight:Object = null):void {
			_scrollBar.mounts = new C_Mounts(null, _paddingRight, _paddingTop);
			_scrollBar.height = ((itemsHeight) ? Number(itemsHeight): height) - _paddingBottom - _paddingTop;
		}
		
		private function refresh():void {
			
			if (!_renderEnabled) {
				_renderCalled = true;
				return;
			}
			
			var i:int = -1;
			var sample:C_Button;
			var item:C_Button;
			var newHeight:Number;
			var contentOffsetY:Number;
			var endLine:int = Math.min(_items.length, _numLines);
			var totalHeight:Number = 0;

			while (++i < _items.length) {
				
				if (i >= _scroll && i < (_scroll + _numLines)) {
					item = _items[i];
					item.stopRender();
					
					sample = _itemSample;
					newHeight = _itemHeight;
					contentOffsetY = 0;
					
					if (i == _scroll && _items.length == 1) {
						sample = _singleItemSample;
						newHeight = _itemHeight + _paddingTop + _paddingBottom;
						contentOffsetY = 0;
					}
					else if (i == _scroll) {
						sample = _firstItemSample;
						newHeight = _itemHeight + _paddingTop;
						contentOffsetY = _paddingTop / 2;
					}
					else if (i == _scroll + endLine - 1) {
						sample = _lastItemSample;
						newHeight = _itemHeight + _paddingBottom;
						contentOffsetY = -_paddingBottom / 2;
					}
					
					if (item.sample !== sample) item.copyFrom(sample, EXCEPTED_PROPS, true);
					item.paddingLeft = _paddingLeft;
					item.paddingRight = _paddingRight;
					item.contentOffsetY = contentOffsetY;
					item.setSize(width, newHeight);
					item.y = totalHeight;
					item.x = 0;
					item.visible = true;
					item.beginRender();
					totalHeight = item.y + item.height;
				}
				else {
					_items[i].visible = false;
				}
			}
			super.height = Math.max(totalHeight, _itemHeight);
			placeScroll(totalHeight);
		}
		
		private function refreshSamples():void {
			var item:C_Button;
			var i:int = -1;
			var endLine:int = Math.min(_items.length, _numLines);
			var sample:C_Button;
			
			while (++i < _items.length) {
				item = _items[i];
				
				if (i >= _scroll && i < (_scroll + _numLines)) {
					
					if (i == _scroll && _items.length == 1) {
						sample = _singleItemSample;
					}
					else if (i == _scroll && _items.length > 1) {
						sample = _firstItemSample;
					}
					else if (i == _scroll + endLine - 1 && _items.length > 1) {
						sample = _lastItemSample;
					}
					else {
						sample = _itemSample;
					}
					
					item.copyFrom(sample, EXCEPTED_PROPS)
				}
			}	
		}
		
		private function refreshAutoWidth():void {
			if (!_autoWidth) return;
			var w:Number = getAutoWidthValue();
			if (w == width) refresh();
			super.width = w;
		}
		
		private function setListeners(target:C_Button, enabled:Boolean):void {
			if (enabled) {
				target.addEventListener(C_Event.SELECT, itemSelectHandler);
			}
			else {
				target.removeEventListener(C_Event.SELECT, itemSelectHandler);
			}
		}
	}

}