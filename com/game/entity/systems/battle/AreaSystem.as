package com.game.entity.systems.battle
{
	import com.game.entity.components.battle.Area;
	import com.game.entity.nodes.battle.AreaNode;
	import com.util.BattleUtils;

	import flash.geom.Point;

	import org.ash.core.Entity;
	import org.ash.core.Game;
	import org.ash.core.NodeList;
	import org.ash.core.System;

	public class AreaSystem extends System
	{
		[Inject(nodeType="com.game.entity.nodes.battle.AreaNode")]
		public var nodes:NodeList;

		private var _game:Game;
		private var _sourceLoc:Point;

		override public function addToGame( game:Game ):void
		{
			_game = game;
			_sourceLoc = new Point();
			nodes.nodeAdded.add(onNodeAdded);
			nodes.nodeRemoved.add(onNodeRemoved);
		}

		private function onNodeAdded( node:AreaNode ):void
		{
			if (node.area.useBeamDynamics)
				node.init(onReady);
		}

		private function onReady( node:AreaNode ):void
		{
			node.animation.offsetY = node.animation.height * 0.5;
		}

		private function onNodeRemoved( node:AreaNode ):void
		{
			node.destroy();
		}

		override public function update( time:Number ):void
		{
			var area:Area;
			var owner:Entity;
			var ratio:Number;

			for (var node:AreaNode = nodes.head; node; node = node.next)
			{
				// Init some useful stuff for updates in general
				area = node.area;
				owner = _game.getEntity(node.detail.ownerID);

				// Perform attachments if the area is attached
				if (owner)
				{
					// If attached to an entity then update location with it
					if (area.moveWithSource)
					{
						BattleUtils.instance.getAttachPointLocation(owner, area.sourceAttachPoint, _sourceLoc);
						node.position.x = _sourceLoc.x;
						node.position.y = _sourceLoc.y;
					}

					// If locked to an entity's heading then rotate with it
					if (area.rotateWithSource)
					{
						node.position.rotation = BattleUtils.instance.getAttachPointRotation(owner, area.sourceAttachPoint);
					}
				}

				// Perform animations if there are any
				if (area.animTime < area.animLength)
				{
					// Update the current frame
					area.animTime += time;

					if (area.animTime > area.animLength)
						area.animTime = area.animLength;

					ratio = area.animTime / area.animLength;
					// Scale the x as required, used for most areas
					node.animation.scaleX = area.startScaleX + area.scaleDeltaX * ratio;

					// Scale the y as required, usually not for beams
					node.animation.scaleY = area.startScaleY + area.scaleDeltaY * ratio;

					// Update sprite alpha
					node.animation.alpha = area.startAlpha + area.alphaDelta * ratio;
				}
				/*
				   else if (node.area.duration > 0)
				   node.area.resetAnimation();
				 */

				// Dirty the area so it gets updated
				node.position.dirty = true;
			}
		}

		override public function removeFromGame( game:Game ):void
		{
			nodes.nodeAdded.remove(onNodeAdded);
			nodes = null;
			_game = null;
			_sourceLoc = null;
		}
	}
}
