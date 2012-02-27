package drops.data {
	import drops.events.C_Event;
	import flash.display.BitmapData;
	import flash.display.GraphicsPath;
	import flash.display.GraphicsPathCommand;
	import flash.display.Shape;
	import flash.events.EventDispatcher;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author Dmitry M.
	 */
	public class C_Background extends EventDispatcher {
		private var _bitmapdata:BitmapData;
		private var _graphicsPath:GraphicsPath;
		private var _normalizedPath:GraphicsPath;
		
		private var _scale9Rect:Rectangle;
		
		private var _shape:String;
		private var _fillColor:Object;
		private var _fillAlpha:Object;
		
		private var _strokeColor:Object;
		private var _strokeAlpha:Object;
		private var _strokeThickness:Object;
		
		public var repeatBitmap:Boolean;
		
		public var cachedBitmap:BitmapData;
		public var cachedW:Number;
		public var cachedH:Number;
		
		private var _ltRoundness:Number;
		private var _rtRoundness:Number;
		private var _rbRoundness:Number;
		private var _lbRoundness:Number;
		
		private static const SHAPE:Shape = new Shape();
		
		public function C_Background(bmd:BitmapData = null, graphicsPath:GraphicsPath = null, scale9Rect:Rectangle = null, shape:String = null, fillColor:Object = null, fillAlpha:Object = null) {
			_bitmapdata = bmd;
			_graphicsPath = graphicsPath;
			_normalizedPath = getNormalizedPath(graphicsPath);
			
			_scale9Rect = (bmd && !scale9Rect) ? new Rectangle(0, 0, bmd.width, bmd.height) : scale9Rect;
			_shape = shape;
			_fillColor = (fillColor === null) ? 0x573c88 : fillColor; 
			_fillAlpha = (fillColor === null) ? 0 : (fillAlpha === null) ? 1 : fillAlpha; 
			
			_ltRoundness = 0;
			_rtRoundness = 0;
			_rbRoundness = 0;
			_lbRoundness = 0;
			
			cachedBitmap = null;
			cachedW = -1;
			cachedH = -1;
			
			repeatBitmap = false;
		}
		
		//-----------------------------------------------------------------------
		//	S E T  /  G E T
		//-----------------------------------------------------------------------
		public function get lbRoundness():Number {
			return _lbRoundness;
		}
		
		public function set lbRoundness(value:Number):void {
			if (value == _lbRoundness) return;
			_lbRoundness = value;
			change();
		}
		
		public function get rbRoundness():Number {
			return _rbRoundness;
		}
		
		public function set rbRoundness(value:Number):void {
			if (value == _rbRoundness) return;
			_rbRoundness = value;
			change();
		}
		
		public function get rtRoundness():Number {
			return _rtRoundness;
		}
		
		public function set rtRoundness(value:Number):void {
			if (value == _rtRoundness) return;
			_rtRoundness = value;
			change();
		}
		
		public function get ltRoundness():Number {
			return _ltRoundness;
		}
		
		public function set ltRoundness(value:Number):void {
			if (value == _ltRoundness) return;
			_ltRoundness = value;
			change();
		}
		
		public function get shape():String {
			return _shape;
		}
		
		public function set shape(value:String):void {
			if (_shape == value) return;
			_shape = shape;
			change();
		}
		
		public function get strokeThickness():Object {
			return _strokeThickness;
		}
		
		public function set strokeThickness(value:Object):void {
			if (value == _strokeThickness) return;
			_strokeThickness = value;
			change();
		}
		
		public function get strokeAlpha():Object {
			return _strokeAlpha;
		}
		
		public function set strokeAlpha(value:Object):void {
			if (value == _strokeAlpha) return;
			_strokeAlpha = value;
			change();
		}
		
		public function get strokeColor():Object {
			return _strokeColor;
		}
		
		public function set strokeColor(value:Object):void {
			if (value == _strokeColor) return;
			_strokeColor = value; 
			change();
		}
		
		
		public function get fillAlpha():Object {
			return _fillAlpha;
		}
		
		public function set fillAlpha(value:Object):void {
			if (value == _fillAlpha) return;
			_fillAlpha = value;
			change();
		}
		
		public function get fillColor():Object {
			return _fillColor;
		}
		
		public function set fillColor(value:Object):void {
			if (value == _fillColor) return;
			_fillColor = value; 
			change();
		}
		
		public function get scale9Rect():Rectangle {
			return _scale9Rect;
		}
		
		public function set scale9Rect(value:Rectangle):void {
			if (value == _scale9Rect) return;
			_scale9Rect = value;
			change();
		}
		
		public function get graphicsPath():GraphicsPath {
			return _graphicsPath;
		}
		
		public function set graphicsPath(value:GraphicsPath):void {
			if (value == _graphicsPath) return;
			_graphicsPath = value;
			_normalizedPath = getNormalizedPath(graphicsPath);
			change();
		}
		
		public function get bitmapdata():BitmapData {
			return _bitmapdata;
		}
		
		public function get normalizedPath():GraphicsPath {
			return _normalizedPath;
		}
		
		public function set bitmapdata(value:BitmapData):void {
			if (value == _bitmapdata) return;
			_bitmapdata = value;
			change();
		}
		
		//-----------------------------------------------------------------------
		//	P U B L I C
		//-----------------------------------------------------------------------
		public function setStroke(thickness:Object, color:Object, alpha:Object):void {
			if (color == _strokeColor && thickness == _strokeThickness && alpha == _strokeAlpha) return;
			_strokeThickness = thickness;
			_strokeColor = color;
			_strokeAlpha = alpha;
		}
		
		public function setRoundness(lt:Number, rt:Number, rb:Number, lb:Number):void {
			if (lt == _ltRoundness && rt == _rtRoundness && rb == _rbRoundness && lb == _lbRoundness) return;
			_ltRoundness = lt;
			_rtRoundness = rt;
			_rbRoundness = rb;
			_lbRoundness = lb;
			change();
		}
		
		public static function createScaledBg(bmd:BitmapData, padding:Number):C_Background {
			return new C_Background(bmd, null, new Rectangle(padding, padding, bmd.width - padding * 2, bmd.height - padding * 2));
		}
		
		public function clone():C_Background {
			var bmd:BitmapData = (_bitmapdata) ? _bitmapdata.clone() : null;
			var rect:Rectangle = (_scale9Rect) ? _scale9Rect.clone() : null;
			var path:GraphicsPath;
			
			if (_graphicsPath) {
				path = new GraphicsPath(_graphicsPath.commands.slice(), _graphicsPath.data.slice(), _graphicsPath.winding);
			}
			
			var bg:C_Background = new C_Background(bmd, path, rect, _shape, _fillColor, _fillAlpha);
			bg.setRoundness(_ltRoundness, _rtRoundness, _rbRoundness, _lbRoundness);
			
			return bg;
		}
		
		public function change():void {
			if (cachedBitmap) cachedBitmap.dispose();
			cachedW = -1;
			cachedH = -1;
			dispatchEvent(new C_Event(C_Event.CHANGE));
		}
		
		//-----------------------------------------------------------------------
		//	P R I V A T E
		//-----------------------------------------------------------------------
		
		//-----------------------------------------------------------------------
		//	S T A T I C
		//-----------------------------------------------------------------------
		private static function getNormalizedPath(path:GraphicsPath):GraphicsPath {
			if (!path) return null;
			SHAPE.graphics.clear();
			SHAPE.graphics.beginFill(0x000000, 1);
			SHAPE.graphics.drawPath(path.commands, path.data, path.winding);
			var bounds:Rectangle = SHAPE.getBounds(SHAPE);
			var commands:Vector.<int> = path.commands.slice();
			var data:Vector.<Number> = path.data.slice();
			
			var i:int = -1;
			for (i = 0; i < data.length; i+= 2) {
				data[i] -= bounds.x;
				data[i + 1] -= bounds.y;
			}
			return new GraphicsPath(commands, data, path.winding);
		}
	}

}