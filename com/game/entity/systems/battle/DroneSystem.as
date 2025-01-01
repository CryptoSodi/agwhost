package com.game.entity.systems.battle
{
	import com.controller.ServerController;
	import com.enum.CategoryEnum;
	import com.game.entity.components.battle.Drone;
	import com.game.entity.components.shared.Detail;
	import com.game.entity.components.shared.Move;
	import com.game.entity.components.shared.Position;
	import com.game.entity.factory.IAttackFactory;
	import com.game.entity.factory.IVFXFactory;
	import com.game.entity.nodes.battle.DroneNode;
	import com.model.asset.AssetVO;
	import com.model.prototype.IPrototype;
	import com.model.prototype.PrototypeModel;
	import com.service.server.incoming.data.BeamAttackData;
	import com.service.server.incoming.data.ProjectileAttackData;
	
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import org.ash.core.Entity;
	import org.ash.core.Game;
	import org.ash.core.NodeList;
	import org.ash.core.System;

	public class DroneSystem extends System
	{
		[Inject(nodeType="com.game.entity.nodes.battle.DroneNode")]
		public var nodes:NodeList;
		[Inject]
		public var attackFactory:IAttackFactory;
		[Inject]
		public var prototypeModel:PrototypeModel;
		[Inject]
		public var vfxFactory:IVFXFactory;

		private var _beamData:BeamAttackData;
		private var _game:Game;
		private var _id:int;
		private var _lookup:Dictionary;
		private var _projectileData:ProjectileAttackData;
		private var _targetLoc:Point;
		private var _targetVec:Point;

		override public function addToGame( game:Game ):void
		{
			_game = game;
			_id = 1;
			_targetVec = new Point();
			nodes.nodeRemoved.add(onNodeRemoved);

			// Create a default BeamAttackData object for the drones to use
			_beamData = new BeamAttackData();
			_beamData.attackHit = false;
			_beamData.targetAttachPoint = "HULL";
			_beamData.targetScatterX = 0;
			_beamData.targetScatterY = 0;
			_beamData.hitLocation = new Point();

			// Create a default ProjectileAttakData object for the drones to use
			_projectileData = new ProjectileAttackData();
		}

		private function onNodeRemoved( node:DroneNode ):void
		{
			vfxFactory.createExplosion(node.entity, node.position.x, node.position.y);
			removeAttack(node.drone);
		}

		override public function update( time:Number ):void
		{
			if (time == 0)
				return;

			var drone:Drone;
			var node:DroneNode;
			var projectile:Entity;
			var target:Entity;

			for (node = nodes.head; node; node = node.next)
			{
				drone = node.drone;

				// Early out if the drone is not visible
				if (!node.animation.render)
					continue;

				// Get the target of the drone
				target = _game.getEntity(drone.targetID);

				// Early out if no target
				if (!target)
					continue;

				// Get the location of the target
				_targetLoc = Position(target.get(Position)).position;

				// If it's time to clean up the attack then do so
				if (drone.currentTick >= drone.cleanupTick && drone.weaponAttack)
				{
					vfxFactory.createHit(target, drone.weaponAttack, _targetLoc.x, _targetLoc.y);
					removeAttack(drone);
					continue;
				}

				// Early out if not orbiting anything
				if (!drone.isOribiting)
				{
					// The drone is no longer orbiting so if it was attacking a target, remove that attack.
					if (drone.weaponAttack != null)
						removeAttack(drone);
					continue;
				}

				// Set the beam origin and target points and compute vector
				_targetVec.setTo(_targetLoc.x - node.position.x, _targetLoc.y - node.position.y);

				// Orient the drone to point at its target
				node.position.rotation = Math.atan2(_targetVec.y, _targetVec.x);

				// Advance the time counter
				drone.currentTick++;

				// If its time to fire at the target then fire
				if (drone.currentTick >= drone.nextFireTick)
				{
					// Set the new next fire tick
					drone.nextFireTick += drone.minWeaponTime + (Math.random() * (drone.maxWeaponTime - drone.minWeaponTime));
					drone.cleanupTick = drone.currentTick + (drone.fireDuration * 30.0);

					var attackProto:IPrototype = prototypeModel.getWeaponPrototype(drone.weaponProto);
					if (attackProto.getValue("attackMethod") == 1)
					{
						var assetVO:AssetVO = Detail(target.get(Detail)).assetVO;

						// Create a dummy set of beam data for the attack
						_beamData.attackId = name;
						_beamData.entityOwnerId = node.entity.id;
						_beamData.targetEntityId = drone.targetID;
						_beamData.hitTarget = drone.targetID;
						_beamData.start = new Point(node.position.x, node.position.y);
						_beamData.maxRange = _targetVec.length - (assetVO.radius * 0.15 * Math.random());
						_beamData.weaponPrototype = drone.weaponProto;
						

						// Create the attack
						drone.weaponAttack = attackFactory.createBeam(_beamData);
					} else
					{
						// Create a dummy set of projectile data for the attack
						_projectileData.attackId = name;
						_projectileData.entityOwnerId = node.entity.id;
						_projectileData.start = new Point(node.position.x, node.position.y);
						_projectileData.weaponPrototype = drone.weaponProto;
						_projectileData.rotation = node.position.rotation;
						_projectileData.guided = false;
						_projectileData.fadeTime = 0;
						_projectileData.startTick = ServerController.SIMULATED_TICK;
						_projectileData.finishTick = ServerController.SIMULATED_TICK + (drone.fireDuration * 20.0);
						_projectileData.end.x = _targetLoc.x;
						_projectileData.end.y = _targetLoc.y;

						// Create the projectile and let it destroy itself when it reaches its target
						projectile = attackFactory.createProjectile(null, _projectileData);
						Move(projectile.get(Move)).destroyOnComplete = true;
					}
				}
			}
		}

		private function removeAttack( drone:Drone ):void
		{
			if (drone.weaponAttack)
			{
				//when a drone is destroyed at the end of a battle we also need to destroy its' beam
				//but that beam may have already been destroyed as part of the cleanup process
				//checking for the Detail will tell us if it has already been destroyed 
				var detail:Detail = drone.weaponAttack.get(Detail);
				if (detail && detail.category == CategoryEnum.ATTACK)
					attackFactory.destroyAttack(drone.weaponAttack);

				drone.weaponAttack = null;
			}
		}

		private function get name():String  { _id++; return "DroneBeam" + _id; }

		override public function removeFromGame( game:Game ):void
		{
			nodes.nodeRemoved.remove(onNodeRemoved);
			nodes = null;
			_beamData = null;
			_game = null;
			_lookup = null;
			_projectileData = null;
			_targetLoc = null;
			_targetVec = null;
		}
	}
}
