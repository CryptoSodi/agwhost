package com.service.server.outgoing.starbase
{
	import com.enum.server.RequestEnum;
	import com.service.server.outgoing.TransactionRequest;

	import flash.utils.ByteArray;

	public class StarbaseSetClientSettingsRequest extends TransactionRequest
	{
		public var settings:String;

		public override function write( output:ByteArray ):void
		{
			super.write(output);
			output.writeUTF(settings);
			output.writeInt(RequestEnum.BINARY_OBJECT_SEQUENCE_TOKEN_END);
		}

		public override function destroy():void
		{
		}
	}
}
