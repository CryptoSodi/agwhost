package com.service.server.connections
{
	import com.Application;
	import com.model.player.CurrentUser;
	import com.service.ExternalInterfaceAPI;

	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.system.Security;

	import org.as3commons.logging.api.ILogger;
	import org.as3commons.logging.api.getLogger;

	public class FacebookTokenConnection extends Connection
	{
		private var _loader:URLLoader;

		private static const _logger:ILogger = getLogger('FacebookTokenConnection');

		override public function connect():void
		{
			ExternalInterfaceAPI.logConsole("Imeprium Facebook Auth...");
			Security.loadPolicyFile("xmlsocket://" + ExternalInterfaceAPI.getLoginHostname() + ":843");

			var loginUri:String      = ExternalInterfaceAPI.getLoginProtocol() + "://" + ExternalInterfaceAPI.getLoginHostname() + ':' + ExternalInterfaceAPI.getLoginPort() + "/login/token";
			ExternalInterfaceAPI.logConsole(loginUri);
			_logger.info("connect - Logging into {0}", [loginUri]);
			var myrequest:URLRequest = new URLRequest(loginUri);
			_logger.info("connect - Token = {0}", [Application.LOGIN_TOKEN]);
			ExternalInterfaceAPI.logConsole(Application.LOGIN_TOKEN);
			myrequest.method = URLRequestMethod.POST;
			myrequest.data = Application.LOGIN_TOKEN;
			_loader = new URLLoader();
			_loader.addEventListener(Event.COMPLETE, onPlayerDataReceived);
			_loader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			_loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			_loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
			_loader.load(myrequest);
		}

		private function onPlayerDataReceived( e:Event ):void
		{
			_logger.info("onPlayerDataReceived");
			try
			{
				var loginData:Object = JSON.parse(String(e.target.data));

				Application.PROXY_SERVER = loginData["proxy-ip"];
				Application.PROXY_PORT = loginData["proxy-port"];
				CurrentUser.id = Application.PLAYER_KEY = loginData["player-key"];
				Application.NETWORK = loginData["play-platform"];
				CurrentUser.naid = Application.PLAYER_KABAM_NAID = loginData["kabam-naid"];
				CurrentUser.authID = Application.PLAYER_TOKEN = loginData["player-token"];
				CurrentUser.oAuthID = Application.PLAYER_OAUTH = loginData["player-oauth-token"];
				CurrentUser.language = Application.LANGUAGE = loginData["language"];
				CurrentUser.country = Application.COUNTRY = loginData["country"];
				Application.ASSET_PATH = loginData["asset-path"];

				ExternalInterfaceAPI.setPlayPlatform(Application.NETWORK);

				connectToProxy();
			} catch ( err:Error )
			{
				_logger.error("nAuthComplete - Failed");
				if (!_errorMessageShown && e.currentTarget.hasOwnProperty("data"))
					handleServerError(e.currentTarget.data);
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

		override public function destroy():void
		{
			super.destroy();

			if (_loader)
			{
				_loader.removeEventListener(Event.COMPLETE, onPlayerDataReceived);
				_loader.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
				_loader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
				_loader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
			}
			_loader = null;
		}
	}
}
