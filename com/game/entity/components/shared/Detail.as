package com.game.entity.components.shared
{
	import com.model.asset.AssetVO;
	import com.model.prototype.IPrototype;

	public class Detail
	{
		public var assetVO:AssetVO;
		public var category:String;
		public var level:int;
		public var ownerID:String;
		public var prototypeVO:IPrototype;
		public var baseLevel:uint;
		public var waypointType:String;
		public var baseRatingTech:uint;
		public var maxPlayersPerFaction:uint;

		public function init( category:String, asset:AssetVO, prototype:IPrototype = null, ownerID:String = '', baseLevel:uint = 0, waypointType:String = '', baseRatingTech:uint = 0 ):void
		{
			this.category = category;
			this.assetVO = asset;
			this.prototypeVO = prototype;
			this.ownerID = ownerID;
			this.baseLevel = baseLevel;
			this.waypointType = waypointType;
			this.baseRatingTech = baseRatingTech;
			this.maxPlayersPerFaction = 0;
		}

		public function get spriteName():String  { return assetVO ? assetVO.spriteName : ''; }
		public function get type():String  { return assetVO ? assetVO.type : ''; }

		public function destroy():void
		{
			assetVO = null;
			prototypeVO = null;
			ownerID = '';
		}
	}
}
