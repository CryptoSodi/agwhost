package com.ui.modal.alliances.alliance
{
	import com.enum.server.AllianceRankEnum;
	import com.enum.server.AllianceResponseEnum;
	import com.enum.ui.ButtonEnum;
	import com.model.alliance.AllianceMemberVO;
	import com.model.alliance.AllianceVO;
	import com.model.player.CurrentUser;
	import com.presenter.shared.IAlliancePresenter;
	import com.ui.core.ButtonPrototype;
	import com.ui.core.View;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;
	import com.ui.hud.shared.mail.NewMailView;
	import com.ui.modal.ButtonFactory;
	import com.ui.modal.playerinfo.PlayerProfileView;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextFormatAlign;
	import flash.utils.getDefinitionByName;

	public class AllianceView extends View
	{
		private var _bg:Bitmap;
		private var _closeBtn:BitmapButton;

		private var _currentState:Sprite;

		private var _title:Label;

		private var _infoBtn:BitmapButton;
		private var _membersBtn:BitmapButton;
		private var _selectedAllianceBtn:BitmapButton;

		private var _infoDisplay:AllianceInfoDisplay;
		private var _memberDisplay:AllianceMemberDisplay;

		private var _allianceKey:String;

		private var _infoText:String            = 'CodeString.Alliance.Info'; //INFO
		private var _memberText:String          = 'CodeString.Alliance.Members'; //MEMBERS
		private var _editMotdText:String        = 'CodeString.Alliance.EditMotd'; //EDIT MOTD
		private var _editDescriptionText:String = 'CodeString.Alliance.EditDescription'; //EDIT DESCRIPTION

		private var _promoteTitleText:String    = 'CodeString.Alliance.Promote.Title'; //PROMOTE PLAYER
		private var _promoteBodyText:String     = 'CodeString.Alliance.Promote.Body'; //Are you sure you want to transfer leadership to this player?
		private var _promoteText:String         = 'CodeString.Alliance.Promote.Promote'; //PROMOTE
		private var _noText:String              = 'CodeString.Alliance.Promote.No'; //NO
		private var _noAllianceFound:String     = 'CodeString.Alliance.NoAllianceFound'; //Alliance not found

		[PostConstruct]
		override public function init():void
		{
			super.init();

			var windowBGClass:Class = Class(getDefinitionByName('AllianceMainBGBMD'));
			_bg = new Bitmap(BitmapData(new windowBGClass()));

			_infoBtn = ButtonFactory.getBitmapButton('AllianceSideBtnUpBMD', 17, 65, _infoText, 0xc9e6f6, 'AllianceSideBtnRollOverBMD', 'AllianceSideBtnDownBMD', null, 'AllianceSideBtnSelectedBMD');
			_infoBtn.fontSize = 20;
			_infoBtn.label.x -= 29;
			_infoBtn.label.y += 3;
			_infoBtn.selectable = true;
			_infoBtn.selected = true;
			_infoBtn.enabled = false;
			selectBitmapButton(_infoBtn);
			addListener(_infoBtn, MouseEvent.MOUSE_UP, onButtonClick);

			_membersBtn = ButtonFactory.getBitmapButton('AllianceSideBtnUpBMD', 17, 135, _memberText, 0xc9e6f6, 'AllianceSideBtnRollOverBMD', 'AllianceSideBtnDownBMD', null, 'AllianceSideBtnSelectedBMD');
			_membersBtn.fontSize = 20;
			_membersBtn.label.x -= 29;
			_membersBtn.label.y += 3;
			_membersBtn.selectable = true;
			_membersBtn.enabled = false;
			addListener(_membersBtn, MouseEvent.MOUSE_UP, onButtonClick);

			_infoDisplay = new AllianceInfoDisplay();
			_infoDisplay.onMotdUpdated = onUpdateMOTD;
			_infoDisplay.onDescriptionUpdated = onUpdateDescription;
			_infoDisplay.onPublicChanged = onPublicChanged;
			_infoDisplay.onLeaveAlliance = onLeaveAlliance;
			_infoDisplay.onSendAllianceMail = onSendAllianceMail;
			_infoDisplay.x = 194;
			_infoDisplay.y = 47;
			_infoDisplay.setEnabled(false);
			_infoDisplay.setVisible(false);
			presenter.injectObject(_infoDisplay);

			_memberDisplay = new AllianceMemberDisplay();
			_memberDisplay.onPromoteMember = onPromoteMember;
			_memberDisplay.onDemoteMember = onDemoteMember;
			_memberDisplay.onRemoveMember = onRemoveMember;
			_memberDisplay.onShowProfile = onShowProfile;
			_memberDisplay.x = 194;
			_memberDisplay.y = 47;
			_memberDisplay.visible = false;

			_title = new Label(22, 0xf0f0f0, 300, 30, true);
			_title.constrictTextToSize = false;
			_title.allCaps = true;
			_title.align = TextFormatAlign.LEFT;
			_title.x = 29;
			_title.y = 10;			
			_title.text = _noAllianceFound;

			presenter.addOnAllianceMembersUpdatedListener(onMembersUpdated);
			presenter.addOnAllianceUpdatedListener(onAllianceUpdate);
			presenter.addOnGenericAllianceMessageRecievedListener(handleAllianceMessage);

			_closeBtn = ButtonFactory.getCloseButton(_bg.width - 36, 11);
			addListener(_closeBtn, MouseEvent.CLICK, onClose);

			addChild(_bg);
			addChild(_closeBtn);
			addChild(_title);
			addChild(_infoBtn);
			addChild(_membersBtn);
			addChild(_infoDisplay);
			addChild(_memberDisplay);
			
			_infoBtn.visible = false;
			_membersBtn.visible = false;
			_infoDisplay.visible = false;

			addEffects();
			effectsIN();

			if (_allianceKey != '')
			{
				_memberDisplay.allianceKey = _allianceKey;
				presenter.allianceBaselineRequest(_allianceKey);
				presenter.allianceRosterRequest(_allianceKey);
			}
		}

		private function onButtonClick( e:MouseEvent ):void
		{
			if (_selectedAllianceBtn)
			{
				switch (_selectedAllianceBtn)
				{
					case _infoBtn:
						if (e.target != _infoBtn)
						{
							_infoDisplay.visible = false;
							unselectBitmapButton(_infoBtn);
						}
						break;
					case _membersBtn:
						if (e.target != _membersBtn)
						{
							_memberDisplay.visible = false;
							unselectBitmapButton(_membersBtn);
						}
						break;
				}

			}

			switch (e.target)
			{
				case _infoBtn:
					if (_selectedAllianceBtn != _infoBtn)
					{
						_infoDisplay.visible = true;
						selectBitmapButton(_infoBtn);
					}
					break;
				case _membersBtn:
					if (_selectedAllianceBtn != _membersBtn)
					{
						_memberDisplay.visible = true;
						presenter.allianceRosterRequest(_allianceKey);
						selectBitmapButton(_membersBtn);
					}
					break;
			}
		}

		private function unselectBitmapButton( btn:BitmapButton ):void
		{
			btn.selectable = true;
			btn.selected = false;
		}

		private function selectBitmapButton( btn:BitmapButton ):void
		{
			btn.selected = true;
			btn.selectable = false;
			_selectedAllianceBtn = btn;
		}

		private function onUpdateDescription( description:String ):void
		{
			var allianceEditInfoView:AllianceEditInfoView = AllianceEditInfoView(_viewFactory.createView(AllianceEditInfoView));
			allianceEditInfoView.titleText = _editDescriptionText;
			allianceEditInfoView.maxChars = 512;
			allianceEditInfoView.bodyText = description;
			allianceEditInfoView.callback = presenter.allianceSetDescription;
			_viewFactory.notify(allianceEditInfoView);
		}

		private function onUpdateMOTD( motd:String ):void
		{
			var allianceEditInfoView:AllianceEditInfoView = AllianceEditInfoView(_viewFactory.createView(AllianceEditInfoView));
			allianceEditInfoView.titleText = _editMotdText;
			allianceEditInfoView.maxChars = 256;
			allianceEditInfoView.bodyText = motd;
			allianceEditInfoView.callback = presenter.allianceSetMOTD;
			_viewFactory.notify(allianceEditInfoView);
		}

		private function onPublicChanged( isPublic:Boolean ):void
		{
			presenter.allianceSetPublic(isPublic);
		}

		private function onPromoteMember( v:AllianceMemberVO ):void
		{

			if (v.rank == AllianceRankEnum.OFFICER)
			{
				var buttons:Vector.<ButtonPrototype> = new Vector.<ButtonPrototype>;
				buttons.push(new ButtonPrototype(_promoteText, presenter.alliancePlayerPromote, [v.key], true, ButtonEnum.GREEN_A));
				buttons.push(new ButtonPrototype(_noText));
				showConfirmation(_promoteTitleText, _promoteBodyText, buttons);
			} else
				presenter.alliancePlayerPromote(v.key);
		}

		private function onDemoteMember( v:AllianceMemberVO ):void
		{
			presenter.alliancePlayerDemote(v.key);
		}

		private function onRemoveMember( v:AllianceMemberVO ):void
		{
			presenter.alliancePlayerKick(v.key);
		}

		private function onShowProfile( v:AllianceMemberVO ):void
		{
			var playerProfileView:PlayerProfileView = PlayerProfileView(_viewFactory.createView(PlayerProfileView));
			playerProfileView.playerKey = v.key;
			_viewFactory.notify(playerProfileView);
		}

		private function onSendAllianceMail():void
		{
			var newMailView:NewMailView = NewMailView(_viewFactory.createView(NewMailView));
			newMailView.setMessageInfo('Alliance', '');
			_viewFactory.notify(newMailView);
		}

		private function onLeaveAlliance():void
		{
			presenter.allianceLeave();
			destroy();
		}

		public function handleAllianceMessage( messageEnum:int, allianceKey:String ):void
		{
			switch (messageEnum)
			{
				case AllianceResponseEnum.SET_SUCCESS:
					if (_allianceKey != '')
					{
						presenter.allianceRosterRequest(_allianceKey);
						presenter.allianceBaselineRequest(_allianceKey);
					}
					break;
				case AllianceResponseEnum.KICKED:
					destroy();
					break;
			}
		}

		private function onMembersUpdated( allianceKey:String, v:Vector.<AllianceMemberVO> ):void
		{
			if (allianceKey == _allianceKey && _memberDisplay)
				_memberDisplay.onMembersUpdated(v);
		}

		private function onAllianceUpdate( allianceKey:String, v:AllianceVO ):void
		{
			if (allianceKey == _allianceKey)
			{
				if (_infoBtn)
					_infoBtn.enabled = true;
				if (_membersBtn)
					_membersBtn.enabled = true;
				if (_title)
					_title.text = v.name;

				if (_infoDisplay)
				{					
					_infoDisplay.setEnabled(true);
					_infoDisplay.setVisible(true);
					_infoDisplay.onAllianceUpdated(v);
				}
				_infoBtn.visible = true;
				_membersBtn.visible = true;
				
				if (_selectedAllianceBtn == _infoBtn)
				{
					_infoDisplay.visible = true;
				}
				else if (_selectedAllianceBtn == _membersBtn)
				{
					_memberDisplay.visible = true;
				}
			}
		}

		public function set allianceKey( v:String ):void  { _allianceKey = v; }

		override public function get width():Number  { return _bg.width; }
		override public function get height():Number  { return _bg.height; }

		[Inject]
		public function set presenter( v:IAlliancePresenter ):void  { _presenter = v; }
		public function get presenter():IAlliancePresenter  { return IAlliancePresenter(_presenter); }

		override public function destroy():void
		{
			presenter.removeOnAllianceMembersUpdatedListener(onMembersUpdated);
			presenter.removeOnAllianceUpdatedListener(onAllianceUpdate);
			presenter.removeOnGenericAllianceMessageRecievedListener(handleAllianceMessage);
			super.destroy();

			_bg = null;
			_currentState = null;

			if (_title)
				_title.destroy();

			_title = null;

			if (_infoBtn)
				_infoBtn.destroy();

			_infoBtn = null;

			if (_membersBtn)
				_membersBtn.destroy();

			_membersBtn = null;

			if (_selectedAllianceBtn)
				_selectedAllianceBtn.destroy();

			_selectedAllianceBtn = null;

			if (_infoDisplay)
				_infoDisplay.destroy();

			_infoDisplay = null;

			if (_memberDisplay)
				_memberDisplay.destroy();

			_memberDisplay = null;

			_allianceKey = '';
		}
	}
}
