package com.controller.command.state
{
	import com.Application;
	import com.controller.GameController;
	import com.controller.ServerController;
	import com.controller.fte.FTEController;
	import com.controller.sound.SoundController;
	import com.enum.AudioEnum;
	import com.enum.FactionEnum;
	import com.enum.PriorityEnum;
	import com.enum.server.ProtocolEnum;
	import com.enum.server.RequestEnum;
	import com.event.StateEvent;
	import com.game.entity.systems.battle.ActiveDefenseSystem;
	import com.game.entity.systems.battle.AreaSystem;
	import com.game.entity.systems.battle.BeamSystem;
	import com.game.entity.systems.battle.DebugLineSystem;
	import com.game.entity.systems.battle.DroneSystem;
	import com.game.entity.systems.battle.ShipSystem;
	import com.game.entity.systems.battle.VitalsSystem;
	import com.game.entity.systems.interact.BattleInteractSystem;
	import com.game.entity.systems.interact.SectorInteractSystem;
	import com.game.entity.systems.interact.StarbaseInteractSystem;
	import com.game.entity.systems.sector.FleetSystem;
	import com.game.entity.systems.shared.AnimationSystem;
	import com.game.entity.systems.shared.FSMSystem;
	import com.game.entity.systems.shared.MoveSystem;
	import com.game.entity.systems.shared.TweenSystem;
	import com.game.entity.systems.shared.background.BackgroundSystem;
	import com.game.entity.systems.shared.grid.GridSystem;
	import com.game.entity.systems.starbase.StarbaseSystem;
	import com.model.asset.AssetModel;
	import com.model.asset.ISpritePack;
	import com.model.battle.BattleModel;
	import com.model.player.CurrentUser;
	import com.model.player.PlayerModel;
	import com.model.scene.SceneModel;
	import com.model.sector.SectorModel;
	import com.model.starbase.StarbaseModel;
	import com.presenter.battle.IBattlePresenter;
	import com.presenter.sector.ISectorPresenter;
	import com.presenter.shared.IGamePresenter;
	import com.presenter.starbase.IStarbasePresenter;
	import com.service.loading.ILoadService;
	import com.service.server.incoming.data.BattleData;
	import com.service.server.outgoing.proxy.ProxyConnectToBattleRequest;
	import com.service.server.outgoing.proxy.ProxyConnectToSectorRequest;
	
	import flash.system.System;
	import flash.utils.Dictionary;
	
	import org.ash.core.Game;
	import org.ash.core.System;
	import org.shared.ObjectPool;

	public class GameCoreCommand extends StateCommand
	{
		private static var oldFaction:String;
		private static var oldState:String;

		[Inject]
		public var assetModel:AssetModel;
		[Inject]
		public var battleModel:BattleModel;
		[Inject]
		public var fteController:FTEController;
		[Inject]
		public var game:Game;
		[Inject]
		public var gameController:GameController;
		[Inject]
		public var loadService:ILoadService;
		[Inject]
		public var playerModel:PlayerModel;
		[Inject]
		public var sceneModel:SceneModel;
		[Inject]
		public var sectorModel:SectorModel;
		[Inject]
		public var serverController:ServerController;
		[Inject]
		public var soundController:SoundController;
		[Inject]
		public var starbaseModel:StarbaseModel;

		public var presenter:IGamePresenter;

		override public function execute():void
		{
			Application.STATE = event.type;
			switch (event.type)
			{
				case StateEvent.GAME_BATTLE_INIT:
					initBattle();
					game.addSystem(ObjectPool.get(BattleInteractSystem), PriorityEnum.UPDATE);
					serverController.protocolListener = ProtocolEnum.BATTLE_CLIENT;
					if( !battleModel.isReplay )
					{
						//connect to the battle
						var request:ProxyConnectToBattleRequest = ProxyConnectToBattleRequest(serverController.getRequest(ProtocolEnum.PROXY_CLIENT, RequestEnum.PROXY_CONNECT_TO_BATTLE));
						request.key = battleModel.battleServerAddress;
						serverController.send(request);
					}
					else
					{
						serverController.requestReplay( battleModel.battleServerAddress );
					}
					break;
				case StateEvent.GAME_BATTLE:
					clearSpritePacks();
					getPresenter();
					presenter.loadBackground(battleModel, true);
					gameController.presenter = presenter;
					//play the battle music
					if (!fteController.running)
						soundController.playSound(AudioEnum.AFX_BG_BATTLE_MUSIC, 0.2, 0, 100);
					BattleInteractSystem(game.getSystem(BattleInteractSystem)).init();
					game.addSystem(ObjectPool.get(BattleInteractSystem), PriorityEnum.UPDATE);
					break;
				case StateEvent.GAME_STARBASE:
					//set the current sector to that of the base so the player goes there when exiting the starbase
					sectorModel.updateSector(starbaseModel.currentBase.sector);
					sectorModel.focusFleetID = null;
					clearSpritePacks();
					initStarbase();
					game.addSystem(ObjectPool.get(StarbaseInteractSystem), PriorityEnum.UPDATE);
					getPresenter();
					presenter.loadBackground(battleModel);
					serverController.protocolListener = ProtocolEnum.STARBASE_CLIENT;
					gameController.presenter = presenter;
					if (!fteController.running)
					{
						switch (CurrentUser.faction)
						{
							case FactionEnum.IGA:
								soundController.playSound(AudioEnum.AFX_BG_IGA_THEME, 0.17, 0, 100);
								break;
							case FactionEnum.SOVEREIGNTY:
								soundController.playSound(AudioEnum.AFX_BG_SOVEREIGNTY_THEME, 0.18, 0, 100);
								break;
							case FactionEnum.TYRANNAR:
								soundController.playSound(AudioEnum.AFX_BG_TYRANNAR_THEME, 0.14, 0, 100);
								break;
						}
					}
					break;
				case StateEvent.GAME_SECTOR_INIT:
					initSector();
					game.addSystem(ObjectPool.get(SectorInteractSystem), PriorityEnum.UPDATE);
					serverController.protocolListener = ProtocolEnum.SECTOR_CLIENT;
					gameController.sectorRequestBaseline();
					break;
				case StateEvent.GAME_SECTOR:
					clearSpritePacks();
					getPresenter();
					gameController.presenter = presenter;
					//					soundController.playSound(AudioEnum.AFX_BG_MAIN_THEME, 0.07, 0, 100);
					presenter.loadBackground(battleModel);
					if (!fteController.running)
					{
						switch (sectorModel.sectorFaction)
						{
							case FactionEnum.IGA:
								//If the player is in their own faction space use the main them; otherwise, use the faction theme
								if (CurrentUser.faction == sectorModel.sectorFaction)
									soundController.playSound(AudioEnum.AFX_BG_MAIN_THEME, 0.07, 0, 100);
								else
									soundController.playSound(AudioEnum.AFX_BG_IGA_THEME, 0.17, 0, 100);
								//Ambient Space Sounds
								soundController.playSound(AudioEnum.AFX_STG_AMBIENT_IGA_SPACE_SOUNDS, 1, 0, 100);
								break;
							case FactionEnum.SOVEREIGNTY:
								//If the player is in their own faction space use the main them; otherwise, use the faction theme
								if (CurrentUser.faction == sectorModel.sectorFaction)
									soundController.playSound(AudioEnum.AFX_BG_MAIN_THEME, 0.07, 0, 100);
								else
									soundController.playSound(AudioEnum.AFX_BG_SOVEREIGNTY_THEME, 0.18, 0, 100);
								//Ambient Space Sounds
								soundController.playSound(AudioEnum.AFX_STG_AMBIENT_SOVEREIGNTY_SPACE_SOUNDS, 1, 0, 100);
								break;
							case FactionEnum.TYRANNAR:
								//If the player is in their own faction space use the main them; otherwise, use the faction theme
								if (CurrentUser.faction == sectorModel.sectorFaction)
									soundController.playSound(AudioEnum.AFX_BG_MAIN_THEME, 0.07, 0, 100);
								else
									soundController.playSound(AudioEnum.AFX_BG_TYRANNAR_THEME, 0.14, 0, 100);
								//Ambient Space Sounds
								soundController.playSound(AudioEnum.AFX_STG_AMBIENT_TYRANNAR_SPACE_SOUNDS, 1, 0, 100);
								break;
						}
					}
					break;
				case StateEvent.GAME_BATTLE_CLEANUP:
					{
						battleModel.cleanup();
						BattleData.globalInstance.destroy();
						getPresenter();
						cleanup();
						serverController.cleanupBattle();
					}
					break;
				case StateEvent.GAME_SECTOR_CLEANUP:
					if (event.nextState != StateEvent.GAME_SECTOR)
					{
						var sectorDisconnect:ProxyConnectToSectorRequest = ProxyConnectToSectorRequest(serverController.getRequest(ProtocolEnum.PROXY_CLIENT, RequestEnum.PROXY_CONNECT_TO_SECTOR));
						serverController.send(sectorDisconnect);
					}

					switch (sectorModel.sectorFaction)
					{
						case FactionEnum.IGA:
							soundController.stopSound(AudioEnum.AFX_STG_AMBIENT_IGA_SPACE_SOUNDS);
							break;
						case FactionEnum.SOVEREIGNTY:
							soundController.stopSound(AudioEnum.AFX_STG_AMBIENT_SOVEREIGNTY_SPACE_SOUNDS);
							break;
						case FactionEnum.TYRANNAR:
							soundController.stopSound(AudioEnum.AFX_STG_AMBIENT_TYRANNAR_SPACE_SOUNDS);
							break;
					}
					getPresenter();
					cleanup();
					break;
				case StateEvent.DEFAULT_CLEANUP:
				case StateEvent.GAME_STARBASE_CLEANUP:
					getPresenter();
					cleanup();
					break;
			}
			presenter = null;
		}

		private function initBattle():void
		{
			game.addSystem(ObjectPool.get(AnimationSystem), PriorityEnum.RENDER);
			game.addSystem(ObjectPool.get(ActiveDefenseSystem), PriorityEnum.RENDER);
			game.addSystem(ObjectPool.get(AreaSystem), PriorityEnum.RESOLVE_COLLISIONS);
			game.addSystem(ObjectPool.get(BackgroundSystem), PriorityEnum.MOVE);
			game.addSystem(ObjectPool.get(BeamSystem), PriorityEnum.RESOLVE_COLLISIONS);
			game.addSystem(ObjectPool.get(DroneSystem), PriorityEnum.RESOLVE_COLLISIONS);
			game.addSystem(ObjectPool.get(FSMSystem), PriorityEnum.RESOLVE_COLLISIONS);
			game.addSystem(ObjectPool.get(GridSystem), PriorityEnum.RESOLVE_COLLISIONS);
			game.addSystem(ObjectPool.get(MoveSystem), PriorityEnum.MOVE);
			game.addSystem(ObjectPool.get(ShipSystem), PriorityEnum.RESOLVE_COLLISIONS);
			game.addSystem(ObjectPool.get(StarbaseSystem), PriorityEnum.RESOLVE_COLLISIONS);
			game.addSystem(ObjectPool.get(TweenSystem), PriorityEnum.RESOLVE_COLLISIONS);
			if (CONFIG::DEBUG == true)
				game.addSystem(ObjectPool.get(DebugLineSystem), PriorityEnum.RESOLVE_COLLISIONS);
			game.addSystem(ObjectPool.get(VitalsSystem), PriorityEnum.RENDER);
		}

		private function initStarbase():void
		{
			game.addSystem(ObjectPool.get(AnimationSystem), PriorityEnum.RENDER);
			game.addSystem(ObjectPool.get(BackgroundSystem), PriorityEnum.MOVE);
			game.addSystem(ObjectPool.get(MoveSystem), PriorityEnum.MOVE);
			game.addSystem(ObjectPool.get(FSMSystem), PriorityEnum.RESOLVE_COLLISIONS);
			game.addSystem(ObjectPool.get(GridSystem), PriorityEnum.RESOLVE_COLLISIONS);
			game.addSystem(ObjectPool.get(StarbaseSystem), PriorityEnum.UPDATE);
			game.addSystem(ObjectPool.get(TweenSystem), PriorityEnum.RESOLVE_COLLISIONS);
		}

		private function initSector():void
		{
			game.addSystem(ObjectPool.get(AnimationSystem), PriorityEnum.RENDER);
			game.addSystem(ObjectPool.get(BackgroundSystem), PriorityEnum.MOVE);
			game.addSystem(ObjectPool.get(MoveSystem), PriorityEnum.MOVE);
			game.addSystem(ObjectPool.get(FleetSystem), PriorityEnum.RESOLVE_COLLISIONS);
			game.addSystem(ObjectPool.get(GridSystem), PriorityEnum.RESOLVE_COLLISIONS);
			game.addSystem(ObjectPool.get(TweenSystem), PriorityEnum.RESOLVE_COLLISIONS);
		}

		private function cleanup():void
		{
			ObjectPool.gc();

			//remove the entities
			game.removeAllEntities();
			//pool the systems
			var systems:Vector.<org.ash.core.System> = game.removeAllSystems();
			for (var i:int = 0; i < systems.length; i++)
				ObjectPool.give(systems[i]);
			//stop any spritepacks that may be building
			assetModel.stopAllSpritePackBuilds();

			playerModel.removeAllPlayers();
			if (presenter)
				presenter.cleanup();
		}

		private function clearSpritePacks():void
		{
			if (oldState != null)
			{
				var factionsDiffer:Boolean = oldFaction != sectorModel.sectorFaction;
				var spritePacks:Dictionary = assetModel.spritePacks;
				var mask:int               = stateMask;
				var memoryUsage:Number     = flash.system.System.totalMemory * 0.000000954;
				//clear out old spritepacks
				for each (var spritePack:ISpritePack in spritePacks)
				{
					if ((spritePack.usedBy != 8 && (spritePack.usedBy & mask) == 0) || (spritePack.usedBy == 8 && factionsDiffer))
					{
						assetModel.removeSpritePack(spritePack);
					}
				}
			}
			oldFaction = sectorModel.sectorFaction;
			oldState = Application.STATE;
		}

		private function getPresenter():void
		{
			switch (event.type)
			{
				case StateEvent.GAME_STARBASE_CLEANUP:
					presenter = gameController.presenter;
					if (presenter && !(presenter is IStarbasePresenter))
						presenter = null;
					break;
				case StateEvent.GAME_STARBASE:
					presenter = injector.getInstance(IStarbasePresenter);
					break;
				case StateEvent.GAME_BATTLE_CLEANUP:
					presenter = gameController.presenter;
					if (presenter && !(presenter is IBattlePresenter))
						presenter = null;
					break;
				case StateEvent.GAME_BATTLE:
					presenter = injector.getInstance(IBattlePresenter);
					break;
				case StateEvent.GAME_SECTOR_CLEANUP:
					presenter = gameController.presenter;
					if (presenter && !(presenter is ISectorPresenter))
						presenter = null;
					break;
				case StateEvent.GAME_SECTOR:
					presenter = injector.getInstance(ISectorPresenter);
					break;
			}
		}

		private function get stateMask():int
		{
			if (event.type == StateEvent.GAME_BATTLE)
				return 1;
			else if (event.type == StateEvent.GAME_SECTOR)
				return 2;
			return 4;
		}
	}
}


