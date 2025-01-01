package com.ui.modal.store
{
	import com.model.prototype.IPrototype;

	public class StoreOtherPage extends StorePage
	{
		private var _allBtn:String          = 'CodeString.Store.AllBtn'; //All

		public function StoreOtherPage( items:Vector.<IPrototype> )
		{
			super(items);

			addFilterBtn(null, _allBtn, 3, false);

			_filterList.selectFilterByIndex(0);
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
		
		override protected function buy( item:StoreItem ):void
		{
			if (item.canAfford)
			{
				var itemPrototype:IPrototype = item.itemProto;
				if (itemPrototype.getValue('resourceType') == 'shipSlots')
				{
					var resourceAmount:uint = itemPrototype.getValue('resourceAmount');
					_presenter.buyOtherItemTransaction(itemPrototype, resourceAmount, false, item.cost);
				} else
				{
				}
			} else
				_openWindow(WINDOW_CANNOT_AFFORD);
		}
	}
}
