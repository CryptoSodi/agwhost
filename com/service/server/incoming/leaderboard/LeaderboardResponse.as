package com.service.server.incoming.leaderboard
{
	import com.service.server.BinaryInputStream;
	import com.service.server.IResponse;
	import com.service.server.incoming.data.LeaderboardData;
	
	import org.shared.ObjectPool;
	
	public class LeaderboardResponse implements IResponse
	{
		private var _header:int;
		private var _protocolID:int;
		
		public var leaderboardData:LeaderboardData;
		public function read( input:BinaryInputStream ):void
		{
			leaderboardData = ObjectPool.get(LeaderboardData);
			leaderboardData.read(input);
		}
		
		public function readJSON( data:Object ):void
		{
			throw new Error("readJSON is not supported");
		}
		
		public function get isTicked():Boolean  { return false; }
		
		public function get header():int  { return _header; }
		public function set header( v:int ):void  { _header = v; }
		
		public function get protocolID():int  { return _protocolID; }
		public function set protocolID( v:int ):void  { _protocolID = v; }
		
		public function destroy():void
		{
			leaderboardData.destroy();
			leaderboardData = null;
		}
	}
}
