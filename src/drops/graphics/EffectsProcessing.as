package drops.graphics {
	import drops.data.effects.C_EffectConverter;
	import drops.data.effects.C_EffectResult;
	import drops.data.effects.C_EffectsArray;
	import drops.data.effects.C_EffectType;
	import drops.data.effects.C_GradientData;
	import drops.data.effects.samples.C_EffectSample;
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.Shape;
	import flash.filters.BitmapFilter;
	import flash.filters.BlurFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author Dmitry Malyovaniy
	 */
	public class EffectsProcessing {
		private static const ZERO_POINT:Point = new Point(0, 0);
		private static const MATRIX:Matrix = new Matrix();
		private static const PI180:Number = Math.PI / 180;
		private static const SHAPE:Shape = new Shape();
		//------------------------------------------------------------------
		//	P U B L I C
		//------------------------------------------------------------------
		public static function generate(source:BitmapData, effects:C_EffectsArray, fillAlpha:Number = 100):C_EffectResult {
			var inner:BitmapData = new BitmapData(source.width, source.height, true, 0x000000);
			var outers:Vector.<C_EffectResult> = new Vector.<C_EffectResult>();
			var tmpBmd:BitmapData;
			var outerBmd:BitmapData;
			var nativeFilter:BitmapFilter;
			var srcRect:Rectangle = source.rect;
			var dstRect:Rectangle = srcRect.clone();
			var fRect:Rectangle;
			var innerIsEmpty:Boolean = true;
			var f:Object;
			var i:int = -1;
			
			while (++i < effects.length) {
				SHAPE.graphics.clear();
				f = effects[i];
				
				if (f is C_EffectType.COLOR) {
					tmpBmd = new BitmapData(srcRect.width, srcRect.height, true, ((f.alpha * 255) << 24) | f.color);
					//BitmapProcessing.maxAlpha(source, tmpBmd);
					//inner = BitmapProcessing.innerEffectOverlay(inner, tmpBmd, 1.0);
					inner = BitmapProcessing.innerEffectComposite(source, inner, tmpBmd, true);
					//inner.copyPixels(tmpBmd, source.rect, ZERO_POINT, null, null, true);
					innerIsEmpty = false;
				}
				else if (f is C_EffectType.GLOW || f is C_EffectType.SHADOW || f is C_EffectType.STROKE) {
					nativeFilter = C_EffectConverter.convertToNative(f as C_EffectSample, true);
					if (f.inner) {
						tmpBmd = new BitmapData(srcRect.width, srcRect.height, true, 0x000000);
						tmpBmd.applyFilter(source, inner.rect, ZERO_POINT, nativeFilter);
						inner = BitmapProcessing.innerEffectComposite(source, inner, tmpBmd);
						innerIsEmpty = false;
					}
					else {
						fRect = source.generateFilterRect(srcRect, nativeFilter);
						tmpBmd = new BitmapData(fRect.width, fRect.height, true, 0);
						tmpBmd.applyFilter(source, fRect, ZERO_POINT, nativeFilter)
						outers.push(new C_EffectResult(tmpBmd, fRect, f.inner));
						dstRect = dstRect.union(fRect);
					}
				}
				else if (f is C_EffectType.GRADIENT) {
					var gd:C_GradientData = f.gradientData;
					MATRIX.createGradientBox(srcRect.width, srcRect.height, -f.angle * PI180);
					SHAPE.graphics.beginGradientFill(f.type, gd.colors, gd.alphas, gd.ratios, MATRIX);
					SHAPE.graphics.drawRect(0, 0, srcRect.width, srcRect.height);
					tmpBmd = new BitmapData(srcRect.width, srcRect.height, true, 0);
					tmpBmd.draw(SHAPE);
					inner = BitmapProcessing.innerEffectComposite(source, inner, tmpBmd, true);
					innerIsEmpty = false;
				}
				else if (f is C_EffectType.NOISE) {
					var alphaBmd:BitmapData = new BitmapData(srcRect.width + f.blurX * 2, srcRect.height + f.blurY * 2, true, 0);
					tmpBmd = new BitmapData(srcRect.width, srcRect.height, true, (255 << 24) | f.color);
					alphaBmd.noise(f.randomSeed, 0, f.dencity * 2.55, BitmapDataChannel.ALPHA, false);
					if (f.blurX || f.blurY) {
						alphaBmd.applyFilter(alphaBmd, alphaBmd.rect, ZERO_POINT, new BlurFilter(f.blurX, f.blurY));
					}
					tmpBmd.copyChannel(alphaBmd, new Rectangle(f.blurX, f.blurY, srcRect.width, srcRect.height), ZERO_POINT, BitmapDataChannel.ALPHA, BitmapDataChannel.ALPHA);
					inner = BitmapProcessing.innerEffectComposite(source, inner, tmpBmd, true);
					alphaBmd.dispose();
					innerIsEmpty = false;
				}
			}
			
			inner = BitmapProcessing.innerEffectOverlay(source, inner, fillAlpha);

			if (outers.length) {
				outerBmd = new BitmapData(dstRect.width, dstRect.height, true, 0);
				var dstPoint:Point = new Point();
				for (i = 0; i < outers.length; i++) {
					dstPoint.x = outers[i].rect.x - dstRect.x;
					dstPoint.y = outers[i].rect.y - dstRect.y;
					outerBmd.copyPixels(outers[i].bmd, outers[i].bmd.rect, new Point(dstPoint.x, dstPoint.y), null, null, true);
					outers[i].bmd.dispose();
				}
				outerBmd = BitmapProcessing.outerEffectOverlay(outerBmd, inner, new Point(-dstRect.x, -dstRect.y));
			}
			else {
				outerBmd = inner;
			}

			return new C_EffectResult(outerBmd, dstRect, false);
		}
		
	}

}