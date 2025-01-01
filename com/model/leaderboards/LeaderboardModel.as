package com.model.leaderboards
{
	import com.enum.LeaderboardEnum;
	import com.model.Model;
	import com.service.server.incoming.data.LeaderboardData;
	import com.service.server.incoming.leaderboard.LeaderboardResponse;

	import flash.utils.Dictionary;

	import org.osflash.signals.Signal;

	public class LeaderboardModel extends Model
	{
		private var _leaderboardEntries:Dictionary;
		private var _lastRequestedType:int;
		private var _lastRequestedScope:int;
		public var onLeaderboardDataUpdated:Signal;

		public function LeaderboardModel()
		{
			_leaderboardEntries = new Dictionary();
			onLeaderboardDataUpdated = new Signal(LeaderboardVO);
			_lastRequestedScope = LeaderboardEnum.PLAYER_GLOBAL;
			_lastRequestedType = LeaderboardEnum.BASE_RATING;

		}

		public function updateLeaderboardEntry( response:LeaderboardResponse ):void
		{
			var currentEntry:LeaderboardVO;
			var leaderboardData:LeaderboardData = response.leaderboardData;
			_lastRequestedType = leaderboardData.leaderboardType;
			_lastRequestedScope = leaderboardData.leaderboardScope;
			if (_lastRequestedScope in _leaderboardEntries && _lastRequestedType in _leaderboardEntries[_lastRequestedScope])
				currentEntry = _leaderboardEntries[_lastRequestedScope][_lastRequestedType];
			else
			{
				currentEntry = new LeaderboardVO();
				if (_leaderboardEntries[_lastRequestedScope] == null)
					_leaderboardEntries[_lastRequestedScope] = new Dictionary;
			}

			currentEntry.update(leaderboardData);

			_leaderboardEntries[_lastRequestedScope][_lastRequestedType] = currentEntry;

			onLeaderboardDataUpdated.dispatch(currentEntry)
		}

		public function getLeaderboardDataByType( type:int, scope:int ):LeaderboardVO
		{
			_lastRequestedType = type;
			_lastRequestedScope = scope;
			return getLeaderboardData;
		}

		public function get getLeaderboardData():LeaderboardVO
		{
			var currentEntry:LeaderboardVO
			if (_lastRequestedScope in _leaderboardEntries && _lastRequestedType in _leaderboardEntries[_lastRequestedScope])
			{
				currentEntry = _leaderboardEntries[_lastRequestedScope][_lastRequestedType];
				if (currentEntry.needsUpdate())
					return null;
			}
			return currentEntry;
		}

		public function get lastRequestedType():int
		{
			return _lastRequestedType;
		}

		public function set lastRequestedType( v:int ):void
		{
			_lastRequestedType = v;
		}

		public function get lastLeaderboardScope():int
		{
			return _lastRequestedScope;
		}

		public function set lastLeaderboardScope( v:int ):void
		{
			_lastRequestedScope = v;
		}
	}
}
