package com.ui.modal.store
{
	import com.enum.CurrencyEnum;
	import com.model.prototype.IPrototype;
	import com.service.language.Localization;

	import org.adobe.utils.StringUtil;

	public class StoreResourcePage extends StorePage
	{
		private var _allBtn:String         = 'CodeString.Store.AllBtn'; //All

		private var _resourcesTitle:String = 'CodeString.Store.ResourcesTitle'; //Resources
		private var _credits:String        = 'CodeString.Store.Credits'; //Credits
		private var _alloy:String          = 'CodeString.Store.Alloy'; //Alloy
		private var _energy:String         = 'CodeString.Store.Energy'; //Energy
		private var _synthetic:String      = 'CodeString.Store.Synthetic'; //Synthetic
		private var _addResources:String   = 'CodeString.Store.AddResource'; //Adds [[Number.ResourceCount]]

		public function StoreResourcePage( items:Vector.<IPrototype> )
		{
			super(items);

			addFilterBtn(null, _allBtn, 3, false);

			addFilterHeader(_resourcesTitle, 5, 7);
			addFilterBtn('Credits', _credits, 3);
			addFilterBtn('Alloy', _alloy, 3);
			addFilterBtn('Energy', _energy, 3);
			addFilterBtn('Synth', _synthetic, 3);

			_filterList.selectFilterByIndex(0);
		}

		override public function updateStoreItems( added:Boolean = false ):void
		{
			super.updateStoreItems();

			var len:uint                 = _itemComponents.length;
			var locManager:Localization  = Localization.instance;
			var enabled:Boolean;
			var canAffordCost:Boolean;
			var currentItem:StoreItem;
			var currentItemPrototype:IPrototype;
			var resourceType:String;
			var currentCreditsMax:uint   = _presenter.getMaxCredits();
			var currentResourcesMax:uint = _presenter.getMaxResources();
			var currentAlloy:uint        = _presenter.getResourceCount(CurrencyEnum.ALLOY);
			var currentCredit:uint       = _presenter.getResourceCount(CurrencyEnum.CREDIT);
			var currentEnergy:uint       = _presenter.getResourceCount(CurrencyEnum.ENERGY);
			var currentSynthetic:uint    = _presenter.getResourceCount(CurrencyEnum.SYNTHETIC);
			var cost:int;

			var resourcePercent:Number;

			var currentResourceCount:uint;
			var currentMax:uint;
			var resourceAmountToPurchase:uint;

			for (var i:uint = 0; i < len; ++i)
			{
				currentItem = _itemComponents[i];
				currentItemPrototype = _items[i];

				if (currentItemPrototype.getValue('hardCurrencyCost') == -1)
				{
					resourcePercent = currentItemPrototype.getValue('resourceAmount');
					resourcePercent *= 0.01;
					resourceType = currentItemPrototype.getValue('resourceType');
					switch (resourceType)
					{
						case CurrencyEnum.ALLOY:
							currentResourceCount = currentAlloy;
							currentMax = currentResourcesMax;
							break;
						case CurrencyEnum.CREDIT:
							currentResourceCount = currentCredit;
							currentMax = currentCreditsMax;
							break;
						case CurrencyEnum.ENERGY:
							currentResourceCount = currentEnergy;
							currentMax = currentResourcesMax;
							break;
						case CurrencyEnum.SYNTHETIC:
							currentResourceCount = currentSynthetic;
							currentMax = currentResourcesMax;
							break;
					}

					if (resourcePercent == 1)
						resourceAmountToPurchase = currentMax - currentResourceCount;
					else
						resourceAmountToPurchase = currentMax * resourcePercent;


					cost = getHardCurrencyCost(resourceAmountToPurchase, resourceType);
					if ((resourceAmountToPurchase + currentResourceCount) <= currentMax && resourceAmountToPurchase != 0)
					{
						enabled = true;
					}
				} else
				{
					enabled = true;
					cost = getHardCurrencyCost(currentItemPrototype);
				}


				canAffordCost = canAfford(cost);

				var addNumber:String       = '<font color="#fbefaf">' + StringUtil.commaFormatNumber(resourceAmountToPurchase) + '</font>';
				var ItemBonusDetail:String = locManager.getStringWithTokens(_addResources, {'[[Number.ResourceCount]]':addNumber});
				currentItem.setItemDetailSubtext(_presenter.getProtoTypeUIDescriptionText(currentItemPrototype));
				currentItem.setItemBonusDetailSubtext(ItemBonusDetail);
				currentItem.enabled = enabled;
				currentItem.canAfford = canAffordCost;
				currentItem.setItemCost(cost);
				canAffordCost = enabled = false;
			}
		}

		override protected function buy( item:StoreItem ):void
		{
			if (item.canAfford)
			{
				var itemPrototype:IPrototype = item.itemProto;
				if (itemPrototype.getValue('resourceType') != '')
				{
					var resourcePercent:uint = itemPrototype.getValue('resourceAmount');
					_presenter.buyResourceTransaction(itemPrototype, resourcePercent, false, item.cost);
				} else
				{
					_presenter.buyItemTransaction(itemPrototype, false, item.cost);
				}
			} else
				_openWindow(WINDOW_CANNOT_AFFORD);
		}
	}
}
