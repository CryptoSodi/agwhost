package com.game.entity.factory
{
	import com.Application;
	import com.controller.transaction.TransactionController;
	import com.enum.AudioEnum;
	import com.enum.CategoryEnum;
	import com.enum.FactionEnum;
	import com.enum.LayerEnum;
	import com.enum.TypeEnum;
	import com.event.StateEvent;
	import com.game.entity.components.battle.Attack;
	import com.game.entity.components.battle.Health;
	import com.game.entity.components.battle.Shield;
	import com.game.entity.components.shared.Animation;
	import com.game.entity.components.shared.Detail;
	import com.game.entity.components.shared.Enemy;
	import com.game.entity.components.shared.Grid;
	import com.game.entity.components.shared.Interactable;
	import com.game.entity.components.shared.Owned;
	import com.game.entity.components.shared.Position;
	import com.game.entity.components.shared.Pylon;
	import com.game.entity.components.shared.VCList;
	import com.game.entity.components.shared.fsm.FSM;
	import com.game.entity.components.shared.fsm.Forcefield;
	import com.game.entity.components.shared.fsm.TurretFSM;
	import com.game.entity.components.starbase.Building;
	import com.game.entity.components.starbase.Platform;
	import com.game.entity.components.starbase.State;
	import com.game.entity.systems.starbase.StarbaseSystem;
	import com.model.asset.AssetVO;
	import com.model.battle.BattleModel;
	import com.model.player.CurrentUser;
	import com.model.player.PlayerModel;
	import com.model.prototype.IPrototype;
	import com.model.prototype.PrototypeVO;
	import com.model.sector.SectorModel;
	import com.model.starbase.BuildingVO;
	import com.model.starbase.StarbaseModel;
	import com.service.server.incoming.data.BattleEntityData;
	import com.util.AllegianceUtil;
	import com.util.CommonFunctionUtil;
	import com.util.InteractEntityUtil;
	
	import flash.geom.Point;
	
	import org.ash.core.Entity;
	import org.greensock.TweenManual;
	import org.shared.ObjectPool;

	public class StarbaseFactory extends BaseFactory implements IStarbaseFactory
	{
		private var _battleModel:BattleModel;
		private var _cornerVO:BuildingVO;
		private var _i:int;
		private var _point:Point               = new Point();
		private var _playerModel:PlayerModel;
		private var _sectorModel:SectorModel;
		private var _starbaseModel:StarbaseModel;
		private var _starbaseVO:BuildingVO;
		private var _tempBuildingVO:BuildingVO = new BuildingVO();
		private var _transactionController:TransactionController;
		private var _baseFaction:String = FactionEnum.IGA;

		public function createBuilding( id:String, vo:BuildingVO ):Entity
		{
			var faction:String =  CurrentUser.id == CurrentUser.id ? CurrentUser.faction : _playerModel.getPlayer(CurrentUser.id).faction;
			
			var building:Entity        = createEntity();
			var prototypeVO:IPrototype = vo.prototype;
			
			/*
			var assetName:String 	   = prototypeVO.asset + '_' + FactionEnum.getFactionShort(faction);
			var assetVO:AssetVO        = _assetModel.getEntityData(assetName);
			
			if( assetVO == null)
				assetVO = _assetModel.getEntityData(prototypeVO.asset);
			*/
			
			var assetVO:AssetVO  = _assetModel.getEntityData(prototypeVO.asset);
			
			/**/
			if(assetVO.spriteSheetsString == "Buildings")
			{
				if(assetVO.spriteXML.length > 0)
				{
					//assetVO.spriteSheetsString = 'Buildings_TYR';
					assetVO.sprites[0] = 'sprite/Buildings_' + FactionEnum.getFactionShort(faction) + '.png';
					assetVO.spriteXML[0] = 'sprite/Buildings_' + FactionEnum.getFactionShort(faction) + '.xml';
					//assetVO.spriteSheetsString += '_' + FactionEnum.getFactionShort(faction);
					//assetVO.spriteXML[0] += '_' + FactionEnum.getFactionShort(faction);
					//assetVO.spriteSheetsString = 'TyrannarBuildings';
					//assetVO.setOneSpriteXML('sprite/TyrannarBuildings.xml');
					
					//assetVO.spriteSheetsString = faction + "Buildings";
					//assetVO.spriteSheetsString = 'TyrannarBuildings';
					//assetVO.setSpriteXML(0, 'sprite/TyrannarBuildings.xml');
					//assetVO.setSpriteXML(0, "sprite/" + faction + "Buildings.xml"); 
					//assetVO.spriteXML[0] = "sprite/" + faction + "Buildings.xml";
				}
			} 
			
			if(assetVO.spriteSheetsString == "BaseWeaponsA")
			{
				if(assetVO.spriteXML.length > 0)
				{
					assetVO.sprites[0] = 'sprite/BaseWeaponsA_' + FactionEnum.getFactionShort(faction) + '.png';
					assetVO.spriteXML[0] = 'sprite/BaseWeaponsA_' + FactionEnum.getFactionShort(faction) + '.xml';
				}
			}
			//*/
			
			//detail component
			var detail:Detail          = ObjectPool.get(Detail);
			detail.init(CategoryEnum.BUILDING, assetVO, prototypeVO, CurrentUser.id);
			building.add(detail);
			//position component
			var pos:Position           = ObjectPool.get(Position);
			pos.init(0, 0, 0, LayerEnum.BUILDING);
			_starbaseModel.grid.convertBuildingGridToIso(pos.position, vo);
			building.add(pos);
			//grid component
			building.add(ObjectPool.get(Grid));
			//animation component
			var anim:Animation         = ObjectPool.get(Animation);
			anim.init(assetVO.type, '', true);
			building.add(anim);
			//interactive component
			building.add(ObjectPool.get(Interactable));
			//owned
			building.add(ObjectPool.get(Owned));
			//building component
			var buildingC:Building     = ObjectPool.get(Building);
			buildingC.init(vo);
			buildingC.faction = faction;
			building.add(buildingC);
			//vclist component
			var vcList:VCList          = ObjectPool.get(VCList);
			vcList.init();
			building.add(vcList);
			
			//additional components based on itemClass
			if (vo.itemClass == TypeEnum.PYLON)
			{
				var pylon:Pylon = ObjectPool.get(Pylon);
				pylon.baseX = vo.baseX;
				pylon.baseY = vo.baseY;
				pylon.color = AllegianceUtil.instance.getFactionColor(CurrentUser.faction);
				building.add(pylon);
				pylon.bottom = createPylonPlatform(vo, pos);
			} else if (vo.itemClass == TypeEnum.POINT_DEFENSE_PLATFORM)
			{
				var turretFSM:TurretFSM = ObjectPool.get(TurretFSM);
				var fsm:FSM             = ObjectPool.get(FSM);
				fsm.init(turretFSM);
				building.add(fsm);
			}
			//assign the name
			building.id = id;
			building.add(faction);
			//set the building animation
			updateStarbaseBuilding(building);
			//add to the game
			addEntity(building);
			return building;
		}

		public function createBattleBuilding( data:BattleEntityData ):Entity
		{
			var faction:String =  data.ownerId == CurrentUser.id ? CurrentUser.faction : _playerModel.getPlayer(data.ownerId).faction;
			
			var building:Entity    = createEntity();
			_tempBuildingVO.prototype = data.buildingPrototype;
			_tempBuildingVO.baseX = data.gridLocationX;
			_tempBuildingVO.baseY = data.gridLocationY;
			_tempBuildingVO.currentHealth = data.currentHealth;
			for (_i = 0; _i < data.modules.length; _i++)
			{
				if (data.modules[_i].modulePrototype)
					_tempBuildingVO.equipModule(_prototypeModel.getWeaponPrototype(data.modules[_i].modulePrototype), data.modules[_i].slotPrototype);
				else if (data.modules[_i].weaponPrototype)
					_tempBuildingVO.equipModule(_prototypeModel.getWeaponPrototype(data.modules[_i].weaponPrototype), data.modules[_i].slotPrototype);
			}

			/*var assetName:String 	   = _tempBuildingVO.asset + '_' + FactionEnum.getFactionShort(faction);
			var assetVO:AssetVO        = _assetModel.getEntityData(assetName);
			
			if( assetVO == null)
				assetVO = _assetModel.getEntityData(_tempBuildingVO.asset);*/
			var assetVO:AssetVO    = _assetModel.getEntityData(_tempBuildingVO.asset);
			if(assetVO.spriteSheetsString == "Buildings")
			{
				if(assetVO.spriteXML.length > 0)
				{
					assetVO.sprites[0] = 'sprite/Buildings_' + FactionEnum.getFactionShort(faction) + '.png';
					assetVO.spriteXML[0] = 'sprite/Buildings_' + FactionEnum.getFactionShort(faction) + '.xml';
				}
			} 
			if(assetVO.spriteSheetsString == "BaseWeaponsA")
			{
				if(assetVO.spriteXML.length > 0)
				{
					assetVO.sprites[0] = 'sprite/BaseWeaponsA_' + FactionEnum.getFactionShort(faction) + '.png';
					assetVO.spriteXML[0] = 'sprite/BaseWeaponsA_' + FactionEnum.getFactionShort(faction) + '.xml';
				}
			}
			
			//detail component
			var detail:Detail      = ObjectPool.get(Detail);
			detail.init(CategoryEnum.BUILDING, assetVO, _tempBuildingVO.prototype, data.ownerId);
			building.add(detail);
			//position component
			var pos:Position       = ObjectPool.get(Position);
			pos.init(data.gridLocationX, data.gridLocationY, 0, LayerEnum.BUILDING);
			_starbaseModel.grid.convertBuildingGridToIso(pos.position, _tempBuildingVO);
			building.add(pos);
			//grid component
			building.add(ObjectPool.get(Grid));
			//animation component
			var anim:Animation     = ObjectPool.get(Animation);
			anim.init(assetVO.type, '', true);
			building.add(anim);
			
			var oid:String = CurrentUser.id;
			//owned or enemy
			if (data.ownerId == CurrentUser.id)
			{
				building.add(ObjectPool.get(Owned));
				if (_tempBuildingVO.itemClass == TypeEnum.POINT_DEFENSE_PLATFORM && data.currentHealth > 0)
					building.add(ObjectPool.get(Interactable));
			} else if (data.factionPrototype != CurrentUser.battleFaction)
			{
				if (data.currentHealth > 0)
					building.add(ObjectPool.get(Interactable));
				building.add(ObjectPool.get(Enemy));
			}
			//health component
			var health:Health      = ObjectPool.get(Health);
			health.init(data.currentHealth, data.maxHealth, _battleModel.getBattleEntity(data.id), 1);
			building.add(health);
			//building component
			var buildingC:Building = ObjectPool.get(Building);
			buildingC.init(_tempBuildingVO);
			buildingC.faction = faction;
			building.add(buildingC);
			//shield component
			var shield:Shield      = ObjectPool.get(Shield);
			shield.init(data.shieldsEnabled, data.shieldsCurrentHealth, true);
			building.add(shield);
			//vclist component
			var vcList:VCList      = ObjectPool.get(VCList);
			if (data.currentHealth > 0)
				vcList.init(TypeEnum.HEALTH_BAR);
			else
				vcList.init();
			if (data.shieldsEnabled && data.currentHealth > 0)
			{
				if (_tempBuildingVO.itemClass == TypeEnum.POINT_DEFENSE_PLATFORM)
					vcList.addComponentType(TypeEnum.TURRET_SHIELD);
				else
					vcList.addComponentType(TypeEnum.BUILDING_SHIELD);
			}
			building.add(vcList);
			//additional components based on itemClass
			if (_tempBuildingVO.itemClass == TypeEnum.PYLON)
			{
				var pylon:Pylon = ObjectPool.get(Pylon);
				pylon.baseX = _tempBuildingVO.baseX;
				pylon.baseY = _tempBuildingVO.baseY;
				pylon.color = AllegianceUtil.instance.getFactionColor(_playerModel.getPlayer(data.ownerId).faction);
				building.add(pylon);
				pylon.bottom = createPylonPlatform(_tempBuildingVO, pos);
			} else if (_tempBuildingVO.itemClass == TypeEnum.POINT_DEFENSE_PLATFORM)
			{
				//attack component
				var attack:Attack = ObjectPool.get(Attack);
				if (data.currentTargetId)
					attack.targetID = data.currentTargetId;
				building.add(attack);
			}
			//assign the name
			building.id = data.id;
			building.add(faction);
			//set the building animation
			updateStarbaseBuilding(building);
			//add to the game
			if (buildingC.buildingVO)
				addEntity(building);
			_tempBuildingVO = new BuildingVO();
			return building;
		}

		public function createBaseItem( id:String, vo:BuildingVO ):Entity
		{
			if (vo.constructionCategory == "Wall")
				return null;
			
			var baseItem:Entity        = createEntity();
			var prototypeVO:IPrototype = vo.prototype;
			var assetVO:AssetVO        = getBaseItemAssetVO(prototypeVO);
			
			//detail component
			var detail:Detail          = ObjectPool.get(Detail);
			detail.init(CategoryEnum.STARBASE, _assetModel.getEntityData(vo.asset), prototypeVO);
			baseItem.add(detail);
			//position component
			var pos:Position           = ObjectPool.get(Position);
			pos.init(0, 0, 1, LayerEnum.STARBSE_SECTOR);
			_starbaseModel.grid.convertBuildingGridToIso(pos.position, vo);
			baseItem.add(pos);
			//grid component
			baseItem.add(ObjectPool.get(Grid));
			//animation component
			var anim:Animation         = ObjectPool.get(Animation);
			anim.init(assetVO.type, '');
			baseItem.add(anim);
			//interactive component
			baseItem.add(ObjectPool.get(Interactable));
			//platform component
			var platform:Platform      = ObjectPool.get(Platform);
			platform.buildingVO = vo;
			baseItem.add(platform);
			//assign the name
			baseItem.id = id;
			//set the building animation
			updateStarbaseBuilding(baseItem);
			//add to the game
			addEntity(baseItem);
			return baseItem;
		}

		public function createBattleBaseItem( data:BattleEntityData):Entity
		{
			_tempBuildingVO.prototype = data.buildingPrototype;
			_tempBuildingVO.baseX = data.gridLocationX;
			_tempBuildingVO.baseY = data.gridLocationY;
			var assetVO:AssetVO   = getBaseItemAssetVO(_tempBuildingVO.prototype);
			var baseItem:Entity   = createEntity();
			//detail component
			var detail:Detail     = ObjectPool.get(Detail);
			detail.init(CategoryEnum.STARBASE, _assetModel.getEntityData(_tempBuildingVO.asset), _tempBuildingVO.prototype, data.ownerId);
			baseItem.add(detail);
			//position component
			var pos:Position      = ObjectPool.get(Position);
			pos.init(0, 0, 1, LayerEnum.STARBSE_SECTOR);
			_starbaseModel.grid.convertBuildingGridToIso(pos.position, _tempBuildingVO);
			baseItem.add(pos);
			//grid component
			baseItem.add(ObjectPool.get(Grid));
			//animation component
			var anim:Animation    = ObjectPool.get(Animation);
			anim.init(assetVO.type, '');
			baseItem.add(anim);
			//platform component
			var platform:Platform = ObjectPool.get(Platform);
			platform.buildingVO = _tempBuildingVO;
			_tempBuildingVO = new BuildingVO();
			baseItem.add(platform);
			//assign the name
			baseItem.id = data.id;
			//set the building animation
			updateStarbaseBuilding(baseItem);
			//add to the game
			addEntity(baseItem);
			return baseItem;
		}

		public function createStarbasePlatform( starbaseOwnerID:String, blend:Boolean = false ):void
		{
			var level:int      = starbaseOwnerID == CurrentUser.id ? CurrentUser.level : _playerModel.getPlayer(starbaseOwnerID).level;
			var faction:String = starbaseOwnerID == CurrentUser.id ? CurrentUser.faction : _playerModel.getPlayer(starbaseOwnerID).faction;
			if (level >= 10 && !_game.getEntity("StarbaseBaseB"))
				createStarbaseExtension("StarbaseBaseB", "StarbaseBaseB", blend, faction);
			if (level >= 20 && !_game.getEntity("StarbaseBaseC"))
				createStarbaseExtension("StarbaseBaseC", "StarbaseBaseC", blend, faction);
			if (level >= 30 && !_game.getEntity("StarbaseBaseD"))
				createStarbaseExtension("StarbaseBaseD", "StarbaseBaseD", blend, faction);
			if (level >= 40 && !_game.getEntity("StarbaseBaseE"))
				createStarbaseExtension("StarbaseBaseE", "StarbaseBaseE", blend, faction);
			//create the corner
			if (!_cornerVO)
			{
				_cornerVO = new BuildingVO();
				_cornerVO.baseX = 268;
				_cornerVO.baseY = 274;
				_cornerVO.prototype = new PrototypeVO({itemClass:'', sizeX:5, sizeY:5});
			}
			if (!_game.getEntity("StarbaseCorner"))
				createStarbasePart('StarbaseCorner', 'Corner', _cornerVO, faction);
			//create the base
			if (!_starbaseVO)
			{
				_starbaseVO = new BuildingVO();
				_starbaseVO.baseX = 275;
				_starbaseVO.baseY = 275;
				_starbaseVO.prototype = new PrototypeVO({itemClass:'', sizeX:45, sizeY:45});
			}
			if (!_game.getEntity("StarbasePlatform"))
				createStarbasePart('StarbasePlatform', 'StarbaseBaseA', _starbaseVO, faction);
		}

		public function createForcefield( key:String, pylonA:Pylon, pylonB:Pylon, color:uint ):Entity
		{
			var baseX:int            = pylonA.baseX < pylonB.baseX ? pylonA.baseX : pylonB.baseX;
			if (pylonA.baseX != pylonB.baseX)
				baseX += 5;
			var baseY:int            = pylonA.baseY < pylonB.baseY ? pylonA.baseY : pylonB.baseY;
			if (pylonA.baseY != pylonB.baseY)
				baseY += 5;
			var dir:String           = (pylonA.baseX == pylonB.baseX) ? "Left" : "Right";
			var sizeX:int            = Math.abs(pylonA.baseX - pylonB.baseX) - 5;
			if (sizeX <= 0)
				sizeX = 5;
			var sizeY:int            = Math.abs(pylonA.baseY - pylonB.baseY) - 5;
			if (sizeY <= 0)
				sizeY = 5;

			var asset:AssetVO        = _assetModel.getEntityData(TypeEnum.FORCEFIELD);
			var building:Building;
			var detail:Detail;
			var field:Forcefield;
			var forcefield:Entity    = _game.getEntity(key);
			var pos:Position;
			var prototype:IPrototype = createforceFieldPrototype(sizeX, sizeY);
			if (forcefield)
			{
				building = forcefield.get(Building);
				building.buildingVO.baseX = baseX;
				building.buildingVO.baseY = baseY;
				building.buildingVO.prototype = prototype;
				detail = forcefield.get(Detail);
				detail.prototypeVO = prototype;
				pos = forcefield.get(Position);
				_starbaseModel.grid.convertBuildingGridToIso(pos.position, building.buildingVO);
				pos.dirty = true;
				field = Forcefield(FSM(forcefield.get(FSM)).component);
				field.adjustFieldLengths();
			} else
			{
				_tempBuildingVO.prototype = prototype;
				_tempBuildingVO.baseX = baseX;
				_tempBuildingVO.baseY = baseY;
				_tempBuildingVO.currentHealth = 100;
				forcefield = createEntity();
				// Add Detail component
				detail = ObjectPool.get(Detail);
				detail.init(CategoryEnum.BUILDING, asset, prototype);
				forcefield.add(detail);
				// Add Animation component
				var anim:Animation = ObjectPool.get(Animation);
				anim.init(asset.type, asset.spriteName + dir, true, 0, 30, true, 0, 51);
				anim.alpha = 0;
				forcefield.add(anim);
				// Add Position component
				pos = ObjectPool.get(Position);
				pos.init(0, 0, 0, LayerEnum.BUILDING);
				_starbaseModel.grid.convertBuildingGridToIso(pos.position, _tempBuildingVO);
				forcefield.add(pos);
				// Building component
				building = ObjectPool.get(Building);
				building.init(_tempBuildingVO);
				forcefield.add(building);
				// Add Grid component
				//forcefield.add(ObjectPool.get(Grid));
				// Add Forcefield component
				field = ObjectPool.get(Forcefield);
				field.animation = anim;
				field.color = color;
				field.building = _tempBuildingVO;
				// Add FSM component
				var fsm:FSM        = ObjectPool.get(FSM);
				fsm.init(field);
				forcefield.add(fsm);
				forcefield.id = key;
				// Add the thruster to the game
				_game.addEntity(forcefield);
				_tempBuildingVO = new BuildingVO();
				_soundController.playSound(AudioEnum.AFX_BARRIER_UP, 0.5);
			}
			return forcefield;
		}

		public function updateStarbaseBuilding( entity:Entity ):void
		{
			if (entity)
			{
				setBuildingAnimation(entity);
			}
		}

		public function createGridSquare( type:String, x:Number, y:Number ):Entity
		{
			var assetVO:AssetVO  = _assetModel.getEntityData(type);
			var isoSquare:Entity = createEntity();
			//detail component
			var detail:Detail    = ObjectPool.get(Detail);
			detail.init(CategoryEnum.STARBASE, assetVO);
			isoSquare.add(detail);
			//animation component
			var anim:Animation   = ObjectPool.get(Animation);
			anim.init(type, assetVO.spriteName, false);
			anim.color = 0xffff00;
			isoSquare.add(anim);
			//position component
			var newPos:Position  = ObjectPool.get(Position);
			newPos.init(x, y, 0, 6);
			isoSquare.add(newPos);
			//grid component
			isoSquare.add(ObjectPool.get(Grid));
			//assign the name
			isoSquare.id = x + type + y;
			//add to game
			addEntity(isoSquare);
			return isoSquare;
		}

		public function createBoundingLine( startX:int, startY:int, endX:int, endY:int ):Entity
		{
			var assetVO:AssetVO     = _assetModel.getEntityData(TypeEnum.DEBUG_LINE);
			if (!assetVO)
			{
				_assetModel.addGameAssetData(InteractEntityUtil.createPrototype(TypeEnum.DEBUG_LINE, 4, "DebugLine"));
				assetVO = _assetModel.getEntityData(TypeEnum.DEBUG_LINE);
			}

			var boundingLine:Entity = createEntity();
			// Add Detail component
			var detail:Detail       = ObjectPool.get(Detail);
			detail.init(assetVO.type, assetVO);
			boundingLine.add(detail);

			// Add Animation component
			var anim:Animation      = ObjectPool.get(Animation);
			anim.init(assetVO.type, assetVO.spriteName, false, 0, 30, true);
			var xDiff:Number        = (startX - endX) * (startX - endX);
			var yDiff:Number        = (startY - endY) * (startY - endY);
			anim.scaleX = Math.sqrt(xDiff + yDiff) / 64;
			anim.scaleY = 1;
			anim.color = AllegianceUtil.instance.getFactionColor(CurrentUser.faction);
			anim.allowTransform = true;
			anim.visible = true;
			boundingLine.add(anim);

			// Add Position component
			var position:Position   = ObjectPool.get(Position);
			position.init(startX, startY, 0, LayerEnum.RANGE);
			position.rotation = Math.atan2(endY - startY, endX - startX);
			boundingLine.add(position);

			boundingLine.id = startX + "." + startY + "." + endX + "." + endY;
			// Add the debug line to the game
			addEntity(boundingLine);
			return boundingLine;
		}

		public function destroyStarbaseItem( building:Entity ):void
		{
			if (!building)
				return;
			destroyEntity(building);
			ObjectPool.give(building.remove(Detail));
			ObjectPool.give(building.remove(Position));
			if (building.has(Grid))
				ObjectPool.give(building.remove(Grid));
			ObjectPool.give(building.remove(Animation));
			if (building.has(Interactable))
				ObjectPool.give(building.remove(Interactable));
			if (building.has(Building))
			{
				var b:Building = building.remove(Building);
				if (b.buildingVO.itemClass == TypeEnum.FORCEFIELD)
					_soundController.playSound(AudioEnum.AFX_BARRIER_DOWN, 0.5);
				ObjectPool.give(b);
			}
			if (building.has(Platform))
				ObjectPool.give(building.remove(Platform));
			if (building.has(VCList))
				ObjectPool.give(building.remove(VCList));
			if (building.has(State))
				ObjectPool.give(building.remove(State));
			if (building.has(Owned))
				ObjectPool.give(building.remove(Owned));
			if (building.has(Enemy))
				ObjectPool.give(building.remove(Enemy));
			if (building.has(Health))
				ObjectPool.give(building.remove(Health));
			if (building.has(Attack))
				ObjectPool.give(building.remove(Attack));
			if (building.has(Shield))
				ObjectPool.give(building.remove(Shield));
			if (building.has(Pylon))
			{
				var pylon:Pylon = building.remove(Pylon);
				destroyStarbaseItem(pylon.bottom);
				ObjectPool.give(pylon);
			}
			if (building.has(FSM))
				ObjectPool.give(building.remove(FSM));
		}
		public function setBaseFaction(faction:String):void
		{
			_baseFaction = faction;
		}

		private function createStarbasePart( id:String, label:String, vo:BuildingVO, faction:String = FactionEnum.IGA ):Entity
		{
			var type:String       = TypeEnum.STARBASE_IGA;
			if (faction != FactionEnum.IGA)
				type = (faction == FactionEnum.SOVEREIGNTY) ? TypeEnum.STARBASE_SOVEREIGNTY : TypeEnum.STARBASE_TYRANNAR;
			var baseItem:Entity   = createEntity();
			var assetVO:AssetVO   = _assetModel.getEntityData(type);
			//detail component
			var detail:Detail     = ObjectPool.get(Detail);
			detail.init(CategoryEnum.STARBASE, assetVO);
			baseItem.add(detail);
			//position component
			var pos:Position      = ObjectPool.get(Position);
			pos.init(2500, 2500, 1, LayerEnum.STARBSE_SECTOR);
			baseItem.add(pos);
			//grid component
			baseItem.add(ObjectPool.get(Grid));
			//animation component
			var anim:Animation    = ObjectPool.get(Animation);
			anim.init(type, label, false, 0, 30, true, 712, 303);
			baseItem.add(anim);
			//platform component
			var platform:Platform = ObjectPool.get(Platform);
			platform.buildingVO = vo;
			baseItem.add(platform);
			//assign the name
			baseItem.id = id;
			addEntity(baseItem);
			return baseItem;
		}

		private function createStarbaseExtension( id:String, label:String, blend:Boolean = false, faction:String = FactionEnum.IGA ):Entity
		{
			var type:String     = TypeEnum.STARBASE_IGA;
			if (faction != FactionEnum.IGA)
				type = (faction == FactionEnum.SOVEREIGNTY) ? TypeEnum.STARBASE_SOVEREIGNTY : TypeEnum.STARBASE_TYRANNAR;
			var baseItem:Entity = createEntity();
			var assetVO:AssetVO = _assetModel.getEntityData(type);
			//detail component
			var detail:Detail   = ObjectPool.get(Detail);
			detail.init(CategoryEnum.STARBASE, assetVO);
			baseItem.add(detail);
			//position component
			var pos:Position    = ObjectPool.get(Position);
			pos.init(2500, 2500, 1, LayerEnum.BACKGROUND);
			baseItem.add(pos);
			//grid component
			baseItem.add(ObjectPool.get(Grid));
			//animation component
			var anim:Animation  = ObjectPool.get(Animation);
			anim.init(type, label, false, 0, 30, true, 712, 303);
			baseItem.add(anim);
			if (blend)
			{
				anim.alpha = 0;
				TweenManual.to(anim, 3, {alpha:1});
			}
			//assign the name
			baseItem.id = id;
			addEntity(baseItem);
			return baseItem;
		}

		private function setBuildingAnimation( entity:Entity ):void
		{
			var animation:Animation = entity.get(Animation);
			var vo:BuildingVO       = (entity.has(Building)) ? Building(entity.get(Building)).buildingVO : Platform(entity.get(Platform)).buildingVO;
			
			/*var assetVO:AssetVO = null;
			
			if(entity.has(Building) && Building(entity.get(Building)).faction.length > 0)
			{
				var assetName:String 	   = vo.asset + '_' + FactionEnum.getFactionShort(Building(entity.get(Building)).faction);
				
				assetVO = _assetModel.getEntityData(assetName);
				
				if( assetVO == null)
					assetVO = _assetModel.getEntityData(vo.asset);
				else
					assetVO.type = vo.asset;
			}
			else
				assetVO  = _assetModel.getEntityData(vo.asset);
			*/
			/**/
			
			var faction:String =  CurrentUser.id == CurrentUser.id ? CurrentUser.faction : _playerModel.getPlayer(CurrentUser.id).faction;
			
			var assetVO:AssetVO  = _assetModel.getEntityData(vo.asset);
			/*if(assetVO.spriteSheetsString == "Buildings")
			{
				if(assetVO.spriteXML.length > 0)
				{
					//entity.get(Building)).faction
					assetVO.sprites[0] = 'sprite/Buildings_' + + FactionEnum.getFactionShort(faction) + '.png';
					assetVO.spriteXML[0] = 'sprite/Buildings_' + + FactionEnum.getFactionShort(faction) + '.xml';
				}
			} 
			if(assetVO.spriteSheetsString == "BaseWeaponsA")
			{
				if(assetVO.spriteXML.length > 0)
				{
					assetVO.sprites[0] = 'sprite/BaseWeaponsA_' + FactionEnum.getFactionShort(faction) + '.png';
					assetVO.spriteXML[0] = 'sprite/BaseWeaponsA_' + FactionEnum.getFactionShort(faction) + '.xml';
				}
			}
			//*/
			
			var vcList:VCList       = entity.get(VCList);
			var level:int           = CommonFunctionUtil.getBuildingVisualLevel(vo.level);

			//set the correct animation ie. normal, damaged, constructing etc.
			switch (vo.itemClass)
			{
				case TypeEnum.COMMAND_CENTER:
				case TypeEnum.CONSTRUCTION_BAY:
				case TypeEnum.DOCK:
				case TypeEnum.DEFENSE_DESIGN:
				case TypeEnum.ADVANCED_TECH:
				case TypeEnum.SHIPYARD:
				case TypeEnum.REACTOR_STATION:
				case TypeEnum.ACADEMY:
				case TypeEnum.OFFICERS_LOUNGE:
				case TypeEnum.WEAPONS_FACILITY:
				case TypeEnum.SURVEILLANCE:
				case TypeEnum.SHIELD_GENERATOR:
					if (vo.currentHealth == 0)
					{
						if (animation.type != TypeEnum.BUILDINGS_DAMAGED)
							animation.type = TypeEnum.BUILDINGS_DAMAGED;
						animation.label = assetVO.spriteName + "Destroyed" + level;
						vo.damaged = vo.destroyed = true;
					} else if (vo.currentHealth < StarbaseSystem.BUILDING_DAMAGED_HEALTH)
					{
						if (animation.type != TypeEnum.BUILDINGS_DAMAGED)
							animation.type = TypeEnum.BUILDINGS_DAMAGED;
						animation.label = assetVO.spriteName + "Damaged" + level;
						vo.destroyed = false;
						vo.damaged = true;
					} else
					{
						if (animation.type != vo.itemClass)
							animation.type = vo.itemClass;
						animation.label = assetVO.spriteName + level;
						vo.damaged = vo.destroyed = false;
					}

					//add the building animation
					if (assetVO.type == TypeEnum.REACTOR_STATION || assetVO.type == TypeEnum.SHIELD_GENERATOR || assetVO.type == TypeEnum.SURVEILLANCE)
					{
						(vo.currentHealth > 0) ? vcList.addComponentType(TypeEnum.BUILDING_ANIMATION) : vcList.removeComponentType(TypeEnum.BUILDING_ANIMATION);
					}
					break;
				case TypeEnum.PYLON:
					var pylon:Pylon   = entity.get(Pylon);
					var bottom:Entity = pylon.bottom;
					if (vo.currentHealth == 0)
					{
						//pylon
						animation.alpha = 0;
						if (animation.type != TypeEnum.BUILDINGS_DAMAGED)
							animation.type = TypeEnum.BUILDINGS_DAMAGED;
						animation.label = assetVO.spriteName + "Damaged" + level;
						//pylon base
						animation = bottom.get(Animation);
						animation.label = "BarrierDestroyed" + level;
						vo.damaged = vo.destroyed = true;
					} else if (vo.currentHealth < StarbaseSystem.BUILDING_DAMAGED_HEALTH)
					{
						if (animation.type != TypeEnum.BUILDINGS_DAMAGED)
							animation.type = TypeEnum.BUILDINGS_DAMAGED;
						animation.label = assetVO.spriteName + "Damaged" + level;
						animation.alpha = 1;
						vo.destroyed = false;
						vo.damaged = true;
						//pylon base
						assetVO = Detail(bottom.get(Detail)).assetVO;
						animation = bottom.get(Animation);
						animation.label = assetVO.spriteName + "Damaged" + level;
						vcList.addComponentType(TypeEnum.BUILDING_ANIMATION);
					} else
					{
						if (animation.type != vo.itemClass)
							animation.type = vo.itemClass;
						animation.alpha = 1;
						animation.label = assetVO.spriteName + level;
						vo.damaged = vo.destroyed = false;
						//pylon base
						assetVO = Detail(bottom.get(Detail)).assetVO;
						animation = bottom.get(Animation);
						animation.label = assetVO.spriteName + level;
						vcList.addComponentType(TypeEnum.BUILDING_ANIMATION);
					}
					break;
				case TypeEnum.RESOURCE_DEPOT:
				case TypeEnum.POINT_DEFENSE_PLATFORM:
					if (vo.currentHealth == 0)
					{
						if (animation.type != TypeEnum.BUILDINGS_DAMAGED)
							animation.type = TypeEnum.BUILDINGS_DAMAGED;
						animation.label = assetVO.spriteName + "Destroyed";
						vo.damaged = vo.destroyed = true;
					} else if (vo.currentHealth < StarbaseSystem.BUILDING_DAMAGED_HEALTH)
					{
						if (animation.type != TypeEnum.BUILDINGS_DAMAGED)
							animation.type = TypeEnum.BUILDINGS_DAMAGED;
						animation.label = assetVO.spriteName + "Damaged";
						vo.destroyed = false;
						vo.damaged = true;
					} else
					{
						if (animation.type != vo.itemClass)
							animation.type = vo.itemClass;
						animation.label = assetVO.spriteName;
						vo.damaged = vo.destroyed = false;
					}
					//add the turret animation
					if (assetVO.type == TypeEnum.POINT_DEFENSE_PLATFORM)
					{
						(vo.currentHealth > 0) ? vcList.addComponentType(TypeEnum.STARBASE_TURRET) : vcList.removeComponentType(TypeEnum.STARBASE_TURRET);
					}
					//add/remove canisters from resource depots
					if (assetVO.type == TypeEnum.RESOURCE_DEPOT)
						(vo.currentHealth > 0) ? vcList.addComponentType(TypeEnum.RESOURCE_DEPOT_CANISTER) : vcList.removeComponentType(TypeEnum.RESOURCE_DEPOT_CANISTER);
					break;
				case TypeEnum.STARBASE_WALL:
					animation.label = assetVO.type;
					animation.offsetX = 66.625;
					animation.offsetY = 32.825;
					break;
				case TypeEnum.STARBASE_ARM:
					animation.label = assetVO.type;
					animation.offsetX = 66.625;
					animation.offsetY = 32.825;
					break;
				case TypeEnum.STARBASE_PLATFORMA:
					animation.label = assetVO.type;
					animation.offsetX = 194;
					animation.offsetY = 97.5;
					break;
				case TypeEnum.STARBASE_PLATFORMB:
					animation.label = assetVO.type;
					animation.offsetX = 194;
					animation.offsetY = 97.5;
					break;
				default:
					_point.setTo(0, 0);
					break;
			}
			//remove the shield if the building is destroyed
			if (vcList && vo.currentHealth == 0)
			{
				vcList.removeComponentType(TypeEnum.BUILDING_SHIELD);
				vcList.removeComponentType(TypeEnum.TURRET_SHIELD);
				if (vcList.hasComponentType(TypeEnum.HEALTH_BAR))
					vcList.removeComponentType(TypeEnum.HEALTH_BAR);
			}
		}

		private function createPylonPlatform( vo:BuildingVO, position:Position):Entity
		{
			var assetVO:AssetVO       = getBaseItemAssetVO(vo.prototype);
			var baseItem:Entity       = createEntity();
			//detail component
			var detail:Detail         = ObjectPool.get(Detail);
			detail.init(CategoryEnum.STARBASE, assetVO);
			baseItem.add(detail);
			//position component
			var pos:Position          = ObjectPool.get(Position);
			pos.init(position.x, position.y, 1, LayerEnum.STARBSE_SECTOR);
			baseItem.add(pos);
			//grid component
			baseItem.add(ObjectPool.get(Grid));
			//animation component
			var anim:Animation        = ObjectPool.get(Animation);
			anim.init(assetVO.type, '', true);
			baseItem.add(anim);
			//platform component
			var buildingVO:BuildingVO = ObjectPool.get(BuildingVO);
			buildingVO.prototype = vo.prototype;
			buildingVO.baseX = vo.baseX;
			buildingVO.baseY = vo.baseY;
			var platform:Platform     = ObjectPool.get(Platform);
			platform.buildingVO = buildingVO;
			baseItem.add(platform);
			//assign the name
			baseItem.id = vo.id + "Base";
			//add to the game
			addEntity(baseItem);
			return baseItem;
		}

		private function getBaseItemAssetVO( prototype:IPrototype ):AssetVO
		{
			var type:String = '';
			switch (prototype.itemClass)
			{
				case TypeEnum.PYLON:
					type = TypeEnum.PYLON_BASE_IGA;
					if (baseFaction != FactionEnum.IGA)
						type = (baseFaction == FactionEnum.SOVEREIGNTY) ? TypeEnum.PYLON_BASE_SOVEREIGNTY : TypeEnum.PYLON_BASE_TYRANNAR;
					break;
				case TypeEnum.STARBASE_ARM:
					type = TypeEnum.STARBASE_ARM_IGA;
					if (baseFaction != FactionEnum.IGA)
						type = (baseFaction == FactionEnum.SOVEREIGNTY) ? TypeEnum.STARBASE_ARM_SOVEREIGNTY : TypeEnum.STARBASE_ARM_TYRANNAR;
					break;
				case TypeEnum.STARBASE_PLATFORMA:
					type = TypeEnum.STARBASE_PLATFORMA_IGA;
					if (baseFaction != FactionEnum.IGA)
						type = (baseFaction == FactionEnum.SOVEREIGNTY) ? TypeEnum.STARBASE_PLATFORMA_SOVEREIGNTY : TypeEnum.STARBASE_PLATFORMA_TYRANNAR;
					break;
				case TypeEnum.STARBASE_PLATFORMB:
					type = TypeEnum.STARBASE_PLATFORMB_IGA;
					if (baseFaction != FactionEnum.IGA)
						type = (baseFaction == FactionEnum.SOVEREIGNTY) ? TypeEnum.STARBASE_PLATFORMB_SOVEREIGNTY : TypeEnum.STARBASE_PLATFORMB_TYRANNAR;
					break;
			}
			return _assetModel.getEntityData(type);
		}

		private function createforceFieldPrototype( sizeX:int, sizeY:int ):IPrototype
		{
			return new PrototypeVO({
									   "key":"Forcefield",
									   "asset":"Forcefield",
									   "uiAsset":"Forcefield",
									   "sizeX":sizeX,
									   "sizeY":sizeY,
									   "health":50000,
									   "itemClass":"Forcefield"});
		}

		private function get baseFaction():String
		{
			switch (Application.STATE)
			{
				case StateEvent.GAME_BATTLE_INIT:
				case StateEvent.GAME_BATTLE:
				case StateEvent.GAME_SECTOR_INIT:
				case StateEvent.GAME_SECTOR:
					return _baseFaction;
					//return _sectorModel.sectorFaction;
			}
			return CurrentUser.faction;
		}

		[Inject]
		public function set battleModel( v:BattleModel ):void  { _battleModel = v; }
		[Inject]
		public function set playerModel( v:PlayerModel ):void  { _playerModel = v; }
		[Inject]
		public function set sectorModel( v:SectorModel ):void  { _sectorModel = v; }
		[Inject]
		public function set starbaseModel( v:StarbaseModel ):void  { _starbaseModel = v; }
		[Inject]
		public function set transactionController( v:TransactionController ):void  { _transactionController = v; }
	}
}
