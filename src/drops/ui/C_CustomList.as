package drops.ui 
{
	import com.adobe.protocols.dict.Definition;
	import drops.events.C_Event;
	import drops.utils.C_Text;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.sampler.NewObjectSample;
	import flash.text.TextField;
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_CustomList extends Sprite {
		//-------------------------------------------
		//	options format:
		//	options:Array = {name:String, values:Array, selectedValue:int};
		//
		//	Fields format:
		//	_rows:Array = C_ComboBox.data = TextField;
		//-------------------------------------------
		[Embed(source="/img/skins/droplist_btn_up.png")]
		private static const EMB_UP_SKIN:Class;
		private static const UP_SKIN:BitmapData = (new EMB_UP_SKIN() as Bitmap).bitmapData;
		
		[Embed(source="/img/skins/droplist_btn_down.png")]
		private static const EMB_DOWN_SKIN:Class;
		private static const DOWN_SKIN:BitmapData = (new EMB_DOWN_SKIN() as Bitmap).bitmapData;
		
		[Embed(source="/img/skins/droplist_btn.png")]
		private static const EMB_SKIN:Class;
		private static const SKIN:BitmapData = (new EMB_SKIN() as Bitmap).bitmapData;
		
		private var _title:TextField;
		private var _options:Array;
		private var _displayed:Array;
		private var _rows:Array;
		
		private var _comboList:C_SelectList;
		
		private var _lineHeight:Number;
		private var _leading:Number;
		private var _betweenSpace:Number;
		private var _ident:Number;
		
		public function C_CustomList(title:String, options:Array, ...displayed) {
			_lineHeight = 20;
			_leading = 10;
			_betweenSpace = 6;
			_ident = 9;
			
			_title = C_Text.defineTF(null, title, C_Text.defineFormat(null, 12, "left", 0));
			addChild(_title);
			
			_options = options;
			_displayed = displayed;
			
			_rows = [];
			
			addEventListener(MouseEvent.MOUSE_DOWN, mDownHandler);
			refresh();
		}
		
		//------------------------------------------------
		//	H A N D L E R S
		//------------------------------------------------
		private function mDownHandler(e:MouseEvent):void {
			parent.setChildIndex(this, parent.numChildren - 1);
		}
		
		private function changeHandler(e:C_Event):void {
			//compareLists();
			var option:Object = _options[e.target.selectedIndex];
			e.target.data.text = option.values[option.selectedValue];
			C_Text.autoSize(e.target.data);
			alignRows();
		}
		
		//------------------------------------------------
		//	P U B L I C
		//------------------------------------------------
		public function refresh():void {
			var option:Object;
			
			clearUnused();
			
			var i:int = _displayed.length;
			_rows.length = i;
			
			while (--i > -1) {
				if (!_rows[i]) {
					var sBox:C_SelectBox = new C_SelectBox();
					sBox.setData(_options, 'name');
					_rows[i] = addChild(sBox);
					_rows[i].data = addChild(C_Text.defineTF(null, null, C_Text.defineFormat(null, 12, "left", 0)));
					defineButton(_rows[i].button);
				}
				option = _options[_displayed[i]];
				_rows[i].selectedIndex = _displayed[i];
				_rows[i].data.text = option.values[option.selectedValue];
				C_Text.autoSize(_rows[i].data);
				_rows[i].addEventListener(C_Event.CHANGE, changeHandler);
			}
			alignRows();
		}
		
		//------------------------------------------------
		//	P R I V A T E
		//------------------------------------------------
		private function compareLists():void {
			var busy:Array = [];
			
			var obj:Object;
			for each(obj in _rows) busy.push(obj.name.selectedIndex);
			
			var i:int;
			for each(obj in _rows) {
				i = obj.list.items.length;
				while (--i > -1) obj.list.items[i].enabled = (busy.indexOf(i) == -1) ? true : false;
			}

		}
		
		private function alignRows():void {
			var offset:int = C_Text.baseLine(_title) + _leading;
			var i:int;
			var len:int = _rows.length;
			
			for (i = 0; i < len; i++ ) {
				_rows[i].x = _ident;
				_rows[i].y = offset;
				_rows[i].data.y = offset + _rows[i].button.content.y;
				_rows[i].data.x = _rows[i].x + _rows[i].width;
				offset += C_Text.baseLine(_rows[i].button.labelField) + _leading;
			}
		}
		
		private function defineButton(button:C_Button):C_Button {
			with(button) {
				setSkin(C_Button.UP_SKIN, UP_SKIN, new Rectangle(14, 3, 5, 14));
				setSkin(C_Button.SELECTED_SKIN, UP_SKIN, new Rectangle(14, 3, 5, 14));
				setSkin(C_Button.DOWN_SKIN, DOWN_SKIN, new Rectangle(14, 3, 5, 14));
				setSkin(C_Button.SKIN, SKIN, new Rectangle(14, 3, 5, 14));
				labelField.defaultTextFormat = CxText.defineFormat(12, "left", 0x828285);
				labelField.setTextFormat(button.labelField.defaultTextFormat);
				define(0, _lineHeight, C_Button.WIDTH, 12, C_Button.LEFT, 10, 8);
			}
			return button;
		}
		
		private function clearUnused():void {
			var i:int = _displayed.length - 1;
			
			for (i; i < _rows.length; i++ ) {
				_rows[i].removeEventListener(C_Event.CHANGE, changeHandler);
				removeChild(_rows[i]);
				removeChild(_rows[i].data);
			}
		}
	}

}