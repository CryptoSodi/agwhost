package com.service.server.incoming.data
{
	import com.service.server.BinaryInputStream;

	public class SectorOrderData implements IServerData
	{
		public var id:String;
		public var entityId:String;
		public var orderType:int;
		public var issuedTick:int;
		public var finishTick:int;
		public var originLocationX:Number;
		public var originLocationY:Number;
		public var targetLocationX:Number;
		public var targetLocationY:Number;
		public var targetId:String;
		public var destinationSector:String;

		public function read( input:BinaryInputStream ):void
		{
			input.checkToken();
			id = input.readUTF();
			entityId = input.readUTF();
			orderType = input.readInt();
			issuedTick = input.readInt();
			finishTick = input.readInt();
			originLocationX = input.readDouble();
			originLocationY = input.readDouble();
			targetLocationX = input.readDouble();
			targetLocationY = input.readDouble();
			targetId = input.readUTF();
			destinationSector = input.readUTF();
			input.checkToken();
		}


		public function readJSON( data:Object ):void
		{
			for (var key:String in data)
			{
				if (this.hasOwnProperty(key))
				{
					this[key] = data[key];
				} else
				{
					// TODO - complain about missing key?
				}
			}
		}

		public function destroy():void
		{

		}
	}
}
