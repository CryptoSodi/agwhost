package com.util.statcalc
{
	public class Stat
	{
		private var _stat:String;
		private var _baseValue:Number;
		private var _flatBonus:Number;
		private var _additivePercent:Number;
		private var _multiplier:Number;

		public function Stat()
		{
			reset();
		}

		public function calculate():Number
		{
			var flatValue:Number    = _baseValue + _flatBonus;
			var percentBonus:Number = flatValue * (_additivePercent / 100.0);

			var result:Number       = (flatValue + percentBonus) * _multiplier;

			return result;
		}

		public function reset():void
		{
			stat = '';
			baseValue = 0.0;
			flatBonus = 0.0;
			additivePercent = 0.0;
			multiplier = 1.0;
		}

		public function set stat( v:String ):void  { _stat = v; }
		public function get stat():String  { return _stat; }

		public function set baseValue( v:Number ):void  { _baseValue = v; }
		public function get baseValue():Number  { return _baseValue; }

		public function set flatBonus( v:Number ):void  { _flatBonus = v; }
		public function get flatBonus():Number  { return _flatBonus; }

		public function set additivePercent( v:Number ):void  { _additivePercent = v; }
		public function get additivePercent():Number  { return _additivePercent; }

		public function set multiplier( v:Number ):void  { _multiplier = v; }
		public function get multiplier():Number  { return _multiplier; }
	}
}
