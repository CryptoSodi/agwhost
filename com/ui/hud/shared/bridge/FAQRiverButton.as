package com.ui.hud.shared.bridge
{
	import com.enum.ui.ButtonEnum;
	import com.ui.UIFactory;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextFormatAlign;
	import flash.utils.getDefinitionByName;

	import org.osflash.signals.Signal;

	public class FAQRiverButton extends Sprite
	{
		public var onClick:Signal;

		private var _faqIcon:Bitmap;
		private var _faqBtn:BitmapButton;
		private var _btnText:Label;

		private var _helpText:String = 'CodeString.FAQRiver.Help'; //HELP

		public function FAQRiverButton()
		{
			onClick = new Signal();

			var faqIconClass:Class = Class(getDefinitionByName('FAQEightsIconBMD'));
			_faqIcon = new Bitmap(BitmapData(new faqIconClass()));

			_faqBtn = UIFactory.getButton(ButtonEnum.ICON_FRAME, 60, 60);
			_faqBtn.addEventListener(MouseEvent.CLICK, onMouseClick, false, 0, true);

			_btnText = new Label(20, 0xd1e5f7, 100, 25);
			_btnText.bold = true;
			_btnText.constrictTextToSize = false;
			_btnText.align = TextFormatAlign.CENTER;
			_btnText.text = _helpText;

			addChild(_faqBtn);
			addChild(_faqIcon);
			addChild(_btnText);

			layout();
		}

		private function onMouseClick( e:MouseEvent ):void
		{
			if (onClick)
				onClick.dispatch();
			e.stopPropagation();
		}

		private function layout():void
		{
			_faqIcon.x = _faqBtn.x + (_faqBtn.defaultSkinWidth - _faqIcon.width) * 0.5;
			_faqIcon.y = _faqBtn.y + (_faqBtn.defaultSkinHeight - _faqIcon.height) * 0.5;

			_btnText.x = _faqBtn.x + (_faqBtn.width - _btnText.width) * 0.5;
			_btnText.y = _faqBtn.height - 1;
		}

		public function destroy():void
		{
			if (onClick)
				onClick.removeAll();

			onClick = null;

			if (_faqBtn)
			{
				_faqBtn.removeEventListener(MouseEvent.CLICK, onMouseClick);
				_faqBtn.destroy();
			}

			_faqBtn = null;

			if (_btnText)
				_btnText.destroy();

			_btnText = null;

			_faqIcon = null;
		}

	}
}
