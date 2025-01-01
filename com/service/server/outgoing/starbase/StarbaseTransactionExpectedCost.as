package com.service.server.outgoing.starbase
{
	import flash.utils.ByteArray;

	public class StarbaseTransactionExpectedCost
	{
		public var time_cost_milliseconds:int;
		public var alloyCost:int;
		public var syntheticCost:int;
		public var energyCost:int;
		public var creditsCost:int;
		public var hardCurrencyCost:int;

		public function write( purchaseType:int, output:ByteArray ):void
		{
			output.writeInt(time_cost_milliseconds);
			output.writeInt(alloyCost);
			output.writeInt(syntheticCost);
			output.writeInt(energyCost);
			output.writeInt(creditsCost);
			output.writeInt(hardCurrencyCost);
		}

		public function destroy():void
		{
			time_cost_milliseconds = 0;
			alloyCost = 0;
			syntheticCost = 0;
			energyCost = 0;
			creditsCost = 0;
			hardCurrencyCost = 0;
		}
	}
}
