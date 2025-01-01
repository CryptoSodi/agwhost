package com.service.server.outgoing.starbase
{
	import com.enum.server.RequestEnum;
	import com.service.server.outgoing.TransactionRequest;

	import flash.utils.ByteArray;

	public class StarbaseBuyOtherStoreItemRequest extends TransactionRequest
	{
		public var storeItemPrototype:String;
		public var itemType:String;
		public var itemAmount:int;
		public var centerSpaceBase:Boolean;

		public override function write( output:ByteArray ):void
		{
			super.write(output);
			output.writeUTF(storeItemPrototype);
			output.writeUTF(itemType);
			output.writeInt(itemAmount);
			output.writeBoolean(centerSpaceBase);
			writeExpectedCosts(output);
			output.writeInt(RequestEnum.BINARY_OBJECT_SEQUENCE_TOKEN_END);
		}

		public override function destroy():void
		{
			super.destroy();
		}
	}
}
