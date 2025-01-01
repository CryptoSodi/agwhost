package com.event
{
	import flash.events.Event;

	public class StarbaseEvent extends Event
	{
		public static const ALERT_FLEET_BATTLE:String    = "alertFleetBattle";
		public static const ALERT_STARBASE_BATTLE:String = "alertStarbaseBattle";
		public static const ALERT_INSTANCED_MISSION_BATTLE:String = "alertInstancedMissionBattle";
		
		public static const ENTER_BASE:String            = "EnterBase";
		public static const ENTER_INSTANCED_MISSION:String  = "EnterInstancedMission";
		public static const WELCOME_BACK:String          = "WelcomeBack";

		public var baseID:String;
		public var battleServerAddress:String;
		public var fleetID:String;
		public var view:Class;
		public var viewData:*;

		public function StarbaseEvent( type:String, baseID:String = null )
		{
			super(type, false, false);
			this.baseID = baseID;
		}
	}
}
