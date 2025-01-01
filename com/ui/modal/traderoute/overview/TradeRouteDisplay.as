package com.ui.modal.traderoute.overview
{
	import com.model.asset.AssetVO;
	import com.model.prototype.IPrototype;
	import com.model.starbase.TradeRouteVO;
	import com.model.transaction.TransactionVO;
	import com.presenter.IImperiumPresenter;
	import com.presenter.starbase.ITradePresenter;
	import com.ui.core.component.bar.ProgressBar;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;
	import com.ui.core.component.misc.ImageComponent;
	import com.ui.modal.ButtonFactory;
	import com.util.CommonFunctionUtil;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	import flash.utils.Timer;
	import flash.utils.getDefinitionByName;
	
	import org.adobe.utils.StringUtil;
	import org.osflash.signals.Signal;
	import org.shared.ObjectPool;

	public class TradeRouteDisplay extends Sprite
	{
		private var _presenter:IImperiumPresenter;
		
		public static var TRADE_ROUTE_IN_PROGRESS_STATE:int = 0;
		public static var SELECT_A_CORP_STATE:int           = 1;
		public static var LOCKED_STATE:int                  = 2;
		public static var CONTRACT_STATE:int                = 3;

		private var _bg:Bitmap;
		private var _lockedIcon:Bitmap;
		private var _dropBarBG:Bitmap;

		private var _creditsSymbol:Bitmap;
		private var _alloySymbol:Bitmap;
		private var _energySymbol:Bitmap;
		private var _syntheticsSymbol:Bitmap;
		private var _repSymbol:Bitmap;

		private var _selectCorpHeadding:Label;

		private var _lockedText:Label;
		private var _lockedReasonText:Label;

		private var _agentText:Label;

		private var _durationLabel:Label;
		private var _duration:Label;

		private var _frequencyLabel:Label;
		private var _frequency:Label;

		private var _creditGain:Label;
		private var _energyGain:Label;
		private var _alloyGain:Label;
		private var _syntheicGain:Label;
		private var _repGain:Label;

		private var _frequencyMS:int;

		private var _timeTillDrop:Label;
		private var _timeTillDropLabel:Label;

		private var _contractBtn:BitmapButton;

		private var _acceptContractBtn:BitmapButton;
		private var _declineContractBtn:BitmapButton;
		private var _infoBtn:BitmapButton;

		private var _cancelContractBtn:BitmapButton;

		private var _baseIncome:uint;
		private var _baseCredit:uint;
		private var _timeRemaining:int;
		private var _timeRemainingUntilDrop:int;
		private var _lockedCount:uint;
		private var _tradeRouteScalar:Number

		private var _currentState:int;

		private var _timer:Timer;

		private var _corpImage:ImageComponent;
		private var _agentImage:ImageComponent;

		private var _dropBar:ProgressBar;

		private var _selectBtns:Vector.<BitmapButton>;
		private var _selectableCorps:Vector.<TradeRouteVO>;

		public var getUIIcon:Function;
		public var getUIDescription:Function;
		public var getConstantPrototype:Function;
		public var getBalancedContractFromFaction:Function;
		public var getAgent:Function;
		public var getAgentDialogByGroup:Function;
		public var hasAgentGreetingBeenViewed:Function;
		public var showAgentGreeting:Function;
		public var showCorporationInfo:Function;
		public var getTradeRouteTransaction:Function;
		public var cancelContract:Function;

		private var _tradeRouteInProgress:TradeRouteVO;
		private var _tradeRouteInProgressTransaction:TransactionVO;

		private var _contractStateSelectedTradeRoute:TradeRouteVO;
		private var _contractStateSelectedContractType:IPrototype;

		private var _durationText:String                    = 'CodeString.TradeRouteDisplay.Duration'; //Duration:
		private var _frequencyText:String                   = 'CodeString.TradeRouteDisplay.Frequency'; //Frequency:
		private var _efficiencyString:String                = 'CodeString.TradeRouteDisplay.Efficiency'; //Efficiency:
		private var _contractBtnText:String                 = 'CodeString.TradeRouteDisplay.ContractBtn'; //CONTRACT
		private var _SelectCorpText:String                  = 'CodeString.TradeRouteDisplay.SelectCorp'; //Select a corporation to do business with.
		private var _perDropText:String                     = 'CodeString.TradeRouteDisplay.PerDrop'; //[[Number.ValuePerDrop]]/Drop
		private var _perMinText:String                      = 'CodeString.Shared.Time.Minutes'; // [[Number.Minutes]] m
		private var _cancelText:String                      = 'CodeString.Shared.CancelBtn'; //Cancel
		private var _accept:String                          = 'CodeString.Shared.Accept'; //ACCEPT
		private var _decline:String                         = 'CodeString.Shared.Decline'; //DECLINE
		private var _locked:String                          = 'CodeString.TradeRouteDisplay.Locked'; //Trade Route is locked.
		private var _lockedReason:String                    = 'CodeString.TradeRouteDisplay.LockedReason'; // Upgrade your Communications Center to level 4 to gain an additional contract.
		private var _lockedReasonMax:String                 = 'CodeString.TradeRouteDisplay.LockedReasonMax'; // Upgrade your Communications Center to level 7 to gain an additional contract.
		private var _nextDrop:String                        = 'CodeString.TradeRouteDisplay.NextDrop'; //Next Drop:

		public var onTradeCorporationSelected:Signal;
		public var onContractAccepted:Signal;

		public function TradeRouteDisplay()
		{
			super();
			_currentState = -1;

			_bg = new Bitmap;
			onTradeCorporationSelected = new Signal(TradeRouteVO);
			onContractAccepted = new Signal(TradeRouteVO, IPrototype);

			addChild(_bg);
		}

		public function addTradeRouteInProgress( tradeRoute:TradeRouteVO ):void
		{
			_tradeRouteInProgress = tradeRoute;
			setState(TRADE_ROUTE_IN_PROGRESS_STATE);
		}

		public function setSelectableCorporations( corps:Vector.<TradeRouteVO> ):void
		{
			_selectableCorps = corps;
			var currentlyViewingAnAlreadyAcceptedContract:Boolean;
			if (_contractStateSelectedTradeRoute != null && _currentState == CONTRACT_STATE)
			{
				var len:uint = corps.length;
				for (var i:uint = 0; i < len; ++i)
				{
					if (corps[i].contractGroup == _contractStateSelectedTradeRoute.contractGroup)
						currentlyViewingAnAlreadyAcceptedContract = true;
				}
			}

			if (!currentlyViewingAnAlreadyAcceptedContract)
				setState(SELECT_A_CORP_STATE);
		}

		public function setLocked( lockedCount:uint ):void
		{
			_lockedCount = lockedCount;
			setState(LOCKED_STATE);
		}

		private function setState( state:int ):void
		{
			var playSound:Boolean = false;
			if(_currentState!= state)
				playSound = true;
			
			clearUpCurrentState();
			_currentState = state;
			switch (_currentState)
			{
				case TRADE_ROUTE_IN_PROGRESS_STATE:
					setUpInProgress(playSound);
					break;
				case SELECT_A_CORP_STATE:
					setUpSelectACorp();
					break;
				case LOCKED_STATE:
					setUpLocked();
					break;
				case CONTRACT_STATE:
					setUpContractState(playSound);
					break;
			}

			layout();
		}

		private function setUpLocked():void
		{
			var fullBGClass:Class   = Class(getDefinitionByName('TradeRouteBlankWindowBMD'));
			var lockIconClass:Class = Class(getDefinitionByName('TradeRouteLockedIconBMD'));

			_bg.bitmapData = BitmapData(new fullBGClass());
			_lockedIcon = new Bitmap(BitmapData(new lockIconClass()));
			addChild(_lockedIcon);

			_lockedText = new Label(22, 0xFFFFFF, _bg.width, 48);
			_lockedText.align = TextFormatAlign.CENTER;
			_lockedText.multiline = true;
			_lockedText.constrictTextToSize = false;
			_lockedText.text = _locked;

			_lockedReasonText = new Label(22, 0xFFFFFF, _bg.width, 80);
			_lockedReasonText.align = TextFormatAlign.CENTER;
			_lockedReasonText.multiline = true;
			_lockedReasonText.constrictTextToSize = false;

			if (_lockedCount == 2)
				_lockedReasonText.text = _lockedReason;
			else
				_lockedReasonText.text = _lockedReasonMax;

			addChild(_lockedText);
			addChild(_lockedReasonText);
		}

		private function setUpSelectACorp():void
		{
			var fullBGClass:Class = Class(getDefinitionByName('TradeRouteBlankWindowBMD'));

			_selectBtns = new Vector.<BitmapButton>;
			_bg.bitmapData = BitmapData(new fullBGClass());
			var selectables:uint  = _selectableCorps.length;
			var newBtn:TradeRouteCorpBtn;
			for (var i:uint = 0; i < selectables; ++i)
			{
				newBtn = new TradeRouteCorpBtn();
				newBtn.tradeRoute = _selectableCorps[i];
				getUIIcon('mediumImage', _selectableCorps[i].factionPrototype, newBtn.onLoadImage);
				newBtn.addEventListener(MouseEvent.CLICK, onOpenContractClicked, false, 0, true);
				newBtn.showInfoSignal.add(showCorpInfo);
				_selectBtns.push(newBtn);
				addChild(newBtn);
			}

			_selectCorpHeadding = new Label(22, 0xFFFFFF, _bg.width, 26);
			_selectCorpHeadding.align = TextFormatAlign.CENTER;
			_selectCorpHeadding.multiline = true;
			_selectCorpHeadding.constrictTextToSize = false;
			_selectCorpHeadding.text = _SelectCorpText;
			addChild(_selectCorpHeadding);
		}

		private function setUpInProgress(playSound:Boolean):void
		{
			var splitBG:Class                   = Class(getDefinitionByName('TradeRouteCorpBGBMD'));
			var creditsSymbolClass:Class        = Class(getDefinitionByName(('TradeRouteCreditsBMD')));
			var alloySymbolClass:Class          = Class(getDefinitionByName(('TradeRouteAlloyBMD')));
			var energySymbolClass:Class         = Class(getDefinitionByName(('TradeRouteEnergyBMD')));
			var syntheticsSymbolClass:Class     = Class(getDefinitionByName(('TradeRouteSyntheticsBMD')));
			var reputationSymbolClass:Class     = Class(getDefinitionByName(('TradeRouteReputationBMD')));
			var dropBarBGClass:Class            = Class(getDefinitionByName(('TradeRouteDropContainerBMD')));

			_frequencyMS = (_tradeRouteInProgress.frequency * 60 * 1000);

			_bg.bitmapData = BitmapData(new splitBG());

			_corpImage = ObjectPool.get(ImageComponent);
			_corpImage.init(2000, 2000);

			_agentImage = ObjectPool.get(ImageComponent);
			_agentImage.init(2000, 2000);

			_dropBarBG = new Bitmap(BitmapData(new dropBarBGClass()));

			_dropBar = new ProgressBar();
			_dropBar.init(ProgressBar.HORIZONTAL, new Bitmap(new BitmapData(_dropBarBG.width - 6, _dropBarBG.height - 8, true, 0xff4f82b4)), null, 0.01);
			_dropBar.setMinMax(0, 1);

			_infoBtn = ButtonFactory.getBitmapButton('TradeRouteInfoBtnNeutralBMD', _bg.width - 30, 5, '', 0xFFFFFF, 'TradeRouteInfoBtnRollOverBMD', 'TradeRouteInfoBtnDownBMD');
			_infoBtn.addEventListener(MouseEvent.CLICK, onInfoBtnClicked, false, 0, true);

			_cancelContractBtn = ButtonFactory.getBitmapButton('CancelBtnNeutralBMD', 89, 407, _cancelText, 0xfd767d, 'CancelBtnRollOverBMD', 'CancelBtnDownBMD');
			_cancelContractBtn.addEventListener(MouseEvent.CLICK, onCancelContractClicked, false, 0, true);

			_agentText = new Label(10, 0xFFFFFF, 205, 77, true, 1);
			_agentText.align = TextFormatAlign.LEFT;
			_agentText.multiline = true;
			_agentText.constrictTextToSize = false;

			_durationLabel = new Label(18, 0xa9dcff);
			_durationLabel.autoSize = TextFieldAutoSize.LEFT;
			_durationLabel.constrictTextToSize = false;
			_durationLabel.text = _durationText;

			_duration = new Label(18, 0xFFFFFF);
			_duration.autoSize = TextFieldAutoSize.LEFT;
			_duration.constrictTextToSize = false;
			_duration.useLocalization = false;

			_frequencyLabel = new Label(18, 0xa9dcff);
			_frequencyLabel.autoSize = TextFieldAutoSize.LEFT;

			_frequencyLabel.constrictTextToSize = false;
			_frequencyLabel.text = _frequencyText

			_frequency = new Label(18, 0xFFFFFF);
			_frequency.autoSize = TextFieldAutoSize.LEFT;
			_frequency.constrictTextToSize = false;
			_frequency.setTextWithTokens(_perMinText, {'[[Number.Minutes]]':_tradeRouteInProgress.frequency});

			_creditsSymbol = new Bitmap(BitmapData(new creditsSymbolClass()));

			_alloySymbol = new Bitmap(BitmapData(new alloySymbolClass()));

			_repSymbol = new Bitmap(BitmapData(new reputationSymbolClass()));
			_repSymbol.visible = false;

			_energySymbol = new Bitmap(BitmapData(new energySymbolClass()));

			_syntheticsSymbol = new Bitmap(BitmapData(new syntheticsSymbolClass()));

			_creditGain = new Label(18, 0xa9dcff);
			_creditGain.autoSize = TextFieldAutoSize.LEFT;
			_creditGain.constrictTextToSize = false;

			_alloyGain = new Label(18, 0xa9dcff);
			_alloyGain.autoSize = TextFieldAutoSize.LEFT;
			_alloyGain.constrictTextToSize = false;

			_repGain = new Label(18, 0xa9dcff);
			_repGain.autoSize = TextFieldAutoSize.LEFT;
			_repGain.constrictTextToSize = false;

			_energyGain = new Label(18, 0xa9dcff);
			_energyGain.autoSize = TextFieldAutoSize.LEFT;
			_energyGain.constrictTextToSize = false;

			_syntheicGain = new Label(18, 0xa9dcff);
			_syntheicGain.autoSize = TextFieldAutoSize.LEFT;
			_syntheicGain.constrictTextToSize = false;

			_timeTillDrop = new Label(18, 0xcbeeff, 174, 18, false);
			_timeTillDrop.align = TextFormatAlign.CENTER;
			_timeTillDrop.constrictTextToSize = false;

			_timeTillDropLabel = new Label(18, 0xffffff);
			_timeTillDropLabel.autoSize = TextFieldAutoSize.LEFT;
			_timeTillDropLabel.constrictTextToSize = false;

			_timeTillDropLabel.text = _nextDrop;

			var frequency:Number                = _tradeRouteInProgress.frequency / 60.0;
			var resourceGain:Number             = (_baseCredit * _tradeRouteInProgress.creditScale) * _tradeRouteScalar;
			var productivity:Number             = _tradeRouteInProgress.productivity;
			var payout:Number                   = _tradeRouteInProgress.payout;

			var currentValue:Number             = Math.floor(((resourceGain * productivity) * (1 - payout)) * frequency);
			_creditGain.setTextWithTokens(_perDropText, {'[[Number.ValuePerDrop]]':StringUtil.commaFormatNumber(currentValue)});

			resourceGain = (_baseIncome * _tradeRouteInProgress.alloyScale) * _tradeRouteScalar;
			currentValue = Math.floor(((resourceGain * productivity) * (1 - payout)) * frequency);
			_alloyGain.setTextWithTokens(_perDropText, {'[[Number.ValuePerDrop]]':StringUtil.commaFormatNumber(currentValue)});

			resourceGain = (_baseIncome * _tradeRouteInProgress.energyScale) * _tradeRouteScalar;
			currentValue = Math.floor(((resourceGain * productivity) * (1 - payout)) * frequency);
			_energyGain.setTextWithTokens(_perDropText, {'[[Number.ValuePerDrop]]':StringUtil.commaFormatNumber(currentValue)});

			resourceGain = (_baseIncome * _tradeRouteInProgress.syntheticScale) * _tradeRouteScalar;
			currentValue = Math.floor(((resourceGain * productivity) * (1 - payout)) * frequency);
			_syntheicGain.setTextWithTokens(_perDropText, {'[[Number.ValuePerDrop]]':StringUtil.commaFormatNumber(currentValue)});

			// TODO - this should be based off of "contractReputationIncome"
			resourceGain = (_baseIncome * _tradeRouteInProgress.reputationScale) * _tradeRouteScalar;
			currentValue = Math.floor(((resourceGain * productivity) * (1 - payout)) * frequency);
			_repGain.setTextWithTokens(_perDropText, {'[[Number.ValuePerDrop]]':StringUtil.commaFormatNumber(currentValue)});
			_repGain.visible = false;

			addChild(_corpImage);
			addChild(_agentImage);

			addChild(_agentText);

			addChild(_cancelContractBtn);

			addChild(_dropBarBG);
			addChild(_dropBar);

			addChild(_infoBtn);

			addChild(_timeTillDrop);
			addChild(_timeTillDropLabel);

			addChild(_creditsSymbol);
			addChild(_alloySymbol);
			addChild(_repSymbol);
			addChild(_energySymbol);
			addChild(_syntheticsSymbol);

			addChild(_creditGain);
			addChild(_alloyGain);
			addChild(_energyGain);
			addChild(_syntheicGain);
			addChild(_repGain);

			addChild(_durationLabel);
			addChild(_duration);
			addChild(_frequencyLabel);
			addChild(_frequency);

			_tradeRouteInProgressTransaction = getTradeRouteTransaction(_tradeRouteInProgress.id);

			if (_tradeRouteInProgressTransaction != null)
				_timeRemaining = _tradeRouteInProgressTransaction.timeRemainingMS;

			_duration.setBuildTime(_timeRemaining / 1000);

			_timeRemainingUntilDrop = _timeRemaining % _frequencyMS;

			var agent:IPrototype                = getAgent(_tradeRouteInProgress.contractGroup, 1441);
			getUIIcon('smallImage', agent, _agentImage.onImageLoaded);

			var agentDialog:Vector.<IPrototype> = getAgentDialogByGroup(agent.getValue('idleGroup'));

			if (agentDialog.length > 0)
			{
				var index:int = Math.random() * (agentDialog.length - 1);
				_agentText.text = agentDialog[index].getValue('dialogString');
				
				if(playSound)
				{
					//todo uncomment when ready
					//var audioDir:String = agentDialog[index].getValue('dialogAudioString');
					//if(audioDir.length>0)
					//	presenter.playSound(audioDir, 0.75);
				}
			}

			_timer = new Timer(1000);
			_timer.addEventListener(TimerEvent.TIMER, onTimerTick, false, 0, true);
			_timer.start();
		}

		private function setUpContractState(playSound:Boolean):void
		{
			var splitBG:Class                   = Class(getDefinitionByName('TradeRouteCorpBGBMD'));
			var creditsSymbolClass:Class        = Class(getDefinitionByName(('TradeRouteCreditsBMD')));
			var alloySymbolClass:Class          = Class(getDefinitionByName(('TradeRouteAlloyBMD')));
			var energySymbolClass:Class         = Class(getDefinitionByName(('TradeRouteEnergyBMD')));
			var syntheticsSymbolClass:Class     = Class(getDefinitionByName(('TradeRouteSyntheticsBMD')));
			var reputationSymbolClass:Class     = Class(getDefinitionByName(('TradeRouteReputationBMD')));


			_bg.bitmapData = BitmapData(new splitBG());

			_corpImage = ObjectPool.get(ImageComponent);
			_corpImage.init(2000, 2000);

			_agentImage = ObjectPool.get(ImageComponent);
			_agentImage.init(2000, 2000);

			_acceptContractBtn = ButtonFactory.getBitmapButton('TradeRouteAcceptBtnNeutralBMD', 152, 404, _accept, 0xa7caf1, 'TradeRouteAcceptBtnRollOverBMD', 'TradeRouteAcceptBtnSelectedBMD');
			_acceptContractBtn.addEventListener(MouseEvent.CLICK, onAcceptContractClicked, false, 0, true);
			_acceptContractBtn.fontSize = 22;
			_acceptContractBtn.label.y += 3;
			_acceptContractBtn.label.x += 7;

			_declineContractBtn = ButtonFactory.getBitmapButton('TradeRouteDeclineBtnNeutralBMD', 6, 404, _decline, 0xfd767d, 'TradeRouteDeclineBtnRollOverBMD', 'TradeRouteDeclineBtnSelectedBMD');
			_declineContractBtn.addEventListener(MouseEvent.CLICK, onDeclineContractClicked, false, 0, true);
			_declineContractBtn.fontSize = 22;
			_declineContractBtn.label.y += 3;
			_declineContractBtn.label.x -= 8;

			_infoBtn = ButtonFactory.getBitmapButton('TradeRouteInfoBtnNeutralBMD', _bg.width - 30, 5, '', 0xFFFFFF, 'TradeRouteInfoBtnRollOverBMD', 'TradeRouteInfoBtnDownBMD');
			_infoBtn.addEventListener(MouseEvent.CLICK, onInfoBtnClicked, false, 0, true);

			_durationLabel = new Label(18, 0xa9dcff);
			_durationLabel.autoSize = TextFieldAutoSize.LEFT;
			_durationLabel.constrictTextToSize = false;
			_durationLabel.text = _durationText;

			_duration = new Label(18, 0xFFFFFF);
			_duration.autoSize = TextFieldAutoSize.LEFT;
			_duration.constrictTextToSize = false;
			_duration.useLocalization = false;

			_agentText = new Label(10, 0xFFFFFF, 205, 77, true, 1);
			_agentText.align = TextFormatAlign.JUSTIFY;
			_agentText.multiline = true;
			_agentText.constrictTextToSize = false;

			_frequencyLabel = new Label(18, 0xa9dcff);
			_frequencyLabel.autoSize = TextFieldAutoSize.LEFT;

			_frequencyLabel.constrictTextToSize = false;
			_frequencyLabel.text = _frequencyText

			_frequency = new Label(18, 0xFFFFFF);
			_frequency.autoSize = TextFieldAutoSize.LEFT;
			_frequency.constrictTextToSize = false;

			_creditsSymbol = new Bitmap(BitmapData(new creditsSymbolClass()));

			_alloySymbol = new Bitmap(BitmapData(new alloySymbolClass()));

			_repSymbol = new Bitmap(BitmapData(new reputationSymbolClass()));
			_repSymbol.visible = false;

			_energySymbol = new Bitmap(BitmapData(new energySymbolClass()));

			_syntheticsSymbol = new Bitmap(BitmapData(new syntheticsSymbolClass()));

			_creditGain = new Label(18, 0xa9dcff);
			_creditGain.autoSize = TextFieldAutoSize.LEFT;
			_creditGain.constrictTextToSize = false;

			_alloyGain = new Label(18, 0xa9dcff);
			_alloyGain.autoSize = TextFieldAutoSize.LEFT;
			_alloyGain.constrictTextToSize = false;

			_repGain = new Label(18, 0xa9dcff);
			_repGain.autoSize = TextFieldAutoSize.LEFT;
			_repGain.constrictTextToSize = false;

			_energyGain = new Label(18, 0xa9dcff);
			_energyGain.autoSize = TextFieldAutoSize.LEFT;
			_energyGain.constrictTextToSize = false;

			_syntheicGain = new Label(18, 0xa9dcff);
			_syntheicGain.autoSize = TextFieldAutoSize.LEFT;
			_syntheicGain.constrictTextToSize = false;

			addChild(_corpImage);
			addChild(_agentImage);

			addChild(_agentText);

			addChild(_acceptContractBtn);
			addChild(_declineContractBtn);
			addChild(_infoBtn);

			addChild(_creditsSymbol);
			addChild(_alloySymbol);
			addChild(_repSymbol);
			addChild(_energySymbol);
			addChild(_syntheticsSymbol);

			addChild(_creditGain);
			addChild(_alloyGain);
			addChild(_energyGain);
			addChild(_syntheicGain);
			addChild(_repGain);

			addChild(_durationLabel);
			addChild(_duration);
			addChild(_frequencyLabel);
			addChild(_frequency);

			var duration:Number                 = getConstantPrototype('contractDurationDefault');
			var frequency:Number                = getConstantPrototype('contractFrequencyDefault');

			var factionPrototype:IPrototype     = _contractStateSelectedTradeRoute.factionPrototype;
			_contractStateSelectedContractType = getBalancedContractFromFaction(_contractStateSelectedTradeRoute.factionPrototype.name);
			var creditScale:Number              = _contractStateSelectedContractType.getValue('creditScale');
			var alloyScale:Number               = _contractStateSelectedContractType.getValue('alloyScale');
			var energyScale:Number              = _contractStateSelectedContractType.getValue('energyScale');
			var syntheticScale:Number           = _contractStateSelectedContractType.getValue('syntheticsScale');
			var reputationScale:Number          = _contractStateSelectedContractType.getValue('reputationScale');

			var productivity:Number             = getConstantPrototype('contractProductivityDefault');
			var payout:Number                   = getConstantPrototype('contractPayoutDefault');
			var creditGain:Number               = (_baseCredit * creditScale) * _tradeRouteScalar;
			var alloyGain:Number                = (_baseIncome * alloyScale) * _tradeRouteScalar;
			var energyGain:Number               = (_baseIncome * energyScale) * _tradeRouteScalar;
			var synGain:Number                  = (_baseIncome * syntheticScale) * _tradeRouteScalar;
			var repGain:Number                  = (_baseIncome * reputationScale) * _tradeRouteScalar;
			var frequencyMult:Number            = frequency / 60.0;

			var currentValue:Number             = Math.floor(((creditGain * productivity) * (1 - payout)) * frequencyMult);
			_creditGain.setTextWithTokens(_perDropText, {'[[Number.ValuePerDrop]]':StringUtil.commaFormatNumber(currentValue)});

			currentValue = Math.floor(((alloyGain * productivity) * (1 - payout)) * frequencyMult);
			_alloyGain.setTextWithTokens(_perDropText, {'[[Number.ValuePerDrop]]':StringUtil.commaFormatNumber(currentValue)});

			currentValue = Math.floor(((energyGain * productivity) * (1 - payout)) * frequencyMult);
			_energyGain.setTextWithTokens(_perDropText, {'[[Number.ValuePerDrop]]':StringUtil.commaFormatNumber(currentValue)});

			currentValue = Math.floor(((synGain * productivity) * (1 - payout)) * frequencyMult);
			_syntheicGain.setTextWithTokens(_perDropText, {'[[Number.ValuePerDrop]]':StringUtil.commaFormatNumber(currentValue)});

			currentValue = Math.floor(((repGain * productivity) * (1 - payout)) * frequencyMult);
			_repGain.setTextWithTokens(_perDropText, {'[[Number.ValuePerDrop]]':StringUtil.commaFormatNumber(currentValue)});
			_repGain.visible = false;

			_frequency.setTextWithTokens(_perMinText, {'[[Number.Minutes]]':frequency});

			_duration.setBuildTime((duration * 60) * 60);

			getUIIcon('mediumImage', _contractStateSelectedTradeRoute.factionPrototype, onImageLoaded);

			var agent:IPrototype                = getAgent(_contractStateSelectedTradeRoute.contractGroup, 1441);
			getUIIcon('smallImage', agent, _agentImage.onImageLoaded);
			var agentDialog:Vector.<IPrototype> = getAgentDialogByGroup(agent.getValue('contractGroup'));

			if (agentDialog.length > 0)
			{
				_agentText.text = agentDialog[0].getValue('dialogString');
				
				if(playSound)
				{
					
					//todo uncomment when ready
					//var audioDir:String = agentDialog[0].getValue('dialogAudioString');
					//if(audioDir.length>0)
					//	presenter.playSound(audioDir, 0.75);
				}
			}

			if (!hasAgentGreetingBeenViewed(agent.getValue('id')))
				showAgentGreeting(agent);
		}

		private function onTimerTick( e:TimerEvent ):void
		{
			if (_tradeRouteInProgressTransaction == null)
				_tradeRouteInProgressTransaction = getTradeRouteTransaction(_tradeRouteInProgress.id);
			if (_tradeRouteInProgressTransaction != null && _tradeRouteInProgress != null)
			{
				_timeRemaining = _tradeRouteInProgressTransaction.timeRemainingMS;
				_timeRemainingUntilDrop = _timeRemaining % _frequencyMS;
			}

			_timeRemaining -= 1000;
			_timeRemainingUntilDrop -= 1000;

			if (_timeRemainingUntilDrop <= 0)
				_timeRemainingUntilDrop = _frequencyMS;

			if (_timeRemaining <= 0)
			{
				_timer.stop();
				_timeRemaining = 0;
				_timeRemainingUntilDrop = 0;
			}

			if (_duration)
				_duration.setBuildTime(_timeRemaining / 1000);

			if (_dropBar)
				_dropBar.amount = 1 - (_timeRemainingUntilDrop / _frequencyMS);

			if (_timeTillDrop)
				_timeTillDrop.setBuildTime(_timeRemainingUntilDrop / 1000);
		}

		private function cleanUpInProgress():void
		{
			if (_timer.running)
				_timer.stop();

			_timer.removeEventListener(TimerEvent.TIMER, onTimerTick);
			_timer = null;

			removeChild(_agentText);
			_agentText.destroy();
			_agentText = null;

			removeChild(_corpImage);
			_corpImage.clearBitmap();
			ObjectPool.give(_corpImage);
			_corpImage = null;

			removeChild(_agentImage);
			_agentImage.clearBitmap();
			ObjectPool.give(_agentImage);
			_agentImage = null;

			removeChild(_infoBtn);
			_infoBtn.removeEventListener(MouseEvent.CLICK, onInfoBtnClicked);
			_infoBtn.destroy();
			_infoBtn = null;

			removeChild(_dropBarBG);
			_dropBarBG = null;

			removeChild(_dropBar);
			_dropBar.destroy();
			_dropBar = null;

			removeChild(_timeTillDrop);
			_timeTillDrop.destroy();
			_timeTillDrop = null;

			removeChild(_timeTillDropLabel);
			_timeTillDropLabel.destroy();
			_timeTillDropLabel = null;

			removeChild(_cancelContractBtn);
			_cancelContractBtn.removeEventListener(MouseEvent.CLICK, onCancelContractClicked);
			_cancelContractBtn.destroy();
			_cancelContractBtn = null;

			removeChild(_creditsSymbol);
			_creditsSymbol = null;

			removeChild(_alloySymbol);
			_alloySymbol = null;

			removeChild(_repSymbol);
			_repSymbol = null;

			removeChild(_energySymbol);
			_energySymbol = null;

			removeChild(_syntheticsSymbol);
			_syntheticsSymbol = null;

			removeChild(_creditGain);
			_creditGain.destroy();
			_creditGain = null;

			removeChild(_alloyGain);
			_alloyGain.destroy();
			_alloyGain = null;

			removeChild(_energyGain);
			_energyGain.destroy();
			_energyGain = null;

			removeChild(_syntheicGain);
			_syntheicGain.destroy();
			_syntheicGain = null;

			removeChild(_repGain);
			_repGain.destroy();
			_repGain = null;

			removeChild(_durationLabel);
			_durationLabel.destroy();
			_durationLabel = null;

			removeChild(_duration);
			_duration.destroy();
			_duration = null;

			removeChild(_frequencyLabel);
			_frequencyLabel.destroy();
			_frequencyLabel = null;

			removeChild(_frequency);
			_frequency.destroy();
			_frequency = null;
		}

		private function cleanUpLocked():void
		{
			removeChild(_lockedIcon);
			_lockedIcon = null;

			removeChild(_lockedText);
			_lockedText.destroy();
			_lockedText = null;

			removeChild(_lockedReasonText);
			_lockedReasonText.destroy();
			_lockedReasonText = null;
		}

		private function cleanUpSelectACorp():void
		{
			var selectables:uint = _selectBtns.length;
			for (var i:uint = 0; i < selectables; ++i)
			{
				_selectBtns[i].removeEventListener(MouseEvent.CLICK, onOpenContractClicked);
				removeChild(_selectBtns[i]);
				_selectBtns[i].destroy();
				_selectBtns[i] = null;
			}
			_selectBtns.length = 0;

			removeChild(_selectCorpHeadding);
			_selectCorpHeadding.destroy();
			_selectCorpHeadding = null;
		}

		private function cleanUpContractState():void
		{
			removeChild(_corpImage);
			_corpImage.clearBitmap();
			ObjectPool.give(_corpImage);
			_corpImage = null;

			removeChild(_agentImage);
			_agentImage.clearBitmap();
			ObjectPool.give(_agentImage);
			_agentImage = null;

			removeChild(_acceptContractBtn);
			_acceptContractBtn.removeEventListener(MouseEvent.CLICK, onAcceptContractClicked);
			_acceptContractBtn.destroy();
			_acceptContractBtn = null;

			removeChild(_declineContractBtn);
			_declineContractBtn.removeEventListener(MouseEvent.CLICK, onDeclineContractClicked);
			_declineContractBtn.destroy();
			_declineContractBtn = null;

			removeChild(_infoBtn);
			_infoBtn.removeEventListener(MouseEvent.CLICK, onInfoBtnClicked);
			_infoBtn.destroy();
			_infoBtn = null;

			removeChild(_agentText);
			_agentText.destroy();
			_agentText = null;

			removeChild(_creditsSymbol);
			_creditsSymbol = null;

			removeChild(_alloySymbol);
			_alloySymbol = null;

			removeChild(_repSymbol);
			_repSymbol = null;

			removeChild(_energySymbol);
			_energySymbol = null;

			removeChild(_syntheticsSymbol);
			_syntheticsSymbol = null;

			removeChild(_creditGain);
			_creditGain.destroy();
			_creditGain = null;

			removeChild(_alloyGain);
			_alloyGain.destroy();
			_alloyGain = null;

			removeChild(_energyGain);
			_energyGain.destroy();
			_energyGain = null;

			removeChild(_syntheicGain);
			_syntheicGain.destroy();
			_syntheicGain = null;

			removeChild(_repGain);
			_repGain.destroy();
			_repGain = null;

			removeChild(_durationLabel);
			_durationLabel.destroy();
			_durationLabel = null;

			removeChild(_duration);
			_duration.destroy();
			_duration = null;

			removeChild(_frequencyLabel);
			_frequencyLabel.destroy();
			_frequencyLabel = null;

			removeChild(_frequency);
			_frequency.destroy();
			_frequency = null;
		}

		private function onOpenContractClicked( e:MouseEvent ):void
		{
			var selectedBtn:TradeRouteCorpBtn;
			if (e.target is TradeRouteCorpBtn)
				selectedBtn = TradeRouteCorpBtn(e.target);
			else if (e.target.parent is TradeRouteCorpBtn)
				selectedBtn = TradeRouteCorpBtn(e.target.parent);

			if (selectedBtn != null)
			{
				_contractStateSelectedTradeRoute = selectedBtn.tradeRoute;
				setState(CONTRACT_STATE);
			}
		}

		private function onInfoBtnClicked( e:MouseEvent ):void
		{
			var corp:IPrototype;
			if (_currentState == TRADE_ROUTE_IN_PROGRESS_STATE)
				corp = _tradeRouteInProgress.factionPrototype;
			else
				corp = _contractStateSelectedTradeRoute.factionPrototype;

			showCorpInfo(corp);
		}

		private function showCorpInfo( corp:IPrototype ):void
		{
			showCorporationInfo(corp);
		}

		private function onAcceptContractClicked( e:MouseEvent ):void
		{
			onContractAccepted.dispatch(_contractStateSelectedTradeRoute, _contractStateSelectedContractType);
		}

		private function onDeclineContractClicked( e:MouseEvent ):void
		{
			setState(SELECT_A_CORP_STATE);
		}

		private function onCancelContractClicked( e:MouseEvent ):void
		{
			if (_tradeRouteInProgress != null)
				cancelContract(_tradeRouteInProgress.id)
		}

		private function layout():void
		{
			switch (_currentState)
			{
				case TRADE_ROUTE_IN_PROGRESS_STATE:
					_dropBarBG.x = 120;
					_dropBarBG.y = 359;

					_dropBar.x = _dropBarBG.x + 3;
					_dropBar.y = _dropBarBG.y + 5;

					_timeTillDrop.x = _dropBar.x;
					_timeTillDrop.y = _dropBar.y - 5;

					_timeTillDropLabel.x = 33;
					_timeTillDropLabel.y = _timeTillDrop.y;

					_agentImage.x = 6;
					_agentImage.y = 93;

					_agentText.x = 97;
					_agentText.y = 95;

					_durationLabel.y = 194;
					_durationLabel.x = 12;

					_duration.y = 194;
					_duration.x = 164;

					_frequencyLabel.y = 218;
					_frequencyLabel.x = 12;

					_frequency.y = 218;
					_frequency.x = 164;

					_creditsSymbol.x = 16;
					_creditsSymbol.y = 248;

					_alloySymbol.x = 163;
					_alloySymbol.y = _creditsSymbol.y;

					_repSymbol.x = 93;
					_repSymbol.y = 321;

					_energySymbol.x = _creditsSymbol.x;
					_energySymbol.y = 284;

					_syntheticsSymbol.x = _alloySymbol.x;
					_syntheticsSymbol.y = _energySymbol.y;

					_creditGain.y = _creditsSymbol.y + (_creditsSymbol.height - _creditGain.height) * 0.5;
					_creditGain.x = _creditsSymbol.x + _creditsSymbol.width + 5;

					_alloyGain.y = _alloySymbol.y + (_alloySymbol.height - _alloyGain.height) * 0.5;
					_alloyGain.x = _alloySymbol.x + _alloySymbol.width + 5;

					_energyGain.y = _energySymbol.y + (_energySymbol.height - _energyGain.height) * 0.5;
					_energyGain.x = _energySymbol.x + _energySymbol.width + 5;

					_syntheicGain.y = _syntheticsSymbol.y + (_syntheticsSymbol.height - _syntheicGain.height) * 0.5;
					_syntheicGain.x = _syntheticsSymbol.x + _syntheticsSymbol.width + 5;

					_repGain.y = _repSymbol.y + (_repSymbol.height - _repGain.height) * 0.5;
					_repGain.x = _repSymbol.x + _repSymbol.width + 5;

					var contractPrototype:IPrototype = _tradeRouteInProgress.factionPrototype;
					getUIIcon('mediumImage', contractPrototype, onImageLoaded);
					break;
				case SELECT_A_CORP_STATE:
					var len:uint                     = _selectBtns.length;
					if (len > 0)
					{
						_selectCorpHeadding.x = _bg.x + (_bg.width - _selectCorpHeadding.width) * 0.5;
						_selectCorpHeadding.y = _bg.y + 20;

						var newBtn:BitmapButton;
						var buttonWidth:int       = _selectBtns[0].width;
						var buttonHeight:int      = _selectBtns[0].height;
						var totalbuttonHeight:int = len * 5 + len * buttonHeight;
						var xPos:int              = (_bg.width - buttonWidth) * 0.5;
						var yPos:int              = _selectCorpHeadding.y + _selectCorpHeadding.textHeight + 5;
						for (var i:uint = 0; i < len; ++i)
						{
							newBtn = _selectBtns[i];
							newBtn.x = xPos;
							newBtn.y = yPos;

							yPos += newBtn.height + 5;
						}
					}

					break;
				case LOCKED_STATE:
					_lockedText.x = _bg.x + (_bg.width - _lockedText.width) * 0.5
					_lockedText.y = 15;

					_lockedIcon.x = _bg.x + (_bg.width - _lockedIcon.width) * 0.5;
					_lockedIcon.y = _bg.y + (_bg.height - _lockedIcon.height) * 0.5;

					_lockedReasonText.x = _bg.x + (_bg.width - _lockedReasonText.width) * 0.5;
					_lockedReasonText.y = _lockedIcon.y + _lockedIcon.height + 45;
					break;
				case CONTRACT_STATE:

					_agentImage.x = 6;
					_agentImage.y = 93;

					_agentText.x = 97;
					_agentText.y = 95;

					_durationLabel.y = 194;
					_durationLabel.x = 12;

					_duration.y = 194;
					_duration.x = 164;

					_frequencyLabel.y = 218;
					_frequencyLabel.x = 12;

					_frequency.y = 218;
					_frequency.x = 164;

					_creditsSymbol.x = 16;
					_creditsSymbol.y = 248;

					_alloySymbol.x = 163;
					_alloySymbol.y = _creditsSymbol.y;

					_repSymbol.x = 93;
					_repSymbol.y = 321;

					_energySymbol.x = _creditsSymbol.x;
					_energySymbol.y = 284;

					_syntheticsSymbol.x = _alloySymbol.x;
					_syntheticsSymbol.y = _energySymbol.y;

					_creditGain.y = _creditsSymbol.y + (_creditsSymbol.height - _creditGain.height) * 0.5;
					_creditGain.x = _creditsSymbol.x + _creditsSymbol.width + 5;

					_alloyGain.y = _alloySymbol.y + (_alloySymbol.height - _alloyGain.height) * 0.5;
					_alloyGain.x = _alloySymbol.x + _alloySymbol.width + 5;

					_energyGain.y = _energySymbol.y + (_energySymbol.height - _energyGain.height) * 0.5;
					_energyGain.x = _energySymbol.x + _energySymbol.width + 5;

					_syntheicGain.y = _syntheticsSymbol.y + (_syntheticsSymbol.height - _syntheicGain.height) * 0.5;
					_syntheicGain.x = _syntheticsSymbol.x + _syntheticsSymbol.width + 5;

					_repGain.y = _repSymbol.y + (_repSymbol.height - _repGain.height) * 0.5;
					_repGain.x = _repSymbol.x + _repSymbol.width + 5;
					break;
			}
		}

		private function onImageLoaded( bmd:BitmapData ):void
		{
			if (_corpImage)
			{
				_corpImage.onImageLoaded(bmd);
				_corpImage.x = _bg.x + (309 - _corpImage.width) * 0.5;
				_corpImage.y = _bg.y + (86 - _corpImage.height) * 0.5;
			}
		}

		public function get timeRemaining():uint
		{
			if (_tradeRouteInProgressTransaction == null && _tradeRouteInProgress != null)
				_tradeRouteInProgressTransaction = getTradeRouteTransaction(_tradeRouteInProgress.id);

			return (_tradeRouteInProgressTransaction) ? _tradeRouteInProgressTransaction.timeRemainingMS : 0;
		}

		public function get lockedCount():uint
		{
			return _lockedCount;
		}
		
		[Inject]
		public function set presenter( value:ITradePresenter ):void  { _presenter = value; }
		public function get presenter():ITradePresenter  { return ITradePresenter(_presenter); }
		
		public function set baseIncome( baseIncome:uint ):void  { _baseIncome = baseIncome; }
		public function set baseCredit( baseCredit:uint ):void  { _baseCredit = baseCredit; }
		public function set tradeRouteScalar( tradeRouteScalar:Number ):void  { _tradeRouteScalar = tradeRouteScalar; }

		public function get currentState():int  { return _currentState; }

		override public function get height():Number
		{
			return _bg.height;
		}

		override public function get width():Number
		{
			return _bg.width;
		}

		private function clearUpCurrentState():void
		{
			switch (_currentState)
			{
				case TRADE_ROUTE_IN_PROGRESS_STATE:
					cleanUpInProgress();
					break;
				case SELECT_A_CORP_STATE:
					cleanUpSelectACorp();
					break;
				case LOCKED_STATE:
					cleanUpLocked();
					break;
				case CONTRACT_STATE:
					cleanUpContractState();
					break;
			}
		}

		public function destroy():void
		{
			clearUpCurrentState();
			_bg = null;

			onTradeCorporationSelected.removeAll();
			onTradeCorporationSelected = null;
		}

	}
}
