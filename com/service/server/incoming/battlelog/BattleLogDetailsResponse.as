package com.service.server.incoming.battlelog
{
	import com.service.server.BinaryInputStream;
	import com.service.server.IResponse;
	import com.service.server.incoming.data.BattleLogPlayerDetailInfo;
	
	public class BattleLogDetailsResponse implements IResponse
	{
		private var _header:int;
		private var _protocolID:int;
		
		public var battleKey:String;
		public var winners:Vector.<BattleLogPlayerDetailInfo>;
		public var losers:Vector.<BattleLogPlayerDetailInfo>;
		public var startTime:Number;
		public var endTime:Number;
		
		public function BattleLogDetailsResponse()
		{
			winners = new Vector.<BattleLogPlayerDetailInfo>;
			losers = new Vector.<BattleLogPlayerDetailInfo>;
		}
		
		public function read( input:BinaryInputStream ):void
		{
			input.checkToken();
			var i:uint;
			battleKey = input.readUTF();
			
			var currentPlayer:BattleLogPlayerDetailInfo;
			var winnersLength:uint = input.readUnsignedInt();
			for(; i < winnersLength; ++i)
			{
				currentPlayer = new BattleLogPlayerDetailInfo();
				currentPlayer.read(input);
				winners.push(currentPlayer);
			}
				
			var losersLength:uint = input.readUnsignedInt();
			for(i = 0; i < losersLength; ++i)
			{
				currentPlayer = new BattleLogPlayerDetailInfo();
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
				var playerSummary:BattleLogPlayerDetailInfo = new BattleLogPlayerDetailInfo();
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
			
		}
		
		public function get isTicked():Boolean  { return false; }
		
		public function get header():int  { return _header; }
		public function set header( v:int ):void  { _header = v; }
		
		public function get protocolID():int  { return _protocolID; }
		public function set protocolID( v:int ):void  { _protocolID = v; }
		
		public function destroy():void
		{
		}
	}
}