package com.util
{
	import com.Application;
	import com.enum.SlotComponentEnum;
	import com.enum.TypeEnum;
	import com.game.entity.components.battle.Ship;
	import com.game.entity.nodes.shared.OwnedNode;
	import com.game.entity.nodes.battle.ship.IShipNode;
	import com.game.entity.nodes.battle.ship.ShipNode;
	import com.game.entity.components.shared.Detail;
	import com.game.entity.components.battle.Modules;
	import com.model.asset.AssetModel;
	import com.model.asset.ISpritePack;
	import com.model.asset.ISpriteSheet;
	import com.model.asset.SpriteSheet;
	import com.model.fleet.FleetModel;
	import com.model.fleet.ShipVO;
	import com.model.player.CurrentUser;
	import com.model.prototype.IPrototype;
	import com.model.prototype.PrototypeModel;
	import com.model.prototype.PrototypeVO;
	import com.service.loading.LoadPriority;
	import com.util.statcalc.StatCalcUtil;
	
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.GradientType;
	import flash.display3D.Context3DTextureFormat;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import org.starling.utils.getNextPowerOfTwo;

	public class RangeBuilder
	{
		public static const SELECTION_SIZE:int = 1;
		
		public static var COLOR_IMPERIUM_BASE:uint     = 0xC0FF27;
		private static const ALPHA:Number      = 0.07;
		private static const OFFSET:int        = 10;

		private var _allegianceUtil:AllegianceUtil;
		private var _assetModel:AssetModel;
		private var _centers:Dictionary        = new Dictionary();
		private var _fleetModel:FleetModel;
		private var _rangeCache:Dictionary     = new Dictionary();

		/**
		 * Draws a heat map of weapon ranges of a ship
		 * @param node The ship to build a range for
		 */
		public function buildRangeFromNodeOnly( node:OwnedNode ):void
		{
			return;
			/**/
			//var vo:ShipVO                   = _fleetModel.getShip(node.entity.id);
			//if (vo == null)
				//return;
			if(!node.entity.has(Detail))
				return;
			if(!node.entity.has(Modules))
				return;
			
			var detail:Detail = node.entity.get(Detail);
			var modules:Modules = node.entity.get(Modules);
			
			var vo:IPrototype = detail.prototypeVO;
			if (vo == null)
				return;
			/*if (modules)
			{
				for (var weaponidx:int = 0; weaponidx < update.weapons.modified.length; ++weaponidx)
				{
					var weapon:WeaponData = WeaponData(update.weapons.modified[weaponidx]);
					modules.moduleStates[weapon.moduleIdx] = weapon.weaponState;
				}
			}*/
			//var modules:Modules    = node.entity.get("Modules");
			/*var apDetail:Detail    = node.detail;
			var attachPoints:Array = apDetail.prototypeVO.getValue("attachPoints");
			
			for each (var attachPoint:String in attachPoints)
			{
				var attachPointProto:IPrototype = _prototypeModel.getAttachPoint(attachPoint);
				var attachPointType:String = attachPointProto.getValue("attachPointType");
				var moduleProto:IPrototype = getModuleByAttachPoint(node, attachPoint);
				var slotIndex:Number = getModuleIndexByAttachPoint(node, attachPoint);
			}*/
			//var weaponPrototypes:Dictionary = vo.modules;
			var name:String                 = '';
			var slotName:String;
			var slots:Array                 = vo.getValue('slots');
			//get the name of this range
			for (var i:int = 0; i < slots.length; i++)
			{
				slotName = slots[i];
				prototypeVO = modules.getModuleByAttachPoint(slotName);//weaponPrototypes[slotName];
				if (prototypeVO && (
					prototypeVO.getValue('slotType') == SlotComponentEnum.SLOT_TYPE_WEAPON || 
					prototypeVO.getValue('slotType') == SlotComponentEnum.SLOT_TYPE_ARC || 
					prototypeVO.getValue('slotType') == SlotComponentEnum.SLOT_TYPE_DRONE ||
					prototypeVO.getValue('slotType') == SlotComponentEnum.SLOT_TYPE_SPINAL))
					name += prototypeVO.name;
			}
			//let the ship know which range it should use
			Ship(node.entity.get(Ship)).rangeReference = name;
			//we only want to build the range if it is new
			if (_rangeCache.hasOwnProperty(name))
				return;
			_rangeCache[name] = true;
			
			var tempRange:Sprite            = new Sprite();
			var tempOutline:Sprite          = new Sprite();
			var color:uint                  = _allegianceUtil.getFactionColor(CurrentUser.battleFaction);
			var roundColor:uint             = _allegianceUtil.getFactionRangeColor(CurrentUser.battleFaction);
			var pivotRange:Number           = 0;
			var slotProto:IPrototype;
			var slotAttachPoint:IPrototype;
			var startAngle:Number           = 0;
			var slotX:Number                = 0;
			var slotY:Number                = 0;
			var prototypeVO:IPrototype;
			var key:String;
			var tempRangeCache:Dictionary   = new Dictionary();
			var maxRange:Number;
			var minRange:Number;
			
			//cycle through the modules and build the weapon ranges
			for (i = 0; i < slots.length; i++)
			{
				slotName = slots[i];
				prototypeVO = modules.getModuleByAttachPoint(slotName);//weaponPrototypes[slotName];
				if (prototypeVO && (
					prototypeVO.getValue('slotType') == SlotComponentEnum.SLOT_TYPE_WEAPON || 
					prototypeVO.getValue('slotType') == SlotComponentEnum.SLOT_TYPE_ARC || 
					prototypeVO.getValue('slotType') == SlotComponentEnum.SLOT_TYPE_DRONE ||
					prototypeVO.getValue('slotType') == SlotComponentEnum.SLOT_TYPE_SPINAL))
				{
					slotProto = PrototypeModel.instance.getSlotPrototype(slotName);
					var attachPointGroup:String = vo.getValue('attachGroup');
					var attachPointType:String = slotProto.getValue('attachPointType');
					slotAttachPoint = PrototypeModel.instance.getAttachPointByType( attachPointGroup, attachPointType );
					//slotAttachPoint = PrototypeModel.instance.getAttachPoint(slotName);
					
					var angleTolerance:Number = prototypeVO.getValue('angleTolerance');
					var slotPivotRange:Number = slotProto.getValue('pivotRange');
					pivotRange = angleTolerance + slotPivotRange;
					
					slotX = slotAttachPoint.getValue('x');
					slotY = slotAttachPoint.getValue('y');
					
					maxRange = prototypeVO.getValue('maxRange');//StatCalcUtil.entityStatCalc(vo, 'maxRange', 0, prototypeVO, slotName);
					minRange = prototypeVO.getValue('minRange');//StatCalcUtil.entityStatCalc(vo, 'minRange', 0, prototypeVO, slotName);
					
					if (pivotRange < 180)
					{
						//draw a wedge
						if (pivotRange == 0)
							pivotRange = 5; //This is the default aim tolerance according to the server
						
						pivotRange *= 2;
						startAngle = slotAttachPoint.getValue('rotation') - (pivotRange / 2);
						tempOutline.addChild(drawWedge(maxRange, pivotRange, minRange, startAngle, slotX, slotY, color, 1));
						tempRange.addChild(drawWedge(maxRange, pivotRange, minRange, startAngle, slotX, slotY, roundColor, ALPHA));
					} else
					{
						//draw a circle but only if the min and max range differ from one that we've already drawn so we don't overlap needlessly
						key = minRange + "-" + maxRange;
						if (!tempRangeCache[key])
						{
							tempOutline.addChild(drawMinMaxRangeCircle(minRange, maxRange, color, 1, 0, 0, true));
							tempRange.addChild(drawMinMaxRangeCircle(minRange, maxRange, roundColor, ALPHA, 0, 0));
							tempRangeCache[key] = true;
						}
					}
				}
			}
			
			//put a knockout glow on the outline and add it into the range
			tempOutline.filters = [new GlowFilter(color, .6, 6, 6, 5, 1, false, true)];
			tempRange.addChildAt(tempOutline, 0);
			
			//add asset data for the ship range
			_assetModel.addGameAssetData(InteractEntityUtil.createPrototype(TypeEnum.SHIP_RANGE));
			//create the spritepack and the spritesheet
			var sp:ISpritePack              = _assetModel.getSpritePack(TypeEnum.SHIP_RANGE, false, null, LoadPriority.LOW, Context3DTextureFormat.BGRA);
			var ss:ISpriteSheet             = _assetModel.getSpriteSheet(name);
			sp.addSpriteSheet(ss);
			
			//add to the holder and convert to a bitmap
			var dw:Number                   = tempRange.width + OFFSET * 2;
			var dh:Number                   = tempRange.height + OFFSET * 2;
			var bounds:Rectangle            = tempRange.getBounds(Application.STAGE);
			var matrix:Matrix               = new Matrix(1, 0, 0, 1, -bounds.x + OFFSET, -bounds.y + OFFSET);
			var xml:XML                     = new XML(<TextureAtlas></TextureAtlas>);
			InteractEntityUtil.updateXML(xml, name, 0, 0, dw, dh);
			var bmd:BitmapData;
			if (Application.STARLING_ENABLED)
			{
				bmd = new BitmapData(getNextPowerOfTwo(dw), getNextPowerOfTwo(dh), true, 0);
				bmd.draw(tempRange, matrix, null, null, null, true);
				//add the bitmapdata to the assetmodel so that it can be used by the animation component
				_assetModel.initSpriteSheet(name, bmd, xml);
			} else
			{
				//if we're in software mode we want the spritesheet to use the bitmapdata directly
				//otherwise it would create a new one which would be inefficient			
				bmd = new BitmapData(dw, dh, true, 0);
				bmd.draw(tempRange, matrix, null, null, null, true);
				_assetModel.initSpriteSheet(name, bmd, xml, false);
				SpriteSheet(ss).addFrame(name, 0, bmd, true);
			}
			//save out the center point for this range
			_centers[name] = new Point(-bounds.x + OFFSET, -bounds.y + OFFSET);
			
			//*/
		}
		
		public function buildRangeFromNode( node:OwnedNode ):void
		{
			var vo:ShipVO                   = _fleetModel.getShip(node.entity.id);
			if (vo == null)
				return;
			var weaponPrototypes:Dictionary = vo.modules;
			var name:String                 = '';
			var slotName:String;
			var slots:Array                 = vo.prototypeVO.getValue('slots');
			//get the name of this range
			for (var i:int = 0; i < slots.length; i++)
			{
				slotName = slots[i];
				prototypeVO = weaponPrototypes[slotName];
				if (prototypeVO && (
					prototypeVO.getValue('slotType') == SlotComponentEnum.SLOT_TYPE_WEAPON || 
					prototypeVO.getValue('slotType') == SlotComponentEnum.SLOT_TYPE_ARC || 
					prototypeVO.getValue('slotType') == SlotComponentEnum.SLOT_TYPE_DRONE ||
					prototypeVO.getValue('slotType') == SlotComponentEnum.SLOT_TYPE_SPINAL))
					name += prototypeVO.name;
			}
			//let the ship know which range it should use
			Ship(node.entity.get(Ship)).rangeReference = name;
			//we only want to build the range if it is new
			if (_rangeCache.hasOwnProperty(name))
				return;
			_rangeCache[name] = true;

			var tempRange:Sprite            = new Sprite();
			var tempOutline:Sprite          = new Sprite();
			var color:uint                  = _allegianceUtil.getFactionColor(CurrentUser.battleFaction);
			var roundColor:uint             = _allegianceUtil.getFactionRangeColor(CurrentUser.battleFaction);
			var pivotRange:Number           = 0;
			var slotProto:IPrototype;
			var slotAttachPoint:IPrototype;
			var startAngle:Number           = 0;
			var slotX:Number                = 0;
			var slotY:Number                = 0;
			var prototypeVO:IPrototype;
			var key:String;
			var tempRangeCache:Dictionary   = new Dictionary();
			var maxRange:Number;
			var minRange:Number;

			//cycle through the modules and build the weapon ranges
			for (i = 0; i < slots.length; i++)
			{
				slotName = slots[i];
				prototypeVO = weaponPrototypes[slotName];
				if (prototypeVO && (
					prototypeVO.getValue('slotType') == SlotComponentEnum.SLOT_TYPE_WEAPON || 
					prototypeVO.getValue('slotType') == SlotComponentEnum.SLOT_TYPE_ARC || 
					prototypeVO.getValue('slotType') == SlotComponentEnum.SLOT_TYPE_DRONE ||
					prototypeVO.getValue('slotType') == SlotComponentEnum.SLOT_TYPE_SPINAL))
				{
					slotProto = PrototypeModel.instance.getSlotPrototype(slotName);
					var attachPointGroup:String = vo.getValue('attachGroup');
					var attachPointType:String = slotProto.getValue('attachPointType');
					slotAttachPoint = PrototypeModel.instance.getAttachPointByType( attachPointGroup, attachPointType );
					//slotAttachPoint = PrototypeModel.instance.getAttachPoint(slotName);

					var angleTolerance:Number = prototypeVO.getValue('angleTolerance');
					var slotPivotRange:Number = slotProto.getValue('pivotRange');
					pivotRange = angleTolerance + slotPivotRange;

					slotX = slotAttachPoint.getValue('x');
					slotY = slotAttachPoint.getValue('y');

					maxRange = StatCalcUtil.entityStatCalc(vo, 'maxRange', 0, prototypeVO, slotName);
					minRange = StatCalcUtil.entityStatCalc(vo, 'minRange', 0, prototypeVO, slotName);

					if (pivotRange < 180)
					{
						//draw a wedge
						if (pivotRange == 0)
							pivotRange = 5; //This is the default aim tolerance according to the server

						pivotRange *= 2;
						startAngle = slotAttachPoint.getValue('rotation') - (pivotRange / 2);
						tempOutline.addChild(drawWedge(maxRange, pivotRange, minRange, startAngle, slotX, slotY, color, 1));
						tempRange.addChild(drawWedge(maxRange, pivotRange, minRange, startAngle, slotX, slotY, roundColor, ALPHA));
					} else
					{
						//draw a circle but only if the min and max range differ from one that we've already drawn so we don't overlap needlessly
						key = minRange + "-" + maxRange;
						if (!tempRangeCache[key])
						{
							tempOutline.addChild(drawMinMaxRangeCircle(minRange, maxRange, color, 1, 0, 0, true));
							tempRange.addChild(drawMinMaxRangeCircle(minRange, maxRange, roundColor, ALPHA, 0, 0));
							tempRangeCache[key] = true;
						}
					}
				}
			}

			//put a knockout glow on the outline and add it into the range
			tempOutline.filters = [new GlowFilter(color, .6, 6, 6, 5, 1, false, true)];
			tempRange.addChildAt(tempOutline, 0);

			//add asset data for the ship range
			_assetModel.addGameAssetData(InteractEntityUtil.createPrototype(TypeEnum.SHIP_RANGE));
			//create the spritepack and the spritesheet
			var sp:ISpritePack              = _assetModel.getSpritePack(TypeEnum.SHIP_RANGE, false, null, LoadPriority.LOW, Context3DTextureFormat.BGRA);
			var ss:ISpriteSheet             = _assetModel.getSpriteSheet(name);
			sp.addSpriteSheet(ss);

			//add to the holder and convert to a bitmap
			var dw:Number                   = tempRange.width + OFFSET * 2;
			var dh:Number                   = tempRange.height + OFFSET * 2;
			var bounds:Rectangle            = tempRange.getBounds(Application.STAGE);
			var matrix:Matrix               = new Matrix(1, 0, 0, 1, -bounds.x + OFFSET, -bounds.y + OFFSET);
			var xml:XML                     = new XML(<TextureAtlas></TextureAtlas>);
			InteractEntityUtil.updateXML(xml, name, 0, 0, dw, dh);
			var bmd:BitmapData;
			if (Application.STARLING_ENABLED)
			{
				bmd = new BitmapData(getNextPowerOfTwo(dw), getNextPowerOfTwo(dh), true, 0);
				bmd.draw(tempRange, matrix, null, null, null, true);
				//add the bitmapdata to the assetmodel so that it can be used by the animation component
				_assetModel.initSpriteSheet(name, bmd, xml);
			} else
			{
				//if we're in software mode we want the spritesheet to use the bitmapdata directly
				//otherwise it would create a new one which would be inefficient			
				bmd = new BitmapData(dw, dh, true, 0);
				bmd.draw(tempRange, matrix, null, null, null, true);
				_assetModel.initSpriteSheet(name, bmd, xml, false);
				SpriteSheet(ss).addFrame(name, 0, bmd, true);
			}
			//save out the center point for this range
			_centers[name] = new Point(-bounds.x + OFFSET, -bounds.y + OFFSET);
		}

		public function drawStarbaseRange( radius:Number, minRange:Number = 0 ):String
		{
			var name:String        = radius + "-" + minRange;
			if (_rangeCache[name])
				return name;
			var tempOutline:Sprite = new Sprite();
			var tempRange:Sprite   = new Sprite();
			var color:uint         = _allegianceUtil.getFactionColor(CurrentUser.faction);

			//Fill for the outline
			tempOutline.addChild(drawMinMaxRangeCircle(minRange, radius, color, 1, 0, 0, true))
			tempOutline.filters = [new GlowFilter(color, .6, 6, 6, 5, 1, false, true)];
			tempRange.addChild(tempOutline);
			tempRange.addChild(drawMinMaxRangeCircle(minRange, radius, 0xcccccc, ALPHA, 0, 0, true));

			if (!_assetModel.getEntityData(TypeEnum.BASE_RANGE))
				_assetModel.addGameAssetData(InteractEntityUtil.createPrototype(TypeEnum.BASE_RANGE));
			var sp:ISpritePack     = _assetModel.getSpritePack(TypeEnum.BASE_RANGE, false, null, LoadPriority.LOW, Context3DTextureFormat.BGRA);
			var ss:ISpriteSheet    = _assetModel.getSpriteSheet(name);
			sp.addSpriteSheet(ss);

			//add to the holder and convert to a bitmap
			var dw:Number          = tempRange.width + OFFSET * 2;
			var dh:Number          = tempRange.height + OFFSET * 2;
			var bounds:Rectangle   = tempRange.getBounds(Application.STAGE);
			var matrix:Matrix      = new Matrix(1, 0, 0, 1, -bounds.x + OFFSET, -bounds.y + OFFSET);
			var xml:XML            = new XML(<TextureAtlas></TextureAtlas>);
			InteractEntityUtil.updateXML(xml, name, 0, 0, dw, dh);
			var bmd:BitmapData;
			if (Application.STARLING_ENABLED)
			{
				bmd = new BitmapData(getNextPowerOfTwo(dw), getNextPowerOfTwo(dh), true, 0);
				bmd.draw(tempRange, matrix, null, null, null, true);
				//add the bitmapdata to the assetmodel so that it can be used by the animation component
				_assetModel.initSpriteSheet(name, bmd, xml);
			} else
			{
				//if we're in software mode we want the spritesheet to use the bitmapdata directly
				//otherwise it would create a new one which would be inefficient	
				bmd = new BitmapData(dw, dh, true, 0);
				bmd.draw(tempRange, matrix, null, null, null, true);
				_assetModel.initSpriteSheet(name, bmd, xml, false);
				SpriteSheet(ss).addFrame(name, 0, bmd, true);
			}
			_centers[name] = new Point(-bounds.x + OFFSET, -bounds.y + OFFSET);
			_rangeCache[name] = true;

			return name;
		}

		public function drawPylonRange( radius:Number ):String
		{
			var name:String        = "Pylon" + radius;
			if (_rangeCache.hasOwnProperty(name))
				return name;
			var tempOutline:Sprite = new Sprite();
			var tempRange:Sprite   = new Sprite();
			var color:uint         = _allegianceUtil.getFactionColor(CurrentUser.faction);

			//Fill for the outline
			radius *= 90;
			tempOutline.addChild(drawRectangle(radius, 20, color, 1, 0, 0, 45));
			tempOutline.addChild(drawRectangle(radius, 20, color, 1, 0, 0, 135));
			tempOutline.addChild(drawRectangle(radius, 20, color, 1, 0, 0, 225));
			tempOutline.addChild(drawRectangle(radius, 20, color, 1, 0, 0, 315));
			tempOutline.filters = [new GlowFilter(color, .6, 6, 6, 5, 1, false, true)];
			tempRange.addChild(tempOutline);
			tempRange.addChild(drawRectangle(radius, 20, 0xcccccc, ALPHA, 0, 0, 45));
			tempRange.addChild(drawRectangle(radius, 20, 0xcccccc, ALPHA, 0, 0, 135));
			tempRange.addChild(drawRectangle(radius, 20, 0xcccccc, ALPHA, 0, 0, 225));
			tempRange.addChild(drawRectangle(radius, 20, 0xcccccc, ALPHA, 0, 0, 315));

			if (!_assetModel.getEntityData(TypeEnum.BASE_RANGE))
				_assetModel.addGameAssetData(InteractEntityUtil.createPrototype(TypeEnum.BASE_RANGE));
			var sp:ISpritePack     = _assetModel.getSpritePack(TypeEnum.BASE_RANGE, false, null, LoadPriority.LOW, Context3DTextureFormat.BGRA);
			var ss:ISpriteSheet    = _assetModel.getSpriteSheet(name);
			sp.addSpriteSheet(ss);

			//add to the holder and convert to a bitmap
			var dw:Number          = tempRange.width + OFFSET * 2;
			var dh:Number          = tempRange.height + OFFSET * 2;
			var bounds:Rectangle   = tempRange.getBounds(Application.STAGE);
			var matrix:Matrix      = new Matrix(1, 0, 0, 1, -bounds.x + OFFSET, -bounds.y + OFFSET);
			var xml:XML            = new XML(<TextureAtlas></TextureAtlas>);
			InteractEntityUtil.updateXML(xml, name, 0, 0, dw, dh);
			var bmd:BitmapData;
			if (Application.STARLING_ENABLED)
			{
				bmd = new BitmapData(getNextPowerOfTwo(dw), getNextPowerOfTwo(dh), true, 0);
				bmd.draw(tempRange, matrix, null, null, null, true);
				//add the bitmapdata to the assetmodel so that it can be used by the animation component
				_assetModel.initSpriteSheet(name, bmd, xml);
			} else
			{
				//if we're in software mode we want the spritesheet to use the bitmapdata directly
				//otherwise it would create a new one which would be inefficient	
				bmd = new BitmapData(dw, dh, true, 0);
				bmd.draw(tempRange, matrix, null, null, null, true);
				_assetModel.initSpriteSheet(name, bmd, xml, false);
				SpriteSheet(ss).addFrame(name, 0, bmd, true);
			}
			_centers[name] = new Point(-bounds.x + OFFSET, -bounds.y + OFFSET);
			_rangeCache[name] = true;

			return name;
		}

		public function drawShipSelectionBox():String
		{
			var name:String     = TypeEnum.SHIP_SELECTION_RANGE;

			if (_rangeCache.hasOwnProperty(name))
				return name;

			if (!_assetModel.getEntityData(TypeEnum.SHIP_SELECTION_RANGE))
				_assetModel.addGameAssetData(InteractEntityUtil.createPrototype(TypeEnum.SHIP_SELECTION_RANGE));

			var sp:ISpritePack  = _assetModel.getSpritePack(TypeEnum.SHIP_SELECTION_RANGE, false);
			var ss:ISpriteSheet = _assetModel.getSpriteSheet(name);
			sp.addSpriteSheet(ss);

			var c:uint          = _allegianceUtil.getFactionColor(CurrentUser.faction);
			var s:Shape         = new Shape();
			s.graphics.beginFill(c, 0.25);
			s.graphics.drawRect(0, 0, SELECTION_SIZE, SELECTION_SIZE);
			s.graphics.endFill();

			var xml:XML         = new XML(<TextureAtlas></TextureAtlas>);
			InteractEntityUtil.updateXML(xml, name, 0, 0, SELECTION_SIZE, SELECTION_SIZE);

			if (Application.STARLING_ENABLED)
			{
				var bmpd:BitmapData = new BitmapData(getNextPowerOfTwo(SELECTION_SIZE), getNextPowerOfTwo(SELECTION_SIZE), true, 0);
				bmpd.draw(s, null, null, null, null, true);
				_assetModel.initSpriteSheet(name, bmpd, xml);
			} else
			{
				bmpd = new BitmapData(SELECTION_SIZE, SELECTION_SIZE, true, 0);
				bmpd.draw(s, null, null, null, null, true);
				_assetModel.initSpriteSheet(name, bmpd, xml, false);
				SpriteSheet(ss).addFrame(name, 0, bmpd, true);
			}

			_rangeCache[name] = true;

			return name;
		}

		public function getCenter( id:String ):Point
		{
			if (_centers.hasOwnProperty(id))
				return _centers[id];
			return new Point();
		}

		private function drawMinMaxRangeCircle( minRange:Number, maxRange:Number, color:uint = 0xffffff, alpha:Number = 1, slotX:Number = 0, slotY:Number = 0, ignoreKeyCheck:Boolean = false ):Sprite
		{
			var canvas:Sprite = new Sprite();

			//Fill the shapes about to be drawn with white at an alpha of .06
			canvas.graphics.beginFill(color, alpha);

			canvas.graphics.drawCircle(slotX, slotY, Number(maxRange));
			canvas.graphics.drawCircle(slotX, slotY, Number(minRange));
			canvas.graphics.endFill();

			return canvas;
		}
		private function drawMinMaxRangeCircleGradient( minRange:Number, maxRange:Number, color:uint = 0xffffff, alpha:Number = 1, slotX:Number = 0, slotY:Number = 0, ignoreKeyCheck:Boolean = false ):Sprite
		{
			var gType:String = GradientType.RADIAL;  
			
			var matrix:Matrix = new Matrix();  
			matrix.createGradientBox(maxRange,maxRange,0,0,0);  
			
			var gColors:Array = [color, color];  
			var gAlphas:Array = [alpha,alpha]; 
			//var gAlphas:Array = [1,1];   
			var gRatio:Array = [0,255]; 
			
			var canvas:Sprite = new Sprite();
			
			//Fill the shapes about to be drawn with white at an alpha of .06
			canvas.graphics.beginGradientFill(gType,gColors,gAlphas,gRatio,matrix);
			//canvas.graphics.beginGradientFill(color, alpha);
			
			canvas.graphics.drawCircle(slotX, slotY, Number(maxRange));
			canvas.graphics.drawCircle(slotX, slotY, Number(minRange));
			canvas.graphics.endFill();
			
			return canvas;
		}

		private function drawWedge( radius:Number, arc:Number, minRange:Number = 0, startAngle:Number = 0, slotX:Number = 0, slotY:Number = 0, color:uint = 0xffffff, alpha:Number = .3 ):Sprite
		{
			var canvas:Sprite = new Sprite();
			canvas.graphics.beginFill(color, alpha);

			// Init vars
			var segAngle:Number, theta:Number, angle:Number, angleMid:Number, segs:Number, ax:Number, ay:Number, bx:Number, by:Number, cx:Number, cy:Number;
			// limit sweep to reasonable numbers
			if (Math.abs(arc) > 360)
			{
				arc = 360;
			}
			// Flash uses 8 segments per circle, to match that, we draw in a maximum
			// of 45 degree segments. First we calculate how many segments are needed
			// for our arc.
			segs = Math.ceil(Math.abs(arc) / 45);
			// Now calculate the sweep of each segment.
			segAngle = arc / segs;

			// The math requires radians rather than degrees. To convert from degrees
			// use the formula (degrees/180)*Math.PI to get radians.
			theta = -(segAngle / 180) * Math.PI;
			// convert angle startAngle to radians
			angle = -(startAngle / 180) * Math.PI;
			//convert arc to radians so we can get x2 and y2
			var radArc:Number = -(arc / 180) * Math.PI;
			//Start position
			var x:Number      = slotX + minRange * Math.cos(angle);
			var y:Number      = slotY + minRange * Math.sin(angle);
			//End position
			var x2:Number     = slotX + minRange * Math.cos(angle + radArc);
			var y2:Number     = slotY + minRange * Math.sin(angle + radArc);
			// move to x,y position
			canvas.graphics.moveTo(x, y);

			// draw the curve in segments no larger than 45 degrees.
			if (segs > 0)
			{
				// draw a line from the center to the start of the curve
				ax = Math.cos(startAngle / 180 * Math.PI) * radius;
				ay = Math.sin(-startAngle / 180 * Math.PI) * radius;
				canvas.graphics.lineTo(ax, ay);
				// Loop for drawing curve segments
				for (var i:int = 0; i < segs; ++i)
				{
					angle += theta;
					angleMid = angle - (theta / 2);
					bx = Math.cos(angle) * radius;
					by = Math.sin(angle) * radius;
					cx = Math.cos(angleMid) * (radius / Math.cos(theta / 2));
					cy = Math.sin(angleMid) * (radius / Math.cos(theta / 2));
					canvas.graphics.curveTo(cx, cy, bx, by);
				}
				// close the wedge by drawing a line to the center
				canvas.graphics.lineTo(x2, y2);
				canvas.graphics.lineTo(x, y);
			}

			return canvas;
		}

		private function drawRectangle( width:Number, height:Number, color:uint = 0xffffff, alpha:Number = 1, slotX:Number = 0, slotY:Number = 0, rotation:Number = 0 ):Sprite
		{
			var canvas:Sprite = new Sprite();
			canvas.graphics.beginFill(color, alpha);
			canvas.graphics.drawRect(0, height * -.5, width, height);
			canvas.graphics.endFill();
			canvas.x = slotX;
			canvas.y = slotY;
			canvas.rotation = rotation;
			return canvas;
		}

		[Inject]
		public function set allegianceUtil( v:AllegianceUtil ):void  { _allegianceUtil = v; }
		[Inject]
		public function set assetModel( v:AssetModel ):void  { _assetModel = v; }
		[Inject]
		public function set fleetModel( v:FleetModel ):void  { _fleetModel = v; }

		public function cleanup():void
		{
			for (var key:String in _centers)
			{
				_centers[key] = null;
				delete _centers[key];
			}
			for (key in _rangeCache)
			{
				_rangeCache[key] = null;
				delete _rangeCache[key];
			}
			_rangeCache = new Dictionary();
			//remove ship ranges
			_assetModel.removeSpritePack(_assetModel.getSpritePack(TypeEnum.SHIP_RANGE, false));
			_assetModel.removeGameAssetData(TypeEnum.SHIP_RANGE);
			//remove base ranges
			_assetModel.removeSpritePack(_assetModel.getSpritePack(TypeEnum.BASE_RANGE, false));
			_assetModel.removeGameAssetData(TypeEnum.BASE_RANGE);
		}
	}
}
