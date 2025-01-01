package com.service.server.connections {
	import com.Application;
	import com.model.player.CurrentUser;
	import com.service.ExternalInterfaceAPI;
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

	public class XsollaConnection extends Connection {
		private static const _logger: ILogger = getLogger('XsollaConnection');

		private var _loader: URLLoader;

		private var _guestToXsolla: Boolean = false;

		public function XsollaConnection() {
			ExternalInterfaceAPI.logConsole("Imperium Xsolla Connection Startup");
		}

		override public function connect(): void {
			var defaultConnection: Object = _assetModel.getFromCache('data/DefaultConnection.txt');

			if (!defaultConnection) {
				defaultConnection = new Object();
				if (CONFIG::IS_CRYPTO)
					defaultConnection.server = '164.90.180.16'; // CRYPTO
				else
					defaultConnection.server = '139.59.150.135'; // LIVE
			}
			ExternalInterfaceAPI.logConsole("Imperium Token Sending...");
			Security.loadPolicyFile("xmlsocket://" + defaultConnection.server + ":843");
			//Security.loadPolicyFile("xmlsocket://" + ExternalInterfaceAPI.getLoginHostname() + ":843");


			ExternalInterfaceAPI.logConsole("Connecting: " + defaultConnection.server);

			var loginUri: String;
			if (CONFIG::IS_DESKTOP) {
				loginUri = 'http://' + defaultConnection.server + ':4000/login/xsolla';
			} else {
				loginUri = ExternalInterfaceAPI.getLoginProtocol() + "://" + ExternalInterfaceAPI.getLoginHostname() + ':' + ExternalInterfaceAPI.getLoginPort() + "/login/xsolla";
			}
			ExternalInterfaceAPI.logConsole("Imperium Token Sending..." + loginUri);
			//_logger.info("login - Logging into {0}", [loginUri]);
			//ExternalInterfaceAPI.logConsole("Imeprium Server URL = " + loginUri);
			var variables: URLVariables = new URLVariables();
			variables["xsolla-token"] = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJlbWFpbCI6InRhc3NhZHVxMDA5QGdtYWlsLmNvbSIsImV4cCI6MTczMzI3Mjk1OCwiZ3JvdXBzIjpbeyJpZCI6Mjg2LCJuYW1lIjoiUGxheWVyIiwiaXNfZGVmYXVsdCI6dHJ1ZX1dLCJpYXQiOjE3MzMxODY1NTgsImlkIjoiOTEwODUwNDE3NTg0NzM3MyIsImlzX21hc3RlciI6dHJ1ZSwiaXNzIjoiaHR0cHM6Ly9sb2dpbi54c29sbGEuY29tIiwibmFtZSI6IlRhc3NhZHVxIEh1c3NhaW4iLCJwaWN0dXJlIjoiaHR0cHM6Ly9wbGF0Zm9ybS1sb29rYXNpZGUuZmJzYnguY29tL3BsYXRmb3JtL3Byb2ZpbGVwaWMvP2FzaWQ9OTEwODUwNDE3NTg0NzM3M1x1MDAyNmhlaWdodD01MFx1MDAyNndpZHRoPTUwXHUwMDI2ZXh0PTE3MzU3Nzg1NThcdTAwMjZoYXNoPUFiYlQ2bWo3b2VEMWh5S2xZQ2wzNlVseiIsInByb21vX2VtYWlsX2FncmVlbWVudCI6dHJ1ZSwicHJvdmlkZXIiOiJmYWNlYm9vayIsInB1Ymxpc2hlcl9pZCI6NTU4OTIsInN1YiI6ImE4ZWE4NzRjLWQwMGQtNGIxYS05YWE2LTY4OWI0ODY4OWY2YiIsInR5cGUiOiJzb2NpYWwiLCJ1c2VybmFtZSI6InRhc3NhZHVxMDA5QGdtYWlsLmNvbSIsInhzb2xsYV9sb2dpbl9hY2Nlc3Nfa2V5IjoiNl9YUi1zMnRSbWRKMkRmMlZTZ3lmZW1BM1ViTWJoNVVMMFQ5MGM0dWR5QSIsInhzb2xsYV9sb2dpbl9wcm9qZWN0X2lkIjoiMzY3NGQ2YTYtOGIyMi0xMWU4LWFkNjctZDg5ZDY3MTU1MjI0In0.EeYFxKwHRmVBG-Y4npLzS57lrY9YZwDeAOSMOAvJTBk"; //ExternalInterfaceAPI.getPlayerXsollaGameAuthToken();
			variables["language"] = ExternalInterfaceAPI.getLanguageCode();
			variables["country"] = ExternalInterfaceAPI.getCountryCode();
			variables["entry-tag"] = ExternalInterfaceAPI.getEntryTag();

			//TODO uncomment when all Guest Account is implemented
			//var guestId:String = ExternalInterfaceAPI.getGuestToXsollaUserId();
			//if(guestId.length > 0)
			//{
			//	_guestToXsolla = true;
			//	variables["guest-user-id"] = guestId;
			//}

			//ExternalInterfaceAPI.logConsole("Imeprium Token = " + ExternalInterfaceAPI.getPlayerXsollaGameAuthToken());
			var request: URLRequest = new URLRequest(loginUri);
			request.data = variables;
			request.method = URLRequestMethod.POST;
			_loader = new URLLoader();
			_loader.addEventListener(Event.COMPLETE, onPlayerDataReceived);
			_loader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			_loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
			_loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
			_loader.load(request);
		}

		private function onPlayerDataReceived(e: Event): void {
			_logger.info("onPlayerDataReceived");
			try {
				var loginData: Object = JSON.parse(String(e.target.data));

				Application.PROXY_SERVER = loginData["proxy-ip"];
				Application.PROXY_PORT = loginData["proxy-port"];
				CurrentUser.id = Application.PLAYER_KEY = loginData["player-key"];
				Application.NETWORK = loginData["play-platform"];
				CurrentUser.naid = Application.PLAYER_KABAM_NAID = loginData["kabam-naid"];
				CurrentUser.authID = Application.PLAYER_TOKEN = loginData["player-token"];
				CurrentUser.oAuthID = Application.PLAYER_OAUTH = loginData["player-oauth-token"];
				CurrentUser.language = Application.LANGUAGE = loginData["language"];
				CurrentUser.country = Application.COUNTRY = loginData["country"];
				//Application.ASSET_PATH = loginData["asset-path"];

				if (_guestToXsolla) {
					ExternalInterfaceAPI.completeGuestToXsolla();
				}

				ExternalInterfaceAPI.setPlayPlatform(Application.NETWORK);
				//ExternalInterfaceAPI.logConsole("Imperium Auth Successful!");
				connectToProxy();
			} catch (err: Error) {
				_logger.error("nAuthComplete - Failed");
				if (!_errorMessageShown && e.currentTarget.hasOwnProperty("data"))
					handleServerError(e.currentTarget.data);

				//ExternalInterfaceAPI.logConsole("Imperium auth failed cause of error!");
			}
			/*_logger.info('onAuthComplete')
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
			if (e.currentTarget.hasOwnProperty("data"))
			{
			handleServerError(e.currentTarget.data);
			}
			}*/
		}

		override protected function onIOError(e: IOErrorEvent): void {
			//ExternalInterfaceAPI.logConsole("onIOError - Http status code");
			_logger.error('onIOError - Http status code - {0}', [_httpStatusCode]);
			super.onIOError(e);
		}

		override protected function onSecurityError(e: IOErrorEvent): void {
			//ExternalInterfaceAPI.logConsole("nSecurityError - Auth Send Failed!");
			_logger.error('onSecurityError - Auth Send Failed');
			super.onSecurityError(e);
		}

		//[Inject]
		//public function set xsollaAPI( v:XsollaAPI ):void  { _xsollaAPI = v; }

		override public function destroy(): void {
			super.destroy();
		}
	}
}