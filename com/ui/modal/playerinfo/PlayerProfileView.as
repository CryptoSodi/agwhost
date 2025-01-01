package com.ui.modal.playerinfo
{
	import com.enum.FactionEnum;
	import com.enum.PlayerUpdateEnum;
	import com.enum.ToastEnum;
	import com.enum.server.AllianceRankEnum;
	import com.enum.ui.ButtonEnum;
	import com.model.asset.AssetVO;
	import com.model.player.CurrentUser;
	import com.model.player.PlayerVO;
	import com.model.prototype.IPrototype;
	import com.presenter.shared.IPlayerProfilePresenter;
	import com.ui.UIFactory;
	import com.ui.core.ButtonPrototype;
	import com.ui.core.View;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;
	import com.ui.core.component.misc.ImageComponent;
	import com.ui.hud.shared.mail.NewMailView;
	import com.ui.modal.ButtonFactory;
	import com.ui.modal.PanelFactory;
	import com.util.CommonFunctionUtil;
	import com.model.player.CurrentUser;
	
	
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.text.TextFormatAlign;
	
	import org.shared.ObjectPool;

	public class PlayerProfileView extends View
	{
		private var _bg:Bitmap;
		private var _closeBtn:BitmapButton;
		private var _factionLogo:Bitmap;
		private var _purchasePremiumSymbol:Bitmap;
		private var _commendationRankRing:Bitmap;
		private var _commendationRankDot:Bitmap;

		private var _title:Label;
		private var _allianceTitle:Label;
		private var _allianceName:Label;
		private var _currentCommendationRankHeader:Label;
		private var _currentCommendationRank:Label;
		private var _nextCommendationRankHeader:Label;
		private var _nextCommendationRank:Label;
		private var _level:Label;
		private var _bioHeader:Label;
		private var _purchaseCostText:Label;

		private var _playerImage:ImageComponent;
		private var _rankImage:ImageComponent;

		private var _allianceInviteBtn:BitmapButton;
		private var _mailBtn:BitmapButton;
		private var _reportBtn:BitmapButton;
		private var _purchaseBtn:BitmapButton;

		private var _playerKey:String;
		private var _purchaseCost:Number;
		private var _player:PlayerVO;

		private var _levelText:String            = 'CodeString.Shared.Level'; //Level [[Number.Level]];
		private var _messageText:String          = 'CodeString.PlayerProfileView.Message'; //MESSAGE
		private var _allianceInviteText:String   = 'CodeString.PlayerProfileView.AllianceInvite'; //ALLIANCE INVITE
		private var _reportText:String           = 'CodeString.PlayerProfileView.Report'; //REPORT
		private var _nameChangeText:String       = 'CodeString.PlayerProfileView.NameChangeBtn'; //NAME CHANGE
		private var _relocateBaseText:String     = 'CodeString.PlayerProfileView.RelocateToBtn'; //RELOCATE BASE TO
		private var _bioText:String              = 'CodeString.PlayerProfileView.Bio'; //BIO
		private var _allianceText:String         = 'CodeString.PlayerProfileView.AllianceTitle'; //ALLIANCE
		private var _currentRankTitleText:String = 'CodeString.PlayerProfileView.CurrentRankTitle'; //Current Rank
		private var _nextRankText:String         = 'CodeString.PlayerProfileView.NextRankTitle'; //Next Rank
		private var _noneText:String             = 'CodeString.PlayerProfileView.NoAlliance'; //None
		private var _newNameTitleText:String     = 'CodeString.PlayerProfileView.NewNameTitle'; //Change Name
		private var _newNameBodyText:String      = 'CodeString.PlayerProfileView.NewNameBody'; //Please Enter Your New Name.
		private var _acceptBtnText:String        = 'CodeString.Shared.Accept'; //ACCEPT
		private var _cancelBtnText:String        = 'CodeString.Shared.CancelBtn'; //CANCEL
		private var _relocateAlertTitle:String   = 'CodeString.Alert.Relocate.Title'; //RELOCATE
		private var _relocateAlertBody:String    = 'CodeString.Alert.Relocate.Body'; //This will move your starbase close to the selected player's starbase.\nAre you Sure?

		private var _emptyNameError:String       = 'CodeString.PlayerProfileView.EmptyNameError'; //Empty Character Name
		private var _tooFewCharacters:String     = 'CodeString.PlayerProfileView.TooFewCharacters'; //Too Few Characters In Name
		private var _minMailLevel:int = 30;
		
		[PostConstruct]
		override public function init():void
		{
			super.init();

			_bg = PanelFactory.getPanel('PlayerProfileBGBMD');

			_factionLogo = new Bitmap();
			_factionLogo.x = 443;
			_factionLogo.y = 107;

			_playerImage = ObjectPool.get(ImageComponent);
			_playerImage.init(178, 178);
			_playerImage.x = 228;
			_playerImage.y = 110;

			_rankImage = ObjectPool.get(ImageComponent);
			_rankImage.init(140, 140);
			_rankImage.x = 40.5;
			_rankImage.y = 98;

			_commendationRankRing = UIFactory.getBitmap('CommendationRankRingBMD');
			_commendationRankRing.x = 42;
			_commendationRankRing.y = 98;

			_commendationRankDot = UIFactory.getBitmap('CommendationRankDotBMD');

			_mailBtn = ButtonFactory.getBitmapButton('PlayerProfileMessageBtnUpBMD', 573, 300, _messageText, 0xbaddff, 'PlayerProfileMessageBtnROBMD', 'PlayerProfileMessageBtnDownBMD');
			_mailBtn.label.fontSize = 18;
			_mailBtn.label.y += 1;
			addListener(_mailBtn, MouseEvent.MOUSE_UP, onButtonClick);

			_allianceInviteBtn = ButtonFactory.getBitmapButton('PlayerProfileMessageBtnUpBMD', 573, _mailBtn.y + _mailBtn.height + 2, _allianceInviteText, 0xbaddff, 'PlayerProfileMessageBtnROBMD',
															   'PlayerProfileMessageBtnDownBMD');
			_allianceInviteBtn.label.fontSize = 18;
			_allianceInviteBtn.label.y += 1;
			addListener(_allianceInviteBtn, MouseEvent.MOUSE_UP, onButtonClick);

			_reportBtn = ButtonFactory.getBitmapButton('PlayerProfileBlockUserBtnUpBMD', 452, 300, _reportText, 0xcffa5a5, 'PlayerProfileBlockUserBtnROBMD', 'PlayerProfileBlockUserBtnDownBMD');
			_reportBtn.label.fontSize = 18;
			_reportBtn.label.y += 1;
			addListener(_reportBtn, MouseEvent.MOUSE_UP, onButtonClick);

			_purchaseBtn = ButtonFactory.getBitmapButton('SquareBuyBtnNeutralBMD', 213, 315, _nameChangeText, 0xf7c78b, 'SquareBuyBtnRollOverBMD', 'SquareBuyBtnSelectedBMD');
			addListener(_purchaseBtn, MouseEvent.MOUSE_UP, onButtonClick);

			_purchasePremiumSymbol = PanelFactory.getPanel('KalganSymbolBMD');
			_purchasePremiumSymbol.x = _purchaseBtn.x + 7;
			_purchasePremiumSymbol.y = _purchaseBtn.y + 24;

			_title = new Label(22, 0xf0f0f0, 300, 30, false);
			_title.constrictTextToSize = false;
			_title.allCaps = true;
			_title.align = TextFormatAlign.LEFT;
			_title.x = 29;
			_title.y = 23;

			_level = new Label(20, 0xb3ddf2, 150, 30);
			_level.constrictTextToSize = false;
			_level.allCaps = true;
			_level.align = TextFormatAlign.LEFT;
			_level.x = 335;
			_level.y = 71;

			_bioHeader = new Label(20, 0xf0f0f0, 150, 30);
			_bioHeader.constrictTextToSize = false;
			_bioHeader.allCaps = true;
			_bioHeader.align = TextFormatAlign.LEFT;
			_bioHeader.x = 649;
			_bioHeader.y = 77;
			_bioHeader.text = _bioText;

			_allianceTitle = new Label(14, 0xf0f0f0, 184, 30, true, 1);
			_allianceTitle.allCaps = true;
			_allianceTitle.align = TextFormatAlign.CENTER;
			_allianceTitle.x = 12;
			_allianceTitle.y = 57;
			_allianceTitle.text = _allianceText;

			_allianceName = new Label(16, 0xf0f0f0, 184, 30, false);
			_allianceName.allCaps = true;
			_allianceName.align = TextFormatAlign.CENTER;
			_allianceName.x = 13;
			_allianceName.y = 77;

			_currentCommendationRankHeader = new Label(20, 0xf0f0f0, 120, 30);
			_currentCommendationRankHeader.constrictTextToSize = false;
			_currentCommendationRankHeader.allCaps = true;
			_currentCommendationRankHeader.align = TextFormatAlign.LEFT;
			_currentCommendationRankHeader.x = 33;
			_currentCommendationRankHeader.y = 240;
			_currentCommendationRankHeader.text = _currentRankTitleText;

			_currentCommendationRank = new Label(12, 0xb3ddf2, 150, 30, true, 1);
			_currentCommendationRank.constrictTextToSize = false;
			_currentCommendationRank.align = TextFormatAlign.LEFT;
			_currentCommendationRank.x = 35;
			_currentCommendationRank.y = 268;

			_nextCommendationRankHeader = new Label(20, 0xf0f0f0, 120, 30);
			_nextCommendationRankHeader.constrictTextToSize = false;
			_nextCommendationRankHeader.allCaps = true;
			_nextCommendationRankHeader.align = TextFormatAlign.LEFT;
			_nextCommendationRankHeader.x = 33;
			_nextCommendationRankHeader.y = 303;
			_nextCommendationRankHeader.text = _nextRankText;

			_nextCommendationRank = new Label(12, 0xb3ddf2, 150, 30, true, 1);
			_nextCommendationRank.constrictTextToSize = false;
			_nextCommendationRank.align = TextFormatAlign.LEFT;
			_nextCommendationRank.x = 35;
			_nextCommendationRank.y = 331;
			_nextCommendationRank.text = _noneText;

			_purchaseCostText = new Label(18, 0xf0f0f0, 114, 25, false);
			_purchaseCostText.align = TextFormatAlign.CENTER;
			_purchaseCostText.constrictTextToSize = false;
			_purchaseCostText.x = _purchaseBtn.x + 4;
			_purchaseCostText.y = _purchaseBtn.y + 26;

			_closeBtn = ButtonFactory.getCloseButton(_bg.width - 40, 25);
			addListener(_closeBtn, MouseEvent.CLICK, onClose);

			addChild(_bg);
			addChild(_closeBtn);
			addChild(_factionLogo);
			addChild(_playerImage);
			addChild(_rankImage);
			addChild(_title);
			addChild(_level);
			addChild(_bioHeader);
			addChild(_allianceTitle);
			addChild(_allianceName);
			addChild(_currentCommendationRankHeader);
			addChild(_currentCommendationRank);
			addChild(_nextCommendationRankHeader);
			addChild(_nextCommendationRank);
			addChild(_allianceInviteBtn);
			// Players over level 30 can mail
			if (CurrentUser.level >= _minMailLevel){
				
				addChild(_mailBtn);
			}
			
			addChild(_reportBtn);
			addChild(_purchaseBtn);
			addChild(_purchasePremiumSymbol);
			addChild(_purchaseCostText);
			addChild(_commendationRankRing);
			addChild(_commendationRankDot);
			
			
			
			if (CurrentUser.id == _playerKey)
			{
				CurrentUser.onPlayerUpdate.add(onPlayerUpdated);
				setUp(CurrentUser.user);
			} else
			{
				presenter.addOnPlayerVOAddedListener(setUp);
				presenter.requestPlayer(_playerKey);
			}

			addEffects();
			effectsIN();
		}

		private function setUp( player:PlayerVO ):void
		{
			if (player.id == _playerKey)
			{
				_player = player;

				if (_title)
					_title.text = player.name;

				presenter.loadPortraitProfile(player.avatarName, _playerImage.onImageLoaded);
				var assetName:String;
				if (_factionLogo)
				{
					switch (player.faction)
					{
						case FactionEnum.IGA:
							_factionLogo.bitmapData = PanelFactory.getBitmapData('PlayerProfileIGALogoBMD');
							assetName = 'igaUIAsset';
							break;
						case FactionEnum.SOVEREIGNTY:
							_factionLogo.bitmapData = PanelFactory.getBitmapData('PlayerProfileSOVLogoBMD');
							assetName = 'sovUIAsset';
							break;
						case FactionEnum.TYRANNAR:
							_factionLogo.bitmapData = PanelFactory.getBitmapData('PlayerProfileTYRLogoBMD');
							assetName = 'tryUIAsset';
							break;
					}


					_factionLogo.x = 440 + (242 - _factionLogo.width) * 0.5;
					_factionLogo.y = 105 + (182 - _factionLogo.height) * 0.5;
				}
				
				
				
				if (_level)
					_level.setTextWithTokens(_levelText, {'[[Number.Level]]':player.level});

				var rank:int = CommonFunctionUtil.getCommendationRank(player.commendationPointsPVE + player.commendationPointsPVP);

				var rankProto:IPrototype = presenter.getCommendationRankPrototypesByName(CommonFunctionUtil.getCommendationProtoName(rank));
				var rankAssetVO:AssetVO = presenter.getAssetVO(rankProto.getValue(assetName));

				_rankImage.filters = [CommonFunctionUtil.getColorMatrixFilter(CommonFunctionUtil.getRankColorBasedOnScore(player.commendationPointsPVE, player.commendationPointsPVP))];

				_currentCommendationRank.text = rankAssetVO.visibleName;
				presenter.loadSmallImage(rankAssetVO.smallImage, _rankImage.onImageLoaded);

				if (rank == 20)
				{
					_nextCommendationRank.text = _noneText;
				} else
				{
					rankProto = presenter.getCommendationRankPrototypesByName(CommonFunctionUtil.getCommendationProtoName(rank + 1));
					rankAssetVO = presenter.getAssetVO(rankProto.getValue(assetName));
					_nextCommendationRank.text = rankAssetVO.visibleName;
				}

				if (_allianceName)
				{
					var allianceText:String;
					if (player.allianceName != '')
					{
						_allianceName.useLocalization = false;
						allianceText = player.allianceName;
					} else
					{
						_allianceName.useLocalization = true;
						allianceText = _noneText;
					}

					_allianceName.text = allianceText;
				}

				if (CurrentUser.id != _playerKey)
				{
					var in_split_test_cohort:Boolean = presenter.hasSectorSplitTestCohort( CurrentUser.vo.baseSector ) || presenter.hasSectorSplitTestCohort( player.baseSector );
					
					if (CurrentUser.faction == player.faction && !in_split_test_cohort)
					{
						var disableBaseRelocate:Boolean = presenter.currentPlayerInABattle();
						_purchaseCost = presenter.getConstantPrototypeValueByName('playerRenamePrice');
						_purchaseBtn.text = _relocateBaseText;
						_purchaseBtn.label.fontSize = 22;
						_purchaseBtn.label.y -= 5;
						_purchaseBtn.visible = !disableBaseRelocate;
						_purchasePremiumSymbol.visible = !disableBaseRelocate;
						_purchaseCostText.visible = !disableBaseRelocate;
						_purchaseCostText.text = String(_purchaseCost);
					} else
					{
						_purchaseBtn.visible = false;
						_purchasePremiumSymbol.visible = false;
						_purchaseCostText.visible = false;
					}

					_commendationRankDot.visible = false;
					_commendationRankRing.visible = false;

					if (_allianceInviteBtn)
						_allianceInviteBtn.visible = (player.faction == CurrentUser.faction && player.alliance == '' && CurrentUser.alliance != '' && (CurrentUser.isAllianceOpen || CurrentUser.allianceRank >
							AllianceRankEnum.
							MEMBER))
				} else
				{
					_purchaseCost = presenter.getConstantPrototypeValueByName('playerRenamePrice');

					_purchaseBtn.text = _nameChangeText;
					_purchaseBtn.label.fontSize = 22;
					_purchaseBtn.label.y -= 5;
					_purchaseCostText.text = String(_purchaseCost);

					_reportBtn.visible = false;
					_allianceInviteBtn.visible = false;
					_mailBtn.visible = false;
					_commendationRankDot.visible = true;
					_commendationRankRing.visible = true;

					var rankPosition:int = CommonFunctionUtil.getRankScoreDisplayPosition(rank, player.commendationPointsPVE + player.commendationPointsPVP);
					switch (rankPosition)
					{
						case 1:
							_commendationRankDot.x = 67;
							_commendationRankDot.y = 113;
							break;
						case 2:
							_commendationRankDot.x = 48;
							_commendationRankDot.y = 186;
							break;
						case 3:
							_commendationRankDot.x = 108;
							_commendationRankDot.y = 228;
							break;
						case 4:
							_commendationRankDot.x = 167;
							_commendationRankDot.y = 188;
							break;
						case 5:
							_commendationRankDot.x = 147;
							_commendationRankDot.y = 112;
							break;
					}
				}


			}
		}

		private function onButtonClick( e:MouseEvent ):void
		{

			switch (e.target)
			{
				case _allianceInviteBtn:
				{
					presenter.allianceSendInvite(_playerKey);

					if (_allianceInviteBtn)
						_allianceInviteBtn.visible = false;

					break;
				}

				case _mailBtn:
				{
					var newMailView:NewMailView = NewMailView(_viewFactory.createView(NewMailView));
					newMailView.setMessageInfo(_player.name, _playerKey);
					_viewFactory.notify(newMailView);

					break;
				}

				case _reportBtn:
				{
					presenter.reportPlayer(_playerKey);

					if (_reportBtn)
						_reportBtn.visible = false;

					break;
				}

				case _purchaseBtn:
				{
					if (CurrentUser.wallet.premium >= _purchaseCost)
						if (CurrentUser.id == _playerKey)
							showInputAlert(_newNameTitleText, _newNameBodyText, _cancelBtnText, null, null, _acceptBtnText, onChangedName, null, true, 20, '', false, "A-Za-z0-9'_\\-бвгдёжзийклмнптфцчшщъьэюяыБГДЁЖЗИЙЛПУФЦЧШЩЪЬЭЮЯЫäöüßÄÖÜàâæéèêëïîôœùûüçÿÀÂÆÉÈÊËÏÎÔŒÛÙÜÇŸìòÒÙíóúñ¿¡ÁÍÓÚÑıçğşİÖÜÇĞŞåÅæøÆÅØãíõÃÍÕ ");
						else
						{
							var buttons:Vector.<ButtonPrototype> = new Vector.<ButtonPrototype>;
							buttons.push(new ButtonPrototype(_acceptBtnText, onRelocateBase, null, true, ButtonEnum.GOLD_A));
							buttons.push(new ButtonPrototype(_cancelBtnText));
							showConfirmation(_relocateAlertTitle, _relocateAlertBody, buttons);
						} else
						CommonFunctionUtil.popPaywall();

					break;
				}
			}
		}

		private function onChangedName( v:String ):void
		{
			if (v != '' && v.length > 1)
				presenter.renamePlayer(v);
			else
			{
				if (v == '')
					showToast(ToastEnum.WRONG, null, _emptyNameError);
				else
					showToast(ToastEnum.WRONG, null, _tooFewCharacters);
			}
		}

		private function onRelocateBase():void
		{
			if (_playerKey != '' && _playerKey != CurrentUser.id)
				presenter.relocateStarbase(_playerKey);
		}

		private function onPlayerUpdated( updateType:int, oldValue:String, newValue:String ):void
		{
			if (oldValue != newValue)
			{
				switch (updateType)
				{
					case PlayerUpdateEnum.TYPE_NAME:
						_title.text = newValue;
						break;
				}
			}
		}

		override public function get height():Number  { return _bg.height; }
		override public function get width():Number  { return _bg.width; }

		public function set playerKey( v:String ):void  { _playerKey = v; }

		[Inject]
		public function set presenter( v:IPlayerProfilePresenter ):void  { _presenter = v; }
		public function get presenter():IPlayerProfilePresenter  { return IPlayerProfilePresenter(_presenter); }

		override public function destroy():void
		{
			if (CurrentUser.id == _playerKey)
				CurrentUser.onPlayerUpdate.remove(onPlayerUpdated);

			presenter.removeOnPlayerVOAddedListener(setUp);
			super.destroy();

			_bg = null;
			_closeBtn.destroy();
			_closeBtn = null;
			_factionLogo = null;

			if (_playerImage)
				ObjectPool.give(_playerImage);

			_playerImage = null;

			if (_title)
				_title.destroy();

			_title = null;

			if (_allianceTitle)
				_allianceTitle.destroy();

			_allianceTitle = null;

			if (_allianceName)
				_allianceName.destroy();

			_allianceName = null;

			if (_currentCommendationRankHeader)
				_currentCommendationRankHeader.destroy();

			_currentCommendationRankHeader = null;

			if (_currentCommendationRank)
				_currentCommendationRank.destroy();

			_currentCommendationRank = null;

			if (_nextCommendationRankHeader)
				_nextCommendationRankHeader.destroy();

			_nextCommendationRankHeader = null;

			if (_nextCommendationRank)
				_nextCommendationRank.destroy();

			_nextCommendationRank = null;

			if (_level)
				_level.destroy();

			_level = null;

			if (_bioHeader)
				_bioHeader.destroy();

			_bioHeader = null;

			if (_allianceInviteBtn)
			{
				removeListener(_allianceInviteBtn, MouseEvent.MOUSE_UP, onButtonClick);
				_allianceInviteBtn.destroy();
			}

			_allianceInviteBtn = null;

			if (_mailBtn)
			{
				removeListener(_mailBtn, MouseEvent.MOUSE_UP, onButtonClick);
				_mailBtn.destroy();
			}

			_mailBtn = null;

			if (_reportBtn)
			{
				removeListener(_reportBtn, MouseEvent.MOUSE_UP, onButtonClick);
				_reportBtn.destroy();
			}

			_reportBtn = null;


			if (_purchaseBtn)
			{
				removeListener(_purchaseBtn, MouseEvent.MOUSE_UP, onButtonClick);
				_purchaseBtn.destroy();
			}

			_purchaseBtn = null;
		}
	}
}
