package com.game.entity.factory
{
	import com.game.entity.components.shared.Pylon;
	import com.model.starbase.BuildingVO;
	import com.service.server.incoming.data.BattleEntityData;
	
	import org.ash.core.Entity;

	public interface IStarbaseFactory
	{
		function createBuilding( id:String, vo:BuildingVO ):Entity;

		function createBattleBuilding( data:BattleEntityData ):Entity;

		function createBaseItem( id:String, vo:BuildingVO ):Entity;

		function createBattleBaseItem( data:BattleEntityData ):Entity;

		function createStarbasePlatform( starbaseOwnerID:String, blend:Boolean = false ):void;

		function createForcefield( key:String, pylonA:Pylon, pylonB:Pylon, color:uint ):Entity;

		function updateStarbaseBuilding( entity:Entity ):void;

		function createGridSquare( type:String, x:Number, y:Number ):Entity;
		
		function createBoundingLine( startX:int, startY:int, endX:int, endY:int ):Entity;

		function destroyStarbaseItem( building:Entity ):void;
		
		function setBaseFaction(faction:String):void;
	}
}
