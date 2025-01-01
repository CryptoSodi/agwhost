package com.service.server.connections
{
	import com.Application;
	import com.controller.ServerController;
	import com.enum.ui.ButtonEnum;
	import com.event.ServerEvent;
	import com.model.asset.AssetModel;
	import com.model.player.CurrentUser;
	import com.service.ExternalInterfaceAPI;
	import com.service.language.Localization;
	import com.ui.alert.ConfirmationView;
	import com.ui.core.ButtonPrototype;
	
	import flash.events.HTTPStatusEvent;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	import org.parade.core.IViewFactory;
	import org.parade.core.ViewEvent;

	public class Connection
	{
		protected static var _instance:Connection;

		protected static var MAX_CONNECTIONS:int = 50;

		protected var _reconnectCount:int;
		protected var _errorMessageShown:Boolean;
		protected var _securityErrorFired:Boolean;
		protected var _httpStatusCode:int;
		protected var _assetModel:AssetModel;
		protected var _eventDispatcher:IEventDispatcher;
		protected var _serverController:ServerController;

		public function Connection()
		{
			_instance = this;
		}

		public function connect():void
		{
			ExternalInterfaceAPI.logConsole("Imeprium Wrong Connection Method");
			CurrentUser.id = Application.PLAYER_KEY;
			CurrentUser.naid = Application.PLAYER_KABAM_NAID;
			CurrentUser.authID = Application.PLAYER_TOKEN;
			CurrentUser.oAuthID = Application.PLAYER_OAUTH;
			CurrentUser.language = Application.LANGUAGE;
			CurrentUser.country = Application.COUNTRY;
			if (Application.NETWORK == Application.NETWORK_UNKNOWN)
				Application.NETWORK = Application.NETWORK_KABAM;

			connectToProxy();
		}

		protected function connectToProxy( isDev:Boolean = false ):void
		{
			ExternalInterfaceAPI.logConsole("Imperium connect to proxy");
			Application.LANGUAGE = ExternalInterfaceAPI.getLocalizationTag();
			if (Application.LANGUAGE != '' && Application.LANGUAGE != null)
				Localization.instance.load('IMPG', Application.LANGUAGE);
			else
				Localization.instance.load('IMPG', 'en');
			//ExternalInterfaceAPI.logConsole("Proxy: " + Application.PROXY_SERVER +":" + Application.PROXY_PORT);
			_serverController.connect(Application.PROXY_SERVER, Application.PROXY_PORT, Application.PROXY_SERVER + ':843', isDev);
			//destroy();
		}

		protected function httpStatusHandler( e:HTTPStatusEvent ):void
		{
			_httpStatusCode = e.status;
		}

		protected function onIOError( e:IOErrorEvent ):void
		{
			sendFailed("Failed-to-Auth");
			if (e.currentTarget.hasOwnProperty("data"))
			{
				var dataText:String = e.currentTarget.data;
				if (dataText.indexOf("suspension") == -1 && dataText.indexOf("banned") == -1 && dataText.indexOf("imperium maintenance") == -1 && _httpStatusCode != 403 && _reconnectCount < MAX_CONNECTIONS)
				{
					++_reconnectCount;
					_securityErrorFired = false;
					connect();
				}

				if (!_errorMessageShown)
					handleServerError(dataText);
			}

			e.stopImmediatePropagation();
		}

		protected function onSecurityError( e:IOErrorEvent ):void
		{
			_securityErrorFired = true;
			sendFailed("Auth-Send-Failed-Security-Error");
		}

		protected function handleServerError( errorText:String ):void
		{
			_errorMessageShown = true;
			var serverEvent:ServerEvent
			errorText = errorText.toLowerCase();
			if (errorText.indexOf('suspension') != -1)
				serverEvent = new ServerEvent(ServerEvent.SUSPENSION);
			else if (errorText.indexOf('banned') != -1)
				serverEvent = new ServerEvent(ServerEvent.BANNED);
			else if (errorText.indexOf('imperium maintenance') != -1)
				serverEvent = new ServerEvent(ServerEvent.MAINTENANCE);
			else
				serverEvent = new ServerEvent(ServerEvent.FAILED_TO_CONNECT);

			_eventDispatcher.dispatchEvent(serverEvent);
		}

		protected function sendFailed( reason:String ):void
		{
			var loader:URLLoader          = new URLLoader();
			var myrequest:URLRequest      = new URLRequest("https://" + ExternalInterfaceAPI.getLoginHostname() + "/Reason=" + reason + '&http-Status-Code=' + _httpStatusCode + '&Security-Error-Fired=' + _securityErrorFired);
			var urlVariables:URLVariables = new URLVariables();
			urlVariables.reason = reason;
			myrequest.method = URLRequestMethod.GET;
			myrequest.data = urlVariables;
			loader = new URLLoader();
			loader.addEventListener(IOErrorEvent.IO_ERROR, postTo80Error);
			loader.load(myrequest);
		}

		private function postTo80Error( e:IOErrorEvent ):void
		{
			e.stopImmediatePropagation();
		}

		[Inject]
		public function set assetModel( v:AssetModel ):void  { _assetModel = v; }
		[Inject]
		public function set serverController( v:ServerController ):void  { _serverController = v; }
		[Inject]
		public function set eventDispatcher( v:IEventDispatcher ):void  { _eventDispatcher = v; }

		public function destroy():void
		{
			_assetModel = null;
			_instance = null;
			_serverController = null;
		}
	}
}
