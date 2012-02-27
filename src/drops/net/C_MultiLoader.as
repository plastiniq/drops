package drops.net {
	import drops.events.C_Event;
	import drops.utils.C_Net;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	/**
	 * @version 1.0
	 * @author Dmitry Malyovaniy
	 */
	public class C_MultiLoader extends EventDispatcher {
		private var _tasks:Dictionary;
		private var _process:Dictionary;
		private var _result:Dictionary;
		
		public function C_MultiLoader():void {
			_process = new Dictionary();
			_tasks = new Dictionary();
			_result = new Dictionary();
		}
		
		//-----------------------------------------------
		//	H A N D L E R S
		//-----------------------------------------------
		private function progressHandler(e:ProgressEvent):void {
			dispatchEvent(new C_Event(C_Event.PROGRESS, progress));
		}
		
		private function completeHandler(e:Event):void {
			var key:* = C_Net.getLoader(e.target);
			_result[key] = C_Net.getData(key);
			_process[key] = null;
			
			if (dictLength(_process) == 0) {
				dispatchEvent(new C_Event(C_Event.ALL_COMPLETE, _result));
				killProcess(_process, completeHandler, progressHandler);
			}
			key = null;
		}
		
		//-----------------------------------------------
		//	P U B L I C
		//-----------------------------------------------
		public function addTask(loader:*, request:URLRequest):void {
			_tasks[loader] = request;
		}
		
		public function start():void {
			killProcess(_process, completeHandler, progressHandler);
			_result = new Dictionary();
			var info:*;
			var key:*;
			
			for (key in _tasks) {
				key.load(_tasks[key]);
				_process[key] = { };
				info = C_Net.getInfo(key);
				info.addEventListener(Event.COMPLETE, completeHandler);
				info.addEventListener(ProgressEvent.PROGRESS, progressHandler);
				delete _tasks[key];
			}
			key = null;
		}
		
		//-----------------------------------------------
		//	S E T  /  G E T
		//-----------------------------------------------
		public function get progress():Number {
			var total:Number = 0.;
			var loaded:Number = 0.;
			var info:*;
			var loader:*;
			
			for (loader in _process) {
				info = C_Net.getInfo(loader);
				total += info.bytesTotal;
				loaded += info.bytesLoaded;
			}
			return (loaded / total) * 100;
		}
		
		public function get result():Dictionary {
			return _result;
		}
		
		//-----------------------------------------------
		//	P R I V A T E
		//-----------------------------------------------
		private static function dictLength(dict:Dictionary):int {
			var k:*, i:int = 0;
			for (k in dict) if (dict[k] != null) i++;
			return i;
		}
		
		private static function killProcess(process:Dictionary, handlerComplete:Function, handlerProgress:Function):void {
			var info:*;
			var key:*;
			for (key in process) {
				info = C_Net.getInfo(key);
				info.removeEventListener(Event.COMPLETE, handlerComplete);
				info.removeEventListener(ProgressEvent.PROGRESS, handlerProgress);
				if (info.bytesTotal > 0 && info.bytesTotal > info.bytesLoaded) {	
					key.close();
				}
				delete process[key];
			}
			key = null;
		}
	}

}