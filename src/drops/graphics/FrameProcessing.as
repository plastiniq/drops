package drops.graphics {
	import drops.data.C_Background;
	import drops.data.C_Shape;
	import drops.data.C_Skin;
	import drops.data.C_SkinFrame;
	import drops.data.effects.C_EffectResult;
	import drops.data.effects.C_EffectsArray;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.GraphicsPath;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import org.bytearray.display.ScaleBitmap;
	/**
	 * ...
	 * @author ...
	 */
	public class FrameProcessing {
		private static const SHAPE:Shape = new Shape();
		private static const MATRIX:Matrix = new Matrix();
		private static const DRAW_MATRIX:Matrix = new Matrix();
		
		public static function drawFrame(target:Shape, skin:C_Skin, state:String, w:Number, h:Number, filtered:Boolean):void {
			target.graphics.clear();
			target.scaleX = 1.0;
			target.scaleY = 1.0;
			
			var frame:C_SkinFrame = skin.frames[state];
			var bg:C_Background = (frame.background) ? frame.background : skin.background;
			var effects:C_EffectsArray = (frame.effects.length) ? frame.effects : skin.effects;

			var bmd:BitmapData;
			
			if (effects.length > 0 && filtered) {
				if (bg.cachedBitmap && bg.cachedW == w && bg.cachedH == h) {
					bmd = bg.cachedBitmap;
				}
				else {
					bmd = getBgBitmapdata(bg, w, h, 1.0);
					bg.cachedBitmap = bmd;
					bg.cachedW = w;
					bg.cachedH = h;
				}
				
				var fResult:C_EffectResult = EffectsProcessing.generate(bmd, effects, bg.fillAlpha as Number);
				MATRIX.tx = fResult.rect.x;
				MATRIX.ty = fResult.rect.y;
				
				target.graphics.beginBitmapFill(fResult.bmd, MATRIX);
				target.graphics.drawRect(MATRIX.tx, MATRIX.ty, fResult.rect.width, fResult.rect.height);
			}
			else {
				drawBackground(bg, target, w, h, bg.fillAlpha as Number);
				target.width = w;
				target.height = h;
			}
		}
		
		private static function getBgBitmapdata(background:C_Background, w:Number, h:Number, alpha:Number):BitmapData {
			SHAPE.graphics.clear();
			SHAPE.scaleX = 1.0;
			SHAPE.scaleY = 1.0;
			
			var bmd:BitmapData;

			drawBackground(background, SHAPE, w, h, alpha);
			var bounds:Rectangle = SHAPE.getBounds(SHAPE);
			
			var scaX:Number = w / bounds.width;
			var scaY:Number = h / bounds.height;
		
			SHAPE.scaleX = scaX;
			SHAPE.scaleY = scaY;
			
			bounds.x *= scaX;
			bounds.y *= scaY;
			bounds.width *= scaX;
			bounds.height *= scaY;
			
			bmd = new BitmapData(bounds.width, bounds.height, true, 0);
			DRAW_MATRIX.createBox(scaX, scaY, 0, -bounds.x, -bounds.y);

			bmd.draw(SHAPE, DRAW_MATRIX);
	
			return bmd;
		}
		
		private static function drawBackground(bg:C_Background, target:Shape, w:Number, h:Number, alpha:Number):void {
			if (bg.bitmapdata) {
				ScaleBitmap.draw(bg.bitmapdata, target.graphics, w, h, bg.scale9Rect, null, false, bg.repeatBitmap);
			}
			else {
				target.graphics.beginFill(bg.fillColor as uint, alpha);
				(bg.strokeColor && bg.strokeThickness) ? target.graphics.lineStyle(bg.strokeThickness as Number, bg.strokeColor as uint, bg.strokeAlpha ? bg.strokeAlpha as Number : 1) : target.graphics.lineStyle();
				target.scale9Grid = null;
				
				if (bg.graphicsPath) {
					target.graphics.drawPath(bg.normalizedPath.commands, bg.normalizedPath.data, bg.normalizedPath.winding);
					target.scale9Grid = bg.scale9Rect;
				}
				else if (bg.shape == C_Shape.CIRCLE) {
					target.graphics.drawEllipse( -0.25, -0.25, w + .5, h + .5);
				}
				else {
					if ((bg.ltRoundness + bg.rtRoundness + bg.rbRoundness + bg.lbRoundness) == 0) {
						target.graphics.drawRect(0, 0, w, h);
					}
					else {
						target.graphics.drawRoundRectComplex(0, 0, w, h, bg.ltRoundness, bg.rtRoundness, bg.lbRoundness, bg.rbRoundness);
					}
				}
			}
		}
	}

}