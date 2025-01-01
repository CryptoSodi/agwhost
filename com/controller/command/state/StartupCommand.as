package com.controller.command.state
{
	import com.controller.command.BattleAlertCommand;
	import com.controller.command.FTECommand;
	import com.controller.command.MissionCommand;
	import com.controller.command.PaywallCommand;
	import com.controller.command.StarbaseCommand;
	import com.controller.command.ToastCommand;
	import com.controller.command.TransitionCommand;
	import com.controller.command.WelcomeBackCommand;
	import com.event.BattleEvent;
	import com.event.FTEEvent;
	import com.event.MissionEvent;
	import com.event.PaywallEvent;
	import com.event.ServerEvent;
	import com.event.StarbaseEvent;
	import com.event.StateEvent;
	import com.event.ToastEvent;
	import com.event.TransitionEvent;
	import com.game.entity.factory.IVCFactory;
	import com.game.entity.factory.VCFactory;
	import com.ui.core.ViewFactory;
	import com.ui.core.ViewStack;
	import com.ui.core.component.tooltips.Tooltips;

	import flash.display.DisplayObjectContainer;

	import org.parade.core.IViewFactory;
	import org.parade.core.IViewStack;

	public class StartupCommand extends StateCommand
	{
		[Inject]
		public var contextView:DisplayObjectContainer;

		override public function execute():void
		{
			mapModel();
			mapController();
			mapCommands();
			mapView();
			startPreloader();
		}

		private function mapModel():void
		{
			injector.map(IVCFactory).toSingleton(VCFactory);
		}

		private function mapView():void
		{
			injector.map(IViewFactory).toSingleton(ViewFactory);
			injector.map(Tooltips).asSingleton();

			//create the ViewStack and initialize it
			var viewStack:IViewStack = new ViewStack();
			injector.injectInto(viewStack);
			injector.map(IViewStack).toValue(viewStack);
		}

		private function mapController():void
		{

		}

		private function mapCommands():void
		{
			commandMap.map(StateEvent.CREATE_CHARACTER, null).toCommand(CreateCharacterCommand);
			commandMap.map(StateEvent.PRELOAD, StateEvent, true).toCommand(PreloadCommand);
			commandMap.map(StateEvent.PRELOAD_COMPLETE, StateEvent, true).toCommand(PreloadCommand);
			commandMap.map(StateEvent.GAME_STARBASE_CLEANUP, StateEvent).toCommand(GameCommand);
			commandMap.map(StateEvent.GAME_BATTLE_CLEANUP, StateEvent).toCommand(GameCommand);
			commandMap.map(StateEvent.GAME_SECTOR_CLEANUP, StateEvent).toCommand(GameCommand);
			commandMap.map(StateEvent.GAME_STARBASE, StateEvent).toCommand(GameCommand);
			commandMap.map(StateEvent.GAME_BATTLE, StateEvent).toCommand(GameCommand);
			commandMap.map(StateEvent.GAME_SECTOR, StateEvent).toCommand(GameCommand);
			commandMap.map(StateEvent.SHUTDOWN_FINISH, StateEvent).toCommand(ShutdownCommand);

			commandMap.map(FTEEvent.FTE_COMPLETE, FTEEvent).toCommand(FTECommand);
			commandMap.map(FTEEvent.FTE_STEP, FTEEvent).toCommand(FTECommand);
			commandMap.map(ToastEvent.SHOW_TOAST, ToastEvent).toCommand(ToastCommand);
			commandMap.map(TransitionEvent.TRANSITION_BEGIN, TransitionEvent).toCommand(TransitionCommand);
			commandMap.map(TransitionEvent.TRANSITION_FAILED, TransitionEvent).toCommand(TransitionCommand);
			commandMap.map(TransitionEvent.TRANSITION_COMPLETE, TransitionEvent).toCommand(TransitionCommand);

			commandMap.map(BattleEvent.BATTLE_COUNTDOWN, BattleEvent).toCommand(BattleAlertCommand);
			commandMap.map(BattleEvent.BATTLE_STARTED, BattleEvent).toCommand(BattleAlertCommand);
			commandMap.map(BattleEvent.BATTLE_ENDED, BattleEvent).toCommand(BattleAlertCommand);
			commandMap.map(BattleEvent.BATTLE_REPLAY, BattleEvent).toCommand(BattleCoreCommand);
			
			commandMap.map(StarbaseEvent.ALERT_FLEET_BATTLE, StarbaseEvent).toCommand(StarbaseCommand);
			commandMap.map(StarbaseEvent.ALERT_STARBASE_BATTLE, StarbaseEvent).toCommand(StarbaseCommand);
			commandMap.map(StarbaseEvent.ALERT_INSTANCED_MISSION_BATTLE, StarbaseEvent).toCommand(StarbaseCommand);
			
			commandMap.map(StarbaseEvent.WELCOME_BACK, StarbaseEvent).toCommand(WelcomeBackCommand);

			commandMap.map(MissionEvent.MISSION_FAILED, MissionEvent).toCommand(MissionCommand);
			commandMap.map(MissionEvent.MISSION_GREETING, MissionEvent).toCommand(MissionCommand);
			commandMap.map(MissionEvent.MISSION_SITUATIONAL, MissionEvent).toCommand(MissionCommand);
			commandMap.map(MissionEvent.MISSION_VICTORY, MissionEvent).toCommand(MissionCommand);
			commandMap.map(MissionEvent.SHOW_REWARDS, MissionEvent).toCommand(MissionCommand);

			commandMap.map(PaywallEvent.OPEN_PAYWALL, PaywallEvent).toCommand(PaywallCommand);
		}

		private function startPreloader():void
		{
			var connectionEvent:ServerEvent = new ServerEvent(ServerEvent.CONNECT_TO_PROXY);
			dispatch(connectionEvent);

			var preloaderEvent:StateEvent   = new StateEvent(StateEvent.PRELOAD);
			dispatch(preloaderEvent);
		}

	}
}


