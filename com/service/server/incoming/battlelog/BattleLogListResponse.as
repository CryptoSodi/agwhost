package com.service.server.incoming.battlelog
{
	import com.service.server.BinaryInputStream;
	import com.service.server.IResponse;
	import com.service.server.incoming.data.BattleLogPlayerSummaryInfo;
	import com.service.server.incoming.data.BattleLogSummaryInfo;
	
	public class BattleLogListResponse implements IResponse
	{
		public var battles:Vector.<BattleLogSummaryInfo>;
		
		private var _header:int;
		private var _protocolID:int;
		
		public function BattleLogListResponse()
		{
			battles = new Vector.<BattleLogSummaryInfo>;
		}
		
		public function read( input:BinaryInputStream ):void
		{
			input.checkToken();
			var currentBattle:BattleLogSummaryInfo;
			var battleLogsLength:uint = input.readUnsignedShort();
			for(var i:uint = 0; i < battleLogsLength; ++i)
			{
				currentBattle = new BattleLogSummaryInfo();
				currentBattle.read(input);
				battles.push(currentBattle);
			}
			input.checkToken();
		}
		
		public function readJSON(input:Object):void
		{
			for each (var summaryJson:Object in input)
			{
				var currentBattle:BattleLogSummaryInfo = new BattleLogSummaryInfo();
				currentBattle.readJSON( summaryJson );
				battles.push(currentBattle);
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