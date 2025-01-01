package com.ui.modal.traderoute.overview
{
	import com.model.prototype.IPrototype;
	import com.model.starbase.TradeRouteVO;
	import com.model.transaction.TransactionVO;
	import com.presenter.starbase.ITradePresenter;
	import com.ui.UIFactory;
	import com.ui.core.View;
	import com.ui.core.component.button.BitmapButton;
	import com.ui.core.component.label.Label;
	import com.ui.modal.ButtonFactory;
	import com.ui.modal.traderoute.contract.TradeRouteContractView;
	import com.ui.modal.traderoute.dialog.TradeRouteDialogView;
	import com.model.asset.AssetVO;

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.MouseEvent;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormatAlign;
	import flash.utils.getDefinitionByName;

	import org.adobe.utils.StringUtil;
	import org.as3commons.logging.api.ILogger;
	import org.as3commons.logging.api.getLogger;
	import org.parade.enum.ViewEnum;

	public class TradeRouteOverviewView extends View
	{
		private var _bg:Bitmap;
		private var _closeBtn:BitmapButton;
		private var _viewName:Label;

		private var _creditsSymbol:Bitmap;
		private var _alloySymbol:Bitmap;
		private var _energySymbol:Bitmap;
		private var _syntheticsSymbol:Bitmap;

		private var _creditsPerDrop:Number;
		private var _alloyPerDrop:Number;
		private var _energyPerDrop:Number;
		private var _syntheticPerDrop:Number;
		private var _tradeRouteScalar:Number;

		private var _creditGain:Label;
		private var _energyGain:Label;
		private var _alloyGain:Label;
		private var _syntheticGain:Label;

		private var _productionOverview:Label;

		private var _contracts:Vector.<TradeRouteDisplay>;
		private var _routes:Vector.<TradeRouteVO>;
		private var _openContracts:Vector.<TradeRouteVO>;

		private var _tradeRoutes:String            = 'CodeString.TradeRouteOverview.Title'; //TRADE ROUTES
		private var _okBtnText:String              = 'CodeString.Shared.OkBtn'; //Ok
		private var _productionOverviewText:String = 'CodeString.TradeRouteOverview.Production'; //Production Per Drop
		private var _perDropText:String            = 'CodeString.TradeRouteDisplay.PerDrop'; //[[Number.ValuePerDrop]]/Drop

		protected const _logger:ILogger            = getLogger('TradeRouteView');

		[PostConstruct]
		override public function init():void
		{
			super.init();
			_openContracts = new Vector.<TradeRouteVO>;
			_contracts = new Vector.<TradeRouteDisplay>;

			_tradeRouteScalar = presenter.getConstantPrototypeValueByName('tradeRouteScalar');

			var windowBGClass:Class                 = Class(getDefinitionByName('TradeRouteBGBMD'));
			_bg = new Bitmap(BitmapData(new windowBGClass()));

			_closeBtn = ButtonFactory.getCloseButton(_bg.width - 47, 25);
			addListener(_closeBtn, MouseEvent.CLICK, onClose);

			_viewName = new Label(20, 0xffffff, 125, 50);
			_viewName.align = TextFormatAlign.LEFT;
			_viewName.multiline = false;
			_viewName.wordWrap = false;
			_viewName.constrictTextToSize = true;
			_viewName.text = _tradeRoutes;
			_viewName.x = 42;
			_viewName.y = 25;

			_creditsSymbol = UIFactory.getBitmap("IconCreditBMD");
			_creditsSymbol.scaleX = _creditsSymbol.scaleY = 0.85;
			_creditsSymbol.smoothing = true;
			_creditsSymbol.x = 75;
			_creditsSymbol.y = 535;

			_alloySymbol = UIFactory.getBitmap("IconAlloyBMD");
			_alloySymbol.scaleX = _alloySymbol.scaleY = 0.85;
			_alloySymbol.smoothing = true;
			_alloySymbol.x = 304;
			_alloySymbol.y = _creditsSymbol.y;

			_energySymbol = UIFactory.getBitmap("IconEnergyBMD");
			_energySymbol.scaleX = _energySymbol.scaleY = 0.85;
			_energySymbol.smoothing = true;
			_energySymbol.x = 534;
			_energySymbol.y = _alloySymbol.y;

			_syntheticsSymbol = UIFactory.getBitmap("IconSynthBMD");
			_syntheticsSymbol.scaleX = _syntheticsSymbol.scaleY = 0.85;
			_syntheticsSymbol.smoothing = true;
			_syntheticsSymbol.x = 762;
			_syntheticsSymbol.y = _energySymbol.y;

			_creditGain = new Label(18, 0xA9DCFF);
			_creditGain.autoSize = TextFieldAutoSize.LEFT;
			_creditGain.y = _creditsSymbol.y + (_creditsSymbol.height - _creditGain.height) * 0.5 - 10;
			_creditGain.x = _creditsSymbol.x + _creditsSymbol.width + 5;
			_creditGain.constrictTextToSize = false;
			addChild(_creditGain);

			_alloyGain = new Label(18, 0xA9DCFF);
			_alloyGain.autoSize = TextFieldAutoSize.LEFT;
			_alloyGain.y = _alloySymbol.y + (_alloySymbol.height - _alloyGain.height) * 0.5 - 10;
			_alloyGain.x = _alloySymbol.x + _alloySymbol.width + 5;
			_alloyGain.constrictTextToSize = false;
			addChild(_alloyGain);

			_energyGain = new Label(18, 0xA9DCFF);
			_energyGain.autoSize = TextFieldAutoSize.LEFT;
			_energyGain.y = _energySymbol.y + (_energySymbol.height - _energyGain.height) * 0.5 - 10;
			_energyGain.x = _energySymbol.x + _energySymbol.width + 5;
			_energyGain.constrictTextToSize = false;
			addChild(_energyGain);

			_syntheticGain = new Label(18, 0xA9DCFF);
			_syntheticGain.autoSize = TextFieldAutoSize.LEFT;
			_syntheticGain.y = _syntheticsSymbol.y + (_syntheticsSymbol.height - _syntheticGain.height) * 0.5 - 10;
			_syntheticGain.x = _syntheticsSymbol.x + _syntheticsSymbol.width + 5;
			_syntheticGain.constrictTextToSize = false;
			addChild(_syntheticGain);

			_productionOverview = new Label(18, 0xFFFFFF);
			_productionOverview.autoSize = TextFieldAutoSize.LEFT;
			_productionOverview.y = 510;
			_productionOverview.x = 37;
			_productionOverview.constrictTextToSize = false;
			_productionOverview.text = _productionOverviewText;

			addChild(_bg);
			addChild(_closeBtn);
			addChild(_viewName);
			addChild(_productionOverview);
			addChild(_creditsSymbol);
			addChild(_alloySymbol);
			addChild(_energySymbol);
			addChild(_syntheticsSymbol);
			addChild(_creditGain);
			addChild(_alloyGain);
			addChild(_energyGain);
			addChild(_syntheticGain);

			_creditsPerDrop = 0;
			_alloyPerDrop = 0;
			_energyPerDrop = 0;
			_syntheticPerDrop = 0;

			var maxContracts:int                    = presenter.maxContracts;
			var getUIIcon:Function                  = presenter.loadIconFromPrototype;
			var getUIDescription:Function           = presenter.getPrototypeUIDescription;
			var getConstantProto:Function           = presenter.getConstantPrototypeValueByName;
			var getBalancedContract:Function        = presenter.getBalancedContractFromFaction;
			var getAgent:Function                   = presenter.getAgent;
			var getAgentDialogByGroup:Function      = presenter.getAgentDialogByGroup;
			var hasAgentGreetingBeenViewed:Function = presenter.hasAgentGreetingBeenViewed;
			var getTradeRouteTransaction:Function   = presenter.getTradeRouteTransaction;
			var cancelContract:Function             = presenter.cancelContract;
			var baseIncome:uint                     = presenter.tradeRouteResourceIncome;
			var baseCredit:uint                     = presenter.tradeRouteCreditIncome;

			var tradeRouteDisplay:TradeRouteDisplay;
			for (var i:uint = 0; i < maxContracts; ++i)
			{
				tradeRouteDisplay = new TradeRouteDisplay();
				tradeRouteDisplay.presenter = presenter;
				tradeRouteDisplay.getUIIcon = getUIIcon;
				tradeRouteDisplay.getUIDescription = getUIDescription;
				tradeRouteDisplay.getConstantPrototype = getConstantProto;
				tradeRouteDisplay.getBalancedContractFromFaction = getBalancedContract;
				tradeRouteDisplay.getAgent = getAgent;
				tradeRouteDisplay.getAgentDialogByGroup = getAgentDialogByGroup;
				tradeRouteDisplay.hasAgentGreetingBeenViewed = hasAgentGreetingBeenViewed;
				tradeRouteDisplay.showAgentGreeting = showAgentGreeting;
				tradeRouteDisplay.showCorporationInfo = showCorporationInfo;
				tradeRouteDisplay.getTradeRouteTransaction = getTradeRouteTransaction;
				tradeRouteDisplay.cancelContract = cancelContract;
				tradeRouteDisplay.onTradeCorporationSelected.add(onCorporationSelected);
				tradeRouteDisplay.onContractAccepted.add(requestContract);
				tradeRouteDisplay.tradeRouteScalar = _tradeRouteScalar;
				tradeRouteDisplay.baseIncome = baseIncome;
				tradeRouteDisplay.baseCredit = baseCredit;
				addChild(tradeRouteDisplay);
				_contracts.push(tradeRouteDisplay);
			}

			presenter.addTransactionListener(onUpdatedTradeRouteTransaction);

			onTradeRoutesUpdated();

			addEffects();
			effectsIN();
		}

		private function showAgentGreeting( agent:IPrototype ):void
		{
			presenter.setAgentGreetingViewed(agent.getValue('id'));
			if (presenter.inFTE)
				return;

			var agentDialog:Vector.<IPrototype>            = presenter.getAgentDialogByGroup(agent.getValue('introGroup'));
			var bodyText:String                            = '';
			if (agentDialog.length > 0)
			{
				bodyText = agentDialog[0].getValue('dialogString');
				
				//todo uncomment when ready
				//var audioDir:String = agentDialog[0].getValue('dialogAudioString');
				//if(audioDir.length>0)
				//	presenter.playSound(audioDir, 0.75);
			}

			var nTradeRouteDialogView:TradeRouteDialogView = TradeRouteDialogView(_viewFactory.createView(TradeRouteDialogView));
			_viewFactory.notify(nTradeRouteDialogView);
			nTradeRouteDialogView.setUpDialog(TradeRouteDialogView.AGENT, agent, bodyText, _okBtnText);

		}

		private function showCorporationInfo( corp:IPrototype ):void
		{
			var bodyText:String                            = presenter.getPrototypeUIDescription(corp);
			var nTradeRouteDialogView:TradeRouteDialogView = TradeRouteDialogView(_viewFactory.createView(TradeRouteDialogView));
			_viewFactory.notify(nTradeRouteDialogView);
			nTradeRouteDialogView.setUpDialog(TradeRouteDialogView.CORP, corp, bodyText, _okBtnText);
		}

		private function onCorporationSelected( tradeRoute:TradeRouteVO ):void
		{
			var nContractView:TradeRouteContractView = TradeRouteContractView(_viewFactory.createView(TradeRouteContractView));
			nContractView.pendingContract = tradeRoute.clone();
			_viewFactory.notify(nContractView);
		}

		private function onOpenActiveContract( tradeRoute:TradeRouteVO ):void
		{
			var nContractView:TradeRouteContractView = TradeRouteContractView(_viewFactory.createView(TradeRouteContractView));
			nContractView.contract = tradeRoute;
			_viewFactory.notify(nContractView);
		}

		private function requestContract( selectedContract:TradeRouteVO, selectedContractProtoType:IPrototype ):void
		{
			presenter.requestContract(false, selectedContractProtoType.name, selectedContract.factionPrototype.name, null);
		}

		private function onUpdatedTradeRouteTransaction( tradeRoute:TransactionVO ):void
		{
			onTradeRoutesUpdated();
		}

		private function onTradeRoutesUpdated():void
		{
			_routes = presenter.tradeRoutes.concat();

			_routes.sort(function( a:TradeRouteVO, b:TradeRouteVO ):int
			{
				return int(b.corporation < a.corporation) - int(a.corporation < b.corporation);
			});

			_openContracts.length = 0;
			var baseIncome:uint          = presenter.tradeRouteResourceIncome;
			var baseCredit:uint          = presenter.tradeRouteCreditIncome;
			var maxContracts:int         = presenter.maxContracts;
			var maxUnlockedContracts:int = presenter.maxUnlockedContracts;
			var i:uint;
			var currentRoute:TradeRouteVO;
			var count:uint;
			_creditsPerDrop = 0;
			_alloyPerDrop = 0;
			_energyPerDrop = 0;
			_syntheticPerDrop = 0;
			for (i = 0; i < _routes.length; )
			{
				currentRoute = _routes[i];
				if (currentRoute.end == 0)
				{
					_openContracts.push(currentRoute);
					_routes.splice(i, 1)
				} else
				{
					var route:TradeRouteVO  = _routes[i];
					var productivity:Number = route.productivity;
					var payout:Number       = 1 - route.payout;
					var creditGain:Number   = (baseCredit * route.creditScale) * _tradeRouteScalar;
					var alloyGain:Number    = (baseIncome * route.alloyScale) * _tradeRouteScalar;
					var energyGain:Number   = (baseIncome * route.energyScale) * _tradeRouteScalar;
					var synGain:Number      = (baseIncome * route.syntheticScale) * _tradeRouteScalar;
					var frequency:Number    = route.frequency / 60.0;

					_creditsPerDrop += Math.floor(((creditGain * productivity) * payout) * frequency);
					_alloyPerDrop += Math.floor(((alloyGain * productivity) * payout) * frequency);
					_energyPerDrop += Math.floor(((energyGain * productivity) * payout) * frequency);
					_syntheticPerDrop += Math.floor(((synGain * productivity) * payout) * frequency);
					++i;
				}
			}

			var ongoingContracts:uint    = _routes.length;
			var openContractsLen:uint    = _openContracts.length;
			var tradeRouteDisplay:TradeRouteDisplay;
			for (i = 0; i < maxContracts; ++i)
			{
				tradeRouteDisplay = _contracts[i];
				if (i < maxUnlockedContracts)
				{
					if (ongoingContracts > 0)
					{
						tradeRouteDisplay.baseIncome = baseIncome;
						tradeRouteDisplay.baseCredit = baseCredit;
						tradeRouteDisplay.tradeRouteScalar = _tradeRouteScalar;
						tradeRouteDisplay.addTradeRouteInProgress(_routes[_routes.length - ongoingContracts/*ongoingContracts - 1*/]);
						--ongoingContracts;
						++count;
					} else
					{
						tradeRouteDisplay.setSelectableCorporations(_openContracts);
						++count;
					}
				} else
				{
					++count;
					tradeRouteDisplay.setLocked(count);
				}
			}

			_creditGain.setTextWithTokens(_perDropText, {'[[Number.ValuePerDrop]]':StringUtil.commaFormatNumber(Math.floor(_creditsPerDrop))});
			_alloyGain.setTextWithTokens(_perDropText, {'[[Number.ValuePerDrop]]':StringUtil.commaFormatNumber(Math.floor(_alloyPerDrop))});
			_energyGain.setTextWithTokens(_perDropText, {'[[Number.ValuePerDrop]]':StringUtil.commaFormatNumber(Math.floor(_energyPerDrop))});
			_syntheticGain.setTextWithTokens(_perDropText, {'[[Number.ValuePerDrop]]':StringUtil.commaFormatNumber(Math.floor(_syntheticPerDrop))});

			_contracts.sort(orderItems);

			layout();
		}

		protected function orderItems( itemOne:TradeRouteDisplay, itemTwo:TradeRouteDisplay ):Number
		{
			if (!itemOne)
				return -1;
			if (!itemTwo)
				return 1;

			var currentStateOne:uint = itemOne.currentState;
			var currentStateTwo:uint = itemTwo.currentState;

			if (currentStateOne == TradeRouteDisplay.TRADE_ROUTE_IN_PROGRESS_STATE && currentStateTwo != TradeRouteDisplay.TRADE_ROUTE_IN_PROGRESS_STATE)
				return -1;
			if (currentStateOne != TradeRouteDisplay.TRADE_ROUTE_IN_PROGRESS_STATE && currentStateTwo == TradeRouteDisplay.TRADE_ROUTE_IN_PROGRESS_STATE)
				return 1;

			if (currentStateOne == TradeRouteDisplay.CONTRACT_STATE && (currentStateTwo == TradeRouteDisplay.LOCKED_STATE || currentStateTwo == TradeRouteDisplay.SELECT_A_CORP_STATE))
				return -1;
			if (currentStateTwo == TradeRouteDisplay.CONTRACT_STATE && (currentStateOne == TradeRouteDisplay.LOCKED_STATE || currentStateOne == TradeRouteDisplay.SELECT_A_CORP_STATE))
				return 1;

			if (currentStateOne == TradeRouteDisplay.SELECT_A_CORP_STATE && (currentStateTwo == TradeRouteDisplay.LOCKED_STATE))
				return -1;
			if (currentStateTwo == TradeRouteDisplay.SELECT_A_CORP_STATE && (currentStateOne == TradeRouteDisplay.LOCKED_STATE))
				return 1;

			if (currentStateOne == TradeRouteDisplay.TRADE_ROUTE_IN_PROGRESS_STATE && currentStateTwo == TradeRouteDisplay.TRADE_ROUTE_IN_PROGRESS_STATE)
			{
				var timeLeftOne:Number = itemOne.timeRemaining;
				var timeLeftTwo:Number = itemTwo.timeRemaining;

				if (timeLeftOne < timeLeftTwo || timeLeftTwo == 0)
					return -1;

				if (timeLeftOne > timeLeftTwo || timeLeftOne == 0)
					return 1;
			}


			if (currentStateOne == TradeRouteDisplay.LOCKED_STATE && currentStateTwo == TradeRouteDisplay.LOCKED_STATE)
			{
				var lockedCountOne:uint = itemOne.lockedCount;
				var lockedCountTwo:uint = itemTwo.lockedCount;

				if (lockedCountOne < lockedCountTwo)
					return -1;
				else if (lockedCountOne > lockedCountTwo)
					return 1;
			}

			return 0;
		}

		private function layout():void
		{
			var len:uint = _contracts.length;
			var tradeRouteDisplay:TradeRouteDisplay;
			var xPos:int = 30;
			var yPos:int = 60;
			for (var i:uint = 0; i < len; ++i)
			{
				tradeRouteDisplay = _contracts[i];
				tradeRouteDisplay.x = xPos;
				tradeRouteDisplay.y = yPos;
				xPos += tradeRouteDisplay.width + 5;
			}
		}
		
		[Inject]
		public function set presenter( value:ITradePresenter ):void  { _presenter = value; }
		public function get presenter():ITradePresenter  { return ITradePresenter(_presenter); }

		override public function get typeUnique():Boolean  { return false; }

		override public function get height():Number  { return _bg.height; }
		override public function get width():Number  { return _bg.width; }

		override public function destroy():void
		{
			presenter.removeTransactionListener(onUpdatedTradeRouteTransaction);

			var len:uint = _contracts.length;
			var tradeRouteDisplay:TradeRouteDisplay;
			for (var i:uint = 0; i < len; ++i)
			{
				tradeRouteDisplay = _contracts[i];
				tradeRouteDisplay.destroy();
				tradeRouteDisplay = null;
			}
			_contracts.length = 0;

			_bg = null;
			_closeBtn.destroy();
			_closeBtn = null;

			_viewName.destroy();
			_viewName = null;

			_creditsSymbol = null;
			_alloySymbol = null;
			_energySymbol = null;
			_syntheticsSymbol = null;


			_creditGain.destroy();
			_creditGain = null;

			_energyGain.destroy();
			_energyGain = null;

			_alloyGain.destroy();
			_alloyGain = null;

			_syntheticGain.destroy();
			_syntheticGain = null;

			_productionOverview.destroy();
			_productionOverview = null;

			super.destroy();
		}
	}
}
