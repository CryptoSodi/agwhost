package com.model.asset
{
	import flash.utils.Dictionary;

	public class SpritePack implements ISpritePack
	{
		private var _cache:Dictionary;
		private var _format:String;
		private var _is3D:Boolean;
		private var _ready:Boolean;
		private var _spriteSheets:Vector.<ISpriteSheet>;
		private var _type:String;
		private var _usedBy:int;

		public function SpritePack( type:String, usedBy:int, format:String )
		{
			_cache = new Dictionary(true);
			_format = format;
			_is3D = _ready = false;
			_spriteSheets = new Vector.<ISpriteSheet>;
			_type = type;
			_usedBy = usedBy;
		}

		public function getFrame( label:String, frame:int ):*
		{
			if (!_ready)
				return null;
			if (!_cache[label])
				getFrames(label);
			return _cache[label][frame];
		}

		public function getFrames( label:String ):Array
		{
			if (!_ready)
				return null;
			if (!_cache[label])
			{
				for (var i:int = 0; i < _spriteSheets.length; i++)
				{
					if (_spriteSheets[i].getFrames(label))
					{
						_cache[label] = _spriteSheets[i].getFrames(label);
						break;
					}
				}
			}
			return _cache[label];
		}

		public function addSpriteSheet( sheet:ISpriteSheet ):void
		{
			if (!sheet.built)
				_ready = false;
			if (!_is3D && sheet.is3D)
				_is3D = true;
			sheet.format = _format;
			sheet.incReferenceCount();
			_spriteSheets.push(sheet);
		}

		public function get is3D():Boolean  { return _is3D; }
		public function get ready():Boolean
		{
			if (!_ready && _spriteSheets.length > 0)
			{
				for (var i:int = 0; i < _spriteSheets.length; i++)
				{
					if (!_spriteSheets[i].built)
						return false;
				}
				_ready = true;
			}
			return true;
		}

		public function get spriteSheets():Vector.<ISpriteSheet>  { return _spriteSheets; }
		public function get type():String  { return _type; }
		public function get usedBy():int  { return _usedBy; }

		public function destroy():void
		{
			_cache = null;
			_ready = false;
			_spriteSheets.length = 0;
			_spriteSheets = null;
		}
	}
}
