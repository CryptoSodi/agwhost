package com.service.server.outgoing.starbase
{
	import com.enum.server.RequestEnum;
	import com.service.server.outgoing.TransactionRequest;

	import flash.utils.ByteArray;

	public class StarbaseSpeedUpTransactionRequest extends TransactionRequest
	{
		public var serverKey:String;
		public var milliseconds:int;
		public var fromStore:Boolean;

		public override function write( output:ByteArray ):void
		{
			super.write(output);
			output.writeUTF(serverKey);
			output.writeInt(purchaseType);
			output.writeInt(milliseconds);
			writeExpectedCosts(output);
			output.writeInt(RequestEnum.BINARY_OBJECT_SEQUENCE_TOKEN_END);
		}

		public override function destroy():void
		{
			super.destroy();
		}
	}
}
