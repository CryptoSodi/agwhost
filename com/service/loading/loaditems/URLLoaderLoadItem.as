package com.service.loading.loaditems
{

	import com.service.loading.LoadingTypes;
	
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;

	public class URLLoaderLoadItem extends LoadItem
	{

		////////////////////////////////////////////////////////////
		//   ATTRIBUTES 
		////////////////////////////////////////////////////////////

		protected var _loader:URLLoader;

		////////////////////////////////////////////////////////////
		//   CONSTRUCTOR 
		////////////////////////////////////////////////////////////

		public function URLLoaderLoadItem( url:String, type:int, priority:int = int.MAX_VALUE, absolute:Boolean = false )
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
				_loader = new URLLoader();
				addLoaderListeners(_loader);
			}

			//TODO: ??? supply LoaderContext to separate application domains
			if( _type == LoadingTypes.BATTLEREPLAY )
			{
				_loader.dataFormat = URLLoaderDataFormat.BINARY;
			}
			_loader.load(new URLRequest(_url.toString()));
		}

		////////////////////////////////////////////////////////////
		//   PROTECTED METHODS 
		////////////////////////////////////////////////////////////

		protected function addLoaderListeners( loader:URLLoader ):void
		{
			loader.addEventListener(Event.OPEN, onLoadStart);
			loader.addEventListener(ProgressEvent.PROGRESS, onLoadProgress);
			loader.addEventListener(Event.COMPLETE, onLoadComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onLoadIOError);
		}

		protected function removeLoaderListeners( loader:URLLoader ):void
		{
			loader.removeEventListener(Event.OPEN, onLoadStart);
			loader.removeEventListener(ProgressEvent.PROGRESS, onLoadProgress);
			loader.removeEventListener(Event.COMPLETE, onLoadComplete);
			loader.removeEventListener(IOErrorEvent.IO_ERROR, onLoadIOError);
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

			return _loader.bytesLoaded / _loader.bytesTotal;
		}
	}
}
