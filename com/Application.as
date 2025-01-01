package com
{
	import com.service.ExternalInterfaceAPI;
	
	import flash.display.DisplayObject;
	import flash.display.LoaderInfo;
	import flash.display.Stage;
	import flash.events.ErrorEvent;
	import flash.events.UncaughtErrorEvent;
	
	import org.as3commons.logging.api.ILogger;
	import org.as3commons.logging.api.getLogger;
	import org.osflash.signals.Signal;
	import org.parade.enum.PlatformEnum;
	import org.parade.util.DeviceMetrics;

	public class Application
	{
		// Network identifiers -- what platform are we running on?
		// Values here must match the "play_platform_id" used by the Kabam platform.
		// On the server the enumeration is KabamPlayPlatformId.
		// Note this document too for reference: https://sites.google.com/a/watercooler-inc.com/kabam-site/kfid
		// ...however ignore the example id's listed there, as they differ from the play platform id.
		public static const NETWORK_UNKNOWN:int    = -1;
		public static const NETWORK_FACEBOOK:int   = 0;
		public static const NETWORK_KABAM:int      = 1;
		//public static const NETWORK_IOS:int      = 2;
		//public static const NETWORK_GOOGLE:int   = 3;	// Possibly deprecated...?
		//public static const NETWORK_ANDROID:int  = 4;	// Apparently deprecated (use NETWORK_GOOGLEAPP).
		public static const NETWORK_YAHOO:int      = 12;
		public static const NETWORK_KONGREGATE:int = 36;
		public static const NETWORK_STEAM:int    = 48;
		public static const NETWORK_DEV:int        = 49;
		public static const NETWORK_GOOGLEAPP:int  = 51;
		//public static const NETWORK_AMAZONAPP:int  = 52;
		public static const NETWORK_XSOLLA:int      = 53;
		public static const NETWORK_GUEST:int      = 54;

		public static var ASSET_PATH:String        = "";
		public static var AVG_LOAD_TIME:int;
		public static var CONNECTION_STATE:String;
		public static var MIN_SCREEN_X:Number      = 1280;
		public static var MIN_SCREEN_Y:Number      = 800;
		public static var NETWORK:int              = NETWORK_UNKNOWN;
		public static var PLAYER_KEY:String;
		public static var PLAYER_KABAM_NAID:String;
		public static var LANGUAGE:String;
		public static var COUNTRY:String;
		public static var PLAYER_TOKEN:String;
		public static var PLAYER_OAUTH:String;
		public static var PROXY_PORT:int;
		public static var PROXY_SERVER:String;
		public static var SCALE:Number             = .7;
		public static var STAGE:Stage;
		public static var STARLING_ENABLED:Boolean;
		public static var STATE:String;
		public static var LOGIN_TOKEN:String;
		public static var BATTLE_WEB_PATH:String;
		
		public static var batteryLife:Number;
		public static var isCharging:Boolean;

		public static var onBatteryChargeChanged:Signal;
		public static var onError:Signal;
		

		private static var _root:DisplayObject;

		private static const _logger:ILogger       = getLogger('Application');
		
		public static function init( stage:Stage ):void
		{
			//ExternalInterfaceAPI.logConsole("Imperium Init");
			
			STAGE = stage;
			AVG_LOAD_TIME = 0;

			onBatteryChargeChanged = new Signal(Boolean, Number);
			onError = new Signal(String);

			var data:Object = rootParameters;
			if (data)
			{
				//TODO hack for quick test
				//NETWORK = NETWORK_XSOLLA; //
				//ExternalInterfaceAPI.logConsole("Imperium Platform = "+ data["play-platform"]);
				
				NETWORK = data["play-platform"] ? data["play-platform"] : NETWORK_XSOLLA;
				LOGIN_TOKEN = data["login-token"];
 				ExternalInterfaceAPI.setPlayPlatform(NETWORK);
				
				ExternalInterfaceAPI.submitKongregateStat("initialized", 1);
			}
			BATTLE_WEB_PATH = ExternalInterfaceAPI.getBattleWebPath();
			trace(DeviceMetrics.toString());
		}

		private static function uncaughtErrorHandler( event:UncaughtErrorEvent ):void
		{
			event.preventDefault();

			var errStr:String;
			if (event.error is Error)
			{
				var error:Error = event.error as Error;
				errStr = error.getStackTrace();
			} else if (event.error is ErrorEvent)
			{
				var errorEvent:ErrorEvent = event.error as ErrorEvent;
				errStr = errorEvent.toString();
					// do something with the error
			} else
			{
				// a non-Error, non-ErrorEvent type was thrown and uncaught
			}

			onError.dispatch(errStr);
		}

		public static function set ROOT( v:DisplayObject ):void
		{
			_root = v;
			_root.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, uncaughtErrorHandler, false, 999999);
		}
		

		public static function get rootParameters():Object
		{
			var obj:Object  = STAGE.stage.getChildAt(0); //get the parent if this swf was loaded in
			var data:Object = (obj is Imperium || DeviceMetrics.PLATFORM == PlatformEnum.MOBILE) ? LoaderInfo(STAGE.root.loaderInfo).parameters : obj.getParameters();

			return data;
		}

		public static function setBatteryStatus( charging:Boolean, chargeRatio:Number ):void
		{
			isCharging = charging;
			batteryLife = chargeRatio;
			onBatteryChargeChanged.dispatch(charging, chargeRatio);
			_logger.info("Battery status changed: isCharging = " + isCharging + ", batteryLife = " + batteryLife + ".");
		}
	}
}
