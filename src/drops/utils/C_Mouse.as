package drops.utils {
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.ui.Mouse;
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_Mouse {
		private static var _stage:Stage;
		private static var _listenersEnabled:Boolean;
		private static var _customCursorEnabled:Boolean;
		
		private static const CURSOR_BOX:Sprite = new Sprite();
		CURSOR_BOX.mouseEnabled = false;
		CURSOR_BOX.mouseChildren = false;
		
		public static const NATIVE:String = 'native';
		
		private static const STACK:Array = [NATIVE];
				
		private static const CURSORS:Object = { };
		
		//----------------------------------------------------------------
		// H A N D L E R S
		//----------------------------------------------------------------
		private static function moveHandler(e:MouseEvent):void {
			CURSOR_BOX.x = e.stageX;
			CURSOR_BOX.y = e.stageY;
		}
		
		//----------------------------------------------------------------
		// P U B L I C
		//----------------------------------------------------------------
		public static function registerCursor(name:String, cursor:DisplayObject, point:Point = null, showNative:Boolean = false):void {
			CURSORS[name] = { cursor:cursor, point:(point ? point : new Point()), showNative:showNative };
		}
		
		public static function removeCursor(name:String):void {
			removeFromStack(name);
			applyCursor();
		}
		
		//----------------------------------------------------------------
		// S E T /  G E T
		//----------------------------------------------------------------
		public static function set cursor(name:String):void {
			if (name) {
				removeFromStack(name);
				STACK.unshift(name);
			}
			applyCursor();
		}
		
		public static function get cursor():String {
			return STACK.length ? STACK[0] : NATIVE;
		}
		
		public static function set stage(value:Stage):void {
			if (_stage === value) return;
			
			if (value) {
				if (_customCursorEnabled) {
					setMoveListeners(true);
					value.addChild(CURSOR_BOX);
				}
			}
			else {
				if (_stage && CURSOR_BOX.parent === _stage) {
					_stage.removeChild(CURSOR_BOX);
				}
				setMoveListeners(false);
			}
			
			_stage = value;
		}

		//----------------------------------------------------------------
		// P R I V A T E 
		//----------------------------------------------------------------
		private static function applyCursor():void {
			var name:String = C_Mouse.cursor;
			
			if (name === NATIVE || !CURSORS[name]) {
				setMoveListeners(false);
				if (_stage && CURSOR_BOX.parent === _stage) _stage.removeChild(CURSOR_BOX);
				_customCursorEnabled = false;
				Mouse.show();
			}
			else {
				var cursor:DisplayObject = CURSORS[name].cursor;
				var pt:Point = CURSORS[name].point;
				var showNative:Boolean = CURSORS[name].showNative;
				
				var i:int = CURSOR_BOX.numChildren;
				while (--i > -1) CURSOR_BOX.removeChildAt(i);

				if (_stage) {
					CURSOR_BOX.x = _stage.mouseX;
					CURSOR_BOX.y = _stage.mouseY;
					_stage.addChild(CURSOR_BOX);
				}
			
				CURSOR_BOX.addChild(cursor);
				cursor.x = -pt.x;
				cursor.y = -pt.y;
				
				setMoveListeners(true);
				_customCursorEnabled = true;
				
				if (!showNative) Mouse.hide();
			}
		}
		
		private static function removeFromStack(name:String):void {
			var i:int = STACK.indexOf(name);
			if (i > -1) STACK.splice(i, 1);
		}
		
		private static function setMoveListeners(enabled:Boolean):void {
			if (!_stage || enabled == _listenersEnabled) return;
			if (enabled) {
				_stage.addEventListener(MouseEvent.MOUSE_MOVE, moveHandler);
			}
			else {
				_stage.removeEventListener(MouseEvent.MOUSE_MOVE, moveHandler);
			}
			_listenersEnabled = enabled;
		}
		
		public static function mouseIsEnabled(target:InteractiveObject):Boolean {
			if (target.mouseEnabled === false) return false;
			var parent:DisplayObjectContainer = target.parent;
			while (parent) {
				if (parent.mouseChildren == false) return false;
				parent = parent.parent;
			}
			return true;
		}
	}

}