package com.presenter.shared
{
	import com.controller.ChatController;
	import com.controller.ServerController;
	import com.controller.transaction.TransactionController;
	import com.enum.server.ProtocolEnum;
	import com.enum.server.RequestEnum;
	import com.event.SectorEvent;
	import com.game.entity.systems.interact.SectorInteractSystem;
	import com.model.asset.AssetModel;
	import com.model.asset.AssetVO;
	import com.model.player.PlayerModel;
	import com.model.player.PlayerVO;
	import com.model.prototype.IPrototype;
	import com.model.prototype.PrototypeModel;
	import com.model.sector.SectorModel;
	import com.model.sector.SectorVO;
	import com.model.starbase.StarbaseModel;
	import com.presenter.ImperiumPresenter;
	import com.service.server.incoming.data.SectorData;
	import com.service.server.outgoing.alliance.AllianceSendInviteRequest;
	import com.service.server.outgoing.chat.ChatReportChatRequest;
	import com.service.server.outgoing.leaderboard.LeaderboardRequestPlayerProfileRequest;

	import org.ash.core.Game;

	public class PlayerProfilePresenter extends ImperiumPresenter implements IPlayerProfilePresenter
	{
		private var _playerModel:PlayerModel;
		private var _assetModel:AssetModel;
		private var _prototypeModel:PrototypeModel;
		private var _sectorModel:SectorModel;
		private var _starbaseModel:StarbaseModel;
		private var _serverController:ServerController;
		private var _chatController:ChatController;
		private var _transactionController:TransactionController;
		private var _game:Game;

		[PostConstruct]
		override public function init():void
		{
			super.init();
		}

		public function getPlayer( id:String ):PlayerVO
		{
			return _playerModel.getPlayer(id);
		}

		public function requestPlayer( id:String, name:String = '' ):void
		{
			var leaderboardRequestPlayerProfile:LeaderboardRequestPlayerProfileRequest = LeaderboardRequestPlayerProfileRequest(_serverController.getRequest(ProtocolEnum.LEADERBOARD_CLIENT, RequestEnum.
																																							 LEADERBOARD_REQUEST_PLAYER_PROFILE));
			leaderboardRequestPlayerProfile.playerKey = id;
			leaderboardRequestPlayerProfile.nameSearch = name;
			_serverController.send(leaderboardRequestPlayerProfile);
		}

		public function allianceSendInvite( playerKey:String ):void
		{
			var sendInvite:AllianceSendInviteRequest = AllianceSendInviteRequest(_serverController.getRequest(ProtocolEnum.ALLIANCE_CLIENT, RequestEnum.ALLIANCE_SEND_INVITE));
			sendInvite.playerKey = playerKey;
			_serverController.send(sendInvite);
		}

		public function reportPlayer( id:String ):void
		{
			var reportPlayerRequest:ChatReportChatRequest = ChatReportChatRequest(_serverController.getRequest(ProtocolEnum.CHAT_CLIENT, RequestEnum.CHAT_REPORT_CHAT));
			reportPlayerRequest.playerKey = id;
			_serverController.send(reportPlayerRequest);

			if (!_chatController.isMuted(id))
				_chatController.mutePlayer(id);
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

		public function loadPortraitProfile( portraitName:String, callback:Function ):void
		{
			var avatarVO:AssetVO = AssetVO(_assetModel.getFromCache(portraitName));
			if(avatarVO != null)
				_assetModel.getFromCache('assets/' + avatarVO.profileImage, callback);
		}

		public function loadSmallImage( smallImageName:String, callback:Function ):void
		{
			_assetModel.getFromCache('assets/' + smallImageName, callback);
		}

		public function getConstantPrototypeValueByName( name:String ):*
		{
			return _prototypeModel.getConstantPrototypeValueByName(name);
		}

		public function renamePlayer( newName:String ):void
		{
			_transactionController.starbaseRenamePlayer(newName);
		}

		public function relocateStarbase( targetPlayer:String ):void
		{
			_transactionController.starbaseRelocateStarbase(targetPlayer);
		}

		public function getAssetVO( assetName:String ):AssetVO
		{
			return _assetModel.getEntityData(assetName);
		}

		public function getCommendationRankPrototypesByName( name:String ):IPrototype
		{
			return _prototypeModel.getCommendationRankPrototypesByName(name);
		}

		public function currentPlayerInABattle():Boolean
		{
			var inBattle:Boolean;

			if (_starbaseModel.currentBase.battleServerAddress != null && _starbaseModel.currentBase.battleServerAddress != '')
				inBattle = true;
			
			if (_starbaseModel.currentBase.instancedMissionAddress != null && _starbaseModel.currentBase.instancedMissionAddress != '')
				inBattle = true;
			
			return inBattle;
		}

		public function getCurrentUsersHomeSector():SectorData
		{
			return _starbaseModel.currentBase.sector;
		}

		public function hasSectorSplitTestCohort( sectorId:String ):Boolean
		{
			if (_sectorModel)
			{
				var sectors:Vector.<SectorVO> = _sectorModel.destinations;
				var sector:SectorVO           = null;
				if (sectors)
				{
					for (var i:int = 0; i < sectors.length; ++i)
					{
						sector = sectors[i];
						if (sector && sector.id == sectorId)
							return sector.splitTestCohortPrototype != null;
					}
				}
			}
			return false;
		}

		public function addOnPlayerVOAddedListener( callback:Function ):void  { _playerModel.onPlayerAdded.add(callback); }
		public function removeOnPlayerVOAddedListener( callback:Function ):void  { _playerModel.onPlayerAdded.remove(callback); }

		[Inject]
		public function set playerModel( v:PlayerModel ):void  { _playerModel = v; }
		[Inject]
		public function set assetModel( v:AssetModel ):void  { _assetModel = v; }
		[Inject]
		public function set sectorModel( v:SectorModel ):void  { _sectorModel = v; }
		[Inject]
		public function set prototypeModel( v:PrototypeModel ):void  { _prototypeModel = v; }
		[Inject]
		public function set starbaseModel( v:StarbaseModel ):void  { _starbaseModel = v; }
		[Inject]
		public function set serverController( v:ServerController ):void  { _serverController = v; }
		[Inject]
		public function set chatController( v:ChatController ):void  { _chatController = v; }
		[Inject]
		public function set transactionController( v:TransactionController ):void  { _transactionController = v; }
		[Inject]
		public function set game( v:Game ):void  { _game = v; }

		override public function destroy():void
		{
			super.destroy();
		}
	}
}
