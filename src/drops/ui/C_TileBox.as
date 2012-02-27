package drops.ui {
	import drops.core.C_SkinnableBox;
	import drops.data.C_Description;
	import drops.data.C_Margin;
	import drops.data.C_Property;
	import drops.data.C_SkinFrame;
	import drops.data.C_SkinState;
	import drops.events.C_Event;
	import drops.utils.C_Display;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_TileBox extends C_SkinnableBox {
		private var _tileWidth:Object;
		private var _tileHeight:Object;
		
		private var _tileAutoWidth:Boolean;
		private var _tileAutoHeight:Boolean;
		
		private var _tilePaddingLeft:Number;
		private var _tilePaddingTop:Number;
		private var _tilePaddingRight:Number;
		private var _tilePaddingBottom:Number;
		
		private var _tileMinWidth:Number;
		private var _tileMinHeight:Number;
		
		private var _tileAlignX:String;
		private var _tileAlignY:String;
		
		private var _hideOverflow:Boolean;
		private var _autoHeight:Boolean;
		private var _autoWidth:Boolean;
		
		private var _lockResize:Boolean;
		
		private var _immediateRender:Boolean;
		private var _renderExceptionIndex:int;
		private var _renderTimer:Timer;
		private var _customMargins:Dictionary;
		
		public var data:Object;
		
		private static const EMPTY_MARGIN:C_Margin = new C_Margin();
		
		public static var description:C_Description = new C_Description(); 
		description.setContainer('addChild', [DisplayObject]);
		description.transparent = true;
		
		description.pushGroup('Mounts');
		description.lastGroup.pushProperty(C_Property.MOUNTS, 'mounts');
		description.pushGroup('Properties');
		description.lastGroup.pushProperty(C_Property.BOOLEAN, 'tileAutoHeight', 'Tile Auto Height');
		description.lastGroup.pushProperty(C_Property.BOOLEAN, 'tileAutoWidth', 'Tile Auto Width');
		description.lastGroup.pushProperty(C_Property.BOOLEAN, 'autoHeight', 'Auto Heightt');
		description.lastGroup.pushProperty(C_Property.BOOLEAN, 'hideOverflow', 'Hide Overflow');
		description.lastGroup.pushProperty(C_Property.NUMBER, 'tileMinWidth', 'Minimal Tile Width');
		description.lastGroup.pushProperty(C_Property.NUMBER, 'tileMinHeight', 'Minimal Tile Height');
		description.lastGroup.pushProperty(C_Property.PERCENTABLE_NUMBER, 'tileWidth', 'Tile Width');
		description.lastGroup.pushProperty(C_Property.PERCENTABLE_NUMBER, 'tileHeight', 'Tile Height');
		
		description.lastGroup.pushProperty(C_Property.MENU, 'tileAlignX', 'Tile Align X');
		description.lastProperty.addOption('left', C_TileAlign.LEFT);
		description.lastProperty.addOption('center', C_TileAlign.CENTER);
		description.lastProperty.addOption('right', C_TileAlign.RIGHT);
		
		description.lastGroup.pushProperty(C_Property.MENU, 'tileAlignY', 'Tile Align Y');
		description.lastProperty.addOption('top', C_TileAlign.TOP);
		description.lastProperty.addOption('center', C_TileAlign.CENTER);
		description.lastProperty.addOption('bottom', C_TileAlign.BOTTOM);
		
		description.pushGroup('Padding');
		description.lastGroup.pushProperty(C_Property.NUMBER, 'tilePaddingLeft', 'Tile Padding Left');
		description.lastGroup.pushProperty(C_Property.NUMBER, 'tilePaddingTop', 'Tile Padding Top');
		description.lastGroup.pushProperty(C_Property.NUMBER, 'tilePaddingRight', 'Tile Padding Righ');
		description.lastGroup.pushProperty(C_Property.NUMBER, 'tilePaddingBottom', 'Tile Padding Bottom');
		
		public function C_TileBox(tileWidth:Object = '50%', tileHeight:Object = '50%') {
			skin.setFrame(C_SkinState.NORMAL, new C_SkinFrame());
			
			_immediateRender = true;
			_renderTimer = new Timer(5, 1);
			
			_tileWidth = tileWidth;
			_tileHeight = tileHeight;
			
			_tileAutoWidth = false;
			_tileAutoHeight = false;
			
			_tilePaddingLeft = 0;
			_tilePaddingTop = 0;
			_tilePaddingRight = 0;
			_tilePaddingBottom = 0;
			
			_tileMinWidth = 0;
			_tileMinHeight = 0;
			
			_tileAlignX = C_TileAlign.LEFT;
			_tileAlignY = C_TileAlign.TOP;
			
			_hideOverflow = false;
			_autoHeight = false;
			_autoWidth = false;
			
			_customMargins = new Dictionary(true);
			
			addEventListener(C_Event.RESIZE, resizeHandler);
			addEventListener(Event.ADDED, addedHandler);
			addEventListener(Event.REMOVED, removedHandler);
			_renderTimer.addEventListener(TimerEvent.TIMER, renderTimerHandler);
		}
		
		//--------------------------------------------------------------
		//	H A N D L E R S
		//--------------------------------------------------------------
		private function renderTimerHandler(e:TimerEvent = null):void {
			refresh(_renderExceptionIndex, true);
		}
		
		private function childResizeHandler(e:C_Event):void {
			refresh();
		}
		
		private function removedHandler(e:Event):void {
			if (e.target !== this) {
				e.target.removeEventListener(C_Event.RESIZE, childResizeHandler);
				refresh((e.target.parent === this) ? getChildIndex(e.target as DisplayObject) : -1);
			}
		}
		
		private function addedHandler(e:Event):void {
			if (e.target !== this) e.target.addEventListener(C_Event.RESIZE, childResizeHandler);
			refresh();
		}
		
		private function resizeHandler(e:C_Event):void {
			if (!_lockResize) refresh();
		}
		
		//--------------------------------------------------------------
		//	S E T / G E T
		//--------------------------------------------------------------
		public function get immediateRender():Boolean {
			return _immediateRender;
		}
		
		public function set immediateRender(value:Boolean):void {
			if (value == _immediateRender) return;
			_immediateRender = value;
			if (value && _renderTimer.running) {
				renderTimerHandler();
				_renderTimer.stop();
			}
		}
		
		public function get autoHeight():Boolean {
			return _autoHeight;
		}
		
		public function set autoHeight(value:Boolean):void {
			if (value == _autoHeight) return;
			_autoHeight = value;
			refresh();
		}
		
		public function get autoWidth():Boolean {
			return _autoWidth;
		}
		
		public function set autoWidth(value:Boolean):void {
			if (value == _autoWidth) return;
			_autoWidth = value;
			refresh();
		}
		
		public function get tileAutoWidth():Boolean {
			return _tileAutoWidth;
		}
		
		public function set tileAutoWidth(value:Boolean):void {
			if (value == _tileAutoWidth) return;
			_tileAutoWidth = value;
			refresh();
		}
		
		public function get tileAutoHeight():Boolean {
			return _tileAutoHeight;
		}
		
		public function set tileAutoHeight(value:Boolean):void {
			if (value == _tileAutoHeight) return;
			_tileAutoHeight = value;
			refresh();
		}
		
		public function get hideOverflow():Boolean {
			return _hideOverflow;
		}
		
		public function set hideOverflow(value:Boolean):void {
			if (value === _hideOverflow) return;
			_hideOverflow = value;
			refresh();
		}
		
		public function get tileAlignX():String {
			return _tileAlignX;
		}
		
		public function set tileAlignX(value:String):void {
			if (value == _tileAlignX) return;
			_tileAlignX = value;
			refresh();
		}
		
		public function get tileAlignY():String {
			return _tileAlignY;
		}
		
		public function set tileAlignY(value:String):void {
			if (value == _tileAlignY) return;
			_tileAlignY = value;
			refresh();
		}
		
		public function get tileHeight():Object {
			return _tileHeight;
		}
		
		public function set tileHeight(value:Object):void {
			if (value == _tileHeight) return;
			_tileHeight = value;
			refresh();
		}
		
		public function get tileWidth():Object {
			return _tileWidth;
		}
		
		public function set tileWidth(value:Object):void {
			if (value == _tileWidth) return;
			_tileWidth = value;
			refresh();
		}
		
		public function get tileMinWidth():Number {
			return _tileMinWidth;
		}
		
		public function set tileMinWidth(value:Number):void {
			if (value == _tileMinWidth) return;
			_tileMinWidth = value;
			refresh();
		}
		
		public function get tileMinHeight():Number {
			return _tileMinHeight;
		}
		
		public function set tileMinHeight(value:Number):void {
			if (value == _tileMinHeight) return;
			_tileMinHeight = value;
			refresh();
		}
		
		public function get tilePaddingLeft():Number {
			return _tilePaddingLeft;
		}
		
		public function set tilePaddingLeft(value:Number):void {
			if (value == _tilePaddingLeft) return;
			_tilePaddingLeft = value;
			refresh();
		}
		
		public function get tilePaddingTop():Number {
			return _tilePaddingTop;
		}
		
		public function set tilePaddingTop(value:Number):void {
			if (value == _tilePaddingTop) return;
			_tilePaddingTop = value;
			refresh();
		}
		
		public function get tilePaddingRight():Number {
			return _tilePaddingRight;
		}
		
		public function set tilePaddingRight(value:Number):void {
			if (value == _tilePaddingRight) return;
			_tilePaddingRight = value;
			refresh();
		}
		
		public function get tilePaddingBottom():Number {
			return _tilePaddingBottom;
		}
		
		public function set tilePaddingBottom(value:Number):void {
			if (value == _tilePaddingBottom) return;
			_tilePaddingBottom = value;
			refresh();
		}

		//--------------------------------------------------------------
		//	P U B L I C
		//--------------------------------------------------------------
		public function setCustomMargin(object:DisplayObject, margin:C_Margin):void {
			_customMargins[object] = margin;
		}

		//--------------------------------------------------------------
		//	P R I V A T E
		//--------------------------------------------------------------
		private function refresh(exceptionIndex:int = -1, immediate:Object = null):void {
			if (immediate === null) immediate = _immediateRender;
			if (!immediate) {
				_renderExceptionIndex = exceptionIndex;
				_renderTimer.reset();
				_renderTimer.start();
				return;
			}
			
			if (_autoWidth) {
				_lockResize = true;
				width = getAutoWidth();
				_lockResize = false
			}
			
			if (numChildren == 0) return;
			var tW:Number = Math.max(_tileMinWidth, C_Display.getNumericValue(_tileWidth, width));
			var tH:Number = Math.max(_tileMinHeight, C_Display.getNumericValue(_tileHeight, height));
			
			var col:int = 0;
			var row:int = 0;
			var maxRowH:Number = 0;
			var tileRect:Rectangle = new Rectangle(0, 0, 0, 0);
			var child:DisplayObject;
			var i:int = -1;
			
			var childMargin:C_Margin;
			
			while (++i < numChildren) {
				child = getChildAt(i);
				childMargin = (_customMargins[child]) ? _customMargins[child] : EMPTY_MARGIN;

				tileRect.x = tileRect.right;
				tileRect.width = (_tileAutoWidth) ? Math.max(_tileMinWidth, child.width + _tilePaddingLeft + _tilePaddingRight + childMargin.width) : tW;
			
				if (tileRect.right > width) {
					tileRect.x = 0;
					tileRect.y = tileRect.bottom;
					maxRowH = 0;
				}
				
				tileRect.height = (_tileAutoHeight) ? Math.max(maxRowH, _tileMinHeight, child.height + _tilePaddingTop + _tilePaddingBottom + childMargin.height) : tH;
				maxRowH = Math.max(maxRowH, tileRect.height);

				alignObject(child, childMargin, tileRect);
				child.visible = Boolean((child.y + child.height) < height || _autoHeight);
				if ((i + 1) == exceptionIndex) i++;
			}
			
			if (_autoHeight) {
				_lockResize = true;
				height = tileRect.bottom;
				_lockResize = false;
			}
		}
		
		private function getAutoWidth():Number {
			var widthIsPercent:Boolean = C_Display.valueIsPercent(_tileWidth);
			
			if (!_tileAutoWidth && !widthIsPercent) {
				return C_Display.getNumericValue(_tileWidth, width) * numChildren;
			}
			
			var child:DisplayObject;
			var i:int = numChildren;
			var margin:C_Margin;
			var max:Number = _tileMinWidth;
			var all:Number = 0;
			var childMargin:C_Margin;
			
			while (--i > -1) {
				child = getChildAt(i);
				childMargin = (_customMargins[child]) ? _customMargins[child] : EMPTY_MARGIN;
				max = Math.max(max, child.width + _tilePaddingLeft + _tilePaddingRight + childMargin.width);
				all += Math.max(_tileMinWidth, child.width + _tilePaddingLeft + _tilePaddingRight + childMargin.width);
			}
			
			return _tileAutoWidth ? all : Math.ceil(100 / C_Display.numberFromObject(_tileWidth) * max);
		}
		
		private function alignObject(object:DisplayObject, objectMargin:C_Margin, rect:Rectangle):void {
			if (_tileAlignX === C_TileAlign.RIGHT) 			{ object.x = rect.right - _tilePaddingRight - objectMargin.right }
			else if (_tileAlignX === C_TileAlign.CENTER)	{ object.x = Math.round(rect.x + (rect.width - object.width) * 0.5) }
			else 											{ object.x = rect.left + _tilePaddingLeft + objectMargin.left }
			
			if (_tileAlignY === C_TileAlign.BOTTOM) 		{ object.y = rect.bottom - _tilePaddingBottom - objectMargin.bottom }
			else if (_tileAlignY === C_TileAlign.CENTER)	{ object.y = Math.round(rect.y + (rect.height - object.height) * 0.5) }
			else 											{ object.y = rect.top + _tilePaddingTop + objectMargin.top }
		}
		
	}

}