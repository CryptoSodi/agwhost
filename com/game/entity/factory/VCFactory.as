package com.game.entity.factory
{
	import com.Application;
	import com.enum.CategoryEnum;
	import com.enum.FactionEnum;
	import com.enum.LayerEnum;
	import com.enum.TypeEnum;
	import com.event.StateEvent;
	import com.game.entity.components.battle.DebuffTray;
	import com.game.entity.components.battle.Health;
	import com.game.entity.components.battle.Shield;
	import com.game.entity.components.shared.Animation;
	import com.game.entity.components.shared.Detail;
	import com.game.entity.components.shared.IRender;
	import com.game.entity.components.shared.Position;
	import com.game.entity.components.shared.Pylon;
	import com.game.entity.components.shared.fsm.FSM;
	import com.game.entity.components.shared.fsm.TurretFSM;
	import com.game.entity.components.shared.render.Render;
	import com.game.entity.components.shared.render.RenderSprite;
	import com.game.entity.components.shared.render.RenderSpriteStarling;
	import com.game.entity.components.shared.render.RenderStarling;
	import com.game.entity.components.shared.render.VisualComponent;
	import com.game.entity.components.starbase.Building;
	import com.game.entity.components.starbase.Construction;
	import com.game.entity.components.starbase.State;
	import com.game.entity.systems.starbase.StarbaseSystem;
	import com.model.asset.AssetVO;
	import com.model.player.PlayerModel;
	import com.model.player.PlayerVO;
	import com.model.prototype.IPrototype;
	import com.model.sector.SectorModel;
	import com.model.starbase.BuildingVO;
	import com.util.AllegianceUtil;
	import com.util.CommonFunctionUtil;

	import flash.display.BlendMode;
	import flash.geom.Point;

	import org.ash.core.Entity;
	import org.shared.ObjectPool;

	public class VCFactory extends BaseFactory implements IVCFactory
	{
		//values for sector name tags (TODO: better spot for this stuff?)
		public static const FONT_COLOR:uint      = 0xffffff;
		public static const FONT_SIZE:int        = 14;
		public static const TEXT_WIDTH:int       = 462;
		public static const TEXT_HEIGHT:int      = 60;
		public static const TEXT_WIDTH_HALF:int  = int(TEXT_WIDTH / 2);
		public static const TEXT_HEIGHT_HALF:int = int(TEXT_HEIGHT / 2);

		private static const DEPOTX:Array        = [175, 155, 124, 93, 74, 74, 93, 124, 155, 175];
		private static const DEPOTY:Array        = [127, 141, 145, 141, 127, 111, 97, 92, 97, 111];

		private var _id:int                      = 0;
		private var _point:Point                 = new Point();
		private var _sectorModel:SectorModel;
		private var _playerModel:PlayerModel;

		public function createBuildingAnimation( buildingVO:BuildingVO, entity:Entity ):Entity
		{
			var assetVO:AssetVO          = _assetModel.getEntityData(TypeEnum.BUILDING_ANIMATION);
			var buildingAnimation:Entity = createEntity();
			//detail component
			var detail:Detail            = ObjectPool.get(Detail);
			detail.init(CategoryEnum.VFX, assetVO);
			buildingAnimation.add(detail);
			//animation component
			var anim:Animation           = ObjectPool.get(Animation);
			buildingAnimation.add(anim);
			var render:IRender           = createAndAddRender(buildingAnimation, entity, 0, 0, 1, true);
			var level:int                = CommonFunctionUtil.getBuildingVisualLevel(buildingVO.level);
			//if constructing is true then we want to show the construction animation
			switch (buildingVO.asset)
			{
				case TypeEnum.PYLON:
					anim.init(assetVO.type, 'BarrierGlow' + level, true, 0, 25, true);
					render.x = render.y = 152;
					anim.color = render.color = Pylon(entity.get(Pylon)).color;
					break;
				case TypeEnum.REACTOR_STATION:
					anim.init(assetVO.type, 'Turbine' + level, true, 0, 25, true);
					render.x = render.y = 125;
					break;
				case TypeEnum.SHIELD_GENERATOR:
					anim.init(assetVO.type, 'Electric' + level, true, 0, 10, true);
					render.x = render.y = 100;
					break;
				case TypeEnum.SURVEILLANCE:
					anim.init(assetVO.type, 'Dish5', false, 0, 12, true);
					anim.scaleX = anim.scaleY = .5 + level * .1;
					if (level < 5)
					{
						anim.scaleX -= .1;
						anim.scaleY -= .1;
					}
					render.scaleX = anim.scaleX;
					render.scaleY = anim.scaleX;
					IRender(render).x = IRender(render).y = 125 - (125 * anim.scaleY);
					anim.allowTransform = true;
					break;
			}
			//visual component
			var vc:VisualComponent       = ObjectPool.get(VisualComponent);
			vc.init(entity);
			buildingAnimation.add(vc);
			//assign the name
			buildingAnimation.id = id;
			addEntity(buildingAnimation);
			return buildingAnimation;
		}

		/**
		 * Creates a construction animation that appears above a building
		 * To create this animation, we need to actually make three entities.
		 * 1 is the beam of light, 2 is the "mothership", 3 is the glow on the mothership
		 * @param buildingVO The buildingVO that we are constructing
		 * @param entity The entity that we are placing this animation on
		 * @return Our newly created construction entity
		 */
		public function createBuildingConstruction( buildingVO:BuildingVO, entity:Entity ):Entity
		{
			var parentBuilding:Building   = entity.get(Building);
			//components
			var animation:Animation;
			var assetVO:AssetVO           = _assetModel.getEntityData(TypeEnum.BUILDING_CONSTRUCTION);
			var detail:Detail;
			var position:Position;
			var render:IRender;
			var visualComponent:VisualComponent;

			//create the beam of light
			var beam:Entity               = createEntity();
			detail = ObjectPool.get(Detail);
			detail.init(CategoryEnum.VFX, assetVO);
			beam.add(detail);
			animation = ObjectPool.get(Animation);
			animation.init(assetVO.type, 'ConstructBeam0', false, 0, 30, true);
			animation.alpha = 0;
			beam.add(animation);
			beam.id = id;

			//create the second beam of light
			var beam2:Entity              = createEntity();
			detail = ObjectPool.get(Detail);
			detail.init(CategoryEnum.VFX, assetVO);
			beam2.add(detail);
			animation = ObjectPool.get(Animation);
			animation.init(assetVO.type, 'ConstructBeam1', false, 0, 30, true);
			animation.alpha = 0;
			beam2.add(animation);
			beam2.id = id;

			//create the glow
			var glow:Entity               = createEntity();
			detail = ObjectPool.get(Detail);
			detail.init(CategoryEnum.VFX, assetVO);
			glow.add(detail);
			animation = ObjectPool.get(Animation);
			animation.init(assetVO.type, 'ConstructGlow', false, 0, 30, true);
			animation.alpha = 0;
			glow.add(animation);
			glow.id = id;

			//create the "mothership"
			var mothership:Entity         = createEntity();
			detail = ObjectPool.get(Detail);
			detail.init(CategoryEnum.VFX, assetVO);
			mothership.add(detail);
			animation = ObjectPool.get(Animation);
			animation.init(assetVO.type, assetVO.spriteName, false, 0, 30, true);
			animation.alpha = 0;
			mothership.add(animation);
			var construction:Construction = ObjectPool.get(Construction);
			construction.beam = beam;
			construction.beam2 = beam2;
			construction.glow = glow;
			construction.mothership = mothership;
			construction.owner = entity;

			visualComponent = ObjectPool.get(VisualComponent);
			visualComponent.init(entity);
			mothership.add(visualComponent);
			mothership.id = id;

			//fsm
			var fsm:FSM                   = ObjectPool.get(FSM);
			fsm.init(construction);
			mothership.add(fsm);

			//lots of hardcoded numbers. YAYAYAYAYAY!!
			var scale:Number              = (buildingVO.sizeX == 15) ? 1 : (buildingVO.sizeY == 10) ? .73 : (parentBuilding.buildingVO.itemClass == TypeEnum.PYLON) ? .62 : .45;
			var size:Number               = (buildingVO.sizeX == 15) ? 400 : (buildingVO.sizeY == 10) ? 250 : (parentBuilding.buildingVO.itemClass == TypeEnum.PYLON) ? 300 : 200;
			var x:Number                  = (size - (258 * scale)) / 2;
			construction.ypos = (buildingVO.sizeX == 15) ? 0 : (buildingVO.sizeY == 10) ? -25 : (parentBuilding.buildingVO.itemClass == TypeEnum.PYLON) ? 15 : 0;

			var state:State               = entity.get(State);
			if (state && state.transaction)
			{
				if (state.transaction.timeMS - state.transaction.timeRemainingMS >= 500)
					construction.state = Construction.RESTABILIZE;
			}

			render = createAndAddRender(beam, entity, x, construction.ypos);
			render.scaleX = scale;
			render.scaleY = .5;
			render.alpha = 0;
			render = createAndAddRender(beam2, entity, x, construction.ypos);
			render.scaleX = scale;
			render.scaleY = .5;
			render.alpha = 0;
			construction.beamScaleY = 1 * scale;
			render = createAndAddRender(mothership, entity, x, construction.ypos);
			render.scaleX = render.scaleY = scale;
			render.alpha = 0;
			render = createAndAddRender(glow, entity, x, construction.ypos);
			render.scaleX = render.scaleY = scale;
			render.alpha = 0;
			render.alpha = 0;

			addEntity(beam);
			addEntity(beam2);
			addEntity(glow);
			addEntity(mothership);
			return mothership;
		}

		public function createHealthBar( entity:Entity ):Entity
		{
			var assetVO:AssetVO        = _assetModel.getEntityData(TypeEnum.HEALTH_BAR);
			var currentHealth:Health   = entity.get(Health);
			var health:Entity          = createEntity();
			//detail component
			var detail:Detail          = ObjectPool.get(Detail);
			detail.init(CategoryEnum.VFX, assetVO);
			health.add(detail);
			//animation component
			var anim:Animation         = ObjectPool.get(Animation);
			anim.init(TypeEnum.HEALTH_BAR, assetVO.spriteName, true, 0, 30, true, 0, 40);
			anim.allowTransform = true;
			health.add(anim);
			//health component
			var healthComponent:Health = entity.get(Health);
			healthComponent.animation = anim;
			health.add(healthComponent);
			anim.scaleX = healthComponent.percent;
			//position component
			var oldPos:Position        = Position(entity.get(Position));
			var newPos:Position        = oldPos.clone();
			newPos.layer = LayerEnum.VFX;
			newPos.ignoreRotation = true;
			oldPos.addLink(newPos);
			health.add(newPos);
			//visual component
			var vc:VisualComponent     = ObjectPool.get(VisualComponent);
			vc.init(entity);
			health.add(vc);
			//assign the name
			health.id = id;
			//add to game
			addEntity(health);
			return health;
		}

		public function createIsoSquare( entity:Entity, type:String ):Entity
		{
			var assetVO:AssetVO    = _assetModel.getEntityData(type);
			var isoSquare:Entity   = createEntity();
			//detail component
			var detail:Detail      = ObjectPool.get(Detail);
			detail.init(CategoryEnum.STARBASE, assetVO);
			isoSquare.add(detail);
			//animation component
			var anim:Animation     = ObjectPool.get(Animation);
			anim.init(type, assetVO.spriteName, true, 0, 30, true);
			anim.color = 0xffff00;
			isoSquare.add(anim);
			//position component
			var oldPos:Position    = Position(entity.get(Position));
			var newPos:Position    = oldPos.clone();
			newPos.layer = LayerEnum.MISC;
			oldPos.addLink(newPos);
			isoSquare.add(newPos);
			//visual component
			var vc:VisualComponent = ObjectPool.get(VisualComponent);
			vc.init(entity);
			isoSquare.add(vc);
			//assign the name
			isoSquare.id = id;
			//add to game
			addEntity(isoSquare);
			return isoSquare;
		}

		public function createStateBar( entity:Entity, text:String ):Entity
		{
			var assetVO:AssetVO    = _assetModel.getEntityData(TypeEnum.STATE_BAR);
			var state:Entity       = createEntity();
			//detail component
			var detail:Detail      = ObjectPool.get(Detail);
			detail.init(CategoryEnum.VFX, assetVO);
			state.add(detail);
			//animation component
			var anim:Animation     = ObjectPool.get(Animation);
			anim.init(TypeEnum.STATE_BAR, assetVO.spriteName, true, 0, 30, true, 0, 40);
			anim.allowTransform = true;
			anim.text = text;
			state.add(anim);
			//add to the entities state component
			var stateC:State       = entity.get(State);
			stateC.component = state;
			//position component
			var oldPos:Position    = Position(entity.get(Position));
			var newPos:Position    = oldPos.clone();
			newPos.layer = LayerEnum.VFX;
			oldPos.addLink(newPos);
			state.add(newPos);
			//visual component
			var vc:VisualComponent = ObjectPool.get(VisualComponent);
			vc.init(entity);
			state.add(vc);
			//assign the name
			state.id = id;
			//add to game
			addEntity(state);
			return state;
		}

		public function createBuildingShield( buildingVO:BuildingVO, entity:Entity ):Entity
		{
			var shield:Entity              = createEntity();
			var faction:String             = _sectorModel.sectorFaction;
			var buildingDetail:Detail      = entity.get(Detail);
			if (buildingDetail)
				var buildingOwner:PlayerVO = _playerModel.getPlayer(buildingDetail.ownerID);

			if (buildingOwner)
				faction = buildingOwner.faction;

			//detail component
			var assetVO:AssetVO            = (buildingVO.prototype.itemClass != TypeEnum.POINT_DEFENSE_PLATFORM) ?
				_assetModel.getEntityData(TypeEnum.BUILDING_SHIELD) :
				_assetModel.getEntityData(TypeEnum.TURRET_SHIELD);
			var detail:Detail              = ObjectPool.get(Detail);
			detail.init(CategoryEnum.VFX, assetVO);
			shield.add(detail);
			//animation component
			var anim:Animation             = ObjectPool.get(Animation);
			var shieldName:String          = (buildingVO.sizeX == 5) ? "BuildingShieldSmall" : ((buildingVO.sizeX == 10) ? "BuildingShieldMedium" : "BuildingShieldLarge");
			anim.init(assetVO.type, shieldName, true, 0, 30, true);
			anim.playing = anim.replay = false;
			anim.alpha = .5;

			if (faction == FactionEnum.IMPERIUM)
				anim.color = 0x00ff00;
			if (faction == FactionEnum.IGA)
				anim.color = 0x6bd7ff;
			else if (faction == FactionEnum.SOVEREIGNTY)
				anim.color = 0xc96bff;
			else
				anim.color = 0xff7d4f;
			shield.add(anim);
			//position component
			var oldPos:Position            = Position(entity.get(Position));
			var newPos:Position            = oldPos.clone();
			newPos.layer = LayerEnum.BUILDING;
			newPos.depth = oldPos.depth + 1;
			oldPos.addLink(newPos);
			shield.add(newPos);
			//visual component
			var vc:VisualComponent         = ObjectPool.get(VisualComponent);
			vc.init(entity);
			shield.add(vc);
			//assign the name
			shield.id = id;
			addEntity(shield);
			return shield;
		}

		public function createShield( entity:Entity ):Entity
		{
			var assetVO:AssetVO     = _assetModel.getEntityData(TypeEnum.SHIELD);
			var shield:Entity       = createEntity();

			//detail component
			var shipDetail:Detail   = entity.get(Detail);
			var faction:String      = shipDetail.prototypeVO.getValue('faction');
			var detail:Detail       = ObjectPool.get(Detail);
			detail.init(CategoryEnum.VFX, assetVO);
			shield.add(detail);
			//position component
			var oldPos:Position     = Position(entity.get(Position));
			var newPos:Position     = oldPos.clone();
			newPos.layer = LayerEnum.SHIELD;
			oldPos.addLink(newPos);
			shield.add(newPos);
			//Scaling
			var shipAssetVO:AssetVO = _assetModel.getEntityData(shipDetail.prototypeVO.asset);
			//animation component
			var anim:Animation      = ObjectPool.get(Animation);
			anim.init(TypeEnum.SHIELD, assetVO.spriteName, true, 0, 30, true);
			anim.playing = anim.replay = false;
			if (faction == FactionEnum.IGA)
				anim.color = 0x5263F6;
			else if (faction == FactionEnum.SOVEREIGNTY)
				anim.color = 0x9652F6;
			else if (faction == FactionEnum.TYRANNAR)
				anim.color = 0xFF4500;
			else
				anim.color = 0x00ff00;
			anim.blendMode = BlendMode.ADD;
			anim.scaleX = anim.scaleY = shipAssetVO.shieldScale;
			anim.allowTransform = true;
			shield.add(anim);
			//visual component
			var vc:VisualComponent  = ObjectPool.get(VisualComponent);
			vc.init(entity);
			shield.add(vc);
			//add the shield
			var shieldC:Shield      = entity.get(Shield);
			shieldC.animation = anim;
			shield.add(shieldC);
			//assign the name
			shield.id = id;
			//add to game
			addEntity(shield);
			return shield;
		}

		public function createStarbaseShield( entity:Entity ):Entity
		{
			var entityDetail:Detail   = entity.get(Detail);
			var type:String           = _sectorModel.starbaseShieldAsset;
			var assetVO:AssetVO       = _assetModel.getEntityData(type);
			var starbaseShield:Entity = createEntity();
			//detail component
			var detail:Detail         = ObjectPool.get(Detail);
			detail.init(CategoryEnum.VFX, assetVO);
			starbaseShield.add(detail);
			//position component
			var oldPos:Position       = Position(entity.get(Position));
			var newPos:Position       = oldPos.clone();
			newPos.layer = LayerEnum.RANGE;
			newPos.rotation = 0;
			newPos.dirty = false;
			oldPos.addLink(newPos);
			starbaseShield.add(newPos);
			//animation component
			var anim:Animation        = ObjectPool.get(Animation);
			anim.init(type, assetVO.spriteName, true, 0, 30, true);
			//anim.color = AllegianceUtil.instance.getFactionColor(_sectorModel.sectorFaction);
			anim.blendMode = BlendMode.ADD;
			switch (entityDetail.level)
			{
				case 1:
				case 2:
					anim.offsetX = 3;
					anim.offsetY = 4;
					anim.scaleX = .8;
					anim.scaleY = .6;
					break;
				case 3:
					anim.offsetX = 3;
					anim.offsetY = -4;
					anim.scaleX = .8;
					anim.scaleY = .6;
					break;
				case 4:
					anim.offsetX = 3;
					anim.offsetY = -23;
					anim.scaleX = .8;
					anim.scaleY = .7;
					break;
				case 5:
					anim.offsetX = 2;
					anim.offsetY = -32;
					anim.scaleX = .9;
					anim.scaleY = .9;
					break;
			}
			anim.allowTransform = true;
			starbaseShield.add(anim);
			//visual component
			var vc:VisualComponent    = ObjectPool.get(VisualComponent);
			vc.init(entity);
			starbaseShield.add(vc);
			//assign the name
			starbaseShield.id = id;
			//add to game
			addEntity(starbaseShield);
			return starbaseShield;
		}

		public function createName( entity:Entity, name:String ):Entity
		{
			var assetVO:AssetVO    = _assetModel.getEntityData(TypeEnum.NAME);
			var text:Entity        = createEntity();
			//detail component
			var detail:Detail      = ObjectPool.get(Detail);
			detail.init(CategoryEnum.VFX, assetVO, null, Detail(entity.get(Detail)).ownerID);
			text.add(detail);
			//position component
			var oldPos:Position    = Position(entity.get(Position));
			var newPos:Position    = oldPos.clone();
			newPos.layer = LayerEnum.TEXT;
			oldPos.addLink(newPos);
			text.add(newPos);
			//animation component
			var anim:Animation     = ObjectPool.get(Animation);
			anim.init(TypeEnum.NAME, '', true, 0, 30, true, TEXT_WIDTH_HALF, TEXT_HEIGHT_HALF);
			anim.playing = anim.replay = false;
			anim.text = name;
			anim.color = AllegianceUtil.instance.getEntityColor(entity);
			anim.forceReady();
			text.add(anim);
			//visual component
			var vc:VisualComponent = ObjectPool.get(VisualComponent);
			vc.init(entity);
			text.add(vc);
			//assign the name
			text.id = id;
			//add to game
			addEntity(text);
			return text;
		}

		public function createTurret( buildingVO:BuildingVO, entity:Entity ):Entity
		{
			//TODO: Not a problem at the moment since all turrets only have one slot but may need to extend this in the future to handle multiple slots
			var slot:String        = buildingVO.getValue("slots")[0];
			var module:IPrototype  = (buildingVO.modules.hasOwnProperty(slot)) ? buildingVO.modules[slot] : null;
			if (module == null)
				return null;
			var turret:Entity      = createEntity();
			//detail component
			var assetVO:AssetVO    = _assetModel.getEntityData(TypeEnum.STARBASE_TURRET);
			var detail:Detail      = ObjectPool.get(Detail);
			detail.init(CategoryEnum.VFX, assetVO);
			turret.add(detail);
			//animation component
			var anim:Animation     = ObjectPool.get(Animation);
			var level:int          = module.getValue('level');
			if (level > 5)
				level = 5;

			switch (module.asset)
			{
				case TypeEnum.TURRET_BEAM_POINT_DEFENSE_CLUSTER:
					anim.init(TypeEnum.STARBASE_TURRET, 'CC' + level, true, 0, 30, true);
					_point.setTo(104, 29);
					break;
				case TypeEnum.TURRET_DRONE:
					anim.init(TypeEnum.STARBASE_TURRET, 'DB' + level, true, 0, 30, true);
					_point.setTo(106, 32);
					break;
				case TypeEnum.TURRET_BOMBARDMENT_CANNON:
					anim.init(TypeEnum.STARBASE_TURRET, 'BC' + level, true, 0, 30, true);
					_point.setTo(108, 34);
					break;
				case TypeEnum.TURRET_SENTINEL_MOUNT:
					anim.init(TypeEnum.STARBASE_TURRET, 'SC' + level, true, 0, 30, true);
					_point.setTo(104, 31);
					break;
				case TypeEnum.TURRET_MISSILE_POD:
					anim.init(TypeEnum.STARBASE_TURRET, 'MP' + level, true, 0, 30, true);
					_point.setTo(108, 29);
					break;
			}
			anim.playing = anim.replay = false;
			turret.add(anim);
			//add the turret animation into the turret finite state machine
			if (Application.STATE == StateEvent.GAME_STARBASE)
				TurretFSM(FSM(entity.get(FSM)).component).animation = anim;
			//add the render
			createAndAddRender(turret, entity, _point.x, _point.y, 1, true);
			//visual component
			var vc:VisualComponent = ObjectPool.get(VisualComponent);
			vc.init(entity);
			turret.add(vc);
			//assign the name
			turret.id = id;
			addEntity(turret);
			return turret;
		}

		public function createDepotCannisters( entity:Entity, index:int = 0 ):Entity
		{
			var assetVO:AssetVO       = _assetModel.getEntityData(TypeEnum.RESOURCE_DEPOT_CANISTER);
			var building:Building     = entity.get(Building);
			var system:StarbaseSystem = StarbaseSystem(_game.getSystem(StarbaseSystem));
			var percent:Number        = (building.buildingVO.percentFilled > 0) ? building.buildingVO.percentFilled * 100 : 0;

			var cannisters:Entity     = createEntity();
			//detail component
			var detail:Detail         = ObjectPool.get(Detail);
			detail.init(CategoryEnum.VFX, assetVO);
			cannisters.add(detail);
			//animation component
			var anim:Animation        = ObjectPool.get(Animation);
			anim.init(assetVO.type, assetVO.spriteName + "_" + percent, false, 0, 30, true);
			cannisters.add(anim);
			createAndAddRender(cannisters, entity, DEPOTX[index] - 12, DEPOTY[index] - 42, 1, true);
			//visual component
			var vc:VisualComponent    = ObjectPool.get(VisualComponent);
			vc.init(entity);
			cannisters.add(vc);
			if (index <= 9)
				vc.addChild(createDepotCannisters(entity, index + 1));
			//assign the name
			cannisters.id = id;
			addEntity(cannisters);
			return cannisters;
		}

		private function createAndAddRender( entity:Entity, target:Entity, x:Number = 0, y:Number = 0, depth:int = -1, takeParentsColor:Boolean = false ):IRender
		{
			//get the animation component of the building
			var eAnimation:Animation = entity.get(Animation);
			var tAnimation:Animation = target.get(Animation);
			//add the render
			var render:IRender;
			if (Application.STARLING_ENABLED)
			{
				render = IRender(ObjectPool.get(RenderStarling));
				if (depth == -1 || depth >= RenderSpriteStarling(tAnimation.render).numChildren)
					RenderSpriteStarling(tAnimation.render).addChild(RenderStarling(render));
				else
					RenderSpriteStarling(tAnimation.render).addChildAt(RenderStarling(render), depth);
			} else
			{
				render = IRender(ObjectPool.get(Render));
				if (depth == -1 || depth >= RenderSprite(tAnimation.render).numChildren)
					RenderSprite(tAnimation.render).addChild(Render(render));
				else
					RenderSprite(tAnimation.render).addChildAt(Render(render), depth);
			}
			if (takeParentsColor && tAnimation.color != 0 && tAnimation.color != 0xffffff)
				render.color = tAnimation.color;
			render.x = x;
			render.y = y;
			eAnimation.render = render;
			return render;
		}

		public function createDebuffTray( entity:Entity ):Entity
		{
			var debuffTrayComponent:DebuffTray = entity.get(DebuffTray);
			var assetVO:AssetVO                = _assetModel.getEntityData(TypeEnum.DEBUFF_TRAY);
			var tray:Entity                    = createEntity();
			tray.add(debuffTrayComponent);
			//detail component
			var detail:Detail                  = ObjectPool.get(Detail);
			detail.init(CategoryEnum.DEBUFF, assetVO);
			tray.add(detail);
			//animation component
			var anim:Animation                 = ObjectPool.get(Animation);
			anim.init(TypeEnum.HEALTH_BAR, "", true, 0, 30, true, 0, 32);
			tray.add(anim);
			debuffTrayComponent.Draw(anim, assetVO);
			//position component
			var oldPos:Position                = Position(entity.get(Position));
			var newPos:Position                = oldPos.clone();
			newPos.layer = LayerEnum.VFX;
			newPos.ignoreRotation = true;
			oldPos.addLink(newPos);
			tray.add(newPos);
			//visual component
			var vc:VisualComponent             = ObjectPool.get(VisualComponent);
			vc.init(entity);
			tray.add(vc);
			//assign the name
			tray.id = id;
			//add to game
			addEntity(tray);
			return tray;
		}

		private function removeRender( entity:Entity, render:IRender = null ):void
		{
			if (entity == null && render == null)
				return;
			var animation:Animation = entity.get(Animation);
			if (entity && render == null)
				render = animation.render;
			//remove the render from the building
			if (Application.STARLING_ENABLED)
			{
				var rs:RenderStarling = RenderStarling(render);
				rs.removeFromParent();
				ObjectPool.give(rs);
			} else
			{
				var r:Render = Render(render);
				r.parent.removeChild(r);
				ObjectPool.give(r);
			}
		}

		public function destroyComponent( component:Entity ):void
		{
			if (!component)
				return;
			var detail:Detail = Detail(component.get(Detail));
			if (!detail)
				return;
			destroyEntity(component);
			switch (detail.type)
			{
				case TypeEnum.HEALTH_BAR:
					var health:Health                   = component.remove(Health);
					health.animation = null;
					break;
				case TypeEnum.DEBUFF_TRAY:
				case TypeEnum.ATTACK_DEBUFF:
				case TypeEnum.DEFENSE_DEBUFF:
				case TypeEnum.SPEED_DEBUFF:
					var tray:DebuffTray                 = component.remove(DebuffTray);
					tray.Draw(null);
					break;
				case TypeEnum.SHIELD:
					var shield:Shield                   = component.remove(Shield);
					shield.animation = null;
					break;
				case TypeEnum.STATE_BAR:
					var state:State                     = VisualComponent(component.get(VisualComponent)).parent.get(State);
					if (state)
						state.component = null;
					break;
				case TypeEnum.BUILDING_ANIMATION:
					//remove the render from the building
					removeRender(component);
					break;
				case TypeEnum.STARBASE_TURRET:
					var vc:VisualComponent              = component.get(VisualComponent);
					if (vc)
					{
						//remove the animation component from the turret finite state machine
						if (Application.STATE == StateEvent.GAME_STARBASE)
							TurretFSM(FSM(vc.parent.get(FSM)).component).animation = null;
					}
					//remove the render from the building
					removeRender(component);
					break;
				case TypeEnum.BUILDING_CONSTRUCTION:
					if (component.has(VisualComponent))
					{
						removeRender(component);
						var construction:Construction = Construction(FSM(component.get(FSM)).component);
						removeRender(construction.beam);
						removeRender(construction.beam2);
						removeRender(construction.glow);
						destroyComponent(construction.beam);
						destroyComponent(construction.beam2);
						destroyComponent(construction.glow);
					}
					break;
				case TypeEnum.RESOURCE_DEPOT_CANISTER:
					var visualComponent:VisualComponent = VisualComponent(component.get(VisualComponent));
					while (visualComponent.numChildren > 0)
					{
						removeRender(component);
						destroyComponent(visualComponent.removeChildAt(0));
					}
					break;
			}
			ObjectPool.give(component.remove(Detail));
			ObjectPool.give(component.remove(Animation));
			if (component.has(VisualComponent))
				ObjectPool.give(component.remove(VisualComponent));
			if (component.has(Position))
				ObjectPool.give(component.remove(Position));
			if (component.has(FSM))
				ObjectPool.give(component.remove(FSM));
		}

		private function get id():String
		{
			_id++;
			return "vc" + _id;
		}

		[Inject]
		public function set sectorModel( v:SectorModel ):void  { _sectorModel = v; }

		[Inject]
		public function set playerModel( v:PlayerModel ):void  { _playerModel = v; }
	}
}
