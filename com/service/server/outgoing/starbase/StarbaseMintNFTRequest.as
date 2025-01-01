package com.service.server.outgoing.starbase
{
	import com.enum.server.RequestEnum;
	import com.service.server.outgoing.TransactionRequest;
	
	import flash.utils.ByteArray;
	
	public class StarbaseMintNFTRequest extends TransactionRequest
	{
		public var tokenType:int;
		public var tokenAmount:int;
		public var tokenPrototype:String;
		
		public override function write( output:ByteArray ):void
		{
			super.write(output);
			output.writeInt(tokenType);
			output.writeInt(tokenAmount);
			output.writeUTF(tokenPrototype);
			output.writeInt(RequestEnum.BINARY_OBJECT_SEQUENCE_TOKEN_END);
		}
		
		public override function destroy():void
		{
			super.destroy();
		}
	}
}