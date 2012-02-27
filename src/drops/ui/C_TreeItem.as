package drops.ui {
	import drops.data.C_Skin;
	import drops.events.C_Event;
	import drops.graphics.DashedLine;
	import drops.graphics.Emb;
	import drops.utils.C_Accessor;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.geom.Point;
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_TreeItem extends Sprite {
		public var parentItem:C_TreeItem;
		
		private var _expandButton:C_Button;
		private var _item:C_Button;
		private var _childrensData:Array;
		private var _childrensItems:Vector.<C_TreeItem>;
		private var _indent:Number;
		private var _leading:Number;
		private var _expanded:Boolean;
		private var _folderSample:C_Button;
		private var _itemSample:C_Button;
		private var _pathColor:uint;
		private var _pathThickness:Number;
		
		private var _renderEnabled:Boolean;
		private var _renderCalled:Boolean;
		
		private var _expandIcon:BitmapData;
		private var _turnIcon:BitmapData;
		
		private var _status:String;
		private static const FOLDER:String = 'folder';
		private static const ITEM:String = 'item';
		private static const UNDEFINED:String = 'undefined';
		
		public function C_TreeItem() {
			_expandIcon = Emb.BUTTON_PLUS;
			_turnIcon = Emb.BUTTON_MINUS;
			_folderSample = new C_Button();
			_pathColor = 0xbdbdbd;
			_pathThickness = 1;
			
			_status = UNDEFINED;
			_renderEnabled = true;
			_renderCalled = false;
			
			_childrensItems = new Vector.<C_TreeItem>();
			_childrensData = [];
			_indent = 10;
			_leading = 4;
			_item = new C_Button();
			_item.setAllPadding(0);
			_item.paddingTop = 1
			_item.paddingBottom = 1
			_item.sample = _folderSample;
			_item.toggle = true;
			addChild(_item);
			
			_item.addEventListener(C_Event.SELECT, itemSelectHandler);
		}
		
		//-------------------------------------------------------------------
		//	H A N D L E R S
		//-------------------------------------------------------------------
		private function expandChangeHandler(e:C_Event):void {
			insideState(!_expandButton.selected, true);
		}
		
		private function childTurnHandler(e:C_Event):void {
			refresh();
			dispatchEvent(new C_Event(C_Event.TURN, null, e.inside));
		}
		
		private function childExpandHandler(e:C_Event):void {
			refresh();
			dispatchEvent(new C_Event(C_Event.EXPAND, null, e.inside));
		}
		
		private function itemSelectHandler(e:C_Event):void {
			dispatchEvent(new C_Event(C_Event.SELECT, e.data, e.inside));
		}
		
		private function childSelectHandler(e:C_Event):void {
			dispatchEvent(new C_Event(C_Event.SELECT, e.data, e.inside));
		}
		
		//-------------------------------------------------------------------
		//	S E T  /  G E T
		//-------------------------------------------------------------------
		public function get item():C_Button {
			return _item;
		}
		
		public function get status():String {
			return _status;
		}
		
		public function get turnIcon():BitmapData {
			return _turnIcon;
		}
		
		public function set turnIcon(value:BitmapData):void {
			if (value === _turnIcon) return;
			_turnIcon = value;
			var i:int = _childrensItems.length;
			while (--i > -1) _childrensItems[i].turnIcon = value;
			refresh();
		}
		
		public function get expandIcon():BitmapData {
			return _expandIcon;
		}
		
		public function set expandIcon(value:BitmapData):void {
			if (_expandIcon === value) return;
			_expandIcon = value;
			var i:int = _childrensItems.length;
			while (--i > -1) _childrensItems[i].expandIcon = value;
			refresh();
		}
		
		public function get itemSample():C_Button {
			return _itemSample;
		}
		
		public function set itemSample(value:C_Button):void {
			_itemSample = value;
			var i:int = _childrensItems.length;
			while (--i > -1) _childrensItems[i].itemSample = value;
			refresh();
		}

		public function get folderSample():C_Button {
			return _folderSample;
		}
		
		public function set folderSample(value:C_Button):void {
			_folderSample = value;
			var i:int = _childrensItems.length;
			while (--i > -1) _childrensItems[i].folderSample = value;
			refresh();
		}
		
		internal function get mountOffset():Number {
			return (_childrensData.length > 0) ? _expandButton.y + _expandButton.height * 0.5 : _item.height * 0.5;
		}
		
		//-------------------------------------------------------------------
		//	P U B L I C
		//-------------------------------------------------------------------
		public function lineStyle(color:uint, thickness:Number):void {
			_pathColor = color;
			_pathThickness = thickness;
			refresh();
			
			var i:int = _childrensItems.length;
			while (--i > -1) {
				_childrensItems[i].lineStyle(color, thickness);
			}
		}
		
		public function beginRender():void {
			_renderEnabled = true;
			
			if (_renderCalled) {
				refresh();
				_renderCalled = false;
			}
			
			var i:int = _childrensItems.length;
			while (--i > -1) _childrensItems[i].beginRender();
		}
		
		public function stopRender():void {
			_renderEnabled = false;
			var i:int = _childrensItems.length;
			while (--i > -1) _childrensItems[i].stopRender();
		}
		
		public function setData(data:Object, labelKey:String, childrensKey:String, iconKey:String = null, dataKey:String = null, expanded:Boolean = false):void {
			clear();
			if (data === null) return;
			
			var childs:Array = C_Accessor.getTarget(data, childrensKey);
			_childrensData = (childs) ? childs.slice(0) : [];
			_expanded = expanded;
			_status = (_childrensData.length > 0) ? FOLDER : ITEM;
			
			if (_status === FOLDER) {
				if (!_expandButton) {
					_expandButton = addChild(new C_Button()) as C_Button;
					_expandButton.addEventListener(C_Event.CHANGE_STATE, expandChangeHandler);
					_expandButton.stopRender();
					_expandButton.toggle = true;
					_expandButton.setAllPadding(0);
					_expandButton.skin = new C_Skin();
					_expandButton.beginRender();
				}
				_expandButton.selected = !expanded;
			}
			
			_item.text = data[labelKey];
			if (iconKey && data.hasOwnProperty(iconKey)) _item.icon = data[iconKey];
			if (dataKey && data.hasOwnProperty(dataKey)) _item.data = data[dataKey];

			var i:int = -1;
			var oY:Number = _item.height;
			var treeItem:C_TreeItem;
			
			while (++i < _childrensData.length) {
				treeItem = new C_TreeItem();
				treeItem.stopRender();
				treeItem.lineStyle(_pathColor, _pathThickness);
				treeItem.itemSample = _itemSample;
				treeItem.folderSample = _folderSample;
				treeItem.expandIcon = _expandIcon;
				treeItem.turnIcon = _turnIcon;
				treeItem.setData(_childrensData[i], labelKey, childrensKey, iconKey, dataKey, expanded);
				treeItem.parentItem = this;
				treeItem.beginRender();
				setListeners(treeItem, true);
				_childrensItems.push(treeItem);
			}
			
			refresh();
		}
		
		public function clear():void {
			var i:int = _childrensItems.length;
			var item:C_TreeItem;
			
			while (--i > -1) {
				item = _childrensItems[i];
				setListeners(item, false);
				item.clear();
				if (item.parent == this) this.removeChild(item);
			}
			_childrensItems.length = 0;
			_childrensData.length = 0;
		}
		
		//-------------------------------------------------------------------
		//	P R I V A T E
		//-------------------------------------------------------------------
		private function insideState(expanded:Boolean, inside:Boolean):void {
			if (expanded === _expanded) return;
			_expanded = expanded;
			refresh();
			dispatchEvent(new C_Event((expanded)? C_Event.EXPAND : C_Event.TURN, null, inside));
		}
		
		private function refresh():void {
			if (!_renderEnabled) {
				_renderCalled = true;
				return;
			}

			applySkins();
		
			var oX:Number = 3;
			var oY:Number = _item.height + _leading;
			var lineX:Number = 0;
			var endLineY:Number;

			if (_status === FOLDER) {
				_expandButton.visible = true;
				_expandButton.icon = _turnIcon;
				_expandButton.selectedIcon = _expandIcon;
				_expandButton.y = Math.round((_item.height * 0.5) - (_expandButton.height * 0.5));
				lineX = Math.round(_expandButton.width * 0.5);
				oX = _expandButton.width + 4;
			}
			else if (_expandButton !== null) {
				_expandButton.visible = false;
			}

			_item.x = oX;
			
			var i:int = -1;
			graphics.clear();
			DashedLine.beginDraw(_pathColor, 1, _pathThickness, 1, 1, true);

			while (++i < _childrensItems.length) {
				if (_expanded) {
					addChild(_childrensItems[i]);
					_childrensItems[i].x = Math.round(oX + _indent);
					_childrensItems[i].y = Math.round(oY);
					endLineY = int(oY + _childrensItems[i].mountOffset);
					DashedLine.moveTo(lineX, endLineY);
					DashedLine.lineTo(_childrensItems[i].x - 2, endLineY, this.graphics);
					oY += _childrensItems[i].height + _leading;
				}
				else if (_childrensItems[i].parent == this) {
					removeChild(_childrensItems[i]);
				}
			}

			if (_expanded && _status === FOLDER) {
				DashedLine.moveTo(Math.round(_expandButton.width * 0.5), _expandButton.y + _expandButton.height);
				DashedLine.lineTo(Math.round(_expandButton.width * 0.5), endLineY, this.graphics);
			}
		}
		
		private function applySkins():void {
			if (_status === FOLDER && _folderSample) {
				_item.sample = _folderSample;
			}
			else if (_status === ITEM && _itemSample) {
				_item.sample = _itemSample;
			}
			else if (_itemSample || _folderSample) {
				_item.sample = (_itemSample) ? _itemSample : _folderSample;
			}
		}
		
		private function setListeners(target:EventDispatcher, enabled:Boolean):void {
			if (enabled) {
				target.addEventListener(C_Event.EXPAND, childExpandHandler);
				target.addEventListener(C_Event.TURN, childTurnHandler);
				target.addEventListener(C_Event.SELECT, childSelectHandler);
			}
			else {
				target.removeEventListener(C_Event.EXPAND, childExpandHandler);
				target.removeEventListener(C_Event.TURN, childTurnHandler);
				target.removeEventListener(C_Event.SELECT, childSelectHandler);
			}
		}
	}

}