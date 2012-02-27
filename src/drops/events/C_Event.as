package drops.events 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_Event extends Event {
		
		public static const RESIZE:String = "rc_esize";
		public static const SELECT:String = "c_select";
		public static const LIST_SELECT:String = "c_list_select";
		public static const CLOSE:String = "c_close";
		public static const OPEN:String = "c_open";
		public static const UPDATE:String = "c_update";
		public static const ENABLE:String = "c_enable";
		public static const DISABLE:String = "c_disable";
		
		public static const CHANGE:String = "c_change";
		public static const CHANGE_COMPLETE:String = "c_changeComplete";
		public static const CHANGE_TEXT:String = "c_changeText";
		public static const CHANGE_NEIGHBORS:String = "c_changeNeighbors";
		public static const CHANGE_SKIN:String = "c_changeSkin";
		public static const CHANGE_STATE:String = "c_changeState";
		public static const CHANGE_POSITION:String = "c_changePosition";
		
		public static const ALL_COMPLETE:String = "c_allComplete";
		public static const ANIMATION_BEGIN:String = "c_animationBegin";
		public static const ANIMATION_COMPLETE:String = "c_animationComplete";
		public static const UPDATE_COMPLETE:String = "c_updateComplete";
		public static const PROGRESS:String = "c_progress";
		
		public static const ADD:String = "c_add";
		public static const REMOVE:String = "c_remove";
		public static const SWAP:String = "c_swap";
		public static const SWAP_COMPLETE:String = "c_swapComplete";
		public static const EXPAND:String = 'c_expand';
		public static const TURN:String = 'c_turn';
		
		public static const MOUSE_OVER:String = 'c_mouseOver';
		public static const MOUSE_OUT:String = 'c_mouseOut';
		
		public static const RESET:String = "c_reset";
		public static const FLIP:String = "c_flip";
		
		public static const CREATION_COMPLETE:String = "c_creationComplete";
		
		private var _data:*;
		private var _inside:Boolean;
		
		public function C_Event(type:String, data:* = null, inside:Boolean = false, bubbles:Boolean = false, cancelable:Boolean = false) { 
			super(type, bubbles, cancelable);
			_data = data;
			_inside = inside;
		} 
		
		public override function clone():Event { 
			return new C_Event(type, data, inside, bubbles, cancelable);
		} 
		
		public override function toString():String { 
			return formatToString("type", "data", "inside", "bubbles", "cancelable"); 
		}
		
		public function get inside():Boolean {
			return _inside;
		}
		
		public function get data():* {
			return _data;
		}
		
	}
	
}