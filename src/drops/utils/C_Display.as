package drops.utils {
	import com.adobe.protocols.dict.events.DisconnectedEvent;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_Display {
		
		private static const GLOBAL_DISABLED:Dictionary = new Dictionary(true);
		private static const DISABLED_SESSIONS:Object = { };
		
		public static function disable(sessionName:String, target:InteractiveObject, exception:DisplayObject = null):void {
			if (DISABLED_SESSIONS[sessionName] || !target) return;
			DISABLED_SESSIONS[sessionName] = new Dictionary();
			disableTarget(target, DISABLED_SESSIONS[sessionName], exception);
		}
		
		public static function restore(sessionName:String):void {
			if (!DISABLED_SESSIONS[sessionName]) return;
			var dict:Dictionary = DISABLED_SESSIONS[sessionName];
			var key:*;
			for (key in dict) {
				delete GLOBAL_DISABLED[key];
				var key2:String;
				for (key2 in dict[key]) {
					key[key2] = dict[key][key2];
				}
			}
			delete DISABLED_SESSIONS[sessionName];
		}
		
		
		public static function getNumericValue(value:Object, relatively:Number, rest:Boolean = false):Number {
			var nValue:Number = numberFromObject(value);
			if (valueIsPercent(value)) {
				nValue = (rest) ? Math.floor((nValue / 100) * relatively) : Math.ceil((nValue / 100) * relatively);
			}
			return nValue;
		}
		
		public static function numberFromObject(value:Object):Number {
			if (value is Number) return value as Number;
			var nValue:Number = Number(value);
			if (!isNaN(nValue)) return nValue;
			
			nValue = Number(String(value).replace(/[^\d\.\,\-]/g, ''));
			return (isNaN(nValue)) ? 0 : nValue;
		}
		
		public static function valueIsPercent(value:Object):Boolean {
			return (String(value).search('%') > -1) ;
		}
		
		public static function transferTo(object:DisplayObject, to:DisplayObject):DisplayObject {
			if (object !== null && to !== null) {
				if (object.parent) {
					var pt:Point = coordToSpace(object.parent, to, object.x, object.y);
					object.x = pt.x;
					object.y = pt.y;
					object.parent.removeChild(object);
				}
				Sprite(to).addChild(object);
			}
			return object;
		}
		
		public static function rectToSpace(from:DisplayObject, to:DisplayObject, rectangle:Rectangle):Rectangle {
			var pt:Point = coordToSpace(from, to, rectangle.x, rectangle.y);
			return new Rectangle(pt.x, pt.y, rectangle.width, rectangle.height);
		}
		
		public static function coordToSpace(from:DisplayObject, to:DisplayObject, x:Number, y:Number):Point {
			return to.globalToLocal(from.localToGlobal(new Point(x, y)));
		}
		
		//-------------------------------------------------------------------------------
		//	P R I V A T E
		//-------------------------------------------------------------------------------
		private static function disableTarget(target:InteractiveObject, disabledDict:Dictionary, exception:DisplayObject = null):void {
			if (target is DisplayObjectContainer && DisplayObjectContainer(target).contains(exception) && target !== exception) {
				var iTarget:DisplayObjectContainer = target as DisplayObjectContainer;
				var i:int = iTarget.numChildren;
				while (--i > -1) {
					var child:* = iTarget.getChildAt(i);
					if (child is InteractiveObject) disableTarget(child, disabledDict, exception);
				}
			}
			else if (target !== exception && !GLOBAL_DISABLED[target] && target.visible) {
				disabledDict[target] = { };
				GLOBAL_DISABLED[target] = true;
				if (target.hasOwnProperty('mouseEnabled')) {
					disabledDict[target].mouseEnabled = target.mouseEnabled;
					target.mouseEnabled = false;
				}
				if (target.hasOwnProperty('mouseChildren')) {
					disabledDict[target].mouseChildren = Object(target).mouseChildren;
					Object(target).mouseChildren = false;
				}
			}
		}
	}

}