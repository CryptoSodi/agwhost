package com.service.server.incoming.data
{
	import com.service.server.BinaryInputStream;
	
	public class BattleLogSummaryInfo implements IServerData
	{
		
		public var battleKey:String;
		public var winners:Vector.<BattleLogPlayerSummaryInfo>;
		public var losers:Vector.<BattleLogPlayerSummaryInfo>;
		public var startTime:Number;
		public var endTime:Number;
		public var hasReplay:Boolean;
		
		public function BattleLogSummaryInfo()
		{
			winners = new Vector.<BattleLogPlayerSummaryInfo>;
			losers = new Vector.<BattleLogPlayerSummaryInfo>;
			hasReplay = false;
		}
		
		public function read( input:BinaryInputStream ):void
		{
			input.checkToken();
			var i:uint;
			var currentPlayer:BattleLogPlayerSummaryInfo;
			battleKey = input.readUTF();
			var winnersLength:int = input.readUnsignedInt();
			
			for(; i < winnersLength; ++i)
			{
				currentPlayer = new BattleLogPlayerSummaryInfo();
				currentPlayer.read(input);
				winners.push(currentPlayer);
			}
			
			var losersLength:int = input.readUnsignedInt();
			
			for(i = 0; i < losersLength; ++i)
			{
				currentPlayer = new BattleLogPlayerSummaryInfo();
				currentPlayer.read(input);
				losers.push(currentPlayer);
			}
			
			startTime = input.readInt64();
			endTime = input.readInt64();
			input.checkToken();
		}
		
		public function readJSON(data:Object):void
		{
			battleKey = data._id;
			startTime = data.startTime;
			endTime = data.endTime;
			for each( var playerJson:Object in data.playerResults )
			{
				var playerSummary:BattleLogPlayerSummaryInfo = new BattleLogPlayerSummaryInfo();
				playerSummary.readJSON( playerJson );
				if( playerJson.victor == true )
				{
					winners.push(playerSummary);
				}
				else
				{
					losers.push(playerSummary);
				}
			}
			hasReplay = data.hasReplay;
		}
		
		public function destroy():void
		{
		}
	}
}