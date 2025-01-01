package com.presenter.shared
{
	import com.Application;
	import com.controller.ChatController;
	import com.controller.GameController;
	import com.event.SectorEvent;
	import com.game.entity.systems.interact.SectorInteractSystem;
	import com.model.chat.ChatChannelVO;
	import com.model.chat.ChatPanelVO;
	import com.model.motd.MotDModel;
	import com.model.motd.MotDVO;
	import com.model.player.PlayerModel;
	import com.model.player.PlayerVO;
	import com.model.sector.SectorModel;
	import com.presenter.ImperiumPresenter;
	
	import com.service.ExternalInterfaceAPI;
	
	import com.event.ServerEvent;
	
	import flash.events.IEventDispatcher;
	
	import flash.utils.Dictionary;

	import org.ash.core.Game;

	public class ChatPresenter extends ImperiumPresenter implements IChatPresenter
	{
		private var _game:Game;
		private var _chatController:ChatController;
		private var _gameController:GameController;
		private var _sectorModel:SectorModel;
		private var _motdModel:MotDModel;
		private var _playerModel:PlayerModel;

		public function sendChatMessage( message:String ):void
		{
			if (Application.NETWORK == Application.NETWORK_GUEST)
			{
				ExternalInterfaceAPI.logConsole("Guest Chat Restriction");
				var serverEvent:ServerEvent
				serverEvent = new ServerEvent(ServerEvent.GUEST_RESTRICTION);
				_eventDispatcher.dispatchEvent(serverEvent);
			}
			else
			{
				if (message.charAt(0) == '/')
					_chatController.handleSlashCommand(message);
				else
					_chatController.sendChatMessageWithDefaultChannel(message);
			}
		}

		public function gotoCoords( x:int, y:int, sector:String ):void
		{

			if (sector != _sectorModel.sectorID)
			{
				jumpToSector(x, y, sector);
			} else
			{
				var system:SectorInteractSystem = SectorInteractSystem(_game.getSystem(SectorInteractSystem));
				if (system != null)
					system.moveToLocation(x, y);
				else
				{
					jumpToSector(x, y, sector);
				}
			}

		}

		private function jumpToSector( x:int, y:int, sector:String ):void
		{
			var sectorEvent:SectorEvent = new SectorEvent(SectorEvent.CHANGE_SECTOR, sector, null, x, y);
			dispatch(sectorEvent);
		}

		public function requestPlayer( id:String, name:String = '' ):void
		{
			_gameController.leaderboardRequestPlayerProfile(id, name);
		}

		public function blockOrUnblockPlayer( id:String ):void
		{
			_chatController.sendUnblockOrBlock(id);
		}

		public function isBlocked( id:String ):Boolean
		{
			return _chatController.isBlocked(id);
		}

		public function mutePlayer( id:String ):void
		{
			_chatController.mutePlayer(id);
		}

		public function isMuted( id:String ):Boolean
		{
			return _chatController.isMuted(id);
		}

		public function getChannelColorFromChannelID( channelID:int ):uint
		{
			return _chatController.getChannelColorFromId(channelID);
		}

		public function getPlayer( id:String ):PlayerVO
		{
			return _playerModel.getPlayer(id);
		}

		public function getPanelLogs( panelID:uint ):String  { return _chatController.getPanelLogs(panelID); }
		public function getActiveChannels():Dictionary  { return _chatController.getActiveChannels(); }

		public function addChatListener( callback:Function ):void  { _chatController.addChatListener(callback); }
		public function removeChatListener( callback:Function ):void  { _chatController.removeChatListener(callback); }

		public function addOnActiveChannelUpdatedListener( callback:Function ):void  { _chatController.addOnActiveChannelUpdatedListener(callback); }
		public function removeOnActiveChannelUpdatedListener( callback:Function ):void  { _chatController.removeOnActiveChannelUpdatedListener(callback); }

		public function addOnDefaultChannelLoadedListener( callback:Function ):void  { _chatController.addOnDefaultChannelLoadedListener(callback); }
		public function removeOnDefaultChannelLoadedListener( callback:Function ):void  { _chatController.removeOnDefaultChannelLoadedListener(callback); }

		public function addOnDefaultChannelUpdatedListener( callback:Function ):void  { _chatController.addOnDefaultChannelUpdatedListener(callback); }
		public function removeOnDefaultChannelUpdatedListener( callback:Function ):void  { _chatController.removeOnDefaultChannelUpdatedListener(callback); }

		public function addMotDUpdatedListener( callback:Function ):void  { _motdModel.newMessage.add(callback); }
		public function removeMotDUpdatedListener( callback:Function ):void  { _motdModel.newMessage.remove(callback); }

		public function addOnPlayerVOAddedListener( callback:Function ):void  { _playerModel.onPlayerAdded.add(callback); }
		public function removeOnPlayerVOAddedListener( callback:Function ):void  { _playerModel.onPlayerAdded.remove(callback); }

		public function get defaultChannel():ChatChannelVO  { return _chatController.getDefaultChannel()}
		public function get chatHasFocus():Boolean  { return _chatController.chatHasFocus; }
		public function get blockedUsers():Vector.<String>  { return _chatController.blockedList; }
		public function get chatPanels():Vector.<ChatPanelVO>  { return _chatController.getChatPanels(); }
		public function get motdMessages():Vector.<MotDVO>  { return _motdModel.motd; }

		public function set defaultChannel( newDefault:ChatChannelVO ):void  { _chatController.setDefaultChannel(newDefault); }
		public function set chatHasFocus( value:Boolean ):void  { _chatController.chatHasFocus = value; }

		[Inject]
		public function set chatController( v:ChatController ):void  { _chatController = v; }
		[Inject]
		public function set game( v:Game ):void  { _game = v; }
		[Inject]
		public function set gameController( v:GameController ):void  { _gameController = v; }
		[Inject]
		public function set motdModel( v:MotDModel ):void  { _motdModel = v; }
		[Inject]
		public function set playerModel( v:PlayerModel ):void  { _playerModel = v; }
		[Inject]
		public function set sectorModel( v:SectorModel ):void  { _sectorModel = v; }
	}
}
