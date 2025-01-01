package com.game.entity.factory
{
	import com.enum.CategoryEnum;
	import com.enum.EntityMoveEnum;
	import com.enum.FactionEnum;
	import com.enum.LayerEnum;
	import com.enum.TypeEnum;
	import com.game.entity.components.battle.Attack;
	import com.game.entity.components.battle.DebuffTray;
	import com.game.entity.components.battle.Health;
	import com.game.entity.components.battle.Modules;
	import com.game.entity.components.battle.Shield;
	import com.game.entity.components.battle.Ship;
	import com.game.entity.components.sector.Fleet;
	import com.game.entity.components.sector.Mission;
	import com.game.entity.components.shared.Animation;
	import com.game.entity.components.shared.Cargo;
	import com.game.entity.components.shared.Detail;
	import com.game.entity.components.shared.Enemy;
	import com.game.entity.components.shared.EventComponent;
	import com.game.entity.components.shared.Grid;
	import com.game.entity.components.shared.Interactable;
	import com.game.entity.components.shared.Move;
	import com.game.entity.components.shared.Owned;
	import com.game.entity.components.shared.Position;
	import com.game.entity.components.shared.VCList;
	import com.model.asset.AssetVO;
	import com.model.battle.BattleModel;
	import com.model.player.CurrentUser;
	import com.model.player.PlayerModel;
	import com.model.prototype.IPrototype;
	import com.service.server.incoming.data.BattleEntityData;
	import com.service.server.incoming.data.ModuleData;
	import com.service.server.incoming.data.SectorEntityData;
	
	import org.ash.core.Entity;
	import org.shared.ObjectPool;

	public class ShipFactory extends BaseFactory implements IShipFactory
	{
		private var _battleModel:BattleModel;
		private var _igaLayer:int;
		private var _imperiumLayer:int;
		private var _malusLayer:int;
		private var _playerModel:PlayerModel;
		private var _tyrannarLayer:int;

		[PostConstruct]
		public function init():void
		{
			var layers:Array = [1, 2, 3];
			_igaLayer = layers.splice(Math.random() * layers.length | 0, 1)[0];
			_imperiumLayer = 0;
			_malusLayer = layers.splice(Math.random() * layers.length | 0, 1)[0];
			_tyrannarLayer = layers.splice(Math.random() * layers.length | 0, 1)[0];
		}

		public function createShip( data:BattleEntityData ):Entity
		{
			var ship:Entity            = createEntity();
			//assign the name
			ship.id = data.id;
			var prototypeVO:IPrototype = data.shipPrototype;
			var assetVO:AssetVO        = _assetModel.getEntityData(prototypeVO.asset);
			//detail component
			var detail:Detail          = ObjectPool.get(Detail);
			detail.init(CategoryEnum.SHIP, assetVO, prototypeVO, data.ownerId);
			ship.add(detail);
			//position component
			var pos:Position           = ObjectPool.get(Position);
			pos.init(data.location.x, data.location.y, data.rotation, LayerEnum.SHIP + getLayer(prototypeVO.getValue('faction')));
			ship.add(pos);
			//move component
			var move:Move              = ObjectPool.get(Move);
			move.init(0, EntityMoveEnum.LERPING);
			ship.add(move);
			//health component
			var health:Health          = ObjectPool.get(Health);
			health.init(data.currentHealth, data.maxHealth, _battleModel.getBattleEntity(data.id), .2);
			ship.add(health);
			//attack component
			var attack:Attack          = ObjectPool.get(Attack);
			if (data.currentTargetId)
				attack.targetID = data.currentTargetId;
			ship.add(attack);
			//grid component
			ship.add(ObjectPool.get(Grid));
			//animation component
			var anim:Animation         = ObjectPool.get(Animation);
			anim.init(assetVO.type, assetVO.spriteName + '_0', true);
			ship.add(anim);
			//owned or enemy
			if (data.ownerId == CurrentUser.id)
				ship.add(ObjectPool.get(Owned));
			else if (data.factionPrototype != CurrentUser.battleFaction)
				ship.add(ObjectPool.get(Enemy));
			//interactive component
			ship.add(ObjectPool.get(Interactable));
			//visual component list
			var vcList:VCList          = ObjectPool.get(VCList);
			vcList.init(TypeEnum.HEALTH_BAR);
			ship.add(vcList);
			//add ship component
			ship.add(ObjectPool.get(Ship));
			//add a module component to keep track of the modules a ship has
			var modules:Modules        = ObjectPool.get(Modules);
			var moduleData:ModuleData;
			var proto:IPrototype;
			for (var i:int = 0; i < data.modules.length; i++)
			{
				moduleData = data.modules[i];
				if (moduleData.weaponPrototype)
				{
					proto = _prototypeModel.getWeaponPrototype(moduleData.weaponPrototype);
					if (proto)
					{
						if (proto.getValue("activated") == true)
							modules.addActivatedModule(moduleData.moduleIdx, proto);
						else
							modules.addModule(moduleData.moduleIdx, proto);
						modules.addModuleByAttachPoint(moduleData.attachPointPrototype, proto);
						modules.addIndexByAttachPoint(moduleData.attachPointPrototype, moduleData.moduleIdx);
					}
				} else if (moduleData.activeDefensePrototype)
				{
					proto = _prototypeModel.getWeaponPrototype(moduleData.activeDefensePrototype);
					if (proto)
					{
						if (proto.getValue("activated") == true)
							modules.addActivatedModule(moduleData.moduleIdx, proto);
						else
							modules.addModule(moduleData.moduleIdx, proto);
						modules.addModuleByAttachPoint(moduleData.attachPointPrototype, proto);
						modules.addIndexByAttachPoint(moduleData.attachPointPrototype, moduleData.moduleIdx);
					}
				} else if (moduleData.modulePrototype)
				{
					//check to see if this ship has a shield
					proto = _prototypeModel.getWeaponPrototype(moduleData.modulePrototype);
					if (proto && proto.getUnsafeValue("type") == 10)
					{
						//add the shield component
						var shield:Shield = ObjectPool.get(Shield);
						shield.init(data.shieldsEnabled, data.shieldsCurrentHealth);
						ship.add(shield);
						if (data.shieldsEnabled)
							vcList.addComponentType(TypeEnum.SHIELD);
					}
					if (proto)
					{
						modules.addModuleByAttachPoint(moduleData.attachPointPrototype, proto);
						modules.addIndexByAttachPoint(moduleData.attachPointPrototype, moduleData.moduleIdx);
					}
				}

			}
			ship.add(modules);
			//add to the game
			addEntity(ship);
			return ship;
		}

		public function createFleet( data:SectorEntityData ):Entity
		{
			var prototypeVO:IPrototype = _prototypeModel.getShipPrototype(data.shipPrototype);
			if (!prototypeVO)
				return null;
			var assetVO:AssetVO        = _assetModel.getEntityData(prototypeVO.asset);
			var fleet:Entity           = createEntity();
			//assign the name
			fleet.id = data.id;
			//detail component
			var detail:Detail          = ObjectPool.get(Detail);
			detail.init(CategoryEnum.SHIP, assetVO, prototypeVO, data.ownerId);
			detail.level = data.level;
			detail.maxPlayersPerFaction = data.maxPlayersPerFaction;
			fleet.add(detail);
			//position component
			var pos:Position           = ObjectPool.get(Position);
			pos.init(data.locationX, data.locationY, 1, LayerEnum.SHIP + getLayer(data.factionPrototype));
			fleet.add(pos);
			//move component
			var move:Move              = ObjectPool.get(Move);
			move.init(data.travelSpeed, EntityMoveEnum.POINT_TO_POINT);
			fleet.add(move);
			//grid component
			fleet.add(ObjectPool.get(Grid));
			//animation component
			var anim:Animation         = ObjectPool.get(Animation);
			anim.init(assetVO.type, assetVO.spriteName + '_0', true);
			fleet.add(anim);
			//attack component
			var attack:Attack          = ObjectPool.get(Attack);
			fleet.add(attack);
			//owned or enemy
			if (data.ownerId == CurrentUser.id)
				fleet.add(ObjectPool.get(Owned));
			else if (data.factionPrototype != CurrentUser.faction || data.mission)
				fleet.add(ObjectPool.get(Enemy));
			//interactive component
			fleet.add(ObjectPool.get(Interactable));
			//visual component list
			var vcList:VCList          = ObjectPool.get(VCList);
			vcList.init(TypeEnum.NAME);
			fleet.add(vcList);
			// cargo component
			var cargo:Cargo            = ObjectPool.get(Cargo);
			cargo.cargo = data.cargo;
			fleet.add(cargo);
			// event component
			if (data.eventSpawn)
				fleet.add(ObjectPool.get(EventComponent));
			//fleet component
			fleet.add(ObjectPool.get(Fleet));
			//mission component
			if (data.mission)
				fleet.add(ObjectPool.get(Mission));
			//add to the game
			addEntity(fleet);
			return fleet;
		}

		public function destroyShip( ship:Entity ):void
		{
			destroyEntity(ship);
			ObjectPool.give(ship.remove(Detail));
			ObjectPool.give(ship.remove(Position));
			ObjectPool.give(ship.remove(Move));
			ObjectPool.give(ship.remove(Health));
			if (ship.has(DebuffTray))
				ObjectPool.give(ship.remove(DebuffTray));				
			if (ship.has(Shield))
				ObjectPool.give(ship.remove(Shield));
			ObjectPool.give(ship.remove(Attack));
			ObjectPool.give(ship.remove(Grid));
			ObjectPool.give(ship.remove(Animation));
			if (ship.has(Owned))
				ObjectPool.give(ship.remove(Owned));
			else if (ship.has(Enemy))
				ObjectPool.give(ship.remove(Enemy));
			ObjectPool.give(ship.remove(Interactable));
			ObjectPool.give(ship.remove(VCList));
			ObjectPool.give(ship.remove(Modules));
			ObjectPool.give(ship.remove(Ship));
		}

		public function destroyFleet( fleet:Entity ):void
		{
			destroyEntity(fleet);
			ObjectPool.give(fleet.remove(Detail));
			ObjectPool.give(fleet.remove(Position));
			ObjectPool.give(fleet.remove(Move));
			ObjectPool.give(fleet.remove(Grid));
			ObjectPool.give(fleet.remove(Animation));
			ObjectPool.give(fleet.remove(Interactable));
			ObjectPool.give(fleet.remove(Fleet));
			ObjectPool.give(fleet.remove(VCList));
			if (fleet.has(Owned))
				ObjectPool.give(fleet.remove(Owned));
			if (fleet.has(Enemy))
				ObjectPool.give(fleet.remove(Enemy));
			if (fleet.has(Mission))
				ObjectPool.give(fleet.remove(Mission));
			if (fleet.has(EventComponent))
				ObjectPool.give(fleet.remove(EventComponent));
		}

		private function getLayer( faction:String ):int
		{
			switch (faction)
			{
				case FactionEnum.IGA:
					return _igaLayer;
				case FactionEnum.SOVEREIGNTY:
					return _malusLayer;
				case FactionEnum.IMPERIUM:
					return _imperiumLayer;
			}
			return _tyrannarLayer;
		}

		[Inject]
		public function set battleModel( v:BattleModel ):void  { _battleModel = v; }
		[Inject]
		public function set playerModel( v:PlayerModel ):void  { _playerModel = v; }
	}
}


