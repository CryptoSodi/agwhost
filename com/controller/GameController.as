package com.controller
{
	import com.Application;
	import com.controller.fte.FTEController;
	import com.controller.sound.SoundController;
	import com.controller.transaction.TransactionController;
	import com.service.ExternalInterfaceAPI;
	import com.enum.AudioEnum;
	import com.enum.BattleLogFilterEnum;
	import com.enum.CategoryEnum;
	import com.enum.FleetStateEnum;
	import com.enum.MissionEnum;
	import com.enum.RemoveReasonEnum;
	import com.enum.TimeLogEnum;
	import com.enum.ToastEnum;
	import com.enum.TypeEnum;
	import com.enum.server.BattleEntityTypeEnum;
	import com.enum.server.OrderEnum;
	import com.enum.server.ProtocolEnum;
	import com.enum.server.RequestEnum;
	import com.enum.server.SectorEntityStateEnum;
	import com.enum.server.SectorEntityTypeEnum;
	import com.event.BattleEvent;
	import com.event.PaywallEvent;
	import com.event.SectorEvent;
	import com.event.ServerEvent;
	import com.event.StarbaseEvent;
	import com.event.StateEvent;
	import com.event.ToastEvent;
	import com.game.entity.components.battle.Attack;
	import com.game.entity.components.battle.Beam;
	import com.game.entity.components.battle.DebuffTray;
	import com.game.entity.components.battle.Drone;
	import com.game.entity.components.battle.Health;
	import com.game.entity.components.battle.Modules;
	import com.game.entity.components.battle.Shield;
	import com.game.entity.components.battle.Ship;
	import com.game.entity.components.sector.Transgate;
	import com.game.entity.components.shared.Animation;
	import com.game.entity.components.shared.Cargo;
	import com.game.entity.components.shared.Detail;
	import com.game.entity.components.shared.Interactable;
	import com.game.entity.components.shared.Move;
	import com.game.entity.components.shared.Owned;
	import com.game.entity.components.shared.Position;
	import com.game.entity.components.shared.Pylon;
	import com.game.entity.components.shared.VCList;
	import com.game.entity.factory.IAttackFactory;
	import com.game.entity.factory.ISectorFactory;
	import com.game.entity.factory.IShipFactory;
	import com.game.entity.factory.IStarbaseFactory;
	import com.game.entity.factory.IVFXFactory;
	import com.game.entity.systems.battle.DebugLineSystem;
	import com.game.entity.systems.interact.SectorInteractSystem;
	import com.game.entity.systems.shared.VCSystem;
	import com.game.entity.systems.shared.grid.GridSystem;
	import com.game.entity.systems.starbase.StarbaseSystem;
	import com.model.achievements.AchievementModel;
	import com.model.alliance.AllianceModel;
	import com.model.asset.AssetModel;
	import com.model.asset.AssetVO;
	import com.model.battle.BattleModel;
	import com.model.battlelog.BattleLogModel;
	import com.model.blueprint.BlueprintModel;
	import com.model.fleet.FleetModel;
	import com.model.fleet.FleetVO;
	import com.model.leaderboards.LeaderboardModel;
	import com.model.mail.MailModel;
	import com.model.mission.MissionModel;
	import com.model.mission.MissionVO;
	import com.model.motd.MotDDailyRewardModel;
	import com.model.motd.MotDModel;
	import com.model.player.BookmarkVO;
	import com.model.player.CurrentUser;
	import com.model.player.PlayerModel;
	import com.model.player.PlayerVO;
	import com.model.prototype.PrototypeModel;
	import com.model.sector.SectorModel;
	import com.model.starbase.StarbaseModel;
	import com.model.warfrontModel.WarfrontModel;
	import com.presenter.sector.ISectorPresenter;
	import com.presenter.shared.IGamePresenter;
	import com.presenter.starbase.IStarbasePresenter;
	import com.service.loading.LoadPriority;
	import com.service.server.ITransactionResponse;
	import com.service.server.incoming.alliance.AllianceBaselineResponse;
	import com.service.server.incoming.alliance.AllianceGenericResponse;
	import com.service.server.incoming.alliance.AllianceInviteResponse;
	import com.service.server.incoming.alliance.AllianceRosterResponse;
	import com.service.server.incoming.alliance.PublicAlliancesResponse;
	import com.service.server.incoming.battle.BattleDataResponse;
	import com.service.server.incoming.battle.BattleDebugLinesResponse;
	import com.service.server.incoming.battle.BattleHasEndedResponse;
	import com.service.server.incoming.battle.BattleParticipantInfo;
	import com.service.server.incoming.battlelog.BattleLogDetailsResponse;
	import com.service.server.incoming.battlelog.BattleLogListResponse;
	import com.service.server.incoming.chat.ChatBaselineResponse;
	import com.service.server.incoming.data.ActiveDefenseData;
	import com.service.server.incoming.data.ActiveDefenseHitData;
	import com.service.server.incoming.data.AreaAttackData;
	import com.service.server.incoming.data.AreaAttackHitData;
	import com.service.server.incoming.data.BattleData;
	import com.service.server.incoming.data.BattleDebuff;
	import com.service.server.incoming.data.BattleEntityData;
	import com.service.server.incoming.data.BeamAttackData;
	import com.service.server.incoming.data.DebuffMapByWeapon;
	import com.service.server.incoming.data.DroneAttackData;
	import com.service.server.incoming.data.ProjectileAttackData;
	import com.service.server.incoming.data.RemovedAttackData;
	import com.service.server.incoming.data.RemovedObjectData;
	import com.service.server.incoming.data.SectorBattleData;
	import com.service.server.incoming.data.SectorEntityData;
	import com.service.server.incoming.data.SectorEntityUpdateData;
	import com.service.server.incoming.data.SectorObjectiveData;
	import com.service.server.incoming.data.SectorOrderData;
	import com.service.server.incoming.data.WeaponData;
	import com.service.server.incoming.leaderboard.LeaderboardResponse;
	import com.service.server.incoming.leaderboard.PlayerProfileResponse;
	import com.service.server.incoming.leaderboard.WarfrontUpdateResponse;
	import com.service.server.incoming.mail.MailDetailResponse;
	import com.service.server.incoming.mail.MailInboxResponse;
	import com.service.server.incoming.mail.MailUnreadResponse;
	import com.service.server.incoming.proxy.ProxyBattleDisconnectedResponse;
	import com.service.server.incoming.proxy.ProxySectorDisconnectedResponse;
	import com.service.server.incoming.proxy.ProxyStarbaseDisconnectedResponse;
	import com.service.server.incoming.sector.SectorAlwaysVisibleBaselineResponse;
	import com.service.server.incoming.sector.SectorAlwaysVisibleUpdateResponse;
	import com.service.server.incoming.sector.SectorBaselineResponse;
	import com.service.server.incoming.sector.SectorFleetTravelAlertResponse;
	import com.service.server.incoming.sector.SectorUpdateResponse;
	import com.service.server.incoming.starbase.StarbaseAchievementsResponse;
	import com.service.server.incoming.starbase.StarbaseAllScoresResponse;
	import com.service.server.incoming.starbase.StarbaseAvailableRerollResponse;
	import com.service.server.incoming.starbase.StarbaseBaselineResponse;
	import com.service.server.incoming.starbase.StarbaseBattleAlertResponse;
	import com.service.server.incoming.starbase.StarbaseBountyRewardResponse;
	import com.service.server.incoming.starbase.StarbaseDailyResponse;
	import com.service.server.incoming.starbase.StarbaseDailyRewardResponse;
	import com.service.server.incoming.starbase.StarbaseFleetDockedResponse;
	import com.service.server.incoming.starbase.StarbaseGetPaywallPayoutsResponse;
	import com.service.server.incoming.starbase.StarbaseInstancedMissionAlertResponse;
	import com.service.server.incoming.starbase.StarbaseMissionCompleteResponse;
	import com.service.server.incoming.starbase.StarbaseMotdListResponse;
	import com.service.server.incoming.starbase.StarbaseMoveStarbaseResponse;
	import com.service.server.incoming.starbase.StarbaseOfferRedeemedResponse;
	import com.service.server.incoming.starbase.StarbaseRerollChanceResultResponse;
	import com.service.server.incoming.starbase.StarbaseRerollReceivedResultResponse;
	import com.service.server.incoming.starbase.StarbaseUnavailableRerollResponse;
	import com.service.server.incoming.universe.UniverseNeedCharacterCreateResponse;
	import com.service.server.incoming.universe.UniverseSectorListResponse;
	import com.service.server.outgoing.alliance.AllianceRequestBaselineRequest;
	import com.service.server.outgoing.alliance.AllianceSendInviteRequest;
	import com.service.server.outgoing.battle.BattleAttackOrderRequest;
	import com.service.server.outgoing.battle.BattleMoveOrderRequest;
	import com.service.server.outgoing.battle.BattleToggleModuleOrderRequest;
	import com.service.server.outgoing.battlelog.BattleLogDetailRequest;
	import com.service.server.outgoing.battlelog.BattleLogListRequest;
	import com.service.server.outgoing.chat.ChatReportChatRequest;
	import com.service.server.outgoing.leaderboard.LeaderboardRequest;
	import com.service.server.outgoing.leaderboard.LeaderboardRequestPlayerProfileRequest;
	import com.service.server.outgoing.mail.MailDeleteMailRequest;
	import com.service.server.outgoing.mail.MailReadMailRequest;
	import com.service.server.outgoing.mail.MailRequestInboxRequest;
	import com.service.server.outgoing.mail.MailSendAllianceMailRequest;
	import com.service.server.outgoing.mail.MailSendMailRequest;
	import com.service.server.outgoing.proxy.ProxyConnectToSectorRequest;
	import com.service.server.outgoing.proxy.ProxyReportCrashRequest;
	import com.service.server.outgoing.sector.SectorOrderRequest;
	import com.service.server.outgoing.sector.SectorRequestBaselineRequest;
	import com.service.server.outgoing.starbase.StarbaseAllScoresRequest;
	import com.service.server.outgoing.starbase.StarbaseBookmarkDeleteRequest;
	import com.service.server.outgoing.starbase.StarbaseBookmarkSaveRequest;
	import com.service.server.outgoing.starbase.StarbaseBookmarkUpdateRequest;
	import com.service.server.outgoing.starbase.StarbaseClaimAchievementRewardRequest;
	import com.service.server.outgoing.starbase.StarbaseMintNFTRequest;
	import com.service.server.outgoing.starbase.StarbaseClaimDailyRequest;
	import com.service.server.outgoing.starbase.StarbaseGetPaywallPayoutsRequest;
	import com.service.server.outgoing.starbase.StarbaseMotDReadRequest;
	import com.service.server.outgoing.starbase.StarbaseRequestAchievementsRequest;
	import com.service.server.outgoing.starbase.StarbaseVerifyPaymentRequest;
	import com.ui.modal.server.ClientCrashView;
	import com.ui.modal.server.DisconnectedView;
	import com.util.AllegianceUtil;
	import com.util.BattleUtils;
	import com.util.TimeLog;

	import flash.events.IEventDispatcher;
	import flash.geom.Point;

	import org.as3commons.logging.api.ILogger;
	import org.as3commons.logging.api.getLogger;
	import org.ash.core.Entity;
	import org.ash.core.Game;
	import org.ash.tick.ITickProvider;
	import org.parade.core.IViewFactory;
	import org.parade.core.IViewStack;
	import org.parade.core.ViewEvent;
	import org.shared.ObjectPool;
	
	import flash.utils.Dictionary;

	/**
	 *
	 * @author Phillip Reagan
	 */
	public class GameController
	{
		private var _assetModel:AssetModel;
		private var _attackFactory:IAttackFactory;
		private var _battleModel:BattleModel;
		private var _eventDispatcher:IEventDispatcher;
		private var _fleetModel:FleetModel;
		private var _fteController:FTEController;
		private var _inFTE:Boolean             = false;
		private var _mailModel:MailModel;
		private var _missionModel:MissionModel;
		private var _blueprintModel:BlueprintModel;
		private var _playerModel:PlayerModel;
		private var _battleLogModel:BattleLogModel;
		private var _presenter:IGamePresenter;
		private var _prototypeModel:PrototypeModel;
		private var _sectorFactory:ISectorFactory;
		private var _sectorModel:SectorModel;
		private var _shipFactory:IShipFactory;
		private var _soundController:SoundController;
		private var _starbaseFactory:IStarbaseFactory;
		private var _starbaseModel:StarbaseModel;
		private var _viewFactory:IViewFactory;
		private var _viewStack:IViewStack;
		private var _vfxFactory:IVFXFactory;
		private var _warfrontModel:WarfrontModel;
		private var _leaderboardModel:LeaderboardModel;
		private var _allianceModel:AllianceModel;
		private var _motdModel:MotDModel;
		private var _motdDailyModel:MotDDailyRewardModel;
		private var _achievementModel:AchievementModel;

		private var _firstTimeInit:Boolean     = true;
		private var _game:Game;
		private var _serverController:ServerController;
		private var _tickProvider:ITickProvider;
		private var _transactionController:TransactionController;
		private var _settingsController:SettingsController;
		private var _chatController:ChatController;
		private var _eventController:EventController;

		private var _baseRelocatedTitle:String = 'CodeString.Toast.BaseRelocated.Title';
		private var _baseRelocatedBody:String  = 'CodeString.Toast.BaseRelocated.Body';

		private var _alreadyRecieved:String    = 'CodeString.Toast.AlreadyReceived';
		private var _hasDocked:String          = 'CodeString.Toast.HasDocked';

		protected const _logger:ILogger        = getLogger('GameController');

		/**
		 *
		 * @param game
		 * @param tickProvider
		 */
		public function GameController( game:Game, tickProvider:ITickProvider )
		{
			_game = game;
			_tickProvider = tickProvider;
			Application.onError.add(globalErrorHandler);
		}

		/**
		 *
		 * @param time The amount of time that has passed since the start of the last game loop
		 */
		public function onTick( time:Number ):void
		{
			if (Application.STATE == StateEvent.GAME_STARBASE)
				_game.update(.033);
			else
				_game.update(_serverController.updateSimulationTime(time));
			_viewStack.update(time);
		}

		//============================================================================================================
		//************************************************************************************************************
		//													BATTLE
		//************************************************************************************************************
		//============================================================================================================

		public function handleBattleDataResponse( delta:BattleDataResponse ):void
		{
			var response:BattleData  = BattleData.globalInstance;
			if (!response.hasBeenBaselined && !delta.isBaseline)
			{
				// we need a baseline, but this is an update. Ignore it
				return;
			}

			response.decodeResponse(delta);
			if (delta.isBaseline)
			{
				_logger.debug(' -- Received BattleDataResponse - baseline');

				if (Application.STATE == StateEvent.GAME_BATTLE_INIT)
				{
					//set the faction of the battle
					_sectorModel.updateSector(response.sector);

					_battleModel.alloy = response.alloy;
					_battleModel.baseOwnerID = response.baseOwner;
					_battleModel.battleStartTick = response.battleStartTick;
					_battleModel.credits = response.credits;
					_battleModel.energy = response.energy;
					_battleModel.synthetic = response.synthetic;
					_battleModel.isBaseCombat = response.isBaseCombat;
					_battleModel.isInstancedMission = response.isInstancedMission;
					_battleModel.missionID = response.missionPersistence;
					_battleModel.mapSizeX = response.maxSizeX;
					_battleModel.mapSizeY = response.maxSizeY;
					
					_battleModel.galacticName = response.galacticName;
					_battleModel.backgroundId = response.backgroundId;
					_battleModel.planetId = response.planetId;
					_battleModel.moonQuantity = response.moonQuantity;
					_battleModel.asteroidQuantity = response.asteroidQuantity;
					_battleModel.appearanceSeed = response.appearanceSeed;
					
					for (participantIndex = 0; participantIndex < response.participants.length; ++participantIndex)
					{
						var id:String = response.participants[participantIndex].id;
						var level:int = response.participants[participantIndex].level;						
						_battleModel.participantRatings[id] = level;
						_battleModel.addParticipant(id);
					}

					if (response.players.length > 0)
						battleAddPlayers(response.players);
					var player:PlayerVO = _playerModel.getPlayer(CurrentUser.id);
					if (player)
					{
						if(player.faction != "")
							CurrentUser.battleFaction = player.faction;
					}
					if (response.entities.length > 0)
						battleShowEntities(response.entities);
					if (response.deadEntities.length > 0)
						battleShowEntities(response.deadEntities);
					if (response.areaAttacks.length > 0)
						fireAreaAttacks(response.areaAttacks);
					if (response.projectileAttacks.length > 0)
						fireProjectiles(response.projectileAttacks);
					if (response.beamAttacks.length > 0)
						fireBeams(response.beamAttacks);

					if (response.isBaseCombat)
					{
						_battleModel.baseFactionColor = AllegianceUtil.instance.getFactionColor(_playerModel.getPlayer(_battleModel.baseOwnerID).faction);
						//create the starbase
						_starbaseFactory.createStarbasePlatform(_battleModel.baseOwnerID);
						StarbaseSystem(_game.getSystem(StarbaseSystem)).depthSort(StarbaseSystem.DEPTH_SORT_ALL);
					}

					//send out the battle state event
					_eventDispatcher.dispatchEvent(new StateEvent(StateEvent.GAME_BATTLE));
					handleBattleState(response);
				}

				TimeLog.endTimeLog(TimeLogEnum.SERVER_GAME_DATA, "battle");
			}

			// update
			if (Application.STATE != StateEvent.GAME_BATTLE)
			{
				var msg:ProxyReportCrashRequest = ProxyReportCrashRequest(_serverController.getRequest(ProtocolEnum.PROXY_CLIENT, RequestEnum.PROXY_REPORT_CRASH));
				msg.dataStr = 'Received BattleUpdate before baseline';
				_serverController.send(msg);
				return;
			}

			_battleModel.battleEndTick = response.battleEndTick;
			//create new
			if (response.players.added.length > 0)
				battleAddPlayers(response.players.added);
			if (response.entities.added.length > 0)
				battleShowEntities(response.entities.added);
			if (response.droneAttacks.added.length > 0)
				fireDrones(response.droneAttacks.added);
			if (response.areaAttacks.added.length > 0)
				fireAreaAttacks(response.areaAttacks.added);
			if (response.projectileAttacks.added.length > 0)
				fireProjectiles(response.projectileAttacks.added);
			if (response.beamAttacks.added.length > 0)
				fireBeams(response.beamAttacks.added);

			//update
			
			
			
			var health:Health;
			var i:int;
			var update:BattleEntityData;
			var shield:Shield;
			var attack:Attack;
			var vcList:VCList;
			for (i = 0; i < response.entities.modified.length; i++)
			{
				update = response.entities.modified[i];
				entity = _game.getEntity(update.id);
				if (entity)
				{
					//Deal with the added, modded and removed maps inside the map
					for each (var modByWep:DebuffMapByWeapon in update.debuffs.modified)
					{
						var tray:DebuffTray;
						if (entity.has(DebuffTray))
							tray = entity.get(DebuffTray);
						else
						{
							tray = ObjectPool.get(DebuffTray);
							tray.init();
						}
						for (var addDebuffKey:String in modByWep.added)
						{
							var addDebuff:BattleDebuff = modByWep.added[addDebuffKey];
							var assetVO:AssetVO        = _assetModel.getEntityData(addDebuff.prototype);
							if (!entity.has(DebuffTray))
							{
								entity.add(tray);
								tray.addDebuff(addDebuffKey, assetVO, addDebuff.stackCount);
								vcList = entity.get(VCList);
								vcList.addComponentType(TypeEnum.DEBUFF_TRAY);
							} else
								tray.addDebuff(addDebuffKey, assetVO, addDebuff.stackCount);
						}

						for each (var modDebuff:BattleDebuff in modByWep.modified)
						{
							tray.addDebuff(null, _assetModel.getEntityData(modDebuff.prototype), modDebuff.stackCount);
						}

						for each (var remDebuff:RemovedObjectData in modByWep.removed)
						{
							//ensure the tray is still on the ship by grabbing it every time
							tray = entity.get(DebuffTray);
							if (tray)
							{
								tray.removeDebuff(remDebuff.id);

								if (tray.isDebuffsEmpty())
								{
									vcList = entity.get(VCList);
									vcList.removeComponentType(TypeEnum.DEBUFF_TRAY);
									entity.remove(DebuffTray);
									ObjectPool.give(tray);
								}
							}
						}
					}

					health = Health(entity.get(Health));
					if (health && health.currentHealth != update.currentHealth)
					{
						health.currentHealth = update.currentHealth;
					}

					shield = entity.get(Shield);
					if (shield)
					{
						shield.enabled = update.shieldsEnabled;
						shield.currentStrength = update.shieldsCurrentHealth;
					}

					if (update.selectedTargetId != "UNSET")
					{
						attack = entity.get(Attack);
						if (attack)
							attack.targetID = update.selectedTargetId;
					} else if (update.organicTargetId != "UNSET")
					{
						attack = entity.get(Attack);
						if (attack)
							attack.targetID = update.organicTargetId;
					}

					var modules:Modules = entity.get(Modules);
					if (modules)
					{
						for (var weaponidx:int = 0; weaponidx < update.weapons.modified.length; ++weaponidx)
						{
							var weapon:WeaponData = WeaponData(update.weapons.modified[weaponidx]);
							modules.moduleStates[weapon.moduleIdx] = weapon.weaponState;
						}
					}
				}
			}

			//Handle Area Attack Collisions
			var area:AreaAttackHitData;
			var aEntity:Entity;
			if (response.areaAttackHits.length > 0 && Application.STARLING_ENABLED)
			{
				var len:int = response.areaAttackHits.length;
				//limiting this to under 7 hits for performance concerns. 
				if (len < 7)
				{
					for (i = 0; i < len; i++)
					{
						area = response.areaAttackHits[i];
						aEntity = _game.getEntity(area.attackId);

						_vfxFactory.createHit(aEntity, aEntity, area.locationX, area.locationY, false, false);
					}
				}
			}

			//remove projectiles
			var entity:Entity;
			var position:Position;
			var removedEntity:RemovedObjectData;
			var removedAttack:RemovedAttackData;
			var removedAttacks:Array = response.areaAttacks.removed.concat(response.beamAttacks.removed, response.droneAttacks.removed, response.projectileAttacks.removed);
			for (i = 0; i < removedAttacks.length; i++)
			{
				removedAttack = removedAttacks[i];
				entity = _game.getEntity("Attack" + String(removedAttack.id));
				if (entity)
				{
					switch (removedAttack.reason)
					{
						case RemoveReasonEnum.AttackComplete:
							_soundController.playSound(AudioEnum.AFX_WEAPON_HIT, 0.5);
							if (_vfxFactory.createHit(entity, entity, removedAttack.x, removedAttack.y, false, true) == null)
							{
								_attackFactory.destroyAttack(entity);
							}
							break;
						case RemoveReasonEnum.Intercepted:
							var activeDefenseHit:ActiveDefenseHitData = response.adHits[entity.id];
							if (activeDefenseHit)
							{
								aEntity = _game.getEntity(activeDefenseHit.owningShip);
								if (aEntity)
									_attackFactory.createActiveDefenseInterceptor(aEntity, activeDefenseHit.attachPoint, removedAttack.x, removedAttack.y);
							}
							_attackFactory.destroyAttack(entity);
							break;
						case RemoveReasonEnum.ShieldComplete:
							_soundController.playSound(AudioEnum.AFX_BARRIER_HIT, 0.5);
							if (_vfxFactory.createHit(entity, entity, removedAttack.x, removedAttack.y, true, true) == null)
							{
								_attackFactory.destroyAttack(entity);
							}
							break;
						default:
							_attackFactory.destroyAttack(entity);
							break;
					}
				}
			}

			//remove entities
			for (i = 0; i < response.entities.removed.length; i++)
			{
				removedEntity = response.entities.removed[i];
				destroyEntity(removedEntity.id, removedEntity.reason);
			}

			for (var participantIndex:int = 0; participantIndex < response.participants.added.length; ++participantIndex)
			{
				var participant:BattleParticipantInfo = BattleParticipantInfo(response.participants.added[participantIndex]);
				_battleModel.participantRatings[participant.id] = participant.level;
				_battleModel.addParticipant(participant.id);				
				_battleModel.reconnect();	
			}

			//remove players
			if (response.players.removed.length)
				battleRemovePlayers(response.players.removed);

			handleBattlePositionUpdateResponse(response);

			if (response.battleStateChanged)
			{
				handleBattleState(response);
			}
		}


		/**
		 *
		 * @param response
		 */
		public function handleBattleDebugLinesResponse( response:BattleDebugLinesResponse ):void
		{
			var dlSystem:DebugLineSystem = DebugLineSystem(_game.getSystem(DebugLineSystem));
			if (!dlSystem)
				return;

			dlSystem.addLine(response.debugLines);
			dlSystem.removeLine(response.removedLines);
		}

		/**
		 *
		 * @param response
		 */
		public function handleBattlePositionUpdateResponse( response:BattleData ):void
		{
			if (Application.STATE != StateEvent.GAME_BATTLE)
			{
				//var msg:ProxyReportCrashRequest = ProxyReportCrashRequest(_serverController.getRequest(ProtocolEnum.PROXY_CLIENT, RequestEnum.PROXY_REPORT_CRASH));
				//msg.dataStr = 'Received BattlePositionUpdate before baseline';
				//_serverController.send(msg);
				return;
			}

			var animation:Animation;
			var i:int = 0;
			var detail:Detail;
			var entity:Entity;
			var move:Move;
			var rotation:Number;
			var turret:Entity;
			var vcList:VCList;
			for (i = 0; i < response.entities.modified.length; i++)
			{
				var battleEntity:BattleEntityData = response.entities.modified[i];
				entity = _game.getEntity(battleEntity.id);
				if (entity)
				{
					detail = entity.get(Detail);
					move = entity.get(Move);
					if (move)
					{
						move.addUpdate(battleEntity.location.x, battleEntity.location.y, battleEntity.velocity.x,
									   battleEntity.velocity.y,
									   battleEntity.rotation,
									   response.tick,
									   response.tick + 1);
					}

					//update turret rotations
					if (detail.type == TypeEnum.POINT_DEFENSE_PLATFORM && battleEntity.weapons.modified.length > 0)
					{
						vcList = entity.get(VCList);
						turret = vcList.getComponent(TypeEnum.STARBASE_TURRET);
						if (turret)
						{
							// Determine sprite frame to use based on angle
							rotation = battleEntity.weapons.modified[0].rotation;
							var num:int = rotation * (44.0 / 256.0) | 0;
							animation = turret.get(Animation);
							animation.frame = num;
							if (animation.render && animation.spritePack)
								animation.render.updateFrame(animation.spritePack.getFrame(animation.label, num), animation);
						}
					}
				}
			}

			for (i = 0; i < response.droneAttacks.modified.length; i++)
			{
				var droneAttack:DroneAttackData = response.droneAttacks.modified[i];
				entity = _game.getEntity(droneAttack.attackId);
				if (entity)
				{
					Move(entity.get(Move)).addUpdate(droneAttack.location.x, droneAttack.location.y, 0, 0, droneAttack.rotation, response.tick, response.tick + 1);
					var drone:Drone = entity.get(Drone);
					drone.isOribiting = droneAttack.isOrbiting;
					drone.targetID = droneAttack.targetEntityId;
				}
			}

			for (i = 0; i < response.beamAttacks.modified.length; i++)
			{
				var beamAttack:BeamAttackData = response.beamAttacks.modified[i];
				entity = _game.getEntity(beamAttack.attackId);
				if (entity)
				{
					var beam:Beam = entity.get(Beam);
					beam.targetID = beamAttack.targetEntityId;
					beam.targetAttachPoint = beamAttack.targetAttachPoint;
					beam.targetScatterX = beamAttack.targetScatterX;
					beam.targetScatterY = beamAttack.targetScatterY;
					beam.attackHit = beamAttack.attackHit;
					beam.hitLocationX = beamAttack.hitLocation.x;
					beam.hitLocationY = beamAttack.hitLocation.y;
					beam.hitTarget = beamAttack.hitTarget;

					//if the attack hit the target set shownHit = false so that the hit animation will be shown next loop
					if (beam.attackHit)
						beam.visibleHitCounter--;
				}
			}


			for (i = 0; i < response.projectileAttacks.modified.length; i++)
			{
				var projectileAttack:ProjectileAttackData = response.projectileAttacks.modified[i];
				entity = _game.getEntity(projectileAttack.attackId);
				if (entity)
				{
					// Iso crunch the rotation of guided attacks
					var rot:Number        = projectileAttack.rotation;
					rot = BattleUtils.instance.isoCrunchAngle(rot);

					// TODO - projectile velocity is constant and known... dig it up and plug it in here to allow projectiles to sim beyond updates if there's lag
					Move(entity.get(Move)).addUpdate(projectileAttack.location.x, projectileAttack.location.y, 0, 0, rot, response.tick, response.tick + 1);
				}
			}
		}

		public function handleBattleEnded( response:BattleHasEndedResponse ):void
		{
			_battleModel.finished = true;
			_battleModel.wonLastBattle = (CurrentUser.id in response.victors);
			_eventDispatcher.dispatchEvent(new BattleEvent(BattleEvent.BATTLE_ENDED, null, response));
			if (_inFTE)
			{
				_inFTE = false;
				_fteController.nextStep();
			}
		}

		/**
		 *
		 * @param response
		 */
		public function handleBattleState( response:BattleData ):void
		{
			if (response.battleState == 3 || response.battleState == 4)
			{
				_eventDispatcher.dispatchEvent(new BattleEvent(BattleEvent.BATTLE_COUNTDOWN, null, response));
			}
			if (response.battleState == 5)
			{
				_battleModel.battleEndTick = response.battleEndTick;
				_battleModel.battleStartTick = response.battleStartTick;
				_eventDispatcher.dispatchEvent(new BattleEvent(BattleEvent.BATTLE_STARTED, null, response));
			}
		}

		/**
		 *
		 * @param id
		 * @param targetID
		 */
		public function battleAttackShip( id:String, targetID:String, moveToTarget:Boolean = false ):void
		{
			var order:BattleAttackOrderRequest = BattleAttackOrderRequest(_serverController.getRequest(ProtocolEnum.BATTLE_CLIENT, RequestEnum.BATTLE_ATTACK_ORDER));
			order.entityID = id;
			order.targetID = targetID;
			order.issuedTick = ServerController.SIMULATED_TICK;
			order.subSystemTarget = -1; // TODO - add subsystem targeting controls
			order.moveToTarget = moveToTarget;
			_serverController.send(order);
		}

		/**
		 *
		 * @param id
		 * @param x
		 * @param y
		 * @param startTick
		 */
		public function battleMoveShip( id:String, x:int, y:int, startTick:int ):void
		{
			var order:BattleMoveOrderRequest = BattleMoveOrderRequest(_serverController.getRequest(ProtocolEnum.BATTLE_CLIENT, RequestEnum.BATTLE_MOVE_ORDER));
			order.entityID = id;
			order.targetX = x;
			order.targetY = y;
			order.startTick = startTick;
			_serverController.send(order);
		}

		private function battleShowEntities( entities:Array ):void
		{
			var entityData:BattleEntityData;
			var entity:Entity;
			var forcefield:Vector.<BattleEntityData>;
			var position:Point = new Point();
			for (var i:int = 0; i < entities.length; i++)
			{
				entityData = BattleEntityData(entities[i]);
				_starbaseFactory.setBaseFaction(entityData.factionId);
				if (!_game.getEntity(entityData.id))
				{
					switch (entityData.type)
					{
						case BattleEntityTypeEnum.SHIP:
							_battleModel.addBattleEntity(entityData);
							if (entityData.currentHealth > 0)
								entity = _shipFactory.createShip(entityData);
							else if(entityData.currentHealth == 0)
							{
								entity = _shipFactory.createShip(entityData);
								_shipFactory.destroyShip(entity);
							}
							break;
						case BattleEntityTypeEnum.PYLON:
						case BattleEntityTypeEnum.BUILDING:
							_battleModel.addBattleEntity(entityData);
							entity = _starbaseFactory.createBattleBuilding(entityData);
							break;
						case BattleEntityTypeEnum.PLATFORM:
							entity = _starbaseFactory.createBattleBaseItem(entityData);
							break;
						case BattleEntityTypeEnum.FORCEFIELD:
							if (entityData.currentHealth > 0)
							{
								if (forcefield == null)
									forcefield = new Vector.<BattleEntityData>;
								forcefield.push(entityData);
							}
							break;
						default:
							trace("making", entityData.type);
							break;
					}
				}
			}

			if (forcefield)
			{
				var player:PlayerVO = _playerModel.getPlayer(forcefield[0].ownerId);
				if (player)
				{
					var color:uint = AllegianceUtil.instance.getFactionColor(player.faction);
					var pylonA:Pylon;
					var pylonB:Pylon;
					for (i = 0; i < forcefield.length; i++)
					{

						pylonA = Pylon(_game.getEntity(forcefield[i].connectedPylons[0]).get(Pylon));
						pylonB = Pylon(_game.getEntity(forcefield[i].connectedPylons[1]).get(Pylon));
						_starbaseFactory.createForcefield(forcefield[i].id, pylonA, pylonB, color);
					}
				}
			}
		}

		//============================================================================================================
		//************************************************************************************************************
		//													PROXY
		//************************************************************************************************************
		//============================================================================================================

		public function handleProxyBattleDisconnected( response:ProxyBattleDisconnectedResponse ):void
		{
			if (!_battleModel.finished)
			{
				if (Application.STATE == StateEvent.GAME_BATTLE ||
					Application.STATE == StateEvent.GAME_BATTLE_INIT)
				{
					if (_battleModel.oldGameState == StateEvent.GAME_STARBASE)
					{
						var starbaseEvent:StarbaseEvent = new StarbaseEvent(StarbaseEvent.ENTER_BASE);
						_eventDispatcher.dispatchEvent(starbaseEvent);
					} else
					{
						var event:SectorEvent = new SectorEvent(SectorEvent.CHANGE_SECTOR, null, null, _battleModel.focusLocation.x, _battleModel.focusLocation.y);
						_eventDispatcher.dispatchEvent(event);
					}
					_chatController.addSystemMessage("Your Battle was terminated.\n");
				}
			}
		}

		public function handleProxySectorDisconnected( response:ProxySectorDisconnectedResponse ):void
		{
			if (Application.STATE == StateEvent.GAME_SECTOR ||
				Application.STATE == StateEvent.GAME_SECTOR_INIT)
			{
				var event:StarbaseEvent = new StarbaseEvent(StarbaseEvent.ENTER_BASE, null);
				_eventDispatcher.dispatchEvent(event);
				_chatController.addSystemMessage("The Sector is restarting.\n");

				if (_inFTE)
					showDisconnect('CONNECTION LOST', 'Your connection was no match for the Imperium!\nPlease refresh your browser.\n\nError Message: 3027 Sector Error');
			}
		}

		public function handleProxyStarbaseDisconnected( response:ProxyStarbaseDisconnectedResponse ):void
		{
			if (Application.STATE == StateEvent.GAME_STARBASE && !_inFTE)
			{
				var sectorEvent:SectorEvent = new SectorEvent(SectorEvent.CHANGE_SECTOR, _sectorModel.sectorID, null);
				_eventDispatcher.dispatchEvent(sectorEvent);
			} else if (_inFTE)
				showDisconnect('CONNECTION LOST', 'Your connection was no match for the Imperium!\nPlease refresh your browser.\n\nError Message: 3026 Starbase Error');
		}

		private function showDisconnect( title:String = 'CONNECTION LOST', message:String = 'Your connection was no match for the Imperium!\n\nPlease refresh your browser.' ):void
		{
			var viewEvent:ViewEvent              = new ViewEvent(ViewEvent.SHOW_VIEW);
			var nDisconnectView:DisconnectedView = DisconnectedView(_viewFactory.createView(DisconnectedView));
			nDisconnectView.titleText = title;
			nDisconnectView.messageText = message;
			viewEvent.targetView = nDisconnectView;
			_eventDispatcher.dispatchEvent(viewEvent);
		}


		//============================================================================================================
		//************************************************************************************************************
		//													UNIVERSE
		//************************************************************************************************************
		//============================================================================================================


		public function handleUniverseNeedCharacterCreateResponse( response:UniverseNeedCharacterCreateResponse ):void
		{
			var serverEvent:ServerEvent = new ServerEvent(ServerEvent.NEED_CHARACTER_CREATE);
			_eventDispatcher.dispatchEvent(serverEvent);
		}

		//============================================================================================================
		//************************************************************************************************************
		//													SECTOR
		//************************************************************************************************************
		//============================================================================================================

		/**
		 *
		 * @param response
		 */
		public function handleSectorBaselineResponse( response:SectorBaselineResponse ):void
		{
			_logger.debug(' -- Received SectorBaselineResponse');

			if (response.entities.length > 0)
				sectorShowEntities(response.entities, false);
			if (response.orders.length > 0)
				sectorAssignOrders(response.orders, false);
			if (response.battles.length > 0)
				sectorAssignBattles(response.battles);

			//send out the sector state event
			_eventDispatcher.dispatchEvent(new StateEvent(StateEvent.GAME_SECTOR));
			TimeLog.endTimeLog(TimeLogEnum.SERVER_GAME_DATA, "sector");
		}

		/**
		 *
		 * @param response
		 */
		public function handleSectorAlwaysVisibleBaselineResponse( response:SectorAlwaysVisibleBaselineResponse ):void
		{
			_sectorModel.updateSector(response.sector);
			if (response.players.length > 0)
				addPlayers(response.players);
			if (response.entities.length > 0)
				sectorShowEntities(response.entities, true);
			if (response.orders.length > 0)
				sectorAssignOrders(response.orders, true);
			if (response.battles.length > 0)
				sectorAssignBattles(response.battles);
			//if (response.objectives.length > 0)
			//sectorShowObjectives(response.objectives);
		}

		/**
		 *
		 * @param response
		 */
		public function handleSectorUpdateResponse( response:SectorUpdateResponse ):void
		{
			if (response.entities.length > 0)
				sectorShowEntities(response.entities, false);
			if (response.orders.length > 0)
				sectorAssignOrders(response.orders, false);
			if (response.battles.length > 0)
				sectorAssignBattles(response.battles);
			if (response.entityUpdates.length > 0)
				sectorUpdateEntities(response.entityUpdates);

			//remove entities
			var removed:RemovedObjectData;
			for (var i:int = 0; i < response.removedEntities.length; i++)
			{
				removed = response.removedEntities[i];
				var entity:Entity = _game.getEntity(removed.id);
				if (entity)
				{
					// Don't destroy anything owned by the player, since the AlwaysVisible update is authoritative over those.
					if (entity.has(Owned))
						continue;
					destroyEntity(removed.id, response.removedEntities[i].reason);
				}
			}

			//remove battles
			if (response.removedBattles.length > 0)
				sectorRemoveBattles(response.removedBattles);
		}

		/**
		 *
		 * @param response
		 */
		public function handleSectorAlwaysVisibleUpdateResponse( response:SectorAlwaysVisibleUpdateResponse ):void
		{
			if (response.players.length > 0)
				addPlayers(response.players);
			if (response.entities.length > 0)
				sectorShowEntities(response.entities, true);
			if (response.orders.length > 0)
				sectorAssignOrders(response.orders, true);
			if (response.battles.length > 0)
				sectorAssignBattles(response.battles);
			if (response.entityUpdates.length > 0)
				sectorUpdateEntities(response.entityUpdates);
			if (response.objectives.length > 0)
				sectorShowObjectives(response.objectives);

			//remove entities
			var removed:RemovedObjectData;
			for (var i:int = 0; i < response.removedEntities.length; i++)
			{
				removed = response.removedEntities[i];
				destroyEntity(removed.id, response.removedEntities[i].reason);
			}

			//remove players
			if (response.removedPlayers.length > 0)
				removePlayers(response.removedPlayers);
			//remove battles
			if (response.removedBattles.length > 0)
				sectorRemoveBattles(response.removedBattles);

			for (i = 0; i < response.removedObjectives.length; i++)
			{
				removed = response.removedObjectives[i];
				destroyEntity(removed.id, response.removedObjectives[i].reason);
			}

		}

		private function sectorAssignBattles( battles:Vector.<SectorBattleData> ):void
		{
			var entity:Entity;
			var battle:SectorBattleData;
			var fleetVO:FleetVO;
			for (var i:int = 0; i < battles.length; i++)
			{
				battle = battles[i];
				if (!_game.getEntity(battle.id))
				{
					for (var j:int = 0; j < battle.participantFleets.length; j++)
					{
						entity = _game.getEntity(battle.participantFleets[j]);
						if (entity)
						{
							Attack(entity.get(Attack)).battleServerAddress = battle.serverIdentifier;
							Attack(entity.get(Attack)).inBattle = true;
							Attack(entity.get(Attack)).battle = battle;
						}
					}
					if (battle.participantBase && battle.participantBase != '')
					{
						entity = _game.getEntity(battle.participantBase);
						if (entity)
						{
							Attack(entity.get(Attack)).battleServerAddress = battle.serverIdentifier;
							Attack(entity.get(Attack)).inBattle = true;
							Attack(entity.get(Attack)).battle = battle;
						}
					}

					_vfxFactory.createAttackIcon(battle);
				}
			}
		}

		private function sectorRemoveBattles( battles:Vector.<RemovedObjectData> ):void
		{
			var attack:Attack;
			var battle:SectorBattleData;
			var attackIcon:Entity;
			var battleEntity:Entity;
			var fleetVO:FleetVO;
			for (var i:int = 0; i < battles.length; i++)
			{
				attackIcon = _game.getEntity(battles[i].id);
				if (attackIcon)
				{
					attack = attackIcon.get(Attack);
					battle = attack.attackData;
					for (var j:int = 0; j < battle.participantFleets.length; j++)
					{
						battleEntity = _game.getEntity(battle.participantFleets[j]);
						if (battleEntity)
						{
							Attack(battleEntity.get(Attack)).inBattle = false;
							Attack(battleEntity.get(Attack)).battle = null;
						}
					}
					if (battle.participantBase && battle.participantBase != '')
					{
						battleEntity = _game.getEntity(battle.participantBase);
						if (battleEntity)
						{
							Attack(battleEntity.get(Attack)).inBattle = false;
							Attack(battleEntity.get(Attack)).battle = null;
						}
					}
					_vfxFactory.destroyAttack(attackIcon);
				}
			}
		}

		private function sectorAssignOrders( orders:Vector.<SectorOrderData>, includeSelfOwned:Boolean ):void
		{
			var entity:Entity;
			var fleet:FleetVO;
			var move:Move;
			var order:SectorOrderData;
			var sectorInteractSystem:SectorInteractSystem = SectorInteractSystem(_game.getSystem(SectorInteractSystem));
			var selectedEntity:Entity                     = sectorInteractSystem.selected;
			var shipClass:String                          = '';
			for (var i:int = 0; i < orders.length; i++)
			{
				order = orders[i];
				entity = _game.getEntity(order.entityId);
				if (entity)
				{
					if (!includeSelfOwned)
					{
						if (entity.get(Owned))
							continue;
					}

					fleet = _fleetModel.getFleet(entity.id);
					if (fleet)
						fleet.defendTarget = "";
					move = entity.get(Move);
					switch (order.orderType)
					{
						case OrderEnum.RECALL:
							if (fleet)
								fleet.state = FleetStateEnum.DOCKING;
							Attack(entity.get(Attack)).targetID = order.targetId;
							move.setPointToPoint(order.targetLocationX, order.targetLocationY, order.issuedTick, order.finishTick);
							break;
						case OrderEnum.FORCED_RECALL:
							if (Detail(entity.get(Detail)).ownerID == CurrentUser.id)
							{
								fleet = _fleetModel.getFleet(entity.id);
								if (fleet)
									fleet.state = FleetStateEnum.FORCED_RECALLING;
							}

						case OrderEnum.ATTACK:
						case OrderEnum.FORCE_ATTACK:
						case OrderEnum.SALVAGE:
						case OrderEnum.TRANS_GATE_TRAVEL:
						case OrderEnum.WAYPOINT_TRAVEL:
							Attack(entity.get(Attack)).targetID = order.targetId;
							move.setPointToPoint(order.targetLocationX, order.targetLocationY, order.issuedTick, order.finishTick);
							break;
						case OrderEnum.DEFEND:
							if (fleet)
								fleet.defendTarget = order.targetId;
						case OrderEnum.MOVE:
						case OrderEnum.REMOTE_MOVE:
						case OrderEnum.TACKLE:
						case OrderEnum.HALT:
							if (Detail(entity.get(Detail)).ownerID == CurrentUser.id)
							{
								shipClass = Detail(entity.get(Detail)).prototypeVO ? Detail(entity.get(Detail)).prototypeVO.itemClass : '';

								//Play ship move sound based on size
								switch (shipClass)
								{

									case TypeEnum.FIGHTER:
									case TypeEnum.TRANSPORT:
										SoundController.instance.playSound(AudioEnum.AFX_ENGINE_ION, 0.5, 0, 1);
										break;
									case TypeEnum.HEAVY_FIGHTER:
										SoundController.instance.playSound(AudioEnum.AFX_ENGINE_HEAVY_ION, 0.5, 0, 1);
										break;
									case TypeEnum.CORVETTE:
										SoundController.instance.playSound(AudioEnum.AFX_ENGINE_IMPULSE, 0.5, 0, 1);
										break;
									case TypeEnum.DESTROYER:
										SoundController.instance.playSound(AudioEnum.AFX_ENGINE_HEAVY_IMPULSE, 0.5, 0, 1);
										break;
									case TypeEnum.BATTLESHIP:
										SoundController.instance.playSound(AudioEnum.AFX_ENGINE_FUSION, 0.5, 0, 1);
										break;
									case TypeEnum.DREADNOUGHT:
										SoundController.instance.playSound(AudioEnum.AFX_ENGINE_HEAVY_FUSION, 0.5, 0, 1);
										break;
								}
							}
							Attack(entity.get(Attack)).targetID = null;
							move.setPointToPoint(order.targetLocationX, order.targetLocationY, order.issuedTick, order.finishTick);
							break;
					}

					if (fleet && fleet.state == FleetStateEnum.DOCKING && order.orderType != OrderEnum.RECALL)
						fleet.state = FleetStateEnum.OUT;

					if (selectedEntity != null && entity.get(Owned) && selectedEntity == entity)
						_fleetModel.updateFleet(_fleetModel.getFleet(entity.id));
				}
			}
			sectorInteractSystem.showSelector();
		}

		/**
		 * Called to update misc. attributes on entities within a sector.
		 * @param updates A list of entities to update
		 */
		private function sectorUpdateEntities( updates:Vector.<SectorEntityUpdateData> ):void
		{
			var cargo:Cargo;
			var detail:Detail;
			var entity:Entity;
			var entityUpdate:SectorEntityUpdateData;
			var position:Position;
			var vcList:VCList;
			var vcSystem:VCSystem = VCSystem(_game.getSystem(VCSystem));
			for (var i:int = 0; i < updates.length; i++)
			{
				entityUpdate = updates[i];
				entity = _game.getEntity(entityUpdate.id);

				if (!entity)
					continue;

				detail = entity.get(Detail);
				if (vcSystem)
				{
					position = entity.get(Position);
					switch (detail.type)
					{
						case TypeEnum.STARBASE_SECTOR_IGA:
							vcList = entity.get(VCList);
							if (entityUpdate.bubbled)
							{
								vcList.addComponentType(TypeEnum.STARBASE_SHIELD_IGA);
								if (entityUpdate.currentHealthPct < _prototypeModel.getConstantPrototypeByName("protectionLowDamageThreshold").getValue('value'))
									_vfxFactory.createSectorExplosion(entity, position.x, position.y);
							} else
								vcList.removeComponentType(TypeEnum.STARBASE_SHIELD_IGA);
							Attack(entity.get(Attack)).bubbled = entityUpdate.bubbled;
							Animation(entity.get(Animation)).label = (entityUpdate.currentHealthPct < .25) ? detail.assetVO.spriteName + detail.level + "DMG" : detail.assetVO.spriteName + detail.level;
							break;
						case TypeEnum.STARBASE_SECTOR_SOVEREIGNTY:
							vcList = entity.get(VCList);
							if (entityUpdate.bubbled)
							{
								vcList.addComponentType(TypeEnum.STARBASE_SHIELD_SOVEREIGNTY);
								if (entityUpdate.currentHealthPct < _prototypeModel.getConstantPrototypeByName("protectionLowDamageThreshold").getValue('value'))
									_vfxFactory.createSectorExplosion(entity, position.x, position.y);
							} else
								vcList.removeComponentType(TypeEnum.STARBASE_SHIELD_SOVEREIGNTY);
							Attack(entity.get(Attack)).bubbled = entityUpdate.bubbled;
							Animation(entity.get(Animation)).label = (entityUpdate.currentHealthPct < .25) ? detail.assetVO.spriteName + detail.level + "DMG" : detail.assetVO.spriteName + detail.level;
							break;
						case TypeEnum.STARBASE_SECTOR_TYRANNAR:
							vcList = entity.get(VCList);
							if (entityUpdate.bubbled)
							{
								vcList.addComponentType(TypeEnum.STARBASE_SHIELD_TYRANNAR);
								if (entityUpdate.currentHealthPct < _prototypeModel.getConstantPrototypeByName("protectionLowDamageThreshold").getValue('value'))
									_vfxFactory.createSectorExplosion(entity, position.x, position.y);
							} else
								vcList.removeComponentType(TypeEnum.STARBASE_SHIELD_TYRANNAR);
							Attack(entity.get(Attack)).bubbled = entityUpdate.bubbled;
							Animation(entity.get(Animation)).label = (entityUpdate.currentHealthPct < .25) ? detail.assetVO.spriteName + detail.level + "DMG" : detail.assetVO.spriteName + detail.level;
							break;
					}
				}

				cargo = entity.get(Cargo);
				if (cargo)
				{
					cargo.cargo = entityUpdate.cargo;

					var fleetVO:FleetVO = _fleetModel.getFleet(entityUpdate.id);
					if (fleetVO)
					{
						fleetVO.currentCargo = cargo.cargo;
						_fleetModel.updateFleet(fleetVO);

						_soundController.playSound(AudioEnum.AFX_GLOBAL_CARGO_COLLECT);
					}
				}
			}
		}

		/**
		 *
		 * @param response
		 */
		public function sectorFleetTravelAlert( response:SectorFleetTravelAlertResponse ):void
		{
			var fleetVO:FleetVO = _fleetModel.getFleet(response.entityId);
			if (fleetVO)
			{
				fleetVO.sector = response.sectorKey;
				_fleetModel.updateFleet(fleetVO);
			}
		}

		/**
		 *
		 * @param response
		 */
		public function handleUniverseSectorListResponse( response:UniverseSectorListResponse ):void
		{
			_sectorModel.addDestinations(response.sectors);
			_sectorModel.addPrivateDestinations(response.privateSectors);
		}

		/**
		 *
		 * @param id
		 * @param x
		 * @param y
		 */
		public function sectorMoveFleet( id:String, x:int, y:int ):void
		{
			var order:SectorOrderRequest = SectorOrderRequest(_serverController.getRequest(ProtocolEnum.SECTOR_CLIENT, RequestEnum.SECTOR_ISSUE_ORDER));
			order.entityId = id;
			order.orderType = OrderEnum.MOVE;
			order.targetLocationX = x;
			order.targetLocationY = y;
			_serverController.send(order);
		}

		/**
		 *
		 */
		public function sectorRequestBaseline( conectToSector:Boolean = true ):void
		{
			if (conectToSector)
			{
				var connectRequest:ProxyConnectToSectorRequest = ProxyConnectToSectorRequest(_serverController.getRequest(ProtocolEnum.PROXY_CLIENT, RequestEnum.PROXY_CONNECT_TO_SECTOR));
				connectRequest.key = _sectorModel.targetSector;
				_serverController.send(connectRequest);
			}

			var request:SectorRequestBaselineRequest = SectorRequestBaselineRequest(_serverController.getRequest(ProtocolEnum.SECTOR_CLIENT, RequestEnum.SECTOR_REQUEST_BASELINE));
			var sis:SectorInteractSystem             = SectorInteractSystem(_game.getSystem(SectorInteractSystem));
			request.viewX = sis.sceneX;
			request.viewY = sis.sceneY;
			_serverController.send(request);
		}

		private function sectorShowEntities( entities:Vector.<SectorEntityData>, includeSelfOwned:Boolean ):void
		{
			var entityData:SectorEntityData;
			for (var i:int = 0; i < entities.length; i++)
			{
				entityData = entities[i];
				if (!includeSelfOwned && entityData.ownerId == CurrentUser.id)
					continue;

				var entity:Entity = _game.getEntity(entityData.id);

				switch (entityData.type)
				{
					case SectorEntityTypeEnum.BASE:
						if (!entity)
						{
							_sectorFactory.createSectorBase(entityData);
						}
						break;
					case SectorEntityTypeEnum.FLEET:
						if (!entity)
						{
							_shipFactory.createFleet(entityData);
						}

						if (entityData.ownerId == CurrentUser.id)
						{
							var fleetVO:FleetVO = _fleetModel.getFleet(entityData.id);
							fleetVO.currentHealth = entityData.currentHealthPct;
							fleetVO.sector = _sectorModel.sectorID;
							if (entityData.state == SectorEntityStateEnum.DEFENDING)
								fleetVO.defendTarget = "defending";
						}
						break;
					case SectorEntityTypeEnum.TRANS_GATE:
						if (!entity)
						{
							_sectorFactory.createTransgate(entityData);
						}
						break;
					case SectorEntityTypeEnum.DEPOT:
						if (!entity)
						{
							_sectorFactory.createDepot(entityData);
						}
						break;
					case SectorEntityTypeEnum.DERELICT:
						if (!entity)
						{
							_sectorFactory.createDerelict(entityData);
						}
						break;
				}
			}

			_fleetModel.updateFleet(null);
		}

		private function sectorShowObjectives( objectives:Vector.<SectorObjectiveData> ):void
		{
			var objectiveData:SectorObjectiveData;
			for (var i:int = 0; i < objectives.length; i++)
			{
				objectiveData = objectives[i];

				var entity:Entity = _game.getEntity(objectiveData.missionKey);

				if (!entity)
					_sectorFactory.createObjective(objectiveData);

			}
		}

		//============================================================================================================
		//************************************************************************************************************
		//													STARBASE
		//************************************************************************************************************
		//============================================================================================================

		/**
		 *
		 * @param response
		 */
		public function handleStarbaseBaselineResponse( response:StarbaseBaselineResponse ):void
		{
			if(!response.validData)
			{
				return;
			}
			_logger.debug(' -- Received StarbaseBaselineResponse [bases: {0}, buildings: {1}, fleets: {2}, ships: {3}, isUpdate:{4}, reason: {5}]',
						  [response.bases.length, response.buildings.length, response.fleets.length, response.ships.length, response.update, response.updateReason]);

			_starbaseModel.setBaseDirty();

			if (!response.update)
				_prototypeModel.setSplits(response.activeSplitPrototypes);

			//handle starbases
			if(response.baselineType == StarbaseBaselineResponse.BASELINE_ALL || response.baselineType & StarbaseBaselineResponse.BASELINE_BASE)
			{
				for (var i:int = 0; i < response.bases.length; i++)
				{
					_starbaseModel.importBaseData(response.bases[i], !response.update);
				}
			}
			//handle buildings
			if(response.baselineType == StarbaseBaselineResponse.BASELINE_ALL || response.baselineType & StarbaseBaselineResponse.BASELINE_BUILDING)
			{
				for (i = 0; i < response.buildings.length; i++)
				{
					_starbaseModel.importBuildingData(response.buildings[i]);
				}
			}
			//handle buffs
			if(response.baselineType == StarbaseBaselineResponse.BASELINE_ALL || response.baselineType & StarbaseBaselineResponse.BASELINE_BUFF)
			{
				for (i = 0; i < response.buffs.length; i++)
				{
					_starbaseModel.importBuffData(response.buffs[i]);
				}
			}

			//handle blueprints
			if(response.baselineType == StarbaseBaselineResponse.BASELINE_ALL || response.baselineType & StarbaseBaselineResponse.BASELINE_BLUEPRINT)
			{
				for (i = 0; i < response.blueprints.length; i++)
				{
					_blueprintModel.importPlayerBlueprints(response.blueprints[i], response.update);
				}
			}

			//handle missions
			if(response.baselineType == StarbaseBaselineResponse.BASELINE_ALL || response.baselineType & StarbaseBaselineResponse.BASELINE_MISSION)
			{
				for (i = 0; i < response.missions.length; i++)
				{
					_missionModel.importMissionData(response.missions[i]);
					//see if the fte needs any of these missions
					if (_fteController.running)
						_fteController.checkMissionRequired(_missionModel.currentMission);
				}
			}

			//handle research
			if(response.baselineType == StarbaseBaselineResponse.BASELINE_ALL || response.baselineType & StarbaseBaselineResponse.BASELINE_RESEARCH)
			{
				for (i = 0; i < response.research.length; i++)
				{
					_starbaseModel.importResearchData(response.research[i]);
				}
	
				if (!response.update)
					_starbaseModel.addBeginnerResearch(_prototypeModel.getResearchPrototypes());
			}

			//handle traderoutes
			if(response.baselineType == StarbaseBaselineResponse.BASELINE_ALL || response.baselineType & StarbaseBaselineResponse.BASELINE_TRADE_ROUTE)
			{
				for (i = 0; i < response.tradeRoutes.length; ++i)
				{
					_starbaseModel.importTradeRouteData(response.tradeRoutes[i]);
				}
			}

			//handle fleets
			if(response.baselineType == StarbaseBaselineResponse.BASELINE_ALL || response.baselineType & StarbaseBaselineResponse.BASELINE_FLEET)
			{
				for (i = 0; i < response.fleets.length; ++i)
				{
					_fleetModel.importFleetData(response.fleets[i]);
				}
			}
			//handle ships
			if(response.baselineType == StarbaseBaselineResponse.BASELINE_ALL || response.baselineType & StarbaseBaselineResponse.BASELINE_SHIP)
			{
				for (i = 0; i < response.ships.length; ++i)
				{
					_fleetModel.importShipData(response.ships[i]);
				}
			}
			if(response.baselineType == StarbaseBaselineResponse.BASELINE_ALL || response.baselineType & StarbaseBaselineResponse.BASELINE_FLEET || response.baselineType & StarbaseBaselineResponse.BASELINE_SHIP)
				_fleetModel.updateFleet(null);
			
			if(response.baselineType == StarbaseBaselineResponse.BASELINE_ALL || response.baselineType & StarbaseBaselineResponse.BASELINE_PLAYER)
				CurrentUser.addBookmarks(response.bookmarks.bookmarks);

			if (!response.update)
			{
				_eventController.addEvents(response.activeEvents, response.upcomingEvents, response.nowMillis);

				if (Application.STATE == StateEvent.GAME_STARBASE)
					IStarbasePresenter(_presenter).showBuildings();
				
				if(response.baselineType == StarbaseBaselineResponse.BASELINE_ALL || response.baselineType & StarbaseBaselineResponse.BASELINE_SETTING)
					_settingsController.setSettings(response.settings);
			}
			if(response.baselineType == StarbaseBaselineResponse.BASELINE_ALL || response.baselineType & StarbaseBaselineResponse.BASELINE_FLEET || response.baselineType & StarbaseBaselineResponse.BASELINE_SHIP)
			{
				_fleetModel.dirty = false;
				_fleetModel.maxAvailableShipSlots = _prototypeModel.getConstantPrototypeValueByName('MaxAvailabeShipSlotsBase') + CurrentUser.purchasedShipSlots;
			}
			_starbaseModel.currentBase.updateResources();
			_transactionController.dataImported();
		}

		/**
		 *
		 * @param response
		 */
		public function handleStarbaseTransactionResponse( response:ITransactionResponse ):void
		{
			_transactionController.handleResponse(response);
		}

		/**
		 *
		 * @param response
		 */
		public function starbaseInstancedMissionAlert( response:StarbaseInstancedMissionAlertResponse ):void
		{
			//see if any fleets are in battle
			var fleets:Vector.<FleetVO> = _fleetModel.fleets;
			var fleetVO:FleetVO;
			var inBattle:Boolean        = Application.STATE == null || ((Application.STATE == StateEvent.GAME_BATTLE_INIT || Application.STATE == StateEvent.GAME_BATTLE) && !_battleModel.finished);
			var newInstancedMissionCombat:Boolean   = false;
			var soundAlarm:Boolean      = false;
			var notifyFleetID:String;
			
			//set the battle server address of center space battles
			/*if (_starbaseModel.centerSpaceBase)
			{
			if (response.centerSpaceBaseBattle != null && response.centerSpaceBaseBattle != "")
			{
			if (_starbaseModel.centerSpaceBase.battleServerAddress == null)
			soundAlarm = true;
			_starbaseModel.centerSpaceBase.battleServerAddress = response.centerSpaceBaseBattle;
			} else
			_starbaseModel.centerSpaceBase.battleServerAddress = null;
			}*/
			//set the battle server address of homebase battles
			if (response.instancedMissionBattle != null && response.instancedMissionBattle != "")
			{
				if (_starbaseModel.homeBase.instancedMissionAddress == null)
				{
					newInstancedMissionCombat = true;
					soundAlarm = true;
				}
				_starbaseModel.homeBase.instancedMissionAddress = response.instancedMissionBattle;
			} else
				_starbaseModel.homeBase.instancedMissionAddress = null;
			
			if (!_fteController.running && Application.STATE != null && !inBattle)
			{
				var event:StarbaseEvent;
				if (newInstancedMissionCombat && response.instancedMissionBattle && response.instancedMissionBattle != "")
				{
					//notify of a home base battle
					event = new StarbaseEvent(StarbaseEvent.ALERT_INSTANCED_MISSION_BATTLE, _starbaseModel.homeBase.id);
					event.battleServerAddress = response.instancedMissionBattle;
					soundAlarm = true;
				}
				if (event)
					_eventDispatcher.dispatchEvent(event);
			}
			
			if (_firstTimeInit)
			{
				TimeLog.endTimeLog(TimeLogEnum.SERVER_GAME_DATA, "starbase");
				var serverEvent:ServerEvent = new ServerEvent(ServerEvent.AUTHORIZED);
				_eventDispatcher.dispatchEvent(serverEvent);
				_firstTimeInit = soundAlarm = false;
			}
			
			//play sound
			if (soundAlarm)
				_soundController.playSound(AudioEnum.AFX_GLOBAL_ALARM);
			
			_fleetModel.updateFleet(null);
		}
		
		public function starbaseBattleAlert( response:StarbaseBattleAlertResponse ):void
		{
			//see if any fleets are in battle
			var fleets:Vector.<FleetVO> = _fleetModel.fleets;
			var fleetVO:FleetVO;
			var inBattle:Boolean        = Application.STATE == null || ((Application.STATE == StateEvent.GAME_BATTLE_INIT || Application.STATE == StateEvent.GAME_BATTLE) && !_battleModel.finished);
			var newBaseCombat:Boolean   = false;
			var soundAlarm:Boolean      = false;
			var notifyFleetID:String;
			for (var i:int = 0; i < fleets.length; i++)
			{
				fleetVO = fleets[i];
				if (response.fleetBattles[fleetVO.id])
				{
					//if this is a new battle then we want to notify. also notify if the fleet we are currently watching comes under attack from a different opponent
					if ((!fleetVO.inBattle && !inBattle) || (_battleModel.battleServerAddress == fleetVO.battleServerAddress && response.fleetBattles[fleetVO.id] != fleetVO.battleServerAddress))
						notifyFleetID = fleetVO.id;
					if (!fleetVO.inBattle)
						soundAlarm = true;
					fleetVO.inBattle = true;
					fleetVO.battleServerAddress = response.fleetBattles[fleetVO.id];
				} else
				{
					fleetVO.inBattle = false;
					fleetVO.battleServerAddress = null;
				}
				//show or hide the battle alert if we're in the sector view
				if (Application.STATE == StateEvent.GAME_SECTOR)
				{
					if (SectorInteractSystem(_game.getSystem(SectorInteractSystem)).selected && SectorInteractSystem(_game.getSystem(SectorInteractSystem)).selected.id == fleetVO.id)
					{
						ISectorPresenter(_presenter).onBattle();
						//don't want to send out the notification if the battle alert is going to show
						if (notifyFleetID == fleetVO.id)
							notifyFleetID = null;
						if (_inFTE)
						{
							_inFTE = false;
							_fteController.nextStep();
						}
					}
				}
			}

			//set the battle server address of center space battles
			/*if (_starbaseModel.centerSpaceBase)
			   {
			   if (response.centerSpaceBaseBattle != null && response.centerSpaceBaseBattle != "")
			   {
			   if (_starbaseModel.centerSpaceBase.battleServerAddress == null)
			   soundAlarm = true;
			   _starbaseModel.centerSpaceBase.battleServerAddress = response.centerSpaceBaseBattle;
			   } else
			   _starbaseModel.centerSpaceBase.battleServerAddress = null;
			   }*/
			//set the battle server address of homebase battles
			if (response.homeBaseBattle != null && response.homeBaseBattle != "")
			{
				if (_starbaseModel.homeBase.battleServerAddress == null)
				{
					newBaseCombat = true;
					soundAlarm = true;
				}
				_starbaseModel.homeBase.battleServerAddress = response.homeBaseBattle;
			} else
				_starbaseModel.homeBase.battleServerAddress = null;

			if (!_fteController.running && Application.STATE != null && !inBattle)
			{
				var event:StarbaseEvent;
				if (newBaseCombat && response.centerSpaceBaseBattle && response.centerSpaceBaseBattle != "" && response.centerSpaceBaseBattle != "0")
				{
					//notify of a center space battle
					event = new StarbaseEvent(StarbaseEvent.ALERT_STARBASE_BATTLE, _starbaseModel.centerSpaceBase.id);
					event.battleServerAddress = response.centerSpaceBaseBattle;
					soundAlarm = true;
				} else if (newBaseCombat && response.homeBaseBattle && response.homeBaseBattle != "")
				{
					//notify of a home base battle
					event = new StarbaseEvent(StarbaseEvent.ALERT_STARBASE_BATTLE, _starbaseModel.homeBase.id);
					event.battleServerAddress = response.homeBaseBattle;
					soundAlarm = true;
				} else if (notifyFleetID)
				{
					//notify that a fleet is in battle
					event = new StarbaseEvent(StarbaseEvent.ALERT_FLEET_BATTLE, null);
					event.fleetID = notifyFleetID;
					event.battleServerAddress = response.fleetBattles[notifyFleetID];
				}
				if (event)
					_eventDispatcher.dispatchEvent(event);
			}

			if (_firstTimeInit)
			{
				TimeLog.endTimeLog(TimeLogEnum.SERVER_GAME_DATA, "starbase");
				var serverEvent:ServerEvent = new ServerEvent(ServerEvent.AUTHORIZED);
				_eventDispatcher.dispatchEvent(serverEvent);
				_firstTimeInit = soundAlarm = false;
			}

			//play sound
			if (soundAlarm)
				_soundController.playSound(AudioEnum.AFX_GLOBAL_ALARM);

			_fleetModel.updateFleet(null);
		}

		/**
		 *
		 * @param response
		 */
		public function handleStarbaseMissionCompleteResponse( response:StarbaseMissionCompleteResponse ):void
		{
			if (Application.STATE != null)
			{
				var mission:MissionVO = _missionModel.getMissionByID(response.missionPersistence);
				if (mission && mission.isFTE)
				{
					if (mission.getValue("automaticallyAcceptRewards") == false)
						_transactionController.missionAcceptRewards(mission.id);
					_fteController.checkMissionRequired(mission);
				} else if (mission && !mission.complete && mission.category != MissionEnum.DAILY)
				{
					_missionModel.missionComplete();
					_transactionController.dataImported();
				}
			}
		}

		/**
		 *
		 * @param response
		 */
		public function handleStarbaseFleetDockedResponse( response:StarbaseFleetDockedResponse ):void
		{
			if (response.alloyCargo + response.energyCargo + response.syntheticCargo > 0)
			{
				var toastEvent:ToastEvent = new ToastEvent();
				toastEvent.toastType = ToastEnum.FLEET_DOCKED;
				toastEvent.addStrings(_fleetModel.getFleet(response.fleetPersistence).name, _hasDocked, response.alloyCargo, _alreadyRecieved, response.energyCargo, response.syntheticCargo);
				_eventDispatcher.dispatchEvent(toastEvent);
			}
		}

		/**
		 *
		 * @param response
		 */
		public function handleStarbaseBountyRewardResponse( response:StarbaseBountyRewardResponse ):void
		{
		/*var toastEvent:ToastEvent = new ToastEvent();
		   toastEvent.toastType = ToastEnum.BOUNTY_REWARD;
		   toastEvent.addStrings(response.bounty);
		   _eventDispatcher.dispatchEvent(toastEvent);*/
		}

		public function handleMessageOftheDayResponse( response:StarbaseMotdListResponse ):void
		{
			_motdModel.addMessages(response.motds);
		}

		public function requestMotDRead( motdKey:String ):void
		{
			var motDReadRequest:StarbaseMotDReadRequest = StarbaseMotDReadRequest(_serverController.getRequest(ProtocolEnum.STARBASE_CLIENT, RequestEnum.STARBASE_MARK_MOTD_READ_MESSAGE));
			motDReadRequest.key = motdKey;
			_serverController.send(motDReadRequest);
		}

		public function handleStarbaseDailyResponse( response:StarbaseDailyResponse ):void
		{
			_motdDailyModel.addData(response.escalation, response.canNextClaimDelta, response.dailyResetsDelta, response.header, response.protocolID);
		}

		public function handleStarbaseDailyRewardResponse( response:StarbaseDailyRewardResponse ):void
		{
			_motdDailyModel.addRewardData(response);
		}
		public function requestDailyClaim( header:int, protocolID:int ):void
		{
			var motDDailyClaimRequest:StarbaseClaimDailyRequest = StarbaseClaimDailyRequest(_serverController.getRequest(ProtocolEnum.STARBASE_CLIENT, RequestEnum.STARBASE_CLAIM_DAILY_MESSAGE));
			_serverController.send(motDDailyClaimRequest);
		}

		public function handleStarbaseAvailableRerollResponse( response:StarbaseAvailableRerollResponse ):void
		{
			_battleModel.addAvailableReroll(response);
		}
		public function handleStarbaseUnavailableRerollResponse( response:StarbaseUnavailableRerollResponse ):void
		{
			_battleModel.addUnavailableReroll(response);
		}
		public function handleStarbaseRerollChanceResponse( response:StarbaseRerollChanceResultResponse ):void
		{
			_battleModel.updateRerollFromScan(response);
		}
		public function handleStarbaseRerollReceivedResponse( response:StarbaseRerollReceivedResultResponse ):void
		{
			_battleModel.updateRerollFromReroll(response);
		}

		public function handleStarbaseMoveStarbaseResponse( response:StarbaseMoveStarbaseResponse ):void
		{
			if (response.status == 0)
			{
				var toastEvent:ToastEvent = new ToastEvent();
				toastEvent.toastType = ToastEnum.BASE_RELOCATED;
				toastEvent.addStrings(_baseRelocatedTitle, _baseRelocatedBody);
				_eventDispatcher.dispatchEvent(toastEvent);
			}

		}

		//============================================================================================================
		//************************************************************************************************************
		//													ACHIEVEMENTS
		//************************************************************************************************************
		//============================================================================================================

		public function handleStarbaseAchievementsResponse( response:StarbaseAchievementsResponse ):void
		{
			_achievementModel.addData(response);
		}

		public function requestAchievements():void
		{
			var requestAchievements:StarbaseRequestAchievementsRequest = StarbaseRequestAchievementsRequest(_serverController.getRequest(ProtocolEnum.STARBASE_CLIENT, RequestEnum.STARBASE_REQUEST_ACHIEVEMENTS));
			_serverController.send(requestAchievements);
		}
		
		public function handleStarbaseAllScoresResponse( response:StarbaseAllScoresResponse ):void
		{
			_achievementModel.addAllScoreData(response);
		}
		
		public function requestAllScores():void
		{
			var requestAllScores:StarbaseAllScoresRequest = StarbaseAllScoresRequest(_serverController.getRequest(ProtocolEnum.STARBASE_CLIENT, RequestEnum.STARBASE_REQUEST_ALL_SCORES));
			_serverController.send(requestAllScores);
		}

		public function claimAchievementReward( achievement:String ):void
		{
			var starbaseClaimAchievementRewardRequest:StarbaseClaimAchievementRewardRequest = StarbaseClaimAchievementRewardRequest(_serverController.getRequest(ProtocolEnum.STARBASE_CLIENT, RequestEnum.
																																								 STARBASE_CLAIM_ACHIEVEMENT_REWARD));
			starbaseClaimAchievementRewardRequest.achievement = achievement;
			_serverController.send(starbaseClaimAchievementRewardRequest);
		}
		
		public function mintNFT( tokenType:int, tokenAmount:int, tokenPrototype:String ):void
		{
			_transactionController.mintNFTTransaction(tokenType, tokenAmount, tokenPrototype);
		}

		//============================================================================================================
		//************************************************************************************************************
		//													PAYMENTS
		//************************************************************************************************************
		//============================================================================================================

		public function handleStarbaseGetPaywallPayoutsResponse( response:StarbaseGetPaywallPayoutsResponse ):void
		{
			var paywall:PaywallEvent = new PaywallEvent(PaywallEvent.OPEN_PAYWALL);
			paywall.paywallData = response.data;
			_eventDispatcher.dispatchEvent(paywall);
		}

		public function requestPaywallPayouts():void
		{
			if (Application.NETWORK == Application.NETWORK_FACEBOOK)
			{
				var paywall:PaywallEvent = new PaywallEvent(PaywallEvent.OPEN_PAYWALL);
				paywall.paywallData = ExternalInterfaceAPI.GetFacebookItems();
				_eventDispatcher.dispatchEvent(paywall);
			}
			else
			{
				//ExternalInterfaceAPI.logConsole("Open Kongregate Payment 2");
				var requestPayouts:StarbaseGetPaywallPayoutsRequest = StarbaseGetPaywallPayoutsRequest(_serverController.getRequest(ProtocolEnum.STARBASE_CLIENT, RequestEnum.STARBASE_GET_PAYWALL_PAYOUTS));
				_serverController.send(requestPayouts);
			}
		}

		public function requestPaymentVerification( externalTrkid:String = '', payoutId:String = '', responseData:String = '', responseSignature:String = '' ):void
		{
			var req:StarbaseVerifyPaymentRequest = StarbaseVerifyPaymentRequest(_serverController.getRequest(ProtocolEnum.STARBASE_CLIENT, RequestEnum.STARBASE_VERIFY_PAYMENT));
			req.externalTrkid = externalTrkid;
			req.payoutId = payoutId;
			req.responseData = responseData;
			req.responseSignature = responseSignature;
			_serverController.send(req);
			_logger.debug('requestPaymentVerification - Request = {0}, externalTrkid = {1}, payoutId = {2}, responseData = {3}, responseSignature = {4}', [req, externalTrkid, payoutId, responseData, responseSignature]);
		}


		//============================================================================================================
		//************************************************************************************************************
		//													MAIL
		//************************************************************************************************************
		//============================================================================================================
		/**
		 *
		 * @param response
		 */
		public function handleMailInboxResponse( response:MailInboxResponse ):void
		{
			_mailModel.addMailHeaders(response.mailData);
			var mailInvites:Dictionary = _mailModel.getMailInvites();
			_allianceModel.setEmailInvites(mailInvites);
			// Load alliances required to set up invitaions.
			var modelAlliances:Dictionary = _allianceModel.getAlliances();
			for (var key:Object in mailInvites) 
			{
				if (!(mailInvites[key] in modelAlliances))
				{	
					var getAllianceBaseline:AllianceRequestBaselineRequest = AllianceRequestBaselineRequest(_serverController.getRequest(ProtocolEnum.ALLIANCE_CLIENT, RequestEnum.ALLIANCE_REQUEST_BASELINE));
					getAllianceBaseline.allianceKey = mailInvites[key];
					_serverController.send(getAllianceBaseline);
				}
			}
		}

		public function handleMailDetailResponse( response:MailDetailResponse ):void
		{
			_mailModel.addMailDetail(response.key, response.sender, response.senderAlliance, response.body, response.senderRace, response.html);
		}

		public function handleUnreadResponse( response:MailUnreadResponse ):void
		{
			_mailModel.updateCount(response.unread, response.total, true);
		}

		public function mailSendMessage( playerID:String, subject:String, body:String ):void
		{
			var sendMessage:MailSendMailRequest = MailSendMailRequest(_serverController.getRequest(ProtocolEnum.MAIL_CLIENT, RequestEnum.MAIL_SEND_MAIL));
			sendMessage.recipient = playerID;
			sendMessage.subject = subject;
			sendMessage.body = body;
			_serverController.send(sendMessage);
		}

		public function mailSendAllianceMessage( subject:String, body:String ):void
		{
			var sendMessage:MailSendAllianceMailRequest = MailSendAllianceMailRequest(_serverController.getRequest(ProtocolEnum.MAIL_CLIENT, RequestEnum.MAIL_SEND_ALLIANCE_MAIL));
			sendMessage.subject = subject;
			sendMessage.body = body;
			_serverController.send(sendMessage);
		}

		public function mailGetMailbox():void
		{
			var getMail:MailRequestInboxRequest = MailRequestInboxRequest(_serverController.getRequest(ProtocolEnum.MAIL_CLIENT, RequestEnum.MAIL_REQUEST_INBOX));
			_serverController.send(getMail);
		}

		public function mailGetMailDetail( mailKey:String ):void
		{
			var getMailDetail:MailReadMailRequest = MailReadMailRequest(_serverController.getRequest(ProtocolEnum.MAIL_CLIENT, RequestEnum.MAIL_READ_MAIL));
			getMailDetail.mail = mailKey;
			_serverController.send(getMailDetail);
		}

		public function mailDelete( v:Vector.<String> ):void
		{
			var mailDelete:MailDeleteMailRequest = MailDeleteMailRequest(_serverController.getRequest(ProtocolEnum.MAIL_CLIENT, RequestEnum.MAIL_DELETE_MAIL));
			mailDelete.mail = v;
			_serverController.send(mailDelete);
		}

		//============================================================================================================
		//************************************************************************************************************
		//													BATTLE LOG (starbase)
		//************************************************************************************************************
		//============================================================================================================

		public function battleLogGetBattleListStarbase():void
		{
			var getBattleLogList:BattleLogListRequest = BattleLogListRequest(_serverController.getRequest(ProtocolEnum.STARBASE_CLIENT, RequestEnum.STARBASE_BATTLELOG_LIST));
			_serverController.send(getBattleLogList);
		}

		public function battleLogGetBattleDetailStarbase( battleLogID:String ):void
		{
			var getBattleLogDetail:BattleLogDetailRequest = BattleLogDetailRequest(_serverController.getRequest(ProtocolEnum.STARBASE_CLIENT, RequestEnum.STARBASE_BATTLELOG_DETAILS));
			getBattleLogDetail.battleLogID = battleLogID;
			_serverController.send(getBattleLogDetail);
		}

		public function handleStarbaseBattleLogListResponse( response:BattleLogListResponse ):void
		{
			_battleLogModel.addBattleLogList(response.battles);
		}

		public function handleStarbaseBattleLogDetailsResponse( response:BattleLogDetailsResponse ):void
		{
			_battleLogModel.addBattleLogDetail(response);
		}


		//============================================================================================================
		//************************************************************************************************************
		//													BATTLE LOG (Mongo)
		//************************************************************************************************************
		//============================================================================================================

		public function battleLogGetBattleList( filter:String ):void
		{
			if (Application.BATTLE_WEB_PATH == null)
			{
				battleLogGetBattleListStarbase();
				return;
			}

			var absoluteUrl:String = Application.BATTLE_WEB_PATH + "?p=" + CurrentUser.id;
			switch (filter)
			{
				case BattleLogFilterEnum.SELFPVP:
					absoluteUrl += "&pvp=true";
					break;
				case BattleLogFilterEnum.SELFPVE:
					absoluteUrl += "&pve=true";
					break;
				case BattleLogFilterEnum.BASEPVP:
					absoluteUrl = Application.BATTLE_WEB_PATH + "?pvpbase";
					break;
				case BattleLogFilterEnum.FLEETPVP:
					absoluteUrl = Application.BATTLE_WEB_PATH + "?pvpfleet";
					break;
				case BattleLogFilterEnum.BESTPVE:
					absoluteUrl = Application.BATTLE_WEB_PATH + "?bestpve";
					break;
				case BattleLogFilterEnum.SELFALL:
				default:
					break;
			}

			trace("requesting " + absoluteUrl);
			AssetModel.instance.getFromCache(absoluteUrl, handleBattleLogListResponse, LoadPriority.HIGH, true);
		}

		public function battleLogGetBattleDetail( battleId:String ):void
		{
			if (Application.BATTLE_WEB_PATH == null)
			{
				battleLogGetBattleDetailStarbase(battleId)
				return;
			}
			var absoluteUrl:String = Application.BATTLE_WEB_PATH + "?detail=" + battleId;
			trace("requesting " + absoluteUrl);
			AssetModel.instance.getFromCache(absoluteUrl, handleBattleLogDetailsResponse, LoadPriority.HIGH, true);
		}

		public function handleBattleLogListResponse( json:Object ):void
		{
			var absoluteUrl:String             = Application.BATTLE_WEB_PATH + "?p=" + CurrentUser.id;
			AssetModel.instance.removeFromCache(absoluteUrl);
			if (json == AssetModel.FAILED)
			{
				trace("failed", absoluteUrl);
				return;
			}

			trace("received", absoluteUrl);
			var response:BattleLogListResponse = new BattleLogListResponse();
			response.readJSON(json);
			_battleLogModel.addBattleLogList(response.battles);
		}

		public function handleBattleLogDetailsResponse( json:Object ):void
		{
			if (json == AssetModel.FAILED)
			{
				return;
			}
			trace("received BattleLogDetailsResponse");
			var response:BattleLogDetailsResponse = new BattleLogDetailsResponse();
			response.readJSON(json);
			_battleLogModel.addBattleLogDetail(response);
		}

		//============================================================================================================
		//************************************************************************************************************
		//													CHAT
		//************************************************************************************************************
		//============================================================================================================

		public function handleChatBaselineResponse( response:ChatBaselineResponse ):void
		{
			_chatController.addBlockedUsers(response);
		}

		public function requestReportPlayer( playerID:String ):void
		{
			var reportPlayerRequest:ChatReportChatRequest = ChatReportChatRequest(_serverController.getRequest(ProtocolEnum.CHAT_CLIENT, RequestEnum.CHAT_REPORT_CHAT));
			reportPlayerRequest.playerKey = playerID;
			_serverController.send(reportPlayerRequest);
		}


		//============================================================================================================
		//************************************************************************************************************
		//													BOOKMARKS
		//************************************************************************************************************
		//============================================================================================================

		public function bookmarkSave( name:String, sector:String, nameProto:String, enumProto:String, sectorProto:String, x:int, y:int ):void
		{
			var saveBookmark:StarbaseBookmarkSaveRequest = StarbaseBookmarkSaveRequest(_serverController.getRequest(ProtocolEnum.STARBASE_CLIENT, RequestEnum.STARBASE_BOOKMARK_SAVE));
			saveBookmark.name = name;
			saveBookmark.sector = sector;
			saveBookmark.nameProto = nameProto;
			saveBookmark.enumProto = enumProto;
			saveBookmark.sectorProto = sectorProto;
			saveBookmark.x = x;
			saveBookmark.y = y;
			_serverController.send(saveBookmark);
		}

		public function bookmarkUpdate( bookmark:BookmarkVO ):void
		{
			var updateBookmark:StarbaseBookmarkUpdateRequest = StarbaseBookmarkUpdateRequest(_serverController.getRequest(ProtocolEnum.STARBASE_CLIENT, RequestEnum.STARBASE_BOOKMARK_UPDATE));
			updateBookmark.bookmark = bookmark;
			_serverController.send(updateBookmark);
		}

		public function bookmarkDelete( bookmarkIndex:uint ):void
		{
			var deleteBookmark:StarbaseBookmarkDeleteRequest = StarbaseBookmarkDeleteRequest(_serverController.getRequest(ProtocolEnum.STARBASE_CLIENT, RequestEnum.STARBASE_BOOKMARK_DELETE));
			deleteBookmark.index = bookmarkIndex;
			_serverController.send(deleteBookmark);
		}

		//============================================================================================================
		//************************************************************************************************************
		//												 LEADERBOARD
		//************************************************************************************************************
		//============================================================================================================

		public function handleWarfrontUpdate( response:WarfrontUpdateResponse ):void
		{
			_warfrontModel.importData(response);
		}

		public function leaderboardRequest( type:int, scope:int ):void
		{
			var leaderboardRequest:LeaderboardRequest = LeaderboardRequest(_serverController.getRequest(ProtocolEnum.LEADERBOARD_CLIENT, RequestEnum.LEADERBOARD_REQUEST_LEADERBOARD));
			leaderboardRequest.type = type;
			leaderboardRequest.scope = scope;
			_serverController.send(leaderboardRequest);
		}

		public function leaderboardRequestPlayerProfile( playerKey:String, name:String ):void
		{
			var leaderboardRequestPlayerProfile:LeaderboardRequestPlayerProfileRequest = LeaderboardRequestPlayerProfileRequest(_serverController.getRequest(ProtocolEnum.LEADERBOARD_CLIENT, RequestEnum.
																																							 LEADERBOARD_REQUEST_PLAYER_PROFILE));
			leaderboardRequestPlayerProfile.playerKey = playerKey;
			leaderboardRequestPlayerProfile.nameSearch = name;
			_serverController.send(leaderboardRequestPlayerProfile);
		}

		public function handlePlayerProfile( response:PlayerProfileResponse ):void
		{
			_playerModel.addPlayers(response.players)
		}

		public function handleLeaderboardUpdate( response:LeaderboardResponse ):void
		{
			_leaderboardModel.updateLeaderboardEntry(response);
		}


		//============================================================================================================
		//************************************************************************************************************
		//												 OFFER
		//************************************************************************************************************
		//============================================================================================================

		public function handleStarbaseOfferRedeemed( response:StarbaseOfferRedeemedResponse ):void
		{
			CurrentUser.removeOffer(response.offerPrototype);
		}

		//============================================================================================================
		//************************************************************************************************************
		//												 ALLIANCE
		//************************************************************************************************************
		//============================================================================================================

		public function allianceSendInvite( playerKey:String ):void
		{
			var sendInvite:AllianceSendInviteRequest = AllianceSendInviteRequest(_serverController.getRequest(ProtocolEnum.ALLIANCE_CLIENT, RequestEnum.ALLIANCE_SEND_INVITE));
			sendInvite.playerKey = playerKey;
			_serverController.send(sendInvite);
		}

		public function handleAllianceBaselineResponse( response:AllianceBaselineResponse ):void
		{
			_allianceModel.addAlliance(response.alliance);
			_allianceModel.addEmailInvites();
		}

		public function handleAllianceRosterResponse( response:AllianceRosterResponse ):void
		{
			_allianceModel.updateMembers(response.allianceKey, response.members);
		}

		public function handleAlliancePublicResponse( response:PublicAlliancesResponse ):void
		{
			_allianceModel.addOpenAlliances(response.alliances);
		}

		public function handleAllianceGenericResponse( response:AllianceGenericResponse ):void
		{
			_allianceModel.handleGenericMessage(response.responseEnum, response.allianceKey)
		}

		public function handleAllianceInviteResponse( response:AllianceInviteResponse ):void
		{
			_allianceModel.addInvitedAlliance(response.inviteVO)
		}

		//============================================================================================================
		//************************************************************************************************************
		//											         GENERAL
		//************************************************************************************************************
		//============================================================================================================

		/**
		 *
		 * @param id
		 * @param targetID
		 * @param moduleID
		 */
		public function toggleModule( id:String, targetID:String, moduleID:int ):void
		{
			var order:BattleToggleModuleOrderRequest = BattleToggleModuleOrderRequest(_serverController.getRequest(ProtocolEnum.BATTLE_CLIENT, RequestEnum.BATTLE_TOGGLE_MODULE_ORDER));
			order.entityID = id;
			order.targetID = targetID; // TODO - does this make sense in this message?
			order.issuedTick = ServerController.SIMULATED_TICK;
			order.moduleID = moduleID;
			_serverController.send(order);
		}

		private function destroyEntity( entityKey:String, reason:int ):void
		{
			//remove entities
			var entity:Entity = _game.getEntity(entityKey);
			if (entity)
			{
				var detail:Detail     = entity.get(Detail);
				var position:Position = entity.get(Position);
				if (reason == RemoveReasonEnum.Destroyed)
				{
					if (Application.STATE == StateEvent.GAME_SECTOR)
						_vfxFactory.createSectorExplosion(entity, position.x, position.y);
					else
						_vfxFactory.createExplosion(entity, position.x, position.y);
				}

				switch (detail.category)
				{
					case CategoryEnum.SHIP:
						if (entity.get(Ship))
						{
							var modules:Modules = entity.get(Modules);
							for (var j:int = 0; j < modules.entityModules.length; j++)
							{
								if (modules.entityModules[j])
									_attackFactory.destroyAttack(modules.entityModules[j]);
							}
							_shipFactory.destroyShip(entity);

						} else
						{
							// update the fleet state if it's a fleet
							if (entity.get(Owned))
							{
								var fleetVO:FleetVO = _fleetModel.getFleet(entity.id);
								if (reason == RemoveReasonEnum.Docked)
									fleetVO.state = FleetStateEnum.DOCKED;
							}
							if (reason == RemoveReasonEnum.TransgateTravel && Animation(entity.get(Animation)).visible == true)
							{
								//find the transgate the player entered
								var entities:Array = GridSystem(_game.getSystem(GridSystem)).getEntitiesAt(position.x, position.y);
								for (var i:int = 0; i < entities.length; i++)
								{
									if (entities[i].entity.has(Transgate))
									{
										//play the transgate animation
										if (!entities[i].animation.playing)
											entities[i].animation.playing = true;
									}
								}
								_soundController.playSound(AudioEnum.AFX_STG_TRANSGATE_ACTIVATION, 0.5);
							}
							_shipFactory.destroyFleet(entity);
						}
						break;
					case CategoryEnum.BUILDING:
						var health:Health = Health(entity.get(Health));
						//set the health of the building to 0 instead of removing it so the destroyed state is shown
						if (health)
							health.currentHealth = 0;
						if (entity.has(Interactable))
							ObjectPool.give(entity.remove(Interactable));
						if (entity.has(DebuffTray))
						{
							var vcList:VCList = entity.get(VCList);
							vcList.removeComponentType(TypeEnum.DEBUFF_TRAY);
							ObjectPool.give(entity.remove(DebuffTray));
						}
						if (detail.prototypeVO && detail.prototypeVO.itemClass == TypeEnum.FORCEFIELD)
							_starbaseFactory.destroyStarbaseItem(entity);
						break;
					case CategoryEnum.STARBASE:
						_starbaseFactory.destroyStarbaseItem(entity);
						break;
					case CategoryEnum.SECTOR:
						_sectorFactory.destroySectorEntity(entity);
						break;
				}
			}
		}

		private function fireDrones( drones:Array ):void
		{
			var ship:Entity;
			for (var i:int = 0; i < drones.length; i++)
			{
				var attack:DroneAttackData = drones[i];
				if (!_game.getEntity(attack.attackId))
				{
					ship = _game.getEntity(attack.entityOwnerId);
					_attackFactory.createDrone(ship, attack);
				}
			}
		}

		private function fireProjectiles( projectiles:Array ):void
		{
			var ship:Entity;
			for (var i:int = 0; i < projectiles.length; i++)
			{
				var attack:ProjectileAttackData = projectiles[i];
				if (!_game.getEntity(attack.attackId))
				{
					ship = _game.getEntity(attack.entityOwnerId);
					_attackFactory.createProjectile(ship, attack);
				}
			}
		}

		private function fireAreaAttacks( areaAttacks:Array ):void
		{
			var ship:Entity;
			for (var i:int = 0; i < areaAttacks.length; i++)
			{
				var attack:AreaAttackData = areaAttacks[i];

				if (!_game.getEntity(attack.attackId))
				{
					ship = _game.getEntity(attack.entityOwnerId);
					_attackFactory.createArea(ship ? ship.id : '', attack);
				}
			}
		}

		private function fireBeams( beams:Array ):void
		{
			for (var i:int = 0; i < beams.length; i++)
			{
				var attack:BeamAttackData = beams[i];
				if (!_game.getEntity(attack.attackId))
					_attackFactory.createBeam(attack);
			}
		}

		private function battleAddPlayers( players:Array ):void
		{
			for (var i:int = 0; i < players.length; i++)
			{
				_playerModel.addPlayer(PlayerVO(players[i]));
			}
		}

		private function addPlayers( players:Vector.<PlayerVO> ):void
		{
			for (var i:int = 0; i < players.length; i++)
			{
				_playerModel.addPlayer(players[i]);
			}
		}

		private function battleRemovePlayers( players:Array ):void
		{
			for (var i:int = 0; i < players.length; i++)
			{
				_playerModel.removePlayer(RemovedObjectData(players[i]).id);
			}
		}

		private function removePlayers( players:Vector.<RemovedObjectData> ):void
		{
			for (var i:int = 0; i < players.length; i++)
			{
				_playerModel.removePlayer(players[i].id);
			}
		}

		private function globalErrorHandler( errStr:String ):void
		{
			//if(CONFIG::DEBUG == true)
			{
				// @todo: throttle
				var msg:ProxyReportCrashRequest      = ProxyReportCrashRequest(_serverController.getRequest(ProtocolEnum.PROXY_CLIENT, RequestEnum.PROXY_REPORT_CRASH));
				msg.dataStr = errStr;
	
				_serverController.send(msg);
				var viewEvent:ViewEvent              = new ViewEvent(ViewEvent.SHOW_VIEW);
				var nClientCrashView:ClientCrashView = ClientCrashView(_viewFactory.createView(ClientCrashView));
				nClientCrashView.errorMsg = errStr;
				viewEvent.targetView = nClientCrashView;
				_eventDispatcher.dispatchEvent(viewEvent);
			}
		}

		public function disconnect():void  { _firstTimeInit = true; }

		/**
		 *
		 * @param serverController
		 */
		public function give( serverController:ServerController ):void
		{
			_serverController = serverController;
			_transactionController.serverController = _serverController;
			_fteController.serverController = _serverController;
			_tickProvider.addFrameListener(onTick);
		}

		public function set inFTE( v:Boolean ):void  { _inFTE = v; }

		[Inject]
		public function set assetModel( v:AssetModel ):void  { _assetModel = v; }
		[Inject]
		public function set attackFactory( v:IAttackFactory ):void  { _attackFactory = v; }
		[Inject]
		public function set battleModel( v:BattleModel ):void  { _battleModel = v; }
		[Inject]
		public function set eventDispatcher( value:IEventDispatcher ):void  { _eventDispatcher = value; }
		[Inject]
		public function set fleetModel( value:FleetModel ):void  { _fleetModel = value; }
		[Inject]
		public function set fteController( v:FTEController ):void  { _fteController = v; }
		[Inject]
		public function set missionModel( value:MissionModel ):void  { _missionModel = value; }
		[Inject]
		public function set mailModel( v:MailModel ):void  { _mailModel = v; }
		[Inject]
		public function set blueprintModel( value:BlueprintModel ):void  { _blueprintModel = value; }
		[Inject]
		public function set playerModel( value:PlayerModel ):void  { _playerModel = value; }
		public function get presenter():IGamePresenter  { return _presenter; }
		public function set presenter( v:IGamePresenter ):void  { _presenter = v; }
		[Inject]
		public function set prototypeModel( v:PrototypeModel ):void  { _prototypeModel = v; }
		[Inject]
		public function set sectorFactory( v:ISectorFactory ):void  { _sectorFactory = v; }
		[Inject]
		public function set sectorModel( v:SectorModel ):void  { _sectorModel = v; }
		[Inject]
		public function set shipFactory( v:IShipFactory ):void  { _shipFactory = v; }
		[Inject]
		public function set soundController( v:SoundController ):void  { _soundController = v; }
		[Inject]
		public function set starbaseFactory( v:IStarbaseFactory ):void  { _starbaseFactory = v; }
		[Inject]
		public function set starbaseModel( v:StarbaseModel ):void  { _starbaseModel = v; }
		[Inject]
		public function set battleLogModel( v:BattleLogModel ):void  { _battleLogModel = v; }
		[Inject]
		public function set transactionController( v:TransactionController ):void  { _transactionController = v; }
		[Inject]
		public function set settingsController( v:SettingsController ):void  { _settingsController = v; }
		[Inject]
		public function set chatController( v:ChatController ):void  { _chatController = v; }
		[Inject]
		public function set eventController( v:EventController ):void  { _eventController = v; }
		[Inject]
		public function set vfxFactory( v:IVFXFactory ):void  { _vfxFactory = v; }
		[Inject]
		public function set viewFactory( v:IViewFactory ):void  { _viewFactory = v; }
		[Inject]
		public function set viewStack( v:IViewStack ):void  { _viewStack = v; }
		[Inject]
		public function set warfrontModel( v:WarfrontModel ):void  { _warfrontModel = v; }
		[Inject]
		public function set leaderboardModel( v:LeaderboardModel ):void  { _leaderboardModel = v; }
		[Inject]
		public function set allianceModel( v:AllianceModel ):void  { _allianceModel = v; }
		[Inject]
		public function set motdModel( v:MotDModel ):void  { _motdModel = v; }
		[Inject]
		public function set motdDailyModel( v:MotDDailyRewardModel ):void  { _motdDailyModel = v; }
		[Inject]
		public function set achievementModel( v:AchievementModel ):void  { _achievementModel = v; }
	}
}
