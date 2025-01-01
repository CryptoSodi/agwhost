package com.model.chat
{
	import com.enum.server.ChatChannelEnum;
	import com.google.analytics.debug.Panel;
	import com.model.Model;
	import com.service.language.Localization;
	import com.util.CommonFunctionUtil;

	import flash.utils.Dictionary;

	import org.adobe.utils.DictionaryUtil;
	import org.osflash.signals.Signal;
	import org.shared.ObjectPool;

	public class ChatModel extends Model
	{
		public var chatSignal:Signal;
		public var activeChannelUpdated:Signal;
		public var onDefaultChannelUpdated:Signal;
		public var onDefaultChannelOverriden:Signal;

		private var _chatPanels:Vector.<ChatPanelVO>;
		private var _defaultChannel:ChatChannelVO;
		private var _activeChannels:Dictionary;
		private var _channels:Dictionary;

		private var _muteList:Vector.<String>;
		private var _blockList:Vector.<String>;


		private var _translatedGroup:String;
		private var _translatedGlobal:String;
		private var _translatedSector:String;
		private var _translatedAlliance:String;
		private var _translatedMembers:String;
		private var _translatedFaction:String;
		
		private var _chatColorDefault:uint   = 0xea8440;
		private var _chatColorFaction:uint   = 0xea8440;
		private var _chatColorGlobal:uint    = 0xf0f0f0;
		private var _chatColorSector:uint    = 0xf1c232;
		private var _chatColorGroup:uint     = 0xea8440; // same as faction but currently unused
		private var _chatColorAlliance:uint  = 0x79da62;
		private var _chatColorMembers:uint   = 0x00ffff;
		private var _chatColorSystem:uint    = 0xff0000;
		private var _chatColorBroadcast:uint = 0x52ea2e;
		private var _chatColorEvent:uint     = 0xbf68fc;
		private var _chatColorWhisper:uint   = 0xd980d3;

		private var _whisperTarget:String;
		private var _replyTarget:String;

		private var _message:String          = "<font color='#[[HexNumber.Color]]'><a href='event:NameLink.[[String.NameLink]]'><font color='#[[FactionHexNumber.Color]]'>[[[String.PlayerName]]]</font></a>: [[String.Message]]<br></font>";
		private var _systemMessage:String    = "<font color='#[[HexNumber.Color]]'>[[String.Message]]</font>";
		private var _defaultMessage:String   = "<font color='#[[HexNumber.Color]]'>[[[String.PlayerName]]]: [[String.Message]]<br></font>"
		private var _global:String           = 'CodeString.Chat.ChannelName.Global'; //Global
		private var _sector:String           = 'CodeString.Chat.ChannelName.Sector'; //Sector
		private var _group:String            = 'CodeString.Chat.ChannelName.Group'; //Group
		private var _faction:String          = 'CodeString.Chat.ChannelName.Faction'; //Faction
		private var _alliance:String         = 'CodeString.Chat.ChannelName.Alliance'; //Alliance
		private var _members:String          = 'CodeString.Chat.ChannelName.Members'; //Members
		private var _centerspace:String      = 'CodeString.Chat.ChannelName.CenterSpace'; //Center Space

		private var _sectorTabName:String    = 'CodeString.Chat.Tab.SectorName'; //SECTOR
		private var _allianceTabName:String  = 'CodeString.Chat.Tab.AllianceName'; //ALLIANCE
		private var _factionTabName:String 	 = 'CodeString.Chat.Tab.FactionName'; //FACTION
		private var _globalTabName:String	 = 'EN';//'CodeString.Chat.Tab.GlobalName'; //GLOBAL default name EN
		private var _membersTabName:String 	 = 'CodeString.Chat.Tab.MembersName'; //MEMBERS

		public function ChatModel()
		{
			chatSignal = new Signal(uint, String, Boolean);
			activeChannelUpdated = new Signal(Dictionary);
			onDefaultChannelOverriden = new Signal(uint);
			onDefaultChannelUpdated = new Signal(ChatChannelVO);

			_whisperTarget = '';
			_replyTarget = '';

			_muteList = new Vector.<String>;
			_blockList = new Vector.<String>;

			_chatPanels = new Vector.<ChatPanelVO>;

			_activeChannels = new Dictionary();
			_channels = new Dictionary();

			addChannel(ChatChannelEnum.GLOBAL);
			addChannel(ChatChannelEnum.FACTION);
			addChannel(ChatChannelEnum.SECTOR);
			addChannel(ChatChannelEnum.ALLIANCE);
			addChannel(ChatChannelEnum.MEMBERS);
			addChannel(ChatChannelEnum.GROUP);
			addChannel(ChatChannelEnum.WHISPER);
			addChannel(ChatChannelEnum.SYSTEM, true);
			addChannel(ChatChannelEnum.BROADCAST, true);
			addChannel(ChatChannelEnum.EVENT, true);

			addPanel(_globalTabName, 0, [ChatChannelEnum.GLOBAL]);
			addPanel(_factionTabName, 1, [ChatChannelEnum.FACTION]);
			addPanel(_sectorTabName, 2, [ChatChannelEnum.SECTOR, ChatChannelEnum.BROADCAST, ChatChannelEnum.EVENT, ChatChannelEnum.SYSTEM, ChatChannelEnum.WHISPER]);
			addPanel(_allianceTabName, 3, [ChatChannelEnum.ALLIANCE]);	
			addPanel(_membersTabName, 4, [ChatChannelEnum.MEMBERS]);
		}

		public function getChannelColorFromId( channelID:int ):int
		{
			var channelColor:int = _chatColorDefault;
			
			switch (channelID)
			{
				case ChatChannelEnum.GLOBAL:
					channelColor = _chatColorGlobal;
					break;
				case ChatChannelEnum.SECTOR:
					channelColor = _chatColorSector;
					break;
				case ChatChannelEnum.GROUP:
					channelColor = _chatColorGroup;
					break;
				case ChatChannelEnum.ALLIANCE:
					channelColor = _chatColorAlliance;
					break;
				case ChatChannelEnum.MEMBERS:
					channelColor = _chatColorMembers;
					break;
				case ChatChannelEnum.SYSTEM:
					channelColor = _chatColorSystem;
					break;
				case ChatChannelEnum.BROADCAST:
					channelColor = _chatColorBroadcast;
					break;
				case ChatChannelEnum.EVENT:
					channelColor = _chatColorEvent;
					break;
				case ChatChannelEnum.WHISPER:
					channelColor = _chatColorWhisper;
					break;
				case ChatChannelEnum.FACTION:
					channelColor = _chatColorFaction;
					break;
			}

			return channelColor;
		}

		public function updateChannelColor( channelID:int, chatChannelColor:uint ):void
		{
			switch (channelID)
			{
				case ChatChannelEnum.GLOBAL:
					_chatColorGlobal = chatChannelColor;
					break;
				case ChatChannelEnum.SECTOR:
					_chatColorSector = chatChannelColor;
					break;
				case ChatChannelEnum.GROUP:
					_chatColorGroup = chatChannelColor;
					break;
				case ChatChannelEnum.ALLIANCE:
					_chatColorAlliance = chatChannelColor;
					break;
				case ChatChannelEnum.MEMBERS:
					_chatColorMembers = chatChannelColor;
					break;
				case ChatChannelEnum.SYSTEM:
					_chatColorSystem = chatChannelColor;
					break;
				case ChatChannelEnum.BROADCAST:
					_chatColorBroadcast = chatChannelColor;
					break;
				case ChatChannelEnum.EVENT:
					_chatColorEvent = chatChannelColor;
					break;
				case ChatChannelEnum.WHISPER:
					_chatColorWhisper = chatChannelColor;
					break;
				case ChatChannelEnum.FACTION:
					_chatColorWhisper = chatChannelColor;
					break;
			}
		}

		public function getChannelFromId( channelId:int ):ChatChannelVO
		{
			var channelToReturn:ChatChannelVO;
			if (channelId in _channels)
				channelToReturn = _channels[channelId];

			return channelToReturn;
		}

		public function isInChannel( channelId:int ):Boolean
		{
			var inChannel:Boolean;
			if (channelId in _activeChannels)
				inChannel = true;

			return inChannel;
		}

		public function getChannelIdFromName( channelName:String ):int
		{
			if (_translatedGlobal == '' || _translatedGlobal == null)
				_translatedGlobal = Localization.instance.getString(_global);
			
			if (_translatedGroup == '' || _translatedGroup == null)
				_translatedGroup = Localization.instance.getString(_group);

			if (_translatedSector == '' || _translatedSector == null)
				_translatedSector = Localization.instance.getString(_sector);

			if (_translatedAlliance == '' || _translatedAlliance == null)
				_translatedAlliance = Localization.instance.getString(_alliance);
			
			if (_translatedMembers == '' || _translatedMembers == null)
				_translatedMembers = Localization.instance.getString(_members);
			
			if (_translatedFaction == '' || _translatedFaction == null)
				_translatedFaction = Localization.instance.getString(_faction);

			var channelID:int = -1;
			switch (channelName)
			{
				case 'global':
				case _translatedGlobal:
					channelID = ChatChannelEnum.GLOBAL;
					break;
				case 'sector':
				case _translatedSector:
					channelID = ChatChannelEnum.SECTOR;
					break;
				case 'group':
				case _translatedGroup:
					channelID = ChatChannelEnum.GROUP;
					break;
				case 'alliance':
				case _translatedAlliance:
					channelID = ChatChannelEnum.ALLIANCE;
					break;
				case 'members':
				case _translatedMembers:
					channelID = ChatChannelEnum.MEMBERS;
					break;
				case 'faction':
				case _translatedFaction:
					channelID = ChatChannelEnum.FACTION;
					break;
			}

			return channelID;
		}

		public function addPanel( name:String, id:uint, channels:Array ):void
		{
			var newPanel:ChatPanelVO = new ChatPanelVO(name, id);
			var len:uint             = channels.length;
			for (var i:uint = 0; i < len; ++i)
				newPanel.addChannel(channels[i], getChannelFromId(channels[i]));

			chatPanels.push(newPanel);
		}

		public function removePanel( id:uint ):void
		{
			var len:uint = chatPanels.length;
			var currentPanel:ChatPanelVO;
			for (var i:uint = 0; i < len; ++i)
			{
				currentPanel = chatPanels[i];
				if (currentPanel.id == id)
				{
					currentPanel = null;
					chatPanels.splice(i, 1);
					break;
				}

			}
		}

		public function addChannelToPanel( panelID:uint, channelID:int ):void
		{
			var len:uint = chatPanels.length;
			var currentPanel:ChatPanelVO;
			for (var i:uint = 0; i < len; ++i)
			{
				currentPanel = chatPanels[i];
				if (currentPanel.id == panelID)
				{
					currentPanel.addChannel(channelID, getChannelFromId(channelID));
					break;
				}

			}
		}

		public function removeChannelToPanel( panelID:uint, channelID:int ):void
		{
			var len:uint = chatPanels.length;
			var currentPanel:ChatPanelVO;
			for (var i:uint = 0; i < len; ++i)
			{
				currentPanel = chatPanels[i];
				if (currentPanel.id == panelID)
				{
					currentPanel.removeChannel(channelID);
					break;
				}

			}
		}

		public function getPanelLogs( panelID:uint ):String
		{
			var len:uint = chatPanels.length;
			var currentPanel:ChatPanelVO;
			for (var i:uint = 0; i < len; ++i)
			{
				currentPanel = chatPanels[i];
				if (currentPanel.id == panelID)
				{
					return currentPanel.logs;
				}

			}
			return '';
		}

		public function addChannel( channelId:int, isActive:Boolean = false ):void
		{
			var channelName:String     = getChannelNameFromId(channelId);
			var playerSendable:Boolean = getChannelPlayerSendableFromId(channelId);
			var channelColor:int       = getChannelColorFromId(channelId);

			var channel:ChatChannelVO  = new ChatChannelVO(channelId, channelName, channelColor, playerSendable);

			_channels[channelId] = channel;

			if (isActive)
			{
				_activeChannels[channelId] = channel;

				if (_defaultChannel == null && channelId == ChatChannelEnum.GLOBAL)
					defaultChannel = channel;

				activeChannelUpdated.dispatch(_activeChannels);
			}
		}

		public function activateChannel( channelId:int ):void
		{
			if (channelId in _channels)
			{
				var channelVO:ChatChannelVO = _channels[channelId];

				_activeChannels[channelId] = channelVO;

				if (_defaultChannel == null && channelId == ChatChannelEnum.GLOBAL)
					defaultChannel = channelVO;

				activeChannelUpdated.dispatch(_activeChannels);
			}
		}

		public function deactivateChannel( channelId:int ):void
		{
			if (channelId in _channels)
			{
				if (channelId in _activeChannels)
				{
					if (_defaultChannel == _activeChannels[channelId])
						_defaultChannel = null;

					delete _activeChannels[channelId];

					if (ChatChannelEnum.SECTOR in _activeChannels)
						_defaultChannel = _activeChannels[ChatChannelEnum.SECTOR];

					activeChannelUpdated.dispatch(_activeChannels);
				}
			}
		}

		public function addChatLog( vo:ChatVO ):void
		{
			var currentPanel:ChatPanelVO;
			var len:uint = _chatPanels.length;
			for (var i:uint = 0; i < len; ++i)
			{
				currentPanel = _chatPanels[i];
				if (currentPanel.listeningToChannel(vo.channelID))
				{
					currentPanel.addChatLog(vo, convertVOToText(vo));
					chatSignal.dispatch(currentPanel.id, currentPanel.logs, true);
				}
			}
		}

		public function rewriteChatLogs( panelID:uint ):void
		{
			var currentPanel:ChatPanelVO;
			var len:uint = _chatPanels.length;
			var i:uint;
			for (; i < len; ++i)
			{
				currentPanel = _chatPanels[i];
				if (currentPanel.id == panelID)
					break;
			}

			if (currentPanel)
			{
				var panelChatLogs:String = '';
				var logs:Vector.<ChatVO> = currentPanel.chatlogVO;
				var currentChat:ChatVO;
				len = logs.length
				for (i = 0; i < len; ++i)
				{
					currentChat = logs[i];
					if (currentChat)
					{
						panelChatLogs += convertVOToText(currentChat)
					}
				}
				currentPanel.logs = panelChatLogs;
				chatSignal.dispatch(currentPanel.id, currentPanel.logs, false);
			}
		}

		public function addOrRemoveBlocked( id:String ):void
		{
			if (_blockList)
			{
				var index:int = _blockList.indexOf(id);
				if (index != -1)
					_blockList.splice(index, 1);
				else
					_blockList.push(id);
			}
		}

		public function isBlocked( id:String ):Boolean
		{
			var index:int = -1;
			if (_blockList)
				index = _blockList.indexOf(id);

			return (index == -1) ? false : true;
		}

		public function isMuted( id:String ):Boolean
		{
			var found:Boolean;
			if (_muteList.indexOf(id) != -1)
				found = true;

			return found;
		}

		public function mutePlayer( id:String ):void
		{
			var index:int = _muteList.indexOf(id);
			if (index != -1)
				_muteList.splice(index, 1);
			else
				_muteList.push(id);
		}

		public function overrideDefaultChannelByChannelID( newChannelId:int ):void
		{
			var newChannel:ChatChannelVO = getChannelFromId(newChannelId);
			if (newChannel != null && newChannel.playerSendable == true)
			{
				defaultChannel = newChannel;

				var index:int = DictionaryUtil.getValues(activeChannels).indexOf(defaultChannel);
				if (index >= 0)
					onDefaultChannelOverriden.dispatch(index);
			}
		}

		private function convertVOToText( vo:ChatVO ):String
		{
			if (_muteList.indexOf(vo.userID) != -1)
				return '';

			var message:String;
			var localizedMsgId:String;
			var tokens:Array            = new Array();
			var chatDict:Dictionary     = new Dictionary();
			var locManager:Localization = Localization.instance;

			chatDict['[[HexNumber.Color]]'] = vo.channel.channelColor.toString(16);
			if (vo.channel.channelID == ChatChannelEnum.SYSTEM)
			{
				localizedMsgId = _systemMessage;
			} else if (vo.channel.channelID == ChatChannelEnum.BROADCAST || vo.channel.channelID == ChatChannelEnum.WHISPER)
			{
				localizedMsgId = _defaultMessage
				if (vo.userName == '')
					vo.userName = 'Admin';

				chatDict['[[String.PlayerName]]'] = vo.userName;
			} else if (vo.channel.channelID == ChatChannelEnum.EVENT)
			{
				localizedMsgId = _defaultMessage
				if (vo.userName == '')
					vo.userName = 'Unknown';

				chatDict['[[String.PlayerName]]'] = vo.userName;
			} else
			{
				localizedMsgId = _message;



				var channelName:String = vo.channel.displayName;
				chatDict['[[String.NameLink]]'] = vo.userID + ':' + vo.userName;
				chatDict['[[String.PlayerName]]'] = vo.userName;
				chatDict['[[FactionHexNumber.Color]]'] = CommonFunctionUtil.getFactionColor(vo.userFaction).toString(16);

			}
			chatDict['[[String.Message]]'] = vo.message;

			vo.localizedMessage = locManager.localizeStringWithTokens(localizedMsgId, chatDict);

			return vo.localizedMessage;
		}

		private function getChannelNameFromId( channelID:int ):String
		{
			var channelName:String = '';
			switch (channelID)
			{
				case ChatChannelEnum.GLOBAL:
					channelName = _global;
					break;
				case ChatChannelEnum.FACTION:
					channelName = _faction;
					break;
				case ChatChannelEnum.SECTOR:
					channelName = _sector;
					break;
				case ChatChannelEnum.GROUP:
					channelName = _group;
					break;
				case ChatChannelEnum.ALLIANCE:
					channelName = _alliance;
					break;
				case ChatChannelEnum.MEMBERS:
					channelName = _members;
					break;
			}
			return channelName;
		}

		private function getChannelPlayerSendableFromId( channelID:int ):Boolean
		{
			var playerSendable:Boolean;
			switch (channelID)
			{
				case ChatChannelEnum.GLOBAL:
				case ChatChannelEnum.FACTION:
				case ChatChannelEnum.ALLIANCE:
				case ChatChannelEnum.MEMBERS:
				case ChatChannelEnum.GROUP:
				case ChatChannelEnum.SECTOR:
					playerSendable = true;
					break;
				case ChatChannelEnum.SYSTEM:
				case ChatChannelEnum.BROADCAST:
				case ChatChannelEnum.EVENT:
					playerSendable = false;
					break;
			}

			return playerSendable;
		}

		public function get activeChannels():Dictionary  { return _activeChannels; }

		public function get defaultChannel():ChatChannelVO  { return _defaultChannel; }

		public function get chatPanels():Vector.<ChatPanelVO>  { return _chatPanels; }

		public function set blockedList( v:Vector.<String> ):void  { _blockList = v; }
		public function get blockedList():Vector.<String>  { return _blockList; }

		public function set defaultChannel( newChannel:ChatChannelVO ):void
		{
			if (newChannel.channelID in _activeChannels && newChannel.playerSendable == true)
			{
				_defaultChannel = newChannel;
				onDefaultChannelUpdated.dispatch(newChannel);
			}
		}
	}
}
