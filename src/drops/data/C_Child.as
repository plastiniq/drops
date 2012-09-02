package drops.data {
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_Child {
		public var name:String;
		public var chain:Array;
		
		public function C_Child(name:String, chain:Object) {
			this.name = name;
			this.chain = importChain(chain);
		}
		
		public static function importChain(chain:Object):Array {
			var result:Array;
			if (chain is Array) {
				return chain as Array;
			}
			else if (chain is String) {
				chain = String(chain).replace(/\s/g, '');
				result =  (String(chain).search(',') > -1) ? chain.split(',') : [chain];
			}
			return result;
		}
	}

}