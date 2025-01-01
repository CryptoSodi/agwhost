package com.ui.modal.battle.chance
{
	import com.model.asset.AssetVO;
	import com.model.battle.BattleRerollVO;
	import com.model.blueprint.BlueprintVO;
	import com.model.prototype.IPrototype;
	import com.presenter.shared.IGameOfChancePresenter;
	import com.presenter.shared.IUIPresenter;
	import com.ui.core.DefaultWindowBG;
	import com.ui.core.View;
	import com.ui.core.component.bar.VScrollbar;
	import com.ui.core.component.tooltips.Tooltips;
	import com.ui.modal.battlelog.BattleLogEntry;

	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;

	import org.shared.ObjectPool;

	public class GameOfChanceListView extends View
	{
		private var _bg:DefaultWindowBG;
		private var _chances:Vector.<ChanceGameDisplayComponent>;
		private var _holder:Sprite;
		private var _maxHeight:int;
		private var _scrollbar:VScrollbar;
		private var _scrollRect:Rectangle;
		private var _tooltips:Tooltips;

		private var _titleText:String = 'CodeString.PendingScans.Title'; //PENDING SCANS

		[PostConstruct]
		override public function init():void
		{
			super.init();

			_chances = new Vector.<ChanceGameDisplayComponent>;

			_bg = ObjectPool.get(DefaultWindowBG);
			_bg.setBGSize(500, 425);
			_bg.addTitle(_titleText, 135);
			addListener(_bg.closeButton, MouseEvent.CLICK, onClose);

			_holder = new Sprite();
			_holder.x = 26;
			_holder.y = 50;
			_maxHeight = 0;

			_scrollRect = new Rectangle(0, 0, 580, 395);
			_scrollRect.y = 0;
			_holder.scrollRect = _scrollRect;

			_scrollbar = new VScrollbar();
			var dragBarBGRect:Rectangle         = new Rectangle(0, 4, 5, 3);
			var scrollbarXPos:Number            = 492;
			var scrollbarYPos:Number            = 57;
			_scrollbar.init(7, _scrollRect.height - 10, scrollbarXPos, scrollbarYPos, dragBarBGRect, '', 'ScrollbarBMD', '', false, this);
			_scrollbar.onScrollSignal.add(onChangedScroll);
			_scrollbar.updateScrollableHeight(_maxHeight);
			_scrollbar.updateDisplayedHeight(_scrollRect.height);
			_scrollbar.maxScroll = 28.25;

			addChild(_bg);
			addChild(_scrollbar);
			addChild(_holder);

			presenter.addAvailableRerollUpdatedListener(onAvailableRerollsUpdated);
			presenter.addRerollFromRerollCallback(onRerollUpdated);
			presenter.addRerollFromScanCallback(onRerollUpdated);

			var rerolls:Vector.<BattleRerollVO> = presenter.getAvailableRerolls();

			//var vo:BattleRerollVO               = new BattleRerollVO("sector.2.battle.14.1368552417881", "player.502.blueprint.1", 300000);
			for each (var vo:BattleRerollVO in rerolls)
				onAvailableRerollsUpdated(vo);

			addEffects();
			effectsIN();
		}

		public function onRerollUpdated( vo:BattleRerollVO ):void
		{
			for each (var chanceComponent:ChanceGameDisplayComponent in _chances)
			{
				if (chanceComponent.battleRerollVO == vo)
				{
					if (vo.blueprintPrototype != '')
						updateBlueprint(chanceComponent, vo);
					else
					{
						chanceComponent.x -= 48;
						chanceComponent.showGainedResourcesView(vo);
					}
				}
			}
		}

		private function onAvailableRerollsUpdated( vo:BattleRerollVO ):void
		{
			if (!vo.isReroll && !vo.hasPaid)
				createScanView(vo);
			else if (vo.isReroll && !vo.hasPaid)
				createRerollView(vo);

			layout();
		}

		private function createScanView( vo:BattleRerollVO ):void
		{
			var chanceComp:ChanceGameDisplayComponent = new ChanceGameDisplayComponent();
			chanceComp.battleRerollVO = vo;
			chanceComp.scanCost = presenter.getConstantPrototypeValueByName('rerollLootPrice');
			chanceComp.getBlueprintPrototype = presenter.getBlueprintPrototypeByName;
			chanceComp.getResearchPrototypeByName = presenter.getResearchPrototypeByName;
			chanceComp.getSelectionInfo = getSelectionInfo
			chanceComp.scanClickSignal.add(onScanClick);
			chanceComp.denyClickSignal.add(onDenyClick);
			chanceComp.showScanView();
			_chances.push(chanceComp);
			_holder.addChild(chanceComp);
		}

		private function createRerollView( vo:BattleRerollVO ):void
		{
			if (vo && _holder)
			{
				var blueprintVO:BlueprintVO;
				if (vo.recievedBlueprintPrototype)
					blueprintVO = presenter.getBlueprintByID(vo.recievedBlueprintPrototype);
				else if (vo.blueprintPrototype)
					blueprintVO = presenter.getBlueprintByName(vo.blueprintPrototype);
				var bpAsset:AssetVO = presenter.getAssetVO(blueprintVO.uiAsset);

				if (blueprintVO)
				{
					var chanceComp:ChanceGameDisplayComponent = new ChanceGameDisplayComponent();
					chanceComp.battleRerollVO = vo;
					chanceComp.loadIconSignal.add(presenter.loadIcon);
					chanceComp.onPurchaseComplete.add(onBlueprintPurchase);
					chanceComp.denyClickSignal.add(onDenyClick);
					chanceComp.rollCost = presenter.getConstantPrototypeValueByName('rerollItemPrice');

					chanceComp.getBlueprintPrototype = presenter.getBlueprintPrototypeByName;
					chanceComp.getResearchPrototypeByName = presenter.getResearchPrototypeByName;
					chanceComp.getSelectionInfo = getSelectionInfo

					_tooltips.addTooltip(chanceComp.blueprintShipIcon, this, chanceComp.getTooltip);
					chanceComp.init(blueprintVO);
					chanceComp.rerollClickSignal.add(onRerollClick);
					chanceComp.showBlueprint(vo.blueprintPrototype, blueprintVO, bpAsset, presenter.getBlueprintHardCurrencyCost(blueprintVO, blueprintVO.partsRemaining));
					_chances.push(chanceComp);
					_holder.addChild(chanceComp);
				}
			}
		}

		private function updateBlueprint( chanceComponent:ChanceGameDisplayComponent, vo:BattleRerollVO ):void
		{
			var blueprintVO:BlueprintVO;
			if (vo.blueprintPrototype)
				blueprintVO = presenter.getBlueprintByName(vo.blueprintPrototype);
			if (vo.recievedBlueprintPrototype && !blueprintVO)
				blueprintVO = presenter.getBlueprintByID(vo.recievedBlueprintPrototype);

			var bpAsset:AssetVO = presenter.getAssetVO(blueprintVO.uiAsset);

			chanceComponent.battleRerollVO = vo;
			chanceComponent.loadIconSignal.add(presenter.loadIcon);
			chanceComponent.onPurchaseComplete.add(onBlueprintPurchase);
			chanceComponent.rollCost = presenter.getConstantPrototypeValueByName('rerollItemPrice');
			//Get BP tooltip
			_tooltips.addTooltip(chanceComponent.blueprintShipIcon, chanceComponent, chanceComponent.getTooltip);
			chanceComponent.init(blueprintVO);
			chanceComponent.rerollClickSignal.add(onRerollClick);
			chanceComponent.updateBlueprint(vo.blueprintPrototype, blueprintVO, bpAsset, presenter.getBlueprintHardCurrencyCost(blueprintVO, blueprintVO.partsRemaining));
		}

		protected function layout():void
		{
			var len:uint = _chances.length;
			var selection:ChanceGameDisplayComponent;
			var yPos:int = 00;
			_maxHeight = 0;
			for (var i:uint = 0; i < len; ++i)
			{
				selection = _chances[i];
				selection.y = yPos;
				_maxHeight += selection.height;
				yPos += selection.height;
			}
			_scrollbar.updateScrollableHeight(_maxHeight);
		}

		private function onChangedScroll( percent:Number ):void
		{
			_scrollRect.y = (_maxHeight - _scrollRect.height) * percent;
			_holder.scrollRect = _scrollRect;
		}

		private function orderItems( itemOne:BattleLogEntry, itemTwo:BattleLogEntry ):Number
		{

			if (!itemOne)
				return -1;
			if (!itemTwo)
				return 1;

			var timeOccurredOne:Number = itemOne.timeOccurred;
			var timeOccurredTwo:Number = itemTwo.timeOccurred;

			if (timeOccurredOne < timeOccurredTwo)
				return -1;
			else if (timeOccurredOne > timeOccurredTwo)
				return 1;

			return 0;
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

		private function onRerollClick( battleID:String, name:String ):void
		{
			presenter.removeBlueprintByName(name);
			presenter.purchaseReroll(battleID);
		}

		private function onScanClick( battleID:String ):void
		{
			presenter.purchaseDeepScan(battleID);
		}

		private function onBlueprintPurchase( blueprintID:String, battleID:String ):void
		{
			var vo:BlueprintVO = presenter.getBlueprintByID(blueprintID);
			presenter.purchaseBlueprint(vo, vo.partsRemaining);
			presenter.removeRerollFromAvailable(battleID);
		}

		private function onDenyClick( battleID:String ):void
		{
			presenter.removeRerollFromAvailable(battleID);
		}

		override public function get height():Number  { return _bg.height; }
		override public function get width():Number  { return _bg.width; }

		[Inject]
		public function set presenter( value:IGameOfChancePresenter ):void  { _presenter = value; }
		public function get presenter():IGameOfChancePresenter  { return IGameOfChancePresenter(_presenter); }
		[Inject]
		public function set tooltips( value:Tooltips ):void  { _tooltips = value; }

		override public function destroy():void
		{
			presenter.removeAvailableRerollUpdatedListener(onAvailableRerollsUpdated);
			presenter.removeRerollFromRerollCallback(onRerollUpdated);
			presenter.removeRerollFromScanCallback(onRerollUpdated);

			super.destroy();

			ObjectPool.give(_bg);
			_bg = null;

			_holder = null;

			_scrollbar.destroy();
			_scrollbar = null;

			_maxHeight = 0;

			_tooltips.removeTooltip(null, this);
			_tooltips = null;

			_chances = null;


		}
	}
}
