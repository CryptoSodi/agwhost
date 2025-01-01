package com.ui.hud.shared.bridge
{

	import com.enum.ui.ButtonEnum;
	import com.ui.UIFactory;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;

	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextFormatAlign;

	import org.osflash.signals.Signal;

	public class AchievementRiverButton extends Sprite
	{
		public var onClick:Signal;

		private var _achievementIcon:Bitmap;
		private var _achievementBtn:BitmapButton;
		private var _btnText:Label;

		private var _achievementText:String = 'CodeString.Achievements.RiverBtn'; //BADGES

		public function AchievementRiverButton()
		{
			onClick = new Signal();

			_achievementIcon = UIFactory.getBitmap('IconTrophyBMD');

			_achievementBtn = UIFactory.getButton(ButtonEnum.ICON_FRAME, 60, 60);
			_achievementBtn.addEventListener(MouseEvent.CLICK, onMouseClick, false, 0, true);

			_btnText = new Label(20, 0xd1e5f7, 100, 25);
			_btnText.bold = true;
			_btnText.constrictTextToSize = false;
			_btnText.align = TextFormatAlign.CENTER;
			_btnText.text = _achievementText;

			addChild(_achievementBtn);
			addChild(_achievementIcon);
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
			_achievementIcon.x = _achievementBtn.x + (_achievementBtn.defaultSkinWidth - _achievementIcon.width) * 0.5;
			_achievementIcon.y = _achievementBtn.y + (_achievementBtn.defaultSkinHeight - _achievementIcon.height) * 0.5;

			_btnText.x = _achievementBtn.x + (_achievementBtn.width - _btnText.width) * 0.5;
			_btnText.y = _achievementBtn.height - 1;
		}

		public function destroy():void
		{
			if (onClick)
				onClick.removeAll();

			onClick = null;

			if (_achievementBtn)
			{
				_achievementBtn.removeEventListener(MouseEvent.CLICK, onMouseClick);
				_achievementBtn.destroy();
			}

			_achievementBtn = null;

			if (_btnText)
				_btnText.destroy();

			_btnText = null;

			_achievementIcon = null;
		}

	}
}
