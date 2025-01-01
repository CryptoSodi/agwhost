package com.ui.hud.shared.command
{
	import com.enum.CurrencyEnum;
	import com.enum.ui.PanelEnum;
	import com.model.starbase.BaseVO;
	import com.model.starbase.BuildingVO;
	import com.model.starbase.TradeRouteVO;
	import com.model.transaction.TransactionVO;
	import com.presenter.shared.CommandPresenter;
	import com.presenter.shared.ICommandPresenter;
	import com.presenter.starbase.ITradePresenter;
	import com.service.language.Localization;
	import com.ui.UIFactory;
	import com.ui.core.ScaleBitmap;
	import com.ui.core.View;
	import com.ui.core.component.tooltips.Tooltips;
	import com.ui.modal.construction.ConstructionInfoView;
	import com.ui.modal.construction.ConstructionView;
	import com.ui.modal.store.StoreView;
	import com.ui.modal.traderoute.overview.TradeRouteOverviewView;

	import flash.geom.Point;
	import flash.utils.Dictionary;

	import org.adobe.utils.StringUtil;
	import org.parade.core.IView;
	import org.parade.enum.ViewEnum;
	import org.shared.ObjectPool;

	public class ResourceTradeCommandView extends View
	{
		[Inject]
		public var tooltip:Tooltips;

		[Inject]
		public var tradePresenter:ITradePresenter;

		//art has declared a universal padding of 4
		static private const PADDING:Number      = 4;
		static private const PBAR_SIZE:Point     = new Point(90, 20);

		private var _contracts:Array             = [];
		private var _currentBase:BaseVO;

		private var _tradeSectionBkgd:ScaleBitmap;
		private var _resrcSectionBkgd:ScaleBitmap;

		private var _resTooltips:Vector.<String> = Vector.<String>(["CodeString.Resources.CreditsTooltip", "CodeString.Resources.AlloyTooltip", "CodeString.Resources.EnergyTooltip", "CodeString.Resources.SyntheticsTooltip"]);

		private var _tradeComp0:TradeRouteComponent;
		private var _tradeComp1:TradeRouteComponent;
		private var _tradeComp2:TradeRouteComponent;
		private var _resourceComponent:ResourceComponent;

		[PostConstruct]
		override public function init():void
		{
			super.init();
			presenter.removeStateListener(onStateChange);
			tradePresenter.addTransactionListener(onUpdateTradeRouteTransactions);

			_currentBase = presenter.currentBase;

			if (_currentBase)
				_currentBase.onResourcesChange.add(onMoneyTick);

			createChildren();
			onMoneyTick();

			onUpdateTradeRouteTransactions(null);
		}

		private function onUpdateTradeRouteTransactions( transaction:TransactionVO ):void
		{
			_contracts = [];

			var _routes:Vector.<TradeRouteVO> = tradePresenter.tradeRoutes.concat();
			_routes.sort(function( a:TradeRouteVO, b:TradeRouteVO ):int
			{
				if (!a)
					return -1;
				if (!b)
					return 1;

				return a.end > b.end ? -1 : 1;
			});

			for (var vo:TradeRouteVO, i:int; i < _routes.length; i++)
			{
				vo = _routes[i];

				if (_contracts.length < tradePresenter.maxUnlockedContracts)
				{
					if (vo.end > 0)
						_contracts.unshift(vo);
					else
						_contracts.push(true);
				} else if (_contracts.length < 3)
					_contracts.push(null);
			}
			for (i = 0; i < _contracts.length; i++)
			{
				if (i>2)
					continue;
				
				if (this["_tradeComp" + i] != null)
					this["_tradeComp" + i].update(_contracts[i]);
			}
		}

		protected function createChildren():void
		{
			_tradeSectionBkgd = UIFactory.getPanel(PanelEnum.CONTAINER_NOTCHED_RIGHT_SMALL, 343, 114, 6, 5);
			addChild(_tradeSectionBkgd);

			_resrcSectionBkgd = UIFactory.getPanel(PanelEnum.CONTAINER_DOUBLE_NOTCHED, 343, 81, 6, _tradeSectionBkgd.y + _tradeSectionBkgd.height + 4);
			addChild(_resrcSectionBkgd);

			//////////////////////////
			//	TRADEROUTE SECTION
			//////////////////////////

			_tradeComp0 = new TradeRouteComponent();
			_tradeComp0.tradePresenter = tradePresenter;
			_tradeComp0.init();
			_tradeComp0.x = 47;
			_tradeComp0.y = 12;
			_tradeComp0.onClick.add(onContractClick);
			addChild(_tradeComp0);

			_tradeComp1 = new TradeRouteComponent();
			_tradeComp1.tradePresenter = tradePresenter;
			_tradeComp1.init();
			_tradeComp1.x = _tradeComp0.x + 100;
			_tradeComp1.y = 12;
			_tradeComp1.onClick.add(onContractClick);
			addChild(_tradeComp1);

			_tradeComp2 = new TradeRouteComponent();
			_tradeComp2.tradePresenter = tradePresenter;
			_tradeComp2.init();
			_tradeComp2.x = _tradeComp1.x + 100;
			_tradeComp2.y = 12;
			_tradeComp2.onClick.add(onContractClick);
			addChild(_tradeComp2);

			//////////////////////////
			//	RESOURCE SECTION
			//////////////////////////

			_resourceComponent = ObjectPool.get(ResourceComponent);
			_resourceComponent.init(true, true, 40);
			_resourceComponent.x = 20;
			_resourceComponent.y = _resrcSectionBkgd.y + 5;
			_resourceComponent.addMoreListener(onMoreClicked);

			tooltip.addTooltip(_resourceComponent.alloyHolder, this, getAlloyTooltip, '', 250, 180, 18, true);
			tooltip.addTooltip(_resourceComponent.creditsHolder, this, getCreditTooltip, '', 250, 180, 18, true);
			tooltip.addTooltip(_resourceComponent.energyHolder, this, getEnergyTooltip, '', 250, 180, 18, true);
			tooltip.addTooltip(_resourceComponent.syntheticHolder, this, getSyntheticTooltip, '', 250, 180, 18, true);
			addChild(_resourceComponent);

			onMoneyTick();
		}

		private function onContractClick( state:String ):void
		{
			if (!presenter.hudEnabled)
				return;
			if (state != TradeRouteComponent.STATE_LOCKED)
			{
				var view:IView = _viewFactory.createView(TradeRouteOverviewView);
				_viewFactory.notify(view);
			} else
			{
				var building:BuildingVO = presenter.getBuildingVOByClass('Surveillance');
				if (building)
				{
					var upgradeView:ConstructionInfoView = ConstructionInfoView(_viewFactory.createView(ConstructionInfoView));
					upgradeView.setup(ConstructionView.BUILD, building);
					_viewFactory.notify(upgradeView);
				}
			}
		}

		private function onMoneyTick():void
		{
			_resourceComponent.updateResource(presenter.currentBase.alloy, presenter.currentBase.maxResources, CurrencyEnum.ALLOY);
			_resourceComponent.updateResource(presenter.currentBase.credits, presenter.currentBase.maxCredits, CurrencyEnum.CREDIT);
			_resourceComponent.updateResource(presenter.currentBase.energy, presenter.currentBase.maxResources, CurrencyEnum.ENERGY);
			_resourceComponent.updateResource(presenter.currentBase.synthetic, presenter.currentBase.maxResources, CurrencyEnum.SYNTHETIC);
		}

		private function getCreditTooltip():String
		{
			var resourceTooltipDict:Dictionary = new Dictionary();
			resourceTooltipDict['[[Number.BaseResourceCount]]'] = StringUtil.commaFormatNumber(_currentBase.credits);
			resourceTooltipDict['[[Number.MaxResourceCount]]'] = StringUtil.commaFormatNumber(_currentBase.maxCredits);

			return Localization.instance.getStringWithTokens(_resTooltips[0], resourceTooltipDict);
		}

		private function getAlloyTooltip():String
		{
			var resourceTooltipDict:Dictionary = new Dictionary();
			resourceTooltipDict['[[Number.BaseResourceCount]]'] = StringUtil.commaFormatNumber(_currentBase.alloy);
			resourceTooltipDict['[[Number.MaxResourceCount]]'] = StringUtil.commaFormatNumber(_currentBase.maxResources);

			return Localization.instance.getStringWithTokens(_resTooltips[1], resourceTooltipDict);
		}

		private function getEnergyTooltip():String
		{
			var resourceTooltipDict:Dictionary = new Dictionary();
			resourceTooltipDict['[[Number.BaseResourceCount]]'] = StringUtil.commaFormatNumber(_currentBase.energy);
			resourceTooltipDict['[[Number.MaxResourceCount]]'] = StringUtil.commaFormatNumber(_currentBase.maxResources);

			return Localization.instance.getStringWithTokens(_resTooltips[2], resourceTooltipDict);
		}

		private function getSyntheticTooltip():String
		{
			var resourceTooltipDict:Dictionary = new Dictionary();
			resourceTooltipDict['[[Number.BaseResourceCount]]'] = StringUtil.commaFormatNumber(_currentBase.synthetic);
			resourceTooltipDict['[[Number.MaxResourceCount]]'] = StringUtil.commaFormatNumber(_currentBase.maxResources);

			return Localization.instance.getStringWithTokens(_resTooltips[3], resourceTooltipDict);
		}

		private function onMoreClicked( currency:String ):void
		{
			if (!presenter.hudEnabled)
				return;
			var storeView:StoreView = StoreView(showView(StoreView));
			var filter:uint         = StoreView.FILTER_ALLOY;
			if (currency == CurrencyEnum.CREDIT)
				filter = StoreView.FILTER_CREDITS;
			else if (currency == CurrencyEnum.ENERGY)
				filter = StoreView.FILTER_ENERGY;
			else if (currency == CurrencyEnum.SYNTHETIC)
				filter = StoreView.FILTER_SYNTHETIC;
			storeView.openToResourcesAndFilter(filter);
		}

		[Inject]
		public function set presenter( value:ICommandPresenter ):void  { _presenter = value; }
		public function get presenter():ICommandPresenter  { return CommandPresenter(_presenter); }

		override public function get type():String  { return ViewEnum.UI; }

		override public function destroy():void
		{
			super.destroy();

			tradePresenter.removeTransactionListener(onUpdateTradeRouteTransactions);
			tradePresenter = null;

			if (_currentBase)
				_currentBase.onResourcesChange.remove(onMoneyTick);

			_currentBase = null;

			tooltip.removeTooltip(null, this);
			tooltip = null;

			for (var tradeComp:TradeRouteComponent, i:int; i < 3; i++)
			{
				tradeComp = this["_tradeComp" + i];
				tradeComp.destroy();

				this["_tradeComp" + i] = null;
			}

			ObjectPool.give(_resourceComponent);
			_resourceComponent = null;
		}
	}
}
