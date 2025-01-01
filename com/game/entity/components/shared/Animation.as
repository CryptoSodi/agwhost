package com.game.entity.components.shared
{
	import com.Application;
	import com.model.asset.ISpritePack;

	import org.osflash.signals.Signal;
	import org.starling.textures.Texture;

	public class Animation
	{
		public static const ANIMATION_READY:int        = 0;
		public static const ANIMATION_RENDER_ADDED:int = 1;
		public static const ANIMATION_COMPLETE:int     = 2;

		public var allowTransform:Boolean;
		public var blendMode:String;
		public var center:Boolean;
		public var color:uint                          = 0;
		public var destroyOnComplete:Boolean;
		public var frame:int;
		public var labelChanged:Boolean;
		public var numberOfFrames:int;
		public var offsetX:Number;
		public var offsetY:Number;
		public var playing:Boolean;
		public var replay:Boolean;
		public var scaleX:Number;
		public var scaleY:Number;
		public var spritePack:ISpritePack;
		public var textChanged:Boolean;
		public var textLostContext:Boolean;
		public var time:Number;
		public var transformScaleFirst:Boolean;
		public var visible:Boolean;
		public var duration:Number;
		public var randomStart:Boolean;

		private var _alpha:Number;
		private var _fps:Number;
		private var _frameDuration:Number;
		private var _label:String;
		private var _lostContext:Boolean;
		private var _numListeners:int;
		private var _ready:Boolean;
		private var _render:IRender;
		private var _signal:Signal;
		private var _sprite:*;
		private var _text:String;
		private var _type:String;

		public function init( type:String, label:String, center:Boolean = false, frame:int = 0, fps:Number = 30, visible:Boolean = false, xoffset:Number = 0, yoffset:Number = 0 ):void
		{
			this.center = center;
			allowTransform = destroyOnComplete = labelChanged = _lostContext = _ready = textChanged = textLostContext = false;
			this.frame = frame;
			duration = -1.0;
			_label = label;
			_type = type;
			offsetX = xoffset;
			offsetY = yoffset;
			playing = replay = transformScaleFirst = true;
			time = 0;
			_alpha = numberOfFrames = scaleX = scaleY = 1;
			_fps = fps;
			_frameDuration = 1 / _fps;
			_numListeners = 0;
			this.visible = visible;
			spritePack = null;
			randomStart = false;
		}

		public function addListener( callback:Function ):void
		{
			if (!_signal)
				_signal = new Signal(int, Animation);
			_numListeners++;
			_signal.add(callback);
		}

		public function removeListener( callback:Function ):void
		{
			if (_signal)
			{
				_signal.remove(callback);
				_numListeners--;
			}
		}

		public function dispatch( type:int ):void
		{
			if (_numListeners > 0)
				_signal.dispatch(type, this);
		}

		public function forceReady( v:Boolean = true ):void  { _ready = v; }
		public function deviceLostContext():void
		{
			if (center && _sprite)
			{
				if (Application.STARLING_ENABLED)
				{
					if (render)
					{
						render.x += Texture(_sprite).frame.width * .5;
						render.y += Texture(_sprite).frame.height * .5;
					}
					offsetX -= Texture(_sprite).frame.width * .5;
					offsetY -= Texture(_sprite).frame.height * .5;
				} else
				{
					offsetX -= _sprite.width * .5;
					offsetY -= _sprite.height * .5;
				}
			}
			_lostContext = true;
			_ready = false;
			if (_text)
			{
				textChanged = textLostContext = true;
				if (spritePack == null)
					_ready = true;
			}
			spritePack = null;
			_sprite = null;
		}

		public function get alpha():Number  { return _alpha; }
		public function set alpha( v:Number ):void  { _alpha = v; if (render) render.alpha = _alpha; }

		public function get lostContext():Boolean  { return _lostContext; }

		public function set forceSprite( v:* ):void  { _sprite = v; }
		public function get sprite():*  { return _sprite; }
		public function set sprite( v:* ):void
		{
			if (v)
			{
				if (!_sprite)
				{
					if (center)
					{
						if (Application.STARLING_ENABLED)
						{
							offsetX += Texture(v).frame.width * .5;
							offsetY += Texture(v).frame.height * .5;
						} else
						{
							offsetX += v.width * .5;
							offsetY += v.height * .5;
						}
					}
					_lostContext = false;
					_ready = true;
				}
				_sprite = v;
			}
		}

		public function get label():String  { return _label; }
		public function set label( v:String ):void  { if (_label != v) labelChanged = true; _label = v; }
		[Inline]
		public function get ready():Boolean  { return _ready; }
		public function get render():IRender  { return _render; }
		public function set render( v:IRender ):void  { _render = v; if (_render) dispatch(ANIMATION_RENDER_ADDED); }
		public function get text():String  { return _text; }
		public function set text( v:String ):void  { _text = v; textChanged = true; }
		public function get type():String  { return _type; }
		public function set type( v:String ):void
		{
			_type = v;
			deviceLostContext();
			_lostContext = false;
			frame = 0;
		}

		public function get height():Number
		{
			if (_sprite)
			{
				if (Application.STARLING_ENABLED)
					return Texture(_sprite).frame.height;
				return _sprite.height;
			}
			return 0;
		}
		public function get width():Number
		{
			if (_sprite)
			{
				if (Application.STARLING_ENABLED)
					return Texture(_sprite).frame.width;
				return _sprite.width;
			}
			return 0;
		}

		public function get frameDuration():Number
		{
			// By default return the standard value
			if (this.duration < 0.0)
				return _frameDuration;

			// If there's a duration scale to that length
			return (this.duration / numberOfFrames);
		}

		public function destroy():void
		{
			blendMode = null;
			color = 0;
			render = null;
			spritePack = null;
			if (_signal)
				_signal.removeAll();
			_signal = null;
			_sprite = null;
			_text = null;
		}
	}
}
