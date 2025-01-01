package com.ui.modal.fakelogin
{
	import com.enum.ui.ButtonEnum;
	import com.enum.ui.LabelEnum;
	import com.enum.ui.PanelEnum;
	import com.ui.UIFactory;
	import com.ui.core.DefaultWindowBG;
	import com.ui.core.ScaleBitmap;
	import com.ui.core.View;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;

	import flash.events.MouseEvent;
	import flash.text.TextFormatAlign;

	import org.shared.ObjectPool;

	public class FakeLoginView extends View
	{
		private var _bg:DefaultWindowBG;

		private var _idBackground:ScaleBitmap;
		private var _playerTokenBackground:ScaleBitmap;

		private var _loginID:Label;
		private var _loginPlayerToken:Label;

		private var _okBtn:BitmapButton;

		private var _callback:Function;

		[PostConstruct]
		override public function init():void
		{
			super.init();

			_bg = ObjectPool.get(DefaultWindowBG);
			_bg.setBGSize(563, 150);
			_bg.addTitle('Fake Login', 114);
			addListener(_bg.closeButton, MouseEvent.CLICK, onClose);

			_idBackground = UIFactory.getScaleBitmap(PanelEnum.INPUT_BOX_BLUE);
			_idBackground.x = 10;
			_idBackground.y = 60;
			_idBackground.width = 572;
			_idBackground.height = 25;

			_playerTokenBackground = UIFactory.getScaleBitmap(PanelEnum.INPUT_BOX_BLUE);
			_playerTokenBackground.x = 10;
			_playerTokenBackground.y = 100;
			_playerTokenBackground.width = 572;
			_playerTokenBackground.height = 25;

			_loginID = new Label(16, 0xf0f0f0, 572, 25);
			_loginID.align = TextFormatAlign.CENTER;
			_loginID.restrict = '0-9';
			_loginID.x = _idBackground.x;
			_loginID.y = _idBackground.y;

			_loginPlayerToken = new Label(16, 0xf0f0f0, 572, 25);
			_loginPlayerToken.align = TextFormatAlign.CENTER;
			_loginPlayerToken.restrict = 'A-Za-z0-9_';
			_loginPlayerToken.x = _playerTokenBackground.x;
			_loginPlayerToken.y = _playerTokenBackground.y;

			_okBtn = UIFactory.getButton(ButtonEnum.BLUE_A, 100, 30, 0, 0, 'OK', LabelEnum.H1);
			_okBtn.x = _playerTokenBackground.x + (_playerTokenBackground.width - _okBtn.width) * 0.5;
			_okBtn.y = _playerTokenBackground.y + _playerTokenBackground.height + 20;
			addListener(_okBtn, MouseEvent.CLICK, onMouseClick);

			addChild(_bg);
			addChild(_idBackground);
			addChild(_playerTokenBackground);
			addChild(_loginID);
			addChild(_loginPlayerToken);
			addChild(_okBtn);


			addEffects();
			effectsIN();
		}

		private function onMouseClick( e:MouseEvent ):void
		{
			_callback(_loginID.text, _loginPlayerToken.text);
		}

		override public function get height():Number  { return _bg.height; }
		override public function get width():Number  { return _bg.width; }

		public function set callBack( v:Function ):void
		{
			_callback = v;
		}

		override public function destroy():void
		{
			super.destroy();

			_idBackground = null;
			_playerTokenBackground = null;

			if (_bg)
				ObjectPool.give(_bg);

			_bg = null;

			if (_loginID)
				_loginID.destroy();

			_loginID = null;

			if (_loginPlayerToken)
				_loginPlayerToken.destroy();

			_loginPlayerToken = null;
		}
	}
}
