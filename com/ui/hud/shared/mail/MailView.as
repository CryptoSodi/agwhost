package com.ui.hud.shared.mail
{
	import com.enum.ui.ButtonEnum;
	import com.model.mail.MailVO;
	import com.model.player.CurrentUser;
	import com.presenter.shared.IUIPresenter;
	import com.ui.UIFactory;
	import com.ui.core.ScaleBitmap;
	import com.ui.core.View;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;
	import com.ui.core.component.misc.ImageComponent;
	import com.ui.modal.ButtonFactory;
	import com.ui.modal.PanelFactory;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextFormatAlign;
	import flash.utils.getDefinitionByName;

	import org.shared.ObjectPool;

	public class MailView extends View
	{
		private var _bg:Bitmap;
		private var _closeBtn:BitmapButton;
		private var _windowFrame:Bitmap;

		private var _messageFrame:ScaleBitmap;

		private var _senderPortrait:ImageComponent;

		private var _title:Label;
		private var _subject:Label;
		private var _body:Label;

		private var _replyAllBtn:BitmapButton;
		private var _replyBtn:BitmapButton;
		private var _backArrowBtn:BitmapButton;
		private var _deleteBtn:BitmapButton;
		private var _replySymbolBtn:BitmapButton;

		private var _deleteCallback:Function;

		private var _mail:MailVO;

		private var _message:String = 'CodeString.Mail.Message'; //MESSAGE
		private var _reply:String   = 'CodeString.Mail.Reply'; //REPLY

		[PostConstruct]
		override public function init():void
		{
			super.init();

			var windowBGClass:Class      = Class(getDefinitionByName('MailWindowMessageBMD'));
			var messageFrameClass:Class  = Class(getDefinitionByName('MailWindowOutlineBMD'));
			_bg = new Bitmap(BitmapData(new windowBGClass()));

			_windowFrame = new Bitmap(BitmapData(new messageFrameClass()));
			_windowFrame.x = 17;
			_windowFrame.y = 82;

			_messageFrame = PanelFactory.getScaleBitmapPanel('MailMessageRowBMD', 650, 97, new Rectangle(233, 16, 6, 6));
			_messageFrame.x = 23;
			_messageFrame.y = 102;

			var portraitFrameClass:Class = Class(getDefinitionByName('BattleLogLargePortraitFrameBMD'));
			_senderPortrait = ObjectPool.get(ImageComponent);
			_senderPortrait.init(2000, 2000);
			_senderPortrait.x = _messageFrame.x + 5;
			_senderPortrait.y = _messageFrame.y + 11;

			_deleteBtn = ButtonFactory.getBitmapButton('MailTrashBtnUpBMD', 652, 45, '', 0, 'MailTrashBtnRollOverBMD', 'MailTrashBtnSelectedBMD', null, 'MailTrashBtnSelectedBMD');
			addListener(_deleteBtn, MouseEvent.CLICK, onDeleteMail);

			_replyBtn = ButtonFactory.getBitmapButton('MailReplyBtnUpBMD', 287, 374, _reply, 0xa9dcff, 'MailReplyBtnRollOverBMD', 'MailReplyBtnSelectedBMD', null, 'MailReplyBtnSelectedBMD');
			addListener(_replyBtn, MouseEvent.CLICK, onReplyToMessage);

			_replySymbolBtn = ButtonFactory.getBitmapButton('MailReplyIconUpBMD', 610, 45, '', 0, 'MailReplyIconRollOverBMD', 'MailReplyIconDownBMD', null, 'MailReplyIconDownBMD');
			addListener(_replySymbolBtn, MouseEvent.CLICK, onReplyToMessage);

			_backArrowBtn = ButtonFactory.getBitmapButton('MailBackArrowBtnUpBMD', 27, 59, '', 0, 'MailBackArrowBtnRollOverBMD', 'MailBackArrowBtnSelectedBMD', null, 'MailBackArrowBtnSelectedBMD');
			addListener(_backArrowBtn, MouseEvent.CLICK, onBackArrowClick);

			_replyAllBtn = UIFactory.getButton(ButtonEnum.REPLY_ALL);
			addListener(_replyAllBtn, MouseEvent.CLICK, onReplyToAll);

			_title = new Label(20, 0xf0f0f0, 150, 25, false);
			_title.align = TextFormatAlign.LEFT;
			_title.x = 25;
			_title.y = 12;
			_title.text = _message;

			_subject = new Label(20, 0xf0f0f0, 600, 34, false);
			_subject.align = TextFormatAlign.LEFT;
			_subject.x = 45;
			_subject.y = 55;

			_body = new Label(13, 0xf0f0f0, 559, 82, false, 1);
			_body.align = TextFormatAlign.LEFT;
			_body.multiline = true;
			_body.x = 106;
			_body.y = 108;

			_closeBtn = ButtonFactory.getCloseButton(_bg.width - 36, 11);
			addListener(_closeBtn, MouseEvent.CLICK, onClose);

			addChild(_bg);
			addChild(_closeBtn);
			addChild(_windowFrame);
			addChild(_messageFrame);
			addChild(_senderPortrait);
			addChild(_title);
			addChild(_subject);
			addChild(_body);
			addChild(_deleteBtn);
			addChild(_replyBtn);
			addChild(_replySymbolBtn);
			addChild(_backArrowBtn);
			// Removed ReplyAllBtn
			//addChild(_replyAllBtn);

			presenter.addOnMailDetailUpdatedListener(setUpView);

			addEffects();
			effectsIN();

		}

		public function setMail( mail:MailVO, deleteCallback:Function ):void
		{
			_mail = mail;
			_deleteCallback = deleteCallback;

			if (_mail.senderKey == null)
				presenter.getMailDetails(_mail.key);
			else
				setUpView(_mail);
		}

		private function setUpView( mail:MailVO ):void
		{
			_mail = mail;

			_subject.text = _mail.subject;
			_title.text = _mail.sender.toUpperCase();
			_body.text = _mail.body;

			if (mail.sendersRace != '')
				presenter.loadPortraitSmall(mail.sendersRace, _senderPortrait.onImageLoaded);

			_replyBtn.visible = (_mail.senderKey != '');
			_replySymbolBtn.visible = (_mail.senderKey != '');
			_replyAllBtn.visible = (_mail.allianceKey != '' && _mail.allianceKey == CurrentUser.alliance);

			var xPos:Number = 590;

			if (_replyAllBtn.visible)
			{
				_replyAllBtn.x = xPos;
				_replyAllBtn.y = 47;

				xPos += _replyAllBtn.width + 10;
			}

			_replySymbolBtn.x = xPos;
			xPos += _replySymbolBtn.width + 10;
			_deleteBtn.x = xPos;

		}

		private function onDeleteMail( e:MouseEvent ):void
		{
			_deleteCallback(_mail.key);
			destroy();
		}

		private function onReplyToMessage( e:MouseEvent ):void
		{
			var newMailView:NewMailView = NewMailView(_viewFactory.createView(NewMailView));
			newMailView.setMessageInfo(_mail.sender, _mail.senderKey, _mail.subject);
			_viewFactory.notify(newMailView);
		}

		private function onReplyToAll( e:MouseEvent ):void
		{
			// Removed ReplyToAll Button
			/* 
			var newMailView:NewMailView = NewMailView(_viewFactory.createView(NewMailView));
			newMailView.setMessageInfo('Alliance', '', _mail.subject);
			_viewFactory.notify(newMailView);
			*/
		}

		private function onBackArrowClick( e:MouseEvent ):void
		{
			destroy();
		}

		override public function get height():Number  { return _bg.height; }
		override public function get width():Number  { return _bg.width; }

		[Inject]
		public function set presenter( v:IUIPresenter ):void  { _presenter = v; }
		public function get presenter():IUIPresenter  { return IUIPresenter(_presenter); }

		override public function destroy():void
		{
			presenter.removeOnMailDetailUpdatedListener(setUpView);
			super.destroy();

			_bg = null;
			_closeBtn.destroy();
			_closeBtn = null;
			_windowFrame = null;
			_messageFrame = null;

			_title.destroy();
			_title = null;

			_subject.destroy();
			_subject = null;

			_body.destroy();
			_body = null;

			_replyBtn.destroy();
			_replyBtn = null;

			_backArrowBtn.destroy();
			_backArrowBtn = null;

			_deleteBtn.destroy();
			_deleteBtn = null;

			_replySymbolBtn.destroy();
			_replySymbolBtn = null;

			_deleteCallback = null;

			_mail = null;
		}
	}
}
