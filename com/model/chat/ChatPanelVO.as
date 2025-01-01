package com.model.chat
{
	import flash.utils.Dictionary;

	import org.shared.ObjectPool;

	public class ChatPanelVO
	{
		private const MAX_LOG_SIZE:int = 50;

		private var _name:String;
		private var _id:uint;
		private var _logs:Vector.<ChatVO>;
		private var _channels:Dictionary;
		private var _chatLog:String;
		private var _defaultSendChannel:ChatChannelVO;

		public function ChatPanelVO( name:String, id:uint )
		{
			_name = name;
			_id = id;
			_channels = new Dictionary();
			_logs = new Vector.<ChatVO>;
			_chatLog = '';
		}

		public function addChatLog( vo:ChatVO, message:String ):void
		{
			if ( !vo || !message )
				return;
			
			_logs.push(vo);
			_chatLog += message;
			if (_logs.length > MAX_LOG_SIZE)
			{
				vo = _logs.shift();
				var target:String = vo.localizedMessage;
				_chatLog = _chatLog.substring(target.length);
				ObjectPool.give(vo);
			}
		}

		public function addChannel( channelID:int, channel:ChatChannelVO ):void
		{
			_channels[channelID] = channel;

			if (_defaultSendChannel == null)
				_defaultSendChannel = channel;

		}

		public function removeChannel( channelID:int ):void
		{
			if (channelID in _channels)
				delete _channels[channelID];
		}

		public function listeningToChannel( channelID:int ):Boolean
		{
			return (channelID in _channels);
		}

		public function set logs( v:String ):void  { _chatLog = v; }
		public function get logs():String  { return _chatLog; }
		public function get chatlogVO():Vector.<ChatVO>  { return _logs; }
		public function get name():String  { return _name; }
		public function get id():uint  { return _id; }
		public function get defaultSendChannel():ChatChannelVO  { return _defaultSendChannel; }
	}
}
