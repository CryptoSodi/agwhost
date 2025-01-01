package com
{
	import com.controller.command.state.StartupCoreCommand;
	import com.event.StateEvent;

	import flash.events.IEventDispatcher;

	import org.robotlegs.extensions.eventCommandMap.api.IEventCommandMap;

	public class StartupBaseConfig
	{
		public function StartupBaseConfig( commandMap:IEventCommandMap, dispatcher:IEventDispatcher )
		{
			commandMap.map(StateEvent.STARTUP_COMPLETE, StateEvent).toCommand(StartupCoreCommand);
		}

		protected function startupComplete( dispatcher:IEventDispatcher ):void
		{
			//send out the state event
			dispatcher.dispatchEvent(new StateEvent(StateEvent.STARTUP_COMPLETE));
		}
	}
}
