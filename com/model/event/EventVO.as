package com.model.event
{
	import com.enum.EventStateEnum;
	import com.model.prototype.IPrototype;

	import flash.utils.getTimer;

	public class EventVO
	{
		private var _prototype:IPrototype;

		private var _clientTime:int;

		private var _state:int;
		private var _timeMS:Number;
		private var _timeRemainingMS:Number;
		private var _timeLeft:Number;

		private const _SHOWTIME:Number = 172800000;

		public function EventVO( prototype:IPrototype, state:int, timeRemainingMS:Number )
		{
			_prototype = prototype;
			_state = state;
			_timeRemainingMS = timeRemainingMS;
			_clientTime = getTimer();
		}

		public function get timeRemainingMS():Number
		{
			switch (_state)
			{
				case EventStateEnum.UPCOMING:
				case EventStateEnum.RUNNING:
					_timeLeft = _timeRemainingMS - (getTimer() - _clientTime);
					if (_timeLeft < 0)
						_timeLeft = 0;
					break;
				case EventStateEnum.ENDED:
					_timeLeft = 0;
					break;
			}
			return _timeLeft;
		}

		public function get prototype():IPrototype  { return _prototype; }
		public function get state():int  { return _state; }
		public function set state( v:int ):void  { _state = v; }
		public function get scoreKey():String  { return _prototype.getValue('scoreKey'); }
		public function get objectiveText():String  { return _prototype.getValue('objectiveText'); }
		public function get rewardsText():String  { return _prototype.getValue('rewardsText'); }
		public function get activeEventBuffsText():String  { return _prototype.getValue('activeEventBuffsText'); }
		public function get rewards():Array  { return _prototype.getValue('rewards'); }
		public function get buffsGranted():Array  { return _prototype.getValue('buffs'); }
		public function get ends():Number  { return _prototype.getValue('eventEnds'); }
		public function get begins():Number  { return _prototype.getValue('eventBegins'); }
		public function set timeRemainingMS( v:Number ):void
		{
			_timeRemainingMS = v;
			_clientTime = getTimer();
		}
		public function get isUiTracking():Boolean  { return _prototype.getValue('uiTracking'); }
		public function get hasScore():Boolean  { return _prototype.getValue('hasScore'); }
	}
}
