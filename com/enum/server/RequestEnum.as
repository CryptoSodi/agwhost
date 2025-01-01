package com.enum.server
{
	public class RequestEnum
	{
		public static const BINARY_OBJECT_SEQUENCE_TOKEN_START:int         = 1000000000;
		public static const BINARY_OBJECT_SEQUENCE_TOKEN_END:int           = 1000000001;

		//==================================================================================
		//===============   PROXY_CLIENT PROTOCOLS    =====================================
		//==================================================================================
		public static const PROXY_TIME_SYNC:int                            = 1;
		public static const PROXY_CONNECT_TO_BATTLE:int                    = 2;
		public static const PROXY_CONNECT_TO_SECTOR:int                    = 3;
		public static const PROXY_LOGIN:int                                = 4;
		public static const PROXY_REPORT_CRASH:int                         = 5;
		public static const PROXY_REPORT_LOGIN_DATA:int                    = 6;
		public static const PROXY_TUTORIAL_STEP_COMPLETED:int              = 7;

		//==================================================================================
		//===============   SECTOR_CLIENT PROTOCOLS    =====================================
		//==================================================================================
		public static const AUTHORIZATION:int                              = 1000;

		public static const SECTOR_SET_VIEW_LOCATION:int                   = 1;
		public static const SECTOR_ISSUE_ORDER:int                         = 2;

		public static const SECTOR_REQUEST_BASELINE:int                    = 5;

		//==================================================================================
		//===============   BATTLE_CLIENT PROTOCOLS    =====================================
		//==================================================================================
		public static const BATTLE_MOVE_ORDER:int                          = 1;
		public static const BATTLE_ATTACK_ORDER:int                        = 2;
		public static const BATTLE_TOGGLE_MODULE_ORDER:int                 = 3;
		public static const BATTLE_PAUSE:int                               = 4;
		public static const BATTLE_RETREAT:int                             = 5;

		//==================================================================================
		//===============   STARBASE_CLIENT PROTOCOLS    ===================================
		//==================================================================================
		public static const STARBASE_BUILD_SHIP:int                        = 1;
		public static const STARBASE_UPDATE_FLEET:int                      = 2;
		public static const STARBASE_LAUNCH_FLEET:int                      = 3;
		public static const STARBASE_RECALL_FLEET:int                      = 4;
		public static const STARBASE_REPAIR_FLEET:int                      = 5;
		public static const STARBASE_RENAME_FLEET:int                      = 6;
		public static const STARBASE_BUILD_NEW_BUILDING:int                = 7;
		//public static const STARBASE_CREATE_CHARACTER:int          = 8;
		public static const STARBASE_SET_CLIENT_SETTINGS:int               = 9;
		public static const STARBASE_UPGRADE_BUILDING:int                  = 10;
		public static const STARBASE_RECYCLE_BUILDING:int                  = 11;
		public static const STARBASE_REFIT_BUILDING:int                    = 12;
		public static const STARBASE_REPAIR_BASE:int                       = 13;
		public static const STARBASE_SPEED_UP_TRANSACTION:int              = 14;
		public static const STARBASE_CANCEL_TRANSACTION:int                = 15;
		public static const STARBASE_MOVE_BUILDING:int                     = 16;
		public static const STARBASE_RESEARCH:int                          = 17;
		public static const STARBASE_BUY_RESOURCE:int                      = 18;
		public static const STARBASE_BUY_STORE_ITEM:int                    = 19;
		public static const STARBASE_RECYCLE_SHIP:int                      = 20;
		public static const STARBASE_REFIT_SHIP:int                        = 21;
		public static const STARBASE_NEGOTIATE_CONTRACT:int                = 22;
		public static const STARBASE_BRIBE_CONTRACT:int                    = 23;
		public static const STARBASE_CANCEL_CONTRACT:int                   = 24;
		public static const STARBASE_EXTEND_CONTRACT:int                   = 25;
		public static const STARBASE_RESECURE_CONTRACT:int                 = 26;
		public static const STARBASE_MISSION_STEP:int                      = 27;
		public static const STARBASE_MISSION_ACCEPT:int                    = 28;
		public static const STARBASE_MISSION_ACCEPT_REWARDS:int            = 29;
		public static const STARBASE_BUYOUT_BLUEPRINT:int                  = 30;
		public static const STARBASE_BATTLELOG_LIST:int                    = 32;
		public static const STARBASE_BATTLELOG_DETAILS:int                 = 33;
		public static const STARBASE_BOOKMARK_SAVE:int                     = 34;
		public static const STARBASE_BOOKMARK_DELETE:int                   = 35;
		public static const STARBASE_BOOKMARK_UPDATE:int                   = 36;
		public static const STARBASE_MARK_MOTD_READ_MESSAGE:int            = 37;
		public static const STARBASE_CLAIM_DAILY_MESSAGE:int               = 38;
		public static const STARBASE_SKIP_TRAINING_MESSAGE:int             = 39;
		public static const STARBASE_REROLL_BLUEPRINT_CHANCE_MESSAGE:int   = 40;
		public static const STARBASE_REROLL_BLUEPRINT_RECEIVED_MESSAGE:int = 41;
		public static const STARBASE_RENAME_PLAYER:int                     = 42;
		public static const STARBASE_MOVE_STARBASE:int                     = 43;
		public static const STARBASE_REQUEST_ACHIEVEMENTS:int              = 44;
		public static const STARBASE_CLAIM_ACHIEVEMENT_REWARD:int          = 45;
		public static const STARBASE_GET_PAYWALL_PAYOUTS:int               = 46;
		public static const STARBASE_VERIFY_PAYMENT:int                    = 47;
		public static const STARBASE_BUY_OTHER_STORE_ITEM:int              = 49;
		public static const STARBASE_INSTANCED_MISSION_START:int           = 50;
		public static const STARBASE_MOVE_STARBASE_TO_TRANSGATE:int        = 51;
		public static const STARBASE_COMPLETE_BLUEPRINT_RESEARCH:int       = 52;
		public static const STARBASE_REQUEST_ALL_SCORES:int      		   = 53;
		public static const STARBASE_MINT_NFT:int 						   = 54;
		

		//==================================================================================
		//===============   MAIL_CLIENT PROTOCOLS        ===================================
		//==================================================================================
		public static const MAIL_REQUEST_INBOX:int                         = 1;
		public static const MAIL_SEND_MAIL:int                             = 2;
		public static const MAIL_DELETE_MAIL:int                           = 3;
		public static const MAIL_READ_MAIL:int                             = 4;
		public static const MAIL_SEND_ALLIANCE_MAIL:int                    = 5;

		//==================================================================================
		//===============   ALLIANCE_CLIENT PROTOCOLS        ===================================
		//==================================================================================

		public static const ALLIANCE_REQUEST_BASELINE:int                  = 1;
		public static const ALLIANCE_REQUEST_ROSTER:int                    = 2;
		public static const ALLIANCE_CREATE_ALLIANCE:int                   = 3;
		public static const ALLIANCE_SET_MOTD:int                          = 4;
		public static const ALLIANCE_SET_DESCRIPTION:int                   = 5;
		public static const ALLIANCE_SET_PUBLIC:int                        = 6;
		public static const ALLIANCE_PROMOTE:int                           = 7;
		public static const ALLIANCE_DEMOTE:int                            = 8;
		public static const ALLIANCE_KICK:int                              = 9;
		public static const ALLIANCE_LEAVE_ALLIANCE:int                    = 10;
		public static const ALLIANCE_JOIN_ALLIANCE:int                     = 11;
		public static const ALLIANCE_SEND_INVITE:int                       = 12;
		public static const ALLIANCE_IGNORE_INVITES:int                    = 13;
		public static const ALLIANCE_REQUEST_PUBLICS:int                   = 14;


		//==================================================================================
		//===============   CHAT_CLIENT PROTOCOLS        ===================================
		//==================================================================================
		public static const CHAT_SEND_CHAT:int                             = 1;
		public static const CHAT_IGNORE_CHAT:int                           = 2;
		public static const CHAT_REPORT_CHAT:int                           = 3;
		public static const CHAT_CHANGE_ROOM:int                           = 4;

		//==================================================================================
		//===============   LEADERBOARD_CLIENT PROTOCOLS ===================================
		//==================================================================================
		public static const LEADERBOARD_REQUEST_LEADERBOARD:int            = 1;
		public static const LEADERBOARD_REQUEST_PLAYER_PROFILE:int         = 2;


		//==================================================================================
		//===============   UNIVERSE_CLIENT PROTOCOLS  =====================================
		//==================================================================================
		public static const UNIVERSE_CHARACTER_CREATION_REQUEST:int        = 1;
	}
}
