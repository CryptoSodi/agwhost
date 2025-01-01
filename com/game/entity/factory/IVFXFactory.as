package com.game.entity.factory
{
	import com.game.entity.components.battle.TrailFX;
	import com.model.prototype.IPrototype;
	import com.service.server.incoming.data.DebugLineData;
	import com.service.server.incoming.data.SectorBattleData;

	import org.ash.core.Entity;

	public interface IVFXFactory
	{
		function createExplosion( parent:Entity, x:int, y:int ):Entity;

		function createSectorExplosion( parent:Entity, x:int, y:int ):Entity;

		function createHit( hitTarget:Entity, projectile:Entity, x:int, y:int, hitShield:Boolean = false, useProjectile:Boolean = false ):Entity;

		function createAttackIcon( data:SectorBattleData ):Entity;

		function createThruster( entity:Entity, attachPointProto:IPrototype, debugAttachPoints:Boolean = false, visible:Boolean = false ):Entity;

		function createMuzzle( entity:Entity, attachPointProto:IPrototype, weaponProto:IPrototype, slotIndex:Number, visible:Boolean = false ):Entity;

		function createDamageEffect( entity:Entity, attachPointProto:IPrototype ):Entity;

		function createDebugLine( data:DebugLineData ):Entity;

		function createTrail( trail:TrailFX, x:Number, y:Number, rotation:Number ):Entity;

		function destroyAttack( attackIcon:Entity ):void;

		function destroyDebugLine( debugLine:Entity ):void;

		function destroyVFX( entity:Entity ):void;

		function destroyTrail( trail:Entity ):void;
	}
}


