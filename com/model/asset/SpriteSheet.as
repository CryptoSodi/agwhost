package com.model.asset
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class SpriteSheet extends SpriteSheetBase
	{
		private var _dest:Point;
		private var _height:Number;
		private var _width:Number;

		override public function init( sprite:*, xml:XML, url:String ):void
		{
			_dest = new Point();
			super.init(sprite, xml, url);
		}

		override protected function cutFrame( label:String, frame:int, region:Rectangle, frameRect:Rectangle ):void
		{
			_width = (!frameRect) ? region.width : frameRect.width;
			_height = (!frameRect) ? region.height : frameRect.height;
			_dest.setTo((!frameRect) ? 0 : Math.abs(frameRect.x), (!frameRect) ? 0 : Math.abs(frameRect.y));
			var bmd:BitmapData = new BitmapData(_width, _height, true, 0);
			bmd.copyPixels(_sprite, region, _dest);
			_frames[label][frame] = bmd;
		}

		public function addFrame( label:String, frame:int, bmd:BitmapData, forceBuilt:Boolean = false ):void
		{
			if (!_frames[label])
				_frames[label] = [];
			_frames[label][frame] = bmd;

			if (forceBuilt)
			{
				_begunLoad = _built = true;
				_sprite = null;
				cleanupBuild();
			}
		}

		override public function destroy():void
		{
			if (_frames)
			{
				for (var label:String in _frames)
				{
					for (var i:int = 0; i < _frames[label].length; i++)
					{
						_frames[label][i].dispose();
					}
					_frames[label].length = 0;
					_frames[label] = null;
					delete _frames[label];
				}
			}
			super.destroy();
		}
	}
}
