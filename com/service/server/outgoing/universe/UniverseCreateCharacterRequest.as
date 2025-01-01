package com.service.server.outgoing.universe
{
	import com.enum.server.RequestEnum;
	import com.enum.server.SpeakerEnum;
	import com.service.server.IRequest;
	
	import flash.utils.ByteArray;

	public class UniverseCreateCharacterRequest implements IRequest
	{
		private var _protocolID:int;
		private var _header:int;

		public var factionPrototype:String;
		public var racePrototype:String;
		public var avatar:String;
		public var name:String;
		
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
			output.writeUTF(factionPrototype);
			output.writeUTF(racePrototype);
			output.writeUTF(name);
			output.writeInt(RequestEnum.BINARY_OBJECT_SEQUENCE_TOKEN_END);
		}

		public function destroy():void
		{
		}
	}
}
