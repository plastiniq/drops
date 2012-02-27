package drops.data {
	import drops.ui.C_RadioButton;
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_RadioGroup {
		private var _groups:Object;
		
		public function C_RadioGroup() {
			_groups = { };
		}
		
		//-------------------------------------------------------
		//	P U B L I C
		//-------------------------------------------------------
		public function call(radio:C_RadioButton, group:String):void {
			var key:String;
			for (key in _groups) {
				if (_groups[key] == radio && key !== group) delete _groups[key];
			}
			
			if (group) {
				if (radio.selected && _groups[group] && _groups[group] !== radio) {
					_groups[group].selected = false;
				}
				if (radio.selected) _groups[group] = radio;
			}
			
		}
		
	}

}