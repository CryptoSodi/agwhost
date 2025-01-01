package com.enum
{
	import com.event.StateEvent;

	public class ToastEnum
	{
		//types
		public static const FLEET_DOCKED:Object         = create(2500, 0, 5, AudioEnum.VO_ALERT_FLEET_DOCKED);
		public static const FLEET_REPAIRED:Object       = create(2000, 0, 4, null);
		public static const FTE_REWARD:Object           = create(100000, 0, 3, null, StateEvent.GAME_BATTLE);
		public static const LEVEL_UP:Object             = create(5000, 0, 1, AudioEnum.VO_ALERT_LEVEL_UP);
		public static const MISSION_NEW:Object          = create(2000, 0, 3, AudioEnum.VO_ALERT_INCOMING_MESSAGE);
		public static const MISSION_REWARD:Object       = create(3000, 0, 2, null);
		public static const TRANSACTION_COMPLETE:Object = create(2000, 0, 4, null, StateEvent.GAME_STARBASE);
		public static const WRONG:Object                = create(2800, 1, 5, AudioEnum.AFX_WRONG);
		public static const PALLADIUM_ADDED:Object      = create(2800, 0, 1, AudioEnum.AFX_TRANSACTION_PALLADIUM_ADDED);
		public static const ALLIANCE:Object             = create(2800, 1, 5, null);
		public static const BLUEPRINT:Object            = create(4000, 0, 5, null);
		public static const BUBBLE_ALERT:Object         = create(4000, 0, 1, null, StateEvent.GAME_BATTLE);
		public static const BASE_RELOCATED:Object       = create(4000, 1, 1, null);
		public static const ACHIEVEMENT:Object          = create(4000, 1, 1, null);

		private static function create( duration:int, limit:int, priority:int, sound:String, state:String = null ):Object
		{
			var obj:Object = {};
			obj.duration = duration;
			obj.limit = limit;
			obj.priority = priority;
			obj.sound = sound;
			obj.state = state;
			return obj;
		}
	}
}
