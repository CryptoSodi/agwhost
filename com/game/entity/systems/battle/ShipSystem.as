package com.game.entity.systems.battle
{
	import com.controller.ServerController;
	import com.controller.sound.SoundController;
	import com.enum.AudioEnum;
	import com.game.entity.components.battle.Damage;
	import com.game.entity.components.battle.Modules;
	import com.game.entity.components.battle.Ship;
	import com.game.entity.components.shared.Animation;
	import com.game.entity.components.shared.Detail;
	import com.game.entity.components.shared.Muzzle;
	import com.game.entity.components.shared.Position;
	import com.game.entity.components.shared.Thruster;
	import com.game.entity.factory.IVFXFactory;
	import com.game.entity.nodes.battle.ship.IShipNode;
	import com.game.entity.nodes.battle.ship.ShipNode;
	import com.game.entity.nodes.battle.ship.ShipStarlingNode;
	import com.model.asset.AssetModel;
	import com.model.prototype.IPrototype;
	import com.model.prototype.PrototypeModel;
	import com.util.BattleUtils;
	
	import flash.geom.Point;
	import flash.utils.Dictionary;
	
	import org.adobe.utils.StringUtil;
	import org.ash.core.Entity;
	import org.ash.core.Game;
	import org.ash.core.NodeList;
	import org.ash.core.System;
	import org.console.Console;

	public class ShipSystem extends System
	{
		[Inject(nodeType="IShipNode")]
		public var nodes:NodeList;

		private var _accelerationComponents:Point;
		private var _assetModel:AssetModel;
		private var _game:Game;
		private var _motionComponentsA:Point;
		private var _motionComponentsB:Point
		private var _prototypeModel:PrototypeModel;
		private var _tempRotation:Number;
		private var _vfxFactory:IVFXFactory;
		private var _soundController:SoundController;

		// TEST ONLY - Set TRUE to show colored markers on all attach points
		private var _debugAttachPoints:Boolean = false;

		override public function addToGame( game:Game ):void
		{
			var shipNode:ShipNode;
			var shipStarlingNode:ShipStarlingNode;
			nodes.nodeAdded.add(onNodeAdded);
			nodes.nodeRemoved.add(onNodeRemoved);

			_accelerationComponents = new Point();
			_game = game;
			_motionComponentsA = new Point();
			_motionComponentsB = new Point();
		}

		override public function update( time:Number ):void
		{
			var ship:Ship;
			for (var node:IShipNode = nodes.head; node; node = node.inext)
			{
				ship = node.ship;
				// If we need to, set which thruster banks should be visible
				// Update every ten frames to reduce flickering from minor changes
				if (ServerController.SIMULATED_TICK > ship.lastUpdate + 2)
				{
					// Set last update
					ship.lastUpdate = ServerController.SIMULATED_TICK;

					// Update the system's motion history
					var p:Point                      = ship.position1;
					p.setTo(node.move.lerpDestination.x, node.move.lerpDestination.y);
					ship.position1 = ship.position2;
					ship.position2 = ship.position3;
					ship.position3 = p;

					// Reconstruct the acceleration vector
					_motionComponentsA.setTo(ship.position1.x - ship.position2.x,
											 ship.position1.y - ship.position2.y);
					_motionComponentsB.setTo(ship.position2.x - ship.position3.x,
											 ship.position2.y - ship.position3.y);
					_accelerationComponents.setTo(_motionComponentsA.x - _motionComponentsB.x, _motionComponentsA.y - _motionComponentsB.y);

					// Determine the acceleration direction
					var accelerationDirection:Number = (Math.atan2(_accelerationComponents.y, _accelerationComponents.x * -1) + node.move.rotation) * 57.2957795;

					// Update thruster visibility
					ship.thrustersFront = false || _debugAttachPoints;
					ship.thrustersRight = false || _debugAttachPoints;
					ship.thrustersBack = false || _debugAttachPoints;
					ship.thrustersLeft = false || _debugAttachPoints;
					if (_accelerationComponents.length > 0.1)
					{
						/*
						   if (accelerationDirection > 270 || accelerationDirection < 90)
						   ship.thrustersFront = true;
						   if (accelerationDirection > 195 && accelerationDirection < 345)
						   ship.thrustersRight = true;
						 */
						if (accelerationDirection > 90 && accelerationDirection < 270)
							ship.thrustersBack = true;
						/*
						   if (accelerationDirection > 15 && accelerationDirection < 165)
						   ship.thrustersLeft = true;
						 */
					}
				}


				//thrusters
				if (node.move.moving)
				{
					// Determine sprite frame to use based on angle
					_tempRotation = Math.atan2(Math.sin(node.position.rotation), Math.cos(node.position.rotation));
					_tempRotation = (_tempRotation / Math.PI) * 180;
					_tempRotation = _tempRotation % 360;
					if (_tempRotation < 0)
						_tempRotation += 360;
					node.animation.label = node.detail.spriteName + "_" + Math.round(_tempRotation / 3.025);
				}
				
				// Update attachments
				for each (var attachment:Entity in ship.attachments)
				{
					var animation:Animation = attachment.get(Animation);
					if (animation)
					{
						// Update thruster visibility
						var thrusterComponent:Thruster  = attachment.get(Thruster);
						if (thrusterComponent && node.move.moving)
						{
							if ((ship.thrustersFront && thrusterComponent.direction == "Forward") ||
								(ship.thrustersRight && thrusterComponent.direction == "Right") ||
								(ship.thrustersBack && thrusterComponent.direction == "Backward") ||
								(ship.thrustersLeft && thrusterComponent.direction == "Left"))
							{
								BattleUtils.instance.moveToAttachPoint(node.ientity, attachment, true);
								animation.visible = true;
							} else
							{
								animation.visible = false;
							}
						}
							
						// Update muzzle flash visibility
						else
						{
							// Update the position of the attachment
							BattleUtils.instance.moveToAttachPoint(node.ientity, attachment, false);

							// Make sure we'll have all the data we need
							var modulesComponent:Modules = node.ientity.get(Modules);
							var muzzleComponent:Muzzle = attachment.get(Muzzle);
							if (modulesComponent && muzzleComponent)
							{
								// Set the state only if there's data
								var moduleStates:Dictionary = modulesComponent.moduleStates;
								var moduleIndex:Number = muzzleComponent.moduleIdx;
								if ( moduleStates.hasOwnProperty(moduleIndex) )
								{
									// Animate dynamics as needed
									if (muzzleComponent.currentFrame >= 0)
									{
										// Start playing chargeup sounds on first frame
										if (muzzleComponent.currentFrame == 0)
										{
											if (muzzleComponent.weaponClass == "GravitonPulseNode")
												_soundController.playSound(AudioEnum.AFX_GRAVITON_PULSE_NODE_CHARGE, 0.5);
											else if (muzzleComponent.weaponClass == "FusionBeamer")
												_soundController.playSound(AudioEnum.AFX_FUSION_BEAMER_CHARGE, 0.5);
										}
										
										// Increment or decrement the animation frame
										var ratio:Number = 0.0;
										var scale:Number = 1.0;
										if (muzzleComponent.charging)
										{
											muzzleComponent.currentFrame += 1;
											ratio = muzzleComponent.currentFrame / muzzleComponent.chargeDuration;
											scale = Math.sin(ratio * 1.57079633);
										}
										else
										{
											muzzleComponent.currentFrame -= 4;
											ratio = muzzleComponent.currentFrame / muzzleComponent.chargeDuration;
											scale = 1.0 - Math.cos(ratio * 1.57079633);
										}
										
										// Clamp and apply scale to sprite
										scale = Math.max( 0.0, Math.min( scale, 1.0 ) );
										var animComponent:Animation = attachment.get(Animation);
										animComponent.scaleX = scale * muzzleComponent.baseScale;
										animComponent.scaleY = scale * muzzleComponent.baseScale;
									}
									// Rest when down spinning down
									else if (animation.visible)
									{
										animation.visible = false;
										muzzleComponent.currentFrame = -1;
										muzzleComponent.charging = false;
									}
									
									// Start charging when entering state
									if ( moduleStates[moduleIndex] == 1 )
									{
										animation.visible = true;
										if (!muzzleComponent.charging)
										{
											muzzleComponent.currentFrame = 0;
											muzzleComponent.charging = true;
										}
									}
									// Ramp down during firing
									else if (muzzleComponent.charging && moduleStates[moduleIndex] != 2)
									{
										muzzleComponent.charging = false;
									}

								}
							}
						}
					}
				}

				//damage effects
				if (node.health.percent > 0 && node.health.percent < node.health.damageThreshold)
				{
					if (node.ship.damageEffects.length == 0)
						showDamage(node);

					for each (var damageEffect:Entity in ship.damageEffects)
					{
						// Update effect position
						BattleUtils.instance.moveToAttachPoint(node.ientity, damageEffect);
						var position:Position = damageEffect.get(Position);
						var damage:Damage     = damageEffect.get(Damage);
						position.rotation += damage.rotOffset;
					}
				}
			}
		}

		private function onNodeAdded( node:IShipNode ):void
		{
			// Set the initial rotation of the ship
			var rot:Number         = (node.position.rotation / Math.PI) * 180;
			rot = rot % 360;
			if (rot < 0)
				rot += 360;
			var num:int            = rot / 3.025 | 0;
			node.animation.label = node.detail.spriteName + "_" + num;

			// Show the thrusters
			var apDetail:Detail    = node.detail;
			var attachPoints:Array = apDetail.prototypeVO.getValue("attachPoints");

			// Set the thruster's acceleration threshold
			node.ship.accelThreshold = 0.1;
			var threshold:Number   = apDetail.prototypeVO.getValue("thrusterThreshold");
			if (threshold)
				node.ship.accelThreshold = threshold;

			for each (var attachPoint:String in attachPoints)
			{
				var attachPointProto:IPrototype = _prototypeModel.getAttachPoint(attachPoint);
				var attachPointType:String = attachPointProto.getValue("attachPointType");
				var moduleProto:IPrototype = getModuleByAttachPoint(node, attachPoint);
				var slotIndex:Number = getModuleIndexByAttachPoint(node, attachPoint);

				// Create the proper kind of sprite
				if (_debugAttachPoints)
				{
					var thruster:Entity = _vfxFactory.createThruster(node.ientity, attachPointProto, true);
					if(thruster != null)
						node.ship.attachments.push(thruster);
				}
				else if (StringUtil.beginsWith(attachPointType, "ThrusterBackward"))
				{
					var thruster:Entity = _vfxFactory.createThruster(node.ientity, attachPointProto, false);
					if(thruster != null)
						node.ship.attachments.push(thruster);
				}
				else if (StringUtil.beginsWith(attachPointType, "ArcWeapon") && moduleProto && moduleProto.getUnsafeValue("chargeTime"))
				{
					node.ship.attachments.push(_vfxFactory.createMuzzle(node.ientity, attachPointProto, moduleProto, slotIndex));
				}
				else if (StringUtil.beginsWith(attachPointType, "SpinalWeapon") && moduleProto && moduleProto.getUnsafeValue("chargeTime"))
				{
					node.ship.attachments.push(_vfxFactory.createMuzzle(node.ientity, attachPointProto, moduleProto, slotIndex));
				}
				else
				{
					continue;
				}

				// Safety check error testing
				if (node.ship.attachments.length > 11 && !_debugAttachPoints)
					throw new Error("Attempted to add too many attachments!");
			}
		}
		
		private function getModuleByAttachPoint( node:IShipNode, attachPoint:String ):IPrototype
		{
			var component:Modules = node.ientity.get(Modules);
			return component.getModuleByAttachPoint( attachPoint );
		}

		private function getModuleIndexByAttachPoint( node:IShipNode, attachPoint:String ):Number
		{
			var component:Modules = node.ientity.get(Modules);
			return component.getModuleIndexByAttachPoint( attachPoint );
		}
		
		private function showDamage( node:IShipNode ):void
		{
			var apDetail:Detail    = node.ientity.get(Detail);
			var attachPoints:Array = apDetail.prototypeVO.getValue("attachPoints");

			// Attach damage effects to each target attach point
			var attachPoint:String
			for (var i:int = 0; i < attachPoints.length; i++)
			{
				var attachPointProto:IPrototype = _prototypeModel.getAttachPoint(attachPoints[i]);

				// Ignore everything but target points
				if (!StringUtil.beginsWith(attachPointProto.getValue("attachPointType"), "Target"))
					continue;

				// Store the damage effect in the component's effects list
				node.ship.damageEffects.push(_vfxFactory.createDamageEffect(node.ientity, attachPointProto));
			}
		}

		private function onNodeRemoved( node:IShipNode ):void
		{
			var thrusters:Vector.<Entity>     = node.ship.attachments;
			for (var i:int = 0; i < thrusters.length; i++)
			{
				var thruster:Entity = thrusters[i];
				if (thruster.has(Detail))
					_vfxFactory.destroyVFX(thruster);
			}

			var damageEffects:Vector.<Entity> = node.ship.damageEffects;
			for (i = 0; i < damageEffects.length; i++)
			{
				var damage:Entity = damageEffects[i];
				if (damage.has(Detail))
					_vfxFactory.destroyVFX(damage);
			}
			node.ship.destroy(false);
		}

		[Inject]
		public function set assetModel( v:AssetModel ):void  { _assetModel = v; }
		[Inject]
		public function set prototypeModel( v:PrototypeModel ):void  { _prototypeModel = v; }
		[Inject]
		public function set vfxFactory( v:IVFXFactory ):void  { _vfxFactory = v; }
		[Inject]
		public function set soundController( v:SoundController ):void { _soundController = v; }

		override public function removeFromGame( game:Game ):void
		{
			nodes.nodeAdded.remove(onNodeAdded);
			nodes.nodeRemoved.remove(onNodeRemoved);
			nodes = null;

			_accelerationComponents = null;
			_game = null;
			_motionComponentsA = null;
			_motionComponentsB = null;
		}
	}
}
