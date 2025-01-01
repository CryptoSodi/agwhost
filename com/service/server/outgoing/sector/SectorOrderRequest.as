package com.service.server.outgoing.sector
{
	import com.enum.server.RequestEnum;
	import com.enum.server.SpeakerEnum;
	import com.service.server.IRequest;

	import flash.utils.ByteArray;

	public class SectorOrderRequest implements IRequest
	{
		public var entityId:String			= '';
		public var orderType:int;
		public var targetLocationX:int;
		public var targetLocationY:int;
		public var targetId:String          = '';
		public var destinationSector:String = '';

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
			output.writeUTF(entityId);
			output.writeInt(orderType);
			output.writeDouble(targetLocationX);
			output.writeDouble(targetLocationY);
			output.writeUTF(targetId);
			output.writeUTF(destinationSector);
			output.writeInt(RequestEnum.BINARY_OBJECT_SEQUENCE_TOKEN_END);
		}

		public function destroy():void
		{
		}
	}
}
