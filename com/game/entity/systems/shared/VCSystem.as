package com.game.entity.systems.shared
{
	import com.enum.CategoryEnum;
	import com.enum.TypeEnum;
	import com.game.entity.components.shared.Animation;
	import com.game.entity.components.shared.Detail;
	import com.game.entity.components.shared.VCList;
	import com.game.entity.components.starbase.Building;
	import com.game.entity.components.starbase.State;
	import com.game.entity.factory.IVCFactory;
	import com.game.entity.nodes.shared.visualComponent.IVCNode;
	import com.game.entity.nodes.shared.visualComponent.VCNode;
	import com.game.entity.nodes.shared.visualComponent.VCSpriteNode;
	import com.game.entity.nodes.shared.visualComponent.VCSpriteStarlingNode;
	import com.game.entity.nodes.shared.visualComponent.VCStarlingNode;
	import com.model.player.PlayerModel;
	import com.model.player.PlayerVO;
	import com.service.language.Localization;
	
	import org.ash.core.Entity;
	import org.ash.core.Game;
	import org.ash.core.NodeList;
	import org.ash.core.System;

	/**
	 * Certain entities will have a 'VCList' (aka Visual Component List) component. A VCList contains the names
	 * of additional entities that we want to display when the entity becomes visible (ie. it is given a Render).
	 * When the entity is no longer visible then the additional entities are also removed. This is useful for showing
	 * health bars, shields, turrets, building animations, etc.
	 */
	public class VCSystem extends System
	{
		[Inject(nodeType="IVCNode")]
		public var nodes:NodeList;

		[Inject(nodeType="IVCSpriteNode")]
		public var spriteNodes:NodeList;

		private var _game:Game;
		private var _playerModel:PlayerModel;
		private var _vcFactory:IVCFactory;

		override public function addToGame( game:Game ):void
		{
			var vcNode:VCNode;
			var vcsNode:VCStarlingNode;
			var vcSpriteNode:VCSpriteNode;
			var vcSpriteStarlingNode:VCSpriteStarlingNode;
			_game = game;
			nodes.nodeAdded.add(onNodeAdded);
			nodes.nodeRemoved.add(onNodeRemoved);
			spriteNodes.nodeAdded.add(onNodeAdded);
			spriteNodes.nodeRemoved.add(onNodeRemoved);
		}

		private function onNodeAdded( node:IVCNode ):void
		{
			var vcList:VCList = node.vcList;
			//if there are components already created for this vcList then we want to ignore this step
			if (vcList.components.length > 0)
				return;
			vcList.addCallbacks(addComponentToNode, rebuildComponent, removeComponentFromNode, node.ientity);
			var names:Array   = vcList.names;
			for (var i:int = 0; i < names.length; i++)
			{
				createComponentFromType(vcList, names[i], node.ientity);
			}
		}

		private function addComponentToNode( entity:Entity, type:String ):void
		{
			var vcList:VCList = entity.get(VCList);
			//only create the component if this class has been initialized
			if ((nodes.head || spriteNodes.head) && Animation(entity.get(Animation)).render != null)
				createComponentFromType(vcList, type, entity);
		}

		private function rebuildComponent( entity:Entity, type:String ):void
		{
			removeComponentFromNode(entity, type);
			addComponentToNode(entity, type);
		}

		private function removeComponentFromNode( entity:Entity, type:String ):void
		{
			var vcList:VCList = entity.get(VCList);
			for (var j:int = 0; j < vcList.components.length; j++)
			{
				if (Detail(vcList.components[j].get(Detail)).type == type)
				{
					switch (type)
					{
						default:
							_vcFactory.destroyComponent(vcList.components[j]);
							break;
					}
					vcList.components.splice(j, 1);
				}
			}
		}

		private function createComponentFromType( vcList:VCList, type:String, entity:Entity ):void
		{
			var animation:Animation;
			var component:Entity;
			switch (type)
			{
				case TypeEnum.BUILDING_ANIMATION:
					component = _vcFactory.createBuildingAnimation(Building(entity.get(Building)).buildingVO, entity);
					if (component)
						vcList.addComponent(component);
					break;
				case TypeEnum.BUILDING_CONSTRUCTION:
					vcList.addComponent(_vcFactory.createBuildingConstruction(Building(entity.get(Building)).buildingVO, entity));
					break;
				case TypeEnum.RESOURCE_DEPOT_CANISTER:
					vcList.addComponent(_vcFactory.createDepotCannisters(entity));
					break;
				case TypeEnum.HEALTH_BAR:
					vcList.addComponent(_vcFactory.createHealthBar(entity));
					break;
				case TypeEnum.DEBUFF_TRAY:
					vcList.addComponent(_vcFactory.createDebuffTray(entity));
					break;
				case TypeEnum.ISO_1x1_IGA:
				case TypeEnum.ISO_1x1_SOVEREIGNTY:
				case TypeEnum.ISO_1x1_TYRANNAR:
				case TypeEnum.ISO_2x2_IGA:
				case TypeEnum.ISO_2x2_SOVEREIGNTY:
				case TypeEnum.ISO_2x2_TYRANNAR:
				case TypeEnum.ISO_3x3_IGA:
				case TypeEnum.ISO_3x3_SOVEREIGNTY:
				case TypeEnum.ISO_3x3_TYRANNAR:
					vcList.addComponent(_vcFactory.createIsoSquare(entity, type));
					break;
				case TypeEnum.NAME:
					var detail:Detail = entity.get(Detail);
					var name:String   = '';
					var vo:PlayerVO   = _playerModel.getPlayer(detail.ownerID);
					if (vo)
					{
						var locName:String = vo.name;
						if (locName.indexOf('NPC.') != -1)
							locName = Localization.instance.getString(vo.name);

						if (detail.category != CategoryEnum.SHIP)
						{
							var level:int;
							if (vo.isNPC)
								level = detail.baseLevel;
							else
								level = vo.level;

							name = "(" + level + ") " + locName;
						} else
						{
							name = ((vo.isNPC) ? "(" + detail.level + ") " : "") + locName;
						}
						if(vo.isNPC)
						{
							if(detail.maxPlayersPerFaction == 1)
								name += "\n(Solo Target)";
							else if( detail.maxPlayersPerFaction > 1)
								name += "\n(Max " + detail.maxPlayersPerFaction + ")";
								
						}
						else
							name += ((vo.allianceName != '') ? '\n(' + vo.allianceName + ')' : '');
						
					}

					component = _vcFactory.createName(entity, name);
					animation = component.get(Animation);
					if (detail.category == CategoryEnum.SECTOR)
					{
						if (detail.type == TypeEnum.STARBASE_SECTOR_IGA ||
							detail.type == TypeEnum.STARBASE_SECTOR_SOVEREIGNTY ||
							detail.type == TypeEnum.STARBASE_SECTOR_TYRANNAR)
							animation.offsetY = Animation(entity.get(Animation)).render.height * .50;
						else
							animation.offsetY = Animation(entity.get(Animation)).render.height * .60;
					} else
						animation.offsetY = Animation(entity.get(Animation)).render.height * .29;
					vcList.addComponent(component);
					break;
				case TypeEnum.BUILDING_SHIELD:
				case TypeEnum.TURRET_SHIELD:
					component = _vcFactory.createBuildingShield(Building(entity.get(Building)).buildingVO, entity);
					if (component)
						vcList.addComponent(component);
					break;
				case TypeEnum.SHIELD:
					vcList.addComponent(_vcFactory.createShield(entity));
					break;
				case TypeEnum.STATE_BAR:
					var state:State   = entity.get(State);
					component = _vcFactory.createStateBar(entity, state.text);
					Animation(component.get(Animation)).scaleX = State(entity.get(State)).percentageDone;
					vcList.addComponent(component);
					break;
				case TypeEnum.STARBASE_TURRET:
					component = _vcFactory.createTurret(Building(entity.get(Building)).buildingVO, entity);
					if (component)
						vcList.addComponent(component);
					break;
				case TypeEnum.STARBASE_SHIELD_IGA:
				case TypeEnum.STARBASE_SHIELD_SOVEREIGNTY:
				case TypeEnum.STARBASE_SHIELD_TYRANNAR:
					vcList.addComponent(_vcFactory.createStarbaseShield(entity));
					break;
			}
		}

		private function onNodeRemoved( node:IVCNode ):void
		{
			var vcList:VCList              = node.vcList;
			var components:Vector.<Entity> = vcList.components;
			for (var i:int = 0; i < components.length; i++)
			{
				_vcFactory.destroyComponent(components[i]);
			}
			vcList.components.length = 0;
			vcList.removeCallbacks();
		}

		[Inject]
		public function set playerModel( v:PlayerModel ):void  { _playerModel = v; }
		[Inject]
		public function set vcFactory( v:IVCFactory ):void  { _vcFactory = v; }

		override public function removeFromGame( game:Game ):void
		{
			_game = null;
			nodes.nodeAdded.remove(onNodeAdded);
			nodes.nodeRemoved.remove(onNodeRemoved);
			nodes = null;
			spriteNodes.nodeAdded.remove(onNodeAdded);
			spriteNodes.nodeRemoved.remove(onNodeRemoved);
			spriteNodes = null;
			_playerModel = null;
			_vcFactory = null;
		}
	}
}
