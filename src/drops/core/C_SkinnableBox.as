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
		
		private var _filteringTimer:Timer;
		
		public static var description:C_Description = new C_Description(); 
		
		description.setContainer('addChild', [DisplayObject]);
		description.transparent = true;
		
		
		public function C_SkinnableBox() {
			_skinManager = new C_SkinManager();
			_bgAlpha = 1;
			_frames = { };
			_skinState = C_SkinState.NORMAL;
			_filteringTimer = new Timer(0, 1);
			
			_skinManager.addEventListener(C_Event.CHANGE, skinChangeHandler);
			_filteringTimer.addEventListener(TimerEvent.TIMER, filteredTimerHandler);
		}
		
		//-----------------------------------------------------------------------
		//	H A N D L E R S
		//-----------------------------------------------------------------------
		private function filteredTimerHandler(e:TimerEvent):void {
			refreshAllFrames(true);
		}
		
		private function skinChangeHandler(e:C_Event):void {
			if (!e.data || e.data == 'all') {
				refreshAllFrames(true);
			}
			else {
				refreshFrame(e.data);
			}
		}
		
		//-----------------------------------------------------------------------
		//	S E T  /  G E T
		//-----------------------------------------------------------------------
		public function get filteringDelay():Number {
			return _filteringTimer.delay;
		}
		
		public function set filteringDelay(value:Number):void {
			_filteringTimer.delay = value;
		}
		
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
		
		//-----------------------------------------------------------------------
		//	O V E R R I D E S
		//-----------------------------------------------------------------------
		override protected function calculateSize():void {
			super.calculateSize();
			refreshAllFrames();
		}
		
		override public function addChildAt(child:DisplayObject, index:int):DisplayObject {
			return super.addChildAt(child, index + skin.numFrames);
		}
		
		override public function getChildAt(index:int):DisplayObject {
			return super.getChildAt(index + skin.numFrames);
		}
		
		override public function getChildIndex(child:DisplayObject):int {
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
		
		//-----------------------------------------------------------------------
		//	P R I V A T E
		//-----------------------------------------------------------------------
		private function refreshAllFrames(immediate:Boolean = false):void {
			var key:String;
			
			for (key in _skinManager.skin.frames) {
				refreshFrame(key, (immediate || _filteringTimer.delay == 0.));
			}
			
			if (_filteringTimer.delay > 0. && !immediate) {
				_filteringTimer.reset();
				_filteringTimer.start();
			}
		}
		
		private function refreshFrame(state:String, filtered:Boolean = true):void {
			if (!_skinManager.skin.frames[state]) return;
			if (!_frames[state]) _frames[state] = super.addChildAt(new Shape(), 0);
			
			var shape:Shape = _frames[state];
			shape.visible = (state === _skinState && (width > 0 && height > 0));
			if ((width < 1 || height < 1)) return;
			
			 FrameProcessing.drawFrame(shape, _skinManager.skin, state, width, height, filtered);
		}
		
	}

}