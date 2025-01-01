package com.service.server.outgoing.starbase
{
	import com.enum.server.RequestEnum;
	import com.service.server.outgoing.TransactionRequest;

	import flash.utils.ByteArray;

	public class StarbaseBuyStoreItemRequest extends TransactionRequest
	{
		public var buffPrototype:String;
		public var centerSpaceBase:Boolean;

		public override function write( output:ByteArray ):void
		{
			super.write(output);
			output.writeUTF(buffPrototype);
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
