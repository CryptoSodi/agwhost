package com.game.entity.factory
{
	import com.model.starbase.BuildingVO;
	
	import org.ash.core.Entity;

	public interface IVCFactory
	{
		function createBuildingAnimation( buildingVO:BuildingVO, entity:Entity ):Entity;

		function createBuildingConstruction( buildingVO:BuildingVO, entity:Entity ):Entity;

		function createHealthBar( entity:Entity ):Entity;

		function createIsoSquare( entity:Entity, type:String ):Entity;

		function createName( entity:Entity, name:String ):Entity;

		function createBuildingShield( buildingVO:BuildingVO, entity:Entity ):Entity;

		function createShield( entity:Entity ):Entity;

		function createStateBar( entity:Entity, text:String ):Entity;

		function createTurret( buildingVO:BuildingVO, entity:Entity ):Entity;

		function createStarbaseShield( entity:Entity ):Entity;

		function createDepotCannisters( entity:Entity, index:int = 0 ):Entity;
		
		function createDebuffTray(entity:Entity):Entity;
		
		function destroyComponent( component:Entity ):void;
	}
}
