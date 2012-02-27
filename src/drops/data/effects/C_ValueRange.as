package drops.data.effects 
{
	/**
	 * ...
	 * @author ...
	 */
	public class C_ValueRange {
		public var min:Number;
		public var max:Number;
		public var step:Number;
		
		public function C_ValueRange(min:Number = 0, max:Number = 100, step:Number = 1) {
			this.min = min;
			this.max = max;
			this.step = step;
		}
		
	}

}