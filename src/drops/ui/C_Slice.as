package drops.ui 
{
	import drops.events.C_Event;
	import drops.graphics.Wedge;
	import drops.utils.C_Text;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.LineScaleMode;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_Slice extends Sprite {
		private var _bg:Shape;
		private var _outline:Shape;
		private var _content:C_SliceContent;
		
		private var _inner:Number;
		private var _outer:Number;
		private var _angle:Number;
		private var _arc:Number;
		
		private var _selected:Boolean;
		
		private var _color:uint;
		private var _colorSel:uint;
		private var _colorOut:uint;
		private var _alphaOut:Number;
		private var _filterSel:Array;

		public function C_Slice(title:String, inner:Number, outer:Number, angle:Number, arc:Number) {
			_inner = inner;
			_outer = outer;
			_angle = angle;
			_arc = arc;
			
			_colorSel = 0x4d475d;
			_color = 0xf7f5fc;
			_colorOut = 0x1b142a;
			_alphaOut = 0.08;
			
			_filterSel = [new DropShadowFilter(1, 90, 0, 1, 5, 5, 1, 3, true)];
			
			_bg = new Shape();
			_content = new C_SliceContent(title, inner, outer, 10);
			_content.angle = angle + arc * 0.5;
			
			_outline = new Shape();
			
			multiAdd(_bg, _content, _outline);
			
			refresh();
			
			addEventListener(MouseEvent.MOUSE_UP, mUpHandler);
		}
		
		//------------------------------------------------
		//	H A N D L E R S
		//------------------------------------------------
		private function mUpHandler(e:MouseEvent):void {
			selected = true;
		}
		
		//------------------------------------------------
		//	S E T  /  G E T
		//------------------------------------------------
		public function get content():C_SliceContent {
			return _content;
		}
		
		public function get selected():Boolean {
			return _selected;
		}
		
		public function set selected(value:Boolean):void {
			if (value != _selected) {
				var tf:TextField = _content.titleField;
				if (value) {
					drawBg(_colorSel);
					_bg.filters = _filterSel;
					//C_Text.defineTF(tf, null, C_Text.defineFormat(tf.getTextFormat(), null, null, 0xFFFFFF));
					dispatchEvent(new C_Event(C_Event.SELECT));
				}
				else {
					drawBg(_color);
					//C_Text.defineTF(tf, null, C_Text.defineFormat(tf.getTextFormat(), null, null, 0x000000));
					_bg.filters = null;
				}
				_selected = value;
			}
		}
		
		public function set icon(bitmapdata:BitmapData):void {
			_content.icon = bitmapdata;
			_content.refresh();
		}
		
		//------------------------------------------------
		//	P R I V A T E
		//------------------------------------------------
		private function refresh():void {
			drawBg((_selected) ? _colorSel : _color);
			drawOutline(_colorOut, _alphaOut);
		}
		
		private function drawBg(color:uint):void {
			_bg.graphics.clear();
			_bg.graphics.beginFill(color);
			Wedge.draw(_bg.graphics, _angle, _arc, _outer);
		}
		
		private function drawOutline(color:uint, alpha:Number):void {
			_outline.graphics.clear();
			_outline.graphics.lineStyle(1, color, alpha, false, LineScaleMode.NORMAL);
			Wedge.draw(_outline.graphics, _angle, _arc, _outer, -1, 0, 0, false);
		}
		
		private function multiAdd(...args):void {
			var i:int = -1;
			while(++i < args.length) addChild(args[i]);
		}
		
	}

}