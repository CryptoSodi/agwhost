package com.service.server.incoming.starbase
{
	import com.service.server.BinaryInputStream;
	import com.service.server.IResponse;
	import com.service.server.incoming.data.ScoreData;
	import com.service.server.incoming.data.MissionScoreData;
	
	import org.shared.ObjectPool;
	
	public class StarbaseAllScoresResponse implements IResponse
	{
		public var scores:Vector.<ScoreData>             		= new Vector.<ScoreData>;
		public var missionScores:Vector.<MissionScoreData>      = new Vector.<MissionScoreData>;
		
		private var _header:int;
		private var _protocolID:int;
		
		public function read( input:BinaryInputStream ):void
		{
			input.checkToken();
			
			var i:uint;
			var scoreData:ScoreData;
			var len:uint = input.readUnsignedInt();
			for (i = 0; i < len; ++i)
			{
				scoreData = ObjectPool.get(ScoreData);
				input.readUTF(); // key
				scoreData.read(input);
				scores.push(scoreData);
			}
			
			var missionScoreData:MissionScoreData;
			var len:uint = input.readUnsignedInt();
			for (i = 0; i < len; ++i)
			{
				missionScoreData = ObjectPool.get(MissionScoreData);
				input.readUTF(); // key
				missionScoreData.read(input);
				missionScores.push(missionScoreData);
			}
			
			input.checkToken();
		}
		
		public function readJSON( data:Object ):void
		{
			// Unimplemented.
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
