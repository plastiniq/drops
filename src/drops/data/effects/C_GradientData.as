package drops.data.effects {
	import flash.display.GradientType;
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_GradientData {
		public var colors:Array;
		public var alphas:Array;
		public var ratios:Array;
		
		public function C_GradientData(colors:Array = null, alphas:Array = null, ratios:Array = null) {
			this.colors = (colors) ? colors : [0xff0000, 0x000000];
			this.alphas = (alphas) ? alphas : [1, 1];
			this.ratios = (ratios) ? ratios : [0, 255];
		}
		
		public function clone():C_GradientData {
			var data:C_GradientData = new C_GradientData();
			data.colors = colors.slice();
			data.alphas = alphas.slice();
			data.ratios = ratios.slice();
			return data;
		}
	}

}