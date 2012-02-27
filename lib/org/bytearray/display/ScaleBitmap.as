/**
*
*
*	ScaleBitmap
*	
*	@author		Didier Brun
*	@author 	Jerôme Decoster
*	@version	1.1
* 
* 	@updated	Malyovaniy Dmitry
*
*/

package org.bytearray.display
{
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class ScaleBitmap
	{
		//--------------------------------------
		//  PUBLIC
		//--------------------------------------
		
		/**
		 * @param bitmapData BitmapData source
		 * @param graphics Graphics to draw
		 * @param width Draw width
		 * @param height Draw height
		 * @param inner Inner rectangle (relative to 0,0)
		 * @param outer Outer rectangle (relative to 0,0)
		 * @param smooth If <code>false</code>, upscaled bitmap images are rendered by using a nearest-neighbor 
		 * algorithm and look pixelated. If <code>true</code>, upscaled bitmap images are rendered by using a 
		 * bilinear algorithm. Rendering by using the nearest neighbor algorithm is usually faster.
		 */
		public static function draw(bitmapData:BitmapData,
									graphics:Graphics,
									width:Number,
									height:Number,
									inner:Rectangle,
									outer:Rectangle = null,
									smooth:Boolean = false,
									repeat:Boolean = false):void
		{	
			
			// center bitamp area for repeat
			var centerArea:BitmapData;
			if (repeat) {
				centerArea = new BitmapData(inner.width, inner.height, true, 0x000000);
				centerArea.copyPixels(bitmapData, inner, new Point(0, 0));
			}
			
			// some useful local vars
			var x:int, y:int;
			var ox:Number = 0, oy:Number;
			var dx:Number = 0, dy:Number;
			var wid:Number, hei:Number;
			var dwid:Number, dhei:Number;
			var sw:int = bitmapData.width;
			var sh:int = bitmapData.height;
			
			var mat:Matrix = new Matrix();
			
			var widths:Array = [inner.left + 1,
								inner.width - 2,
								sw - inner.right + 1];
			
			var heights:Array = [inner.top + 1,
								 inner.height - 2,
								 sh - inner.bottom + 1];
			
			var rx:Number = width - widths[0] - widths[2];
			var ry:Number = height - heights[0] - heights[2];
			var ol:Number = (outer != null) ? -outer.left : 0;
			var ot:Number = (outer != null) ? -outer.top : 0;
			
			var cellRepeat:Boolean;
			var cellMat:Matrix;
			var cellBitmapData:BitmapData;
			
			// let's draw
			for (x; x < 3 ;x++)
			{
				// original width
				wid = widths[x];
				// draw width						
				dwid = x==1 ? rx : wid;
				// original & draw offset
				dy = oy = 0;

				for (y = 0; y < 3; y++)
				{
					// original height
					hei = heights[y];
					// draw height
					dhei = y==1 ? ry : hei;
		
					if (dwid > 0 && dhei > 0)
					{

						if (x == 1 && y == 1 && repeat) 
						{
							mat.a = 1;
							mat.d = 1;
							mat.tx = 0;
							mat.ty = 0;
							mat.translate(ox, oy);
							cellRepeat = true;
							cellBitmapData = centerArea;
						}
						else 
						{
							// some matrix computation
							mat.a = dwid / wid;
							mat.d = dhei / hei;
							mat.tx = -ox * mat.a + dx;
							mat.ty = -oy * mat.d + dy;
							mat.translate(ol, ot);
							cellRepeat = false;
							cellBitmapData = bitmapData;
						}
						
						
						
						// draw the cell
						graphics.beginBitmapFill(cellBitmapData, mat, cellRepeat, smooth);
						graphics.drawRect(dx + ol, dy + ot, dwid, dhei);
					}
					
					// offset incrementation
					oy += hei;
					dy += dhei;
				}
				
				// offset incrementation
				ox += wid;
				dx += dwid;
			}
			
			graphics.endFill();
		}
	}
}



