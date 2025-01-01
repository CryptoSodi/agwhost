package com.service.loading.loaditems
{

	import com.enum.TimeLogEnum;
	import com.service.loading.LoadingTypes;
	import com.service.loading.URL;
	import com.util.TimeLog;
	import com.util.priorityqueue.IPrioritizable;
	
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.media.Sound;
	import flash.net.URLLoader;
	import flash.system.ApplicationDomain;
	import flash.utils.getTimer;
	
	import org.osflash.signals.Signal;

	public class LoadItem extends EventDispatcher implements ILoadItem, IPrioritizable
	{
		////////////////////////////////////////////////////////////
		//   CONSTANTS 
		////////////////////////////////////////////////////////////

		public static const CANCEL:String    = "cancel";

		public static const COMPLETE:String  = "complete";

		public static const START:String     = "start";

		public static const ERROR:String     = "error";

		public static const PROGRESS:String  = "progress";

		public static const MAX_RETRIES:uint = 3;

		////////////////////////////////////////////////////////////
		//   ATTRIBUTES 
		////////////////////////////////////////////////////////////

		protected var _absoluteURL:Boolean;
		protected var _applicationDomain:ApplicationDomain;
		protected var _asset:Object;
		protected var _loaded:Boolean;
		protected var _loadStartTime:int;
		protected var _priority:int;
		protected var _retries:int;
		protected var _tracked:Boolean;
		protected var _type:int;
		protected var _updateSignal:Signal;
		protected var _url:URL;
		protected var _totalBytes:int;
		protected var _totalBytesLoaded:int;
		protected var _totalBytesLoadedLastFrame:int;

		////////////////////////////////////////////////////////////
		//   CONSTRUCTOR 
		////////////////////////////////////////////////////////////

		public function LoadItem( url:String, type:int, priority:int = int.MAX_VALUE, absolute:Boolean = false )
		{
			_absoluteURL = absolute;
			_loaded = false;
			_priority = priority;
			_retries = 0;
			_totalBytes = 0;
			_totalBytesLoaded = 0;
			_totalBytesLoadedLastFrame = 0;
			_tracked = false;
			_type = type;
			_updateSignal = new Signal(String, ILoadItem);
			_url = new URL(url);
		}

		////////////////////////////////////////////////////////////
		//   PUBLIC API 
		////////////////////////////////////////////////////////////

		public function cancel():void
		{
			throw new Error("LoadItem.cancel() should be implemented by a subclass");
		}

		public function destroy():void
		{
			_url = null;
			_asset = null;
			_updateSignal.removeAll();
			_updateSignal = null;
		}

		public function load():void
		{
			throw new Error("LoadItem.load() should be implemented by a subclass");
		}

		public function addUpdateListener( callback:Function ):void
		{
			_updateSignal.add(callback);
		}

		public function removeUpdateListener( callback:Function ):void
		{
			_updateSignal.remove(callback);
		}

		////////////////////////////////////////////////////////////
		//   PROTECTED METHODS 
		////////////////////////////////////////////////////////////

		protected function onLoadComplete( event:Event ):void
		{
			var loader:Object = event.target;
			_loaded = true;

			if (loader is LoaderInfo)
			{
				this.asset = LoaderInfo(loader).content;
			} else if (loader is Sound)
			{
				this.asset = loader;
			} else if (loader is URLLoader)
			{
				this.asset = URLLoader(loader).data;
			}

			_updateSignal.dispatch(COMPLETE, this);
		}

		protected function onLoadIOError( event:IOErrorEvent ):void
		{
			_retries++;
			if (_retries < MAX_RETRIES)
				load();
			else
				_updateSignal.dispatch(ERROR + event.text, this);
		}

		protected function onHTTPStatusError( event:HTTPStatusEvent ):void
		{
			_retries++;
			if (_retries < MAX_RETRIES)
				load();
			else
				_updateSignal.dispatch(ERROR, this);
		}

		protected function onLoadProgress( event:Event ):void
		{
			if (_totalBytes == 0)
				_totalBytes = ProgressEvent(event).bytesTotal;
			_totalBytesLoadedLastFrame = ProgressEvent(event).bytesLoaded - _totalBytesLoaded;
			_totalBytesLoaded = ProgressEvent(event).bytesLoaded;
			_updateSignal.dispatch(PROGRESS, this);
		}

		protected function onLoadStart( event:Event ):void
		{
			_updateSignal.dispatch(START, this);
			if (_type != LoadingTypes.SPRITE_SHEET || type != LoadingTypes.SPRITE_SHEET_MESH)
			{
				TimeLog.startTimeLog(TimeLogEnum.FILE_LOAD, _url.baseUrl);
				_loadStartTime = getTimer();
			}
		}

		////////////////////////////////////////////////////////////
		//   GETTERS / SETTERS 
		////////////////////////////////////////////////////////////

		public function get absoluteURL():Boolean
		{
			return _absoluteURL;
		}

		public function get applicationDomain():ApplicationDomain
		{
			return _applicationDomain;
		}

		public function get asset():Object
		{
			return _asset;
		}

		public function set asset( value:Object ):void
		{
			_asset = value;
		}

		public function get filename():String
		{
			return _url.filename;
		}

		public function get loaded():Boolean
		{
			return _loaded;
		}

		public function set prefix( v:String ):void
		{
			_url.prefix = v;
		}

		public function get priority():int
		{
			return _priority;
		}

		public function get progress():Number
		{
			throw new Error("LoadItem.get progress() should be implemented by a subclass");
		}

		public function get type():int  { return _type; }

		public function get url():String
		{
			var query:String = _url.queryString;
			if( query == '' )
			{
				return _url.baseUrl;
			}
			else
			{
				return _url.baseUrl + "?" + _url.queryString;
			}			
		}

		public function get fullPath():String
		{
			return _url.toString();
		}

		public function get loadStartTime():int
		{
			return _loadStartTime;
		}

		public function get totalBytes():int  { return _totalBytes; }
		public function get totalBytesLoaded():int  { return _totalBytesLoaded; }
		public function get totalBytesLoadedLastFrame():int  { return _totalBytesLoadedLastFrame; }

		public function get tracked():Boolean  { return _tracked; }
		public function set tracked( v:Boolean ):void  { _tracked = v; }
	}
}
