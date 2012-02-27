package drops.net {
	import com.adobe.serialization.json.JSON;
	import drops.events.C_Event;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.Dictionary;
	/**
	 * @version 1.0
	 * @author Dmitry Malyovaniy
	 */
	public class C_SQL extends EventDispatcher{
		private var _host:String;
		private var _loaders:Dictionary;
		
		public function C_SQL(host:String) {
			_host = host;
			_loaders = new Dictionary();
		}
		//-------------------------------------------------------
		//	H A N D L E R S
		//-------------------------------------------------------
		private function completeHandler(e:Event):void {
			if (e.target.data != undefined) {
				_loaders[e.target].call(this, JSON.decode(e.target.data));
			}
			
			e.target.removeEventListener(Event.COMPLETE, completeHandler);
			e.target.close();
			delete _loaders[e.target];
		}
		
		//-------------------------------------------------------
		//	P U B L I C
		//-------------------------------------------------------
		public function query(handler:Function, query:String):void {
			var params:URLVariables = new URLVariables();
			var request:URLRequest = new URLRequest();
			var loader:URLLoader = new URLLoader();
			
			params.query = query;
			request.data = params;
			request.method = URLRequestMethod.POST;
			request.url = _host;
			loader.load(request);
			
			loader.addEventListener(Event.COMPLETE, completeHandler);
			_loaders[loader] = handler;
		}

	}

}