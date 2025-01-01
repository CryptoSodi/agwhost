package com.service.language
{
	import com.Application;
	import com.controller.ChatController;
	import com.event.LoadEvent;
	import com.model.asset.AssetModel;
	import com.service.loading.LoadPriority;
	
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.net.SharedObject;
	import flash.utils.Dictionary;
	
	import org.as3commons.logging.api.ILogger;
	import org.as3commons.logging.api.getLogger;
	import org.osflash.signals.Signal;

	import com.service.ExternalInterfaceAPI;
	public class Localization
	{

		public static var loaded:Boolean            = false;
		public static var instance:Localization;

		[Inject]
		public var assetModel:AssetModel;
		[Inject]
		public var chatController:ChatController;
		[Inject]
		public var eventDispatcher:IEventDispatcher;

		public var onLoadFinished:Signal;

		private var _defaultFallbackLanguage:String = 'en';
		private var _language:String;
		private var _loadingURL:String              = 'data/localization/001_en.txt';
		private var _stageWebserviceUrl:String      = 'http://xlate-stage.kabam.com/index.php';
		private var _strings:Dictionary;
		private var _webserviceUrl:String           = 'http://xlate.kabam.com/index.php';
		public static var _languageEn:Boolean = false;
		public static var _languageFr:Boolean = false;
		public static var _languageEs:Boolean = false;
		public static var _languageDe:Boolean = false;
		public static var _languageIt:Boolean = false;
		public static var _languagePl:Boolean = false;
		private const _logger:ILogger               = getLogger('LocalizationManager');

		public function Localization()
		{
			instance = this;
			_strings = new Dictionary();
			onLoadFinished = new Signal();
		}
		
		
		private static var so:SharedObject = SharedObject.getLocal("IGWDATA");
		
		//Toggle Language Function
		public static function toggleLanguage( v:String ):void
		{
			
			//Save Language
			switch (v){
				
				case "en":
					so.data.language = "en"
					break;
				
				case "fr":
					so.data.language = "fr"
					break;
				
				case "es":
					so.data.language = "es"
					break;
				
				case "de":
					so.data.language = "de"
					break;
				
				case "it":
					so.data.language = "it"
					break;
				
				case "pl":
					so.data.language = "pl"
					break;
				
			}
			ExternalInterfaceAPI.setLocalizationTag(v);
			ExternalInterfaceAPI.reloadSWF();
		}
		
		
		public function load( key:String = '', language:String = '' ):void
		{
			ExternalInterfaceAPI.logConsole("Language Tag: " + language);
			var path:String = key;
			_language = language;
			if (language != '' && language != null)
				path += '_' + language;
			else
				path += '_' + _defaultFallbackLanguage;
			/*
			   if (Application.ASSET_PATH != null && Application.ASSET_PATH != '')
			   assetModel.getFromCache('xlate/' + path, onWebLoaded, LoadPriority.IMMEDIATE);
			   else
			 */

			// Onload download language files & set languageID to true
			// Default English
			_loadingURL = "data/localization/" + ExternalInterfaceAPI.getLocalizationFolder() + ".txt";
			
			
			ExternalInterfaceAPI.logConsole("Language Folder: " + _loadingURL);
			
			assetModel.getFromCache(_loadingURL, onloaded, LoadPriority.IMMEDIATE);
		}

		public function onloaded( data:Object ):void
		{
			var strings:Array = data.locStrings;
			var len:uint      = strings.length;
			for (var i:uint = 0; i < len; ++i)
			{
				addString(strings[i].trans, strings[i].phrase);
			}

			chatController.initStrings();
			loaded = true;
			onLoadFinished.dispatch();
			eventDispatcher.dispatchEvent(new Event(LoadEvent.LOCALIZATION_COMPLETE));
		}

		public function onWebLoaded( data:Array ):void
		{
			if (data && data.length > 0)
			{
				for each (var locEntry:Object in data)
				{
					addString(locEntry.trans, locEntry.phrase);
				}

				chatController.initStrings();
				loaded = true;
				onLoadFinished.dispatch();
				eventDispatcher.dispatchEvent(new Event(LoadEvent.LOCALIZATION_COMPLETE));
			} else
				assetModel.getFromCache(_loadingURL, onloaded, LoadPriority.IMMEDIATE);
		}

		private function addString( stringToAdd:String, key:String ):void
		{
			_strings[key] = stringToAdd;
		}

		public function getString( key:String ):String
		{
			var foundString:String;
			if (key != "")
			{
				foundString = _strings[key];
				if (foundString == null)
				{
					foundString = '';
				}
			} else
				foundString = key;

			return foundString;
		}

		public function getStringWithTokens( key:String, tokens:Object ):String
		{
			var foundString:String;
			if (key != "")
			{
				foundString = _strings[key];
				if (foundString != null)
				{
					foundString = localizeStringWithTokens(foundString, tokens);
				} else
				{
					foundString = '';
				}
			} else
				foundString = key;

			return foundString;
		}

		public function localizeStringWithTokens( stringWithSubs:String, tokens:Object ):String
		{
			var tokenString:String;
			for (var key:String in tokens)
			{

				tokenString = getString(tokens[key]);
				if (tokenString == '')
					tokenString = tokens[key];

				stringWithSubs = stringWithSubs.split(key).join(tokenString);
			}
			return stringWithSubs;
		}
		

	}
}
