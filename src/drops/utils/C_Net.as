package drops.utils 
{
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.net.URLLoader;
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class C_Net {
		
		public static function getData(loader:*):*{
			var data:*;
			if (loader is Loader) {			data = loader.content;}
			else if (loader is URLLoader) {	data = loader.data;}
			else {							trace ('ERROR: undefined loader type', loader);}
			return data;
		}
		
		public static function getLoader(target:*):*{
			var loader:*;
			if (target is LoaderInfo) {		loader = target.loader;}
			else if (target is URLLoader) {	loader = target;}
			else {							trace ('ERROR: undefined target type', target);}
			return loader;
		}
		
		public static function getInfo(loader:*):* {
			var info:*;
			if (loader is Loader) {			info = loader.contentLoaderInfo; }
			else if (loader is URLLoader) {	info = loader; }
			else {							trace ('ERROR: undefined loader type', loader);}
			return info;
		}
	}

}