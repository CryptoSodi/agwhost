package com.presenter.shared
{
	import com.Application;
	import com.event.LoadEvent;
	import com.event.ServerEvent;
	import com.event.StateEvent;
	import com.presenter.ImperiumPresenter;
	import com.service.language.Localization;
	import com.service.loading.ILoadService;

	import flash.events.Event;

	import org.osflash.signals.Signal;

	public class TransitionPresenter extends ImperiumPresenter implements ITransitionPresenter
	{
		private var _cleanupEvent:StateEvent;
		private var _completeSignal:Signal;
		private var _initEvent:StateEvent;
		private var _loadService:ILoadService;
		private var _updateSignal:Signal;
		private var _failed:Boolean;

		private var _creatingCharacter:String    = 'CodeString.TransitionEvent.CreatingCharacter'; //Creating Character...
		private var _connectingToProxy:String    = 'CodeString.TransitionEvent.ConnectingToProxy'; //Connecting To Proxy...
		private var _loggingIntoAccount:String   = 'CodeString.TransitionEvent.LoggingIntoAccount'; //logging into account...
		private var _connectingToBattle:String   = 'CodeString.TransitionEvent.ConnectingToBattle'; //Connecting To Battle...
		private var _connectingToSector:String   = 'CodeString.TransitionEvent.ConnectingToSector'; //Connecting To Sector...
		private var _connectingToStarbase:String = 'CodeString.TransitionEvent.ConnectingToStarbase'; //Connecting To Starbase...

		[PostConstruct]
		override public function init():void
		{
			_eventDispatcher.addEventListener(LoadEvent.LOCALIZATION_COMPLETE, onLocalizationComplete);
			super.init();
			if (!_completeSignal)
				_completeSignal = new Signal();
			if (!_updateSignal)
				_updateSignal = new Signal();
		}

		public function sendEvents():void
		{
			if (_cleanupEvent)
				dispatch(_cleanupEvent);
			if (_initEvent)
				dispatch(_initEvent);
		}

		public function addEvents( initEvent:StateEvent, cleanupEvent:StateEvent ):void
		{
			_initEvent = initEvent;
			_cleanupEvent = cleanupEvent;
		}

		public function transitionComplete():void  { _completeSignal.dispatch(); }

		public function addCompleteListener( callback:Function ):void  { _completeSignal.add(callback); }
		public function removeCompleteListener( callback:Function ):void  { _completeSignal.remove(callback); }

		public function addUpdateListener( callback:Function ):void  { _updateSignal.add(callback); }
		public function removeUpdateListener( callback:Function ):void  { _updateSignal.remove(callback); }
		public function updateView():void  { _updateSignal.dispatch(); }

		private function onLocalizationComplete( e:Event ):void  { _updateSignal.dispatch(); }

		public function get connectingText():String
		{
			if (!Localization.loaded)
				return "...";
			else if (Application.CONNECTION_STATE == ServerEvent.CONNECT_TO_PROXY)
				return _connectingToProxy;
			else if (Application.CONNECTION_STATE == ServerEvent.LOGIN_TO_ACCOUNT)
				return _loggingIntoAccount;
			else if (_initEvent == null)
				return "...";
			else if (_initEvent.type == StateEvent.GAME_BATTLE_INIT || _initEvent.type == StateEvent.GAME_BATTLE)
				return _connectingToBattle;
			else if (_initEvent.type == StateEvent.GAME_SECTOR_INIT || _initEvent.type == StateEvent.GAME_SECTOR)
				return _connectingToSector;
			return _connectingToStarbase;
		}

		public function get estimatedLoadCompleted():Number  { return _loadService.estimatedLoadCompleted; }

		public function set failed( v:Boolean ):void  { _failed = v; _updateSignal.dispatch()}
		public function get failed():Boolean  { return _failed; }

		public function get trackAnalytics():Boolean
		{
			if (_initEvent == null) // || _initEvent.type == StateEvent.CONNECTING_TO_PROXY || _initEvent.type == StateEvent.LOGGING_INTO_ACCOUNT)
				return false;
			return true;
		}

		public function get hasWaiting():Boolean  { return _loadService.highPrioritiesInProgress > 0; }

		[Inject]
		public function set loadService( v:ILoadService ):void  { _loadService = v; }

		override public function destroy():void
		{
			_eventDispatcher.removeEventListener(LoadEvent.LOCALIZATION_COMPLETE, onLocalizationComplete);
			super.destroy();
			_completeSignal.removeAll();
			_completeSignal = null;
			_cleanupEvent = _initEvent = null;
			_loadService.reset();
			_loadService = null;
		}

	}
}
