package com.presenter.shared
{
	import com.presenter.IImperiumPresenter;

	import flash.utils.Dictionary;

	public interface IAlliancePresenter extends IImperiumPresenter
	{
		function allianceBaselineRequest( allianceKey:String ):void;
		function allianceRosterRequest( allianceKey:String ):void;
		function alliancePublicAllianceRequest():void;
		function allianceCreateRequest( name:String, isPublic:Boolean, description:String ):void;
		function allianceSetMOTD( motd:String ):void;
		function allianceSetDescription( description:String ):void;
		function allianceSetPublic( isPublic:Boolean ):void;
		function alliancePlayerPromote( playerKey:String ):void;
		function alliancePlayerDemote( playerKey:String ):void;
		function alliancePlayerKick( playerKey:String ):void;
		function allianceLeave():void;
		function allianceJoin( allianceKey:String ):void;
		function allianceSendInvite( playerKey:String ):void;
		function allianceIgnoreInvites():void;
		function getAllianceInvites():Dictionary;

		function addOnAllianceUpdatedListener( callback:Function ):void;
		function removeOnAllianceUpdatedListener( callback:Function ):void;
		function addOnOpenAlliancesUpdatedListener( callback:Function ):void;
		function removeOnOpenAlliancesUpdatedListener( callback:Function ):void;
		function addOnInvitedAlliancesUpdatedListener( callback:Function ):void;
		function removeOnInvitedAlliancesUpdatedListener( callback:Function ):void;
		function addOnAllianceMembersUpdatedListener( callback:Function ):void;
		function removeOnAllianceMembersUpdatedListener( callback:Function ):void;
		function addOnGenericAllianceMessageRecievedListener( callback:Function ):void;
		function removeOnGenericAllianceMessageRecievedListener( callback:Function ):void;
		
		function sendGetMailboxMessage():void;
	}
}
