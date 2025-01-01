package com.ui.modal.alliances.noalliance
{
	import com.enum.server.AllianceResponseEnum;
	import com.model.player.CurrentUser;
	import com.presenter.shared.IAlliancePresenter;
	import com.ui.core.View;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;
	import com.ui.modal.ButtonFactory;
	import com.ui.modal.alliances.alliance.AllianceView;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextFormatAlign;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;

	public class NoAllianceView extends View
	{
		private var _bg:Bitmap;
		private var _closeBtn:BitmapButton;
		private var _currentState:Sprite;

		private var _title:Label;

		private var _joinDisplay:JoinAllianceDisplay;
		private var _invitesDisplay:AllianceInvitesDisplay;
		private var _createDisplay:CreateAllianceDisplay;

		private var _joinBtn:BitmapButton;
		private var _inviteBtn:BitmapButton;
		private var _createBtn:BitmapButton;
		private var _selectedAllianceBtn:BitmapButton;

		private var _allianceText:String        = 'CodeString.Shared.Alliances'; //ALLIANCES
		private var _allianceJoinText:String    = 'CodeString.NoAlliance.Join'; //JOIN
		private var _allianceInvitesText:String = 'CodeString.NoAlliance.Invites'; //INVITES
		private var _allianceCreateText:String  = 'CodeString.Alliance.Create'; //CREATE

		[PostConstruct]
		override public function init():void
		{
			super.init();

			var windowBGClass:Class = Class(getDefinitionByName('AllianceMainBGBMD'));
			_bg = new Bitmap(BitmapData(new windowBGClass()));

			_joinBtn = ButtonFactory.getBitmapButton('AllianceSideBtnUpBMD', 17, 64, _allianceJoinText, 0xc9e6f6, 'AllianceSideBtnRollOverBMD', 'AllianceSideBtnDownBMD', null, 'AllianceSideBtnSelectedBMD');
			_joinBtn.fontSize = 20;
			_joinBtn.label.x -= 29;
			_joinBtn.label.y += 3;
			_joinBtn.selectable = true;
			addListener(_joinBtn, MouseEvent.MOUSE_UP, onButtonClick);

			_inviteBtn = ButtonFactory.getBitmapButton('AllianceSideBtnUpBMD', 17, 135, _allianceInvitesText, 0xc9e6f6, 'AllianceSideBtnRollOverBMD', 'AllianceSideBtnDownBMD', null, 'AllianceSideBtnSelectedBMD');
			_inviteBtn.fontSize = 20;
			_inviteBtn.label.x -= 29;
			_inviteBtn.label.y += 3;
			_inviteBtn.selectable = true;
			addListener(_inviteBtn, MouseEvent.MOUSE_UP, onButtonClick);
			
			_createBtn = ButtonFactory.getBitmapButton('AllianceSideBtnUpBMD', 17, 205, _allianceCreateText, 0xc9e6f6, 'AllianceSideBtnRollOverBMD', 'AllianceSideBtnDownBMD', null, 'AllianceSideBtnSelectedBMD');
			_createBtn.fontSize = 20;
			_createBtn.label.x -= 29;
			_createBtn.label.y += 3;
			_createBtn.selectable = true;
			addListener(_createBtn, MouseEvent.MOUSE_UP, onButtonClick);

			_joinDisplay = new JoinAllianceDisplay();
			_joinDisplay.joinAllianceClick = joinAlliance;
			_joinDisplay.viewAllianceClick = viewAlliance;
			presenter.injectObject(_joinDisplay);
			_joinDisplay.x = 194;
			_joinDisplay.y = 47;
			_joinDisplay.visible = false;

			_invitesDisplay = new AllianceInvitesDisplay();
			_invitesDisplay.joinAllianceClick = joinAlliance;
			_invitesDisplay.viewAllianceClick = viewAlliance;
			_invitesDisplay.x = 194;
			_invitesDisplay.y = 47;
			_invitesDisplay.visible = false;
			
			_createDisplay = new CreateAllianceDisplay();
			_createDisplay.createAllianceClick = createAlliance;
			presenter.injectObject(_createDisplay);
			_createDisplay.x = 194;
			_createDisplay.y = 47;
			_createDisplay.visible = false;

			_title = new Label(20, 0xf0f0f0, 150, 25);
			_title.align = TextFormatAlign.LEFT;
			_title.x = 29;
			_title.y = 10;
			_title.text = _allianceText;

			presenter.addOnOpenAlliancesUpdatedListener(onAlliancesUpdated);
			presenter.addOnInvitedAlliancesUpdatedListener(onInvitedAlliancesUpdated);
			presenter.addOnGenericAllianceMessageRecievedListener(handleAllianceMessage);

			_closeBtn = ButtonFactory.getCloseButton(_bg.width - 36, 11);
			addListener(_closeBtn, MouseEvent.CLICK, onClose);

			addChild(_bg);
			addChild(_closeBtn);
			addChild(_title);
			addChild(_createBtn);
			addChild(_joinBtn);
			addChild(_inviteBtn);
			addChild(_joinDisplay);
			addChild(_invitesDisplay);
			addChild(_createDisplay);
	
			addEffects();
			effectsIN();
			
			presenter.alliancePublicAllianceRequest();
			
			_joinDisplay.visible = true;
			selectBitmapButton(_joinBtn);
		}

		private function onButtonClick( e:MouseEvent ):void
		{
			if (_selectedAllianceBtn)
			{
				switch (_selectedAllianceBtn)
				{
					case _joinBtn:
						if (e.target != _joinBtn)
						{
							_joinDisplay.visible = false;
							unselectBitmapButton(_joinBtn);
						}
						break;
					case _inviteBtn:
						if (e.target != _inviteBtn)
						{
							_invitesDisplay.visible = false;
							unselectBitmapButton(_inviteBtn);
						}
						break;
					case _createBtn:
						if (e.target != _createBtn)
						{
							_createDisplay.visible = false;
							unselectBitmapButton(_createBtn);
						}
						break;
				}
			}

			switch (e.target)
			{
				case _joinBtn:
					if (_selectedAllianceBtn != _joinBtn)
					{
						presenter.alliancePublicAllianceRequest();
						_joinDisplay.visible = true;
						selectBitmapButton(_joinBtn);
					}
					break;
				case _inviteBtn:
					if (_selectedAllianceBtn != _inviteBtn)
					{
						if (presenter)
							_invitesDisplay.onInvitesUpdated(presenter.getAllianceInvites());

						_invitesDisplay.visible = true;
						selectBitmapButton(_inviteBtn);
					}
					break;
				case _createBtn:
					if (_selectedAllianceBtn != _createBtn)
					{
						_createDisplay.visible = true;
						selectBitmapButton(_createBtn);
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

		private function createAlliance( name:String, isPublic:Boolean, description:String ):void
		{
			presenter.allianceCreateRequest(name, isPublic, description);
		}

		private function joinAlliance( allianceKey:String ):void
		{
			presenter.allianceJoin(allianceKey);
		}

		private function viewAlliance( allianceKey:String ):void
		{
			if (allianceKey != '')
			{
				var allianceView:AllianceView = AllianceView(_viewFactory.createView(AllianceView));
				allianceView.allianceKey = allianceKey;
				_viewFactory.notify(allianceView);
			}
		}

		private function onAlliancesUpdated( v:Dictionary ):void
		{
			if (_joinDisplay)
				_joinDisplay.onAlliancesUpdated(v);
		}

		private function onInvitedAlliancesUpdated( v:Dictionary ):void
		{
			if (_invitesDisplay)
				_invitesDisplay.onInvitesUpdated(v);
		}

		public function handleAllianceMessage( messageEnum:int, allianceKey:String ):void
		{
			switch (messageEnum)
			{
				case AllianceResponseEnum.ALLIANCE_CREATED:
				case AllianceResponseEnum.JOINED:
					CurrentUser.alliance = allianceKey;
					destroy();
					break;
				case AllianceResponseEnum.ALLIANCE_CREATION_FAILED_NAMEINUSE:
				case AllianceResponseEnum.ALLIANCE_CREATION_FAILED_UNKNOWN:
					_createDisplay.handleAllianceMessage(messageEnum);
					break;
				case AllianceResponseEnum.JOIN_FAILED_TOOMANYPLAYERS:
					break;
			}
		}

		override public function get height():Number  { return _bg.height; }
		override public function get width():Number  { return _bg.width; }

		[Inject]
		public function set presenter( v:IAlliancePresenter ):void  { _presenter = v; }
		public function get presenter():IAlliancePresenter  { return IAlliancePresenter(_presenter); }

		override public function destroy():void
		{
			presenter.removeOnOpenAlliancesUpdatedListener(onAlliancesUpdated);
			presenter.removeOnInvitedAlliancesUpdatedListener(onInvitedAlliancesUpdated);
			presenter.removeOnGenericAllianceMessageRecievedListener(handleAllianceMessage);
			super.destroy();

			_bg = null;
			_closeBtn.destroy();
			_closeBtn = null;
			_currentState = null;

			if (_title)
				_title.destroy();

			_title = null;

			if (_createDisplay)
				_createDisplay.destroy();

			_createDisplay = null;

			if (_joinDisplay)
				_joinDisplay.destroy();

			_joinDisplay = null;

			if (_invitesDisplay)
				_invitesDisplay.destroy();

			_invitesDisplay = null;

			if (_createBtn)
				_createBtn.destroy();

			_createBtn = null;

			if (_joinBtn)
				_joinBtn.destroy();

			_joinBtn = null;

			if (_inviteBtn)
				_inviteBtn.destroy();

			_inviteBtn = null;

			if (_selectedAllianceBtn)
				_selectedAllianceBtn.destroy();

			_selectedAllianceBtn = null;
		}
	}
}
