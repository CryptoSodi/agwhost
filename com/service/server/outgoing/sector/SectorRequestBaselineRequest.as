package com.service.server.outgoing.sector
{
	import com.enum.server.RequestEnum;
	import com.enum.server.SpeakerEnum;
	import com.service.server.IRequest;

	import flash.utils.ByteArray;

	public class SectorRequestBaselineRequest implements IRequest
	{
		public var viewX:int;
		public var viewY:int;

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
			output.writeInt(viewX);
			output.writeInt(viewY);
			output.writeInt(RequestEnum.BINARY_OBJECT_SEQUENCE_TOKEN_END);
		}

		public function destroy():void
		{
		}
	}
}
