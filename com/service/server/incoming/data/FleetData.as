package com.service.server.incoming.data
{
	import com.service.server.BinaryInputStream;

	public class FleetData implements IServerData
	{
		public var starbaseID:String;
		public var defendTarget:String;
		public var currentCargo:Number;
		public var cargoCapacity:Number;
		public var loadSpeed:Number;
		public var currentHealth:Number;
		public var id:String;
		public var level:int;
		public var name:String;
		public var ownerID:String;
		public var sector:String;
		public var sectorLocationX:Number;
		public var sectorLocationY:Number;
		public var ships:Vector.<String> = new Vector.<String>;

		public function read( input:BinaryInputStream ):void
		{
			input.checkToken();
			input.checkToken();
			id = input.readUTF();
			input.checkToken();

			ownerID = input.readUTF();
			sector = input.readUTF();
			starbaseID = input.readUTF();
			name = input.readUTF();
			sectorLocationX = input.readDouble();
			sectorLocationY = input.readDouble();
			currentHealth = input.readDouble();
			level = input.readInt();

			currentCargo = 0;
			currentCargo += input.readInt64(); // alloy
			currentCargo += input.readInt64(); // energy
			currentCargo += input.readInt64(); // synthetic
			cargoCapacity = input.readInt64(); // cargo capacity
			loadSpeed = input.readDouble();
			defendTarget = input.readUTF();

			input.checkToken();
		}

		public function readJSON( data:Object ):void
		{
			throw new Error("readJSON in FleetData is not supported");
		}

		public function destroy():void
		{
			ships.length = 0;
		}
	}
}
