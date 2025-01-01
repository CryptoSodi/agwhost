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

	public class DiscordButton extends Sprite
	{
		public var onClick:Signal;

		private var _discordIcon:Bitmap;
		private var _discordBtn:BitmapButton;
		private var _btnText:Label;

		private var _helpText:String = 'CodeString.Discord.Link'; //Discord

		public function DiscordButton()
		{
			onClick = new Signal();

			var discordIconClass:Class = Class(getDefinitionByName('DiscordIconBMD')); //Discord Icon
			_discordIcon = new Bitmap(BitmapData(new discordIconClass()));

			_discordBtn = UIFactory.getButton(ButtonEnum.ICON_FRAME, 60, 60);
			_discordBtn.addEventListener(MouseEvent.CLICK, onMouseClick, false, 0, true);

			_btnText = new Label(20, 0xd1e5f7, 100, 25);
			_btnText.bold = true;
			_btnText.constrictTextToSize = false;
			_btnText.align = TextFormatAlign.CENTER;
			_btnText.text = _helpText;

			addChild(_discordBtn);
			addChild(_discordIcon);
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
			_discordIcon.x = _discordBtn.x + (_discordBtn.defaultSkinWidth - _discordIcon.width) * 0.5;
			_discordIcon.y = _discordBtn.y + (_discordBtn.defaultSkinHeight - _discordIcon.height) * 0.5;

			_btnText.x = _discordBtn.x + (_discordBtn.width - _btnText.width) * 0.5;
			_btnText.y = _discordBtn.height - 1;
		}

		public function destroy():void
		{
			if (onClick)
				onClick.removeAll();

			onClick = null;

			if (_discordBtn)
			{
				_discordBtn.removeEventListener(MouseEvent.CLICK, onMouseClick);
				_discordBtn.destroy();
			}

			_discordBtn = null;

			if (_btnText)
				_btnText.destroy();

			_btnText = null;

			_discordIcon = null;
		}

	}
}
