package com.service.server.outgoing.starbase
{
	import com.enum.server.RequestEnum;
	import com.service.server.outgoing.TransactionRequest;
	
	import flash.utils.ByteArray;
	
	public class StarbaseMoveStarbaseToTransgateRequest extends TransactionRequest
	{
		public var targetSector:String;
		public var targetTransgate:String;
		
		public override function write( output:ByteArray ):void
		{
			super.write(output);
			output.writeUTF(targetSector);
			output.writeUTF(targetTransgate);
			writeExpectedCosts(output);
			output.writeInt(RequestEnum.BINARY_OBJECT_SEQUENCE_TOKEN_END);
		}
		
		public override function destroy():void
		{
			super.destroy();
		}
	}
}
