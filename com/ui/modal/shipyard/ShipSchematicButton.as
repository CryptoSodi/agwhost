package com.ui.modal.shipyard
{
	import com.ui.core.component.label.Label;
	import com.ui.core.component.button.BitmapButton;
	
	import flash.text.TextFormatAlign;
	
	public class ShipSchematicButton extends BitmapButton
	{
		public function ShipSchematicButton()
		{
			super();
		}
		
		override public function set text( msg:String ):void
		{
			if (!_label)
			{
				_label = new Label(18, 0xffffff, 100, 50);
				_label.align = TextFormatAlign.CENTER;
				addChild(_label);
			}
			_label.text = msg;
			resizeAndLayoutLabel();
		}
		
		override protected function resizeAndLayoutLabel():void
		{
			_label.x = _leftMargin + (defaultSkinWidth - _leftMargin - _rightMargin - _label.width) / 2;
			_label.y = _bitmap.height;
		}
	
		override public function get height():Number
		{
			return _bitmap.height;
		}
		
		override public function get width():Number
		{
			return _bitmap.width;
		}
		
	}
}