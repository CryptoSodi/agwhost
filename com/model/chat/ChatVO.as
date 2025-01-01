package com.model.chat
{
	import flash.utils.getTimer;

	public class ChatVO
	{
		private var _message:String;
		private var _timestamp:int;
		private var _userID:String;
		private var _userFaction:String;
		private var _channel:ChatChannelVO;
		private var _localizedMessage:String;
		private var _userName:String;

		public function init( userid:String, username:String, faction:String, channel:ChatChannelVO, message:String, timestamp:int = -1 ):void
		{
			_userID = userid;
			_userName = username;
			_userFaction = faction;
			_channel = channel;
			_message = message;
			_timestamp = (timestamp == -1) ? getTimer() : timestamp;
		}

		public function get message():String  { return _message; }
		public function set localizedMessage( v:String ):void  { _localizedMessage = v; }
		public function get localizedMessage():String  { return _localizedMessage; }
		public function get timestamp():int  { return _timestamp; }
		public function get channel():ChatChannelVO  { return _channel; }
		public function get channelID():int  { return _channel.channelID; }
		public function get userID():String  { return _userID; }
		public function get userName():String  { return _userName; }
		public function set userName( v:String ):void  { _userName = v; }
		public function get userFaction():String  { return _userFaction; }

		public function destroy():void
		{
			_channel = null;
		}
	}
}
