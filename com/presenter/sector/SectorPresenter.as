package com.presenter.sector
{
	import com.Application;
	import com.controller.ServerController;
	import com.controller.transaction.TransactionController;
	import com.enum.TypeEnum;
	import com.enum.server.OrderEnum;
	import com.enum.server.ProtocolEnum;
	import com.enum.server.RequestEnum;
	import com.event.BattleEvent;
	import com.event.MissionEvent;
	import com.event.SectorEvent;
	import com.event.StarbaseEvent;
	import com.game.entity.components.battle.Attack;
	import com.game.entity.components.sector.Mission;
	import com.game.entity.components.shared.Detail;
	import com.game.entity.components.shared.Position;
	import com.game.entity.systems.interact.SectorInteractSystem;
	import com.model.alliance.AllianceModel;
	import com.model.asset.AssetVO;
	import com.model.fleet.FleetModel;
	import com.model.fleet.FleetVO;
	import com.model.mission.MissionModel;
	import com.model.mission.MissionVO;
	import com.model.player.PlayerModel;
	import com.model.player.PlayerVO;
	import com.model.prototype.PrototypeModel;
	import com.model.sector.SectorModel;
	import com.model.sector.SectorVO;
	import com.model.starbase.BaseVO;
	import com.model.starbase.StarbaseModel;
	import com.model.battle.BattleModel;
	import com.presenter.shared.GamePresenter;
	import com.service.server.outgoing.sector.SectorOrderRequest;
	import com.service.server.outgoing.sector.SectorSetViewLocationRequest;
	
	import com.service.ExternalInterfaceAPI;
	import com.event.ServerEvent;
	import com.model.prototype.IPrototype
	

	import org.ash.core.Entity;
	import org.osflash.signals.Signal;
	import org.robotlegs.extensions.presenter.impl.Presenter;

	public class SectorPresenter extends GamePresenter implements ISectorPresenter
	{
		private var _destinations:Vector.<SectorVO>;
		private var _fleetModel:FleetModel;
		private var _missionModel:MissionModel;
		private var _playerModel:PlayerModel;
		private var _onBattleSignal:Signal;
		private var _onInteractSignal:Signal;
		private var _onNotificationSignal:Signal;
		private var _sectorModel:SectorModel;
		private var _serverController:ServerController;
		private var _transactionController:TransactionController;
		private var _starbaseModel:StarbaseModel;
		private var _system:SectorInteractSystem;
		private var _allianceModel:AllianceModel;

		[PostConstruct]
		override public function init():void
		{
			super.init();
			_destinations = new Vector.<SectorVO>;
			_onBattleSignal = new Signal(Entity, Boolean, String);
			_onInteractSignal = new Signal(int, int, Entity, Entity);
			_onNotificationSignal = new Signal(String, Entity);
			_system = SectorInteractSystem(_game.getSystem(SectorInteractSystem));
			_system.presenter = this;
		}

		public function onInteractionWithSectorEntity( x:int, y:int, entity:Entity, selectedEntity:Entity ):void
		{
			_onInteractSignal.dispatch(x, y, entity, selectedEntity);
		}

		public function onBattle():void
		{
			var entity:Entity = _system.selected;
			if (entity)
			{
				var fleetVO:FleetVO = _fleetModel.getFleet(entity.id);
				if (fleetVO)
					_onBattleSignal.dispatch(entity, fleetVO.inBattle, fleetVO.battleServerAddress);
			}
		}

		public function joinBattle( battleServerAddress:String ):void
		{
			var event:BattleEvent = new BattleEvent(BattleEvent.BATTLE_JOIN, battleServerAddress);
			dispatch(event);
		}

		public function attackEntity( entity:Entity, ignoreVerification:Boolean = false ):void
		{
			//attack the target
			if (_system.selected && entity)
			{
				var detail:Detail = entity.get(Detail);
				if(detail == null)
					return;
				
				var showMission:Boolean = false;
				//if this is a mission entity we only want to attack after showing the mission intro
				if (entity.has(Mission))
				{
					var mission:MissionVO = _missionModel.currentMission;
					if (!mission.accepted)
					{
						showMission = true;
						var missionEvent:MissionEvent = new MissionEvent(MissionEvent.MISSION_GREETING);
						dispatch(missionEvent);
					}
				}
				var attack:Boolean = (ignoreVerification) ? true : false;
				if (!ignoreVerification)
				{
					attack = true;
					if (detail.type == TypeEnum.STARBASE_SECTOR_IGA || detail.type == TypeEnum.STARBASE_SECTOR_SOVEREIGNTY || detail.type == TypeEnum.STARBASE_SECTOR_TYRANNAR)
					{
						var selectedEntityPlayer:PlayerVO = getPlayer(detail.ownerID);
						if(selectedEntityPlayer)
						{
							if (!selectedEntityPlayer.isNPC && _starbaseModel.currentBase.bubbleTimeRemaining > 0)
							{
								_onNotificationSignal.dispatch('bubble', entity);
								attack = false;
							}
							
							if (attack && Application.NETWORK == Application.NETWORK_GUEST && !selectedEntityPlayer.isNPC)
							{
								attack = false;
								ExternalInterfaceAPI.logConsole("Guest Attack Restriction");
								var serverEvent:ServerEvent
								serverEvent = new ServerEvent(ServerEvent.GUEST_RESTRICTION);
								_eventDispatcher.dispatchEvent(serverEvent);
							}
						}
					}
				}
				if (!showMission && attack)
				{
					var order:SectorOrderRequest = SectorOrderRequest(_serverController.getRequest(ProtocolEnum.SECTOR_CLIENT, RequestEnum.SECTOR_ISSUE_ORDER));
					order.entityId = _system.selected.id;
					order.orderType = OrderEnum.ATTACK;
					order.targetId = entity.id;
					_serverController.send(order);
				}
			}
		}

		public function tackleEntity( entity:Entity, ignoreVerification:Boolean = false ):void
		{
			//attack the target
			if (_system.selected && entity)
			{
				var detail:Detail = entity.get(Detail);
				var showMission:Boolean = false;
				//if this is a mission entity we only want to attack after showing the mission intro
				if (entity.has(Mission))
				{
					var mission:MissionVO = _missionModel.currentMission;
					if (!mission.accepted)
					{
						showMission = true;
						var missionEvent:MissionEvent = new MissionEvent(MissionEvent.MISSION_GREETING);
						dispatch(missionEvent);
					}
				}
				var attack:Boolean = (ignoreVerification) ? true : false;
				if (!ignoreVerification)
				{
					attack = true;
					if (detail.type == TypeEnum.STARBASE_SECTOR_IGA || detail.type == TypeEnum.STARBASE_SECTOR_SOVEREIGNTY || detail.type == TypeEnum.STARBASE_SECTOR_TYRANNAR)
					{
						if (_starbaseModel.currentBase.bubbleTimeRemaining > 0)
						{
							_onNotificationSignal.dispatch('bubble', entity);
							attack = false;
						}
					}
				}
				if (!showMission && attack)
				{
					var order:SectorOrderRequest = SectorOrderRequest(_serverController.getRequest(ProtocolEnum.SECTOR_CLIENT, RequestEnum.SECTOR_ISSUE_ORDER));
					order.entityId = _system.selected.id;
					order.orderType = OrderEnum.TACKLE;
					order.targetId = entity.id;
					_serverController.send(order);
				}
			}
		}

		public function selectFleet( fleetID:String, gotoLocation:Boolean = true, canEnterBattle:Boolean = true, canChangeSector:Boolean = true ):Boolean
		{
			var fleetVO:FleetVO = getFleetVO(fleetID);
			if (fleetVO)
			{
				_sectorModel.focusFleetID = fleetVO.id;
				if (!_fteController.running && fleetVO.inBattle && canEnterBattle)
				{
					var battleEvent:BattleEvent = new BattleEvent(BattleEvent.BATTLE_JOIN, fleetVO.battleServerAddress);
					dispatch(battleEvent);
				} else if (fleetVO.sector == _sectorModel.sectorID)
				{
					var entity:Entity = _game.getEntity(fleetID);
					if (entity)
					{
						_system.selectEntity(entity, gotoLocation);
						if (gotoLocation)
						{
							var position:Position = entity.get(Position);
							jumpToLocation(position.x, position.y);
						}
						return true;
					}
				} else if (fleetVO.sector != "" && gotoLocation && canChangeSector)
				{
					var sectorEvent:SectorEvent = new SectorEvent(SectorEvent.CHANGE_SECTOR, fleetVO.sector, fleetID);
					dispatch(sectorEvent);
					return true;
				}
			}
			return false;
		}

		public function recallFleet( entity:Entity, targetTransgate:Entity = null ):void
		{
			if (entity && entity.id != null)
			{
				var order:SectorOrderRequest = SectorOrderRequest(_serverController.getRequest(ProtocolEnum.SECTOR_CLIENT, RequestEnum.SECTOR_ISSUE_ORDER));
				order.entityId = entity.id;
				order.orderType = OrderEnum.RECALL;
				order.targetLocationX = order.targetLocationY = 0;
				order.targetId = (targetTransgate) ? targetTransgate.id : "";
				_serverController.send(order);
			}
		}

		public function defendBase( entity:Entity, targetBase:Entity ):void
		{
			if (entity && entity.id != null && targetBase && targetBase.id != null)
			{
				var fleet:FleetVO = _fleetModel.getFleet(entity.id);
				if (fleet)
				{
					var order:SectorOrderRequest = SectorOrderRequest(_serverController.getRequest(ProtocolEnum.SECTOR_CLIENT, RequestEnum.SECTOR_ISSUE_ORDER));
					order.entityId = entity.id;
					order.orderType = OrderEnum.DEFEND;
					order.targetId = targetBase.id;
					_serverController.send(order);
				}
			}
		}

		public function watchBattle( entity:Entity ):void
		{
			var battleServerAddress:String = Attack(entity.get(Attack)).battleServerAddress;
			if (battleServerAddress)
				joinBattle(battleServerAddress);
		}

		public function travelViaTransgate( sector:String, entity:Entity, target:Entity ):void
		{
			if (Application.NETWORK == Application.NETWORK_GUEST)
			{
				ExternalInterfaceAPI.logConsole("Guest Travel Restriction");
				var serverEvent:ServerEvent
				serverEvent = new ServerEvent(ServerEvent.GUEST_RESTRICTION);
				_eventDispatcher.dispatchEvent(serverEvent);
			}
			else
			{
				if (entity && entity.id != null)
				{
					var order:SectorOrderRequest = SectorOrderRequest(_serverController.getRequest(ProtocolEnum.SECTOR_CLIENT, RequestEnum.SECTOR_ISSUE_ORDER));
					order.entityId = entity.id;
					order.orderType = OrderEnum.TRANS_GATE_TRAVEL;
					order.targetId = target.id;
					order.targetLocationX = order.targetLocationY = 0;
					order.destinationSector = sector;
					_serverController.send(order);
				}
			}
		}
		public function relocateToTransgate( sector:String, targetTransgate:String ):void
		{
			_transactionController.starbaseRelocateStarbaseToTransgate(sector, targetTransgate);
		}
		
		public function travelToWaypoint(entity:Entity, target:Entity ):void
		{
			if (entity && entity.id != null)
			{
				var order:SectorOrderRequest = SectorOrderRequest(_serverController.getRequest(ProtocolEnum.SECTOR_CLIENT, RequestEnum.SECTOR_ISSUE_ORDER));
				order.entityId = entity.id;
				order.orderType = OrderEnum.WAYPOINT_TRAVEL;
				order.targetId = target.id;
				order.targetLocationX = order.targetLocationY = 0;
				_serverController.send(order);
			}
		}

		public function lootDerelictFleet( entity:Entity ):void
		{
			if (!_system.selected || _system.selected.id == null)
				return;

			var order:SectorOrderRequest = SectorOrderRequest(_serverController.getRequest(ProtocolEnum.SECTOR_CLIENT, RequestEnum.SECTOR_ISSUE_ORDER));
			order.entityId = _system.selected.id;
			order.orderType = OrderEnum.SALVAGE;
			order.targetId = entity.id;
			_serverController.send(order);
		}

		public function enterStarbase( entity:Entity ):void
		{
			var event:StarbaseEvent = new StarbaseEvent(StarbaseEvent.ENTER_BASE, (entity != null) ? entity.id : null);
			dispatch(event);
		}
		public function enterInstancedMission():void
		{
			var event:StarbaseEvent = new StarbaseEvent(StarbaseEvent.ENTER_INSTANCED_MISSION);
			dispatch(event);
		}

		public function getFleetVO( id:String ):FleetVO
		{
			return _fleetModel.getFleet(id);
		}

		public function loadIcon( url:String, callback:Function ):void
		{
			_assetModel.getFromCache("assets/" + url, callback);
		}

		public function loadMiniIconFromEntityData( type:String, callback:Function ):void
		{
			var _currentAssetVO:AssetVO = _assetModel.getEntityData(type);
			var icon:String             = _currentAssetVO.iconImage;
			loadIcon(icon, callback);
		}

		public function removeTargetSelection():void
		{
			_system.removeTargetSelection();
		}

		override public function confirmReady():void
		{
			super.confirmReady();

			//get the entities in our view area
			var setView:SectorSetViewLocationRequest = SectorSetViewLocationRequest(_serverController.getRequest(ProtocolEnum.SECTOR_CLIENT, RequestEnum.SECTOR_SET_VIEW_LOCATION));
			setView.x = _sceneModel.focus.x;
			setView.y = _sceneModel.focus.y;
			_serverController.send(setView);
		}

		override public function loadBackground(battleModel:BattleModel, useModelData:Boolean = false):void
		{
			super.loadBackground(battleModel, battleModel);
			//focus the view
			//is there a location we want to focus on?
			var foundFleet:Boolean;
			if (_sectorModel.focusLocation.x != 0)
			{
				jumpToLocation(_sectorModel.focusLocation.x, _sectorModel.focusLocation.y);
			} else
			{
				//focus on the fleet if there is one
				if (_sectorModel.focusFleetID && !_sectorModel.viewBase)
				{
					if (selectFleet(_sectorModel.focusFleetID, true, false, false))
						foundFleet = true;
				}
				_sectorModel.viewBase = false;
				if (!foundFleet)
				{
					//finally focus on the starbase if the fleet doesn't exist
					var base:BaseVO = _starbaseModel.currentBase;
					if (base)
						jumpToLocation(base.sectorLocationX, base.sectorLocationY);
				}
			}
		}

		public function getTransgateDestinations():Vector.<SectorVO>
		{
			return _sectorModel.destinations;
		}
		
		public function getPrivateDestinations():Vector.<SectorVO>
		{
			return _sectorModel.privateDestinations;
		}

		public function getConstantPrototypeByName( v:String ):*
		{
			return _prototypeModel.getConstantPrototypeValueByName(v);
		}
		
		public function getTransgateCustomDestinationPrototype( key:String ):IPrototype  
		{ 
			return _prototypeModel.getTransgateCustomDestinationPrototype(key);
		}
		
		public function getTransgateCustomDestinationGroupByCustomDestinationGroup( group:String ):Vector.<IPrototype>
		{
			return _prototypeModel.getTransgateCustomDestinationGroupByCustomDestinationGroup(group);
		}

		public function getPlayer( id:String ):PlayerVO  { return _playerModel.getPlayer(id); }

		public function getBase( id:String ):BaseVO  { return _starbaseModel.getBaseByID(id); }
		public function getFleets():Vector.<FleetVO>  { return _fleetModel.fleets; }

		public function addInteractListener( listener:Function ):void  { _onInteractSignal.add(listener); }
		public function removeInteractListener( listener:Function ):void  { _onInteractSignal.remove(listener); }

		public function addListenerOnCoordsUpdate( listener:Function ):void  { _system.onCoordsUpdate.add(listener); }
		public function removeListenerOnCoordsUpdate( listener:Function ):void  { _system.onCoordsUpdate.remove(listener); }

		public function addBattleListener( listener:Function ):void  { _onBattleSignal.add(listener); }
		public function removeBattleListener( listener:Function ):void  { _onBattleSignal.remove(listener); }

		public function addListenerForFleetUpdate( listener:Function ):void  { _fleetModel.onUpdatedFleetsSignal.add(listener); }
		public function removeListenerForFleetUpdate( listener:Function ):void  { _fleetModel.onUpdatedFleetsSignal.remove(listener); }

		public function addNotificationListener( listener:Function ):void  { _onNotificationSignal.add(listener); }
		public function removeNotificationListener( listener:Function ):void  { _onNotificationSignal.remove(listener); }

		public function addSelectionChangeListener( listener:Function ):void  { _system.onSelectionChangeSignal.add(listener); }

		public function addOnGenericAllianceMessageRecievedListener( callback:Function ):void  { _allianceModel.onGenericAllianceMessageRecieved.add(callback); }
		public function removeOnGenericAllianceMessageRecievedListener( callback:Function ):void  { _allianceModel.onGenericAllianceMessageRecieved.remove(callback); }

		public function jumpToLocation( x:Number, y:Number ):void
		{
			_system.jumpToLocation(x, y);
		}

		public function get currentMission():MissionVO  { return _missionModel.currentMission; }
		public function get neighborhood():int  { return _sectorModel.neighborhood; }
		public function get focusFleetID():String  { return _sectorModel.focusFleetID; }
		public function get selectedEntity():Entity  { return _system.selected; }
		public function get selectedEnemy():Entity  { return _system.selectedEnemy; }
		public function get sectorID():String  { return _sectorModel.sectorID; }
		public function get sectorName():String  { return _sectorModel.sectorName; }
		public function get sectorEnum():String  { return _sectorModel.sectorEnum; }

		[Inject]
		public function set missionModel( v:MissionModel ):void  { _missionModel = v; }
		[Inject]
		public function set sectorModel( v:SectorModel ):void  { _sectorModel = v; }
		[Inject]
		public function set serverController( v:ServerController ):void  { _serverController = v; }
		[Inject]
		public function set starbaseModel( v:StarbaseModel ):void  { _starbaseModel = v; }
		[Inject]
		public function set fleetModel( v:FleetModel ):void  { _fleetModel = v; }
		[Inject]
		public function set transactionController( v:TransactionController ):void  { _transactionController = v; }
		[Inject]
		public function set playerModel( v:PlayerModel ):void  { _playerModel = v; }
		[Inject]
		public function set allianceModel( v:AllianceModel ):void  { _allianceModel = v; }

		override public function destroy():void
		{
			super.destroy();
			_destinations = null;
			_onBattleSignal.removeAll();
			_onBattleSignal = null;
			_onInteractSignal.removeAll();
			_onInteractSignal = null;
			_onNotificationSignal.removeAll();
			_onNotificationSignal = null;
			_fleetModel = null;
			_missionModel = null;
			_sectorModel = null;
			_serverController = null;
			_starbaseModel = null;
			_system.presenter = null;
			_system = null;
		}
	}
}


