package drops.ui {
	import drops.events.C_Event;
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_Menu extends C_Button {
		private var _list:C_SelectList;
		
		private var _listPaddingLeft:Number;
		private var _listPaddingTop:Number;
		private var _listPaddingBottom:Number;
		
		private var _selectedIndex:int;
		
		public function C_Menu() {
			_listPaddingLeft = 0;
			_listPaddingTop = 0;
			_listPaddingBottom = 0;

			_list = new C_SelectList();
			_list.toggle = false;
			_list.turn();
			
			_list.addEventListener(MouseEvent.MOUSE_UP, listUpHandler);
			_list.addEventListener(C_Event.ANIMATION_COMPLETE, listAnimationComplete);
			addEventListener(MouseEvent.MOUSE_DOWN, mDownHandler);
		}
		
		//-------------------------------------------------------------
		//	H A N D L E R S
		//-------------------------------------------------------------
		private function listAnimationComplete(e:C_Event):void {
			if (!_list.expanded && stage) {
				stage.removeEventListener(MouseEvent.MOUSE_DOWN, stageDownHandler);
			}
		}
		
		private function listUpHandler(e:MouseEvent):void {
			_selectedIndex = _list.items.indexOf(e.target);
			dispatchEvent(new C_Event(C_Event.LIST_SELECT, e.target, true));
			turn();
		}
		
		private function stageDownHandler(e:MouseEvent):void {
			if (_list.expanded) {
				if (!this.contains(e.target as DisplayObject) && !_list.contains(e.target as DisplayObject)) turn();
			}
		}
		
		private function mDownHandler(e:MouseEvent):void {
			(_list.expanded && !_list.contains(e.target as DisplayObject)) ? turn() : expand();
		}
		
		//-------------------------------------------------------------
		//	S E T  /  G E T
		//-------------------------------------------------------------
		public function get selectedIndex():int {
			return _selectedIndex;
		}
		
		public function get selectedItem():C_Button {
			return (_selectedIndex > -1 && _selectedIndex < _list.items.length) ? _list.items[_selectedIndex] : null;
		}
		
		public function get listPaddingBottom():Number {
			return _listPaddingBottom;
		}
		
		public function set listPaddingBottom(value:Number):void {
			if (value == _listPaddingBottom) return;
			_listPaddingBottom = value;
			placeList();
		}
		
		public function get listPaddingTop():Number {
			return _listPaddingTop;
		}
		
		public function set listPaddingTop(value:Number):void {
			if (value == _listPaddingTop) return;
			_listPaddingTop = value;
			placeList();
		}
		
		public function get listPaddingLeft():Number {
			return _listPaddingLeft;
		}
		
		public function set listPaddingLeft(value:Number):void {
			if (value == _listPaddingLeft) return;
			_listPaddingLeft = value;
			placeList();
		}
		
		public function get list():C_SelectList {
			return _list;
		}

		//-------------------------------------------------------------
		//	P R I V A T E
		//-------------------------------------------------------------
		private function turn():void {
			_list.turn(true);
		}
		
		private function expand():void {
			if (!stage) return;
			stage.addEventListener(MouseEvent.MOUSE_DOWN, stageDownHandler);
			
			if (_list.parent !== stage) stage.addChild(_list);
			if (stage.getChildIndex(_list) < stage.numChildren -1) stage.setChildIndex(_list, stage.numChildren - 1);
			
			placeList();
			_list.expand(true);
		}
		
		private function placeList():void {
			if (!stage || _list.parent !== stage) return;
			
			var pt:Point = localToGlobal(new Point(this.x, this.y));
			
			_list.x = Math.max(0, pt.x) + _listPaddingLeft;
			
			if (pt.y + height + _list.height > stage.stageHeight) {
				_list.y = pt.y - _list.height - _listPaddingBottom;
			}
			else {
				_list.y = pt.y + height + _listPaddingTop;
			}
		}
	}

}