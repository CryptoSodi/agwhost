package com.model.asset
{
	import com.enum.CategoryEnum;
	import com.event.RequestLoadEvent;
	import com.game.entity.components.shared.Detail;
	import com.model.Model;
	import com.model.player.CurrentUser;
	import com.model.prototype.IPrototype;
	import com.service.loading.LoadPriority;
	import com.service.loading.LoadingTypes;

	import flash.display3D.Context3DTextureFormat;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;

	import org.as3commons.logging.api.ILogger;
	import org.as3commons.logging.api.getLogger;
	import org.ash.core.Entity;
	import org.ash.tick.ITickProvider;
	import org.swiftsuspenders.Injector;

	public class AssetModel extends Model
	{
		public static var instance:AssetModel;

		public static const FAILED:String = "failed";
		protected static const LOADING:String = "loading";
		protected const _logger:ILogger       = getLogger('AssetModel');

		protected var _audioProtos:Vector.<IPrototype>;
		protected var _cache:Dictionary;
		protected var _callbacks:Dictionary;
		protected var _frameTick:ITickProvider;
		protected var _injector:Injector;
		protected var _spritePacks:Dictionary;
		protected var _spriteSheets:Dictionary;
		protected var _spriteSheetBuilds:Vector.<ISpriteSheet>;

		public function AssetModel()
		{
			_audioProtos = new Vector.<IPrototype>;
			_cache = new Dictionary();
			_callbacks = new Dictionary();
			_spritePacks = new Dictionary();
			_spriteSheets = new Dictionary();
			_spriteSheetBuilds = new Vector.<ISpriteSheet>;
			instance = this;
		}
		
		public function getAssetVOByName(key:String):AssetVO{
			return _cache[key];
		}

		public function cache( url:String, asset:Object ):void
		{
			if (_cache[url] == null)
				_cache[url] = asset;
			else if (_cache[url] == LOADING)
			{
				_cache[url] = asset;
				applyCallbacks(asset, url);
			}
		}

		public function getFromCache( url:String, callback:Function = null, priority:int = 3/*LoadPriority.LOW*/, absoluteURL:Boolean = false ):Object
		{
			if (_cache[url] == null)
			{
				dispatch(new RequestLoadEvent(url, priority, absoluteURL));
				_cache[url] = LOADING;
			}
			if (_cache[url] == LOADING)
			{
				if (callback != null)
					addCallback(callback, url);
				return null;
			}
			if (callback != null)
				callback.apply(this, [_cache[url]]);
			return _cache[url];
		}

		public function removeFromCache( url:String ):void
		{
			_cache[url] = null;
			delete _cache[url];
		}

		public function clearCache():void
		{
			for (var url:String in _cache)
				removeFromCache(url);
		}

		public function addGameAssetData( data:IPrototype ):void
		{
			if (!_cache[data.name])
				_cache[data.name] = new AssetVO();
			_cache[data.name].addGameAssetData(data);
		}

		public function addUIAssetData( data:IPrototype ):void
		{
			if (!_cache[data.name])
				_cache[data.name] = new AssetVO();
			_cache[data.name].addUIAssetData(data);
		}

		public function addAudioAssetData( data:IPrototype ):void
		{
			if (!_cache[data.name])
				_cache[data.name] = new AssetVO();
			_cache[data.name].addAudioAssetData(data);

			_audioProtos.push(data);
		}

		public function addFilterAssetData( data:IPrototype ):void
		{
			if (!_cache[data.name])
				_cache[data.name] = new AssetVO();
			_cache[data.name].addFilterAssetData(data);
		}

		public function getAudioProtos():Vector.<IPrototype>  { return _audioProtos; }

		public function removeGameAssetData( name:String ):void
		{
			if (_cache[name])
			{
				_cache[name] = null;
				delete _cache[name];
			}
		}

		public function getEntityData( type:String ):AssetVO
		{
			if (_cache[type])
				return _cache[type];
			else
				_logger.debug('No entity data found for: {0}', [type]);
			return null;
		}

		public function getSpritePack( type:String, load:Boolean = true, entity:Entity = null, priority:int = 3 /*LoadPriority.LOW*/, format:String = Context3DTextureFormat.BGRA ):ISpritePack
		{
			if (_spritePacks[type])
			{
				return _spritePacks[type];
			}
			if (!_cache[type])
			{
				_logger.debug('No entity data found for: {0}', [type]);
				return null;
			} else
			{
				if (_spritePacks[type] == null)
				{
					//check to see if any of these sprite sheets have already been loaded
					var detail:Detail;
					var vo:AssetVO   = _cache[type];
					var toLoad:Array = [];
					var sheet:ISpriteSheet;
					_spritePacks[type] = new SpritePack(type, vo.usedBy, format);
					for (var i:int = 0; i < vo.sprites.length; i++)
					{
						sheet = getSpriteSheet(vo.sprites[i], vo.isMesh);
						if (!sheet.begunLoad)
						{
							if (load)
							{
								if (vo.isMesh)
									toLoad.push(vo.sprites[i]);
								else
								{
									toLoad.push(vo.sprites[i]);
									toLoad.push(vo.spriteXML[i]);
								}
								sheet.begunLoad = true;

								//find the priority if we have an entity
								if (entity)
								{
									detail = entity.get(Detail);
									switch (detail.category)
									{
										case CategoryEnum.BUILDING:
											priority = LoadPriority.HIGH;
											break;
										case CategoryEnum.SECTOR:
											priority = LoadPriority.HIGH;
											break;
										case CategoryEnum.SHIP:
											priority = detail.prototypeVO.getValue("faction") == CurrentUser.faction ? LoadPriority.IMMEDIATE : LoadPriority.MEDIUM;
											break;
										case CategoryEnum.STARBASE:
											priority = LoadPriority.IMMEDIATE;
											break;
									}
								}
							} else
								sheet.begunLoad = true;
						}
						_spritePacks[type].addSpriteSheet(sheet);
					}
					if (toLoad.length > 0)
					{
						var event:RequestLoadEvent = new RequestLoadEvent(null, priority);
						event.batchLoad(vo.isMesh ? LoadingTypes.SPRITE_SHEET_MESH : LoadingTypes.SPRITE_SHEET, toLoad);
						dispatch(event);
					}
				}
			}
			return _spritePacks[type];
		}

		public function initSpriteSheet( url:String, asset:*, xml:XML, build:Boolean = true ):void
		{
			if (_spriteSheets[url])
			{
				_spriteSheets[url].init(asset, xml, url);
				if (build)
				{
					//trace(url, _spriteSheets[url].referenceCount);
					_spriteSheetBuilds.push(_spriteSheets[url]);
					if (_spriteSheetBuilds.length == 1)
						_frameTick.addFrameListener(buildSpriteSheets);
				}
			}
		}

		public function getSpriteSheet( url:String, isMesh:Boolean = false ):ISpriteSheet
		{
			if (!_spriteSheets[url])
				_spriteSheets[url] = /*(isMesh) ? new MeshSheet() : */ _injector.getInstance(ISpriteSheet);
			return _spriteSheets[url];
		}

		public function removeSpritePack( pack:ISpritePack ):void
		{
			if (!pack)
				return;
			_spritePacks[pack.type] = null;
			delete _spritePacks[pack.type];
			for (var i:int = 0; i < pack.spriteSheets.length; i++)
			{
				pack.spriteSheets[i].decReferenceCount();
				if (pack.spriteSheets[i].referenceCount <= 0)
				{
					//trace("removing", pack.type, pack.spriteSheets[i].url, pack.spriteSheets[i].referenceCount);
					removeSpriteSheet(pack.spriteSheets[i].url);
				}
			}
			pack.destroy();
		}

		public function removeAllSpritePacks():void
		{
			for each (var pack:ISpritePack in _spritePacks)
			{
				removeSpritePack(pack);
			}
		}

		public function removeSpriteSheet( url:String ):void
		{
			if (!_spriteSheets[url])
				return;
			if (_spriteSheets[url] == null)
				return;
			_spriteSheets[url].destroy();
			_spriteSheets[url] = null;
			delete _spriteSheets[url];
		}

		public function stopAllSpritePackBuilds():void
		{
			_spriteSheetBuilds.length = 0;
			_frameTick.removeFrameListener(buildSpriteSheets);
		}

		private function buildSpriteSheets( time:Number ):void
		{
			var endBuild:Number = getTimer() + 20;
			while (getTimer() < endBuild && _spriteSheetBuilds.length > 0)
			{
				if (!_spriteSheetBuilds[0].build() || _spriteSheetBuilds[0].built)
				{
					_spriteSheetBuilds.shift();
					//stop the build loop if there is nothing left to build
					if (_spriteSheetBuilds.length == 0)
						_frameTick.removeFrameListener(buildSpriteSheets);
				}
			}
		}

		private function addCallback( callback:Function, url:String ):void
		{
			if (callback != null && url)
			{
				if (!_callbacks[url])
					_callbacks[url] = [];
				if (_callbacks[url].indexOf(callback) == -1)
					_callbacks[url].push(callback);
			}
		}

		private function applyCallbacks( asset:Object, url:String ):void
		{
			if (asset && url)
			{
				if (_callbacks.hasOwnProperty(url))
				{
					var assetArg:Array  = [asset];
					var callbacks:Array = _callbacks[url];
					for (var i:int = 0; i < callbacks.length; i++)
					{
						callbacks[i].apply(null, assetArg);
					}

					//remove the callbacks
					_callbacks[url] = null;
					delete _callbacks[url];
				}
			}
		}

		[Inject]
		public function set frameTick( v:ITickProvider ):void  { _frameTick = v; }
		[Inject]
		public function set injector( v:Injector ):void  { _injector = v; }

		public function get spritePacks():Dictionary  { return _spritePacks; }
	}
}
