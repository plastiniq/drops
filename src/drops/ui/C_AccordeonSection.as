package drops.ui {
	import drops.charts.C_ChartItem;
	import drops.core.C_Box;
	import drops.core.C_ScrollableArea;
	import drops.core.C_SkinnableBox;
	import drops.data.C_Skin;
	import drops.data.C_SkinFrame;
	import drops.data.C_SkinState;
	import drops.events.C_Event;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_AccordeonSection extends C_Box {
		private var _headerHeight:Number;
		private var _expandedHeight:Number;
		private var _header:C_Button;
		private var _content:C_ScrollableArea;
		private var _contentPadding:Number;
		private var _expanded:Boolean;
		private var _autoHeight:Boolean;
		
		public function C_AccordeonSection(title:String = null, expanded:Boolean = true) {
			_contentPadding = 10;
			_headerHeight = 20;
			_expandedHeight = 200;
			_expanded = expanded;
			_autoHeight = false;
			
			_header = super.addChild(new C_Button(title)) as C_Button;
			_header.top = 0;
			_header.left = 0;
			_header.right = 0;
			_header.contentAlignX = C_Button.LEFT;
			_header.skin = new C_Skin(null, null, null, 0xFF0000);
			
			_content = super.addChild(new C_ScrollableArea()) as C_ScrollableArea;
			_content.overflow = C_ScrollableArea.HIDDEN;
			_content.setMounts(0, 0, null, 0);
			_header.skin = new C_Skin(null, null, null, 0xFFFFFF);
			
			_header.addEventListener(MouseEvent.CLICK, headerClickHandler);
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			
			refresh();
			width = 150;
		}
		
		//------------------------------------------------
		//	H A N D L E R S
		//------------------------------------------------
		private function removedChildHandler(e:Event):void {
			enabledChildListeners(e.target as EventDispatcher, false);
		}
		
		private function childResizeHandler(e:C_Event):void {
			refresh();
		}
		
		private function addedToStageHandler(e:Event):void {
			refresh();
		}
		
		private function headerClickHandler(e:Event):void {
			if (_expanded) {
				hideContent(true);
			}
			else {
				showContent(true);
			}
		}
		
		private function completeAnimationHandler(target:* = null):void {
			if (target) target.visible = false;
			dispatchEvent(new C_Event(C_Event.ANIMATION_COMPLETE));
		}
		
		//-----------------------------------------------
		//	O V E R R I D E D
		//-----------------------------------------------
		override public function addChild(child:DisplayObject):DisplayObject {
			enabledChildListeners(child, true);
			_content.addChild(child);
			refresh();
			return child;
		}
		
		//------------------------------------------------
		//	S E T  /  G E T
		//------------------------------------------------
		public function get expandedHeight():Number {
			return _expandedHeight;
		}
		
		public function set expandedHeight(value:Number):void {
			_autoHeight = false;
			_expandedHeight = Math.max(_headerHeight + _contentPadding, value);
			refresh();
		}
		
		public function get autoHeight():Boolean {
			return _autoHeight;
		}
		
		public function set autoHeight(value:Boolean):void {
			_autoHeight = value;
			refresh();
		}
		
		public function get title():String {
			return _header.text;
		}
		
		public function set title(value:String):void {
			_header.text = value;
		}
		
		public function get contentPadding():Number {
			return _contentPadding;
		}
		
		public function set contentPadding(value:Number):void {
			if (value != _contentPadding) {
				_contentPadding = value;
				refresh();
			}
		}
		
		public function get headerHeight():Number {
			return _headerHeight;
		}
		
		public function set headerHeight(value:Number):void {
			if (value != _headerHeight) {
				_headerHeight = value;
				refresh();
			}
		}
		
		public function get header():C_Button {
			return _header;
		}
		
		public function get content():C_ScrollableArea {
			return _content;
		}
		
		//------------------------------------------------
		//	P U B L I C
		//------------------------------------------------
		public function showContent(animation:Boolean = false):void {
			if (_autoHeight) _expandedHeight = _content.content.contentBounds.bottom + _headerHeight + _contentPadding;

			_content.visible = true;
			if (animation) {
				dispatchEvent(new C_Event(C_Event.ANIMATION_BEGIN));
				TweenMax.to(this, 0.15, { height:_expandedHeight, onComplete:completeAnimationHandler } );
			}
			else {
				_content.height = _expandedHeight;
				dispatchEvent(new C_Event(C_Event.CHANGE_COMPLETE));
			}
			_expanded = true;
		}
		
		public function hideContent(animation:Boolean = false):void {
			if (animation) {
				dispatchEvent(new C_Event(C_Event.ANIMATION_BEGIN));
				TweenMax.to(this, 0.15, { height:_headerHeight, onComplete:completeAnimationHandler, onCompleteParams:[_content] } );
			}
			else {
				_content.visible = false;
				dispatchEvent(new C_Event(C_Event.CHANGE_COMPLETE));
			}
			_expanded = false;
		}
		
		public function refresh():void {
			if (_content.content.numChildren) {
				//trace(_content.content.getChildAt(0).height);
				//trace(_content.content.contentBounds.height);
			}
			if (_autoHeight) _expandedHeight = Math.round(_content.content.contentBounds.bottom + _headerHeight + _contentPadding);
			height = (_expanded) ? _expandedHeight : _headerHeight;
			_header.height = _headerHeight;
			_content.top = _headerHeight;
		}
		
		//------------------------------------------------
		//	P R I V A T E
		//------------------------------------------------
		private function enabledChildListeners(target:EventDispatcher, enabled:Boolean):void {
			if (enabled) {
				if (target is C_Box) target.addEventListener(C_Event.RESIZE, childResizeHandler);
				target.addEventListener(Event.REMOVED, removedChildHandler);
			}
			else {
				target.removeEventListener(C_Event.RESIZE, childResizeHandler);
				target.removeEventListener(Event.REMOVED, removedChildHandler);
			}
		}
	}

}