package com.service.server.connections
{
	import com.Application;
	import com.model.player.CurrentUser;

	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.system.Security;

	import org.as3commons.logging.api.ILogger;
	import org.as3commons.logging.api.getLogger;

	public class DevConnection extends Connection
	{
		private var _loader:URLLoader;

		private static const _logger:ILogger = getLogger('DevConnection');

		override public function connect():void
		{
			if (CONFIG::FLASH_LIVE_DEBUG_MODE == true)
			{
				
				//Security.loadPolicyFile("xmlsocket://37.18.201.89:843");
				
				//var loginUri:String        = "http://37.18.201.89:4000/login/xsolla";
				/*CRYPTO/ Security.loadPolicyFile("xmlsocket://164.90.180.16:843");//*/
				/*LIVE*/  Security.loadPolicyFile("xmlsocket://139.59.150.135:843");//*/
				
				/*CRYPTO/ var loginUri:String        = "http://164.90.180.16:4000/login/xsolla";//*/
				/*LIVE*/  var loginUri:String        = "http://139.59.150.135:4000/login/xsolla";//*/
				
				_logger.info("login - Logging into {0}", [loginUri]);
				//ExternalInterfaceAPI.logConsole("Imeprium Server URL = " + loginUri);
				var variables:URLVariables = new URLVariables();
				//variables["xsolla-token"] = copy token here!
				
				variables["language"] = "en";
				variables["country"] = "US";
				variables["entry-tag"] = "";
				
				//ExternalInterfaceAPI.logConsole("Imeprium Token = " + ExternalInterfaceAPI.getPlayerXsollaGameAuthToken());
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
			else if (CONFIG::FLASH_DEBUG_MODE == true)
			{
				var defaultConnection:Object = _assetModel.getFromCache('data/DefaultConnection.txt');
				Application.ASSET_PATH = "";//defaultConnection.assetPath;
				/* CRYPTO */  //Application.PROXY_SERVER = "164.90.180.16";//"134.209.251.89";//"165.227.132.33";//"37.18.201.91";//"127.0.0.1";//defaultConnection.server;
				/* TM */      Application.PROXY_SERVER = "134.209.251.89";//"165.227.132.33";//"37.18.201.91";//"127.0.0.1";//defaultConnection.server;
				/* STAGING */ //Application.PROXY_SERVER = "165.227.132.33";//"165.227.132.33";//"37.18.201.91";//"127.0.0.1";//defaultConnection.server;
				var variables:URLVariables   = new URLVariables();
				variables.fakeid = 1616;//7777;//16161616;//8001;//102;//37;//CurrentUser.naid;
				variables.cacheavoidance = new Date().getTime(); // HACK: Prevent caching in IE.
				////////var myrequest:URLRequest     = new URLRequest('http://' + defaultConnection.server + ':4000/fakeloginflashdev');
				
				/* CRYPTO */  //var myrequest:URLRequest     = new URLRequest('http://164.90.180.16:4000/fakeloginflashdev?fakeid='+variables.fakeid+'&proxyportoverride=20002&language=en&country=US');
				/* TM */      var myrequest:URLRequest     = new URLRequest('http://134.209.251.89:4000/fakeloginflashdev?fakeid='+variables.fakeid+'&proxyportoverride=20002&language=en&country=US');
				/* STAGING */ //var myrequest:URLRequest     = new URLRequest('http://165.227.132.33:4000/fakeloginflashdev?fakeid='+variables.fakeid+'&proxyportoverride=20002&language=en&country=US');
				//var myrequest:URLRequest     = new URLRequest('http://134.209.251.89:4000/fakeloginflashdev?fakeid='+variables.fakeid+'&proxyportoverride=20002&language=en&country=US');
				//var myrequest:URLRequest     = new URLRequest('http://37.18.201.91:4000/fakeloginflashdev?fakeid='+variables.fakeid+'&proxyportoverride=20002&language=en&country=US');
				//var myrequest:URLRequest     = new URLRequest('http://localhost:4000/fakeloginflashdev?fakeid='+variables.fakeid+'&proxyportoverride=20002&language=en&country=US');
				myrequest.method = URLRequestMethod.GET;
				myrequest.data = variables;
				_loader = new URLLoader();
				_loader.addEventListener(Event.COMPLETE, onPlayerDataReceived);
				_loader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
				_loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
				_loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
				_loader.load(myrequest);
				
				_logger.info("connect - Logging into http://{0}:4000/fakeloginflashdev", ["127.0.0.1"]);
			}
			else
			{
				var defaultConnection:Object = _assetModel.getFromCache('data/DefaultConnection.txt');
				Application.ASSET_PATH = defaultConnection.assetPath;
				Application.PROXY_SERVER = defaultConnection.server;
				var variables:URLVariables   = new URLVariables();
				variables.fakeid = CurrentUser.naid;
				variables.cacheavoidance = new Date().getTime(); // HACK: Prevent caching in IE.
				var myrequest:URLRequest     = new URLRequest('http://' + defaultConnection.server + ':4000/fakeloginflashdev');
				myrequest.method = URLRequestMethod.GET;
				myrequest.data = variables;
				_loader = new URLLoader();
				_loader.addEventListener(Event.COMPLETE, onPlayerDataReceived);
				_loader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
				_loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
				_loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
				_loader.load(myrequest);
				
				_logger.info("connect - Logging into http://{0}:4000/fakeloginflashdev", [defaultConnection.server]);
				
			}
			
		}

		private function onPlayerDataReceived( e:Event ):void
		{
			_logger.info("onPlayerDataReceived");

			var loginData:Object    = JSON.parse(String(e.target.data));

			var proxyIP:String      = loginData["proxy-ip"];
			if (proxyIP != "auto")
				Application.PROXY_SERVER = proxyIP;

			var proxyPortStr:String = loginData["proxy-port"];
			var proxyPort:int       = (proxyPortStr == "unknown") ? 20000 : int(proxyPortStr);
			Application.PROXY_PORT = proxyPort;

			CurrentUser.id = Application.PLAYER_KEY = loginData["player-key"];
			CurrentUser.naid = Application.PLAYER_KABAM_NAID = loginData["kabam-naid"];
			CurrentUser.authID = Application.PLAYER_TOKEN = loginData["player-token"];
			CurrentUser.oAuthID = Application.PLAYER_OAUTH = loginData["player-oauth-token"];
			CurrentUser.language = Application.LANGUAGE = loginData["language"];
			CurrentUser.country = Application.COUNTRY = loginData["country"];

			connectToProxy(true);
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
