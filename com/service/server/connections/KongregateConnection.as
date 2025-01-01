package com.service.server.connections
{
	import com.Application;
	import com.model.player.CurrentUser;
	import com.service.ExternalInterfaceAPI;
	import com.service.kongregate.KongregateAPI;
	import com.service.loading.LoadPriority;

	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.system.Security;

	import org.as3commons.logging.api.ILogger;
	import org.as3commons.logging.api.getLogger;

	public class KongregateConnection extends Connection
	{
		private static const _logger:ILogger = getLogger('KongregateConnection');

		private var _kongregateAPI:KongregateAPI;
		private var _loader:URLLoader;

		override public function connect():void
		{
			ExternalInterfaceAPI.logConsole("Imperium Kongregate Auth...");
			Security.loadPolicyFile("xmlsocket://" + ExternalInterfaceAPI.getLoginHostname() + ":843");

			var loginUri:String        = ExternalInterfaceAPI.getLoginProtocol() + "://" + ExternalInterfaceAPI.getLoginHostname() + ':' + ExternalInterfaceAPI.getLoginPort() + "/login/kongregate";
			_logger.info("login - Logging into {0}", [loginUri]);
			var variables:URLVariables = new URLVariables();
			variables["kongregate-user-id"] = _kongregateAPI.userID;
			variables["kongregate-user-auth-token"] = _kongregateAPI.gameAuthToken;
			variables["language"] = ExternalInterfaceAPI.getLanguageCode();
			variables["country"] = ExternalInterfaceAPI.getCountryCode();
			variables["entry-tag"] = ExternalInterfaceAPI.getEntryTag();
			var request:URLRequest     = new URLRequest(loginUri);
			request.data = variables;
			request.method = URLRequestMethod.POST;
			_loader = new URLLoader();
			_loader.addEventListener(Event.COMPLETE, onPlayerDataReceived);
			_loader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			_loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			_loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
			_loader.load(request);
		}

		private function onPlayerDataReceived( e:Event ):void
		{
			_logger.info('onAuthComplete')
			try
			{
				var data:Object          = JSON.parse(URLLoader(e.currentTarget).data);
				var loginResponse:Object = data;

				Application.PROXY_SERVER = loginResponse["proxy-ip"];
				Application.PROXY_PORT = loginResponse["proxy-port"];
				CurrentUser.id = Application.PLAYER_KEY = loginResponse["player-key"];
				Application.NETWORK = loginResponse["play-platform"];
				CurrentUser.naid = Application.PLAYER_KABAM_NAID = loginResponse["kabam-naid"];
				CurrentUser.authID = Application.PLAYER_TOKEN = loginResponse["player-token"];
				CurrentUser.oAuthID = Application.PLAYER_OAUTH = loginResponse["player-oauth-token"];
				CurrentUser.language = Application.LANGUAGE = loginResponse["language"];
				CurrentUser.country = Application.COUNTRY = loginResponse["country"];
				Application.ASSET_PATH = loginResponse["asset-path"];
				
				ExternalInterfaceAPI.logConsole("Imperium Auth Successful!");

				if (_loader)
				{
					_loader.removeEventListener(Event.COMPLETE, onPlayerDataReceived);
					_loader.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
					_loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
					_loader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
				}
				_loader = null;

				ExternalInterfaceAPI.setPlayPlatform(Application.NETWORK);

				connectToProxy();
			} catch ( err:Error )
			{
				ExternalInterfaceAPI.logConsole("Imperium Auth Failure!");
				
				if (e.currentTarget.hasOwnProperty("data"))
				{
					handleServerError(e.currentTarget.data);
				}
			}
		}

		override protected function onIOError( e:IOErrorEvent ):void
		{
			_logger.error('onIOError - Http status code - {0}', [_httpStatusCode]);
			super.onIOError(e);
		}

		override protected function onSecurityError( e:IOErrorEvent ):void
		{
			_logger.error('onSecurityError - Auth Send Failed');
			super.onSecurityError(e);
		}

		[Inject]
		public function set kongregateAPI( v:KongregateAPI ):void  { _kongregateAPI = v; }

		override public function destroy():void
		{
			super.destroy();
			_kongregateAPI = null;
		}
	}
}
