package com.model.asset
{

	import com.enum.TimeLogEnum;
	import com.util.TimeLog;

	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;

	import org.as3commons.logging.api.ILogger;
	import org.as3commons.logging.api.getLogger;

	public class SpriteSheetBase implements ISpriteSheet
	{
		protected const _logger:ILogger   = getLogger('SpriteSheet');

		protected var _begunLoad:Boolean  = false;
		protected var _built:Boolean      = false;
		protected var _format:String;
		protected var _frames:Dictionary;
		protected var _referenceCount:int = 0;
		protected var _sprite:BitmapData;
		protected var _subtextureIndex:int;
		protected var _url:String;
		protected var _xml:XMLList;

		public function SpriteSheetBase()
		{
			_begunLoad = _built = false;
			_referenceCount = 0;
		}

		public function init( sprite:*, xml:XML, url:String ):void
		{
			TimeLog.startTimeLog(TimeLogEnum.SPRITESHEET_PARSE, url);
			_subtextureIndex = 0;
			_frames = new Dictionary();
			_sprite = BitmapData(sprite);
			_xml = (xml != null) ? xml.SubTexture : null;
			_url = url;
		}

		public function getFrame( label:String, frame:int ):*
		{
			if (!_frames[label])
			{
				_logger.debug('Label {} does not yet exist on the spritesheet.', label);
				return null;
			}
			if (frame > _frames[label].length)
				frame = _frames[label].length - 1;
			if (!_frames[label][frame])
			{
				_logger.debug('Frame {0} does not yet exist on the spritesheet for label {1}.', [frame, label]);
				return null;
			}

			return _frames[label][frame];
		}

		public function getFrames( label:String ):Array
		{
			if (!_frames[label])
			{
				_logger.debug('Label {} does not yet exist on the spritesheet.', label);
				return null;
			}
			return _frames[label];
		}

		public function build():Boolean
		{
			if (_xml == null)
				return false;
			var subTexture:XML     = _xml[_subtextureIndex];
			var name:String        = subTexture.attribute("name");
			var x:Number           = parseFloat(subTexture.attribute("x"));
			var y:Number           = parseFloat(subTexture.attribute("y"));
			var width:Number       = parseFloat(subTexture.attribute("width"));
			var height:Number      = parseFloat(subTexture.attribute("height"));
			var frameX:Number      = parseFloat(subTexture.attribute("frameX"));
			var frameY:Number      = parseFloat(subTexture.attribute("frameY"));
			var frameWidth:Number  = parseFloat(subTexture.attribute("frameWidth"));
			var frameHeight:Number = parseFloat(subTexture.attribute("frameHeight"));

			var nparams:Array      = name.split("^");
			if (_frames[nparams[0]] == null)
				_frames[nparams[0]] = [];

			var region:Rectangle   = new Rectangle(x, y, width, height);
			var frame:Rectangle    = frameWidth > 0 && frameHeight > 0 ?
				new Rectangle(frameX, frameY, frameWidth, frameHeight) : null;
			if (nparams.length > 1)
				cutFrame(nparams[0], int(nparams[1]), region, frame);
			else
				cutFrame(nparams[0], 0, region, frame);

			_subtextureIndex++;
			if (_subtextureIndex == _xml.length())
			{
				cleanupBuild();
				_built = true;
				_subtextureIndex = 0;
			}
			return true;
		}

		protected function cutFrame( label:String, frame:int, region:Rectangle, frameRect:Rectangle ):void
		{

		}

		protected function cleanupBuild():void
		{
			//dispose of the xml and the bitmapdatas that were used to build the spritesheet
			_xml = null;
			if (_sprite)
			{
				_sprite.dispose();
				_sprite = null;
			}
			TimeLog.endTimeLog(TimeLogEnum.SPRITESHEET_PARSE, url);
		}

		public function incReferenceCount():void  { _referenceCount++; }
		public function decReferenceCount():void  { _referenceCount--; }

		public function get built():Boolean  { return _built; }
		public function get begunLoad():Boolean  { return _begunLoad; }
		public function set begunLoad( v:Boolean ):void  { _begunLoad = v; }
		public function set format( v:String ):void  { _format = v; }
		public function get is3D():Boolean  { return false; }
		public function get referenceCount():int  { return _referenceCount; }
		public function get url():String  { return _url; }

		public function destroy():void
		{
			_frames = null;
			_referenceCount = 0;
			_url = null;
			_xml = null;
		}
	}
}
