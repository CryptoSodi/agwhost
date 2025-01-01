package com.service.server.outgoing.battle
{
	import com.enum.server.RequestEnum;
	import com.enum.server.SpeakerEnum;
	import com.service.server.IRequest;

	import flash.utils.ByteArray;

	public class BattleAttackOrderRequest implements IRequest
	{
		public var entityID:String;
		public var targetID:String;
		public var issuedTick:int;
		public var subSystemTarget:int;
		public var moveToTarget:Boolean = false;

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
			output.writeUTF(entityID);
			output.writeInt(issuedTick);
			output.writeUTF(targetID);
			output.writeInt(subSystemTarget);
			output.writeBoolean(moveToTarget);
			output.writeInt(RequestEnum.BINARY_OBJECT_SEQUENCE_TOKEN_END);
		}

		public function destroy():void
		{
			moveToTarget = false;
		}
	}
}
