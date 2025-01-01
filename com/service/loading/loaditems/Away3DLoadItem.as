package com.service.loading.loaditems
{

	import flash.errors.IOError;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;

	import org.away3d.events.AssetEvent;
	import org.away3d.library.assets.AssetType;
	import org.away3d.loaders.Loader3D;

	/**
	 * This is the internal base class for LoadItems that use a Loader
	 * to download their asset
	 */
	public class Away3DLoadItem extends LoadItem
	{
		private static const _context:LoaderContext = new LoaderContext(false, ApplicationDomain.currentDomain);

		protected var _loader:Loader3D;

		////////////////////////////////////////////////////////////
		//   CONSTRUCTOR 
		////////////////////////////////////////////////////////////

		public function Away3DLoadItem( url:String, type:int, priority:int = int.MAX_VALUE, absolute:Boolean = false )
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
					_loader.stopLoad();
					_loader = null;
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
			if (!_loader)
			{
				_loader = new Loader3D(false);
				addLoaderListeners(_loader);
			}
			_loader.load(new URLRequest(_url.toString()));
		}

		protected function onAssetLoadComplete( event:AssetEvent ):void
		{
			if (event.asset.assetType == AssetType.MESH)
			{
				this.asset = event.asset;
				_loaded = true;
				_updateSignal.dispatch(COMPLETE, this);
			}
		}

		////////////////////////////////////////////////////////////
		//   PRIVATE METHODS 
		////////////////////////////////////////////////////////////

		private function addLoaderListeners( loader:Loader3D ):void
		{
			loader.addEventListener(AssetEvent.ASSET_COMPLETE, onAssetLoadComplete);
		}

		private function removeLoaderListeners( loader:Loader3D ):void
		{
			loader.removeEventListener(AssetEvent.ASSET_COMPLETE, onAssetLoadComplete);
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
			return 0; //_loader.contentLoaderInfo.bytesLoaded / _loader.contentLoaderInfo.bytesTotal;
		}
	}
}
