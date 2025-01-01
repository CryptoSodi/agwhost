package com.ui.modal.store
{
	import com.Application;
	import com.model.prototype.IPrototype;
	import com.ui.core.component.bar.VScrollbar;

	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.text.TextFormatAlign;

	public class StoreBuffPage extends StorePage
	{
		private var _filtersMask:Rectangle;
		private var _filterScrollbar:VScrollbar;
		private var _filtersMaxHeight:Number;

		private var _allBtn:String           = 'CodeString.Store.AllBtn'; //All

		private var _incomeTitle:String      = 'CodeString.Store.IncomeTitle'; //Resource Boosts
		private var _incomeFull:String       = 'CodeString.Store.IncomeFull'; //Income +100%
		private var _incomeHalf:String       = 'CodeString.Store.IncomeHalf'; //Income +50%

		private var _creditsTitle:String     = 'CodeString.Store.CreditsBoostsTitle'; //Credits Boosts
		private var _creditsFull:String      = 'CodeString.Store.CreditsFull'; //Credits +100%
		private var _creditsHalf:String      = 'CodeString.Store.CreditsHalf'; //Credits +50%

		private var _alloyTitle:String       = 'CodeString.Store.AlloyBoostsTitle'; //Alloy Boosts
		private var _alloyFull:String        = 'CodeString.Store.AlloyFull'; //Alloy +100%
		private var _alloyHalf:String        = 'CodeString.Store.AlloyHalf'; //Alloy +50%

		private var _energyTitle:String      = 'CodeString.Store.EnergyBoostsTitle'; //Energy Boosts
		private var _energyFull:String       = 'CodeString.Store.EnergyFull'; //Energy +100%
		private var _energyHalf:String       = 'CodeString.Store.EnergyHalf'; //Energy +50%

		private var _syntheticsTitle:String  = 'CodeString.Store.SyntheticsBoostsTitle'; //Synthetics Boosts
		private var _syntheticsFull:String   = 'CodeString.Store.SyntheticsFull'; //Synthetics +100%
		private var _syntheticsHalf:String   = 'CodeString.Store.SyntheticsHalf'; //Synthetics +50%

		private var _buildBoostsTitle:String = 'CodeString.Store.BuildBoostsTitle'; //Build Boosts
		private var _buildSpeedFull:String   = 'CodeString.Store.BuildSpeedFull'; //Build Speed +100%
		private var _buildSpeedHalf:String   = 'CodeString.Store.BuildSpeedHalf'; //Build Speed +50%
		private var _buildTime:String        = 'CodeString.Store.BuildTime'; //Build Time

		private var _fleetBoostsTitle:String = 'CodeString.Store.FleetBoostsTitle'; //Fleet Boosts
		private var _fleetSpeed:String       = 'CodeString.Store.FleetSpeed'; //Fleet Speed
		private var _cargoCapacity:String    = 'CodeString.Store.CargoCapacity'; //Cargo Capacity

		private var _buffsTitle:String       = 'CodeString.Store.Buffs';
		private var _Salvage:String          = 'CodeString.Store.SalvageBuffs';
		private var _Bounty:String           = 'CodeString.Store.BountyBuffs';
		private var _repairSpeed:String      = 'CodeString.Store.RepairSpeedBuffs';
		private var _treasureFinding:String  = 'CodeString.Store.TreasureFindingBuffs';

		public function StoreBuffPage( items:Vector.<IPrototype> )
		{

			super(items);

			addFilterBtn(null, _allBtn, 3, false);
			/*
			   addFilterHeader(_incomeTitle, 5, 6);
			   addFilterBtn('Income_Full', _incomeFull, 3);
			   addFilterBtn('Income_Half', _incomeHalf, 3);

			   addFilterHeader(_creditsTitle, 5, 6);
			   addFilterBtn('Credits_Full', _creditsFull, 3);
			   addFilterBtn('Credits_Half', _creditsHalf, 3);

			   addFilterHeader(_alloyTitle, 5, 6);
			   addFilterBtn('Alloy_Full', _alloyFull, 3);
			   addFilterBtn('Alloy_Half', _alloyHalf, 3);

			   addFilterHeader(_energyTitle, 5, 6);
			   addFilterBtn('Energy_Full', _energyFull, 3);
			   addFilterBtn('Energy_Half', _energyHalf, 3);

			   addFilterHeader(_syntheticsTitle, 5, 6);
			   addFilterBtn('Synth_Full', _syntheticsFull, 3);
			   addFilterBtn('Synth_Half', _syntheticsHalf, 3);

			   addFilterHeader(_buildBoostsTitle, 5, 6);
			   addFilterBtn('Build_Speed_Full', _buildSpeedFull, 3);
			   addFilterBtn('Build_Speed_Half', _buildSpeedHalf, 3);
			   addFilterBtn('Build_Time', _buildTime, 3);

			   addFilterHeader(_fleetBoostsTitle, 5, 6);
			   addFilterBtn('Fleet_Speed', _fleetSpeed, 3);
			   addFilterBtn('Cargo', _cargoCapacity, 3);
			 */

			addFilterHeader(_buffsTitle, 5, 6);
			addFilterBtn('Treasure_Finding', _treasureFinding, 3);
			addFilterBtn('Repair_Speed', _repairSpeed, 3);
			addFilterBtn('Salvage', _Salvage, 3);
			addFilterBtn('Bounty', _Bounty, 3);

			_filtersMaxHeight = _filterList.height;

			_filtersMask = new Rectangle(0, 0, _filterList.width, 427);

			_filterList.scrollRect = _filtersMask;

			_filterScrollbar = new VScrollbar();
			addChild(_filterScrollbar);
			var scrollbarXPos:Number    = 271;
			var scrollbarYPos:Number    = 109;
			var dragBarBGRect:Rectangle = new Rectangle(0, 4, 5, 3);
			_filterScrollbar.init(7, 427, scrollbarXPos, scrollbarYPos, dragBarBGRect, '', 'ScrollbarBMD', '', false, this);
			_filterScrollbar.onScrollSignal.add(onChangedFilterScroll);
			_filterScrollbar.updateScrollableHeight(_filtersMaxHeight);
			_filterScrollbar.updateDisplayedHeight(_filtersMask.height);
			_filterScrollbar.maxScroll = 7.5;

			_filterList.selectFilterByIndex(0);
		}

		override protected function onRemoved( e:Event ):void
		{
			if (_filterScrollbar)
				_filterScrollbar.enabled = false;

			super.onRemoved(e);
		}

		override protected function onAdded( e:Event ):void
		{
			if (_filterScrollbar)
				_filterScrollbar.enabled = true;

			super.onAdded(e);
		}

		private function onChangedFilterScroll( percent:Number ):void
		{
			_filtersMask.y = (_filtersMaxHeight - _filtersMask.height) * percent;
			_filterList.scrollRect = _filtersMask;
		}

		override public function updateStoreItems( added:Boolean = false ):void
		{
			super.updateStoreItems();
			var timeRemaining:int = 0;
			var len:uint          = _itemComponents.length;
			var currentSpeedUpTime:int;
			var enabled:Boolean;
			var currentItem:StoreItem;
			var currentItemPrototype:IPrototype;
			var cost:int;
			var canAffordCost:Boolean;

			for (var i:uint = 0; i < len; ++i)
			{
				currentItem = _itemComponents[i];
				currentItemPrototype = _items[i];
				cost = getHardCurrencyCost(currentItemPrototype);
				canAffordCost = canAfford(cost);

				currentItem.enabled = true;
				currentItem.canAfford = canAffordCost;
				currentItem.setItemCost(cost);
				canAffordCost = enabled = false;
			}
		}

		override public function destroy():void
		{
			super.destroy();

			_filtersMask = null;
			_filterScrollbar.onScrollSignal.remove(onChangedFilterScroll);
			_filterScrollbar.destroy();
			_filterScrollbar = null;
		}
	}
}
