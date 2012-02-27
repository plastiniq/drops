package drops.ui {
	import drops.core.C_Box;
	import drops.core.C_SkinnableBox;
	import drops.data.C_Background;
	import drops.data.C_Child;
	import drops.data.C_Description;
	import drops.data.C_Mounts;
	import drops.data.C_Property;
	import drops.data.C_Skin;
	import drops.data.C_SkinFrame;
	import drops.data.C_SkinState;
	import drops.events.C_Event;
	import drops.graphics.Emb;
	import drops.utils.C_Color;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.InterpolationMethod;
	import flash.display.LineScaleMode;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_ColorPlane extends C_Box {
		private var _field:C_Box;
		private var _fieldBg:Shape;
		private var _fieldOverlay:Shape;
		private var _fieldPicker:Bitmap;
		private var _fieldMask:Shape;
		private var _fieldStroke:Shape;
		
		private var _track:C_SkinnableBox;
		private var _trackPicker:C_Button;
		private var _trackStroke:Shape;
		
		private var _trackPickerGab:Number;
		private var _trackThickness:Number;
		private var _spacing:Number;
		
		private var _color:C_Color;
		private var _hexColor:C_Color;
		
		private var _strokeAlpha:Number;
		private var _trackAlign:String;
		private var _changed:Boolean;
		
		private var _currentTarget:*;
		
		public static const LEFT:String = 'left';
		public static const RIGHT:String = 'right';
		public static const TOP:String = 'top';
		public static const BOTTOM:String = 'bottom';
		private static const SAMPLE_BG_SKIN:C_Skin = new C_Skin();
		SAMPLE_BG_SKIN.background = new C_Background(null, null, null, null, 0);
		
		public static var description:C_Description = new C_Description();
		description.pushGroup('Options');
		description.lastGroup.pushProperty(C_Property.NUMBER, 'trackThickness', 'Track Thickness');
		description.lastGroup.pushProperty(C_Property.MENU, 'trackAlign', 'Track Align');
		description.lastProperty.addOption('left', LEFT);
		description.lastProperty.addOption('right', RIGHT);
		description.lastProperty.addOption('top', TOP);
		description.lastProperty.addOption('bottom', BOTTOM);
		
		public function C_ColorPlane() {
			width = 256;
			height = 256;
			
			_strokeAlpha = 0.12;
			_trackThickness = 20;
			_spacing = 10;
			_trackPickerGab = 7;
			_trackAlign = RIGHT;
			
			_changed = false;
			
			_color = new C_Color();
			_hexColor = new C_Color();
			
			_field = new C_Box();
			addChild(_field);
			
			_fieldBg = new Shape();
			_fieldBg.graphics.beginFill(0);
			_fieldBg.graphics.drawRect(0, 0, 100, 100);
			_field.addChild(_fieldBg);
			
			_fieldOverlay = new Shape();
			drawGradient(0, _fieldBg.width, _fieldBg.height, [0xFFFFFF, 0xFFFFFF], _fieldOverlay.graphics);
			drawGradient( -Math.PI / 2, _fieldBg.width, _fieldBg.height, [0, 0], _fieldOverlay.graphics);
			_field.addChild(_fieldOverlay);
			_fieldOverlay.cacheAsBitmap = true;
			
			_fieldPicker = new Bitmap(Emb.SB_PICKER);
			_field.addChild(_fieldPicker);
			
			_fieldMask = new Shape();
			_fieldMask.graphics.beginFill(0);
			_fieldMask.graphics.drawRect(0, 0, _field.width, _field.height);
			_fieldPicker.mask = _fieldMask;
			addChild(_fieldMask);
			
			_fieldStroke = new Shape();
			_fieldStroke.alpha = _strokeAlpha;
			_fieldStroke.graphics.lineStyle(1, 0, 1, false, LineScaleMode.NONE);
			_fieldStroke.graphics.drawRect(0, 0, 100, 100);
			_field.addChild(_fieldStroke);
			
			_track = new C_SkinnableBox();
			var hueSkin:C_Skin = new C_Skin(buildHueGradient());
			_track.skin = hueSkin;
			addChild(_track);
			
			_trackStroke = new Shape();
			_trackStroke.alpha = _strokeAlpha;
			_trackStroke.graphics.lineStyle(1, 0, 1, false, LineScaleMode.NONE)
			_trackStroke.graphics.drawRect(0, 0, 100, 100);
			addChild(_trackStroke);
			
			_trackPicker = new C_Button();
			_trackPicker.mouseEnabled = false;
			_trackPicker.height = Emb.H_PICKER.height;
			_trackPicker.skin = new C_Skin(Emb.H_PICKER, null, new Rectangle(7, 0, 3, 9));
			_track.addChild(_trackPicker);
		
			_track.addEventListener(MouseEvent.MOUSE_DOWN, trackDownHandler);
			_field.addEventListener(MouseEvent.MOUSE_DOWN, fieldDownHandler);
			_field.addEventListener(C_Event.RESIZE, fieldResizeHandler);
			addEventListener(C_Event.RESIZE, resizeHandler);
			addEventListener(C_Event.CHANGE, changeHandler);
		
			refresh();
		}
		
		//-------------------------------------------------------------------------
		//	H A N D L E R S
		//-------------------------------------------------------------------------
		private function changeHandler(e:C_Event):void {
			_changed = true;
		}
		
		private function resizeHandler(e:C_Event):void {
			refresh();
		}
		
		private function removedFromStage(e:MouseEvent):void {
			enabledTrackListeners(false);
		}
		
		private function stageUpHandler(e:MouseEvent):void {
			enabledTrackListeners(false);
			if (_changed) {
				change(true, true);
				_changed = false;
			}
		}
		
		private function stageMoveHandler(e:MouseEvent):void {
			setPickersFromMouse();
		}
		
		private function fieldDownHandler(e:MouseEvent):void {
			_currentTarget = _field;
			setPickersFromMouse();
			enabledTrackListeners(true);
		}
		
		private function trackDownHandler(e:MouseEvent):void {
			_currentTarget = _track;
			setPickersFromMouse();
			enabledTrackListeners(true);
		}
		
		private function fieldResizeHandler(e:C_Event):void {
			_fieldMask.width = _fieldOverlay.width = _fieldBg.width = _field.width;
			_fieldMask.height = _fieldOverlay.height = _fieldBg.height = _field.height;
			_fieldStroke.width = (_field.width * 1.01) - 0.5;
			_fieldStroke.height = (_field.height * 1.01) - 0.5;
		}
		
		//-------------------------------------------------------------------------
		//	S E T  /  G E T
		//-------------------------------------------------------------------------
		public function get strokeAlpha():Number {
			return _strokeAlpha;
		}
		
		public function set strokeAlpha(value:Number):void {
			_strokeAlpha = value;
			_fieldStroke.alpha = _strokeAlpha;
			_trackStroke.alpha = _strokeAlpha;
		}
		
		public function get trackThickness():Number {
			return _trackThickness;
		}
		
		public function set trackThickness(value:Number):void {
			if (value == _trackThickness) return;
			_trackThickness = value;
			refresh();
		}
		
		public function get spacing():Number {
			return _spacing;
		}
		
		public function set spacing(value:Number):void {
			if (value == _spacing) return;
			_spacing = value;
			refresh();
		}
		
		public function get color():C_Color {
			return _color;
		}
		
		public function get hexColor():uint {
			return _color.hex;
		}
		
		public function set hexColor(value:uint):void {
			insideHex(value, true, false, true);
		}
		
		public function get trackAlign():String {
			return _trackAlign;
		}
		
		public function set trackAlign(value:String):void {
			if (value === _trackAlign) return;
			_trackAlign = value;
			refresh();
		}
		
		//-------------------------------------------------------------------------
		//	P R I V A T E
		//-------------------------------------------------------------------------
		public function insideHex(value:uint, dispatch:Boolean, inside:Boolean = false, complete:Boolean = false):void {
			if (value == _color.hex) {
				if (dispatch && complete) change(complete, inside);
				return;
			}
			
			_color.hex = value;
			upadteVisible();
			
			if (dispatch) {
				change(false, inside);
				if (complete) change(true, inside);
			}
		}
		
		private function refresh():void {
			_track.width = _trackThickness;
			_trackPicker.left = -_trackPickerGab;
			_trackPicker.right = -_trackPickerGab;
			
			if (_trackAlign === LEFT || _trackAlign === RIGHT) {
				_track.height = height;
				_track.rotation = 0;
				_track.x = (_trackAlign === LEFT) ? 0 : width - _trackThickness;
				_track.y = 0;
			}
			else {
				_track.height = width;
				_track.rotation = 90;
				_track.x = width;
				_track.y = (_trackAlign === TOP) ? 0 : height - _trackThickness;
			}
			
			_trackStroke.x = _track.x;
			_trackStroke.y = _track.y;
			_trackStroke.width = (_track.width * 1.01) - 0.5;
			_trackStroke.height = (_track.height * 1.01) - 0.5;
			
			var mounts:C_Mounts = new C_Mounts(0, 0, 0, 0);
			mounts[_trackAlign] = _trackThickness + _spacing;
			_field.mounts = mounts;
			
			upadteVisible();
		}
		
		private function setPickersFromMouse():void {
			if (_currentTarget == _field) {
				var s:Number = (_field.mouseX / _field.width) * 100;
				var l:Number = 100 - ((_field.mouseY / _field.height) * 100);
				
				if (s != _color.s || l !== _color.l) {
					_color.s = s;
					_color.l = l;
					updatePointers();
					change(false, true);
				}
			}
			else {
				var h:Number = 359 - ((_track.mouseY / _track.height) * 359);
				if (h !== _color.h) {
					_color.h = h;
					upadteVisible();
					change(false, true);
				}
			}
		}
		
		internal function upadteVisible():void {
			updatePointers();
			updateField();
		}
		
		private function updatePointers():void {
			_trackPicker.y = Math.round(_track.height - ((_color.h / 359) * _track.height) - _trackPicker.height * 0.5);
			_fieldPicker.x = (_color.s / 100) * _field.width - (_fieldPicker.width * 0.5);
			_fieldPicker.y = _field.height - ((_color.l / 100) * _field.height) - (_fieldPicker.height * 0.5);
		}
		
		private function updateField():void {
			_hexColor.s = 100;
			_hexColor.l = 100;
			_hexColor.h = _color.h;
			var ct:ColorTransform = _fieldBg.transform.colorTransform;
			ct.color = _hexColor.hex;
			_fieldBg.transform.colorTransform = ct;
		}
		
		private function enabledTrackListeners(enabled:Boolean):void {
			if (enabled) {
				stage.addEventListener(MouseEvent.MOUSE_MOVE, stageMoveHandler);
				stage.addEventListener(MouseEvent.MOUSE_UP, stageUpHandler);
				stage.addEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
			}
			else {
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, stageMoveHandler);
				stage.removeEventListener(MouseEvent.MOUSE_UP, stageUpHandler);
				stage.removeEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
			}
		}
		
		private static function drawGradient(angle:Number, width:Number, height:Number, colors:Array, target:Graphics):void {
			var matrix:Matrix = new Matrix();
			matrix.createGradientBox(width, height, angle, 0, 0);
			target.beginGradientFill(GradientType.LINEAR, colors, [1, 0], [0, 255], matrix, "pad", InterpolationMethod.LINEAR_RGB);
			target.drawRect(0, 0, width, height);
		}
		
		private static function buildHueGradient():BitmapData {
			var color:C_Color = new C_Color(0xFF0000);
			var bd:BitmapData = new BitmapData(1, 360, false);
			var i:int = -1;
			while (++i <= 360) {
				color.h = i;
				bd.setPixel(0, 359-i, color.hex);
			}
			return bd;
		}
		
		private function change(complete:Boolean, inside:Boolean):void {
			dispatchEvent(new C_Event((complete) ? C_Event.CHANGE_COMPLETE : C_Event.CHANGE, null, inside));
		}
	}

}