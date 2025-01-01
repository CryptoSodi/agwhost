package com.presenter.sector
{
	import com.game.entity.components.shared.Position;
	import com.model.mission.MissionVO;
	import com.model.player.PlayerVO;
	import com.presenter.IImperiumPresenter;

	import flash.geom.Point;

	import org.ash.core.Entity;
	import org.osflash.signals.Signal;

	public interface IMiniMapPresenter extends IImperiumPresenter
	{
		function get addToMiniMapSignal():Signal;
		function get clearMiniMapSignal():Signal;
		function get fteRunning():Boolean;
		function get removeFromMiniMapSignal():Signal;
		function get scrollMiniMapSignal():Signal;

		function enterStarbase():void;
		function isInInstancedMission():Boolean;
		function enterInstancedMission():void;
		function updateScale():void;
		function mouseDown():void;
		function mouseUp():void;
		function mouseMove( xDelta:Number, yDelta:Number ):void;
		function mouseWheel( delta:Number ):void;

		function getEntity( id:String ):Entity;
		function showSector():void;
		function retreat():void;
		function findBase( userName:String ):void;
		function moveToMissionTarget():String;

		function addListenerOnCoordsUpdate( listener:Function ):void;
		function removeListenerOnCoordsUpdate( listener:Function ):void;

		function get currentMission():MissionVO;

		function addListenerToUpdateMission( listener:Function ):void;
		function removeListenerToUpdateMission( listener:Function ):void;

		function get isMissionBattle():Boolean;
		function get mapWidth():Number;
		function set mapWidth( v:Number ):void;
		function get miniMapWidth():Number;
		function set miniMapWidth( v:Number ):void;
		function get sectorName():String;
		function get sectorEnum():String;
		function get showRetreat():Boolean;
		function get zoom():Number;
		function get zoomPercent():Number;
		function set zoomPercent( v:Number ):void;
		function getPlayer( id:String ):PlayerVO;
		function getConstantPrototypeByName( v:String ):*;
		function get focusedFleetRating():int;

		function addSelectionChangeListener( listener:Function ):void;
		function removeSelectionChangeListener( listener:Function ):void;

		function getIconPosition( width:Number, height:Number, entityPosition:Position ):Point;
	}
}
