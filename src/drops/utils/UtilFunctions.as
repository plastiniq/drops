package drops.utils {
 import drops.data.C_Description;
 import drops.data.C_Property;
 import drops.data.effects.samples.C_EffectSample;
 import flash.utils.describeType;
 import flash.utils.getDefinitionByName;
 import flash.utils.getQualifiedClassName;
 
 public class UtilFunctions {
	 public static function cloneByDescription(source:*):Object {
		if (!source) return null;
		
		var cloned:* = new source.constructor();
		var descr:* = C_Accessor.getDescription(source);
		if (descr) {
			var prop:Object;
			var value:*;
			var target:Object;
			
			for each(prop in descr) {
				target = (prop.hasOwnProperty('target')) ? prop.target : null;
				if (prop.cloneFunc) {
					value = C_Accessor.getValue(C_Accessor.getValue(source, prop.method, target), prop.cloneFunc);
				}
				else {
					value = C_Accessor.getValue(source, prop.method, target);
				}
				C_Accessor.setValue(cloned, prop.method, value, target);
			}
		}
		return cloned;
	 }
 
     public static function newSibling(sourceObj:Object):* {
         if(sourceObj) {
 
             var objSibling:*;
             try {
                 var classOfSourceObj:Class = getDefinitionByName(getQualifiedClassName(sourceObj)) as Class;
                 objSibling = new classOfSourceObj();
             }
 
             catch(e:Object) {}
 
             return objSibling;
         }
         return null;
     }
 
     public static function clone(source:Object):Object {
         var clone:Object;
         if(source) {
             clone = newSibling(source);
 
             if(clone) {
                 copyData(source, clone);
             }
         }
 
         return clone;
     }
	 
	 public function independentCopy(source:*):*{
		// if (source is Number || source is int || source is String) return source;
	 }
 
     public static function copyData(source:Object, destination:Object, banned:Array = null, sourceInfo:XML = null):void {
		if (!source || !destination) return;
		
		if (!banned) banned = [];

		if (!sourceInfo) sourceInfo = describeType(source);
		var prop:XML;
		
		for each(prop in sourceInfo.variable) {
			if (source.hasOwnProperty(prop.@name) && destination.hasOwnProperty(prop.@name) && banned.indexOf(String(prop.@name)) == -1) {
				destination[prop.@name] = source[prop.@name];
			}
		}

		for each(prop in sourceInfo.accessor) {
			if (prop.@access == "readwrite" && banned.indexOf(String(prop.@name)) == -1) {
				if (destination.hasOwnProperty(prop.@name) && source.hasOwnProperty(prop.@name)) {
					destination[prop.@name] = source[prop.@name];
				}
			}
		}

     }
 }
}