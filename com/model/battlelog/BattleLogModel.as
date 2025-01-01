package com.model.battlelog
{
	import com.model.Model;
	import com.service.server.incoming.battlelog.BattleLogDetailsResponse;
	import com.service.server.incoming.data.BattleLogPlayerSummaryInfo;
	import com.service.server.incoming.data.BattleLogSummaryInfo;
	
	import org.osflash.signals.Signal;
	
	public class BattleLogModel extends Model
	{
		private var _battleLogs:Vector.<BattleLogVO>;
		
		public var countUpdated:Signal;
		public var battleLogListUpdated:Signal;
		public var battleLogDetailUpdated:Signal;
		
		[PostConstruct]
		public function init():void
		{
			_battleLogs = new Vector.<BattleLogVO>;
			battleLogListUpdated = new Signal(Vector.<BattleLogVO>);
			battleLogDetailUpdated = new Signal(BattleLogVO);
		}
		
		public function addBattleLogList( v:Vector.<BattleLogSummaryInfo> ):void
		{
			var oldLogs:Vector.<BattleLogVO> = _battleLogs.concat();	
			_battleLogs = new Vector.<BattleLogVO>;
			
			var len:uint = v.length;
			var currentBattlelog:BattleLogVO;
			var currentBattleData:BattleLogSummaryInfo;
			for(var i:uint = 0; i < len; ++i)
			{
				currentBattleData = v[i];
				currentBattlelog = getMailByKey(currentBattleData.battleKey, oldLogs);
				
				if(currentBattlelog == null && currentBattleData.battleKey != '')
					currentBattlelog = createBattleLog(currentBattleData);
				
				if(currentBattlelog)
					_battleLogs.push(currentBattlelog);
			}
			oldLogs.length = 0;
			battleLogListUpdated.dispatch(_battleLogs);
		}
		
		private function createBattleLog( currentBattleData:BattleLogSummaryInfo ):BattleLogVO
		{
			var winners:Vector.<BattleLogPlayerInfoVO> = new Vector.<BattleLogPlayerInfoVO>;
			var losers:Vector.<BattleLogPlayerInfoVO> = new Vector.<BattleLogPlayerInfoVO>;
			var len:uint;
			var i:uint;
			var newBattleLog:BattleLogVO = new BattleLogVO(currentBattleData.battleKey, currentBattleData.startTime, currentBattleData.endTime);
			var currentBattleWinners:Vector.<BattleLogPlayerSummaryInfo> = currentBattleData.winners;
			var currentBattleLosers:Vector.<BattleLogPlayerSummaryInfo> = currentBattleData.losers;
			var currentPlayerSummary:BattleLogPlayerSummaryInfo;
			var newPlayer:BattleLogPlayerInfoVO;
			len = currentBattleWinners.length;
			for(; i < len; ++i)
			{
				currentPlayerSummary = currentBattleWinners[i];
				if(currentPlayerSummary)
				{
					newPlayer = new BattleLogPlayerInfoVO(currentPlayerSummary.name, currentPlayerSummary.playerKey, currentPlayerSummary.race, currentPlayerSummary.faction, currentPlayerSummary.rating, currentPlayerSummary.wasBase);
					winners.push(newPlayer);
				}
			}
			newBattleLog.setWinners(winners);
			len = currentBattleLosers.length;
			for(i = 0; i < len; ++i)
			{
				currentPlayerSummary = currentBattleLosers[i];
				if(currentPlayerSummary)
				{
					newPlayer = new BattleLogPlayerInfoVO(currentPlayerSummary.name, currentPlayerSummary.playerKey, currentPlayerSummary.race, currentPlayerSummary.faction, currentPlayerSummary.rating, currentPlayerSummary.wasBase);
					losers.push(newPlayer);
				}
			}
			newBattleLog.setLosers(losers);
			newBattleLog.setHasReplay(currentBattleData.hasReplay);
			
			return newBattleLog;
		}
		
		public function addBattleLogDetail( v:BattleLogDetailsResponse ):void
		{
			var battleLog:BattleLogVO = getMailByKey(v.battleKey, _battleLogs);
			if(battleLog)
			{
				battleLog.updateWithDetails(v);
				battleLogDetailUpdated.dispatch(battleLog);
			}
		}
		
		public function getMailByKey( battleKey:String, battleLogHolder:Vector.<BattleLogVO> ):BattleLogVO
		{
			var battleLog:BattleLogVO;
			if(battleLogHolder)
			{
				var len:uint = battleLogHolder.length;
				var currentBattleLog:BattleLogVO;
				for(var i:uint = 0; i < len; ++i)
				{
					currentBattleLog = battleLogHolder[i];	
					if(currentBattleLog.battleKey == battleKey)
					{
						battleLog  = currentBattleLog;
						break;
					}
				}
				
			}
			
			return battleLog;	
		}
	}
}