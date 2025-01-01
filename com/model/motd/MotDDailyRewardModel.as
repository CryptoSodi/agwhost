package com.model.motd
{
	import com.model.Model;
	import com.service.server.incoming.starbase.StarbaseBaselineResponse;
	import com.service.server.incoming.starbase.StarbaseDailyRewardResponse;
	
	import flash.utils.getTimer;
	
	import org.osflash.signals.Signal;
	
	public class MotDDailyRewardModel extends Model
	{
		private var _escalation:int;
		private var _canClaimDelta:Number;
		private var _dailyResetsDelta:Number;
		
		private var _header:int;
		private var _protocolID:int;
		
		private var _clientTime:int;
		private var _temp:Number;
		private var _timeMS:Number;
		private var _timeRemainingMS:Number;
		private var _resetTimeRemainingMS:Number;
		
		private var _rewards:StarbaseDailyRewardResponse;
		public var rewardResponse:Signal;
		
		[PostConstruct]
		public function init():void
		{
			rewardResponse = new Signal(StarbaseDailyRewardResponse);			
		}
		
		public function addData(escalation:int, canClaimDelta:Number, dailyResetsDelta:Number, header:int, protocol:int):void
		{
			_escalation = escalation;
			_timeRemainingMS = _canClaimDelta = canClaimDelta;
			_resetTimeRemainingMS = _dailyResetsDelta = dailyResetsDelta;
			
			_header = header;
			_protocolID = protocol;
			
			_clientTime = getTimer();
		}
		
		public function addRewardData(reward:StarbaseDailyRewardResponse):void
		{
			_rewards = reward;
			if(_rewards)
				rewardResponse.dispatch(_rewards);
		}
		
		public function get timeRemainingMS():Number
		{
			_temp = _timeRemainingMS - (getTimer() - _clientTime);
			if (_temp < 0)
				_temp = 0;
			return _temp;
		}
		
		public function get resetTimeRemainingMS():Number
		{
			_temp = _resetTimeRemainingMS - (getTimer() - _clientTime);
			if (_temp < 0)
				_temp = 0;
			return _temp;
		}

		public function get escalation():int { return _escalation; }
		public function set escalation(value:int):void { _escalation = value; }

		public function get canClaimDelta():Number { return _canClaimDelta; }
		public function set canClaimDelta(value:Number):void { _canClaimDelta = value; }
		
		public function get dailyResetsDelta():Number { return _dailyResetsDelta; }
		public function set dailyResetsDelta(value:Number):void { _dailyResetsDelta = value; }

		public function get header():int { return _header; }
		public function set header(value:int):void { _header = value; }

		public function get protocolID():int { return _protocolID; }
		public function set protocolID(value:int):void { _protocolID = value; }
	}
}