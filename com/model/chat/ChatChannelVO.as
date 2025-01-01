package com.model.chat
{
	public class ChatChannelVO
	{
		private var _channelDisplayName:String;
		private var _channelID:int;
		private var _channelColor:int;
		private var _playerSendable:Boolean;
		
		public function ChatChannelVO( channelID:int, displayName:String, channelColor:uint, playerSendable:Boolean)
		{
			_channelID = channelID;
			_channelDisplayName = displayName;
			_channelColor = channelColor;
			_playerSendable = playerSendable;
		}
		
		public function get displayName():String  { return _channelDisplayName; }
		public function set channelID( channelId:int ):void  { _channelID = channelId; }
		public function get channelID():int  { return _channelID; }
		public function get channelColor():uint  { return _channelColor; }
		public function get playerSendable():Boolean { return _playerSendable; }
	}
}