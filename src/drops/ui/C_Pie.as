package drops.ui {
	import drops.core.C_Box;
	import drops.events.C_Event;
	import drops.graphics.Wedge;
	import drops.utils.C_Text;
	import com.greensock.layout.ScaleMode;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_Pie extends C_Box {
		//	objects
		private var _button:C_Button;
		private var _list:Sprite;
		private var _label:Sprite;
		private var _labelField:TextField;
		private var _labelShadow:TextField;
		private var _labelFilter:Array;
		private var _options:Array;
		
		//	properties
		private var _key:String;
		private var _inner:Number;
		private var _turned:Number;
		private var _outer:Number;
		private var _selectedIndex:int;
		private var _expanded:Boolean;
		private var _labelMargin:Number;
		
		public function C_Pie(label:String, options:Array, key:String) {
			_options = options;
			_key = key;
			
			_inner = 29;
			_turned = 35;
			_outer = 150;
			_labelMargin = 4;
			
			_list = new Sprite();
			_button = new C_Button('Button');
			
			_labelField = C_Text.defineTF(null, label, C_Text.defineFormat(null, 14, "center", 0xfbf9ff));
			_labelField.alpha = 0.6;
			_labelShadow = C_Text.clone(_labelField, null);
				
			_label = new Sprite();
			_label.cacheAsBitmap = true;
			_label.addChild(_labelField);
			_label.addChild(_labelShadow);
			
			_labelFilter = [new DropShadowFilter(1, 90, 0, 1, 2, 2, 1.3, 2, false, true)];
			
			multiAdd(_list, _button, _label);
			
			_button.addEventListener(MouseEvent.MOUSE_UP, buttonUpHandler);
			addEventListener(MouseEvent.MOUSE_OVER, mOverHandler);
			addEventListener(MouseEvent.MOUSE_OUT, mOutHandler);
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			
			update();
		}
		
		//----------------------------------------------------
		//	H A N D L E R S
		//----------------------------------------------------
		private function stageDownHandler(e:Event):void {
			if (!this.contains(e.target as DisplayObject) && _expanded) turn();
		}
		
		private function addedToStageHandler(e:Event):void {
			stage.addEventListener(MouseEvent.MOUSE_DOWN, stageDownHandler);
		}
		
		private function buttonUpHandler(e:MouseEvent):void {
			if (_expanded) {
				turn();
			}
			else {
				expand();
			}
		}
		
		private function mWheelHandler(e:MouseEvent):void {
			selectedIndex += (e.delta > 0) ? -1 : 1;
		}
		
		private function mOutHandler(e:MouseEvent):void {
			removeEventListener(MouseEvent.MOUSE_WHEEL, mWheelHandler);
		}
		
		private function mOverHandler(e:MouseEvent):void {
			addEventListener(MouseEvent.MOUSE_WHEEL, mWheelHandler);
		}
		
		private function selectHandler(e:C_Event):void {
			_selectedIndex = _list.getChildIndex(e.target as DisplayObject);
			
			var i:int = -1;
			while (++i < _list.numChildren) {
				if (i != _selectedIndex) C_Slice(_list.getChildAt(i)).selected = false;
			}
		}
		
		//----------------------------------------------------
		//	S E T  /  G E T
		//----------------------------------------------------
		public function set inner(value:Number):void {
			if (value != _inner) {
				_inner = value;
				refresh();
			}
		}
		
		public function get button():C_Button {
			return _button;
		}
		
		public function get selectedIndex():int {
			return _selectedIndex;
		}
		
		public function set selectedIndex(value:int):void {
			_selectedIndex = value - (Math.floor(value / _list.numChildren) * _list.numChildren);
			C_Slice(_list.getChildAt(_selectedIndex)).selected = true;
		}
		
		//----------------------------------------------------
		//	P U B L I C
		//----------------------------------------------------
		public function update():void {
			var i:int = -1;
			while (++i < _list.numChildren) {
				getChildAt(i).removeEventListener(C_Event.SELECT, selectHandler);
				removeChildAt(i);
			}
			
			var num:int = _options.length;
			var slice:C_Slice;
			
			this.graphics.beginFill(0xFF0000);
			for (i = 0; i < num; i++ ) {
				slice = new C_Slice(_options[i][_key], _inner, _outer, i * (360 / num), (360 / num));
				_list.addChild(slice);
				slice.addEventListener(C_Event.SELECT, selectHandler);
				if (i == 0) slice.selected = true;
			}
			refresh();
			turn(false);
		}
		
		//----------------------------------------------------
		//	P R I V A T E
		//----------------------------------------------------
		private function refresh():void {
			_button.width = _inner * 2;
			_button.height = _inner * 2;
			_button.x = int(-_button.width * 0.5);
			_button.y = int( -_button.height * 0.5);
			
			_label.x = -(_label.width * 0.5);
			_label.y = -_turned - _label.height - _labelMargin;
		
			C_Text.clone(_labelField, _labelShadow);
			_labelShadow.filters = _labelFilter;
		}
		
		private function expand():void {
			TweenMax.to(_list, 0.13, { scaleX: 1, scaleY: 1, ease:FastEase } );
			_label.alpha = 0;
			_label.y = -_outer - _label.height - _labelMargin;
			contentVisible(true);
			_expanded = true;
		}
		
		private function turn(animate:Boolean = true):void {
			var sca:Number = _turned / _outer;
			TweenMax.to(_list, (animate) ? 0.13 : 0, { scaleX: sca, scaleY: sca, ease:FastEase } );
			TweenMax.to(_label, (animate) ? 0.13 : 0, { y: -_turned - _label.height - _labelMargin, alpha: 1, ease:FastEase } );
			contentVisible(false);
			_expanded = false;
		}
		
		private function contentVisible(value:Boolean):void {
			var i:int = -1;
			while (++i < _list.numChildren) C_Slice(_list.getChildAt(i)).content.visible = value;
		}
		
		private function multiAdd(...args):void {
			var i:int = -1;
			while (++i < args.length) addChild(args[i]);
		}
		
	}

}