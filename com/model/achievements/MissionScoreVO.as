package com.model.achievements
{
	public class MissionScoreVO
	{
		private var _key:String;
		private var _instancedMissionID:int;
		private var _bestTime:int;
		
		public function MissionScoreVO( key:String, instancedMissionID:int, bestTime:int )
		{
			_key = key;
			_instancedMissionID = instancedMissionID;
			_bestTime = bestTime;
		}
		
		public function get key():String  { return _key; }
		public function get instancedMissionID():int  { return _instancedMissionID; }
		public function get bestTime():int  { return _bestTime; }
	}
}