package com.game.entity.factory
{
	import com.service.server.incoming.data.BattleEntityData;
	import com.service.server.incoming.data.SectorEntityData;

	import org.ash.core.Entity;

	public interface IShipFactory
	{
		function createShip( data:BattleEntityData ):Entity;

		function createFleet( data:SectorEntityData ):Entity;

		function destroyShip( ship:Entity ):void;

		function destroyFleet( fleet:Entity ):void;
	}
}
