package drops.net {
	import com.adobe.serialization.json.JSON;
	import drops.events.C_Event;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.geom.Vector3D;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_RimLoader extends EventDispatcher{
		
		private var _jsonLoader:URLLoader;
		private var _jsonRequest:URLRequest;
		private var _textureLoader:Loader;
		
		private var _dataCache:Object;
		private var _session:int;
		
		public function C_RimLoader() {
			_jsonLoader = new URLLoader();
			_jsonRequest = new URLRequest();
			_textureLoader = new Loader();
			_dataCache = { };
			
			_jsonLoader.addEventListener(Event.COMPLETE, jsonCompleteHandler);
			_textureLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, textureCompleteHandler);
		}
		
		//-----------------------------------------------
		//	H A N D L E R S
		//-----------------------------------------------
		private function textureCompleteHandler(e:Event):void {
			_dataCache[_session].texture = (_textureLoader.content as Bitmap).bitmapData.clone();
			dispatchEvent(new C_Event(C_Event.ALL_COMPLETE, _session));
		}
		
		private function jsonCompleteHandler(e:Event):void {
			if (_jsonLoader.data != undefined) {
				_dataCache[_session] = JSON.decode(_jsonLoader.data);
				_dataCache[_session].relief = arrToRelief(_dataCache[_session].relief);

				closeLoader(_textureLoader);
				_textureLoader.load(new URLRequest(_dataCache[_session].textureUrl));
			}
		}
		
		//-----------------------------------------------
		//	P U B L I C
		//-----------------------------------------------
		public function load(id:int):void {
			if (_dataCache[id]) {
				dispatchEvent(new C_Event(C_Event.ALL_COMPLETE, id));
			}
			else {
				_session = id;
				closeLoader(_jsonLoader);
				
				var params:URLVariables = new URLVariables();
				params.id = id;
				_jsonRequest.data  = params;
				_jsonRequest.method = URLRequestMethod.POST;
				_jsonRequest.url = "http://www.c3.dev/index.php";
				
				_jsonLoader.load(_jsonRequest);
			}
		}
		
		//-----------------------------------------------
		//	S E T  /  G E T
		//-----------------------------------------------
		public function get data():Object {
			return _dataCache;
		}
		
		//-----------------------------------------------
		//	P R I V A T E
		//-----------------------------------------------
		private static function arrToRelief(arr:Array):Vector.<Vector3D> {
			var vec:Vector.<Vector3D> = new Vector.<Vector3D>;
			
			var i:int;
			var len:int = arr.length;
			for (i = 0; i < len; i += 2) {
				vec.push(new Vector3D(arr[i], arr[i + 1]));
			}
			return vec;
		}
		
		private function closeLoader(loader:Object):void {
			var info:Object;
			
			if (loader is Loader) {
				info = loader.contentLoaderInfo;
			}
			else if (loader is URLLoader) {
				info = loader;
			}

			if ((info) && (info.bytesTotal > 0) && (info.bytesTotal < info.bytesLoaded)) {
				loader.close();
				trace("close");
			}
		}
	}
}