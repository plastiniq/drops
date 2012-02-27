package drops.data {
	import drops.core.C_Box;
	import drops.events.C_Event;
	import drops.ui.C_Label;
	import drops.ui.C_LabeledBox;
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public dynamic class C_LabeledGroup extends Array {
		public var maxLabel:C_Label;
		
		public function C_LabeledGroup() {
		}
		
		//-------------------------------------------------------
		//	H A N D L E R S
		//-------------------------------------------------------
		private function resizeBoxHandler(e:C_Event):void {
			if (e.data == C_Box.BOTH || e.data == C_Box.WIDTH) {
				if (e.target.width > maxLabel.width) {
					maxLabel = e.target as C_Label;
					alignAll();
				}
				else if (e.target === maxLabel) {
					refreshMaxLabel();
					alignAll();
				}
			}
		}
		
		//-------------------------------------------------------
		//	P U B L I C
		//-------------------------------------------------------
		public function addBox(box:C_LabeledBox):void {
			if (!box || this.indexOf(box) > -1) return;
			
			if (!maxLabel || (box.label.width > maxLabel.width)) {
				maxLabel = box.label;
				alignAll();
			}
			else {
				box.align();
			}
			
			box.label.addEventListener(C_Event.RESIZE, resizeBoxHandler);
			this.push(box);
		}
		
		public function removeBox(box:C_LabeledBox):void {
			var index:int = this.indexOf(box);
			if (index == -1) return;

			box.label.removeEventListener(C_Event.RESIZE, resizeBoxHandler);
			this.splice(index, 1);
			
			if (box.label === maxLabel) {
				refreshMaxLabel();
				alignAll();
			}
		}
		
		public function refreshMaxLabel():void {
			var i:int = this.length;
			maxLabel = null;
			while (--i > -1) if (maxLabel === null || this[i].label.width > maxLabel.width) maxLabel = this[i].label;
		}
		
		//-------------------------------------------------------
		//	P R I V A T E
		//-------------------------------------------------------
		private function alignAll():void {
			var i:int = this.length;
			while (--i > -1) this[i].align();
		}
	}

}