package com.event
{
	import com.service.server.IResponse;
	
	import flash.events.Event;

	public class BattleEvent extends Event
	{
		public static const BATTLE_COUNTDOWN:String = "countdown";
		public static const BATTLE_JOIN:String      = "join";
		public static const BATTLE_STARTED:String   = "started";
		public static const BATTLE_ENDED:String     = "ended";
		public static const BATTLE_REPLAY:String    = "replay"; 

		
		public var baseID:String;
		public var battleServerAddress:String;
		public var response:IResponse;

		public function BattleEvent( type:String, battleServerAddress:String = null, response:IResponse = null )
		{
			super(type, false, false);
			this.battleServerAddress = battleServerAddress;
			this.response = response;
		}
	}
}
