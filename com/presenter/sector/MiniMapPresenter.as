package com.presenter.sector
{
	import com.Application;
	import com.controller.ServerController;
	import com.enum.TypeEnum;
	import com.enum.server.ProtocolEnum;
	import com.enum.server.RequestEnum;
	import com.event.SectorEvent;
	import com.event.StarbaseEvent;
	import com.event.StateEvent;
	import com.game.entity.components.shared.Detail;
	import com.game.entity.components.shared.Position;
	import com.game.entity.nodes.shared.grid.GridNode;
	import com.game.entity.systems.interact.BattleInteractSystem;
	import com.game.entity.systems.interact.InteractSystem;
	import com.game.entity.systems.interact.SectorInteractSystem;
	import com.game.entity.systems.interact.StarbaseInteractSystem;
	import com.game.entity.systems.shared.grid.GridSystem;
	import com.model.battle.BattleModel;
	import com.model.fleet.FleetModel;
	import com.model.fleet.FleetVO;
	import com.model.mission.MissionModel;
	import com.model.mission.MissionVO;
	import com.model.player.CurrentUser;
	import com.model.player.PlayerModel;
	import com.model.player.PlayerVO;
	import com.model.prototype.PrototypeModel;
	import com.model.scene.SceneModel;
	import com.model.sector.SectorModel;
	import com.model.starbase.BaseVO;
	import com.model.starbase.StarbaseModel;
	import com.presenter.ImperiumPresenter;
	import com.service.server.outgoing.battle.BattleRetreatRequest;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import org.ash.core.Entity;
	import org.ash.core.Game;
	import org.osflash.signals.Signal;
	
	public class MiniMapPresenter extends ImperiumPresenter implements IMiniMapPresenter
	{
		private const ZOOM_MIN:Number                         = 0.5;
		private const ZOOM_MAX:Number                         = 2.5;
		private const ZOOM_RANGE:Number                       = ZOOM_MAX - ZOOM_MIN;
		
		private var _battleModel:BattleModel;
		private var _combinedFactor:Number;
		private var _dragStart:Point;
		private var _fleetModel:FleetModel;
		private var _game:Game;
		private var _missionModel:MissionModel;
		private var _scale:Number;
		private var _sceneModel:SceneModel;
		private var _sectorModel:SectorModel;
		private var _serverController:ServerController;
		private var _starbaseModel:StarbaseModel;
		private var _playerModel:PlayerModel;
		private var _prototypeModel:PrototypeModel;
		private var _zoom:Number                              = 1.0;
		
		/** The actual world coord size of the map the minimap represents. */
		private var _mapWidth:Number                          = 0.0;
		
		/** The size of the minimap's viewport; used to set the scale factor. */
		private var _miniMapWidth:Number                      = 0.0;
		
		private var _interactSystem:InteractSystem;
		
		private var _addToMiniMapSignal:Signal;
		private var _clearMiniMapSignal:Signal;
		private var _removeFromMiniMapSignal:Signal;
		private var _scrollMiniMapSignal:Signal;
		
		private var _launchFleetForMission:String             = 'CodeString.Toast.LaunchFleetForMission';
		private var _returnFleetToHomeSectorForMission:String = 'CodeString.Toast.ReturnFleetToHomeSectorForMission';
		
		[PostConstruct]
		override public function init():void
		{
			super.init();
			_addToMiniMapSignal = new Signal(Entity, Rectangle);
			_removeFromMiniMapSignal = new Signal(Entity);
			_scrollMiniMapSignal = new Signal();
			_clearMiniMapSignal = new Signal();
		}
		
		public function updateScale():void
		{
			_scale = _mapWidth > 0 ? _miniMapWidth / _mapWidth : 0;
			_combinedFactor = _scale * _zoom;
		}
		
		public function getIconPosition( width:Number, height:Number, entityPosition:Position ):Point
		{
			var result:Point   = new Point();
			var xCenter:Number = width >> 1;
			result.x = xCenter + (entityPosition.x - _sceneModel.focus.x) * _combinedFactor;
			
			var yCenter:Number = height >> 1;
			result.y = yCenter + (entityPosition.y - _sceneModel.focus.y) * _combinedFactor;
			
			return result;
		}
		
		override protected function onStateChange( e:StateEvent ):void
		{
			_interactSystem = null;
			super.onStateChange(e);
		}
		
		public function mouseDown():void
		{
			_dragStart = _sceneModel.focus.clone();
			interactSystem.followEntity = null;
		}
		
		public function mouseUp():void
		{
			
		}
		
		public function mouseMove( xDelta:Number, yDelta:Number ):void
		{
			if (interactSystem)
				interactSystem.jumpToLocation(_dragStart.x - (xDelta / _combinedFactor), _dragStart.y - (yDelta / _combinedFactor));
		}
		
		public function mouseWheel( delta:Number ):void
		{
			zoom += delta / 30;
		}
		
		
		
		public function enterStarbase():void
		{
			var event:StarbaseEvent = new StarbaseEvent(StarbaseEvent.ENTER_BASE);
			dispatch(event);
		}
		
		public function isInInstancedMission():Boolean
		{
			return (_starbaseModel.homeBase.instancedMissionAddress != null);
		}
		public function enterInstancedMission():void
		{
			var event:StarbaseEvent = new StarbaseEvent(StarbaseEvent.ENTER_INSTANCED_MISSION);
			dispatch(event);
		}
		
		public function showSector():void
		{
			if (_fteController.running)
				return;
			var sectorEvent:SectorEvent;
			if ((Application.STATE == StateEvent.GAME_BATTLE_INIT || Application.STATE == StateEvent.GAME_BATTLE) && (!_battleModel.isBaseCombat || _battleModel.baseOwnerID != CurrentUser.id))
			{
				if (_battleModel.oldGameState == StateEvent.GAME_SECTOR)
				{
					var fleetID:String  = null;
					var sectorID:String = _battleModel.oldSector;
					if (_sectorModel.focusFleetID != null)
					{
						var fleetVO:FleetVO = _fleetModel.getFleet(_sectorModel.focusFleetID);
						if (fleetVO.sector == _battleModel.oldSector)
							fleetID = _sectorModel.focusFleetID;
						else if (fleetVO.sector == _sectorModel.sectorID)
						{
							fleetID = _sectorModel.focusFleetID;
							sectorID = _sectorModel.sectorID;
						}
					}
					if (fleetID != null)
						sectorEvent = new SectorEvent(SectorEvent.CHANGE_SECTOR, sectorID, fleetID);
					else
						sectorEvent = new SectorEvent(SectorEvent.CHANGE_SECTOR, sectorID, null, _battleModel.focusLocation.x, _battleModel.focusLocation.y);
					
					sectorEvent = new SectorEvent(SectorEvent.CHANGE_SECTOR, _battleModel.oldSector, null, _battleModel.focusLocation.x, _battleModel.focusLocation.y);
					dispatch(sectorEvent);
				} else
				{
					var event:StarbaseEvent = new StarbaseEvent(StarbaseEvent.ENTER_BASE);
					dispatch(event);
				}
			} else
			{
				_sectorModel.viewBase = true;
				_sectorModel.focusFleetID = null;
				sectorEvent = new SectorEvent(SectorEvent.CHANGE_SECTOR);
				dispatch(sectorEvent);
			}
		}
		
		public function retreat():void
		{
			var request:BattleRetreatRequest = BattleRetreatRequest(_serverController.getRequest(ProtocolEnum.BATTLE_CLIENT, RequestEnum.BATTLE_RETREAT));
			_serverController.send(request);
		}
		
		public function findBase( userName:String ):void
		{
			var baseVO:BaseVO = (userName == CurrentUser.id) ? _starbaseModel.currentBase : null;
			if (baseVO)
			{
				if (baseVO.sectorID == _sectorModel.sectorID)
					interactSystem.jumpToLocation(baseVO.sectorLocationX, baseVO.sectorLocationY);
				else
				{
					var sectorEvent:SectorEvent = new SectorEvent(SectorEvent.CHANGE_SECTOR, baseVO.sectorID);
					_sectorModel.viewBase = true;
					dispatch(sectorEvent);
				}
			}
		}
		
		private function findClosestTransgate( target:Entity ):Entity
		{
			var entity:Entity;
			var bestDistSq:Number     = 0;
			var targetPos:Position    = target.get(Position);
			
			// This will only work in sector mode, because it's the only place transgates are found, naturally.
			var detail:Detail;
			var pos:Position;
			var distSq:Number;
			var gridSystem:GridSystem = GridSystem(_game.getSystem(GridSystem));
			for (var node:GridNode = gridSystem.nodes.head; node; node = node.next)
			{
				detail = node.entity.get(Detail);
				switch (detail.type)
				{
					case TypeEnum.TRANSGATE_IGA:
					case TypeEnum.TRANSGATE_SOVEREIGNTY:
					case TypeEnum.TRANSGATE_TYRANNAR:
						break;
					default:
						continue;
				}
				
				pos = node.entity.get(Position);
				distSq = (pos.x - targetPos.x) * (pos.x - targetPos.x) + (pos.y - targetPos.y) * (pos.y - targetPos.y);
				if (bestDistSq <= 0 || distSq < bestDistSq)
				{
					entity = node.entity;
					bestDistSq = distSq;
				}
			}
			
			return entity;
		}
		
		public function moveToMissionTarget():String
		{
			var mission:MissionVO           = _missionModel.currentMission;
			//send the player back to their base if they're doing a non-kill mission
			if (mission.progressEvent != "Kill")
			{
				if (Application.STATE != StateEvent.GAME_STARBASE)
				{
					var starbaseEvent:StarbaseEvent = new StarbaseEvent(StarbaseEvent.ENTER_BASE);
					dispatch(starbaseEvent);
				}
				return null;
			}
			
			var fleet:FleetVO;
			var fleets:Vector.<FleetVO>     = _fleetModel.fleets;
			var activeFleet:FleetVO;
			var hasFleetLaunched:Boolean    = false;
			for (var i:int = 0; i < fleets.length; i++)
			{
				fleet = fleets[i];
				if (fleet.sector != "")
				{
					hasFleetLaunched = true;
				}
			}			
			if(!hasFleetLaunched)
			{
				return _launchFleetForMission;
			}
			
			var activeFleetId:String = _sectorModel.focusFleetID;
			activeFleet = _fleetModel.getFleet(activeFleetId);
			
			//TODO: handle the case when no fleet is active but still launched (e.g., recently selected fleet is not in the current sector)
			if(!activeFleet)
				return null;				
			
			var system:SectorInteractSystem = SectorInteractSystem(_game.getSystem(SectorInteractSystem));
			if (system)
			{
				//are we in the same sector as the mission entity?
				if (mission.sector == _sectorModel.sectorID)
				{
					var missionEntities:Vector.<Entity> = system.missionEntities;
					if (missionEntities.length > 0 && activeFleet)
					{
						var entity:Entity     = missionEntities[0];
						var position:Position = entity.get(Position);
						system.moveToLocation(position.x, position.y, 1.3);
						return null;
					}
				} else
				{
					//we're not in the same sector so point to a nearby transgate we can travel through
					if (activeFleet)
					{
						var fleetEntity:Entity = _game.getEntity(activeFleetId);
						if (fleetEntity)
						{
							var closestTransgate:Entity = findClosestTransgate(fleetEntity);
							if (closestTransgate)
							{
								var transgatePos:Position = closestTransgate.get(Position);
								system.moveToLocation(transgatePos.x, transgatePos.y, 1.3);
							}
						}
						return null;
					}
				}
				return _launchFleetForMission;
			}
			
			var event:SectorEvent;
			if (activeFleet)
				event = new SectorEvent(SectorEvent.CHANGE_SECTOR, activeFleet.sector, activeFleet.id);
			if (event)
			{
				dispatch(event);
				return null;
			}
			
			if (Application.STATE == StateEvent.GAME_SECTOR)
			{
				if (hasFleetLaunched &&
					mission.sector != _sectorModel.sectorID &&
					_starbaseModel.homeBase.sectorID != _sectorModel.sectorID)
				{
					return _returnFleetToHomeSectorForMission;
				}
			}
			
			return _launchFleetForMission;
		}
		
		public function getConstantPrototypeByName( v:String ):*
		{
			return _prototypeModel.getConstantPrototypeValueByName(v);
		}
		
		public function getEntity( id:String ):Entity  { return _game.getEntity(id); }
		
		public function addListenerOnCoordsUpdate( listener:Function ):void  { SectorInteractSystem(_game.getSystem(SectorInteractSystem)).onCoordsUpdate.add(listener); }
		public function removeListenerOnCoordsUpdate( listener:Function ):void  { SectorInteractSystem(_game.getSystem(SectorInteractSystem)).onCoordsUpdate.remove(listener); }
		
		public function get addToMiniMapSignal():Signal  { return _addToMiniMapSignal; }
		public function get clearMiniMapSignal():Signal  { return _clearMiniMapSignal; }
		public function get fteRunning():Boolean  { return _fteController.running; }
		
		public function get mapWidth():Number  { return _mapWidth; }
		public function set mapWidth( value:Number ):void  { _mapWidth = value; updateScale(); }
		
		public function get miniMapWidth():Number  { return _miniMapWidth; }
		public function set miniMapWidth( value:Number ):void  { _miniMapWidth = value; updateScale(); }
		
		public function get removeFromMiniMapSignal():Signal  { return _removeFromMiniMapSignal; }
		public function get scrollMiniMapSignal():Signal  { return _scrollMiniMapSignal; }
		
		public function get sectorName():String  { return _sectorModel.sectorName; }
		public function get sectorEnum():String  { return _sectorModel.sectorEnum; }
		
		public function get interactSystem():InteractSystem
		{
			if (_interactSystem)
				return _interactSystem;
			switch (Application.STATE)
			{
				case StateEvent.GAME_STARBASE:
					_interactSystem = StarbaseInteractSystem(_game.getSystem(StarbaseInteractSystem));
					break;
				case StateEvent.GAME_BATTLE:
					_interactSystem = BattleInteractSystem(_game.getSystem(BattleInteractSystem));
					break;
				case StateEvent.GAME_SECTOR:
					_interactSystem = SectorInteractSystem(_game.getSystem(SectorInteractSystem));
					break;
				default:
					_interactSystem = null;
			}
			return _interactSystem;
		}
		
		public function get isMissionBattle():Boolean  { return !_missionModel.currentMission.isFTE && _battleModel.missionID == _missionModel.currentMission.id; }
		
		public function get showRetreat():Boolean
		{
			if(_battleModel.isInstancedMission)
				return true;
			
			var baseOwner:PlayerVO = getPlayer(_battleModel.baseOwnerID);
			return _battleModel.isBaseCombat && _battleModel.baseOwnerID != CurrentUser.id && !baseOwner.isNPC && (_battleModel.participants.indexOf(CurrentUser.id) > -1);
		}
		
		public function get zoom():Number  { return _zoom; }
		public function set zoom( v:Number ):void
		{
			v = v < ZOOM_MIN ? ZOOM_MIN : v;
			v = v > ZOOM_MAX ? ZOOM_MAX : v;
			
			_zoom = v;
			updateScale();
		}
		
		public function get focusedFleetRating():int
		{
			if (_sectorModel.focusFleetID)
				return _fleetModel.getFleet(_sectorModel.focusFleetID).level
			
			return 0;
		}
		
		public function get zoomPercent():Number  { return (_zoom - ZOOM_MIN) / ZOOM_RANGE; }
		public function set zoomPercent( v:Number ):void  { zoom = ZOOM_MIN + (ZOOM_RANGE * v); }
		
		public function getPlayer( id:String ):PlayerVO  { return _playerModel.getPlayer(id); }
		
		public function addSelectionChangeListener( listener:Function ):void  { _sectorModel.addSelectedFleetIDChangedListener(listener); }
		public function removeSelectionChangeListener( listener:Function ):void  { _sectorModel.removeSelectedFleetIDChangedListener(listener); }
		
		public function get currentMission():MissionVO  { return _missionModel.currentMission; }
		
		public function addListenerToUpdateMission( listener:Function ):void  { _missionModel.addListenerToUpdateMission(listener); }
		public function removeListenerToUpdateMission( listener:Function ):void  { _missionModel.removeListenerToUpdateMission(listener); }
		
		[Inject]
		public function set battleModel( v:BattleModel ):void  { _battleModel = v; }
		[Inject]
		public function set fleetModel( v:FleetModel ):void  { _fleetModel = v; }
		[Inject]
		public function set game( v:Game ):void  { _game = v; }
		[Inject]
		public function set missionModel( v:MissionModel ):void  { _missionModel = v; }
		[Inject]
		public function set sceneModel( v:SceneModel ):void  { _sceneModel = v; }
		[Inject]
		public function set sectorModel( v:SectorModel ):void  { _sectorModel = v; }
		[Inject]
		public function set serverController( v:ServerController ):void  { _serverController = v; }
		[Inject]
		public function set starbaseModel( v:StarbaseModel ):void  { _starbaseModel = v; }
		[Inject]
		public function set playerModel( v:PlayerModel ):void  { _playerModel = v; }
		[Inject]
		public function set prototypeModel( v:PrototypeModel ):void  { _prototypeModel = v; }
		
	}
}
