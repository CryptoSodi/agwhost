package com.ui.core.component.misc
{
	import com.ui.core.component.IComponent;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;

	public class ImageComponent extends Sprite implements IComponent
	{
		protected var _bitmap:Bitmap;
		protected var _imageHeight:Number;
		protected var _imageWidth:Number;
		protected var _center:Boolean;

		public function init( imageWidth:Number, imageHeight:Number ):void
		{
			_imageHeight = imageHeight;
			_imageWidth = imageWidth;

			if (!_bitmap)
			{
				_bitmap = new Bitmap();
				addChild(_bitmap);
			}
		}

		public function onImageLoaded( asset:BitmapData ):void
		{
			if (asset && _bitmap)
			{
				_bitmap.bitmapData = asset;
				_bitmap.width = asset.width;
				_bitmap.height = asset.height;
				var scale:Number = 0;
				if (_bitmap.width > _imageWidth)
				{
					scale = _imageWidth / _bitmap.width;
					_bitmap.width *= scale;
					_bitmap.height *= scale;
				}
				if (_bitmap.height > _imageHeight)
				{
					scale = _imageHeight / _bitmap.height;
					_bitmap.width *= scale;
					_bitmap.height *= scale;
				}

				if (_center)
				{
					_bitmap.x = (_imageWidth - _bitmap.width) * 0.5;
					_bitmap.y = (_imageHeight - _bitmap.height) * 0.5;
				}
			}
		}

		public function get image():Bitmap
		{
			return _bitmap;
		}
		
		public function clearBitmap():void  { if (_bitmap) _bitmap.bitmapData = null; }

		override public function get height():Number  { return (_bitmap) ? _bitmap.height : 0; }
		override public function get width():Number  { return (_bitmap) ? _bitmap.width : 0; }

		public function get center():Boolean  { return _center; }
		public function set center( value:Boolean ):void  { _center = value; }

		public function get enabled():Boolean  { return visible; }
		public function set enabled( value:Boolean ):void  { visible = value; }

		public function get smoothing():Boolean  { return (_bitmap) ? _bitmap.smoothing : 0; }
		public function set smoothing( v:Boolean ):void  { if (_bitmap) _bitmap.smoothing = v; }

		public function destroy():void
		{
			while (numChildren > 0)
				removeChildAt(0);

			alpha = 1;
			center = false;
			mask = null;
			filters = [];
			x = y = 0;
			visible = true;

			if (_bitmap)
			{
				_bitmap.bitmapData = null;
				_bitmap = null;
			}
		}
	}
}
