package com.game.entity.systems.battle
{
	import com.controller.ServerController;
	import com.enum.LayerEnum;
	import com.game.entity.components.battle.TrailFX;
	import com.game.entity.components.shared.Animation;
	import com.game.entity.components.shared.Position;
	import com.game.entity.factory.IVFXFactory;
	import com.game.entity.nodes.battle.TrailFXNode;

	import flash.geom.Point;

	import org.ash.core.Entity;
	import org.ash.core.Game;
	import org.ash.core.NodeList;
	import org.ash.core.System;

	public class TrailFXSystem extends System
	{
		[Inject(nodeType="com.game.entity.nodes.battle.TrailFXNode")]
		public var nodes:NodeList;

		private var _alpha:Number;
		private var _bounds:Point;
		private var _game:Game;
		private var _lastUpdate:int;
		private var _scalar:Number;
		private var _vfxFactory:IVFXFactory;

		override public function addToGame( game:Game ):void
		{
			_bounds = new Point(30, 5);
			_game = game;
			_lastUpdate = ServerController.SIMULATED_TICK;
			_scalar = 1 / _bounds.x;
			nodes.nodeRemoved.add(onEntityRemoved);
		}

		/**
		 * When an entity is removed we want to clean up any segments that may still exist
		 * @param node The node that was removed
		 */
		private function onEntityRemoved( node:TrailFXNode ):void
		{
			for (var i:int = 0; i < node.trail.segments.length; i++)
			{
				_vfxFactory.destroyTrail(node.trail.segments[i]);
			}
			node.trail.segments.length = 0;
		}

		/**
		 * Called every frame to update any trails
		 * @param delta The amount of time, in milliseconds, since the last update
		 */
		override public function update( delta:Number ):void
		{
			var node:TrailFXNode;
			if (ServerController.SIMULATED_TICK > _lastUpdate)
			{
				//upate and create new trails
				for (node = nodes.head; node; node = node.next)
				{
					if (node.animation.ready)
					{
						updateCurrentSegment(node, true);
						extendTrail(node);
					}
				}
				_lastUpdate = ServerController.SIMULATED_TICK;
			} else
			{
				//update trails
				for (node = nodes.head; node; node = node.next)
				{
					if (node.animation.ready)
						updateCurrentSegment(node);
				}
			}
		}

		/**
		 * Takes the current segment and scales it to span the distance covered in the last update
		 * @param node The trail that we're working with
		 * @param last Set to true if we're on the last update for the 'currentSegment'
		 */
		private function updateCurrentSegment( node:TrailFXNode, last:Boolean = false ):void
		{
			if (node.trail.currentSegment)
			{
				var animation:Animation  = node.trail.currentSegment.get(Animation);
				var position:Point       = node.position.position;
				var segPosition:Position = node.trail.currentSegment.get(Position);
				animation.scaleX = Point.distance(position, node.trail.lastPosition) * _scalar;
				//if we're on the last update for the current segment then update the rotation just to make sure we line up properly with the next one
				if (last)
					segPosition.rotation = Math.atan2(position.y - node.trail.lastPosition.y, position.x - node.trail.lastPosition.x);
				else
					segPosition.dirty = true;
			}
		}

		/**
		 * Adds a new segment to a trail
		 * @param node The trail that we're working with
		 */
		private function extendTrail( node:TrailFXNode ):void
		{
			var position:Point      = node.position.position;
			var trail:TrailFX       = node.trail;

			var segment:Entity;
			if (trail.segments.length < trail.maxSegments)
			{
				segment = _vfxFactory.createTrail(trail, position.x, position.y, Math.atan2(position.y - trail.lastPosition.y, position.x - trail.lastPosition.x));
			} else
			{
				segment = trail.segments.shift();
				var pos:Position = segment.get(Position);
				pos.init(position.x, position.y, Math.atan2(position.y - trail.lastPosition.y, position.x - trail.lastPosition.x), LayerEnum.VFX);
			}

			var animation:Animation = segment.get(Animation);
			animation.scaleX = 0;
			animation.scaleY = trail.thickness;
			animation.offsetY = trail.thickness * .5;

			trail.currentSegment = segment;
			trail.lastPosition.setTo(position.x, position.y);
			trail.segments.push(segment);

			//update the alpha of the remaining segments
			_alpha = trail.alphaChange;
			for (var i:int = 0; i < trail.segments.length; i++)
			{
				Animation(trail.segments[i].get(Animation)).alpha = _alpha;
				_alpha += trail.alphaChange;
			}
			if (animation.render)
				animation.render.alpha = 0;
		}

		[Inject]
		public function set vfxFactory( v:IVFXFactory ):void  { _vfxFactory = v; }

		public override function removeFromGame( game:Game ):void
		{
			nodes.nodeRemoved.remove(onEntityRemoved);
			nodes = null;
			_bounds = null;
			_game = null;
			_vfxFactory = null;
		}
	}
}


