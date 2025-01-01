package com.model.player
{
	public class OfferVO
	{
		private var _offerPrototype:String;
		private var _offerDuration:Number;
		private var _endTimeStamp:Number;
		private var _clientTime:Number;
		private var _timeRemaining:Number;

		public function OfferVO( offerPrototype:String, offerDuration:Number, endTimeStamp:Number )
		{
			_offerPrototype = offerPrototype;
			_offerDuration = offerDuration;
			_endTimeStamp = endTimeStamp;
		}

		public function get offerDuration():Number  { return _offerDuration; }
		public function get endTimestamp():Number  { return _endTimeStamp; }
		public function get offerPrototype():String  { return _offerPrototype; }

		public function get timeRemainingMS():Number
		{
			var currentTime:Date = new Date();
			_timeRemaining = _endTimeStamp - currentTime.time;
			if (_timeRemaining < 0)
				_timeRemaining = 0;
			return _timeRemaining;
		}
	}
}
