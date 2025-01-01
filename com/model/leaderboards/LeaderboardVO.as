package com.model.leaderboards
{
	import com.service.server.incoming.data.LeaderboardAllianceData;
	import com.service.server.incoming.data.LeaderboardData;
	import com.service.server.incoming.data.LeaderboardPlayerData;

	import flash.utils.getTimer;

	public class LeaderboardVO
	{
		private var _type:int;
		private var _players:Vector.<LeaderboardEntryVO>;
		private var _alliances:Vector.<LeaderboardEntryVO>;
		private var _lastUpdate:Number;

		private var _refreshTime:Number = 300000;

		public function LeaderboardVO()
		{
			_players = new Vector.<LeaderboardEntryVO>;
			_alliances = new Vector.<LeaderboardEntryVO>;
		}

		public function update( leaderboardData:LeaderboardData ):void
		{
			_lastUpdate = getTimer();
			_type = leaderboardData.leaderboardType;
			var players:Vector.<LeaderboardPlayerData>     = leaderboardData.players;
			var alliances:Vector.<LeaderboardAllianceData> = leaderboardData.alliances;
			var len:uint                                   = players.length;
			var i:uint;
			var currentData:LeaderboardEntryVO;
			_players.length = len;
			for (; i < len; ++i)
			{
				currentData = new LeaderboardEntryVO();
				currentData.setUpFromPlayerData(players[i]);
				_players[i] = currentData;
			}

			len = alliances.length;
			_alliances.length = len;
			for (i = 0; i < len; ++i)
			{
				currentData = new LeaderboardEntryVO();
				currentData.setUpFromAllianceData(alliances[i]);
				_alliances[i] = currentData;
			}
		}

		public function needsUpdate():Boolean
		{
			var needsUpdate:Boolean;
			if (getTimer() - _lastUpdate > _refreshTime)
				needsUpdate = true;

			return needsUpdate;
		}

		public function get players():Vector.<LeaderboardEntryVO>
		{
			return _players;
		}

		public function get alliances():Vector.<LeaderboardEntryVO>
		{
			return _alliances;
		}
	}
}
