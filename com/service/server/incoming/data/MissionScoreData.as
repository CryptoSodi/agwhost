package com.service.server.incoming.data
{
	import com.service.server.BinaryInputStream;
	
	public class MissionScoreData implements IServerData
	{
		public var key:String;
		public var instancedMissionID:int;
		public var bestTime:int;
		
		public function read( input:BinaryInputStream ):void
		{
			input.checkToken();
			input.checkToken();
			key = input.readUTF();
			input.checkToken();
			instancedMissionID = input.readInt();
			bestTime = input.readInt();
			
			input.checkToken();
		}
		
		public function readJSON( data:Object ):void
		{
			throw new Error("readJSON in MissionScoreData is not supported");
		}
		
		public function destroy():void
		{
		}
	}
}