package com.presenter.preload
{
	import com.Application;
	import com.controller.ServerController;
	import com.enum.server.ProtocolEnum;
	import com.enum.server.RequestEnum;
	import com.event.ServerEvent;
	import com.event.StateEvent;
	import com.event.TransitionEvent;
	import com.model.asset.AssetModel;
	import com.model.asset.AssetVO;
	import com.model.player.CurrentUser;
	import com.model.prototype.IPrototype;
	import com.model.prototype.PrototypeModel;
	import com.model.starbase.StarbaseModel;
	import com.presenter.ImperiumPresenter;
	import com.service.loading.ILoadService;
	import com.service.loading.LoadService;
	import com.service.server.outgoing.proxy.ProxyTutorialStepCompletedMessage;
	import com.service.server.outgoing.universe.UniverseCreateCharacterRequest;

	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.text.Font;
	import flash.utils.getDefinitionByName;

	import org.as3commons.logging.api.ILogger;
	import org.as3commons.logging.api.getLogger;
	import org.osflash.signals.Signal;
	import org.parade.enum.PlatformEnum;
	import org.parade.util.DeviceMetrics;

	public class PreloadPresenter extends ImperiumPresenter implements IPreloadPresenter
	{
		public static var complete:Boolean       = false;

		private static var _masterLoaded:Boolean = false;

		private const _logger:ILogger            = getLogger('PreloadPresenter');

		private var _assetModel:AssetModel;
		private var _beginSignal:Signal;
		private var _completeSignal:Signal;
		private var _loadCompleteSignal:Signal;
		private var _loadService:ILoadService;
		private var _progressSignal:Signal;
		private var _prototypeModel:PrototypeModel;
		private var _serverController:ServerController;
		private var _starbaseModel:StarbaseModel;

		[PostConstruct]
		override public function init():void
		{
			super.init();
			_beginSignal = new Signal(int);
			_completeSignal = new Signal();
			_loadCompleteSignal = new Signal();
			_progressSignal = new Signal(int, int);
		}

		public function beginLoad():void
		{
			_eventMap.mapListener(_eventDispatcher, ProgressEvent.PROGRESS, onProgress, ProgressEvent, false, 0, true);
			_eventMap.mapListener(_eventDispatcher, LoadService.ALL_COMPLETE, onLoadComplete, Event, false, 0, true);

			if (DeviceMetrics.PLATFORM == PlatformEnum.BROWSER)
				_loadService.lazyLoad('LoadMaster.xml');
			else
				_loadService.lazyLoad('LoadMobileMaster.xml');
		}

		public function trackPlayerProgress( id:int ):void
		{
			var msg:ProxyTutorialStepCompletedMessage = ProxyTutorialStepCompletedMessage(_serverController.getRequest(ProtocolEnum.PROXY_CLIENT, RequestEnum.PROXY_TUTORIAL_STEP_COMPLETED));
			msg.stepId = id;
			msg.kabamNaid = CurrentUser.naid;
			_serverController.send(msg);
		}

		private function preloadFromMaster():void
		{
			var xml:XMLList;
			if (DeviceMetrics.PLATFORM == PlatformEnum.BROWSER)
				xml = XML(_assetModel.getFromCache('LoadMaster.xml')).children();
			else
				xml = XML(_assetModel.getFromCache('LoadMobileMaster.xml')).children();

			var nodes:XMLList;
			for (var i:int = 0; i < xml.length(); i++)
			{
				nodes = xml[i].children();
				for (var j:int = 0; j < nodes.length(); j++)
				{
					_loadService.lazyLoad(nodes[j]);
				}
			}

			_beginSignal.dispatch(xml.length());
		}

		private function onProgress( e:ProgressEvent ):void
		{
			if (_masterLoaded)
				_progressSignal.dispatch(e.bytesLoaded, e.bytesTotal);
		}

		private function onLoadComplete( e:Event ):void
		{
			if (_masterLoaded)
			{
				var xml:XMLList = (DeviceMetrics.PLATFORM == PlatformEnum.BROWSER) ? XML(_assetModel.getFromCache('LoadMaster.xml')).children() : XML(_assetModel.getFromCache('LoadMobileMaster.xml')).
					children();
				var name:String;

				if (DeviceMetrics.PLATFORM == PlatformEnum.MOBILE)
				{
					Font.registerFont(Class(getDefinitionByName('Agency')));
					Font.registerFont(Class(getDefinitionByName('AgencyBold')));
					Font.registerFont(Class(getDefinitionByName('OpenSansBold')));
					Font.registerFont(Class(getDefinitionByName('OpenSansRegular')));
				} else
				{
					for (var i:int = 0; i < xml.length(); i++)
					{
						name = xml[i].name();
						switch (name)
						{
							case 'fonts':
								registerFonts(xml[i]);
								break;
						}
					}
				}

				//remove the xml file from memory
				if (DeviceMetrics.PLATFORM == PlatformEnum.BROWSER)
					_assetModel.removeFromCache('LoadMaster.xml');
				else
					_assetModel.removeFromCache('LoadMobileMaster.xml');

				_progressSignal.removeAll();
				_loadCompleteSignal.dispatch();

				_eventMap.unmapListener(_eventDispatcher, ProgressEvent.PROGRESS, onProgress, ProgressEvent);
				_eventMap.unmapListener(_eventDispatcher, LoadService.ALL_COMPLETE, onLoadComplete, Event);
			} else if (!_masterLoaded)
			{
				_masterLoaded = true;
				preloadFromMaster();
			}
		}

		public function transitionToLoad():void
		{
			_loadService.reset();
			complete = true;
			var stateEvent:StateEvent;
			if (Application.CONNECTION_STATE == ServerEvent.NEED_CHARACTER_CREATE)
				stateEvent = new StateEvent(StateEvent.CREATE_CHARACTER);
			var transitionEvent:TransitionEvent = new TransitionEvent(TransitionEvent.TRANSITION_BEGIN);
			transitionEvent.addEvents(stateEvent, new StateEvent(StateEvent.PRELOAD_COMPLETE));
			dispatch(transitionEvent);

			if (Application.CONNECTION_STATE == ServerEvent.NOT_CONNECTED)
				dispatch(new ServerEvent(ServerEvent.CONNECT_TO_PROXY));
		}

		public function sendCharacterToServer( factionPrototype:String, racePrototype:String ):void
		{
			var transitionEvent:TransitionEvent                       = new TransitionEvent(TransitionEvent.TRANSITION_BEGIN);
			transitionEvent.addEvents(null, null);
			dispatch(transitionEvent);

			var createCharacterRequest:UniverseCreateCharacterRequest = UniverseCreateCharacterRequest(_serverController.getRequest(ProtocolEnum.UNIVERSE_CLIENT, RequestEnum.UNIVERSE_CHARACTER_CREATION_REQUEST));
			createCharacterRequest.factionPrototype = factionPrototype;
			createCharacterRequest.racePrototype = racePrototype;
			createCharacterRequest.name = CurrentUser.name;
			_serverController.send(createCharacterRequest);
		}

		public function getRacePrototypesByFaction( faction:String, race:String ):Vector.<IPrototype>
		{
			return _prototypeModel.getRacePrototypesByFaction(faction, race);
		}

		public function getRacePrototypeByName( race:String ):IPrototype
		{
			return _prototypeModel.getRacePrototypeByName(race);
		}

		public function getFirstNameOptions( race:String, gender:String ):Vector.<IPrototype>
		{
			return _prototypeModel.getFirstNameOptions(race, gender);
		}

		public function getLastNameOptions( race:String, gender:String ):Vector.<IPrototype>
		{
			return _prototypeModel.getLastNameOptions(race, gender);
		}

		public function getAudioProtos():Vector.<IPrototype>
		{
			return _assetModel.getAudioProtos();
		}

		public function getEntityData( type:String ):AssetVO
		{
			return _assetModel.getEntityData(type);
		}

		public function addLoadCompleteListener( callback:Function ):void  { _loadCompleteSignal.add(callback); }
		public function removeLoadCompleteListener( callback:Function ):void  { _loadCompleteSignal.remove(callback); }

		/**
		 * Take the fonts that were loaded in and register them for use
		 * @param node xml list of the fonts
		 */
		private function registerFonts( node:XML ):void
		{
			var fontNames:Array = node.@names.split(",");
			for (var i:int = 0; i < fontNames.length; i++)
			{
				Font.registerFont(Class(getDefinitionByName(fontNames[i])));
			}
		}

		public function loadPortraitIcon( portraitName:String, callback:Function ):void
		{
			var avatarVO:AssetVO = AssetVO(_assetModel.getFromCache(portraitName));
			_assetModel.getFromCache('assets/' + avatarVO.iconImage, callback);
		}

		public function loadPortraitLarge( portraitName:String, callback:Function ):void
		{
			var avatarVO:AssetVO = AssetVO(_assetModel.getFromCache(portraitName));
			_assetModel.getFromCache('assets/' + avatarVO.largeImage, callback);
		}

		[Inject]
		public function set assetModel( v:AssetModel ):void  { _assetModel = v; }

		public function get beginSignal():Signal  { return _beginSignal; }
		public function get completeSignal():Signal  { return _completeSignal; }
		[Inject]
		public function set loadService( v:ILoadService ):void  { _loadService = v; }
		public function get progressSignal():Signal  { return _progressSignal; }
		[Inject]
		public function set prototypeModel( v:PrototypeModel ):void  { _prototypeModel = v; }
		[Inject]
		public function set serverController( v:ServerController ):void  { _serverController = v; }
		[Inject]
		public function set starbaseModel( v:StarbaseModel ):void  { _starbaseModel = v; }

		override public function destroy():void
		{
			super.destroy();
			_loadService = null;
			_serverController = null;
			_beginSignal.removeAll();
			_beginSignal = null;
			_completeSignal.removeAll();
			_completeSignal = null;
			_loadCompleteSignal.removeAll();
			_loadCompleteSignal = null;
			_progressSignal.removeAll();
			_progressSignal = null;
			_prototypeModel = null;
			_starbaseModel = null;
		}
	}
}
