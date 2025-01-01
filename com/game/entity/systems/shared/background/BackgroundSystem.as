package com.game.entity.systems.shared.background
{
	import com.Application;
	import com.enum.FactionEnum;
	import com.enum.TypeEnum;
	import com.event.StateEvent;
	import com.event.signal.QuadrantSignal;
	import com.game.entity.factory.IBackgroundFactory;
	import com.model.asset.AssetModel;
	import com.model.asset.AssetVO;
	import com.model.asset.ISpritePack;
	import com.model.battle.BattleModel;
	import com.model.scene.SceneModel;
	import com.model.sector.SectorModel;
	import com.service.loading.LoadPriority;
	import com.util.InteractEntityUtil;
	import com.util.Random;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import org.ash.core.Game;
	import org.ash.core.System;
	import org.osflash.signals.Signal;
	import org.parade.core.IViewStack;
	import org.parade.enum.ViewEnum;
	import org.parade.util.DeviceMetrics;
	import org.shared.ObjectPool;
	import org.starling.display.BlendMode;
	import org.starling.display.Image;
	import org.starling.display.Sprite;

	public class BackgroundSystem extends System
	{
		private static const MAX_MOONS:int        = 3; //Does a random number between 0 and MAX_MOONS. Max is actually one less than the value set here
		private static const MAX_PLANETS:int      = 2; //Does a random number between 0 and MAX_PLANETS. Max is actually one less than the value set here

		private static const STAR_LAYER:int       = 0;
		private static const STAR_LAYER2:int      = 1;
		private static const PLANET_LAYER_1:int   = 2;
		private static const MOON_LAYER_1:int     = 3;
		private static const MOON_LAYER_2:int     = 4;
		private static const MOON_LAYER_3:int     = 5;
		private static const ASTEROID_LAYER_1:int = 6;
		private static const ASTEROID_LAYER_2:int = 7;
		private static const FOG_LAYER:int        = 8;
		private static const DEBRIS_LAYER:int     = 9;

		[Inject]
		public var assetModel:AssetModel;
		[Inject]
		public var backgroundFactory:IBackgroundFactory;
		[Inject]
		public var quadrantSignal:QuadrantSignal;
		[Inject]
		public var sceneModel:SceneModel;
		[Inject]
		public var sectorModel:SectorModel;
		[Inject]
		public var viewStack:IViewStack;

		private var _game:Game;
		private var _initialized:Boolean;
		private var _layers:Vector.<BackgroundLayer>;
		private var _lookup:Dictionary;
		private var _nebula:flash.display.Sprite;
		private var _nebulaStarling:org.starling.display.Sprite;
		private var _oldIds:Array;
		private var _oldView:Rectangle;
		private var _readySignal:Signal;

		override public function addToGame( game:Game ):void
		{
			_game = game;
			_initialized = false;
			_layers = new Vector.<BackgroundLayer>;
			_lookup = new Dictionary();
			_oldIds = [];
			_oldView = new Rectangle();
			_readySignal = new Signal();

			quadrantSignal.add(onVisibleHashChanged);
		}

		override public function update( time:Number ):void
		{
			if (!_initialized && sceneModel.ready && assetModel.getSpritePack(TypeEnum.BACKGROUND, true, null, LoadPriority.IMMEDIATE))
			{
				if (Application.STARLING_ENABLED)
					createNebulaStarfield();
				else
					createNebula();
			}
		}

		public function buildBackground(battleModel:BattleModel, useModelData:Boolean = false):void
		{
			var assetVO:AssetVO;
			var item:BackgroundItem;
			var num:int;
			var width:Number           = (Application.STATE == StateEvent.GAME_SECTOR) ? sectorModel.width : 5000;
			var height:Number          = (Application.STATE == StateEvent.GAME_SECTOR) ? sectorModel.height : 5000;
			
			if(useModelData && Application.STATE == StateEvent.GAME_BATTLE && battleModel.mapSizeX > 0 && battleModel.mapSizeY > 0)
			{
				width = battleModel.mapSizeX;
				height = battleModel.mapSizeY / 2;
			}
			
			var customAppearance:Boolean = false;
			
			var spriteSheets:String;
			var spriteSheetPath:String;
			if(useModelData && battleModel.galacticName.length > 0)
			{
				customAppearance = true;
				spriteSheetPath = "bg/" + battleModel.galacticName + "/";
			}
			else
			{
				//setup the spritesheet for the space elements
				spriteSheetPath = "bg/IMP/";
				if ( sectorModel.sectorFaction != FactionEnum.IMPERIUM)
				{
					if (sectorModel.sectorFaction == FactionEnum.IGA)
						spriteSheetPath = "bg/IGA/";
					else
						spriteSheetPath = (sectorModel.sectorFaction == FactionEnum.SOVEREIGNTY) ? "bg/SOV/" : "bg/TYR/";
				}
			}
			
			var random:Random;
			var seed:String;
			if(customAppearance)
			{
				random = new Random(battleModel.appearanceSeed);
				seed = String(battleModel.appearanceSeed);
				spriteSheets = spriteSheetPath + "BG" + battleModel.backgroundId;
			}
			else
			{
				random = new Random(sectorModel.appearanceSeed);
				seed = String(sectorModel.appearanceSeed);
				spriteSheets = spriteSheetPath + "BG" + random.nextMinMax(1, sectorModel.numBackgroundSprites + 1);
			}
			createLayers(width, height);

			//create the nebulae 
			updateSpriteData(TypeEnum.BACKGROUND, spriteSheets, true);

			//create the starfields
			spriteSheets = spriteSheetPath + "StarfieldFog";
			updateSpriteData(TypeEnum.BACKGROUND_FOG_STARS, spriteSheets);
			if (Application.STARLING_ENABLED) //don't show bg stars if in software mode for performance
				_layers[STAR_LAYER].addItemFromData(TypeEnum.BACKGROUND_FOG_STARS, "StarBG", 2048, 1048, 1, true);
			_layers[STAR_LAYER2].addItemFromData(TypeEnum.BACKGROUND_FOG_STARS, "StarFG", 1024, 1024, 1, true);

			spriteSheets = "";
			//only show the planets, moons and asteroids if we're in the sector
			//if (Application.STATE == StateEvent.GAME_SECTOR)
			{
				//create the planets
				var numPlanets:int;
				
				if(customAppearance)
				{
					if(battleModel.planetId == 0)
						numPlanets = 0;
					else
						numPlanets = 1;
				}
				else
					numPlanets = random.nextMinMax(0, MAX_PLANETS);
				if (numPlanets == 0)
					numPlanets = (random.nextNumber() < .92) ? 1 : 0;
				if (numPlanets > 0)
				{
					var bounds:Rectangle;
					var scale:Number;
					var ss:int                          ;
					
					if(customAppearance)
						ss = battleModel.planetId;
					else
						ss = random.nextMinMax(1, sectorModel.numPlanetSprites + 1);
					spriteSheets += spriteSheetPath + "Planet" + ss;
					var planets:Vector.<BackgroundItem> = new Vector.<BackgroundItem>;
					for (var i:int = 0; i < numPlanets; i++)
					{
						bounds = _layers[PLANET_LAYER_1].bounds;
						scale = 1 + (random.nextMinMax(0, 35) / 100);
						item = _layers[PLANET_LAYER_1].addItemFromData(TypeEnum.BACKGROUND_ELEMENTS, "Planet" + ss, 1024, 1024, scale, false,
																	   random.nextMinMax(0 - (bounds.width * .15), bounds.width - (bounds.width * .3)),
																	   random.nextMinMax(0 - (bounds.height * .15), bounds.height - (bounds.height * .3)));
						planets.push(item);
					}

					//create the moons
					var numMoons:int;
					var parallax:Number;
					for (i = 0; i < planets.length; i++)
					{
						item = planets[i];
						if(customAppearance)
							numMoons = battleModel.moonQuantity;
						else
							numMoons = random.nextMinMax(0, MAX_MOONS);
						
						for (i = 0; i < numMoons; i++)
						{
							num = (i % 3) + MOON_LAYER_1;
							parallax = 1 - _layers[num].parallaxSpeed;
							_layers[num].addItemFromData(TypeEnum.BACKGROUND_ELEMENTS, "Moon" + random.nextMinMax(1, 3), 256, 256, 1, false,
														 random.nextMinMax((item.x + (item.width * .13)) / parallax, (item.x + item.width - (item.width * .13)) / parallax),
														 random.nextMinMax((item.y + (item.height * .13)) / parallax, (item.y + item.height - (item.height * .13)) / parallax));
						}

					}
				}

				//create the asteroids
				var numAsteroids:int;
				if(customAppearance)
					numAsteroids = battleModel.asteroidQuantity;
				else
					numAsteroids = random.nextMinMax(1, 17);
				if (numAsteroids > 0 && Application.STARLING_ENABLED)
				{
					bounds = _layers[ASTEROID_LAYER_1].bounds;
					var bounds2:Rectangle = _layers[ASTEROID_LAYER_2].bounds;
					if (spriteSheets != "")
						spriteSheets += ",";
					spriteSheets += spriteSheetPath + "Asteroids";
					var p:Number          = _layers[ASTEROID_LAYER_1].parallaxSpeed;
					for (i = 0; i < numAsteroids; i++)
					{
						item = _layers[ASTEROID_LAYER_2].addItemFromData(TypeEnum.BACKGROUND_ELEMENTS, "AsteroidFG", 2048, 1024, 1, false,
																		 random.nextMinMax(0 - (bounds2.width * .2), bounds2.width - (bounds2.width * .2)),
																		 random.nextMinMax(0 - (bounds2.height * .2), bounds2.height - (bounds2.height * .2)));
						//should we show the background asteroid?
						if (random.nextNumber() < .7)
							_layers[ASTEROID_LAYER_1].addItemFromData(TypeEnum.BACKGROUND_ELEMENTS, "AsteroidBG", 2048, 1024, 1, false, item.x - item.x * p, item.y - item.y * p);

					}
				}

				//create space debris

				updateSpriteData(TypeEnum.BACKGROUND_ELEMENTS, spriteSheets);
			}

			//create space fog
			_layers[FOG_LAYER].addItemFromData(TypeEnum.BACKGROUND_FOG_STARS, "Fog", 1024, 1024, 1, true);

			sceneModel.buildScene(width, height);
		}

		private function updateSpriteData( type:String, spriteSheets:String, isJPG:Boolean = false ):void
		{
			var assetVO:AssetVO = assetModel.getEntityData(type);
			var make:Boolean    = false;
			if (!assetVO)
				make = true;
			else if (assetVO && assetVO.spriteSheetsString != spriteSheets)
			{
				assetModel.removeGameAssetData(type);
				var sp:ISpritePack = assetModel.getSpritePack(type, false);
				assetModel.removeSpritePack(sp);
				make = spriteSheets != "";
			}
			if (make)
				assetModel.addGameAssetData(InteractEntityUtil.createPrototype(type, 8, spriteSheets, isJPG));
		}

		private function onVisibleHashChanged( type:int, viewBounds:Rectangle ):void
		{
			if (type == QuadrantSignal.VISIBLE_HASH_CHANGED)
			{
				var bgItem:BackgroundItem;
				var duplicate:Dictionary = new Dictionary(true);
				var ids:Array            = getItemsByRect(viewBounds);
				var index:int;
				for (var i:int = 0; i < ids.length; i++)
				{
					if (!_game.getEntity(ids[i]))
					{
						backgroundFactory.createBackground(_lookup[ids[i]]);
					}
					duplicate[ids[i]] = true;
				}
				for (i = 0; i < _oldIds.length; i++)
				{
					if (!duplicate[_oldIds[i]])
						backgroundFactory.destroyBackground(_game.getEntity(_oldIds[i]));
				}
				_oldIds = ids;
			}
		}

		private function createNebula():void
		{
			var sp:ISpritePack = assetModel.getSpritePack(TypeEnum.BACKGROUND, true, null, LoadPriority.IMMEDIATE);
			if (sp && sp.ready)
			{
				var dwidth:Number  = 0;
				var dheight:Number = 0;
				_nebula = new flash.display.Sprite();
				var bmp:Bitmap;
				while (dheight <= DeviceMetrics.MAX_HEIGHT_PIXELS)
				{
					while (dwidth <= DeviceMetrics.MAX_WIDTH_PIXELS)
					{
						bmp = new Bitmap(sp.getFrame("BG", 0));
						bmp.x = dwidth;
						bmp.y = dheight;
						_nebula.addChild(bmp);
						dwidth += 2048;
					}
					dwidth = 0;
					dheight += 2048;
				}
				if (_nebula.numChildren == 1)
				{
					_nebula.x = (DeviceMetrics.MAX_WIDTH_PIXELS - _nebula.width) / 2;
					_nebula.y = (DeviceMetrics.MAX_HEIGHT_PIXELS - _nebula.height) / 2;
				}
				_nebula.cacheAsBitmap = true;
				viewStack.addToLayer(_nebula, ViewEnum.GAME);
				_initialized = true;
				_readySignal.dispatch();
			}
		}

		private function createNebulaStarfield():void
		{
			var sp:ISpritePack = assetModel.getSpritePack(TypeEnum.BACKGROUND, true, null, LoadPriority.IMMEDIATE);
			if (sp && sp.ready)
			{
				var dwidth:Number  = 0;
				var dheight:Number = 0;
				_nebulaStarling = new org.starling.display.Sprite();
				var image:Image;
				while (dheight <= DeviceMetrics.MAX_HEIGHT_PIXELS)
				{
					while (dwidth <= DeviceMetrics.MAX_WIDTH_PIXELS)
					{
						image = new Image(sp.getFrame("BG", 0));
						image.x = dwidth;
						image.y = dheight;
						image.blendMode = BlendMode.NONE;
						_nebulaStarling.addChild(image);
						dwidth += 2048;
					}
					dwidth = 0;
					dheight += 2048;
				}
				if (_nebulaStarling.numChildren == 1)
				{
					_nebulaStarling.x = (DeviceMetrics.MAX_WIDTH_PIXELS - _nebulaStarling.width) / 2;
					_nebulaStarling.y = (DeviceMetrics.MAX_HEIGHT_PIXELS - _nebulaStarling.height) / 2;
				}
				_nebulaStarling.blendMode = BlendMode.NONE;
				_nebulaStarling.flatten();
				viewStack.addToLayer(_nebulaStarling, ViewEnum.GAME);
				_initialized = true;
				_readySignal.dispatch();
			}
		}

		private function getItemsByRect( viewBounds:Rectangle ):Array
		{
			var ids:Array = [];
			for (var i:int = 0; i < _layers.length; i++)
			{
				ids = ids.concat(_layers[i].getItemsByRect(viewBounds));
			}

			return ids;
		}

		public function addReadySignal( callback:Function ):void  { _readySignal.addOnce(callback); }

		/**
		 * Called when the stage3d context is lost to rebuild the starfield.
		 * Also called when this class is destroyed to allow the starfield to be garbage collected
		 */
		public function uninitialize():void
		{
			_initialized = false;
			if (_nebula)
			{
				_nebula.parent.removeChild(_nebula);
				_nebula = null;
			} else if (_nebulaStarling)
			{
				_nebulaStarling.parent.removeChild(_nebulaStarling);
				_nebulaStarling = null;
			}
		}

		private function createLayers( width:Number, height:Number ):void
		{
			//starfield layers
			_layers.push(createLayer(STAR_LAYER, .005, 1, width, height, _lookup));
			_layers.push(createLayer(STAR_LAYER2, .009, 1, width, height, _lookup));

			//planet layers
			_layers.push(createLayer(PLANET_LAYER_1, .01, 1, width, height, _lookup));

			//moon layers
			_layers.push(createLayer(MOON_LAYER_1, .025, .50, width, height, _lookup));
			_layers.push(createLayer(MOON_LAYER_2, .03, .75, width, height, _lookup));
			_layers.push(createLayer(MOON_LAYER_3, .035, 1, width, height, _lookup));

			//asteroid layers
			_layers.push(createLayer(ASTEROID_LAYER_1, .13, 1.1, width, height, _lookup));
			_layers.push(createLayer(ASTEROID_LAYER_2, .15, 1.1, width, height, _lookup));

			//fog layers
			_layers.push(createLayer(FOG_LAYER, .25, 1, width, height, _lookup));

			//debris layer
			_layers.push(createLayer(DEBRIS_LAYER, .35, 1, width, height, _lookup));
		}

		private function createLayer( layer:int, parallaxSpeed:Number, scale:Number, width:Number, height:Number, lookup:Dictionary ):BackgroundLayer
		{
			var bgLayer:BackgroundLayer = ObjectPool.get(BackgroundLayer);
			bgLayer.init(layer, parallaxSpeed, scale, width, height, lookup);
			return bgLayer;
		}

		public function get ready():Boolean  { return _initialized; }

		override public function removeFromGame( game:Game ):void
		{
			uninitialize();
			_game = null;
			quadrantSignal.remove(onVisibleHashChanged);
			quadrantSignal = null;
			sceneModel.cleanup();
			sceneModel = null;
			backgroundFactory = null;
			_readySignal.removeAll();
			_readySignal = null;
			viewStack = null;
			_oldIds.length = 0;
			_oldIds = null;
			_oldView = null;

			updateSpriteData(TypeEnum.BACKGROUND_ELEMENTS, "");

			for (var i:int = 0; i < _layers.length; i++)
			{
				ObjectPool.give(_layers[i]);
			}
			_layers.length = 0;

			sectorModel = null;
		}
	}
}
