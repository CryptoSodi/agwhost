package com.game.entity.components.shared.render
{
	import com.game.entity.components.shared.Animation;
	import com.game.entity.components.shared.IRender;
	import com.game.entity.factory.VCFactory;

	import org.starling.display.BlendMode;
	import org.starling.display.Sprite;
	import org.starling.text.TextField;
	import org.starling.utils.VAlign;

	public class NameRenderStarling extends Sprite implements IRender
	{
		private var _label:TextField;
		private var _text:String = '';
		private var _color:uint;

		public function NameRenderStarling()
		{
			_color = VCFactory.FONT_COLOR;
		}

		public function updateFrame( image:*, animation:Animation, forceResize:Boolean = false ):void
		{

		}

		public function applyTransform( rot:Number, sx:Number, sy:Number, scaleFirst:Boolean, offsetX:Number, offsetY:Number ):void
		{

		}

		public function addGlow( color:uint, strength:Number = 1, blur:Number = 1, resolution:Number = .5 ):void  {}
		public function removeGlow():void  {}

		public function get color():uint  { return (_label != null) ? _label.color : _color; }
		public function set color( value:uint ):void
		{
			if (_label)
				_label.color = value;

			_color = value;
		}

		override public function get height():Number  { return VCFactory.TEXT_HEIGHT; }
		override public function get width():Number  { return VCFactory.TEXT_WIDTH; }

		public function set text( v:String ):void
		{
			if (!_label)
			{
				removeChild(_label);
				_label = new TextField(VCFactory.TEXT_WIDTH, VCFactory.TEXT_HEIGHT, '', 'OpenSansBoldBitmap', VCFactory.FONT_SIZE, _color);
				_label.kerning = true;
				_label.vAlign = VAlign.TOP;
				addChild(_label);
			}
			if (_text != v)
			{
				_label.text = v;
				_text = v;
			}
		}

		public function destroy():void
		{
			alpha = scaleX = scaleY = 1;
			visible = true;
			rotation = 0;
			blendMode = BlendMode.NORMAL;
		}
	}
}
