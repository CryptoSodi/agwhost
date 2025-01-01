package com.game.entity.components.shared.render
{
	import com.game.entity.components.shared.Animation;
	import com.game.entity.components.shared.IRender;

	import org.starling.display.BlendMode;
	import org.starling.display.Image;
	import org.starling.display.Sprite;
	import org.starling.text.TextField;
	import org.starling.textures.Texture;

	public class BarRenderStarling extends Sprite implements IRender
	{
		private var _back:Image;
		private var _fore:Image;
		private var _scaleX:Number;
		private var _string:String;
		private var _text:TextField;

		public function BarRenderStarling()
		{
			_back = new Image(RenderStarling.DEFAULT_TEXTURE);
			_fore = new Image(RenderStarling.DEFAULT_TEXTURE);
			_scaleX = 0;
			addChild(_back);
			addChild(_fore);
		}

		public function updateFrame( image:*, animation:Animation, forceResize:Boolean = false ):void
		{
			if (animation.ready)
			{
				_back.texture = Texture(animation.spritePack.getFrame(animation.label, 0));
				_back.readjustSize();
				_fore.texture = Texture(animation.spritePack.getFrame(animation.label + "Green", 0));
				_fore.readjustSize();
				_fore.scaleX = _scaleX;
			}
		}

		public function applyTransform( rot:Number, sx:Number, sy:Number, scaleFirst:Boolean, offsetX:Number, offsetY:Number ):void
		{
			scaleX = sx;
		}

		public function addGlow( color:uint, strength:Number = 1, blur:Number = 1, resolution:Number = .5 ):void  {}
		public function removeGlow():void  {}

		public function get color():uint  { return 0; }
		public function set color( value:uint ):void  {}

		override public function get scaleX():Number  { return _fore.scaleX; }
		override public function set scaleX( value:Number ):void
		{
			_scaleX = value;
			_fore.scaleX = value;
		}

		public function set text( text:String ):void
		{
			if (!_text || text == null)
			{
				if (_text && contains(_text))
					removeChild(_text);
				_text = new TextField(66, 14, '', "Open Sans", 12, 0xecffff);
				_text.x = 0;
				_text.y = 1;
				_fore.x = _fore.y = 3;
				addChild(_text);
			}
			if (text != null && text != _string)
			{
				_string = text;
				_text.text = text;
			}
		}

		public function destroy():void
		{
			_scaleX = 0;
			//texture = null;
			alpha = 1;
			visible = true;
			rotation = 0;
			if (_text)
			{
				if (contains(_text))
					removeChild(_text);
				_text = null;
			}
			_fore.x = _fore.y = 0;
			_string = null;
			blendMode = BlendMode.NORMAL;
		}
	}
}
