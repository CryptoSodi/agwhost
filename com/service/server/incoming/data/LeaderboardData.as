package com.service.server.incoming.data
{
	import com.service.server.BinaryInputStream;

	import org.shared.ObjectPool;

	public class LeaderboardData implements IServerData
	{
		public var leaderboardType:int;
		public var leaderboardScope:int;
		public var players:Vector.<LeaderboardPlayerData>;
		public var alliances:Vector.<LeaderboardAllianceData>;

		public function LeaderboardData()
		{
			players = new Vector.<LeaderboardPlayerData>;
			alliances = new Vector.<LeaderboardAllianceData>;
		}

		public function read( input:BinaryInputStream ):void
		{
			input.checkToken();

			leaderboardType = input.readInt(); // leaderboard type
			leaderboardScope = input.readInt();

			var num:int          = input.readUnsignedInt();
			var currentLeaderboardPlayer:LeaderboardPlayerData;
			for (var idx:int = 0; idx < num; ++idx)
			{
				currentLeaderboardPlayer = ObjectPool.get(LeaderboardPlayerData);
				currentLeaderboardPlayer.read(input);
				players.push(currentLeaderboardPlayer);
			}

			var numAlliances:int = input.readUnsignedInt();
			var currentLeaderboardAlliance:LeaderboardAllianceData;
			for (idx = 0; idx < numAlliances; ++idx)
			{
				currentLeaderboardAlliance = ObjectPool.get(LeaderboardAllianceData);
				currentLeaderboardAlliance.read(input);
				alliances.push(currentLeaderboardAlliance);
			}

			input.checkToken();
		}

		public function readJSON( data:Object ):void
		{
			throw new Error("readJSON is not supported");
		}

		public function destroy():void
		{
			players.length = 0;
			alliances.length = 0;
		}
	}
}
