package com.service.server.outgoing.starbase
{
	import com.enum.server.RequestEnum;
	import com.service.server.outgoing.TransactionRequest;

	import flash.utils.ByteArray;

	public class StarbaseRecycleShipRequest extends TransactionRequest
	{
		public var shipPersistence:String;
		public var expectedRefund:StarbaseTransactionExpectedCost = new StarbaseTransactionExpectedCost;

		public override function write( output:ByteArray ):void
		{
			super.write(output);
			output.writeUTF(shipPersistence);
			writeExpectedCosts(output);
			output.writeInt(RequestEnum.BINARY_OBJECT_SEQUENCE_TOKEN_END);
		}

		public override function destroy():void
		{
		}
	}
}
