package com.service.server.outgoing.starbase
{
	import com.enum.server.RequestEnum;
	import com.service.server.outgoing.TransactionRequest;

	import flash.utils.ByteArray;

	public class StarbaseMissionAcceptRewardsRequest extends TransactionRequest
	{
		public var missionPersistence:String;

		public override function write( output:ByteArray ):void
		{
			super.write(output);
			output.writeUTF(missionPersistence);
			output.writeInt(RequestEnum.BINARY_OBJECT_SEQUENCE_TOKEN_END);
		}

		public override function destroy():void
		{
		}
	}
}
