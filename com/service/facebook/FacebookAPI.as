package com.service.facebook
{
	import com.service.ExternalInterfaceAPI;
	
	public class FacebookAPI
	{
		private var _purchaseItemsCallback:Function;
		
		public function purchaseCurrency( quantity:int, callback:Function ):void
		{
			_purchaseItemsCallback = callback;
			ExternalInterfaceAPI.OpenFacebookPaywall(quantity);
		}
		
		public function onFacebookItemsPurchased( response:Object ):void
		{
			if (_purchaseItemsCallback != null)
			{
				_purchaseItemsCallback(response)
				_purchaseItemsCallback = null;
			}
		}
	}
}