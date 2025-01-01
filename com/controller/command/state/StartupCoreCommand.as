package com.controller.command.state
{
	import com.controller.ChatController;
	import com.controller.EventController;
	import com.controller.GameController;
	import com.controller.ServerController;
	import com.controller.SettingsController;
	import com.controller.command.ContextLostCommand;
	import com.controller.command.PaywallCommand;
	import com.controller.command.GuestCommand;
	import com.controller.command.TransitionCoreCommand;
	import com.controller.command.account.ConnectionCommand;
	import com.controller.command.account.PaymentCommand;
	import com.controller.command.load.LoadCompleteCommand;
	import com.controller.command.load.RequestLoadCommand;
	import com.controller.fte.FTEController;
	import com.controller.keyboard.KeyboardController;
	import com.controller.sound.SoundController;
	import com.controller.toast.ToastController;
	import com.controller.transaction.TransactionController;
	import com.controller.transaction.requirements.IRequirementFactory;
	import com.controller.transaction.requirements.RequirementFactory;
	import com.event.BattleEvent;
	import com.event.LoadEvent;
	import com.event.PaywallEvent;
	import com.event.RequestLoadEvent;
	import com.event.SectorEvent;
	import com.event.ServerEvent;
	import com.event.StarbaseEvent;
	import com.event.StateEvent;
	import com.event.TransitionEvent;
	import com.event.signal.InteractSignal;
	import com.event.signal.QuadrantSignal;
	import com.game.entity.factory.AttackFactory;
	import com.game.entity.factory.BackgroundFactory;
	import com.game.entity.factory.IAttackFactory;
	import com.game.entity.factory.IBackgroundFactory;
	import com.game.entity.factory.IInteractFactory;
	import com.game.entity.factory.ISectorFactory;
	import com.game.entity.factory.IShipFactory;
	import com.game.entity.factory.IStarbaseFactory;
	import com.game.entity.factory.IVFXFactory;
	import com.game.entity.factory.InteractFactory;
	import com.game.entity.factory.SectorFactory;
	import com.game.entity.factory.ShipFactory;
	import com.game.entity.factory.StarbaseFactory;
	import com.game.entity.factory.VFXFactory;
	import com.model.achievements.AchievementModel;
	import com.model.alliance.AllianceModel;
	import com.model.asset.AssetModel;
	import com.model.battle.BattleModel;
	import com.model.battlelog.BattleLogModel;
	import com.model.blueprint.BlueprintModel;
	import com.model.chat.ChatModel;
	import com.model.event.EventModel;
	import com.model.fleet.FleetModel;
	import com.model.leaderboards.LeaderboardModel;
	import com.model.mail.MailModel;
	import com.model.mission.MissionModel;
	import com.model.motd.MotDDailyRewardModel;
	import com.model.motd.MotDModel;
	import com.model.player.PlayerModel;
	import com.model.prototype.PrototypeModel;
	import com.model.scene.SceneModel;
	import com.model.sector.SectorModel;
	import com.model.starbase.StarbaseModel;
	import com.model.transaction.TransactionModel;
	import com.model.warfrontModel.WarfrontModel;
	import com.presenter.battle.BattlePresenter;
	import com.presenter.battle.IBattlePresenter;
	import com.presenter.battle.IWarfrontPresenter;
	import com.presenter.battle.WarfrontPresenter;
	import com.presenter.preload.IPreloadPresenter;
	import com.presenter.preload.PreloadPresenter;
	import com.presenter.sector.IMiniMapPresenter;
	import com.presenter.sector.ISectorPresenter;
	import com.presenter.sector.MiniMapPresenter;
	import com.presenter.sector.SectorPresenter;
	import com.presenter.shared.AchievementPresenter;
	import com.presenter.shared.AlliancePresenter;
	import com.presenter.shared.BookmarkPresenter;
	import com.presenter.shared.ChatPresenter;
	import com.presenter.shared.CommandPresenter;
	import com.presenter.shared.EngineeringPresenter;
	import com.presenter.shared.EventPresenter;
	import com.presenter.shared.GameOfChancePresenter;
	import com.presenter.shared.IAchievementPresenter;
	import com.presenter.shared.IAlliancePresenter;
	import com.presenter.shared.IBookmarkPresenter;
	import com.presenter.shared.IChatPresenter;
	import com.presenter.shared.ICommandPresenter;
	import com.presenter.shared.IEngineeringPresenter;
	import com.presenter.shared.IEventPresenter;
	import com.presenter.shared.IGameOfChancePresenter;
	import com.presenter.shared.ILeaderboardPresenter;
	import com.presenter.shared.IPlayerProfilePresenter;
	import com.presenter.shared.ITransitionPresenter;
	import com.presenter.shared.IUIPresenter;
	import com.presenter.shared.LeaderboardPresenter;
	import com.presenter.shared.PlayerProfilePresenter;
	import com.presenter.shared.TransitionPresenter;
	import com.presenter.shared.UIPresenter;
	import com.presenter.starbase.AttackAlertPresenter;
	import com.presenter.starbase.ConstructionPresenter;
	import com.presenter.starbase.FleetPresenter;
	import com.presenter.starbase.IAttackAlertPresenter;
	import com.presenter.starbase.IConstructionPresenter;
	import com.presenter.starbase.IFleetPresenter;
	import com.presenter.starbase.IMissionPresenter;
	import com.presenter.starbase.IShipyardPresenter;
	import com.presenter.starbase.IStarbasePresenter;
	import com.presenter.starbase.IStorePresenter;
	import com.presenter.starbase.ITradePresenter;
	import com.presenter.starbase.MissionPresenter;
	import com.presenter.starbase.ShipyardPresenter;
	import com.presenter.starbase.StarbasePresenter;
	import com.presenter.starbase.StorePresenter;
	import com.presenter.starbase.TradePresenter;
	import com.service.ExternalInterfaceAPI;
	import com.service.kongregate.KongregateAPI;
	import com.service.facebook.FacebookAPI;
	import com.service.language.Localization;
	import com.service.loading.ILoadService;
	import com.service.loading.LoadService;
	import com.util.AllegianceUtil;
	import com.util.BattleUtils;
	import com.util.CommonFunctionUtil;
	import com.util.RangeBuilder;
	import com.util.RouteLineBuilder;
	import com.util.statcalc.StatCalcUtil;

	import org.as3commons.logging.api.LOGGER_FACTORY;
	import org.as3commons.logging.setup.SimpleTargetSetup;
	import org.as3commons.logging.setup.target.FlashConsoleTarget;

	public class StartupCoreCommand extends StateCommand
	{
		override public function execute():void
		{
			//setup the logging and set it to show its' output in the console (Cc)
			LOGGER_FACTORY.setup = new SimpleTargetSetup(new FlashConsoleTarget());

			mapCommands();
			mapControllers();
			mapModels();
			mapPresenters();
			mapService();
			mapSignals();
		}

		private function mapCommands():void
		{
			//state events
			commandMap.map(StateEvent.GAME_STARBASE_CLEANUP, StateEvent).toCommand(GameCoreCommand);
			commandMap.map(StateEvent.GAME_BATTLE_CLEANUP, StateEvent).toCommand(GameCoreCommand);
			commandMap.map(StateEvent.GAME_SECTOR_CLEANUP, StateEvent).toCommand(GameCoreCommand);
			commandMap.map(StateEvent.DEFAULT_CLEANUP, StateEvent).toCommand(GameCoreCommand);
			commandMap.map(StateEvent.GAME_BATTLE_INIT, StateEvent).toCommand(GameCoreCommand);
			commandMap.map(StateEvent.GAME_SECTOR_INIT, StateEvent).toCommand(GameCoreCommand);
			commandMap.map(StateEvent.GAME_STARBASE, StateEvent).toCommand(GameCoreCommand);
			commandMap.map(StateEvent.GAME_BATTLE, StateEvent).toCommand(GameCoreCommand);
			commandMap.map(StateEvent.GAME_SECTOR, StateEvent).toCommand(GameCoreCommand);
			commandMap.map(StateEvent.SHUTDOWN_START, StateEvent).toCommand(ShutdownCoreCommand);
			commandMap.map(StateEvent.SHUTDOWN_FINISH, StateEvent).toCommand(ShutdownCoreCommand);

			//this command will handle the error that occurs when starling loses the device context
			commandMap.map(StateEvent.LOST_CONTEXT, null).toCommand(ContextLostCommand);

			commandMap.map(BattleEvent.BATTLE_JOIN, BattleEvent).toCommand(BattleCoreCommand);

			commandMap.map(ServerEvent.CONNECT_TO_PROXY, ServerEvent).toCommand(ConnectionCommand);
			commandMap.map(ServerEvent.LOGIN_TO_ACCOUNT, ServerEvent).toCommand(ConnectionCommand);
			commandMap.map(ServerEvent.NEED_CHARACTER_CREATE, ServerEvent).toCommand(ConnectionCommand);
			commandMap.map(ServerEvent.AUTHORIZED, ServerEvent).toCommand(ConnectionCommand);
			commandMap.map(ServerEvent.FAILED_TO_CONNECT, ServerEvent).toCommand(ConnectionCommand);
			commandMap.map(ServerEvent.MAINTENANCE, ServerEvent).toCommand(ConnectionCommand);
			commandMap.map(ServerEvent.BANNED, ServerEvent).toCommand(ConnectionCommand);
			commandMap.map(ServerEvent.SUSPENSION, ServerEvent).toCommand(ConnectionCommand);
			commandMap.map(ServerEvent.OPEN_PAYMENT, ServerEvent).toCommand(PaymentCommand);
			commandMap.map(ServerEvent.GUEST_RESTRICTION, ServerEvent).toCommand(GuestCommand);

			commandMap.map(SectorEvent.CHANGE_SECTOR, SectorEvent).toCommand(SectorCoreCommand);
			commandMap.map(StarbaseEvent.ENTER_BASE, StarbaseEvent).toCommand(StarbaseCoreCommand);
			commandMap.map(StarbaseEvent.ENTER_INSTANCED_MISSION, StarbaseEvent).toCommand(StarbaseCoreCommand);

			commandMap.map(LoadEvent.COMPLETE, LoadEvent).toCommand(LoadCompleteCommand);
			commandMap.map(RequestLoadEvent.REQUEST, RequestLoadEvent).toCommand(RequestLoadCommand);
			commandMap.map(TransitionEvent.TRANSITION_BEGIN, TransitionEvent).toCommand(TransitionCoreCommand);
			commandMap.map(TransitionEvent.TRANSITION_FAILED, TransitionEvent).toCommand(TransitionCoreCommand);
			commandMap.map(TransitionEvent.TRANSITION_COMPLETE, TransitionEvent).toCommand(TransitionCoreCommand);


			commandMap.map(PaywallEvent.BUY_ITEM, PaywallEvent).toCommand(PaywallCommand);
			commandMap.map(PaywallEvent.GET_PAYWALL, PaywallEvent).toCommand(PaywallCommand);
			commandMap.map(PaywallEvent.OPEN_PAYWALL, PaywallEvent).toCommand(PaywallCommand);
		}

		private function mapControllers():void
		{
			injector.map(ChatController).asSingleton();
			injector.map(FTEController).asSingleton();
			injector.map(GameController).asSingleton();
			injector.map(KeyboardController).asSingleton();
			injector.map(ServerController).asSingleton();
			injector.map(ToastController).asSingleton();
			injector.map(TransactionController).asSingleton();
			injector.map(SettingsController).asSingleton();
			injector.map(SoundController).asSingleton();
			injector.map(EventController).asSingleton();
		}

		private function mapModels():void
		{
			injector.map(IAttackFactory).toSingleton(AttackFactory);
			injector.map(IBackgroundFactory).toSingleton(BackgroundFactory);
			injector.map(IInteractFactory).toSingleton(InteractFactory);
			injector.map(IRequirementFactory).toSingleton(RequirementFactory);
			injector.map(ISectorFactory).toSingleton(SectorFactory);
			injector.map(IShipFactory).toSingleton(ShipFactory);
			injector.map(IStarbaseFactory).toSingleton(StarbaseFactory);
			injector.map(IVFXFactory).toSingleton(VFXFactory);

			injector.map(AllianceModel).asSingleton();
			injector.map(AssetModel).asSingleton();
			injector.map(BattleLogModel).asSingleton();
			injector.map(BattleModel).asSingleton();
			injector.map(BlueprintModel).asSingleton();
			injector.map(ChatModel).asSingleton();
			injector.map(FleetModel).asSingleton();
			injector.map(LeaderboardModel).asSingleton();
			injector.map(MailModel).asSingleton();
			injector.map(MissionModel).asSingleton();
			injector.map(MotDDailyRewardModel).asSingleton();
			injector.map(MotDModel).asSingleton();
			injector.map(PlayerModel).asSingleton();
			injector.map(PrototypeModel).asSingleton();
			injector.map(SceneModel).asSingleton();
			injector.map(SectorModel).asSingleton();
			injector.map(StarbaseModel).asSingleton();
			injector.map(TransactionModel).asSingleton();
			injector.map(WarfrontModel).asSingleton();
			injector.map(AchievementModel).asSingleton();
			injector.map(EventModel).asSingleton();
		}

		private function mapPresenters():void
		{
			injector.map(ITransitionPresenter).toSingleton(TransitionPresenter);
			injector.map(IPreloadPresenter).toSingleton(PreloadPresenter);

			//game state presenters
			injector.map(IStarbasePresenter).toSingleton(StarbasePresenter);
			injector.map(IBattlePresenter).toSingleton(BattlePresenter);
			injector.map(ISectorPresenter).toSingleton(SectorPresenter);
			injector.map(IMiniMapPresenter).toSingleton(MiniMapPresenter);

			//ui presenters
			injector.map(IAlliancePresenter).toSingleton(AlliancePresenter);
			injector.map(IAttackAlertPresenter).toSingleton(AttackAlertPresenter);
			injector.map(IConstructionPresenter).toSingleton(ConstructionPresenter);
			injector.map(IEngineeringPresenter).toSingleton(EngineeringPresenter);
			injector.map(IFleetPresenter).toSingleton(FleetPresenter);
			injector.map(IMissionPresenter).toSingleton(MissionPresenter);
			injector.map(IPlayerProfilePresenter).toSingleton(PlayerProfilePresenter);
			injector.map(IShipyardPresenter).toSingleton(ShipyardPresenter);
			injector.map(IStorePresenter).toSingleton(StorePresenter);
			injector.map(ITradePresenter).toSingleton(TradePresenter);
			injector.map(IUIPresenter).toSingleton(UIPresenter);
			injector.map(IWarfrontPresenter).toSingleton(WarfrontPresenter);
			injector.map(ICommandPresenter).toSingleton(CommandPresenter);
			injector.map(IChatPresenter).toSingleton(ChatPresenter);
			injector.map(IBookmarkPresenter).toSingleton(BookmarkPresenter);
			injector.map(IAchievementPresenter).toSingleton(AchievementPresenter);
			injector.map(IGameOfChancePresenter).toSingleton(GameOfChancePresenter);
			injector.map(ILeaderboardPresenter).toSingleton(LeaderboardPresenter);
			injector.map(IEventPresenter).toSingleton(EventPresenter);
		}

		private function mapService():void
		{
			injector.map(AllegianceUtil).toSingleton(AllegianceUtil);
			injector.map(KongregateAPI).toSingleton(KongregateAPI);
			injector.map(FacebookAPI).toSingleton(FacebookAPI);
			injector.map(ILoadService).toSingleton(LoadService);
			injector.map(RangeBuilder).asSingleton();
			injector.map(RouteLineBuilder).asSingleton();

			injector.injectInto(new BattleUtils());
			injector.injectInto(new CommonFunctionUtil());
			injector.injectInto(new ExternalInterfaceAPI());
			injector.injectInto(new Localization());
			injector.injectInto(new StatCalcUtil());
		}

		private function mapSignals():void
		{
			var ints:InteractSignal = new InteractSignal();
			var qs:QuadrantSignal   = new QuadrantSignal();

			injector.map(InteractSignal).toValue(ints);
			injector.map(QuadrantSignal).toValue(qs);
		}
	}
}


