package com.service.server.outgoing.starbase
{
	import com.enum.server.RequestEnum;
	import com.service.server.outgoing.TransactionRequest;

	import flash.utils.ByteArray;

	public class StarbaseMissionStepRequest extends TransactionRequest
	{
		public var missionPrototype:String;
		public var progress:int;


		public override function write( output:ByteArray ):void
		{
			super.write(output);
			output.writeUTF(missionPrototype);
			output.writeInt(progress);
			output.writeInt(RequestEnum.BINARY_OBJECT_SEQUENCE_TOKEN_END);
		}

		public override function destroy():void
		{
		}
	}
}
