package drops.ui 
{
	import drops.core.C_Box;
	import drops.core.C_ScrollableArea;
	import drops.events.C_Event;
	import flash.events.Event;
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_Accordeon extends C_ScrollableArea {
		private var _sections:Array;
		private var _animationBegin:Boolean;
		
		public function C_Accordeon() {
			width = 100;
			height = 100;
			_animationBegin = false;
			_sections = [];
			overflow = SCROLL;
		}
		
		//--------------------------------------------
		//	H A N D L E R S
		//--------------------------------------------
		private function sectionResizeHandler(e:C_Event):void {
			if (e.data === C_Box.WIDTH) return;
			var i:int = 0;
			while (++i < _sections.length) {
				_sections[i].y = _sections[i - 1].y + _sections[i - 1].height;
			}
			if (!_animationBegin) refresh();
		}
		
		private function animationBeginHandler(e:Event):void {
			_animationBegin = true;
		}
		
		private function animationCompleteHandler(e:Event):void {
			_animationBegin = false;
			refresh();
		}
		
		//--------------------------------------------
		//	P U B L I C
		//--------------------------------------------
		public function pushSection(section:C_AccordeonSection):C_AccordeonSection {
			section.y = (_sections.length > 0) ? _sections[_sections.length -1].y + _sections[_sections.length -1].height : 0;
			section.addEventListener(C_Event.ANIMATION_BEGIN, animationBeginHandler);
			section.addEventListener(C_Event.ANIMATION_COMPLETE, animationCompleteHandler);
			section.addEventListener(C_Event.RESIZE, sectionResizeHandler);
			_sections.push(section);
			addChild(section);
			return section;
		}
		
		//--------------------------------------------
		//	P R I V A T E
		//--------------------------------------------

	}

}