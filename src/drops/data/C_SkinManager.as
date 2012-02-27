package drops.data {
	import drops.events.C_Event;
	import flash.events.EventDispatcher;
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public dynamic class C_SkinManager extends EventDispatcher {
		private var _skin:C_Skin;

		public static var description:C_Description = new C_Description(); 
		description.pushGroup('States');
		description.lastGroup.pushProperty(C_Property.SKIN, 'skin');
		description.lastProperty.addOption('Normal', C_SkinState.NORMAL);
		description.lastProperty.addOption('Selected', C_SkinState.SELECTED);
		description.lastProperty.addOption('Mouse Over', C_SkinState.MOUSE_OVER);
		description.lastProperty.addOption('Mouse Down', C_SkinState.MOUSE_DOWN);
		
		public function C_SkinManager() {
			_skin = new C_Skin();
			 setListeners(_skin, true);
		}
		
		//-----------------------------------------------------
		//	H A N D L E R S
		//-----------------------------------------------------
		private function skinChangeHandler(e:C_Event):void {
			dispatchEvent(new C_Event(C_Event.CHANGE, e.data));
		}
		
		//-----------------------------------------------------
		//	P U B L I C
		//-----------------------------------------------------
		public function get skin():C_Skin {
			return _skin;
		}
		
		public function set skin(value:C_Skin):void {
			 setListeners(_skin, false);
			_skin = (value) ? value : new C_Skin();
			 setListeners(_skin, true);
			dispatchEvent(new C_Event(C_Event.CHANGE, 'all', true));
		}
		
		//-----------------------------------------------------
		//	P R I V A T E
		//-----------------------------------------------------
		private function setListeners(target:C_Skin, enabled:Boolean):void {
			if (!target) return;
			if (enabled) {
				target.addEventListener(C_Event.CHANGE, skinChangeHandler);
			}
			else {
				target.removeEventListener(C_Event.CHANGE, skinChangeHandler);
			}
		}
	}

}