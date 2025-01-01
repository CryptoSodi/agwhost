package com.game.entity.factory
{
	import com.enum.CategoryEnum;
	import com.enum.FactionEnum;
	import com.enum.LayerEnum;
	import com.enum.TypeEnum;
	import com.game.entity.components.battle.Attack;
	import com.game.entity.components.sector.Mission;
	import com.game.entity.components.sector.Transgate;
	import com.game.entity.components.shared.Animation;
	import com.game.entity.components.shared.Cargo;
	import com.game.entity.components.shared.Detail;
	import com.game.entity.components.shared.Enemy;
	import com.game.entity.components.shared.EventComponent;
	import com.game.entity.components.shared.Grid;
	import com.game.entity.components.shared.Interactable;
	import com.game.entity.components.shared.Owned;
	import com.game.entity.components.shared.Position;
	import com.game.entity.components.shared.VCList;
	import com.model.asset.AssetVO;
	import com.model.player.CurrentUser;
	import com.model.player.PlayerModel;
	import com.model.player.PlayerVO;
	import com.model.sector.SectorModel;
	import com.service.server.incoming.data.SectorEntityData;
	import com.service.server.incoming.data.SectorObjectiveData;

	import org.ash.core.Entity;
	import org.shared.ObjectPool;

	public class SectorFactory extends BaseFactory implements ISectorFactory
	{
		private var _playerModel:PlayerModel;
		private var _sectorModel:SectorModel;

		public function createSectorBase( data:SectorEntityData ):Entity
		{
			var type:String       = _sectorModel.starbaseAsset;
			var assetVO:AssetVO   = _assetModel.getEntityData(type);
			var sectorBase:Entity = createEntity();
			//detail component
			var detail:Detail     = ObjectPool.get(Detail);
			detail.init(CategoryEnum.SECTOR, assetVO, null, data.ownerId);
			detail.level = 1;
			var player:PlayerVO   = _playerModel.getPlayer(data.ownerId);
			var level:int         = (player && !player.isNPC) ? player.level : data.level;
			if (level > 40)
				detail.level = 5;
			else if (level > 30)
				detail.level = 4;
			else if (level > 20)
				detail.level = 3;
			else if (level > 10)
				detail.level = 2;

			detail.baseLevel = data.level;
			
			detail.baseRatingTech = data.baseRatingTech;
			
			detail.maxPlayersPerFaction = data.maxPlayersPerFaction;

			sectorBase.add(detail);
			//position component
			var pos:Position      = ObjectPool.get(Position);
			pos.init(data.locationX, data.locationY, 1, LayerEnum.STARBSE_SECTOR);
			sectorBase.add(pos);
			//interactive component
			sectorBase.add(ObjectPool.get(Interactable));
			//grid component
			sectorBase.add(ObjectPool.get(Grid));
			//animation component
			var dmgAppend:String  = data.currentHealthPct < .25 ? "DMG" : '';
			var anim:Animation    = ObjectPool.get(Animation);
			if (data.factionPrototype != _sectorModel.sectorFaction)
			{
				var faction:String = (data.factionPrototype == FactionEnum.IGA) ? "IGA_" : (data.factionPrototype == FactionEnum.SOVEREIGNTY) ? "SOV_" : "TYR_";
				//anim.init(assetVO.type, faction  + detail.level, true, 0, 30, false, -6, -40);
			} else
				anim.init(assetVO.type, assetVO.spriteName + detail.level + dmgAppend, true, 0, 30, false, -6, -40);
			sectorBase.add(anim);
			//attack component
			var attack:Attack     = ObjectPool.get(Attack);
			attack.bubbled = data.bubbled;
			sectorBase.add(attack);
			//visual component list
			var vcList:VCList     = ObjectPool.get(VCList);
			vcList.init(TypeEnum.NAME);
			if (data.bubbled)
			{
				if (_sectorModel.sectorFaction == FactionEnum.IGA)
					vcList.addComponentType(TypeEnum.STARBASE_SHIELD_IGA);
				else if (_sectorModel.sectorFaction == FactionEnum.SOVEREIGNTY)
					vcList.addComponentType(TypeEnum.STARBASE_SHIELD_SOVEREIGNTY);
				else
					vcList.addComponentType(TypeEnum.STARBASE_SHIELD_TYRANNAR);
			}
			sectorBase.add(vcList);
			//owned or enemy
			if (data.ownerId == CurrentUser.id)
				sectorBase.add(ObjectPool.get(Owned));
			else if (data.factionPrototype != CurrentUser.faction)
				sectorBase.add(ObjectPool.get(Enemy));
			//mission component
			if (data.mission)
				sectorBase.add(ObjectPool.get(Mission));

			if (data.eventSpawn)
				sectorBase.add(ObjectPool.get(EventComponent));
			//assign the name
			sectorBase.id = data.id;
			addEntity(sectorBase);
			return sectorBase;
		}

		public function createTransgate( data:SectorEntityData ):Entity
		{
			var type:String          = _sectorModel.transgateAsset;
			var assetVO:AssetVO      = _assetModel.getEntityData(type);
			var transgate:Entity     = createEntity();
			//detail component
			var detail:Detail        = ObjectPool.get(Detail);
			detail.init(CategoryEnum.SECTOR, assetVO);
			transgate.add(detail);
			//position component
			var pos:Position         = ObjectPool.get(Position);
			pos.init(data.locationX, data.locationY, 1, LayerEnum.STARBSE_SECTOR);
			transgate.add(pos);
			//interactive component
			transgate.add(ObjectPool.get(Interactable));
			//grid component
			transgate.add(ObjectPool.get(Grid));
			//animation component
			var anim:Animation       = ObjectPool.get(Animation);
			//anim.init(assetVO.type, assetVO.spriteName, true);
			anim.playing = anim.replay = false;
			transgate.add(anim);
			//transgagte component
			var transgateC:Transgate = ObjectPool.get(Transgate);
			transgateC.isPositiveWarp = data.isPositiveWarp;
			transgateC.customDestinationPrototypeGroup = data.additionalInfo;
			transgate.add(transgateC);
			//mission component
			if (data.mission)
				transgate.add(ObjectPool.get(Mission));
			//assign the name
			transgate.id = data.id;
			addEntity(transgate);
			return transgate;
		}

		public function createDepot( data:SectorEntityData ):Entity
		{
			var type:String     = _sectorModel.depotAsset;
			var assetVO:AssetVO = _assetModel.getEntityData(type);
			var depot:Entity    = createEntity();
			//detail component
			var detail:Detail   = ObjectPool.get(Detail);
			detail.init(CategoryEnum.SECTOR, assetVO);
			depot.add(detail);
			//position component
			var pos:Position    = ObjectPool.get(Position);
			pos.init(data.locationX, data.locationY, 1, LayerEnum.STARBSE_SECTOR);
			depot.add(pos);
			//interactive component
			depot.add(ObjectPool.get(Interactable));
			//grid component
			depot.add(ObjectPool.get(Grid));
			//animation component
			var anim:Animation  = ObjectPool.get(Animation);
			anim.init(assetVO.type, assetVO.spriteName, true);
			anim.playing = anim.replay = false;
			depot.add(anim);
			//attack component
			var attack:Attack   = ObjectPool.get(Attack);
			depot.add(attack);
			//mission component
			if (data.mission)
				depot.add(ObjectPool.get(Mission));
			//assign the name
			depot.id = data.id;
			addEntity(depot);
			return depot;
		}

		public function createOutpost( data:SectorEntityData ):Entity
		{
			var type:String     = _sectorModel.outpostAsset;
			var assetVO:AssetVO = _assetModel.getEntityData(type);
			var outpost:Entity  = createEntity();
			//detail component
			var detail:Detail   = ObjectPool.get(Detail);
			detail.init(CategoryEnum.SECTOR, assetVO);
			outpost.add(detail);
			//position component
			var pos:Position    = ObjectPool.get(Position);
			pos.init(data.locationX, data.locationY, 1, LayerEnum.STARBSE_SECTOR);
			outpost.add(pos);
			//interactive component
			outpost.add(ObjectPool.get(Interactable));
			//grid component
			outpost.add(ObjectPool.get(Grid));
			//animation component
			var anim:Animation  = ObjectPool.get(Animation);
			anim.init(assetVO.type, assetVO.spriteName, true);
			anim.playing = anim.replay = false;
			outpost.add(anim);
			//attack component
			var attack:Attack   = ObjectPool.get(Attack);
			outpost.add(attack);
			//mission component
			if (data.mission)
				outpost.add(ObjectPool.get(Mission));
			//assign the name
			outpost.id = data.id;
			addEntity(outpost);
			return outpost;
		}

		public function createDerelict( data:SectorEntityData ):Entity
		{
			var type:String     = TypeEnum.DERELICT_IGA;
			if (_sectorModel.sectorFaction == FactionEnum.IMPERIUM)
				type = TypeEnum.DERELICT_IMPERIUM;
			else if (_sectorModel.sectorFaction == FactionEnum.SOVEREIGNTY)
				type = TypeEnum.DERELICT_SOVEREIGNTY;
			else if (_sectorModel.sectorFaction == FactionEnum.TYRANNAR)
				type = TypeEnum.DERELICT_TYRANNAR;
			var assetVO:AssetVO = _assetModel.getEntityData(type);
			var derelict:Entity = createEntity();
			//detail component
			var detail:Detail   = ObjectPool.get(Detail);
			detail.init(CategoryEnum.SECTOR, assetVO);
			derelict.add(detail);
			//position component
			var pos:Position    = ObjectPool.get(Position);
			pos.init(data.locationX, data.locationY, 1, LayerEnum.STARBSE_SECTOR);
			derelict.add(pos);
			//grid component
			derelict.add(ObjectPool.get(Grid));
			//animation component
			var anim:Animation  = ObjectPool.get(Animation);
			anim.init(assetVO.type, assetVO.spriteName, true);
			anim.playing = anim.replay = false;
			derelict.add(anim);
			//interactive component
			derelict.add(ObjectPool.get(Interactable));
			// cargo component
			derelict.add(ObjectPool.get(Cargo));
			//assign the name
			derelict.id = data.id;
			//add to the game
			addEntity(derelict);
			return derelict;
		}

		public function createObjective( data:SectorObjectiveData ):Entity
		{
			var assetVO:AssetVO  = _assetModel.getEntityData(data.asset);
			var objective:Entity = createEntity();
			//detail component
			var detail:Detail    = ObjectPool.get(Detail);
			detail.init(CategoryEnum.SECTOR, assetVO, null, '', 0, data.type);
			objective.add(detail);
			//position component
			var pos:Position     = ObjectPool.get(Position);
			pos.init(data.locationX, data.locationY, 1, LayerEnum.STARBSE_SECTOR);
			objective.add(pos);
			//grid component
			objective.add(ObjectPool.get(Grid));
			//animation component
			var anim:Animation   = ObjectPool.get(Animation);
			anim.init(assetVO.type, assetVO.spriteName, true);
			anim.playing = anim.replay = false;
			objective.add(anim);
			//interactive component
			objective.add(ObjectPool.get(Interactable));
			// Mission
			objective.add(ObjectPool.get(Mission));
			//assign the name
			objective.id = data.missionKey
			//add to the game
			addEntity(objective);
			return objective;
		}

		public function destroySectorEntity( entity:Entity ):void
		{
			destroyEntity(entity);
			ObjectPool.give(entity.remove(Detail));
			ObjectPool.give(entity.remove(Position));
			ObjectPool.give(entity.remove(Interactable));
			ObjectPool.give(entity.remove(Grid));
			ObjectPool.give(entity.remove(Animation));
			if (entity.has(Attack))
				ObjectPool.give(entity.remove(Attack));
			if (entity.has(Cargo))
				ObjectPool.give(entity.remove(Cargo));
			if (entity.has(Enemy))
				ObjectPool.give(entity.remove(Enemy));
			if (entity.has(Mission))
				ObjectPool.give(entity.remove(Mission));
			if (entity.has(Owned))
				ObjectPool.give(entity.remove(Owned));
			if (entity.has(Transgate))
				ObjectPool.give(entity.remove(Transgate));
			if (entity.has(VCList))
				ObjectPool.give(entity.remove(VCList));
			if (entity.has(EventComponent))
				ObjectPool.give(entity.remove(EventComponent));
		}

		[Inject]
		public function set playerModel( v:PlayerModel ):void  { _playerModel = v; }
		[Inject]
		public function set sectorModel( v:SectorModel ):void  { _sectorModel = v; }
	}
}
