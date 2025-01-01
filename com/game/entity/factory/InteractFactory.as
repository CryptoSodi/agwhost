package com.game.entity.factory
{
	import com.enum.CategoryEnum;
	import com.enum.FactionEnum;
	import com.enum.LayerEnum;
	import com.enum.TypeEnum;
	import com.game.entity.components.battle.Ship;
	import com.game.entity.components.shared.Animation;
	import com.game.entity.components.shared.Detail;
	import com.game.entity.components.shared.Grid;
	import com.game.entity.components.shared.Owned;
	import com.game.entity.components.shared.Position;
	import com.game.entity.components.starbase.Building;
	import com.model.asset.AssetVO;
	import com.model.player.CurrentUser;
	import com.model.player.PlayerModel;
	import com.model.prototype.IPrototype;
	import com.model.prototype.PrototypeModel;
	import com.model.sector.SectorModel;
	import com.model.starbase.BuildingVO;
	import com.util.AllegianceUtil;
	import com.util.RangeBuilder;
	import com.util.RouteLineBuilder;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import org.ash.core.Entity;
	import org.shared.ObjectPool;

	public class InteractFactory extends BaseFactory implements IInteractFactory
	{
		private var _id:int = 1;
		private var _label:String;
		private var _rangeBuilder:RangeBuilder;
		private var _routeLineBuilder:RouteLineBuilder;
		private var _playerModel:PlayerModel;
		private var _sectorModel:SectorModel;
		private var _type:String;

		public function showSelection( target:Entity, selector:Entity, x:int = 0, y:int = 0 , inBattle:Boolean = false):Entity
		{
			var animation:Animation;
			var color:uint;
			var isNew:Boolean = selector == null
			var position:Position;
			
			var faction:String = CurrentUser.faction;
			if(inBattle)
				faction = CurrentUser.battleFaction;

			switch (faction)
			{
				case FactionEnum.IGA:
					color = 0x3FD2FF;
					break;
				case FactionEnum.IMPERIUM:
					color = 0x00ff00;
					break;
				case FactionEnum.SOVEREIGNTY:
					color = 0xAF4DFF;
					break;
				case FactionEnum.TYRANNAR:
					color = 0xFFAC3F;
					break;
			}

			//if we don't have a target than we assume we're placing a destination
			if (!target)
			{
				if (isNew)
					selector = createInteractEntity("Destinationicon", TypeEnum.SHIELD);
				//position component
				if (isNew)
				{
					position = ObjectPool.get(Position);
					position.init(x, y, 0, LayerEnum.VFX);
					selector.add(position);
				} else
				{
					position = selector.get(Position);
					position.x = x;
					position.y = y;
				}
				animation = selector.get(Animation);
				animation.scaleX = animation.scaleY = 0.75;
				animation.color = color;
				//add to game
				if (isNew)
					_game.addEntity(selector);
				return selector;
			}

			var detail:Detail = target.get(Detail);
			if (detail.category == CategoryEnum.BUILDING && detail.type == TypeEnum.FORCEFIELD)
				return null;
			//determine which sprite to show
			if (detail.category == CategoryEnum.SHIP || detail.category == CategoryEnum.BUILDING)
			{
				_label = target.has(Owned) ? "Selector" : "EnemySelector";
				_type = TypeEnum.SHIELD;
				color = 0xffffff;
			} else
			{
				_label = "BaseSelector";
				_type = TypeEnum.SHIELD;
			}
			if (selector && Animation(selector.get(Animation)).label != _label)
			{
				destroyInteractEntity(selector);
				selector = null;
				isNew = true;
			}
			if (isNew)
				selector = createInteractEntity(_label, _type);

			//update scale and color
			animation = selector.get(Animation);
			animation.color = color;
			if (detail.category == CategoryEnum.SHIP)
			{
				if (target.has(Owned))
					animation.color = AllegianceUtil.instance.getFactionColor(faction);
				animation.scaleX = animation.scaleY = detail.assetVO.radius / 60;
				if (animation.scaleX < 1)
					animation.scaleX = animation.scaleY = 1;
			} else if (detail.category == CategoryEnum.BUILDING)
			{
				animation.scaleX = animation.scaleY = Building(target.get(Building)).buildingVO.sizeX / 5;
				if (animation.scaleX < 1.2)
					animation.scaleX = animation.scaleY = 1.2;
			} else
			{
				switch (detail.type)
				{
					case TypeEnum.DERELICT_IGA:
					case TypeEnum.DERELICT_SOVEREIGNTY:
					case TypeEnum.DERELICT_TYRANNAR:
						animation.scaleX = animation.scaleY = .5;
						break;
					default:
						animation.scaleX = animation.scaleY = 1;
						break;
				}
			}

			//update or add the position component
			if (isNew)
			{
				var oldPos:Position = target.get(Position);
				var newPos:Position = oldPos.clone();
				newPos.layer = LayerEnum.MISC;
				newPos.rotation = 0;
				newPos.ignoreRotation = true;
				oldPos.addLink(newPos);
				selector.add(newPos);
			} else
			{
				position = target.get(Position);
				var selectorPos:Position = selector.get(Position);
				selectorPos.linkedTo.removeLink(selectorPos);
				selectorPos.x = position.x;
				selectorPos.y = position.y;
				selectorPos.dirty = true;
				position.addLink(selectorPos);
			}

			//add to game
			if (isNew)
				_game.addEntity(selector);
			return selector;
		}

		public function showMultiShipSelection( target:Entity, selectionRect:Rectangle ):Entity
		{
			var name:String         = _rangeBuilder.drawShipSelectionBox();
			var position:Position;

			if (!target)
			{
				target = createInteractEntity(name, TypeEnum.SHIP_SELECTION_RANGE);
				position = ObjectPool.get(Position);
				position.init(selectionRect.x, selectionRect.y, 0, LayerEnum.RANGE);
				target.add(position);
				_game.addEntity(target);
			} else
			{
				position = target.get(Position);
				position.x = selectionRect.x;
				position.y = selectionRect.y;
				position.dirty = true;
			}

			var animation:Animation = target.get(Animation);
			animation.scaleX = selectionRect.width / RangeBuilder.SELECTION_SIZE;
			animation.scaleY = selectionRect.height / RangeBuilder.SELECTION_SIZE;

			position.x += selectionRect.width / 2;
			position.y += selectionRect.height / 2;

			return target;
		}

		public function createRouteLine( ship:Entity, destination:Point ):Entity
		{
			_routeLineBuilder.drawRouteLine();
			var routeLine:Entity    = createInteractEntity(TypeEnum.ROUTE_LINE, TypeEnum.ROUTE_LINE);
			var position:Position   = (ship.get(Position) as Position).clone();
			position.layer = LayerEnum.RANGE;
			position.clearRotation();
			routeLine.add(position);

			var animation:Animation = routeLine.get(Animation);
			animation.allowTransform = true;
			animation.center = false;
			animation.offsetY = RouteLineBuilder.OUTLINE_WIDTH / 2;

			RouteLineBuilder.adjustRotation(routeLine, destination);
			RouteLineBuilder.updateRouteLine(routeLine, ship);

			_game.addEntity(routeLine);
			return routeLine;
		}

		public function createRange( entity:Entity ):Entity
		{
			var name:String;
			var buildingVO:BuildingVO = Building(entity.get(Building)).buildingVO;
			var scale:Number          = 1;
			if (buildingVO.itemClass == TypeEnum.POINT_DEFENSE_PLATFORM)
			{
				var slots:Array = buildingVO.getValue("slots");
				if (slots && buildingVO.modules && buildingVO.modules[slots[0]] != null)
				{
					var proto:IPrototype = PrototypeModel.instance.getWeaponPrototype(buildingVO.modules[slots[0]].name);
					var maxRange:Number  = proto.getValue('maxRange');
					var minRange:Number  = proto.getValue('minRange');
					scale = (maxRange > 1000) ? maxRange / 1000 : 1;
					maxRange = maxRange / scale;
					minRange = minRange / scale;
					name = _rangeBuilder.drawStarbaseRange(maxRange, minRange);
				} else
					return null;
			} else if (buildingVO.itemClass == TypeEnum.PYLON)
				name = _rangeBuilder.drawPylonRange(buildingVO.shieldRadius);
			else
				name = _rangeBuilder.drawStarbaseRange(buildingVO.shieldRadius);

			var range:Entity          = createInteractEntity(name, TypeEnum.BASE_RANGE);
			//position component
			var oldPos:Position       = Position(entity.get(Position));
			var newPos:Position       = oldPos.clone();
			newPos.layer = LayerEnum.RANGE;
			oldPos.addLink(newPos);
			range.add(newPos);
			//animation component
			var anim:Animation        = range.get(Animation);
			anim.allowTransform = true;
			anim.transformScaleFirst = false;
			anim.center = false;
			anim.scaleX = scale;
			anim.scaleY = .5 * scale;
			var center:Point          = _rangeBuilder.getCenter(name);
			anim.offsetX = center.x;
			anim.offsetY = center.y;
			range.add(anim);
			//grid component
			range.add(ObjectPool.get(Grid));
			//assign the name
			range.id = id;
			//add to game
			_game.addEntity(range);
			return range;
		}

		public function createShipRange( entity:Entity ):Entity
		{
			var name:String     = Ship(entity.get(Ship)).rangeReference;
			var range:Entity    = createInteractEntity(name, TypeEnum.SHIP_RANGE);
			//position component
			var oldPos:Position = Position(entity.get(Position));
			var newPos:Position = oldPos.clone();
			newPos.layer = LayerEnum.RANGE;
			oldPos.addLink(newPos);
			range.add(newPos);
			//animation component
			var anim:Animation  = range.get(Animation);
			anim.allowTransform = true;
			anim.transformScaleFirst = false;
			anim.center = false;
			anim.scaleY = .5;
			var center:Point    = _rangeBuilder.getCenter(name);
			anim.offsetX = center.x;
			anim.offsetY = center.y;
			range.add(anim);
			//grid component
			range.add(ObjectPool.get(Grid));
			//add to game
			_game.addEntity(range);
			return range;
		}

		public function clearRanges():void
		{
			_rangeBuilder.cleanup();
		}

		private function createInteractEntity( label:String, type:String ):Entity
		{
			var assetVO:AssetVO = _assetModel.getEntityData(type);
			var entity:Entity   = ObjectPool.get(Entity);
			//detail component
			var detail:Detail   = ObjectPool.get(Detail);
			detail.init(CategoryEnum.VFX, assetVO);
			entity.add(detail);
			//animation component
			var anim:Animation  = ObjectPool.get(Animation);
			anim.init(type, label, true, 0, 30, true);
			anim.allowTransform = true;
			entity.add(anim);
			//assign the name
			entity.id = id;
			return entity;
		}

		public function destroyInteractEntity( entity:Entity ):Entity
		{
			if (entity)
			{
				destroyEntity(entity);
				ObjectPool.give(entity.remove(Detail));
				ObjectPool.give(entity.remove(Position));
				ObjectPool.give(entity.remove(Animation));
				if (entity.get(Grid))
					ObjectPool.give(entity.remove(Grid));
			}
			return null;
		}

		[Inject]
		public function set rangeBuilder( v:RangeBuilder ):void  { _rangeBuilder = v; }
		[Inject]
		public function set routeLineBuilder( v:RouteLineBuilder ):void  { _routeLineBuilder = v; }
		[Inject]
		public function set playerModel( v:PlayerModel ):void  { _playerModel = v; }
		[Inject]
		public function set sectorModel( v:SectorModel ):void  { _sectorModel = v; }

		private function get id():String
		{
			_id++;
			return "Interact" + _id;
		}
	}
}
