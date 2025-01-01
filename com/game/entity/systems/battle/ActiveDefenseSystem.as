package com.game.entity.systems.battle
{
	import com.game.entity.components.battle.ActiveDefense;
	import com.game.entity.factory.IAttackFactory;
	import com.game.entity.nodes.battle.ActiveDefenseNode;
	import com.util.BattleUtils;

	import flash.geom.Point;

	import org.ash.core.Entity;
	import org.ash.core.Game;
	import org.ash.core.NodeList;
	import org.ash.core.System;

	public class ActiveDefenseSystem extends System
	{
		[Inject(nodeType="com.game.entity.nodes.battle.ActiveDefenseNode")]
		public var nodes:NodeList;

		private var _attackFactory:IAttackFactory;
		private var _game:Game;
		private var _point:Point;
		private var _sourceLoc:Point;
		private var _targetLoc:Point;

		override public function addToGame( game:Game ):void
		{
			_game = game;
			_point = new Point();
			_sourceLoc = new Point();
			_targetLoc = new Point();
		}

		override public function update( time:Number ):void
		{
			if (time == 0)
				return;

			var activeDefense:ActiveDefense;
			var beamLength:Number;
			var node:ActiveDefenseNode;
			var ratio:Number;
			for (node = nodes.head; node; node = node.next)
			{
				activeDefense = node.activeDefense;

				//skip if the render is not ready
				if (!node.animation.render)
					continue;

				//if the owner no longer exists. destroy the entity
				if (activeDefense.owner.id != activeDefense.ownerID)
				{
					removeActiveDefense(node.entity);
					continue;
				}

				// Update the current frame
				activeDefense.animationTime += time;

				ratio = activeDefense.animationTime / activeDefense.animationLength;

				if (activeDefense.type == ActiveDefense.BEAM)
				{
					if (!activeDefense.ready)
					{
						node.animation.offsetY = node.animation.height * 0.5;
						activeDefense.ready = true;
					}

					if (activeDefense.strength < 1)
					{
						activeDefense.strength += activeDefense.growSpeed;
						if (activeDefense.strength > 1)
							activeDefense.strength = 1;
					}

					// Update the point of origin with the moving firer
					BattleUtils.instance.getAttachPointLocation(activeDefense.owner, activeDefense.sourceAttachPoint, _sourceLoc);
					node.position.x = _sourceLoc.x;
					node.position.y = _sourceLoc.y;

					//the target location of where the attack was shot down
					_targetLoc.x = activeDefense.hitLocationX;
					_targetLoc.y = activeDefense.hitLocationY;

					// Stop the beam at the target it's hitting if it hit successfully
					_point.setTo(_sourceLoc.x - _targetLoc.x, _sourceLoc.y - _targetLoc.y);
					beamLength = _point.length;

					// Set the properties to the beam
					node.animation.scaleX = beamLength / activeDefense.baseWidth * activeDefense.strength;
					node.position.rotation = Math.atan2(_targetLoc.y - _sourceLoc.y, _targetLoc.x - _sourceLoc.x);
				} else
				{
					// Update sprite scale
					node.animation.scaleX = node.animation.scaleY = activeDefense.scaleStart + activeDefense.scaleDelta * ratio;
				}

				// Update sprite alpha
				node.animation.alpha = activeDefense.alphaStart + activeDefense.alphaDelta * ratio;

				//destroy the activeDefense interceptor if the animation has reached its' end
				if (activeDefense.animationTime > activeDefense.animationLength)
					removeActiveDefense(node.entity);

				node.position.dirty = true;
			}
		}

		private function removeActiveDefense( entity:Entity ):void
		{
			_attackFactory.destroyAttack(entity);
		}

		override public function removeFromGame( game:Game ):void
		{
			nodes = null;
			_game = null;
			_point = null;
			_sourceLoc = null;
			_targetLoc = null;
		}

		[Inject]
		public function set attackFactory( a:IAttackFactory ):void  { _attackFactory = a }
	}
}
