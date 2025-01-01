package com.service.server.incoming.data
{
	import com.service.server.BinaryInputStream;
	
	public class SectorObjectiveData implements IServerData
	{
		public var missionKey:String;
		public var locationX:Number;
		public var locationY:Number;
		public var asset:String;
		public var type:String;
		
		public function read(input:BinaryInputStream):void
		{
			missionKey  = input.readUTF(); //Mission key
			input.checkToken();
			locationX   = input.readDouble(); //locationX
			locationY   = input.readDouble(); //locationY
			asset 		= input.readUTF(); //Asset
			type 		= input.readUTF(); //Type
			input.checkToken();
		}
		
		public function readJSON(data:Object):void
		{
		}
		
		public function destroy():void
		{
		}
	}
}