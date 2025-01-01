package com.service.loading.loaditems
{

	import flash.display.Loader;
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;

	/**
	 * This is the internal base class for LoadItems that use a Loader
	 * to download their asset
	 */
	public class LoaderLoadItem extends LoadItem
	{
		private static const _context:LoaderContext = new LoaderContext(false, ApplicationDomain.currentDomain);

		////////////////////////////////////////////////////////////
		//   ATTRIBUTES 
		////////////////////////////////////////////////////////////

		protected var _loader:Loader;

		////////////////////////////////////////////////////////////
		//   CONSTRUCTOR 
		////////////////////////////////////////////////////////////

		public function LoaderLoadItem( url:String, type:int, priority:int = int.MAX_VALUE, absolute:Boolean = false )
		{
			super(url, type, priority, absolute);
		}

		////////////////////////////////////////////////////////////
		//   PUBLIC API 
		////////////////////////////////////////////////////////////

		public override function cancel():void
		{
			if (_loader)
			{
				removeLoaderListeners(_loader);

				try
				{
					_loader.close();
				} catch ( e:IOError )
				{
					// The loader will throw an IOError (with error code 2029)
					// if it wasn't loading anything, which we ignore. If it was
					// some other kind of error, we throw the error
					if (e.errorID != 2029)
					{
						throw e;
					}
				}
			}

			_updateSignal.dispatch(CANCEL, this);
		}

		public override function destroy():void
		{
			super.destroy();

			if (_loader)
			{
				removeLoaderListeners(_loader);
				_loader = null;
			}
		}

		public override function load():void
		{
			// ensure that only 1 loader is used for this BitmapLoadItem instance
			if (!_loader)
			{
				_loader = new Loader();
				addLoaderListeners(_loader);
			}
			_loader.load(new URLRequest(_url.toString()), _context);
		}

		override protected function onLoadComplete( event:Event ):void
		{
			_applicationDomain = _loader.contentLoaderInfo.applicationDomain;
			super.onLoadComplete(event);
		}

		////////////////////////////////////////////////////////////
		//   PRIVATE METHODS 
		////////////////////////////////////////////////////////////

		private function addLoaderListeners( loader:Loader ):void
		{
			loader.contentLoaderInfo.addEventListener(Event.OPEN, onLoadStart);
			loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, onLoadProgress);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadIOError);
		}

		private function removeLoaderListeners( loader:Loader ):void
		{
			_loader.contentLoaderInfo.removeEventListener(Event.OPEN, onLoadStart);
			_loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, onLoadProgress);
			_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadComplete);
			_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onLoadIOError);
		}

		////////////////////////////////////////////////////////////
		//   GETTERS / SETTERS 
		////////////////////////////////////////////////////////////

		public override function get progress():Number
		{
			if (!_loader)
			{
				return 0;
			}

			return _loader.contentLoaderInfo.bytesLoaded / _loader.contentLoaderInfo.bytesTotal;
		}
	}
}
