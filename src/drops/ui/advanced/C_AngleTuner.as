package drops.ui.advanced {
	import drops.core.C_Box;
	import drops.core.C_SkinnableBox;
	import drops.data.C_Emboss;
	import drops.events.C_Event;
	import drops.ui.CxNumericInput;
	import drops.utils.C_Text;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.LineScaleMode;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.net.NetConnection;
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_AngleTuner extends C_Box {
		private var _circle:C_SkinnableBox;
		private var _centerIcon:Bitmap;
		
		private var _rayPadding:Number;
		private var _ray:Sprite;
		private var _angle:Number;
		
		private var _input:CxNumericInput;

		private var _rayColor:uint;
		private var _rayThickness:Number;
		private var _inputSpacing:Number;
		
		private static const PI180:Number = Math.PI / 180;
		
		public function C_AngleTuner() {
			_angle = 0;
			_rayColor = 0x000000;
			_rayThickness = 0;
			_rayPadding = 0;
			_inputSpacing = 4;
	
			_circle = new C_SkinnableBox();
			addChild(_circle);
			
			_ray = new Sprite();
			addChild(_ray);
			
			_centerIcon = new Bitmap();
			addChild(_centerIcon);
	
			_input = new CxNumericInput( -180, 180);
			_input.suffix = '°';
			_input.mode = CxNumericInput.INTEGER;
			addChild(_input);
			
			_ray.addEventListener(MouseEvent.MOUSE_DOWN, mDownHandler);
			_input.addEventListener(C_Event.CHANGE, inputChangeHandler);
			_input.addEventListener(C_Event.CHANGE_COMPLETE, inputChangeCompleteHandler);
			_input.addEventListener(C_Event.RESIZE, inputResizeHandler);
			_circle.addEventListener(C_Event.RESIZE, circleResizeHandler);
			
			align();
		}
		
		//-----------------------------------------------------------
		//	H A N D L E R S
		//-----------------------------------------------------------
		private function inputChangeCompleteHandler(e:C_Event):void {
			if (e.inside) insideAngle(_input.current, e.inside, true, false);
		}
		
		private function inputChangeHandler(e:C_Event):void {
			if (e.inside) insideAngle(_input.current, e.inside, false, false);
		}
		
		private function inputResizeHandler(e:C_Event):void {
			align();
		}
		
		private function circleResizeHandler(e:C_Event):void {
			align();
		}
		
		private function stageUpHandler(e:MouseEvent):void {
			setMoveListeners(false);
			change(true, true);
		}
		
		private function stageMoveHandler(e:MouseEvent):void {
			insideAngle(getAngle(mouseX, mouseY, e.shiftKey), true, false);
		}
		
		private function removedFormStageHandler(e:Event):void {
			setMoveListeners(false);
		}
		
		private function mDownHandler(e:MouseEvent):void {
			insideAngle(getAngle(mouseX, mouseY, e.shiftKey), false, true);
			setMoveListeners(true);
		}
		
		//-----------------------------------------------------------
		//	S E T  /  G E T
		//-----------------------------------------------------------
		public function get input():CxNumericInput {
			return _input;
		}
		
		public function get circle():C_SkinnableBox {
			return _circle;
		}
		
		public function get ray():Sprite {
			return _ray;
		}
		
		public function get inputSpacing():Number {
			return _inputSpacing;
		}
		
		public function set inputSpacing(value:Number):void {
			if (_inputSpacing == value) return;
			_inputSpacing = value;
			align();
		}
		
		public function get centerIcon():BitmapData {
			return _centerIcon.bitmapData;
		}
		
		public function set centerIcon(value:BitmapData):void {
			if (_centerIcon.bitmapData == value) return;
			_centerIcon.bitmapData = value;
			align();
		}
		
		public function get rayThickness():Number {
			return _rayThickness;
		}
		
		public function set rayThickness(value:Number):void {
			if (_rayThickness == value) return;
			_rayThickness = value;
			drawRay();
		}
		
		public function get rayColor():uint {
			return _rayColor;
		}
		
		public function set rayColor(value:uint):void {
			if (_rayColor == value) return;
			_rayColor = value;
			drawRay();
		}
		
		public function get rayPadding():Number {
			return _rayPadding;
		}
		
		public function set rayPadding(value:Number):void {
			if (_rayPadding == value) return;
			_rayPadding = value;
			drawRay();
		}
		
		public function get angle():Number {
			return _angle;
		}
		
		public function set angle(value:Number):void {
			insideAngle(value, false, true);
		}
		
		//-----------------------------------------------------------
		//	P R I V A T E
		//-----------------------------------------------------------
		private function getAngle(mX:Number, mY:Number, shift:Boolean = false):Number {
			var value:Number = Math.atan2(mX - (_circle.width * 0.5), mY - (_circle.height * 0.5)) / PI180 - 90;
			if (shift) value = Math.round(value / 15) * 15;
			if (value < 0) value += 360;
			if (value > 180) value = -180 - (180 - value);
			return value;
		}
		
		private function insideAngle(value:Number, inside:Boolean, complete:Boolean, refreshInput:Boolean = true):void {
			if (value == _angle) {
				if (complete) change(complete, inside);
				return;
			}
			_angle = value;
			drawRay();
			change(false, inside);
			if (refreshInput) _input.current = value;
			if (complete) change(true, inside);
		}
		
		private function setMoveListeners(enabled:Boolean):void {
			if (enabled) {
				addEventListener(Event.REMOVED_FROM_STAGE, removedFormStageHandler);
				stage.addEventListener(MouseEvent.MOUSE_MOVE, stageMoveHandler);
				stage.addEventListener(MouseEvent.MOUSE_UP, stageUpHandler);
			}
			else {
				removeEventListener(Event.REMOVED_FROM_STAGE, removedFormStageHandler);
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, stageMoveHandler);
				stage.removeEventListener(MouseEvent.MOUSE_UP, stageUpHandler);
			}
		}
		
		private function align():void {
			_input.x = _circle.width + _inputSpacing;
			_input.y = Math.round((_circle.height - _input.height) * 0.5);
			
			width = _input.x + _input.width;
			height = _circle.height;
			
			_centerIcon.x = Math.round((_circle.width - _centerIcon.width) * 0.5);
			_centerIcon.y = Math.round((_circle.height - _centerIcon.height) * 0.5);
			
			drawRay();
		}
		
		private function drawRay():void {
			_ray.graphics.clear();
			
			var hW:Number = _circle.width * 0.5;
			var hH:Number = _circle.height * 0.5;
			
			_ray.graphics.beginFill(0, 0);
			_ray.graphics.drawEllipse(0, 0, _circle.width, _circle.height);
			_ray.graphics.endFill();
			
			var ax:Number = Math.cos(_angle * PI180) * (hW - _rayPadding) + hW;
			var ay:Number = Math.sin(-_angle * PI180) * (hH - _rayPadding) + hH;
			
			_ray.graphics.lineStyle(_rayThickness, _rayColor, 1, false, LineScaleMode.NONE);
			_ray.graphics.moveTo(hW, hH);
			_ray.graphics.lineTo(ax, ay);
			_ray.graphics.endFill();
		}
		
		private function change(complete:Boolean, inside:Boolean):void {
			dispatchEvent(new C_Event((complete) ? C_Event.CHANGE_COMPLETE : C_Event.CHANGE, null, inside));
		}
	}

}