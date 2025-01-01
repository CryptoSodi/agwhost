package com.model.battlelog
{
	public class BattleLogBaseInfoVO
	{
		private var _health:Number;
		private var _buildings:Vector.<BattleLogEntityInfoVO>;
		private var _baseRating:int;
		
		public function BattleLogBaseInfoVO( health:Number, baseRating:int)
		{
			_health = health;
			_baseRating = baseRating;
		}
		
		public function addBuildings( v:Vector.<BattleLogEntityInfoVO> ):void
		{
			_buildings = v;
		}
		
		public function get health():Number { return _health; }
		public function get baseRatings():int { return _baseRating; }
	}
}