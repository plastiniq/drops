package drops.data 
{
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_Option {
		public var name:String;
		public var value:*;
		
		public function C_Option(name:String, value:* = null) {
			this.name = name;
			this.value = (value) ? value : name;
		}
		
	}

}