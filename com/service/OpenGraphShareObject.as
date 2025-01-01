package com.service
{
	import org.as3commons.logging.util.jsonXify;

	/**
	 * This should closely map the generic Open Graph Object that we want to share via Facebook and other implementations for Google+ and the like.
	 */
	internal class OpenGraphShareObject
	{
		static public const ACTION_BUILD:String    = "build";
		static public const ACTION_UPGRADE:String  = "upgrade";
		static public const ACTION_REFIT:String    = "refit";
		static public const ACTION_RESEARCH:String = "research";
		static public const ACTION_LEVELUP:String  = "levelup";
		static public const ACTION_DEFEAT:String   = "defeat";
		static public const ACTION_JOIN:String     = "join";
		static public const ACTION_FIND:String     = "find";

		public var type:String;

		public var url:String;
		public var title:String;
		public var image:String;

		public var level:String;

		public var data:*;

		public var description:String;
		public var name:String;
		public var caption:String;

		public function toString():String
		{
			return jsonXify(this);
		}
	}
}
