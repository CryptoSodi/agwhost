package com.service.server.incoming.data
{
	import com.service.server.BinaryInputStream;
	
	public class BattleLogEntityDetailInfo implements IServerData
	{
		public var protoName:String;
		public var health:Number;
		
		public function read( input:BinaryInputStream ):void
		{
			var value:int = input.readUnsignedInt();
			protoName = input.readUTF();
			health = input.readDouble();
		}
		
		public function readJSON( data:Object ):void
		{
			protoName = data.prototype;
			health = data.health;
		}
		
		public function destroy():void
		{
			
		}
	}
}