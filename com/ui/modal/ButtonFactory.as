package com.ui.modal
{
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.button.ButtonBase;

	import flash.display.BitmapData;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;

	public class ButtonFactory
	{
		private static const _bmdStore:Dictionary = new Dictionary();

		public static function getBitmapButton( upName:String, dx:Number, dy:Number, text:String = '', textColor:uint = 0, overName:String = null, downName:String = null,
												disabledName:String = null, selectName:String = null, horzMargin:Number = 0, vertMargin:Number = 0 ):BitmapButton
		{
			var button:BitmapButton     = new BitmapButton();
			button.x = dx;
			button.y = dy;
			var upSkin:BitmapData       = getBMD(upName);
			var overSkin:BitmapData     = getBMD(overName);
			var downSkin:BitmapData     = getBMD(downName);
			var disabledSkin:BitmapData = getBMD(disabledName);
			var selectSkin:BitmapData   = getBMD(selectName);
			button.init(upSkin, overSkin, downSkin, disabledSkin, selectSkin);
			applyText(button, text, textColor);
			button.horzTxtMargin = horzMargin;
			button.vertTxtMargin = vertMargin;
			return button;
		}

		public static function getCloseButton( x:Number, y:Number ):BitmapButton  { return getBitmapButton('CloseBtnUpBMD', x, y, '', 0, 'CloseBtnRollOverBMD', 'CloseBtnDownBMD'); }

		private static function applyText( button:ButtonBase, text:String, textColor:uint ):void
		{
			if (text != null && text != '')
			{
				button.text = text;
				button.textColor = textColor;
			}
		}

		public static function getBMD( name:String ):BitmapData
		{
			if (name == null || name == '')
				return null;
			if (!_bmdStore[name])
			{
				var bmdClass:Class = Class(getDefinitionByName(name));
				var bmd:BitmapData = BitmapData(new bmdClass());
				_bmdStore[name] = bmd;
			}
			return _bmdStore[name];
		}
	}
}
