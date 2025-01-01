package com.controller
{
	import com.enum.PlayerUpdateEnum;
	import com.enum.server.ChatChannelEnum;
	import com.enum.server.ChatResponseCodeEnum;
	import com.enum.server.ProtocolEnum;
	import com.enum.server.RequestEnum;
	import com.game.entity.systems.shared.background.BackgroundSystem;
	import com.model.chat.ChatChannelVO;
	import com.model.chat.ChatModel;
	import com.model.chat.ChatPanelVO;
	import com.model.chat.ChatVO;
	import com.model.player.CurrentUser;
	import com.model.sector.SectorModel;
	import com.service.language.Localization;
	import com.service.server.incoming.chat.ChatBaselineResponse;
	import com.service.server.incoming.chat.ChatResponse;
	import com.service.server.outgoing.chat.ChatChangeRoomRequest;
	import com.service.server.outgoing.chat.ChatIgnoreChatRequest;
	import com.service.server.outgoing.chat.ChatReportChatRequest;
	import com.service.server.outgoing.chat.ChatSendChatRequest;

	import flash.utils.Dictionary;

	import org.adobe.utils.StringUtil;
	import org.as3commons.logging.api.ILogger;
	import org.as3commons.logging.api.getLogger;
	import org.ash.core.Game;
	import org.shared.ObjectPool;

	public class ChatController
	{
		public var chatHasFocus:Boolean            = false;

		private var _chatModel:ChatModel;
		private var _slashCommands:Dictionary;

		private var _sectorModel:SectorModel;
		private var _serverController:ServerController;
		private var _backgroundSystem:BackgroundSystem
		private var _game:Game;

		private var _printResults:Boolean;
		private var _loggedIn:Boolean;
		private var _lostConnection:Boolean;

		private var _sector:String                 = 'CodeString.Chat.ChannelName.Sector'; //Sector
		private var _group:String                  = 'CodeString.Chat.ChannelName.Group'; //Group
		private var _faction:String                = 'CodeString.Chat.ChannelName.Faction'; //Faction
		private var _alliance:String               = 'CodeString.Chat.ChannelName.Alliance'; //Alliance
		private var _members:String          = 'CodeString.Chat.ChannelName.Members'; //Members
		private var _centerspace:String            = 'CodeString.Chat.ChannelName.CenterSpace'; //Center Space
		private var _listBlockedUsers:String       = 'CodeString.Chat.SlashCommand.ListBlockedUsers'; //listblockedusers
		private var _getChannelUsers:String        = 'CodeString.Chat.SlashCommand.GetChannelUsers'; //getchannelusers
		private var _help:String                   = 'CodeString.Chat.SlashCommand.Help'; //help
		private var _helpText:String               = 'CodeString.Chat.Message.HelpText'; //Valid Slash Commands:<br>/s - Sector Chat<br>/g - Group Chat<br>/f - Faction Chat<br>/a - Alliance Chat<br>/c - Center Space Chat<br>/getchannelusers - Gets a list of current channel users<br> /listBlockedUsers - Gets a list of blocked users
		private var _blockedUser:String            = 'CodeString.Chat.Message.BlockedUser'; //Blocked User
		private var _unblockedUser:String          = 'CodeString.Chat.Message.UnblockedUser'; //Unblocked User
		private var _blockedUsers:String           = 'CodeString.Chat.Message.BlockedUsers'; //Blocked Users: 
		private var _channelUsers:String           = 'CodeString.Chat.Message.ChannelUsers'; //Channel Users: 

		private var _sectorChannelID:String        = 'sector';
		private var _groupChannelID:String         = 'group';
		private var _factionChannelID:String       = 'faction';
		private var _allianceChannelID:String      = 'alliance';
		private var _membersChannelID:String       = 'members';
		private var _centerspaceChannelID:String   = 'centerspace';
		private var _systemMessageChannelID:String = 'systemmessage';

		private const _logger:ILogger              = getLogger('ChatController');

		[PostConstruct]
		public function init():void
		{
			_slashCommands = new Dictionary();
			_slashCommands['/s'] = ChatChannelEnum.SECTOR;
			//_slashCommands['/g'] = ChatChannelEnum.GROUP;
			_slashCommands['/g'] = ChatChannelEnum.GLOBAL;
			_slashCommands['/a'] = ChatChannelEnum.ALLIANCE;
			_slashCommands['/f'] = ChatChannelEnum.FACTION;
			_slashCommands['/m'] = ChatChannelEnum.MEMBERS;
			//_slashCommands['/c'] = _centerspaceChannelID;

			_backgroundSystem = BackgroundSystem(_game.getSystem(BackgroundSystem));
			_sectorModel.addSectorChangeListener(joinSectorChat);
			CurrentUser.onPlayerUpdate.add(onPlayerUpdate);
		}

		public function initStrings():void
		{
			var locManager:Localization = Localization.instance;
			_sector = locManager.getString(_sector);
			_group = locManager.getString(_group);
			_faction = locManager.getString(_faction);
			_alliance = locManager.getString(_alliance);
			_members = locManager.getString(_members);
			_centerspace = locManager.getString(_centerspace).split(' ').join('');
			_getChannelUsers = locManager.getString(_getChannelUsers);
			_listBlockedUsers = locManager.getString(_listBlockedUsers);
			_help = locManager.getString(_help);
			_helpText = locManager.getString(_helpText);
			_blockedUser = locManager.getString(_blockedUser);
			_unblockedUser = locManager.getString(_unblockedUser);
			_blockedUsers = locManager.getString(_blockedUsers);
			_channelUsers = locManager.getString(_channelUsers);
		}

		public function give( serverController:ServerController ):void
		{
			_serverController = serverController;
		}

		private function onPlayerUpdate( updateType:int, oldValue:String, newValue:String ):void
		{
			if (PlayerUpdateEnum.TYPE_ALLIANCE)
			{
				if (oldValue != newValue)
				{
					if (newValue != '')
						_chatModel.activateChannel(ChatChannelEnum.ALLIANCE);
					else
						_chatModel.deactivateChannel(ChatChannelEnum.ALLIANCE);
				}
			}
		}

		public function sendChatMessageWithDefaultChannel( message:String ):void
		{
			if (_chatModel.defaultChannel == null)
			{
				_chatModel.overrideDefaultChannelByChannelID(ChatChannelEnum.SECTOR);
				_logger.error('Whoa there guy no default channel trying to set the default to sector.')
			}

			if (_chatModel.defaultChannel == null)
				_logger.fatal('YOU HAVE NO SECTOR CHANNEL SOMETHING IS MESSED UP! GAME OVER MAN GAME OVER')
			else
				sendChannelMessage(_chatModel.defaultChannel.channelID, message);
		}

		public function handleSlashCommand( message:String ):void
		{
			var messageParts:Array = message.split(' ');
			var firstWord:String   = messageParts[0];
			var command:String;
			if (firstWord.length < 3)
				command = firstWord.toLowerCase();
			else
			{
				command = firstWord.slice(1).toLowerCase();
			}

			switch (command)
			{
				case _getChannelUsers:
					_printResults = true;
					break;
				case _listBlockedUsers:
					_printResults = true;
					break;
				case _help:
					addSystemMessage(_helpText);
					break;
				default:
					var channelID:int = -1;
					if (command.length < 3)
					{
						channelID = _slashCommands[command];
					} else
					{
						_chatModel.getChannelIdFromName(command);
					}

					if (channelID != -1 && _chatModel.isInChannel(channelID))
					{
						messageParts.shift();
						sendChannelMessage(channelID, messageParts.join(' '));
					}
					break;
			}
		}

		public function linkCoords( x:int, y:int ):void
		{
			var message:String = x + ',' + y;
			if (_chatModel.defaultChannel)
				sendChannelMessage(_chatModel.defaultChannel.channelID, message);
		}

		private function addMessage( channel:int, userNID:String, userDisplayName:String, userFaction:String, message:String ):void
		{

			var chatChannel:ChatChannelVO = _chatModel.getChannelFromId(channel);
			userDisplayName = StringUtil.htmlEncode(userDisplayName);
			message = StringUtil.escapeHTML(message);
			message = checkForCoords(message, true);
			message = checkForAlliance(message);
			var newMessage:ChatVO         = ObjectPool.get(ChatVO);
			newMessage.init(userNID, userDisplayName, userFaction, chatChannel, message);
			_chatModel.addChatLog(newMessage);
		}

		public function addSystemMessage( message:String, faction:String = '', systemName:String = '' ):void
		{
			var chatChannel:ChatChannelVO = _chatModel.getChannelFromId(ChatChannelEnum.SYSTEM);
			var newMessage:ChatVO         = ObjectPool.get(ChatVO);
			newMessage.init('none', systemName, faction, chatChannel, message);
			_chatModel.addChatLog(newMessage);
		}

		private function checkForAlliance( message:String ):String
		{
			
			if (message.indexOf('[alliance.') != -1)
			{	
				// matches strings between square brackets and with alliance in it [alliance.*], ignores nested combinations and extracts only the inner part
				var allianceInSquareBracketsRegExp:RegExp = /\[alliance.[^\[\]]*?\]/g;
				var messageParts:Array = message.match(allianceInSquareBracketsRegExp);
				var allianceLinks:Dictionary = new Dictionary();
				var len:uint           = messageParts.length;
				var currentPartOfMessage:String;
				var indexOfDot:int;
				for (var i:uint = 0; i < len; ++i)
				{
					currentPartOfMessage = messageParts[i];

					var allianceName:String = currentPartOfMessage.replace("[alliance.", "");
					allianceName = allianceName.replace("]", "");
					
					if(allianceName != "")
					{
						// Prepare extracted alliance key to match database key
						var allianceNameLink:String = allianceName.toLowerCase();
						allianceNameLink = allianceNameLink.replace(" ", "_");
						allianceLinks[currentPartOfMessage] = "<font color='#2ecc71'><a href='event:AllianceLink." + allianceNameLink + "'>" + allianceName + "</a></font>";
					}
				}
				
				// Prepare message with hyperlinks
				for ( var key:String in allianceLinks ) 
				{
					var currentLink:String = allianceLinks[key] as String;
					var previousReplacedIndex:int =  message.indexOf(key);
					
					while (previousReplacedIndex != -1)
					{						
						message = message.replace(key, currentLink);
						previousReplacedIndex =  message.indexOf(key, currentLink.length + previousReplacedIndex);
					}
				}
			}
			return message;
		}	
		
		private function checkForCoords( message:String, recieved:Boolean = false ):String
		{

			if (message.indexOf(',') != -1)
			{
				var sectorModel:SectorModel;
				if (_backgroundSystem == null)
					_backgroundSystem = BackgroundSystem(_game.getSystem(BackgroundSystem));

				if (_backgroundSystem)
					sectorModel = _backgroundSystem.sectorModel;

				var maxXCoord:Number   = (sectorModel) ? sectorModel.width * 0.01 : 350;
				var maxYCoord:Number   = (sectorModel) ? sectorModel.height * 0.01 : 350;
				var messageParts:Array = message.split(' ');
				var len:uint           = messageParts.length;
				var currentPartOfMessage:String;
				var indexOfComma:uint;
				var lenOfMessagePart:uint;
				var firstSetOfCoords:Boolean;
				var secondSetOfCoords:Boolean;
				for (var i:uint = 0; i < len; ++i)
				{
					currentPartOfMessage = messageParts[i];
					lenOfMessagePart = currentPartOfMessage.length;
					indexOfComma = currentPartOfMessage.indexOf(',');
					if (indexOfComma != -1 && lenOfMessagePart > indexOfComma + 1)
					{
						var parenIndex:int = currentPartOfMessage.indexOf('(');
						var coords1:Number = Number(currentPartOfMessage.substring(0, indexOfComma));
						var coords2:Number = Number(currentPartOfMessage.substring(indexOfComma + 1, (parenIndex != -1 && recieved) ? parenIndex : lenOfMessagePart));
						firstSetOfCoords = !isNaN(coords1);
						secondSetOfCoords = !isNaN(coords2);
						//check if they are coords and in coords range

						if (firstSetOfCoords == true && (coords1 <= maxXCoord && coords1 >= 0) && secondSetOfCoords == true && (coords2 <= maxYCoord && coords2 >= 0))
						{
							if (recieved)
							{
								var sector:String      = currentPartOfMessage.substring(parenIndex + 1, currentPartOfMessage.length - 1);
								var linkMessage:String = coords1 + ',' + coords2 + ',' + sector;
								messageParts[i] = "<font color='#a9dcff'><a href='event:CoordLink." + linkMessage + "'>" + currentPartOfMessage + "</a></font>"
							} else
							{
								messageParts[i] += '(' + _sectorModel.sectorID + ')';
							}
						}
					}
				}
				message = messageParts.join(' ');
			}
			return message;
		}

		public function isBlocked( id:String ):Boolean
		{
			return _chatModel.isBlocked(id);
		}

		public function isMuted( id:String ):Boolean
		{
			return _chatModel.isMuted(id);
		}

		public function mutePlayer( id:String ):void
		{
			_chatModel.mutePlayer(id);
		}

		public function recievedMessage( response:ChatResponse ):void
		{
			switch (response.responseCode)
			{
				case ChatResponseCodeEnum.OK:
					addMessage(response.channel, response.senderKey, response.senderName, response.senderFaction, response.message);
					break;
				case ChatResponseCodeEnum.ROOM_JOINED:
					_logger.info('SUCCESS: Room Joined {}', response.channel);
					_chatModel.activateChannel(response.channel);
					break;
				case ChatResponseCodeEnum.ROOM_LEFT:
					_logger.info('SUCCESS: Room Left {}', response.channel);
					_chatModel.deactivateChannel(response.channel);
					break;
				case ChatResponseCodeEnum.NO_SUCH_PLAYER:
					_logger.error('ERROR: No Such Player');
					break;
				case ChatResponseCodeEnum.NO_SUCH_CHAT_ROOM:
					_logger.error('ERROR: No Chat Channel');
					break;
			}
		}

		private function getAggregatedChannelID( requestedChannelID:int ):String
		{
			var faction:int  = requestedChannelID % 3;
			if (faction == 0)
				faction = 3;

			var grouping:int = Math.floor((requestedChannelID - 1) / 9);

			return faction + "." + grouping;
		}

		private function sendChannelMessage( channelId:int, message:String ):void
		{
			message = checkForCoords(message);
			var msg:ChatSendChatRequest = ChatSendChatRequest(_serverController.getRequest(ProtocolEnum.CHAT_CLIENT, RequestEnum.CHAT_SEND_CHAT));
			msg.channel = channelId;
			msg.message = message;
			msg.playerKey = CurrentUser.id;
			_serverController.send(msg);
		}

		public function sendUnblockOrBlock( userNAID:String ):void
		{
			_chatModel.addOrRemoveBlocked(userNAID);
			var msg:ChatIgnoreChatRequest = ChatIgnoreChatRequest(_serverController.getRequest(ProtocolEnum.CHAT_CLIENT, RequestEnum.CHAT_IGNORE_CHAT));
			msg.playerKey = userNAID;
			_serverController.send(msg);
		}

		public function sendReportChat( userNAID:String ):void
		{
			var msg:ChatReportChatRequest = ChatReportChatRequest(_serverController.getRequest(ProtocolEnum.CHAT_CLIENT, RequestEnum.CHAT_REPORT_CHAT));
			msg.playerKey = userNAID;
			_serverController.send(msg);
		}

		public function addBlockedUsers( response:ChatBaselineResponse ):void
		{
			_chatModel.blockedList = response.ignoredPlayers;
		}

		private function joinSectorChat( id:String ):void
		{
			var key:int                   = id ? int(id.split(".")[1]) : 1;
			var newID:String              = "sector." + getAggregatedChannelID(key);

			var msg:ChatChangeRoomRequest = ChatChangeRoomRequest(_serverController.getRequest(ProtocolEnum.CHAT_CLIENT, RequestEnum.CHAT_CHANGE_ROOM));
			msg.roomKey = id;
			msg.roomKey = newID;
			msg.channel = ChatChannelEnum.SECTOR;
			_serverController.send(msg);

			_logger.info('Change Room Request: Sector Channel {}', id);
		}

		public function addChatListener( callback:Function ):void  { _chatModel.chatSignal.add(callback); }
		public function removeChatListener( callback:Function ):void  { _chatModel.chatSignal.remove(callback); }

		public function addOnActiveChannelUpdatedListener( callback:Function ):void  { _chatModel.activeChannelUpdated.add(callback); }
		public function removeOnActiveChannelUpdatedListener( callback:Function ):void  { _chatModel.activeChannelUpdated.remove(callback); }

		public function addOnDefaultChannelLoadedListener( callback:Function ):void  { _chatModel.onDefaultChannelOverriden.add(callback); }
		public function removeOnDefaultChannelLoadedListener( callback:Function ):void  { _chatModel.onDefaultChannelOverriden.remove(callback); }

		public function addOnDefaultChannelUpdatedListener( callback:Function ):void  { _chatModel.onDefaultChannelUpdated.add(callback); }
		public function removeOnDefaultChannelUpdatedListener( callback:Function ):void  { _chatModel.onDefaultChannelUpdated.remove(callback); }

		public function getDefaultChannel():ChatChannelVO  { return _chatModel.defaultChannel; }
		public function setDefaultChannel( newDefaultId:ChatChannelVO ):void
		{
			_chatModel.defaultChannel = newDefaultId;
		}

		public function getChannelColorFromId( channelID:int ):uint
		{
			return _chatModel.getChannelColorFromId(channelID);
		}

		public function getActiveChannels():Dictionary  { return _chatModel.activeChannels; }
		public function getChatPanels():Vector.<ChatPanelVO>  { return _chatModel.chatPanels; }
		public function getPanelLogs( panelID:uint ):String  { return _chatModel.getPanelLogs(panelID); }

		public function get blockedList():Vector.<String>  { return _chatModel.blockedList; }

		[Inject]
		public function set chatModel( v:ChatModel ):void  { _chatModel = v; }
		[Inject]
		public function set game( v:Game ):void  { _game = v; }
		[Inject]
		public function set sectorModel( v:SectorModel ):void  { _sectorModel = v; }
	}
}
