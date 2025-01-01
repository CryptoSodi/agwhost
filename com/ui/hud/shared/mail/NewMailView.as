package com.ui.hud.shared.mail
{
	import com.presenter.shared.IUIPresenter;
	import com.ui.core.View;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;
	import com.ui.modal.ButtonFactory;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.MouseEvent;
	import flash.text.TextFormatAlign;
	import flash.utils.getDefinitionByName;

	public class NewMailView extends View
	{
		private var _name:String;
		private var _playerID:String;
		private var _subjectText:String;

		private var _bg:Bitmap;
		private var _closeBtn:BitmapButton;
		private var _title:Label;
		private var _to:Label;
		private var _subject:Label;
		private var _body:Label;

		private var _sendBtn:BitmapButton;

		private var _newMessage:String     = 'CodeString.Mail.NewMessage'; //NEW MESSAGE
		private var _subjectLocText:String = 'CodeString.Mail.Subject'; //Subject
		private var _reply:String          = 'CodeString.Mail.ReplyText'; //RE: [[1]]
		private var _send:String           = 'CodeString.Mail.Send'; //SEND
		private var _bodyText:String       = 'CodeString.Mail.Body'; //Write Message Here


		[PostConstruct]
		override public function init():void
		{
			super.init();

			var windowBGClass:Class = Class(getDefinitionByName('MailNewMessageWindowBGBMD'));
			_bg = new Bitmap(BitmapData(new windowBGClass()));

			_title = new Label(20, 0xf0f0f0, 150, 25, true);
			_title.align = TextFormatAlign.LEFT;
			_title.x = 25;
			_title.y = 12;
			_title.text = _newMessage;

			_to = new Label(18, 0xa9dcff, 468, 25, false);
			_to.align = TextFormatAlign.LEFT;
			_to.x = 37;
			_to.y = 55;
			_to.text = _name;

			_subject = new Label(18, 0xa9dcff, 468, 25, true);
			_subject.align = TextFormatAlign.LEFT;
			_subject.x = 37;
			_subject.y = 82;
			if (_subjectText == '')
			{
				_subject.text = _subjectLocText;
				_subject.maxChars = 45;
				_subject.allowInput = true;
				_subject.clearOnFocusIn = true;
				_subject.letterSpacing = .8;
				_subject.addLabelColor(0xbdfefd, 0x000000);
			} else
			{
				if (_subjectText.indexOf('RE:') == -1)
					_subject.setTextWithTokens(_reply, {'[[String.Subject]]':_subjectText});
				else
				{
					_subject.useLocalization = false
					_subject.text = _subjectText;
				}
			}

			_body = new Label(18, 0xa9dcff, 468, 106, true);
			_body.align = TextFormatAlign.LEFT;
			_body.text = _bodyText;
			_body.x = 37;
			_body.y = 118;
			_body.maxChars = 250;
			_body.multiline = true;
			_body.allowInput = true;
			_body.clearOnFocusIn = true;
			_body.letterSpacing = .8;
			_body.addLabelColor(0xbdfefd, 0x000000);

			_sendBtn = ButtonFactory.getBitmapButton('MailReplyBtnUpBMD', 370, 235, _send, 0xa9dcff, 'MailReplyBtnRollOverBMD', 'MailReplyBtnSelectedBMD', null, 'MailReplyBtnSelectedBMD');
			addListener(_sendBtn, MouseEvent.CLICK, onSendMail);

			_closeBtn = ButtonFactory.getCloseButton(_bg.width - 36, 11);
			addListener(_closeBtn, MouseEvent.CLICK, onClose);

			addChild(_bg);
			addChild(_closeBtn);
			addChild(_title);
			addChild(_to);
			addChild(_subject);
			addChild(_body);
			addChild(_sendBtn);

			addEffects();
			effectsIN();
		}

		private function onSendMail( e:MouseEvent ):void
		{
			if (_subject.text != _subjectLocText && _body.text != _bodyText)
			{
				if (_playerID != '')
					presenter.sendMailMessage(_playerID, _subject.text, _body.text);
				else
					presenter.sendAllianceMailMessage(_subject.text, _body.text);

				destroy();
			}
		}

		public function setMessageInfo( name:String, playerID:String = '', subjectText:String = '' ):void
		{
			_name = name;
			_playerID = playerID;
			_subjectText = subjectText;
		}

		[Inject]
		public function set presenter( value:IUIPresenter ):void  { _presenter = value; }
		public function get presenter():IUIPresenter  { return IUIPresenter(_presenter); }

		override public function destroy():void
		{
			super.destroy();

			_bg = null;
			_closeBtn.destroy();
			_closeBtn = null;

			_title.destroy();
			_title = null;

			_to.destroy();
			_to = null;

			_subject.destroy();
			_subject = null;

			_body.destroy();
			_body = null;

			_sendBtn.destroy();
			_sendBtn = null;
		}
	}
}
