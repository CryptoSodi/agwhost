package com.game.entity.components.shared.render
{
	import com.game.entity.components.shared.Animation;
	import com.game.entity.components.shared.IRender;

	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Point;

	import org.starling.display.BlendMode;
	import org.starling.display.DisplayObject;
	import org.starling.display.Image;
	import org.starling.filters.BlurFilter;
	import org.starling.textures.Texture;

	public class RenderStarling extends Image implements IRender
	{
		public static var DEFAULT_TEXTURE:Texture;

		private var _matrix:Matrix;
		private var _resize:Boolean;

		public function RenderStarling()
		{
			if (!DEFAULT_TEXTURE)
				DEFAULT_TEXTURE = Texture.fromBitmapData(new BitmapData(1, 1, false, 0), false);
			super(DEFAULT_TEXTURE);
			_resize = true;
		}

		public function updateFrame( image:*, animation:Animation, forceResize:Boolean = false ):void
		{
			if (image)
			{
				texture = Texture(image);
				if (_resize || forceResize)
				{
					readjustSize();
					_resize = false;
					visible = true;
				}
			} else
			{
				_resize = true;
				texture = Texture(DEFAULT_TEXTURE);
				readjustSize();
			}
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
			transformationMatrix = _matrix;
		}

		override public function hitTest( localPoint:Point, forTouch:Boolean = false ):DisplayObject
		{
			localPoint = globalToLocal(localPoint)
			return super.hitTest(localPoint, forTouch);
		}

		public function addGlow( color:uint, strength:Number = 1, blur:Number = 1, resolution:Number = .5 ):void  { filter = BlurFilter.createGlow(color, strength, 1, resolution); }
		public function removeGlow():void  { if (filter) filter.dispose(); filter = null; }

		public function destroy():void
		{
			if (_matrix)
			{
				_matrix.identity();
				transformationMatrix = _matrix;
			}
			blendMode = BlendMode.NORMAL;
			_matrix = null;
			_resize = true;
			alpha = scaleX = scaleY = 1;
			visible = false;
			rotation = 0;
			color = 0xffffff;
			dispose();
		}
	}
}
