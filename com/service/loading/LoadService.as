package com.service.loading
{

	import com.Application;
	import com.enum.TimeLogEnum;
	import com.event.LoadEvent;
	import com.service.loading.loaditems.BatchLoadItem;
	import com.service.loading.loaditems.ILoadItem;
	import com.service.loading.loaditems.LoadItem;
	import com.service.loading.loaditems.LoaderLoadItem;
	import com.service.loading.loaditems.SoundLoadItem;
	import com.service.loading.loaditems.URLLoaderLoadItem;
	import com.util.TimeLog;

	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.ProgressEvent;
	import flash.utils.getTimer;

	import org.as3commons.logging.api.ILogger;
	import org.as3commons.logging.api.getLogger;

	/**
	 *
	 * USAGE:
	 *
	 * var loadService:ILoadService = new LoadService();
	 *
	 * var loadItem:ILoadItem;
	 *
	 * loadItem	= new BitmapLoadItem("http://server/image.png",	LoadPriority.HIGH);
	 * loadItem = new SWFLoadItem("http://server/image.png",	LoadPriority.MEDIUM);
	 * loadItem = new SoundLoadItem("http://server/image.png",	LoadPriority.LOW);
	 * loadItem = new XMLLoadItem("http://server/image.png",	LoadPriority.PRELOAD);
	 * loadItem = new TextLoadItem("http://server/image.png",	LoadPriority.IMMEDIATE);
	 *
	 * loadItem.priority										= LoadPriority.IMMEDIATE;
	 * loadItem.url												= "http://server/asset.jpg";
	 * trace(loadItem.progress);								// 0.0 - 1.0
	 *
	 * loadItem.addEventListener(IOErrorEvent.IO_ERROR,			onIOError);
	 * loadItem.addEventListener(LoadEvent.COMPLETE,			onLoadComplete);
	 * loadItem.addEventListener(LoadEvent.START,				onLoadStart);
	 * loadItem.addEventListener(LoadProgressEvent.PROGRESS,	onLoadProgress);
	 *
	 * loadService.load(loadItem);
	 * loadService.cancel(loadItem);
	 *
	 * var bitmap:Bitmap				= Bitmap(bitmapLoadItem.asset);		// will be null until LoadEvent.COMPLETE is fired
	 * bitmap							= bitmapLoadItem.bitmap;			// will be null until LoadEvent.COMPLETE is fired
	 *
	 * var displayObject:DisplayObject	= DisplayObject(swfLoadItem.asset);	// will be null until LoadEvent.COMPLETE is fired
	 * displayObject					= swfLoadItem.displayObject;		// will be null until LoadEvent.COMPLETE is fired
	 *
	 * var sound:Sound					= Sound(soundLoadItem.asset);		// will be null until LoadEvent.COMPLETE is fired
	 * sound							= soundLoadItem.sound;				// will be null until LoadEvent.COMPLETE is fired
	 *
	 * var xml:XML						= XML(xmlLoadItem.asset);			// will be null until LoadEvent.COMPLETE is fired
	 * xml								= xmlLoadItem.xml;					// will be null until LoadEvent.COMPLETE is fired
	 *
	 * var text:String					= String(textLoadItem.asset);		// will be null until LoadEvent.COMPLETE is fired
	 * text								= textLoadItem.text;				// will be null until LoadEvent.COMPLETE is fired
	 *
	 */
	public final class LoadService implements ILoadService
	{

		////////////////////////////////////////////////////////////
		//   CONSTANTS 
		////////////////////////////////////////////////////////////

		public static const ALL_COMPLETE:String   = "AllComplete";
		private static const MAX_CONNECTIONS:int  = 5;
		private const _logger:ILogger             = getLogger('LoadService');

		////////////////////////////////////////////////////////////
		//   ATTRIBUTES 
		////////////////////////////////////////////////////////////

		private var _dispatcher:IEventDispatcher;
		private var _itemsLoaded:int              = 0;
		private var _loadMap:LoadMap;
		private var _loadTimes:Vector.<int>;
		private var _paused:Boolean               = false;

		//estimated loading
		private var _estimatedTimeToFinish:Number = 0;
		private var _fileSizeAverage:int          = 1000000;
		private var _totalBytesLoaded:int         = 0;
		private var _totalBytesLoading:int        = 0;

		////////////////////////////////////////////////////////////
		//   CONSTRUCTOR 
		////////////////////////////////////////////////////////////

		[PostConstruct]
		public function constructor():void
		{
			_loadMap = new LoadMap();
			_loadTimes = new Vector.<int>();
		}

		////////////////////////////////////////////////////////////
		//   PUBLIC API 
		////////////////////////////////////////////////////////////

		public function cancel( loadItem:ILoadItem ):void
		{
			loadItem.cancel();
			_loadMap.remove(loadItem);
			loadNext();
		}

		public function lazyLoad( url:String, priority:int = 3, doLoad:Boolean = true, absoluteURL:Boolean = false ):ILoadItem
		{
			var loader:ILoadItem;
			var index:int        = url.lastIndexOf('.');
			var extension:String = (index != -1) ? url.substr(index + 1).toLowerCase() : '';

			switch (extension)
			{
				/*case '3ds':
				   loader = new Away3DLoadItem(url, LoadingTypes.MESH, priority);
				   break;*/
				case 'jpg':
				case 'jpeg':
				case 'png':
				case 'gif':
					loader = new LoaderLoadItem(url, LoadingTypes.BITMAP, priority);
					break;
				case 'wav':
				case 'mp3':
					loader = new SoundLoadItem(url, LoadingTypes.SOUND, priority);
					break;
				case 'swf':
					loader = new LoaderLoadItem(url, LoadingTypes.SWF, priority);
					break;
				case 'xml':
					loader = new URLLoaderLoadItem(url, LoadingTypes.XML, priority);
					break;
				case 'battle':
					loader = new URLLoaderLoadItem(url, LoadingTypes.BATTLEREPLAY, priority);
					break;
				default:
					loader = new URLLoaderLoadItem(url, LoadingTypes.TEXT, priority);
					break;
			}
			if (doLoad)
				load(loader);
			return loader;
		}

		public function load( loadItem:ILoadItem ):void
		{
			loadItem.prefix = (loadItem.absoluteURL) ? '' : Application.ASSET_PATH;
			// look to see if that asset is already in progress
			if (!_loadMap.contains(loadItem))
				_loadMap.add(loadItem);

			loadNext();
		}

		public function loadBatch( type:int, urls:Array, priority:int = 3 ):ILoadItem
		{
			var batchLoader:BatchLoadItem = new BatchLoadItem(urls, type, priority);
			load(batchLoader);
			for (var i:int = 0; i < urls.length; i++)
				batchLoader.addLoadItem(lazyLoad(urls[i], priority, false));
			for (i = 0; i < batchLoader.items.length; i++)
				load(batchLoader.items[i]);
			return batchLoader;
		}

		public function pause():void
		{
			//doesn't stop any current loads it just prevents any more loads from this point on
			_paused = true;
		}

		public function resume():void
		{
			_paused = false;
			loadNext();
		}

		public function reset():void
		{
			_estimatedTimeToFinish = 0;
			_totalBytesLoaded = 0;
			_totalBytesLoading = 1;
		}

		////////////////////////////////////////////////////////////
		//   PRIVATE METHODS 
		////////////////////////////////////////////////////////////

		private function addLoadItemListeners( loadItem:ILoadItem ):void
		{
			loadItem.addUpdateListener(onUpdate);
		}

		private function removeLoadItemListeners( loadItem:ILoadItem ):void
		{
			loadItem.removeUpdateListener(onUpdate);
		}

		private function onUpdate( state:String, loadItem:ILoadItem ):void
		{
			switch (state)
			{
				case LoadItem.CANCEL:
					cancel(loadItem);
					break;
				case LoadItem.COMPLETE:
					var endTime:int                 = getTimer();
					if (loadItem.type != LoadingTypes.SPRITE_SHEET || loadItem.type != LoadingTypes.SPRITE_SHEET_MESH)
					{
						TimeLog.endTimeLog(TimeLogEnum.FILE_LOAD, loadItem.url);
						_logger.info('Loading Complete: {0}  Time: {1}', [loadItem.fullPath, endTime - loadItem.loadStartTime]);
						updateAvgLoadTime(loadItem.totalBytesLoaded, loadItem.loadStartTime, endTime);
					}
					removeLoadItemListeners(loadItem);
					_loadMap.remove(loadItem);
					_dispatcher.dispatchEvent(new LoadEvent(loadItem));

					_itemsLoaded++;

					var progressEvent:ProgressEvent = new ProgressEvent(ProgressEvent.PROGRESS);
					progressEvent.bytesLoaded = _itemsLoaded;
					progressEvent.bytesTotal = _loadMap.loadsInProgress + _loadMap.loadsWaiting + _itemsLoaded;
					_dispatcher.dispatchEvent(progressEvent);
					loadNext();
					break;
				case LoadItem.PROGRESS:
					if (loadItem.priority < LoadPriority.MEDIUM)
					{
						if (!loadItem.tracked)
						{
							_totalBytesLoading += loadItem.totalBytes;
							loadItem.tracked = true;
						}
						_totalBytesLoaded += loadItem.totalBytesLoadedLastFrame;
							//trace(estimatedTimeToFinish, estimatedLoadCompleted);
					}
					break;
				case LoadItem.START:
					break;
				default:
					_logger.error("Load error: {0}, {1}", [state, loadItem.fullPath]);
					_loadMap.remove(loadItem);
					loadNext();
					break;
			}
		}

		private function loadNext():void
		{
			// stop if we're already loading too many
			if (_loadMap.loadsInProgress >= MAX_CONNECTIONS || _paused)
			{
				return;
			}

			// stop if there's nothing to load
			if (_loadMap.loadsWaiting == 0)
			{
				//We've finished loading all assets...?
				if (_loadMap.loadsInProgress == 0)
				{
					_itemsLoaded = 0;
					_dispatcher.dispatchEvent(new Event(ALL_COMPLETE));
				}
				return;
			}

			// get the next item to load
			var loadItem:ILoadItem = _loadMap.getNextLoadItem();
			// listen to the "master" load item for this URL
			addLoadItemListeners(loadItem);

			_logger.info('Loading: {}', loadItem.fullPath);
			loadItem.load();

			if (_loadMap.loadsInProgress < MAX_CONNECTIONS && _loadMap.loadsWaiting > 0)
				loadNext();
		}

		private function updateAvgLoadTime( bytesLoaded:Number, startTime:Number, endTime:Number ):void
		{
			if ((endTime - startTime) <= 0)
				return;
			_loadTimes.push(bytesLoaded / (endTime - startTime));
			if (_loadTimes.length > 10)
				_loadTimes.shift();

			var len:uint = _loadTimes.length;
			if (len > 2)
			{
				var avgLoadTime:int = 0;
				for (var i:uint = 0; i < len; ++i)
				{
					avgLoadTime += _loadTimes[i];
				}

				avgLoadTime /= len;
				Application.AVG_LOAD_TIME = avgLoadTime;
			}
		}

		public function get estimatedLoadCompleted():Number  { return _totalBytesLoaded / (_totalBytesLoading + (_loadMap.highPrioritiesInWaiting * _fileSizeAverage)); }
		public function get highPrioritiesInProgress():int  { return _loadMap.highPrioritiesInProgress; }
		public function get highPrioritiesInWaiting():int  { return _loadMap.highPrioritiesInWaiting; }
		public function get highPrioritiesTotal():int  { return _loadMap.highPrioritiesTotal; }
		public function get itemsInWaiting():int  { return _loadMap.loadsWaiting; }

		[Inject]
		public function set dispatcher( v:IEventDispatcher ):void  { _dispatcher = v; }
	}
}
