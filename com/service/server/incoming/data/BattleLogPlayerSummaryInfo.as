package com.service.server.incoming.data
{
	import com.service.server.BinaryInputStream;

	public class BattleLogPlayerSummaryInfo implements IServerData
	{
		public var name:String;
		public var playerKey:String;
		public var race:String;
		public var faction:String;
		public var rating:int;
		public var wasBase:Boolean;
		
		public function read( input:BinaryInputStream ):void
		{
			input.checkToken();
			name = input.readUTF();
			playerKey = input.readUTF();
			race = input.readUTF();
			faction = input.readUTF();
			wasBase = input.readBoolean();
			rating = input.readInt();
			input.checkToken();
		}
		
		public function readJSON( data:Object ):void
		{
			name = data.name;
			playerKey = data.playerId;
			race = data.race;
			faction = data.faction;
			if( data["baseResult"] )
			{
				wasBase = true;
				rating = data.baseResult.rating;
			}
			else
			{
				wasBase = false;
				rating = data.fleetResult.rating;
			}
		}
		
		public function destroy():void
		{
			
		}
	}
}