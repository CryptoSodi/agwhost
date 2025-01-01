package com.service.server.incoming.data
{
	import com.service.server.BinaryInputStream;
	import com.service.server.incoming.data.CrewInfo;
	import org.shared.ObjectPool;

	public class BattleLogPlayerDetailInfo implements IServerData
	{
		public var name:String;
		public var playerKey:String;
		public var race:String;
		public var faction:String;
		public var hasFleet:Boolean;
		public var fleet:BattleLogFleetDetailInfo;
		public var hasBase:Boolean;
		public var base:BattleLogBaseDetailInfo;
		public var level:int;
		public var creditsGained:int;
		public var blueprintGained:String;
		public var crewGained:CrewInfo;

		public function read( input:BinaryInputStream ):void
		{
			input.checkToken();
			name = input.readUTF();
			playerKey = input.readUTF();
			race = input.readUTF();
			faction = input.readUTF();
			hasFleet = input.readBoolean();
			if (hasFleet)
			{
				fleet = new BattleLogFleetDetailInfo();
				fleet.read(input);
			}
			hasBase = input.readBoolean();
			if (hasBase)
			{
				base = new BattleLogBaseDetailInfo();
				base.read(input);
			}
			level = input.readInt();
			creditsGained = input.readInt64();
			blueprintGained = input.readUTF();
			crewGained = ObjectPool.get(CrewInfo);
			crewGained.read(input);
			input.checkToken();
		}

		public function readJSON( data:Object ):void
		{
			name = data.name;
			playerKey = data.playerId;
			race = data.race;
			faction = data.faction;
			hasFleet = false;
			if (data.fleetResult)
			{
				hasFleet = true;
				fleet = new BattleLogFleetDetailInfo();
				fleet.readJSON(data.fleetResult);
			}
			hasBase = false;
			if (data.baseResult)
			{
				hasBase = true;
				base = new BattleLogBaseDetailInfo();
				base.readJSON(data.baseResult);
			}
			//level = input.level; // player level (not rating) seems to be unused
			creditsGained = data.credits;
			blueprintGained = data.blueprintGained;
			if( data.crewGained )
			{
				crewGained = ObjectPool.get(CrewInfo);
				crewGained.readJSON(data.crewGained);
			}
		}

		public function destroy():void
		{

		}

	}
}
