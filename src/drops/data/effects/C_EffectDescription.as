package drops.data.effects {
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public dynamic class C_EffectDescription extends Array {
		public var name:String;
		
		public function C_EffectDescription(name:String = 'undefined') {
			this.name = name;
		}
		
		//--------------------------------------------------
		//	S E T  /  G E T
		//--------------------------------------------------
		public function get lastProperty():C_EffectProperty {
			return this[this.length - 1];
		}
	}

}