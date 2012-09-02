package drops.data {
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_Property {
		private var _method:String;
		private var _label:String;
		private var _options:Array;
		private var _target:Array;
		
		public var min:Object;
		public var max:Object;
		public var step:Object;
		
		public var refreshAfterChange:Boolean;
		
		private var _type:String;
		public static const STRING:String = "string";
		public static const NUMBER:String = "number";
		public static const INTEGER:String = "integer";
		public static const PERCENTABLE_NUMBER:String = "percentableNumber";
		public static const BOOLEAN:String = "boolean";
		public static const BITMAPDATA:String = "bitmapdata";
		public static const MENU:String = "menu";
		public static const SKIN:String = "skin";
		public static const FILTERS:String = "filters";
		public static const SLIDER:String = "slider";
		public static const TEXT_FORMAT:String = "textFormat";
		public static const MOUNTS:String = "mounts";
		public static const EMBOSS:String = "emboss";
		
		public function C_Property(type:String, method:String, label:String = null, options:Array = null, target:Object = null) {
			_method = method;
			_type = type;
			_label = label;
			_options = (options == null) ? [] : options;
			
			refreshAfterChange = false;
			
			if (target is Array) {
				_target = target as Array;
			}
			else if (target is String) {
				target = String(target).replace(/\s/g, '');
				_target =  (String(target).search(',') > -1) ? target.split(',') : [target];
			}
		}
		
		//--------------------------------------------------
		//	P U B L I C
		//--------------------------------------------------
		public function setRange(min:Number, max:Number, step:Number = 1):void {
			this.min = min;
			this.max = max;
			this.step = step;
		}
		
		public function addOption(name:String, value:* = null):Object {
			var option:C_Option = new C_Option(name, (value) ? value : name);
			_options.push(option);
			return option;
		}
		
		//--------------------------------------------------
		//	S E T  /  G E T
		//--------------------------------------------------
		public function get target():Object { return _target }
		public function set target(value:Object):void { 
			_target = (value is Array) ? value as Array : (value is String) ? value.split(',') : null; 
		}
		
		public function get options():Array { return _options }
		public function set options(value:Array):void { _options = value }
		
		public function get label():String { return _label }
		public function set label(value:String):void { _label = value }
		
		public function get type():String { return _type }
		public function set type(value:String):void { _type = value }
		
		public function get method():String { return _method }
		public function set method(value:String):void { _method = value }
	}

}