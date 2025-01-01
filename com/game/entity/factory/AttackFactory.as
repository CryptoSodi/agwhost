package com.game.entity.factory
{
	import com.enum.CategoryEnum;
	import com.enum.EntityMoveEnum;
	import com.enum.FactionEnum;
	import com.enum.LayerEnum;
	import com.enum.TypeEnum;
	import com.game.entity.components.battle.ActiveDefense;
	import com.game.entity.components.battle.Area;
	import com.game.entity.components.battle.Beam;
	import com.game.entity.components.battle.Drone;
	import com.game.entity.components.battle.Modules;
	import com.game.entity.components.battle.TrailFX;
	import com.game.entity.components.shared.Animation;
	import com.game.entity.components.shared.Detail;
	import com.game.entity.components.shared.Grid;
	import com.game.entity.components.shared.Move;
	import com.game.entity.components.shared.Position;
	import com.model.asset.AssetVO;
	import com.model.player.CurrentUser;
	import com.model.prototype.IPrototype;
	import com.model.sector.SectorModel;
	import com.service.server.incoming.data.ActiveDefenseHitData;
	import com.service.server.incoming.data.AreaAttackData;
	import com.service.server.incoming.data.BeamAttackData;
	import com.service.server.incoming.data.DroneAttackData;
	import com.service.server.incoming.data.ProjectileAttackData;
	import com.util.BattleUtils;

	import flash.geom.Point;

	import org.ash.core.Entity;
	import org.shared.ObjectPool;

	public class AttackFactory extends BaseFactory implements IAttackFactory
	{
		private var _sectorModel:SectorModel;

		public function createProjectile( owner:Entity, data:ProjectileAttackData ):Entity
		{
			//Determine the firing ship or building faction
			var faction:String         = FactionEnum.IGA;
			if (owner)
			{
				var ownerDetail:Detail = owner.get(Detail);
				if (ownerDetail.category == 'Building')
					faction = _sectorModel.sectorFaction;
				else
					faction = ownerDetail.prototypeVO.getValue('faction');
			} else
				faction = (data.playerOwnerId == CurrentUser.id) ? CurrentUser.faction : _sectorModel.sectorFaction;

			//get the prototype and asset vo
			var prototypeVO:IPrototype = _prototypeModel.getWeaponPrototype(data.weaponPrototype);
			var assetVO:AssetVO;

			if (prototypeVO.asset == 'MissilePod')
			{
				switch (faction)
				{
					case FactionEnum.IMPERIUM:
					case FactionEnum.IGA:
						assetVO = _assetModel.getEntityData(TypeEnum.IGA_MISSILE);
						break;
					case FactionEnum.SOVEREIGNTY:
						assetVO = _assetModel.getEntityData(TypeEnum.SOV_MISSILE);
						break;
					case FactionEnum.TYRANNAR:
						assetVO = _assetModel.getEntityData(TypeEnum.TYR_MISSILE);
						break;
				}
			} else
				assetVO = _assetModel.getEntityData(prototypeVO.asset);

			var projectile:Entity      = createEntity();
			//detail component
			var detail:Detail          = ObjectPool.get(Detail);
			detail.init(CategoryEnum.ATTACK, assetVO, prototypeVO);
			projectile.add(detail);
			//position component
			var pos:Position           = ObjectPool.get(Position);
			var rot:Number             = BattleUtils.instance.isoCrunchAngle(data.rotation);
			pos.init(data.start.x, data.start.y, rot, LayerEnum.ATTACK);
			projectile.add(pos);
			//move component
			var move:Move              = ObjectPool.get(Move);
			var fadeTime:Number        = (data.fadeTime < 0) ? 3 : data.fadeTime;
			if (data.guided)
			{
				move.init(30, EntityMoveEnum.LERPING);
				move.fadeOut = data.finishTick - fadeTime;
			} else
			{
				move.init(30, EntityMoveEnum.POINT_TO_POINT);
				move.setPointToPoint(data.end.x, data.end.y, data.startTick, data.finishTick);
				move.fadeOut = move.endTick - fadeTime;
			}
			projectile.add(move);
			//animation component
			var anim:Animation         = ObjectPool.get(Animation);
			anim.init(assetVO.type, assetVO.spriteName, true);
			anim.scaleX = anim.scaleY = assetVO.scale;
			anim.allowTransform = true;
			projectile.add(anim);
			//grid component
			projectile.add(ObjectPool.get(Grid));
			//assign the name
			projectile.id = data.attackId;
			//add missile trail component if this is a guided projectile and it is set to have a trail
			if (detail.prototypeVO.getValue("trailLength") > 1)
			{
				// the missile trail component
				var trail:TrailFX = ObjectPool.get(TrailFX);
				trail.type = TypeEnum.MISSILE_TRAIL;
				trail.maxSegments = prototypeVO.getValue("trailLength");
				trail.color = parseInt(prototypeVO.getValue("trailColor"), 16);
				trail.thickness = prototypeVO.getValue("trailThickness");
				trail.lastPosition.setTo(pos.x, pos.y);
				trail.alphaChange = 1 / trail.maxSegments;
				projectile.add(trail);
			}
			//add to game
			addEntity(projectile);
			//Play audio
			playSound(assetVO);
			return projectile;
		}

		public function createBeam( data:BeamAttackData ):Entity
		{
			//get the prototype and asset vo
			var prototypeVO:IPrototype = _prototypeModel.getWeaponPrototype(data.weaponPrototype);
			var assetVO:AssetVO        = _assetModel.getEntityData(prototypeVO.asset);
			var beam:Entity            = createEntity();
			//detail component
			var detail:Detail          = ObjectPool.get(Detail);
			detail.init(CategoryEnum.ATTACK, assetVO, prototypeVO, data.entityOwnerId);
			beam.add(detail);
			//position component
			var pos:Position           = ObjectPool.get(Position);
			pos.init(data.start.x, data.start.y, 0, LayerEnum.ATTACK);
			beam.add(pos);
			//beam component
			var beamC:Beam             = ObjectPool.get(Beam);
			beamC.init(data.entityOwnerId, data.targetEntityId, data.sourceAttachPoint, data.targetAttachPoint, data.targetScatterX, data.targetScatterY, data.maxRange, data.attackHit, .2);
			beamC.baseWidth = assetVO.type == TypeEnum.TURRET_BEAM_POINT_DEFENSE_CLUSTER ? 128 : 256;
			beamC.hitLocationX = data.hitLocation.x;
			beamC.hitLocationY = data.hitLocation.y;
			beamC.hitTarget = data.hitTarget;
			beam.add(beamC);
			//animation component
			var anim:Animation         = ObjectPool.get(Animation);
			anim.init(assetVO.type, assetVO.spriteName);
			anim.scaleX = 0;
			anim.scaleY = assetVO.scale;
			anim.allowTransform = true;
			beam.add(anim);
			//grid component
			beam.add(ObjectPool.get(Grid));
			//assign the name
			beam.id = data.attackId;
			//add to game
			addEntity(beam);
			//Play SoundFX
			playSound(assetVO);
			return beam;
		}

		public function createDrone( owner:Entity, data:DroneAttackData ):Entity
		{
			//Determine the firing ship or building faction
			var ownerDetail:Detail     = owner.get(Detail);
			var faction:String         = '';

			if (ownerDetail.category == 'Building')
				faction = _sectorModel.sectorFaction;
			else
				faction = ownerDetail.prototypeVO.getValue('faction');

			//get the prototype and asset vo
			var prototypeVO:IPrototype = _prototypeModel.getWeaponPrototype(data.weaponPrototype);
			var assetVO:AssetVO        = _assetModel.getEntityData(prototypeVO.asset);
			var attack:Entity          = createEntity();

			//detail component
			var detail:Detail          = ObjectPool.get(Detail);
			detail.init(CategoryEnum.ATTACK, assetVO, prototypeVO);
			attack.add(detail);

			//position component
			var pos:Position           = ObjectPool.get(Position);
			pos.init(data.start.x, data.start.y, data.rotation * 0.0174532925, LayerEnum.ATTACK);
			attack.add(pos);

			//move component
			var move:Move              = ObjectPool.get(Move);
			move.init(30, EntityMoveEnum.LERPING);
			attack.add(move);

			//animation component
			var anim:Animation         = ObjectPool.get(Animation);
			anim.init(assetVO.type, assetVO.spriteName, true);
			anim.allowTransform = true;
			anim.scaleX = anim.scaleY = assetVO.scale;
			attack.add(anim);

			//drone component
			var drone:Drone            = ObjectPool.get(Drone);
			drone.init(data.entityOwnerId, data.targetEntityId);
			drone.currentTick = 0;
			drone.fireDuration = prototypeVO.getValue("fireDuration");
			drone.minWeaponTime = prototypeVO.getValue("minWeaponTime") * 30.0;
			drone.maxWeaponTime = prototypeVO.getValue("maxWeaponTime") * 30.0;
			drone.weaponProto = prototypeVO.getValue("weaponProto");
			attack.add(drone);

			//grid component
			attack.add(ObjectPool.get(Grid));

			//assign the name
			attack.id = data.attackId;

			//add to game
			addEntity(attack);

			//Play SoundFX
			playSound(assetVO);
			return attack;
		}

		public function createArea( shipID:String, data:AreaAttackData ):Entity
		{
			//get the prototype and asset vo
			var prototypeVO:IPrototype = _prototypeModel.getWeaponPrototype(data.weaponPrototype);
			var assetVO:AssetVO        = _assetModel.getEntityData(prototypeVO.asset);
			var ship:Entity            = _game.getEntity(shipID);
			var area:Entity            = createEntity();

			//detail component
			var detail:Detail          = ObjectPool.get(Detail);
			detail.init(CategoryEnum.ATTACK, assetVO, prototypeVO, shipID);
			area.add(detail);

			//area component
			var areaC:Area             = ObjectPool.get(Area);
			areaC.init(shipID, data.sourceAttachPoint, 1500, prototypeVO);
			area.add(areaC);

			//position component
			var pos:Position           = ObjectPool.get(Position);
			pos.init(data.start.x, data.start.y, 0, LayerEnum.ATTACK);
			if (areaC.rotateWithSource && ship)
				pos.rotation = BattleUtils.instance.getAttachPointRotation(ship, areaC.sourceAttachPoint)
			var randomRot:Boolean      = prototypeVO.getValue("randomRot");
			if (randomRot)
				pos.rotation += (Math.random() * 6.28318531);
			area.add(pos);

			//animation component
			var anim:Animation         = ObjectPool.get(Animation);
			anim.init(assetVO.type, assetVO.spriteName, !areaC.useBeamDynamics);
			anim.scaleX = areaC.startScaleX;
			anim.scaleY = areaC.startScaleY;
			anim.allowTransform = true;
			var randomAnim:Boolean     = prototypeVO.getValue("randomAnim");
			if (randomAnim)
				anim.randomStart = true;
			var color:String           = prototypeVO.getValue("color");
			if (color)
				anim.color = parseInt(color, 16);
			var stretch:Boolean        = prototypeVO.getValue("stretchFrames");
			if (stretch)
				anim.duration = (areaC.animLength > areaC.duration) ? areaC.animLength : areaC.duration;
			area.add(anim);

			//animation component
			area.add(ObjectPool.get(Grid));

			//assign the name
			area.id = data.attackId;

			//add to game
			addEntity(area);
			//Play SoundFX
			playSound(assetVO);
			return area;
		}

		public function createActiveDefenseInterceptor( owner:Entity, attachPoint:String, x:int, y:int ):Entity
		{
			//get the prototype and asset vo
			var modules:Modules             = Modules(owner.get(Modules));
			var prototypeVO:IPrototype      = modules.getModuleByAttachPoint(attachPoint);
			if (prototypeVO == null)
				return null;
			var activeDefenseType:int       = ActiveDefense.BEAM;
			if (prototypeVO.itemClass == TypeEnum.DEFLECTOR_SCREEN)
				activeDefenseType = ActiveDefense.FLAK;
			else if (prototypeVO.itemClass == TypeEnum.DISTORTION_WEB)
				activeDefenseType = ActiveDefense.SHIELD;
			if (activeDefenseType == ActiveDefense.SHIELD)
				return null;
			var assetVO:AssetVO             = _assetModel.getEntityData(prototypeVO.asset);
			var interceptor:Entity          = createEntity();
			//detail component
			var detail:Detail               = ObjectPool.get(Detail);
			detail.init(CategoryEnum.ATTACK, assetVO, prototypeVO, owner.id);
			interceptor.add(detail);
			//activeDefense component
			var activeDefense:ActiveDefense = ObjectPool.get(ActiveDefense);
			activeDefense.init(activeDefenseType, owner, attachPoint);
			activeDefense.hitLocationX = x;
			activeDefense.hitLocationY = y;
			interceptor.add(activeDefense);
			//position component
			var sourceLoc:Point             = new Point(x, y);
			if (activeDefenseType == ActiveDefense.BEAM)
				BattleUtils.instance.getAttachPointLocation(owner, attachPoint, sourceLoc);
			var pos:Position                = ObjectPool.get(Position);
			pos.init(sourceLoc.x, sourceLoc.y, 0, LayerEnum.ATTACK);
			interceptor.add(pos);
			//animation component
			var anim:Animation              = ObjectPool.get(Animation);
			var center:Boolean              = (activeDefenseType == ActiveDefense.FLAK) ? true : false;
			anim.init(assetVO.type, assetVO.spriteName, center, 0, 30, true);
			anim.scaleX = 0;
			anim.scaleY = assetVO.scale;
			anim.allowTransform = true;
			interceptor.add(anim);
			//assign the name
			interceptor.id = "AD" + owner.id + attachPoint + x + y;
			//add to game
			addEntity(interceptor);
			//Play SoundFX
			playSound(assetVO);
			return interceptor;
		}

		public function cleanAttack( attack:Entity ):void
		{
			if (attack.has(Beam))
				ObjectPool.give(attack.remove(Beam));
			if (attack.has(Move))
				ObjectPool.give(attack.remove(Move));
			if (attack.has(Area))
				ObjectPool.give(attack.remove(Area));
			if (attack.has(Drone))
				ObjectPool.give(attack.remove(Drone));
			if (attack.has(TrailFX))
				ObjectPool.give(attack.remove(TrailFX));
			ObjectPool.give(attack.remove(Grid));
		}

		public function destroyAttack( attack:Entity ):void
		{
			destroyEntity(attack);
			if (attack.has(Beam))
				ObjectPool.give(attack.remove(Beam));
			if (attack.has(Move))
				ObjectPool.give(attack.remove(Move));
			if (attack.has(ActiveDefense))
				ObjectPool.give(attack.remove(ActiveDefense));
			if (attack.has(Area))
				ObjectPool.give(attack.remove(Area));
			if (attack.has(Drone))
				ObjectPool.give(attack.remove(Drone));
			if (attack.has(TrailFX))
				ObjectPool.give(attack.remove(TrailFX));
			if (attack.has(Grid))
				ObjectPool.give(attack.remove(Grid));
			ObjectPool.give(attack.remove(Detail));
			ObjectPool.give(attack.remove(Position));
			ObjectPool.give(attack.remove(Animation));
		}

		[Inject]
		public function set sectorModel( value:SectorModel ):void
		{
			_sectorModel = value;
		}

	}
}
