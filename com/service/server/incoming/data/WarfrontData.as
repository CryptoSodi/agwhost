package com.service.server.incoming.data
{
	import com.model.prototype.IPrototype;
	import com.model.prototype.PrototypeModel;
	import com.service.server.BinaryInputStream;

	public class WarfrontData
	{
		public var id:String;
		public var battleServerAddress:String;

		public var attackerID:String;
		public var attackerName:String;
		public var attackerRace:IPrototype;
		public var attackerFleetRating:int;

		public var defenderID:String;
		public var defenderName:String;
		public var defenderRace:IPrototype;
		public var defenderFleetRating:int;
		public var defenderBaseRating:int;

		public var sector:String;
		public var sectorX:Number;
		public var sectorY:Number;

		public function read( input:BinaryInputStream ):void
		{
			var prototypeModel:PrototypeModel = PrototypeModel.instance;

			// map value
			input.checkToken();
			id = input.readUTF(); // battleKey
			battleServerAddress = input.readUTF(); // battleIdentifier

			attackerID = input.readUTF(); // attacker key
			attackerName = input.readUTF(); // attacker name
			attackerRace = prototypeModel.getRacePrototypeByName(input.readUTF()); // attacker racePrototype
			attackerFleetRating = input.readInt(); // attacker fleet rating

			defenderID = input.readUTF(); // defender key
			defenderName = input.readUTF(); // defender name
			defenderRace = prototypeModel.getRacePrototypeByName(input.readUTF()); // defender racePrototype
			defenderFleetRating = input.readInt(); // defender fleet rating
			defenderBaseRating = input.readInt(); // defender baseRating

			sector = input.readUTF(); // sector
			sectorX = input.readDouble(); // sectorX
			sectorY = input.readDouble(); // sectorY

			input.checkToken();
		}

		public function readJSON( data:Object ):void
		{
			throw new Error("readJSON in TradeRouteData is not supported");
		}

		public function destroy():void
		{

		}
	}
}
