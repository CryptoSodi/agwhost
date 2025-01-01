package com.service.server.incoming.data
{
	import com.service.server.BinaryInputStream;
	
	public class AreaAttackHitData implements IServerData
	{
		public var attackId:String;
		public var target:String
		public var locationX:Number;
		public var locationY:Number;
		
		public function read(input:BinaryInputStream):void
		{
			attackId	= String(input.readUnsignedInt());
			target		= input.readUTF();
			
			locationX = input.readDouble();
			locationY = input.readDouble();
		}
		
		public function readJSON(data:Object):void
		{
		}
		
		public function destroy():void
		{
		}
	}
}