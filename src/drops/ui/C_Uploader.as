package drops.ui 
{
	import drops.core.C_Box;
	import drops.events.C_Event;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.FileReference;
	import flash.text.TextFieldType;
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_Uploader extends C_Box {
		private var _buttonWidth:Number;
		
		private var _button:C_Button;
		private var _input:C_Input;
		private var _fileReference:FileReference;
		private var _loader:Loader;
		private var _typeList:Array;
		
		public function C_Uploader(typeList:Array = null) {
			_typeList = typeList;
			
			_buttonWidth = 20;
			
			_button = new C_Button();
			_button.top = 0;
			_button.left = 0;
			_button.width = _buttonWidth;
			_button.bottom = 0;
			addChild(_button);
			
			_input = new C_Input();
			_input.top = 0;
			_input.left = _buttonWidth;
			_input.right = 0;
			_input.bottom = 0;
			addChild(_input);
			_input.textField.type = TextFieldType.DYNAMIC;
			
			_fileReference = new FileReference();
			_loader = new Loader();
			
			_button.addEventListener(MouseEvent.CLICK, mClickHandler);
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loaderCompleteHandler);
			_fileReference.addEventListener(Event.SELECT, fileSelectHandler);
			_fileReference.addEventListener(Event.COMPLETE, fileCompleteHandler);
		}
		
		//----------------------------------------------
		//	H A N D L E R S
		//----------------------------------------------
		private function loaderCompleteHandler(e:Event):void {
			dispatchEvent(new C_Event(C_Event.CHANGE_COMPLETE));
		}
		
		private function fileCompleteHandler(e:Event):void {
			var bytes:ByteArray = _fileReference.data;
			_loader.loadBytes(bytes);
		}
		
		private function fileSelectHandler(e:Event):void {
			_input.text = _fileReference.name;
			_fileReference.load();
		}
		
		private function mClickHandler(e:Event):void {
			_fileReference.browse(_typeList);
		}
		
		//----------------------------------------------
		//	S E T  /  G E T
		//----------------------------------------------
		public function get loaderContent():DisplayObject {
			return _loader.content;
		}
		
		public function get input():C_Input {
			return _input;
		}
		
		public function get button():C_Button {
			return _button;
		}
		
		public function get buttonWidth():Number {
			return _buttonWidth;
		}
		
		public function set buttonWidth(value:Number):void {
			_buttonWidth = value;
			_button.width = _buttonWidth;
			_input.left = _buttonWidth;
		}
	}
}