package com.model.battle
{
	import flash.utils.getTimer;

	public class BattleRerollVO
	{
		private var _battleKey:String;
		private var _recievedBlueprintPrototype:String;
		private var _timeRemaining:Number;
		private var _isReroll:Boolean;
		private var _hasPaid:Boolean;

		//paid
		private var _blueprintPrototype:String;
		private var _alloyReward:Number;
		private var _creditsReward:Number;
		private var _energyReward:Number;
		private var _syntheticReward:Number;

		private var _clientTime:Number;

		public function BattleRerollVO( battleKey:String, recievedBlueprintPrototype:String, timeRemaining:Number )
		{
			_battleKey = battleKey;
			_recievedBlueprintPrototype = recievedBlueprintPrototype;
			_timeRemaining = timeRemaining;

			if (_recievedBlueprintPrototype)
				_isReroll = true;

			_clientTime = getTimer();
		}

		public function rerolled( blueprintPrototype:String ):void
		{
			if (!_hasPaid)
			{
				_hasPaid = true;
				_blueprintPrototype = blueprintPrototype;
			}
		}

		public function scanned( blueprintPrototype:String, alloyReward:Number, creditsReward:Number, energyReward:Number, syntheticReward:Number ):void
		{
			if (!_hasPaid)
			{
				_hasPaid = true;
				_blueprintPrototype = blueprintPrototype;
				_alloyReward = alloyReward;
				_creditsReward = creditsReward;
				_energyReward = energyReward;
				_syntheticReward = syntheticReward;
			}
		}

		public function get battleKey():String  { return _battleKey; }
		public function get recievedBlueprintPrototype():String  { return _recievedBlueprintPrototype; }
		public function get isReroll():Boolean  { return _isReroll; }

		public function get hasPaid():Boolean  { return _hasPaid; }

		public function get blueprintPrototype():String  { return _blueprintPrototype; }
		public function get alloyReward():Number  { return _alloyReward; }
		public function get creditsReward():Number  { return _creditsReward; }
		public function get energyReward():Number  { return _energyReward; }
		public function get syntheticReward():Number  { return _syntheticReward; }

		public function get timeRemaining():Number
		{
			var timeRemaining:Number = _timeRemaining - (getTimer() - _clientTime);
			if (timeRemaining < 0)
				timeRemaining = 0;
			return timeRemaining;
		}
	}
}
