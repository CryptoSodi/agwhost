package com
{
	import com.controller.command.state.StartupCommand;
	import com.event.StateEvent;

	import flash.display.DisplayObjectContainer;
	import flash.events.IEventDispatcher;

	import org.parade.util.DeviceMetrics;
	import org.robotlegs.extensions.eventCommandMap.api.IEventCommandMap;
	
	import com.service.ExternalInterfaceAPI;

	public class StartupConfig extends StartupBaseConfig
	{
		private static var _FontArray:Array;
		
		public function StartupConfig( commandMap:IEventCommandMap, dispatcher:IEventDispatcher, contextView:DisplayObjectContainer )
		{
			
			super(commandMap, dispatcher);

			commandMap.map(StateEvent.STARTUP_COMPLETE, StateEvent).toCommand(StartupCommand);

			DeviceMetrics.init(contextView.stage, CONFIG::PLATFORM);
			
			_FontArray = new Array();
			_FontArray.push(ExternalInterfaceAPI.getFont(0));
			_FontArray.push(ExternalInterfaceAPI.getFont(1));
			Application.init(contextView.stage);

			startupComplete(dispatcher);
		}
		public static function get FontArray():Array
		{
			return _FontArray;
		}
		
	}
}
