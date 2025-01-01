package com.service.server.outgoing.starbase
{
	import com.enum.server.RequestEnum;
	import com.enum.server.SpeakerEnum;
	import com.service.server.IRequest;
	
	import flash.utils.ByteArray;
	
	public class StarbaseVerifyPaymentRequest implements IRequest
	{
		private var _protocolID:int;
		private var _header:int;
		
		public var externalTrkid:String;
		public var payoutId:String;
		public var responseData:String;
		public var responseSignature:String;
		
		public function init( protocolID:int, header:int ):void
		{
			_protocolID = protocolID;
			_header = header;
		}
		
		public function write( output:ByteArray ):void
		{
			output.writeByte(_protocolID);
			output.writeByte(SpeakerEnum.CLIENT_SPEAKER);
			output.writeByte(_header);
			
			output.writeInt(RequestEnum.BINARY_OBJECT_SEQUENCE_TOKEN_START);
			output.writeUTF(externalTrkid);
			output.writeUTF(payoutId);
			output.writeUTF(responseData);
			output.writeUTF(responseSignature);
			output.writeInt(RequestEnum.BINARY_OBJECT_SEQUENCE_TOKEN_END);
		}
		
		public function destroy():void
		{
		}

		public function set protocolID(value:int):void { _protocolID = value; }

		public function set header(value:int):void { _header = value; }


	}
}