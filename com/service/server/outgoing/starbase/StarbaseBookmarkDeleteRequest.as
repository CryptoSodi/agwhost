package com.service.server.outgoing.starbase
{
	import com.enum.server.RequestEnum;
	import com.service.server.outgoing.TransactionRequest;

	import flash.utils.ByteArray;

	public class StarbaseBookmarkDeleteRequest extends TransactionRequest
	{
		public var index:int;

		public override function write( output:ByteArray ):void
		{
			super.write(output);
			output.writeUnsignedInt(index);
			output.writeInt(RequestEnum.BINARY_OBJECT_SEQUENCE_TOKEN_END);
		}

		public override function destroy():void
		{
			super.destroy();
		}
	}
}
