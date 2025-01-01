package com.model.battlelog
{
	import com.service.server.incoming.data.BattleLogBaseDetailInfo;
	import com.service.server.incoming.data.BattleLogEntityDetailInfo;
	import com.service.server.incoming.data.BattleLogFleetDetailInfo;

	public class BattleLogPlayerInfoVO
	{
		private var _name:String;
		private var _playerKey:String;
		private var _race:String;
		private var _faction:String;
		private var _rating:int;
		private var _wasBase:Boolean;

		//Update
		private var _hasFleet:Boolean;
		private var _fleet:BattleLogFleetInfoVO;
		private var _hasBase:Boolean;
		private var _base:BattleLogBaseInfoVO;
		private var _level:int;
		private var _creditsGained:int;
		private var _blueprintGained:String;

		public function BattleLogPlayerInfoVO( name:String, playerKey:String, race:String, faction:String, rating:int, wasBase:Boolean )
		{
			_name = name;
			_playerKey = playerKey;
			_race = race;
			_faction = faction;
			_rating = rating;
			_wasBase = wasBase;
		}

		public function updatePlayerInfo( hasFleet:Boolean, fleet:BattleLogFleetDetailInfo, hasBase:Boolean, base:BattleLogBaseDetailInfo, level:int, creditsGained:int, blueprintGained:String ):void
		{
			_hasFleet = hasFleet;

			if (fleet)
				addFleet(fleet);

			_hasBase = hasBase;

			if (base)
				addBase(base);

			_level = level;
			_creditsGained = creditsGained;
			_blueprintGained = blueprintGained;
		}

		private function addFleet( fleet:BattleLogFleetDetailInfo ):void
		{
			var shipData:Vector.<BattleLogEntityDetailInfo> = fleet.ships;
			var len:uint                                    = shipData.length;
			var currentEntity:BattleLogEntityDetailInfo;
			var newShip:BattleLogEntityInfoVO;
			var ships:Vector.<BattleLogEntityInfoVO>        = new Vector.<BattleLogEntityInfoVO>;
			_fleet = new BattleLogFleetInfoVO(fleet.name, fleet.fleetRating, fleet.fleetHealth, fleet.alloyGained, fleet.energyGained, fleet.syntheticGained);

			for (var i:uint = 0; i < len; ++i)
			{
				currentEntity = shipData[i];
				newShip = new BattleLogEntityInfoVO(currentEntity.protoName, currentEntity.health);
				ships.push(newShip);
			}
			_fleet.addShips(ships);
		}

		private function addBase( base:BattleLogBaseDetailInfo ):void
		{
			var buildingData:Vector.<BattleLogEntityDetailInfo> = base.buildings;
			var len:uint                                        = buildingData.length;
			var currentEntity:BattleLogEntityDetailInfo;
			var newBuilding:BattleLogEntityInfoVO;
			var buildings:Vector.<BattleLogEntityInfoVO>        = new Vector.<BattleLogEntityInfoVO>;
			_base = new BattleLogBaseInfoVO(base.baseHealth, base.baseRating);

			for (var i:uint = 0; i < len; ++i)
			{
				currentEntity = buildingData[i];
				newBuilding = new BattleLogEntityInfoVO(currentEntity.protoName, currentEntity.health);
				buildings.push(newBuilding);
			}
			_base.addBuildings(buildings);
		}

		public function get name():String  { return _name; }
		public function get playerKey():String  { return _playerKey; }
		public function get race():String  { return _race; }
		public function get faction():String  { return _faction; }
		public function get rating():int  { return _rating; }
		public function get wasBase():Boolean  { return _wasBase; }

		public function get hasFleet():Boolean  { return _hasFleet; }
		public function get fleet():BattleLogFleetInfoVO  { return _fleet; }
		public function get hasBase():Boolean  { return _hasBase; }
		public function get base():BattleLogBaseInfoVO  { return _base; }
		public function get level():int  { return _level; }
		public function get creditsGained():int  { return _creditsGained; }
		public function get alloyGained():int  { return (_hasFleet) ? _fleet.alloyGained() : 0; }
		public function get energyGained():int  { return (_hasFleet) ? _fleet.energyGained() : 0; }
		public function get syntheticGained():int  { return (_hasFleet) ? _fleet.syntheticGained() : 0; }
		public function get blueprintGained():String  { return _blueprintGained; }
	}
}
