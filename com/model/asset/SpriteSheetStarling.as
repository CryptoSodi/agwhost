package com.model.asset
{
	import flash.geom.Rectangle;

	import org.starling.textures.Texture;

	public class SpriteSheetStarling extends SpriteSheetBase
	{
		private var _baseTexture:Texture;

		override public function init( sprite:*, xml:XML, url:String ):void
		{
			super.init(sprite, xml, url);
			//TODO crashes sometimes
			_baseTexture = Texture.fromBitmapData(_sprite, false, false, 1, _format);
		}

		override protected function cutFrame( label:String, frame:int, region:Rectangle, frameRect:Rectangle ):void
		{
			_frames[label][frame] = Texture.fromTexture(_baseTexture, region, frameRect);
		}

		override public function destroy():void
		{
			for (var label:String in _frames)
			{
				_frames[label].length = 0;
				_frames[label] = null;
				delete _frames[label];
			}

			if (_baseTexture)
				_baseTexture.dispose();

			_baseTexture = null;
			super.destroy();
		}
	}
}
