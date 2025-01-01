package com.model.warfrontModel
{
	import com.model.prototype.IPrototype;
	import com.service.server.incoming.data.WarfrontData;

	public class WarfrontVO
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

		public function importData( data:WarfrontData ):void
		{
			id = data.id;
			battleServerAddress = data.battleServerAddress;

			attackerID = data.attackerID;
			attackerName = data.attackerName;
			attackerRace = data.attackerRace;
			attackerFleetRating = data.attackerFleetRating;

			defenderID = data.defenderID;
			defenderName = data.defenderName;
			defenderRace = data.defenderRace;
			defenderFleetRating = data.defenderFleetRating;
			defenderBaseRating = data.defenderBaseRating;

			sector = data.sector;
			sectorX = data.sectorX;
			sectorY = data.sectorY;
		}

		public function destroy():void
		{
			attackerRace = null;
			defenderRace = null;
		}
	}
}
