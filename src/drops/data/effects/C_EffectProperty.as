package drops.data.effects {
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_EffectProperty {
		public var type:String;
		public var method:String;
		public var label:String;
		public var options:Array;
		public var range:*;
		
		public var cloneFunc:String;
		
		public function C_EffectProperty(type:String, method:String, label:String, options:Array = null, range:* = null) {
			this.type = type;
			this.method = method;
			this.label = label;
			this.options = options;
			this.range = range;
		}
		
	}

}