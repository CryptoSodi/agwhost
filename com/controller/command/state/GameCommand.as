package com.controller.command.state
{
	import com.controller.fte.FTEController;
	import com.controller.transaction.TransactionController;
	import com.enum.PriorityEnum;
	import com.event.MissionEvent;
	import com.event.StateEvent;
	import com.game.entity.systems.battle.TrailFXSystem;
	import com.game.entity.systems.shared.VCSystem;
	import com.game.entity.systems.shared.render.RenderSystem;
	import com.game.entity.systems.starbase.StateSystem;
	import com.model.battle.BattleModel;
	import com.model.mission.MissionModel;
	import com.model.motd.MotDModel;
	import com.model.player.CurrentUser;
	import com.model.starbase.StarbaseModel;
	import com.ui.hud.battle.BattleShipSelectionView;
	import com.ui.hud.battle.BattleUserView;
	import com.ui.hud.battle.BattleView;
	import com.ui.hud.sector.SectorView;
	import com.ui.hud.shared.ChatView;
	import com.ui.hud.shared.IconDrawerView;
	import com.ui.hud.shared.MiniMapView;
	import com.ui.hud.shared.PlayerView;
	import com.ui.hud.shared.bridge.BridgeView;
	import com.ui.hud.shared.command.CommandView;
	import com.ui.hud.shared.engineering.EngineeringView;
	import com.ui.hud.starbase.StarbaseView;

	import org.ash.core.Game;
	import org.parade.core.IView;
	import org.parade.core.IViewFactory;
	import org.parade.core.IViewStack;
	import org.parade.core.ViewController;
	import org.parade.core.ViewEvent;
	import org.parade.enum.ViewEnum;
	import org.shared.ObjectPool;

	public class GameCommand extends StateCommand
	{
		[Inject]
		public var battleModel:BattleModel;
		[Inject]
		public var fteController:FTEController;
		[Inject]
		public var game:Game;
		[Inject]
		public var missionModel:MissionModel;
		[Inject]
		public var motdModel:MotDModel;
		[Inject]
		public var starbaseModel:StarbaseModel;
		[Inject]
		public var transactionController:TransactionController;
		[Inject]
		public var viewController:ViewController;
		[Inject]
		public var viewFactory:IViewFactory;
		[Inject]
		public var viewStack:IViewStack;

		override public function execute():void
		{
			var missionEvent:MissionEvent;
			switch (event.type)
			{
				case StateEvent.GAME_BATTLE:
					initBattle();
					dispatchViewEvent(BattleUserView);
					dispatchViewEvent(MiniMapView, true);
					dispatchViewEvent(BattleView);
					if (!battleModel.isInstancedMission && battleModel.participants.indexOf(CurrentUser.id) > -1 && (!battleModel.isBaseCombat || battleModel.baseOwnerID != CurrentUser.id))
						dispatchViewEvent(BattleShipSelectionView);
					dispatchViewEvent(ChatView, true);
					//is this battle part of a mission? if so show the dialogue
					if (!missionModel.currentMission.isFTE && battleModel.missionID == missionModel.currentMission.id)
					{
						missionEvent = new MissionEvent(MissionEvent.MISSION_SITUATIONAL);
						dispatch(missionEvent);
					}
					break;
				case StateEvent.GAME_STARBASE:
					dispatchViewEvent(PlayerView, true);
					dispatchViewEvent(StarbaseView);
					dispatchViewEvent(MiniMapView, true);
					dispatchViewEvent(BridgeView, true);
					dispatchViewEvent(EngineeringView, true);
					dispatchViewEvent(ChatView, true);
					dispatchViewEvent(CommandView, true);
					dispatchViewEvent(IconDrawerView, true);
					initStarbase();
					break;
				case StateEvent.GAME_SECTOR:
					dispatchViewEvent(PlayerView, true);
					dispatchViewEvent(MiniMapView, true);
					dispatchViewEvent(EngineeringView, true);
					dispatchViewEvent(SectorView);
					dispatchViewEvent(BridgeView, true);
					dispatchViewEvent(ChatView, true);
					dispatchViewEvent(CommandView, true);
					dispatchViewEvent(IconDrawerView, true);
					initSector();
					break;
				case StateEvent.GAME_BATTLE_CLEANUP:
					if (!missionModel.currentMission.isFTE && battleModel.missionID == missionModel.currentMission.id && !battleModel.wonLastBattle)
					{
						missionEvent = new MissionEvent(MissionEvent.MISSION_FAILED);
						dispatch(missionEvent);
					} else if (!missionModel.currentMission.isFTE && missionModel.currentMission.complete && !missionModel.currentMission.rewardAccepted)
					{
						missionModel.missionComplete();
						transactionController.dataImported();
					}
				case StateEvent.GAME_SECTOR_CLEANUP:
				case StateEvent.GAME_STARBASE_CLEANUP:
					viewStack.clearLayer(ViewEnum.BACKGROUND_LAYER);
					viewStack.clearLayer(ViewEnum.GAME_LAYER);
					break;
			}
		}

		private function initBattle():void
		{
			game.addSystem(ObjectPool.get(RenderSystem), PriorityEnum.RENDER);
			game.addSystem(ObjectPool.get(VCSystem), PriorityEnum.RENDER);
			game.addSystem(ObjectPool.get(TrailFXSystem), PriorityEnum.RENDER);
		}

		private function initStarbase():void
		{
			game.addSystem(ObjectPool.get(RenderSystem), PriorityEnum.RENDER);
			game.addSystem(ObjectPool.get(VCSystem), PriorityEnum.RENDER);
			game.addSystem(ObjectPool.get(StateSystem), PriorityEnum.RESOLVE_COLLISIONS);
		}

		private function initSector():void
		{
			game.addSystem(ObjectPool.get(RenderSystem), PriorityEnum.RENDER);
			game.addSystem(ObjectPool.get(VCSystem), PriorityEnum.RENDER);
		}

		private function dispatchViewEvent( viewClass:Class, checkIfViewExists:Boolean = false ):void
		{
			if (checkIfViewExists)
			{
				var view:IView = viewController.getView(viewClass);
				if (view != null)
				{
					//readd the view to maintain correct depth sorting
					viewStack.addView(view);
					return;
				}
			}
			var viewEvent:ViewEvent = new ViewEvent(ViewEvent.SHOW_VIEW);
			viewEvent.targetClass = viewClass;
			dispatch(viewEvent);
		}
	}
}


