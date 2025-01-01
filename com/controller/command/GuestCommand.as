package com.controller.command
{
	import com.Application;
	import com.controller.GameController;
	import com.event.ServerEvent;
	import com.service.ExternalInterfaceAPI;
	
	import org.parade.core.IViewFactory;
	import org.robotlegs.extensions.presenter.impl.Command;
	
	import org.as3commons.logging.api.ILogger;
	import org.as3commons.logging.api.getLogger;
	
	import com.ui.modal.information.GuestRestrictionView;
	
	public class GuestCommand extends Command
	{
		[Inject]
		public var event:ServerEvent;
		[Inject]
		public var viewFactory:IViewFactory;
		[Inject]
		public var gameController:GameController;
		
		private static const _logger:ILogger = getLogger('GuestCommand');
		
		override public function execute():void
		{
			switch (event.type)
			{
				case ServerEvent.GUEST_RESTRICTION:
					if (viewFactory)
					{
						var window:GuestRestrictionView = GuestRestrictionView(viewFactory.createView(GuestRestrictionView));
						viewFactory.notify(window);
					}
					break;
			}
		}
	}
}
