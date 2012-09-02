package drops.ui.advanced {
	import drops.data.C_Skin;
	import drops.events.C_Event;
	import drops.ui.C_PopUpColorPicker;
	import drops.utils.C_Color;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_Stopper extends Sprite {
		private var _picker:C_PopUpColorPicker;
		private var _arrowBitmap:Bitmap;
		
		private var _align:String;
		
		private var _colorTransform:ColorTransform;
		private var _color:C_Color;
		
		private var _location:Number;
		private var _alphaValue:Number;
		
		private var _moved:Boolean;
		private var _downOffset:Number;
		
		public function C_Stopper() {
			mouseChildren = false;
			doubleClickEnabled = true;
			_location = 0;
			_alphaValue = 1;
			_downOffset = 0;
			
			_picker = new C_PopUpColorPicker();
			_picker.showInput = false;
			_picker.hexColor = 0xffff00;
			_picker.sample.width = 11;
			_picker.sample.height = 12;
			addChild(_picker);
			
			_align = C_StopperAlign.BOTTOM;
			_arrowBitmap = new Bitmap();
			addChild(_arrowBitmap);
			
			_colorTransform = new ColorTransform();
			_color = new C_Color();
		
			_picker.addEventListener(C_Event.RESIZE, pickerResizeHandler);
			
			_picker.addEventListener(C_Event.CHANGE, changeHandler);
			_picker.addEventListener(C_Event.CHANGE_COMPLETE, completeHandler);
			
			addEventListener(Event.ADDED, addedHandler);
			addEventListener(MouseEvent.DOUBLE_CLICK, doubleClickHandler);
			addEventListener(MouseEvent.MOUSE_DOWN, downHandler);
			
			refresh();
		}
		
		//---------------------------------------------------------
		//	H A N D L E R
		//---------------------------------------------------------
		private function stageUpHandler(e:MouseEvent):void {
			stopDrag();
		}
		
		private function stageMoveHandler(e:MouseEvent):void {
			if (parent) {
				_moved  = true;
				insideLocation((parent.mouseX - _downOffset) / parent.width, true, true, false);
			}
		}
		
		private function downHandler(e:MouseEvent):void {
			insideSelected(true, true);
			_downOffset = mouseX;
			startDrag();
			
			if (_picker.window.expanded) _picker.expand();
		}
		
		private function doubleClickHandler(e:MouseEvent):void {
			_picker.expand();
		}
		
		private function completeHandler(e:C_Event):void {
			change(true, e.inside);
		}
		
		private function changeHandler(e:C_Event):void {
			refreshArrow();
			change(false, e.inside);
		}
		
		private function addedHandler(e:Event):void {
			if (e.target === this) refreshLocation();
		}
		
		private function pickerResizeHandler(e:C_Event):void {
			refresh();
		}
		
		//---------------------------------------------------------
		//	S E T  /  G E T
		//---------------------------------------------------------
		public function get sampleSkin():C_Skin {
			return _picker.sampleButton.skin;
		}
		
		public function set sampleSkin(value:C_Skin):void {
			_picker.sampleButton.skin = value;
		}
		
		public function get picker():C_PopUpColorPicker {
			return _picker;
		}
		
		public function get align():String {
			return _align;
		}
		
		public function set align(value:String):void {
			if (_align === value) return;
			_align = value;
			refresh();
		}
		
		public function get stopperArrow():BitmapData {
			return _arrowBitmap.bitmapData;
		}
		
		public function set stopperArrow(value:BitmapData):void {
			if (value === _arrowBitmap.bitmapData) return;
			_arrowBitmap.bitmapData = value;
			refresh();
			refreshArrow();
		}
		
		public function get sampleHeight():Number {
			return _picker.height;
		}
		
		public function set sampleHeight(value:Number):void {
			_picker.height = value;
		}
		
		public function get sampleWidth():Number {
			return _picker.width;
		}
		
		public function set sampleWidth(value:Number):void {
			_picker.width = value;
		}
		
		public function get location():Number {
			return _location;
		}
		
		public function set location(value:Number):void {
			insideLocation(value, false);
		}
		
		
		public function get alphaValue():Number {
			return _alphaValue;
		}
		
		public function set alphaValue(value:Number):void {
			insideAlpha(value, false);
		}
		
		//---------------------------------------------------------
		//	P U B L I C
		//---------------------------------------------------------
		
		//---------------------------------------------------------
		//	O V E R R I D E D
		//---------------------------------------------------------
		override public function stopDrag():void {
			if (stage) {
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, stageMoveHandler);
				stage.removeEventListener(MouseEvent.MOUSE_UP, stageUpHandler);
			}
			if (_moved) change(true, true);
		}
		
		override public function startDrag(lockCenter:Boolean = false, bounds:Rectangle = null):void {
			if (!stage) return;
			_moved = false;
			stage.addEventListener(MouseEvent.MOUSE_MOVE, stageMoveHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP, stageUpHandler);
		}
		
		//---------------------------------------------------------
		//	P R I V A T E
		//---------------------------------------------------------
		public function insideSelected(value:Boolean, inside:Boolean, dispatch:Boolean = true):void {
			if (value === _picker.sampleButton.selected) return; 
			_picker.sampleButton.selected = value;
			if (value && dispatch) dispatchEvent(new C_Event(C_Event.SELECT, null, inside));
		}
		
		public function insideHex(value:uint, inside:Boolean, dispatch:Boolean = true, complete:Boolean = true):void {
			_picker.insideHex(value, dispatch, inside, complete);
			refreshArrow();
		}
		
		public function insideLocation(value:Number, inside:Boolean, dispatch:Boolean = true, complete:Boolean = true):void {
			if (_location == value) {
				if (complete && dispatch) change(true, inside);
				return;
			}
			_location = Math.max(0, Math.min(1, value));
			refreshLocation();
			if (dispatch) {
				change(complete, inside);
				if (complete) change(true, inside);
			}
		}
		
		public function insideAlpha(value:Number, inside:Boolean, dispatch:Boolean = true, complete:Boolean = true):void {
			if (_alphaValue == value) {
				if (complete && dispatch) change(true, inside);
				return;
			}
			_alphaValue = Math.max(0, Math.min(1, value));
			if (dispatch) {
				change(complete, inside);
				if (complete) change(true, inside);
			}
		}
		
		public function refreshLocation():void {
			if (parent) {
				var abs:Number = Math.round(_location * parent.width);
				x = Math.round((abs % 2 && _location > 0 && _location < 1) ? abs + 1 : _location * parent.width);
				y = 0;
			}
		}
		
		private function refreshArrow():void {
			if (_color.hex == _picker.hexColor) return;
			
			_color.hex = _picker.hexColor;
			_color.l -= 20;
			_color.s -= 20;
			_colorTransform.color = _color.hex;
			_arrowBitmap.transform.colorTransform = _colorTransform;
		}
		
		private function refresh():void {
			_picker.x = -Math.round(_picker.width * 0.5);
			_arrowBitmap.x = -Math.round(_arrowBitmap.width * 0.5);
			
			_picker.y = (_align === C_StopperAlign.TOP) ? 0 : _arrowBitmap.height;
			_arrowBitmap.y = (_align === C_StopperAlign.TOP) ? _picker.height : 0;
		}
		
		private function change(complete:Boolean, inside:Boolean):void {
			dispatchEvent(new C_Event((complete) ? C_Event.CHANGE_COMPLETE : C_Event.CHANGE, null, inside));
		}
	}

}