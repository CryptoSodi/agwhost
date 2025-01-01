package com.game.entity.systems.battle
{
	import com.controller.sound.SoundController;
	import com.enum.AudioEnum;
	import com.enum.CategoryEnum;
	import com.enum.TypeEnum;
	import com.game.entity.components.battle.Health;
	import com.game.entity.components.shared.Detail;
	import com.game.entity.components.starbase.Building;
	import com.game.entity.factory.IVFXFactory;
	import com.game.entity.nodes.battle.HealthNode;
	import com.game.entity.nodes.battle.ShieldNode;

	import flash.utils.Dictionary;

	import org.ash.core.Game;
	import org.ash.core.NodeList;
	import org.ash.core.System;
	import org.osflash.signals.Signal;
	import org.shared.ObjectPool;

	public class VitalsSystem extends System
	{
		[Inject(nodeType="com.game.entity.nodes.battle.HealthNode")]
		public var healthNodes:NodeList;

		[Inject(nodeType="com.game.entity.nodes.battle.ShieldNode")]
		public var shieldNodes:NodeList;

		private var _soundController:SoundController;
		private var _tempID:String;
		private var _totalHealthByPlayer:Dictionary;
		private var _vfxFactory:IVFXFactory;
		public var onHealthChanged:Signal;

		override public function addToGame( game:Game ):void
		{
			var node:HealthNode;
			var shNode:ShieldNode;
			onHealthChanged = new Signal(String, Number);
			_totalHealthByPlayer = new Dictionary();
			healthNodes.nodeAdded.add(onHealthNodeAdded);
			healthNodes.nodeRemoved.add(onNodeRemoved);
			shieldNodes.nodeAdded.add(onShieldNodeAdded);
			shieldNodes.nodeRemoved.add(onNodeRemoved);
		}

		private function onHealthNodeAdded( node:HealthNode ):void
		{
			node.init(onHealthChange);
			//track the total health of the player's entities
			_tempID = node.detail.ownerID;
			if (!_totalHealthByPlayer.hasOwnProperty(_tempID))
			{
				var health:Health = ObjectPool.get(Health);
				health.init(0, 0, null, -1);
				_totalHealthByPlayer[_tempID] = health;
			}
			if (node.detail.category != CategoryEnum.BUILDING || node.detail.prototypeVO.itemClass != TypeEnum.PYLON)
			{
				_totalHealthByPlayer[_tempID].maxHealth += node.health.maxHealth;
				_totalHealthByPlayer[_tempID].currentHealth += node.health.currentHealth;
				onHealthChanged.dispatch(_tempID, _totalHealthByPlayer[_tempID].percent);
			}
		}

		private function onShieldNodeAdded( node:* ):void
		{
			node.init(onEnableChanged, onStrengthChanged);
		}

		private function onNodeRemoved( node:* ):void
		{
			if (node is HealthNode)
			{
				onHealthChange(node, 0, node.health.currentHealth);
			}
			node.destroy();
		}

		private function onHealthChange( node:HealthNode, percent:Number, change:Number ):void
		{
			if (node.health.animation)
			{
				node.health.animation.scaleX = percent;
				if (node.health.animation.render)
					node.health.animation.render.scaleX = percent;
			}
			if (node.detail.category != CategoryEnum.BUILDING || node.detail.prototypeVO.itemClass != TypeEnum.PYLON)
			{
				//update the total health of the player's entities
				_tempID = Detail(node.entity.get(Detail)).ownerID;
				_totalHealthByPlayer[_tempID].currentHealth -= change;
				onHealthChanged.dispatch(_tempID, _totalHealthByPlayer[_tempID].percent);
			}
		}

		private function onStrengthChanged( node:ShieldNode, current:int ):void
		{
			if (node.shield.enabled && !node.shield.isBuildingShield)
			{
				//_soundController.playSound(AudioEnum.AFX_SHIELD_HIT_SHIP, 0.5);
				if (node.shield.animation)
					node.shield.animation.playing = true;
			}
		}

		private function onEnableChanged( node:ShieldNode, enabled:Boolean ):void
		{
			if (enabled)
			{
				if (node.shield.isBuildingShield)
				{
					var building:Building = node.$building;
					if (building.buildingVO.itemClass == TypeEnum.POINT_DEFENSE_PLATFORM)
					{
						if (!node.vcList.hasComponentType(TypeEnum.TURRET_SHIELD))
							node.vcList.addComponentType(TypeEnum.TURRET_SHIELD);
					} else
					{
						if (!node.vcList.hasComponentType(TypeEnum.BUILDING_SHIELD))
							node.vcList.addComponentType(TypeEnum.BUILDING_SHIELD);
					}
				} else if (!node.vcList.hasComponentType(TypeEnum.SHIELD))
					node.vcList.addComponentType(TypeEnum.SHIELD);
				_soundController.playSound(AudioEnum.AFX_SHIELDS_UP, 0.5);
					//_vfxFactory.createMessage(node.entity, TypeEnum.SHIELD_RESTORED);
			} else
			{
				if (node.shield.isBuildingShield)
				{
					building = node.$building;
					if (building.buildingVO.itemClass == TypeEnum.POINT_DEFENSE_PLATFORM)
						node.vcList.removeComponentType(TypeEnum.TURRET_SHIELD);
					else
						node.vcList.removeComponentType(TypeEnum.BUILDING_SHIELD);
				} else
					node.vcList.removeComponentType(TypeEnum.SHIELD);
				//_vfxFactory.createMessage(node.entity, TypeEnum.SHIELD_DOWN);
				_soundController.playSound(AudioEnum.AFX_SHIELDS_DOWN, 0.5);
			}
		}

		public function getTotalHealthByPlayer( id:String ):Number
		{
			if (_totalHealthByPlayer.hasOwnProperty(id))
				return _totalHealthByPlayer[id].percent;
			return 1;
		}

		[Inject]
		public function set soundController( v:SoundController ):void  { _soundController = v }
		[Inject]
		public function set vfxFactory( v:IVFXFactory ):void  { _vfxFactory = v }

		override public function removeFromGame( game:Game ):void
		{
			onHealthChanged.removeAll();
			onHealthChanged = null;
			healthNodes.nodeAdded.remove(onHealthNodeAdded);
			healthNodes.nodeRemoved.remove(onNodeRemoved);
			shieldNodes.nodeAdded.remove(onShieldNodeAdded);
			shieldNodes.nodeRemoved.remove(onNodeRemoved);
			healthNodes = null;
			shieldNodes = null;
			_totalHealthByPlayer = null;
		}
	}
}
