package com.enum.server
{
	public class ResponseEnum
	{
		//Proxy
		public static const PROXY_TIME_SYNC:int                            = 1;
		public static const PROXY_BATTLE_DISCONNECTED:int                  = 2;
		public static const PROXY_SECTOR_DISCONNECTED:int                  = 3;
		public static const PROXY_STARBASE_DISCONNECTED:int                = 4;

		public static const AUTHORIZATION:int                              = 1000;

		//Sector
		public static const SECTOR_BASELINE:int                            = 1;
		public static const SECTOR_UPDATE:int                              = 2;
		public static const SECTOR_ALWAYS_VISIBLE_BASELINE:int             = 3;
		public static const SECTOR_ALWAYS_VISIBLE_UPDATE:int               = 4;
		public static const SECTOR_FLEET_TRAVEL_ALERT:int                  = 6;

		//Battle
		public static const BATTLE_BASELINE:int                            = 1;
		public static const BATTLE_UPDATE:int                              = 2;
		public static const BATTLE_DEBUG_LINES:int                         = 3;
		public static const BATTLE_OBJECT_UPDATE:int                       = 4;
		public static const BATTLE_START_TIME:int                          = 5;
		public static const BATTLE_HAS_BEGUN:int                           = 6;
		public static const BATTLE_HAS_ENDED:int                           = 7;

		//Starbase
		public static const STARBASE_BASELINE:int                          = 1;
		public static const STARBASE_TRANSACTION_RESPONSE:int              = 2;

		public static const STARBASE_BATTLE_ALERT:int                      = 4;
		public static const STARBASE_MISSION_COMPLETE:int                  = 5;
		public static const STARBASE_FLEET_DOCKED:int                      = 6;
		public static const STARBASE_BOUNTY_REWARD:int                     = 7;
		public static const STARBASE_BATTLELOG_LIST:int                    = 8;
		public static const STARBASE_BATTLELOG_DETAILS:int                 = 9;
		public static const STARBASE_OFFER_REDEEMED:int                    = 10;
		public static const STARBASE_MOTD_LIST:int                         = 11;
		public static const STARBASE_DAILY:int                             = 12;
		public static const STARBASE_DAILY_REWARD:int                      = 13;
		public static const STARBASE_AVAILABLE_REROLL:int                  = 14;
		public static const STARBASE_REROLL_CHANCE_RESULT:int              = 15;
		public static const STARBASE_REROLL_RECEIVED_RESULT:int            = 16;
		public static const STARBASE_MOVE_STARBASE_RESPONSE:int            = 17;
		public static const STARBASE_ACHIEVEMENTS_RESPONSE:int             = 18;
		public static const STARBASE_GET_PAYWALL_PAYOUTS_RESPONSE:int      = 19;
		public static const STARBASE_UNAVAILABLE_REROLL:int                = 20;
		public static const STARBASE_AVAILABLE_CREWMEMBER_REROLL:int       = 21;
		public static const STARBASE_UNAVAILABLE_CREWMEMBER_REROLL:int     = 22;
		public static const STARBASE_REROLL_CREWMEMBER_RECEIVED_RESULT:int = 23;
		public static const STARBASE_INSTANCED_MISSION_ALERT:int   		   = 24;
		public static const STARBASE_ALL_SCORES_RESPONSE:int               = 25;

		// mail
		public static const MAIL_UNREAD:int                                = 1;
		public static const MAIL_INBOX:int                                 = 2;
		public static const MAIL_DETAIL:int                                = 3;

		// alliance
		public static const ALLIANCE_BASELINE:int                          = 1;
		public static const ALLIANCE_ROSTER:int                            = 2;
		public static const GENERIC_ALLIANCE_RESPONSE:int                  = 3;
		public static const PUBLIC_ALLIANCES_RESPONSE:int                  = 4;
		public static const ALLIANCE_INVITE:int                            = 5;

		// chat
		public static const CHAT_BASELINE:int                              = 1;
		public static const CHAT_RESPONSE:int                              = 2;
		public static const CHAT_EVENT:int                                 = 3;

		// leaderboard
		public static const LEADERBOARD:int                                = 1;
		public static const PLAYER_PROFILE:int                             = 2;
		public static const WARFRONT_UPDATE:int                            = 3;

		// universe
		public static const UNIVERSE_NEED_CHARACTER_CREATE:int             = 1;
		public static const UNIVERSE_SECTOR_LIST:int                       = 2;

	}
}
