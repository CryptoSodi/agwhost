package com.model.battlelog
{
	import flash.utils.Dictionary;
	
	public class BattleLogFleetInfoVO
	{
		private var _name:String;
		private var _ships:Vector.<BattleLogEntityInfoVO>;
		private var _fleetRating:int;
		private var _fleetHealth:Number;
		private var _alloyGained:int;
		private var _energyGained:int;
		private var _syntheticGained:int;
		
		public function BattleLogFleetInfoVO( name:String, fleetRaiting:int, fleetHealth:Number, alloyGained:int, energyGained:int, syntheticGained:int)
		{
			_name = name;
			_fleetRating = fleetRaiting;
			_fleetHealth = fleetHealth;
			_alloyGained = alloyGained;
			_energyGained = energyGained;
			_syntheticGained = syntheticGained;
		}
		
		public function addShips( v:Vector.<BattleLogEntityInfoVO> ):void
		{
			_ships = v;
		}
		
		public function fleetRating():int { return _fleetRating; }
		public function fleetHealth():Number { return _fleetHealth; }
		public function alloyGained():int { return _alloyGained; }
		public function energyGained():int { return _energyGained; }
		public function syntheticGained():int { return _syntheticGained; }
		public function get ships():Vector.<BattleLogEntityInfoVO> { return _ships; }
		
	}
}