package com.model.achievements
{
	public class ScoreVO
	{
		private var _key:String;
		private var _scoreKey:String;
		private var _value:Number;

		public function ScoreVO( key:String, scoreKey:String, value:Number )
		{
			_key = key;
			_scoreKey = scoreKey;
			_value = value;
		}

		public function get key():String  { return _key; }
		public function get scoreKey():String  { return _scoreKey; }
		public function get value():Number  { return _value; }
	}
}
