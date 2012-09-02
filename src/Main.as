package {
	import drops.ui.C_Button;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class Main extends Sprite {
		
		public function Main():void {
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void {
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			var btn:C_Button = new C_Button();
			btn.setMounts(10, 10, 10, 10);
			btn.skin.background.fillColor = 0xff0000;
			btn.skin.background.fillAlpha = 1.0;
			//stage.addChild(btn);
		}
		
		//---------------------------------------------------
		//	H A N D L E R S
		//---------------------------------------------------
		
	}
	
}