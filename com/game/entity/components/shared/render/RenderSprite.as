package com.game.entity.components.shared.render
{
	import com.game.entity.components.shared.Animation;
	import com.game.entity.components.shared.IRender;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;

	public class RenderSprite extends Sprite implements IRender
	{
		private var _bitmap:Bitmap;
		private var _colorFilter:ColorMatrixFilter;
		private var _colorMatrix:Array;
		private var _filters:Array;
		private var _matrix:Matrix;

		public function RenderSprite()
		{
			_bitmap = new Bitmap();
			addChild(_bitmap);
		}

		public function updateFrame( image:*, animation:Animation, forceResize:Boolean = false ):void
		{
			if (image)
				_bitmap.bitmapData = BitmapData(image);
		}

		public function applyTransform( rot:Number, sx:Number, sy:Number, scaleFirst:Boolean, offsetX:Number, offsetY:Number ):void
		{
			if (!_matrix)
				_matrix = new Matrix();
			_matrix.identity();
			_matrix.translate(-offsetX, -offsetY);
			if (scaleFirst)
			{
				_matrix.scale(sx, sy);
				_matrix.rotate(rot);
			} else
			{
				_matrix.rotate(rot);
				_matrix.scale(sx, sy);
			}
			_matrix.translate(x + offsetX, y + offsetY);
			transform.matrix = _matrix;
			_bitmap.smoothing = true;
		}

		public function addGlow( color:uint, strength:Number = 1, blur:Number = 1, resolution:Number = .5 ):void
		{
			if (_colorFilter == null)
				initColorMode();
			_filters.push(new GlowFilter(color, 1, 6 / resolution, 6 / resolution, strength));
			filters = _filters;
		}
		public function removeGlow():void
		{
			if (!_filters)
				return;
			_filters.pop();
			filters = _filters;
		}

		public function get color():uint  { return transform.colorTransform.color; }
		public function set color( value:uint ):void
		{
			if (value != 0xffffff)
			{
				if (_colorFilter == null)
					initColorMode();
				_colorMatrix[0] = (((value >> 16) & 0xFF) / 0xFF);
				_colorMatrix[6] = (((value >> 8) & 0xFF) / 0xFF);
				_colorMatrix[12] = ((value & 0xFF) / 0xFF);
				_colorFilter.matrix = _colorMatrix;

				filters = _filters;
			} else
				filters.length = 0;
		}

		/**
		 * Setting up the necessary objects to perform coloring just once here to avoid
		 * creating new ones each time the color is changed. this helps with performance
		 * and garbage collection
		 */
		private function initColorMode():void
		{
			_colorFilter = new ColorMatrixFilter();
			_colorMatrix = [1, 0, 0, 0, 0,
							0, 1, 0, 0, 0,
							0, 0, 1, 0, 0,
							0, 0, 0, 1, 0];
			_filters = [_colorFilter];
		}

		override public function get height():Number  { return _bitmap.height; }
		override public function get width():Number  { return _bitmap.width; }

		public function destroy():void
		{
			if (_matrix)
			{
				_matrix.identity();
				transform.matrix = _matrix;
			}
			_matrix = null;
			_bitmap.bitmapData = null;
			_bitmap.smoothing = false;
			alpha = scaleX = scaleY = 1;
			visible = true;
			rotation = 0;
			blendMode = BlendMode.NORMAL;
			_colorFilter = null;
			_colorMatrix = null;
			if (_filters)
			{
				_filters.length = 0;
				filters = _filters;
				_filters = null;
			}
		}
	}
}
