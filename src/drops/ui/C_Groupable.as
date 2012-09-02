package drops.ui {
	import drops.core.C_Box;
	import drops.events.C_Event;
	import flash.display.Sprite;
	import flash.events.Event;
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_Groupable extends C_Box {
		private var _neighbors:Array;
		private var _group:String;
		
		public function C_Groupable() {
			_neighbors = [];
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler);
		}
		
		//------------------------------------------------
		//	H A N D L E R S
		//------------------------------------------------
		private function removedFromStageHandler(e:Event):void {
			var neighbor:*;
			for each (neighbor in _neighbors) neighbor.callNeighbor(this, true);
		}
		
		private function addedToStageHandler(e:Event):void {
			updateNeighbors();
		}
		
		//------------------------------------------------
		//	S E T  /  G E T
		//------------------------------------------------
		public function get neighbors():Array {
			return _neighbors;
		}
		
		public function get group():String {
			return _group;
		}
		
		public function set group(name:String):void {
			_group = name;
			updateNeighbors();
		}
		
		//------------------------------------------------
		//	P U B L I C
		//------------------------------------------------
		public function callNeighbor(object:*, remove:Boolean = false):void {
			var index:int = _neighbors.indexOf(object);
			if (index > 0 && remove) {
				_neighbors.splice(index, 1);
				dispatchEvent(new C_Event(C_Event.CHANGE_NEIGHBORS));
			}
			else if (object.toString() == this.toString() && object != this && object.group && object.group == this.group) {
				_neighbors.push(object);
				dispatchEvent(new C_Event(C_Event.CHANGE_NEIGHBORS));
			}
		}
		
		public function getMaxLabelWidth():Number {
			var maxLabel:Number = (this.hasOwnProperty('label')) ? this['label'].width : 0;
			var obj:*;
			for each (obj in neighbors) if (obj.hasOwnProperty('label')) maxLabel = Math.max(maxLabel, obj.label.width);
			return maxLabel;
		}
		//------------------------------------------------
		//	P R I V A T E
		//------------------------------------------------
		private function updateNeighbors():void {
			if (parent) {
				var newArr:Array = [];
				var objStr:String = toString();
				var child:*;
				var mismatch:Boolean;
				var i:int = parent.numChildren;
				
				while (--i > -1) {
					child = parent.getChildAt(i);
					if (child.toString() == objStr && child != this && child.group && child.group == group) {
						if (_neighbors.indexOf(child) < 0) mismatch = true;
						newArr.push(child);
						child.callNeighbor(this);
					}
				}
				if (mismatch && _neighbors.length != newArr.length) dispatchEvent(new C_Event(C_Event.CHANGE_NEIGHBORS));
				_neighbors = newArr;
			}
			else {
				_neighbors = [];
			}
		}
	}

}