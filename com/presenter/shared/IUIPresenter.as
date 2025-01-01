package com.presenter.shared
{
	import com.controller.transaction.requirements.RequirementVO;
	import com.model.asset.AssetVO;
	import com.model.battle.BattleRerollVO;
	import com.model.blueprint.BlueprintVO;
	import com.model.event.EventVO;
	import com.model.motd.MotDDailyRewardModel;
	import com.model.motd.MotDModel;
	import com.model.prototype.IPrototype;
	import com.model.starbase.BuffVO;
	import com.presenter.IImperiumPresenter;
	import com.service.loading.LoadPriority;

	import flash.utils.Dictionary;

	import org.parade.core.IView;

	public interface IUIPresenter extends IImperiumPresenter
	{
		function changeResolution():void;

		function gotoCoords( x:int, y:int, sector:String ):void;
		function viewBattleReplay( battleId:String ):void;

		function getTransactions():Dictionary;
		function loadIcon( url:String, callback:Function ):void;
		function loadIconFromEntityData( type:String, callback:Function ):void;
		function loadMessageImage( url:String, callback:Function ):void;
		function loadPortraitSmall( portraitName:String, callback:Function ):void
		function getAssetVOFromIPrototype( prototype:IPrototype ):AssetVO;
		function getAssetVO( assetName:String ):AssetVO;
		function getFilterAssetVO( prototype:IPrototype ):AssetVO;
		function toggleSFXMute():void;
		function toggleMusicMute():void;
		function setSFXVolume( v:Number ):void;
		function setMusicVolume( v:Number ):void;
		function toggleFullScreen():void;
		function fteNextStep():void;
		function fteSkip():void;
		function loadPortraitMedium( portraitName:String, callback:Function ):void;
		function loadPortraitIcon( portraitName:String, callback:Function ):void;
		function getPrototypeUIName( prototype:IPrototype ):String;
		function getPrototypeUIIcon( prototype:IPrototype ):String;
		function getFromCache( url:String, callback:Function = null, priority:int = LoadPriority.LOW, absoluteURL:Boolean = false ):Object;

		function addBattleLogListUpdatedListener( callback:Function ):void;
		function removeBattleLogListUpdatedListener( callback:Function ):void;
		function addBattleLogDetailUpdatedListener( callback:Function ):void;
		function removeBattleLogDetailUpdatedListener( callback:Function ):void;

		function getBlueprintByName( prototype:String ):BlueprintVO;
		function removeBlueprintByName( name:String ):void;
		function getBlueprintByID( id:String ):BlueprintVO;
		function getBlueprintHardCurrencyCost( blueprint:BlueprintVO, partsPurchased:Number ):Number;
		function purchaseBlueprint( blueprint:BlueprintVO, partsPurchased:Number ):void;
		function purchaseReroll( battleKey:String ):void;
		function purchaseDeepScan( battleKey:String ):void;
		function addRerollFromRerollCallback( callback:Function ):void;
		function addRerollFromScanCallback( callback:Function ):void;
		function removeRerollFromAvailable( battleID:String ):void;
		function getBattleEndDialogByFaction( faction:String, combatResult:String = 'Victory' ):Vector.<IPrototype>;
		function getBlueprintPrototypeByName( name:String ):IPrototype;
		function sendMailMessage( playerID:String, subject:String, body:String ):void;
		function sendAllianceMailMessage( subject:String, body:String ):void;
		function sendGetMailboxMessage():void;
		function getFactionPrototypesByName( name:String ):IPrototype;
		function getRacePrototypeByName( name:String ):IPrototype;
		function requestPlayer( id:String, name:String = '' ):void;

		function getBuffPrototypes():Dictionary;
		function getBuffPrototypeByName( name:String ):IPrototype;
		function getCommendationRankPrototypesByName( name:String ):IPrototype;
		function getConstantPrototypeValueByName( name:String ):Number;
		function linkCoords( x:int, y:int ):void;
		function addBookmark( x:int, y:int ):void;
		function addMailCountUpdateListener( callback:Function ):void;
		function removeMailCountUpdateListener( callback:Function ):void;
		function addOnMailHeadersUpdatedListener( callback:Function ):void;
		function removeOnMailHeadersUpdatedListener( callback:Function ):void;
		function addOnMailDetailUpdatedListener( callback:Function ):void;
		function removeOnMailDetailUpdatedListener( callback:Function ):void;
		function addMotDUpdatedListener( callback:Function ):void
		function addDailyRewardListener( callback:Function ):void;
		function removeDailyRewardListener( callback:Function ):void;
		function removeMotDUpdatedListener( callback:Function ):void;
		function addWarfrontUpdateListener( listener:Function ):void;
		function removeWarfrontUpdateListener( listener:Function ):void;
		function addAvailableRerollUpdatedListener( callback:Function ):void;
		function removeAvailableRerollUpdatedListener( callback:Function ):void;
		function removeRerollFromRerollCallback( callback:Function ):void;
		function removeRerollFromScanCallback( callback:Function ):void;
		function addEventUpdatedListener( callback:Function ):void;
		function removeEventUpdatedListener( callback:Function ):void;

		function sendMotDMessageRead( key:String ):void;
		function allianceSendInvite( playerKey:String ):void;
		function sendDailyClaimRequest( header:int, protocolID:int ):void;

		function getMailDetails( mailKey:String ):void;
		function deleteMail( v:Vector.<String> ):void;
		function mailRead( mailKey:String ):void;

		function get unreadMailCount():uint;
		function getPrototypeByName( proto:String ):IPrototype;
		function getShipPrototypeByName( proto:String ):IPrototype;
		function getFAQPrototypes():Vector.<IPrototype>;
		function getBattleLogList( filter:String ):void;
		function getBattleLogDetails( battleKey:String ):void;
		function getAvailableRerolls():Vector.<BattleRerollVO>;

		function addOnPlayerVOAddedListener( callback:Function ):void;
		function removeOnPlayerVOAddedListener( callback:Function ):void;
		function canEquip( prototype:IPrototype, slotType:String ):RequirementVO;

		function addTransactionListener( type:int, callback:Function ):void;
		function removeTransactionListener( callback:Function ):void;

		function removeBuff( buff:BuffVO ):void;
		function updateStarbasePlatform():void;
		function getOfferPrototypeByName( name:String ):IPrototype;
		function getOfferItemsByItemGroup( itemGroup:String ):Vector.<IPrototype>;
		function getView( view:Class ):IView;

		function get buffs():Vector.<BuffVO>;
		function get bubbleTimeRemaining():Number;

		function get isSFXMuted():Boolean;
		function get isMusicMuted():Boolean;
		function get sfxVolume():Number;
		function get musicVolume():Number;
		function get isFullScreen():Boolean;
		function get motdModel():MotDModel;
		function get motdDailyModel():MotDDailyRewardModel;
		function get currentGameState():String;

		function get igaContextMenuDefaultIndex():int;
		function setIGAContextMenuDefaultIndex( v:int ):void;

		function get tyrContextMenuDefaultIndex():int;
		function setTYRContextMenuDefaultIndex( v:int ):void;

		function get sovContextMenuDefaultIndex():int;
		function setSOVContextMenuDefaultIndex( v:int ):void;
		
		function get csContextMenuDefaultIndex():int;
		function setCSContextMenuDefaultIndex( v:int ):void;

		function get currentActiveEvent():EventVO;
		function get activeEvents():Vector.<EventVO>;
		function get upcomingEvents():Vector.<EventVO>;
	}
}
