package com.model.battlelog
{
	public class BattleLogEntityInfoVO
	{
		private var _protoName:String;
		private var _health:Number;
		
		public function BattleLogEntityInfoVO( protoName:String, health:Number)
		{
			_protoName = protoName
			_health = health;
		}
		
		public function get protoName():String { return _protoName; }
		public function get health():Number { return _health; }
	}
}