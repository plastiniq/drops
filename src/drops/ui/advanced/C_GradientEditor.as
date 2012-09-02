package drops.ui.advanced {
	import drops.core.C_Box;
	import drops.core.C_SkinnableBox;
	import drops.data.C_Mounts;
	import drops.data.C_Skin;
	import drops.events.C_Event;
	import drops.ui.C_Button;
	import drops.ui.C_ColorPicker;
	import drops.ui.C_Line;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.InterpolationMethod;
	import flash.display.Shape;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_GradientEditor extends C_SkinnableBox {
		private var _padding:Number;
		private var _contextSpacing:Number;
		
		private var _stopWidth:Number;
		private var _stopHeight:Number;

		private var _stopSample:C_Button;
		
		private var _gradientBox:C_Box;
		private var _gradientBg:Bitmap;
		private var _gradientOverlay:C_SkinnableBox;

		private var _context:C_ContextGE;
		private var _colorTrack:C_StopperTrack;
		
		private var _underline:C_Line;
		
		public var changeFunction:Function;
		
		public function C_GradientEditor() {
			_padding = 4;
			_contextSpacing = 4;
			_stopWidth = 11;
			_stopHeight = 12;
			
			width = 300;
			height = 98;

			_colorTrack = new C_StopperTrack();
			addChild(_colorTrack);
			
			_gradientBox = new C_Box();
			addChild(_gradientBox);
			
			_gradientBg = new Bitmap();
			_gradientBox.addChild(_gradientBg);
			
			_gradientOverlay = new C_SkinnableBox();
			_gradientOverlay.mounts.setMounts(0, 0, 0, 0);
			_gradientBox.addChild(_gradientOverlay);
			
			_context = new C_ContextGE();
			addChild(_context);
			
			_underline = new C_Line();
			addChild(_underline);
	
			align();
			
			_colorTrack.addEventListener(C_Event.RESIZE, elementsResizeHandler);
			_colorTrack.addEventListener(C_Event.CHANGE, trackChangeHandler);
			_colorTrack.addEventListener(C_Event.CHANGE_COMPLETE, trackCompleteHandler);
			_colorTrack.addEventListener(C_Event.CHANGE_STATE, trackChangeStateHandler);
			
			_context.addEventListener(C_Event.RESIZE, elementsResizeHandler);
			
			_context.addEventListener(C_Event.CHANGE, contextChangeHandler);
			_context.addEventListener(C_Event.CHANGE_COMPLETE, contextCompleteHandler);
			
			_gradientBox.addEventListener(C_Event.RESIZE, gradientBoxResizeHandler);
		}
		
		//----------------------------------------------------------------------
		//	H A N D L E R S
		//----------------------------------------------------------------------
		private function trackChangeStateHandler(e:C_Event):void {
			_context.stopper = _colorTrack.selectedStopper;
		}
		
		private function contextCompleteHandler(e:C_Event):void {
			change(true, e.inside);
		}
		
		private function contextChangeHandler(e:C_Event):void {
			_colorTrack.markChanged();
			refreshBg();
			change(false, e.inside);
		}
		
		private function trackCompleteHandler(e:C_Event):void {
			if (e.inside) _context.refresh();
			change(true, e.inside);
		}
		
		private function trackChangeHandler(e:C_Event):void {
			refreshBg();
			if (e.inside) _context.refreshLocation();
			change(false, e.inside);
		}
		
		private function elementsResizeHandler(e:C_Event):void {
			if (!e.inside && e.data !== C_Box.WIDTH) {
				align();
			}
		}
		
		private function gradientBoxResizeHandler(e:C_Event):void {
			_gradientBg.width = _gradientBox.width;
			_gradientBg.height = _gradientBox.height;
		}
		
		//----------------------------------------------------------------------
		//	S E T / G E T
		//----------------------------------------------------------------------
		public function get underline():C_Line {
			return _underline;
		}
		
		
		public function get contextSpacing():Number {
			return _contextSpacing;
		}
		
		public function set contextSpacing(value:Number):void {
			if (_contextSpacing == value) return;
			_contextSpacing = value;
			align();
		}
		
		public function get padding():Number {
			return _padding;
		}
		
		public function set padding(value:Number):void {
			if (_padding == value) return;
			_padding = value;
			align();
		}
		
		public function get gradientOverlay():C_SkinnableBox {
			return _gradientOverlay;
		}
		
		public function get context():C_ContextGE {
			return _context;
		}
		
		public function get track():C_StopperTrack {
			return _colorTrack;
		}
		
		public function get stopperSkin():C_Skin {
			return track.stopperSkin;
		}
		
		public function set stopperSkin(value:C_Skin):void {
			track.stopperSkin = value;
		}
		
		public function get stopperArrow():BitmapData {
			return track.stopperArrow;
		}
		
		public function set stopperArrow(value:BitmapData):void {
			track.stopperArrow = value;
		}
		
		//----------------------------------------------------------------------
		//	P U B L I C
		//----------------------------------------------------------------------
		public function load(colors:Array, alphas:Array, ratios:Array):void {
			_colorTrack.load(colors, alphas, ratios);
		}
		
		public function addStopper(type:String):void {
		}
		
		public function get colors():Array {
			return _colorTrack.colors;
		}
		
		public function get alphas():Array {
			return _colorTrack.alphas;
		}
		
		public function get ratios():Array {
			return _colorTrack.ratios;
		}
		
		//----------------------------------------------------------------------
		//	P R I V A T E
		//----------------------------------------------------------------------
		private function refreshBg():void {
			_gradientBg.scaleX = _gradientBg.scaleY = 1;
			_gradientBg.bitmapData = _colorTrack.gradientBitmapData;
			_gradientBg.height = _gradientBox.height;
		}
		
		private function align():void {
			
			_context.mounts = new C_Mounts(_padding, _padding, null, 0);
			_colorTrack.mounts = new C_Mounts(_padding, _padding, null, _context.height + _contextSpacing);
			_gradientBox.mounts = new C_Mounts(_padding, _padding, _padding, height - _colorTrack.y);

			_underline.mounts = new C_Mounts(_padding, _padding, null, height - _context.y);
		}
		
		private function filledSprite():Sprite {
			var sprite:Sprite = new Sprite();
			sprite.graphics.beginFill(0, 1);
			sprite.graphics.drawRect(0, 0, 100, 100);
			return sprite;
		}
		
		private function change(complete:Boolean, inside:Boolean):void {
			if (changeFunction !== null) changeFunction.apply(this, [inside, complete]);
			dispatchEvent(new C_Event((complete) ? C_Event.CHANGE_COMPLETE : C_Event.CHANGE, null, inside));
		}
	}

}