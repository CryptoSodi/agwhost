package com.presenter.shared
{
	import com.model.asset.AssetVO;
	import com.model.player.PlayerVO;
	import com.model.prototype.IPrototype;
	import com.presenter.IImperiumPresenter;
	import com.service.server.incoming.data.SectorData;

	public interface IPlayerProfilePresenter extends IImperiumPresenter
	{
		function getPlayer( id:String ):PlayerVO;
		function requestPlayer( id:String, name:String = '' ):void;
		function loadPortraitProfile( portraitName:String, callback:Function ):void;
		function loadSmallImage( portraitName:String, callback:Function ):void;
		function reportPlayer( id:String ):void;
		function allianceSendInvite( playerKey:String ):void;
		function gotoCoords( x:int, y:int, sector:String ):void;
		function getConstantPrototypeValueByName( name:String ):*;
		function renamePlayer( newName:String ):void;
		function relocateStarbase( targetPlayer:String ):void;
		function getAssetVO( name:String ):AssetVO;
		function getCommendationRankPrototypesByName( name:String ):IPrototype;
		function currentPlayerInABattle():Boolean;
		function getCurrentUsersHomeSector():SectorData;
		function hasSectorSplitTestCohort( sectorId:String ):Boolean;

		function addOnPlayerVOAddedListener( callback:Function ):void;
		function removeOnPlayerVOAddedListener( callback:Function ):void;
	}
}
