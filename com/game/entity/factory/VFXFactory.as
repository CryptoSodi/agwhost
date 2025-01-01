package com.game.entity.factory
{
	import com.Application;
	import com.enum.AudioEnum;
	import com.enum.CategoryEnum;
	import com.enum.FactionEnum;
	import com.enum.LayerEnum;
	import com.enum.TypeEnum;
	import com.event.StateEvent;
	import com.game.entity.components.battle.Attack;
	import com.game.entity.components.battle.Damage;
	import com.game.entity.components.battle.TrailFX;
	import com.game.entity.components.shared.Animation;
	import com.game.entity.components.shared.DebugLine;
	import com.game.entity.components.shared.Detail;
	import com.game.entity.components.shared.Grid;
	import com.game.entity.components.shared.Muzzle;
	import com.game.entity.components.shared.Position;
	import com.game.entity.components.shared.Thruster;
	import com.model.asset.AssetVO;
	import com.model.battle.BattleModel;
	import com.model.player.PlayerModel;
	import com.model.player.PlayerVO;
	import com.model.prototype.IPrototype;
	import com.service.server.incoming.data.DebugLineData;
	import com.service.server.incoming.data.SectorBattleData;
	import com.util.BattleUtils;
	
	import flash.display.BlendMode;
	
	import org.adobe.utils.StringUtil;
	import org.ash.core.Entity;
	import org.parade.core.IViewStack;
	import org.parade.enum.PlatformEnum;
	import org.parade.util.DeviceMetrics;
	import org.shared.ObjectPool;

	public class VFXFactory extends BaseFactory implements IVFXFactory
	{
		private var _attackFactory:IAttackFactory;
		private var _battleModel:BattleModel;
		private var _explosionScale:Array = [0.25, 0.5, 1];
		private var _id:int               = 1;
		private var _hitCounter:int       = 0;
		private var _viewStack:IViewStack;
		private var _playerModel:PlayerModel;

		public function createExplosion( parent:Entity, x:int, y:int ):Entity
		{
			var animation:Animation = Animation(parent.get(Animation));
			var detail:Detail       = Detail(parent.get(Detail));
			var itemClass:String    = detail.prototypeVO ? detail.prototypeVO.itemClass : '';
			if (itemClass == TypeEnum.FORCEFIELD)
				return null;
			if (itemClass == '' && (detail.type == TypeEnum.STARBASE_SECTOR_IGA ||
				detail.type == TypeEnum.STARBASE_SECTOR_SOVEREIGNTY ||
				detail.type == TypeEnum.STARBASE_SECTOR_TYRANNAR))
				itemClass = TypeEnum.STARBASE_SECTOR_TYRANNAR;
			var expScale:Number     = 1.0;
			var audioFile:String;
			if (animation.visible)
			{
				var assetVO:AssetVO;
				var showShockwave:int;
				var showFlare:int;
				switch (itemClass)
				{
					//small explosion
					case TypeEnum.FIGHTER:
					case TypeEnum.HEAVY_FIGHTER:
					case TypeEnum.SHIELD_GENERATOR:
					case TypeEnum.POINT_DEFENSE_PLATFORM:
					case TypeEnum.PYLON:
						assetVO = _assetModel.getEntityData(TypeEnum.EXPLOSION_SMALL);
						expScale = 0.75;
						audioFile = (detail.category == CategoryEnum.BUILDING) ? AudioEnum.AFX_BLD_EXPLOSION_SMALL : AudioEnum.AFX_SHIP_EXPLOSION_SMALL;
						if (detail.category)
						{
							expScale = 1;
							_viewStack.shake(1, 1, 6, 3);
						}
						break;
					//large explosion
					case TypeEnum.BATTLESHIP:
					case TypeEnum.DREADNOUGHT:
					case TypeEnum.TRANSPORT:
						showShockwave = Math.floor((Math.random() * 2)) + 1;
						showFlare = Math.floor((Math.random() * 2)) + 1;
						if (showShockwave == 1)
							createShockwave(detail, animation, 5, x, y);
						if (showFlare == 1)
							createFlare(detail, animation, 1, x, y);
						if (Application.STATE == StateEvent.GAME_BATTLE)
							_viewStack.shake(5, 2, 10, 3);
					case TypeEnum.COMMAND_CENTER:
					case TypeEnum.CONSTRUCTION_BAY:
					case TypeEnum.DOCK:
						assetVO = DeviceMetrics.PLATFORM == PlatformEnum.MOBILE ? _assetModel.getEntityData(TypeEnum.EXPLOSION_SMALL) : _assetModel.getEntityData(TypeEnum.EXPLOSION_LARGE);
						audioFile = (detail.category == CategoryEnum.BUILDING) ? AudioEnum.AFX_BLD_EXPLOSION_BIG : AudioEnum.AFX_SHIP_EXPLOSION_BIG;
						if (detail.category == CategoryEnum.BUILDING)
						{
							_viewStack.shake(5, 2, 10, 3);
						}
						break;
					case "DroneBay":
					case "AssaultSquadron":
					case "BombardierWing":
					case "DroneSquadron":
						assetVO = _assetModel.getEntityData(TypeEnum.EXPLOSION_SMALL);
						expScale = 0.20;
						audioFile = AudioEnum.AFX_SHIP_EXPLOSION_SMALL;
						break;
					//medium explosion
					default:
						showShockwave = Math.floor((Math.random() * 2)) + 1;
						showFlare = Math.floor((Math.random() * 2)) + 1;
						if (showShockwave == 1)
							createShockwave(detail, animation, 1, x, y);
						if (showFlare == 1)
							createFlare(detail, animation, 1, x, y);

						assetVO = DeviceMetrics.PLATFORM == PlatformEnum.MOBILE ? _assetModel.getEntityData(TypeEnum.EXPLOSION_SMALL) : _assetModel.getEntityData(TypeEnum.EXPLOSION_LARGE);
						expScale = 0.8;
						audioFile = (detail.category == CategoryEnum.BUILDING) ? AudioEnum.AFX_BLD_EXPLOSION_MEDIUM : AudioEnum.AFX_SHIP_EXPLOSION_MEDIUM;
						if (detail.category == CategoryEnum.BUILDING)
						{
							expScale = 1;
							_viewStack.shake(3, 1.3, 8, 3);
						}
						break;
				}
				var explosion:Entity = createEntity();
				//detail component
				detail = ObjectPool.get(Detail);
				detail.init(CategoryEnum.EXPLOSION, assetVO);
				explosion.add(detail);
				//position component
				var pos:Position     = ObjectPool.get(Position);
				pos.init(x, y, 1, LayerEnum.EXPLOSION);
				pos.rotation = Math.random() * 360;
				pos.depth = 0;
				explosion.add(pos);
				//animation component
				animation = ObjectPool.get(Animation);
				animation.init(assetVO.type, assetVO.spriteName, true, 0, 30, false);
				animation.scaleX = animation.scaleY = expScale;
				animation.allowTransform = true;
				animation.destroyOnComplete = true;
				explosion.add(animation);
				//grid component
				explosion.add(ObjectPool.get(Grid));
				//assign the name
				explosion.id = name;
				//add to game
				addEntity(explosion);
				//Play Explosion
				_soundController.playSound(audioFile, 0.5);
				return explosion;
			}
			return null;
		}

		public function createSectorExplosion( parent:Entity, x:int, y:int ):Entity
		{
			var animation:Animation = Animation(parent.get(Animation));
			if (!animation.visible)
				return null;
			var detail:Detail       = Detail(parent.get(Detail));
			var itemClass:String    = detail.prototypeVO ? detail.prototypeVO.itemClass : '';
			if (itemClass == '')
				itemClass = detail.type;
			var expScale:Number     = 1.0;
			var audioFile:String;
			var assetVO:AssetVO     = _assetModel.getEntityData(TypeEnum.EXPLOSION_SMALL);
			var showShockwave:int;
			var showFlare:int;
			switch (itemClass)
			{
				case TypeEnum.FIGHTER:
				case TypeEnum.HEAVY_FIGHTER:
					expScale = 0.75;
					audioFile = AudioEnum.AFX_SHIP_EXPLOSION_SMALL;
					break;

				case TypeEnum.STARBASE_SECTOR_IGA:
				case TypeEnum.STARBASE_SECTOR_SOVEREIGNTY:
				case TypeEnum.STARBASE_SECTOR_TYRANNAR:
					audioFile = AudioEnum.AFX_BLD_EXPLOSION_BIG;
					_viewStack.shake(5, 2, 10, 3);
					createShockwave(detail, animation, 5, x, y);
					break;

				case TypeEnum.BATTLESHIP:
				case TypeEnum.DREADNOUGHT:
				case TypeEnum.TRANSPORT:
					showShockwave = Math.floor((Math.random() * 2)) + 1;
					showFlare = Math.floor((Math.random() * 2)) + 1;
					if (showShockwave == 1)
						createShockwave(detail, animation, 3, x, y);
					if (showFlare == 1)
						createFlare(detail, animation, 1, x, y);
					if (Application.STATE == StateEvent.GAME_BATTLE)
						_viewStack.shake(5, 2, 10, 3);
					audioFile = AudioEnum.AFX_SHIP_EXPLOSION_BIG;
					break;

				case TypeEnum.DERELICT_IGA:
				case TypeEnum.DERELICT_SOVEREIGNTY:
				case TypeEnum.DERELICT_TYRANNAR:
					createFlare(detail, animation, .75, x, y);
					return null;

				default:
					showFlare = Math.floor((Math.random() * 2)) + 1;
					if (showFlare == 1)
						createFlare(detail, animation, 1, x, y);
					expScale = 0.8;
					audioFile = AudioEnum.AFX_SHIP_EXPLOSION_MEDIUM;
					break;
			}
			var explosion:Entity    = createEntity();
			//detail component
			detail = ObjectPool.get(Detail);
			detail.init(CategoryEnum.EXPLOSION, assetVO);
			explosion.add(detail);
			//position component
			var pos:Position        = ObjectPool.get(Position);
			pos.init(x, y, 1, LayerEnum.EXPLOSION);
			pos.rotation = Math.random() * 360;
			pos.depth = 0;
			explosion.add(pos);
			//animation component
			animation = ObjectPool.get(Animation);
			animation.init(assetVO.type, assetVO.spriteName, true, 0, 30, false);
			animation.scaleX = animation.scaleY = expScale;
			animation.allowTransform = true;
			animation.destroyOnComplete = true;
			explosion.add(animation);
			//grid component
			explosion.add(ObjectPool.get(Grid));
			//assign the name
			explosion.id = name;
			//add to game
			addEntity(explosion);
			//Play Explosion
			_soundController.playSound(audioFile, 0.5);
			return explosion;
			return null;
		}

		private function createShockwave( detail:Detail, animation:Animation, expScale:Number, x:int, y:int ):void
		{
			var shockVO:AssetVO  = _assetModel.getEntityData(TypeEnum.EXPLOSION_SHOCKWAVE);
			var explosion:Entity = createEntity();
			//detail component
			detail = ObjectPool.get(Detail);
			detail.init(CategoryEnum.EXPLOSION, shockVO);
			explosion.add(detail);
			//position component
			var pos:Position     = ObjectPool.get(Position);
			pos.init(x, y, 1, LayerEnum.EXPLOSION);
			pos.depth = 2;
			explosion.add(pos);
			//animation component
			animation = ObjectPool.get(Animation);
			animation.init(TypeEnum.EXPLOSION_SHOCKWAVE, shockVO.spriteName, true, 0, 30, false);
			animation.scaleX = animation.scaleY = expScale;
			animation.allowTransform = true;
			animation.destroyOnComplete = true;
			explosion.add(animation);
			//grid component
			explosion.add(ObjectPool.get(Grid));
			//assign the name
			explosion.id = name;
			//add to game
			addEntity(explosion);
		}

		private function createFlare( detail:Detail, animation:Animation, expScale:Number, x:int, y:int ):void
		{
			var shockVO:AssetVO  = _assetModel.getEntityData(TypeEnum.EXPLOSION_FLARE);
			var explosion:Entity = createEntity();
			//detail component
			detail = ObjectPool.get(Detail);
			detail.init(CategoryEnum.EXPLOSION, shockVO);
			explosion.add(detail);
			//position component
			var pos:Position     = ObjectPool.get(Position);
			pos.init(x, y, 0, LayerEnum.EXPLOSION);
			pos.depth = 1;
			explosion.add(pos);
			//animation component
			animation = ObjectPool.get(Animation);
			animation.init(TypeEnum.EXPLOSION_FLARE, shockVO.spriteName, true, 0, 30, false);
			animation.scaleX = animation.scaleY = expScale;
			animation.blendMode = BlendMode.ADD;
			animation.allowTransform = true;
			animation.destroyOnComplete = true;
			explosion.add(animation);
			//grid component
			explosion.add(ObjectPool.get(Grid));
			//assign the name
			explosion.id = name;
			//add to game
			addEntity(explosion);
		}

		public function createHit( hitTarget:Entity, projectile:Entity, x:int, y:int, hitShield:Boolean = false, useProjectile:Boolean = false ):Entity
		{
			if (hitTarget == null || projectile == null)
				return null;

			var detail:Detail       = Detail(projectile.get(Detail));
			var shakeIt:Boolean     = detail.prototypeVO.getValue('shakeOnHit');

			_hitCounter++;
			if (_hitCounter < 3 && !shakeIt)
				return null;
			_hitCounter = 0;

			var animation:Animation = Animation(projectile.get(Animation));

			var targetDetail:Detail = Detail(hitTarget.get(Detail));
			var hitItemClass:String = targetDetail.prototypeVO ? targetDetail.prototypeVO.itemClass : '';

			if (!animation.visible || detail.prototypeVO == null)
				return null;

			if (useProjectile)
				_attackFactory.cleanAttack(projectile);

			var itemClass:String    = detail.prototypeVO.getValue('itemClass');
			var assetVO:AssetVO;


			//detail component
			detail = (useProjectile) ? projectile.get(Detail) : ObjectPool.get(Detail);
			if (hitShield)
				assetVO = _assetModel.getEntityData(TypeEnum.SHIELD_HIT);
			else if (itemClass == 'PlasmaMissile' || itemClass == 'MissileBattery' || itemClass == 'MissilePod' || itemClass == 'AntimatterTorpedo' || itemClass == 'GravitonBomb')
				assetVO = _assetModel.getEntityData(TypeEnum.EXPLOSION_MISSILEHIT);
			else if (itemClass == 'PulseLaser' || itemClass == 'DisintegrationRay' || itemClass == 'GravitonBeam')
				assetVO = _assetModel.getEntityData(TypeEnum.EXPLOSION_LASERHIT);
			else
				assetVO = _assetModel.getEntityData(TypeEnum.HIT);
			detail.init(CategoryEnum.EXPLOSION, assetVO);
			//position component
			var pos:Position        = useProjectile ? projectile.get(Position) : ObjectPool.get(Position);
			pos.init(x, y, 1, LayerEnum.HIT);
			//animation component
			animation = useProjectile ? projectile.get(Animation) : ObjectPool.get(Animation);
			animation.init(assetVO.type, assetVO.spriteName, true, 0, 30, true);
			if (hitShield)
				animation.color = _battleModel.baseFactionColor;
			//Scale the hit based on ship type
			var hitScale:Number     = 0;
			//This only applicable to lasers
			switch (hitItemClass)
			{
				case TypeEnum.FIGHTER:
				case TypeEnum.HEAVY_FIGHTER:
					hitScale = 0.15;
					break;
				case TypeEnum.CORVETTE:
				case TypeEnum.DESTROYER:
					hitScale = 0.18;
					break;
				case TypeEnum.BATTLESHIP:
				case TypeEnum.DREADNOUGHT:
				case TypeEnum.TRANSPORT:
					hitScale = 0.2;
					break;
				default:
					hitScale = 0;
			}

			if (hitScale == 0)
			{
				switch (itemClass)
				{
					case 'ParticleBlaster':
					case 'StrikeCannon':
						hitScale = _explosionScale[Math.floor((Math.random() * 2))];
						break;
					case 'Railgun':
						hitScale = _explosionScale[Math.floor((Math.random() * 2))];
						break;
					case 'PlasmaMissile':
					case 'MissileBattery':
					case 'MissilePod':
						hitScale = _explosionScale[Math.floor((Math.random() * 2))];
						break;
					default:
						hitScale = 0.5;
				}

			}
			animation.scaleX = animation.scaleY = hitScale;
			animation.allowTransform = true;
			animation.destroyOnComplete = true;

			// Do screen shake if appropriate
			if (shakeIt)
				_viewStack.shake(5, 2, 17, 3);

			if (!useProjectile)
			{
				var hit:Entity = createEntity();
				hit.add(detail);
				hit.add(pos);
				hit.add(animation);
				hit.id = name;
				addEntity(hit);
			} else
			{
				animation.spritePack = null;
				animation.forceSprite = null;
				_game.updateEntityID(projectile, name);
				pos.layerSwap(LayerEnum.ATTACK, LayerEnum.HIT);
			}
			return (useProjectile) ? projectile : hit;
		}

		public function createAttackIcon( data:SectorBattleData ):Entity
		{
			var attackIcon:Entity   = createEntity();
			var assetVO:AssetVO     = _assetModel.getEntityData(TypeEnum.ATTACK_ICON);
			//detail component
			var detail:Detail       = ObjectPool.get(Detail);
			detail.init(CategoryEnum.VFX, assetVO);
			attackIcon.add(detail);
			//animation component
			var animation:Animation = ObjectPool.get(Animation);
			animation.init(assetVO.type, assetVO.spriteName, true, 0, 30, false, 0, -30);
			animation.allowTransform = true;
			animation.scaleX = animation.scaleY = 0.9;
			attackIcon.add(animation);
			//grid component
			attackIcon.add(ObjectPool.get(Grid));
			//position component
			var position:Position   = ObjectPool.get(Position);
			position.init(data.locationX, data.locationY - 32, 0, LayerEnum.VFX);
			attackIcon.add(position);
			//attack component
			var attack:Attack       = ObjectPool.get(Attack);
			attack.attackData = data;
			attackIcon.add(attack);
			//assign the name
			attackIcon.id = data.id;
			//add to game
			addEntity(attackIcon);
			return attackIcon;
		}

		public function createTrail( trail:TrailFX, x:Number, y:Number, rotation:Number ):Entity
		{
			var missileTrail:Entity = createEntity();
			var assetVO:AssetVO     = _assetModel.getEntityData(TypeEnum.MISSILE_TRAIL);
			//detail component
			var detail:Detail       = ObjectPool.get(Detail);
			detail.init(CategoryEnum.VFX, assetVO);
			missileTrail.add(detail);
			//animation component
			var animation:Animation = ObjectPool.get(Animation);
			animation.init(assetVO.type, assetVO.spriteName, false, 0, 30, true);
			animation.color = trail.color;
			animation.allowTransform = true;
			missileTrail.add(animation);
			//position component
			var position:Position   = ObjectPool.get(Position);
			position.init(x, y, rotation, LayerEnum.VFX);
			missileTrail.add(position);
			//assign the name
			missileTrail.id = name;
			//add to game
			addEntity(missileTrail);
			return missileTrail;
		}

		public function createThruster( entity:Entity, attachPointProto:IPrototype, debugAttachPoints:Boolean = false, visible:Boolean = false ):Entity
		{
			var thrusterAsset:AssetVO = _assetModel.getEntityData(TypeEnum.THRUSTER);
			
			if(thrusterAsset == null)
				return null;
			
			if(attachPointProto == null)
				return null;
			
			// Add Detail component
			var detail:Detail         = ObjectPool.get(Detail);
			detail.init(CategoryEnum.VFX, thrusterAsset);
			detail.prototypeVO = attachPointProto;

			// Add Animation component
			var ownerId:String        = Detail(entity.get(Detail)).ownerID;
			var player:PlayerVO 	  = _playerModel.getPlayer(ownerId);
			if(player == null)
				return null;
			
			var ownerFaction:String   = player.faction;
			var factionPrepend:String = "SOV/";
			if (ownerFaction == FactionEnum.IGA)
				factionPrepend = "IGA/";
			else if (ownerFaction == FactionEnum.TYRANNAR)
				factionPrepend = "TYR/";
			else if (ownerFaction == FactionEnum.IMPERIUM)
				factionPrepend = "IMP/";
			var anim:Animation        = ObjectPool.get(Animation);
			anim.init(thrusterAsset.type, factionPrepend + thrusterAsset.spriteName, false, 0, 30, visible);
			//PR: Turning the blendmode off on these for now as it causes more of a performance hit and looks to be doubling our draw calls?
			//will investigate more shortly
			//anim.blendMode = BlendMode.ADD;
			anim.alpha = 1.0;
			anim.scaleX = attachPointProto.getValue("scale") * 2.0;
			anim.scaleY = attachPointProto.getValue("scale") * 1.0;
			anim.offsetX = 0;
			anim.offsetY = 32;

			if (debugAttachPoints)
			{
				if (StringUtil.beginsWith(attachPointProto.getValue("attachPointType"), "Weapon"))
					anim.color = 0xFF0000;
				else if (StringUtil.beginsWith(attachPointProto.getValue("attachPointType"), "ArcWeapon") ||
					StringUtil.beginsWith(attachPointProto.getValue("attachPointType"), "DroneBay") ||
					StringUtil.beginsWith(attachPointProto.getValue("attachPointType"), "SpinalWeapon"))
					anim.color = 0xFFFF00;
				else if (StringUtil.beginsWith(attachPointProto.getValue("attachPointType"), "Thruster"))
					anim.color = 0x00FF00;
				else if (StringUtil.beginsWith(attachPointProto.getValue("attachPointType"), "Target"))
					anim.color = 0x00FFFF;
				else if (StringUtil.beginsWith(attachPointProto.getValue("attachPointType"), "Defense"))
					anim.color = 0x0000FF;
			}

			anim.allowTransform = true;
			
			
			// Create a sprite for each thruster and add as child of the ship
			var thruster:Entity       = createEntity();
			thruster.add(detail);
			thruster.add(anim);

			if (debugAttachPoints)
			{
				anim.alpha = 1.0;
				anim.scaleY = attachPointProto.getValue("scale") * 0.1;
				anim.scaleX = attachPointProto.getValue("scale") * 0.5;
				anim.offsetX = 0;
				anim.offsetY = 16;
			}

			// Add Position component
			var position:Position     = ObjectPool.get(Position);
			thruster.add(position);
			position.init(0, 0, 0, LayerEnum.VFX);
			BattleUtils.instance.moveToAttachPoint(entity, thruster);
			
			// Add Thruster Component
			var thrusterC:Thruster    = ObjectPool.get(Thruster);
			if(thrusterC != null)
			{
				if (StringUtil.beginsWith(attachPointProto.getValue("attachPointType"), "ThrusterForward"))
					thrusterC.direction = "Forward";
				else if (StringUtil.beginsWith(attachPointProto.getValue("attachPointType"), "ThrusterRight"))
					thrusterC.direction = "Right";
				else if (StringUtil.beginsWith(attachPointProto.getValue("attachPointType"), "ThrusterBackward"))
					thrusterC.direction = "Backward";
				else if (StringUtil.beginsWith(attachPointProto.getValue("attachPointType"), "ThrusterLeft"))
					thrusterC.direction = "Left";
				else if (debugAttachPoints)
					thrusterC.direction = "Backward";
			}
			thruster.add(thrusterC);

			thruster.id = name;
			// Add the thruster to the game
			_game.addEntity(thruster);
			return thruster;
		}

		public function createMuzzle( entity:Entity, attachPointProto:IPrototype, weaponProto:IPrototype, slotIndex:Number, visible:Boolean = false ):Entity
		{
			// Get asset from the weapon proto
			var assetName:String    = weaponProto.getValue("chargeAsset");
			var muzzleAsset:AssetVO = _assetModel.getEntityData(assetName);

			// Create a sprite for each muzzle and add as child of the ship
			var muzzle:Entity       = createEntity();

			// Add Detail component
			var detail:Detail       = ObjectPool.get(Detail);
			detail.init(CategoryEnum.VFX, muzzleAsset);
			detail.prototypeVO = attachPointProto;
			muzzle.add(detail);

			// Add Animation component
			var ownerId:String      = Detail(entity.get(Detail)).ownerID;
			var ownerFaction:String = _playerModel.getPlayer(ownerId).faction;
			var anim:Animation      = ObjectPool.get(Animation);
			anim.init(muzzleAsset.type, muzzleAsset.spriteName, true, 0, 30, visible);
			//PR: Turning the blendmode off on these for now as it causes more of a performance hit and looks to be doubling our draw calls?
			//will investigate more shortly
			//anim.blendMode = BlendMode.ADD;
			anim.alpha = 1.0;
			anim.scaleX = 0.0;
			anim.scaleY = 0.0;

			// Get color from the weapon data
			var color:String        = weaponProto.getUnsafeValue("chargeColor");
			anim.color = (color) ? uint("0x" + color) : 0xFFFFFF;

			anim.allowTransform = true;
			muzzle.add(anim);

			// Add Position component
			var position:Position   = ObjectPool.get(Position);
			muzzle.add(position);
			position.init(0, 0, 0, LayerEnum.VFX);
			position.rotation = 90.0 * 0.0174532925;
			BattleUtils.instance.moveToAttachPoint(entity, muzzle);

			// Add Muzzle Component
			var muzzleC:Muzzle      = ObjectPool.get(Muzzle);
			muzzleC.moduleIdx = slotIndex;
			muzzleC.currentFrame = -1;
			muzzleC.chargeDuration = weaponProto.getUnsafeValue("chargeTime") * 30.0;
			muzzleC.weaponClass = weaponProto.getUnsafeValue("itemClass");
			muzzleC.baseScale = attachPointProto.getValue("scale");
			muzzle.add(muzzleC);

			muzzle.id = name;
			// Add the thruster to the game
			_game.addEntity(muzzle);
			return muzzle;
		}

		public function createDamageEffect( entity:Entity, attachPointProto:IPrototype ):Entity
		{
			// Create a sprite for each thruster and add as child of the ship
			var damageEffect:Entity = ObjectPool.get(Entity);

			// Add Detail component
			var detail:Detail       = ObjectPool.get(Detail);
			detail.init(CategoryEnum.VFX, _assetModel.getEntityData(TypeEnum.DAMAGE), attachPointProto);
			damageEffect.add(detail);

			// Add Animation component
			var anim:Animation      = ObjectPool.get(Animation);
			anim.init(Animation(entity.get(Animation)).type, TypeEnum.DAMAGE, true, 0, 30, true);
			anim.scaleX = anim.scaleY = attachPointProto.getValue("scale") * (Math.random() * 1.5);
			anim.frame = (Math.random() * 18) | 0;
			anim.allowTransform = true;
			damageEffect.add(anim);

			// Add Position component
			var position:Position   = ObjectPool.get(Position);
			damageEffect.add(position);
			position.init(0, 0, 0, LayerEnum.VFX);
			BattleUtils.instance.moveToAttachPoint(entity, damageEffect);

			// Add Damage component
			var damage:Damage       = ObjectPool.get(Damage);
			damage.rotOffset = Math.random() * 360;
			damageEffect.add(damage);

			damageEffect.id = name;
			// Add the thruster to the game
			_game.addEntity(damageEffect);
			return damageEffect
		}

		public function createDebugLine( data:DebugLineData ):Entity
		{
			var assetVO:AssetVO   = _assetModel.getEntityData(TypeEnum.DEBUG_LINE);
			if (!assetVO)
				return null;

			var debugLine:Entity  = createEntity();
			// Add Detail component
			var detail:Detail     = ObjectPool.get(Detail);
			detail.init(assetVO.type, assetVO);
			debugLine.add(detail);

			// Add Animation component
			var anim:Animation    = ObjectPool.get(Animation);
			anim.init(assetVO.type, assetVO.spriteName, false, 0, 30, true);
			var xDiff:Number      = (data.startX - data.endX) * (data.startX - data.endX);
			var yDiff:Number      = (data.startY - data.endY) * (data.startY - data.endY);
			anim.scaleX = Math.sqrt(xDiff + yDiff) / 64;
			anim.scaleY = 0.25;
			anim.allowTransform = true;
			anim.visible = true;
			debugLine.add(anim);

			// Add Position component
			var position:Position = ObjectPool.get(Position);
			position.init(data.startX, data.startY, 0, LayerEnum.ACTIVE_DEFENSE);
			position.rotation = Math.atan2(data.endY - data.startY, data.endX - data.startX);
			debugLine.add(position);

			//debug line component
			var dl:DebugLine      = ObjectPool.get(DebugLine);
			dl.startColor = data.startColor;
			dl.endColor = data.endColor;
			debugLine.add(dl);

			debugLine.id = TypeEnum.DEBUG_LINE + data.id;
			// Add the debug line to the game
			_game.addEntity(debugLine);
			return debugLine;
		}

		public function destroyAttack( attackIcon:Entity ):void
		{
			destroyEntity(attackIcon);
			ObjectPool.give(attackIcon.remove(Detail));
			ObjectPool.give(attackIcon.remove(Animation));
			ObjectPool.give(attackIcon.remove(Grid));
			ObjectPool.give(attackIcon.remove(Position));
			ObjectPool.give(attackIcon.remove(Attack));
		}

		public function destroyDebugLine( debugLine:Entity ):void
		{
			ObjectPool.give(debugLine.remove(Detail));
			ObjectPool.give(debugLine.remove(Animation));
			ObjectPool.give(debugLine.remove(Position));
			ObjectPool.give(debugLine.remove(DebugLine));
			ObjectPool.give(debugLine);
		}

		public function destroyVFX( entity:Entity ):void
		{
			destroyEntity(entity);
			ObjectPool.give(entity.remove(Detail));
			ObjectPool.give(entity.remove(Position));
			ObjectPool.give(entity.remove(Animation));
			if (entity.has(Damage))
				ObjectPool.give(entity.remove(Damage));
			if (entity.has(Grid))
				ObjectPool.give(entity.remove(Grid));
			if (entity.has(Thruster))
				ObjectPool.give(entity.remove(Thruster));
		}

		public function destroyTrail( trail:Entity ):void
		{
			destroyEntity(trail);
			ObjectPool.give(trail.remove(Detail));
			ObjectPool.give(trail.remove(Position));
			ObjectPool.give(trail.remove(Animation));
		}

		private function get name():String
		{
			_id++;
			return "vfx" + _id;
		}

		[Inject]
		public function set attackFactory( v:IAttackFactory ):void  { _attackFactory = v; }
		[Inject]
		public function set battleModel( v:BattleModel ):void  { _battleModel = v; }
		[Inject]
		public function set playerModel( v:PlayerModel ):void  { _playerModel = v; }
		[Inject]
		public function set viewStack( v:IViewStack ):void  { _viewStack = v; }
	}
}


