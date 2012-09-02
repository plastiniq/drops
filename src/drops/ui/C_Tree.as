package drops.ui {
	import drops.data.C_Emboss;
	import drops.data.C_Skin;
	import drops.events.C_Event;
	import drops.graphics.Emb;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_Tree extends Sprite {
		private var _expandedIcon:BitmapData;
		private var _turnedIcon:BitmapData;
		private var _selectedItem:C_Button;
		private var _mainItem:C_TreeItem;
		private var _folderSample:C_Button;
		private var _itemSample:C_Button;
		
		private var _pathColor:uint;
		private var _pathThickness:uint;
		
		private var _expandIcon:BitmapData;
		private var _turnIcon:BitmapData;
		
		public function C_Tree() {
			_mainItem = new C_TreeItem();
			addChild(_mainItem);
			
			_expandIcon = Emb.BUTTON_PLUS;
			_turnIcon = Emb.BUTTON_MINUS;
			
			_pathColor = 0xbdbdbd;
			_pathThickness = 1;
			

			_mainItem.addEventListener(C_Event.SELECT, selectHandler);
			_mainItem.addEventListener(C_Event.EXPAND, expandHandler);
			_mainItem.addEventListener(C_Event.TURN, turnHandler);
		}
		
		//-----------------------------------------------------------
		//	H A N D L E R S
		//-----------------------------------------------------------
		private function turnHandler(e:C_Event):void {
			dispatchEvent(new C_Event(C_Event.TURN));
		}
		
		private function expandHandler(e:C_Event):void {
			dispatchEvent(new C_Event(C_Event.EXPAND));
		}
		
		private function selectHandler(e:C_Event):void {
			if (_selectedItem) {
				_selectedItem.selected = false;
				_selectedItem.enabled = true;
			}
			
			if (e.data is C_Button) {
				C_Button(e.data).enabled = false;
				_selectedItem = e.data;
			}
			dispatchEvent(new C_Event(C_Event.SELECT, e.data, e.inside));
		}
		
		//-----------------------------------------------------------
		//	S E T  /  G E T
		//-----------------------------------------------------------
		public function get selectedItem():C_Button {
			return _selectedItem;
		}
		
		public function get turnIcon():BitmapData {
			return _turnIcon;
		}
		
		public function set turnIcon(value:BitmapData):void {
			if (value === _turnIcon) return;
			_turnIcon = value;
			_mainItem.turnIcon = value;
		}
		
		public function get expandIcon():BitmapData {
			return _expandIcon;
		}
		
		public function set expandIcon(value:BitmapData):void {
			if (_expandIcon === value) return;
			_expandIcon = value;
			_mainItem.expandIcon = value;
		}
		
		public function get folderSample():C_Button {
			return _folderSample;
		}
		
		public function set folderSample(value:C_Button):void {
			_folderSample = value;
			_mainItem.folderSample = value;
		}
		
		public function get itemSample():C_Button {
			return _itemSample;
		}
		
		public function set itemSample(value:C_Button):void {
			_itemSample = value;
			_mainItem.itemSample = value;
		}
		
		//-----------------------------------------------------------
		//	P U B L I C
		//-----------------------------------------------------------
		public function lineStyle(color:uint, thickness:Number = 1):void {
			_pathColor = color;
			_pathThickness = thickness;
			_mainItem.lineStyle(color, thickness);
		}
		
		public function setData(data:Object, labelKey:String, childrensKey:String, iconKey:String = null, dataKey:String = null, expanded:Boolean = false):void {
			if (_selectedItem) {
				_selectedItem.selected = false;
				_selectedItem.enabled = true;
			}

			_mainItem.lineStyle(_pathColor, _pathThickness);
			_mainItem.setData(data, labelKey, childrensKey, iconKey, dataKey, expanded);
			_mainItem.item.selected = true;
			_selectedItem = _mainItem.item;
			
			addChild(_mainItem);
			dispatchEvent(new C_Event(C_Event.CHANGE));
		}
		
		//-----------------------------------------------------------
		//	P R I V A T E
		//-----------------------------------------------------------
		
	}

}