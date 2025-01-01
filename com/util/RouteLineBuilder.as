package com.util
{
	import com.Application;
	import com.enum.TypeEnum;
	import com.game.entity.components.shared.Animation;
	import com.game.entity.components.shared.Move;
	import com.game.entity.components.shared.Position;
	import com.model.asset.AssetModel;
	import com.model.asset.ISpritePack;
	import com.model.asset.ISpriteSheet;
	import com.model.asset.SpriteSheet;
	import com.service.loading.LoadPriority;

	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display3D.Context3DTextureFormat;
	import flash.geom.Point;

	import org.ash.core.Entity;
	import org.starling.utils.getNextPowerOfTwo;

	public class RouteLineBuilder
	{
		private static const LINE_WIDTH:int       = 3;
		private static const LINE_COLOR:uint      = 0xffffff;
		private static const LINE_ALPHA:Number    = 0.5;

		public static const OUTLINE_WIDTH:int     = 9;
		private static const OUTLINE_ALPHA:Number = 0.6;
		private static const LINE_BASE_LENGTH:int = 100;

		private var _assetModel:AssetModel;

		public function drawRouteLine():String
		{
			var name:String       = TypeEnum.ROUTE_LINE;
			if (_assetModel.getEntityData(TypeEnum.ROUTE_LINE) != null)
				return name;

			//add asset data for the route line
			_assetModel.addGameAssetData(InteractEntityUtil.createPrototype(TypeEnum.ROUTE_LINE));
			//create a sprite pack and sprite sheet for the line
			var temp:Sprite       = new Sprite();
			var sp:ISpritePack    = _assetModel.getSpritePack(TypeEnum.ROUTE_LINE, false, null, LoadPriority.LOW, Context3DTextureFormat.BGRA);
			var ss:ISpriteSheet   = _assetModel.getSpriteSheet(name);
			sp.addSpriteSheet(ss);

			var outlineColor:uint = AllegianceUtil.instance.getPlayerColor();
			temp.graphics.beginFill(outlineColor, OUTLINE_ALPHA);
			temp.graphics.lineStyle(0, 0, 0);
			temp.graphics.drawRect(0, 0, LINE_BASE_LENGTH, OUTLINE_WIDTH);
			temp.graphics.endFill();

			var offset:Number     = (OUTLINE_WIDTH - LINE_WIDTH) / 2;
			temp.graphics.beginFill(LINE_COLOR, LINE_ALPHA);
			temp.graphics.drawRect(0, offset, LINE_BASE_LENGTH, LINE_WIDTH);
			temp.graphics.endFill();

			var xml:XML           = new XML(<TextureAtlas></TextureAtlas>);
			InteractEntityUtil.updateXML(xml, name, 0, 0, LINE_BASE_LENGTH, temp.height);
			var bmd:BitmapData;
			if (Application.STARLING_ENABLED)
			{
				bmd = new BitmapData(getNextPowerOfTwo(LINE_BASE_LENGTH), getNextPowerOfTwo(temp.height), true, 0);
				bmd.draw(temp, null, null, null, null, true);
				//add the bitmapdata to the assetmodel so that it can be used by the animation component
				_assetModel.initSpriteSheet(name, bmd, xml);
			} else
			{
				//if we're in software mode we want the spritesheet to use the bitmapdata directly
				//otherwise it would create a new one which would be inefficient
				bmd = new BitmapData(LINE_BASE_LENGTH, temp.height, true, 0);
				bmd.draw(temp, null, null, null, null, true);
				_assetModel.initSpriteSheet(name, bmd, xml, false);
				SpriteSheet(ss).addFrame(name, 0, bmd, true);
			}
			return name;
		}

		public static function adjustRotation( routeLine:Entity, destination:Point ):void
		{
			var position:Position = routeLine.get(Position);
			position.rotation = Math.atan2(destination.y - position.y, destination.x - position.x);
		}

		/**
		 * Updates a route line to match the position of a ship, & tweaks the scale so the length is correct.
		 *
		 * @param routeLine		The routeline entity
		 * @param ship			The ship to match
		 */
		public static function updateRouteLine( routeLine:Entity, ship:Entity ):void
		{
			// Match coordinates
			var move:Move             = ship.get(Move);
			var shipPosition:Position = ship.get(Position);
			var linePosition:Position = routeLine.get(Position);
			linePosition.x = shipPosition.x;
			linePosition.y = shipPosition.y;

			// Adjust the length of the line
			var animation:Animation   = routeLine.get(Animation);
			var point:Point           = new Point(shipPosition.x - move.destination.x, shipPosition.y - move.destination.y);
			animation.scaleX = point.length / RouteLineBuilder.LINE_BASE_LENGTH;
		}

		[Inject]
		public function set assetModel( v:AssetModel ):void  { _assetModel = v; }
	}
}
