package com.game.entity.systems.shared
{
	import com.Application;
	import com.controller.ServerController;
	import com.enum.CategoryEnum;
	import com.enum.EntityMoveEnum;
	import com.event.StateEvent;
	import com.game.entity.components.shared.Detail;
	import com.game.entity.components.shared.Move;
	import com.game.entity.components.shared.Owned;
	import com.game.entity.components.shared.Position;
	import com.game.entity.factory.IAttackFactory;
	import com.game.entity.factory.IVFXFactory;
	import com.game.entity.nodes.shared.MoveNode;
	import com.model.fleet.FleetModel;

	import org.ash.core.Game;
	import org.ash.core.NodeList;
	import org.ash.core.System;

	public class MoveSystem extends System
	{
		[Inject(nodeType="com.game.entity.nodes.shared.MoveNode")]
		public var nodes:NodeList;

		private var _fleetModel:FleetModel;
		private var _tempRotation:Number;
		private var _vfxFactory:IVFXFactory;
		private var _attackFactory:IAttackFactory;

		override public function update( time:Number ):void
		{
			if (time == 0)
				return;

			var node:MoveNode;
			for (node = nodes.head; node; node = node.next)
			{
				moveEntity(node, time);
			}
		}

		private function moveEntity( node:MoveNode, time:Number ):void
		{
			var detail:Detail     = node.detail;
			var move:Move         = node.move;
			var position:Position = node.position;

			if (move.type == EntityMoveEnum.LERPING && !move.lerping && move.hasUpdate)
				move.setNextUpdate();
			if (move.directionChanged)
			{
				move.setStart(position.position);
				if (move.type == EntityMoveEnum.POINT_TO_POINT)
					move.setDelta(move.destination.x - move.start.x, move.destination.y - move.start.y);
				else
					move.setDelta(move.lerpDestination.x - move.start.x, move.lerpDestination.y - move.start.y);
				move.directionChanged = false;
				if (move.type == EntityMoveEnum.LERPING)
					position.targetRotation = move.rotation;
				else if (detail.category == CategoryEnum.SHIP)
				{
					position.targetRotation = Math.atan2(move.delta.y, move.delta.x);
				} else
					position.targetRotation = position.rotation = Math.atan2(move.delta.y, move.delta.x);
			}
			if (move.moving)
			{
				if (move.startTick > ServerController.SIMULATED_TICK)
					return;
				move.time += time;
				if (move.time < 0)
					return;

				//rotation
				var ratio:Number = Math.min(move.totalTime, move.time) / move.totalTime;
				//alpha fade out on projectiles that are reaching the end of their life
				if (move.fadeOut > 0 && detail.category == CategoryEnum.ATTACK)
				{
					if (ServerController.SIMULATED_TICK >= move.fadeOut)
						node.animation.alpha = 1.05 - ratio;
				}
				if (position.rotation != position.targetRotation)
				{
					if (move.type == EntityMoveEnum.LERPING)
						position.rotation = position.startRotation + position.rotationDelta * ratio;
					else
						position.rotation = position.startRotation + Math.min(move.time * .6, 1) * position.rotationDelta;
				}

				if (move.relative)
				{
					move.setStart(position.linkedTo.position);
					move.setDelta(move.destination.x, move.destination.y);
				}

				position.x = move.start.x + ratio * move.delta.x;
				position.y = move.start.y + ratio * move.delta.y;
				if (move.time >= move.totalTime)
				{
					if (move.type == EntityMoveEnum.POINT_TO_POINT)
					{
						move.moving = false;
						if (Application.STATE == StateEvent.GAME_SECTOR && node.entity.has(Owned))
							_fleetModel.updateFleet(null);

						if (move.destroyOnComplete)
						{
							if (detail.category == CategoryEnum.ATTACK)
								_attackFactory.destroyAttack(node.entity);
						}
					} else
					{
						if (move.hasUpdate)
						{
							var tt:Number = move.time - move.totalTime;
							move.setNextUpdate();
							move.time = tt;
							moveEntity(node, 0);
						} else
						{
							if (position.x == move.destination.x && position.y == move.destination.y)
								move.moving = false;
							move.lerping = false;
						}
					}
				}
			}
		}

		[Inject]
		public function set fleetModel( v:FleetModel ):void  { _fleetModel = v; }
		[Inject]
		public function set vfxFactory( v:IVFXFactory ):void  { _vfxFactory = v; }
		[Inject]
		public function set attackFactory( v:IAttackFactory ):void  { _attackFactory = v; }

		override public function removeFromGame( game:Game ):void
		{
			nodes = null;
			_fleetModel = null;
			_vfxFactory = null;
		}
	}
}
