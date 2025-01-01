package com.service.server.incoming.battle
{
	import com.service.server.BinaryInputStream;

	public class BattleParticipantInfo
	{
		public var id:String;
		public var level:int;
		
		public function read( input:BinaryInputStream ):void
		{
			id = input.readUTF();
			level = input.readInt();
		}
	}
}