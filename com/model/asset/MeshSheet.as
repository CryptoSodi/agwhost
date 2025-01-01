package com.model.asset
{
	import flash.utils.Dictionary;

	import org.away3d.entities.Mesh;

	public class MeshSheet extends SpriteSheetBase implements ISpriteSheet
	{
		private var _height:Number;
		private var _mesh:Mesh;
		private var _width:Number;

		override public function init( sprite:*, xml:XML, url:String ):void
		{
			_built = true;
			_subtextureIndex = 0;
			_frames = new Dictionary();
			_mesh = sprite;
			_xml = (xml != null) ? xml.SubTexture : null;
			_url = url;
		}

		override public function getFrame( label:String, frame:int ):*
		{
			return _mesh;
		}

		override public function getFrames( label:String ):Array
		{
			if (!_frames[label])
				_frames[label] = [_mesh];
			return _frames[label];
		}

		override public function get is3D():Boolean  { return true; }

		override public function destroy():void
		{
			/*if (_frames)
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
			   }*/
			super.destroy();
		}
	}
}
