package drops.ui
{
	import drops.core.C_Box;
	import drops.core.C_SkinnableBox;
	import drops.data.C_Child;
	import drops.data.C_Description;
	import drops.data.C_Property;
	import drops.data.C_Skin;
	import drops.data.C_SkinFrame;
	import drops.data.C_SkinState;
	import drops.events.C_Event;
	import drops.graphics.Wedge;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_ProgressBar extends C_Box {
		private var _track:C_SkinnableBox;
		private var _progress:C_SkinnableBox;
		private var _progressMask:Shape;
		
		private var _progressValue:Number;
		
		private var _mode:String;
		public static const RADIAL_TYPE:String = "radial";
		public static const HORIZONTAL_TYPE:String = "horizontal";
		public static const HORIZONTAL_SCALE_TYPE:String = "horizontalScale";
		
		public static var description:C_Description = new C_Description();
		description.pushChild(new C_Child('track', 'track'));
		description.pushChild(new C_Child('progress track', 'progressTrack'));
		
		description.pushGroup('Position and Size', 2);
		description.lastGroup.pushProperty(C_Property.NUMBER, 'x', 'X');
		description.lastGroup.pushProperty(C_Property.NUMBER, 'y', 'Y');
		description.lastGroup.pushProperty(C_Property.NUMBER, 'width', 'Width');
		description.lastGroup.pushProperty(C_Property.NUMBER, 'height', 'Height');
		description.pushGroup('Mounts');
		description.lastGroup.pushProperty(C_Property.MOUNTS, 'mounts');
		description.pushGroup('Options');
		description.lastGroup.pushProperty(C_Property.NUMBER, 'progress', 'Progress');
		description.lastGroup.pushProperty(C_Property.MENU, 'mode');
		description.lastProperty.addOption('radial', RADIAL_TYPE);
		description.lastProperty.addOption('horizontal mask', HORIZONTAL_TYPE);
		description.lastProperty.addOption('horizontal scale', HORIZONTAL_SCALE_TYPE);
		/*description.pushGroup('Track Skin');
		description.lastGroup.pushProperty(C_Property.SKIN, 'skin', null, null, 'track');
		description.lastProperty.addOption('Normal Skin', C_SkinnableBox.BACKGROUND_SKIN);
		description.pushGroup('Progress Track Skin');
		description.lastGroup.pushProperty(C_Property.SKIN, 'skin', null, null, 'progressTrack');
		description.lastProperty.addOption('Normal Skin', C_SkinnableBox.BACKGROUND_SKIN);*/
		
		public function C_ProgressBar() {
			super.width = 100;
			super.height = 10;
			
			_progressValue = 60;

			_track = new C_SkinnableBox();
			_track.skin = new C_Skin(null, null, null, 0xefedf5);
			addChild(_track);
			
			_progress = new C_SkinnableBox();
			_progress.skin = new C_Skin(null, null, null, 0x5c5885);
			addChild(_progress);
			
			_progressMask = new Shape();
			_progressMask.visible = false;
			addChild(_progressMask);
			
			mode = HORIZONTAL_SCALE_TYPE;
			
			addEventListener(C_Event.RESIZE, resizeHandler);
		}
		
		//----------------------------------------------
		//	H A N D L E R S
		//----------------------------------------------
		private function resizeHandler(e:Event):void {
			refresh();
		}
		
		//----------------------------------------------
		//	S E T  /  G E T
		//----------------------------------------------
		public function get progressTrack():C_SkinnableBox {
			return _progress;
		}
		
		public function get track():C_SkinnableBox {
			return _track;
		}
		
		public function get mode():String {
			return _mode;
		}
		
		public function set mode(value:String):void {
			_mode = value;
			if (value == HORIZONTAL_SCALE_TYPE) {
				_progress.mask = null;
				_progressMask.visible = false;
			}
			else {
				_progress.mask = _progressMask;
				_progressMask.visible = true;
			}
			
			refresh();
		}
		
		public function get progress():Number {
			return _progressValue;
		}
		
		public function set progress(value:Number):void {
			_progressValue = Math.max(0, Math.min(100, value));
			updateProgress();
		}
		//--------------------------------------------
		//	O V E R R I D E D
		//--------------------------------------------

		//----------------------------------------------
		//	P U B L I C
		//----------------------------------------------
		public function refresh():void {
			_track.width = width;
			_track.height = height;
			updateProgress();
		}
		
		//----------------------------------------------
		//	P R I V A T E
		//----------------------------------------------
		private function updateProgress():void {
			if (_mode === HORIZONTAL_SCALE_TYPE) {
				_progress.width = int(width * (_progressValue / 100));
				_progress.height = height;
			}
			else {
				_progress.width = width;
				_progress.height = height;
				_progressMask.graphics.clear();
				_progressMask.graphics.beginFill(0xFF0000);
				
				if (_mode === HORIZONTAL_TYPE) {
					_progressMask.x = 0;
					_progressMask.y = 0;
					_progressMask.graphics.drawRect(0, 0, int(width * (_progressValue / 100)), height);
				}
				if (_mode === RADIAL_TYPE) {
					_progressMask.x = width * 0.5;
					_progressMask.y = height * 0.5;
					Wedge.draw(_progressMask.graphics, 0, (_progressValue / 100) * 360, width * 0.5, height * 0.5);
				}
			}
		}		
	}
}