package com.game.entity.components.battle
{
	public class Beam
	{
		public var attackHit:Boolean;
		public var baseWidth:int = 256;
		public var followShipRotation:Boolean;
		public var growSpeed:Number;
		public var hitLocationX:int;
		public var hitLocationY:int;
		public var hitTarget:String;
		public var maxRange:Number;
		public var ownerID:String;
		public var strength:Number;
		public var targetID:String;
		public var sourceAttachPoint:String;
		public var targetAttachPoint:String;
		public var targetScatterX:Number;
		public var targetScatterY:Number;
		public var visibleHitCounter:int;

		public function init( ownerID:String, targetID:String, sourceAttachPoint:String, targetAttachPoint:String, targetScatterX:Number = 0, targetScatterY:Number = 0, maxRange:Number = 0, attackHit:Boolean =
							  true, growSpeed:Number = .2, followShipRotation:Boolean = false ):void
		{
			this.followShipRotation = followShipRotation;
			this.ownerID = ownerID;
			this.growSpeed = growSpeed;
			this.strength = 0;
			this.targetID = targetID;
			this.sourceAttachPoint = sourceAttachPoint;
			this.targetAttachPoint = targetAttachPoint;
			this.targetScatterX = targetScatterX;
			this.targetScatterY = targetScatterY;
			this.maxRange = maxRange;
			this.attackHit = attackHit;
			visibleHitCounter = 0;
			hitLocationX = hitLocationY = 0;
		}
	}
}
