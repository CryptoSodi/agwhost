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
	import com.service.server.connections.DevConnection;
	import com.service.server.connections.FacebookConnection;
	import com.service.server.connections.KabamConnection;
	import com.service.server.connections.KongregateConnection;
	import com.service.server.connections.XsollaConnection;
	import com.service.server.connections.SteamConnection;
	import com.service.server.connections.GuestConnection;
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

	public class ConnectionCommand extends Command
	{
		[Inject]
		public var event:ServerEvent;
		[Inject]
		public var fteController:FTEController;
		[Inject]
		public var presenter:ITransitionPresenter;
		[Inject]
		public var serverController:ServerController;
		[Inject]
		public var starbaseModel:StarbaseModel;
		[Inject]
		public var viewFactory:IViewFactory;

		private static const _logger:ILogger = getLogger('ConnectionCommand');

		override public function execute():void
		{
			//ExternalInterfaceAPI.logConsole("Imperium Connection Init");
			Application.CONNECTION_STATE = event.type;
			//ExternalInterfaceAPI.logConsole("Imperium Connection State: " + Application.CONNECTION_STATE);
			_logger.info("execute - Application.CONNECTION_STATE = {0}", [event.type]);
			switch (event.type)
			{
				case ServerEvent.CONNECT_TO_PROXY:
					if (Application.NETWORK == Application.NETWORK_KABAM || Application.NETWORK == Application.NETWORK_DEV)
						establishConnection(KabamConnection);
					else if (Application.NETWORK == Application.NETWORK_KONGREGATE)
						establishConnection(KongregateConnection);
					else if (Application.NETWORK == Application.NETWORK_STEAM)
						establishConnection(SteamConnection);
					else if (Application.NETWORK == Application.NETWORK_GUEST)
						establishConnection(GuestConnection);
					else if (Application.NETWORK == Application.NETWORK_XSOLLA)
					{
						if (CONFIG::FLASH_DEBUG_MODE == true || CONFIG::FLASH_LIVE_DEBUG_MODE)
							establishConnection(DevConnection);
						else
							establishConnection(XsollaConnection);
					}
					else if (Application.NETWORK == Application.NETWORK_FACEBOOK)
						establishConnection(FacebookConnection);
					else if (CurrentUser.naid)
						establishConnection(DevConnection);
					else
						Application.CONNECTION_STATE = ServerEvent.NOT_CONNECTED;
					
					break;

				case ServerEvent.LOGIN_TO_ACCOUNT:
					TimeLog.startTimeLog(TimeLogEnum.LOGIN_TO_ACCOUNT);
					var proxyLogin:ClientLoginRequest    = ClientLoginRequest(serverController.getRequest(ProtocolEnum.PROXY_CLIENT, RequestEnum.PROXY_LOGIN));
					proxyLogin.name = CurrentUser.id;
					proxyLogin.challengeToken = CurrentUser.authID; // this should be given to us by KABAM authentication
					proxyLogin.clientVersion = 1; // TODO - increment this as we break binary compatibility
					
					//ExternalInterfaceAPI.logConsole("Imperium Credentails: id = " + CurrentUser.id + " ; auth = " + CurrentUser.authID);
					serverController.send(proxyLogin);
					serverController.lockRead = true;
					break;

				case ServerEvent.NEED_CHARACTER_CREATE:
					dispatch(new StateEvent(StateEvent.CREATE_CHARACTER));
					break;

				case ServerEvent.BANNED:
				case ServerEvent.SUSPENSION:
				case ServerEvent.MAINTENANCE:
				case ServerEvent.FAILED_TO_CONNECT:
					var transitionEvent:TransitionEvent  = new TransitionEvent(TransitionEvent.TRANSITION_FAILED);
					dispatch(transitionEvent);


					var title:String;
					var body:String;

					if (event.type == ServerEvent.BANNED)
					{
						title = "ACCOUNT BANNED";
						body = "This Account has been banned. If you think this is wrong please contact support.";
					} else if (event.type == ServerEvent.SUSPENSION)
					{
						title = "ACCOUNT SUSPENSION";
						body = "This Account has been suspended. If you think this is wrong please contact support.";
					} else if (event.type == ServerEvent.MAINTENANCE)
					{
						title = "MAINTENANCE";
						body = "The game is currently undergoing maintenance. Please try again later.";
					} else
					{
						title = "CONNECTION FAILED";
						body = "Failed to connect. Try to refresh and if that does not work please contact support.";
						ExternalInterfaceAPI.refresh();
						break;
					}
					ExternalInterfaceAPI.logConsole("Failed to connect: " + title + " - " + body);

					var buttons:Vector.<ButtonPrototype> = new Vector.<ButtonPrototype>;
					buttons.push(new ButtonPrototype('OK', null, null, true, ButtonEnum.RED_A));

					var viewEvent:ViewEvent              = new ViewEvent(ViewEvent.SHOW_VIEW);
					var view:ConfirmationView            = ConfirmationView(viewFactory.createView(ConfirmationView));

					view.setup(title, body, buttons)
					viewEvent.targetView = view;
					dispatch(viewEvent);

					break;
				default:
					sendPixelRequest();
					onAuthorized();
					break;
			}
			if (presenter)
				presenter.updateView();
		}

		private function onAuthorized():void
		{
			TimeLog.endTimeLog(TimeLogEnum.LOGIN_TO_ACCOUNT);
			//If the preloader is done then we want to notify the loading screen that we're switching views
			if (PreloadPresenter.complete)
			{
				var event:Event;
				if (fteController.startInSector)
					event = new SectorEvent(SectorEvent.CHANGE_SECTOR, starbaseModel.homeBase.sectorID);
				else if (starbaseModel.homeBase.battleServerAddress != null)
					event = new BattleEvent(BattleEvent.BATTLE_JOIN, starbaseModel.homeBase.battleServerAddress);
				else if (starbaseModel.homeBase.instancedMissionAddress != null)
					event = new BattleEvent(BattleEvent.BATTLE_JOIN, starbaseModel.homeBase.instancedMissionAddress);
				else
					event = new StarbaseEvent(StarbaseEvent.ENTER_BASE);
				dispatch(event);

				if (Application.NETWORK == Application.NETWORK_KONGREGATE || Application.NETWORK == Application.NETWORK_FACEBOOK)
				{
					var paywall:PaywallEvent = new PaywallEvent(PaywallEvent.BUY_ITEM);
					dispatch(paywall);
				}
			}
		}

		private function sendPixelRequest():void
		{
			if (DeviceMetrics.PLATFORM == PlatformEnum.BROWSER)
				ExternalInterfaceAPI.popPixel(1);
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
