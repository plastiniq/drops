package drops.ui {
	import drops.data.C_Emboss;
	import flash.text.TextFormat;
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_ButtonLabel extends C_Label {
		private var _mainColor:Object;
		private var _overlayColor:Object;
		
		private var _mainFormat:TextFormat;
		private var _overlayFormat:TextFormat;
		
		private var _mainEmboss:C_Emboss;
		private var _overlayEmboss:C_Emboss;
		
		public function C_ButtonLabel(text:String = null, format:TextFormat = null) {
			super(text, format);
			_mainColor = super.textColor;
			_mainFormat = super.textFormat;
			_mainEmboss = super.emboss;
		}
		
		//----------------------------------------------------------
		//	O V E R R I D E
		//----------------------------------------------------------
		override public function get emboss():C_Emboss { 
			return _mainEmboss; 
		}
		
		override public function set emboss(value:C_Emboss):void {
			_mainEmboss = value;
			if (!_overlayEmboss) super.emboss = value;
		}
		
		override public function get textFormat():TextFormat { 
			return _mainFormat; 
		}
		
		override public function set textFormat(value:TextFormat):void {
			_mainFormat = value;
			if (!_overlayFormat) super.textFormat = value;
		}
		
		override public function get textColor():Object { 
			return _mainColor; 
		}
		
		override public function set textColor(value:Object):void {
			_mainColor = value;
			if (!_overlayColor) super.textColor = value;
		}
		
		//----------------------------------------------------------
		//	P U B L I C
		//----------------------------------------------------------
		public function set overlayEmboss(value:C_Emboss):void {
			if (value === null) {
				super.emboss = _mainEmboss;
			}
			else {
				_overlayEmboss = value;
				super.emboss = _overlayEmboss;
			}
		}
		
		public function set overlayTextFormat(value:TextFormat):void {
			if (value === null) {
				super.textFormat = _mainFormat;
			}
			else {
				_overlayFormat = value;
				super.textFormat = value;
			}
		}
		
		public function set overlayTextColor(value:Object):void {
			if (value === null) {
				super.textColor = _mainColor;
			}
			else {
				_overlayColor = value;
				super.textColor = value;
			}
		}
		
	}

}