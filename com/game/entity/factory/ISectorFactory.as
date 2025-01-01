package com.game.entity.factory
{
	import com.service.server.incoming.data.SectorEntityData;
	import com.service.server.incoming.data.SectorObjectiveData;
	
	import org.ash.core.Entity;

	public interface ISectorFactory
	{
		function createSectorBase( data:SectorEntityData ):Entity;

		function createTransgate( data:SectorEntityData ):Entity;

		function createDepot( data:SectorEntityData ):Entity;

		function createOutpost( data:SectorEntityData ):Entity;

		function createDerelict( data:SectorEntityData ):Entity;
		
		function createObjective( data:SectorObjectiveData ):Entity;

		function destroySectorEntity( entity:Entity ):void;
	}
}
