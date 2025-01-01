package com.enum.server
{
	public class AllianceResponseEnum
	{
		public static var ALLIANCE_CREATED:Number                   = 1;
		public static var ALLIANCE_CREATION_FAILED_NAMEINUSE:Number = 2;
		public static var ALLIANCE_CREATION_FAILED_BADNAME:Number   = 3;
		public static var ALLIANCE_CREATION_FAILED_UNKNOWN:Number   = 4;
		public static var SET_SUCCESS:Number                        = 5;
		public static var SET_FAILED_TOOLONG:Number                 = 6;
		public static var SET_FAILED_LACKINGRANK:Number             = 7;
		public static var SET_FAILED_UNKNOWN:Number                 = 8;
		public static var INVITE_FAILED_IGNORED:Number              = 9;
		public static var INVITE_FAILED_OFFLINE:Number              = 10;
		public static var INVITE_FAILED_INALLIANCE:Number           = 11
		public static var JOIN_FAILED_TOOMANYPLAYERS:Number         = 12;
		public static var JOIN_FAILED_NOALLIANCE:Number             = 13;
		public static var KICKED:Number                             = 14;
		public static var LEFT:Number                               = 15;
		public static var JOINED:Number                             = 16
		public static var YOUGOTDEMOTED:Number                      = 17;
		public static var INVITED:Number                            = 100;
	}
}
