package com.service.server.outgoing.starbase
{
	import com.enum.server.RequestEnum;
	import com.service.server.outgoing.TransactionRequest;

	import flash.utils.ByteArray;

	public class StarbaseRepairBaseRequest extends TransactionRequest
	{
		public var centerSpaceBase:Boolean;

		public override function write( output:ByteArray ):void
		{
			super.write(output);
			output.writeInt(purchaseType);
			output.writeBoolean(centerSpaceBase);
			output.writeInt(RequestEnum.BINARY_OBJECT_SEQUENCE_TOKEN_END);
		}

		public override function destroy():void
		{
			super.destroy();
		}
	}
}
