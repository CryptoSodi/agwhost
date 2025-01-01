package com.game.entity.systems.battle
{
	import com.game.entity.components.battle.Beam;
	import com.game.entity.components.shared.Position;
	import com.game.entity.factory.IAttackFactory;
	import com.game.entity.factory.IVFXFactory;
	import com.game.entity.nodes.battle.BeamNode;
	import com.util.BattleUtils;

	import flash.geom.Point;

	import org.ash.core.Entity;
	import org.ash.core.Game;
	import org.ash.core.NodeList;
	import org.ash.core.System;

	public class BeamSystem extends System
	{
		[Inject(nodeType="com.game.entity.nodes.battle.BeamNode")]
		public var nodes:NodeList;

		private var _game:Game;
		private var _point:Point;
		private var _sourceLoc:Point;
		private var _targetLoc:Point;

		private var _vfxFactory:IVFXFactory;
		private var _attackFactory:IAttackFactory;

		override public function addToGame( game:Game ):void
		{
			_game = game;
			_point = new Point();
			_sourceLoc = new Point();
			_targetLoc = new Point();
			nodes.nodeAdded.add(onNodeAdded);
			nodes.nodeRemoved.add(onNodeRemoved);
		}

		private function onNodeAdded( node:BeamNode ):void
		{
			node.init(onReady);
		}

		private function onReady( node:BeamNode ):void
		{
			node.animation.offsetY = node.animation.height * 0.5;
		}

		private function onNodeRemoved( node:BeamNode ):void
		{
			node.destroy();
		}

		override public function update( time:Number ):void
		{
			if (time == 0)
				return;

			var beam:Beam;
			var beamLength:Number;
			var node:BeamNode;
			var owner:Entity;
			var pos:Position;
			var target:Entity;

			for (node = nodes.head; node; node = node.next)
			{
				beam = node.beam;
				if (beam.strength < 1)
				{
					beam.strength += beam.growSpeed;
					if (beam.strength > 1)
						beam.strength = 1;
				}
				if (node.animation.render)
				{
					owner = _game.getEntity(node.detail.ownerID);
					// It is possible that the owner of the beam was destroyed before the beam has expired.
					// In this case we let the beam own itself so that it continues to exist until the server removes it.
					if (!owner)
						owner = node.entity;

					// Update the point of origin with the moving firer
					BattleUtils.instance.getAttachPointLocation(owner, beam.sourceAttachPoint, _sourceLoc);
					node.position.x = _sourceLoc.x;
					node.position.y = _sourceLoc.y;

					target = _game.getEntity(beam.targetID);
					if (target && beam.targetID == beam.hitTarget)
					{
						// Use the specified attach point is there is one
						if (beam.targetAttachPoint != "HULL")
						{
							BattleUtils.instance.getAttachPointLocation(target, beam.targetAttachPoint, _targetLoc);
						}
						// Use the ship's hull coordinates otherwise
						else
						{
							pos = target.get(Position);
							_targetLoc.x = pos.x;
							_targetLoc.y = pos.y;
						}
					} else
					{
						//used by active defense beams that shoot down projectiles or guided bombs
						_targetLoc.x = beam.hitLocationX;
						_targetLoc.y = beam.hitLocationY;
					}

					// Apply the randomization to the location
					_targetLoc.x += beam.targetScatterX;
					_targetLoc.y += beam.targetScatterY;

					// Stop the beam at the target it's hitting if it hit successfully
					beamLength = beam.maxRange;
					if (beam.attackHit)
					{
						_point.setTo(_sourceLoc.x - _targetLoc.x, _sourceLoc.y - _targetLoc.y);
						beamLength = _point.length;

						if (beam.visibleHitCounter <= 0 && beam.strength >= 1)
						{
							_vfxFactory.createHit(target, node.entity, _targetLoc.x, _targetLoc.y);
							beam.visibleHitCounter = 5;
						}
					}

					// Set the properties to the beam
					node.animation.scaleX = beamLength / beam.baseWidth * node.beam.strength;
					node.position.rotation = Math.atan2(_targetLoc.y - _sourceLoc.y, _targetLoc.x - _sourceLoc.x);

					/*
					   node.animation.scaleX = beam.maxRange / 256 * node.beam.strength;
					   if (beam.followShipRotation)
					   {
					   node.position.rotation = Position(owner.get(Position)).rotation;
					   } else
					   node.position.rotation = BattleUtils.instance.getAttachPointRotation(owner, beam.sourceAttachPoint);
					 */
				}
			}
		}

		override public function removeFromGame( game:Game ):void
		{
			nodes.nodeAdded.remove(onNodeAdded);
			nodes = null;
			_game = null;
			_point = null;
			_sourceLoc = null;
			_targetLoc = null;
		}

		[Inject]
		public function set vfxFactory( v:IVFXFactory ):void  { _vfxFactory = v }
		[Inject]
		public function set attackFactory( a:IAttackFactory ):void  { _attackFactory = a }
	}
}
