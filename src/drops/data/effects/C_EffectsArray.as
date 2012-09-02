package drops.data.effects {
	import drops.utils.UtilFunctions;
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public dynamic class C_EffectsArray extends Array {
		private var _selectedIndex:uint;
		
		public function C_EffectsArray(...args) {
			if (args) {
				var i:int = args.length;
				while (--i > -1) this.unshift(args[i]);
			}
		}
		
		public function clone():C_EffectsArray {
			var clone:C_EffectsArray = new C_EffectsArray();
			var i:int = this.length;
			while (--i > -1) {
				clone.unshift(UtilFunctions.cloneByDescription(this[i]));
			}
			clone.selectedIndex = _selectedIndex;
			return clone;
		}
		
		public function get selectedIndex():uint {
			return _selectedIndex;
		}
		
		public function set selectedIndex(value:uint):void {
			_selectedIndex = value;
		}
		
		
	}

}