package com.game.entity.systems.starbase
{
	import com.Application;
	import com.controller.sound.SoundController;
	import com.enum.StarbaseConstructionEnum;
	import com.enum.TypeEnum;
	import com.event.StateEvent;
	import com.game.entity.components.shared.Position;
	import com.game.entity.components.shared.Pylon;
	import com.game.entity.components.shared.fsm.FSM;
	import com.game.entity.components.starbase.Building;
	import com.game.entity.components.starbase.Platform;
	import com.game.entity.factory.IInteractFactory;
	import com.game.entity.factory.IStarbaseFactory;
	import com.game.entity.nodes.starbase.BuildingNode;
	import com.game.entity.nodes.starbase.PlatformNode;
	import com.model.battle.BattleModel;
	import com.model.player.CurrentUser;
	import com.model.prototype.IPrototype;
	import com.model.starbase.BuildingVO;
	import com.model.starbase.StarbaseModel;
	import com.util.AllegianceUtil;
	import com.util.statcalc.StatCalcUtil;

	import flash.geom.Rectangle;
	import flash.utils.Dictionary;

	import org.ash.core.Entity;
	import org.ash.core.Game;
	import org.ash.core.NodeList;
	import org.ash.core.System;
	import org.console.Cc;
	import org.shared.ObjectPool;
	import org.starling.core.Starling;

	public class StarbaseSystem extends System
	{
		public static const BUILDING_DAMAGED_HEALTH:Number = .6;
		public static const DEPTH_SORT_ALL:String          = "depthSortAll";
		public static const DEPTH_SORT_BUILDINGS:String    = "depthSortBuildings";
		public static const DEPTH_SORT_PLATFORMS:String    = "depthSortPlatforms";

		[Inject(nodeType="com.game.entity.nodes.starbase.BuildingNode")]
		public var buildingNodes:NodeList;

		[Inject(nodeType="com.game.entity.nodes.starbase.PlatformNode")]
		public var platformNodes:NodeList;

		private var _battleModel:BattleModel;
		private var _boundsRect1:Rectangle;
		private var _boundsRect2:Rectangle;
		private var _color:uint;
		private var _depth:uint;
		private var _depthDependency:Dictionary;
		private var _depthVisited:Dictionary;
		private var _forceFields:Dictionary;
		private var _game:Game;
		private var _generatorRanges:Vector.<Entity>;
		private var _generators:Vector.<BuildingNode>;
		private var _interactFactory:IInteractFactory;
		private var _pylonRanges:Vector.<Entity>;
		private var _pylons:Vector.<BuildingNode>;
		private var _resourceDepots:Vector.<BuildingNode>;
		private var _soundController:SoundController;
		private var _starbaseModel:StarbaseModel;
		private var _starbaseFactory:IStarbaseFactory;
		private var _turretRanges:Vector.<Entity>;
		private var _turrets:Vector.<BuildingNode>;

		override public function addToGame( game:Game ):void
		{
			buildingNodes.nodeAdded.add(onBuildingNodeAdded);
			buildingNodes.nodeRemoved.add(onBuildingNodeRemoved);

			_boundsRect1 = new Rectangle();
			_boundsRect2 = new Rectangle();
			_color = AllegianceUtil.instance.getFactionColor(CurrentUser.faction);
			_depthDependency = new Dictionary();
			_depthVisited = new Dictionary();
			_forceFields = new Dictionary();
			_generatorRanges = new Vector.<Entity>;
			_generators = new Vector.<BuildingNode>;
			_pylonRanges = new Vector.<Entity>;
			_pylons = new Vector.<BuildingNode>;
			_resourceDepots = new Vector.<BuildingNode>;
			_turretRanges = new Vector.<Entity>;
			_turrets = new Vector.<BuildingNode>;

			_starbaseModel.addListener(updateResourceDepots);
			Cc.addSlashCommand('forceContextLoss', forceContextLoss);
			Cc.addSlashCommand('showGrid', onShowGrid);
		}

		public function createBuildingsFromStarbase():void
		{
			var buildings:Vector.<BuildingVO> = _starbaseModel.buildings;
			for (var i:int = 0; i < buildings.length; i++)
			{
				if (buildings[i].constructionCategory == StarbaseConstructionEnum.PLATFORM)
					_starbaseFactory.createBaseItem(buildings[i].id, buildings[i]);
				else
					_starbaseFactory.createBuilding(buildings[i].id, buildings[i]);
			}
			//show the platform
			_starbaseFactory.createStarbasePlatform(CurrentUser.id);
			findPylonConnections();
			depthSort(DEPTH_SORT_ALL);
		}

		private function onBuildingNodeAdded( node:BuildingNode ):void
		{
			node.init(onBuildingHealthChanged);
			switch (node.building.buildingVO.itemClass)
			{
				case TypeEnum.POINT_DEFENSE_PLATFORM:
					_turrets.push(node);
					break;
				case TypeEnum.PYLON:
					node.$pylon.node = node;
					_pylons.push(node);
					break;
				case TypeEnum.COMMAND_CENTER:
				case TypeEnum.RESOURCE_DEPOT:
					if (node.building.buildingVO.itemClass == TypeEnum.RESOURCE_DEPOT)
						_resourceDepots.push(node);
					else
						_resourceDepots.unshift(node);
					updateResourceDepots();
					break;
				case TypeEnum.SHIELD_GENERATOR:
					_generators.push(node);
					break;
			}
		}

		private function onBuildingNodeRemoved( node:BuildingNode ):void
		{
			var index:int;
			switch (node.building.buildingVO.itemClass)
			{
				case TypeEnum.FORCEFIELD:
					if (node.entity.has(FSM))
						ObjectPool.give(node.entity.remove(FSM));
					break;
				case TypeEnum.POINT_DEFENSE_PLATFORM:
					index = _turrets.indexOf(node);
					if (index > -1)
						_turrets.splice(index, 1);
					break;
				case TypeEnum.PYLON:
					index = _pylons.indexOf(node);
					if (index > -1)
						_pylons.splice(index, 1);
					break;
				case TypeEnum.COMMAND_CENTER:
				case TypeEnum.RESOURCE_DEPOT:
					index = _resourceDepots.indexOf(node);
					if (index > -1)
					{
						_resourceDepots.splice(index, 1);
						updateResourceDepots();
					}
					break;
				case TypeEnum.SHIELD_GENERATOR:
					index = _generators.indexOf(node);
					if (index > -1)
						_generators.splice(index, 1);
					break;
			}
			node.destroy();
		}

		private function onBuildingHealthChanged( node:BuildingNode, percent:Number, change:Number ):void
		{
			if (node.building.buildingVO.destroyed && percent > 0)
			{
				//restore the building from its' damaged state
				_starbaseFactory.updateStarbaseBuilding(node.entity);
				if (Application.STATE == StateEvent.GAME_STARBASE && node.building.buildingVO.itemClass == TypeEnum.PYLON)
					findPylonConnections(node.entity, true);
			} else if (node.building.buildingVO.damaged && percent >= BUILDING_DAMAGED_HEALTH)
			{
				//restore the building from its' damaged state
				_starbaseFactory.updateStarbaseBuilding(node.entity);
			} else if (percent < BUILDING_DAMAGED_HEALTH && !node.building.buildingVO.damaged)
			{
				_starbaseFactory.updateStarbaseBuilding(node.entity);
			} else if (percent == 0 && !node.building.buildingVO.destroyed)
				_starbaseFactory.updateStarbaseBuilding(node.entity);
		}

		private function updateResourceDepots():void
		{
			var cCredits:uint;
			var cResources:uint;
			var dCredits:uint;
			var dResources:uint;
			if (Application.STATE == StateEvent.GAME_BATTLE || Application.STATE == StateEvent.GAME_BATTLE_INIT)
			{
				dCredits = _battleModel.credits;
				dResources = _battleModel.alloy + _battleModel.energy + _battleModel.synthetic;
			} else
			{
				dCredits = _starbaseModel.currentBase.credits;
				dResources = _starbaseModel.currentBase.alloy + _starbaseModel.currentBase.energy + _starbaseModel.currentBase.synthetic;
			}
			var mCredits:uint;
			var mResources:uint;
			var percent:Number;
			for (var i:int = 0; i < _resourceDepots.length; i++)
			{
				mCredits = StatCalcUtil.buildingStatCalc("CreditCap", _resourceDepots[i].building.buildingVO);
				mResources = StatCalcUtil.buildingStatCalc("ResourceCap", _resourceDepots[i].building.buildingVO) * 3;
				cCredits = (dCredits < mCredits) ? dCredits : mCredits;
				cResources = (dResources < mResources) ? dResources : mResources;
				dCredits -= cCredits;
				dResources -= cResources;
				percent = (cCredits + cResources) / (mCredits + mResources);
				//we only care about percents in 25% increments
				if (percent >= 1)
					percent = 1;
				else if (percent >= .75)
					percent = .75;
				else if (percent >= .5)
					percent = .5;
				else if (percent >= .25)
					percent = .25;
				else
					percent = 0;
				if (_resourceDepots[i].building.buildingVO.percentFilled != percent)
				{
					_resourceDepots[i].building.buildingVO.percentFilled = percent;
					if (i > 0)
						_starbaseFactory.updateStarbaseBuilding(_resourceDepots[i].entity);
				}
			}
		}

		//============================================================================================================
		//************************************************************************************************************
		//											Point Defense Platforms
		//************************************************************************************************************
		//============================================================================================================

		public function showTurretRanges( target:Entity, show:Boolean = true ):void
		{
			if (_turretRanges.length > 0 && !show)
			{
				//remove the ranges if needed
				for (var i:int = 0; i < _turretRanges.length; i++)
					_interactFactory.destroyInteractEntity(_turretRanges[i]);
				_turretRanges.length = 0;
			}

			//cycle through the existing turrets and add ranges to those that need
			if (show)
			{
				if (target == null)
				{
					for (i = 0; i < _turrets.length; i++)
						_turretRanges.push(_interactFactory.createRange(_turrets[i].entity));
				} else
					_turretRanges.push(_interactFactory.createRange(target));
			}
		}

		//============================================================================================================
		//************************************************************************************************************
		//													Pylon 
		//************************************************************************************************************
		//============================================================================================================

		public function showPylonRanges( target:Entity, show:Boolean = true ):void
		{
			if (_pylonRanges.length > 0 && !show)
			{
				//remove the ranges if needed
				for (var i:int = 0; i < _pylonRanges.length; i++)
					_interactFactory.destroyInteractEntity(_pylonRanges[i]);
				_pylonRanges.length = 0;
			}

			//cycle through the existing pylons and add ranges to those that need
			if (show)
			{
				if (target == null)
				{
					for (i = 0; i < _pylons.length; i++)
						_pylonRanges.push(_interactFactory.createRange(_pylons[i].entity));
				} else
					_pylonRanges.push(_interactFactory.createRange(target));
			}
		}

		public function positionPylonBase( entity:Entity ):void
		{
			var building:Building  = entity.get(Building);
			var position:Position  = entity.get(Position);
			var pylon:Pylon        = entity.get(Pylon);

			pylon.baseX = building.buildingVO.baseX;
			pylon.baseY = building.buildingVO.baseY;
			var platform:Platform  = pylon.bottom.get(Platform);
			platform.buildingVO.baseX = building.buildingVO.baseX;
			platform.buildingVO.baseY = building.buildingVO.baseY;
			var positionB:Position = pylon.bottom.get(Position);
			positionB.x = position.x;
			positionB.y = position.y;
			depthSort(DEPTH_SORT_PLATFORMS);
		}

		public function findPylonConnections( target:Entity = null, disable:Boolean = false ):void
		{
			if (target)
				findPylonConnectionsForEntity(target, disable);
			else
				findPylonConnectionsForAll();
		}

		private function findPylonConnectionsForAll():void
		{
			var pylonA:BuildingNode;
			var pylonB:BuildingNode;

			for (var i:int = 0; i < _pylons.length; i++)
			{
				pylonA = _pylons[i];
				if (pylonA.building.buildingVO.currentHealth < 1 || !pylonA.building.buildingVO.built)
					continue;
				for (var j:int = i + 1; j < _pylons.length; j++)
				{
					pylonB = _pylons[j];
					if (pylonB.building.buildingVO.currentHealth < 1 || !pylonB.building.buildingVO.built)
						continue;
					checkConnection(pylonA, pylonB);
				}
			}
		}

		private function findPylonConnectionsForEntity( target:Entity, disable:Boolean ):void
		{
			var pylonA:BuildingNode = Pylon(target.get(Pylon)).node;
			var pylonB:BuildingNode;

			if (disable)
			{
				if (pylonA.$pylon.bottomConnection)
				{
					_starbaseFactory.destroyStarbaseItem(_game.getEntity(pylonA.$pylon.bottomWallKey));
					pylonA.$pylon.removeConnection(pylonA.$pylon.bottomConnection);
				}
				if (pylonA.$pylon.leftConnection)
				{
					_starbaseFactory.destroyStarbaseItem(_game.getEntity(pylonA.$pylon.leftWallKey));
					pylonA.$pylon.removeConnection(pylonA.$pylon.leftConnection);
				}
				if (pylonA.$pylon.rightConnection)
				{
					_starbaseFactory.destroyStarbaseItem(_game.getEntity(pylonA.$pylon.rightWallKey));
					pylonA.$pylon.removeConnection(pylonA.$pylon.rightConnection);
				}
				if (pylonA.$pylon.topConnection)
				{
					_starbaseFactory.destroyStarbaseItem(_game.getEntity(pylonA.$pylon.topWallKey));
					pylonA.$pylon.removeConnection(pylonA.$pylon.topConnection);
				}
				return;
			}

			if (pylonA.building.buildingVO.currentHealth < 1 || !pylonA.building.buildingVO.built)
				return;

			//update pylon position to match building
			pylonA.$pylon.baseX = pylonA.building.buildingVO.baseX;
			pylonA.$pylon.baseY = pylonA.building.buildingVO.baseY;

			for (var i:int = 0; i < _pylons.length; i++)
			{
				pylonB = _pylons[i];
				if (pylonB == pylonA || pylonB.building.buildingVO.currentHealth < 1 || !pylonB.building.buildingVO.built)
					continue;
				checkConnection(pylonA, pylonB, true);
			}
		}

		private function checkConnection( pylonA:BuildingNode, pylonB:BuildingNode, checkBOnNoConnection:Boolean = false ):void
		{
			var distance:int;
			var j:int;
			var result:Object;
			var maxLength:int;
			var startX:int;
			var startY:int;
			var endX:int;
			var endY:int;

			//ensure at least one of the pylons is in range of the other
			distance = -1;
			if (pylonA.building.buildingVO.baseX == pylonB.building.buildingVO.baseX)
				distance = Math.abs(pylonA.building.buildingVO.baseY - pylonB.building.buildingVO.baseY);
			else if (pylonA.building.buildingVO.baseY == pylonB.building.buildingVO.baseY)
				distance = Math.abs(pylonA.building.buildingVO.baseX - pylonB.building.buildingVO.baseX);
			distance *= 18;
			maxLength = Math.max(pylonA.building.buildingVO.shieldRadius * 90, pylonB.building.buildingVO.shieldRadius * 90);
			if (distance > 90 && distance <= maxLength)
			{
				//one final check to ensure there is not a building in the path of the forcefield
				startX = pylonA.$pylon.baseX < pylonB.$pylon.baseX ? pylonA.$pylon.baseX : pylonB.$pylon.baseX;
				if (pylonA.$pylon.baseX != pylonB.$pylon.baseX)
					startX += 5;
				startY = pylonA.$pylon.baseY < pylonB.$pylon.baseY ? pylonA.$pylon.baseY : pylonB.$pylon.baseY;
				if (pylonA.$pylon.baseY != pylonB.$pylon.baseY)
					startY += 5;
				endX = Math.abs(pylonA.$pylon.baseX - pylonB.$pylon.baseX) - 10;
				endX = (endX < 0) ? 5 : endX + 5;
				endY = Math.abs(pylonA.$pylon.baseY - pylonB.$pylon.baseY) - 10;
				endY = (endY < 0) ? 5 : endY + 5;
				_boundsRect1.setTo(startX, startY, endX, endY);
				for (var node:BuildingNode = buildingNodes.head; node; node = node.next)
				{
					if (node.building.buildingVO.itemClass == TypeEnum.FORCEFIELD || node == pylonA || node == pylonB)
						continue;
					_boundsRect2.setTo(node.building.buildingVO.baseX, node.building.buildingVO.baseY, node.building.buildingVO.sizeX, node.building.buildingVO.sizeY);
					if (_boundsRect1.intersects(_boundsRect2) || _boundsRect1.containsRect(_boundsRect2))
					{
						//remove the connecting forcefield because there is a building in the way
						pylonA.$pylon.removeConnection(pylonB);
						if (_game.getEntity(pylonA.$pylon.craftKey(pylonB)))
							_starbaseFactory.destroyStarbaseItem(_game.getEntity(pylonA.$pylon.craftKey(pylonB)));
						return;
					}
				}

				//there is no building in the way so add the connection
				result = pylonA.$pylon.addConnection(pylonB);
				if (result)
				{
					if (result.added)
						_starbaseFactory.createForcefield(result.added, pylonA.$pylon, pylonB.$pylon, _color);
					if (result.removed)
						_starbaseFactory.destroyStarbaseItem(_game.getEntity(result.removed));
				}
				result = pylonB.$pylon.addConnection(pylonA);
				if (result)
				{
					if (result.added)
						_starbaseFactory.createForcefield(result.added, pylonA.$pylon, pylonB.$pylon, _color);
					if (result.removed)
						_starbaseFactory.destroyStarbaseItem(_game.getEntity(result.removed));
				}
			} else if (_game.getEntity(pylonA.$pylon.craftKey(pylonB)))
			{
				pylonA.$pylon.removeConnection(pylonB);
				_starbaseFactory.destroyStarbaseItem(_game.getEntity(pylonA.$pylon.craftKey(pylonB)));
				if (checkBOnNoConnection)
					findPylonConnections(pylonB.entity);
			}
		}

		//============================================================================================================
		//************************************************************************************************************
		//												Shield Generators
		//************************************************************************************************************
		//============================================================================================================

		public function showShieldRanges( target:Entity, show:Boolean = true ):void
		{
			if (_generatorRanges.length > 0 && !show)
			{
				//remove the ranges if needed
				for (var i:int = 0; i < _generatorRanges.length; i++)
					_interactFactory.destroyInteractEntity(_generatorRanges[i]);
				_generatorRanges.length = 0;
			}

			//cycle through the existing generators and add ranges to those that need
			if (show)
			{
				if (target == null)
				{
					for (i = 0; i < _generators.length; i++)
						_generatorRanges.push(_interactFactory.createRange(_generators[i].entity));
				} else
					_generatorRanges.push(_interactFactory.createRange(target));
			}
		}

		public function showShields( forceOff:Boolean = false, selectedGenerator:Entity = null ):void
		{
			//brute force checks to see if a building has a shield
			var active:Boolean;
			var distance:Number;
			var distanceX:Number;
			var distanceY:Number;
			var generator:BuildingNode;
			var module:IPrototype;
			var position:Position;
			var size:Number;
			var slot:String;
			var type:String;
			for (var node:BuildingNode = buildingNodes.head; node; node = node.next)
			{
				active = false;
				size = node.building.buildingVO.sizeX * .5;
				type = node.building.buildingVO.itemClass == TypeEnum.POINT_DEFENSE_PLATFORM ? TypeEnum.TURRET_SHIELD : TypeEnum.BUILDING_SHIELD;
				if (!forceOff && node.building.buildingVO.itemClass != TypeEnum.FORCEFIELD)
				{
					for (var i:int = 0; i < _generators.length; i++)
					{
						if (_generators[i] != node && (selectedGenerator == null || selectedGenerator == _generators[i].entity))
						{
							slot = _generators[i].building.buildingVO.getValue("slots")[0];
							module = (_generators[i].building.buildingVO.modules.hasOwnProperty(slot)) ? _generators[i].building.buildingVO.modules[slot] : null;
							if (module)
							{
								generator = _generators[i];
								distanceX = (node.building.buildingVO.baseX + size) - (generator.building.buildingVO.baseX + 2.5);
								distanceY = (node.building.buildingVO.baseY + size) - (generator.building.buildingVO.baseY + 2.5);
								distance = Math.sqrt((distanceX * distanceX) + (distanceY * distanceY));
								if (distance < (Math.round(generator.building.buildingVO.shieldRadius / 18)))
								{
									active = true;
									break;
								}
							}
						}
					}
				}
				if (active)
				{
					if (node.$vcList && !node.$vcList.hasComponentType(type))
						node.$vcList.addComponentType(type);
				} else if (node.$vcList)
					node.$vcList.removeComponentType(type);
			}
		}

		//============================================================================================================
		//************************************************************************************************************
		//												Depth Sorting 
		//************************************************************************************************************
		//============================================================================================================

		public function depthSort( type:String ):void
		{
			if (type == DEPTH_SORT_ALL || type == DEPTH_SORT_PLATFORMS)
				depthSortPlatforms();
			if (type == DEPTH_SORT_ALL || type == DEPTH_SORT_BUILDINGS)
				depthSortBuildings();
		}

		private function depthSortPlatforms():void
		{
			var platformNode:PlatformNode;
			var platformNodeInner:PlatformNode;
			var vo:BuildingVO;
			var voInner:BuildingVO;
			for (platformNode = platformNodes.head; platformNode; platformNode = platformNode.next)
			{
				var behind:Array  = [];
				vo = platformNode.platform.buildingVO;
				var rightA:Number = vo.baseX + vo.sizeX;
				var frontA:Number = vo.baseY + vo.sizeY;

				for (platformNodeInner = platformNodes.head; platformNodeInner; platformNodeInner = platformNodeInner.next)
				{
					voInner = platformNodeInner.platform.buildingVO;

					// See if B should go behind A
					// simplest possible check, interpenetrations also count as "behind", which does do a bit more work later, but the inner loop tradeoff for a faster check makes up for it
					if ((voInner.baseX < rightA) &&
						(voInner.baseY < frontA) &&
						(platformNode !== platformNodeInner))
					{
						behind.push(platformNodeInner);
					}
				}

				_depthDependency[platformNode] = behind;
			}
			// Set the childrens' depth, using dependency ordering
			_depth = 0;
			for (platformNode = platformNodes.head; platformNode; platformNode = platformNode.next)
				if (true !== _depthVisited[platformNode])
					place(platformNode);

			// Clear out temporary dictionary so we're not retaining memory between calls
			_depthDependency = new Dictionary();
			_depthVisited = new Dictionary();
		}

		private function depthSortBuildings():void
		{
			var buildingNode:BuildingNode;
			var buildingNodeInner:BuildingNode;
			var vo:BuildingVO;
			var voInner:BuildingVO;
			for (buildingNode = buildingNodes.head; buildingNode; buildingNode = buildingNode.next)
			{
				var behind:Array  = [];
				vo = buildingNode.building.buildingVO;
				var rightA:Number = vo.baseX + vo.sizeX;
				var frontA:Number = vo.baseY + vo.sizeY;

				for (buildingNodeInner = buildingNodes.head; buildingNodeInner; buildingNodeInner = buildingNodeInner.next)
				{
					voInner = buildingNodeInner.building.buildingVO;

					// See if B should go behind A
					// simplest possible check, interpenetrations also count as "behind", which does do a bit more work later, but the inner loop tradeoff for a faster check makes up for it
					if ((voInner.baseX < rightA) &&
						(voInner.baseY < frontA) &&
						(buildingNode != buildingNodeInner))
					{
						behind.push(buildingNodeInner);
					}
				}

				_depthDependency[buildingNode] = behind;
			}
			// Set the childrens' depth, using dependency ordering
			_depth = 0;
			for (buildingNode = buildingNodes.head; buildingNode; buildingNode = buildingNode.next)
				if (true !== _depthVisited[buildingNode])
					place(buildingNode);

			// Clear out temporary dictionary so we're not retaining memory between calls
			_depthDependency = new Dictionary();
			_depthVisited = new Dictionary();
		}

		/**
		 * Dependency-ordered depth placement of the given objects and its dependencies.
		 */
		private function place( nodeToPlace:* ):void
		{
			_depthVisited[nodeToPlace] = true;

			var node:*;
			for (var i:int = 0; i < _depthDependency[nodeToPlace].length; i++)
			{
				node = _depthDependency[nodeToPlace][i];
				if (true !== _depthVisited[node])
					place(node);
			}

			nodeToPlace.position.depth = _depth;

			_depth += 1;
		}

		private function onShowGrid():void
		{
			_starbaseModel.grid.showGrid(_game, _starbaseFactory);
		}

		private function forceContextLoss():void
		{
			Starling.current.context.dispose();
		}

		[Inject]
		public function set battleModel( v:BattleModel ):void  { _battleModel = v; }
		[Inject]
		public function set game( v:Game ):void  { _game = v; }
		public function get generators():Vector.<BuildingNode>  { return _generators; }
		[Inject]
		public function set interactFactory( v:IInteractFactory ):void  { _interactFactory = v; }
		[Inject]
		public function set soundController( v:SoundController ):void  { _soundController = v; }
		[Inject]
		public function set starbaseModel( v:StarbaseModel ):void  { _starbaseModel = v; }
		[Inject]
		public function set starbaseFactory( v:IStarbaseFactory ):void  { _starbaseFactory = v; }

		override public function removeFromGame( game:Game ):void
		{
			showShieldRanges(null, false);
			showTurretRanges(null, false);
			buildingNodes.nodeAdded.remove(onBuildingNodeAdded);
			buildingNodes.nodeRemoved.remove(onBuildingNodeRemoved);
			buildingNodes = null;
			_boundsRect1 = null;
			_boundsRect2 = null;
			_depthDependency = null;
			_generatorRanges = null;
			_generators.length = 0;
			_generators = null;
			_pylonRanges = null;
			_pylons.length = 0;
			_pylons = null;
			_resourceDepots.length = 0;
			_resourceDepots = null;
			_soundController = null;
			_turretRanges = null;
			_turrets.length = 0;
			_turrets = null;
			platformNodes = null;
			_depthVisited = null;
			_game = null;
			_starbaseModel.removeListener(updateResourceDepots);
		}
	}
}

