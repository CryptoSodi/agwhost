package com.game.entity.components.shared.render
{
	import com.game.entity.components.shared.Animation;
	import com.game.entity.components.shared.IRender;
	import com.ui.core.component.label.Label;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Sprite;

	public class BarRender extends Sprite implements IRender
	{
		private var _back:Bitmap;
		private var _fore:Bitmap;
		private var _label:Label;
		private var _scaleX:Number;
		private var _string:String;

		public function BarRender()
		{
			_back = new Bitmap();
			_fore = new Bitmap();
			_scaleX = 0;
			addChild(_back);
			addChild(_fore);
		}

		public function updateFrame( image:*, animation:Animation, forceResize:Boolean = false ):void
		{
			if (animation.ready && !_back.bitmapData)
			{
				_back.bitmapData = BitmapData(animation.spritePack.getFrame(animation.label, 0));
				_fore.bitmapData = BitmapData(animation.spritePack.getFrame(animation.label + "Green", 0));
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

		override public function get scaleY():Number  { return 1; }
		override public function set scaleY( value:Number ):void  {}

		public function set text( v:String ):void
		{
			if (!_label)
			{
				_label = new Label(12, 0xecffff, 60, 22, true, 1);
				_label.constrictTextToSize = false;
			}
			if (v && v != _string)
			{
				_label.text = v;
				_string = v;
			}
			_label.x = 2;
			_label.y = -2;
			_fore.x = _fore.y = 3;
			addChild(_label);
		}

		public function destroy():void
		{
			_scaleX = 0;
			_back.bitmapData = null;
			_fore.bitmapData = null;
			_fore.x = _fore.y = 0;
			if (_label)
			{
				_label.destroy();
				removeChild(_label);
				_label = null;
				_string = null;
			}
			alpha = 1;
			visible = true;
			rotation = 0;
			blendMode = BlendMode.NORMAL;
		}
	}
}
