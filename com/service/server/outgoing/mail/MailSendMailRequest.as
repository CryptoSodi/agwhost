package com.service.server.outgoing.mail
{
	import com.enum.server.RequestEnum;
	import com.enum.server.SpeakerEnum;
	import com.service.server.IRequest;
	
	import flash.utils.ByteArray;

	public class MailSendMailRequest implements IRequest
	{
		public var recipient:String;
		public var subject:String;
		public var body:String;

		private var _protocolID:int;
		private var _header:int;

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
			output.writeUTF(recipient);
			output.writeUTF(subject);
			output.writeUTF(body);
			output.writeInt(RequestEnum.BINARY_OBJECT_SEQUENCE_TOKEN_END);
		}

		public function destroy():void
		{
		}
	}
}
