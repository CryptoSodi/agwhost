package com.controller.command.account
{
	import com.Application;
	import com.controller.ServerController;
	import com.controller.fte.FTEController;
	import com.enum.TimeLogEnum;
	import com.enum.server.ProtocolEnum;
	import com.enum.server.RequestEnum;
	import com.enum.ui.ButtonEnum;
	import com.event.BattleEvent;
	import com.event.PaywallEvent;
	import com.event.SectorEvent;
	import com.event.ServerEvent;
	import com.event.StarbaseEvent;
	import com.event.StateEvent;
	import com.event.TransitionEvent;
	import com.model.player.CurrentUser;
	import com.model.starbase.StarbaseModel;
	import com.presenter.preload.PreloadPresenter;
	import com.presenter.shared.ITransitionPresenter;
	import com.service.ExternalInterfaceAPI;
	import com.service.server.connections.Connection;
	import com.service.server.connections.XsollaPaymentConnection;
	import com.service.server.outgoing.proxy.ClientLoginRequest;
	import com.ui.alert.ConfirmationView;
	import com.ui.core.ButtonPrototype;
	import com.ui.core.ViewFactory;
	import com.util.TimeLog;
	
	import flash.events.Event;
	
	import org.as3commons.logging.api.ILogger;
	import org.as3commons.logging.api.getLogger;
	import org.parade.core.IViewFactory;
	import org.parade.core.ViewEvent;
	import org.parade.enum.PlatformEnum;
	import org.parade.util.DeviceMetrics;
	import org.robotlegs.extensions.presenter.impl.Command;
	
	public class PaymentCommand extends Command
	{
		//[Inject]
		//public var event:ServerEvent;
		//[Inject]
		//public var fteController:FTEController;
		//[Inject]
		public var presenter:ITransitionPresenter;
		//[Inject]
		//public var serverController:ServerController;
		//[Inject]
		//public var starbaseModel:StarbaseModel;
		//[Inject]
		//public var viewFactory:IViewFactory;
		private static const _logger:ILogger = getLogger('PaymentCommand');
		
		override public function execute():void
		{
			establishConnection(XsollaPaymentConnection);
			
			if (presenter)
				presenter.updateView();
		}
		
		private function establishConnection( ConnectionClass:Class ):void
		{
			//ExternalInterfaceAPI.logConsole("connecting...");
			var connection:Connection = new ConnectionClass();
			injector.injectInto(connection);
			connection.connect();
		}
	}
}
