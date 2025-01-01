package com.ui.hud.shared.mail
{
	import com.model.mail.MailVO;
	import com.presenter.shared.IUIPresenter;
	import com.ui.core.View;
	import com.ui.core.component.bar.VScrollbar;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;
	import com.ui.modal.ButtonFactory;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;

	public class MailBoxView extends View
	{
		private var _bg:Bitmap;
		private var _closeBtn:BitmapButton;
		private var _messageFrame:Bitmap;
		private var _mailEntries:Dictionary;
		private var _title:Label;
		private var _noMail:Label;

		private var _deleteBtn:BitmapButton;
		private var _selectionCheckbox:BitmapButton;

		private var _checkboxEmpty:BitmapData;
		private var _checkboxDash:BitmapData;
		private var _checkboxChecked:BitmapData;

		private var _selectionCount:int;

		private var _mail:Vector.<MailEntry>;

		private var _scrollbar:VScrollbar;
		private var _maxHeight:int;

		private var _scrollRect:Rectangle;

		private var _holder:Sprite;

		private var _mailbox:String      = 'CodeString.Mail.Mailbox'; //MAILBOX
		private var _emptyMailbox:String = 'CodeString.Mail.NoMail'; //You have no mail - get some friends. Or enemies.

		[PostConstruct]
		override public function init():void
		{
			super.init();

			_mailEntries = new Dictionary;
			_mail = new Vector.<MailEntry>;
			var windowBGClass:Class       = Class(getDefinitionByName('MailWindowMessageBMD'));
			var messageFrameClass:Class   = Class(getDefinitionByName('MailWindowMainBMD'));

			var checkboxEmptyClass:Class  = Class(getDefinitionByName('CheckboxBtnUncheckedBMD'));
			var checkboxFilledClass:Class = Class(getDefinitionByName('CheckboxBtnCheckedBMD'));
			var checkboxDashClass:Class   = Class(getDefinitionByName('CheckboxBtnDeselectBMD'));

			_bg = new Bitmap(BitmapData(new windowBGClass()));

			_checkboxEmpty = BitmapData(new checkboxEmptyClass());
			_checkboxDash = BitmapData(new checkboxDashClass());
			_checkboxChecked = BitmapData(new checkboxFilledClass());

			_title = new Label(20, 0xf0f0f0, 150, 25, true);
			_title.align = TextFormatAlign.LEFT;
			_title.x = 25;
			_title.y = 12;
			_title.text = _mailbox;

			_messageFrame = new Bitmap(BitmapData(new messageFrameClass()));
			_messageFrame.x = 18;
			_messageFrame.y = 46;

			_noMail = new Label(24, 0xf0f0f0);
			_noMail.constrictTextToSize = false;
			_noMail.autoSize = TextFieldAutoSize.CENTER;
			_noMail.x = _bg.x + (_bg.width - _noMail.textWidth) * 0.5;
			_noMail.y = _bg.y + (_bg.height - _noMail.textHeight) * 0.5;
			_noMail.text = _emptyMailbox;

			_deleteBtn = ButtonFactory.getBitmapButton('MailTrashBtnUpBMD', 598, 50, '', 0, 'MailTrashBtnRollOverBMD', 'MailTrashBtnSelectedBMD', null, 'MailTrashBtnSelectedBMD');
			addListener(_deleteBtn, MouseEvent.CLICK, onDeleteMail);

			_selectionCheckbox = ButtonFactory.getBitmapButton('CheckboxBtnUncheckedBMD', 32, 56, '', 0, 'CheckboxBtnUncheckedBMD');
			addListener(_selectionCheckbox, MouseEvent.CLICK, onSelectionChanged);

			_closeBtn = ButtonFactory.getCloseButton(_bg.width - 36, 11);
			addListener(_closeBtn, MouseEvent.CLICK, onClose);

			_holder = new Sprite();
			_holder.x = 24;
			_holder.y = 90;
			_maxHeight = 0;

			_scrollRect = new Rectangle(0, 0, 666, 336);
			_scrollRect.y = 0;
			_holder.scrollRect = _scrollRect;

			_scrollbar = new VScrollbar();
			var dragBarBGRect:Rectangle   = new Rectangle(0, 5, 5, 2);
			var scrollbarXPos:Number      = 692;
			var scrollbarYPos:Number      = 88;
			_scrollbar.init(7, _scrollRect.height, scrollbarXPos, scrollbarYPos, dragBarBGRect, '', 'ScrollbarBMD', '', false, this);
			_scrollbar.onScrollSignal.add(onChangedScroll);
			_scrollbar.updateScrollableHeight(_maxHeight);
			_scrollbar.updateDisplayedHeight(_scrollRect.height);
			_scrollbar.maxScroll = 12;

			addChild(_bg);
			addChild(_closeBtn);
			addChild(_title);
			addChild(_messageFrame);
			addChild(_noMail);
			addChild(_scrollbar);
			addChild(_deleteBtn);
			addChild(_selectionCheckbox);
			addChild(_holder);

			presenter.addOnMailHeadersUpdatedListener(onMailHeadersUpdated);
			presenter.addMailCountUpdateListener(onMailCountUpdated);
			presenter.sendGetMailboxMessage();

			addEffects();
			effectsIN();
		}

		private function onMailHeadersUpdated( v:Vector.<MailVO> ):void
		{
			var len:uint = v.length;
			var currentMailVO:MailVO;
			var currentMailEntry:MailEntry;
			for (var i:uint = 0; i < len; ++i)
			{
				currentMailVO = v[i];
				if (currentMailVO.key in _mailEntries)
					currentMailEntry = _mailEntries[currentMailVO.key];
				else
				{
					currentMailEntry = new MailEntry();
					currentMailEntry.init(currentMailVO);
					currentMailEntry.onClicked.add(onEntryClicked);
					currentMailEntry.onSelectionChanged.add(onMailSelectionChange);
					_mail.push(currentMailEntry);
				}
				_mailEntries[currentMailVO.key] = currentMailEntry;
				_holder.addChild(currentMailEntry);
			}

			_mail.sort(orderItems);
			updateSelectionBtn();
			layout();
		}

		private function onEntryClicked( entry:MailEntry ):void
		{
			presenter.mailRead(entry.mailKey);
			var mailView:MailView = MailView(_viewFactory.createView(MailView));
			_viewFactory.notify(mailView);
			mailView.setMail(entry.mail, onDeletedFromMailView);

		}

		private function onDeleteMail( e:MouseEvent ):void
		{
			var len:uint                     = _mail.length;
			var currentMailEntry:MailEntry;
			var keysToRemove:Vector.<String> = new Vector.<String>;
			for (var i:uint = 0; i < len; ++i)
			{
				currentMailEntry = _mail[i];
				if (currentMailEntry.selected)
				{
					if (currentMailEntry.selected)
						--_selectionCount;

					_holder.removeChild(currentMailEntry);
					delete _mailEntries[currentMailEntry.mailKey]
					keysToRemove.push(currentMailEntry.mailKey);
					_mail.splice(i, 1);
					currentMailEntry = null;
					--len;
					--i;
				}
			}
			presenter.deleteMail(keysToRemove);
			updateSelectionBtn();
			layout();
		}

		private function onDeletedFromMailView( key:String ):void
		{
			var len:uint                     = _mail.length;
			var currentMailEntry:MailEntry;
			var keysToRemove:Vector.<String> = new Vector.<String>;
			for (var i:uint = 0; i < len; ++i)
			{
				currentMailEntry = _mail[i];
				if (currentMailEntry.mailKey == key)
				{
					if (currentMailEntry.selected)
						--_selectionCount;

					_holder.removeChild(currentMailEntry);
					delete _mailEntries[currentMailEntry.mailKey]
					keysToRemove.push(currentMailEntry.mailKey);
					_mail.splice(i, 1);
					currentMailEntry = null;
					break;
				}
			}
			presenter.deleteMail(keysToRemove);
			updateSelectionBtn();
			layout();
		}

		protected function layout():void
		{
			var len:uint = _mail.length;
			var selection:MailEntry;
			var yPos:int = 0;
			_noMail.visible = (len > 0) ? false : true;
			_maxHeight = 0;
			for (var i:uint = 0; i < len; ++i)
			{
				selection = _mail[i];
				selection.y = yPos;
				_maxHeight += selection.height + 4;
				yPos += selection.height + 4;
			}
			_maxHeight -= 3;
			_scrollbar.updateScrollableHeight(_maxHeight);
		}

		private function onChangedScroll( percent:Number ):void
		{
			_scrollRect.y = (_maxHeight - _scrollRect.height) * percent;
			_holder.scrollRect = _scrollRect;
		}

		private function orderItems( itemOne:MailEntry, itemTwo:MailEntry ):Number
		{

			if (!itemOne)
				return -1;
			if (!itemTwo)
				return 1;

			var timeSentOne:Number = itemOne.timeSent;
			var timeSent:Number    = itemTwo.timeSent;

			if (timeSentOne > timeSent)
				return -1;
			else if (timeSentOne < timeSent)
				return 1;

			return 0;
		}

		private function onMailSelectionChange( v:Boolean ):void
		{
			if (v)
				++_selectionCount;
			else
				--_selectionCount;

			updateSelectionBtn();
		}

		private function updateSelectionBtn():void
		{
			if (_selectionCount == _mail.length)
				_selectionCheckbox.updateBackgrounds(_checkboxChecked, _checkboxChecked);
			else if (_selectionCount > 0)
				_selectionCheckbox.updateBackgrounds(_checkboxDash, _checkboxDash);
			else
				_selectionCheckbox.updateBackgrounds(_checkboxEmpty, _checkboxEmpty);
		}

		private function onSelectionChanged( e:MouseEvent ):void
		{

			if (_selectionCount == _mail.length)
				setMailEntrySelected(false)
			else if (_selectionCount > 0)
				setMailEntrySelected(false)
			else
				setMailEntrySelected(true)
		}

		private function setMailEntrySelected( v:Boolean ):void
		{

			var len:uint = _mail.length;
			var currentMailEntry:MailEntry;

			if (v)
				_selectionCount = len;
			else
				_selectionCount = 0;

			for (var i:uint = 0; i < len; ++i)
			{
				currentMailEntry = _mail[i];
				currentMailEntry.selected = v;
			}
			updateSelectionBtn();
		}

		private function onMailCountUpdated( unread:uint, count:uint, serverUpdate:Boolean ):void
		{
			if (serverUpdate)
				presenter.sendGetMailboxMessage();
		}

		override public function get height():Number  { return _bg.height; }
		override public function get width():Number  { return _bg.width; }

		[Inject]
		public function set presenter( value:IUIPresenter ):void  { _presenter = value; }
		public function get presenter():IUIPresenter  { return IUIPresenter(_presenter); }

		override public function destroy():void
		{
			presenter.removeOnMailHeadersUpdatedListener(onMailHeadersUpdated);
			presenter.removeMailCountUpdateListener(onMailCountUpdated);
			super.destroy();

			_bg = null;
			_closeBtn.destroy();
			_closeBtn = null;
			_messageFrame = null;

			_title.destroy();
			_title = null;

			_noMail.destroy();
			_noMail = null;

			_deleteBtn.destroy();
			_deleteBtn = null;

			var len:uint = _mail.length;
			var currentMailEntry:MailEntry;
			for (var i:uint = 0; i < len; ++i)
			{
				currentMailEntry = _mail[i];
				_holder.removeChild(currentMailEntry);
				currentMailEntry.destroy();
				currentMailEntry = null;
			}
			_mail.length = 0;

			for (var key:String in _mailEntries)
			{
				delete _mailEntries[key];
			}
			_mailEntries = null;

			_holder = null;

			_scrollbar.destroy();
			_scrollbar = null;


			_maxHeight = 0;
		}
	}
}
