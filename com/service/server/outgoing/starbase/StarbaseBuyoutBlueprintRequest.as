package com.service.server.outgoing.starbase
{
	import com.enum.server.RequestEnum;
	import com.service.server.outgoing.TransactionRequest;

	import flash.utils.ByteArray;

	public class StarbaseBuyoutBlueprintRequest extends TransactionRequest
	{
		public var blueprintPersistence:String;
		public var partsPurchased:int;

		public override function write( output:ByteArray ):void
		{
			super.write(output);
			output.writeUTF(blueprintPersistence);
			writeExpectedCosts(output);
			output.writeInt(partsPurchased);
			output.writeInt(RequestEnum.BINARY_OBJECT_SEQUENCE_TOKEN_END);
		}

		public override function destroy():void
		{
			super.destroy();
		}
	}
}
