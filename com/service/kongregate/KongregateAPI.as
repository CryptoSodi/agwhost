package com.service.kongregate
{
	import com.service.ExternalInterfaceAPI;

	public class KongregateAPI
	{
		private var _purchaseItemsCallback:Function;

		public function purchaseItems( items:Array, callback:Function ):void
		{
			_purchaseItemsCallback = callback;
			ExternalInterfaceAPI.purchaseKongregateItems(items);
		}

		public function get gameAuthToken():String
		{
			return ExternalInterfaceAPI.getPlayerKongregateGameAuthToken();
		}

		public function get userName():String
		{
			return ExternalInterfaceAPI.getPlayerKongregateUsername();
		}

		public function get userID():Number
		{
			return ExternalInterfaceAPI.getPlayerKongregateUserId();
		}

		public function onKongregateItemsPurchased( response:Object ):void
		{
			if (_purchaseItemsCallback != null)
			{
				_purchaseItemsCallback(response)
				_purchaseItemsCallback = null;
			}
		}
	}
}
