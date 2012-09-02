package drops.graphics {
	import flash.display.BitmapData;
	import flash.display.Shader;
	import flash.display.ShaderJob;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class BitmapProcessing {
		[Embed(source="shaders/AlphaIntersect.pbj", mimeType="application/octet-stream")]
		private static const EMB_ALPHA_INTERSECT:Class;
		private static const ALPHA_INTERSECT:Shader = new Shader(new EMB_ALPHA_INTERSECT() as ByteArray);
		
		[Embed(source="shaders/Merge.pbj", mimeType="application/octet-stream")]
		private static const EMB_MERGE:Class;
		private static const MERGE:Shader = new Shader(new EMB_MERGE() as ByteArray);
		
		[Embed(source="shaders/MergeExclude.pbj", mimeType="application/octet-stream")]
		private static const EMB_MERGE_EXCLUDE:Class;
		private static const MERGE_EXCLUDE:Shader = new Shader(new EMB_MERGE_EXCLUDE() as ByteArray);
		
		[Embed(source="shaders/Add.pbj", mimeType="application/octet-stream")]
		private static const EMB_ADD:Class;
		private static const ADD:Shader = new Shader(new EMB_ADD() as ByteArray);
		
		[Embed(source="shaders/AlphaThreshold.pbj", mimeType="application/octet-stream")]
		private static const EMB_ALPHA_THRESHOLD:Class;
		private static const ALPHA_THRESHOLD:Shader = new Shader(new EMB_ALPHA_THRESHOLD() as ByteArray);
		
		[Embed(source="shaders/Empty.pbj", mimeType="application/octet-stream")]
		private static const EMB_EMPTY:Class;
		private static const EMPTY:Shader = new Shader(new EMB_EMPTY() as ByteArray);
		
		[Embed(source="shaders/innerEffectOverlay.pbj", mimeType="application/octet-stream")]
		private static const EMB_INNER_EFFECT_OVERLAY:Class;
		private static const INNER_EFFECT_OVERLAY:Shader = new Shader(new EMB_INNER_EFFECT_OVERLAY() as ByteArray);
		
		[Embed(source="shaders/innerEffectComposite.pbj", mimeType="application/octet-stream")]
		private static const EMB_INNER_EFFECT_COMPOSITE:Class;
		private static const INNER_EFFECT_COMPOSITE:Shader = new Shader(new EMB_INNER_EFFECT_COMPOSITE() as ByteArray);
		
		[Embed(source="shaders/outerEffectOverlay.pbj", mimeType="application/octet-stream")]
		private static const EMB_OUTER_EFFECT_OVERLAY:Class;
		private static const OUTER_EFFECT_OVERLAY:Shader = new Shader(new EMB_OUTER_EFFECT_OVERLAY() as ByteArray);
		
		[Embed(source="shaders/maxAlpha.pbj", mimeType="application/octet-stream")]
		private static const EMB_MAX_ALPHA:Class;
		private static const MAX_ALPHA:Shader = new Shader(new EMB_MAX_ALPHA() as ByteArray);
		
		public static function alphaIntersect(target:BitmapData, overlay:BitmapData, destPoint:Point, alphaMultiply:Number = 1.0):BitmapData {
			ALPHA_INTERSECT.data.target.input = target;
			ALPHA_INTERSECT.data.overlay.input = overlay;
			//ALPHA_INTERSECT.data.multiply.value = [alphaMultiply];
			ALPHA_INTERSECT.data.destPoint.value[0] =  destPoint.x;
			ALPHA_INTERSECT.data.destPoint.value[1] =  destPoint.y;
			
			var bmd:BitmapData = new BitmapData(target.width, target.height, target.transparent, 0x000000);
			var myJob:ShaderJob = new ShaderJob(ALPHA_INTERSECT, bmd);
			myJob.start(true);
			return bmd;
		}
		
		public static function maxAlpha(sourceBmd:BitmapData, targetBmd:BitmapData):BitmapData {
			MAX_ALPHA.data.source.input = sourceBmd;
			MAX_ALPHA.data.target.input = targetBmd;
			var myJob:ShaderJob = new ShaderJob(MAX_ALPHA, targetBmd);
			myJob.start(true);
			return targetBmd;
		}
		
		public static function innerEffectComposite(sourceBmd:BitmapData, innerBmd:BitmapData, overlayBmd:BitmapData, maxAlpha:Boolean = false):BitmapData {
			INNER_EFFECT_COMPOSITE.data.source.input = sourceBmd;
			INNER_EFFECT_COMPOSITE.data.inner.input = innerBmd;
			INNER_EFFECT_COMPOSITE.data.overlay.input = overlayBmd;
			INNER_EFFECT_COMPOSITE.data.maxAlphaEnabled.value[0] = maxAlpha ? 1 : 0;
			//var res:BitmapData = new BitmapData(innerBmd.width, innerBmd.height, true, 0x000000);
			var myJob:ShaderJob = new ShaderJob(INNER_EFFECT_COMPOSITE, innerBmd);
			myJob.start(true);
			return innerBmd;
		}
		
		public static function innerEffectOverlay(sourceBmd:BitmapData, innerBmd:BitmapData, fillAlpha:Number = 100):BitmapData {
			INNER_EFFECT_OVERLAY.data.source.input = sourceBmd;
			INNER_EFFECT_OVERLAY.data.inner.input = innerBmd;
			INNER_EFFECT_OVERLAY.data.fillAlpha.value[0] =  fillAlpha / 100;
			var res:BitmapData = new BitmapData(sourceBmd.width, sourceBmd.height, sourceBmd.transparent, 0x000000);
			var myJob:ShaderJob = new ShaderJob(INNER_EFFECT_OVERLAY, res);
			myJob.start(true);
			return res;
		}
		
		public static function outerEffectOverlay(outerBmd:BitmapData, innerBmd:BitmapData, destPoint:Point, fillAlpha:Number = 100):BitmapData {
			OUTER_EFFECT_OVERLAY.data.outer.input = outerBmd;
			OUTER_EFFECT_OVERLAY.data.inner.input = innerBmd;
			OUTER_EFFECT_OVERLAY.data.fillAlpha.value[0] =  fillAlpha / 100;
			OUTER_EFFECT_OVERLAY.data.destPoint.value[0] =  destPoint.x;
			OUTER_EFFECT_OVERLAY.data.destPoint.value[1] =  destPoint.y;
			OUTER_EFFECT_OVERLAY.data.innerSize.value[0] =  innerBmd.width;
			OUTER_EFFECT_OVERLAY.data.innerSize.value[1] =  innerBmd.height;
			var myJob:ShaderJob = new ShaderJob(OUTER_EFFECT_OVERLAY, outerBmd);
			myJob.start(true);
			return outerBmd;
		}
		
		public static function alphaThreshold(target:BitmapData):BitmapData {
			ALPHA_THRESHOLD.data.target.input = target;
			var myJob:ShaderJob = new ShaderJob(ALPHA_THRESHOLD, target);
			myJob.start(true);
			return target;
		}
		
		public static function mergeExclude(target:BitmapData, overlay:BitmapData, destPoint:Point):BitmapData {
			MERGE_EXCLUDE.data.target.input = target;
			MERGE_EXCLUDE.data.overlay.input = overlay;
			MERGE_EXCLUDE.data.destPoint.value[0] =  destPoint.x;
			MERGE_EXCLUDE.data.destPoint.value[1] =  destPoint.y;

			MERGE_EXCLUDE.data.overlaySize.value[0] =  overlay.width;
			MERGE_EXCLUDE.data.overlaySize.value[1] =  overlay.height;
			
			var myJob:ShaderJob = new ShaderJob(MERGE_EXCLUDE, target);
			myJob.start(true);
			return target;
		}
		
		public static function add(target:BitmapData, overlay:BitmapData, destPoint:Point):BitmapData {
			ADD.data.target.input = target;
			ADD.data.overlay.input = overlay;
			ADD.data.destPoint.value[0] =  destPoint.x;
			ADD.data.destPoint.value[1] =  destPoint.y;

			ADD.data.overlaySize.value[0] =  overlay.width;
			ADD.data.overlaySize.value[1] =  overlay.height;
			
			var myJob:ShaderJob = new ShaderJob(ADD, target);
			myJob.start(true);
			return target;
		}
		
		public static function merge(target:BitmapData, overlay:BitmapData, destPoint:Point):BitmapData {
			MERGE.data.target.input = target;
			MERGE.data.overlay.input = overlay;
			MERGE.data.destPoint.value[0] =  destPoint.x;
			MERGE.data.destPoint.value[1] =  destPoint.y;

			MERGE.data.overlaySize.value[0] =  overlay.width;
			MERGE.data.overlaySize.value[1] =  overlay.height;
			
			var myJob:ShaderJob = new ShaderJob(MERGE, target);
			myJob.start(true);
			return target;
		}
		
		public static function shadersInit(target:BitmapData):void {
			EMPTY.data.src.input = target;
			var myJob:ShaderJob = new ShaderJob(EMPTY, target);
			myJob.start(true);
		}
	}
}