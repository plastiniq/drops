package drops.graphics 
{
	import com.greensock.plugins.TransformMatrixPlugin;
	import com.greensock.plugins.TweenPlugin;
	import com.greensock.TweenMax;
	import com.greensock.easing.*;
	import flash.display.DisplayObject;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Transform;
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class Animations{
		TweenPlugin.activate([TransformMatrixPlugin]);
		
		public function Animations() {
			
		}
		
		public static function resizeAroundCenter(target:DisplayObject, width:Number, height:Number, time:Number = 0.2, onComplete:Function = null):void {
			var diffW:Number = width - target.width;
			var diffH:Number = height - target.height;
			
			var vars:Object = {x:target.x - diffW * 0.5, y:target.y - diffH * 0.5, width:width, height:height};
			if (onComplete !== null) vars.onComplete = onComplete;
			TweenMax.to(target, time, vars);
		}
		
		public static function scaleAroundCenter(obj:DisplayObject, alpha:Number = 1, scaleX:Number = 1.0, scaleY:Number = 1.0, time:Number = 0.2, onComplete:Function = null, onCompleteParams:Array = null, easeFunc:Function = null):void {

			var startW:Number = obj.width / obj.transform.matrix.a;
			var startH:Number = obj.height / obj.transform.matrix.d;
			
			var startX:Number = obj.x - ((startW - obj.width) * 0.5);
			var startY:Number = obj.y - ((startH - obj.height) * 0.5);
			
			var tx:Number = startX + (startW - (startW * scaleX)) * 0.5;
			var ty:Number = startY + (startH - (startH * scaleY)) * 0.5;
			
			var vars:Object = { alpha:alpha, ease:easeFunc, transformMatrix: { a:scaleX, b:0, c:0, d:scaleY, tx:tx, ty:ty }};
			if (onComplete !== null) {
				vars.onComplete = onComplete;
				vars.onCompleteParams = onCompleteParams;
			}
			TweenMax.to(obj, time, vars);
		}
		
		public static function scaleAroundPoint(obj:DisplayObject, scaleX:Number, scaleY:Number, point:Point, time:Number = 0.2):void {
			var startW:Number = obj.width / obj.transform.matrix.a;
			var startH:Number = obj.height / obj.transform.matrix.d;
			
			var newW:Number = startW * scaleX;
			var newH:Number = startH * scaleY;
			
			var tx:Number = obj.x - ((point.x / obj.width) * newW) + point.x;
			var ty:Number = obj.y - ((point.y / obj.height) * newH) + point.y;
			
			TweenMax.to(obj, time, {transformMatrix: { a:scaleX, b:0, c:0, d:scaleY, tx:tx, ty:ty }});
		}
		
	}

}