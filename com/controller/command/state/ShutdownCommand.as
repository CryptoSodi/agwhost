package com.controller.command.state
{
	import com.Application;
	import com.event.StateEvent;
	import com.ui.ReconnectView;

	import org.parade.core.ViewEvent;

	public class ShutdownCommand extends StateCommand
	{
		override public function execute():void
		{
			if (event.type == StateEvent.SHUTDOWN_FINISH)
				finishShutdown();
		}

		private function finishShutdown():void
		{
			Application.PROXY_SERVER = null;
			var viewEvent:ViewEvent = new ViewEvent(ViewEvent.SHOW_VIEW);
			viewEvent.targetClass = ReconnectView;
			dispatch(viewEvent);
		}
	}
}
