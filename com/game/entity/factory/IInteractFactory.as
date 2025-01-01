package com.game.entity.factory
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import org.ash.core.Entity;

	public interface IInteractFactory
	{
		function showSelection( target:Entity, selector:Entity, x:int = 0, y:int = 0, inBattle:Boolean = false):Entity;

		function showMultiShipSelection( target:Entity, selectionRect:Rectangle ):Entity;

		function createRouteLine( entity:Entity, destination:Point ):Entity;

		function createRange( entity:Entity ):Entity;

		function createShipRange( entity:Entity ):Entity;

		function clearRanges():void;

		function destroyInteractEntity( entity:Entity ):Entity;
	}
}
