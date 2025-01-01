package com.service.server.outgoing.starbase
{
	import com.enum.server.RequestEnum;
	import com.service.server.outgoing.TransactionRequest;

	import flash.utils.ByteArray;

	public class StarbaseLaunchFleetRequest extends TransactionRequest
	{
		public var fleets:Array;

		public override function write( output:ByteArray ):void
		{
			super.write(output);
			var len:uint = fleets.length;
			output.writeUnsignedInt(len);
			for (var i:uint = 0; i < len; ++i)
				output.writeUTF(fleets[i].id);

			output.writeInt(RequestEnum.BINARY_OBJECT_SEQUENCE_TOKEN_END);
		}

		public override function destroy():void
		{
		}
	}
}
