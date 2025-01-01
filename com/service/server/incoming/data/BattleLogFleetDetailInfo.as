package com.service.server.incoming.data
{
	import com.service.server.BinaryInputStream;

	public class BattleLogFleetDetailInfo implements IServerData
	{
		public var name:String;
		public var ships:Vector.<BattleLogEntityDetailInfo>;
		public var fleetRating:int;
		public var fleetHealth:Number;
		public var alloyGained:int;
		public var energyGained:int;
		public var syntheticGained:int;
		public var blueprintGained:String;
		
		public function read( input:BinaryInputStream ):void
		{
			ships = new Vector.<BattleLogEntityDetailInfo>;
			input.checkToken();
			name = input.readUTF();
			var shipsLength:int = input.readUnsignedInt();
			var currentShip:BattleLogEntityDetailInfo;
			for(var i:uint = 0; i < shipsLength; ++i)
			{
				currentShip = new BattleLogEntityDetailInfo();
				currentShip.read(input);
				ships.push(currentShip);
			}
			fleetRating = input.readInt();
			fleetHealth = input.readDouble();
			alloyGained = input.readInt();
			energyGained = input.readInt();
			syntheticGained = input.readInt();
			input.checkToken();
		}
		
		public function readJSON( data:Object ):void
		{
			ships = new Vector.<BattleLogEntityDetailInfo>;
			name = data.key;
			var currentShip:BattleLogEntityDetailInfo;
			for each( var shipJson:Object in data.shipResults )
			{
				currentShip = new BattleLogEntityDetailInfo();
				currentShip.readJSON(shipJson);
				ships.push(currentShip);
			}

			fleetRating = data.rating;
			fleetHealth = data.health;
			alloyGained = data.alloyCargoChange;
			energyGained = data.energyCargoChange;
			syntheticGained = data.syntheticCargoChange;
		}
		
		public function destroy():void
		{
			
		}
	}
}