package com.game.entity.factory
{
	import com.service.server.incoming.data.AreaAttackData;
	import com.service.server.incoming.data.BeamAttackData;
	import com.service.server.incoming.data.DroneAttackData;
	import com.service.server.incoming.data.ProjectileAttackData;

	import org.ash.core.Entity;

	public interface IAttackFactory
	{
		function createProjectile( ship:Entity, data:ProjectileAttackData ):Entity;

		function createBeam( data:BeamAttackData ):Entity;

		function createDrone( ship:Entity, data:DroneAttackData ):Entity;

		function createActiveDefenseInterceptor( owner:Entity, attachPoint:String, x:int, y:int ):Entity;

		function cleanAttack( attack:Entity ):void;

		function destroyAttack( attack:Entity ):void;

		function createArea( shipID:String, data:AreaAttackData ):Entity;
	}
}
