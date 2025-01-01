package com.presenter.battle
{
	import com.enum.CategoryEnum;
	import com.model.asset.AssetVO;
	import com.model.battle.BattleEntityVO;
	import com.model.battle.BattleRerollVO;
	import com.model.blueprint.BlueprintVO;
	import com.model.fleet.FleetVO;
	import com.model.player.PlayerVO;
	import com.model.prototype.IPrototype;
	import com.presenter.shared.IGamePresenter;

	import flash.utils.Dictionary;

	import org.ash.core.Entity;

	public interface IBattlePresenter extends IGamePresenter
	{
		function getModuleAssetVo( entity:Entity, idx:Number ):AssetVO;
		function loadSmallImage( portraitName:String, callback:Function ):void;
		function loadMediumImage( portraitName:String, callback:Function ):void;

		function addStartListener( callback:Function ):void;
		function removeStartListener( callback:Function ):void;
		function onBattleStarted():void;
		function onBattleEnded():void;
		function sharePvPVictory():void;

		function getPlayer( id:String ):PlayerVO;
		function getParticipantRating( id:String ):int;
		function getBattleEntitiesByPlayer( id:String, category:String = CategoryEnum.SHIP ):Vector.<BattleEntityVO>;
		function exitCombat():void;
		function selectOwnedShipById( shipId:String ):void;

		function getSelectedFleet():FleetVO;
		function getShip( shipId:String ):Entity;
		function loadIcon( url:String, callback:Function ):void;
		function getHealthPercentByPlayerID( id:String ):Number;
		function loadMiniIconFromEntityData( type:String, callback:Function ):void;
		function getBlueprintHardCurrencyCost( blueprint:BlueprintVO, partsPurchased:Number ):Number;
		function purchaseBlueprint( blueprint:BlueprintVO, partsPurchased:Number ):void;
		function purchaseReroll( battleKey:String ):void;
		function purchaseDeepScan( battleKey:String ):void;
		function addRerollFromRerollCallback( callback:Function ):void;
		function removeRerollFromRerollCallback( callback:Function ):void;
		function addRerollFromScanCallback( callback:Function ):void;
		function removeRerollFromScanCallback( callback:Function ):void;
		function removeRerollFromAvailable( battleID:String ):void;

		function addListenerVitalPercentUpdates( listener:Function ):void;
		function removeListenerVitalPercentUpdates( listener:Function ):void;

		function getConstantPrototypeValueByName( name:String ):Number;
		function getStoreItemPrototypeByName( name:String ):IPrototype;
		function isPlayerBaseOwner( playerID:String ):Boolean;
		function isPlayerInCombat( playerID:String ):Boolean;
		function getBlueprintByName( name:String ):BlueprintVO;
		function getAvailableRerollById( id:String ):BattleRerollVO;
		function getBlueprintByID( id:String ):BlueprintVO;
		function removeBlueprintByName( name:String ):void;
		function isInstancedMission():Boolean;

		function getBlueprintPrototypeByName( v:String ):IPrototype;
		function getResearchPrototypeByName( v:String ):IPrototype;
		function getShipPrototype( v:String ):IPrototype;
		function getModulePrototypeByName( v:String ):IPrototype;
		function getConstantPrototypeByName( name:String ):IPrototype;
		function getBEDialogueByFaction( faction:String, result:String = 'Victory' ):Vector.<IPrototype>;
		function getPrototypeByName( proto:String ):IPrototype;
		function getUnavailableReroll( id:String ):int;

		function addListenerBattleEntitiesControlledUpdated( listener:Function ):void;

		function addListenerOnParticipantsAdded( listener:Function ):void;
		function removeListenerOnParticipantsAdded( listener:Function ):void;

		function get battleRunning():Boolean;
		function get battleTimeRemaining():Number;
		function get doesPlayerOwnBase():Boolean;
		function get isBaseCombat():Boolean;
		function get isFTERunning():Boolean;
		function get isPVEBattle():Boolean;
		function get ownedBlueprints():Dictionary;
		function get participants():Vector.<String>;
		function get players():Dictionary;
		function get showRetreat():Boolean;
	}
}
