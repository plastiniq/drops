package drops.ui {
	import drops.core.C_Box;
	import drops.data.C_LabeledGroup;
	import drops.events.C_Event;
	import flash.display.DisplayObject;
	import flash.events.Event;
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_LabeledBox extends C_Box {
		public static const GROUPS:Object = { };
		
		private var _label:C_Label;
		private var _group:String;
		private var _content:DisplayObject;
		private var _spacing:Number;
		
		private var _contentOffsetY:Number;
		private var _labelOffsetY:Number;
		
		private var _fit:String;
		public static const NONE:String = 'none';
		public static const SPACING:String = 'spacing';
		public static const CONTENT:String = 'content';
		
		public function C_LabeledBox(text:String = null, content:DisplayObject = null) {
			_spacing = 3;
			_contentOffsetY = 0;
			_labelOffsetY = 0;
			_fit = NONE;
			
			_label = new C_Label(text);
			_content = content;
			addChild(_label);
			
			addEventListener(Event.REMOVED, removedHandler);
			addEventListener(Event.ADDED, addedHandler);
			addEventListener(C_Event.RESIZE, resizeHandler);
			
			if (content) {
				this.content = content;
			}
			else {
				align();
			}
		}
		
		//-------------------------------------------------------
		//	H A N D L E R S
		//-------------------------------------------------------
		private function resizeHandler(e:C_Event):void {
			if (_fit !== NONE && _content) align();
		}
		
		private function contentRemovedHandler(e:Event):void {
			if (e.target == _content) {
				_content.removeEventListener(Event.REMOVED, contentRemovedHandler);
				_content = null;
				align();
			}
		}
		
		private function addedHandler(e:Event):void {
			if (e.target === this && _group !== null) {
				if (!GROUPS[_group]) GROUPS[_group] = new C_LabeledGroup();
				GROUPS[_group].addBox(this);
			}
		}
		
		private function removedHandler(e:Event):void {
			if (e.target === this && GROUPS[_group]) {
				GROUPS[_group].removeBox(this);
			}
		}
		
		//-------------------------------------------------------
		//	S E T  /  G E T
		//-------------------------------------------------------
		public function get labelOffsetY():Number {
			return _labelOffsetY;
		}
		
		public function set labelOffsetY(value:Number):void {
			if (value == _labelOffsetY) return;
			_labelOffsetY = value;
			align();
		}
		
		public function get contentOffsetY():Number {
			return _contentOffsetY;
		}
		
		public function set contentOffsetY(value:Number):void {
			if (value == _contentOffsetY) return;
			_contentOffsetY = value;
			align();
		}
		
		public function get spacing():Number {
			return _spacing;
		}
		
		public function set spacing(value:Number):void {
			if (value == _spacing) return;
			_spacing = value;
			align();
		}
		
		public function get content():DisplayObject {
			return _content;
		}
		
		public function set content(object:DisplayObject):void {
			if (_content === object) return;
			
			if (_content && _content.parent === this) {
				this.removeChild(_content);
			}
			
			if (object) {
				addChild(object);
				object.addEventListener(Event.REMOVED, contentRemovedHandler);
			}
			else {
				_label.y = 0;
			}
			_content = object;
			align();
		}
		
		public function get group():String {
			return _group;
		}
		
		public function set group(value:String):void {
			if (value === _group) return;
			if (value == '') value = null;
			
			if (GROUPS[_group]) {
				GROUPS[_group].removeBox(this);
				if (GROUPS[_group].length == 0) delete GROUPS[_group];
			}
			
			if (value !== null) {
				if (!GROUPS[value]) GROUPS[value] = new C_LabeledGroup();
				GROUPS[value].addBox(this);
			}
			_group = value;
			align();
		}
		
		public function get label():C_Label {
			return _label;
		}
		
		public function get fit():String {
			return _fit;
		}
		
		public function set fit(value:String):void {
			if (value == _fit) return;
			_fit = value;
			align();
		}
		
		//-------------------------------------------------------
		//	P U B L I C
		//-------------------------------------------------------

		//-------------------------------------------------------
		//	P R I V A T E
		//-------------------------------------------------------
		public function align():void {
			if (_content) {
				var maxLabelWidth:Number = (GROUPS[_group] && GROUPS[_group].maxLabel) ? GROUPS[_group].maxLabel.width : _label.width;
				if (_fit === NONE || _fit === CONTENT) {
					_content.x = Math.round(maxLabelWidth + _spacing);
					if (_fit === CONTENT) _content.width = width - _content.x;
					if (_fit == NONE) width = _content.x + _content.width;
				}
				else if (_fit === SPACING) {
					_content.x = width - _content.width;
				}
				_content.y = _contentOffsetY + Math.round((height - _content.height) * 0.5);
			}
			_label.y = _labelOffsetY + Math.round((height - _label.textHeight) * 0.5);
		}
	}

}