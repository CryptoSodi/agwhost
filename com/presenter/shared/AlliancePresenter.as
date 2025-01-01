package com.presenter.shared
{
	import com.controller.ServerController;
	import com.controller.GameController;
	import com.enum.server.ProtocolEnum;
	import com.enum.server.RequestEnum;
	import com.model.alliance.AllianceModel;
	import com.model.player.CurrentUser;
	import com.presenter.ImperiumPresenter;
	import com.service.server.outgoing.alliance.AllianceCreateAllianceRequest;
	import com.service.server.outgoing.alliance.AllianceDemoteRequest;
	import com.service.server.outgoing.alliance.AllianceIgnoreInvitesRequest;
	import com.service.server.outgoing.alliance.AllianceJoinRequest;
	import com.service.server.outgoing.alliance.AllianceKickRequest;
	import com.service.server.outgoing.alliance.AllianceLeaveRequest;
	import com.service.server.outgoing.alliance.AlliancePromoteRequest;
	import com.service.server.outgoing.alliance.AllianceRequestBaselineRequest;
	import com.service.server.outgoing.alliance.AllianceRequestPublicsRequest;
	import com.service.server.outgoing.alliance.AllianceRequestRosterRequest;
	import com.service.server.outgoing.alliance.AllianceSendInviteRequest;
	import com.service.server.outgoing.alliance.AllianceSetDescriptionRequest;
	import com.service.server.outgoing.alliance.AllianceSetMOTDRequest;
	import com.service.server.outgoing.alliance.AllianceSetPublicRequest;

	import flash.utils.Dictionary;

	public class AlliancePresenter extends ImperiumPresenter implements IAlliancePresenter
	{
		private var _allianceModel:AllianceModel;
		private var _serverController:ServerController;
		private var _gameController:GameController;

		[PostConstruct]
		override public function init():void
		{
			super.init();
		}

		public function allianceBaselineRequest( allianceKey:String ):void
		{
			var getAllianceBaseline:AllianceRequestBaselineRequest = AllianceRequestBaselineRequest(_serverController.getRequest(ProtocolEnum.ALLIANCE_CLIENT, RequestEnum.ALLIANCE_REQUEST_BASELINE));
			getAllianceBaseline.allianceKey = allianceKey;
			_serverController.send(getAllianceBaseline);
		}

		public function allianceRosterRequest( allianceKey:String ):void
		{
			var getAllianceRoster:AllianceRequestRosterRequest = AllianceRequestRosterRequest(_serverController.getRequest(ProtocolEnum.ALLIANCE_CLIENT, RequestEnum.ALLIANCE_REQUEST_ROSTER));
			getAllianceRoster.allianceKey = allianceKey;
			_serverController.send(getAllianceRoster);
		}

		public function alliancePublicAllianceRequest():void
		{
			var getPublics:AllianceRequestPublicsRequest = AllianceRequestPublicsRequest(_serverController.getRequest(ProtocolEnum.ALLIANCE_CLIENT, RequestEnum.ALLIANCE_REQUEST_PUBLICS));
			getPublics.faction = CurrentUser.faction;
			_serverController.send(getPublics);
		}

		public function allianceCreateRequest( name:String, isPublic:Boolean, description:String ):void
		{
			var createAlliance:AllianceCreateAllianceRequest = AllianceCreateAllianceRequest(_serverController.getRequest(ProtocolEnum.ALLIANCE_CLIENT, RequestEnum.ALLIANCE_CREATE_ALLIANCE));
			createAlliance.name = name;
			createAlliance.publicAlliance = isPublic;
			createAlliance.description = description;
			_serverController.send(createAlliance);
		}

		public function allianceSetMOTD( motd:String ):void
		{
			var setMOTD:AllianceSetMOTDRequest = AllianceSetMOTDRequest(_serverController.getRequest(ProtocolEnum.ALLIANCE_CLIENT, RequestEnum.ALLIANCE_SET_MOTD));
			setMOTD.motd = motd;
			_serverController.send(setMOTD);
		}

		public function allianceSetDescription( description:String ):void
		{
			var setDescription:AllianceSetDescriptionRequest = AllianceSetDescriptionRequest(_serverController.getRequest(ProtocolEnum.ALLIANCE_CLIENT, RequestEnum.ALLIANCE_SET_DESCRIPTION));
			setDescription.description = description;
			_serverController.send(setDescription);
		}

		public function allianceSetPublic( isPublic:Boolean ):void
		{
			var setPublic:AllianceSetPublicRequest = AllianceSetPublicRequest(_serverController.getRequest(ProtocolEnum.ALLIANCE_CLIENT, RequestEnum.ALLIANCE_SET_PUBLIC));
			setPublic.publicAlliance = isPublic;
			_serverController.send(setPublic);
		}

		public function alliancePlayerPromote( playerKey:String ):void
		{
			var promotePlayer:AlliancePromoteRequest = AlliancePromoteRequest(_serverController.getRequest(ProtocolEnum.ALLIANCE_CLIENT, RequestEnum.ALLIANCE_PROMOTE));
			promotePlayer.playerKey = playerKey;
			_serverController.send(promotePlayer);
		}

		public function alliancePlayerDemote( playerKey:String ):void
		{
			var demotePlayer:AllianceDemoteRequest = AllianceDemoteRequest(_serverController.getRequest(ProtocolEnum.ALLIANCE_CLIENT, RequestEnum.ALLIANCE_DEMOTE));
			demotePlayer.playerKey = playerKey;
			_serverController.send(demotePlayer);
		}

		public function alliancePlayerKick( playerKey:String ):void
		{
			var kickPlayer:AllianceKickRequest = AllianceKickRequest(_serverController.getRequest(ProtocolEnum.ALLIANCE_CLIENT, RequestEnum.ALLIANCE_KICK));
			kickPlayer.playerKey = playerKey;
			_serverController.send(kickPlayer);
		}

		public function allianceLeave():void
		{
			var leaveAlliance:AllianceLeaveRequest = AllianceLeaveRequest(_serverController.getRequest(ProtocolEnum.ALLIANCE_CLIENT, RequestEnum.ALLIANCE_LEAVE_ALLIANCE));
			_serverController.send(leaveAlliance);
		}

		public function allianceJoin( allianceKey:String ):void
		{
			var join:AllianceJoinRequest = AllianceJoinRequest(_serverController.getRequest(ProtocolEnum.ALLIANCE_CLIENT, RequestEnum.ALLIANCE_JOIN_ALLIANCE));
			join.allianceKey = allianceKey;
			_serverController.send(join);
		}

		public function allianceSendInvite( playerKey:String ):void
		{
			var sendInvite:AllianceSendInviteRequest = AllianceSendInviteRequest(_serverController.getRequest(ProtocolEnum.ALLIANCE_CLIENT, RequestEnum.ALLIANCE_SEND_INVITE));
			sendInvite.playerKey = playerKey;
			_serverController.send(sendInvite);
		}

		public function allianceIgnoreInvites():void
		{
			var ignoreInvites:AllianceIgnoreInvitesRequest = AllianceIgnoreInvitesRequest(_serverController.getRequest(ProtocolEnum.ALLIANCE_CLIENT, RequestEnum.ALLIANCE_IGNORE_INVITES));
			_serverController.send(ignoreInvites);
		}

		public function getAllianceInvites():Dictionary
		{
			return _allianceModel.getAllianceInvites();
		}

		public function sendGetMailboxMessage():void
		{
			_gameController.mailGetMailbox();
		}
		
		public function addOnAllianceUpdatedListener( callback:Function ):void  { _allianceModel.onAllianceUpdated.add(callback); }
		public function removeOnAllianceUpdatedListener( callback:Function ):void  { _allianceModel.onAllianceUpdated.remove(callback); }

		public function addOnOpenAlliancesUpdatedListener( callback:Function ):void  { _allianceModel.onOpenAlliancesUpdated.add(callback); }
		public function removeOnOpenAlliancesUpdatedListener( callback:Function ):void  { _allianceModel.onOpenAlliancesUpdated.remove(callback); }

		public function addOnInvitedAlliancesUpdatedListener( callback:Function ):void  { _allianceModel.onInvitedAlliancesUpdated.add(callback); }
		public function removeOnInvitedAlliancesUpdatedListener( callback:Function ):void  { _allianceModel.onInvitedAlliancesUpdated.remove(callback); }

		public function addOnAllianceMembersUpdatedListener( callback:Function ):void  { _allianceModel.onAllianceMembersUpdated.add(callback); }
		public function removeOnAllianceMembersUpdatedListener( callback:Function ):void  { _allianceModel.onAllianceMembersUpdated.remove(callback); }

		public function addOnGenericAllianceMessageRecievedListener( callback:Function ):void  { _allianceModel.onGenericAllianceMessageRecieved.add(callback); }
		public function removeOnGenericAllianceMessageRecievedListener( callback:Function ):void  { _allianceModel.onGenericAllianceMessageRecieved.remove(callback); }

		[Inject]
		public function set allianceModel( v:AllianceModel ):void  { _allianceModel = v; }
		[Inject]
		public function set serverController( v:ServerController ):void  { _serverController = v; }
		[Inject]
		public function set gameController( v:GameController ):void  { _gameController = v; }		
		
		override public function destroy():void
		{
			super.destroy();
			_allianceModel = null;
			_serverController = null;
		}
	}
}
