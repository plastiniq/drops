package drops.data 
{
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_TaskEntry {
		public var target:*;
		public var method:*;
		public var value:*;
		
		public function C_TaskEntry(method:*, target:*, value:* = null) {
			this.method = method;
			this.value = value;
			this.target = target;
		}
		
	}

}