package com.ui.modal.battle
{
	import com.Application;
	import com.enum.AudioEnum;
	import com.enum.server.UnavailableRerollEnum;
	import com.enum.ui.ButtonEnum;
	import com.enum.ui.LabelEnum;
	import com.enum.ui.PanelEnum;
	import com.model.asset.AssetVO;
	import com.model.battle.BattleRerollVO;
	import com.model.blueprint.BlueprintVO;
	import com.model.player.CurrentUser;
	import com.model.player.PlayerVO;
	import com.model.prototype.IPrototype;
	import com.presenter.battle.IBattlePresenter;
	import com.service.ExternalInterfaceAPI;
	import com.ui.UIFactory;
	import com.ui.core.DefaultWindowBG;
	import com.ui.core.ScaleBitmap;
	import com.ui.core.View;
	import com.ui.core.component.bar.VScrollbar;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;
	import com.ui.core.component.misc.ImageComponent;
	import com.ui.core.component.tooltips.Tooltips;
	import com.ui.modal.battle.chance.ChanceGameDisplayComponent;
	import com.util.CommonFunctionUtil;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	import flash.utils.Dictionary;
	
	import org.adobe.utils.DictionaryUtil;
	import org.adobe.utils.StringUtil;
	import org.shared.ObjectPool;

	public class BattleEndView extends View
	{
		
		[Inject]
		private var _tooltips:Tooltips;

		private var _battleID:String;
		private var _blueprintProtoName:String;

		private var _victors:Dictionary;

		private var _blueprintCost:int;
		private var _lootedAlloyAmount:Number;
		private var _lootedCreditsAmount:Number;
		private var _lootedEnergyAmount:Number;
		private var _lootedSyntheticsAmount:Number;

		private var _cargoFull:Boolean;

		private var _maxHeight:Number;

		private var _participants:Vector.<String>;

		private var _isPlayerInCombat:Boolean;
		private var _isPlayerVictor:Boolean;

		private var _bg:DefaultWindowBG;

		private var _okBtn:BitmapButton;
		private var _shareButton:BitmapButton;

		private var _defeatedVO:PlayerVO;
		private var _victorVO:PlayerVO;

		private var _lootHolder:Sprite;
		private var _participantHolder:Sprite;

		private var _scrollbar:VScrollbar;

		private var _scrollRect:Rectangle;

		private var _lootedAlloySymbol:Bitmap;
		private var _lootedCreditsSymbol:Bitmap;
		private var _lootedEnergySymbol:Bitmap;
		private var _lootedSyntheticsSymbol:Bitmap;

		private var _headingBG:ScaleBitmap;
		private var _participantsBG:ScaleBitmap;
		private var _beCDialogueBG:ScaleBitmap;
		private var _lootBg:ScaleBitmap;
		private var _unavailableRerollBG:ScaleBitmap;

		private var _titleLbl:Label;
		private var _lootedAlloyLbl:Label;
		private var _lootedCreditsLbl:Label;
		private var _lootedEnergyLbl:Label;
		private var _lootedSyntheticsLbl:Label;
		private var _beCDialogueLbl:Label;
		private var _victorsHeading:Label;
		private var _losersHeading:Label;
		private var _unavailableReroll:Label;

		private var _blueprint:BlueprintVO;

		private var _chanceComponent:ChanceGameDisplayComponent;

		private var _soundToPlay:String = '';
		private var _cargoFullString:String = 'CodeString.BattleEnd.Full'; //[[Number.AmountLooted]] (FULL)
		private var _okBtnText:String       = 'CodeString.Shared.OkBtn'; //OK
		private var _shareBtnText:String    = 'CodeString.BattleEnd.ShareBtn'; //Share
		private var _completeBtnText:String = 'CodeString.Dialogue.Complete'; //COMPLETE
		private var _drawText:String        = 'CodeString.BattleLog.DrawTitle' //DRAW
		private var _watchText:String       = 'CodeString.BattleEnd.Watch'; //WATCH
		private var _victoryText:String     = 'CodeString.BattleEnd.Victory'; //VICTORY
		private var _defeatText:String      = 'CodeString.BattleEnd.Defeat'; //DEFEAT
		private var _titleText:String       = 'CodeString.BattleEnd.Title'; //BATTLE REPORT
		private var _victorText:String      = 'CodeString.BattleLog.Victor'; //Victor
		private var _defeatedText:String    = 'CodeString.BattleLog.Defeated'; //Defeated

		private var _NoChallenge:String     = 'CodeString.UnavailableReroll.NoChallenge'; //Your fleet's rating was too high to receive blueprints from this opponent.
		private var _FarmPenalty:String     = 'CodeString.UnavailableReroll.FarmPenalty'; //You have attacked this opponent too often to receive blueprints.
		private var _DamageReq:String       = 'CodeString.UnavailableReroll.DamageReq'; //You did not do enough damage to this opponent to receive a blueprint.
		private var _AllComplete:String     = 'CodeString.UnavailableReroll.AllComplete'; //You have already completed all blueprints which can drop from this opponent.
		private var _SlotsFull:String       = 'CodeString.UnavailableReroll.SlotsFull'; //This opponent was not eligible to drop parts for any of your in-progress blueprints.
		private var _NoneInBand:String      = 'CodeString.UnavailableReroll.NoneInBand'; //Opponents of this rating have no blueprints available for you.
		private var _MissingTech:String     = 'CodeString.UnavailableReroll.MissingTech'; //You must upgrade your labs or technology to receive blueprints from this opponent.
		private var _BadEncounter:String    = 'CodeString.UnavailableReroll.BadEncounter'; //The specific opponent you killed could not drop any blueprints for you.
		private var _BadFaction:String      = 'CodeString.UnavailableReroll.BadFaction'; //You must fight opponents of a different faction to receive blueprints.
		private var _NoneAtRarity:String    = 'CodeString.UnavailableReroll.NoneAtRarity'; //There are no other blueprints available of the specified rarity.

		[PostConstruct]
		override public function init():void
		{
			super.init();
			presenter.addCleanupListener(destroy);

			var totalVictors:uint                  = DictionaryUtil.getLength(_victors);

			_isPlayerInCombat = presenter.isPlayerInCombat(CurrentUser.id);
			_isPlayerVictor = (_isPlayerInCombat) ? (CurrentUser.id in _victors) : false;
			_participants = presenter.participants;
			_maxHeight = 0;

			if (_isPlayerVictor)
				_victorVO = CurrentUser.user;

			var greaterThenTwoParticipants:Boolean = (_participants.length > 2);

			var soundNumber:int                    = Math.random() * (4 - 1) + 1;
			var sound:String;
			if (_isPlayerVictor || !_isPlayerInCombat)
			{

				switch (soundNumber)
				{
					case 1:
						sound = AudioEnum.AFX_STG_VICTORY_1;
						break;
					case 2:
						sound = AudioEnum.AFX_STG_VICTORY_2;
						break;
					case 3:
						sound = AudioEnum.AFX_STG_VICTORY_3;
						break;
					case 4:
						sound = AudioEnum.AFX_STG_VICTORY_4;
						break;
				}

			} else
			{
				switch (soundNumber)
				{
					case 1:
						sound = AudioEnum.AFX_STG_DEFEAT_1;
						break;
					case 2:
						sound = AudioEnum.AFX_STG_DEFEAT_2;
						break;
					case 3:
						sound = AudioEnum.AFX_STG_DEFEAT_3;
						break;
					case 4:
						sound = AudioEnum.AFX_STG_DEFEAT_4;
						break;
				}

			}
			presenter.playSound(sound, 0.25);

			var bgWidth:Number                     = (greaterThenTwoParticipants) ? 946 : 926;

			_bg = ObjectPool.get(DefaultWindowBG);
			_bg.setBGSize(bgWidth, 479);
			_bg.addTitle(_titleText, 239);
			_bg.x -= 21;
			addListener(_bg.closeButton, MouseEvent.CLICK, exitCombat);
			addChild(_bg);

			_chanceComponent = new ChanceGameDisplayComponent();
			_chanceComponent.onPurchaseComplete.add(onBlueprintPurchase);
			_chanceComponent.rerollClickSignal.add(onRerollClick);
			_chanceComponent.scanClickSignal.add(onScanClick);
			_chanceComponent.denyClickSignal.add(onDenyClick);
			_chanceComponent.getBlueprintPrototype = presenter.getBlueprintPrototypeByName;
			_chanceComponent.getResearchPrototypeByName = presenter.getResearchPrototypeByName;
			_chanceComponent.getSelectionInfo = getSelectionInfo;
			_chanceComponent.cargoFull = _cargoFull;
			_chanceComponent.componentHolder.x = (greaterThenTwoParticipants) ? 460 : 440;
			_chanceComponent.componentHolder.y = 324;

			_titleLbl = new Label(80, 0xffdd3d, 914, 100);
			_titleLbl.allCaps = true;
			_titleLbl.constrictTextToSize = false;
			_titleLbl.multiline = false;
			_titleLbl.align = TextFormatAlign.CENTER;
			_titleLbl.letterSpacing = 1.5;
			_titleLbl.y = 54;

			if (!_isPlayerInCombat)
				_titleLbl.text = _watchText;
			else if (_isPlayerVictor)
				_titleLbl.text = _victoryText;
			else if (totalVictors == 0)
				_titleLbl.text = _drawText;
			else
			{
				_titleLbl.textColor = 0xF58993;
				_titleLbl.text = _defeatText;
			}

			if (totalVictors > 0)
			{
				_victorsHeading = new Label(22, 0xffdd3d, 130, 33);
				_victorsHeading.x = 11;
				_victorsHeading.y = 125;
				_victorsHeading.align = TextFormatAlign.CENTER;
				_victorsHeading.text = _victorText;

				_losersHeading = new Label(22, 0xfe4f4f, 130, 33);
				_losersHeading.x = 769;
				_losersHeading.y = 125;
				_losersHeading.align = TextFormatAlign.CENTER;
				_losersHeading.text = _defeatedText;
			}

			_lootBg = UIFactory.getScaleBitmap(PanelEnum.CONTAINER_NOTCHED);
			_lootBg.width = 362;
			_lootBg.height = 123;
			_lootBg.x = 7;
			_lootBg.y = 324;

			_lootHolder = new Sprite();
			_lootHolder.x = 13;
			_lootHolder.y = 335;

			_lootedCreditsSymbol = UIFactory.getBitmap('LootedResourceCreditsBMD');

			_lootedEnergySymbol = UIFactory.getBitmap('LootedResourceEnergyBMD');
			_lootedEnergySymbol.x = _lootedCreditsSymbol.x + 179;
			_lootedEnergySymbol.y = _lootedCreditsSymbol.y;

			_lootedAlloySymbol = UIFactory.getBitmap('LootedResourceAlloyBMD');
			_lootedAlloySymbol.x = _lootedCreditsSymbol.x;
			_lootedAlloySymbol.y = _lootedCreditsSymbol.y + 50;

			_lootedSyntheticsSymbol = UIFactory.getBitmap('LootedResourceSyntheticsBMD');
			_lootedSyntheticsSymbol.x = _lootedEnergySymbol.x;
			_lootedSyntheticsSymbol.y = _lootedCreditsSymbol.y + 50;

			var textColor:uint                     = (_isPlayerVictor) ? 0x7afe60 : 0xf04c4c;

			_lootedCreditsLbl = new Label(13, 0xf0f0f0, 140, 20, true, 1);
			_lootedCreditsLbl.textColor = textColor;
			_lootedCreditsLbl.x = _lootedCreditsSymbol.width * 0.5 + _lootedCreditsSymbol.x - 35;
			_lootedCreditsLbl.y = _lootedCreditsSymbol.height * 0.5 + _lootedCreditsSymbol.y - 4;
			_lootedCreditsLbl.constrictTextToSize = false;
			_lootedCreditsLbl.align = TextFormatAlign.LEFT;
			_lootedCreditsLbl.letterSpacing = 1.5;

			_lootedEnergyLbl = new Label(13, 0xf0f0f0, 140, 30, true, 1);
			_lootedEnergyLbl.textColor = textColor;
			_lootedEnergyLbl.x = _lootedEnergySymbol.width * 0.5 + _lootedEnergySymbol.x - 35;
			_lootedEnergyLbl.y = _lootedEnergySymbol.height * 0.5 + _lootedEnergySymbol.y - 4;
			_lootedEnergyLbl.constrictTextToSize = false;
			_lootedEnergyLbl.align = TextFormatAlign.LEFT;
			_lootedEnergyLbl.letterSpacing = 1.5;


			_lootedAlloyLbl = new Label(13, 0xf0f0f0, 140, 30, true, 1);
			_lootedAlloyLbl.textColor = textColor;
			_lootedAlloyLbl.x = _lootedAlloySymbol.width * 0.5 + _lootedAlloySymbol.x - 35;
			_lootedAlloyLbl.y = _lootedAlloySymbol.height * 0.5 + _lootedAlloySymbol.y - 4;
			_lootedAlloyLbl.constrictTextToSize = false;
			_lootedAlloyLbl.align = TextFormatAlign.LEFT;
			_lootedAlloyLbl.letterSpacing = 1.5;

			_lootedSyntheticsLbl = new Label(13, 0xf0f0f0, 140, 30, true, 1);
			_lootedSyntheticsLbl.textColor = textColor;
			_lootedSyntheticsLbl.x = _lootedSyntheticsSymbol.width * 0.5 + _lootedSyntheticsSymbol.x - 35;
			_lootedSyntheticsLbl.y = _lootedSyntheticsSymbol.height * 0.5 + _lootedSyntheticsSymbol.y - 4;
			_lootedSyntheticsLbl.constrictTextToSize = false;
			_lootedSyntheticsLbl.align = TextFormatAlign.LEFT;
			_lootedSyntheticsLbl.letterSpacing = 1.5;

			_lootedCreditsLbl.text = StringUtil.commaFormatNumber(_lootedCreditsAmount);

			if (_isPlayerVictor && _cargoFull)
			{
				_lootedEnergyLbl.setTextWithTokens(_cargoFullString, {'[[Number.AmountLooted]]':StringUtil.commaFormatNumber(_lootedEnergyAmount)});
				_lootedAlloyLbl.setTextWithTokens(_cargoFullString, {'[[Number.AmountLooted]]':StringUtil.commaFormatNumber(_lootedAlloyAmount)});
				_lootedSyntheticsLbl.setTextWithTokens(_cargoFullString, {'[[Number.AmountLooted]]':StringUtil.commaFormatNumber(_lootedSyntheticsAmount)});
			} else
			{
				_lootedEnergyLbl.text = StringUtil.commaFormatNumber(_lootedEnergyAmount);
				_lootedAlloyLbl.text = StringUtil.commaFormatNumber(_lootedAlloyAmount);
				_lootedSyntheticsLbl.text = StringUtil.commaFormatNumber(_lootedSyntheticsAmount);
			}

			_beCDialogueLbl = new Label(21, 0x7ca5fd, 579, 60, true);
			_beCDialogueLbl.align = TextFormatAlign.LEFT;

			_okBtn = UIFactory.getButton(ButtonEnum.BLUE_A, 140, 40, 760, 461, _okBtnText);
			addListener(_okBtn, MouseEvent.CLICK, exitCombat);

			var debugFB:Boolean                    = false;
			if (debugFB ||
				(Application.NETWORK == Application.NETWORK_FACEBOOK &&
				!presenter.isPVEBattle &&
				_isPlayerInCombat &&
				_isPlayerVictor))
			{
				_shareButton = UIFactory.getButton(ButtonEnum.BLUE_A, 140, 40, 600, 461, _shareBtnText);
				addListener(_shareButton, MouseEvent.CLICK, onClickShare);
			}

			_headingBG = UIFactory.getScaleBitmap(PanelEnum.CONTAINER_INNER);
			_headingBG.width = (greaterThenTwoParticipants) ? 918 : 898;
			_headingBG.height = 102;
			_headingBG.x = 7;
			_headingBG.y = 48;

			_participantsBG = UIFactory.getScaleBitmap(PanelEnum.CONTAINER_INNER);
			_participantsBG.width = 898;
			_participantsBG.height = 164;
			_participantsBG.x = 7;
			_participantsBG.y = 154;

			_beCDialogueBG = UIFactory.getScaleBitmap(PanelEnum.CONTAINER_INNER);
			_beCDialogueBG.width = 582;
			_beCDialogueBG.height = 37;
			_beCDialogueBG.x = 7;
			_beCDialogueBG.y = 465;

			var participants:Vector.<PlayerVO>     = new Vector.<PlayerVO>;
			var len:uint                           = _participants.length;
			var i:uint;
			for (; i < len; ++i)
			{
				participants.push(presenter.getPlayer(_participants[i]));
			}

			_participantHolder = new Sprite();
			_participantHolder.x = 6;
			_participantHolder.y = 154;

			var currentBattlEndParticipantDisplay:BattleEndParticipantDisplay;
			var currentPlayer:PlayerVO;
			var isVictor:Boolean;
			var victorCount:uint;
			var defeatedCount:uint;
			len = participants.length;
			for (i = 0; i < len; ++i)
			{
				currentPlayer = participants[i];
				isVictor = (totalVictors > 0) ? currentPlayer.id in _victors : (i % 2 == 0);
				currentBattlEndParticipantDisplay = new BattleEndParticipantDisplay(currentPlayer, presenter.getParticipantRating(currentPlayer.id), isVictor);
				currentBattlEndParticipantDisplay.setUp(presenter.getAssetVO, presenter.loadMediumImage, presenter.loadMiniIconFromEntityData, presenter.getBattleEntitiesByPlayer);
				currentBattlEndParticipantDisplay.x = (isVictor) ? 6 : 440;
				currentBattlEndParticipantDisplay.y = (isVictor) ? ((victorCount++ * (currentBattlEndParticipantDisplay.height + 14))) : ((defeatedCount++ * (currentBattlEndParticipantDisplay.
					height + 14)));
				_participantHolder.addChild(currentBattlEndParticipantDisplay);

				if (_maxHeight < currentBattlEndParticipantDisplay.y + currentBattlEndParticipantDisplay.height)
					_maxHeight = (currentBattlEndParticipantDisplay.y + currentBattlEndParticipantDisplay.height)

				if (_defeatedVO == null && !isVictor)
					_defeatedVO = currentPlayer;

				if (_victorVO == null && isVictor)
					_victorVO = currentPlayer;
			}

			_scrollRect = new Rectangle(_participantHolder.x, _participantHolder.y, _participantsBG.width, _participantsBG.height);
			_scrollRect.y = 0;
			_participantHolder.scrollRect = _scrollRect

			_scrollbar = new VScrollbar();
			var dragBarBGRect:Rectangle            = new Rectangle(0, 4, 5, 3);
			var scrollbarXPos:Number               = _participantsBG.x + _participantsBG.width + 5;
			var scrollbarYPos:Number               = _participantsBG.y;
			_scrollbar.init(7, _scrollRect.height, scrollbarXPos, scrollbarYPos, dragBarBGRect, '', 'ScrollBarBMD', '', false, this);
			_scrollbar.onScrollSignal.add(onChangedScroll);
			_scrollbar.updateScrollableHeight(_maxHeight);
			_scrollbar.updateDisplayedHeight(_scrollRect.height);
			_scrollbar.maxScroll = 123;

			_lootHolder.addChild(_lootedCreditsSymbol);
			_lootHolder.addChild(_lootedAlloySymbol);
			_lootHolder.addChild(_lootedSyntheticsSymbol);
			_lootHolder.addChild(_lootedEnergySymbol);
			_lootHolder.addChild(_lootedCreditsLbl);
			_lootHolder.addChild(_lootedAlloyLbl);
			_lootHolder.addChild(_lootedSyntheticsLbl);
			_lootHolder.addChild(_lootedEnergyLbl);

			addChild(_bg);
			addChild(_headingBG);
			addChild(_participantsBG);
			addChild(_beCDialogueBG);
			addChild(_titleLbl);
			addChild(_lootBg);
			addChild(_lootHolder);
			addChild(_beCDialogueLbl);
			addChild(_okBtn);
			addChild(_participantHolder);
			addChild(_scrollbar);

			showChanceComponent();

			if (_victorsHeading)
				addChild(_victorsHeading);

			if (_losersHeading)
				addChild(_losersHeading);

			if (_shareButton)
				addChild(_shareButton);

			addBattleEndDialogue();

			presenter.addRerollFromRerollCallback(onRerollUpdated);
			presenter.addRerollFromScanCallback(onRerollUpdated);

			addEffects();
			effectsIN();
		}

		private function showChanceComponent( brVO:BattleRerollVO = null ):void
		{

			if (!brVO)
				_chanceComponent.battleRerollVO = presenter.getAvailableRerollById(_battleID);
			else
				_chanceComponent.battleRerollVO = brVO;

			if (_blueprintProtoName)
			{
				var blueprintVO:IPrototype = presenter.getBlueprintPrototypeByName(_blueprintProtoName);
				var bpAsset:AssetVO = presenter.getAssetVO(blueprintVO);
				ExternalInterfaceAPI.shareBlueprintFind(blueprintVO);
				_blueprint = presenter.getBlueprintByName(_blueprintProtoName);

				_chanceComponent.loadIconSignal.add(loadBPIcon);
				if (_blueprint)
					_blueprintCost = presenter.getBlueprintHardCurrencyCost(_blueprint, _blueprint.partsRemaining);

				_chanceComponent.init(_blueprint);
				_chanceComponent.rollCost = presenter.getConstantPrototypeValueByName('rerollItemPrice');

				_chanceComponent.showBlueprint(_blueprintProtoName, null, bpAsset, _blueprintCost);

				_tooltips.addTooltip(_chanceComponent.blueprintShipIcon, _chanceComponent, _chanceComponent.getTooltip);

				addChild(_chanceComponent);

			} else if (_isPlayerVictor && _chanceComponent.battleRerollVO)
			{
				_chanceComponent.scanCost = presenter.getConstantPrototypeValueByName('rerollLootPrice');
				_chanceComponent.showScanView();
				addChild(_chanceComponent);
			} else
			{
				_unavailableRerollBG = UIFactory.getScaleBitmap(PanelEnum.CONTAINER_NOTCHED);
				_unavailableRerollBG.width = 449;
				_unavailableRerollBG.height = 123;
				_unavailableRerollBG.x = (_participantHolder.numChildren > 2) ? 476 : 456;
				_unavailableRerollBG.y = 324;

				_unavailableReroll = new Label(24, 0xffdd3d, _unavailableRerollBG.width, _unavailableRerollBG.height);
				_unavailableReroll.align = TextFormatAlign.CENTER;
				_unavailableReroll.multiline = true;
				_unavailableReroll.text = getUnavailableRerollString(presenter.getUnavailableReroll(_battleID));
				_unavailableReroll.x = _unavailableRerollBG.x;
				_unavailableReroll.y = _unavailableRerollBG.y + (_unavailableRerollBG.height - _unavailableReroll.textHeight) * 0.5;

				addChild(_unavailableRerollBG);
				addChild(_unavailableReroll);
			}
		}

		public function onRerollUpdated( rerollVO:BattleRerollVO ):void
		{
			if (rerollVO.blueprintPrototype != '')
			{
				_blueprintProtoName = rerollVO.blueprintPrototype;
				_chanceComponent.hideBlueprint();
				showChanceComponent(rerollVO);
			} else
				_chanceComponent.showGainedResourcesView(rerollVO);
		}

		private function onChangedScroll( percent:Number ):void
		{
			if (_scrollRect)
				_scrollRect.y = (_maxHeight - _scrollRect.height) * percent;

			if (_participantHolder)
				_participantHolder.scrollRect = _scrollRect;
		}

		private function loadBPIcon( imageName:String, callback:Function ):void
		{
			if (presenter)
				presenter.loadIcon(imageName, callback);
		}

		protected function exitCombat( e:MouseEvent ):void
		{
			presenter.exitCombat();
			destroy();
		}

		private function addBattleEndDialogue():void
		{
			var dialogueOptions:Vector.<IPrototype> = new Vector.<IPrototype>;
			if (_isPlayerInCombat)
			{
				if (_isPlayerVictor && _victorVO)
					dialogueOptions = presenter.getBEDialogueByFaction(_victorVO.faction);
				else
				{
					if (_victorVO)
						dialogueOptions = presenter.getBEDialogueByFaction(_victorVO.faction, 'Taunt');
					else
					{
						if (_defeatedVO)
							dialogueOptions = presenter.getBEDialogueByFaction(_defeatedVO.faction, 'Taunt');
					}
				}

			} else
			{
				if (_victorVO && CurrentUser)
					dialogueOptions = presenter.getBEDialogueByFaction(_victorVO.faction, (_victorVO.faction == CurrentUser.faction) ? 'Victory' : 'Taunt');
				else
				{
					if (_defeatedVO)
						dialogueOptions = presenter.getBEDialogueByFaction(_defeatedVO.faction, 'Taunt');
				}
			}
			
			if(dialogueOptions.length>0)
			{
				_beCDialogueLbl.text = dialogueOptions[Math.floor(CommonFunctionUtil.randomMinMax(0, (dialogueOptions.length - 1)))].getValue('dialogString');
				
			}
			else
			{
				_beCDialogueLbl.text = "";
				_soundToPlay = "";
			}
			
			_beCDialogueLbl.x = _beCDialogueBG.x + (_beCDialogueBG.width - _beCDialogueLbl.textWidth) * 0.5;
			_beCDialogueLbl.y = _beCDialogueBG.y + (_beCDialogueBG.height - _beCDialogueLbl.textHeight) * 0.5;
		}

		private function getUnavailableRerollString( v:int ):String
		{
			switch (v)
			{
				case UnavailableRerollEnum.NO_CHALLENGE:
					return _NoChallenge;
				case UnavailableRerollEnum.FARM_PENALTY:
					return _FarmPenalty;
				case UnavailableRerollEnum.DAMAGE_REQ:
					return _DamageReq;
				case UnavailableRerollEnum.ALL_COMPLETE:
					return _AllComplete;
				case UnavailableRerollEnum.SLOTS_FULL:
					return _SlotsFull;
				case UnavailableRerollEnum.NONE_IN_BAND:
					return _NoneInBand;
				case UnavailableRerollEnum.MISSING_TECH:
					return _MissingTech;
				case UnavailableRerollEnum.BAD_ENCOUNTER:
					return _BadEncounter;
				case UnavailableRerollEnum.BAD_FACTION:
					return _BadFaction;
				case UnavailableRerollEnum.NONE_AT_RARITY:
					return _NoneAtRarity;

			}

			return '';
		}

		private function getSelectionInfo( prototype:IPrototype, info:Function ):*
		{
			var selectionInfo:*;
			if (prototype)
			{
				var reqBuildClass:String = prototype.getUnsafeValue('requiredBuildingClass');
				if (reqBuildClass)
				{
					var proto:IPrototype;
					if (reqBuildClass == 'ShipDesignFacility')
					{
						proto = presenter.getShipPrototype(prototype.getValue('referenceName'));
						if (proto)
						{
							selectionInfo = info(proto.getValue('type'), proto);
						} else
						{
							proto = presenter.getShipPrototype(prototype.getValue('referenceName'));
							if (proto)
								selectionInfo = info(proto.getValue('type'), proto);
						}

					} else if (reqBuildClass == 'CommandCenter')
					{
						selectionInfo = info(prototype.getValue('type'), prototype);
					} else if (reqBuildClass == 'WeaponsDesignFacility')
					{
						proto = presenter.getModulePrototypeByName(prototype.getValue('referenceName'));
						selectionInfo = info(proto.getValue('type'), proto);
					} else
					{
						proto = presenter.getModulePrototypeByName(prototype.getValue('referenceName'));
						selectionInfo = info(proto.getValue('type'), proto);
					}
				} else
					selectionInfo = info(prototype.getValue('type'), prototype);
			}

			return selectionInfo;
		}

		private function onClickShare( e:MouseEvent ):void
		{
			presenter.sharePvPVictory();
		}

		private function onBlueprintPurchase( blueprintID:String, battleID:String ):void
		{
			var vo:BlueprintVO = presenter.getBlueprintByID(blueprintID);
			presenter.purchaseBlueprint(vo, vo.partsRemaining);
			presenter.removeRerollFromAvailable(battleID);
		}

		private function onRerollClick( battleID:String, name:String ):void
		{
			presenter.removeBlueprintByName(name);
			presenter.purchaseReroll(battleID);
		}

		private function onScanClick( battleID:String ):void
		{
			presenter.purchaseDeepScan(battleID);
		}

		private function onDenyClick( battleID:String ):void
		{
			presenter.removeRerollFromAvailable(battleID);
		}

		public function get lootHolder():Sprite  { return _lootHolder; }
		public function set battleID( v:String ):void  { _battleID = v; }
		public function set victors( v:Dictionary ):void  { _victors = v; }
		public function set lootedAlloyAmount( v:Number ):void  { _lootedAlloyAmount = v; }
		public function set lootedCreditsAmount( v:Number ):void  { _lootedCreditsAmount = v; }
		public function set lootedEnergyAmount( v:Number ):void  { _lootedEnergyAmount = v; }
		public function set lootedSyntheticsAmount( v:Number ):void  { _lootedSyntheticsAmount = v; }
		public function set cargoFull( v:Boolean ):void  { _cargoFull = v; }
		public function set blueprintProtoName( v:String ):void  { _blueprintProtoName = v; }

		override public function get height():Number  { return _bg.height; }
		override public function get width():Number  { return _bg.width; }
		
		[Inject]
		public function set presenter( value:IBattlePresenter ):void  { _presenter = value; }
		public function get presenter():IBattlePresenter  { return IBattlePresenter(_presenter); }
		[Inject]
		public function set tooltips( value:Tooltips ):void  { _tooltips = value; }

		override public function destroy():void
		{
			presenter.removeCleanupListener(destroy);
			presenter.removeRerollFromRerollCallback(onRerollUpdated);
			presenter.removeRerollFromScanCallback(onRerollUpdated);
			super.destroy();

			if (_tooltips)
				_tooltips.removeTooltip(null, this);

			_tooltips = null;

			if (_bg)
			{
				removeListener(_bg.closeButton, MouseEvent.CLICK, exitCombat);
				ObjectPool.give(_bg);
			}

			_bg = null;

			if (_okBtn)
			{
				removeListener(_okBtn, MouseEvent.CLICK, exitCombat);
				_okBtn.destroy();
			}

			_okBtn = null;


			if (_shareButton)
			{
				removeListener(_shareButton, MouseEvent.CLICK, onClickShare);
				_shareButton.destroy();
			}

			_shareButton = null;

			_defeatedVO = null;
			_victorVO = null;

			if (_scrollbar)
				_scrollbar.destroy();

			_scrollbar = null;

			if (_titleLbl)
				_titleLbl.destroy();

			_titleLbl = null;

			if (_lootedAlloyLbl)
				_lootedAlloyLbl.destroy();

			_lootedAlloyLbl = null;

			if (_lootedCreditsLbl)
				_lootedCreditsLbl.destroy();

			_lootedCreditsLbl = null;

			if (_lootedEnergyLbl)
				_lootedEnergyLbl.destroy();

			_lootedEnergyLbl = null;

			if (_lootedSyntheticsLbl)
				_lootedSyntheticsLbl.destroy();

			_lootedSyntheticsLbl = null;

			if (_beCDialogueLbl)
				_beCDialogueLbl.destroy();

			_beCDialogueLbl = null;

			if (_victorsHeading)
				_victorsHeading.destroy();

			_victorsHeading = null;

			if (_losersHeading)
				_losersHeading.destroy();

			_losersHeading = null;

			if (_unavailableReroll)
				_unavailableReroll.destroy();

			_unavailableReroll = null;

			if (_chanceComponent)
				_chanceComponent.destroy();

			_chanceComponent = null;

			var len:uint = _participantHolder.numChildren;
			var currentParticipant:BattleEndParticipantDisplay;
			for (var i:uint = 0; i < len; ++i)
			{
				currentParticipant = BattleEndParticipantDisplay(_participantHolder.getChildAt(i));
				currentParticipant.destroy();
			}
			_participantHolder = null;

			_lootHolder = null;
			_scrollRect = null;

			_lootedAlloySymbol = null;
			_lootedCreditsSymbol = null;
			_lootedEnergySymbol = null;
			_lootedSyntheticsSymbol = null;

			_headingBG = null;
			_participantsBG = null;
			_beCDialogueBG = null;
			_lootBg = null;
			_unavailableRerollBG = null;
		}
	}
}
