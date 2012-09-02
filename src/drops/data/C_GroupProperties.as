package drops.data {
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_GroupProperties {
		public var expanded:Boolean;
		
		public var title:String;
		public var properties:Array;
		public var numColumns:int;
		
		public function C_GroupProperties(title:String, properties:Array = null, numColumns:int = 1, expanded:Boolean = true) {
			this.title = title;
			this.expanded = expanded;
			this.properties = (properties) ? properties : [];
			this.numColumns = numColumns;
		}
		
		//--------------------------------------------------
		//	S E T  /  G E T
		//--------------------------------------------------
		public function get lastProperty():C_Property {
			return properties[properties.length - 1];
		}

		//--------------------------------------------------
		//	P U B L I C
		//--------------------------------------------------
		public function pushProperty(type:String, method:String, label:String = null, options:Array = null, target:Object = null):C_Property {
			var prop:C_Property = new C_Property(type, method, label, options, target);
			properties.push(prop);
			return prop;
		}
	}

}