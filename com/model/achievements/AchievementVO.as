package com.model.achievements
{
	public class AchievementVO
	{
		private var _key:String;
		private var _category:String;
		private var _achievementPrototype:String;
		private var _claimedFlag:Boolean;

		public function AchievementVO( key:String, achievementPrototype:String, claimedFlag:Boolean )
		{
			_key = key;
			_category = achievementPrototype.slice(0, achievementPrototype.length - 2);
			_achievementPrototype = achievementPrototype;
			_claimedFlag = claimedFlag;
		}

		public function get key():String  { return _key; }
		public function get category():String  { return _category; }
		public function get achievementPrototype():String  { return _achievementPrototype; }
		public function set claimedFlag( v:Boolean ):void  { _claimedFlag = v; }
		public function get claimedFlag():Boolean  { return _claimedFlag; }
	}
}
