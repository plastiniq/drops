package drops.ui 
{
	import drops.data.C_Description;
	import drops.data.C_Property;
	import drops.data.C_RadioGroup;
	import drops.data.C_SkinState;
	import drops.events.C_Event;
	import flash.events.Event;
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_RadioButton extends C_CheckBox {
		private static const GROUPS:C_RadioGroup = new C_RadioGroup();
		private var _group:String;
	
		public static var description:C_Description = new C_Description();
		description.pushGroup('Position and Size', 2);
		description.lastGroup.pushProperty(C_Property.NUMBER, 'x', 'X');
		description.lastGroup.pushProperty(C_Property.NUMBER, 'y', 'Y');
		description.lastGroup.pushProperty(C_Property.NUMBER, 'width', 'Width');
		description.lastGroup.pushProperty(C_Property.NUMBER, 'height', 'Height');
		description.pushGroup('Mounts');
		description.lastGroup.pushProperty(C_Property.MOUNTS, 'mounts');
		description.pushGroup('Text');
		description.lastGroup.pushProperty(C_Property.STRING, 'text');
		description.lastGroup.pushProperty(C_Property.TEXT_FORMAT, 'textFormat');
		description.pushGroup('Button Properties');
		description.lastGroup.pushProperty(C_Property.NUMBER, 'buttonWidth', 'Button Width');
		description.lastGroup.pushProperty(C_Property.BOOLEAN, 'selected', 'Selected');
		description.lastGroup.pushProperty(C_Property.STRING, 'group', 'Group');
		description.pushGroup('Label Properties');
		description.lastGroup.pushProperty(C_Property.NUMBER, 'labelOffsetY', 'Label Vertical Offset');
		description.lastGroup.pushProperty(C_Property.NUMBER, 'spacing', 'Spacing');
		description.pushGroup('Button Skin');
		description.lastGroup.pushProperty(C_Property.BITMAPDATA, 'selectedIcon', 'Icon');
		description.lastGroup.pushProperty(C_Property.NUMBER, 'contentOffsetX', 'Icon Offset X', null, 'button');
		description.lastGroup.pushProperty(C_Property.NUMBER, 'contentOffsetY', 'Icon Offset Y', null, 'button');
		
		description.lastGroup.pushProperty(C_Property.SKIN, 'skin', null, null, 'button');
		description.lastProperty.addOption('Normal Skin', C_SkinState.NORMAL);
		description.lastProperty.addOption('Selected Skin', C_SkinState.SELECTED);
		description.lastProperty.addOption('Mouse Over Skin', C_SkinState.MOUSE_OVER);
		description.lastProperty.addOption('Mouse Down Skin', C_SkinState.MOUSE_DOWN);
		
		public function C_RadioButton(text:String = null) {
			super(text);
			addEventListener(Event.REMOVED, removedHandler);
			addEventListener(Event.ADDED, addedHandler);
			addEventListener(C_Event.SELECT, selectHandler);
			addEventListener(C_Event.CHANGE_STATE, changeStateHandler);
		}
		
		//--------------------------------------------------------------
		//	H A N D L E R S
		//--------------------------------------------------------------
		private function changeStateHandler(e:C_Event):void {
			button.enabled = !selected;
		}
		
		private function selectHandler(e:Event):void {
			GROUPS.call(this, _group);
		}
		
		private function addedHandler(e:Event):void {
			if (e.target === this) GROUPS.call(this, _group);
		}
		
		private function removedHandler(e:Event):void {
			if (e.target === this) GROUPS.call(this, null);
		}
		
		//--------------------------------------------------------------
		//	S E T  /  G E T
		//--------------------------------------------------------------
		public function get group():String {
			return _group;
		}
		
		public function set group(value:String):void {
			if (_group == value) return;
			_group = value;
			GROUPS.call(this, _group);
		}
	}

}