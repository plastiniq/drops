package drops.ui {
	import drops.core.C_Box;
	import drops.core.C_SkinnableBox;
	import drops.data.C_Mounts;
	import drops.data.C_Skin;
	import drops.data.C_SkinFrame;
	import drops.data.C_SkinState;
	import drops.events.C_Event;
	import com.greensock.TweenMax;
	import flash.display.Shape;
	import flash.events.MouseEvent;
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_Tumbler extends C_SkinnableBox {
		private var _pointer:C_Button;
		
		private var _onButton:C_Button;
		private var _onMask:Shape;
		private var _offButton:C_Button;
		private var _offMask:Shape;
		
		private var _enabled:Boolean;
		private var _pointerLength:Number;
		
		private var _axis:String;
		public static const X:String = 'x';
		public static const Y:String = 'y';
		
		public function C_Tumbler() {
			width = 40;
			height = 20;
			_axis = X;
			_enabled = true;
			_pointerLength = 10;
			
			_onButton = new C_Button('On');
			_onButton.autoSize = C_Button.NONE;
			_onButton.skin = new C_Skin(null, null, null, 0x7cb4e4);
			_onButton.setAllPadding(0);
			_onButton.cropContent = true;
			addChild(_onButton);
	
			_offButton = new C_Button('Off');
			_offButton.autoSize = C_Button.NONE;
			_offButton.skin = new C_Skin(null, null, null, 0xced7de);
			_offButton.setAllPadding(0);
			addChild(_offButton);
			
			_onMask = new Shape();
			_onMask.graphics.beginFill(0);
			_onMask.graphics.drawRect(0, 0, 100, 100);
			_onButton.mask = _onMask;
			addChild(_onMask);
			
			_offMask = new Shape();
			_offMask.graphics.beginFill(0);
			_offMask.graphics.drawRect(0, 0, 100, 100);
			_offButton.mask = _offMask;
			addChild(_offMask);
			
			_pointer = new C_Button();
			_pointer.setAllPadding(0);
			addChild(_pointer);
		
			refresh();
			
			_pointer.addEventListener(C_Event.RESIZE, pointerResizeHandler);
			addEventListener(MouseEvent.CLICK, clickHandler);
			addEventListener(C_Event.RESIZE, resizeHandler);
		}
		
		//------------------------------------------------------------
		//	H A N D L E R S
		//------------------------------------------------------------
		private function pointerResizeHandler(e:C_Event):void {
			if (e.data === lengthProp || e.data === BOTH) {
				_pointerLength = _pointer[lengthProp];
				refresh();
			}
		}
		
		private function clickHandler(e:MouseEvent):void {
			privateEnabled(!_enabled, true);
		}

		private function resizeHandler(e:C_Event):void {
			refreshPointer();
		}
		
		//------------------------------------------------------------
		//	S E T  /  G E T
		//------------------------------------------------------------
		public function get enabled():Boolean {
			return _enabled;
		}
		
		public function set enabled(value:Boolean):void {
			privateEnabled(value, false);
		}
		
		public function get pointer():C_Button {
			return _pointer;
		}
		
		public function get offButton():C_Button {
			return _offButton;
		}
		
		public function get onButton():C_Button {
			return _onButton;
		}
		
		//------------------------------------------------------------
		//	P R I V A T E
		//------------------------------------------------------------
		private function privateEnabled(enabled:Boolean, inside:Boolean):void {
			if (_enabled === enabled) return;
			
			_enabled = enabled;
			var vars:Object = { onUpdate:refreshPointer };
			vars[_axis] = (enabled) ?  this[lengthProp] - _pointer[lengthProp] : 0;
			TweenMax.to(_pointer, 0.15, vars);
			dispatchEvent(new C_Event(C_Event.CHANGE, null, inside));
		}
		
		private function refresh():void {
			_onButton.mounts.setMounts(0, 0, 0, 0);
			_offButton.mounts.setMounts(0, 0, 0, 0);
			_pointer.mounts.setMounts(0, 0, 0, 0);
			
			if (_axis === X) {
				_onButton.right = _pointerLength;
				_offButton.left = _pointerLength;
				_pointer.left = null;
				_pointer.right = null;
				_pointer.width = _pointerLength;
			}
			else {
				_onButton.bottom = _pointerLength;
				_offButton.top = _pointerLength;
				_pointer.bottom = null;
				_pointer.top = null;
				_pointer.height = _pointerLength;
			}
			
			_pointer[_axis] = (_enabled) ? this[lengthProp] - _pointerLength : 0;
			refreshPointer();
		}
		
		private function refreshPointer():void {
			var thick:String = thickProp;
			var length:String = lengthProp;
			var offset:String = (_axis === X) ? 'contentOffsetX' : 'contentOffsetX';

			_onMask[thick] = this[thick];
			_onMask[length] = _pointer[_axis] + (_pointer[length] * 0.5);
			_onButton[offset] = _pointer[_axis] - (this[length] - _pointer[length]);
			
			_offMask[thick] = this[thick];
			_offMask[_axis] = (_pointer[_axis] + (_pointer[length] * 0.5));
			_offMask[length] = this[length] - _offMask[_axis];
			_offButton[offset] = _pointer[_axis];
		}
		
		private function get thickProp():String {
			return (_axis === X) ? 'height' : 'width';
		}
		
		private function get lengthProp():String {
			return (_axis === X) ? 'width' : 'height';
		}
		
	}

}