package com.ui.modal.traderoute.contract
{
	import com.model.prototype.IPrototype;
	import com.model.starbase.TradeRouteVO;
	import com.presenter.starbase.ITradePresenter;
	import com.ui.core.View;
	import com.ui.core.component.bar.ProgressBar;
	import com.ui.core.component.bar.Slider;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;
	import com.ui.core.component.misc.ImageComponent;
	import com.ui.core.component.pulldown.PullDown;
	import com.ui.core.component.pulldown.PullDownData;
	import com.ui.modal.ButtonFactory;
	import com.ui.modal.traderoute.dialog.TradeRouteDialogView;
	import com.model.asset.AssetVO;
	import com.ui.core.ScaleBitmap;
	import com.util.TradeRouteUtil;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	import flash.utils.getDefinitionByName;

	import org.parade.enum.ViewEnum;
	import org.shared.ObjectPool;

	public class TradeRouteContractView extends View
	{
		private var _bg:Bitmap;
		private var _closeBtn:BitmapButton;
		private var _viewName:Label;

		private var _agentImage:ImageComponent;
		private var _agentName:Label;
		private var _contractText:Label;

		private var _contractExpireTime:Label;

		private var _proposeBtn:BitmapButton;
		private var _buyoutBtn:BitmapButton;

		private var _bribeSliderBG:ScaleBitmap;

		private var _creditsCostSymbol:Sprite;
		private var _creditsSymbol:Bitmap;
		private var _alloySymbol:Bitmap;
		private var _energySymbol:Bitmap;
		private var _syntheticsSymbol:Bitmap;
		private var _repSymbol:Bitmap;
		private var _currentRepSymbol:Bitmap;

		private var _creditIncome:uint;
		private var _resourceIncome:uint;

		private var _currentCreditCost:int;

		private var _creditCost:Label;
		private var _creditGain:Label;
		private var _energyGain:Label;
		private var _alloyGain:Label;
		private var _syntheicGain:Label;
		private var _repGain:Label;

		private var _distributionLabel:Label;
		private var _productivityLabel:Label;
		private var _payoutLabel:Label;
		private var _durationLabel:Label;
		private var _frequencyLabel:Label;
		private var _protectionLabel:Label;

		private var _bribeSlider:Slider;

		private var _productivitySlider:Slider;
		private var _payoutSlider:Slider;
		private var _durationSlider:Slider;
		private var _frequencySlider:Slider;
		private var _securitySlider:Slider;

		private var _contractTypeSelection:PullDown;

		private var _validContracts:Vector.<IPrototype>;
		private var _agent:IPrototype;
		private var _validAgents:Vector.<IPrototype>;

		private var _selectedContract:TradeRouteVO;
		private var _negotiating:Boolean;

		private var _maxRep:Number;
		private var _repBar:ProgressBar;

		private var _dialogPopped:Boolean;
		
		private var _soundToPlay:String = '';
		private var _perHrText:String          = 'CodeString.Shared.PerHr'; //[[Number.ValuePerHr]]/h
		private var _perMinText:String         = 'CodeString.Shared.PerMin'; // [[Number.ValuePerMin]]/m
		private var _percentText:String        = 'CodeString.Shared.Percent'; // [[Number.PercentValue]]%
		private var _distributionText:String   = 'CodeString.TradeRouteContract.Distribution'; //Distribution
		private var _productivityString:String = 'CodeString.TradeRouteContract.Productivity'; //Productivity
		private var _payoutText:String         = 'CodeString.TradeRouteContract.Payout'; //Payout
		private var _durationText:String       = 'CodeString.TradeRouteContract.Duration'; //Duration
		private var _frequencyText:String      = 'CodeString.TradeRouteContract.Frequency'; //Frequency
		private var _securityText:String       = 'CodeString.TradeRouteContract.Security'; //Security
		private var _proposeBtnText:String     = 'CodeString.TradeRouteContract.ProposeBtn'; //Propose
		private var _buyoutBtnText:String      = 'CodeString.TradeRouteContract.BuyoutBtn'; //Buyout
		private var _bribeText:String          = 'CodeString.TradeRouteContract.CurrentBribe'; //Current Bribe: [[Number.CurrentBribeValue]]
		private var _negotiationTitle:String   = 'CodeString.TradeRouteContract.Title.Negotiation'; //CONTRACT NEGOTIATION
		private var _activeTitle:String        = 'CodeString.TradeRouteContract.Title.Active'; //ACTIVE CONTRACT

		private var _okBtnText:String          = 'CodeString.Shared.OkBtn'; //Ok

		[PostConstruct]
		override public function init():void
		{
			super.init();
			var windowBGClass:Class             = Class(getDefinitionByName('TradeRouteNegotiationBGBMD'));
			var creditsSymbolClass:Class        = Class(getDefinitionByName(('TradeRouteCreditsBMD')));
			var alloySymbolClass:Class          = Class(getDefinitionByName(('TradeRouteAlloyBMD')));
			var energySymbolClass:Class         = Class(getDefinitionByName(('TradeRouteEnergyBMD')));
			var syntheticsSymbolClass:Class     = Class(getDefinitionByName(('TradeRouteSyntheticsBMD')));
			var reputationSymbolClass:Class     = Class(getDefinitionByName(('TradeRouteReputationBMD')));

			_bg = new Bitmap(BitmapData(new windowBGClass()));

			_closeBtn = ButtonFactory.getCloseButton(_bg.width - 55, 25);
			addListener(_closeBtn, MouseEvent.CLICK, onClose);

			_viewName = new Label(20, 0xffffff, 125, 50);
			_viewName.align = TextFormatAlign.LEFT;
			_viewName.multiline = false;
			_viewName.wordWrap = false;
			_viewName.constrictTextToSize = true;
			_viewName.x = 35;
			_viewName.y = 25;

			_agentImage = ObjectPool.get(ImageComponent);
			_agentImage.init(2000, 2000);
			_agentImage.x = 64;
			_agentImage.y = 166;

			_maxRep = presenter.getConstantPrototypeValueByName('contractRepReq_Legendary');

			_resourceIncome = presenter.tradeRouteResourceIncome;
			_creditIncome = presenter.tradeRouteCreditIncome;

			var creditsCostSymbol:Bitmap        = new Bitmap(BitmapData(new creditsSymbolClass()));
			_creditsCostSymbol = new Sprite();
			_creditsCostSymbol.x = 532;
			_creditsCostSymbol.y = 540;
			_creditsCostSymbol.addChild(creditsCostSymbol);
			_creditsCostSymbol.mouseEnabled = false;

			_creditsSymbol = new Bitmap(BitmapData(new creditsSymbolClass()));
			_creditsSymbol.x = 180;
			_creditsSymbol.y = 72;

			_alloySymbol = new Bitmap(BitmapData(new alloySymbolClass()));
			_alloySymbol.x = 330;
			_alloySymbol.y = _creditsSymbol.y;

			_energySymbol = new Bitmap(BitmapData(new energySymbolClass()));
			_energySymbol.x = 480;
			_energySymbol.y = _alloySymbol.y;

			_syntheticsSymbol = new Bitmap(BitmapData(new syntheticsSymbolClass()));
			_syntheticsSymbol.x = 630;
			_syntheticsSymbol.y = _energySymbol.y;

			_repSymbol = new Bitmap(BitmapData(new reputationSymbolClass()));
			_repSymbol.x = 780;
			_repSymbol.y = _syntheticsSymbol.y;

			_currentRepSymbol = new Bitmap(BitmapData(new reputationSymbolClass()));
			_currentRepSymbol.x = 66;
			_currentRepSymbol.y = 285;

			_distributionLabel = new Label(14, 0xa2d3f5);
			_distributionLabel.autoSize = TextFieldAutoSize.LEFT;
			_distributionLabel.y = 337;
			_distributionLabel.x = 157;
			_distributionLabel.constrictTextToSize = false;
			_distributionLabel.text = _distributionText;

			_productivityLabel = new Label(14, 0xa2d3f5);
			_productivityLabel.autoSize = TextFieldAutoSize.LEFT;
			_productivityLabel.y = 395;
			_productivityLabel.x = 157;
			_productivityLabel.constrictTextToSize = false;
			_productivityLabel.text = _productivityString;

			_payoutLabel = new Label(14, 0xa2d3f5);
			_payoutLabel.autoSize = TextFieldAutoSize.LEFT;
			_payoutLabel.y = 456;
			_payoutLabel.x = 157;
			_payoutLabel.constrictTextToSize = false;
			_payoutLabel.text = _payoutText;

			_durationLabel = new Label(14, 0xa2d3f5);
			_durationLabel.autoSize = TextFieldAutoSize.LEFT;
			_durationLabel.y = 337;
			_durationLabel.x = 630;
			_durationLabel.constrictTextToSize = false;
			_durationLabel.text = _durationText;

			_frequencyLabel = new Label(14, 0xa2d3f5);
			_frequencyLabel.autoSize = TextFieldAutoSize.LEFT;
			_frequencyLabel.y = 395;
			_frequencyLabel.x = 630;
			_frequencyLabel.constrictTextToSize = false;
			_frequencyLabel.text = _frequencyText;

			_protectionLabel = new Label(14, 0xa2d3f5);
			_protectionLabel.autoSize = TextFieldAutoSize.LEFT;
			_protectionLabel.y = 456;
			_protectionLabel.x = 630;
			_protectionLabel.constrictTextToSize = false;
			_protectionLabel.text = _securityText;

			_creditCost = new Label(14, 0xFFFFFF);
			_creditCost.useLocalization = false;
			_creditCost.autoSize = TextFieldAutoSize.LEFT;
			_creditCost.y = _creditsCostSymbol.y + (_creditsCostSymbol.height - _creditCost.height) * 0.5 - 8;
			_creditCost.x = _creditsCostSymbol.x + _creditsCostSymbol.width + 5;
			_creditCost.constrictTextToSize = false;
			_creditCost.mouseEnabled = false;

			_creditGain = new Label(14, 0xFFFFFF);
			_creditGain.autoSize = TextFieldAutoSize.LEFT;
			_creditGain.y = _creditsSymbol.y + (_creditsSymbol.height - _creditGain.height) * 0.5 - 8;
			_creditGain.x = _creditsSymbol.x + _creditsSymbol.width + 5;
			_creditGain.constrictTextToSize = false;

			_alloyGain = new Label(14, 0xFFFFFF);
			_alloyGain.autoSize = TextFieldAutoSize.LEFT;
			_alloyGain.y = _alloySymbol.y + (_alloySymbol.height - _alloyGain.height) * 0.5 - 8;
			_alloyGain.x = _alloySymbol.x + _alloySymbol.width + 5;
			_alloyGain.constrictTextToSize = false;

			_energyGain = new Label(14, 0xFFFFFF);
			_energyGain.autoSize = TextFieldAutoSize.LEFT;
			_energyGain.y = _energySymbol.y + (_energySymbol.height - _energyGain.height) * 0.5 - 8;
			_energyGain.x = _energySymbol.x + _energySymbol.width + 5;
			_energyGain.constrictTextToSize = false;

			_syntheicGain = new Label(14, 0xFFFFFF);
			_syntheicGain.autoSize = TextFieldAutoSize.LEFT;
			_syntheicGain.y = _syntheticsSymbol.y + (_syntheticsSymbol.height - _syntheicGain.height) * 0.5 - 8;
			_syntheicGain.x = _syntheticsSymbol.x + _syntheticsSymbol.width + 5;
			_syntheicGain.constrictTextToSize = false;

			_repGain = new Label(14, 0xFFFFFF);
			_repGain.autoSize = TextFieldAutoSize.LEFT;
			_repGain.y = _repSymbol.y + (_repSymbol.height - _repGain.height) * 0.5 - 8;
			_repGain.x = _repSymbol.x + _repSymbol.width + 5;
			_repGain.constrictTextToSize = false;

			_agentName = new Label(18, 0xFFFFFF, 800, 95);
			_agentName.y = 134;
			_agentName.x = 66;
			_agentName.multiline = true;
			_agentName.align = TextFormatAlign.LEFT;
			_agentName.constrictTextToSize = false;

			_contractText = new Label(16, 0xFFFFFF, 800, 95);
			_contractText.y = 170;
			_contractText.x = 184;
			_contractText.multiline = true;
			_contractText.align = TextFormatAlign.LEFT;
			_contractText.constrictTextToSize = false;
			/*
			   _bribeSlider = new Slider('ViewContractBribeSliderBGBMD', 'ViewContractBribeSilderBarBMD', 'ViewContractBribeSilderBMD', 'ViewContractBribeSliderArrowBtnBMD', 'ViewContractBribeSliderArrowRollOverBtnBMD');
			   _bribeSlider.init(0, presenter.getConstantPrototypeValueByName('contractBribePurchaseLimit'), 0xdbbd97, true, true, formatSliderBribeText);
			   _bribeSlider.currentValue = 0;
			   _bribeSlider.x = 390;
			   _bribeSlider.y = 290;

			   var sliderRect:Rectangle            = new Rectangle(6, 3, 244, 27);
			   _bribeSliderBG = PanelFactory.getScaleBitmapPanel('ViewContractBribeBG', _bribeSlider.width + 5, 32, sliderRect)
			   _bribeSliderBG.x = _bribeSlider.x - 5;
			   _bribeSliderBG.y = _bribeSlider.y - 7;

			   _productivitySlider = new Slider('SliderBGBMD', 'SilderBarBMD', 'SilderSelectorBMD', 'SliderArrowBtnBMD', 'SliderArrowRollOverBtnBMD');
			   _productivitySlider.init(presenter.getConstantPrototypeValueByName('contractProductivityMin'), presenter.getConstantPrototypeValueByName('contractProductivityMax'), 0xffffff, true, false, formatSliderCurrentTextPercent);
			   _productivitySlider.currentValue = presenter.getConstantPrototypeValueByName('contractProductivityDefault');
			   _productivitySlider.onSliderUpdate.add(onProductivityOrPayoutChanged);
			   _productivitySlider.x = 156;
			   _productivitySlider.y = 418;

			   _payoutSlider = new Slider('SliderBGBMD', 'SilderBarBMD', 'SilderSelectorBMD', 'SliderArrowBtnBMD', 'SliderArrowRollOverBtnBMD');
			   _payoutSlider.init(presenter.getConstantPrototypeValueByName('contractPayoutMin'), presenter.getConstantPrototypeValueByName('contractPayoutMax'), 0xffffff, true, false, formatSliderCurrentTextPercent);
			   _payoutSlider.currentValue = presenter.getConstantPrototypeValueByName('contractPayoutDefault');
			   _payoutSlider.onSliderUpdate.add(onProductivityOrPayoutChanged);
			   _payoutSlider.x = 156;
			   _payoutSlider.y = 480;

			   _durationSlider = new Slider('SliderBGBMD', 'SilderBarBMD', 'SilderSelectorBMD', 'SliderArrowBtnBMD', 'SliderArrowRollOverBtnBMD');
			   _durationSlider.init(presenter.getConstantPrototypeValueByName('contractDurationMin'), presenter.getConstantPrototypeValueByName('contractDurationMax'), 0xffffff, true, false, formatSliderCurrentTextHours);
			   _durationSlider.currentValue = presenter.getConstantPrototypeValueByName('contractDurationDefault');
			   _durationSlider.x = 630;
			   _durationSlider.y = 361;

			   _frequencySlider = new Slider('SliderBGBMD', 'SilderBarBMD', 'SilderSelectorBMD', 'SliderArrowBtnBMD', 'SliderArrowRollOverBtnBMD');
			   _frequencySlider.init(presenter.getConstantPrototypeValueByName('contractFrequencyMin'), presenter.getConstantPrototypeValueByName('contractFrequencyMax'), 0xffffff, true, false, formatSliderCurrentTextMinutes);
			   _frequencySlider.currentValue = presenter.getConstantPrototypeValueByName('contractFrequencyDefault');
			   _frequencySlider.x = 630;
			   _frequencySlider.y = 418;

			   _securitySlider = new Slider('SliderBGBMD', 'SilderBarBMD', 'SilderSelectorBMD', 'SliderArrowBtnBMD', 'SliderArrowRollOverBtnBMD');
			   _securitySlider.init(presenter.getConstantPrototypeValueByName('contractSecurityMin'), presenter.getConstantPrototypeValueByName('contractSecurityMax'), 0xffffff, true, false, formatSliderCurrentTextPercent);
			   _securitySlider.currentValue = presenter.getConstantPrototypeValueByName('contractSecurityDefault');
			   _securitySlider.x = 630;
			   _securitySlider.y = 480;
			 */
			var barBGBMD:Class                  = Class(getDefinitionByName(('ViewContractRepBGBMD')));
			var barBMD:Class                    = Class(getDefinitionByName(('ViewContractRepBarBMD')));

			_repBar = new ProgressBar();
			_repBar.init(ProgressBar.HORIZONTAL, new Bitmap(BitmapData(new barBMD())), new Bitmap(BitmapData(new barBGBMD())), 0.01);
			_repBar.setMinMax(0, _maxRep);
			_repBar.x = 95;
			_repBar.y = 286;
			_repBar.amount = _selectedContract.reputation;

			_proposeBtn = ButtonFactory.getBitmapButton('ViewContractProposeBtnUpBMD', 400, 535, _proposeBtnText, 0xa2d3f5, 'ViewContractProposeBtnRollOverBMD');
			_proposeBtn.label.x -= 89;
			addListener(_proposeBtn, MouseEvent.CLICK, requestContract);

			_buyoutBtn = ButtonFactory.getBitmapButton('ViewContractBribeBtnUpBMD', 706, 283, _buyoutBtnText, 0xdbbd97, 'ViewContractBribeBtnRollOverBMD');

			_contractTypeSelection = new PullDown();
			var rect:Rectangle                  = new Rectangle(1, 1, 123, 21);
			_contractTypeSelection.init(125, 24, 0, 'ViewContractPulldownBGBMD', rect, 174, 362, 0, 14, true);

			addChild(_bg);
			addChild(_closeBtn);
			addChild(_agentImage);
			addChild(_viewName);
			addChild(_agentName);
			addChild(_buyoutBtn);
			addChild(_bribeSliderBG);
			addChild(_proposeBtn);
			addChild(_creditsSymbol);
			addChild(_alloySymbol);
			addChild(_energySymbol);
			addChild(_syntheticsSymbol);
			addChild(_creditsCostSymbol);
			addChild(_repSymbol);
			addChild(_currentRepSymbol);
			addChild(_distributionLabel);
			addChild(_productivityLabel);
			addChild(_payoutLabel);
			addChild(_durationLabel);
			addChild(_frequencyLabel);
			addChild(_protectionLabel);
			addChild(_creditCost);
			addChild(_creditGain);
			addChild(_alloyGain);
			addChild(_energyGain);
			addChild(_syntheicGain);
			addChild(_repGain);
			addChild(_contractText);
			addChild(_repBar);
			addChild(_productivitySlider);
			addChild(_payoutSlider);
			addChild(_durationSlider);
			addChild(_frequencySlider);
			addChild(_bribeSlider);
			addChild(_securitySlider);
			addChild(_contractTypeSelection);

			_validContracts = presenter.getContractsFromFaction(_selectedContract.contractGroup);

			var currentContractType:IPrototype;
			var contractPullDownData:Array      = new Array();
			var currentContractPullDownData:PullDownData;
			var len:uint                        = _validContracts.length;
			for (var i:uint = 0; i < len; ++i)
			{
				currentContractType = _validContracts[i];
				if (currentContractType != null)
				{
					currentContractPullDownData = new PullDownData();
					currentContractPullDownData.displayName = presenter.getProtoTypeUIName(currentContractType);
					currentContractPullDownData.index = i;
					currentContractPullDownData.returnParams = [currentContractType];

					contractPullDownData.push(currentContractPullDownData);
				}
			}
			_contractTypeSelection.addPullDownData(contractPullDownData);
			_contractTypeSelection.onChangedSelected.add(setContractType);

			_agent = presenter.getAgent(_selectedContract.contractGroup, _selectedContract.reputation);

			_agentName.text = presenter.getProtoTypeUIName(_agent);
			presenter.loadIconFromPrototype('icon', _agent, _agentImage.onImageLoaded);
			var agentDialog:Vector.<IPrototype> = presenter.getAgentDialogByGroup(_agent.getValue('contractGroup'));

			if (agentDialog.length > 0)
			{
				_contractText.text = agentDialog[0].getValue('dialogString');
				
				//todo uncomment when ready
				//var audioDir:String = agentDialog[0].getValue('dialogAudioString');
				//if(audioDir.length>0)
				//	_soundToPlay = audioDir;
				//else
					_soundToPlay = "";
				
				if(_soundToPlay.length > 0)
					presenter.playSound(_soundToPlay, 0.75);
			}
			else
				_soundToPlay = "";

			updateIncome();
			updateContract();

			addEffects();
			effectsIN();
		}

		private function updateContract():void
		{
			if (_negotiating)
			{

				_viewName.text = _negotiationTitle;

				if (_selectedContract.contractPrototype != null)
				{
					if (isNaN(_selectedContract.bribe))
						_bribeSlider.currentValue = 0;
					else
						_bribeSlider.currentValue = _selectedContract.bribe;

					_productivitySlider.currentValue = _selectedContract.productivity;
					_payoutSlider.currentValue = _selectedContract.payout;
					_durationSlider.currentValue = _selectedContract.duration;
					_frequencySlider.currentValue = _selectedContract.frequency;
					_securitySlider.currentValue = _selectedContract.security;

					_currentCreditCost = 0.15 * _creditIncome;
				} else
				{
					_selectedContract.contractPrototype = _validContracts[0];
					_currentCreditCost = 0;
					TradeRouteUtil.RollPointValue(_selectedContract.reputation);
				}

				_creditCost.text = String(_currentCreditCost);
			} else
			{
				_viewName.text = _activeTitle;

				_creditsCostSymbol.visible = false;
				_creditCost.visible = false;

				_bribeSlider.visible = false;
				_bribeSliderBG.visible = false;

				_contractTypeSelection.selectByDisplayName(_selectedContract.contractPrototype.getValue('uiAsset'));
				_contractTypeSelection.enabled = false;

				_productivitySlider.currentValue = _selectedContract.productivity;
				_productivitySlider.enabled = false;

				_payoutSlider.currentValue = _selectedContract.payout;
				_payoutSlider.enabled = false;

				_durationSlider.currentValue = _selectedContract.duration;
				_durationSlider.enabled = false;

				_frequencySlider.currentValue = _selectedContract.frequency;
				_frequencySlider.enabled = false;

				_securitySlider.currentValue = _selectedContract.security;
				_securitySlider.enabled = false;

				_proposeBtn.visible = false;
				_buyoutBtn.visible = false;
			}
			updateIncome();
		}

		override protected function effectsDoneIn():void
		{
			super.effectsDoneIn();
			if (_negotiating)
			{
				if (!presenter.hasAgentGreetingBeenViewed(_agent.getValue('id')))
				{
					showAgentGreeting();
				}
			}
		}


		private function showAgentGreeting():void
		{
			presenter.setAgentGreetingViewed(_agent.getValue('id'));
			if (presenter.inFTE)
				return;

			var agentDialog:Vector.<IPrototype>            = presenter.getAgentDialogByGroup(_agent.getValue('introGroup'));
			var bodyText:String                            = '';
			if (agentDialog.length > 0)
			{
				bodyText = agentDialog[0].getValue('dialogString');
				//todo uncomment when ready
				//var audioDir:String = agentDialog[0].getValue('dialogAudioString');
				//if(audioDir.length>0)
				//	_soundToPlay = audioDir;
				//else
					_soundToPlay = "";
				
				if(_soundToPlay.length > 0)
					presenter.playSound(_soundToPlay, 0.75);
			}

			var nTradeRouteDialogView:TradeRouteDialogView = TradeRouteDialogView(_viewFactory.createView(TradeRouteDialogView));
			_viewFactory.notify(nTradeRouteDialogView);
			nTradeRouteDialogView.setUpDialog(TradeRouteDialogView.AGENT, _agent, bodyText, _okBtnText);

		}

		private function onProductivityOrPayoutChanged( current:Number, percent:Number ):void
		{
			updateIncome();
		}

		private function setContractType( args:Array ):void
		{
			var selectedContractType:IPrototype = args[0];
			_selectedContract.contractPrototype = selectedContractType;
			updateIncome();
		}

		private function onTradeRouteUpdated( success:Boolean ):void
		{
			if (!_dialogPopped)
			{
				updateContract();

				var agentDialog:Vector.<IPrototype>;
				var onClose:Function;
				if (!success)
				{
					agentDialog = presenter.getAgentDialogByGroup(_agent.getValue('rejectGroup'));
					onClose = onTradeRouteDialogClosed;
				} else
				{
					agentDialog = presenter.getAgentDialogByGroup(_agent.getValue('acceptGroup'));
					onClose = destroy;
				}

				var bodyText:String                            = '';
				if (agentDialog.length > 0)
				{
					bodyText = agentDialog[Math.floor(Math.random() * agentDialog.length)].getValue('dialogString');
					//todo uncomment when ready
					//var audioDir:String = agentDialog[Math.floor(Math.random() * agentDialog.length)].getValue('dialogAudioString');
					//if(audioDir.length>0)
					//	_soundToPlay = audioDir;
					//else
						_soundToPlay = "";
					
					if(_soundToPlay.length > 0)
						presenter.playSound(_soundToPlay, 0.75);
				}

				var nTradeRouteDialogView:TradeRouteDialogView = TradeRouteDialogView(_viewFactory.createView(TradeRouteDialogView));
				_viewFactory.notify(nTradeRouteDialogView);
				nTradeRouteDialogView.setUpDialog(TradeRouteDialogView.AGENT, _agent, bodyText, _okBtnText, onClose);
				_dialogPopped = true;
			}
		}

		private function onTradeRouteDialogClosed():void
		{
			_dialogPopped = false;
		}

		private function updateIncome():void
		{
			var productivity:Number = _productivitySlider.currentValue;
			var payout:Number       = _payoutSlider.currentValue;
			var creditGain:Number   = _creditIncome * _selectedContract.creditScale;
			var alloyGain:Number    = _resourceIncome * _selectedContract.alloyScale;
			var energyGain:Number   = _resourceIncome * _selectedContract.energyScale;
			var synGain:Number      = _resourceIncome * _selectedContract.syntheticScale
			var repGain:Number      = _resourceIncome * _selectedContract.reputationScale;
			var frequency:Number    = _frequencySlider.currentValue / 60.0;

			var currentValue:Number = Math.floor((creditGain * productivity) * (1 - payout) * frequency);
			_creditGain.setTextWithTokens(_perHrText, {'[[Number.ValuePerHr]]':currentValue});

			currentValue = Math.floor((alloyGain * productivity) * (1 - payout) * frequency);
			_alloyGain.setTextWithTokens(_perHrText, {'[[Number.ValuePerHr]]':currentValue});

			currentValue = Math.floor((energyGain * productivity) * (1 - payout) * frequency);
			_energyGain.setTextWithTokens(_perHrText, {'[[Number.ValuePerHr]]':currentValue});

			currentValue = Math.floor((synGain * productivity) * (1 - payout) * frequency);
			_syntheicGain.setTextWithTokens(_perHrText, {'[[Number.ValuePerHr]]':currentValue});

			currentValue = Math.floor((repGain * productivity) * (1 - payout) * frequency);
			_repGain.setTextWithTokens(_perHrText, {'[[Number.ValuePerHr]]':currentValue});

		}

		private function getAgent( agents:Vector.<IPrototype> ):IPrototype
		{
			var len:uint          = agents.length;
			var currentAgent:IPrototype;
			var currentRep:Number = _selectedContract.reputation;
			for (var i:uint = 0; i < len; ++i)
			{
				currentAgent = agents[i];
				if (currentAgent.getValue('minRep') <= currentRep && currentAgent.getValue('maxRep') >= currentRep)
					break;
			}

			return currentAgent;
		}

		private function formatSliderBribeText( currentValue:Number, percent:Number, textBox:Label ):void
		{
			textBox.setTextWithTokens(_bribeText, {'[[Number.CurrentBribeValue]]':Math.round(currentValue)});
		}

		private function formatSliderCurrentTextPercent( currentValue:Number, percent:Number, textBox:Label ):void
		{
			textBox.setTextWithTokens(_percentText, {'[[Number.PercentValue]]':Math.round((currentValue * 100))});
		}

		private function formatSliderCurrentTextHours( currentValue:Number, percent:Number, textBox:Label ):void
		{
			textBox.setTextWithTokens(_perHrText, {'[[Number.ValuePerHr]]':Math.floor(currentValue)});
		}

		private function formatSliderCurrentTextMinutes( currentValue:Number, percent:Number, textBox:Label ):void
		{
			textBox.setTextWithTokens(_perMinText, {'[[Number.ValuePerMin]]':Math.floor(currentValue)});
		}

		private function requestContract( e:MouseEvent ):void
		{
			//presenter.requestContract(false, _selectedContract.contractPrototype.name, _durationSlider.currentValue, _selectedContract.factionPrototype.name, _frequencySlider.currentValue, _payoutSlider.
			//					  currentValue, _productivitySlider.currentValue, _securitySlider.currentValue, onTradeRouteUpdated);
		}

		public function set pendingContract( contract:TradeRouteVO ):void
		{
			_selectedContract = contract;
			_negotiating = true;
		}

		public function set contract( contract:TradeRouteVO ):void
		{
			_selectedContract = contract;
			_negotiating = false;
		}
		
		[Inject]
		public function set presenter( value:ITradePresenter ):void  { _presenter = value; }
		public function get presenter():ITradePresenter  { return ITradePresenter(_presenter); }

		override public function get typeUnique():Boolean  { return false; }

		override public function get height():Number  { return _bg.height; }
		override public function get width():Number  { return _bg.width; }

		override public function destroy():void
		{
			_bg = null;
			_closeBtn.destroy();
			_closeBtn = null;

			_viewName.destroy();
			_viewName = null;

			super.destroy();
		}
	}
}
