package com.model.battlelog
{
	import com.service.server.incoming.battlelog.BattleLogDetailsResponse;
	import com.service.server.incoming.data.BattleLogPlayerDetailInfo;

	public class BattleLogVO
	{

		private var _battleKey:String;
		private var _winners:Vector.<BattleLogPlayerInfoVO>;
		private var _losers:Vector.<BattleLogPlayerInfoVO>;
		private var _startTime:Number;
		private var _endTime:Number;
		private var _timeSince:Number;
		private var _hasDetails:Boolean;
		private var _hasReplay:Boolean;

		public function BattleLogVO( battleKey:String, startTime:Number, endTime:Number )
		{
			_winners = new Vector.<BattleLogPlayerInfoVO>;
			_losers = new Vector.<BattleLogPlayerInfoVO>;
			_battleKey = battleKey;
			_startTime = startTime;
			_endTime = endTime;
		}

		public function setWinners( winners:Vector.<BattleLogPlayerInfoVO> ):void
		{
			_winners = winners
		}

		public function setLosers( losers:Vector.<BattleLogPlayerInfoVO> ):void
		{
			_losers = losers;
		}
		
		public function setHasReplay( hasReplay:Boolean ):void
		{
			_hasReplay = hasReplay;
		}

		public function updateWithDetails( v:BattleLogDetailsResponse ):void
		{
			var winners:Vector.<BattleLogPlayerDetailInfo> = v.winners;
			var len:uint                                   = winners.length;
			var i:uint;
			var currentPlayerData:BattleLogPlayerDetailInfo;
			var currentPlayer:BattleLogPlayerInfoVO;
			for (; i < len; ++i)
			{
				currentPlayerData = winners[i];
				currentPlayer = getPlayerInfo(currentPlayerData.playerKey, _winners);
				if (currentPlayer)
					currentPlayer.updatePlayerInfo(currentPlayerData.hasFleet, currentPlayerData.fleet, currentPlayerData.hasBase, currentPlayerData.base, currentPlayerData.level, currentPlayerData.creditsGained,
												   currentPlayerData.blueprintGained);
			}

			var losers:Vector.<BattleLogPlayerDetailInfo>  = v.losers;
			len = losers.length;
			for (i = 0; i < len; ++i)
			{
				currentPlayerData = losers[i];
				currentPlayer = getPlayerInfo(currentPlayerData.playerKey, _losers);
				if (currentPlayer)
					currentPlayer.updatePlayerInfo(currentPlayerData.hasFleet, currentPlayerData.fleet, currentPlayerData.hasBase, currentPlayerData.base, currentPlayerData.level, currentPlayerData.creditsGained,
												   currentPlayerData.blueprintGained);
			}

			_hasDetails = true;
		}

		public function getPlayerInfo( id:String, v:Vector.<BattleLogPlayerInfoVO> ):BattleLogPlayerInfoVO
		{
			var len:uint = v.length;
			var currentPlayer:BattleLogPlayerInfoVO;
			for (var i:uint = 0; i < len; ++i)
			{
				currentPlayer = v[i];
				if (currentPlayer.playerKey == id)
					return currentPlayer;
			}

			return null;
		}

		public function get battleKey():String  { return _battleKey; }
		public function get winners():Vector.<BattleLogPlayerInfoVO>  { return _winners; }
		public function get losers():Vector.<BattleLogPlayerInfoVO>  { return _losers; }
		public function get startTime():Number  { return _startTime; }
		public function get endTime():Number  { return _endTime; }
		public function get hasReplay():Boolean  { return _hasReplay; }
		public function get timeSince():Number  { return (new Date()).time - endTime; }
		public function get hasDetails():Boolean  { return _hasDetails; }
	}
}
