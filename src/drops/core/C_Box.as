package drops.core 
{
	import drops.data.C_Description;
	import drops.data.C_Mounts;
	import drops.data.C_Spacing;
	import drops.events.C_Event;
	import drops.data.C_Property;
	import drops.utils.C_Display;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_Box extends Sprite {
		private var _width:Number;
		private var _height:Number;
		private var _mounts:C_Mounts;
		
		private var _parentW:Number;
		private var _parentH:Number;
	
		private var _prevW:Number;
		private var _prevH:Number;
		
		private var _boundsChanged:Boolean;
		private var _boundsRect:Rectangle;
		
		public static const WIDTH:String = 'width';
		public static const HEIGHT:String = 'height';
		public static const BOTH:String = 'both';
		
		public static var description:C_Description = new C_Description(); 
		description.pushGroup('Position and Size');
		description.lastGroup.pushProperty(C_Property.NUMBER, 'x', 'X');
		description.lastGroup.pushProperty(C_Property.NUMBER, 'y', 'Y');
		description.lastGroup.pushProperty(C_Property.NUMBER, 'width', 'Width');
		description.lastGroup.pushProperty(C_Property.NUMBER, 'height', 'Height');
		
		public function C_Box() {
			_prevW = _width = 10;
			_prevH = _height = 10;
			_mounts = new C_Mounts();
			_boundsRect = new Rectangle;
			addEventListener(Event.ADDED, addedHandler);
			addEventListener(Event.REMOVED, removedHandler);
		}

		//-----------------------------------------------
		//	H A N D L E R S
		//-----------------------------------------------
		private function resizeParentHandler(e:Event):void {
			sizeChanged(true);
		}
		
		private function removedHandler(e:Event):void {
			if (e.target == this && stage && parent == stage) {
				stage.removeEventListener(Event.RESIZE, resizeParentHandler);
			}
		}
		
		private function addedHandler(e:Event):void {
			if (e.target == this) {
				if (stage && parent == stage) {
					stage.addEventListener(Event.RESIZE, resizeParentHandler);
				}
				sizeChanged(true);
			}
		}
		
		//--------------------------------------------
		//	O V E R R I D E D
		//--------------------------------------------
		override public function set scaleY(value:Number):void {
			super.scaleY = value;
			calculateSize();
		}
		
		override public function set scaleX(value:Number):void {
			super.scaleX = value;
			calculateSize();
		}
		
		override public function getBounds(targetCoordinateSpace:DisplayObject):Rectangle {
			if (targetCoordinateSpace) {
				var pt:Point = targetCoordinateSpace.globalToLocal(parent ? parent.localToGlobal(new Point(x, y)) : new Point(x, y));
				return new Rectangle(pt.x, pt.y, width * scaleX, height * scaleY);
			}
			return new Rectangle();
		}
		
		override public function set x(value:Number):void{
			if (!isNaN(value) && x != value) {
				if (!_mounts.blockedX) {
					super.x = value;
				}
			}
		}
		
    	override public function set y(value:Number):void{
			if (!isNaN(value) && y != value) {
				if (!_mounts.blockedY) {
					super.y = value;
				}
			}
		}

		override public function get height():Number {
			return _height;
		}
		
		override public function set height(value:Number):void {
			if (!isNaN(value) && value != _height) {
				_height = value;
				sizeChanged(false);
			}
		}
		
		override public function get width():Number {
			return _width;
		}
		
		override public function set width(value:Number):void {
			if (!isNaN(value) && value != _width) {
				_width = value;
				sizeChanged(false);
			}
		}
		
		//-----------------------------------------------
		//	S E T  /  G E T
		//-----------------------------------------------
		public function get mounts():C_Mounts {
			return _mounts;
		}
		
		public function set mounts(mounts:C_Mounts):void {
			_mounts = (mounts === null) ? new C_Mounts() : mounts;
			sizeChanged(false);
		}
		
		public function get bottomOffset():Object {
			return _mounts.bottomOffset;
		}
		
		public function set bottomOffset(value:Object):void {
			if (value != _mounts.bottomOffset) {
				_mounts.bottomOffset = value;
				sizeChanged(false);
			}
		}
		
		public function get topOffset():Object {
			return _mounts.topOffset;
		}
		
		public function set topOffset(value:Object):void {
			if (value != _mounts.topOffset) {
				_mounts.topOffset = value;
				sizeChanged(false);
			}
		}
		
		public function get rightOffset():Object {
			return _mounts.rightOffset;
		}
		
		public function set rightOffset(value:Object):void {
			if (value != _mounts.rightOffset) {
				_mounts.rightOffset = value;
				sizeChanged(false);
			}
		}
		
		public function get leftOffset():Object {
			return _mounts.leftOffset;
		}
		
		public function set leftOffset(value:Object):void {
			if (value != _mounts.leftOffset) {
				_mounts.leftOffset = value;
				sizeChanged(false);
			}
		}
		
		public function get contentHeight():Number {
			return super.height;
		}
		
		public function get contentWidth():Number {
			return super.width;
		}
		
		public function get contentBounds():Rectangle {
			return super.getBounds(this);
		}
		
		public function get top():Object {
			return _mounts.top;
		}
		
		public function set top(value:Object):void {
			if (value != _mounts.top) {
				_mounts.top = (String(value) == '') ? null : value;
				sizeChanged(false);
			}
		}
		
		public function get bottom():Object {
			return _mounts.bottom;
		}
		
		public function set bottom(value:Object):void {
			if (value != _mounts.bottom) {
				_mounts.bottom = (String(value) == '') ? null : value;
				sizeChanged(false);
			}
		}
		
		public function get left():Object {
			return _mounts.left;
		}
		
		public function set left(value:Object):void {
			if (value != _mounts.left) {
				mounts.left = (String(value) == '') ? null : value;
				sizeChanged(false);
			}
		}
		
		public function get right():Object {
			return _mounts.right;
		}
		
		public function set right(value:Object):void {
			if (value != _mounts.right) {
				mounts.right = (String(value) == '') ? null : value;
				sizeChanged(false);
			}
		}
		
		public function get size():Array {
			return [width, height];
		}
		
		public function set size(value:Array):void {
			if (!value || value.length != 2 || (value[0] == _width && value[1] == _height)) return;
			_width = value[0];
			_height = value[1];
			sizeChanged(false);
		}
		
		//-----------------------------------------------
		//	P U B L I C
		//-----------------------------------------------
		public function getTotalScale(prop:String):Number {
			var total:Number = this[prop];
			var parent:DisplayObject = this.parent;
			while (parent && !(parent is Stage)) {
				total *= parent[prop];
				parent = parent.parent;
			}
			return total;
		}
		
		public function setMounts(left:Object = null, right:Object = null, top:Object = null, bottom:Object = null, leftOffset:Object = null, rightOffset:Object = null, topOffset:Object = null, bottomOffset:Object = null):void {
			_mounts.setMounts(left, right, top, bottom, leftOffset, rightOffset, topOffset, bottomOffset);
			sizeChanged(false);
		}
		
		public function setSize(width:Number, height:Number):void {
			if (width == _width && height == _height) return;
			_width = width;
			_height = height;
			sizeChanged(false);
		}
		
		//-----------------------------------------------
		//	P R I V A T E
		//-----------------------------------------------
		protected function calculateSize():void {
			refreshParentSize();

			if (_mounts.left !== null && _mounts.right !== null) { super.x = C_Display.getNumericValue(_mounts.left, _parentW);
																_width = _parentW - x - C_Display.getNumericValue(_mounts.right, _parentW, true);
			}
			else if (_mounts.left !== null)						{ super.x = C_Display.getNumericValue(_mounts.left, _parentW) }
			else if (_mounts.right !== null)					{ super.x = _parentW - _width - C_Display.getNumericValue(_mounts.right, _parentW) }

			if (_mounts.top != null && _mounts.bottom !== null)	{ super.y = C_Display.getNumericValue(_mounts.top, _parentH);
																  _height = _parentH - y - C_Display.getNumericValue(_mounts.bottom, _parentH, true); 
			}
			else if (_mounts.top !== null)						{ super.y = C_Display.getNumericValue(_mounts.top, _parentH) }
			else if (_mounts.bottom !== null)					{ super.y = _parentH - _height - C_Display.getNumericValue(_mounts.bottom, _parentH) }
			
			var lO:Number = (_mounts.leftOffset === null) ? 	0 : C_Display.getNumericValue(_mounts.leftOffset, _width * scaleX);
			var rO:Number = (_mounts.rightOffset === null) ? 	0 : C_Display.getNumericValue(_mounts.rightOffset, _width * scaleX);
			var tO:Number = (_mounts.topOffset === null) ? 		0 : C_Display.getNumericValue(_mounts.topOffset, _height * scaleY);
			var bO:Number = (_mounts.bottomOffset === null) ? 	0 : C_Display.getNumericValue(_mounts.bottomOffset, _height * scaleY);
			
			super.x = super.x + lO;
			if (_mounts.right !== null) _width += rO - lO;
			
			super.y = super.y + tO;
			if (_mounts.bottom !== null) _height += bO - tO;
		}

		protected function sizeChanged(inside:Boolean):void {
			calculateSize();
			
			var i:int = numChildren;
			var child:DisplayObject;
			while (--i > -1) {
				child = getChildAt(i);
				if (child is C_Box) C_Box(child).sizeChanged(true);
			}

			if (_prevW !== _width || _prevH != _height) {
				var direction:String = (_prevW !== _width && _prevH !== _height) ? BOTH : (_prevW !== _width) ? WIDTH : HEIGHT;
				_prevW = _width;
				_prevH = _height;
				dispatchEvent(new C_Event(C_Event.RESIZE, direction, inside));
				_boundsChanged = true;
			}
		}
		
		private function refreshParentSize():void {
			if (parent) {
				_parentW = (parent is Stage) ? stage.stageWidth : parent.width;
				_parentH = (parent is Stage) ? stage.stageHeight : parent.height;
			}
			else {
				_parentW = 0;
				_parentH = 0;
			}
		}
	}

}