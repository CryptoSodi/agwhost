package com.game.entity.components.battle
{
	import org.ash.core.Entity;

	public class ActiveDefense
	{
		public static const BEAM:int   = 0;
		public static const FLAK:int   = 1;
		public static const SHIELD:int = 2;

		public var alphaDelta:Number;
		public var alphaStart:Number;
		public var animationLength:Number;
		public var animationTime:Number;
		public var baseWidth:int       = 256;
		public var followShipRotation:Boolean;
		public var growSpeed:Number;
		public var hitLocationX:int;
		public var hitLocationY:int;
		public var owner:Entity;
		public var ownerID:String;
		public var ready:Boolean;
		public var scaleDelta:Number;
		public var scaleStart:Number;
		public var sourceAttachPoint:String;
		public var strength:Number;
		public var type:int;

		public function init( type:int, owner:Entity, sourceAttachPoint:String ):void
		{
			this.animationLength = animationLength;
			alphaDelta = alphaStart = animationTime = 0;
			this.followShipRotation = false;
			this.owner = owner;
			this.ownerID = owner.id;
			this.growSpeed = 1;
			this.strength = 0;
			this.sourceAttachPoint = sourceAttachPoint;
			hitLocationX = hitLocationY = 0;
			ready = false;
			this.type = type;

			if (type == BEAM)
			{
				animationLength = .4;
				alphaStart = 1;
				alphaDelta = -1;
			} else if (type == FLAK)
			{
				animationLength = .25;
				alphaStart = 1;
				alphaDelta = 1;
				scaleDelta = .5;
				scaleStart = .5;
			}
		}

		public function destroy():void
		{
			owner = null;
		}
	}
}
