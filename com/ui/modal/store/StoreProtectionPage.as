package com.ui.modal.store
{
	import com.model.prototype.IPrototype;

	public class StoreProtectionPage extends StorePage
	{
		private var _allBtn:String          = 'CodeString.Store.AllBtn'; //All

		private var _protectionTitle:String = 'CodeString.Store.ProtectionTitle'; //Protection
		private var _baseProtection:String  = 'CodeString.Store.BaseProtection'; //Base Protection

		public function StoreProtectionPage( items:Vector.<IPrototype> )
		{
			super(items);

			addFilterBtn(null, _allBtn, 3, false);

			addFilterHeader(_protectionTitle, 5, 7);
			addFilterBtn('Protection', _baseProtection, 3);
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
	}
}
