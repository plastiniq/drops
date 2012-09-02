package drops.utils {
	import drops.data.C_Description;
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_Accessor {
		
		public static function setValue(target:*, methodName:String, data:*, targetChain:Object = null):* {
			target = getTarget(target, targetChain);
			
			if (target && target.hasOwnProperty(methodName)) {
				if (target[methodName] is Function) {
					(target[methodName] as Function).apply(target, (data is Array) ? data : [data]);
				}
				else {
					target[methodName] = data;
				}
			}
			else {
				trace('setValue error in Accessor: Target not contains method. Object:', target, 'Method:', methodName);
			}
			return data;
		}
		
		public static function getValue(target:*, methodName:String, targetChain:Object = null):* {
			target = getTarget(target, targetChain);
			if (target.hasOwnProperty(methodName)) {
				return (target[methodName] is Function) ? target[methodName].apply(target) : target[methodName];
			}
			else {
				trace('getValue error in Accessor: Target not contains method. Object:', target, 'Method:', methodName);
				return null;
			}
		}
		
		public static function convertChain(chain:Object):Array {
			if (!chain) return null;
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
		
		public static function getTarget(object:*, chain:Object):*{
			if (!chain) return object;
			
			chain = convertChain(chain);
			var i:int = -1;

			while (++i < chain.length) {
				if (chain[i] == 'constructor' || object.hasOwnProperty(chain[i])) {
					object = object[chain[i]];
				}
				else {
					return null;
				}
			}
			return object;
		}
		
		public static function getDescription(target:*):Object {
			if (!target || !target.constructor.hasOwnProperty('description')) return null;
			return target.constructor.description;
		}
	}
}