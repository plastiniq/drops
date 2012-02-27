/**
*
*
*	ScaleBitmapSprite
*	
*	@author		Didier Brun
*	@author 	Jerôme Decoster
*	@version	1.1
*
*/

package org.bytearray.display {
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;

	public class ScaleBitmapSprite extends Sprite
	{
		private var _bitmapData:BitmapData;
		protected var _height:Number;
		protected var _width:Number;
		private var inner:Rectangle;
		private var minHeight:Number;
		private var minWidth:Number;
		private var outer:Rectangle;
		private var outerHeight:Number;
		private var outerWidth:Number;
		private var smooth:Boolean;
		
		/**
		 * @param bitmapData BitmapData source
		 * @param inner Inner rectangle (relative to 0,0)
		 * @param outer Outer rectangle (relative to 0,0)
		 * @param smooth If <code>false</code>, upscaled bitmap images are rendered by using a nearest-neighbor 
		 * algorithm and look pixelated. If <code>true</code>, upscaled bitmap images are rendered by using a 
		 * bilinear algorithm. Rendering by using the nearest neighbor algorithm is usually faster.
		 */
		function ScaleBitmapSprite(bitmapData:BitmapData,
							 inner:Rectangle,
							 outer:Rectangle = null,
							 smooth:Boolean = false)
		{	
			_bitmapData = bitmapData;
			this.inner = inner;
			this.outer = outer;
			this.smooth = smooth;
			
			if (outer != null)
			{		
				_width = outer.width;
				_height = outer.height;
				outerWidth = bitmapData.width - outer.width;
				outerHeight = bitmapData.height - outer.height;
			}
			else
			{
				_width = inner.width;
				_height = inner.height;
				outerWidth = 0;
				outerHeight = 0;
			}
			
			minWidth = bitmapData.width - inner.width - outerWidth + 2;
			minHeight = bitmapData.height - inner.height - outerHeight + 2;
		}
		
		//--------------------------------------
		//  EVENTS
		//--------------------------------------
		protected function onRender(event:Event = null):void 
		{
			/*graphics.clear();
			
			
			 * Math.floor optimisation (works only with positive values)
			 * 
			 * Slower 1733ms
			 * var test:Number = Math.floor(1.5);
			 * 
			 * Fastest 145ms
			 * var test:int = 1.5 >> 0;
			 
			
			ScaleBitmap.draw(_bitmapData,
									 graphics,
									 (_width + outerWidth) >> 0,
									 (_height + outerHeight) >> 0,
									 inner,
									 outer,
									 smooth);*/
		}
		
		protected function draw():void{
			graphics.clear();
			
			/*
			 * Math.floor optimisation (works only with positive values)
			 * 
			 * Slower 1733ms
			 * var test:Number = Math.floor(1.5);
			 * 
			 * Fastest 145ms
			 * var test:int = 1.5 >> 0;
			 */
			
			ScaleBitmap.draw(_bitmapData,
									 graphics,
									 (_width + outerWidth) >> 0,
									 (_height + outerHeight) >> 0,
									 inner,
									 outer,
									 smooth);
		}
		
		//--------------------------------------
		//  PUBLIC
		//--------------------------------------
		
		/**
		 * setter deactivated
		 */
		override public function set scaleX(value:Number):void
		{
		}
		
		/**
		 * setter deactivated
		 */
		override public function set scaleY(value:Number):void
		{
		}
		
		/**
		 * @inheritDoc
		 */
		override public function get width():Number{ return _width; }
		
		/**
		 * @inheritDoc
		 */
		override public function set width(value:Number):void
		{
			_width = value > minWidth ? value : minWidth;
			draw();
		}
		
		/**
		 * @inheritDoc
		 */
		override public function get height():Number{ return _height; }
		
		/**
		 * @inheritDoc
		 */
		override public function set height(value:Number):void
		{
			_height = value > minHeight ? value : minHeight;
			draw();
		}
		
		/**
		 * The BitmapData object being referenced.
		 */
		public function get bitmapData():BitmapData{ return _bitmapData; }
		
		public function set bitmapData(value:BitmapData):void
		{	
			_bitmapData = value;
			draw();
		}
	}
}