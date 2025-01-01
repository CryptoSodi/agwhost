package com.game.entity.systems.sector
{
	import com.Application;
	import com.event.StateEvent;
	import com.game.entity.components.shared.Detail;
	import com.game.entity.factory.IVFXFactory;
	import com.game.entity.nodes.sector.fleet.FleetNode;
	import com.game.entity.nodes.sector.fleet.FleetStarlingNode;
	import com.game.entity.nodes.sector.fleet.IFleetNode;
	import com.model.prototype.IPrototype;
	import com.model.prototype.PrototypeModel;
	import com.util.BattleUtils;

	import org.adobe.utils.StringUtil;
	import org.ash.core.Game;
	import org.ash.core.NodeList;
	import org.ash.core.System;

	public class FleetSystem extends System
	{
		private static const THRUSTER_THRESHOLD:Number = 5;

		[Inject(nodeType="IFleetNode")]
		public var nodes:NodeList;

		private var _tempRotation:Number;
		private var _prototypeModel:PrototypeModel;
		private var _vfxFactory:IVFXFactory;

		override public function addToGame( game:Game ):void
		{
			var fleetNode:FleetNode;
			var fleetStarlingNode:FleetStarlingNode;

			nodes.nodeAdded.add(onNodeAdded);
			nodes.nodeRemoved.add(onNodeRemoved);
		}

		override public function update( time:Number ):void
		{
			for (var node:IFleetNode = nodes.head; node; node = node.inext)
			{
				if (node.move.totalTime >= THRUSTER_THRESHOLD && node.move.time > 1.5 && node.move.time < node.move.totalTime - 0.3)
				{
					if (!node.fleet.thrustersEngaged)
						createThrusters(node);
				} else if (node.fleet.thrustersEngaged)
					destroyThrusters(node);

				//update the rotation of the ship if it is moving
				if (node.move.moving)
				{
					// Determine sprite frame to use based on angle
					_tempRotation = Math.atan2(Math.sin(node.position.rotation) * 2.0, Math.cos(node.position.rotation));
					node.position.rotation = _tempRotation;
					_tempRotation = (_tempRotation / Math.PI) * 180;
					_tempRotation = _tempRotation % 360;
					if (_tempRotation < 0)
						_tempRotation += 360;
					node.animation.label = node.detail.spriteName + "_" + Math.round(_tempRotation / 3.025);
				}

				//update thrusters if they are engaged
				if (node.fleet.thrustersEngaged)
				{
					BattleUtils.instance.moveToAttachPoint(node.ientity, node.fleet.thrusterBackLeft);
					BattleUtils.instance.moveToAttachPoint(node.ientity, node.fleet.thrusterBackRight);
				}
			}
		}

		private function onNodeAdded( node:IFleetNode ):void
		{
			// Correct rotation for isometric perspective. only need to do this if not in battle
			if (Application.STATE != StateEvent.GAME_BATTLE)
			{
				var x:Number = Math.cos(node.position.rotation);
				var y:Number = Math.sin(node.position.rotation) * 2;
				node.position.rotation = Math.atan2(y, x);
			}

			// Determine sprite frame to use based on angle
			var rot:Number = (node.position.rotation / Math.PI) * 180;
			rot = rot % 360;
			if (rot < 0)
				rot += 360;
			var num:int    = rot / 3.025 | 0;
			node.animation.label = node.detail.spriteName + "_" + num;
		}

		private function createThrusters( node:IFleetNode ):void
		{
			// Show the thrusters
			var attachPoints:Array = node.detail.prototypeVO.getValue("attachPoints");

			for each (var attachPoint:String in attachPoints)
			{
				var attachPointProto:IPrototype = _prototypeModel.getAttachPoint(attachPoint);

				// Ignore everything but back thrusters
				if (StringUtil.beginsWith(attachPointProto.getValue("attachPointType"), "ThrusterBackwardLeft"))
					node.fleet.thrusterBackLeft = _vfxFactory.createThruster(node.ientity, attachPointProto, false, true);
				if (StringUtil.beginsWith(attachPointProto.getValue("attachPointType"), "ThrusterBackwardRight"))
					node.fleet.thrusterBackRight = _vfxFactory.createThruster(node.ientity, attachPointProto, false, true);
			}
			node.fleet.thrustersEngaged = true;
		}

		private function destroyThrusters( node:IFleetNode ):void
		{
			if (node.fleet.thrusterBackLeft && node.fleet.thrusterBackLeft.has(Detail))
				_vfxFactory.destroyVFX(node.fleet.thrusterBackLeft);
			if (node.fleet.thrusterBackRight && node.fleet.thrusterBackRight.has(Detail))
				_vfxFactory.destroyVFX(node.fleet.thrusterBackRight);
			node.fleet.disengageThrusters();
		}

		private function onNodeRemoved( node:IFleetNode ):void
		{
			if (node.fleet.thrustersEngaged)
				destroyThrusters(node);
		}

		override public function removeFromGame( game:Game ):void
		{
			nodes.nodeAdded.remove(onNodeAdded);
			nodes.nodeRemoved.remove(onNodeRemoved);
			nodes = null;
		}

		[Inject]
		public function set prototypeModel( v:PrototypeModel ):void  { _prototypeModel = v; }
		[Inject]
		public function set vfxFactory( v:IVFXFactory ):void  { _vfxFactory = v; }
	}
}

