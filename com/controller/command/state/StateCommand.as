package com.controller.command.state
{
	import com.event.StateEvent;
	
	import org.robotlegs.extensions.presenter.impl.Command;
	
	public class StateCommand extends Command
	{
		[Inject]
		public var event:StateEvent;
	}
}