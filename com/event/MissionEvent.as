package com.event
{
	import flash.events.Event;
	
	public class MissionEvent extends Event
	{
		public static const MISSION_FAILED:String   		= "MissionFailed";
		public static const MISSION_GREETING:String   		= "MissionGreeting";
		public static const MISSION_SITUATIONAL:String   	= "MissionSituational";
		public static const MISSION_VICTORY:String   		= "MissionVictory";
		public static const SHOW_REWARDS:String   			= "ShowRewards";
		
		public function MissionEvent( type:String )
		{
			super(type, false, false);
		}
	}
}