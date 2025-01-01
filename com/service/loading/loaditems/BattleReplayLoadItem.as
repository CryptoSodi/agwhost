package com.service.loading.loaditems
{
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;

	public final class BattleReplayLoadItem extends LoadItem
	{

		////////////////////////////////////////////////////////////
		//   ATTRIBUTES 
		////////////////////////////////////////////////////////////

		//protected var _loader:Sound;

		////////////////////////////////////////////////////////////
		//   CONSTRUCTOR 
		////////////////////////////////////////////////////////////

		public function BattleReplayLoadItem( url:String, type:int, priority:int = int.MAX_VALUE, absolute:Boolean = false )
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
			if (_loader)
				removeLoaderListeners(_loader);

			_loader = new Sound();
			addLoaderListeners(_loader);
			_loader.load(new URLRequest(_url.toString()));
		}

		////////////////////////////////////////////////////////////
		//   PRIVATE METHODS 
		////////////////////////////////////////////////////////////

		private function addLoaderListeners( loader:Sound ):void
		{
			loader.addEventListener(Event.OPEN, onLoadStart);
			loader.addEventListener(ProgressEvent.PROGRESS, onLoadProgress);
			loader.addEventListener(Event.COMPLETE, onLoadComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR, onLoadIOError);
		}

		private function removeLoaderListeners( loader:Sound ):void
		{
			_loader.removeEventListener(Event.OPEN, onLoadStart);
			_loader.removeEventListener(ProgressEvent.PROGRESS, onLoadProgress);
			_loader.removeEventListener(Event.COMPLETE, onLoadComplete);
			_loader.removeEventListener(IOErrorEvent.IO_ERROR, onLoadIOError);
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

		//		protected override function onLoadComplete(event:Event):void
		//		{
		//			this.asset = Bitmap(_loader.content);
		//		}

		public function get sound():Sound
		{
			if (_asset)
			{
				return Sound(_asset);
			}

			return null;
		}
	}
}
