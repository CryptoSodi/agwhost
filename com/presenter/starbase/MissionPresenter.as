package com.presenter.starbase
{
	import com.Application;
	import com.controller.ServerController;
	import com.controller.fte.FTEController;
	import com.controller.transaction.TransactionController;
	import com.enum.TypeEnum;
	import com.enum.server.ProtocolEnum;
	import com.enum.server.RequestEnum;
	import com.event.MissionEvent;
	import com.event.SectorEvent;
	import com.event.StarbaseEvent;
	import com.event.TransitionEvent;
	import com.event.StateEvent;
	import com.event.signal.TransactionSignal;
	import com.game.entity.components.shared.Detail;
	import com.game.entity.components.shared.Position;
	import com.game.entity.nodes.shared.grid.GridNode;
	import com.game.entity.systems.interact.SectorInteractSystem;
	import com.game.entity.systems.shared.grid.GridSystem;
	import com.model.achievements.AchievementModel;
	import com.model.asset.AssetModel;
	import com.model.asset.AssetVO;
	import com.model.fleet.FleetModel;
	import com.model.fleet.FleetVO;
	import com.model.mission.MissionInfoVO;
	import com.model.mission.MissionModel;
	import com.model.mission.MissionVO;
	import com.model.player.CurrentUser;
	import com.model.prototype.IPrototype;
	import com.model.prototype.PrototypeModel;
	import com.model.sector.SectorModel;
	import com.model.starbase.StarbaseModel;
	import com.presenter.ImperiumPresenter;
	import com.service.language.Localization;
	import com.service.server.outgoing.battle.BattlePauseRequest;
	
	import flash.events.Event;
	
	import org.ash.core.Entity;
	import org.ash.core.Game;
	import org.shared.ObjectPool;
	
	
	public class MissionPresenter extends ImperiumPresenter implements IMissionPresenter
	{
		private var _assetModel:AssetModel;
		private var _fleetModel:FleetModel;
		private var _game:Game;
		private var _locToken:Object;
		private var _missionModel:MissionModel;
		private var _achievementModel:AchievementModel;
		private var _prototypeModel:PrototypeModel;
		private var _sectorModel:SectorModel;
		private var _serverController:ServerController;
		private var _starbaseModel:StarbaseModel;
		private var _transactionController:TransactionController;
		
		private var _launchFleetForMission:String             = 'CodeString.Toast.LaunchFleetForMission';
		private var _returnFleetToHomeSectorForMission:String = 'CodeString.Toast.ReturnFleetToHomeSectorForMission';
		
		[PostConstruct]
		override public function init():void
		{
			super.init();
			_locToken = {"[[String.PlayerName]]":CurrentUser.name};
		}
		
		public function getMissionInfo( type:String, chapterID:int = -1, missionID:int = -1, forCaptainsLog:Boolean = false ):MissionInfoVO
		{
			var dialog:IPrototype;
			var info:MissionInfoVO = ObjectPool.get(MissionInfoVO);
			var mission:MissionVO  = (chapterID == -1 || missionID == -1) ? _missionModel.currentMission : _missionModel.getStoryMission(chapterID, missionID);
			if (!mission)
				return null;
			var npc:IPrototype;
			var progress:int       = 0;
			
			
			switch (type)
			{
				case MissionEvent.MISSION_FAILED:
					dialog = _prototypeModel.getDialogPrototypeByName(mission.failDialogue);
					info.addDialog(Localization.instance.getStringWithTokens(dialog.getValue('dialogString'), _locToken));
					//todo uncomment when ready
					//var audioDir:String = dialog.getValue('dialogAudioString');
					//if(audioDir.length>0)
					//	info.addSound(audioDir);
					//info.addSound("sounds/sfx/AFX_Base_Weapon_Missle_Pod_v001A.mp3");
					addSpeaker(dialog, info);
					progress = 2;
					break;
				case MissionEvent.MISSION_GREETING:
					dialog = _prototypeModel.getDialogPrototypeByName(mission.greetingDialogue);
					info.addDialog(Localization.instance.getStringWithTokens(dialog.getValue('dialogString'), _locToken));
					//todo uncomment when ready
					//var audioDir:String = dialog.getValue('dialogAudioString');
					//if(audioDir.length>0)
					//	info.addSound(audioDir);
					//info.addSound("sounds/sfx/AFX_Base_Weapon_Missle_Pod_v001A.mp3");
					addSpeaker(dialog, info);
					dialog = _prototypeModel.getDialogPrototypeByName(mission.briefingDialogue);
					info.addDialog(Localization.instance.getStringWithTokens(dialog.getValue('dialogString'), _locToken));
					//todo uncomment when ready
					//var audioDir:String = dialog.getValue('dialogAudioString');
					//if(audioDir.length>0)
					//	info.addSound(audioDir);
					//info.addSound("sounds/sfx/AFX_Base_Weapon_Missle_Pod_v001A.mp3");
					addSpeaker(dialog, info);
					progress = 0;
					//for non kill missions we also want to add the situational dialog into the missionInfoVO
					if (forCaptainsLog || mission.progressEvent == "Kill")
						break;
				case MissionEvent.MISSION_SITUATIONAL:
					dialog = _prototypeModel.getDialogPrototypeByName(mission.situationDialogue);
					info.addDialog(Localization.instance.getStringWithTokens(dialog.getValue('dialogString'), _locToken));
					//todo uncomment when ready
					//var audioDir:String = dialog.getValue('dialogAudioString');
					//if(audioDir.length>0)
					//	info.addSound(audioDir);
					//info.addSound("sounds/sfx/AFX_Base_Weapon_Missle_Pod_v001A.mp3");
					addSpeaker(dialog, info);
					progress = (mission.progressEvent == "Kill") ? 2 : 0;
					break;
				case MissionEvent.MISSION_VICTORY:
					dialog = _prototypeModel.getDialogPrototypeByName(mission.victoryDialogue);
					info.addDialog(Localization.instance.getStringWithTokens(dialog.getValue('dialogString'), _locToken));
					
					//todo uncomment when ready
					//var audioDir:String = dialog.getValue('dialogAudioString');
					//if(audioDir.length>0)
					//	info.addSound(audioDir);
					//info.addSound("sounds/sfx/AFX_Base_Weapon_Missle_Pod_v001A.mp3");
					addSpeaker(dialog, info);
					progress = 3;
					break;
			}
			
			
			//objectives
			var objectives:Array   = mission.objectives.split(',');
			var objProto:IPrototype;
			for (var i:int = 0; i < objectives.length; i++)
			{
				objProto = _prototypeModel.getMissionObjective(objectives[i]);
				if (objProto)
					info.addObjective(Localization.instance.getString(objProto.getValue('dialogString')));
			}
			
			//rewards
			info.alloyReward = mission.alloyReward;
			info.creditReward = mission.creditsReward;
			info.energyReward = mission.energyReward;
			info.syntheticReward = mission.syntheticReward;
			info.palladiumCurrencyReward = mission.palladiumCurrencyReward;
			info.blueprintReward = mission.blueprintReward;
			
			info.currentProgress = progress; //mission.progress;
			info.progressRequired = 3; //mission.progressRequired;
			
			//object pool the missionVO if we had to make a new one to get the info
			if (chapterID != -1 && missionID != -1 && (chapterID != _missionModel.currentMission.chapter || missionID != _missionModel.currentMission.mission))
				ObjectPool.give(mission);
			
			return info;
		}
		
		public function acceptMission():void
		{
			var mission:MissionVO = _missionModel.currentMission;
			_missionModel.missionAccepted();
			_transactionController.missionAccept(mission.id);
		}
		public function startInstancedMission(id:String):void
		{
			_transactionController.instancedMissionStart(id);
			
			var event:TransitionEvent = new TransitionEvent(TransitionEvent.TRANSITION_BEGIN);
			dispatch(event);
		}
		public function isInstancedMissionOn():Boolean
		{
			if(_starbaseModel.homeBase.instancedMissionAddress == null)
				return false;
			else
				return true;
		}
		
		public function showReward():void
		{
			var missionEvent:MissionEvent = new MissionEvent(MissionEvent.SHOW_REWARDS);
			dispatch(missionEvent);
		}
		
		public function acceptMissionReward():void
		{
			var mission:MissionVO = _missionModel.currentMission;
			_missionModel.missionRewardAccepted();
			_transactionController.missionAcceptRewards(mission.id);
		}
		
		public function dispatchMissionEvent( type:String ):void
		{
			var missionEvent:MissionEvent = new MissionEvent(type);
			dispatch(missionEvent);
		}
		
		public function loadIcon( url:String, callback:Function ):void
		{
			_assetModel.getFromCache("assets/" + url, callback);
		}
		
		public function fteNextStep():void
		{
			if (_fteController.running)
				_fteController.nextStep();
		}
		
		public function showSector():void
		{
			var event:Event;
			event = new SectorEvent(SectorEvent.CHANGE_SECTOR, _starbaseModel.homeBase.sectorID);
			dispatch(event);
		}
		public function fteSkip():void
		{
			if (_fteController.running)
				_fteController.skipFTE();
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
			var mission:MissionVO           = currentMission;
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
		
		public function getStoryMission( chapter:int, mission:int ):MissionVO
		{
			return _missionModel.getStoryMission(chapter, mission);
		}
		
		public function unpauseBattle():void
		{
			var pauseRequest:BattlePauseRequest = BattlePauseRequest(_serverController.getRequest(ProtocolEnum.BATTLE_CLIENT, RequestEnum.BATTLE_PAUSE));
			pauseRequest.pause = false;
			_serverController.send(pauseRequest);
		}
		
		public function requestAllScores():void
		{
			_serverController.requestAllScores();
		}
		
		public function onAddAllScoresUpdatedListener( Listener:Function ):void  { _achievementModel.onAllScoresUpdated.add(Listener); }
		public function onRemoveAllScoresUpdatedListener( Listener:Function ):void  { _achievementModel.onAllScoresUpdated.remove(Listener); }
		
		public function addTransactionListener( callback:Function ):void  { _transactionController.addListener(TransactionSignal.DATA_IMPORTED, callback); }
		public function removeTransactionListener( callback:Function ):void  { _transactionController.removeListener(callback); }
		
		private function addSpeaker( dialog:IPrototype, info:MissionInfoVO ):void
		{
			//set the npc and title
			var assetVO:AssetVO;
			var key:String     = dialog.getValue('speaker').replace(/ /g, '');
			var npc:IPrototype = _prototypeModel.getNPCPrototypeByName(key);
			if (npc)
				assetVO = _assetModel.getEntityData(npc.getValue("race"));
			if (assetVO)
			{
				info.addTitle(assetVO.visibleName, 0xffb128);
				info.addImages(assetVO.iconImage, assetVO.mediumImage, assetVO.largeImage);
			} else
			{
				info.addTitle("!!" + dialog.getValue('speaker') + "!!", 0xffb128);
				info.addImages('', '', '');
			}
		}
		
		public function get currentMission():MissionVO  { return _missionModel.currentMission; }
		public function get fteStep():int  { return _fteController.step; }
		[Inject]
		public function set assetModel( v:AssetModel ):void  { _assetModel = v; }
		[Inject]
		public function set fleetModel( v:FleetModel ):void  { _fleetModel = v; }
		[Inject]
		public function set game( v:Game ):void  { _game = v; }
		[Inject]
		public function set missionModel( v:MissionModel ):void  { _missionModel = v; }
		[Inject]
		public function set achievementModel( v:AchievementModel ):void  { _achievementModel = v; }
		[Inject]
		public function set prototypeModel( v:PrototypeModel ):void  { _prototypeModel = v; }
		[Inject]
		public function set sectorModel( v:SectorModel ):void  { _sectorModel = v; }
		[Inject]
		public function set serverController( v:ServerController ):void  { _serverController = v; }
		[Inject]
		public function set starbaseModel( v:StarbaseModel ):void  { _starbaseModel = v; }
		[Inject]
		public function set transactionController( v:TransactionController ):void  { _transactionController = v; }
		
		override public function destroy():void
		{
			_assetModel = null;
			_fleetModel = null;
			_game = null;
			_locToken = null;
			_achievementModel = null;
			_missionModel = null;
			_prototypeModel = null;
			_sectorModel = null;
			_serverController = null;
			_starbaseModel = null;
			_transactionController = null;
		}
	}
}


