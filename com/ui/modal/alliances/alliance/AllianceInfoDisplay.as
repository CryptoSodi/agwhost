package com.ui.modal.alliances.alliance
{
	import com.enum.server.AllianceRankEnum;
	import com.enum.server.AllianceResponseEnum;
	import com.enum.ui.ButtonEnum;
	import com.enum.ui.LabelEnum;
	import com.model.alliance.AllianceVO;
	import com.model.player.CurrentUser;
	import com.service.language.Localization;
	import com.ui.UIFactory;
	import com.ui.core.ScaleBitmap;
	import com.ui.core.component.bar.VScrollbar;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;
	import com.ui.core.component.tooltips.Tooltips;
	import com.ui.modal.ButtonFactory;
	import com.ui.modal.PanelFactory;
	import com.util.CommonFunctionUtil;

	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;

	public class AllianceInfoDisplay extends Sprite
	{
		public var onMotdUpdated:Function;
		public var onDescriptionUpdated:Function;
		public var onPublicChanged:Function;
		public var onLeaveAlliance:Function;
		public var onSendAllianceMail:Function;

		private var _membersCount:Label;
		private var _motdTitle:Label;
		private var _motd:Label;
		private var _description:Label;
		private var _descriptionTitle:Label;
		private var _rank:Label;
		private var _checkboxText:Label;

		private var _motdBG:Bitmap;
		private var _descriptionBG:ScaleBitmap;

		private var _motdHolder:Sprite;
		private var _descriptionHolder:Sprite;

		private var _leaveBtn:BitmapButton;
		private var _publicCheckbox:BitmapButton;
		private var _editMOTD:BitmapButton;
		private var _editDescription:BitmapButton;
		private var _messageAllBtn:BitmapButton;

		private var _motdScrollbar:VScrollbar;
		private var _descriptionScrollbar:VScrollbar;

		private var _motdScrollRect:Rectangle;
		private var _descriptionScrollRect:Rectangle;

		private var _alliance:AllianceVO;

		private var _tooltips:Tooltips;

		private var _messageOfTheDayText:String           = 'CodeString.AllianceInfoDisplay.MotdTitle'; //MESSAGE OF THE DAY
		private var _descriptionText:String               = 'CodeString.AllianceInfoDisplay.DescriptionTitle'; //DESCRIPTION
		private var _leaveAllianceText:String             = 'CodeString.AllianceInfoDisplay.LeaveAlliance'; //QUIT
		private var _publicAllianceText:String            = 'CodeString.AllianceInfoDisplay.PublicAlliance'; //Public Alliance
		private var _publicAllianceDescriptionText:String = 'CodeString.Alliance.PublicDescription' //Public alliances can be joined by anyone in your faction!
		private var _alliancePlayerRankText:String        = 'CodeString.AllianceInfoDisplay.PlayerRank' //Your Rank: [[String:CurrentPlayerRank]]
		private var _allianceMemberCountText:String       = 'CodeString.AllianceInfoDisplay.MemberCount' //Members: [[Number:CurrentMemberCount]]/[[Number:MaxMemberCount]]
		private var _messageAllText:String                = 'CodeString.AllianceInfoDisplay.MessageAll';

		public function AllianceInfoDisplay()
		{
			super();

			_motdBG = PanelFactory.getScaleBitmapPanel('AllianceTextboxBMD', 500, 57, new Rectangle(15, 11, 2, 2));
			_motdBG.x = 6;
			_motdBG.y = 38;

			_descriptionBG = PanelFactory.getScaleBitmapPanel('AllianceTextboxBMD', 500, 107, new Rectangle(15, 11, 2, 2));
			_descriptionBG.x = 6;
			_descriptionBG.y = 156;

			_membersCount = new Label(20, 0xf0f0f0, 150, 25);
			_membersCount.align = TextFormatAlign.LEFT;
			_membersCount.x = 385;
			_membersCount.y = 133;

			_motdTitle = new Label(18, 0xa9dcff, 150, 25);
			_motdTitle.align = TextFormatAlign.LEFT;
			_motdTitle.x = 10;
			_motdTitle.y = 15;
			_motdTitle.text = _messageOfTheDayText;

			_descriptionTitle = new Label(18, 0xa9dcff, 150, 25);
			_descriptionTitle.align = TextFormatAlign.LEFT;
			_descriptionTitle.x = 10;
			_descriptionTitle.y = 133;
			_descriptionTitle.text = _descriptionText;

			_rank = new Label(18, 0xf0f0f0, 150, 25, false);
			_rank.align = TextFormatAlign.LEFT;
			_rank.x = 10;
			_rank.y = 270;

			_motd = new Label(18, 0xa9dcff, 450);
			_motd.constrictTextToSize = false;
			_motd.autoSize = TextFieldAutoSize.LEFT;
			_motd.align = TextFormatAlign.LEFT;
			_motd.multiline = true;

			_motdHolder = new Sprite();
			_motdHolder.x = _motdBG.x + 5;
			_motdHolder.y = _motdBG.y + 3;
			_motdHolder.addChild(_motd);

			_description = new Label(18, 0xa9dcff, 450);
			_description.constrictTextToSize = false;
			_description.autoSize = TextFieldAutoSize.LEFT;
			_description.align = TextFormatAlign.LEFT;
			_description.multiline = true;

			_descriptionHolder = new Sprite();
			_descriptionHolder.x = _descriptionBG.x + 5;
			_descriptionHolder.y = _descriptionBG.y + 3;
			_descriptionHolder.addChild(_description);

			_leaveBtn = ButtonFactory.getBitmapButton('CancelBtnNeutralBMD', 0, 0, _leaveAllianceText, 0xF58993, 'CancelBtnRollOverBMD', 'CancelBtnDownBMD');
			_leaveBtn.x = 372;
			_leaveBtn.y = _rank.y;
			_leaveBtn.addEventListener(MouseEvent.CLICK, onLeaveAllianceClick, false, 0, true);

			_editMOTD = ButtonFactory.getBitmapButton('EditBtnUpBMD', 0, 0, '', 0, 'EditBtnRollOverBMD', 'EditBtnDownBMD', null, 'EditBtnDownBMD');
			_editMOTD.x = _motdBG.x + _motdBG.width - _editMOTD.width;
			_editMOTD.y = _motdBG.y - _editMOTD.height * 0.5;
			_editMOTD.addEventListener(MouseEvent.CLICK, onMessageOfTheDayClick, false, 0, true);

			_editDescription = ButtonFactory.getBitmapButton('EditBtnUpBMD', 0, 0, '', 0, 'EditBtnRollOverBMD', 'EditBtnDownBMD', null, 'EditBtnDownBMD');
			_editDescription.x = _descriptionBG.x + _descriptionBG.width - _editDescription.width;
			_editDescription.y = _descriptionBG.y - _editDescription.height * 0.5;
			_editDescription.addEventListener(MouseEvent.CLICK, onDescriptionClick, false, 0, true);

			_publicCheckbox = ButtonFactory.getBitmapButton('CheckboxBtnUncheckedBMD', 0, 0, '', 0, null, 'CheckboxBtnUncheckedBMD', null, 'CheckboxBtnCheckedBMD');
			_publicCheckbox.x = _rank.x;
			_publicCheckbox.y = _rank.y + 30;
			_publicCheckbox.addEventListener(MouseEvent.CLICK, onIsPublicClick, false, 0, true);
			_publicCheckbox.selectable = true;

			_messageAllBtn = UIFactory.getButton(ButtonEnum.BLUE_A, 144, 29, 362, 334, _messageAllText, LabelEnum.H1);
			_messageAllBtn.addEventListener(MouseEvent.CLICK, onSendAllianceMailClick, false, 0, true);

			_checkboxText = new Label(18, 0xa9dcff, 469, 30, true);
			_checkboxText.align = TextFormatAlign.LEFT;
			_checkboxText.text = _publicAllianceText;
			_checkboxText.x = _publicCheckbox.x + _publicCheckbox.width + 5;
			_checkboxText.y = _publicCheckbox.y + (_checkboxText.textHeight - _publicCheckbox.height) * 0.5;
			_checkboxText.visible = false;

			_motdScrollRect = new Rectangle(0, 0, _motdHolder.width, _motdBG.height - 5);
			_motdScrollRect.y = 0;
			_motdHolder.scrollRect = _motdScrollRect;

			_descriptionScrollRect = new Rectangle(0, 0, _descriptionHolder.width, _descriptionBG.height - 5);
			_descriptionScrollRect.y = 0;
			_descriptionHolder.scrollRect = _descriptionScrollRect;

			_descriptionScrollbar = new VScrollbar();
			var dragBarBGRect:Rectangle = new Rectangle(0, 4, 5, 3);
			var scrollbarXPos:Number    = _descriptionBG.x + _descriptionBG.width - 3;
			var scrollbarYPos:Number    = _descriptionBG.y;
			_descriptionScrollbar.init(7, _descriptionScrollRect.height, scrollbarXPos, scrollbarYPos, dragBarBGRect, '', 'ScrollbarBMD', '', false, this, _descriptionHolder);
			_descriptionScrollbar.onScrollSignal.add(onChangedDescriptionScroll);
			_descriptionScrollbar.updateScrollableHeight(_description.textHeight);
			_descriptionScrollbar.updateDisplayedHeight(_descriptionScrollRect.height);
			_descriptionScrollbar.maxScroll = 7;

			_motdScrollbar = new VScrollbar();
			scrollbarXPos = _motdBG.x + _motdBG.width - 3;
			scrollbarYPos = _motdBG.y;
			_motdScrollbar.init(7, _motdScrollRect.height, scrollbarXPos, scrollbarYPos, dragBarBGRect, '', 'ScrollbarBMD', '', false, this, _motdHolder);
			_motdScrollbar.onScrollSignal.add(onChangedMOTDScroll);
			_motdScrollbar.updateScrollableHeight(_motd.textHeight);
			_motdScrollbar.updateDisplayedHeight(_motdScrollRect.height);
			_motdScrollbar.maxScroll = 7;

			addChild(_motdBG);
			addChild(_descriptionBG);
			addChild(_membersCount);
			addChild(_motdTitle);
			addChild(_descriptionTitle);
			addChild(_rank);
			addChild(_motdHolder);
			addChild(_motdScrollbar);
			addChild(_descriptionHolder);
			addChild(_descriptionScrollbar);
			addChild(_publicCheckbox);
			addChild(_checkboxText);
			addChild(_editMOTD);
			addChild(_editDescription);
			addChild(_leaveBtn);
			addChild(_messageAllBtn);

			if (_alliance)
				onAllianceUpdated(_alliance);
		}

		public function handleAllianceMessage( messageEnum:int ):void
		{
			switch (messageEnum)
			{
				case AllianceResponseEnum.ALLIANCE_CREATION_FAILED_NAMEINUSE:
				case AllianceResponseEnum.ALLIANCE_CREATION_FAILED_UNKNOWN:
					break;
			}
		}

		public function onAllianceUpdated( v:AllianceVO ):void
		{
			_alliance = v;

			if (CurrentUser.alliance == v.key)
			{
				if (_rank)
					_rank.setTextWithTokens(_alliancePlayerRankText, {'[[String:CurrentPlayerRank]]':CommonFunctionUtil.getAllianceRankName(CurrentUser.allianceRank)});

				if (CurrentUser.allianceRank > AllianceRankEnum.MEMBER)
				{
					_messageAllBtn.visible = _editMOTD.visible = _editDescription.visible = true;

				} else
				{
					_messageAllBtn.visible = _editMOTD.visible = _editDescription.visible = false;
				}

				if (CurrentUser.allianceRank == AllianceRankEnum.LEADER)
				{
					_publicCheckbox.visible = _checkboxText.visible = true;
					_leaveBtn.visible = (v.memberCount <= 1) ? true : false;
				} else
					_publicCheckbox.visible = _checkboxText.visible = false;

			} else
			{
				_rank.text = '';
				_leaveBtn.visible = _publicCheckbox.visible = _checkboxText.visible = _messageAllBtn.visible = _editMOTD.visible = _editDescription.visible = false;
			}

			_motd.text = v.motd;
			_description.text = v.description;
			_publicCheckbox.selected = v.isPublic;
			_membersCount.setTextWithTokens(_allianceMemberCountText, {'[[Number:CurrentMemberCount]]':v.memberCount, '[[Number:MaxMemberCount]]':1000});

			_motdScrollbar.updateScrollableHeight(_motd.textHeight);
			_descriptionScrollbar.updateScrollableHeight(_description.textHeight);
		}

		private function onSendAllianceMailClick( e:MouseEvent ):void
		{
			if (onSendAllianceMail != null)
				onSendAllianceMail();
		}

		private function onIsPublicClick( e:MouseEvent ):void
		{
			if (onPublicChanged != null)
				onPublicChanged(_publicCheckbox.selected);
		}

		private function onMessageOfTheDayClick( e:MouseEvent ):void
		{
			if (onMotdUpdated != null)
				onMotdUpdated(_motd.text);
		}

		private function onDescriptionClick( e:MouseEvent ):void
		{
			if (onDescriptionUpdated != null)
				onDescriptionUpdated(_description.text);
		}

		private function onLeaveAllianceClick( e:MouseEvent ):void
		{
			if (onLeaveAlliance != null)
				onLeaveAlliance();
		}

		private function onChangedMOTDScroll( percent:Number ):void
		{
			_motdScrollRect.y = (_motd.textHeight - _motdScrollRect.height) * percent;
			_motdHolder.scrollRect = _motdScrollRect;
		}

		private function onChangedDescriptionScroll( percent:Number ):void
		{
			_descriptionScrollRect.y = (_description.textHeight - _descriptionScrollRect.height) * percent;
			_descriptionHolder.scrollRect = _descriptionScrollRect;
		}
		
		public function setEnabled( state:Boolean ):void
		{
			_leaveBtn.enabled = state;
			_editMOTD.enabled = state;
			_editDescription.enabled = state;
			_publicCheckbox.enabled = state;
			_messageAllBtn.enabled = state;
		}
		
		public function setVisible( state:Boolean ):void
		{
			_leaveBtn.visible = state;
			_editMOTD.visible = state;
			_editDescription.visible = state;
			_publicCheckbox.visible = state;
			_messageAllBtn.visible = state;
		}

		[Inject]
		public function set tooltips( value:Tooltips ):void
		{
			_tooltips = value;

			if (_publicCheckbox)
				_tooltips.addTooltip(_publicCheckbox, this, null, Localization.instance.getString(_publicAllianceDescriptionText));
		}

		public function destroy():void
		{
			if (_tooltips)
				_tooltips.removeTooltip(null, this);

			_descriptionScrollRect = null;
			_alliance = null;
			onMotdUpdated = null;
			onDescriptionUpdated = null;
			onPublicChanged = null;
			onLeaveAlliance = null;

			if (_membersCount)
				_membersCount.destroy();

			_membersCount = null;

			if (_motdTitle)
				_motdTitle.destroy();

			_motdTitle = null;

			if (_motd)
				_motd.destroy();

			_motd = null;

			if (_description)
				_description.destroy();

			_description = null;

			if (_descriptionTitle)
				_descriptionTitle.destroy();

			_descriptionTitle = null;

			if (_rank)
				_rank.destroy();

			_rank = null;

			if (_checkboxText)
				_checkboxText.destroy();

			_checkboxText = null;

			_motdBG = null;
			_descriptionBG = null;
			_descriptionHolder = null;

			if (_leaveBtn)
			{
				_leaveBtn.removeEventListener(MouseEvent.CLICK, onLeaveAllianceClick);
				_leaveBtn.destroy();
			}

			_leaveBtn = null;

			if (_publicCheckbox)
			{
				_publicCheckbox.removeEventListener(MouseEvent.CLICK, onIsPublicClick);
				_publicCheckbox.destroy();
			}

			_publicCheckbox = null;

			if (_editMOTD)
			{
				_editMOTD.removeEventListener(MouseEvent.CLICK, onMessageOfTheDayClick);
				_editMOTD.destroy();
			}

			_editMOTD = null;

			if (_editDescription)
			{
				_editDescription.removeEventListener(MouseEvent.CLICK, onDescriptionClick);
				_editDescription.destroy();
			}

			_editDescription = null;

			if (_descriptionScrollbar)
				_descriptionScrollbar.destroy();

			_descriptionScrollbar = null;

			if (_messageAllBtn)
			{
				_messageAllBtn.removeEventListener(MouseEvent.CLICK, onSendAllianceMail);
				_messageAllBtn.destroy();
			}
			_messageAllBtn = null;
		}
	}
}
