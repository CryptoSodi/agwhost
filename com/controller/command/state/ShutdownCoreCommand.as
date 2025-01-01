package com.controller.command.state
{
	import com.Application;
	import com.controller.GameController;
	import com.controller.ServerController;
	import com.event.StateEvent;
	import com.event.TransitionEvent;

	import org.parade.core.ViewEvent;

	public class ShutdownCoreCommand extends StateCommand
	{
		[Inject]
		public var gameController:GameController;
		[Inject]
		public var serverController:ServerController;

		override public function execute():void
		{
			if (event.type == StateEvent.SHUTDOWN_START)
				startShutdown();
			else
				finishShutdown();
		}

		private function startShutdown():void
		{
			//close the server connection
			serverController.disconnect();
			gameController.disconnect();

			var transitionEvent:TransitionEvent = new TransitionEvent(TransitionEvent.TRANSITION_BEGIN);
			var cleanupState:String;
			switch (Application.STATE)
			{
				case StateEvent.GAME_BATTLE_INIT:
				case StateEvent.GAME_BATTLE:
					cleanupState = StateEvent.GAME_BATTLE_CLEANUP;
					break;
				case StateEvent.GAME_SECTOR_INIT:
				case StateEvent.GAME_SECTOR:
					cleanupState = StateEvent.GAME_SECTOR_CLEANUP;
					break;
				case StateEvent.GAME_STARBASE:
					cleanupState = StateEvent.GAME_STARBASE_CLEANUP;
					break;
				case null:
				case StateEvent.PRELOAD:
					cleanupState = "";
					break;
				default:
					cleanupState = StateEvent.DEFAULT_CLEANUP;
					break;
			}
			transitionEvent.addEvents(new StateEvent(StateEvent.SHUTDOWN_FINISH, cleanupState), new StateEvent(cleanupState, StateEvent.SHUTDOWN_FINISH));
			dispatch(transitionEvent);
		}

		private function finishShutdown():void
		{
			dispatch(new ViewEvent(ViewEvent.DESTROY_ALL_VIEWS));
			var transitionEvent:TransitionEvent = new TransitionEvent(TransitionEvent.TRANSITION_COMPLETE);
			dispatch(transitionEvent);
		}
	}
}
