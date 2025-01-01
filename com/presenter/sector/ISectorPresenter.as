package com.presenter.sector
{
	import com.model.fleet.FleetVO;
	import com.model.mission.MissionVO;
	import com.model.player.PlayerVO;
	import com.model.sector.SectorVO;
	import com.model.starbase.BaseVO;
	import com.presenter.shared.IGamePresenter;

	import org.ash.core.Entity;
	import com.model.prototype.IPrototype

	public interface ISectorPresenter extends IGamePresenter
	{
		function onInteractionWithSectorEntity( x:int, y:int, entity:Entity, selectedEntity:Entity ):void;
		function onBattle():void;
		function joinBattle( battleServerAddress:String ):void;
		function selectFleet( fleetID:String, gotoLocation:Boolean = true, canEnterBattle:Boolean = true, canChangeSector:Boolean = true ):Boolean;
		function attackEntity( entity:Entity, ignoreVerification:Boolean = false ):void;
		function tackleEntity( entity:Entity, ignoreVerification:Boolean = false ):void;
		function recallFleet( entity:Entity, targetTransgate:Entity = null ):void;
		function defendBase( entity:Entity, targetBase:Entity ):void
		function watchBattle( entity:Entity ):void;
		function enterStarbase( entity:Entity ):void;
		function travelViaTransgate( sector:String, entity:Entity, target:Entity ):void;
		function relocateToTransgate( sector:String, targetTransgate:String ):void;
		function travelToWaypoint(entity:Entity, target:Entity ):void;
		function lootDerelictFleet( entity:Entity ):void;
		function jumpToLocation( x:Number, y:Number ):void;
		function getFleetVO( id:String ):FleetVO;
		function loadIcon( url:String, callback:Function ):void
		function loadMiniIconFromEntityData( type:String, callback:Function ):void;
		function removeTargetSelection():void;
		function getTransgateDestinations():Vector.<SectorVO>;
		function getPrivateDestinations():Vector.<SectorVO>;
		function getPlayer( id:String ):PlayerVO;
		function getConstantPrototypeByName( v:String ):*;
		
		function getTransgateCustomDestinationPrototype( key:String ):IPrototype;
		function getTransgateCustomDestinationGroupByCustomDestinationGroup( group:String ):Vector.<IPrototype>;

		function addInteractListener( listener:Function ):void;
		function removeInteractListener( listener:Function ):void;

		function addListenerOnCoordsUpdate( listener:Function ):void;
		function removeListenerOnCoordsUpdate( listener:Function ):void;

		function addBattleListener( listener:Function ):void;
		function removeBattleListener( listener:Function ):void;

		function addListenerForFleetUpdate( listener:Function ):void;
		function removeListenerForFleetUpdate( listener:Function ):void;

		function addNotificationListener( listener:Function ):void;
		function removeNotificationListener( listener:Function ):void;

		function addSelectionChangeListener( listener:Function ):void;
		function addOnGenericAllianceMessageRecievedListener( callback:Function ):void;
		function removeOnGenericAllianceMessageRecievedListener( callback:Function ):void;

		function getBase( id:String ):BaseVO;
		function getFleets():Vector.<FleetVO>;

		function get sectorName():String;
		function get sectorEnum():String;
		function get currentMission():MissionVO;
		function get neighborhood():int;
		function get focusFleetID():String;
		function get selectedEntity():Entity;
		function get selectedEnemy():Entity;
		function get sectorID():String;
	}
}
