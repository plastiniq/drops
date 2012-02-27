package drops.data {
	import drops.data.C_Property;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public dynamic class C_Description extends Array {
		public var childrens:Array;
		public var transparent:Boolean;
		public var showBounds:Boolean;
		public var lockChildrensSkin:Boolean;
		public var addMethod:String;
		public var supportedClasses:Array;
		public var defaultSize:Rectangle;
		
		public function C_Description(childrens:Array = null, transparent:Boolean = false, showBounds:Boolean = true) {
			this.childrens = (childrens === null) ? [] : childrens;
			this.transparent = transparent;
			this.showBounds = showBounds;
			defaultSize = new Rectangle(0, 0, 100, 100);
		}	
		
		//--------------------------------------------------
		//	S E T  /  G E T
		//--------------------------------------------------
		public function get lastProperty():C_Property {
			return lastGroup.lastProperty;
		}
		
		public function get lastGroup():C_GroupProperties {
			return this[length - 1];
		}
		
		//--------------------------------------------------
		//	P U B L I C
		//--------------------------------------------------
		public function setContainer(addMethod:String, classes:Array):void {
			this.addMethod = addMethod;
			this.supportedClasses = (classes) ? classes : [];
		}
		
		public function pushChild(child:C_Child):void {
			childrens.push(child);
		}
		
		public function pushGroup(title:String, numColumns:int = 1, expanded:Boolean = true):C_GroupProperties {
			push(new C_GroupProperties(title, null, numColumns, expanded));
			return lastGroup;
		}
		
	}
}