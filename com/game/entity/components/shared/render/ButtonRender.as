package com.game.entity.components.shared.render
{
	import com.game.entity.components.shared.Animation;
	import com.game.entity.components.shared.IRender;
	import com.ui.core.component.label.Label;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Sprite;

	public class ButtonRender extends Sprite implements IRender
	{
		private var _back:Bitmap;
		private var _label:Label;
		private var _scaleX:Number;

		public function ButtonRender()
		{
			_back = new Bitmap();
			_scaleX = 0;
			addChild(_back);
		}

		public function updateFrame( image:*, animation:Animation, forceResize:Boolean = false ):void
		{
			if (animation.ready && !_back.bitmapData)
			{
				_back.bitmapData = BitmapData(animation.spritePack.getFrame(animation.label, 0));
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

		override public function get scaleY():Number  { return 1; }
		override public function set scaleY( value:Number ):void  {}

		public function set text( v:String ):void
		{
			if (!_label)
			{
				_label = new Label(12, 0xecffff, 60, 22, true, "Open Sans");
				_label.constrictTextToSize = false;
			}
			_label.text = v;
			_label.x = 2;
			addChild(_label);
		}

		public function destroy():void
		{
			_scaleX = 0;
			_back.bitmapData = null;
			if (_label)
			{
				_label.destroy();
				removeChild(_label);
				_label = null;
			}
			alpha = 1;
			visible = true;
			rotation = 0;
			blendMode = BlendMode.NORMAL;
		}
	}
}
