package com.service.server.outgoing.starbase
{
	import com.enum.server.RequestEnum;
	import com.service.server.outgoing.TransactionRequest;

	import flash.utils.ByteArray;

	public class StarbaseBuyResourceRequest extends TransactionRequest
	{
		public var resource:String;
		public var percent:int;
		public var centerSpaceBase:Boolean;

		public override function write( output:ByteArray ):void
		{
			super.write(output);
			output.writeUTF(resource);
			output.writeInt(percent);
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
