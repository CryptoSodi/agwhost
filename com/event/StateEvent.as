package com.event
{
	import flash.events.Event;

	public class StateEvent extends Event
	{
		public static const STARTUP_COMPLETE:String      = 'startupComplete';

		public static const PRELOAD:String               = 'preload';

		public static const PRELOAD_COMPLETE:String      = 'preloadComplete';

		public static const CREATE_CHARACTER:String      = 'createCharacter';

		public static const GAME_STARBASE:String         = 'gameStarbase';

		public static const GAME_STARBASE_CLEANUP:String = 'gameStarbaseCleanup';

		public static const GAME_BATTLE_INIT:String      = 'gameBattleInit';

		public static const GAME_BATTLE:String           = 'gameBattle';

		public static const GAME_BATTLE_CLEANUP:String   = 'gameBattleCleanup';

		public static const GAME_SECTOR_INIT:String      = 'gameSectorInit';

		public static const GAME_SECTOR:String           = 'gameSector';

		public static const GAME_SECTOR_CLEANUP:String   = 'gameSectorCleanup';

		public static const GAME_SHUTDOWN:String         = 'gameShutdown';

		public static const DEFAULT_CLEANUP:String       = 'defaultCleanup';

		public static const LOST_CONTEXT:String          = 'gameLostContext';

		public static const SHUTDOWN_START:String        = "shutdownStart";

		public static const SHUTDOWN_FINISH:String       = "shutdownFinish";

		public var nextState:String;

		public function StateEvent( type:String, nextState:String = null )
		{
			super(type, false, false);
			this.nextState = nextState;
		}


	}
}
