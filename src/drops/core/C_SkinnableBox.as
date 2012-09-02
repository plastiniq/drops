package drops.core {
	import drops.data.C_Description;
	import drops.data.C_Skin;
	import drops.data.C_SkinFrame;
	import drops.data.C_SkinManager;
	import drops.data.C_SkinState;
	import drops.events.C_Event;
	import drops.graphics.BitmapProcessing;
	import drops.graphics.FrameProcessing;
	import drops.graphics.EffectsProcessing;
	import drops.ui.C_Button;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_SkinnableBox extends C_Box {
		private var _skinManager:C_SkinManager;
		private var _frames:Object;
		private var _skinState:String;
		private var _bgAlpha:Number;
		
		private var _drawQueue:Object;
		private var _drawRequest:Boolean;
		
		private var _snapToPixels:Boolean;
		
		public static var description:C_Description = new C_Description(); 
		
		description.setContainer('addChild', [DisplayObject]);
		description.transparent = true;
		
		
		public function C_SkinnableBox() {
			_skinManager = new C_SkinManager();
			_bgAlpha = 1;
			_frames = { };
			_drawQueue = { };
			_drawRequest = false;
			_skinState = C_SkinState.NORMAL;
			_snapToPixels = false;
			
			_skinManager.addEventListener(C_Event.CHANGE, skinChangeHandler);
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}

		//-----------------------------------------------------------------------
		//	H A N D L E R S
		//-----------------------------------------------------------------------
		private function addedToStageHandler(e:Event):void {
			if (_drawRequest) renderHandler();
		}
		
		private function renderHandler(e:Event = null):void {
			var key:String;
			for (key in _drawQueue) {
				drawFrame(key, true, _drawQueue[key].filtered);
			}
			_drawQueue = { };
			if (stage) stage.removeEventListener(Event.RENDER, renderHandler);
			_drawRequest = false;
		}
		
		private function skinChangeHandler(e:C_Event):void {
			if (!e.data || e.data == 'all') {
				refreshAllFrames(true, false);
			}
			else {
				drawFrame(e.data, false);
			}
		}
		
		//-----------------------------------------------------------------------
		//	S E T  /  G E T
		//-----------------------------------------------------------------------
		public function get skinManager():C_SkinManager {
			return _skinManager;
		}
		
		public function get skinState():String {
			return _skinState;
		}
		
		public function set skinState(value:String):void {
			if (value === _skinState) return;
			if (_skinState && _frames[_skinState]) {
				_frames[_skinState].visible = false;
			}
			if (_frames[value]) {
				_frames[value].visible = true;
			}
			_skinState = value;
		}
		
		public function get skin():C_Skin {
			return _skinManager.skin;
		}
		
		public function set skin(skin:C_Skin):void {
			var key:String;
			
			for (key in _frames) {
				if (!skin || !skin.frames[key]) {
					super.removeChild(_frames[key]);
					delete _frames[key];
				}
			}
			
			_skinManager.skin = skin;
		}
		
		//-----------------------------------------------------------------------
		//	P U B L I C
		//-----------------------------------------------------------------------
		public function isFrameShape(object:DisplayObject):Boolean {
			var value:Object;
			for each (value in _frames) {
				if (value === object) return true;
			}
			return false;
		}
		
		//-----------------------------------------------------------------------
		//	O V E R R I D E S
		//-----------------------------------------------------------------------
		override protected function calculateSize():void {
			super.calculateSize();
			refreshAllFrames(true, false);
		}
		
		override public function addChildAt(child:DisplayObject, index:int):DisplayObject {
			return super.addChildAt(child, index + skin.numFrames);
		}
		
		override public function getChildAt(index:int):DisplayObject {
			return super.getChildAt(index + skin.numFrames);
		}
		
		override public function getChildIndex(child:DisplayObject):int {
			var th:* = this;
			return super.getChildIndex(child) - skin.numFrames;
		}
		
		override public function removeChildAt(index:int):DisplayObject {
			return super.removeChildAt(index + skin.numFrames);
		}
		
		override public function setChildIndex(child:DisplayObject, index:int):void {
			return super.setChildIndex(child, index + skin.numFrames);
		}
		
		override public function swapChildren(child1:DisplayObject, child2:DisplayObject):void {
			return super.swapChildren(child1, child2);
		}
		
		override public function swapChildrenAt(index1:int, index2:int):void {
			return super.swapChildrenAt(index1 + skin.numFrames, index2 + skin.numFrames);
		}
		
		override public function get numChildren():int {
			return super.numChildren - skin.numFrames;
		}
		
		public function get opacity():Number {
			return alpha * 100;
		}
		
		public function set opacity(value:Number):void {
			alpha = value / 100;
		}
		
		public function get bgAlpha():Number {
			return _bgAlpha;
		}
		
		public function set bgAlpha(value:Number):void {
			if (_bgAlpha == value) return;
			_bgAlpha = value;
			var frame:Shape;
			for each(frame in _frames) frame.alpha = _bgAlpha;
		}
		
		public function getFrameHeight():Number {
			return _frames[_skinState].height;
		}
		
		//-----------------------------------------------------------------------
		//	P R I V A T E
		//-----------------------------------------------------------------------
		private function refreshAllFrames(filtered:Boolean, immediately:Boolean = false):void {
			var key:String;
			for (key in _skinManager.skin.frames) {
				drawFrame(key, immediately, filtered);
			}
		}

		private function drawFrame(state:String, immediately:Boolean = true, filtered:Boolean = true):void {
			if (!_skinManager.skin.frames[state]) return;
			
			if (_frames[state] === undefined) {
				_frames[state] = new Shape();
				super.addChildAt(_frames[state], 0);
			}
			
			if (!immediately) {
				if (!_drawRequest) {
					if (stage) {
						stage.invalidate();
						stage.addEventListener(Event.RENDER, renderHandler);
					}
				}
				_drawQueue[state] = { "filtered":filtered };
				_drawRequest = true;
			}
			
			var shape:Shape = _frames[state];
			shape.alpha = _bgAlpha;
			shape.visible = (state === _skinState && (width > 0 && height > 0));
			FrameProcessing.drawFrame(shape, _skinManager.skin, state, width, height, filtered);
		}
		
	}

}