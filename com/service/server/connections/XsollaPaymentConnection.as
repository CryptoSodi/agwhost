package com.service.server.connections
{
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
	
	public class XsollaPaymentConnection extends Connection
	{
		
		public function XsollaPaymentConnection()
		{
			//ExternalInterfaceAPI.logConsole("Imperium Xsolla Paymment Connection Startup");
		}
		private static const _logger:ILogger = getLogger('XsollaPayment');
		
		private var _loader:URLLoader;
		
		override public function connect():void
		{
			
			var defaultConnection:Object = _assetModel.getFromCache('data/DefaultConnection.txt');
			
			if (!defaultConnection)
			{
				defaultConnection = new Object();
				if ( CONFIG::IS_CRYPTO )
					defaultConnection.server = '164.90.180.16';  // CRYPTO
				else
					defaultConnection.server = '139.59.150.135'; // LIVE
			}
			//ExternalInterfaceAPI.logConsole("Imperium Payment Token Request...");
			Security.loadPolicyFile("xmlsocket://" +  defaultConnection.server + ":843");
			//Security.loadPolicyFile("xmlsocket://" + ExternalInterfaceAPI.getLoginHostname() + ":843");
			
			var paymentUri:String        = ExternalInterfaceAPI.getPaymentProtocol() + "://" + ExternalInterfaceAPI.getPaymentHostname() + ':' + ExternalInterfaceAPI.getPaymentPort() + "/token/xsolla";
			if(CONFIG::IS_DESKTOP){
				paymentUri = 'http://' + defaultConnection.server + ':9000/token/xsolla';	
			} else {
				paymentUri = ExternalInterfaceAPI.getPaymentProtocol() + "://" + ExternalInterfaceAPI.getPaymentHostname() + ':' + ExternalInterfaceAPI.getPaymentPort() + "/token/xsolla";
			}
			
			_logger.info("payment - Logging into {0}", [paymentUri]);
			var variables:URLVariables = new URLVariables();
			variables["xsolla-token"] = ExternalInterfaceAPI.getPlayerXsollaGameAuthToken();
			
			var request:URLRequest     = new URLRequest(paymentUri);
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
			_logger.info("onPlayerDataReceived");
			try
			{
				//ExternalInterfaceAPI.logConsole("Imperium Payment Successful!");
				
				//var paymentData:Object = JSON.parse(String(e.target.data));
				//var access_token:String = paymentData["token"];
				var access_token:String = String(e.target.data)
				
				ExternalInterfaceAPI.openXsollaStore(access_token);
				
			} catch ( err:Error )
			{
				_logger.error("nPaymentComplete - Failed");
				if (!_errorMessageShown && e.currentTarget.hasOwnProperty("data"))
					handleServerError(e.currentTarget.data);
				
				ExternalInterfaceAPI.logConsole("Imperium Payment failed cause of error!");
			}
		}
		
		override protected function onIOError( e:IOErrorEvent ):void
		{
			//ExternalInterfaceAPI.logConsole("onIOError - Http status code");
			_logger.error('onIOError - Http status code - {0}', [_httpStatusCode]);
			super.onIOError(e);
			destroy();
		}
		
		override protected function onSecurityError( e:IOErrorEvent ):void
		{
			//ExternalInterfaceAPI.logConsole("nSecurityError - Payment Send Failed!");
			_logger.error('onSecurityError - Payment Send Failed');
			super.onSecurityError(e);
			destroy();
		}
	}
}