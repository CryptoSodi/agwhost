package com.controller.transaction.requirements
{
	public class PurchaseVO
	{
		public var alloyCost:uint;
		public var creditsCost:uint;
		public var energyCost:uint;
		public var premium:int;
		public var syntheticCost:uint;

		public var alloyAmountShort:int;
		public var creditsAmountShort:int;
		public var energyAmountShort:int;
		public var premiumAmountShort:int;
		public var syntheticAmountShort:int;
		public var resourcePremiumCost:int;

		public var canPurchase:Boolean;
		public var canPurchaseWithPremium:Boolean;
		public var canPurchaseResourcesWithPremium:Boolean;
		public var costExceedsMaxResources:Boolean;

		public function reset():void
		{
			alloyAmountShort = 0;
			creditsAmountShort = 0;
			energyAmountShort = 0;
			premiumAmountShort = 0;
			syntheticAmountShort = 0;
			resourcePremiumCost = 0;

			canPurchase = true;
			canPurchaseWithPremium = true;
			canPurchaseResourcesWithPremium = true;
			costExceedsMaxResources = false;

			premium = 0;
		}
	}
}
