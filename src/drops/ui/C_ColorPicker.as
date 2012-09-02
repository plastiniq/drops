package drops.ui {
	import drops.core.C_Box;
	import drops.core.C_SkinnableBox;
	import drops.data.C_Background;
	import drops.data.C_Child;
	import drops.data.C_Description;
	import drops.data.C_Emboss;
	import drops.data.C_Mounts;
	import drops.data.C_Property;
	import drops.data.C_Skin;
	import drops.data.C_SkinFrame;
	import drops.data.C_SkinState;
	import drops.events.C_Event;
	import drops.utils.C_Color;
	import flash.display.LineScaleMode;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_ColorPicker extends C_Box {
		private var _strokeAlpha:Number;
		private var _spacing:Number;
		private var _tunerWidth:Number;
		
		private var _sample:C_Box;
		private var _sampleBg:C_SkinnableBox;
		private var _sampleStroke:Shape;
		
		private var _plane:C_ColorPlane;
		private var _tuner:C_ColorTuner;
		
		public var changeFunction:Function;
		
		public function C_ColorPicker() {
			setSize(320, 250);
			
			_strokeAlpha = 0.12;
			_tunerWidth = 60;
			_spacing = 10;
			
			_sample = new C_Box();
			_sample.setSize(_tunerWidth, 34);
			addChild(_sample);
			
			_sampleBg = new C_SkinnableBox();
			_sampleBg.skin.background = new C_Background(null, null, null, null, 0x808080, 1);
			_sampleBg.mounts = new C_Mounts(0, 0, 0, 0);
			_sample.addChild(_sampleBg);
			
			_sampleStroke = new Shape();
			_sampleStroke.alpha = _strokeAlpha;
			_sampleStroke.graphics.lineStyle(1, 0, 1);
			_sampleStroke.graphics.drawRect(0, 0, _sample.width - 0.5, _sample.height - 0.5);
			_sample.addChild(_sampleStroke);
			
			_plane = new C_ColorPlane();
			_plane.strokeAlpha = _strokeAlpha;
			addChild(_plane);
			
			_tuner = new C_ColorTuner();
			addChild(_tuner);
			
			_sample.addEventListener(C_Event.RESIZE, sampleResizeHandler);
			
			_tuner.addEventListener(C_Event.CHANGE, tunerChangeHandler);
			_tuner.addEventListener(C_Event.CHANGE_COMPLETE, tunerCompleteHandler);
			
			_plane.addEventListener(C_Event.CHANGE, planeChangeHandler);
			_plane.addEventListener(C_Event.CHANGE_COMPLETE, planeCompleteHandler);
			
			addEventListener(C_Event.RESIZE, resizeHandler);
			
			refreshSample();
			align();
		}
		
		//--------------------------------------------------------
		//	H A N D L E R S
		//--------------------------------------------------------
		private function tunerCompleteHandler(e:C_Event):void {
			change(true, e.inside);
		}
		
		private function planeCompleteHandler(e:C_Event):void {
			change(true, e.inside);
		}
		
		private function planeChangeHandler(e:C_Event):void {
			if (e.inside) _tuner.insideHex(_plane.hexColor, false);
			change(false, e.inside);
		}
		
		private function tunerChangeHandler(e:C_Event):void {
			if (e.inside) {
				_plane.color.h = _tuner.color.h;
				_plane.color.s = _tuner.color.s;
				_plane.color.l = _tuner.color.l;
				_plane.upadteVisible();
			}
			change(false, e.inside);
		}
	
		private function sampleResizeHandler(e:C_Event):void {
			_sampleStroke.width = _sample.width - 0.5;
			_sampleStroke.height = _sample.height - 0.5;
			_tuner.top = _sample.height + _spacing;
		}
		
		private function resizeHandler(e:C_Event):void {
			align();
		}
		
		//--------------------------------------------------------
		//	S E T  /  G E T
		//--------------------------------------------------------
		public function get tuner():C_ColorTuner {
			return _tuner;
		}
		
		public function get plane():C_ColorPlane {
			return _plane;
		}
		
		public function get strokeAlpha():Number {
			return _strokeAlpha;
		}
		
		public function set strokeAlpha(value:Number):void {
			_strokeAlpha = value;
			_plane.strokeAlpha = value;
			_sampleStroke.alpha = _strokeAlpha;
		}
		
		public function get sampleHeight():Number {
			return _sample.height;
		}
		
		public function set sampleHeight(value:Number):void {
			_sample.height = value;
		}
		
		public function get hexColor():uint {
			return _plane.hexColor;
		}
		
		public function set hexColor(value:uint):void {
			insideHex(value, true, false, true);
		}
		
		public function get tunerWidth():Number {
			return _tunerWidth
		}
		
		public function set tunerWidth(value:Number):void {
			_tunerWidth = value;
			align();
		}
		
		public function get spacing():Number {
			return _spacing;
		}
		
		public function set spacing(value:Number):void {
			_spacing = value;
			align();
		}
		
		//--------------------------------------------------------
		//	P U B L I C
		//--------------------------------------------------------
		public function insideHex(value:uint, dispatch:Boolean, inside:Boolean = false, complete:Boolean = false):void {
			if (value === hexColor) {
				if (dispatch && complete) change(complete, inside);
				return;
			}
			
			_plane.insideHex(value, false);
			_tuner.insideHex(value, false);
			
			if (dispatch) {
				change(false, inside);
				if (complete) change(true, inside);
			}
		}
		
		//--------------------------------------------------------
		//	P R I V A T E
		//--------------------------------------------------------
		private function align():void {
			_sample.y = 0;
			_sample.x = width - _tunerWidth;
			
			_plane.mounts = new C_Mounts(0, _tunerWidth + _spacing, 0, 0);
			
			_tuner.width = _tunerWidth;
			_tuner.mounts = new C_Mounts(null, 0, _sample.height + _spacing, 0);
		}
		
		private function refreshSample():void {
			var ct:ColorTransform = _sampleBg.transform.colorTransform;
			ct.color = _plane.color.hex;
			_sampleBg.transform.colorTransform = ct;
		}
		
		private function copyValues(source:C_Color, target:C_Color):void {
			 target.h = source.h;
			 target.s = source.s;
			 target.l = source.l;
		}
		
		private function change(complete:Boolean, inside:Boolean):void {
			refreshSample();
			if (changeFunction !== null) changeFunction.apply(this, [inside, complete]);
			dispatchEvent(new C_Event((complete) ? C_Event.CHANGE_COMPLETE : C_Event.CHANGE, null, inside));
		}
	}
}
