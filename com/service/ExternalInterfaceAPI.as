package com.service
{
	import com.Application;
	import com.controller.SettingsController;
	import com.event.TransactionEvent;
	import com.model.asset.AssetModel;
	import com.model.asset.AssetVO;
	import com.model.player.CurrentUser;
	import com.model.player.PlayerVO;
	import com.model.prototype.IPrototype;
	import com.service.kongregate.KongregateAPI;
	import com.service.language.Localization;
	
	import flash.display.StageDisplayState;
	import flash.external.ExternalInterface;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getDefinitionByName;

	import org.osflash.signals.Signal;
	
	

	public class ExternalInterfaceAPI
	{
		
		static private const ON_SWF_LOADED:String                = "Imperium.onSwfLoaded";

		static private const SHARE_PvP_VICTORY:String            = "Imperium.sharePvPVictory";
		static private const SHARE_USER_LEVEL_UP:String          = "Imperium.shareLevelUp";
		static private const SHARE_TRANSACTION:String            = "Imperium.shareTransaction";
		static private const SHARE_PLAY_REQUEST:String           = "Imperium.sharePlayRequest";
		
		static private const GET_FACEBOOK_USER_ID:String            = "Imperium.getFacebookUserId";
		static private const GET_FACEBOOK_USER_ACCESS_TOKEN:String  = "Imperium.getFacebookAccessToken";
		static private const GET_FACEBOOK_ITEMS:String 				= "Imperium.getFacebookItems";
		static private const OPEN_FACEBOOK_PAYWALL:String 				= "Imperium.openFacebookPaywall";

		static private const GET_LOGIN_PROTOCOL:String           = "Imperium.getLoginProtocol";
		static private const GET_LOGIN_HOSTNAME:String           = "Imperium.getLoginHostname";
		static private const GET_LOGIN_PORT:String               = "Imperium.getLoginPort";
		static private const GET_PAYMENT_PROTOCOL:String           = "Imperium.getPaymentProtocol";
		static private const GET_PAYMENT_HOSTNAME:String           = "Imperium.getPaymentHostname";
		static private const GET_PAYMENT_PORT:String               = "Imperium.getPaymentPort";
		static private const OPEN_XSOLLA_STORE:String 			 = "Imperium.openXsollaStore";
		static private const SET_PLAY_PLATFORM:String            = "Imperium.setPlayPlatform";
		static private const RELOAD_SWF:String            		 = "Imperium.reloadSwf";

		static private const GET_BATTLE_WEB_PATH:String          = "Imperium.getBattleWebPath";
		static private const ON_REFRESH:String          		 = "Imperium.onRefresh";
		static private const ON_LOG_OUT:String       		     = "Imperium.onLogOut";
		static private const ON_REGISTER_GUEST:String            = "Imperium.onRegisterGuest";

		static private const POP_PAYWALL:String                  = "Imperium.popPaywall";
		static private const POP_PIXEL:String                    = "Imperium.popPixel";
		
		static private const GET_LOCALIZATION_FOLDER:String      = "Imperium.getLocalizationFolder";
		static private const GET_LOCALIZATION_VO_FOLDER:String      = "Imperium.getLocalizationVOFolder";
		static private const GET_MAIN_FONT:String      			 = "Imperium.getMainFont";
		static private const GET_TRACE_FONT:String     			 = "Imperium.getTraceFont";
		static private const GET_FONT:String     			 = "Imperium.getFont";
		static private const SET_LOCALIZATION_TAG:String      = "Imperium.saveLocalizationTag";
		static private const GET_LOCALIZATION_TAG:String      = "Imperium.getLocalizationTag";
		
		static private const GET_LANGUAGE_CODE:String      = "Imperium.getLanguageCode";
		static private const GET_COUNTRY_CODE:String      = "Imperium.getCountryCode";
		static private const GET_ENTRY_TAG:String      = "Imperium.getEntryTag";

		static private const PURCHASE_KONGREGATE_ITEMS:String    = "ImperiumKongregateDriver.purchaseKongregateItems";
		static private const GET_PLAYER_KONGREGATE_USER_ID:String = "ImperiumKongregateDriver.getPlayerKongregateUserId";
		static private const GET_PLAYER_KONGREGATE_USERNAME:String = "ImperiumKongregateDriver.getPlayerKongregateUsername";
		static private const GET_PLAYER_KONGREGATE_GAME_AUTH_TOKEN:String = "ImperiumKongregateDriver.getPlayerKongregateGameAuthToken";
		static private const SUBMIT_KONGREGATE_STAT:String    = "ImperiumKongregateDriver.submitKongregateStat";
		
		static private const GET_PLAYER_XSOLLA_GAME_AUTH_TOKEN:String = "Imperium.getPlayerXsollaGameAuthToken";
		
		static private const GET_STEAM_SESSION_TICKET:String = "Imperium.getSteamSessionTicket";
		
		static private const GET_GUEST_USER_ID:String = "Imperium.getGuestUserId";
		static private const SET_GUEST_USER_ID:String = "Imperium.setGuestUserId";
		
		static private const GET_GUEST_TO_XSOLLA_USER_ID:String = "Imperium.getGuestToXsollaUserId";
		static private const COMPLETE_GUEST_TO_XSOLLA:String = "Imperium.completeGuestToXsollaUserId";

		static private var FBSharePvP_name:String                = "CodeString.FacebookSharePvP.Name";
		static private var FBSharePvP_description:String         = "CodeString.FacebookSharePvP.Description";
		static private var FBSharePvP_caption:String             = "CodeString.FacebookSharePvP.Caption";

		static private var FBSharePvB_name:String                = "CodeString.FacebookSharePvB.Name";
		static private var FBSharePvB_description:String         = "CodeString.FacebookSharePvB.Description";
		static private var FBSharePvB_caption:String             = "CodeString.FacebookSharePvB.Caption";

		static private var FBSharePlayRequest_description:String = "CodeString.FacebookSharePlayRequest.Message";
		static private var FBSharePlayRequest_title:String       = "CodeString.FacebookSharePlayRequest.Title";

		private static var _instance:ExternalInterfaceAPI;

		private var _assetModel:AssetModel;
		private var _settingsController:SettingsController;
		//private var _kongregateAPI:KongregateAPI;

		[PostConstruct]
		public function init():void
		{
			_instance = this;

			if (ExternalInterface.available)
			{
				ExternalInterface.addCallback("setBatteryStatus", Application.setBatteryStatus);
				ExternalInterface.addCallback("sharePlayRequest", sharePlayRequest);
				//ExternalInterface.addCallback("onKongregateItemsPurchased", _kongregateAPI.onKongregateItemsPurchased);

				onSwfLoaded();
				ExternalInterfaceAPI.logConsole("Imperium init ExternalAPI - success");
			}
			else
			{
				ExternalInterfaceAPI.logConsole("Imperium init ExternalAPI - failed");
			}
		}
		
		
		public static function logConsole(msg:String, caller:Object = null):void{
			var str:String = "";
			if(caller){
				str = getQualifiedClassName(caller);
				str += ":: ";
			}
			str += msg;
			trace(str);
			if(ExternalInterface.available){
				ExternalInterface.call("console.log", str);
			}
		}
		

		private function toggleFullscreen():void
		{
			if (Application.STAGE.displayState == StageDisplayState.FULL_SCREEN_INTERACTIVE)
				_settingsController.toggleFullScreen();
		}

		[Inject]
		public function set assetModel( v:AssetModel ):void  { _assetModel = v; }
		[Inject]
		public function set settingsController( v:SettingsController ):void  { _settingsController = v; }
		//[Inject]
		//public function set kongregateAPI( v:KongregateAPI ):void  { _kongregateAPI = v; }

		public static function onSwfLoaded():void
		{
			if (ExternalInterface.available)
				ExternalInterface.call(ON_SWF_LOADED);
		}
		public static function getFacebookUserId():String
		{
			if (!ExternalInterface.available)
				return null;
			return ExternalInterface.call(GET_FACEBOOK_USER_ID);
		}
		public static function getFacebookUserAccessToken():String
		{
			if (!ExternalInterface.available)
				return null;
			return ExternalInterface.call(GET_FACEBOOK_USER_ACCESS_TOKEN);
		}
		public static function GetFacebookItems():String
		{
			if (!ExternalInterface.available)
				return null;
			return ExternalInterface.call(GET_FACEBOOK_ITEMS);
		}
		public static function OpenFacebookPaywall(quantity:int):void
		{
			if (!ExternalInterface.available)
				return;
			ExternalInterface.call(OPEN_FACEBOOK_PAYWALL, quantity);
		}
		
		public static function getLoginProtocol():String
		{
			if (!ExternalInterface.available)
				return null;
			return ExternalInterface.call(GET_LOGIN_PROTOCOL);
		}

		public static function getLoginHostname():String
		{
			if (!ExternalInterface.available)
				return null;
			return ExternalInterface.call(GET_LOGIN_HOSTNAME);
		}

		public static function getLoginPort():int
		{
			if (!ExternalInterface.available)
				return 0;
			return ExternalInterface.call(GET_LOGIN_PORT);
		}
		
		public static function getPaymentProtocol():String
		{
			if (!ExternalInterface.available)
				return null;
			return ExternalInterface.call(GET_PAYMENT_PROTOCOL);
		}
		
		public static function getPaymentHostname():String
		{
			if (!ExternalInterface.available)
				return null;
			return ExternalInterface.call(GET_PAYMENT_HOSTNAME);
		}
		
		public static function getPaymentPort():int
		{
			if (!ExternalInterface.available)
				return 0;
			return ExternalInterface.call(GET_PAYMENT_PORT);
		}
		
		public static function openXsollaStore(token:String):int
		{
			if(CONFIG::IS_DESKTOP){
				var urlRequest:URLRequest = new URLRequest("https://secure.xsolla.com/paystation2/?access_token=" + token);
				navigateToURL(urlRequest);			
				return 1;
			}
			if (!ExternalInterface.available)
				return 0;
			return ExternalInterface.call(OPEN_XSOLLA_STORE, token);
		}

		public static function setPlayPlatform( num:int ):void
		{
			if (ExternalInterface.available)
				ExternalInterface.call(SET_PLAY_PLATFORM, num);
		}
		
		public static function reloadSWF():void
		{
			if(CONFIG::IS_DESKTOP){
				var NativeApplicationTypeDef:Object = getDefinitionByName("flash.desktop.NativeApplication");
				NativeApplicationTypeDef.nativeApplication.exit(0);
			}
			
			if (ExternalInterface.available)
				ExternalInterface.call(RELOAD_SWF);
		}

		public static function getBattleWebPath():String
		{
			if (!ExternalInterface.available)
				return null;
			return ExternalInterface.call(GET_BATTLE_WEB_PATH);
		}
		
		public static function refresh():void
		{
			if(CONFIG::IS_DESKTOP){
				var NativeApplicationTypeDef:Object = getDefinitionByName("flash.desktop.NativeApplication");
				NativeApplicationTypeDef.nativeApplication.exit(0);
			}
			
			if (ExternalInterface.available)
				ExternalInterface.call(ON_REFRESH);
		}
		
		public static function registerGuest():void
		{
			if (ExternalInterface.available)
				ExternalInterface.call(ON_REGISTER_GUEST);
		}
		
		public static function logOut():void
		{
			if (ExternalInterface.available)
				ExternalInterface.call(ON_LOG_OUT);
		}
		
		public static function popPixel( num:int ):void
		{
			if (ExternalInterface.available)
				ExternalInterface.call(POP_PIXEL, num);
		}

		public static function popPayWall():void
		{
			_instance.toggleFullscreen();

			if (ExternalInterface.available)
			{
				ExternalInterface.call(POP_PAYWALL, CurrentUser.naid, CurrentUser.oAuthID, CurrentUser.language);
			}
		}
		
		public static function getLocalizationFolder():String
		{
			if (!ExternalInterface.available)
				return "001_en";
			return ExternalInterface.call(GET_LOCALIZATION_FOLDER);
		}
		
		public static function getLocalizationVOFolder():String
		{
			if (!ExternalInterface.available)
				return "001_en";
			return ExternalInterface.call(GET_LOCALIZATION_VO_FOLDER);
		}
		
		public static function getMainFont():String
		{
			if (!ExternalInterface.available)
				return "Arial";
			return ExternalInterface.call(GET_MAIN_FONT);
		}
		public static function getTraceFont():String
		{
			if (!ExternalInterface.available)
				return "Verdana";
			return ExternalInterface.call(GET_TRACE_FONT);
		}
		public static function getFont(nr:int):String
		{
			if (!ExternalInterface.available)
				return (nr == 1) ? "Open Sans" : "Agency FB";
			return ExternalInterface.call(GET_FONT, nr);
		}
		
		public static function setLocalizationTag(tag:String):void
		{
			if (ExternalInterface.available)
			{	
				ExternalInterface.call(SET_LOCALIZATION_TAG, tag);
			}
		}
		public static function getLocalizationTag():String
		{
			if (!ExternalInterface.available)
				return "en";
			return ExternalInterface.call(GET_LOCALIZATION_TAG);
		}
		public static function getLanguageCode():String
		{
			if (!ExternalInterface.available)
				return "en";
			if(CONFIG::IS_DESKTOP){
				//return Imperium.language;
				return "en";
			}
			return ExternalInterface.call(GET_LANGUAGE_CODE);
		}
		public static function getCountryCode():String
		{
			if (!ExternalInterface.available)
				return "US";
			if(CONFIG::IS_DESKTOP){
				//return Imperium.country;
				return "US";
			}
			return ExternalInterface.call(GET_COUNTRY_CODE);
		}
		public static function getEntryTag():String
		{
			if (!ExternalInterface.available)
				return "";
			if(CONFIG::IS_DESKTOP){
				//return Imperium.entryTag;
				return "";
			}
			return ExternalInterface.call(GET_ENTRY_TAG);
		}
		
		public static function submitKongregateStat( name:String, value:int ):void
		{
			if (ExternalInterface.available)
			{
				ExternalInterface.call(SUBMIT_KONGREGATE_STAT, name, value);
			}
		}

		public static function purchaseKongregateItems( items:Array ):void
		{
			if (ExternalInterface.available)
			{
				ExternalInterface.call(PURCHASE_KONGREGATE_ITEMS, items);
			}
		}

		public static function getPlayerKongregateUserId():Number
		{
			if (!ExternalInterface.available)
				return 0;
			return ExternalInterface.call(GET_PLAYER_KONGREGATE_USER_ID);
		}

		public static function getPlayerKongregateUsername():String
		{
			if (!ExternalInterface.available)
				return null;
			return ExternalInterface.call(GET_PLAYER_KONGREGATE_USERNAME);
		}

		public static function getPlayerKongregateGameAuthToken():String
		{
			if (!ExternalInterface.available)
				return null;
			return ExternalInterface.call(GET_PLAYER_KONGREGATE_GAME_AUTH_TOKEN);
		}
		
		public static function getPlayerXsollaGameAuthToken():String
		{	
			if(CONFIG::IS_DESKTOP){
				return Imperium.authToken;
			}
			
			if (!ExternalInterface.available)
				return null;
			
			return ExternalInterface.call(GET_PLAYER_XSOLLA_GAME_AUTH_TOKEN);
		}
		
		public static function getSteamSessionTicket():String
		{
			if (!ExternalInterface.available)
				return null;
			return ExternalInterface.call(GET_STEAM_SESSION_TICKET);
		}
		
		public static function getGuestUserId():String
		{
			if (!ExternalInterface.available)
				return null;
			
			return ExternalInterface.call(GET_GUEST_USER_ID);
		}
		
		public static function getGuestToXsollaUserId():String
		{
			if (!ExternalInterface.available)
				return null;
			
			return ExternalInterface.call(GET_GUEST_TO_XSOLLA_USER_ID);
		}
		
		public static function completeGuestToXsolla():void
		{
			if (!ExternalInterface.available)
				return;
			
			ExternalInterface.call(COMPLETE_GUEST_TO_XSOLLA);
		}
		
		public static function setGuestUserId(id:String):void
		{
			if (!ExternalInterface.available)
				return;
			
			ExternalInterface.call(SET_GUEST_USER_ID, id);
		}

		public static function sharePlayRequest():void
		{
			if (ExternalInterface.available)
			{
				_instance.toggleFullscreen();
				var localizationObj:Dictionary = new Dictionary();
				localizationObj["[[String.PlayerFaction]]"] = CurrentUser.faction;

				if (Application.NETWORK == Application.NETWORK_FACEBOOK)
				{
					var og:OpenGraphShareObject = new OpenGraphShareObject();
					og.description = Localization.instance.getStringWithTokens(FBSharePlayRequest_description, localizationObj);
					og.title = Localization.instance.getString(FBSharePlayRequest_title);

					ExternalInterface.call(SHARE_PLAY_REQUEST + "_facebook", og);
				}
			}
		}

		public static function shareVictory( enemyPlayer:PlayerVO, isBaseCombat:Boolean ):void
		{
			if (ExternalInterface.available)
			{
				_instance.toggleFullscreen();
				var localizationObj:Dictionary = new Dictionary();
				localizationObj["[[String.PlayerName]]"] = CurrentUser.name;
				localizationObj["[[String.PlayerFaction]]"] = CurrentUser.faction;
				localizationObj["[[String.EnemyName]]"] = enemyPlayer.name;
				localizationObj["[[String.EnemyFaction]]"] = enemyPlayer.faction;

				if (Application.NETWORK == Application.NETWORK_FACEBOOK || true)
				{
					var assetPrefix:String;

					if (Application.ASSET_PATH != "" && Application.ASSET_PATH.indexOf('localhost') == -1)
						assetPrefix = Application.ASSET_PATH + "assets/";
					else
						assetPrefix = "http://oddalchemy.com/kabam/";

					var og:OpenGraphShareObject = new OpenGraphShareObject();
					og.type = OpenGraphShareObject.ACTION_DEFEAT;
					og.title = enemyPlayer.name;

					if (isBaseCombat)
					{
						og.name = Localization.instance.getStringWithTokens(FBSharePvB_name, localizationObj);
						og.description = Localization.instance.getStringWithTokens(FBSharePvB_description, localizationObj);
						og.caption = Localization.instance.getString(FBSharePvB_caption);
						og.image = assetPrefix + getSocialImage("BaseCombat");
					} else
					{
						og.name = Localization.instance.getStringWithTokens(FBSharePvP_name, localizationObj);
						og.description = Localization.instance.getStringWithTokens(FBSharePvP_description, localizationObj);
						og.caption = Localization.instance.getString(FBSharePvP_caption);
						og.image = assetPrefix + getSocialImage("PVPCombat");
					}

					ExternalInterface.call(SHARE_PvP_VICTORY + "_facebook", og);
				}
			}
		}

		public static function shareTransaction( type:String, prototype:IPrototype ):void
		{
			if (ExternalInterface.available)
			{
				if (Application.NETWORK == Application.NETWORK_FACEBOOK)
				{
					var asset:AssetVO = AssetModel.instance.getEntityData(prototype.uiAsset);
					if (asset)
					{
						var og:OpenGraphShareObject = new OpenGraphShareObject();
						og.type = resolveTransactionType_facebook(type);
						og.title = resolveTransactionTitle(type, prototype, asset);
						if (Application.ASSET_PATH != "" && Application.ASSET_PATH.indexOf('localhost') == -1)
							og.image = Application.ASSET_PATH + "assets/" + getSocialImage(type);
						else
							og.image = "http://oddalchemy.com/kabam/" + getSocialImage(type);
						og.description = Localization.instance.getString(asset.descriptionText);
						ExternalInterface.call(SHARE_TRANSACTION + "_facebook", og);
					}
				}
			}
		}

		static private function resolveTransactionType_facebook( input:String ):String
		{
			var out:String;

			switch (input)
			{
				case TransactionEvent.STARBASE_BUILDING_BUILD:
				case TransactionEvent.STARBASE_BUILD_SHIP:
				{
					out = OpenGraphShareObject.ACTION_BUILD;
					break;
				}

				case TransactionEvent.STARBASE_REFIT_BUILDING:
				case TransactionEvent.STARBASE_REFIT_SHIP:
				{
					out = OpenGraphShareObject.ACTION_REFIT;
					break;
				}

				case TransactionEvent.STARBASE_RESEARCH:
				{
					out = OpenGraphShareObject.ACTION_RESEARCH;
					break;
				}

				case TransactionEvent.STARBASE_BUILDING_UPGRADE:
				default:
				{
					out = OpenGraphShareObject.ACTION_UPGRADE;
					break;
				}
			}

			return out;
		}

		static private function resolveTransactionTitle( type:String, prototype:IPrototype, asset:AssetVO ):String
		{
			var out:String;
			var localizationObj:Dictionary = new Dictionary();
			switch (type)
			{
				case TransactionEvent.STARBASE_BUILDING_BUILD:
				case TransactionEvent.STARBASE_BUILD_SHIP:
				case TransactionEvent.STARBASE_REFIT_SHIP:
				case TransactionEvent.STARBASE_REFIT_BUILDING:
					return Localization.instance.getString(asset.visibleName);
				case TransactionEvent.STARBASE_RESEARCH:
					out = "CodeString.FacebookShareResearch.Title";
					localizationObj["[[String.ItemName]]"] = Localization.instance.getString(asset.visibleName);
					localizationObj["[[String.Level]]"] = prototype.getUnsafeValue("level");
					break;
				case TransactionEvent.STARBASE_BUILDING_UPGRADE:
					out = "CodeString.FacebookShareUpgrade.Title";
					localizationObj["[[String.ItemName]]"] = Localization.instance.getString(asset.visibleName);
					localizationObj["[[String.Level]]"] = prototype.getUnsafeValue("level");
					break;
			}

			if (out)
				out = Localization.instance.getStringWithTokens(out, localizationObj);

			return out;
		}

		static public function shareLevelUp( charName:String, lvl:int, isBaseLevel:Boolean ):void
		{
			if (ExternalInterface.available)
			{
				if (Application.NETWORK == Application.NETWORK_FACEBOOK)
				{
					var og:OpenGraphShareObject    = new OpenGraphShareObject();
					og.type = OpenGraphShareObject.ACTION_LEVELUP;
					og.title = charName;
					og.level = String(lvl);
					//get the image
					if (Application.ASSET_PATH != "" && Application.ASSET_PATH.indexOf('localhost') == -1)
						og.image = Application.ASSET_PATH + "assets/" + ((isBaseLevel) ? getSocialImage("BaseLevelup") : getSocialImage("Levelup"));
					else
						og.image = "http://oddalchemy.com/kabam/" + ((isBaseLevel) ? getSocialImage("BaseLevelup") : getSocialImage("Levelup"));
					//localize
					var localizationObj:Dictionary = new Dictionary();
					localizationObj["[[String.PlayerName]]"] = CurrentUser.name;
					localizationObj["[[String.Level]]"] = lvl;
					og.description = Localization.instance.getStringWithTokens(isBaseLevel ? "CodeString.FacebookShareBaseLevelup" : "CodeString.FacebookShareLevelup", localizationObj);
					ExternalInterface.call(SHARE_USER_LEVEL_UP + "_facebook", og);
				}
			}
		}

		static public function shareAllianceJoin():void
		{
			if (ExternalInterface.available)
			{
				if (Application.NETWORK == Application.NETWORK_FACEBOOK)
				{
					var og:OpenGraphShareObject    = new OpenGraphShareObject();
					og.type = OpenGraphShareObject.ACTION_JOIN;
					og.title = "Alliance";
					if (Application.ASSET_PATH != "" && Application.ASSET_PATH.indexOf('localhost') == -1)
						og.image = Application.ASSET_PATH + "assets/" + getSocialImage("Alliance");
					else
						og.image = "http://oddalchemy.com/kabam/" + getSocialImage("Alliance");
					//localize
					var localizationObj:Dictionary = new Dictionary();
					localizationObj["[[String.PlayerName]]"] = CurrentUser.name;
					localizationObj["[[String.AllianceName]]"] = CurrentUser.allianceName;
					og.description = Localization.instance.getStringWithTokens("CodeString.FacebookShareAlliance", localizationObj);
					ExternalInterface.call(SHARE_TRANSACTION + "_facebook", og);
				}
			}
		}

		static public function shareBlueprintFind( blueprint:IPrototype ):void
		{
			if (ExternalInterface.available)
			{
				if (Application.NETWORK == Application.NETWORK_FACEBOOK)
				{
					var asset:AssetVO = AssetModel.instance.getEntityData(blueprint.uiAsset);
					if (asset)
					{
						var og:OpenGraphShareObject    = new OpenGraphShareObject();
						og.type = OpenGraphShareObject.ACTION_FIND;
						og.title = Localization.instance.getString(asset.visibleName);
						if (Application.ASSET_PATH != "" && Application.ASSET_PATH.indexOf('localhost') == -1)
							og.image = Application.ASSET_PATH + "assets/" + getSocialImage("Blueprint", blueprint);
						else
							og.image = "http://oddalchemy.com/kabam/" + getSocialImage("Blueprint", blueprint);
						//localize
						var localizationObj:Dictionary = new Dictionary();
						localizationObj["[[String.PlayerName]]"] = CurrentUser.name;
						og.description = Localization.instance.getStringWithTokens("CodeString.FacebookShareBlueprints", localizationObj);
						ExternalInterface.call(SHARE_TRANSACTION + "_facebook", og);
					}
				}
			}
		}

		static private function getSocialImage( type:String, proto:IPrototype = null ):String
		{
			var img:String = "social/";
			switch (type)
			{
				case TransactionEvent.STARBASE_BUILDING_BUILD:
				case TransactionEvent.STARBASE_BUILDING_UPGRADE:
				case TransactionEvent.STARBASE_REFIT_BUILDING:
					img += "BuildingComplete.png";
					break;

				case TransactionEvent.STARBASE_REFIT_SHIP:
					img += "ShipRefit.png";
					break;

				case TransactionEvent.STARBASE_BUILD_SHIP:
					img += "ShipResearchComplete.png";
					break;

				case TransactionEvent.STARBASE_RESEARCH:
					img += (proto) ? "ShipResearchComplete.png" : "ResearchNewTech.png";
					break;

				case "Alliance":
					img += "Leaderboard_Acc.png";
					break;

				case "BaseLevelup":
					img += "BaseRating.png";
					break;
				case "Levelup":
					img += "Milestone_UserLevels.png";
					break;

				case "BaseCombat":
					img += "Destroyed_Tyr_Base.png";
					break;
				case "PVPCombat":
					img += "WonPVPMatch.png";
					break;

				case "Blueprint":
					var rarity:String = proto.getValue('rarity');
					if (rarity == 'Uncommon')
						img += "Blueprint_Uncommon.png";
					else if (rarity == 'Rare')
						img += "Blueprint_Rare.png";
					else if (rarity == 'Epic')
						img += "Blueprint_Epic.png";
					else if (rarity == 'Legendary')
						img += "Blueprint_Legendary.png";
					else
						img += "Blueprint_Advanced.png";
					break;
			}
			return img;
		}


	}
}

