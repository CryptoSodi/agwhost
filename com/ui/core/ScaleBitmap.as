/**
 *
 *	ScaleBitmap
 *
 * 	@version	1.1
 * 	@author 	Didier BRUN	-  http://www.bytearray.org
 *
 * 	@version	1.2.1
 * 	@author		Alexandre LEGOUT - http://blog.lalex.com
 *
 * 	@version	1.2.2
 * 	@author		Pleh
 *
 * 	Project page : http://www.bytearray.org/?p=118
 *
 */

package com.ui.core
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;

	public class ScaleBitmap extends Bitmap
	{
		protected var _height:Number        = 0;
		protected var _matrix:Matrix;
		protected var _originalBitmap:BitmapData;
		protected var _scaled:Boolean;
		protected var _scale9Grid:Rectangle = null;
		protected var _width:Number         = 0;

		public function ScaleBitmap( bmpData:BitmapData = null, pixelSnapping:String = "auto", smoothing:Boolean = false )
		{
			_matrix = new Matrix();
			_scaled = false;

			// original bitmap
			if (bmpData)
				_originalBitmap = bmpData;

			// super constructor
			super(_originalBitmap, pixelSnapping, smoothing);
		}

		// ------------------------------------------------
		//
		// ---o public methods
		//
		// ------------------------------------------------

		/**
		 * setter bitmapData
		 */
		override public function set bitmapData( bmpData:BitmapData ):void
		{
			if (_scaled && super.bitmapData)
				super.bitmapData.dispose();
			_originalBitmap = bmpData;
			_scaled = false;
			if (bmpData)
			{
				if (_scale9Grid != null)
				{
					if (!validGrid(_scale9Grid))
					{
						_scale9Grid = null;
					}
					setSize(_width, _height);
				} else
				{
					super.bitmapData = bmpData;
				}
			}
		}

		public function get src():BitmapData
		{
			return _originalBitmap;
		}

		/**
		 * setter width
		 */
		override public function set width( w:Number ):void
		{
			_width = w;
			setSize(w, _height);
		}

		/**
		 * setter height
		 */
		override public function set height( h:Number ):void
		{
			_height = h;
			setSize(_width, h);
		}

		/**
		 * set scale9Grid
		 */
		override public function set scale9Grid( r:Rectangle ):void
		{
			// Check if the given grid is different from the current one
			if ((_scale9Grid == null && r != null) || (_scale9Grid != null && !_scale9Grid.equals(r)))
			{
				if (r == null)
				{
					// If deleting scalee9Grid, restore the original bitmap
					// then resize it (streched) to the previously set dimensions
					_scale9Grid = null;
					bitmapData = _originalBitmap;
					setSize(_width, _height);
				} else
				{
					if (!validGrid(r))
					{
						throw(new Error("#001 - The _scale9Grid does not match the original BitmapData"));
						return;
					}

					_scale9Grid = r.clone();
					resizeBitmap(width, height);
					scaleX = 1;
					scaleY = 1;
				}
			}
		}

		private function validGrid( r:Rectangle ):Boolean
		{
			return r.right <= _originalBitmap.width && r.bottom <= _originalBitmap.height;
		}

		/**
		 * get scale9Grid
		 */
		override public function get scale9Grid():Rectangle
		{
			return _scale9Grid;
		}

		/**
		 * setSize
		 */
		public function setSize( w:Number, h:Number ):void
		{
			if (_scale9Grid == null)
			{
				if (w > 0)
					super.width = w;
				if (h > 0)
					super.height = h;
			} else
			{
				w = Math.max(w, _originalBitmap.width);
				h = Math.max(h, _originalBitmap.height);
				if (w > 0 && h > 0)
				{
					_width = w;
					_height = h;
					resizeBitmap(w, h);
				}
			}
		}

		/**
		 * get original bitmap
		 */
		public function getOriginalBitmapData():BitmapData
		{
			return _originalBitmap;
		}

		// ------------------------------------------------
		//
		// ---o protected methods
		//
		// ------------------------------------------------

		/**
		 * resize bitmap
		 */
		protected function resizeBitmap( w:Number, h:Number ):void
		{
			_scaled = true;
			var bmpData:BitmapData = new BitmapData(w, h, true, 0x00000000);

			var rows:Array         = [0, _scale9Grid.top, _scale9Grid.bottom, _originalBitmap.height];
			var cols:Array         = [0, _scale9Grid.left, _scale9Grid.right, _originalBitmap.width];

			var dRows:Array        = [0, _scale9Grid.top, h - (_originalBitmap.height - _scale9Grid.bottom), h];
			var dCols:Array        = [0, _scale9Grid.left, w - (_originalBitmap.width - _scale9Grid.right), w];

			var origin:Rectangle;
			var draw:Rectangle;

			for (var cx:int = 0; cx < 3; cx++)
			{
				for (var cy:int = 0; cy < 3; cy++)
				{
					origin = new Rectangle(cols[cx], rows[cy], cols[cx + 1] - cols[cx], rows[cy + 1] - rows[cy]);
					draw = new Rectangle(dCols[cx], dRows[cy], dCols[cx + 1] - dCols[cx], dRows[cy + 1] - dRows[cy]);
					_matrix.identity();
					_matrix.a = draw.width / origin.width;
					_matrix.d = draw.height / origin.height;
					_matrix.tx = draw.x - origin.x * _matrix.a;
					_matrix.ty = draw.y - origin.y * _matrix.d;
					bmpData.draw(_originalBitmap, _matrix, null, null, draw, smoothing);
				}
			}
			super.bitmapData = bmpData;
		}

		public function destroy():void
		{
			if (_scaled && super.bitmapData)
				super.bitmapData.dispose();
			filters = [];
			_matrix.identity();
			_width = _height = 0;
			_originalBitmap = null;
			_scaled = false;
			_scale9Grid = null;
		}
	}
}
