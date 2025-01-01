package com.game.entity.components.shared.render
{
	import com.game.entity.components.shared.Animation;
	import com.game.entity.components.shared.IRender;
	import com.game.entity.factory.VCFactory;
	import com.ui.core.component.label.Label;

	import flash.display.BlendMode;
	import flash.display.Sprite;

	public class NameRender extends Sprite implements IRender
	{
		private var _label:Label;

		public function NameRender()
		{
			_label = new Label(VCFactory.FONT_SIZE, VCFactory.FONT_COLOR, VCFactory.TEXT_WIDTH, VCFactory.TEXT_HEIGHT, true, 1);
			_label.bold = true;
			_label.useLocalization = false;
			_label.leading = -4;
			_label.constrictTextToSize = false;
			addChild(_label);
		}

		public function updateFrame( image:*, animation:Animation, forceResize:Boolean = false ):void  {}

		public function applyTransform( rot:Number, sx:Number, sy:Number, scaleFirst:Boolean, offsetX:Number, offsetY:Number ):void  {}

		public function addGlow( color:uint, strength:Number = 1, blur:Number = 1, resolution:Number = .5 ):void  {}
		public function removeGlow():void  {}

		public function get color():uint  { return (_label != null) ? _label.textColor : 0; }
		public function set color( value:uint ):void  { if (_label) _label.textColor = value; }

		override public function get height():Number  { return VCFactory.TEXT_HEIGHT; }
		override public function get width():Number  { return VCFactory.TEXT_WIDTH; }

		public function set text( v:String ):void  { _label.text = v; }

		public function destroy():void
		{
			_label.text = '';
			alpha = scaleX = scaleY = 1;
			visible = true;
			rotation = 0;
			blendMode = BlendMode.NORMAL;
		}
	}
}
